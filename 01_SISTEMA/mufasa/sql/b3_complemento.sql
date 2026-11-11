-- MUFASA — complemento do B3 sobre o banco do B1 (PostgreSQL 16)
--
-- Aplicar DEPOIS do dump do B1, conectado como dono do banco:
--     psql -d mufasa -f sql/b3_complemento.sql
--
-- O que este arquivo faz:
--   1. Cria as tabelas que so o B3 usa: usuarios, tokens_revogados,
--      auditoria_acessos, consentimentos, solicitacoes_titular.
--   2. Cria perfis de banco com menor privilegio: a API e o chatbot nunca
--      conectam como postgres.
--   3. Torna a auditoria append-only (sem UPDATE e sem DELETE).
-- O que NAO faz: nao altera nenhuma tabela do B1. As correcoes sugeridas
-- para o B1 (chaves, tipos, restricoes) estao em docs/AUDITORIA_SEGURANCA.md.
--
-- As senhas dos perfis de banco NAO estao aqui. Definir depois, fora do
-- repositorio:   ALTER ROLE mufasa_api PASSWORD '...';

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Tabelas do B3
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    login          VARCHAR(64)  NOT NULL UNIQUE CHECK (login ~ '^[A-Za-z0-9._@-]{3,64}$'),
    senha_hash     VARCHAR(100) NOT NULL CHECK (senha_hash LIKE '$2b$%'),   -- so bcrypt
    perfil         VARCHAR(20)  NOT NULL CHECK (perfil IN ('ALUNO','DOCENTE','COORDENACAO','NUCLEO_APOIO',
                                                           'FINANCEIRO','DIRECAO','ADMIN','ENCARREGADO_DADOS')),
    id_aluno       VARCHAR(10),
    id_professor   VARCHAR(10),
    id_curso       VARCHAR(10),
    ativo          BOOLEAN      NOT NULL DEFAULT TRUE,
    falhas_login   SMALLINT     NOT NULL DEFAULT 0,
    bloqueado_ate  TIMESTAMPTZ,
    ultimo_login   TIMESTAMPTZ,
    criado_em      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    -- Cada perfil carrega so o vinculo de que precisa.
    CHECK (perfil <> 'ALUNO'   OR id_aluno IS NOT NULL),
    CHECK (perfil <> 'DOCENTE' OR id_professor IS NOT NULL)
);
-- Quando o B1 criar as chaves primarias, adicionar:
--   ALTER TABLE usuarios ADD FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno);
--   ALTER TABLE usuarios ADD FOREIGN KEY (id_professor) REFERENCES professores(id_professor);
CREATE UNIQUE INDEX IF NOT EXISTS ux_usuarios_aluno ON usuarios(id_aluno) WHERE id_aluno IS NOT NULL;

CREATE TABLE IF NOT EXISTS tokens_revogados (
    jti        VARCHAR(64) PRIMARY KEY,
    expira_em  TIMESTAMPTZ NOT NULL
);
-- Limpeza periodica:  DELETE FROM tokens_revogados WHERE expira_em < now();

CREATE TABLE IF NOT EXISTS auditoria_acessos (
    id_auditoria   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    momento        TIMESTAMPTZ  NOT NULL DEFAULT now(),
    id_requisicao  VARCHAR(32),
    id_usuario     BIGINT,
    perfil         VARCHAR(20),
    operacao       VARCHAR(40)  NOT NULL,
    recurso        VARCHAR(200) NOT NULL,
    id_aluno_alvo  VARCHAR(10),
    resultado      VARCHAR(12)  NOT NULL CHECK (resultado IN ('PERMITIDO','NEGADO','BLOQUEADO')),
    origem         VARCHAR(45)               -- IP; guardar por 6 meses (Marco Civil, art. 15)
);
CREATE INDEX IF NOT EXISTS ix_auditoria_aluno   ON auditoria_acessos(id_aluno_alvo, momento);
CREATE INDEX IF NOT EXISTS ix_auditoria_momento ON auditoria_acessos(momento);

