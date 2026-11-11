"""
Consultas das telas do painel: conta, alertas, paineis, turmas, area do
aluno, financeiro, administracao e parametros.

Mesmas regras de app/api/consultas.py: so parametros nomeados, nenhum SQL
montado com texto do usuario, variacao so por fragmentos constantes deste
arquivo, e cada consulta seleciona so as colunas que a tela usa.
"""

from sqlalchemy import text

# ---------------------------------------------------------------------------
# Conta e primeiro acesso
# ---------------------------------------------------------------------------

CONTA = text("""
    SELECT u.id_usuario, u.login, u.nome, u.email, u.perfil, u.id_aluno, u.id_professor, u.id_curso,
           c.nome AS curso, u.deve_trocar_senha, u.termo_versao, u.termo_aceito_em, u.ultimo_login,
           (SELECT count(*) FROM notificacoes n WHERE n.id_usuario = u.id_usuario AND n.lida_em IS NULL)
               AS notificacoes_nao_lidas
      FROM usuarios u
      LEFT JOIN cursos c ON c.id_curso = u.id_curso
     WHERE u.id_usuario = :id_usuario
""")

SENHA_DO_USUARIO = text("SELECT login, senha_hash FROM usuarios WHERE id_usuario = :id_usuario")

TROCAR_SENHA = text("""
    UPDATE usuarios
       SET senha_hash = :senha_hash, deve_trocar_senha = FALSE, senha_alterada_em = :agora
     WHERE id_usuario = :id_usuario
""")

ACEITAR_TERMO = text("""
    UPDATE usuarios SET termo_versao = :versao, termo_aceito_em = :agora WHERE id_usuario = :id_usuario
""")

NOTIFICACOES = text("""
    SELECT id_notificacao, criada_em, tipo, titulo, texto, id_alerta, lida_em
      FROM notificacoes
     WHERE id_usuario = :id_usuario
       AND (NOT CAST(:so_nao_lidas AS BOOLEAN) OR lida_em IS NULL)
     ORDER BY criada_em DESC, id_notificacao DESC
     LIMIT :limite OFFSET :deslocamento
""")

# So a propria notificacao: o id_usuario na condicao impede marcar a de outro.
MARCAR_LIDA = text("""
    UPDATE notificacoes SET lida_em = :agora
     WHERE id_notificacao = :id_notificacao AND id_usuario = :id_usuario AND lida_em IS NULL
""")

MARCAR_TODAS_LIDAS = text("""
    UPDATE notificacoes SET lida_em = :agora WHERE id_usuario = :id_usuario AND lida_em IS NULL
""")

CRIAR_NOTIFICACAO = text("""
    INSERT INTO notificacoes (id_usuario, criada_em, tipo, titulo, texto, id_alerta)
    VALUES (:id_usuario, :agora, :tipo, :titulo, :texto, :id_alerta)
""")

USUARIOS_ATIVOS_DO_PERFIL = text("""
    SELECT id_usuario FROM usuarios
     WHERE perfil = :perfil AND ativo
       AND (CAST(:id_curso AS VARCHAR) IS NULL OR id_curso = :id_curso)
""")

# ---------------------------------------------------------------------------
# Alertas (RN03, RF18, RF19, RF20)
# ---------------------------------------------------------------------------

_FILA_BASE = """
    SELECT a.id_alerta, a.id_aluno, al.nome_ficticio, al.semestre_atual, al.id_curso, a.tipo, a.nivel,
           a.situacao, a.criado_em, a.prazo_em, a.id_responsavel, u.nome AS responsavel, a.primeira_acao_em,
           a.encerrado_em, a.causa, a.desfecho, s.score, s.tendencia, s.fatores_principais,
           ult.momento AS ultima_acao_em, (a.situacao <> 'ENCERRADO' AND a.prazo_em < :agora) AS vencido
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
      LEFT JOIN vw_score_atual s ON s.id_aluno = a.id_aluno
      LEFT JOIN usuarios u ON u.id_usuario = a.id_responsavel
      LEFT JOIN LATERAL (SELECT max(e.momento) AS momento FROM alerta_eventos e
                          WHERE e.id_alerta = a.id_alerta AND e.tipo = 'ACAO') ult ON TRUE
     WHERE ((CAST(:situacao AS VARCHAR) IS NULL AND a.situacao <> 'ENCERRADO') OR a.situacao = :situacao)
       AND (CAST(:tipo AS VARCHAR) IS NULL OR a.tipo = :tipo)
       AND (CAST(:nivel AS VARCHAR) IS NULL OR a.nivel = :nivel)
       AND (CAST(:responsavel AS BIGINT) IS NULL OR a.id_responsavel = :responsavel)
       AND (NOT CAST(:sem_responsavel AS BOOLEAN) OR a.id_responsavel IS NULL)
       AND (NOT CAST(:so_vencidos AS BOOLEAN) OR (a.situacao <> 'ENCERRADO' AND a.prazo_em < :agora))
"""

