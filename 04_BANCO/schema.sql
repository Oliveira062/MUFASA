-- MUFASA — esquema relacional do banco de evasão (PostgreSQL)
-- Espelha as abas de Banco_Evasao_IA_Normalizado.xlsx.

CREATE TABLE universidades (
    id_universidade  VARCHAR(10) PRIMARY KEY,
    nome             VARCHAR(120) NOT NULL,
    cidade           VARCHAR(80)  NOT NULL,
    uf               CHAR(2)      NOT NULL
);

CREATE TABLE cursos (
    id_curso              VARCHAR(10) PRIMARY KEY,
    id_universidade       VARCHAR(10) NOT NULL REFERENCES universidades(id_universidade),
    nome                  VARCHAR(120) NOT NULL,
    grau                  VARCHAR(30)  NOT NULL,
    duracao_semestres     SMALLINT     NOT NULL,
    media_aprovacao       NUMERIC(3,1) NOT NULL DEFAULT 6,
    frequencia_minima_pct SMALLINT     NOT NULL DEFAULT 75
);

CREATE TABLE professores (
    id_professor        VARCHAR(10) PRIMARY KEY,
    nome                VARCHAR(120) NOT NULL,
    titulacao           VARCHAR(30),
    area_atuacao        VARCHAR(60),
    regime_trabalho     VARCHAR(20),
    email_institucional VARCHAR(120) UNIQUE,
    data_admissao       DATE
);

CREATE TABLE materias (
    id_materia            VARCHAR(10) PRIMARY KEY,
    id_curso              VARCHAR(10) NOT NULL REFERENCES cursos(id_curso),
    nome                  VARCHAR(120) NOT NULL,
    semestre_grade        SMALLINT     NOT NULL CHECK (semestre_grade BETWEEN 1 AND 12),
    carga_horaria_h       SMALLINT     NOT NULL,
    media_aprovacao       NUMERIC(3,1) NOT NULL DEFAULT 6,
    frequencia_minima_pct SMALLINT     NOT NULL DEFAULT 75
);

CREATE TABLE turmas (
    id_turma       VARCHAR(16) PRIMARY KEY,
    id_materia     VARCHAR(10) NOT NULL REFERENCES materias(id_materia),
    id_professor   VARCHAR(10) NOT NULL REFERENCES professores(id_professor),
    periodo_letivo VARCHAR(7)  NOT NULL,          -- ex.: 2026/2
    turma          CHAR(1)     NOT NULL,
    turno          VARCHAR(12) NOT NULL,
    UNIQUE (id_materia, periodo_letivo, turma)
);

CREATE TABLE alunos (
    id_aluno                      VARCHAR(10) PRIMARY KEY,
    nome_ficticio                 VARCHAR(120) NOT NULL,
    id_curso                      VARCHAR(10)  NOT NULL REFERENCES cursos(id_curso),
    semestre_atual                SMALLINT     NOT NULL,
    idade                         SMALLINT,
    bairro                        VARCHAR(80),
    tipo_ensino_medio             VARCHAR(30),
    apoio_psicossocial_solicitado BOOLEAN NOT NULL DEFAULT FALSE,  -- dado sensível
    necessidade_acessibilidade    BOOLEAN NOT NULL DEFAULT FALSE   -- dado sensível
);

-- Dados sensíveis (LGPD): tabela separada para restringir acesso por perfil.
CREATE TABLE socioeconomico (
    id_aluno                              VARCHAR(10) PRIMARY KEY REFERENCES alunos(id_aluno) ON DELETE CASCADE,
    renda_familiar_mensal                 NUMERIC(10,2),
    moradores_domicilio                   SMALLINT,
    renda_per_capita                      NUMERIC(10,2),
    auxilio_bolsa                         VARCHAR(30),
    trabalha                              VARCHAR(20),
    horas_trabalho_dia                    SMALLINT,
    horas_estudo_semana                   NUMERIC(4,1),
    responsabilidades_familiares_h_semana SMALLINT,
    distancia_km                          NUMERIC(5,1),
    tempo_deslocamento_min                SMALLINT,
    meio_transporte                       VARCHAR(20)
);

CREATE TABLE indicadores_academicos (
    id_aluno                         VARCHAR(10) NOT NULL REFERENCES alunos(id_aluno) ON DELETE CASCADE,
    periodo_letivo                   VARCHAR(7)  NOT NULL,
    faltas_total                     SMALLINT,
    frequencia_pct                   SMALLINT,
    disciplinas_reprovadas_historico SMALLINT,
    atividades_pendentes             SMALLINT,
    media_semestre_anterior          NUMERIC(3,1),
    media_atual                      NUMERIC(3,1),
    tendencia_media                  NUMERIC(3,1),
    PRIMARY KEY (id_aluno, periodo_letivo)
);

CREATE TABLE avaliacoes_risco (
    id_avaliacao     VARCHAR(10) PRIMARY KEY,
    id_aluno         VARCHAR(10) NOT NULL REFERENCES alunos(id_aluno) ON DELETE CASCADE,
    periodo_letivo   VARCHAR(7)  NOT NULL,
    tipo             VARCHAR(20) NOT NULL,         -- Inicial, Recalculada...
    data_avaliacao   DATE        NOT NULL,
    risco_evasao_pct NUMERIC(4,1) NOT NULL,
    nivel_risco      VARCHAR(10)  NOT NULL CHECK (nivel_risco IN ('Baixo','Moderado','Alto','Crítico'))
);

CREATE TABLE matriculas (
    id_matricula   VARCHAR(10) PRIMARY KEY,
    id_aluno       VARCHAR(10) NOT NULL REFERENCES alunos(id_aluno) ON DELETE CASCADE,
    id_turma       VARCHAR(16) NOT NULL REFERENCES turmas(id_turma),
    nota_final     NUMERIC(3,1) CHECK (nota_final BETWEEN 0 AND 10),
    frequencia_pct SMALLINT     CHECK (frequencia_pct BETWEEN 0 AND 100),
    situacao       VARCHAR(40),
    UNIQUE (id_aluno, id_turma)
);

CREATE TABLE regras_risco (
    id_regra       VARCHAR(10) PRIMARY KEY,
    regra          VARCHAR(40) NOT NULL UNIQUE,
    condicao       VARCHAR(120) NOT NULL,
    pontuacao      SMALLINT,                       -- NULL na linha "faixas"
    interpretacao  VARCHAR(160)
);

CREATE INDEX ix_matriculas_turma   ON matriculas(id_turma);
CREATE INDEX ix_turmas_professor   ON turmas(id_professor);
CREATE INDEX ix_avaliacoes_aluno   ON avaliacoes_risco(id_aluno);
