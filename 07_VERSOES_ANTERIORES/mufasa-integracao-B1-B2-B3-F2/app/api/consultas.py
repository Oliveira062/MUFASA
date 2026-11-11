"""
Todas as consultas SQL do B3, em um unico lugar para revisao.

Cada constante usa so parametros nomeados (:nome). Nenhuma e montada com
dado do usuario. Onde a consulta precisa variar (ordenacao), a variacao vem
de uma lista branca de fragmentos fixos, nunca do texto recebido.

Os filtros opcionais usam CAST(:x AS tipo) IS NULL para o PostgreSQL saber
o tipo do parametro mesmo quando ele chega vazio.

Minimizacao (LGPD art. 6, III): cada consulta seleciona so as colunas que
o endpoint devolve. Nenhum SELECT *.
"""

from sqlalchemy import text

# ---------------------------------------------------------------------------
# Usuarios e sessao
# ---------------------------------------------------------------------------

USUARIO_POR_LOGIN = text("""
    SELECT id_usuario, login, senha_hash, perfil, id_aluno, id_professor, id_curso,
           ativo, falhas_login, bloqueado_ate
      FROM usuarios
     WHERE login = :login
""")

USUARIO_POR_ID = text("""
    SELECT id_usuario, login, perfil, id_aluno, id_professor, id_curso, ativo
      FROM usuarios
     WHERE id_usuario = :id_usuario
""")

REGISTRAR_FALHA_LOGIN = text("""
    UPDATE usuarios
       SET falhas_login = falhas_login + 1,
           bloqueado_ate = CASE WHEN falhas_login + 1 >= :max_falhas
                                THEN :bloquear_ate ELSE bloqueado_ate END
     WHERE id_usuario = :id_usuario
""")

ZERAR_FALHAS_LOGIN = text("""
    UPDATE usuarios
       SET falhas_login = 0, bloqueado_ate = NULL, ultimo_login = :agora
     WHERE id_usuario = :id_usuario
""")

TOKEN_REVOGADO = text("SELECT 1 FROM tokens_revogados WHERE jti = :jti")

REVOGAR_TOKEN = text("""
    INSERT INTO tokens_revogados (jti, expira_em) VALUES (:jti, :expira_em)
""")

# ---------------------------------------------------------------------------
# Escopo de acesso (RN07, RN17)
# ---------------------------------------------------------------------------

ALUNO_DAS_TURMAS_DO_DOCENTE = text("""
    SELECT 1
      FROM matriculas m
      JOIN turmas t ON t.id_turma = m.id_turma
     WHERE m.id_aluno = :id_aluno
       AND t.id_professor = :id_professor
     LIMIT 1
""")

ALUNO_DO_CURSO = text("""
    SELECT 1 FROM alunos WHERE id_aluno = :id_aluno AND id_curso = :id_curso
""")

NIVEL_MAIS_RECENTE = text("""
    SELECT nivel_risco
      FROM avaliacoes_risco
     WHERE id_aluno = :id_aluno
     ORDER BY data_avaliacao DESC, id_avaliacao DESC
     LIMIT 1
""")

# ---------------------------------------------------------------------------
# Listagem. O nivel vem da ultima avaliacao gravada, numa unica consulta:
# nada de calcular o score aluno por aluno dentro de um laco (N+1).
# ---------------------------------------------------------------------------

_NIVEL_SUBCONSULTA = """
    (SELECT r.nivel_risco FROM avaliacoes_risco r
      WHERE r.id_aluno = a.id_aluno
      ORDER BY r.data_avaliacao DESC, r.id_avaliacao DESC
      LIMIT 1)
"""

_LISTA_BASE = f"""
    SELECT a.id_aluno, a.nome_ficticio, a.semestre_atual, {_NIVEL_SUBCONSULTA} AS nivel_risco
      FROM alunos a
     WHERE (CAST(:semestre AS INTEGER) IS NULL OR a.semestre_atual = :semestre)
"""

_FILTRO_POR_PERFIL = {
    "DOCENTE": """
       AND EXISTS (SELECT 1 FROM matriculas m JOIN turmas t ON t.id_turma = m.id_turma
                    WHERE m.id_aluno = a.id_aluno AND t.id_professor = :id_professor)
    """,
    "COORDENACAO": "AND a.id_curso = :id_curso",
    "NUCLEO_APOIO": f"AND a.id_curso = :id_curso AND {_NIVEL_SUBCONSULTA} IN ('Alto', 'Crítico')",
}

# Lista branca de ordenacao: o parametro da URL escolhe a CHAVE, nunca o SQL.
ORDENACOES = {
    "nome": "ORDER BY a.nome_ficticio, a.id_aluno",
    "semestre": "ORDER BY a.semestre_atual, a.id_aluno",
    "matricula": "ORDER BY a.id_aluno",
}


def consulta_lista_alunos(perfil: str, ordem: str):
    """Monta a listagem so a partir de fragmentos constantes deste arquivo."""
    return text(
        _LISTA_BASE
        + _FILTRO_POR_PERFIL[perfil]
        + "\n" + ORDENACOES[ordem]
        + "\n LIMIT :limite OFFSET :deslocamento"
    )


# ---------------------------------------------------------------------------
# Perfil do aluno, separado por grau de sensibilidade
# ---------------------------------------------------------------------------

ALUNO_BASICO = text("""
    SELECT a.id_aluno, a.nome_ficticio, a.id_curso, c.nome AS curso, a.semestre_atual
      FROM alunos a
      LEFT JOIN cursos c ON c.id_curso = a.id_curso
     WHERE a.id_aluno = :id_aluno
""")

# Idade so para a regra de menor de idade (RN16, LGPD art. 14); nao e devolvida.
IDADE_ALUNO = text("SELECT idade FROM alunos WHERE id_aluno = :id_aluno")