# Escopo do Anexo E, no SQL: quem nao pode ver o alerta nem o recebe.
_ESCOPO_ALERTA = {
    "COORDENACAO": "AND al.id_curso = :id_curso",
    "NUCLEO_APOIO": "AND a.id_responsavel = :id_usuario",
    "DOCENTE": """AND a.tipo = 'PEDAGOGICO'
       AND EXISTS (SELECT 1 FROM matriculas m JOIN turmas t ON t.id_turma = m.id_turma
                    WHERE m.id_aluno = a.id_aluno AND t.id_professor = :id_professor)""",
    "FINANCEIRO": """AND a.tipo = 'PEDAGOGICO' AND s.fatores_principais @> '["financeiro"]'::jsonb""",
}

# RN03 e RF18: Critico antes de Alto; prazo mais proximo; score maior; piora
# antes de estabilidade; empate: ha mais tempo sem contato primeiro.
_ORDEM_FILA = """
     ORDER BY CASE a.nivel WHEN 'CRITICO' THEN 0 WHEN 'ALTO' THEN 1 WHEN 'INDETERMINADO' THEN 3 ELSE 2 END,
              a.prazo_em,
              s.score DESC NULLS LAST,
              CASE s.tendencia WHEN 'PIORA_SUSTENTADA' THEN 0 WHEN 'PIORA' THEN 1 WHEN 'ESTAVEL' THEN 2 ELSE 3 END,
              COALESCE(ult.momento, a.criado_em),
              a.id_alerta
"""


def consulta_fila(perfil: str):
    return text(_FILA_BASE + _ESCOPO_ALERTA[perfil] + _ORDEM_FILA + " LIMIT :limite OFFSET :deslocamento")


def consulta_total_fila(perfil: str):
    return text("SELECT count(*) FROM (" + _FILA_BASE + _ESCOPO_ALERTA[perfil] + ") q")


def consulta_alerta_no_escopo(perfil: str):
    """Mesmo filtro da fila, para um alerta so (inclusive encerrado)."""
    return text("""
    SELECT a.id_alerta, a.id_aluno, al.nome_ficticio, al.id_curso, al.idade, a.tipo, a.nivel, a.situacao,
           a.criado_em, a.prazo_em, a.id_responsavel, u.nome AS responsavel, a.atribuido_em, a.primeira_acao_em,
           a.encerrado_em, a.causa, a.desfecho, a.houve_contato, a.canal_contato, a.acoes_executadas,
           a.score_no_encerramento, a.id_score_origem
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
      LEFT JOIN vw_score_atual s ON s.id_aluno = a.id_aluno
      LEFT JOIN usuarios u ON u.id_usuario = a.id_responsavel
     WHERE a.id_alerta = :id_alerta
    """ + _ESCOPO_ALERTA[perfil] + " FOR UPDATE OF a")


EVENTOS_DO_ALERTA = text("""
    SELECT e.id_evento, e.momento, e.tipo, e.tipo_acao, e.descricao, e.visivel_aluno, e.id_usuario,
           u.nome AS autor, u.perfil AS perfil_autor
      FROM alerta_eventos e
      LEFT JOIN usuarios u ON u.id_usuario = e.id_usuario
     WHERE e.id_alerta = :id_alerta
     ORDER BY e.momento, e.id_evento
""")

REGISTRAR_EVENTO = text("""
    INSERT INTO alerta_eventos (id_alerta, momento, id_usuario, tipo, tipo_acao, descricao, visivel_aluno)
    VALUES (:id_alerta, :agora, :id_usuario, :tipo, :tipo_acao, :descricao, :visivel_aluno)
""")

ATRIBUIR_ALERTA = text("""
    UPDATE alertas SET id_responsavel = :id_responsavel, atribuido_em = :agora, atualizado_em = :agora
     WHERE id_alerta = :id_alerta
""")

ASSUMIR_ALERTA = text("""
    UPDATE alertas SET situacao = 'EM_ATENDIMENTO', atualizado_em = :agora
     WHERE id_alerta = :id_alerta AND situacao = 'ABERTO'
""")

PRIMEIRA_ACAO = text("""
    UPDATE alertas
       SET primeira_acao_em = COALESCE(primeira_acao_em, :agora),
           situacao = CASE WHEN situacao = 'ABERTO' THEN 'EM_ATENDIMENTO' ELSE situacao END,
           atualizado_em = :agora
     WHERE id_alerta = :id_alerta
""")

