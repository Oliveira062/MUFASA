-- MUFASA — banco do chatbot (F2), sobre o B1 e o complemento do B3 (PostgreSQL 16)
--
-- Aplicar DEPOIS de sql/b3_complemento.sql, conectado como dono do banco:
--     psql -d mufasa -f sql/chatbot.sql
--     psql -d mufasa -c "ALTER ROLE mufasa_chat PASSWORD 'escolha-uma-senha-forte'"
--
-- O que este arquivo faz (RN06, Anexo D.2):
--   1. Cria VISOES so de leitura com o minimo que o chatbot responde.
--      Nenhuma tem dado socioeconomico, de saude, de acessibilidade, idade,
--      bairro, senha ou usuario.
--   2. Cria as tabelas de conversa e historico (RN13).
--   3. Da ao perfil mufasa_chat acesso SO a essas visoes e tabelas.
-- O que NAO faz: nao altera nenhuma tabela nem nenhum dado do B1.
-- As visoes tambem ignoram linhas de matriculas sem id_aluno. As 2.000 sobras
-- de importacao do dump original sao removidas por sql/b1_limpeza_sobras.sql
-- (ou nem existem no dump limpo em ../banco/).

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Visoes do chatbot
-- security_barrier impede que uma funcao no WHERE de quem consulta veja
-- linhas antes do filtro da visao.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_chat_disciplinas_aluno WITH (security_barrier = true) AS
SELECT m.id_aluno,
       mt.nome                  AS disciplina,
       t.periodo_letivo,
       m.va1, m.va2, m.va3,
       m.nota_final,
       m.frequencia_pct,
       m.situacao,
       mt.frequencia_minima_pct
  FROM matriculas m
  JOIN turmas   t  ON t.id_turma   = m.id_turma
  JOIN materias mt ON mt.id_materia = t.id_materia
 WHERE m.id_aluno IS NOT NULL;

CREATE OR REPLACE VIEW vw_chat_indicadores WITH (security_barrier = true) AS
SELECT id_aluno, periodo_letivo, faltas_total, frequencia_pct, media_semestre_anterior,
       media_atual, tendencia_media, atividades_pendentes
  FROM indicadores_academicos;

-- Ultima avaliacao de cada aluno, com o nome ficticio para as listas da equipe.
CREATE OR REPLACE VIEW vw_chat_risco_atual WITH (security_barrier = true) AS
SELECT a.id_aluno, a.nome_ficticio, a.id_curso, a.semestre_atual,
       r.nivel_risco, r.data_avaliacao, r.periodo_letivo
  FROM alunos a
  JOIN LATERAL (
        SELECT r2.nivel_risco, r2.data_avaliacao, r2.periodo_letivo
          FROM avaliacoes_risco r2
         WHERE r2.id_aluno = a.id_aluno
         ORDER BY r2.data_avaliacao DESC, r2.id_avaliacao DESC
         LIMIT 1) r ON TRUE;

-- Vinculo aluno-docente, para o escopo do perfil DOCENTE.
CREATE OR REPLACE VIEW vw_chat_vinculo_docente WITH (security_barrier = true) AS
SELECT DISTINCT m.id_aluno, t.id_professor
  FROM matriculas m
  JOIN turmas t ON t.id_turma = m.id_turma
 WHERE m.id_aluno IS NOT NULL;

-- ---------------------------------------------------------------------------
-- 2. Conversa e historico
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS chat_conversas (
    id_conversa          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario           BIGINT      NOT NULL REFERENCES usuarios(id_usuario),
    iniciada_em          TIMESTAMPTZ NOT NULL DEFAULT now(),
    ultima_interacao     TIMESTAMPTZ NOT NULL DEFAULT now(),
    encerrada_em         TIMESTAMPTZ,
    motivo_encerramento  VARCHAR(12) CHECK (motivo_encerramento IN ('INATIVIDADE', 'USUARIO'))
);
CREATE INDEX IF NOT EXISTS ix_chat_conversas_aberta ON chat_conversas(id_usuario) WHERE encerrada_em IS NULL;

CREATE TABLE IF NOT EXISTS chat_mensagens (
    id_mensagem          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_conversa          BIGINT       NOT NULL REFERENCES chat_conversas(id_conversa),
    id_usuario           BIGINT       NOT NULL REFERENCES usuarios(id_usuario),
    momento              TIMESTAMPTZ  NOT NULL DEFAULT now(),
    pergunta_redigida    VARCHAR(600) NOT NULL,   -- sem CPF, e-mail, telefone e matricula
    intencao             VARCHAR(40)  NOT NULL,
    consulta_executada   VARCHAR(80),
    registros            INTEGER      NOT NULL DEFAULT 0,
    resposta             VARCHAR(4000) NOT NULL,
    redigida_por_ia      BOOLEAN      NOT NULL DEFAULT FALSE,
    tentativa_burla      BOOLEAN      NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_chat_mensagens_usuario ON chat_mensagens(id_usuario, momento DESC);
CREATE INDEX IF NOT EXISTS ix_chat_mensagens_burla ON chat_mensagens(momento) WHERE tentativa_burla;

-- ---------------------------------------------------------------------------
-- 3. Permissoes do perfil mufasa_chat (criado em b3_complemento.sql)
-- ---------------------------------------------------------------------------

-- Retira o que o complemento do B3 tinha dado: o chatbot nao precisa das tabelas.
REVOKE ALL ON cursos, materias, turmas FROM mufasa_chat;

GRANT SELECT ON vw_chat_disciplinas_aluno, vw_chat_indicadores, vw_chat_risco_atual,
               vw_chat_vinculo_docente TO mufasa_chat;
-- Nomes das disciplinas, para reconhecer a citada na pergunta.
GRANT SELECT (nome) ON materias TO mufasa_chat;

GRANT SELECT, INSERT ON chat_conversas TO mufasa_chat;
GRANT UPDATE (ultima_interacao, encerrada_em, motivo_encerramento) ON chat_conversas TO mufasa_chat;
GRANT SELECT, INSERT ON chat_mensagens TO mufasa_chat;   -- historico: sem UPDATE nem DELETE
GRANT USAGE ON SEQUENCE chat_conversas_id_conversa_seq, chat_mensagens_id_mensagem_seq TO mufasa_chat;
-- REFERENCES usuarios exige que o banco confira a chave; o perfil nao le a tabela.

-- Teto de tempo por consulta, para uma pergunta nunca travar o banco.
ALTER ROLE mufasa_chat SET statement_timeout = '3s';

COMMIT;
