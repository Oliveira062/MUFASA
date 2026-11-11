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

# ---------------------------------------------------------------------------
# Busca da equipe com filtros combinados (app/chatbot/filtros.py)
# UMA consulta fixa: cada filtro e um par de limites (minimo e maximo,
# inclusivo ou exclusivo) que fica NULL quando nao foi pedido. O texto da
# pergunta nunca entra no SQL, so os numeros, como parametros.
# A distancia so e lida quando :ver_distancia e verdadeiro (nucleo de apoio).
# ---------------------------------------------------------------------------

LIMITE_BUSCA = 15
CAMPOS_DA_BUSCA = ("frequencia", "media", "faltas", "pendencias", "semestre", "distancia")

_FILTROS_DA_BUSCA = """
     WHERE (CAST(:id_professor AS VARCHAR) IS NULL
            OR b.id_aluno IN (SELECT id_aluno FROM vw_chat_vinculo_docente WHERE id_professor = :id_professor))
       AND (CAST(:id_curso AS VARCHAR) IS NULL OR b.id_curso = :id_curso)
       AND (CAST(:niveis AS VARCHAR[]) IS NULL OR b.nivel_risco = ANY(CAST(:niveis AS VARCHAR[])))
       AND (NOT CAST(:media_caiu AS BOOLEAN) OR b.tendencia_media < 0)
       AND (CAST(:frequencia_ge AS NUMERIC) IS NULL OR b.frequencia_pct >= :frequencia_ge)
       AND (CAST(:frequencia_gt AS NUMERIC) IS NULL OR b.frequencia_pct >  :frequencia_gt)
       AND (CAST(:frequencia_le AS NUMERIC) IS NULL OR b.frequencia_pct <= :frequencia_le)
       AND (CAST(:frequencia_lt AS NUMERIC) IS NULL OR b.frequencia_pct <  :frequencia_lt)
       AND (CAST(:media_ge AS NUMERIC) IS NULL OR b.media_atual >= :media_ge)
       AND (CAST(:media_gt AS NUMERIC) IS NULL OR b.media_atual >  :media_gt)
       AND (CAST(:media_le AS NUMERIC) IS NULL OR b.media_atual <= :media_le)
       AND (CAST(:media_lt AS NUMERIC) IS NULL OR b.media_atual <  :media_lt)
       AND (CAST(:faltas_ge AS NUMERIC) IS NULL OR b.faltas_total >= :faltas_ge)
       AND (CAST(:faltas_gt AS NUMERIC) IS NULL OR b.faltas_total >  :faltas_gt)
       AND (CAST(:faltas_le AS NUMERIC) IS NULL OR b.faltas_total <= :faltas_le)
       AND (CAST(:faltas_lt AS NUMERIC) IS NULL OR b.faltas_total <  :faltas_lt)
       AND (CAST(:pendencias_ge AS NUMERIC) IS NULL OR b.atividades_pendentes >= :pendencias_ge)
       AND (CAST(:pendencias_gt AS NUMERIC) IS NULL OR b.atividades_pendentes >  :pendencias_gt)
       AND (CAST(:pendencias_le AS NUMERIC) IS NULL OR b.atividades_pendentes <= :pendencias_le)
       AND (CAST(:pendencias_lt AS NUMERIC) IS NULL OR b.atividades_pendentes <  :pendencias_lt)
       AND (CAST(:semestre_ge AS NUMERIC) IS NULL OR b.semestre_atual >= :semestre_ge)
       AND (CAST(:semestre_gt AS NUMERIC) IS NULL OR b.semestre_atual >  :semestre_gt)
       AND (CAST(:semestre_le AS NUMERIC) IS NULL OR b.semestre_atual <= :semestre_le)
       AND (CAST(:semestre_lt AS NUMERIC) IS NULL OR b.semestre_atual <  :semestre_lt)
       AND (CAST(:distancia_ge AS NUMERIC) IS NULL OR (:ver_distancia AND d.distancia_km >= :distancia_ge))
       AND (CAST(:distancia_gt AS NUMERIC) IS NULL OR (:ver_distancia AND d.distancia_km >  :distancia_gt))
       AND (CAST(:distancia_le AS NUMERIC) IS NULL OR (:ver_distancia AND d.distancia_km <= :distancia_le))
       AND (CAST(:distancia_lt AS NUMERIC) IS NULL OR (:ver_distancia AND d.distancia_km <  :distancia_lt))
"""