ENCERRAR_ALERTA = text("""
    UPDATE alertas
       SET situacao = 'ENCERRADO', encerrado_em = :agora, causa = :causa, desfecho = :desfecho,
           houve_contato = :houve_contato, canal_contato = :canal_contato, acoes_executadas = :acoes_executadas,
           score_no_encerramento = :score, atualizado_em = :agora
     WHERE id_alerta = :id_alerta AND situacao <> 'ENCERRADO'
""")

SCORE_E_SOBREPOSICAO = text("""
    SELECT score, nivel, motivo_sobreposicao FROM vw_score_atual WHERE id_aluno = :id_aluno
""")

# Responsaveis possiveis: nucleo de apoio e coordenacao do curso, com a carga atual.
RESPONSAVEIS = text("""
    SELECT u.id_usuario, u.nome, u.perfil,
           (SELECT count(*) FROM alertas a WHERE a.id_responsavel = u.id_usuario AND a.situacao <> 'ENCERRADO')
               AS alertas_abertos
      FROM usuarios u
     WHERE u.ativo AND u.perfil IN ('NUCLEO_APOIO', 'COORDENACAO') AND u.id_curso = :id_curso
     ORDER BY u.perfil DESC, u.nome
""")

RESPONSAVEL_VALIDO = text("""
    SELECT u.id_usuario, u.perfil,
           (SELECT count(*) FROM alertas a WHERE a.id_responsavel = u.id_usuario AND a.situacao <> 'ENCERRADO')
               AS alertas_abertos
      FROM usuarios u
     WHERE u.id_usuario = :id_usuario AND u.ativo AND u.perfil IN ('NUCLEO_APOIO', 'COORDENACAO')
       AND u.id_curso = :id_curso
""")

ALERTAS_DO_ALUNO = text("""
    SELECT id_alerta, tipo, nivel, situacao, criado_em, prazo_em, encerrado_em, causa, desfecho
      FROM alertas
     WHERE id_aluno = :id_aluno
     ORDER BY criado_em DESC, id_alerta DESC
     LIMIT 50
""")

# Area do aluno: so os eventos marcados como visiveis para ele.
EVENTOS_VISIVEIS_AO_ALUNO = text("""
    SELECT e.momento, e.tipo_acao, e.descricao
      FROM alerta_eventos e
      JOIN alertas a ON a.id_alerta = e.id_alerta
     WHERE a.id_aluno = :id_aluno AND e.visivel_aluno
     ORDER BY e.momento DESC, e.id_evento DESC
     LIMIT 100
""")

# ---------------------------------------------------------------------------
# Paineis (Anexo D.3). Escopo: curso da coordenacao; direcao: instituicao.
# ---------------------------------------------------------------------------

_ALUNOS_DO_RECORTE = """
      FROM alunos al
      LEFT JOIN vw_score_atual s ON s.id_aluno = al.id_aluno
     WHERE (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
       AND (CAST(:semestre AS INTEGER) IS NULL OR al.semestre_atual = :semestre)
       AND (CAST(:turno AS VARCHAR) IS NULL OR EXISTS (
             SELECT 1 FROM matriculas m JOIN turmas t ON t.id_turma = m.id_turma
              WHERE m.id_aluno = al.id_aluno AND t.turno = :turno))
       AND (CAST(:fator AS VARCHAR) IS NULL OR s.fatores_principais ->> 0 = :fator)
       AND (CAST(:tendencia AS VARCHAR) IS NULL OR s.tendencia = :tendencia)
"""

PAINEL_DISTRIBUICAO = text("""
    SELECT COALESCE(s.nivel, 'PENDENTE') AS nivel, count(*) AS total
""" + _ALUNOS_DO_RECORTE + """
     GROUP BY COALESCE(s.nivel, 'PENDENTE')
""")

PAINEL_FAIXAS_SCORE = text("""
    SELECT CASE WHEN s.score <= 25 THEN '0-25' WHEN s.score <= 50 THEN '26-50'
                WHEN s.score <= 75 THEN '51-75' ELSE '76-100' END AS faixa, count(*) AS total
""" + _ALUNOS_DO_RECORTE + """
       AND s.score IS NOT NULL
     GROUP BY 1
""")

