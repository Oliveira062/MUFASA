"""
Todas as consultas SQL do chatbot, em um unico lugar para revisao.

Mesma regra do B3 (app/api/banco.py): so constantes com parametros
nomeados, nenhuma montada com texto do usuario. O chatbot nao gera SQL: a
intencao escolhe UMA destas constantes e o servidor preenche os parametros
com o escopo do usuario logado (RN06).

Toda consulta tem LIMIT (Anexo D.2: limite de linhas obrigatorio) e le so
as visoes vw_chat_* criadas em sql/chatbot.sql.
"""

from sqlalchemy import text

LIMITE_LINHAS = 50
LIMITE_LISTA_RISCO = 10

# ---------------------------------------------------------------------------
# Dados do proprio aluno
# ---------------------------------------------------------------------------

DISCIPLINAS_DO_ALUNO = text("""
    SELECT disciplina, periodo_letivo, va1, va2, va3, nota_final, frequencia_pct, situacao,
           frequencia_minima_pct
      FROM vw_chat_disciplinas_aluno
     WHERE id_aluno = :id_aluno
     ORDER BY disciplina
     LIMIT :limite
""")

INDICADORES_DO_ALUNO = text("""
    SELECT periodo_letivo, faltas_total, frequencia_pct, media_semestre_anterior, media_atual,
           tendencia_media, atividades_pendentes
      FROM vw_chat_indicadores
     WHERE id_aluno = :id_aluno
     ORDER BY periodo_letivo DESC
     LIMIT 1
""")

RISCO_DO_ALUNO = text("""
    SELECT id_aluno, nome_ficticio, nivel_risco, data_avaliacao, periodo_letivo
      FROM vw_chat_risco_atual
     WHERE id_aluno = :id_aluno
     LIMIT 1
""")

# ---------------------------------------------------------------------------
# Equipe: contagens e listas dentro do escopo do perfil
# ---------------------------------------------------------------------------

RESUMO_RISCO_CURSO = text("""
    SELECT nivel_risco, COUNT(*) AS total
      FROM vw_chat_risco_atual
     WHERE id_curso = :id_curso
     GROUP BY nivel_risco
     LIMIT 10
""")

RESUMO_RISCO_DOCENTE = text("""
    SELECT nivel_risco, COUNT(*) AS total
      FROM vw_chat_risco_atual
     WHERE id_aluno IN (SELECT id_aluno FROM vw_chat_vinculo_docente WHERE id_professor = :id_professor)
     GROUP BY nivel_risco
     LIMIT 10
""")

MAIOR_RISCO_CURSO = text("""
    SELECT id_aluno, nome_ficticio, semestre_atual, nivel_risco, data_avaliacao
      FROM vw_chat_risco_atual
     WHERE id_curso = :id_curso
       AND nivel_risco IN (:critico, :alto)
     ORDER BY CASE WHEN nivel_risco = :critico THEN 0 ELSE 1 END, data_avaliacao DESC, nome_ficticio
     LIMIT :limite
""")

MAIOR_RISCO_DOCENTE = text("""
    SELECT id_aluno, nome_ficticio, semestre_atual, nivel_risco, data_avaliacao
      FROM vw_chat_risco_atual
     WHERE id_aluno IN (SELECT id_aluno FROM vw_chat_vinculo_docente WHERE id_professor = :id_professor)
       AND nivel_risco IN (:critico, :alto)
     ORDER BY CASE WHEN nivel_risco = :critico THEN 0 ELSE 1 END, data_avaliacao DESC, nome_ficticio
     LIMIT :limite
""")

# ---------------------------------------------------------------------------
# Conversa e historico (RN13, auditoria do Anexo D.2)
# ---------------------------------------------------------------------------

CONVERSA_ABERTA = text("""
    SELECT id_conversa, ultima_interacao
      FROM chat_conversas
     WHERE id_usuario = :id_usuario AND encerrada_em IS NULL
     ORDER BY id_conversa DESC
     LIMIT 1
""")

NOVA_CONVERSA = text("""
    INSERT INTO chat_conversas (id_usuario, iniciada_em, ultima_interacao)
    VALUES (:id_usuario, :agora, :agora)
    RETURNING id_conversa
""")

TOCAR_CONVERSA = text("""
    UPDATE chat_conversas SET ultima_interacao = :agora
     WHERE id_conversa = :id_conversa AND id_usuario = :id_usuario
""")

ENCERRAR_CONVERSA = text("""
    UPDATE chat_conversas SET encerrada_em = :agora, motivo_encerramento = :motivo
     WHERE id_conversa = :id_conversa AND id_usuario = :id_usuario AND encerrada_em IS NULL
""")

REGISTRAR_MENSAGEM = text("""
    INSERT INTO chat_mensagens
           (id_conversa, id_usuario, momento, pergunta_redigida, intencao, consulta_executada,
            registros, resposta, redigida_por_ia, tentativa_burla)
    VALUES (:id_conversa, :id_usuario, :momento, :pergunta_redigida, :intencao, :consulta_executada,
            :registros, :resposta, :redigida_por_ia, :tentativa_burla)
""")

HISTORICO_DO_USUARIO = text("""
    SELECT id_conversa, momento, pergunta_redigida, intencao, resposta
      FROM chat_mensagens
     WHERE id_usuario = :id_usuario
     ORDER BY momento DESC, id_mensagem DESC
     LIMIT :limite
""")

# Catalogo de disciplinas: serve so para reconhecer o nome citado na
# pergunta e dizer "voce nao esta matriculado nela", em vez de inventar.
NOMES_DAS_DISCIPLINAS = text("""
    SELECT DISTINCT nome FROM materias ORDER BY nome LIMIT 300
""")
