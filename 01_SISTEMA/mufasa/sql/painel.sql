-- MUFASA — tabelas dos paineis, alertas e operacao (PostgreSQL 16)
--
-- Aplicar DEPOIS de sql/b3_complemento.sql e ANTES de sql/chatbot.sql:
--     psql -d mufasa -f sql/painel.sql
--
-- O que este arquivo cria:
--   1. Colunas novas em usuarios (nome, e-mail, termo de primeiro acesso,
--      troca obrigatoria de senha) e as chaves estrangeiras que faltavam.
--   2. scores_risco: historico de cada calculo do B2. O painel le sempre o
--      ultimo calculo de cada aluno (vw_score_atual).
--   3. Alertas com prazo (Critico 48 h, Alto 5 dias uteis), responsavel,
--      historico so de insercao e notificacoes.
--   4. Parametros versionados, com proposta da administracao tecnica e
--      aprovacao da coordenacao.
--   5. Cargas de CSV em duas etapas (validar, depois confirmar).
--   6. Registros tecnicos e sinal de vida dos servicos.
--   7. fila_recalculo + gatilhos: qualquer mudanca nos indicadores ou no
--      socioeconomico coloca o aluno na fila e avisa o servico de calculo
--      (NOTIFY), que recalcula o score e atualiza os alertas em segundos.
--   8. Perfil de banco mufasa_calculo (servico de calculo), com o minimo.
--
-- Senhas dos perfis de banco ficam fora do repositorio:
--     ALTER ROLE mufasa_calculo PASSWORD '...';

BEGIN;

-- ---------------------------------------------------------------------------
-- 1. Usuarios
-- ---------------------------------------------------------------------------