PAINEL_ALERTAS = text("""
    SELECT count(*) FILTER (WHERE a.situacao <> 'ENCERRADO' AND a.tipo = 'PEDAGOGICO') AS abertos,
           count(*) FILTER (WHERE a.situacao <> 'ENCERRADO' AND a.tipo = 'PEDAGOGICO' AND a.prazo_em < :agora)
               AS vencidos,
           count(*) FILTER (WHERE a.situacao <> 'ENCERRADO' AND a.tipo = 'PEDAGOGICO' AND a.id_responsavel IS NULL)
               AS sem_responsavel,
           count(*) FILTER (WHERE a.situacao = 'EM_ATENDIMENTO') AS em_atendimento,
           count(*) FILTER (WHERE a.situacao <> 'ENCERRADO' AND a.tipo = 'DADOS') AS tarefas_dados,
           count(*) FILTER (WHERE a.situacao = 'ENCERRADO') AS encerrados
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
     WHERE (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
""")

# Em risco num instante passado: ultimo score de cada aluno ate aquele momento.
EM_RISCO_EM = text("""
    SELECT count(*) FILTER (WHERE ult.nivel IN ('ALTO', 'CRITICO')) AS em_risco, count(ult.nivel) AS com_score
      FROM alunos al
      LEFT JOIN LATERAL (SELECT sr.nivel FROM scores_risco sr
                          WHERE sr.id_aluno = al.id_aluno AND sr.calculado_em <= :momento
                          ORDER BY sr.calculado_em DESC, sr.id_score DESC LIMIT 1) ult ON TRUE
     WHERE (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
""")

EVOLUCAO_RISCO = text("""
    SELECT dia::date AS dia,
           count(*) FILTER (WHERE ult.nivel IN ('ALTO', 'CRITICO')) AS em_risco,
           count(*) FILTER (WHERE ult.nivel = 'CRITICO') AS criticos,
           count(ult.nivel) AS com_score
      FROM generate_series(CAST(:inicio AS date), CAST(:fim AS date), interval '1 day') dia
     CROSS JOIN alunos al
      LEFT JOIN LATERAL (SELECT sr.nivel FROM scores_risco sr
                          WHERE sr.id_aluno = al.id_aluno AND sr.calculado_em < dia + interval '1 day'
                          ORDER BY sr.calculado_em DESC, sr.id_score DESC LIMIT 1) ult ON TRUE
     WHERE (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
     GROUP BY dia
     ORDER BY dia
""")

PRIMEIRO_CALCULO = text("SELECT min(calculado_em), max(calculado_em) FROM scores_risco")

FATORES_FREQUENTES = text("""
    SELECT f.fator, count(*) AS total
      FROM alunos al
      JOIN vw_score_atual s ON s.id_aluno = al.id_aluno
     CROSS JOIN LATERAL jsonb_array_elements_text(s.fatores_principais) f(fator)
     WHERE s.nivel IN ('ALTO', 'CRITICO')
       AND (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
       AND (CAST(:semestre AS INTEGER) IS NULL OR al.semestre_atual = :semestre)
       AND (CAST(:turno AS VARCHAR) IS NULL OR EXISTS (
             SELECT 1 FROM matriculas m JOIN turmas t ON t.id_turma = m.id_turma
              WHERE m.id_aluno = al.id_aluno AND t.turno = :turno))
       AND (CAST(:fator AS VARCHAR) IS NULL OR s.fatores_principais ->> 0 = :fator)
       AND (CAST(:tendencia AS VARCHAR) IS NULL OR s.tendencia = :tendencia)
     GROUP BY f.fator
     ORDER BY total DESC, f.fator
""")

POR_CURSO = text("""
    SELECT c.id_curso, c.nome AS curso, COALESCE(s.nivel, 'PENDENTE') AS nivel, count(*) AS total
      FROM alunos al
      JOIN cursos c ON c.id_curso = al.id_curso
      LEFT JOIN vw_score_atual s ON s.id_aluno = al.id_aluno
     GROUP BY c.id_curso, c.nome, COALESCE(s.nivel, 'PENDENTE')
     ORDER BY c.nome
""")

POR_SEMESTRE = text("""
    SELECT al.semestre_atual AS semestre, COALESCE(s.nivel, 'PENDENTE') AS nivel, count(*) AS total
""" + _ALUNOS_DO_RECORTE + """
     GROUP BY al.semestre_atual, COALESCE(s.nivel, 'PENDENTE')
     ORDER BY al.semestre_atual
""")

# RF25: permanencia de quem teve contato contra quem nao teve, nos alertas encerrados.
EFICACIA = text("""
    SELECT a.houve_contato, a.desfecho, count(*) AS total
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
     WHERE a.situacao = 'ENCERRADO' AND a.tipo = 'PEDAGOGICO'
       AND (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
     GROUP BY a.houve_contato, a.desfecho
""")

CAUSAS = text("""
    SELECT a.causa, count(*) AS total
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
     WHERE a.situacao = 'ENCERRADO' AND a.tipo = 'PEDAGOGICO'
       AND (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
     GROUP BY a.causa
     ORDER BY total DESC
""")