-- Consentimento como LOG de eventos: conceder e revogar sao linhas novas.
-- O estado atual e o evento mais recente por finalidade.
CREATE TABLE IF NOT EXISTS consentimentos (
    id_consentimento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno         VARCHAR(10)  NOT NULL,
    finalidade       VARCHAR(30)  NOT NULL CHECK (finalidade IN ('DADOS_SAUDE')),
    concedido        BOOLEAN      NOT NULL,
    concedido_por    VARCHAR(12)  NOT NULL CHECK (concedido_por IN ('TITULAR','RESPONSAVEL')),
    versao_termo     VARCHAR(10)  NOT NULL,
    registrado_em    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    id_usuario       BIGINT       NOT NULL
);
CREATE INDEX IF NOT EXISTS ix_consentimentos_aluno ON consentimentos(id_aluno, finalidade, registrado_em);

CREATE TABLE IF NOT EXISTS solicitacoes_titular (
    id_solicitacao BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno       VARCHAR(10)   NOT NULL,
    tipo           VARCHAR(40)   NOT NULL,
    descricao      VARCHAR(1000) NOT NULL DEFAULT '',
    situacao       VARCHAR(12)   NOT NULL DEFAULT 'ABERTA' CHECK (situacao IN ('ABERTA','EM_ANALISE','ATENDIDA','NEGADA')),
    registrada_em  TIMESTAMPTZ   NOT NULL DEFAULT now(),
    respondida_em  TIMESTAMPTZ
);

-- Indices que as consultas da API usam nas tabelas do B1. Indice nao muda dado.
CREATE INDEX IF NOT EXISTS ix_b3_avaliacoes_aluno_data ON avaliacoes_risco(id_aluno, data_avaliacao DESC);
CREATE INDEX IF NOT EXISTS ix_b3_matriculas_aluno      ON matriculas(id_aluno);
CREATE INDEX IF NOT EXISTS ix_b3_turmas_professor      ON turmas(id_professor);
CREATE INDEX IF NOT EXISTS ix_b3_indicadores_aluno     ON indicadores_academicos(id_aluno, periodo_letivo DESC);
CREATE INDEX IF NOT EXISTS ix_b3_alunos_curso          ON alunos(id_curso);

-- ---------------------------------------------------------------------------
-- 2. Perfis de banco com menor privilegio
-- ---------------------------------------------------------------------------

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_api') THEN
        CREATE ROLE mufasa_api LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_chat') THEN
        CREATE ROLE mufasa_chat LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
    END IF;
END $$;

-- Ninguem herda acesso por padrao.
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO mufasa_api, mufasa_chat;

-- API: le as tabelas do B1, nunca altera.
GRANT SELECT ON alunos, cursos, materias, turmas, matriculas, indicadores_academicos,
               socioeconomico, avaliacoes_risco, professores TO mufasa_api;

-- API: tabelas proprias, com o minimo de operacoes.
-- Usuarios sao criados pelo script scripts/criar_usuario.py, com o dono do banco.
GRANT SELECT ON usuarios TO mufasa_api;
GRANT UPDATE (falhas_login, bloqueado_ate, ultimo_login) ON usuarios TO mufasa_api;
GRANT SELECT, INSERT ON tokens_revogados TO mufasa_api;
GRANT SELECT, INSERT ON auditoria_acessos TO mufasa_api;          -- sem UPDATE/DELETE: append-only
GRANT SELECT, INSERT ON consentimentos TO mufasa_api;             -- revogacao e linha nova
GRANT SELECT, INSERT ON solicitacoes_titular TO mufasa_api;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO mufasa_api;

-- Chatbot (RN06): somente leitura, sem dado socioeconomico nem de saude.
GRANT SELECT ON cursos, materias, turmas TO mufasa_chat;

-- ---------------------------------------------------------------------------
-- 3. Auditoria imutavel mesmo para quem tiver UPDATE por engano
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION bloquear_alteracao_auditoria() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'auditoria_acessos e somente de insercao';
END $$;

DROP TRIGGER IF EXISTS tg_auditoria_imutavel ON auditoria_acessos;
CREATE TRIGGER tg_auditoria_imutavel
    BEFORE UPDATE OR DELETE ON auditoria_acessos
    FOR EACH ROW EXECUTE FUNCTION bloquear_alteracao_auditoria();

-- Retencao: o expurgo semestral dos IPs com mais de 6 meses e feito pelo dono
-- do banco, em rotina documentada, desativando o gatilho so durante a rotina:
--   ALTER TABLE auditoria_acessos DISABLE TRIGGER tg_auditoria_imutavel;
--   UPDATE auditoria_acessos SET origem = NULL WHERE momento < now() - interval '6 months';
--   ALTER TABLE auditoria_acessos ENABLE TRIGGER tg_auditoria_imutavel;

COMMIT;
