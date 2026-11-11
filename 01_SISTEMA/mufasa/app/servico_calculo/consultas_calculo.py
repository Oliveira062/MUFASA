"""
SQL do servico de calculo. Mesma regra do resto do projeto: constantes com
parametros nomeados, nada montado com dado de fora. O servico conecta como
mufasa_calculo, que so enxerga as colunas usadas aqui (sql/painel.sql).
"""

from sqlalchemy import text

# ---------------------------------------------------------------------------
# Fila
# ---------------------------------------------------------------------------

ENFILEIRAR_SEM_SCORE = text("""
    INSERT INTO fila_recalculo (id_aluno, motivo)
    SELECT a.id_aluno, 'carga_inicial' FROM alunos a
     WHERE NOT EXISTS (SELECT 1 FROM scores_risco s WHERE s.id_aluno = a.id_aluno)
    ON CONFLICT (id_aluno) DO NOTHING
""")

# Versao de parametros diferente da do ultimo score: recalcula.
ENFILEIRAR_VERSAO_ANTIGA = text("""
    INSERT INTO fila_recalculo (id_aluno, motivo)
    SELECT s.id_aluno, 'parametro' FROM vw_score_atual s WHERE s.versao_parametros <> :versao
    ON CONFLICT (id_aluno) DO NOTHING
""")

LER_FILA = text("""
    SELECT id_aluno, motivo, enfileirado_em
      FROM fila_recalculo
     ORDER BY enfileirado_em
     LIMIT :lote
       FOR UPDATE SKIP LOCKED
""")

# So remove se o aluno nao voltou para a fila durante o calculo.
TIRAR_DA_FILA = text("""
    DELETE FROM fila_recalculo WHERE id_aluno = :id_aluno AND enfileirado_em <= :lido_em
""")

# ---------------------------------------------------------------------------
# Parametros vigentes (RN22)
# ---------------------------------------------------------------------------

PARAMETROS_VIGENTES = text("SELECT chave, valor FROM parametros")
VERSAO_VIGENTE = text("SELECT max(versao) FROM parametros_versoes")

# ---------------------------------------------------------------------------
# Dados do aluno para o score (Anexo A). Nenhuma coluna de nome, bairro,
# saude, raca ou forma de ingresso (RN21).
# ---------------------------------------------------------------------------

ALUNO = text("""
    SELECT id_aluno, id_curso, semestre_atual, idade FROM alunos WHERE id_aluno = :id_aluno
""")

DISCIPLINAS_DO_PERIODO = text("""
    SELECT mt.nome, mt.carga_horaria_h, m.nota_final, m.frequencia_pct, m.situacao, t.turno, t.periodo_letivo,
           p.inicio, p.fim
      FROM matriculas m
      JOIN turmas t   ON t.id_turma = m.id_turma
      JOIN materias mt ON mt.id_materia = t.id_materia
      LEFT JOIN periodos_letivos p ON p.periodo_letivo = t.periodo_letivo
     WHERE m.id_aluno = :id_aluno
     ORDER BY t.periodo_letivo DESC, mt.nome
""")

INDICADORES = text("""
    SELECT periodo_letivo, media_semestre_anterior
      FROM indicadores_academicos
     WHERE id_aluno = :id_aluno
     ORDER BY periodo_letivo DESC
     LIMIT 1
""")

SOCIOECONOMICO = text("""
    SELECT renda_per_capita, trabalha, horas_trabalho_dia, tempo_deslocamento_min, auxilio_bolsa
      FROM socioeconomico
     WHERE id_aluno = :id_aluno
""")

# ---------------------------------------------------------------------------
# Score
# ---------------------------------------------------------------------------

SCORES_RECENTES = text("""
    SELECT id_score, score, nivel, nivel_origem, versao_parametros, fatores, modificadores, motivo_sobreposicao
      FROM scores_risco
     WHERE id_aluno = :id_aluno
     ORDER BY calculado_em DESC, id_score DESC
     LIMIT 2
""")

GRAVAR_SCORE = text("""
    INSERT INTO scores_risco
           (id_aluno, score, nivel, completude, fatores_principais, detalhamento, contribuicoes,
            sobreposicao_frequencia, recomendacao, nivel_origem, motivo_sobreposicao, parcial, fatores,
            modificadores, recomendacoes, tendencia, score_anterior, nivel_anterior, versao_parametros,
            versao_modelo, motivo, calculado_em)
    VALUES (:id_aluno, :score, :nivel, :completude, CAST(:fatores_principais AS JSONB), CAST(:detalhamento AS JSONB),
            CAST(:contribuicoes AS JSONB), :sobreposicao_frequencia, :recomendacao, :nivel_origem,
            :motivo_sobreposicao, :parcial, CAST(:fatores AS JSONB), CAST(:modificadores AS JSONB),
            CAST(:recomendacoes AS JSONB), :tendencia, :score_anterior, :nivel_anterior, :versao_parametros,
            :versao_modelo, :motivo, :calculado_em)
    RETURNING id_score
""")

# ---------------------------------------------------------------------------
# Alertas (RN03) e tarefas de dados (RN01)
# ---------------------------------------------------------------------------

ALERTA_ABERTO = text("""
    SELECT id_alerta, nivel, prazo_em, situacao, id_responsavel
      FROM alertas
     WHERE id_aluno = :id_aluno AND tipo = :tipo AND situacao <> 'ENCERRADO'
""")