# RF20: marcacoes de classificacao equivocada (relatorio de qualidade do modelo).
DIVERGENCIAS = text("""
    SELECT count(*) FROM alerta_eventos e
      JOIN alertas a ON a.id_alerta = e.id_alerta
      JOIN alunos al ON al.id_aluno = a.id_aluno
     WHERE e.tipo = 'DIVERGENCIA' AND (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
""")

TEMPO_PRIMEIRA_ACAO = text("""
    SELECT a.nivel, count(*) AS total,
           count(*) FILTER (WHERE a.primeira_acao_em <= a.prazo_em) AS no_prazo,
           avg(EXTRACT(EPOCH FROM (a.primeira_acao_em - a.criado_em)) / 3600.0) AS horas_media
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
     WHERE a.tipo = 'PEDAGOGICO' AND a.primeira_acao_em IS NOT NULL
       AND (CAST(:id_curso AS VARCHAR) IS NULL OR al.id_curso = :id_curso)
     GROUP BY a.nivel
""")

ULTIMO_CALCULO = text("""
    SELECT max(calculado_em) AS ultimo, count(DISTINCT versao_parametros) AS versoes FROM vw_score_atual
""")

SINAL_DO_CALCULO = text("SELECT ultimo_sinal, detalhe FROM servicos_status WHERE servico = 'calculo'")

TAMANHO_FILA = text("SELECT count(*) FROM fila_recalculo")

# ---------------------------------------------------------------------------
# Docente: turmas
# ---------------------------------------------------------------------------

TURMAS_DO_DOCENTE = text("""
    SELECT t.id_turma, mt.nome AS materia, t.periodo_letivo, t.turno, mt.carga_horaria_h,
           count(m.id_aluno) AS alunos,
           count(*) FILTER (WHERE s.nivel = 'CRITICO') AS criticos,
           count(*) FILTER (WHERE s.nivel = 'ALTO') AS altos,
           avg(m.nota_final) AS media_turma, avg(m.frequencia_pct) AS frequencia_turma
      FROM turmas t
      JOIN materias mt ON mt.id_materia = t.id_materia
      LEFT JOIN matriculas m ON m.id_turma = t.id_turma
      LEFT JOIN vw_score_atual s ON s.id_aluno = m.id_aluno
     WHERE t.id_professor = :id_professor
     GROUP BY t.id_turma, mt.nome, t.periodo_letivo, t.turno, mt.carga_horaria_h
     ORDER BY t.periodo_letivo DESC, mt.nome
""")

TURMA_DO_DOCENTE = text("""
    SELECT t.id_turma, mt.nome AS materia, t.periodo_letivo, t.turno
      FROM turmas t JOIN materias mt ON mt.id_materia = t.id_materia
     WHERE t.id_turma = :id_turma AND t.id_professor = :id_professor
""")

ALUNOS_DA_TURMA = text("""
    SELECT al.id_aluno, al.nome_ficticio, al.semestre_atual, m.nota_final, m.frequencia_pct, m.situacao,
           s.nivel, s.score, s.fatores_principais
      FROM matriculas m
      JOIN alunos al ON al.id_aluno = m.id_aluno
      LEFT JOIN vw_score_atual s ON s.id_aluno = al.id_aluno
     WHERE m.id_turma = :id_turma
     ORDER BY CASE s.nivel WHEN 'CRITICO' THEN 0 WHEN 'ALTO' THEN 1 WHEN 'MODERADO' THEN 2 ELSE 3 END,
              s.score DESC NULLS LAST, al.nome_ficticio
""")

# ---------------------------------------------------------------------------
# Aluno: disciplinas (RF17)
# ---------------------------------------------------------------------------

DISCIPLINAS_DO_ALUNO = text("""
    SELECT t.id_turma, mt.nome AS materia, t.periodo_letivo, t.turno, mt.carga_horaria_h,
           m.va1, m.va2, m.va3, m.nota_final, m.frequencia_pct, m.situacao, p.nome AS professor
      FROM matriculas m
      JOIN turmas t ON t.id_turma = m.id_turma
      JOIN materias mt ON mt.id_materia = t.id_materia
      LEFT JOIN professores p ON p.id_professor = t.id_professor
     WHERE m.id_aluno = :id_aluno
     ORDER BY t.periodo_letivo DESC, mt.nome
""")

# ---------------------------------------------------------------------------
# Financeiro (Anexo E: alunos com fator financeiro no alerta)
# ---------------------------------------------------------------------------