INDICADORES_ATUAIS = text("""
    SELECT periodo_letivo, faltas_total, frequencia_pct, disciplinas_reprovadas_historico,
           atividades_pendentes, media_semestre_anterior, media_atual, tendencia_media
      FROM indicadores_academicos
     WHERE id_aluno = :id_aluno
     ORDER BY periodo_letivo DESC
     LIMIT 1
""")

# Sem renda familiar total, numero de moradores, ProUni, FIES ou desconto:
# o score usa so a renda per capita, e nenhum perfil precisa dos outros.
SOCIOECONOMICO_RESTRITO = text("""
    SELECT renda_per_capita, trabalha, horas_trabalho_dia, tempo_deslocamento_min, auxilio_bolsa
      FROM socioeconomico
     WHERE id_aluno = :id_aluno
""")

DADOS_SENSIVEIS_APOIO = text("""
    SELECT apoio_psicossocial_solicitado, necessidade_acessibilidade
      FROM alunos
     WHERE id_aluno = :id_aluno
""")

HISTORICO_RISCO = text("""
    SELECT periodo_letivo, tipo, data_avaliacao, risco_evasao_pct, nivel_risco
      FROM avaliacoes_risco
     WHERE id_aluno = :id_aluno
     ORDER BY data_avaliacao, id_avaliacao
     LIMIT :limite
""")

# ---------------------------------------------------------------------------
# Agregados (CA19): grupos com menos de 5 alunos nao saem do banco.
# ---------------------------------------------------------------------------

AGREGADOS_POR_SEMESTRE = text(f"""
    SELECT a.semestre_atual AS semestre, {_NIVEL_SUBCONSULTA} AS nivel_risco, COUNT(*) AS total
      FROM alunos a
     WHERE (CAST(:id_curso AS VARCHAR) IS NULL OR a.id_curso = :id_curso)
     GROUP BY a.semestre_atual, nivel_risco
    HAVING COUNT(*) >= :minimo_grupo
     ORDER BY a.semestre_atual, nivel_risco
""")

# ---------------------------------------------------------------------------
# Direitos do titular e consentimento (LGPD arts. 8, 11, 14, 18)
# ---------------------------------------------------------------------------

CONSENTIMENTOS_DO_ALUNO = text("""
    SELECT finalidade, concedido, concedido_por, versao_termo, registrado_em
      FROM consentimentos
     WHERE id_aluno = :id_aluno
     ORDER BY registrado_em, id_consentimento
""")

REGISTRAR_CONSENTIMENTO = text("""
    INSERT INTO consentimentos
           (id_aluno, finalidade, concedido, concedido_por, versao_termo, registrado_em, id_usuario)
    VALUES (:id_aluno, :finalidade, :concedido, :concedido_por, :versao_termo, :registrado_em, :id_usuario)
""")

MEUS_DADOS_CADASTRO = text("""
    SELECT id_aluno, nome_ficticio, id_curso, semestre_atual, idade, bairro, tipo_ensino_medio,
           apoio_psicossocial_solicitado, necessidade_acessibilidade
      FROM alunos
     WHERE id_aluno = :id_aluno
""")

MEUS_DADOS_SOCIOECONOMICO = text("""
    SELECT renda_familiar_mensal, moradores_domicilio, renda_per_capita, auxilio_bolsa, trabalha,
           horas_trabalho_dia, horas_estudo_semana, responsabilidades_familiares_h_semana,
           distancia_km, tempo_deslocamento_min, meio_transporte, prouni, fies, desconto_funcionario
      FROM socioeconomico
     WHERE id_aluno = :id_aluno
""")

MEUS_DADOS_MATRICULAS = text("""
    SELECT m.id_turma, mt.nome AS materia, m.nota_final, m.frequencia_pct, m.situacao
      FROM matriculas m
      JOIN turmas t ON t.id_turma = m.id_turma
      JOIN materias mt ON mt.id_materia = t.id_materia
     WHERE m.id_aluno = :id_aluno
     ORDER BY m.id_turma
""")

REGISTRAR_SOLICITACAO_TITULAR = text("""
    INSERT INTO solicitacoes_titular (id_aluno, tipo, descricao, situacao, registrada_em)
    VALUES (:id_aluno, :tipo, :descricao, 'ABERTA', :registrada_em)
""")

LISTAR_SOLICITACOES_TITULAR = text("""
    SELECT id_solicitacao, id_aluno, tipo, situacao, registrada_em
      FROM solicitacoes_titular
     ORDER BY registrada_em DESC, id_solicitacao DESC
     LIMIT :limite OFFSET :deslocamento
""")

# ---------------------------------------------------------------------------
# Auditoria (LGPD art. 37). Tabela so de insercao: o usuario mufasa_api nao
# tem UPDATE nem DELETE nela (sql/b3_complemento.sql).
# ---------------------------------------------------------------------------

REGISTRAR_AUDITORIA = text("""
    INSERT INTO auditoria_acessos
           (momento, id_requisicao, id_usuario, perfil, operacao, recurso, id_aluno_alvo, resultado, origem)
    VALUES (:momento, :id_requisicao, :id_usuario, :perfil, :operacao, :recurso, :id_aluno_alvo, :resultado, :origem)
""")

LISTAR_AUDITORIA = text("""
    SELECT momento, id_requisicao, id_usuario, perfil, operacao, recurso, id_aluno_alvo, resultado
      FROM auditoria_acessos
     WHERE (CAST(:id_aluno AS VARCHAR) IS NULL OR id_aluno_alvo = :id_aluno)
     ORDER BY momento DESC, id_auditoria DESC
     LIMIT :limite OFFSET :deslocamento
""")
