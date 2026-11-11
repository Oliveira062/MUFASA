-- Migracao 002: atividades com prazo e visoes novas do chatbot.
-- Criada em 28/10/2026 (pedido do João). Depois de aplicada, este arquivo nao se edita.
--
-- 1. atividades_aluno: cada atividade do aluno em uma turma, com prazo e data
--    de entrega. Enquanto a instituicao nao carrega as atividades reais, o
--    banco de demonstracao recebe atividades SIMULADAS (coluna simulada = TRUE),
--    geradas por scripts/simular_atividades.py de forma coerente com
--    indicadores_academicos.atividades_pendentes.
-- 2. vw_chat_atividades_aluno: o que o aluno pergunta ("o que vence esta semana?").
-- 3. vw_chat_busca_alunos: indicadores atuais + nivel de risco + tendencia, para
--    as buscas com filtros combinados da equipe e para respostas pessoais.
-- 4. vw_chat_deslocamento: distancia e tempo de deslocamento. E dado
--    socioeconomico: o chatbot so usa para o nucleo de apoio, o unico perfil
--    que ja ve esse dado no painel (app/api/visibilidade.py).

CREATE TABLE IF NOT EXISTS atividades_aluno (
    id_atividade  BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno      VARCHAR(255) NOT NULL REFERENCES alunos(id_aluno),
    id_turma      VARCHAR(255) NOT NULL REFERENCES turmas(id_turma),
    titulo        VARCHAR(120) NOT NULL,
    tipo          VARCHAR(30)  NOT NULL,
    prazo_em      DATE         NOT NULL,
    entregue_em   DATE,
    simulada      BOOLEAN      NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_atividades_aluno_prazo ON atividades_aluno (id_aluno, prazo_em);
-- Mesmo dono das demais tabelas do B1, para as visoes (dono mufasa_dono) poderem ler.
ALTER TABLE atividades_aluno OWNER TO mufasa_dono;

CREATE OR REPLACE VIEW vw_chat_atividades_aluno WITH (security_barrier = true) AS
SELECT a.id_aluno, mt.nome AS disciplina, a.titulo, a.tipo, a.prazo_em, a.entregue_em
  FROM atividades_aluno a
  JOIN turmas   t  ON t.id_turma   = a.id_turma
  JOIN materias mt ON mt.id_materia = t.id_materia;

CREATE OR REPLACE VIEW vw_chat_busca_alunos WITH (security_barrier = true) AS
SELECT a.id_aluno, a.nome_ficticio, a.id_curso, a.semestre_atual,
       CASE s.nivel WHEN 'CRITICO' THEN 'Crítico' WHEN 'ALTO' THEN 'Alto'
                    WHEN 'MODERADO' THEN 'Moderado' WHEN 'BAIXO' THEN 'Baixo' END AS nivel_risco,
       CASE s.nivel_anterior WHEN 'CRITICO' THEN 'Crítico' WHEN 'ALTO' THEN 'Alto'
                    WHEN 'MODERADO' THEN 'Moderado' WHEN 'BAIXO' THEN 'Baixo' END AS nivel_anterior,
       s.fatores_principais,
       s.calculado_em::date AS data_avaliacao,
       i.periodo_letivo, i.frequencia_pct, i.faltas_total, i.media_atual, i.media_semestre_anterior,
       i.tendencia_media, i.atividades_pendentes
  FROM alunos a
  LEFT JOIN vw_score_atual s ON s.id_aluno = a.id_aluno AND s.nivel <> 'INDETERMINADO'
  LEFT JOIN LATERAL (SELECT * FROM indicadores_academicos x WHERE x.id_aluno = a.id_aluno
                      ORDER BY x.periodo_letivo DESC LIMIT 1) i ON TRUE;

CREATE OR REPLACE VIEW vw_chat_deslocamento WITH (security_barrier = true) AS
SELECT id_aluno, distancia_km, tempo_deslocamento_min
  FROM socioeconomico;

ALTER VIEW vw_chat_atividades_aluno OWNER TO mufasa_dono;
ALTER VIEW vw_chat_busca_alunos OWNER TO mufasa_dono;
ALTER VIEW vw_chat_deslocamento OWNER TO mufasa_dono;

GRANT SELECT ON vw_chat_atividades_aluno, vw_chat_busca_alunos, vw_chat_deslocamento TO mufasa_chat;