ALUNOS_DO_FINANCEIRO = text("""
    SELECT al.id_aluno, al.nome_ficticio, a.id_alerta, a.nivel, a.situacao, a.prazo_em, s.score,
           s.recomendacoes, so.renda_per_capita, so.auxilio_bolsa
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
      JOIN vw_score_atual s ON s.id_aluno = a.id_aluno
      LEFT JOIN socioeconomico so ON so.id_aluno = a.id_aluno
     WHERE a.tipo = 'PEDAGOGICO' AND a.situacao <> 'ENCERRADO'
       AND s.fatores_principais @> '["financeiro"]'::jsonb
     ORDER BY CASE a.nivel WHEN 'CRITICO' THEN 0 ELSE 1 END, a.prazo_em, al.id_aluno
     LIMIT :limite OFFSET :deslocamento
""")

# ---------------------------------------------------------------------------
# Calendario de retorno (RN14)
# ---------------------------------------------------------------------------

AGENDAMENTOS_DO_ALUNO = text("""
    SELECT g.id_agendamento, g.inicio, g.situacao, g.motivo_excecao, g.solicitado_em, u.nome AS solicitado_por
      FROM agendamentos g
      LEFT JOIN usuarios u ON u.id_usuario = g.solicitado_por
     WHERE g.id_aluno = :id_aluno
     ORDER BY g.inicio DESC
     LIMIT 50
""")

# Agendamento ativo mais proximo da data pedida (antes ou depois).
AGENDAMENTO_PROXIMO = text("""
    SELECT inicio FROM agendamentos
     WHERE id_aluno = :id_aluno AND situacao <> 'CANCELADO'
       AND inicio > :pedido - make_interval(days => :intervalo)
       AND inicio < :pedido + make_interval(days => :intervalo)
     ORDER BY inicio DESC
     LIMIT 1
""")

ULTIMO_AGENDAMENTO_ATIVO = text("""
    SELECT max(inicio) FROM agendamentos WHERE id_aluno = :id_aluno AND situacao <> 'CANCELADO'
""")

CRIAR_AGENDAMENTO = text("""
    INSERT INTO agendamentos (id_aluno, inicio, solicitado_por, solicitado_em, motivo_excecao, id_alerta)
    VALUES (:id_aluno, :inicio, :solicitado_por, :agora, :motivo_excecao, :id_alerta)
    RETURNING id_agendamento
""")

REGISTRAR_RECUSA_AGENDAMENTO = text("""
    INSERT INTO agendamentos_recusas (id_aluno, pedido_para, proxima_data, solicitado_por, momento)
    VALUES (:id_aluno, :pedido_para, :proxima_data, :solicitado_por, :agora)
""")

AGENDAMENTO_POR_ID = text("""
    SELECT id_agendamento, id_aluno, situacao FROM agendamentos WHERE id_agendamento = :id_agendamento
""")

MUDAR_AGENDAMENTO = text("""
    UPDATE agendamentos SET situacao = :situacao, atualizado_em = :agora WHERE id_agendamento = :id_agendamento
""")

# ---------------------------------------------------------------------------
# Administracao tecnica (sem leitura do conteudo dos dados)
# ---------------------------------------------------------------------------

LISTAR_USUARIOS = text("""
    SELECT id_usuario, login, nome, perfil, id_curso, ativo, ultimo_login, deve_trocar_senha, demonstracao,
           (bloqueado_ate IS NOT NULL AND bloqueado_ate > :agora) AS bloqueado
      FROM usuarios
     WHERE (CAST(:perfil AS VARCHAR) IS NULL OR perfil = :perfil)
       AND (CAST(:busca AS VARCHAR) IS NULL OR lower(login) LIKE :busca OR lower(COALESCE(nome, '')) LIKE :busca)
     ORDER BY perfil, login
     LIMIT :limite OFFSET :deslocamento
""")

CONTAR_USUARIOS = text("""
    SELECT perfil, count(*) AS total, count(*) FILTER (WHERE ativo) AS ativos,
           count(*) FILTER (WHERE deve_trocar_senha) AS primeiro_acesso
      FROM usuarios GROUP BY perfil ORDER BY perfil
""")

CRIAR_USUARIO = text("""
    INSERT INTO usuarios (login, senha_hash, perfil, id_aluno, id_professor, id_curso, nome, email, deve_trocar_senha)
    VALUES (:login, :senha_hash, :perfil, :id_aluno, :id_professor, :id_curso, :nome, :email, TRUE)
    RETURNING id_usuario
""")

LOGIN_EXISTE = text("SELECT 1 FROM usuarios WHERE lower(login) = lower(:login)")

USUARIO_PARA_ADMIN = text("SELECT id_usuario, login, perfil, ativo FROM usuarios WHERE id_usuario = :id_usuario")