CRIAR_ALERTA = text("""
    INSERT INTO alertas (id_aluno, id_score_origem, tipo, nivel, situacao, criado_em, prazo_em, id_responsavel,
                         atribuido_em, atualizado_em)
    VALUES (:id_aluno, :id_score, :tipo, :nivel, 'ABERTO', :agora, :prazo_em, :id_responsavel,
            CASE WHEN CAST(:id_responsavel AS BIGINT) IS NULL THEN NULL ELSE CAST(:agora AS TIMESTAMPTZ) END, :agora)
    RETURNING id_alerta
""")

ATUALIZAR_NIVEL_ALERTA = text("""
    UPDATE alertas SET nivel = :nivel, prazo_em = :prazo_em, atualizado_em = :agora WHERE id_alerta = :id_alerta
""")

ENCERRAR_TAREFA_DADOS = text("""
    UPDATE alertas
       SET situacao = 'ENCERRADO', encerrado_em = :agora, causa = 'NAO_IDENTIFICADA', desfecho = 'DADOS_CORRIGIDOS',
           houve_contato = FALSE, acoes_executadas = 'Dados completados; o score foi calculado.', atualizado_em = :agora
     WHERE id_alerta = :id_alerta
""")

REGISTRAR_EVENTO = text("""
    INSERT INTO alerta_eventos (id_alerta, momento, id_usuario, tipo, descricao)
    VALUES (:id_alerta, :agora, NULL, :tipo, :descricao)
""")

# Nucleo de apoio do curso com menos alertas abertos, abaixo do teto (RN02:
# alerta Critico aciona o nucleo de apoio; teto da tabela C.2).
NAE_DISPONIVEL = text("""
    SELECT u.id_usuario
      FROM usuarios u
      LEFT JOIN alertas a ON a.id_responsavel = u.id_usuario AND a.situacao <> 'ENCERRADO'
     WHERE u.perfil = 'NUCLEO_APOIO' AND u.ativo AND u.id_curso = :id_curso
     GROUP BY u.id_usuario
    HAVING COUNT(a.id_alerta) < :teto
     ORDER BY COUNT(a.id_alerta), u.id_usuario
     LIMIT 1
""")

EQUIPE_DO_CURSO = text("""
    SELECT id_usuario, perfil FROM usuarios
     WHERE ativo AND perfil IN ('COORDENACAO', 'NUCLEO_APOIO') AND id_curso = :id_curso
""")

ADMINISTRACAO = text("SELECT id_usuario FROM usuarios WHERE ativo AND perfil = 'ADMIN'")

CRIAR_NOTIFICACAO = text("""
    INSERT INTO notificacoes (id_usuario, criada_em, tipo, titulo, texto, id_alerta)
    VALUES (:id_usuario, :agora, :tipo, :titulo, :texto, :id_alerta)
""")

ALERTAS_VENCIDOS_SEM_AVISO = text("""
    SELECT a.id_alerta, a.id_aluno, a.nivel, a.id_responsavel, al.id_curso
      FROM alertas a
      JOIN alunos al ON al.id_aluno = a.id_aluno
     WHERE a.situacao = 'ABERTO' AND a.tipo = 'PEDAGOGICO' AND a.prazo_em < :agora
       AND NOT EXISTS (SELECT 1 FROM alerta_eventos e WHERE e.id_alerta = a.id_alerta AND e.tipo = 'PRAZO_VENCIDO')
     LIMIT 500
""")

# ---------------------------------------------------------------------------
# Cargas confirmadas (RN08: tudo ou nada)
# ---------------------------------------------------------------------------

CARGA_CONFIRMADA = text("""
    SELECT id_carga, tipo, enviado_por FROM cargas WHERE situacao = 'CONFIRMADA'
     ORDER BY confirmado_em LIMIT 1 FOR UPDATE SKIP LOCKED
""")

LINHAS_DA_CARGA = text("""
    SELECT numero, dados FROM carga_linhas WHERE id_carga = :id_carga AND erro IS NULL ORDER BY numero
""")

APLICAR_NOTAS = text("""
    UPDATE matriculas
       SET va1 = :va1, va2 = :va2, va3 = :va3, nota_final = :nota_final, frequencia_pct = :frequencia_pct,
           situacao = :situacao
     WHERE id_matricula = :id_matricula
""")

APLICAR_INDICADORES = text("""
    INSERT INTO indicadores_academicos (id_aluno, periodo_letivo, faltas_total, atividades_pendentes,
                                        disciplinas_reprovadas_historico, media_semestre_anterior)
    VALUES (:id_aluno, :periodo_letivo, :faltas_total, :atividades_pendentes,
            :disciplinas_reprovadas_historico, :media_semestre_anterior)
    ON CONFLICT (id_aluno, periodo_letivo) DO UPDATE
       SET faltas_total = EXCLUDED.faltas_total, atividades_pendentes = EXCLUDED.atividades_pendentes,
           disciplinas_reprovadas_historico = EXCLUDED.disciplinas_reprovadas_historico,
           media_semestre_anterior = EXCLUDED.media_semestre_anterior
""")

FINALIZAR_CARGA = text("""
    UPDATE cargas SET situacao = :situacao, aplicada_em = :agora, resultado = :resultado WHERE id_carga = :id_carga
""")

# ---------------------------------------------------------------------------
# Operacao
# ---------------------------------------------------------------------------

SINAL_DE_VIDA = text("""
    INSERT INTO servicos_status (servico, ultimo_sinal, detalhe) VALUES ('calculo', :agora, :detalhe)
    ON CONFLICT (servico) DO UPDATE SET ultimo_sinal = EXCLUDED.ultimo_sinal, detalhe = EXCLUDED.detalhe
""")

REGISTRAR_LOG = text("""
    INSERT INTO logs_tecnicos (momento, servico, nivel, evento, mensagem) VALUES (:agora, 'calculo', :nivel, :evento, :mensagem)
""")