ALTER TABLE usuarios
    ADD COLUMN IF NOT EXISTS nome              VARCHAR(120),
    ADD COLUMN IF NOT EXISTS email             VARCHAR(160),
    ADD COLUMN IF NOT EXISTS deve_trocar_senha BOOLEAN     NOT NULL DEFAULT TRUE,
    ADD COLUMN IF NOT EXISTS senha_alterada_em TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS termo_versao      VARCHAR(10),
    ADD COLUMN IF NOT EXISTS termo_aceito_em   TIMESTAMPTZ,
    -- Conta de demonstracao: a API recusa o login dela quando AMBIENTE=producao.
    ADD COLUMN IF NOT EXISTS demonstracao      BOOLEAN     NOT NULL DEFAULT FALSE;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_usuarios_aluno') THEN
        ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_aluno FOREIGN KEY (id_aluno) REFERENCES alunos(id_aluno);
        ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_professor FOREIGN KEY (id_professor) REFERENCES professores(id_professor);
        ALTER TABLE usuarios ADD CONSTRAINT fk_usuarios_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso);
        ALTER TABLE usuarios ADD CONSTRAINT ck_usuarios_email CHECK (email IS NULL OR email ~ '^[^@\s]+@[^@\s]+\.[^@\s]+$');
        -- Coordenacao e nucleo de apoio trabalham sobre um curso.
        ALTER TABLE usuarios ADD CONSTRAINT ck_usuarios_curso
            CHECK (perfil NOT IN ('COORDENACAO', 'NUCLEO_APOIO') OR id_curso IS NOT NULL);
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 2. Score calculado pelo B2
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS scores_risco (
    id_score                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno                VARCHAR(255) NOT NULL REFERENCES alunos(id_aluno),
    score                   SMALLINT     CHECK (score BETWEEN 0 AND 100),
    nivel                   VARCHAR(14)  NOT NULL CHECK (nivel IN ('BAIXO','MODERADO','ALTO','CRITICO','INDETERMINADO')),
    completude              NUMERIC(4,3) NOT NULL CHECK (completude BETWEEN 0 AND 1),   -- fracao do peso disponivel
    fatores_principais      JSONB        NOT NULL DEFAULT '[]',
    detalhamento            JSONB        NOT NULL DEFAULT '{}',
    contribuicoes           JSONB        NOT NULL DEFAULT '{}',
    sobreposicao_frequencia BOOLEAN      NOT NULL DEFAULT FALSE,
    recomendacao            VARCHAR(400) NOT NULL DEFAULT '',
    -- RN01/RN02/RN04: origem do nivel, fatores com frase e modificadores ficam
    -- gravados junto do score, e nao recalculados na exibicao.
    nivel_origem            VARCHAR(16)  NOT NULL DEFAULT 'FAIXA'
                                         CHECK (nivel_origem IN ('FAIXA','FAIXA_PARCIAL','SOBREPOSICAO','COMPLETUDE')),
    motivo_sobreposicao     VARCHAR(400),
    parcial                 BOOLEAN      NOT NULL DEFAULT FALSE,
    fatores                 JSONB        NOT NULL DEFAULT '[]',
    modificadores           JSONB        NOT NULL DEFAULT '[]',
    recomendacoes           JSONB        NOT NULL DEFAULT '[]',   -- catalogo do Anexo F (G.2)
    tendencia               VARCHAR(18)  CHECK (tendencia IN ('MELHORA','ESTAVEL','PIORA','PIORA_SUSTENTADA')),
    score_anterior          SMALLINT,
    nivel_anterior          VARCHAR(14),
    versao_parametros       INTEGER      NOT NULL,
    versao_modelo           VARCHAR(30)  NOT NULL,
    motivo                  VARCHAR(40)  NOT NULL DEFAULT 'carga_inicial',
    calculado_em            TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_scores_aluno_momento ON scores_risco(id_aluno, calculado_em DESC, id_score DESC);
CREATE INDEX IF NOT EXISTS ix_scores_momento ON scores_risco(calculado_em);

-- Ultimo calculo de cada aluno.
CREATE OR REPLACE VIEW vw_score_atual WITH (security_barrier = true) AS
SELECT DISTINCT ON (s.id_aluno)
       s.id_score, s.id_aluno, s.score, s.nivel, s.completude, s.fatores_principais, s.detalhamento,
       s.contribuicoes, s.sobreposicao_frequencia, s.recomendacao, s.versao_modelo, s.calculado_em,
       s.nivel_origem, s.motivo_sobreposicao, s.parcial, s.fatores, s.modificadores, s.recomendacoes,
       s.tendencia, s.score_anterior, s.nivel_anterior, s.versao_parametros
  FROM scores_risco s
 ORDER BY s.id_aluno, s.calculado_em DESC, s.id_score DESC;

-- ---------------------------------------------------------------------------
-- 3. Alertas, historico e notificacoes
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS alertas (
    id_alerta             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno              VARCHAR(255) NOT NULL REFERENCES alunos(id_aluno),
    id_score_origem       BIGINT       NOT NULL REFERENCES scores_risco(id_score),
    -- ALTO e CRITICO: alerta pedagogico. INDETERMINADO: tarefa de correcao de
    -- dados (RN01, CA12), que nunca entra na fila pedagogica.
    tipo                  VARCHAR(12)  NOT NULL DEFAULT 'PEDAGOGICO' CHECK (tipo IN ('PEDAGOGICO','DADOS')),
    -- Nivel atual do aluno. Se ele sair de Alto/Critico, o alerta e atualizado,
    -- nao apagado (RN03): quem fecha e a equipe, com o desfecho.
    nivel                 VARCHAR(14)  NOT NULL CHECK (nivel IN ('BAIXO','MODERADO','ALTO','CRITICO','INDETERMINADO')),
    situacao              VARCHAR(16)  NOT NULL DEFAULT 'ABERTO'
                                       CHECK (situacao IN ('ABERTO','EM_ATENDIMENTO','ENCERRADO')),
    criado_em             TIMESTAMPTZ  NOT NULL DEFAULT now(),
    prazo_em              TIMESTAMPTZ  NOT NULL,
    id_responsavel        BIGINT       REFERENCES usuarios(id_usuario),
    atribuido_em          TIMESTAMPTZ,
    primeira_acao_em      TIMESTAMPTZ,
    encerrado_em          TIMESTAMPTZ,
    -- Registro de desfecho (Anexo F, G.3): causa e desfecho em lista fechada.
    causa                 VARCHAR(20)  CHECK (causa IN ('FINANCEIRA','ACADEMICA','TRABALHO','SAUDE','FAMILIAR',
                                                      'TRANSPORTE','ESCOLHA_DE_CURSO','INSTITUCIONAL',
                                                      'NAO_IDENTIFICADA')),
    desfecho              VARCHAR(20)  CHECK (desfecho IN ('PERMANECEU','TRANCOU','EVADIU','TRANSFERIU',
                                                         'EM_ACOMPANHAMENTO','DADOS_CORRIGIDOS')),
    houve_contato         BOOLEAN,
    canal_contato         VARCHAR(20)  CHECK (canal_contato IN ('AMBIENTE_VIRTUAL','PRESENCIAL','EMAIL_INSTITUCIONAL',
                                                              'EMERGENCIA_RN19')),
    acoes_executadas      VARCHAR(1000),
    score_no_encerramento SMALLINT,
    atualizado_em         TIMESTAMPTZ  NOT NULL DEFAULT now(),
    -- CA20: nenhum alerta e encerrado sem causa e desfecho preenchidos.
    CHECK (situacao <> 'ENCERRADO' OR (encerrado_em IS NOT NULL AND causa IS NOT NULL AND desfecho IS NOT NULL
                                       AND houve_contato IS NOT NULL AND acoes_executadas IS NOT NULL))
);
-- Um alerta aberto por aluno e por tipo.
CREATE UNIQUE INDEX IF NOT EXISTS ux_alertas_aberto ON alertas(id_aluno, tipo) WHERE situacao <> 'ENCERRADO';
CREATE INDEX IF NOT EXISTS ix_alertas_situacao_prazo ON alertas(situacao, prazo_em);
CREATE INDEX IF NOT EXISTS ix_alertas_responsavel ON alertas(id_responsavel) WHERE situacao <> 'ENCERRADO';

CREATE TABLE IF NOT EXISTS alerta_eventos (
    id_evento     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_alerta     BIGINT        NOT NULL REFERENCES alertas(id_alerta),
    momento       TIMESTAMPTZ   NOT NULL DEFAULT now(),
    id_usuario    BIGINT        REFERENCES usuarios(id_usuario),   -- vazio = sistema
    tipo          VARCHAR(16)   NOT NULL CHECK (tipo IN ('CRIADO','NIVEL_ALTERADO','ATRIBUIDO','ACAO',
                                                         'PRAZO_VENCIDO','DIVERGENCIA','ENCERRADO')),
    tipo_acao     VARCHAR(24)   CHECK (tipo_acao IN ('CONVERSA','ORIENTACAO_ACADEMICA','ENCAMINHAMENTO_NAE',
                                                     'ENCAMINHAMENTO_FINANCEIRO','CONTATO_SEM_RETORNO','OUTRO')),
    descricao     VARCHAR(1000) NOT NULL DEFAULT '',
    visivel_aluno BOOLEAN       NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS ix_alerta_eventos_alerta ON alerta_eventos(id_alerta, momento);

CREATE TABLE IF NOT EXISTS notificacoes (
    id_notificacao BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_usuario     BIGINT       NOT NULL REFERENCES usuarios(id_usuario),
    criada_em      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    tipo           VARCHAR(20)  NOT NULL CHECK (tipo IN ('ALERTA_NOVO','ALERTA_NIVEL','ALERTA_ATRIBUIDO',
                                                         'PRAZO_VENCIDO','DIVERGENCIA','PARAMETRO','CARGA',
                                                         'TAREFA_DADOS')),
    titulo         VARCHAR(120) NOT NULL,
    texto          VARCHAR(300) NOT NULL,
    id_alerta      BIGINT       REFERENCES alertas(id_alerta),
    lida_em        TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS ix_notificacoes_usuario ON notificacoes(id_usuario, criada_em DESC);

-- ---------------------------------------------------------------------------
-- 4. Parametros versionados
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS parametros (
    chave          VARCHAR(40)    PRIMARY KEY CHECK (chave ~ '^[A-Z0-9_]{3,40}$'),
    valor          NUMERIC(12,4)  NOT NULL,
    minimo         NUMERIC(12,4)  NOT NULL,
    maximo         NUMERIC(12,4)  NOT NULL,
    unidade        VARCHAR(30)    NOT NULL,
    -- FALSE: muda so por recalibracao formal (Anexo A.9), nunca por ajuste avulso.
    editavel       BOOLEAN        NOT NULL DEFAULT TRUE,
    descricao      VARCHAR(300)   NOT NULL,
    atualizado_em  TIMESTAMPTZ    NOT NULL DEFAULT now(),
    CHECK (valor BETWEEN minimo AND maximo)
);

-- Valores padrao do SRS v1.1 (Anexo B, tabela C.2). Mesma lista de
-- app/calculo/parametros.py (CATALOGO); o teste de ponta a ponta confere.
INSERT INTO parametros (chave, valor, minimo, maximo, unidade, editavel, descricao) VALUES
 ('PESO_I1_DESEMPENHO', 0.2, 0, 1, 'fração', FALSE, 'Peso do desempenho acadêmico (I1).'),
 ('PESO_I2_FREQUENCIA', 0.18, 0, 1, 'fração', FALSE, 'Peso da frequência (I2).'),
 ('PESO_I3_REPROVACAO', 0.09, 0, 1, 'fração', FALSE, 'Peso da taxa de reprovação acumulada (I3).'),
 ('PESO_I4_AVA', 0.08, 0, 1, 'fração', FALSE, 'Peso do engajamento no AVA (I4).'),
 ('PESO_I5_FINANCEIRO', 0.11, 0, 1, 'fração', FALSE, 'Peso da situação financeira (I5).'),
 ('PESO_I6_TRABALHO', 0.07, 0, 1, 'fração', FALSE, 'Peso do trabalho (I6).'),
 ('PESO_I7_DESLOCAMENTO', 0.05, 0, 1, 'fração', FALSE, 'Peso do deslocamento (I7).'),
 ('PESO_I8_SAUDE_MENTAL', 0.08, 0, 1, 'fração', FALSE, 'Peso da saúde mental (I8).'),
 ('PESO_I9_SAUDE_FISICA', 0.05, 0, 1, 'fração', FALSE, 'Peso da saúde física (I9).'),
 ('PESO_I10_MORADIA', 0.05, 0, 1, 'fração', FALSE, 'Peso da moradia (I10).'),
 ('PESO_I11_DEPENDENTES', 0.04, 0, 1, 'fração', FALSE, 'Peso dos dependentes sob cuidado (I11).'),
 ('NOTA_MINIMA', 6.0, 0, 10, 'nota 0 a 10', TRUE, 'Nota mínima de aprovação. Autonomia institucional (CF art. 207; LDB art. 53).'),
 ('NOTA_CONFORTAVEL', 8.0, 0, 10, 'nota 0 a 10', TRUE, 'Nota a partir da qual o desempenho não gera risco.'),
 ('NOTA_CRITICA', 4.0, 0, 10, 'nota 0 a 10', TRUE, 'Nota abaixo da qual a curva de I1 entra no último trecho.'),
 ('FREQUENCIA_MINIMA', 75.0, 0, 100, '%', TRUE, 'Frequência mínima para aprovação (LDB art. 47, §3º; prática regulamentar de 75%).'),
 ('FREQUENCIA_CONFORTAVEL', 90.0, 0, 100, '%', TRUE, 'Frequência a partir da qual não há risco.'),
 ('FREQUENCIA_CRITICA', 60.0, 0, 100, '%', TRUE, 'Frequência abaixo da qual a curva de I2 entra no último trecho.'),
 ('RENDA_EXTREMA', 0.25, 0, 10, 'SM por pessoa', TRUE, 'Até este valor: extrema vulnerabilidade (I5 = 100).'),
 ('RENDA_VULNERAVEL', 0.5, 0, 10, 'SM por pessoa', TRUE, 'Corte de baixa renda do CadÚnico (Decreto nº 6.135/2007).'),
 ('RENDA_UM_SM', 1.0, 0, 10, 'SM por pessoa', TRUE, 'Abaixo de um salário mínimo por pessoa.'),
 ('RENDA_AUXILIO', 1.5, 0, 10, 'SM por pessoa', TRUE, 'Teto de prioridade do PNAES (Decreto nº 7.234/2010, art. 5º).'),
 ('SALARIO_MINIMO', 1621.0, 1000, 10000, 'reais', TRUE, 'Salário mínimo nacional vigente (R$ 1.621,00 em 2026). Atualizar a cada decreto anual.'),
 ('JORNADA_LIMITE', 20.0, 0, 80, 'horas por semana', TRUE, 'Jornada acima da qual o trabalho compete com o estudo (Lei nº 11.788/2008 como referência).'),
 ('DESLOCAMENTO_LIMITE', 60.0, 0, 300, 'minutos por trajeto', TRUE, 'Deslocamento de referência por trajeto (faixas do IBGE).'),
 ('AVA_DIAS_SEM_ACESSO', 21.0, 1, 90, 'dias', TRUE, 'Dias sem acesso ao AVA que levam I4 a 100 (Astin, 1984).'),
 ('CORTE_BAIXO', 25.0, 0, 100, 'pontos', TRUE, 'Score até este valor: nível Baixo.'),
 ('CORTE_MODERADO', 50.0, 0, 100, 'pontos', TRUE, 'Score até este valor: nível Moderado.'),
 ('CORTE_ALTO', 75.0, 0, 100, 'pontos', TRUE, 'Score até este valor: nível Alto; acima, Crítico.'),
 ('COMPLETUDE_MINIMA', 40.0, 0, 100, '% dos pesos', TRUE, 'Abaixo disto o nível é Indeterminado (RN01).'),
 ('COMPLETUDE_PLENA', 70.0, 0, 100, '% dos pesos', TRUE, 'Abaixo disto o score é parcial e só chega a Crítico por sobreposição.'),
 ('SLA_CRITICO_HORAS', 48.0, 12, 168, 'horas', TRUE, 'Prazo do primeiro atendimento de alerta Crítico.'),
 ('SLA_ALTO_DIAS_UTEIS', 5.0, 1, 15, 'dias úteis', TRUE, 'Prazo do primeiro atendimento de alerta Alto (sábado e domingo não contam; feriados não estão cadastrados).'),
 ('SLA_DADOS_DIAS_UTEIS', 10.0, 1, 30, 'dias úteis', TRUE, 'Prazo da tarefa de correção de dados de aluno Indeterminado.'),
 ('MINIMO_GRUPO', 5.0, 3, 50, 'alunos', TRUE, 'Grupos menores são suprimidos nos agregados (RN07, CA19).'),
 ('INTERVALO_ATENDIMENTOS', 15.0, 1, 60, 'dias', TRUE, 'Intervalo mínimo entre atendimentos (RN14).'),
 ('TETO_ALERTAS_RESPONSAVEL', 30.0, 1, 500, 'alertas', TRUE, 'Teto de alertas abertos por responsável (valor a confirmar na Sprint 1).')
ON CONFLICT (chave) DO NOTHING;

-- RN22: cada alteracao cria uma versao com autor, data, justificativa e a
-- fotografia completa dos valores. Cada score guarda o numero da versao.
CREATE TABLE IF NOT EXISTS parametros_versoes (
    versao        INTEGER      PRIMARY KEY,
    criada_em     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    autor         BIGINT       REFERENCES usuarios(id_usuario),   -- vazio = carga inicial
    aprovador     BIGINT       REFERENCES usuarios(id_usuario),
    justificativa VARCHAR(500) NOT NULL,
    valores       JSONB        NOT NULL
);
INSERT INTO parametros_versoes (versao, justificativa, valores)
SELECT 1, 'Valores padrão do SRS v1.1 (Anexo B, tabela C.2).', jsonb_object_agg(chave, valor) FROM parametros
ON CONFLICT (versao) DO NOTHING;

-- Calendario: S1 so vale com o periodo em andamento (Anexo A.6). O B1 nao
-- traz datas de periodo; o inicio de 2026/2 e a data da avaliacao inicial
-- do dump, e o fim fica vazio ate a secretaria encerrar o periodo.
CREATE TABLE IF NOT EXISTS periodos_letivos (
    periodo_letivo VARCHAR(10) PRIMARY KEY CHECK (periodo_letivo ~ '^\d{4}/[12]$'),
    inicio         DATE        NOT NULL,
    fim            DATE,
    CHECK (fim IS NULL OR fim > inicio)
);
INSERT INTO periodos_letivos (periodo_letivo, inicio)
SELECT DISTINCT periodo_letivo, DATE '2026-08-17' FROM turmas WHERE periodo_letivo = '2026/2'
ON CONFLICT (periodo_letivo) DO NOTHING;

CREATE TABLE IF NOT EXISTS parametros_propostas (
    id_proposta    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    chave          VARCHAR(40)   NOT NULL REFERENCES parametros(chave),
    valor_anterior NUMERIC(12,4) NOT NULL,
    valor_novo     NUMERIC(12,4) NOT NULL,
    justificativa  VARCHAR(500)  NOT NULL,
    proposto_por   BIGINT        NOT NULL REFERENCES usuarios(id_usuario),
    proposto_em    TIMESTAMPTZ   NOT NULL DEFAULT now(),
    situacao       VARCHAR(10)   NOT NULL DEFAULT 'PENDENTE' CHECK (situacao IN ('PENDENTE','APROVADA','REJEITADA')),
    decidido_por   BIGINT        REFERENCES usuarios(id_usuario),
    decidido_em    TIMESTAMPTZ,
    versao_gerada  INTEGER       REFERENCES parametros_versoes(versao),
    -- Quem propoe nao aprova a propria proposta.
    CHECK (decidido_por IS NULL OR decidido_por <> proposto_por)
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_proposta_pendente ON parametros_propostas(chave) WHERE situacao = 'PENDENTE';

-- ---------------------------------------------------------------------------
-- 5. Cargas de CSV
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cargas (
    id_carga       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo           VARCHAR(20)  NOT NULL CHECK (tipo IN ('INDICADORES','NOTAS')),
    nome_arquivo   VARCHAR(120) NOT NULL,
    tamanho_bytes  INTEGER      NOT NULL CHECK (tamanho_bytes BETWEEN 1 AND 20971520),
    -- Impressao digital do arquivo: o mesmo CSV nao e aplicado duas vezes.
    hash_sha256    CHAR(64)     NOT NULL CHECK (hash_sha256 ~ '^[0-9a-f]{64}$'),
    enviado_por    BIGINT       NOT NULL REFERENCES usuarios(id_usuario),
    enviado_em     TIMESTAMPTZ  NOT NULL DEFAULT now(),
    situacao       VARCHAR(12)  NOT NULL CHECK (situacao IN ('VALIDADA','COM_ERROS','CONFIRMADA','APLICADA',
                                                           'FALHOU','CANCELADA')),
    linhas_total   INTEGER      NOT NULL DEFAULT 0,
    linhas_validas INTEGER      NOT NULL DEFAULT 0,
    confirmado_por BIGINT       REFERENCES usuarios(id_usuario),
    confirmado_em  TIMESTAMPTZ,
    aplicada_em    TIMESTAMPTZ,
    resultado      VARCHAR(300)
);

CREATE TABLE IF NOT EXISTS carga_linhas (
    id_carga BIGINT  NOT NULL REFERENCES cargas(id_carga),
    numero   INTEGER NOT NULL,
    dados    JSONB,
    erro     VARCHAR(300),
    PRIMARY KEY (id_carga, numero)
);

-- ---------------------------------------------------------------------------
-- 6. Operacao: registros tecnicos e sinal de vida dos servicos
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS logs_tecnicos (
    id_log        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    momento       TIMESTAMPTZ  NOT NULL DEFAULT now(),
    servico       VARCHAR(20)  NOT NULL CHECK (servico IN ('api','chat','calculo','painel')),
    nivel         VARCHAR(6)   NOT NULL CHECK (nivel IN ('INFO','AVISO','ERRO')),
    evento        VARCHAR(60)  NOT NULL,
    mensagem      VARCHAR(500) NOT NULL DEFAULT '',   -- nunca dado pessoal
    id_requisicao VARCHAR(32)
);
CREATE INDEX IF NOT EXISTS ix_logs_momento ON logs_tecnicos(momento DESC);

CREATE TABLE IF NOT EXISTS servicos_status (
    servico      VARCHAR(20)  PRIMARY KEY,
    ultimo_sinal TIMESTAMPTZ  NOT NULL,
    detalhe      VARCHAR(200) NOT NULL DEFAULT ''
);

-- ---------------------------------------------------------------------------
-- 7. Fila de recalculo e gatilhos
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS fila_recalculo (
    id_aluno       VARCHAR(255) PRIMARY KEY REFERENCES alunos(id_aluno),
    motivo         VARCHAR(40)  NOT NULL,
    enfileirado_em TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- SECURITY DEFINER com search_path fixo: quem altera os indicadores nao
-- precisa de permissao na fila, e a funcao nao pode ser enganada por uma
-- tabela de mesmo nome em outro esquema.
CREATE OR REPLACE FUNCTION enfileirar_recalculo() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
    aluno VARCHAR;
BEGIN
    aluno := CASE WHEN TG_OP = 'DELETE' THEN OLD.id_aluno ELSE NEW.id_aluno END;
    INSERT INTO fila_recalculo (id_aluno, motivo) VALUES (aluno, TG_TABLE_NAME)
    ON CONFLICT (id_aluno) DO UPDATE SET motivo = EXCLUDED.motivo, enfileirado_em = now();
    PERFORM pg_notify('mufasa_recalculo', '');
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS tg_recalculo_indicadores ON indicadores_academicos;
CREATE TRIGGER tg_recalculo_indicadores
    AFTER INSERT OR UPDATE OR DELETE ON indicadores_academicos
    FOR EACH ROW EXECUTE FUNCTION enfileirar_recalculo();

DROP TRIGGER IF EXISTS tg_recalculo_socioeconomico ON socioeconomico;
CREATE TRIGGER tg_recalculo_socioeconomico
    AFTER INSERT OR UPDATE OR DELETE ON socioeconomico
    FOR EACH ROW EXECUTE FUNCTION enfileirar_recalculo();

-- Mudou um parametro do modelo: todos os alunos sao recalculados com a nova versao.
CREATE OR REPLACE FUNCTION recalcular_todos_por_parametro() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    -- Parametros de operacao (prazos, grupo minimo...) nao mudam o score.
    IF NEW.valor IS DISTINCT FROM OLD.valor
       AND NEW.chave NOT IN ('SLA_CRITICO_HORAS','SLA_ALTO_DIAS_UTEIS','SLA_DADOS_DIAS_UTEIS','MINIMO_GRUPO',
                             'INTERVALO_ATENDIMENTOS','TETO_ALERTAS_RESPONSAVEL') THEN
        INSERT INTO fila_recalculo (id_aluno, motivo)
        SELECT id_aluno, 'parametro' FROM alunos
        ON CONFLICT (id_aluno) DO UPDATE SET motivo = 'parametro', enfileirado_em = now();
        PERFORM pg_notify('mufasa_recalculo', '');
    END IF;
    RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS tg_recalculo_parametro ON parametros;
CREATE TRIGGER tg_recalculo_parametro
    AFTER UPDATE ON parametros
    FOR EACH ROW EXECUTE FUNCTION recalcular_todos_por_parametro();

-- Historico de alertas e de score: so insercao.
CREATE OR REPLACE FUNCTION bloquear_alteracao_historico() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION '% e somente de insercao', TG_TABLE_NAME;
END $$;

DROP TRIGGER IF EXISTS tg_alerta_eventos_imutavel ON alerta_eventos;
CREATE TRIGGER tg_alerta_eventos_imutavel BEFORE UPDATE OR DELETE ON alerta_eventos
    FOR EACH ROW EXECUTE FUNCTION bloquear_alteracao_historico();
DROP TRIGGER IF EXISTS tg_scores_imutavel ON scores_risco;
CREATE TRIGGER tg_scores_imutavel BEFORE UPDATE OR DELETE ON scores_risco
    FOR EACH ROW EXECUTE FUNCTION bloquear_alteracao_historico();

-- ---------------------------------------------------------------------------
-- 7b. Calendario de retorno (RN14, CA03)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS agendamentos (
    id_agendamento BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno       VARCHAR(255) NOT NULL REFERENCES alunos(id_aluno),
    inicio         TIMESTAMPTZ  NOT NULL,
    solicitado_por BIGINT       NOT NULL REFERENCES usuarios(id_usuario),
    solicitado_em  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    situacao       VARCHAR(12)  NOT NULL DEFAULT 'MARCADO' CHECK (situacao IN ('MARCADO','REALIZADO','CANCELADO')),
    -- Atendimento antes do intervalo minimo: so com motivo (RN14, excecao).
    motivo_excecao VARCHAR(300),
    id_alerta      BIGINT       REFERENCES alertas(id_alerta),
    atualizado_em  TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_agendamentos_aluno ON agendamentos(id_aluno, inicio) WHERE situacao <> 'CANCELADO';
-- Recusas por intervalo tambem ficam registradas (RN14, auditoria).
CREATE TABLE IF NOT EXISTS agendamentos_recusas (
    id_recusa      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_aluno       VARCHAR(255) NOT NULL REFERENCES alunos(id_aluno),
    pedido_para    TIMESTAMPTZ  NOT NULL,
    proxima_data   TIMESTAMPTZ  NOT NULL,
    solicitado_por BIGINT       NOT NULL REFERENCES usuarios(id_usuario),
    momento        TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- 8. Dono e permissoes
-- ---------------------------------------------------------------------------

DO $$
DECLARE
    tabela TEXT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'mufasa_calculo') THEN
        CREATE ROLE mufasa_calculo LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
    END IF;
    FOREACH tabela IN ARRAY ARRAY['scores_risco', 'alertas', 'alerta_eventos', 'notificacoes', 'parametros',
                                  'parametros_propostas', 'parametros_versoes', 'periodos_letivos', 'cargas', 'carga_linhas', 'logs_tecnicos',
                                  'servicos_status', 'fila_recalculo', 'agendamentos', 'agendamentos_recusas']
    LOOP
        EXECUTE format('ALTER TABLE %I OWNER TO mufasa_dono', tabela);
    END LOOP;
END $$;
ALTER FUNCTION enfileirar_recalculo() OWNER TO mufasa_dono;
ALTER FUNCTION recalcular_todos_por_parametro() OWNER TO mufasa_dono;
ALTER VIEW vw_score_atual OWNER TO mufasa_dono;

GRANT USAGE ON SCHEMA public TO mufasa_calculo;

-- API (mufasa_api) ---------------------------------------------------------
GRANT SELECT ON scores_risco, vw_score_atual, alertas, alerta_eventos, parametros, parametros_propostas,
               parametros_versoes, periodos_letivos,
               cargas, carga_linhas, logs_tecnicos, servicos_status, apoio_aluno TO mufasa_api;
GRANT SELECT ON regras_risco TO mufasa_api;
-- Usuarios: primeiro acesso, troca de senha e gestao pela administracao.
GRANT INSERT (login, senha_hash, perfil, id_aluno, id_professor, id_curso, nome, email, deve_trocar_senha)
      ON usuarios TO mufasa_api;
GRANT UPDATE (senha_hash, deve_trocar_senha, senha_alterada_em, termo_versao, termo_aceito_em, ativo, nome, email)
      ON usuarios TO mufasa_api;
-- Alertas: atribuir, registrar acao, encerrar. Criar alerta e papel do calculo.
GRANT UPDATE (situacao, id_responsavel, atribuido_em, primeira_acao_em, encerrado_em, causa, desfecho,
              houve_contato, canal_contato, acoes_executadas, score_no_encerramento, atualizado_em)
      ON alertas TO mufasa_api;
GRANT INSERT ON alerta_eventos TO mufasa_api;
GRANT SELECT, INSERT ON notificacoes TO mufasa_api;
GRANT UPDATE (lida_em) ON notificacoes TO mufasa_api;
GRANT UPDATE (valor, atualizado_em) ON parametros TO mufasa_api;
GRANT INSERT ON parametros_versoes TO mufasa_api;
GRANT INSERT ON parametros_propostas TO mufasa_api;
GRANT UPDATE (situacao, decidido_por, decidido_em, versao_gerada) ON parametros_propostas TO mufasa_api;
GRANT INSERT ON cargas, carga_linhas TO mufasa_api;
GRANT UPDATE (situacao, confirmado_por, confirmado_em) ON cargas TO mufasa_api;
GRANT INSERT ON logs_tecnicos TO mufasa_api;
GRANT SELECT, INSERT ON agendamentos, agendamentos_recusas TO mufasa_api;
GRANT UPDATE (situacao, atualizado_em) ON agendamentos TO mufasa_api;
-- Recalculo pedido pela administracao (/admin/calculos): so entra na fila.
GRANT SELECT, INSERT, UPDATE (motivo, enfileirado_em) ON fila_recalculo TO mufasa_api;
GRANT SELECT, INSERT, UPDATE ON servicos_status TO mufasa_api;
GRANT UPDATE (situacao, respondida_em) ON solicitacoes_titular TO mufasa_api;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO mufasa_api;

-- Calculo (mufasa_calculo) ---------------------------------------------------
-- Le so as colunas que o score usa; nada de nome, idade, bairro ou apoio.
GRANT SELECT (id_aluno, id_curso) ON alunos TO mufasa_calculo;
GRANT SELECT ON indicadores_academicos TO mufasa_calculo;
GRANT SELECT (id_aluno, renda_per_capita, trabalha, horas_trabalho_dia, tempo_deslocamento_min, auxilio_bolsa)
      ON socioeconomico TO mufasa_calculo;
GRANT SELECT, DELETE ON fila_recalculo TO mufasa_calculo;
GRANT INSERT (id_aluno, motivo) ON fila_recalculo TO mufasa_calculo;
GRANT UPDATE (motivo, enfileirado_em) ON fila_recalculo TO mufasa_calculo;
GRANT SELECT, INSERT ON scores_risco TO mufasa_calculo;
GRANT SELECT ON vw_score_atual, parametros, parametros_versoes, periodos_letivos TO mufasa_calculo;
-- Dados academicos que o score usa (B.2.1 a B.2.3, A.5, A.6).
GRANT SELECT (id_aluno, id_turma, nota_final, frequencia_pct, situacao) ON matriculas TO mufasa_calculo;
GRANT SELECT (id_turma, id_materia, periodo_letivo, turno) ON turmas TO mufasa_calculo;
GRANT SELECT (id_materia, nome, carga_horaria_h) ON materias TO mufasa_calculo;
GRANT SELECT (id_aluno, semestre_atual) ON alunos TO mufasa_calculo;
-- Idade so para o filtro de encaminhamentos de RN16; nunca entra no score.
GRANT SELECT (idade) ON alunos TO mufasa_calculo;
GRANT SELECT, INSERT ON alertas TO mufasa_calculo;
GRANT UPDATE (nivel, prazo_em, atualizado_em, situacao, encerrado_em, causa, desfecho, houve_contato,
              acoes_executadas) ON alertas TO mufasa_calculo;   -- encerra so tarefa de dados resolvida
GRANT SELECT, INSERT ON alerta_eventos TO mufasa_calculo;
GRANT INSERT ON notificacoes TO mufasa_calculo;
GRANT SELECT (id_usuario, perfil, id_curso, ativo) ON usuarios TO mufasa_calculo;
-- Aplicar cargas confirmadas.
GRANT SELECT ON cargas, carga_linhas TO mufasa_calculo;
GRANT UPDATE (situacao, aplicada_em, resultado) ON cargas TO mufasa_calculo;
GRANT INSERT, UPDATE ON indicadores_academicos TO mufasa_calculo;
GRANT SELECT (id_matricula) ON matriculas TO mufasa_calculo;   -- conferir a chave na carga
GRANT UPDATE (va1, va2, va3, nota_final, frequencia_pct, situacao) ON matriculas TO mufasa_calculo;
GRANT SELECT, INSERT, UPDATE ON servicos_status TO mufasa_calculo;
GRANT INSERT ON logs_tecnicos TO mufasa_calculo;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO mufasa_calculo;
ALTER ROLE mufasa_calculo SET statement_timeout = '30s';
ALTER ROLE mufasa_api SET statement_timeout = '10s';

COMMIT;