ATIVAR_USUARIO = text("UPDATE usuarios SET ativo = :ativo WHERE id_usuario = :id_usuario")

REDEFINIR_SENHA = text("""
    UPDATE usuarios SET senha_hash = :senha_hash, deve_trocar_senha = TRUE WHERE id_usuario = :id_usuario
""")

DESBLOQUEAR = text("UPDATE usuarios SET falhas_login = 0, bloqueado_ate = NULL WHERE id_usuario = :id_usuario")

ALUNO_EXISTE = text("SELECT 1 FROM alunos WHERE id_aluno = :id_aluno")
PROFESSOR_EXISTE = text("SELECT 1 FROM professores WHERE id_professor = :id_professor")
CURSO_EXISTE = text("SELECT 1 FROM cursos WHERE id_curso = :id_curso")

REGISTROS_TECNICOS = text("""
    SELECT momento, servico, nivel, evento, mensagem, id_requisicao
      FROM logs_tecnicos
     WHERE (CAST(:servico AS VARCHAR) IS NULL OR servico = :servico)
       AND (CAST(:nivel AS VARCHAR) IS NULL OR nivel = :nivel)
     ORDER BY momento DESC, id_log DESC
     LIMIT :limite OFFSET :deslocamento
""")

REGISTRAR_LOG = text("""
    INSERT INTO logs_tecnicos (momento, servico, nivel, evento, mensagem, id_requisicao)
    VALUES (:agora, :servico, :nivel, :evento, :mensagem, :id_requisicao)
""")

SERVICOS = text("SELECT servico, ultimo_sinal, detalhe FROM servicos_status ORDER BY servico")

SINAL_DE_VIDA = text("""
    INSERT INTO servicos_status (servico, ultimo_sinal, detalhe) VALUES (:servico, :agora, :detalhe)
    ON CONFLICT (servico) DO UPDATE SET ultimo_sinal = EXCLUDED.ultimo_sinal, detalhe = EXCLUDED.detalhe
""")

ENFILEIRAR_TODOS = text("""
    INSERT INTO fila_recalculo (id_aluno, motivo)
    SELECT id_aluno, 'manual' FROM alunos
     WHERE (CAST(:id_curso AS VARCHAR) IS NULL OR id_curso = :id_curso)
       AND (CAST(:semestre AS INTEGER) IS NULL OR semestre_atual = :semestre)
    ON CONFLICT (id_aluno) DO UPDATE SET motivo = 'manual', enfileirado_em = now()
""")

ACORDAR_CALCULO = text("SELECT pg_notify('mufasa_recalculo', '')")

# Cargas de CSV (RN08, RF06)
CARGA_COM_HASH = text("""
    SELECT id_carga, situacao FROM cargas
     WHERE hash_sha256 = :hash AND situacao IN ('VALIDADA', 'CONFIRMADA', 'APLICADA')
     LIMIT 1
""")

CRIAR_CARGA = text("""
    INSERT INTO cargas (tipo, nome_arquivo, tamanho_bytes, hash_sha256, enviado_por, enviado_em, situacao,
                        linhas_total, linhas_validas)
    VALUES (:tipo, :nome_arquivo, :tamanho_bytes, :hash, :enviado_por, :agora, :situacao, :linhas_total,
            :linhas_validas)
    RETURNING id_carga
""")

CRIAR_LINHA_CARGA = text("""
    INSERT INTO carga_linhas (id_carga, numero, dados, erro) VALUES (:id_carga, :numero, CAST(:dados AS jsonb), :erro)
""")

LISTAR_CARGAS = text("""
    SELECT c.id_carga, c.tipo, c.nome_arquivo, c.tamanho_bytes, c.hash_sha256, c.enviado_em, c.situacao,
           c.linhas_total, c.linhas_validas, c.confirmado_em, c.aplicada_em, c.resultado, u.login AS enviado_por
      FROM cargas c
      LEFT JOIN usuarios u ON u.id_usuario = c.enviado_por
     ORDER BY c.enviado_em DESC, c.id_carga DESC
     LIMIT :limite OFFSET :deslocamento
""")

CARGA_POR_ID = text("""
    SELECT c.id_carga, c.tipo, c.nome_arquivo, c.tamanho_bytes, c.hash_sha256, c.enviado_em, c.situacao,
           c.linhas_total, c.linhas_validas, c.confirmado_em, c.aplicada_em, c.resultado, c.enviado_por
      FROM cargas c
     WHERE c.id_carga = :id_carga
""")