BUSCA_ALUNOS = text("""
    SELECT b.id_aluno, b.nome_ficticio, b.semestre_atual, b.nivel_risco, b.frequencia_pct, b.media_atual,
           b.faltas_total, b.atividades_pendentes, b.tendencia_media,
           CASE WHEN :ver_distancia THEN d.distancia_km END AS distancia_km
      FROM vw_chat_busca_alunos b
      LEFT JOIN vw_chat_deslocamento d ON d.id_aluno = b.id_aluno AND :ver_distancia
""" + _FILTROS_DA_BUSCA + """
     ORDER BY CASE b.nivel_risco WHEN 'Crítico' THEN 0 WHEN 'Alto' THEN 1 WHEN 'Moderado' THEN 2
                                 WHEN 'Baixo' THEN 3 ELSE 4 END, b.frequencia_pct NULLS LAST, b.nome_ficticio
     LIMIT :limite
""")

# Agregado de uma linha so (por isso sem LIMIT).
CONTAGEM_BUSCA_ALUNOS = text("""
    SELECT COUNT(*) AS total,
           COUNT(*) FILTER (WHERE b.nivel_risco = 'Crítico') AS criticos,
           COUNT(*) FILTER (WHERE b.nivel_risco = 'Alto') AS altos
      FROM vw_chat_busca_alunos b
      LEFT JOIN vw_chat_deslocamento d ON d.id_aluno = b.id_aluno AND :ver_distancia
""" + _FILTROS_DA_BUSCA)

_SUFIXO = {">": ("gt",), ">=": ("ge",), "<": ("lt",), "<=": ("le",), "=": ("ge", "le"), "entre": ("ge", "le")}


def parametros_busca(filtros: list, niveis: list[str], media_caiu: bool, ver_distancia: bool,
                     id_professor: str | None = None, id_curso: str | None = None) -> dict:
    """Traduz a lista de filtros (campo e operador ja conferidos) nos limites da consulta fixa."""
    params = {f"{c}_{s}": None for c in CAMPOS_DA_BUSCA for s in ("ge", "gt", "le", "lt")}
    for f in filtros:
        if f.campo not in CAMPOS_DA_BUSCA or f.operador not in _SUFIXO:
            raise ValueError("filtro fora da lista permitida")
        sufixos = _SUFIXO[f.operador]
        if f.operador == "entre":
            params[f"{f.campo}_ge"], params[f"{f.campo}_le"] = f.valor, f.valor2
        else:
            for sufixo in sufixos:
                params[f"{f.campo}_{sufixo}"] = f.valor
    params.update({"niveis": list(niveis) or None, "media_caiu": bool(media_caiu), "ver_distancia": bool(ver_distancia),
                   "id_professor": id_professor, "id_curso": id_curso})
    return params


# ---------------------------------------------------------------------------
# Respostas pessoais e atividades com prazo
# ---------------------------------------------------------------------------

PERFIL_DO_ALUNO = text("""
    SELECT nome_ficticio, nivel_risco, nivel_anterior, fatores_principais, periodo_letivo, frequencia_pct,
           media_atual, media_semestre_anterior, tendencia_media, atividades_pendentes
      FROM vw_chat_busca_alunos
     WHERE id_aluno = :id_aluno
     LIMIT 1
""")

ATIVIDADES_PENDENTES_DO_ALUNO = text("""
    SELECT disciplina, titulo, tipo, prazo_em
      FROM vw_chat_atividades_aluno
     WHERE id_aluno = :id_aluno AND entregue_em IS NULL
     ORDER BY prazo_em, disciplina
     LIMIT :limite
""")

ULTIMAS_DA_CONVERSA = text("""
    SELECT m.pergunta_redigida, m.intencao
      FROM chat_mensagens m
      JOIN chat_conversas c ON c.id_conversa = m.id_conversa
     WHERE m.id_usuario = :id_usuario AND c.encerrada_em IS NULL
     ORDER BY m.momento DESC, m.id_mensagem DESC
     LIMIT :limite
""")