REJEICOES_DA_CARGA = text("""
    SELECT numero, erro FROM carga_linhas WHERE id_carga = :id_carga AND erro IS NOT NULL ORDER BY numero
     LIMIT 5000
""")

MUDAR_CARGA = text("""
    UPDATE cargas SET situacao = :nova, confirmado_por = :id_usuario, confirmado_em = :agora
     WHERE id_carga = :id_carga AND situacao = 'VALIDADA'
""")

TURMAS_E_MATRICULAS = text("""
    SELECT m.id_matricula, m.id_aluno, m.id_turma FROM matriculas m
""")

IDS_ALUNOS = text("SELECT id_aluno FROM alunos")

# ---------------------------------------------------------------------------
# Parametros (RN22, RF23)
# ---------------------------------------------------------------------------

LISTAR_PARAMETROS = text("""
    SELECT chave, valor, minimo, maximo, unidade, editavel, descricao, atualizado_em
      FROM parametros ORDER BY chave
""")

PARAMETRO = text("""
    SELECT chave, valor, minimo, maximo, editavel FROM parametros WHERE chave = :chave FOR UPDATE
""")

VALORES_PARAMETROS = text("SELECT chave, valor FROM parametros")

VERSOES = text("""
    SELECT v.versao, v.criada_em, v.justificativa, ua.login AS autor, ub.login AS aprovador
      FROM parametros_versoes v
      LEFT JOIN usuarios ua ON ua.id_usuario = v.autor
      LEFT JOIN usuarios ub ON ub.id_usuario = v.aprovador
     ORDER BY v.versao DESC
     LIMIT 50
""")

# Trava consultiva da transacao: duas alteracoes ao mesmo tempo nao geram o
# mesmo numero de versao (e nao exige privilegio extra na tabela).
TRAVAR_VERSOES = text("SELECT pg_advisory_xact_lock(7302201)")
PROXIMA_VERSAO = text("SELECT COALESCE(max(versao), 0) + 1 FROM parametros_versoes")

APLICAR_PARAMETRO = text("UPDATE parametros SET valor = :valor, atualizado_em = :agora WHERE chave = :chave")

CRIAR_VERSAO = text("""
    INSERT INTO parametros_versoes (versao, criada_em, autor, aprovador, justificativa, valores)
    SELECT :versao, :agora, :autor, :aprovador, :justificativa, jsonb_object_agg(chave, valor) FROM parametros
""")

PROPOSTAS = text("""
    SELECT p.id_proposta, p.chave, p.valor_anterior, p.valor_novo, p.justificativa, p.proposto_em, p.situacao,
           p.decidido_em, p.versao_gerada, up.login AS proposto_por, ud.login AS decidido_por
      FROM parametros_propostas p
      LEFT JOIN usuarios up ON up.id_usuario = p.proposto_por
      LEFT JOIN usuarios ud ON ud.id_usuario = p.decidido_por
     ORDER BY CASE p.situacao WHEN 'PENDENTE' THEN 0 ELSE 1 END, p.proposto_em DESC
     LIMIT 100
""")

CRIAR_PROPOSTA = text("""
    INSERT INTO parametros_propostas (chave, valor_anterior, valor_novo, justificativa, proposto_por, proposto_em)
    VALUES (:chave, :valor_anterior, :valor_novo, :justificativa, :proposto_por, :agora)
    RETURNING id_proposta
""")

PROPOSTA_PENDENTE = text("""
    SELECT id_proposta, chave, valor_novo, justificativa, proposto_por
      FROM parametros_propostas WHERE id_proposta = :id_proposta AND situacao = 'PENDENTE' FOR UPDATE
""")

PENDENTE_DA_CHAVE = text("SELECT 1 FROM parametros_propostas WHERE chave = :chave AND situacao = 'PENDENTE'")

DECIDIR_PROPOSTA = text("""
    UPDATE parametros_propostas
       SET situacao = :situacao, decidido_por = :decidido_por, decidido_em = :agora, versao_gerada = :versao
     WHERE id_proposta = :id_proposta
""")

# ---------------------------------------------------------------------------
# Encarregado de dados
# ---------------------------------------------------------------------------

SOLICITACAO_POR_ID = text("SELECT id_solicitacao, situacao FROM solicitacoes_titular WHERE id_solicitacao = :id")

RESPONDER_SOLICITACAO = text("""
    UPDATE solicitacoes_titular SET situacao = :situacao, respondida_em = :agora WHERE id_solicitacao = :id
""")

SOLICITACOES_DO_ALUNO = text("""
    SELECT id_solicitacao, tipo, situacao, registrada_em, respondida_em
      FROM solicitacoes_titular WHERE id_aluno = :id_aluno ORDER BY registrada_em DESC LIMIT 50
""")
