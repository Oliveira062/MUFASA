--
-- PostgreSQL database dump
--

\restrict ZQ4gFzwVffDWmS8gylf1GFMpyqbPefQVkBsYJIEpmeavYsOpNohTvwzLS5gRDnU

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

-- Started on 2026-10-26 23:17:04

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16684)
-- Name: alunos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alunos (
    id_aluno character varying(255),
    nome_ficticio character varying(255),
    id_curso character varying(255),
    semestre_atual integer,
    idade integer,
    bairro character varying(255),
    tipo_ensino_medio character varying(255),
    apoio_psicossocial_solicitado character varying(255),
    necessidade_acessibilidade character varying(255)
);


ALTER TABLE public.alunos OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16699)
-- Name: avaliacoes_risco; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.avaliacoes_risco (
    id_avaliacao character varying(255),
    id_aluno character varying(255),
    periodo_letivo character varying(255),
    tipo character varying(255),
    data_avaliacao character varying(255),
    risco_evasao_pct numeric,
    nivel_risco character varying(255)
);


ALTER TABLE public.avaliacoes_risco OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16664)
-- Name: cursos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cursos (
    id_curso character varying(255),
    id_universidade character varying(255),
    nome character varying(255),
    grau character varying(255),
    duracao_semestres integer,
    media_aprovacao integer,
    frequencia_minima_pct integer
);


ALTER TABLE public.cursos OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16694)
-- Name: indicadores_academicos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.indicadores_academicos (
    id_aluno character varying(255),
    periodo_letivo character varying(255),
    faltas_total integer,
    frequencia_pct integer,
    disciplinas_reprovadas_historico integer,
    atividades_pendentes integer,
    media_semestre_anterior numeric,
    media_atual numeric,
    tendencia_media numeric
);


ALTER TABLE public.indicadores_academicos OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16674)
-- Name: materias; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.materias (
    id_materia character varying(255),
    id_curso character varying(255),
    nome character varying(255),
    semestre_grade integer,
    carga_horaria_h integer,
    media_aprovacao integer,
    frequencia_minima_pct integer
);


ALTER TABLE public.materias OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16704)
-- Name: matriculas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.matriculas (
    id_matricula character varying(255),
    id_aluno character varying(255),
    id_turma character varying(255),
    nota_final numeric,
    frequencia_pct integer,
    situacao character varying(255),
    va1 numeric,
    va2 numeric,
    va3 numeric
);


ALTER TABLE public.matriculas OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16669)
-- Name: professores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.professores (
    id_professor character varying(255),
    nome character varying(255),
    titulacao character varying(255),
    area_atuacao character varying(255),
    regime_trabalho character varying(255),
    email_institucional character varying(255),
    data_admissao character varying(255)
);


ALTER TABLE public.professores OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16709)
-- Name: regras_risco; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regras_risco (
    id_regra character varying(255),
    regra character varying(255),
    condicao character varying(255),
    pontuacao character varying(255),
    interpretacao character varying(255)
);


ALTER TABLE public.regras_risco OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16689)
-- Name: socioeconomico; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.socioeconomico (
    id_aluno character varying(255),
    renda_familiar_mensal integer,
    moradores_domicilio integer,
    renda_per_capita numeric,
    auxilio_bolsa character varying(255),
    trabalha character varying(255),
    horas_trabalho_dia integer,
    horas_estudo_semana numeric,
    responsabilidades_familiares_h_semana integer,
    distancia_km numeric,
    tempo_deslocamento_min integer,
    meio_transporte character varying(255),
    prouni character varying(255),
    fies character varying(255),
    desconto_funcionario character varying(255)
);


ALTER TABLE public.socioeconomico OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16679)
-- Name: turmas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.turmas (
    id_turma character varying(255),
    id_materia character varying(255),
    id_professor character varying(255),
    periodo_letivo character varying(255),
    turma character varying(255),
    turno character varying(255)
);


ALTER TABLE public.turmas OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16659)
-- Name: universidades; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.universidades (
    id_universidade character varying(255),
    nome character varying(255),
    cidade character varying(255),
    uf character varying(255)
);


ALTER TABLE public.universidades OWNER TO postgres;

--
-- TOC entry 4922 (class 0 OID 16684)
-- Dependencies: 220
-- Data for Name: alunos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alunos (id_aluno, nome_ficticio, id_curso, semestre_atual, idade, bairro, tipo_ensino_medio, apoio_psicossocial_solicitado, necessidade_acessibilidade) FROM stdin;
ALU0001	Julia Araújo Silva	CUR01	2	23	Recanto do Sol	Regular presencial	Não	Não
ALU0002	Camila Mendes Carvalho	CUR01	1	21	Anápolis City	Regular presencial	Sim	Sim
ALU0003	Isabela Araújo Ribeiro	CUR01	3	17	Maracanã	Regular presencial	Não	Não
ALU0004	Beatriz Ribeiro Santos	CUR01	7	31	Jardim Alexandrina	Regular presencial	Não	Não
ALU0005	Isabela Gomes Gomes	CUR01	4	29	Paraíso	Regular presencial	Não	Não
ALU0006	Gabriel Ribeiro Teixeira	CUR01	1	23	Setor Industrial	Regular presencial	Não	Não
ALU0007	João Araújo Silva	CUR01	5	26	Setor Industrial	EJA	Não	Não
ALU0008	Letícia Rocha Silva	CUR01	2	18	Jardim Alexandrina	Regular presencial	Não	Não
ALU0009	João Pereira Costa	CUR01	2	26	Boa Vista	Regular presencial	Não	Não
ALU0010	Ana Gomes Ferreira	CUR01	7	17	Boa Vista	Regular presencial	Não	Não
ALU0011	Victor Almeida Gomes	CUR01	1	19	Setor Central	Regular presencial	Não	Não
ALU0012	Amanda Lima Souza	CUR01	5	21	Anápolis City	Regular presencial	Não	Não
ALU0013	Eduardo Santos Mendes	CUR01	7	26	Setor Central	Regular presencial	Não	Não
ALU0014	Lucas Lima Santos	CUR01	3	27	Jibran El Hadj	Regular híbrido	Não	Não
ALU0015	Gabriel Silva Pereira	CUR01	2	20	Anápolis City	Regular presencial	Não	Não
ALU0016	Maria Rocha Silva	CUR01	2	20	Jardim Alexandrina	Regular presencial	Não	Não
ALU0017	Matheus Carvalho Rodrigues	CUR01	5	26	São Carlos	Regular presencial	Sim	Não
ALU0018	Rafael Lima Teixeira	CUR01	6	28	Setor Industrial	EJA	Não	Não
ALU0019	Felipe Lima Almeida	CUR01	1	20	São Carlos	EJA	Não	Não
ALU0020	Thiago Carvalho Silva	CUR01	7	26	Setor Central	Regular presencial	Não	Não
ALU0021	Luana Ferreira Lima	CUR01	1	20	Anápolis City	Regular presencial	Não	Não
ALU0022	Amanda Mendes Carvalho	CUR01	4	26	Setor Central	Regular presencial	Não	Não
ALU0023	Rafael Almeida Souza	CUR01	6	31	Setor Industrial	Regular presencial	Não	Não
ALU0024	Renato Rocha Nunes	CUR01	2	20	Maracanã	Regular presencial	Não	Não
ALU0025	Carlos Santos Ferreira	CUR01	7	27	Jardim Alexandrina	Regular presencial	Não	Não
ALU0026	Rafael Silva Rodrigues	CUR01	4	25	Jardim Alexandrina	Regular presencial	Não	Sim
ALU0027	Eduardo Barbosa Almeida	CUR01	2	17	Anápolis City	Regular presencial	Não	Não
ALU0028	Mariana Mendes Carvalho	CUR01	3	24	Recanto do Sol	Regular presencial	Não	Não
ALU0029	Felipe Pereira Ribeiro	CUR01	8	17	Vila Jaiara	Regular presencial	Não	Não
ALU0030	Pedro Martins Souza	CUR01	7	23	Vivian Parque	Regular híbrido	Não	Não
ALU0031	Lucas Araújo Ribeiro	CUR01	6	19	Boa Vista	Regular presencial	Não	Não
ALU0032	Matheus Ribeiro Santos	CUR01	1	17	São Carlos	Regular presencial	Não	Não
ALU0033	Letícia Costa Lima	CUR01	2	20	São Carlos	Regular presencial	Não	Não
ALU0034	Julia Oliveira Rocha	CUR01	4	21	Boa Vista	Regular presencial	Não	Sim
ALU0035	Renato Teixeira Nunes	CUR01	5	26	Maracanã	Regular presencial	Não	Não
ALU0036	Lucas Gomes Mendes	CUR01	2	17	Jundiaí	Regular presencial	Não	Não
ALU0037	Gustavo Teixeira Gomes	CUR01	3	24	Paraíso	Regular presencial	Não	Não
ALU0038	Mariana Ferreira Martins	CUR01	7	27	Setor Industrial	Regular presencial	Não	Não
ALU0039	Isabela Gomes Pereira	CUR01	2	24	Setor Central	Regular híbrido	Sim	Não
ALU0040	Felipe Martins Mendes	CUR01	3	17	Vila Jaiara	Regular presencial	Não	Não
ALU0041	Thiago Gomes Lima	CUR01	3	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0042	Amanda Souza Oliveira	CUR01	5	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0043	Lucas Martins Souza	CUR01	3	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0044	Ana Carvalho Barbosa	CUR01	3	23	Setor Industrial	Regular híbrido	Não	Não
ALU0045	Letícia Barbosa Santos	CUR01	1	17	Vivian Parque	Regular presencial	Não	Não
ALU0046	Amanda Teixeira Almeida	CUR01	5	22	Paraíso	Regular presencial	Não	Não
ALU0047	Larissa Silva Carvalho	CUR01	4	17	Filostro Machado	Regular presencial	Sim	Não
ALU0048	Letícia Costa Rodrigues	CUR01	8	21	Vila Jaiara	Regular presencial	Não	Não
ALU0049	Maria Ribeiro Santos	CUR01	5	32	Jundiaí	Regular presencial	Sim	Não
ALU0050	Lucas Barbosa Almeida	CUR01	3	19	Filostro Machado	Regular presencial	Não	Não
ALU0051	Amanda Pereira Silva	CUR01	1	25	São Carlos	Regular presencial	Não	Não
ALU0052	Rafael Teixeira Oliveira	CUR01	7	29	Jundiaí	Regular presencial	Não	Não
ALU0053	Carlos Mendes Costa	CUR01	8	31	Boa Vista	Regular híbrido	Não	Não
ALU0054	Isabela Barbosa Souza	CUR01	4	17	Vila Jaiara	Regular presencial	Não	Não
ALU0055	Ana Nunes Santos	CUR01	2	20	São Carlos	Regular presencial	Não	Não
ALU0056	Isabela Rocha Rocha	CUR01	1	20	Vila Jaiara	Regular presencial	Não	Não
ALU0057	Felipe Rodrigues Nunes	CUR01	3	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0058	Gabriel Carvalho Almeida	CUR01	1	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0059	Matheus Carvalho Ribeiro	CUR01	4	25	Recanto do Sol	Regular presencial	Não	Não
ALU0060	Maria Costa Teixeira	CUR01	1	23	Boa Vista	EJA	Não	Sim
ALU0061	Mariana Silva Pereira	CUR01	8	19	Setor Central	EJA	Não	Não
ALU0062	Matheus Pereira Rocha	CUR01	2	24	Maracanã	Regular híbrido	Não	Não
ALU0063	Lucas Rocha Ribeiro	CUR01	8	26	Residencial das Rosas	Regular presencial	Não	Não
ALU0064	Renato Barbosa Silva	CUR01	5	18	Maracanã	Regular presencial	Não	Não
ALU0065	Eduardo Almeida Rocha	CUR01	7	21	Vivian Parque	Regular híbrido	Não	Não
ALU0066	Renato Lima Pereira	CUR01	3	22	Residencial das Rosas	Regular presencial	Não	Não
ALU0067	Rafael Mendes Souza	CUR01	6	19	Jibran El Hadj	Regular presencial	Não	Não
ALU0068	Lucas Almeida Araújo	CUR01	1	19	São Carlos	Regular presencial	Não	Não
ALU0069	Rafael Oliveira Silva	CUR01	1	21	Maracanã	EJA	Não	Não
ALU0070	Carlos Carvalho Silva	CUR01	1	17	Recanto do Sol	Regular presencial	Não	Não
ALU0071	Matheus Souza Gomes	CUR01	4	17	Boa Vista	Regular presencial	Não	Não
ALU0072	Eduardo Mendes Costa	CUR01	4	23	Jundiaí	Regular presencial	Não	Não
ALU0073	Beatriz Costa Souza	CUR01	6	25	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0074	Carlos Pereira Almeida	CUR01	3	22	Anápolis City	Regular híbrido	Não	Sim
ALU0075	Victor Carvalho Almeida	CUR01	5	23	Jibran El Hadj	Regular presencial	Sim	Não
ALU0076	Renato Souza Almeida	CUR01	8	27	Maracanã	Regular presencial	Não	Não
ALU0077	Bruno Almeida Oliveira	CUR01	4	18	Anápolis City	Regular presencial	Não	Não
ALU0078	Victor Barbosa Mendes	CUR01	1	23	Vila Jaiara	Regular híbrido	Não	Não
ALU0079	Lucas Santos Souza	CUR01	4	27	Jibran El Hadj	Regular presencial	Não	Não
ALU0080	Rafael Mendes Ribeiro	CUR01	2	17	Setor Central	Regular presencial	Não	Não
ALU0081	Renato Mendes Oliveira	CUR01	4	22	São Carlos	EJA	Não	Sim
ALU0082	Isabela Carvalho Araújo	CUR01	1	27	Setor Industrial	Regular presencial	Não	Não
ALU0083	Gabriel Carvalho Rodrigues	CUR01	1	24	Maracanã	Regular presencial	Sim	Não
ALU0084	Bruno Almeida Carvalho	CUR01	2	25	Residencial das Rosas	Regular presencial	Não	Sim
ALU0085	Ana Costa Barbosa	CUR01	3	25	Filostro Machado	EJA	Não	Não
ALU0086	Larissa Rodrigues Gomes	CUR01	8	27	Filostro Machado	Regular presencial	Não	Não
ALU0087	Gabriel Rodrigues Rodrigues	CUR01	8	24	Jardim Alexandrina	Regular presencial	Não	Não
ALU0088	Victor Silva Martins	CUR01	8	28	Setor Central	Regular presencial	Não	Não
ALU0089	Beatriz Souza Carvalho	CUR01	2	25	Anápolis City	Regular presencial	Não	Não
ALU0090	João Santos Souza	CUR01	1	23	Boa Vista	Regular híbrido	Não	Não
ALU0091	Bruno Pereira Ferreira	CUR01	6	17	Paraíso	Regular presencial	Não	Não
ALU0092	Thiago Nunes Ribeiro	CUR01	1	18	Maracanã	Regular presencial	Não	Não
ALU0093	Rafael Almeida Ribeiro	CUR01	4	18	Jardim Alexandrina	Regular presencial	Não	Não
ALU0094	Rafael Barbosa Martins	CUR01	6	17	Boa Vista	Regular presencial	Não	Não
ALU0095	Letícia Ferreira Rocha	CUR01	3	29	Boa Vista	Regular presencial	Não	Não
ALU0096	Rafael Santos Gomes	CUR01	1	18	Vivian Parque	Regular presencial	Não	Não
ALU0097	Camila Lima Souza	CUR01	6	28	São Carlos	Regular presencial	Não	Não
ALU0098	Julia Silva Santos	CUR01	2	17	Maracanã	Regular presencial	Sim	Não
ALU0099	Matheus Mendes Araújo	CUR01	4	23	Vivian Parque	EJA	Não	Não
ALU0100	Maria Costa Araújo	CUR01	4	19	Jundiaí	Regular presencial	Não	Não
ALU0101	Lucas Silva Araújo	CUR01	2	23	Recanto do Sol	Regular presencial	Não	Não
ALU0102	Larissa Silva Oliveira	CUR01	5	21	Filostro Machado	EJA	Não	Não
ALU0103	Camila Carvalho Silva	CUR01	8	24	Paraíso	Regular presencial	Não	Não
ALU0104	Victor Mendes Gomes	CUR01	7	24	Jibran El Hadj	Regular presencial	Não	Não
ALU0105	Renato Ferreira Carvalho	CUR01	8	17	Jundiaí	Regular presencial	Não	Não
ALU0106	Victor Mendes Pereira	CUR01	5	24	Setor Industrial	Regular presencial	Não	Não
ALU0107	Eduardo Araújo Nunes	CUR01	3	26	Filostro Machado	EJA	Não	Não
ALU0108	Larissa Oliveira Martins	CUR01	4	20	Anápolis City	Regular presencial	Não	Não
ALU0109	Pedro Rodrigues Silva	CUR01	2	17	Maracanã	Regular presencial	Não	Não
ALU0110	Rafael Costa Ribeiro	CUR01	2	21	Setor Industrial	Regular presencial	Não	Não
ALU0111	Lucas Ribeiro Barbosa	CUR01	8	26	Setor Central	Regular presencial	Não	Sim
ALU0112	Eduardo Costa Santos	CUR01	4	19	Anápolis City	EJA	Sim	Não
ALU0113	Rafael Costa Souza	CUR01	7	24	Filostro Machado	Regular presencial	Não	Não
ALU0114	Victor Carvalho Santos	CUR01	8	22	Recanto do Sol	Regular presencial	Não	Não
ALU0115	Camila Carvalho Oliveira	CUR01	3	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0116	Lucas Nunes Silva	CUR01	7	17	Vivian Parque	Regular presencial	Sim	Não
ALU0117	Ana Martins Lima	CUR01	5	18	Anápolis City	Regular híbrido	Não	Não
ALU0118	Letícia Silva Pereira	CUR01	8	21	Boa Vista	EJA	Não	Não
ALU0119	Larissa Ribeiro Nunes	CUR01	4	20	Paraíso	EJA	Sim	Não
ALU0120	Thiago Ferreira Rodrigues	CUR01	8	27	Maracanã	Regular presencial	Não	Não
ALU0121	Letícia Ferreira Martins	CUR01	5	25	Jundiaí	Regular presencial	Sim	Não
ALU0122	Renato Carvalho Santos	CUR01	5	20	Vila Jaiara	Regular presencial	Sim	Não
ALU0123	Matheus Ribeiro Nunes	CUR01	1	22	Setor Industrial	Regular presencial	Sim	Não
ALU0124	Ana Teixeira Ferreira	CUR01	8	31	Jibran El Hadj	Regular híbrido	Não	Não
ALU0125	Victor Lima Araújo	CUR01	3	17	Anápolis City	Regular híbrido	Não	Não
ALU0126	Luana Silva Nunes	CUR01	7	28	Setor Industrial	Regular presencial	Não	Não
ALU0127	João Mendes Ferreira	CUR01	8	29	Jibran El Hadj	Regular presencial	Sim	Não
ALU0128	Julia Teixeira Nunes	CUR01	3	17	Setor Central	Regular presencial	Não	Não
ALU0129	Lucas Rocha Martins	CUR01	6	19	Vila Jaiara	Regular presencial	Não	Não
ALU0130	Gustavo Costa Gomes	CUR01	7	25	Paraíso	Regular presencial	Não	Sim
ALU0131	Felipe Oliveira Rocha	CUR01	8	27	São Carlos	Regular presencial	Não	Não
ALU0132	Luana Santos Mendes	CUR01	6	18	Residencial das Rosas	Regular híbrido	Sim	Não
ALU0133	Pedro Pereira Silva	CUR01	7	27	Setor Industrial	Regular presencial	Não	Não
ALU0134	Mariana Oliveira Costa	CUR01	5	22	Filostro Machado	Regular presencial	Não	Não
ALU0135	Carlos Ribeiro Martins	CUR01	3	24	Boa Vista	EJA	Não	Não
ALU0136	Luana Ribeiro Ribeiro	CUR01	3	24	Vivian Parque	Regular presencial	Sim	Não
ALU0137	Rafael Martins Teixeira	CUR01	2	17	Setor Central	Regular híbrido	Não	Não
ALU0138	Thiago Santos Gomes	CUR01	2	21	Vivian Parque	Regular presencial	Não	Não
ALU0139	João Araújo Ribeiro	CUR01	5	23	Setor Central	Regular presencial	Não	Não
ALU0140	Eduardo Ribeiro Souza	CUR01	2	29	Boa Vista	Regular presencial	Sim	Não
ALU0141	Victor Ferreira Araújo	CUR01	8	20	Vivian Parque	Regular presencial	Não	Não
ALU0142	Ana Carvalho Ribeiro	CUR01	6	17	Setor Central	Regular presencial	Não	Não
ALU0143	Isabela Martins Martins	CUR01	2	24	Setor Central	Regular presencial	Não	Não
ALU0144	Beatriz Silva Araújo	CUR01	6	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0145	Gabriel Ribeiro Rocha	CUR01	7	25	Boa Vista	Regular presencial	Não	Não
ALU0146	Isabela Nunes Souza	CUR01	2	21	Maracanã	Regular híbrido	Não	Não
ALU0147	Carlos Nunes Araújo	CUR01	2	32	Jundiaí	Regular presencial	Não	Não
ALU0148	Felipe Lima Rodrigues	CUR01	2	24	Setor Industrial	Regular presencial	Não	Não
ALU0149	Amanda Almeida Ferreira	CUR01	4	23	Vivian Parque	Regular presencial	Sim	Não
ALU0150	Gabriel Souza Almeida	CUR01	6	20	Vila Jaiara	Regular presencial	Não	Não
ALU0151	Carlos Costa Nunes	CUR01	7	22	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0152	Mariana Nunes Teixeira	CUR01	4	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0153	Isabela Mendes Araújo	CUR01	2	24	Filostro Machado	Regular presencial	Não	Não
ALU0154	Carlos Lima Souza	CUR01	6	17	São Carlos	Regular presencial	Sim	Não
ALU0155	Pedro Lima Santos	CUR01	1	21	Boa Vista	Regular presencial	Não	Não
ALU0156	Bruno Carvalho Ferreira	CUR01	6	27	Maracanã	Regular presencial	Sim	Não
ALU0157	Felipe Martins Ferreira	CUR01	2	19	Vivian Parque	Regular presencial	Não	Não
ALU0158	Beatriz Teixeira Gomes	CUR01	1	21	Paraíso	EJA	Sim	Não
ALU0159	Carlos Costa Teixeira	CUR01	3	17	Paraíso	Regular presencial	Não	Não
ALU0160	Beatriz Ribeiro Gomes	CUR01	5	18	Maracanã	EJA	Não	Não
ALU0161	Mariana Araújo Mendes	CUR01	2	19	Setor Central	EJA	Sim	Não
ALU0162	Rafael Costa Lima	CUR01	4	28	São Carlos	Regular híbrido	Não	Não
ALU0163	Bruno Barbosa Pereira	CUR01	6	22	Maracanã	Regular presencial	Sim	Sim
ALU0164	Carlos Ribeiro Gomes	CUR01	5	20	Boa Vista	EJA	Não	Não
ALU0165	Eduardo Carvalho Rocha	CUR01	5	21	Filostro Machado	Regular presencial	Não	Não
ALU0166	João Rodrigues Gomes	CUR01	1	25	Paraíso	Regular presencial	Não	Não
ALU0167	Julia Lima Nunes	CUR01	7	25	Vila Jaiara	Regular híbrido	Sim	Não
ALU0168	Felipe Souza Ferreira	CUR01	4	23	Paraíso	Regular presencial	Não	Não
ALU0169	João Martins Oliveira	CUR01	2	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0170	Pedro Oliveira Rodrigues	CUR01	4	22	Setor Industrial	Regular presencial	Não	Não
ALU0171	Amanda Lima Pereira	CUR01	1	28	Anápolis City	Regular presencial	Não	Não
ALU0172	Gustavo Santos Costa	CUR01	5	25	Setor Industrial	EJA	Sim	Sim
ALU0173	Camila Araújo Pereira	CUR01	3	24	Jundiaí	Regular presencial	Não	Não
ALU0174	Pedro Martins Rocha	CUR01	7	17	São Carlos	EJA	Não	Não
ALU0175	Gustavo Ferreira Araújo	CUR01	3	18	Jardim Alexandrina	Regular presencial	Não	Não
ALU0176	Julia Silva Santos	CUR01	2	19	Jundiaí	Regular presencial	Não	Não
ALU0177	Thiago Carvalho Araújo	CUR01	7	20	Residencial das Rosas	Regular presencial	Não	Não
ALU0178	Bruno Souza Oliveira	CUR01	6	17	Vivian Parque	Regular presencial	Não	Não
ALU0179	Pedro Costa Pereira	CUR01	1	24	Vivian Parque	Regular híbrido	Sim	Não
ALU0180	Eduardo Santos Carvalho	CUR01	5	22	Paraíso	Regular presencial	Não	Sim
ALU0181	João Oliveira Santos	CUR01	7	17	Jibran El Hadj	Regular presencial	Sim	Não
ALU0182	Luana Martins Araújo	CUR01	8	24	Maracanã	Regular presencial	Não	Não
ALU0183	Felipe Pereira Pereira	CUR01	8	30	Vivian Parque	Regular híbrido	Não	Não
ALU0184	Renato Nunes Mendes	CUR01	3	19	Setor Industrial	Regular presencial	Não	Não
ALU0185	Victor Ferreira Rocha	CUR01	3	19	Jardim Alexandrina	Regular presencial	Não	Não
ALU0186	Luana Barbosa Ferreira	CUR01	2	17	Vila Jaiara	Regular presencial	Não	Não
ALU0187	Isabela Rodrigues Costa	CUR01	1	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0188	Beatriz Ribeiro Carvalho	CUR01	8	21	Setor Central	Regular presencial	Não	Não
ALU0189	Maria Rodrigues Mendes	CUR01	8	28	Anápolis City	Regular presencial	Sim	Não
ALU0190	Victor Teixeira Almeida	CUR01	4	17	Jundiaí	Regular presencial	Não	Não
ALU0191	Pedro Teixeira Carvalho	CUR01	6	22	Boa Vista	Regular presencial	Não	Não
ALU0192	Amanda Nunes Almeida	CUR01	4	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0193	Eduardo Souza Souza	CUR01	5	30	Recanto do Sol	EJA	Não	Não
ALU0194	Gabriel Oliveira Teixeira	CUR01	5	35	Jardim Alexandrina	Regular híbrido	Sim	Não
ALU0195	Bruno Gomes Pereira	CUR01	3	29	Paraíso	Regular presencial	Não	Sim
ALU0196	Maria Carvalho Teixeira	CUR01	1	22	Jardim Alexandrina	Regular presencial	Não	Não
ALU0197	Matheus Barbosa Nunes	CUR01	4	23	Vila Jaiara	Regular presencial	Não	Não
ALU0198	João Souza Teixeira	CUR01	4	27	Vivian Parque	Regular presencial	Não	Não
ALU0199	Carlos Costa Araújo	CUR01	3	22	São Carlos	Regular presencial	Sim	Sim
ALU0200	Luana Ferreira Carvalho	CUR01	6	18	Recanto do Sol	Regular híbrido	Não	Sim
ALU0201	Rafael Pereira Ferreira	CUR01	4	24	Residencial das Rosas	Regular híbrido	Não	Não
ALU0202	João Santos Teixeira	CUR01	6	17	Anápolis City	Regular presencial	Não	Não
ALU0203	Ana Gomes Rocha	CUR01	1	23	Jundiaí	Regular presencial	Não	Não
ALU0204	Larissa Teixeira Rocha	CUR01	8	30	Maracanã	Regular presencial	Sim	Não
ALU0205	Beatriz Teixeira Rocha	CUR01	6	29	Residencial das Rosas	Regular presencial	Não	Não
ALU0206	Thiago Carvalho Carvalho	CUR01	5	20	Paraíso	Regular presencial	Sim	Não
ALU0207	Beatriz Lima Almeida	CUR01	3	18	Vivian Parque	Regular híbrido	Não	Não
ALU0208	Victor Almeida Gomes	CUR01	1	22	Maracanã	Regular presencial	Não	Não
ALU0209	Rafael Martins Mendes	CUR01	3	26	Anápolis City	Regular presencial	Não	Não
ALU0210	Letícia Nunes Teixeira	CUR01	2	27	Boa Vista	Regular presencial	Não	Não
ALU0211	Lucas Rodrigues Rocha	CUR01	2	30	Boa Vista	Regular híbrido	Não	Não
ALU0212	João Nunes Rodrigues	CUR01	4	23	Filostro Machado	Regular presencial	Não	Não
ALU0213	Thiago Carvalho Teixeira	CUR01	2	17	Maracanã	Regular híbrido	Não	Não
ALU0214	Julia Martins Ribeiro	CUR01	5	27	Anápolis City	Regular presencial	Não	Não
ALU0215	Pedro Ferreira Araújo	CUR01	6	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0216	Gabriel Gomes Nunes	CUR01	2	27	Maracanã	Regular presencial	Sim	Sim
ALU0217	Gabriel Silva Rocha	CUR01	5	18	Setor Industrial	Regular presencial	Não	Não
ALU0218	Felipe Almeida Oliveira	CUR01	4	21	Vivian Parque	Regular presencial	Não	Não
ALU0219	Pedro Almeida Mendes	CUR01	1	26	Setor Central	Regular presencial	Não	Não
ALU0220	Gustavo Carvalho Gomes	CUR01	6	19	São Carlos	EJA	Não	Não
ALU0221	Gustavo Barbosa Araújo	CUR01	8	19	Boa Vista	EJA	Não	Não
ALU0222	Eduardo Gomes Mendes	CUR01	7	23	Setor Industrial	Regular presencial	Não	Não
ALU0223	Mariana Mendes Carvalho	CUR01	4	26	Residencial das Rosas	Regular presencial	Não	Não
ALU0224	João Nunes Ribeiro	CUR01	7	23	Jundiaí	Regular híbrido	Não	Não
ALU0225	Thiago Lima Araújo	CUR01	3	21	Jundiaí	Regular presencial	Não	Não
ALU0226	Eduardo Souza Gomes	CUR01	3	27	Filostro Machado	Regular presencial	Não	Não
ALU0227	Eduardo Teixeira Carvalho	CUR01	5	17	Anápolis City	EJA	Sim	Não
ALU0228	Camila Carvalho Almeida	CUR01	4	19	Vivian Parque	Regular presencial	Não	Não
ALU0229	Bruno Oliveira Carvalho	CUR01	2	20	Vivian Parque	Regular presencial	Não	Sim
ALU0230	Larissa Santos Oliveira	CUR01	8	26	Setor Central	EJA	Não	Sim
ALU0231	Larissa Rodrigues Silva	CUR01	5	27	Setor Industrial	Regular presencial	Não	Não
ALU0232	Renato Costa Oliveira	CUR01	4	22	Anápolis City	Regular híbrido	Não	Não
ALU0233	Bruno Lima Martins	CUR01	4	17	Filostro Machado	Regular presencial	Não	Não
ALU0234	Amanda Souza Nunes	CUR01	2	26	Setor Industrial	Regular presencial	Não	Não
ALU0235	Lucas Silva Carvalho	CUR01	6	28	Anápolis City	Regular presencial	Não	Não
ALU0236	Amanda Barbosa Carvalho	CUR01	6	21	São Carlos	Regular presencial	Não	Não
ALU0237	Victor Martins Oliveira	CUR01	3	25	Jundiaí	Regular presencial	Sim	Não
ALU0238	Letícia Pereira Souza	CUR01	8	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0239	Camila Carvalho Lima	CUR01	1	27	Vila Jaiara	Regular presencial	Não	Não
ALU0240	Ana Costa Silva	CUR01	2	28	Vila Jaiara	EJA	Não	Não
ALU0241	Eduardo Souza Almeida	CUR01	2	17	São Carlos	Regular presencial	Não	Não
ALU0242	Luana Araújo Araújo	CUR01	4	17	Anápolis City	Regular presencial	Não	Não
ALU0243	Camila Oliveira Rocha	CUR01	3	21	Residencial das Rosas	Regular híbrido	Não	Não
ALU0244	Larissa Ferreira Barbosa	CUR01	3	28	São Carlos	Regular presencial	Não	Não
ALU0245	Thiago Nunes Teixeira	CUR01	4	17	Residencial das Rosas	Regular presencial	Sim	Não
ALU0246	Camila Carvalho Gomes	CUR01	8	22	Jardim Alexandrina	Regular híbrido	Não	Não
ALU0247	Bruno Martins Silva	CUR01	2	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0248	Julia Mendes Santos	CUR01	4	20	Anápolis City	Regular presencial	Não	Não
ALU0249	Bruno Rodrigues Almeida	CUR01	2	27	São Carlos	Regular presencial	Não	Não
ALU0250	Matheus Araújo Lima	CUR01	3	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0251	Mariana Martins Gomes	CUR01	5	17	Recanto do Sol	Regular presencial	Não	Não
ALU0252	Matheus Silva Araújo	CUR01	7	21	Setor Central	Regular presencial	Não	Não
ALU0253	Julia Silva Gomes	CUR01	6	17	São Carlos	Regular presencial	Não	Não
ALU0254	Gabriel Lima Ribeiro	CUR01	6	25	Paraíso	Regular presencial	Não	Não
ALU0255	Felipe Nunes Gomes	CUR01	5	24	Jundiaí	Regular híbrido	Não	Não
ALU0256	Beatriz Souza Ribeiro	CUR01	5	23	Jardim Alexandrina	Regular presencial	Não	Não
ALU0257	Gustavo Nunes Lima	CUR01	4	25	Jundiaí	Regular presencial	Não	Não
ALU0258	Isabela Teixeira Carvalho	CUR01	1	19	Jibran El Hadj	Regular presencial	Não	Não
ALU0259	Rafael Nunes Santos	CUR01	4	23	Maracanã	Regular presencial	Não	Não
ALU0260	Rafael Ferreira Lima	CUR01	8	18	Setor Central	Regular presencial	Não	Não
ALU0261	Luana Almeida Rodrigues	CUR01	1	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0262	Rafael Martins Costa	CUR01	4	17	Boa Vista	Regular presencial	Não	Não
ALU0263	Pedro Pereira Martins	CUR01	8	20	São Carlos	Regular híbrido	Não	Sim
ALU0264	Amanda Barbosa Rodrigues	CUR01	1	25	Setor Industrial	Regular presencial	Não	Não
ALU0265	Eduardo Ferreira Ribeiro	CUR01	3	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0266	Felipe Rodrigues Pereira	CUR01	8	17	Vila Jaiara	EJA	Não	Sim
ALU0267	Maria Araújo Nunes	CUR01	6	24	Maracanã	Regular presencial	Não	Não
ALU0268	Ana Mendes Barbosa	CUR01	2	19	Maracanã	Regular presencial	Sim	Não
ALU0269	Beatriz Teixeira Lima	CUR01	6	27	Setor Central	Regular presencial	Não	Não
ALU0270	Luana Oliveira Gomes	CUR01	8	23	Jardim Alexandrina	Regular presencial	Não	Não
ALU0271	Maria Martins Rocha	CUR01	1	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0272	Gustavo Gomes Mendes	CUR01	4	19	Jardim Alexandrina	Regular presencial	Não	Não
ALU0273	Thiago Silva Teixeira	CUR01	4	27	Vila Jaiara	Regular presencial	Não	Sim
ALU0274	Matheus Oliveira Lima	CUR01	2	23	Setor Central	Regular presencial	Não	Não
ALU0275	Thiago Souza Ribeiro	CUR01	2	17	Residencial das Rosas	Regular presencial	Não	Sim
ALU0276	Bruno Araújo Teixeira	CUR01	6	17	Filostro Machado	Regular presencial	Não	Não
ALU0277	Isabela Costa Mendes	CUR01	1	21	São Carlos	Regular presencial	Não	Não
ALU0278	Maria Mendes Carvalho	CUR01	5	29	Filostro Machado	Regular presencial	Não	Não
ALU0279	Lucas Araújo Martins	CUR01	2	18	São Carlos	Regular presencial	Não	Sim
ALU0280	Carlos Araújo Ferreira	CUR01	7	23	Boa Vista	Regular híbrido	Não	Não
ALU0281	Amanda Barbosa Silva	CUR01	1	25	Setor Industrial	Regular presencial	Não	Não
ALU0282	Mariana Barbosa Rocha	CUR01	8	17	Anápolis City	Regular presencial	Sim	Não
ALU0283	Renato Carvalho Oliveira	CUR01	7	26	Recanto do Sol	Regular presencial	Não	Não
ALU0284	Gabriel Souza Carvalho	CUR01	6	24	Recanto do Sol	Regular presencial	Não	Não
ALU0285	Felipe Martins Rodrigues	CUR01	5	27	Residencial das Rosas	Regular presencial	Não	Não
ALU0286	Lucas Gomes Almeida	CUR01	2	23	Anápolis City	Regular híbrido	Não	Não
ALU0287	Rafael Mendes Gomes	CUR01	5	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0288	Lucas Pereira Rodrigues	CUR01	2	20	Filostro Machado	Regular presencial	Não	Não
ALU0289	Luana Silva Carvalho	CUR01	4	19	Paraíso	Regular híbrido	Não	Não
ALU0290	Mariana Pereira Pereira	CUR01	4	18	Jardim Alexandrina	Regular presencial	Não	Não
ALU0291	Amanda Ferreira Costa	CUR01	1	20	Recanto do Sol	Regular presencial	Não	Não
ALU0292	Felipe Martins Ferreira	CUR01	7	17	Recanto do Sol	Regular presencial	Não	Não
ALU0293	Thiago Martins Gomes	CUR01	8	17	Maracanã	Regular híbrido	Não	Não
ALU0294	Bruno Teixeira Martins	CUR01	5	21	Vila Jaiara	Regular presencial	Não	Não
ALU0295	Larissa Rodrigues Lima	CUR01	4	17	Boa Vista	Regular presencial	Não	Não
ALU0296	Lucas Silva Oliveira	CUR01	8	20	Setor Industrial	Regular presencial	Não	Não
ALU0297	Maria Ribeiro Gomes	CUR01	8	17	Setor Central	Regular presencial	Sim	Não
ALU0298	Isabela Almeida Oliveira	CUR01	8	23	Setor Industrial	Regular presencial	Não	Não
ALU0299	Eduardo Mendes Mendes	CUR01	2	20	Setor Industrial	EJA	Sim	Não
ALU0300	Camila Costa Silva	CUR01	7	22	Paraíso	Regular presencial	Não	Não
ALU0301	Letícia Pereira Ferreira	CUR01	1	21	Setor Industrial	Regular presencial	Não	Não
ALU0302	Bruno Rocha Ferreira	CUR01	8	28	Paraíso	Regular presencial	Sim	Não
ALU0303	Isabela Silva Barbosa	CUR01	5	20	Jundiaí	Regular presencial	Não	Sim
ALU0304	João Lima Oliveira	CUR01	8	17	Jardim Alexandrina	Regular presencial	Não	Sim
ALU0305	Luana Barbosa Ribeiro	CUR01	3	25	Vila Jaiara	Regular presencial	Não	Não
ALU0306	João Rocha Ribeiro	CUR01	5	25	Residencial das Rosas	Regular presencial	Sim	Não
ALU0307	Camila Teixeira Rocha	CUR01	4	22	Recanto do Sol	Regular presencial	Não	Não
ALU0308	Gabriel Rocha Teixeira	CUR01	1	24	Boa Vista	EJA	Não	Não
ALU0309	Julia Ribeiro Lima	CUR01	1	22	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0310	Bruno Rodrigues Almeida	CUR01	5	25	São Carlos	Regular presencial	Não	Não
ALU0311	Felipe Teixeira Oliveira	CUR01	4	22	Recanto do Sol	Regular presencial	Não	Não
ALU0312	Ana Mendes Santos	CUR01	8	17	Recanto do Sol	Regular presencial	Sim	Sim
ALU0313	Ana Ribeiro Martins	CUR01	8	25	Maracanã	Regular presencial	Não	Não
ALU0314	Letícia Oliveira Almeida	CUR01	1	17	Setor Central	Regular presencial	Não	Não
ALU0315	Matheus Gomes Santos	CUR01	2	22	Anápolis City	Regular híbrido	Não	Não
ALU0316	Matheus Pereira Mendes	CUR01	8	23	Paraíso	Regular presencial	Não	Não
ALU0317	Ana Rocha Rodrigues	CUR01	8	26	São Carlos	Regular híbrido	Não	Não
ALU0318	Gustavo Teixeira Rodrigues	CUR01	4	21	Anápolis City	Regular presencial	Não	Sim
ALU0319	Larissa Silva Teixeira	CUR01	3	20	Vila Jaiara	EJA	Não	Não
ALU0320	Felipe Oliveira Mendes	CUR01	7	26	Residencial das Rosas	Regular híbrido	Não	Não
ALU0321	Eduardo Souza Mendes	CUR01	2	24	Maracanã	EJA	Sim	Não
ALU0322	Bruno Araújo Nunes	CUR01	5	27	Vila Jaiara	Regular presencial	Não	Não
ALU0323	Victor Teixeira Silva	CUR01	4	21	Recanto do Sol	Regular presencial	Não	Não
ALU0324	Pedro Oliveira Pereira	CUR01	6	18	Paraíso	Regular presencial	Não	Não
ALU0325	Luana Rodrigues Carvalho	CUR01	6	23	São Carlos	EJA	Não	Não
ALU0326	Matheus Araújo Costa	CUR01	7	17	Setor Central	Regular presencial	Não	Não
ALU0327	Matheus Araújo Silva	CUR01	1	21	Anápolis City	Regular presencial	Não	Não
ALU0328	Pedro Rocha Teixeira	CUR01	2	18	Setor Industrial	Regular presencial	Sim	Sim
ALU0329	Camila Teixeira Pereira	CUR01	1	26	Jibran El Hadj	EJA	Não	Não
ALU0330	Rafael Gomes Lima	CUR01	6	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0331	Julia Barbosa Oliveira	CUR01	4	23	Maracanã	Regular presencial	Não	Não
ALU0332	Larissa Barbosa Araújo	CUR01	7	24	Vila Jaiara	Regular presencial	Sim	Não
ALU0333	Letícia Mendes Ferreira	CUR01	1	20	Maracanã	Regular presencial	Não	Não
ALU0334	Lucas Souza Araújo	CUR01	2	32	Setor Central	Regular presencial	Não	Não
ALU0335	Ana Martins Ribeiro	CUR01	5	17	Boa Vista	Regular híbrido	Não	Não
ALU0336	Letícia Santos Carvalho	CUR01	5	18	Paraíso	Regular presencial	Não	Não
ALU0337	Matheus Rocha Araújo	CUR01	3	19	Setor Industrial	Regular presencial	Não	Não
ALU0338	Thiago Carvalho Mendes	CUR01	1	22	Jundiaí	Regular híbrido	Não	Não
ALU0339	João Mendes Almeida	CUR01	3	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0340	Amanda Rodrigues Teixeira	CUR01	1	22	Maracanã	Regular presencial	Não	Não
ALU0341	Camila Gomes Rodrigues	CUR01	4	17	Anápolis City	Regular presencial	Sim	Não
ALU0342	Eduardo Martins Araújo	CUR01	2	25	Recanto do Sol	Regular híbrido	Sim	Não
ALU0343	Felipe Rodrigues Ribeiro	CUR01	4	25	Vila Jaiara	Regular presencial	Não	Não
ALU0344	Amanda Ribeiro Araújo	CUR01	4	21	Setor Central	Regular presencial	Não	Não
ALU0345	Isabela Almeida Lima	CUR01	7	18	Boa Vista	Regular presencial	Não	Não
ALU0346	Renato Silva Souza	CUR01	7	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0347	Gustavo Barbosa Rodrigues	CUR01	3	18	Anápolis City	Regular presencial	Não	Não
ALU0348	Mariana Costa Silva	CUR01	7	17	São Carlos	Regular híbrido	Sim	Não
ALU0349	Gustavo Lima Lima	CUR01	8	20	Jibran El Hadj	Regular presencial	Não	Não
ALU0350	Eduardo Lima Rocha	CUR01	8	21	Setor Central	Regular presencial	Não	Não
ALU0351	Camila Barbosa Rodrigues	CUR01	5	24	Setor Central	Regular presencial	Não	Não
ALU0352	Gustavo Gomes Almeida	CUR01	2	22	Recanto do Sol	Regular presencial	Não	Sim
ALU0353	Bruno Almeida Carvalho	CUR01	3	17	Setor Industrial	Regular presencial	Não	Não
ALU0354	Letícia Teixeira Rodrigues	CUR01	7	23	São Carlos	Regular presencial	Não	Não
ALU0355	Amanda Oliveira Gomes	CUR01	5	31	Paraíso	Regular híbrido	Não	Não
ALU0356	Luana Carvalho Rocha	CUR01	8	22	Setor Central	Regular presencial	Sim	Não
ALU0357	Larissa Martins Lima	CUR01	8	22	Residencial das Rosas	Regular presencial	Não	Não
ALU0358	Victor Araújo Rodrigues	CUR01	7	18	Boa Vista	Regular presencial	Não	Não
ALU0359	Pedro Barbosa Mendes	CUR01	4	20	São Carlos	EJA	Não	Sim
ALU0360	Letícia Santos Souza	CUR01	2	24	Vila Jaiara	Regular híbrido	Sim	Não
ALU0361	Beatriz Araújo Gomes	CUR01	2	17	Setor Central	Regular presencial	Não	Não
ALU0362	Gustavo Ferreira Costa	CUR01	4	20	São Carlos	EJA	Não	Não
ALU0363	Luana Souza Ribeiro	CUR01	8	20	Setor Central	Regular presencial	Não	Não
ALU0364	João Souza Ferreira	CUR01	1	19	Paraíso	EJA	Não	Não
ALU0365	Maria Lima Martins	CUR01	2	17	Vivian Parque	Regular presencial	Sim	Não
ALU0366	Isabela Nunes Barbosa	CUR01	3	19	Vila Jaiara	Regular híbrido	Não	Não
ALU0367	Gabriel Carvalho Martins	CUR01	8	25	Jibran El Hadj	Regular presencial	Não	Não
ALU0368	Amanda Almeida Silva	CUR01	4	22	Jundiaí	EJA	Não	Não
ALU0369	Julia Almeida Costa	CUR01	3	25	São Carlos	Regular presencial	Não	Não
ALU0370	Maria Pereira Costa	CUR01	6	28	Setor Industrial	Regular presencial	Não	Não
ALU0371	Maria Costa Almeida	CUR01	7	23	Setor Industrial	Regular presencial	Não	Não
ALU0372	Renato Ferreira Nunes	CUR01	8	22	Paraíso	Regular presencial	Não	Não
ALU0373	Felipe Barbosa Silva	CUR01	6	20	Vila Jaiara	Regular presencial	Não	Não
ALU0374	Luana Lima Santos	CUR01	3	18	Vivian Parque	Regular presencial	Sim	Não
ALU0375	Maria Martins Martins	CUR01	6	24	Residencial das Rosas	Regular híbrido	Não	Não
ALU0376	Eduardo Rocha Rocha	CUR01	8	18	Jibran El Hadj	Regular presencial	Não	Não
ALU0377	Bruno Silva Oliveira	CUR01	1	33	São Carlos	Regular presencial	Sim	Não
ALU0378	Carlos Almeida Pereira	CUR01	6	27	Anápolis City	Regular presencial	Não	Não
ALU0379	Renato Costa Mendes	CUR01	7	27	Vivian Parque	Regular híbrido	Não	Não
ALU0380	Pedro Teixeira Pereira	CUR01	1	29	Vila Jaiara	Regular presencial	Não	Sim
ALU0381	Pedro Lima Almeida	CUR01	7	26	Setor Industrial	Regular presencial	Não	Não
ALU0382	Gabriel Barbosa Rodrigues	CUR01	2	19	Anápolis City	Regular presencial	Não	Não
ALU0383	João Martins Mendes	CUR01	5	21	Filostro Machado	Regular presencial	Não	Não
ALU0384	Larissa Lima Rocha	CUR01	2	24	Anápolis City	Regular presencial	Não	Não
ALU0385	Amanda Nunes Rocha	CUR01	5	28	Boa Vista	Regular híbrido	Não	Não
ALU0386	João Mendes Oliveira	CUR01	6	23	Paraíso	Regular presencial	Não	Não
ALU0387	Camila Nunes Lima	CUR01	3	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0388	Ana Costa Rodrigues	CUR01	8	22	Vivian Parque	Regular presencial	Não	Não
ALU0389	Eduardo Barbosa Gomes	CUR01	7	21	Maracanã	Regular presencial	Não	Não
ALU0390	Renato Lima Teixeira	CUR01	7	19	Boa Vista	Regular presencial	Sim	Não
ALU0391	Letícia Rocha Martins	CUR01	7	28	Paraíso	EJA	Não	Não
ALU0392	Gabriel Gomes Barbosa	CUR01	5	24	Vila Jaiara	Regular presencial	Não	Não
ALU0393	Beatriz Costa Gomes	CUR01	4	24	Jundiaí	Regular presencial	Não	Não
ALU0394	Gabriel Oliveira Gomes	CUR01	4	18	Maracanã	Regular híbrido	Não	Não
ALU0395	Mariana Souza Martins	CUR01	3	27	Jundiaí	Regular presencial	Não	Não
ALU0396	Amanda Teixeira Carvalho	CUR01	5	20	Jibran El Hadj	Regular presencial	Não	Não
ALU0397	Carlos Nunes Martins	CUR01	3	25	Vila Jaiara	Regular presencial	Não	Não
ALU0398	Bruno Rocha Oliveira	CUR01	6	23	Vivian Parque	Regular presencial	Não	Não
ALU0399	Gustavo Martins Rodrigues	CUR01	8	17	Paraíso	Regular presencial	Sim	Não
ALU0400	Beatriz Rodrigues Souza	CUR01	4	21	Anápolis City	Regular presencial	Não	Não
ALU0401	Gustavo Ribeiro Almeida	CUR01	3	17	Setor Central	Regular presencial	Sim	Não
ALU0402	Julia Nunes Santos	CUR01	3	22	Residencial das Rosas	Regular presencial	Não	Não
ALU0403	Mariana Nunes Gomes	CUR01	1	17	Setor Central	Regular presencial	Não	Não
ALU0404	Isabela Nunes Almeida	CUR01	3	23	Boa Vista	Regular presencial	Não	Não
ALU0405	Amanda Martins Rocha	CUR01	8	30	Jibran El Hadj	Regular presencial	Não	Não
ALU0406	Gabriel Oliveira Santos	CUR01	4	25	Vivian Parque	Regular presencial	Não	Não
ALU0407	Larissa Teixeira Ferreira	CUR01	4	20	Residencial das Rosas	Regular presencial	Não	Não
ALU0408	Maria Silva Martins	CUR01	6	17	Maracanã	Regular presencial	Não	Não
ALU0409	Beatriz Costa Pereira	CUR01	4	20	Filostro Machado	EJA	Não	Não
ALU0410	Thiago Oliveira Martins	CUR01	8	18	Boa Vista	Regular presencial	Não	Não
ALU0411	Ana Ribeiro Silva	CUR01	4	18	Jundiaí	Regular presencial	Não	Não
ALU0412	Luana Silva Teixeira	CUR01	6	19	Setor Industrial	Regular presencial	Não	Não
ALU0413	Carlos Rocha Rodrigues	CUR01	2	23	São Carlos	Regular presencial	Sim	Não
ALU0414	Camila Pereira Silva	CUR01	5	18	Jibran El Hadj	Regular presencial	Não	Não
ALU0415	Ana Mendes Rocha	CUR01	8	20	Setor Central	Regular presencial	Não	Não
ALU0416	Victor Nunes Barbosa	CUR01	8	23	Boa Vista	Regular presencial	Não	Não
ALU0417	Gabriel Silva Oliveira	CUR01	5	26	Anápolis City	Regular presencial	Não	Não
ALU0418	Beatriz Souza Santos	CUR01	6	25	Filostro Machado	Regular presencial	Não	Não
ALU0419	Larissa Carvalho Souza	CUR01	5	17	Filostro Machado	Regular híbrido	Não	Sim
ALU0420	Letícia Mendes Santos	CUR01	6	20	Jardim Alexandrina	Regular presencial	Não	Não
ALU0421	Eduardo Santos Silva	CUR01	3	26	Setor Industrial	Regular presencial	Não	Não
ALU0422	Gabriel Rodrigues Costa	CUR01	4	26	Jundiaí	Regular presencial	Não	Não
ALU0423	Thiago Lima Gomes	CUR01	6	23	Vila Jaiara	Regular presencial	Não	Não
ALU0424	Beatriz Santos Mendes	CUR01	6	19	Recanto do Sol	Regular presencial	Não	Não
ALU0425	Rafael Santos Teixeira	CUR01	8	18	São Carlos	Regular presencial	Não	Não
ALU0426	Camila Santos Carvalho	CUR01	5	25	Jibran El Hadj	Regular presencial	Sim	Não
ALU0427	Rafael Martins Rocha	CUR01	4	28	Maracanã	Regular presencial	Não	Não
ALU0428	Carlos Ferreira Barbosa	CUR01	2	17	Filostro Machado	Regular presencial	Não	Não
ALU0429	Pedro Santos Teixeira	CUR01	4	26	Vivian Parque	Regular presencial	Não	Não
ALU0430	Luana Ferreira Mendes	CUR01	1	17	Vila Jaiara	Regular híbrido	Não	Não
ALU0431	Larissa Araújo Lima	CUR01	2	27	Setor Industrial	Regular presencial	Não	Não
ALU0432	Carlos Araújo Silva	CUR01	2	20	Filostro Machado	Regular presencial	Não	Não
ALU0433	Bruno Araújo Santos	CUR01	8	25	Residencial das Rosas	EJA	Não	Não
ALU0434	Julia Martins Martins	CUR01	7	20	Anápolis City	Regular presencial	Não	Sim
ALU0435	Victor Rodrigues Costa	CUR01	6	23	Setor Industrial	Regular presencial	Não	Não
ALU0436	Rafael Mendes Ribeiro	CUR01	2	22	Vivian Parque	Regular presencial	Não	Não
ALU0437	Mariana Gomes Souza	CUR01	2	30	Recanto do Sol	Regular híbrido	Não	Não
ALU0438	Victor Costa Mendes	CUR01	1	30	Anápolis City	Regular presencial	Não	Não
ALU0439	Pedro Costa Martins	CUR01	8	17	Residencial das Rosas	Regular presencial	Sim	Não
ALU0440	Mariana Souza Teixeira	CUR01	5	19	Setor Industrial	Regular presencial	Sim	Não
ALU0441	Camila Silva Ribeiro	CUR01	6	19	Recanto do Sol	Regular presencial	Não	Não
ALU0442	Gustavo Costa Mendes	CUR01	3	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0443	Thiago Gomes Silva	CUR01	1	22	Paraíso	Regular presencial	Sim	Não
ALU0444	Renato Gomes Costa	CUR01	8	20	Setor Industrial	Regular presencial	Não	Não
ALU0445	Bruno Mendes Ferreira	CUR01	8	33	Vivian Parque	Regular presencial	Não	Não
ALU0446	Mariana Teixeira Rocha	CUR01	2	23	Jibran El Hadj	Regular presencial	Não	Não
ALU0447	Beatriz Rocha Ferreira	CUR01	1	22	Anápolis City	Regular presencial	Sim	Não
ALU0448	Pedro Carvalho Santos	CUR01	5	23	Anápolis City	Regular presencial	Não	Não
ALU0449	Bruno Souza Almeida	CUR01	8	26	Setor Industrial	EJA	Não	Não
ALU0450	Beatriz Nunes Santos	CUR01	5	27	São Carlos	Regular presencial	Não	Não
ALU0451	Carlos Nunes Souza	CUR01	4	17	Filostro Machado	Regular presencial	Não	Sim
ALU0452	Camila Barbosa Costa	CUR01	4	26	Filostro Machado	Regular presencial	Não	Não
ALU0453	Renato Costa Pereira	CUR01	8	18	Vila Jaiara	Regular presencial	Não	Sim
ALU0454	Victor Teixeira Martins	CUR01	6	17	Jundiaí	Regular híbrido	Não	Sim
ALU0455	Felipe Ferreira Gomes	CUR01	8	24	Anápolis City	Regular presencial	Não	Não
ALU0456	João Barbosa Carvalho	CUR01	6	17	Vivian Parque	Regular presencial	Não	Não
ALU0457	Julia Teixeira Barbosa	CUR01	7	19	Jundiaí	EJA	Não	Não
ALU0458	Gustavo Rocha Martins	CUR01	2	24	Jardim Alexandrina	Regular presencial	Não	Não
ALU0459	Camila Oliveira Rocha	CUR01	7	25	Filostro Machado	Regular presencial	Não	Sim
ALU0460	Eduardo Santos Pereira	CUR01	5	20	Jardim Alexandrina	Regular híbrido	Não	Não
ALU0461	Bruno Teixeira Almeida	CUR01	1	22	Boa Vista	Regular presencial	Não	Não
ALU0462	João Oliveira Barbosa	CUR01	6	26	Jundiaí	Regular presencial	Não	Não
ALU0463	Bruno Lima Silva	CUR01	6	17	São Carlos	EJA	Não	Não
ALU0464	Beatriz Costa Silva	CUR01	3	19	Boa Vista	Regular presencial	Não	Não
ALU0465	Eduardo Mendes Ferreira	CUR01	5	19	Anápolis City	Regular presencial	Não	Não
ALU0466	Mariana Ferreira Lima	CUR01	6	17	Setor Industrial	Regular presencial	Sim	Sim
ALU0467	Beatriz Barbosa Teixeira	CUR01	3	22	Anápolis City	Regular presencial	Não	Sim
ALU0468	Felipe Nunes Silva	CUR01	2	18	Vivian Parque	Regular presencial	Não	Não
ALU0469	Camila Carvalho Carvalho	CUR01	6	19	Jibran El Hadj	Regular presencial	Não	Não
ALU0470	João Araújo Almeida	CUR01	2	30	Jardim Alexandrina	EJA	Não	Não
ALU0471	Matheus Carvalho Rocha	CUR01	3	20	Setor Industrial	Regular presencial	Sim	Não
ALU0472	Amanda Almeida Santos	CUR01	7	21	Setor Central	Regular presencial	Não	Não
ALU0473	Maria Araújo Nunes	CUR01	6	20	Recanto do Sol	Regular presencial	Não	Não
ALU0474	Letícia Ribeiro Rodrigues	CUR01	2	17	São Carlos	Regular híbrido	Não	Não
ALU0475	Ana Rodrigues Barbosa	CUR01	8	22	Paraíso	Regular presencial	Não	Não
ALU0476	Beatriz Lima Costa	CUR01	4	21	Maracanã	Regular presencial	Não	Não
ALU0477	João Costa Almeida	CUR01	3	19	Jibran El Hadj	Regular presencial	Não	Não
ALU0478	Isabela Oliveira Ribeiro	CUR01	4	21	Paraíso	EJA	Não	Não
ALU0479	Felipe Silva Mendes	CUR01	4	20	Setor Central	Regular presencial	Não	Não
ALU0480	Maria Souza Pereira	CUR01	3	17	Recanto do Sol	Regular presencial	Não	Não
ALU0481	Larissa Silva Lima	CUR01	2	17	Vila Jaiara	Regular presencial	Não	Não
ALU0482	Rafael Mendes Martins	CUR01	8	22	Setor Industrial	Regular presencial	Não	Não
ALU0483	Victor Gomes Mendes	CUR01	5	22	Jibran El Hadj	Regular presencial	Não	Sim
ALU0484	Gabriel Teixeira Teixeira	CUR01	2	20	São Carlos	Regular presencial	Não	Não
ALU0485	Carlos Almeida Almeida	CUR01	3	23	Jibran El Hadj	Regular presencial	Não	Não
ALU0486	Carlos Lima Gomes	CUR01	4	30	Anápolis City	Regular presencial	Não	Não
ALU0487	João Ribeiro Santos	CUR01	8	18	Filostro Machado	Regular presencial	Não	Não
ALU0488	Camila Souza Costa	CUR01	4	21	Setor Industrial	Regular presencial	Não	Não
ALU0489	Carlos Costa Nunes	CUR01	6	20	Maracanã	Regular presencial	Não	Não
ALU0490	Gabriel Araújo Barbosa	CUR01	4	22	Vila Jaiara	EJA	Sim	Não
ALU0491	Victor Souza Rocha	CUR01	2	17	Filostro Machado	Regular híbrido	Não	Não
ALU0492	Amanda Araújo Martins	CUR01	7	23	Jardim Alexandrina	Regular híbrido	Não	Não
ALU0493	Thiago Ribeiro Carvalho	CUR01	3	22	Recanto do Sol	Regular presencial	Não	Não
ALU0494	Victor Carvalho Costa	CUR01	5	17	Paraíso	Regular presencial	Não	Não
ALU0495	Thiago Rodrigues Teixeira	CUR01	4	18	Setor Industrial	EJA	Não	Não
ALU0496	Lucas Nunes Mendes	CUR01	4	28	Anápolis City	Regular híbrido	Não	Não
ALU0497	Maria Mendes Mendes	CUR01	6	19	Vivian Parque	Regular presencial	Não	Não
ALU0498	Thiago Pereira Souza	CUR01	3	23	Jardim Alexandrina	Regular presencial	Não	Não
ALU0499	Bruno Almeida Ferreira	CUR01	3	20	Vila Jaiara	Regular presencial	Não	Não
ALU0500	Mariana Rocha Mendes	CUR01	7	22	Jibran El Hadj	EJA	Não	Não
ALU0501	Isabela Ribeiro Barbosa	CUR01	7	28	Jibran El Hadj	Regular presencial	Não	Não
ALU0502	Rafael Almeida Teixeira	CUR01	1	22	Boa Vista	Regular presencial	Não	Não
ALU0503	Gustavo Lima Gomes	CUR01	7	24	Paraíso	Regular presencial	Não	Não
ALU0504	Pedro Martins Almeida	CUR01	5	17	Jundiaí	Regular presencial	Não	Não
ALU0505	Victor Gomes Silva	CUR01	6	22	Recanto do Sol	Regular presencial	Sim	Não
ALU0506	Rafael Teixeira Lima	CUR01	6	23	Vivian Parque	EJA	Sim	Não
ALU0507	Matheus Teixeira Costa	CUR01	3	18	Paraíso	Regular híbrido	Não	Não
ALU0508	Bruno Oliveira Oliveira	CUR01	5	26	Anápolis City	Regular presencial	Não	Não
ALU0509	Matheus Almeida Pereira	CUR01	8	17	Setor Industrial	Regular híbrido	Não	Não
ALU0510	Lucas Mendes Teixeira	CUR01	6	23	Vila Jaiara	Regular presencial	Não	Não
ALU0511	Lucas Mendes Araújo	CUR01	6	17	São Carlos	Regular presencial	Não	Não
ALU0512	João Mendes Mendes	CUR01	2	17	Jundiaí	Regular presencial	Não	Sim
ALU0513	Carlos Pereira Nunes	CUR01	2	21	Setor Central	Regular híbrido	Não	Não
ALU0514	Mariana Nunes Carvalho	CUR01	2	27	Maracanã	Regular presencial	Não	Não
ALU0515	Eduardo Lima Gomes	CUR01	2	22	Residencial das Rosas	Regular presencial	Não	Não
ALU0516	Matheus Mendes Almeida	CUR01	6	22	Boa Vista	Regular híbrido	Não	Não
ALU0517	Luana Carvalho Santos	CUR01	6	19	Boa Vista	Regular híbrido	Não	Não
ALU0518	João Ferreira Carvalho	CUR01	1	17	Setor Industrial	Regular presencial	Não	Não
ALU0519	Amanda Silva Gomes	CUR01	5	20	Recanto do Sol	Regular presencial	Não	Não
ALU0520	Rafael Lima Oliveira	CUR01	3	30	Vila Jaiara	Regular presencial	Não	Não
ALU0521	Felipe Costa Carvalho	CUR01	5	17	Maracanã	Regular híbrido	Não	Não
ALU0522	Renato Mendes Barbosa	CUR01	4	29	Residencial das Rosas	Regular presencial	Não	Não
ALU0523	Ana Araújo Lima	CUR01	5	18	Paraíso	Regular híbrido	Não	Não
ALU0524	Carlos Almeida Araújo	CUR01	2	25	Jibran El Hadj	Regular presencial	Não	Não
ALU0525	Maria Barbosa Rodrigues	CUR01	8	25	Setor Industrial	Regular presencial	Sim	Não
ALU0526	Maria Mendes Souza	CUR01	5	25	Jibran El Hadj	Regular presencial	Não	Não
ALU0527	Rafael Almeida Almeida	CUR01	2	21	Boa Vista	EJA	Não	Não
ALU0528	Ana Rocha Costa	CUR01	3	20	Residencial das Rosas	Regular presencial	Não	Não
ALU0529	Bruno Almeida Nunes	CUR01	2	27	Vivian Parque	Regular presencial	Não	Não
ALU0530	Isabela Nunes Nunes	CUR01	8	23	Vila Jaiara	Regular presencial	Não	Não
ALU0531	Mariana Silva Ribeiro	CUR01	3	26	Vivian Parque	Regular híbrido	Não	Não
ALU0532	Carlos Barbosa Nunes	CUR01	2	17	São Carlos	Regular híbrido	Sim	Sim
ALU0533	Luana Almeida Pereira	CUR01	7	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0534	Amanda Oliveira Mendes	CUR01	6	31	São Carlos	Regular híbrido	Não	Não
ALU0535	Luana Ferreira Pereira	CUR01	1	25	Setor Central	EJA	Não	Não
ALU0536	Ana Nunes Lima	CUR01	3	24	São Carlos	Regular presencial	Sim	Não
ALU0537	Amanda Almeida Mendes	CUR01	4	29	Vivian Parque	Regular presencial	Não	Não
ALU0538	Felipe Carvalho Carvalho	CUR01	2	19	Setor Industrial	Regular presencial	Não	Não
ALU0539	Letícia Rodrigues Almeida	CUR01	7	21	Jardim Alexandrina	Regular presencial	Não	Não
ALU0540	Renato Oliveira Ribeiro	CUR01	4	27	Filostro Machado	Regular presencial	Não	Não
ALU0541	Bruno Costa Silva	CUR01	6	17	Paraíso	Regular presencial	Sim	Não
ALU0542	Ana Costa Nunes	CUR01	4	17	São Carlos	Regular presencial	Não	Não
ALU0543	Rafael Ribeiro Silva	CUR01	2	17	Boa Vista	Regular presencial	Não	Não
ALU0544	Camila Carvalho Pereira	CUR01	5	19	Maracanã	Regular presencial	Não	Não
ALU0545	Camila Gomes Silva	CUR01	4	22	São Carlos	Regular presencial	Não	Não
ALU0546	João Silva Lima	CUR01	2	21	Jundiaí	EJA	Não	Não
ALU0547	Isabela Ribeiro Rocha	CUR01	6	32	Paraíso	Regular presencial	Sim	Não
ALU0548	Luana Lima Nunes	CUR01	1	19	Jundiaí	Regular presencial	Não	Não
ALU0549	Lucas Pereira Nunes	CUR01	1	20	Jardim Alexandrina	Regular presencial	Não	Não
ALU0550	João Carvalho Silva	CUR01	5	20	Residencial das Rosas	Regular presencial	Não	Não
ALU0551	Amanda Santos Martins	CUR01	4	25	Boa Vista	Regular presencial	Não	Não
ALU0552	Gustavo Ribeiro Araújo	CUR01	4	17	Jibran El Hadj	Regular presencial	Sim	Não
ALU0553	Eduardo Rodrigues Rocha	CUR01	8	24	Paraíso	Regular presencial	Sim	Não
ALU0554	Bruno Nunes Rodrigues	CUR01	3	21	Jardim Alexandrina	Regular presencial	Não	Não
ALU0555	Bruno Souza Araújo	CUR01	3	19	Recanto do Sol	Regular presencial	Não	Não
ALU0556	Camila Araújo Teixeira	CUR01	6	17	Vila Jaiara	Regular presencial	Não	Não
ALU0557	Amanda Araújo Mendes	CUR01	4	23	Filostro Machado	EJA	Sim	Não
ALU0558	João Rodrigues Ferreira	CUR01	1	18	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0559	Felipe Santos Souza	CUR01	4	29	São Carlos	Regular presencial	Sim	Não
ALU0560	Thiago Martins Souza	CUR01	6	25	Setor Central	Regular presencial	Não	Não
ALU0561	Beatriz Souza Martins	CUR01	8	24	Recanto do Sol	Regular presencial	Não	Não
ALU0562	Bruno Pereira Gomes	CUR01	4	21	Maracanã	Regular híbrido	Não	Não
ALU0563	Isabela Oliveira Carvalho	CUR01	2	26	Maracanã	Regular presencial	Não	Não
ALU0564	Mariana Costa Nunes	CUR01	2	20	Residencial das Rosas	Regular híbrido	Não	Não
ALU0565	Larissa Araújo Ferreira	CUR01	7	20	Recanto do Sol	Regular presencial	Não	Não
ALU0566	Mariana Rodrigues Santos	CUR01	6	27	Jardim Alexandrina	Regular presencial	Não	Não
ALU0567	Beatriz Costa Ribeiro	CUR01	1	18	Anápolis City	Regular presencial	Não	Não
ALU0568	Gabriel Souza Nunes	CUR01	7	25	Setor Industrial	Regular presencial	Não	Não
ALU0569	Julia Carvalho Almeida	CUR01	1	17	Jundiaí	Regular presencial	Não	Não
ALU0570	Isabela Lima Lima	CUR01	4	26	Anápolis City	Regular presencial	Não	Não
ALU0571	Eduardo Rodrigues Barbosa	CUR01	8	22	Vivian Parque	Regular presencial	Sim	Não
ALU0572	Rafael Araújo Lima	CUR01	2	24	Vivian Parque	EJA	Não	Não
ALU0573	Gustavo Gomes Silva	CUR01	3	21	Anápolis City	Regular presencial	Não	Não
ALU0574	Thiago Pereira Gomes	CUR01	5	24	Filostro Machado	Regular presencial	Não	Não
ALU0575	Ana Mendes Oliveira	CUR01	4	24	Residencial das Rosas	Regular presencial	Não	Não
ALU0576	Eduardo Gomes Teixeira	CUR01	5	21	Residencial das Rosas	EJA	Não	Sim
ALU0577	Victor Souza Araújo	CUR01	8	23	Vila Jaiara	Regular presencial	Não	Não
ALU0578	Lucas Mendes Mendes	CUR01	2	22	Maracanã	Regular híbrido	Não	Não
ALU0579	Renato Barbosa Ferreira	CUR01	1	17	Residencial das Rosas	Regular presencial	Não	Não
ALU0580	Luana Carvalho Carvalho	CUR01	3	17	Recanto do Sol	Regular presencial	Não	Não
ALU0581	Lucas Souza Mendes	CUR01	3	19	Maracanã	Regular híbrido	Não	Não
ALU0582	Matheus Barbosa Ferreira	CUR01	2	18	Setor Central	Regular presencial	Sim	Não
ALU0583	Luana Araújo Araújo	CUR01	1	27	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0584	Renato Almeida Pereira	CUR01	1	24	Jardim Alexandrina	Regular presencial	Não	Não
ALU0585	Thiago Rodrigues Santos	CUR01	7	22	Jardim Alexandrina	Regular híbrido	Não	Não
ALU0586	Julia Araújo Rodrigues	CUR01	2	17	Recanto do Sol	Regular híbrido	Não	Não
ALU0587	Isabela Costa Almeida	CUR01	8	26	Vivian Parque	Regular híbrido	Não	Não
ALU0588	Renato Pereira Gomes	CUR01	4	20	Recanto do Sol	Regular presencial	Não	Não
ALU0589	Isabela Almeida Gomes	CUR01	7	24	Setor Central	Regular presencial	Não	Não
ALU0590	Gabriel Teixeira Almeida	CUR01	1	23	Jundiaí	Regular presencial	Não	Não
ALU0591	Bruno Mendes Teixeira	CUR01	6	19	Paraíso	Regular presencial	Não	Não
ALU0592	João Carvalho Rocha	CUR01	6	26	São Carlos	Regular presencial	Não	Não
ALU0593	Larissa Ferreira Martins	CUR01	5	26	Paraíso	Regular presencial	Não	Não
ALU0594	Felipe Lima Gomes	CUR01	4	17	Filostro Machado	Regular híbrido	Não	Não
ALU0595	Letícia Almeida Rodrigues	CUR01	4	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0596	Carlos Rodrigues Oliveira	CUR01	1	25	Filostro Machado	EJA	Sim	Não
ALU0597	Carlos Barbosa Silva	CUR01	7	21	Anápolis City	Regular híbrido	Não	Não
ALU0598	Julia Oliveira Almeida	CUR01	1	24	Vivian Parque	Regular presencial	Não	Não
ALU0599	Luana Gomes Barbosa	CUR01	7	21	Jundiaí	Regular híbrido	Não	Não
ALU0600	Julia Souza Ribeiro	CUR01	1	22	Boa Vista	Regular presencial	Não	Não
ALU0601	Bruno Costa Teixeira	CUR01	6	17	Anápolis City	Regular presencial	Não	Não
ALU0602	Renato Gomes Mendes	CUR01	5	29	Vila Jaiara	Regular presencial	Não	Não
ALU0603	Larissa Rocha Rocha	CUR01	8	17	Jundiaí	Regular presencial	Não	Não
ALU0604	Felipe Martins Pereira	CUR01	4	33	Residencial das Rosas	Regular híbrido	Não	Não
ALU0605	Letícia Carvalho Almeida	CUR01	3	24	Paraíso	Regular presencial	Não	Não
ALU0606	Felipe Carvalho Mendes	CUR01	3	19	Maracanã	Regular presencial	Não	Não
ALU0607	Larissa Silva Costa	CUR01	3	17	Maracanã	Regular presencial	Não	Sim
ALU0608	Lucas Costa Araújo	CUR01	5	18	Maracanã	Regular presencial	Não	Sim
ALU0609	Camila Rocha Carvalho	CUR01	3	24	Setor Central	Regular presencial	Sim	Não
ALU0610	Letícia Teixeira Mendes	CUR01	3	25	Paraíso	Regular presencial	Não	Não
ALU0611	João Rocha Pereira	CUR01	3	17	Setor Central	EJA	Não	Sim
ALU0612	Luana Lima Oliveira	CUR01	3	29	Setor Industrial	Regular presencial	Não	Não
ALU0613	Eduardo Teixeira Rodrigues	CUR01	1	18	Maracanã	Regular presencial	Não	Não
ALU0614	Matheus Ferreira Lima	CUR01	7	28	Paraíso	Regular presencial	Não	Não
ALU0615	Carlos Rocha Rodrigues	CUR01	3	27	Vivian Parque	Regular presencial	Não	Não
ALU0616	Pedro Barbosa Rodrigues	CUR01	3	30	Jardim Alexandrina	Regular presencial	Não	Não
ALU0617	Larissa Silva Rocha	CUR01	7	18	Boa Vista	Regular presencial	Não	Não
ALU0618	Luana Lima Barbosa	CUR01	2	27	Filostro Machado	Regular presencial	Sim	Não
ALU0619	Camila Araújo Souza	CUR01	2	22	Anápolis City	Regular presencial	Não	Sim
ALU0620	João Teixeira Barbosa	CUR01	4	21	Jundiaí	Regular presencial	Não	Sim
ALU0621	Gabriel Rocha Ferreira	CUR01	4	24	Jibran El Hadj	Regular presencial	Não	Não
ALU0622	Camila Carvalho Santos	CUR01	1	29	São Carlos	Regular presencial	Não	Não
ALU0623	Beatriz Silva Nunes	CUR01	6	28	São Carlos	Regular híbrido	Não	Não
ALU0624	João Souza Rodrigues	CUR01	7	24	Jundiaí	Regular presencial	Sim	Não
ALU0625	Julia Barbosa Teixeira	CUR01	6	26	Vila Jaiara	Regular presencial	Não	Não
ALU0626	Luana Carvalho Ribeiro	CUR01	7	22	Maracanã	Regular presencial	Não	Não
ALU0627	Bruno Araújo Almeida	CUR01	1	28	Residencial das Rosas	Regular presencial	Não	Não
ALU0628	Mariana Rocha Oliveira	CUR01	4	23	Paraíso	Regular presencial	Não	Não
ALU0629	Matheus Almeida Mendes	CUR01	4	23	Maracanã	Regular presencial	Não	Não
ALU0630	Pedro Pereira Ferreira	CUR01	1	29	Recanto do Sol	Regular presencial	Não	Não
ALU0631	Camila Oliveira Araújo	CUR01	3	17	Jibran El Hadj	EJA	Não	Não
ALU0632	Gustavo Martins Nunes	CUR01	8	26	Setor Industrial	Regular presencial	Não	Não
ALU0633	Felipe Mendes Carvalho	CUR01	3	22	Boa Vista	Regular presencial	Não	Sim
ALU0634	Carlos Costa Rocha	CUR01	3	22	Boa Vista	Regular presencial	Não	Não
ALU0635	Ana Gomes Oliveira	CUR01	4	21	Jibran El Hadj	Regular presencial	Não	Não
ALU0636	Pedro Araújo Araújo	CUR01	3	23	Maracanã	Regular presencial	Não	Não
ALU0637	Gabriel Lima Costa	CUR01	6	24	Maracanã	Regular presencial	Não	Não
ALU0638	Gustavo Gomes Martins	CUR01	4	29	Anápolis City	Regular presencial	Não	Não
ALU0639	Isabela Mendes Carvalho	CUR01	3	26	Filostro Machado	Regular presencial	Não	Sim
ALU0640	Victor Ribeiro Martins	CUR01	1	24	Vila Jaiara	Regular presencial	Não	Não
ALU0641	Rafael Rodrigues Pereira	CUR01	8	24	Vivian Parque	Regular presencial	Não	Não
ALU0642	João Lima Rodrigues	CUR01	4	27	Recanto do Sol	Regular presencial	Não	Não
ALU0643	Eduardo Souza Pereira	CUR01	4	20	Boa Vista	Regular presencial	Não	Não
ALU0644	Carlos Ferreira Lima	CUR01	5	26	Jundiaí	Regular presencial	Não	Não
ALU0645	Rafael Santos Lima	CUR01	6	29	Paraíso	Regular presencial	Não	Não
ALU0646	Lucas Ribeiro Araújo	CUR01	5	17	Paraíso	Regular presencial	Não	Sim
ALU0647	Renato Martins Martins	CUR01	5	25	Recanto do Sol	Regular presencial	Não	Não
ALU0648	Victor Ribeiro Ferreira	CUR01	7	17	Setor Central	Regular presencial	Não	Não
ALU0649	Luana Barbosa Ferreira	CUR01	3	28	Jibran El Hadj	Regular presencial	Não	Sim
ALU0650	Amanda Lima Oliveira	CUR01	8	17	Residencial das Rosas	Regular presencial	Não	Não
ALU0651	Matheus Teixeira Ferreira	CUR01	2	22	São Carlos	EJA	Não	Não
ALU0652	Pedro Almeida Costa	CUR01	5	18	Residencial das Rosas	Regular presencial	Não	Não
ALU0653	Letícia Martins Pereira	CUR01	6	25	Residencial das Rosas	Regular presencial	Não	Não
ALU0654	Gabriel Barbosa Nunes	CUR01	4	24	São Carlos	Regular presencial	Sim	Não
ALU0655	Felipe Ferreira Lima	CUR01	8	25	Maracanã	EJA	Não	Não
ALU0656	Amanda Nunes Teixeira	CUR01	4	24	Filostro Machado	EJA	Sim	Não
ALU0657	Thiago Lima Souza	CUR01	8	26	Paraíso	Regular híbrido	Não	Não
ALU0658	Isabela Lima Souza	CUR01	8	24	Vivian Parque	Regular presencial	Sim	Não
ALU0659	Lucas Araújo Souza	CUR01	6	20	Vila Jaiara	EJA	Não	Não
ALU0660	Eduardo Ribeiro Araújo	CUR01	4	25	Maracanã	Regular presencial	Não	Não
ALU0661	Beatriz Rocha Rocha	CUR01	4	17	Setor Central	EJA	Não	Não
ALU0662	Maria Rodrigues Rocha	CUR01	1	17	Maracanã	Regular presencial	Não	Não
ALU0663	Eduardo Ribeiro Rocha	CUR01	8	30	Setor Industrial	Regular híbrido	Não	Não
ALU0664	Julia Gomes Costa	CUR01	1	24	Jardim Alexandrina	Regular presencial	Não	Não
ALU0665	Gabriel Souza Rodrigues	CUR01	6	17	Filostro Machado	Regular presencial	Sim	Não
ALU0666	Rafael Rodrigues Ribeiro	CUR01	8	23	São Carlos	Regular presencial	Não	Não
ALU0667	Bruno Almeida Mendes	CUR01	6	31	Anápolis City	Regular presencial	Não	Não
ALU0668	Maria Ribeiro Almeida	CUR01	3	20	Anápolis City	Regular presencial	Sim	Sim
ALU0669	Victor Oliveira Teixeira	CUR01	3	28	Setor Central	Regular presencial	Não	Não
ALU0670	Eduardo Almeida Araújo	CUR01	2	30	Paraíso	Regular presencial	Não	Não
ALU0671	Eduardo Souza Martins	CUR01	8	17	Vivian Parque	Regular presencial	Não	Não
ALU0672	Maria Araújo Santos	CUR01	8	21	Jibran El Hadj	Regular híbrido	Não	Não
ALU0673	Larissa Almeida Teixeira	CUR01	4	22	São Carlos	Regular presencial	Não	Não
ALU0674	Bruno Carvalho Oliveira	CUR01	3	27	Filostro Machado	Regular presencial	Não	Não
ALU0675	Carlos Barbosa Rodrigues	CUR01	3	20	Setor Industrial	Regular presencial	Não	Não
ALU0676	Isabela Souza Almeida	CUR01	1	31	São Carlos	Regular presencial	Não	Não
ALU0677	Beatriz Ribeiro Teixeira	CUR01	1	27	Boa Vista	Regular presencial	Não	Não
ALU0678	Thiago Silva Araújo	CUR01	2	21	Filostro Machado	Regular presencial	Não	Não
ALU0679	Matheus Costa Almeida	CUR01	1	22	Paraíso	Regular presencial	Sim	Não
ALU0680	Carlos Nunes Santos	CUR01	3	27	Setor Industrial	Regular híbrido	Não	Não
ALU0681	Matheus Mendes Silva	CUR01	6	27	Jibran El Hadj	Regular presencial	Não	Não
ALU0682	Matheus Teixeira Pereira	CUR01	4	21	Jardim Alexandrina	EJA	Sim	Não
ALU0683	Larissa Martins Ferreira	CUR01	6	26	Jundiaí	Regular presencial	Não	Não
ALU0684	Camila Pereira Barbosa	CUR01	7	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0685	Eduardo Almeida Costa	CUR01	2	17	Vivian Parque	Regular híbrido	Não	Não
ALU0686	Julia Rocha Silva	CUR01	3	23	Paraíso	Regular presencial	Não	Sim
ALU0687	Victor Nunes Nunes	CUR01	2	19	Jardim Alexandrina	Regular presencial	Não	Não
ALU0688	Camila Oliveira Ribeiro	CUR01	3	29	Vivian Parque	EJA	Não	Não
ALU0689	Rafael Nunes Oliveira	CUR01	6	25	Vila Jaiara	EJA	Não	Não
ALU0690	Isabela Gomes Pereira	CUR01	3	20	Anápolis City	EJA	Não	Não
ALU0691	Luana Oliveira Mendes	CUR01	5	24	Vila Jaiara	Regular presencial	Não	Não
ALU0692	Pedro Nunes Rocha	CUR01	2	31	Filostro Machado	EJA	Não	Não
ALU0693	Carlos Santos Santos	CUR01	2	29	Boa Vista	Regular presencial	Sim	Sim
ALU0694	Felipe Rodrigues Souza	CUR01	3	22	Jibran El Hadj	Regular híbrido	Não	Não
ALU0695	Amanda Araújo Ribeiro	CUR01	2	24	Vila Jaiara	Regular híbrido	Não	Não
ALU0696	Luana Rodrigues Pereira	CUR01	7	17	Setor Central	EJA	Não	Sim
ALU0697	Isabela Gomes Araújo	CUR01	2	25	Boa Vista	Regular presencial	Não	Não
ALU0698	Gustavo Barbosa Barbosa	CUR01	6	20	Anápolis City	Regular presencial	Não	Não
ALU0699	Pedro Teixeira Lima	CUR01	8	23	Anápolis City	Regular híbrido	Não	Não
ALU0700	Carlos Mendes Araújo	CUR01	5	25	Vila Jaiara	Regular presencial	Não	Não
ALU0701	Lucas Teixeira Carvalho	CUR01	7	18	Setor Central	Regular presencial	Não	Não
ALU0702	Lucas Gomes Ribeiro	CUR01	8	25	Paraíso	Regular presencial	Não	Não
ALU0703	Gustavo Pereira Carvalho	CUR01	6	21	Filostro Machado	Regular presencial	Não	Não
ALU0704	Luana Souza Oliveira	CUR01	4	24	Jundiaí	Regular presencial	Não	Não
ALU0705	Beatriz Nunes Costa	CUR01	2	31	Setor Industrial	Regular presencial	Sim	Não
ALU0706	Bruno Gomes Almeida	CUR01	7	24	Maracanã	Regular híbrido	Sim	Não
ALU0707	Ana Rodrigues Gomes	CUR01	7	23	Residencial das Rosas	Regular presencial	Não	Sim
ALU0708	Luana Rodrigues Almeida	CUR01	8	23	Boa Vista	Regular presencial	Não	Sim
ALU0709	Larissa Rodrigues Souza	CUR01	3	23	Vila Jaiara	Regular presencial	Não	Não
ALU0710	Pedro Pereira Silva	CUR01	7	30	Vila Jaiara	Regular híbrido	Não	Não
ALU0711	Eduardo Gomes Barbosa	CUR01	5	24	Vivian Parque	Regular presencial	Não	Não
ALU0712	Bruno Barbosa Mendes	CUR01	8	22	Setor Industrial	Regular presencial	Não	Não
ALU0713	Luana Mendes Nunes	CUR01	3	26	Filostro Machado	Regular presencial	Não	Não
ALU0714	Bruno Pereira Barbosa	CUR01	8	19	Anápolis City	Regular presencial	Não	Sim
ALU0715	Beatriz Ferreira Ferreira	CUR01	3	19	Vivian Parque	Regular presencial	Não	Não
ALU0716	Pedro Barbosa Oliveira	CUR01	1	21	Filostro Machado	Regular presencial	Sim	Não
ALU0717	Isabela Carvalho Oliveira	CUR01	1	23	São Carlos	Regular híbrido	Não	Não
ALU0718	Felipe Souza Lima	CUR01	7	19	Maracanã	Regular presencial	Não	Não
ALU0719	Larissa Barbosa Oliveira	CUR01	8	25	Recanto do Sol	Regular presencial	Não	Sim
ALU0720	Rafael Mendes Oliveira	CUR01	7	29	Paraíso	Regular presencial	Sim	Não
ALU0721	Beatriz Santos Ribeiro	CUR01	2	24	Vivian Parque	Regular híbrido	Não	Não
ALU0722	Luana Ferreira Teixeira	CUR01	8	22	Boa Vista	Regular presencial	Não	Não
ALU0723	Victor Santos Nunes	CUR01	2	17	Maracanã	Regular presencial	Não	Não
ALU0724	Larissa Nunes Rocha	CUR01	4	29	Recanto do Sol	Regular presencial	Não	Não
ALU0725	Beatriz Teixeira Martins	CUR01	2	24	São Carlos	Regular presencial	Não	Não
ALU0726	Lucas Rocha Lima	CUR01	7	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0727	Ana Teixeira Barbosa	CUR01	4	21	Maracanã	Regular híbrido	Sim	Não
ALU0728	Gustavo Gomes Ferreira	CUR01	4	17	Maracanã	Regular presencial	Não	Não
ALU0729	Isabela Martins Oliveira	CUR01	6	20	Setor Central	Regular presencial	Não	Não
ALU0730	Letícia Gomes Souza	CUR01	7	18	Jardim Alexandrina	Regular presencial	Não	Não
ALU0731	Letícia Lima Souza	CUR01	8	23	Setor Central	Regular presencial	Não	Não
ALU0732	Renato Carvalho Ferreira	CUR01	3	27	Filostro Machado	Regular presencial	Sim	Não
ALU0733	Ana Teixeira Santos	CUR01	6	23	Filostro Machado	Regular presencial	Não	Não
ALU0734	Amanda Martins Costa	CUR01	2	21	Setor Industrial	Regular presencial	Não	Não
ALU0735	Julia Souza Souza	CUR01	4	23	Setor Industrial	EJA	Não	Não
ALU0736	Felipe Carvalho Mendes	CUR01	1	19	Setor Central	Regular híbrido	Não	Não
ALU0737	Isabela Oliveira Mendes	CUR01	7	20	Jardim Alexandrina	Regular presencial	Não	Não
ALU0738	Felipe Barbosa Carvalho	CUR01	8	26	Setor Central	Regular presencial	Não	Sim
ALU0739	Mariana Rodrigues Mendes	CUR01	1	25	Filostro Machado	Regular presencial	Não	Não
ALU0740	Letícia Costa Costa	CUR01	8	17	Paraíso	Regular híbrido	Não	Sim
ALU0741	Maria Mendes Nunes	CUR01	4	18	Boa Vista	Regular presencial	Não	Não
ALU0742	Isabela Souza Araújo	CUR01	1	22	Recanto do Sol	Regular presencial	Não	Não
ALU0743	Gustavo Barbosa Santos	CUR01	5	21	Jardim Alexandrina	Regular presencial	Não	Não
ALU0744	Pedro Carvalho Rocha	CUR01	3	28	Jibran El Hadj	EJA	Não	Não
ALU0745	Thiago Almeida Rodrigues	CUR01	3	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0746	Maria Silva Almeida	CUR01	1	27	Vila Jaiara	Regular presencial	Não	Não
ALU0747	Pedro Oliveira Santos	CUR01	7	34	Paraíso	Regular presencial	Sim	Não
ALU0748	Amanda Lima Martins	CUR01	6	25	Vila Jaiara	EJA	Não	Não
ALU0749	Gabriel Oliveira Rodrigues	CUR01	4	20	Anápolis City	Regular presencial	Sim	Não
ALU0750	Letícia Almeida Rocha	CUR01	6	26	Maracanã	Regular híbrido	Não	Não
ALU0751	Rafael Ribeiro Oliveira	CUR01	6	23	Vila Jaiara	Regular presencial	Não	Não
ALU0752	Renato Barbosa Ribeiro	CUR01	4	18	Jardim Alexandrina	Regular presencial	Não	Sim
ALU0753	Thiago Gomes Oliveira	CUR01	2	22	Jardim Alexandrina	Regular híbrido	Não	Não
ALU0754	Matheus Martins Almeida	CUR01	4	20	São Carlos	Regular presencial	Não	Não
ALU0755	Thiago Lima Almeida	CUR01	6	28	Jundiaí	Regular presencial	Sim	Não
ALU0756	Eduardo Gomes Oliveira	CUR01	8	20	Setor Industrial	Regular híbrido	Não	Não
ALU0757	Bruno Souza Lima	CUR01	2	21	Boa Vista	Regular presencial	Sim	Não
ALU0758	Thiago Rocha Rodrigues	CUR01	7	29	Residencial das Rosas	Regular presencial	Não	Não
ALU0759	Felipe Oliveira Oliveira	CUR01	1	26	Anápolis City	Regular presencial	Não	Não
ALU0760	Pedro Martins Silva	CUR01	5	23	São Carlos	Regular híbrido	Não	Não
ALU0761	Julia Almeida Ribeiro	CUR01	7	25	Vivian Parque	Regular presencial	Não	Sim
ALU0762	Maria Ribeiro Martins	CUR01	5	19	Setor Central	Regular presencial	Sim	Não
ALU0763	Beatriz Gomes Pereira	CUR01	3	19	Boa Vista	EJA	Não	Não
ALU0764	Letícia Ferreira Martins	CUR01	4	19	Recanto do Sol	Regular presencial	Não	Sim
ALU0765	Gustavo Gomes Barbosa	CUR01	7	20	Setor Central	Regular presencial	Não	Sim
ALU0766	Mariana Ribeiro Barbosa	CUR01	1	17	Setor Central	Regular presencial	Não	Não
ALU0767	Felipe Almeida Martins	CUR01	1	21	Setor Industrial	Regular presencial	Não	Não
ALU0768	Beatriz Souza Ribeiro	CUR01	6	21	Paraíso	Regular presencial	Não	Não
ALU0769	Matheus Pereira Almeida	CUR01	1	32	Residencial das Rosas	EJA	Não	Não
ALU0770	Matheus Souza Ribeiro	CUR01	6	21	Filostro Machado	Regular presencial	Sim	Não
ALU0771	Letícia Pereira Ribeiro	CUR01	6	22	Setor Industrial	Regular híbrido	Não	Não
ALU0772	Maria Rocha Pereira	CUR01	8	20	Setor Industrial	Regular presencial	Não	Não
ALU0773	Victor Martins Rocha	CUR01	1	19	Jundiaí	Regular presencial	Não	Não
ALU0774	Maria Martins Santos	CUR01	4	25	Jibran El Hadj	Regular presencial	Não	Não
ALU0775	Gabriel Lima Teixeira	CUR01	8	24	Setor Central	Regular presencial	Não	Não
ALU0776	João Carvalho Araújo	CUR01	4	28	Jundiaí	Regular presencial	Não	Não
ALU0777	Matheus Rodrigues Carvalho	CUR01	3	20	Paraíso	Regular híbrido	Não	Não
ALU0778	Julia Araújo Rodrigues	CUR01	7	30	Recanto do Sol	Regular presencial	Não	Não
ALU0779	Gustavo Lima Santos	CUR01	8	20	Jibran El Hadj	Regular híbrido	Não	Não
ALU0780	Beatriz Nunes Rocha	CUR01	5	27	Anápolis City	Regular presencial	Não	Sim
ALU0781	Eduardo Barbosa Ferreira	CUR01	5	24	Boa Vista	Regular híbrido	Não	Não
ALU0782	Carlos Santos Araújo	CUR01	1	28	São Carlos	Regular híbrido	Não	Não
ALU0783	Gabriel Teixeira Almeida	CUR01	5	17	São Carlos	Regular presencial	Não	Sim
ALU0784	Ana Rodrigues Ferreira	CUR01	4	21	São Carlos	Regular presencial	Sim	Não
ALU0785	Gabriel Teixeira Ferreira	CUR01	3	17	Paraíso	Regular presencial	Não	Não
ALU0786	Carlos Almeida Gomes	CUR01	6	21	Anápolis City	Regular presencial	Não	Não
ALU0787	Carlos Mendes Rodrigues	CUR01	5	22	São Carlos	Regular presencial	Não	Não
ALU0788	Gabriel Barbosa Oliveira	CUR01	1	23	Vivian Parque	Regular presencial	Sim	Não
ALU0789	Julia Barbosa Santos	CUR01	7	28	Boa Vista	EJA	Sim	Não
ALU0790	Pedro Teixeira Carvalho	CUR01	1	17	Residencial das Rosas	Regular presencial	Não	Não
ALU0791	Eduardo Martins Rocha	CUR01	1	17	Setor Central	Regular presencial	Não	Não
ALU0792	Felipe Almeida Ribeiro	CUR01	6	17	Jundiaí	Regular presencial	Não	Não
ALU0793	Gabriel Silva Rocha	CUR01	8	27	São Carlos	Regular presencial	Não	Não
ALU0794	Felipe Souza Teixeira	CUR01	7	22	Jardim Alexandrina	Regular presencial	Não	Não
ALU0795	Ana Ferreira Almeida	CUR01	5	17	São Carlos	Regular presencial	Não	Não
ALU0796	Lucas Almeida Carvalho	CUR01	7	25	Maracanã	Regular híbrido	Não	Sim
ALU0797	Julia Barbosa Rodrigues	CUR01	7	22	Setor Central	Regular presencial	Não	Não
ALU0798	Thiago Pereira Barbosa	CUR01	6	33	Maracanã	Regular presencial	Não	Não
ALU0799	Isabela Lima Rodrigues	CUR01	8	17	Maracanã	Regular híbrido	Não	Não
ALU0800	Rafael Mendes Costa	CUR01	6	20	Jundiaí	Regular presencial	Não	Não
ALU0801	Victor Silva Carvalho	CUR01	4	24	Jundiaí	Regular presencial	Sim	Não
ALU0802	Julia Rocha Nunes	CUR01	8	23	Jundiaí	Regular presencial	Não	Não
ALU0803	Larissa Carvalho Barbosa	CUR01	8	19	Jundiaí	Regular híbrido	Sim	Não
ALU0804	Amanda Rodrigues Almeida	CUR01	5	28	Vivian Parque	EJA	Não	Não
ALU0805	Matheus Lima Rocha	CUR01	8	24	Filostro Machado	Regular presencial	Não	Não
ALU0806	Bruno Nunes Ribeiro	CUR01	3	20	Maracanã	EJA	Sim	Não
ALU0807	Lucas Barbosa Ferreira	CUR01	6	28	Anápolis City	Regular híbrido	Não	Não
ALU0808	Felipe Pereira Lima	CUR01	3	20	Boa Vista	Regular presencial	Não	Não
ALU0809	Eduardo Carvalho Ferreira	CUR01	3	17	Paraíso	Regular presencial	Não	Não
ALU0810	Lucas Nunes Ferreira	CUR01	8	27	São Carlos	Regular presencial	Não	Não
ALU0811	Rafael Costa Pereira	CUR01	4	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0812	Thiago Gomes Costa	CUR01	4	22	Setor Central	Regular presencial	Não	Não
ALU0813	Lucas Rodrigues Carvalho	CUR01	5	25	Paraíso	Regular híbrido	Sim	Não
ALU0814	Ana Costa Nunes	CUR01	2	24	Filostro Machado	Regular presencial	Sim	Não
ALU0815	Gabriel Mendes Nunes	CUR01	2	24	Vivian Parque	Regular presencial	Não	Não
ALU0816	Eduardo Santos Silva	CUR01	3	17	Jundiaí	EJA	Não	Não
ALU0817	Camila Nunes Nunes	CUR01	7	23	Jibran El Hadj	Regular presencial	Sim	Não
ALU0818	Julia Santos Oliveira	CUR01	7	20	Filostro Machado	Regular presencial	Não	Sim
ALU0819	Carlos Gomes Costa	CUR01	2	27	Vivian Parque	Regular presencial	Não	Não
ALU0820	Eduardo Santos Souza	CUR01	2	20	Residencial das Rosas	Regular presencial	Sim	Não
ALU0821	Renato Almeida Pereira	CUR01	8	20	Filostro Machado	Regular presencial	Não	Não
ALU0822	Ana Carvalho Nunes	CUR01	4	17	Jundiaí	EJA	Sim	Não
ALU0823	Bruno Santos Gomes	CUR01	4	17	Vivian Parque	Regular presencial	Não	Não
ALU0824	Mariana Silva Almeida	CUR01	3	22	Setor Central	Regular híbrido	Sim	Não
ALU0825	Renato Nunes Nunes	CUR01	5	35	Vila Jaiara	Regular presencial	Não	Não
ALU0826	Renato Araújo Santos	CUR01	6	22	Jardim Alexandrina	Regular presencial	Não	Não
ALU0827	Matheus Carvalho Santos	CUR01	2	20	São Carlos	Regular presencial	Não	Não
ALU0828	Amanda Ribeiro Souza	CUR01	8	20	Paraíso	Regular presencial	Não	Não
ALU0829	Carlos Martins Oliveira	CUR01	4	17	Vivian Parque	Regular híbrido	Não	Não
ALU0830	Larissa Lima Santos	CUR01	2	26	Vivian Parque	Regular híbrido	Não	Não
ALU0831	Matheus Souza Silva	CUR01	5	22	Setor Central	Regular presencial	Não	Não
ALU0832	Beatriz Almeida Almeida	CUR01	7	17	Boa Vista	Regular presencial	Não	Não
ALU0833	Julia Costa Nunes	CUR01	6	17	Anápolis City	Regular presencial	Não	Não
ALU0834	Carlos Rodrigues Silva	CUR01	1	29	Boa Vista	Regular presencial	Sim	Não
ALU0835	Victor Lima Nunes	CUR01	3	27	Jundiaí	Regular presencial	Não	Não
ALU0836	Ana Carvalho Costa	CUR01	6	17	Paraíso	Regular presencial	Sim	Não
ALU0837	João Almeida Mendes	CUR01	4	27	Paraíso	Regular presencial	Não	Não
ALU0838	Amanda Araújo Martins	CUR01	5	22	Paraíso	Regular presencial	Não	Não
ALU0839	Thiago Barbosa Santos	CUR01	2	28	Paraíso	Regular híbrido	Não	Não
ALU0840	Ana Souza Ferreira	CUR01	6	27	Anápolis City	Regular presencial	Sim	Não
ALU0841	Isabela Oliveira Santos	CUR01	6	20	São Carlos	Regular presencial	Sim	Não
ALU0842	Matheus Pereira Rodrigues	CUR01	5	27	Jundiaí	Regular presencial	Não	Não
ALU0843	Rafael Ribeiro Teixeira	CUR01	7	24	Paraíso	Regular híbrido	Não	Não
ALU0844	Eduardo Lima Oliveira	CUR01	2	22	Setor Industrial	Regular presencial	Não	Não
ALU0845	Eduardo Rocha Rocha	CUR01	5	22	Jibran El Hadj	Regular híbrido	Não	Não
ALU0846	Matheus Rodrigues Silva	CUR01	2	28	Residencial das Rosas	Regular presencial	Não	Não
ALU0847	Isabela Silva Souza	CUR01	8	26	Filostro Machado	Regular presencial	Não	Não
ALU0848	Julia Silva Souza	CUR01	1	23	Setor Industrial	Regular presencial	Não	Não
ALU0849	Isabela Ferreira Araújo	CUR01	5	19	Residencial das Rosas	EJA	Sim	Não
ALU0850	Matheus Gomes Martins	CUR01	1	26	Maracanã	Regular presencial	Não	Sim
ALU0851	Bruno Silva Almeida	CUR01	3	23	Residencial das Rosas	EJA	Sim	Não
ALU0852	Letícia Gomes Souza	CUR01	7	17	Vivian Parque	Regular presencial	Não	Não
ALU0853	Pedro Santos Rocha	CUR01	4	18	Jundiaí	Regular presencial	Não	Não
ALU0854	João Rodrigues Almeida	CUR01	8	22	Filostro Machado	Regular presencial	Não	Não
ALU0855	Victor Gomes Oliveira	CUR01	4	26	Anápolis City	Regular presencial	Sim	Não
ALU0856	Rafael Oliveira Oliveira	CUR01	6	21	Jibran El Hadj	Regular presencial	Sim	Sim
ALU0857	Larissa Santos Carvalho	CUR01	4	23	Boa Vista	Regular presencial	Não	Não
ALU0858	Luana Silva Ferreira	CUR01	2	28	São Carlos	Regular presencial	Não	Não
ALU0859	Isabela Ferreira Silva	CUR01	2	22	Recanto do Sol	Regular presencial	Não	Não
ALU0860	Gabriel Mendes Lima	CUR01	2	19	Maracanã	Regular presencial	Não	Não
ALU0861	Renato Almeida Nunes	CUR01	2	24	Recanto do Sol	Regular presencial	Sim	Não
ALU0862	Lucas Carvalho Costa	CUR01	5	20	Vila Jaiara	Regular presencial	Sim	Não
ALU0863	Carlos Nunes Santos	CUR01	6	18	Paraíso	Regular presencial	Sim	Não
ALU0864	Amanda Mendes Santos	CUR01	1	30	São Carlos	Regular presencial	Não	Não
ALU0865	Letícia Rodrigues Barbosa	CUR01	4	25	Paraíso	EJA	Não	Não
ALU0866	Camila Souza Barbosa	CUR01	3	17	Filostro Machado	Regular presencial	Não	Não
ALU0867	Gustavo Martins Costa	CUR01	8	18	Residencial das Rosas	Regular presencial	Não	Não
ALU0868	Thiago Gomes Rodrigues	CUR01	3	26	Setor Industrial	Regular presencial	Sim	Não
ALU0869	Luana Santos Santos	CUR01	8	26	Setor Central	Regular presencial	Não	Não
ALU0870	Rafael Lima Gomes	CUR01	8	20	São Carlos	Regular híbrido	Não	Não
ALU0871	Thiago Martins Rocha	CUR01	7	17	Setor Industrial	Regular presencial	Não	Não
ALU0872	Larissa Lima Pereira	CUR01	2	24	Anápolis City	Regular híbrido	Sim	Não
ALU0873	Thiago Almeida Santos	CUR01	3	17	Setor Industrial	Regular presencial	Não	Não
ALU0874	Maria Costa Rocha	CUR01	2	20	Paraíso	Regular presencial	Não	Não
ALU0875	Thiago Ribeiro Oliveira	CUR01	7	19	Setor Industrial	Regular presencial	Não	Sim
ALU0876	Isabela Barbosa Rocha	CUR01	8	18	Jundiaí	Regular presencial	Não	Sim
ALU0877	Maria Ferreira Costa	CUR01	1	32	Vila Jaiara	Regular presencial	Não	Não
ALU0878	Gabriel Barbosa Santos	CUR01	8	22	Residencial das Rosas	Regular presencial	Não	Não
ALU0879	Renato Gomes Araújo	CUR01	3	17	Boa Vista	EJA	Não	Não
ALU0880	Gustavo Rodrigues Rodrigues	CUR01	1	29	Recanto do Sol	Regular presencial	Não	Não
ALU0881	Felipe Nunes Ferreira	CUR01	1	23	Setor Industrial	Regular presencial	Sim	Sim
ALU0882	Beatriz Costa Nunes	CUR01	4	17	Jundiaí	Regular presencial	Não	Não
ALU0883	Thiago Souza Carvalho	CUR01	7	17	Filostro Machado	Regular híbrido	Não	Não
ALU0884	Bruno Araújo Ferreira	CUR01	6	27	Vivian Parque	Regular híbrido	Sim	Sim
ALU0885	Gustavo Gomes Araújo	CUR01	2	27	Boa Vista	Regular presencial	Não	Não
ALU0886	Pedro Martins Mendes	CUR01	7	18	São Carlos	Regular presencial	Não	Não
ALU0887	Letícia Costa Carvalho	CUR01	6	22	Recanto do Sol	Regular presencial	Não	Não
ALU0888	Gustavo Teixeira Rocha	CUR01	5	25	Anápolis City	Regular presencial	Não	Não
ALU0889	Pedro Rocha Barbosa	CUR01	5	17	Vila Jaiara	Regular presencial	Sim	Não
ALU0890	João Ribeiro Rodrigues	CUR01	1	18	Setor Industrial	Regular presencial	Não	Não
ALU0891	Luana Nunes Rocha	CUR01	3	24	Jardim Alexandrina	Regular presencial	Não	Não
ALU0892	Ana Souza Teixeira	CUR01	4	26	Anápolis City	Regular presencial	Não	Não
ALU0893	Isabela Rocha Barbosa	CUR01	8	21	Anápolis City	Regular presencial	Sim	Não
ALU0894	Amanda Ribeiro Gomes	CUR01	3	28	Setor Central	Regular presencial	Não	Não
ALU0895	Letícia Gomes Almeida	CUR01	5	19	Setor Central	Regular presencial	Não	Sim
ALU0896	Eduardo Silva Almeida	CUR01	6	21	Residencial das Rosas	Regular presencial	Não	Não
ALU0897	Mariana Martins Rocha	CUR01	5	24	Jardim Alexandrina	EJA	Não	Não
ALU0898	Mariana Rodrigues Pereira	CUR01	1	30	Jibran El Hadj	Regular presencial	Não	Não
ALU0899	Mariana Pereira Almeida	CUR01	7	17	Boa Vista	Regular presencial	Não	Não
ALU0900	Eduardo Silva Mendes	CUR01	3	26	Setor Industrial	Regular híbrido	Não	Não
ALU0901	Julia Rodrigues Teixeira	CUR01	2	36	Jundiaí	Regular presencial	Não	Não
ALU0902	Ana Costa Mendes	CUR01	4	19	Vila Jaiara	Regular presencial	Não	Não
ALU0903	Renato Silva Teixeira	CUR01	3	17	São Carlos	Regular presencial	Não	Não
ALU0904	Gabriel Oliveira Pereira	CUR01	5	21	Jibran El Hadj	Regular presencial	Não	Sim
ALU0905	Maria Rodrigues Costa	CUR01	2	21	São Carlos	Regular presencial	Não	Não
ALU0906	Beatriz Santos Barbosa	CUR01	1	17	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0907	Pedro Santos Costa	CUR01	2	17	Filostro Machado	Regular híbrido	Não	Não
ALU0908	Carlos Teixeira Silva	CUR01	7	29	São Carlos	Regular presencial	Não	Não
ALU0909	Eduardo Rocha Lima	CUR01	4	19	Anápolis City	Regular presencial	Não	Não
ALU0910	Luana Teixeira Rocha	CUR01	3	20	Filostro Machado	Regular presencial	Não	Não
ALU0911	Camila Ferreira Araújo	CUR01	5	24	Residencial das Rosas	Regular presencial	Não	Não
ALU0912	Rafael Carvalho Mendes	CUR01	6	22	Paraíso	Regular presencial	Não	Não
ALU0913	Gabriel Araújo Teixeira	CUR01	2	20	Maracanã	Regular presencial	Não	Não
ALU0914	Rafael Carvalho Rocha	CUR01	6	19	Filostro Machado	EJA	Não	Não
ALU0915	Amanda Rocha Oliveira	CUR01	7	19	Vivian Parque	Regular presencial	Não	Não
ALU0916	Larissa Teixeira Carvalho	CUR01	4	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0917	Victor Ribeiro Pereira	CUR01	2	28	Jundiaí	Regular presencial	Sim	Não
ALU0918	Eduardo Martins Gomes	CUR01	8	22	Jardim Alexandrina	Regular presencial	Não	Não
ALU0919	Carlos Lima Nunes	CUR01	1	17	Paraíso	Regular presencial	Não	Não
ALU0920	Felipe Martins Teixeira	CUR01	8	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0921	Beatriz Ferreira Ferreira	CUR01	7	24	São Carlos	Regular presencial	Não	Não
ALU0922	João Pereira Mendes	CUR01	5	22	Boa Vista	Regular presencial	Não	Não
ALU0923	Camila Santos Araújo	CUR01	5	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0924	Mariana Gomes Silva	CUR01	6	25	Setor Industrial	Regular presencial	Não	Não
ALU0925	Felipe Martins Souza	CUR01	2	24	São Carlos	Regular presencial	Não	Não
ALU0926	Isabela Santos Ferreira	CUR01	7	24	Paraíso	Regular presencial	Não	Não
ALU0927	Thiago Mendes Mendes	CUR01	6	21	Setor Central	Regular híbrido	Sim	Não
ALU0928	Gustavo Silva Carvalho	CUR01	8	25	Recanto do Sol	EJA	Não	Não
ALU0929	Lucas Martins Ribeiro	CUR01	8	17	Maracanã	Regular presencial	Não	Não
ALU0930	Maria Teixeira Rocha	CUR01	1	22	Recanto do Sol	Regular presencial	Não	Não
ALU0931	Thiago Nunes Pereira	CUR01	5	30	Vivian Parque	Regular presencial	Não	Não
ALU0932	Thiago Martins Rodrigues	CUR01	3	30	Anápolis City	Regular presencial	Não	Não
ALU0933	Luana Santos Araújo	CUR01	7	23	Maracanã	Regular presencial	Não	Não
ALU0934	Gustavo Rocha Costa	CUR01	6	33	Recanto do Sol	Regular presencial	Não	Não
ALU0935	Thiago Araújo Oliveira	CUR01	5	28	Residencial das Rosas	Regular presencial	Não	Não
ALU0936	Felipe Gomes Rocha	CUR01	3	17	Setor Industrial	Regular presencial	Sim	Não
ALU0937	Julia Almeida Gomes	CUR01	5	23	Jundiaí	Regular presencial	Sim	Não
ALU0938	Eduardo Santos Pereira	CUR01	3	27	Jundiaí	EJA	Não	Sim
ALU0939	Ana Pereira Araújo	CUR01	1	19	Anápolis City	Regular presencial	Não	Não
ALU0940	Matheus Teixeira Nunes	CUR01	3	22	Recanto do Sol	Regular híbrido	Sim	Não
ALU0941	Eduardo Costa Lima	CUR01	2	27	Setor Central	Regular presencial	Sim	Não
ALU0942	Beatriz Rocha Gomes	CUR01	7	20	Vivian Parque	Regular presencial	Não	Não
ALU0943	Letícia Lima Teixeira	CUR01	5	23	Vila Jaiara	Regular presencial	Não	Não
ALU0944	João Lima Souza	CUR01	1	23	Jardim Alexandrina	Regular híbrido	Não	Não
ALU0945	Gustavo Oliveira Almeida	CUR01	3	20	Jardim Alexandrina	Regular presencial	Não	Não
ALU0946	Carlos Rodrigues Silva	CUR01	1	34	Setor Central	Regular híbrido	Sim	Não
ALU0947	Ana Ferreira Rodrigues	CUR01	8	26	Residencial das Rosas	Regular presencial	Não	Não
ALU0948	Amanda Souza Souza	CUR01	2	17	Residencial das Rosas	Regular presencial	Não	Não
ALU0949	Luana Ferreira Silva	CUR01	3	32	Filostro Machado	Regular híbrido	Sim	Não
ALU0950	Carlos Lima Costa	CUR01	2	26	Jardim Alexandrina	Regular presencial	Não	Sim
ALU0951	Thiago Araújo Gomes	CUR01	3	21	Filostro Machado	Regular presencial	Não	Não
ALU0952	Matheus Ribeiro Nunes	CUR01	2	21	Jardim Alexandrina	Regular presencial	Não	Não
ALU0953	Camila Araújo Lima	CUR01	4	24	Anápolis City	EJA	Não	Não
ALU0954	Beatriz Ferreira Pereira	CUR01	5	31	Jardim Alexandrina	Regular presencial	Não	Não
ALU0955	João Costa Pereira	CUR01	7	29	Vila Jaiara	Regular presencial	Não	Não
ALU0956	Pedro Souza Teixeira	CUR01	4	23	Residencial das Rosas	Regular presencial	Não	Não
ALU0957	Maria Gomes Silva	CUR01	5	20	Paraíso	Regular presencial	Não	Não
ALU0958	Bruno Silva Costa	CUR01	5	17	Recanto do Sol	Regular híbrido	Não	Não
ALU0959	Carlos Costa Barbosa	CUR01	6	27	Jundiaí	Regular presencial	Não	Não
ALU0960	Beatriz Gomes Almeida	CUR01	8	18	Maracanã	Regular presencial	Sim	Não
ALU0961	Larissa Santos Barbosa	CUR01	3	19	Setor Industrial	EJA	Não	Não
ALU0962	Mariana Teixeira Almeida	CUR01	3	25	Recanto do Sol	Regular presencial	Não	Não
ALU0963	Bruno Ferreira Araújo	CUR01	3	24	Maracanã	Regular presencial	Não	Não
ALU0964	Lucas Silva Mendes	CUR01	5	28	Vila Jaiara	Regular presencial	Não	Não
ALU0965	Gustavo Carvalho Mendes	CUR01	7	28	São Carlos	EJA	Não	Não
ALU0966	Rafael Ribeiro Souza	CUR01	6	22	Anápolis City	Regular presencial	Não	Não
ALU0967	Gabriel Martins Ferreira	CUR01	4	27	Residencial das Rosas	Regular presencial	Não	Não
ALU0968	Mariana Lima Souza	CUR01	5	17	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0969	Camila Rocha Ribeiro	CUR01	2	24	Filostro Machado	Regular presencial	Não	Não
ALU0970	Renato Costa Rodrigues	CUR01	5	18	Anápolis City	Regular presencial	Não	Não
ALU0971	Luana Oliveira Pereira	CUR01	6	25	Vila Jaiara	Regular presencial	Sim	Não
ALU0972	Lucas Silva Ferreira	CUR01	3	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0973	Beatriz Rocha Mendes	CUR01	4	17	Jibran El Hadj	Regular presencial	Não	Não
ALU0974	Renato Almeida Barbosa	CUR01	3	18	Residencial das Rosas	Regular presencial	Não	Não
ALU0975	Eduardo Mendes Martins	CUR01	4	18	Residencial das Rosas	Regular presencial	Não	Não
ALU0976	Luana Martins Santos	CUR01	3	17	Vila Jaiara	Regular presencial	Sim	Sim
ALU0977	Amanda Pereira Rodrigues	CUR01	1	18	Residencial das Rosas	Regular presencial	Sim	Não
ALU0978	Rafael Barbosa Pereira	CUR01	7	27	Paraíso	Regular presencial	Não	Não
ALU0979	Matheus Carvalho Silva	CUR01	6	22	Filostro Machado	Regular presencial	Não	Não
ALU0980	Eduardo Rocha Souza	CUR01	2	19	Anápolis City	Regular presencial	Não	Sim
ALU0981	Victor Martins Araújo	CUR01	6	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0982	Larissa Pereira Barbosa	CUR01	2	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU0983	Mariana Ferreira Araújo	CUR01	6	17	Setor Industrial	Regular híbrido	Não	Não
ALU0984	Carlos Oliveira Rodrigues	CUR01	5	22	Recanto do Sol	Regular presencial	Não	Não
ALU0985	Amanda Nunes Oliveira	CUR01	8	22	Jardim Alexandrina	EJA	Sim	Não
ALU0986	Renato Almeida Pereira	CUR01	6	24	Filostro Machado	Regular presencial	Não	Não
ALU0987	Pedro Rocha Martins	CUR01	5	26	Jibran El Hadj	Regular presencial	Não	Não
ALU0988	Letícia Santos Ferreira	CUR01	2	20	Anápolis City	Regular presencial	Não	Não
ALU0989	Julia Oliveira Ferreira	CUR01	5	24	Anápolis City	Regular presencial	Não	Não
ALU0990	Gustavo Barbosa Nunes	CUR01	1	22	Vila Jaiara	EJA	Não	Não
ALU0991	Felipe Ferreira Ribeiro	CUR01	2	18	Anápolis City	Regular presencial	Não	Não
ALU0992	Gabriel Souza Costa	CUR01	3	19	Jardim Alexandrina	Regular presencial	Sim	Não
ALU0993	Luana Gomes Ferreira	CUR01	4	20	Vila Jaiara	Regular presencial	Não	Não
ALU0994	Thiago Oliveira Carvalho	CUR01	8	29	São Carlos	Regular presencial	Não	Não
ALU0995	Mariana Rocha Gomes	CUR01	6	20	Setor Industrial	Regular presencial	Não	Sim
ALU0996	Victor Araújo Costa	CUR01	1	27	São Carlos	Regular presencial	Não	Não
ALU0997	Felipe Silva Costa	CUR01	2	19	Residencial das Rosas	Regular presencial	Não	Não
ALU0998	Felipe Santos Ferreira	CUR01	7	24	Anápolis City	Regular presencial	Não	Não
ALU0999	Pedro Souza Barbosa	CUR01	8	17	Jardim Alexandrina	Regular presencial	Não	Não
ALU1000	Lucas Lima Ferreira	CUR01	1	21	Jundiaí	Regular presencial	Não	Não
\.


--
-- TOC entry 4925 (class 0 OID 16699)
-- Dependencies: 223
-- Data for Name: avaliacoes_risco; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.avaliacoes_risco (id_avaliacao, id_aluno, periodo_letivo, tipo, data_avaliacao, risco_evasao_pct, nivel_risco) FROM stdin;
AVR0001	ALU0001	2026/2	Inicial	2026-08-17	26.1	Moderado
AVR0002	ALU0002	2026/2	Inicial	2026-08-17	73.3	Crítico
AVR0003	ALU0003	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0004	ALU0004	2026/2	Inicial	2026-08-17	22.8	Moderado
AVR0005	ALU0005	2026/2	Inicial	2026-08-17	19.7	Baixo
AVR0006	ALU0006	2026/2	Inicial	2026-08-17	27.8	Moderado
AVR0007	ALU0007	2026/2	Inicial	2026-08-17	12.0	Baixo
AVR0008	ALU0008	2026/2	Inicial	2026-08-17	7.5	Baixo
AVR0009	ALU0009	2026/2	Inicial	2026-08-17	66.3	Crítico
AVR0010	ALU0010	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0011	ALU0011	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0012	ALU0012	2026/2	Inicial	2026-08-17	49.8	Alto
AVR0013	ALU0013	2026/2	Inicial	2026-08-17	11.0	Baixo
AVR0014	ALU0014	2026/2	Inicial	2026-08-17	16.2	Baixo
AVR0015	ALU0015	2026/2	Inicial	2026-08-17	31.0	Moderado
AVR0016	ALU0016	2026/2	Inicial	2026-08-17	6.0	Baixo
AVR0017	ALU0017	2026/2	Inicial	2026-08-17	9.0	Baixo
AVR0018	ALU0018	2026/2	Inicial	2026-08-17	20.6	Moderado
AVR0019	ALU0019	2026/2	Inicial	2026-08-17	31.5	Moderado
AVR0020	ALU0020	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0021	ALU0021	2026/2	Inicial	2026-08-17	12.9	Baixo
AVR0022	ALU0022	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0023	ALU0023	2026/2	Inicial	2026-08-17	26.3	Moderado
AVR0024	ALU0024	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0025	ALU0025	2026/2	Inicial	2026-08-17	58.2	Crítico
AVR0026	ALU0026	2026/2	Inicial	2026-08-17	24.4	Moderado
AVR0027	ALU0027	2026/2	Inicial	2026-08-17	27.0	Moderado
AVR0028	ALU0028	2026/2	Inicial	2026-08-17	40.0	Alto
AVR0029	ALU0029	2026/2	Inicial	2026-08-17	24.5	Moderado
AVR0030	ALU0030	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0031	ALU0031	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0032	ALU0032	2026/2	Inicial	2026-08-17	42.4	Alto
AVR0033	ALU0033	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0034	ALU0034	2026/2	Inicial	2026-08-17	20.9	Moderado
AVR0035	ALU0035	2026/2	Inicial	2026-08-17	32.5	Moderado
AVR0036	ALU0036	2026/2	Inicial	2026-08-17	30.5	Moderado
AVR0037	ALU0037	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0038	ALU0038	2026/2	Inicial	2026-08-17	28.0	Moderado
AVR0039	ALU0039	2026/2	Inicial	2026-08-17	8.1	Baixo
AVR0040	ALU0040	2026/2	Inicial	2026-08-17	31.6	Moderado
AVR0041	ALU0041	2026/2	Inicial	2026-08-17	34.5	Moderado
AVR0042	ALU0042	2026/2	Inicial	2026-08-17	9.0	Baixo
AVR0043	ALU0043	2026/2	Inicial	2026-08-17	35.3	Alto
AVR0044	ALU0044	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0045	ALU0045	2026/2	Inicial	2026-08-17	17.2	Baixo
AVR0046	ALU0046	2026/2	Inicial	2026-08-17	32.9	Moderado
AVR0047	ALU0047	2026/2	Inicial	2026-08-17	42.1	Alto
AVR0048	ALU0048	2026/2	Inicial	2026-08-17	5.6	Baixo
AVR0049	ALU0049	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0050	ALU0050	2026/2	Inicial	2026-08-17	30.5	Moderado
AVR0051	ALU0051	2026/2	Inicial	2026-08-17	27.2	Moderado
AVR0052	ALU0052	2026/2	Inicial	2026-08-17	15.4	Baixo
AVR0053	ALU0053	2026/2	Inicial	2026-08-17	20.5	Moderado
AVR0054	ALU0054	2026/2	Inicial	2026-08-17	26.4	Moderado
AVR0055	ALU0055	2026/2	Inicial	2026-08-17	27.1	Moderado
AVR0056	ALU0056	2026/2	Inicial	2026-08-17	23.8	Moderado
AVR0057	ALU0057	2026/2	Inicial	2026-08-17	68.7	Crítico
AVR0058	ALU0058	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0059	ALU0059	2026/2	Inicial	2026-08-17	13.3	Baixo
AVR0060	ALU0060	2026/2	Inicial	2026-08-17	42.2	Alto
AVR0061	ALU0061	2026/2	Inicial	2026-08-17	46.0	Alto
AVR0062	ALU0062	2026/2	Inicial	2026-08-17	23.9	Moderado
AVR0063	ALU0063	2026/2	Inicial	2026-08-17	13.4	Baixo
AVR0064	ALU0064	2026/2	Inicial	2026-08-17	48.7	Alto
AVR0065	ALU0065	2026/2	Inicial	2026-08-17	20.4	Moderado
AVR0066	ALU0066	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0067	ALU0067	2026/2	Inicial	2026-08-17	42.1	Alto
AVR0068	ALU0068	2026/2	Inicial	2026-08-17	3.5	Baixo
AVR0069	ALU0069	2026/2	Inicial	2026-08-17	24.5	Moderado
AVR0070	ALU0070	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0071	ALU0071	2026/2	Inicial	2026-08-17	27.7	Moderado
AVR0072	ALU0072	2026/2	Inicial	2026-08-17	30.8	Moderado
AVR0073	ALU0073	2026/2	Inicial	2026-08-17	23.9	Moderado
AVR0074	ALU0074	2026/2	Inicial	2026-08-17	15.8	Baixo
AVR0075	ALU0075	2026/2	Inicial	2026-08-17	35.5	Alto
AVR0076	ALU0076	2026/2	Inicial	2026-08-17	34.1	Moderado
AVR0077	ALU0077	2026/2	Inicial	2026-08-17	33.8	Moderado
AVR0078	ALU0078	2026/2	Inicial	2026-08-17	31.5	Moderado
AVR0079	ALU0079	2026/2	Inicial	2026-08-17	22.6	Moderado
AVR0080	ALU0080	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0081	ALU0081	2026/2	Inicial	2026-08-17	42.0	Alto
AVR0082	ALU0082	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0083	ALU0083	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0084	ALU0084	2026/2	Inicial	2026-08-17	26.2	Moderado
AVR0085	ALU0085	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0086	ALU0086	2026/2	Inicial	2026-08-17	13.9	Baixo
AVR0087	ALU0087	2026/2	Inicial	2026-08-17	25.1	Moderado
AVR0088	ALU0088	2026/2	Inicial	2026-08-17	25.0	Moderado
AVR0089	ALU0089	2026/2	Inicial	2026-08-17	20.1	Moderado
AVR0090	ALU0090	2026/2	Inicial	2026-08-17	25.4	Moderado
AVR0091	ALU0091	2026/2	Inicial	2026-08-17	16.2	Baixo
AVR0092	ALU0092	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0093	ALU0093	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0094	ALU0094	2026/2	Inicial	2026-08-17	24.1	Moderado
AVR0095	ALU0095	2026/2	Inicial	2026-08-17	11.3	Baixo
AVR0096	ALU0096	2026/2	Inicial	2026-08-17	23.3	Moderado
AVR0097	ALU0097	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0098	ALU0098	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0099	ALU0099	2026/2	Inicial	2026-08-17	75.5	Crítico
AVR0100	ALU0100	2026/2	Inicial	2026-08-17	37.0	Alto
AVR0101	ALU0101	2026/2	Inicial	2026-08-17	28.3	Moderado
AVR0102	ALU0102	2026/2	Inicial	2026-08-17	7.5	Baixo
AVR0103	ALU0103	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0104	ALU0104	2026/2	Inicial	2026-08-17	23.4	Moderado
AVR0105	ALU0105	2026/2	Inicial	2026-08-17	33.2	Moderado
AVR0106	ALU0106	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0107	ALU0107	2026/2	Inicial	2026-08-17	22.4	Moderado
AVR0108	ALU0108	2026/2	Inicial	2026-08-17	34.8	Moderado
AVR0109	ALU0109	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0110	ALU0110	2026/2	Inicial	2026-08-17	11.0	Baixo
AVR0111	ALU0111	2026/2	Inicial	2026-08-17	22.0	Moderado
AVR0112	ALU0112	2026/2	Inicial	2026-08-17	19.9	Baixo
AVR0113	ALU0113	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0114	ALU0114	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0115	ALU0115	2026/2	Inicial	2026-08-17	11.0	Baixo
AVR0116	ALU0116	2026/2	Inicial	2026-08-17	78.0	Crítico
AVR0117	ALU0117	2026/2	Inicial	2026-08-17	26.0	Moderado
AVR0118	ALU0118	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0119	ALU0119	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0120	ALU0120	2026/2	Inicial	2026-08-17	52.1	Alto
AVR0121	ALU0121	2026/2	Inicial	2026-08-17	29.9	Moderado
AVR0122	ALU0122	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0123	ALU0123	2026/2	Inicial	2026-08-17	12.0	Baixo
AVR0124	ALU0124	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0125	ALU0125	2026/2	Inicial	2026-08-17	24.2	Moderado
AVR0126	ALU0126	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0127	ALU0127	2026/2	Inicial	2026-08-17	15.6	Baixo
AVR0128	ALU0128	2026/2	Inicial	2026-08-17	29.4	Moderado
AVR0129	ALU0129	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0130	ALU0130	2026/2	Inicial	2026-08-17	41.8	Alto
AVR0131	ALU0131	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0132	ALU0132	2026/2	Inicial	2026-08-17	21.7	Moderado
AVR0133	ALU0133	2026/2	Inicial	2026-08-17	10.3	Baixo
AVR0134	ALU0134	2026/2	Inicial	2026-08-17	18.9	Baixo
AVR0135	ALU0135	2026/2	Inicial	2026-08-17	12.4	Baixo
AVR0136	ALU0136	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0137	ALU0137	2026/2	Inicial	2026-08-17	32.1	Moderado
AVR0138	ALU0138	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0139	ALU0139	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0140	ALU0140	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0141	ALU0141	2026/2	Inicial	2026-08-17	37.5	Alto
AVR0142	ALU0142	2026/2	Inicial	2026-08-17	13.4	Baixo
AVR0143	ALU0143	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0144	ALU0144	2026/2	Inicial	2026-08-17	16.8	Baixo
AVR0145	ALU0145	2026/2	Inicial	2026-08-17	39.6	Alto
AVR0146	ALU0146	2026/2	Inicial	2026-08-17	23.6	Moderado
AVR0147	ALU0147	2026/2	Inicial	2026-08-17	21.1	Moderado
AVR0148	ALU0148	2026/2	Inicial	2026-08-17	31.9	Moderado
AVR0149	ALU0149	2026/2	Inicial	2026-08-17	27.7	Moderado
AVR0150	ALU0150	2026/2	Inicial	2026-08-17	46.0	Alto
AVR0151	ALU0151	2026/2	Inicial	2026-08-17	62.6	Crítico
AVR0152	ALU0152	2026/2	Inicial	2026-08-17	16.4	Baixo
AVR0153	ALU0153	2026/2	Inicial	2026-08-17	20.5	Moderado
AVR0154	ALU0154	2026/2	Inicial	2026-08-17	21.6	Moderado
AVR0155	ALU0155	2026/2	Inicial	2026-08-17	56.1	Crítico
AVR0156	ALU0156	2026/2	Inicial	2026-08-17	46.0	Alto
AVR0157	ALU0157	2026/2	Inicial	2026-08-17	36.6	Alto
AVR0158	ALU0158	2026/2	Inicial	2026-08-17	25.0	Moderado
AVR0159	ALU0159	2026/2	Inicial	2026-08-17	13.3	Baixo
AVR0160	ALU0160	2026/2	Inicial	2026-08-17	30.5	Moderado
AVR0161	ALU0161	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0162	ALU0162	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0163	ALU0163	2026/2	Inicial	2026-08-17	27.7	Moderado
AVR0164	ALU0164	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0165	ALU0165	2026/2	Inicial	2026-08-17	32.3	Moderado
AVR0166	ALU0166	2026/2	Inicial	2026-08-17	33.9	Moderado
AVR0167	ALU0167	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0168	ALU0168	2026/2	Inicial	2026-08-17	35.7	Alto
AVR0169	ALU0169	2026/2	Inicial	2026-08-17	28.5	Moderado
AVR0170	ALU0170	2026/2	Inicial	2026-08-17	43.7	Alto
AVR0171	ALU0171	2026/2	Inicial	2026-08-17	37.8	Alto
AVR0172	ALU0172	2026/2	Inicial	2026-08-17	7.7	Baixo
AVR0173	ALU0173	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0174	ALU0174	2026/2	Inicial	2026-08-17	36.5	Alto
AVR0175	ALU0175	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0176	ALU0176	2026/2	Inicial	2026-08-17	16.7	Baixo
AVR0177	ALU0177	2026/2	Inicial	2026-08-17	46.4	Alto
AVR0178	ALU0178	2026/2	Inicial	2026-08-17	20.9	Moderado
AVR0179	ALU0179	2026/2	Inicial	2026-08-17	47.8	Alto
AVR0180	ALU0180	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0181	ALU0181	2026/2	Inicial	2026-08-17	33.3	Moderado
AVR0182	ALU0182	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0183	ALU0183	2026/2	Inicial	2026-08-17	26.5	Moderado
AVR0184	ALU0184	2026/2	Inicial	2026-08-17	7.5	Baixo
AVR0185	ALU0185	2026/2	Inicial	2026-08-17	54.1	Alto
AVR0186	ALU0186	2026/2	Inicial	2026-08-17	27.9	Moderado
AVR0187	ALU0187	2026/2	Inicial	2026-08-17	30.3	Moderado
AVR0188	ALU0188	2026/2	Inicial	2026-08-17	6.5	Baixo
AVR0189	ALU0189	2026/2	Inicial	2026-08-17	28.2	Moderado
AVR0190	ALU0190	2026/2	Inicial	2026-08-17	32.6	Moderado
AVR0191	ALU0191	2026/2	Inicial	2026-08-17	20.9	Moderado
AVR0192	ALU0192	2026/2	Inicial	2026-08-17	25.7	Moderado
AVR0193	ALU0193	2026/2	Inicial	2026-08-17	32.0	Moderado
AVR0194	ALU0194	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0195	ALU0195	2026/2	Inicial	2026-08-17	24.0	Moderado
AVR0196	ALU0196	2026/2	Inicial	2026-08-17	20.7	Moderado
AVR0197	ALU0197	2026/2	Inicial	2026-08-17	15.8	Baixo
AVR0198	ALU0198	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0199	ALU0199	2026/2	Inicial	2026-08-17	38.0	Alto
AVR0200	ALU0200	2026/2	Inicial	2026-08-17	28.5	Moderado
AVR0201	ALU0201	2026/2	Inicial	2026-08-17	76.5	Crítico
AVR0202	ALU0202	2026/2	Inicial	2026-08-17	18.3	Baixo
AVR0203	ALU0203	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0204	ALU0204	2026/2	Inicial	2026-08-17	31.8	Moderado
AVR0205	ALU0205	2026/2	Inicial	2026-08-17	11.0	Baixo
AVR0206	ALU0206	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0207	ALU0207	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0208	ALU0208	2026/2	Inicial	2026-08-17	36.9	Alto
AVR0209	ALU0209	2026/2	Inicial	2026-08-17	15.7	Baixo
AVR0210	ALU0210	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0211	ALU0211	2026/2	Inicial	2026-08-17	29.7	Moderado
AVR0212	ALU0212	2026/2	Inicial	2026-08-17	43.5	Alto
AVR0213	ALU0213	2026/2	Inicial	2026-08-17	28.0	Moderado
AVR0214	ALU0214	2026/2	Inicial	2026-08-17	37.8	Alto
AVR0215	ALU0215	2026/2	Inicial	2026-08-17	33.7	Moderado
AVR0216	ALU0216	2026/2	Inicial	2026-08-17	23.7	Moderado
AVR0217	ALU0217	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0218	ALU0218	2026/2	Inicial	2026-08-17	29.2	Moderado
AVR0219	ALU0219	2026/2	Inicial	2026-08-17	15.8	Baixo
AVR0220	ALU0220	2026/2	Inicial	2026-08-17	54.9	Alto
AVR0221	ALU0221	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0222	ALU0222	2026/2	Inicial	2026-08-17	18.6	Baixo
AVR0223	ALU0223	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0224	ALU0224	2026/2	Inicial	2026-08-17	38.0	Alto
AVR0225	ALU0225	2026/2	Inicial	2026-08-17	47.1	Alto
AVR0226	ALU0226	2026/2	Inicial	2026-08-17	11.6	Baixo
AVR0227	ALU0227	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0228	ALU0228	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0229	ALU0229	2026/2	Inicial	2026-08-17	0.0	Baixo
AVR0230	ALU0230	2026/2	Inicial	2026-08-17	22.1	Moderado
AVR0231	ALU0231	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0232	ALU0232	2026/2	Inicial	2026-08-17	30.6	Moderado
AVR0233	ALU0233	2026/2	Inicial	2026-08-17	29.3	Moderado
AVR0234	ALU0234	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0235	ALU0235	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0236	ALU0236	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0237	ALU0237	2026/2	Inicial	2026-08-17	33.5	Moderado
AVR0238	ALU0238	2026/2	Inicial	2026-08-17	37.5	Alto
AVR0239	ALU0239	2026/2	Inicial	2026-08-17	25.5	Moderado
AVR0240	ALU0240	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0241	ALU0241	2026/2	Inicial	2026-08-17	31.5	Moderado
AVR0242	ALU0242	2026/2	Inicial	2026-08-17	25.7	Moderado
AVR0243	ALU0243	2026/2	Inicial	2026-08-17	27.1	Moderado
AVR0244	ALU0244	2026/2	Inicial	2026-08-17	8.8	Baixo
AVR0245	ALU0245	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0246	ALU0246	2026/2	Inicial	2026-08-17	22.1	Moderado
AVR0247	ALU0247	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0248	ALU0248	2026/2	Inicial	2026-08-17	20.2	Moderado
AVR0249	ALU0249	2026/2	Inicial	2026-08-17	21.8	Moderado
AVR0250	ALU0250	2026/2	Inicial	2026-08-17	31.9	Moderado
AVR0251	ALU0251	2026/2	Inicial	2026-08-17	33.3	Moderado
AVR0252	ALU0252	2026/2	Inicial	2026-08-17	9.6	Baixo
AVR0253	ALU0253	2026/2	Inicial	2026-08-17	33.4	Moderado
AVR0254	ALU0254	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0255	ALU0255	2026/2	Inicial	2026-08-17	25.5	Moderado
AVR0256	ALU0256	2026/2	Inicial	2026-08-17	22.6	Moderado
AVR0257	ALU0257	2026/2	Inicial	2026-08-17	34.0	Moderado
AVR0258	ALU0258	2026/2	Inicial	2026-08-17	39.1	Alto
AVR0259	ALU0259	2026/2	Inicial	2026-08-17	11.4	Baixo
AVR0260	ALU0260	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0261	ALU0261	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0262	ALU0262	2026/2	Inicial	2026-08-17	32.0	Moderado
AVR0263	ALU0263	2026/2	Inicial	2026-08-17	40.2	Alto
AVR0264	ALU0264	2026/2	Inicial	2026-08-17	8.5	Baixo
AVR0265	ALU0265	2026/2	Inicial	2026-08-17	15.5	Baixo
AVR0266	ALU0266	2026/2	Inicial	2026-08-17	7.5	Baixo
AVR0267	ALU0267	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0268	ALU0268	2026/2	Inicial	2026-08-17	29.5	Moderado
AVR0269	ALU0269	2026/2	Inicial	2026-08-17	34.4	Moderado
AVR0270	ALU0270	2026/2	Inicial	2026-08-17	38.0	Alto
AVR0271	ALU0271	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0272	ALU0272	2026/2	Inicial	2026-08-17	47.5	Alto
AVR0273	ALU0273	2026/2	Inicial	2026-08-17	41.0	Alto
AVR0274	ALU0274	2026/2	Inicial	2026-08-17	23.9	Moderado
AVR0275	ALU0275	2026/2	Inicial	2026-08-17	42.1	Alto
AVR0276	ALU0276	2026/2	Inicial	2026-08-17	20.5	Moderado
AVR0277	ALU0277	2026/2	Inicial	2026-08-17	28.0	Moderado
AVR0278	ALU0278	2026/2	Inicial	2026-08-17	36.0	Alto
AVR0279	ALU0279	2026/2	Inicial	2026-08-17	29.6	Moderado
AVR0280	ALU0280	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0281	ALU0281	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0282	ALU0282	2026/2	Inicial	2026-08-17	69.5	Crítico
AVR0283	ALU0283	2026/2	Inicial	2026-08-17	58.9	Crítico
AVR0284	ALU0284	2026/2	Inicial	2026-08-17	26.0	Moderado
AVR0285	ALU0285	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0286	ALU0286	2026/2	Inicial	2026-08-17	37.0	Alto
AVR0287	ALU0287	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0288	ALU0288	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0289	ALU0289	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0290	ALU0290	2026/2	Inicial	2026-08-17	25.9	Moderado
AVR0291	ALU0291	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0292	ALU0292	2026/2	Inicial	2026-08-17	25.5	Moderado
AVR0293	ALU0293	2026/2	Inicial	2026-08-17	0.0	Baixo
AVR0294	ALU0294	2026/2	Inicial	2026-08-17	20.3	Moderado
AVR0295	ALU0295	2026/2	Inicial	2026-08-17	44.4	Alto
AVR0296	ALU0296	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0297	ALU0297	2026/2	Inicial	2026-08-17	48.1	Alto
AVR0298	ALU0298	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0299	ALU0299	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0300	ALU0300	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0301	ALU0301	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0302	ALU0302	2026/2	Inicial	2026-08-17	24.5	Moderado
AVR0303	ALU0303	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0304	ALU0304	2026/2	Inicial	2026-08-17	14.8	Baixo
AVR0305	ALU0305	2026/2	Inicial	2026-08-17	38.5	Alto
AVR0306	ALU0306	2026/2	Inicial	2026-08-17	31.9	Moderado
AVR0307	ALU0307	2026/2	Inicial	2026-08-17	40.9	Alto
AVR0308	ALU0308	2026/2	Inicial	2026-08-17	33.9	Moderado
AVR0309	ALU0309	2026/2	Inicial	2026-08-17	26.4	Moderado
AVR0310	ALU0310	2026/2	Inicial	2026-08-17	27.4	Moderado
AVR0311	ALU0311	2026/2	Inicial	2026-08-17	29.5	Moderado
AVR0312	ALU0312	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0313	ALU0313	2026/2	Inicial	2026-08-17	20.3	Moderado
AVR0314	ALU0314	2026/2	Inicial	2026-08-17	36.9	Alto
AVR0315	ALU0315	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0316	ALU0316	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0317	ALU0317	2026/2	Inicial	2026-08-17	14.7	Baixo
AVR0318	ALU0318	2026/2	Inicial	2026-08-17	52.2	Alto
AVR0319	ALU0319	2026/2	Inicial	2026-08-17	20.7	Moderado
AVR0320	ALU0320	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0321	ALU0321	2026/2	Inicial	2026-08-17	38.0	Alto
AVR0322	ALU0322	2026/2	Inicial	2026-08-17	38.0	Alto
AVR0323	ALU0323	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0324	ALU0324	2026/2	Inicial	2026-08-17	20.5	Moderado
AVR0325	ALU0325	2026/2	Inicial	2026-08-17	6.2	Baixo
AVR0326	ALU0326	2026/2	Inicial	2026-08-17	9.5	Baixo
AVR0327	ALU0327	2026/2	Inicial	2026-08-17	19.9	Baixo
AVR0328	ALU0328	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0329	ALU0329	2026/2	Inicial	2026-08-17	24.1	Moderado
AVR0330	ALU0330	2026/2	Inicial	2026-08-17	21.7	Moderado
AVR0331	ALU0331	2026/2	Inicial	2026-08-17	32.5	Moderado
AVR0332	ALU0332	2026/2	Inicial	2026-08-17	39.0	Alto
AVR0333	ALU0333	2026/2	Inicial	2026-08-17	8.1	Baixo
AVR0334	ALU0334	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0335	ALU0335	2026/2	Inicial	2026-08-17	4.0	Baixo
AVR0336	ALU0336	2026/2	Inicial	2026-08-17	45.2	Alto
AVR0337	ALU0337	2026/2	Inicial	2026-08-17	32.8	Moderado
AVR0338	ALU0338	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0339	ALU0339	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0340	ALU0340	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0341	ALU0341	2026/2	Inicial	2026-08-17	12.0	Baixo
AVR0342	ALU0342	2026/2	Inicial	2026-08-17	39.0	Alto
AVR0343	ALU0343	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0344	ALU0344	2026/2	Inicial	2026-08-17	38.3	Alto
AVR0345	ALU0345	2026/2	Inicial	2026-08-17	24.6	Moderado
AVR0346	ALU0346	2026/2	Inicial	2026-08-17	33.6	Moderado
AVR0347	ALU0347	2026/2	Inicial	2026-08-17	40.0	Alto
AVR0348	ALU0348	2026/2	Inicial	2026-08-17	59.8	Crítico
AVR0349	ALU0349	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0350	ALU0350	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0351	ALU0351	2026/2	Inicial	2026-08-17	24.0	Moderado
AVR0352	ALU0352	2026/2	Inicial	2026-08-17	48.2	Alto
AVR0353	ALU0353	2026/2	Inicial	2026-08-17	34.8	Moderado
AVR0354	ALU0354	2026/2	Inicial	2026-08-17	34.0	Moderado
AVR0355	ALU0355	2026/2	Inicial	2026-08-17	33.7	Moderado
AVR0356	ALU0356	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0357	ALU0357	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0358	ALU0358	2026/2	Inicial	2026-08-17	30.4	Moderado
AVR0359	ALU0359	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0360	ALU0360	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0361	ALU0361	2026/2	Inicial	2026-08-17	37.4	Alto
AVR0362	ALU0362	2026/2	Inicial	2026-08-17	4.9	Baixo
AVR0363	ALU0363	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0364	ALU0364	2026/2	Inicial	2026-08-17	29.0	Moderado
AVR0365	ALU0365	2026/2	Inicial	2026-08-17	19.9	Baixo
AVR0366	ALU0366	2026/2	Inicial	2026-08-17	23.2	Moderado
AVR0367	ALU0367	2026/2	Inicial	2026-08-17	26.2	Moderado
AVR0368	ALU0368	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0369	ALU0369	2026/2	Inicial	2026-08-17	28.9	Moderado
AVR0370	ALU0370	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0371	ALU0371	2026/2	Inicial	2026-08-17	35.8	Alto
AVR0372	ALU0372	2026/2	Inicial	2026-08-17	29.5	Moderado
AVR0373	ALU0373	2026/2	Inicial	2026-08-17	37.6	Alto
AVR0374	ALU0374	2026/2	Inicial	2026-08-17	30.1	Moderado
AVR0375	ALU0375	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0376	ALU0376	2026/2	Inicial	2026-08-17	15.5	Baixo
AVR0377	ALU0377	2026/2	Inicial	2026-08-17	45.2	Alto
AVR0378	ALU0378	2026/2	Inicial	2026-08-17	29.4	Moderado
AVR0379	ALU0379	2026/2	Inicial	2026-08-17	18.6	Baixo
AVR0380	ALU0380	2026/2	Inicial	2026-08-17	30.8	Moderado
AVR0381	ALU0381	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0382	ALU0382	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0383	ALU0383	2026/2	Inicial	2026-08-17	12.0	Baixo
AVR0384	ALU0384	2026/2	Inicial	2026-08-17	40.9	Alto
AVR0385	ALU0385	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0386	ALU0386	2026/2	Inicial	2026-08-17	23.2	Moderado
AVR0387	ALU0387	2026/2	Inicial	2026-08-17	49.6	Alto
AVR0388	ALU0388	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0389	ALU0389	2026/2	Inicial	2026-08-17	5.8	Baixo
AVR0390	ALU0390	2026/2	Inicial	2026-08-17	36.0	Alto
AVR0391	ALU0391	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0392	ALU0392	2026/2	Inicial	2026-08-17	36.6	Alto
AVR0393	ALU0393	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0394	ALU0394	2026/2	Inicial	2026-08-17	31.0	Moderado
AVR0395	ALU0395	2026/2	Inicial	2026-08-17	16.4	Baixo
AVR0396	ALU0396	2026/2	Inicial	2026-08-17	32.0	Moderado
AVR0397	ALU0397	2026/2	Inicial	2026-08-17	15.6	Baixo
AVR0398	ALU0398	2026/2	Inicial	2026-08-17	29.2	Moderado
AVR0399	ALU0399	2026/2	Inicial	2026-08-17	14.6	Baixo
AVR0400	ALU0400	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0401	ALU0401	2026/2	Inicial	2026-08-17	40.9	Alto
AVR0402	ALU0402	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0403	ALU0403	2026/2	Inicial	2026-08-17	37.6	Alto
AVR0404	ALU0404	2026/2	Inicial	2026-08-17	19.8	Baixo
AVR0405	ALU0405	2026/2	Inicial	2026-08-17	13.3	Baixo
AVR0406	ALU0406	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0407	ALU0407	2026/2	Inicial	2026-08-17	36.0	Alto
AVR0408	ALU0408	2026/2	Inicial	2026-08-17	37.6	Alto
AVR0409	ALU0409	2026/2	Inicial	2026-08-17	35.8	Alto
AVR0410	ALU0410	2026/2	Inicial	2026-08-17	32.7	Moderado
AVR0411	ALU0411	2026/2	Inicial	2026-08-17	28.3	Moderado
AVR0412	ALU0412	2026/2	Inicial	2026-08-17	66.8	Crítico
AVR0413	ALU0413	2026/2	Inicial	2026-08-17	15.9	Baixo
AVR0414	ALU0414	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0415	ALU0415	2026/2	Inicial	2026-08-17	25.7	Moderado
AVR0416	ALU0416	2026/2	Inicial	2026-08-17	13.3	Baixo
AVR0417	ALU0417	2026/2	Inicial	2026-08-17	68.6	Crítico
AVR0418	ALU0418	2026/2	Inicial	2026-08-17	28.1	Moderado
AVR0419	ALU0419	2026/2	Inicial	2026-08-17	21.6	Moderado
AVR0420	ALU0420	2026/2	Inicial	2026-08-17	20.5	Moderado
AVR0421	ALU0421	2026/2	Inicial	2026-08-17	26.5	Moderado
AVR0422	ALU0422	2026/2	Inicial	2026-08-17	11.6	Baixo
AVR0423	ALU0423	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0424	ALU0424	2026/2	Inicial	2026-08-17	7.0	Baixo
AVR0425	ALU0425	2026/2	Inicial	2026-08-17	34.0	Moderado
AVR0426	ALU0426	2026/2	Inicial	2026-08-17	38.1	Alto
AVR0427	ALU0427	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0428	ALU0428	2026/2	Inicial	2026-08-17	18.4	Baixo
AVR0429	ALU0429	2026/2	Inicial	2026-08-17	18.2	Baixo
AVR0430	ALU0430	2026/2	Inicial	2026-08-17	43.9	Alto
AVR0431	ALU0431	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0432	ALU0432	2026/2	Inicial	2026-08-17	29.2	Moderado
AVR0433	ALU0433	2026/2	Inicial	2026-08-17	27.0	Moderado
AVR0434	ALU0434	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0435	ALU0435	2026/2	Inicial	2026-08-17	31.5	Moderado
AVR0436	ALU0436	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0437	ALU0437	2026/2	Inicial	2026-08-17	44.3	Alto
AVR0438	ALU0438	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0439	ALU0439	2026/2	Inicial	2026-08-17	27.6	Moderado
AVR0440	ALU0440	2026/2	Inicial	2026-08-17	29.5	Moderado
AVR0441	ALU0441	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0442	ALU0442	2026/2	Inicial	2026-08-17	38.3	Alto
AVR0443	ALU0443	2026/2	Inicial	2026-08-17	38.0	Alto
AVR0444	ALU0444	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0445	ALU0445	2026/2	Inicial	2026-08-17	40.8	Alto
AVR0446	ALU0446	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0447	ALU0447	2026/2	Inicial	2026-08-17	44.8	Alto
AVR0448	ALU0448	2026/2	Inicial	2026-08-17	17.8	Baixo
AVR0449	ALU0449	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0450	ALU0450	2026/2	Inicial	2026-08-17	30.8	Moderado
AVR0451	ALU0451	2026/2	Inicial	2026-08-17	28.9	Moderado
AVR0452	ALU0452	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0453	ALU0453	2026/2	Inicial	2026-08-17	21.3	Moderado
AVR0454	ALU0454	2026/2	Inicial	2026-08-17	38.5	Alto
AVR0455	ALU0455	2026/2	Inicial	2026-08-17	45.9	Alto
AVR0456	ALU0456	2026/2	Inicial	2026-08-17	28.5	Moderado
AVR0457	ALU0457	2026/2	Inicial	2026-08-17	33.2	Moderado
AVR0458	ALU0458	2026/2	Inicial	2026-08-17	15.7	Baixo
AVR0459	ALU0459	2026/2	Inicial	2026-08-17	49.6	Alto
AVR0460	ALU0460	2026/2	Inicial	2026-08-17	35.3	Alto
AVR0461	ALU0461	2026/2	Inicial	2026-08-17	15.7	Baixo
AVR0462	ALU0462	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0463	ALU0463	2026/2	Inicial	2026-08-17	34.9	Moderado
AVR0464	ALU0464	2026/2	Inicial	2026-08-17	34.7	Moderado
AVR0465	ALU0465	2026/2	Inicial	2026-08-17	38.4	Alto
AVR0466	ALU0466	2026/2	Inicial	2026-08-17	43.0	Alto
AVR0467	ALU0467	2026/2	Inicial	2026-08-17	14.6	Baixo
AVR0468	ALU0468	2026/2	Inicial	2026-08-17	29.9	Moderado
AVR0469	ALU0469	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0470	ALU0470	2026/2	Inicial	2026-08-17	36.0	Alto
AVR0471	ALU0471	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0472	ALU0472	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0473	ALU0473	2026/2	Inicial	2026-08-17	64.4	Crítico
AVR0474	ALU0474	2026/2	Inicial	2026-08-17	34.1	Moderado
AVR0475	ALU0475	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0476	ALU0476	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0477	ALU0477	2026/2	Inicial	2026-08-17	17.0	Baixo
AVR0478	ALU0478	2026/2	Inicial	2026-08-17	27.8	Moderado
AVR0479	ALU0479	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0480	ALU0480	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0481	ALU0481	2026/2	Inicial	2026-08-17	15.5	Baixo
AVR0482	ALU0482	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0483	ALU0483	2026/2	Inicial	2026-08-17	26.3	Moderado
AVR0484	ALU0484	2026/2	Inicial	2026-08-17	32.2	Moderado
AVR0485	ALU0485	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0486	ALU0486	2026/2	Inicial	2026-08-17	7.5	Baixo
AVR0487	ALU0487	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0488	ALU0488	2026/2	Inicial	2026-08-17	22.8	Moderado
AVR0489	ALU0489	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0490	ALU0490	2026/2	Inicial	2026-08-17	4.0	Baixo
AVR0491	ALU0491	2026/2	Inicial	2026-08-17	10.8	Baixo
AVR0492	ALU0492	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0493	ALU0493	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0494	ALU0494	2026/2	Inicial	2026-08-17	15.5	Baixo
AVR0495	ALU0495	2026/2	Inicial	2026-08-17	31.3	Moderado
AVR0496	ALU0496	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0497	ALU0497	2026/2	Inicial	2026-08-17	8.0	Baixo
AVR0498	ALU0498	2026/2	Inicial	2026-08-17	16.8	Baixo
AVR0499	ALU0499	2026/2	Inicial	2026-08-17	25.8	Moderado
AVR0500	ALU0500	2026/2	Inicial	2026-08-17	18.6	Baixo
AVR0501	ALU0501	2026/2	Inicial	2026-08-17	59.9	Crítico
AVR0502	ALU0502	2026/2	Inicial	2026-08-17	47.1	Alto
AVR0503	ALU0503	2026/2	Inicial	2026-08-17	40.8	Alto
AVR0504	ALU0504	2026/2	Inicial	2026-08-17	12.4	Baixo
AVR0505	ALU0505	2026/2	Inicial	2026-08-17	49.3	Alto
AVR0506	ALU0506	2026/2	Inicial	2026-08-17	39.5	Alto
AVR0507	ALU0507	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0508	ALU0508	2026/2	Inicial	2026-08-17	21.9	Moderado
AVR0509	ALU0509	2026/2	Inicial	2026-08-17	16.2	Baixo
AVR0510	ALU0510	2026/2	Inicial	2026-08-17	1.4	Baixo
AVR0511	ALU0511	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0512	ALU0512	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0513	ALU0513	2026/2	Inicial	2026-08-17	21.2	Moderado
AVR0514	ALU0514	2026/2	Inicial	2026-08-17	20.9	Moderado
AVR0515	ALU0515	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0516	ALU0516	2026/2	Inicial	2026-08-17	21.6	Moderado
AVR0517	ALU0517	2026/2	Inicial	2026-08-17	33.8	Moderado
AVR0518	ALU0518	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0519	ALU0519	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0520	ALU0520	2026/2	Inicial	2026-08-17	28.3	Moderado
AVR0521	ALU0521	2026/2	Inicial	2026-08-17	37.6	Alto
AVR0522	ALU0522	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0523	ALU0523	2026/2	Inicial	2026-08-17	36.7	Alto
AVR0524	ALU0524	2026/2	Inicial	2026-08-17	57.8	Crítico
AVR0525	ALU0525	2026/2	Inicial	2026-08-17	22.2	Moderado
AVR0526	ALU0526	2026/2	Inicial	2026-08-17	19.3	Baixo
AVR0527	ALU0527	2026/2	Inicial	2026-08-17	11.0	Baixo
AVR0528	ALU0528	2026/2	Inicial	2026-08-17	32.6	Moderado
AVR0529	ALU0529	2026/2	Inicial	2026-08-17	18.9	Baixo
AVR0530	ALU0530	2026/2	Inicial	2026-08-17	30.1	Moderado
AVR0531	ALU0531	2026/2	Inicial	2026-08-17	17.6	Baixo
AVR0532	ALU0532	2026/2	Inicial	2026-08-17	73.8	Crítico
AVR0533	ALU0533	2026/2	Inicial	2026-08-17	15.8	Baixo
AVR0534	ALU0534	2026/2	Inicial	2026-08-17	24.8	Moderado
AVR0535	ALU0535	2026/2	Inicial	2026-08-17	70.2	Crítico
AVR0536	ALU0536	2026/2	Inicial	2026-08-17	36.9	Alto
AVR0537	ALU0537	2026/2	Inicial	2026-08-17	22.4	Moderado
AVR0538	ALU0538	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0539	ALU0539	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0540	ALU0540	2026/2	Inicial	2026-08-17	22.3	Moderado
AVR0541	ALU0541	2026/2	Inicial	2026-08-17	43.4	Alto
AVR0542	ALU0542	2026/2	Inicial	2026-08-17	34.5	Moderado
AVR0543	ALU0543	2026/2	Inicial	2026-08-17	22.3	Moderado
AVR0544	ALU0544	2026/2	Inicial	2026-08-17	21.4	Moderado
AVR0545	ALU0545	2026/2	Inicial	2026-08-17	24.3	Moderado
AVR0546	ALU0546	2026/2	Inicial	2026-08-17	28.9	Moderado
AVR0547	ALU0547	2026/2	Inicial	2026-08-17	57.2	Crítico
AVR0548	ALU0548	2026/2	Inicial	2026-08-17	58.1	Crítico
AVR0549	ALU0549	2026/2	Inicial	2026-08-17	26.7	Moderado
AVR0550	ALU0550	2026/2	Inicial	2026-08-17	49.9	Alto
AVR0551	ALU0551	2026/2	Inicial	2026-08-17	7.5	Baixo
AVR0552	ALU0552	2026/2	Inicial	2026-08-17	25.7	Moderado
AVR0553	ALU0553	2026/2	Inicial	2026-08-17	37.1	Alto
AVR0554	ALU0554	2026/2	Inicial	2026-08-17	22.0	Moderado
AVR0555	ALU0555	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0556	ALU0556	2026/2	Inicial	2026-08-17	12.7	Baixo
AVR0557	ALU0557	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0558	ALU0558	2026/2	Inicial	2026-08-17	22.7	Moderado
AVR0559	ALU0559	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0560	ALU0560	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0561	ALU0561	2026/2	Inicial	2026-08-17	4.0	Baixo
AVR0562	ALU0562	2026/2	Inicial	2026-08-17	26.9	Moderado
AVR0563	ALU0563	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0564	ALU0564	2026/2	Inicial	2026-08-17	40.5	Alto
AVR0565	ALU0565	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0566	ALU0566	2026/2	Inicial	2026-08-17	26.1	Moderado
AVR0567	ALU0567	2026/2	Inicial	2026-08-17	7.4	Baixo
AVR0568	ALU0568	2026/2	Inicial	2026-08-17	25.4	Moderado
AVR0569	ALU0569	2026/2	Inicial	2026-08-17	56.2	Crítico
AVR0570	ALU0570	2026/2	Inicial	2026-08-17	32.9	Moderado
AVR0571	ALU0571	2026/2	Inicial	2026-08-17	20.2	Moderado
AVR0572	ALU0572	2026/2	Inicial	2026-08-17	60.2	Crítico
AVR0573	ALU0573	2026/2	Inicial	2026-08-17	35.1	Alto
AVR0574	ALU0574	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0575	ALU0575	2026/2	Inicial	2026-08-17	19.1	Baixo
AVR0576	ALU0576	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0577	ALU0577	2026/2	Inicial	2026-08-17	22.6	Moderado
AVR0578	ALU0578	2026/2	Inicial	2026-08-17	26.3	Moderado
AVR0579	ALU0579	2026/2	Inicial	2026-08-17	46.8	Alto
AVR0580	ALU0580	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0581	ALU0581	2026/2	Inicial	2026-08-17	28.6	Moderado
AVR0582	ALU0582	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0583	ALU0583	2026/2	Inicial	2026-08-17	8.0	Baixo
AVR0584	ALU0584	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0585	ALU0585	2026/2	Inicial	2026-08-17	15.4	Baixo
AVR0586	ALU0586	2026/2	Inicial	2026-08-17	8.0	Baixo
AVR0587	ALU0587	2026/2	Inicial	2026-08-17	48.9	Alto
AVR0588	ALU0588	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0589	ALU0589	2026/2	Inicial	2026-08-17	24.8	Moderado
AVR0590	ALU0590	2026/2	Inicial	2026-08-17	14.5	Baixo
AVR0591	ALU0591	2026/2	Inicial	2026-08-17	34.6	Moderado
AVR0592	ALU0592	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0593	ALU0593	2026/2	Inicial	2026-08-17	50.0	Alto
AVR0594	ALU0594	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0595	ALU0595	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0596	ALU0596	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0597	ALU0597	2026/2	Inicial	2026-08-17	19.8	Baixo
AVR0598	ALU0598	2026/2	Inicial	2026-08-17	22.0	Moderado
AVR0599	ALU0599	2026/2	Inicial	2026-08-17	27.0	Moderado
AVR0600	ALU0600	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0601	ALU0601	2026/2	Inicial	2026-08-17	33.6	Moderado
AVR0602	ALU0602	2026/2	Inicial	2026-08-17	42.2	Alto
AVR0603	ALU0603	2026/2	Inicial	2026-08-17	31.3	Moderado
AVR0604	ALU0604	2026/2	Inicial	2026-08-17	32.6	Moderado
AVR0605	ALU0605	2026/2	Inicial	2026-08-17	18.8	Baixo
AVR0606	ALU0606	2026/2	Inicial	2026-08-17	33.7	Moderado
AVR0607	ALU0607	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0608	ALU0608	2026/2	Inicial	2026-08-17	39.1	Alto
AVR0609	ALU0609	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0610	ALU0610	2026/2	Inicial	2026-08-17	18.4	Baixo
AVR0611	ALU0611	2026/2	Inicial	2026-08-17	57.0	Crítico
AVR0612	ALU0612	2026/2	Inicial	2026-08-17	44.3	Alto
AVR0613	ALU0613	2026/2	Inicial	2026-08-17	26.0	Moderado
AVR0614	ALU0614	2026/2	Inicial	2026-08-17	30.3	Moderado
AVR0615	ALU0615	2026/2	Inicial	2026-08-17	39.8	Alto
AVR0616	ALU0616	2026/2	Inicial	2026-08-17	22.8	Moderado
AVR0617	ALU0617	2026/2	Inicial	2026-08-17	57.7	Crítico
AVR0618	ALU0618	2026/2	Inicial	2026-08-17	39.1	Alto
AVR0619	ALU0619	2026/2	Inicial	2026-08-17	22.9	Moderado
AVR0620	ALU0620	2026/2	Inicial	2026-08-17	46.2	Alto
AVR0621	ALU0621	2026/2	Inicial	2026-08-17	21.2	Moderado
AVR0622	ALU0622	2026/2	Inicial	2026-08-17	66.0	Crítico
AVR0623	ALU0623	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0624	ALU0624	2026/2	Inicial	2026-08-17	22.1	Moderado
AVR0625	ALU0625	2026/2	Inicial	2026-08-17	32.5	Moderado
AVR0626	ALU0626	2026/2	Inicial	2026-08-17	19.7	Baixo
AVR0627	ALU0627	2026/2	Inicial	2026-08-17	15.9	Baixo
AVR0628	ALU0628	2026/2	Inicial	2026-08-17	15.4	Baixo
AVR0629	ALU0629	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0630	ALU0630	2026/2	Inicial	2026-08-17	26.5	Moderado
AVR0631	ALU0631	2026/2	Inicial	2026-08-17	29.2	Moderado
AVR0632	ALU0632	2026/2	Inicial	2026-08-17	23.4	Moderado
AVR0633	ALU0633	2026/2	Inicial	2026-08-17	40.4	Alto
AVR0634	ALU0634	2026/2	Inicial	2026-08-17	24.5	Moderado
AVR0635	ALU0635	2026/2	Inicial	2026-08-17	25.1	Moderado
AVR0636	ALU0636	2026/2	Inicial	2026-08-17	45.5	Alto
AVR0637	ALU0637	2026/2	Inicial	2026-08-17	9.1	Baixo
AVR0638	ALU0638	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0639	ALU0639	2026/2	Inicial	2026-08-17	49.1	Alto
AVR0640	ALU0640	2026/2	Inicial	2026-08-17	22.2	Moderado
AVR0641	ALU0641	2026/2	Inicial	2026-08-17	21.4	Moderado
AVR0642	ALU0642	2026/2	Inicial	2026-08-17	20.7	Moderado
AVR0643	ALU0643	2026/2	Inicial	2026-08-17	43.4	Alto
AVR0644	ALU0644	2026/2	Inicial	2026-08-17	26.7	Moderado
AVR0645	ALU0645	2026/2	Inicial	2026-08-17	7.0	Baixo
AVR0646	ALU0646	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0647	ALU0647	2026/2	Inicial	2026-08-17	40.9	Alto
AVR0648	ALU0648	2026/2	Inicial	2026-08-17	23.2	Moderado
AVR0649	ALU0649	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0650	ALU0650	2026/2	Inicial	2026-08-17	32.1	Moderado
AVR0651	ALU0651	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0652	ALU0652	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0653	ALU0653	2026/2	Inicial	2026-08-17	23.4	Moderado
AVR0654	ALU0654	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0655	ALU0655	2026/2	Inicial	2026-08-17	29.5	Moderado
AVR0656	ALU0656	2026/2	Inicial	2026-08-17	45.3	Alto
AVR0657	ALU0657	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0658	ALU0658	2026/2	Inicial	2026-08-17	29.7	Moderado
AVR0659	ALU0659	2026/2	Inicial	2026-08-17	15.5	Baixo
AVR0660	ALU0660	2026/2	Inicial	2026-08-17	26.2	Moderado
AVR0661	ALU0661	2026/2	Inicial	2026-08-17	28.7	Moderado
AVR0662	ALU0662	2026/2	Inicial	2026-08-17	29.6	Moderado
AVR0663	ALU0663	2026/2	Inicial	2026-08-17	26.2	Moderado
AVR0664	ALU0664	2026/2	Inicial	2026-08-17	21.7	Moderado
AVR0665	ALU0665	2026/2	Inicial	2026-08-17	24.8	Moderado
AVR0666	ALU0666	2026/2	Inicial	2026-08-17	19.8	Baixo
AVR0667	ALU0667	2026/2	Inicial	2026-08-17	10.5	Baixo
AVR0668	ALU0668	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0669	ALU0669	2026/2	Inicial	2026-08-17	24.3	Moderado
AVR0670	ALU0670	2026/2	Inicial	2026-08-17	22.0	Moderado
AVR0671	ALU0671	2026/2	Inicial	2026-08-17	27.1	Moderado
AVR0672	ALU0672	2026/2	Inicial	2026-08-17	28.2	Moderado
AVR0673	ALU0673	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0674	ALU0674	2026/2	Inicial	2026-08-17	14.6	Baixo
AVR0675	ALU0675	2026/2	Inicial	2026-08-17	31.1	Moderado
AVR0676	ALU0676	2026/2	Inicial	2026-08-17	15.8	Baixo
AVR0677	ALU0677	2026/2	Inicial	2026-08-17	28.5	Moderado
AVR0678	ALU0678	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0679	ALU0679	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0680	ALU0680	2026/2	Inicial	2026-08-17	33.3	Moderado
AVR0681	ALU0681	2026/2	Inicial	2026-08-17	36.0	Alto
AVR0682	ALU0682	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0683	ALU0683	2026/2	Inicial	2026-08-17	24.5	Moderado
AVR0684	ALU0684	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0685	ALU0685	2026/2	Inicial	2026-08-17	37.7	Alto
AVR0686	ALU0686	2026/2	Inicial	2026-08-17	30.2	Moderado
AVR0687	ALU0687	2026/2	Inicial	2026-08-17	32.6	Moderado
AVR0688	ALU0688	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0689	ALU0689	2026/2	Inicial	2026-08-17	34.8	Moderado
AVR0690	ALU0690	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0691	ALU0691	2026/2	Inicial	2026-08-17	56.7	Crítico
AVR0692	ALU0692	2026/2	Inicial	2026-08-17	47.0	Alto
AVR0693	ALU0693	2026/2	Inicial	2026-08-17	22.4	Moderado
AVR0694	ALU0694	2026/2	Inicial	2026-08-17	24.1	Moderado
AVR0695	ALU0695	2026/2	Inicial	2026-08-17	35.0	Alto
AVR0696	ALU0696	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0697	ALU0697	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0698	ALU0698	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0699	ALU0699	2026/2	Inicial	2026-08-17	32.3	Moderado
AVR0700	ALU0700	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0701	ALU0701	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0702	ALU0702	2026/2	Inicial	2026-08-17	20.9	Moderado
AVR0703	ALU0703	2026/2	Inicial	2026-08-17	34.9	Moderado
AVR0704	ALU0704	2026/2	Inicial	2026-08-17	43.0	Alto
AVR0705	ALU0705	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0706	ALU0706	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0707	ALU0707	2026/2	Inicial	2026-08-17	19.1	Baixo
AVR0708	ALU0708	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0709	ALU0709	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0710	ALU0710	2026/2	Inicial	2026-08-17	27.0	Moderado
AVR0711	ALU0711	2026/2	Inicial	2026-08-17	20.4	Moderado
AVR0712	ALU0712	2026/2	Inicial	2026-08-17	31.2	Moderado
AVR0713	ALU0713	2026/2	Inicial	2026-08-17	15.7	Baixo
AVR0714	ALU0714	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0715	ALU0715	2026/2	Inicial	2026-08-17	28.6	Moderado
AVR0716	ALU0716	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0717	ALU0717	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0718	ALU0718	2026/2	Inicial	2026-08-17	26.5	Moderado
AVR0719	ALU0719	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0720	ALU0720	2026/2	Inicial	2026-08-17	34.3	Moderado
AVR0721	ALU0721	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0722	ALU0722	2026/2	Inicial	2026-08-17	41.1	Alto
AVR0723	ALU0723	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0724	ALU0724	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0725	ALU0725	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0726	ALU0726	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0727	ALU0727	2026/2	Inicial	2026-08-17	66.6	Crítico
AVR0728	ALU0728	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0729	ALU0729	2026/2	Inicial	2026-08-17	11.6	Baixo
AVR0730	ALU0730	2026/2	Inicial	2026-08-17	20.9	Moderado
AVR0731	ALU0731	2026/2	Inicial	2026-08-17	26.0	Moderado
AVR0732	ALU0732	2026/2	Inicial	2026-08-17	28.2	Moderado
AVR0733	ALU0733	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0734	ALU0734	2026/2	Inicial	2026-08-17	25.2	Moderado
AVR0735	ALU0735	2026/2	Inicial	2026-08-17	28.8	Moderado
AVR0736	ALU0736	2026/2	Inicial	2026-08-17	35.5	Alto
AVR0737	ALU0737	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0738	ALU0738	2026/2	Inicial	2026-08-17	79.9	Crítico
AVR0739	ALU0739	2026/2	Inicial	2026-08-17	32.5	Moderado
AVR0740	ALU0740	2026/2	Inicial	2026-08-17	2.5	Baixo
AVR0741	ALU0741	2026/2	Inicial	2026-08-17	47.5	Alto
AVR0742	ALU0742	2026/2	Inicial	2026-08-17	11.5	Baixo
AVR0743	ALU0743	2026/2	Inicial	2026-08-17	32.9	Moderado
AVR0744	ALU0744	2026/2	Inicial	2026-08-17	14.5	Baixo
AVR0745	ALU0745	2026/2	Inicial	2026-08-17	36.0	Alto
AVR0746	ALU0746	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0747	ALU0747	2026/2	Inicial	2026-08-17	44.4	Alto
AVR0748	ALU0748	2026/2	Inicial	2026-08-17	64.6	Crítico
AVR0749	ALU0749	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0750	ALU0750	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0751	ALU0751	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0752	ALU0752	2026/2	Inicial	2026-08-17	22.0	Moderado
AVR0753	ALU0753	2026/2	Inicial	2026-08-17	24.5	Moderado
AVR0754	ALU0754	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0755	ALU0755	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0756	ALU0756	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0757	ALU0757	2026/2	Inicial	2026-08-17	34.5	Moderado
AVR0758	ALU0758	2026/2	Inicial	2026-08-17	41.2	Alto
AVR0759	ALU0759	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0760	ALU0760	2026/2	Inicial	2026-08-17	28.0	Moderado
AVR0761	ALU0761	2026/2	Inicial	2026-08-17	31.7	Moderado
AVR0762	ALU0762	2026/2	Inicial	2026-08-17	25.0	Moderado
AVR0763	ALU0763	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0764	ALU0764	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0765	ALU0765	2026/2	Inicial	2026-08-17	27.8	Moderado
AVR0766	ALU0766	2026/2	Inicial	2026-08-17	13.7	Baixo
AVR0767	ALU0767	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0768	ALU0768	2026/2	Inicial	2026-08-17	47.4	Alto
AVR0769	ALU0769	2026/2	Inicial	2026-08-17	29.5	Moderado
AVR0770	ALU0770	2026/2	Inicial	2026-08-17	68.2	Crítico
AVR0771	ALU0771	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0772	ALU0772	2026/2	Inicial	2026-08-17	42.0	Alto
AVR0773	ALU0773	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0774	ALU0774	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0775	ALU0775	2026/2	Inicial	2026-08-17	6.0	Baixo
AVR0776	ALU0776	2026/2	Inicial	2026-08-17	32.3	Moderado
AVR0777	ALU0777	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0778	ALU0778	2026/2	Inicial	2026-08-17	33.0	Moderado
AVR0779	ALU0779	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0780	ALU0780	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0781	ALU0781	2026/2	Inicial	2026-08-17	30.4	Moderado
AVR0782	ALU0782	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0783	ALU0783	2026/2	Inicial	2026-08-17	16.6	Baixo
AVR0784	ALU0784	2026/2	Inicial	2026-08-17	14.9	Baixo
AVR0785	ALU0785	2026/2	Inicial	2026-08-17	10.8	Baixo
AVR0786	ALU0786	2026/2	Inicial	2026-08-17	15.4	Baixo
AVR0787	ALU0787	2026/2	Inicial	2026-08-17	22.8	Moderado
AVR0788	ALU0788	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0789	ALU0789	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0790	ALU0790	2026/2	Inicial	2026-08-17	12.8	Baixo
AVR0791	ALU0791	2026/2	Inicial	2026-08-17	17.8	Baixo
AVR0792	ALU0792	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0793	ALU0793	2026/2	Inicial	2026-08-17	27.7	Moderado
AVR0794	ALU0794	2026/2	Inicial	2026-08-17	20.3	Moderado
AVR0795	ALU0795	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0796	ALU0796	2026/2	Inicial	2026-08-17	23.0	Moderado
AVR0797	ALU0797	2026/2	Inicial	2026-08-17	18.2	Baixo
AVR0798	ALU0798	2026/2	Inicial	2026-08-17	23.6	Moderado
AVR0799	ALU0799	2026/2	Inicial	2026-08-17	32.4	Moderado
AVR0800	ALU0800	2026/2	Inicial	2026-08-17	17.1	Baixo
AVR0801	ALU0801	2026/2	Inicial	2026-08-17	33.8	Moderado
AVR0802	ALU0802	2026/2	Inicial	2026-08-17	21.2	Moderado
AVR0803	ALU0803	2026/2	Inicial	2026-08-17	40.6	Alto
AVR0804	ALU0804	2026/2	Inicial	2026-08-17	25.4	Moderado
AVR0805	ALU0805	2026/2	Inicial	2026-08-17	22.0	Moderado
AVR0806	ALU0806	2026/2	Inicial	2026-08-17	37.6	Alto
AVR0807	ALU0807	2026/2	Inicial	2026-08-17	44.1	Alto
AVR0808	ALU0808	2026/2	Inicial	2026-08-17	29.8	Moderado
AVR0809	ALU0809	2026/2	Inicial	2026-08-17	38.5	Alto
AVR0810	ALU0810	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0811	ALU0811	2026/2	Inicial	2026-08-17	41.3	Alto
AVR0812	ALU0812	2026/2	Inicial	2026-08-17	21.4	Moderado
AVR0813	ALU0813	2026/2	Inicial	2026-08-17	44.5	Alto
AVR0814	ALU0814	2026/2	Inicial	2026-08-17	22.7	Moderado
AVR0815	ALU0815	2026/2	Inicial	2026-08-17	37.1	Alto
AVR0816	ALU0816	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0817	ALU0817	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0818	ALU0818	2026/2	Inicial	2026-08-17	30.0	Moderado
AVR0819	ALU0819	2026/2	Inicial	2026-08-17	24.0	Moderado
AVR0820	ALU0820	2026/2	Inicial	2026-08-17	26.5	Moderado
AVR0821	ALU0821	2026/2	Inicial	2026-08-17	32.9	Moderado
AVR0822	ALU0822	2026/2	Inicial	2026-08-17	47.2	Alto
AVR0823	ALU0823	2026/2	Inicial	2026-08-17	10.8	Baixo
AVR0824	ALU0824	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0825	ALU0825	2026/2	Inicial	2026-08-17	12.0	Baixo
AVR0826	ALU0826	2026/2	Inicial	2026-08-17	25.0	Moderado
AVR0827	ALU0827	2026/2	Inicial	2026-08-17	30.9	Moderado
AVR0828	ALU0828	2026/2	Inicial	2026-08-17	17.3	Baixo
AVR0829	ALU0829	2026/2	Inicial	2026-08-17	18.3	Baixo
AVR0830	ALU0830	2026/2	Inicial	2026-08-17	23.2	Moderado
AVR0831	ALU0831	2026/2	Inicial	2026-08-17	19.1	Baixo
AVR0832	ALU0832	2026/2	Inicial	2026-08-17	13.3	Baixo
AVR0833	ALU0833	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0834	ALU0834	2026/2	Inicial	2026-08-17	29.9	Moderado
AVR0835	ALU0835	2026/2	Inicial	2026-08-17	24.8	Moderado
AVR0836	ALU0836	2026/2	Inicial	2026-08-17	36.4	Alto
AVR0837	ALU0837	2026/2	Inicial	2026-08-17	25.1	Moderado
AVR0838	ALU0838	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0839	ALU0839	2026/2	Inicial	2026-08-17	25.3	Moderado
AVR0840	ALU0840	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0841	ALU0841	2026/2	Inicial	2026-08-17	40.2	Alto
AVR0842	ALU0842	2026/2	Inicial	2026-08-17	34.5	Moderado
AVR0843	ALU0843	2026/2	Inicial	2026-08-17	45.5	Alto
AVR0844	ALU0844	2026/2	Inicial	2026-08-17	56.3	Crítico
AVR0845	ALU0845	2026/2	Inicial	2026-08-17	17.7	Baixo
AVR0846	ALU0846	2026/2	Inicial	2026-08-17	38.1	Alto
AVR0847	ALU0847	2026/2	Inicial	2026-08-17	46.3	Alto
AVR0848	ALU0848	2026/2	Inicial	2026-08-17	27.0	Moderado
AVR0849	ALU0849	2026/2	Inicial	2026-08-17	20.8	Moderado
AVR0850	ALU0850	2026/2	Inicial	2026-08-17	12.2	Baixo
AVR0851	ALU0851	2026/2	Inicial	2026-08-17	26.4	Moderado
AVR0852	ALU0852	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0853	ALU0853	2026/2	Inicial	2026-08-17	35.4	Alto
AVR0854	ALU0854	2026/2	Inicial	2026-08-17	17.5	Baixo
AVR0855	ALU0855	2026/2	Inicial	2026-08-17	32.9	Moderado
AVR0856	ALU0856	2026/2	Inicial	2026-08-17	32.5	Moderado
AVR0857	ALU0857	2026/2	Inicial	2026-08-17	18.0	Baixo
AVR0858	ALU0858	2026/2	Inicial	2026-08-17	43.8	Alto
AVR0859	ALU0859	2026/2	Inicial	2026-08-17	44.5	Alto
AVR0860	ALU0860	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0861	ALU0861	2026/2	Inicial	2026-08-17	37.1	Alto
AVR0862	ALU0862	2026/2	Inicial	2026-08-17	33.1	Moderado
AVR0863	ALU0863	2026/2	Inicial	2026-08-17	62.9	Crítico
AVR0864	ALU0864	2026/2	Inicial	2026-08-17	12.5	Baixo
AVR0865	ALU0865	2026/2	Inicial	2026-08-17	9.8	Baixo
AVR0866	ALU0866	2026/2	Inicial	2026-08-17	72.2	Crítico
AVR0867	ALU0867	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0868	ALU0868	2026/2	Inicial	2026-08-17	19.5	Baixo
AVR0869	ALU0869	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0870	ALU0870	2026/2	Inicial	2026-08-17	28.0	Moderado
AVR0871	ALU0871	2026/2	Inicial	2026-08-17	8.5	Baixo
AVR0872	ALU0872	2026/2	Inicial	2026-08-17	39.8	Alto
AVR0873	ALU0873	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0874	ALU0874	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0875	ALU0875	2026/2	Inicial	2026-08-17	8.5	Baixo
AVR0876	ALU0876	2026/2	Inicial	2026-08-17	24.4	Moderado
AVR0877	ALU0877	2026/2	Inicial	2026-08-17	11.6	Baixo
AVR0878	ALU0878	2026/2	Inicial	2026-08-17	43.0	Alto
AVR0879	ALU0879	2026/2	Inicial	2026-08-17	20.0	Moderado
AVR0880	ALU0880	2026/2	Inicial	2026-08-17	15.1	Baixo
AVR0881	ALU0881	2026/2	Inicial	2026-08-17	26.0	Moderado
AVR0882	ALU0882	2026/2	Inicial	2026-08-17	53.5	Alto
AVR0883	ALU0883	2026/2	Inicial	2026-08-17	21.2	Moderado
AVR0884	ALU0884	2026/2	Inicial	2026-08-17	25.8	Moderado
AVR0885	ALU0885	2026/2	Inicial	2026-08-17	19.9	Baixo
AVR0886	ALU0886	2026/2	Inicial	2026-08-17	25.6	Moderado
AVR0887	ALU0887	2026/2	Inicial	2026-08-17	16.2	Baixo
AVR0888	ALU0888	2026/2	Inicial	2026-08-17	45.0	Alto
AVR0889	ALU0889	2026/2	Inicial	2026-08-17	35.8	Alto
AVR0890	ALU0890	2026/2	Inicial	2026-08-17	16.2	Baixo
AVR0891	ALU0891	2026/2	Inicial	2026-08-17	26.0	Moderado
AVR0892	ALU0892	2026/2	Inicial	2026-08-17	26.2	Moderado
AVR0893	ALU0893	2026/2	Inicial	2026-08-17	32.2	Moderado
AVR0894	ALU0894	2026/2	Inicial	2026-08-17	17.2	Baixo
AVR0895	ALU0895	2026/2	Inicial	2026-08-17	17.1	Baixo
AVR0896	ALU0896	2026/2	Inicial	2026-08-17	20.1	Moderado
AVR0897	ALU0897	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0898	ALU0898	2026/2	Inicial	2026-08-17	20.5	Moderado
AVR0899	ALU0899	2026/2	Inicial	2026-08-17	41.1	Alto
AVR0900	ALU0900	2026/2	Inicial	2026-08-17	19.4	Baixo
AVR0901	ALU0901	2026/2	Inicial	2026-08-17	25.6	Moderado
AVR0902	ALU0902	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0903	ALU0903	2026/2	Inicial	2026-08-17	53.3	Alto
AVR0904	ALU0904	2026/2	Inicial	2026-08-17	34.2	Moderado
AVR0905	ALU0905	2026/2	Inicial	2026-08-17	33.2	Moderado
AVR0906	ALU0906	2026/2	Inicial	2026-08-17	17.2	Baixo
AVR0907	ALU0907	2026/2	Inicial	2026-08-17	38.2	Alto
AVR0908	ALU0908	2026/2	Inicial	2026-08-17	19.9	Baixo
AVR0909	ALU0909	2026/2	Inicial	2026-08-17	26.4	Moderado
AVR0910	ALU0910	2026/2	Inicial	2026-08-17	11.6	Baixo
AVR0911	ALU0911	2026/2	Inicial	2026-08-17	15.5	Baixo
AVR0912	ALU0912	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0913	ALU0913	2026/2	Inicial	2026-08-17	21.3	Moderado
AVR0914	ALU0914	2026/2	Inicial	2026-08-17	16.5	Baixo
AVR0915	ALU0915	2026/2	Inicial	2026-08-17	48.4	Alto
AVR0916	ALU0916	2026/2	Inicial	2026-08-17	33.5	Moderado
AVR0917	ALU0917	2026/2	Inicial	2026-08-17	21.5	Moderado
AVR0918	ALU0918	2026/2	Inicial	2026-08-17	26.5	Moderado
AVR0919	ALU0919	2026/2	Inicial	2026-08-17	44.0	Alto
AVR0920	ALU0920	2026/2	Inicial	2026-08-17	24.0	Moderado
AVR0921	ALU0921	2026/2	Inicial	2026-08-17	20.8	Moderado
AVR0922	ALU0922	2026/2	Inicial	2026-08-17	21.0	Moderado
AVR0923	ALU0923	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0924	ALU0924	2026/2	Inicial	2026-08-17	7.8	Baixo
AVR0925	ALU0925	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0926	ALU0926	2026/2	Inicial	2026-08-17	41.8	Alto
AVR0927	ALU0927	2026/2	Inicial	2026-08-17	14.4	Baixo
AVR0928	ALU0928	2026/2	Inicial	2026-08-17	13.4	Baixo
AVR0929	ALU0929	2026/2	Inicial	2026-08-17	12.8	Baixo
AVR0930	ALU0930	2026/2	Inicial	2026-08-17	40.8	Alto
AVR0931	ALU0931	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0932	ALU0932	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0933	ALU0933	2026/2	Inicial	2026-08-17	13.9	Baixo
AVR0934	ALU0934	2026/2	Inicial	2026-08-17	36.7	Alto
AVR0935	ALU0935	2026/2	Inicial	2026-08-17	43.6	Alto
AVR0936	ALU0936	2026/2	Inicial	2026-08-17	29.0	Moderado
AVR0937	ALU0937	2026/2	Inicial	2026-08-17	24.7	Moderado
AVR0938	ALU0938	2026/2	Inicial	2026-08-17	19.7	Baixo
AVR0939	ALU0939	2026/2	Inicial	2026-08-17	18.5	Baixo
AVR0940	ALU0940	2026/2	Inicial	2026-08-17	25.7	Moderado
AVR0941	ALU0941	2026/2	Inicial	2026-08-17	22.8	Moderado
AVR0942	ALU0942	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0943	ALU0943	2026/2	Inicial	2026-08-17	21.9	Moderado
AVR0944	ALU0944	2026/2	Inicial	2026-08-17	53.1	Alto
AVR0945	ALU0945	2026/2	Inicial	2026-08-17	13.9	Baixo
AVR0946	ALU0946	2026/2	Inicial	2026-08-17	38.5	Alto
AVR0947	ALU0947	2026/2	Inicial	2026-08-17	40.0	Alto
AVR0948	ALU0948	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0949	ALU0949	2026/2	Inicial	2026-08-17	52.9	Alto
AVR0950	ALU0950	2026/2	Inicial	2026-08-17	28.9	Moderado
AVR0951	ALU0951	2026/2	Inicial	2026-08-17	28.9	Moderado
AVR0952	ALU0952	2026/2	Inicial	2026-08-17	22.5	Moderado
AVR0953	ALU0953	2026/2	Inicial	2026-08-17	7.1	Baixo
AVR0954	ALU0954	2026/2	Inicial	2026-08-17	21.9	Moderado
AVR0955	ALU0955	2026/2	Inicial	2026-08-17	15.0	Baixo
AVR0956	ALU0956	2026/2	Inicial	2026-08-17	32.2	Moderado
AVR0957	ALU0957	2026/2	Inicial	2026-08-17	12.3	Baixo
AVR0958	ALU0958	2026/2	Inicial	2026-08-17	23.5	Moderado
AVR0959	ALU0959	2026/2	Inicial	2026-08-17	13.0	Baixo
AVR0960	ALU0960	2026/2	Inicial	2026-08-17	14.8	Baixo
AVR0961	ALU0961	2026/2	Inicial	2026-08-17	30.4	Moderado
AVR0962	ALU0962	2026/2	Inicial	2026-08-17	25.8	Moderado
AVR0963	ALU0963	2026/2	Inicial	2026-08-17	5.0	Baixo
AVR0964	ALU0964	2026/2	Inicial	2026-08-17	14.0	Baixo
AVR0965	ALU0965	2026/2	Inicial	2026-08-17	19.6	Baixo
AVR0966	ALU0966	2026/2	Inicial	2026-08-17	36.5	Alto
AVR0967	ALU0967	2026/2	Inicial	2026-08-17	11.8	Baixo
AVR0968	ALU0968	2026/2	Inicial	2026-08-17	32.0	Moderado
AVR0969	ALU0969	2026/2	Inicial	2026-08-17	15.4	Baixo
AVR0970	ALU0970	2026/2	Inicial	2026-08-17	28.3	Moderado
AVR0971	ALU0971	2026/2	Inicial	2026-08-17	26.4	Moderado
AVR0972	ALU0972	2026/2	Inicial	2026-08-17	18.7	Baixo
AVR0973	ALU0973	2026/2	Inicial	2026-08-17	16.3	Baixo
AVR0974	ALU0974	2026/2	Inicial	2026-08-17	20.7	Moderado
AVR0975	ALU0975	2026/2	Inicial	2026-08-17	22.7	Moderado
AVR0976	ALU0976	2026/2	Inicial	2026-08-17	40.5	Alto
AVR0977	ALU0977	2026/2	Inicial	2026-08-17	42.9	Alto
AVR0978	ALU0978	2026/2	Inicial	2026-08-17	16.7	Baixo
AVR0979	ALU0979	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0980	ALU0980	2026/2	Inicial	2026-08-17	27.5	Moderado
AVR0981	ALU0981	2026/2	Inicial	2026-08-17	35.1	Alto
AVR0982	ALU0982	2026/2	Inicial	2026-08-17	21.4	Moderado
AVR0983	ALU0983	2026/2	Inicial	2026-08-17	10.0	Baixo
AVR0984	ALU0984	2026/2	Inicial	2026-08-17	16.0	Baixo
AVR0985	ALU0985	2026/2	Inicial	2026-08-17	4.0	Baixo
AVR0986	ALU0986	2026/2	Inicial	2026-08-17	35.2	Alto
AVR0987	ALU0987	2026/2	Inicial	2026-08-17	28.7	Moderado
AVR0988	ALU0988	2026/2	Inicial	2026-08-17	32.0	Moderado
AVR0989	ALU0989	2026/2	Inicial	2026-08-17	22.2	Moderado
AVR0990	ALU0990	2026/2	Inicial	2026-08-17	37.9	Alto
AVR0991	ALU0991	2026/2	Inicial	2026-08-17	17.8	Baixo
AVR0992	ALU0992	2026/2	Inicial	2026-08-17	24.0	Moderado
AVR0993	ALU0993	2026/2	Inicial	2026-08-17	22.9	Moderado
AVR0994	ALU0994	2026/2	Inicial	2026-08-17	35.6	Alto
AVR0995	ALU0995	2026/2	Inicial	2026-08-17	19.0	Baixo
AVR0996	ALU0996	2026/2	Inicial	2026-08-17	20.8	Moderado
AVR0997	ALU0997	2026/2	Inicial	2026-08-17	20.2	Moderado
AVR0998	ALU0998	2026/2	Inicial	2026-08-17	22.2	Moderado
AVR0999	ALU0999	2026/2	Inicial	2026-08-17	28.9	Moderado
AVR1000	ALU1000	2026/2	Inicial	2026-08-17	14.5	Baixo
\.


--
-- TOC entry 4918 (class 0 OID 16664)
-- Dependencies: 216
-- Data for Name: cursos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cursos (id_curso, id_universidade, nome, grau, duracao_semestres, media_aprovacao, frequencia_minima_pct) FROM stdin;
CUR01	UNI01	Inteligência Artificial	Bacharelado	8	6	75
\.


--
-- TOC entry 4924 (class 0 OID 16694)
-- Dependencies: 222
-- Data for Name: indicadores_academicos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.indicadores_academicos (id_aluno, periodo_letivo, faltas_total, frequencia_pct, disciplinas_reprovadas_historico, atividades_pendentes, media_semestre_anterior, media_atual, tendencia_media) FROM stdin;
ALU0001	2026/2	5	72	0	2	6.9	7.7	0.8
ALU0002	2026/2	6	69	0	4	2.8	2.9	0.1
ALU0003	2026/2	1	93	0	0	5.4	6.7	1.3
ALU0004	2026/2	2	87	0	0	6.6	5.9	-0.7
ALU0005	2026/2	5	73	0	2	5.7	6.5	0.8
ALU0006	2026/2	3	85	0	0	6.6	5.6	-1.0
ALU0007	2026/2	4	75	0	0	6.9	7.2	0.3
ALU0008	2026/2	4	77	0	1	4.8	6.9	2.1
ALU0009	2026/2	7	60	0	1	5.7	4.0	-1.7
ALU0010	2026/2	0	100	1	0	5.8	6.1	0.3
ALU0011	2026/2	2	88	0	0	6.0	5.9	-0.1
ALU0012	2026/2	7	61	0	1	5.8	5.1	-0.7
ALU0013	2026/2	4	76	0	0	7.8	8.2	0.4
ALU0014	2026/2	1	92	0	2	5.6	5.9	0.3
ALU0015	2026/2	3	83	0	0	7.3	6.3	-1.0
ALU0016	2026/2	4	76	0	0	5.2	7.5	2.3
ALU0017	2026/2	3	85	0	2	8.0	8.0	0.0
ALU0018	2026/2	3	82	0	2	7.1	6.4	-0.7
ALU0019	2026/2	3	86	0	1	4.5	5.5	1.0
ALU0020	2026/2	4	78	0	1	4.3	6.9	2.6
ALU0021	2026/2	3	85	0	1	7.6	7.3	-0.3
ALU0022	2026/2	3	84	0	0	6.1	6.4	0.3
ALU0023	2026/2	1	97	0	3	8.3	7.2	-1.1
ALU0024	2026/2	3	86	0	0	8.4	7.4	-1.0
ALU0025	2026/2	6	68	0	2	5.1	3.6	-1.5
ALU0026	2026/2	4	77	0	0	8.8	7.0	-1.8
ALU0027	2026/2	1	95	1	2	5.5	7.2	1.7
ALU0028	2026/2	4	77	0	2	3.1	5.0	1.9
ALU0029	2026/2	2	91	2	3	6.4	7.5	1.1
ALU0030	2026/2	4	78	0	2	5.5	6.4	0.9
ALU0031	2026/2	3	84	0	0	6.4	7.1	0.7
ALU0032	2026/2	6	67	0	0	3.7	3.6	-0.1
ALU0033	2026/2	2	89	0	1	9.3	9.5	0.2
ALU0034	2026/2	6	64	0	2	4.9	5.5	0.6
ALU0035	2026/2	4	79	1	3	6.7	8.7	2.0
ALU0036	2026/2	2	88	1	3	7.4	7.8	0.4
ALU0037	2026/2	2	90	0	0	6.6	7.0	0.4
ALU0038	2026/2	3	83	0	2	6.6	6.6	0.0
ALU0039	2026/2	3	84	0	1	7.4	7.2	-0.2
ALU0040	2026/2	2	89	1	0	8.6	7.4	-1.2
ALU0041	2026/2	4	77	2	1	9.1	8.1	-1.0
ALU0042	2026/2	2	90	0	0	6.5	6.0	-0.5
ALU0043	2026/2	1	97	1	1	4.5	5.1	0.6
ALU0044	2026/2	2	90	0	0	5.1	6.6	1.5
ALU0045	2026/2	5	71	0	0	6.3	6.2	-0.1
ALU0046	2026/2	3	84	0	1	6.3	5.6	-0.7
ALU0047	2026/2	2	87	0	1	9.2	6.0	-3.2
ALU0048	2026/2	1	92	0	0	7.6	6.9	-0.7
ALU0049	2026/2	3	83	0	1	6.1	7.8	1.7
ALU0050	2026/2	1	93	1	3	6.9	7.2	0.3
ALU0051	2026/2	0	100	0	0	9.1	7.7	-1.4
ALU0052	2026/2	3	81	0	0	5.5	5.8	0.3
ALU0053	2026/2	1	92	0	3	6.0	6.0	0.0
ALU0054	2026/2	2	90	0	2	7.8	7.0	-0.8
ALU0055	2026/2	3	81	0	3	4.5	5.2	0.7
ALU0056	2026/2	1	92	0	0	8.3	8.2	-0.1
ALU0057	2026/2	8	55	0	1	5.4	4.3	-1.1
ALU0058	2026/2	2	87	0	2	6.3	7.4	1.1
ALU0059	2026/2	1	94	0	1	7.1	7.0	-0.1
ALU0060	2026/2	7	59	0	2	3.8	4.2	0.4
ALU0061	2026/2	4	75	0	0	10.0	8.5	-1.5
ALU0062	2026/2	6	67	0	1	6.2	5.9	-0.3
ALU0063	2026/2	7	61	0	1	4.0	5.5	1.5
ALU0064	2026/2	4	77	0	1	4.9	4.1	-0.8
ALU0065	2026/2	5	74	0	0	8.0	9.1	1.1
ALU0066	2026/2	3	85	0	0	5.7	6.6	0.9
ALU0067	2026/2	1	92	0	1	7.4	6.2	-1.2
ALU0068	2026/2	6	65	0	0	6.6	6.8	0.2
ALU0069	2026/2	0	98	1	1	7.6	7.6	0.0
ALU0070	2026/2	2	87	1	0	5.9	6.5	0.6
ALU0071	2026/2	7	61	1	2	8.1	7.5	-0.6
ALU0072	2026/2	3	86	0	4	7.6	5.6	-2.0
ALU0073	2026/2	4	80	0	1	8.0	7.7	-0.3
ALU0074	2026/2	4	80	0	2	7.2	7.1	-0.1
ALU0075	2026/2	5	71	0	1	5.2	5.0	-0.2
ALU0076	2026/2	4	77	1	3	7.1	6.9	-0.2
ALU0077	2026/2	5	74	0	2	3.4	4.8	1.4
ALU0078	2026/2	2	89	1	1	7.9	6.4	-1.5
ALU0079	2026/2	6	69	0	1	9.2	9.7	0.5
ALU0080	2026/2	4	78	0	2	5.2	5.3	0.1
ALU0081	2026/2	2	90	1	2	8.0	6.5	-1.5
ALU0082	2026/2	3	86	0	0	7.0	7.7	0.7
ALU0083	2026/2	0	100	0	0	5.0	6.7	1.7
ALU0084	2026/2	4	75	0	2	7.0	6.1	-0.9
ALU0085	2026/2	4	77	1	0	8.4	8.5	0.1
ALU0086	2026/2	2	87	0	1	8.6	7.8	-0.8
ALU0087	2026/2	2	89	0	1	7.2	7.0	-0.2
ALU0088	2026/2	0	100	0	2	9.4	8.9	-0.5
ALU0089	2026/2	3	84	0	1	4.9	5.2	0.3
ALU0090	2026/2	3	82	0	2	5.7	5.8	0.1
ALU0091	2026/2	1	95	0	2	4.1	5.9	1.8
ALU0092	2026/2	4	78	0	0	5.5	6.9	1.4
ALU0093	2026/2	1	95	0	2	4.8	6.4	1.6
ALU0094	2026/2	0	100	1	1	7.2	7.0	-0.2
ALU0095	2026/2	4	77	0	1	9.0	7.9	-1.1
ALU0096	2026/2	4	80	0	1	7.3	7.2	-0.1
ALU0097	2026/2	3	82	0	1	5.7	7.2	1.5
ALU0098	2026/2	7	62	0	2	6.4	6.1	-0.3
ALU0099	2026/2	9	51	0	3	3.7	2.9	-0.8
ALU0100	2026/2	4	79	1	0	7.5	5.6	-1.9
ALU0101	2026/2	1	93	0	1	8.4	7.3	-1.1
ALU0102	2026/2	4	75	0	1	6.0	6.4	0.4
ALU0103	2026/2	3	86	0	1	5.3	5.5	0.2
ALU0104	2026/2	1	96	1	0	4.6	5.8	1.2
ALU0105	2026/2	4	77	0	0	5.4	5.3	-0.1
ALU0106	2026/2	2	91	0	2	6.6	7.5	0.9
ALU0107	2026/2	6	68	0	4	5.5	6.0	0.5
ALU0108	2026/2	4	78	0	2	6.1	5.3	-0.8
ALU0109	2026/2	1	97	1	0	6.1	6.2	0.1
ALU0110	2026/2	1	95	0	2	6.1	6.9	0.8
ALU0111	2026/2	3	83	1	0	6.0	6.1	0.1
ALU0112	2026/2	3	86	0	3	6.6	6.3	-0.3
ALU0113	2026/2	0	98	0	0	7.5	6.5	-1.0
ALU0114	2026/2	4	80	0	4	5.3	6.2	0.9
ALU0115	2026/2	3	86	0	2	5.5	5.5	0.0
ALU0116	2026/2	7	62	1	3	8.0	4.5	-3.5
ALU0117	2026/2	3	82	0	2	6.7	7.8	1.1
ALU0118	2026/2	4	79	0	0	4.8	6.4	1.6
ALU0119	2026/2	1	93	0	0	7.9	8.2	0.3
ALU0120	2026/2	5	72	1	1	5.7	5.0	-0.7
ALU0121	2026/2	5	73	0	0	7.8	6.9	-0.9
ALU0122	2026/2	0	98	0	3	5.7	7.0	1.3
ALU0123	2026/2	4	76	0	0	5.8	6.1	0.3
ALU0124	2026/2	2	91	0	0	7.6	7.9	0.3
ALU0125	2026/2	3	86	0	0	7.0	6.6	-0.4
ALU0126	2026/2	2	91	0	1	7.5	7.7	0.2
ALU0127	2026/2	4	76	0	0	5.7	5.6	-0.1
ALU0128	2026/2	0	99	1	0	7.1	6.3	-0.8
ALU0129	2026/2	4	78	0	0	7.8	6.3	-1.5
ALU0130	2026/2	5	74	0	1	6.0	4.9	-1.1
ALU0131	2026/2	4	79	0	0	6.2	6.3	0.1
ALU0132	2026/2	2	87	0	1	8.2	7.3	-0.9
ALU0133	2026/2	2	87	1	1	6.5	6.4	-0.1
ALU0134	2026/2	2	87	0	1	7.4	6.6	-0.8
ALU0135	2026/2	4	75	0	0	6.3	5.7	-0.6
ALU0136	2026/2	0	98	0	0	7.5	7.9	0.4
ALU0137	2026/2	2	88	0	1	7.9	6.7	-1.2
ALU0138	2026/2	3	83	0	1	7.5	7.8	0.3
ALU0139	2026/2	2	87	0	2	6.3	6.4	0.1
ALU0140	2026/2	2	89	0	1	6.3	7.2	0.9
ALU0141	2026/2	5	71	0	3	8.2	7.5	-0.7
ALU0142	2026/2	0	98	0	0	9.2	8.9	-0.3
ALU0143	2026/2	2	91	0	2	7.1	7.4	0.3
ALU0144	2026/2	4	75	1	0	6.6	6.0	-0.6
ALU0145	2026/2	6	65	0	3	4.0	5.2	1.2
ALU0146	2026/2	6	68	0	0	6.7	6.3	-0.4
ALU0147	2026/2	3	83	0	1	7.5	6.8	-0.7
ALU0148	2026/2	3	85	1	1	6.5	6.2	-0.3
ALU0149	2026/2	1	92	0	1	9.8	7.9	-1.9
ALU0150	2026/2	1	93	0	2	6.5	5.2	-1.3
ALU0151	2026/2	1	92	2	0	6.2	4.5	-1.7
ALU0152	2026/2	3	84	0	2	4.4	5.8	1.4
ALU0153	2026/2	4	79	0	1	5.8	6.1	0.3
ALU0154	2026/2	2	88	0	0	8.0	7.8	-0.2
ALU0155	2026/2	7	60	2	2	3.8	4.6	0.8
ALU0156	2026/2	3	85	1	4	7.5	5.6	-1.9
ALU0157	2026/2	3	81	2	2	4.5	5.2	0.7
ALU0158	2026/2	3	82	0	2	6.1	6.5	0.4
ALU0159	2026/2	1	93	0	1	10.0	9.9	-0.1
ALU0160	2026/2	3	81	2	1	7.3	6.3	-1.0
ALU0161	2026/2	3	85	0	0	5.5	7.0	1.5
ALU0162	2026/2	3	82	0	0	6.4	6.6	0.2
ALU0163	2026/2	0	100	0	1	7.9	6.5	-1.4
ALU0164	2026/2	2	88	0	2	6.6	7.0	0.4
ALU0165	2026/2	0	100	0	1	8.0	7.9	-0.1
ALU0166	2026/2	5	73	1	2	7.0	6.6	-0.4
ALU0167	2026/2	3	83	1	0	5.4	7.9	2.5
ALU0168	2026/2	3	86	1	3	4.4	5.9	1.5
ALU0169	2026/2	2	90	0	1	5.3	7.4	2.1
ALU0170	2026/2	4	79	0	1	8.9	7.0	-1.9
ALU0171	2026/2	4	78	0	2	7.8	6.2	-1.6
ALU0172	2026/2	2	88	0	1	5.5	5.9	0.4
ALU0173	2026/2	3	85	0	2	5.7	6.7	1.0
ALU0174	2026/2	4	80	0	3	6.0	5.7	-0.3
ALU0175	2026/2	3	85	0	0	6.0	6.3	0.3
ALU0176	2026/2	2	90	0	1	7.8	6.9	-0.9
ALU0177	2026/2	4	78	2	2	8.6	7.8	-0.8
ALU0178	2026/2	2	91	0	1	5.6	5.8	0.2
ALU0179	2026/2	4	78	0	2	10.0	7.4	-2.6
ALU0180	2026/2	3	86	0	0	7.3	6.8	-0.5
ALU0181	2026/2	1	92	0	5	7.8	6.7	-1.1
ALU0182	2026/2	2	89	0	2	7.1	6.6	-0.5
ALU0183	2026/2	3	81	0	1	6.4	7.2	0.8
ALU0184	2026/2	1	97	0	1	8.8	9.4	0.6
ALU0185	2026/2	4	80	2	3	5.7	5.0	-0.7
ALU0186	2026/2	2	90	0	1	7.6	6.3	-1.3
ALU0187	2026/2	3	84	0	1	7.2	6.1	-1.1
ALU0188	2026/2	4	80	0	1	7.4	6.9	-0.5
ALU0189	2026/2	4	80	0	0	4.7	5.9	1.2
ALU0190	2026/2	3	84	1	4	7.1	6.9	-0.2
ALU0191	2026/2	4	76	0	1	9.1	7.8	-1.3
ALU0192	2026/2	4	78	0	1	9.2	8.3	-0.9
ALU0193	2026/2	2	91	1	2	7.9	7.9	0.0
ALU0194	2026/2	2	89	0	1	6.7	7.2	0.5
ALU0195	2026/2	4	80	0	0	7.5	6.0	-1.5
ALU0196	2026/2	1	92	0	1	5.4	5.3	-0.1
ALU0197	2026/2	3	86	0	2	6.7	6.1	-0.6
ALU0198	2026/2	0	100	0	2	7.5	7.6	0.1
ALU0199	2026/2	4	77	1	2	9.1	7.6	-1.5
ALU0200	2026/2	3	81	0	3	6.5	5.4	-1.1
ALU0201	2026/2	5	70	2	4	2.6	3.1	0.5
ALU0202	2026/2	4	79	0	1	4.2	5.1	0.9
ALU0203	2026/2	0	100	0	1	7.1	8.4	1.3
ALU0204	2026/2	3	84	1	0	7.9	7.3	-0.6
ALU0205	2026/2	3	85	0	0	7.9	8.1	0.2
ALU0206	2026/2	0	99	1	1	8.5	8.9	0.4
ALU0207	2026/2	4	79	0	0	5.6	6.2	0.6
ALU0208	2026/2	5	73	2	2	5.7	5.9	0.2
ALU0209	2026/2	0	99	0	1	6.4	6.0	-0.4
ALU0210	2026/2	0	99	0	0	6.3	7.1	0.8
ALU0211	2026/2	1	95	0	3	8.9	7.5	-1.4
ALU0212	2026/2	2	88	1	3	5.6	6.7	1.1
ALU0213	2026/2	3	81	0	0	8.0	6.5	-1.5
ALU0214	2026/2	5	74	0	1	4.5	4.4	-0.1
ALU0215	2026/2	3	85	0	1	6.9	5.3	-1.6
ALU0216	2026/2	3	82	0	1	8.1	7.2	-0.9
ALU0217	2026/2	2	91	0	1	7.0	8.6	1.6
ALU0218	2026/2	7	63	0	4	6.9	8.4	1.5
ALU0219	2026/2	3	82	0	0	6.3	6.2	-0.1
ALU0220	2026/2	1	94	0	1	5.8	4.8	-1.0
ALU0221	2026/2	0	99	2	0	5.2	6.5	1.3
ALU0222	2026/2	4	77	1	0	7.9	7.7	-0.2
ALU0223	2026/2	4	80	0	0	6.7	7.6	0.9
ALU0224	2026/2	3	84	1	2	9.6	7.6	-2.0
ALU0225	2026/2	3	86	0	1	9.7	5.9	-3.8
ALU0226	2026/2	3	86	0	0	7.0	6.8	-0.2
ALU0227	2026/2	4	76	0	0	7.2	8.0	0.8
ALU0228	2026/2	3	85	1	0	5.0	7.0	2.0
ALU0229	2026/2	0	100	0	0	7.1	7.1	0.0
ALU0230	2026/2	4	79	0	1	7.5	7.3	-0.2
ALU0231	2026/2	4	76	0	0	5.5	6.1	0.6
ALU0232	2026/2	5	71	0	2	6.9	5.8	-1.1
ALU0233	2026/2	4	76	0	1	4.4	5.1	0.7
ALU0234	2026/2	3	81	0	2	7.7	7.9	0.2
ALU0235	2026/2	6	69	0	1	5.4	5.6	0.2
ALU0236	2026/2	4	75	1	2	6.5	6.8	0.3
ALU0237	2026/2	1	93	1	1	8.2	7.7	-0.5
ALU0238	2026/2	3	83	0	3	8.0	5.8	-2.2
ALU0239	2026/2	3	82	0	1	7.5	5.9	-1.6
ALU0240	2026/2	1	93	0	1	7.6	8.4	0.8
ALU0241	2026/2	6	66	1	2	5.8	5.5	-0.3
ALU0242	2026/2	5	72	0	3	4.7	5.4	0.7
ALU0243	2026/2	2	88	0	1	8.2	5.9	-2.3
ALU0244	2026/2	1	92	0	0	7.1	7.0	-0.1
ALU0245	2026/2	0	98	1	1	8.0	8.0	0.0
ALU0246	2026/2	4	78	0	1	8.2	7.0	-1.2
ALU0247	2026/2	3	82	0	0	5.4	7.1	1.7
ALU0248	2026/2	5	74	0	0	5.2	5.6	0.4
ALU0249	2026/2	4	75	1	0	4.8	5.6	0.8
ALU0250	2026/2	1	97	0	1	7.3	5.9	-1.4
ALU0251	2026/2	3	85	0	1	9.2	6.6	-2.6
ALU0252	2026/2	4	75	0	0	4.5	5.2	0.7
ALU0253	2026/2	3	82	0	0	9.0	6.7	-2.3
ALU0254	2026/2	1	93	0	2	6.3	7.0	0.7
ALU0255	2026/2	4	79	0	1	6.7	6.7	0.0
ALU0256	2026/2	5	71	0	0	6.4	5.1	-1.3
ALU0257	2026/2	4	80	1	2	7.8	8.1	0.3
ALU0258	2026/2	3	81	1	3	6.6	6.4	-0.2
ALU0259	2026/2	2	87	0	0	7.0	6.2	-0.8
ALU0260	2026/2	2	88	0	0	8.4	6.4	-2.0
ALU0261	2026/2	0	98	0	0	4.9	6.2	1.3
ALU0262	2026/2	4	75	0	2	4.2	6.0	1.8
ALU0263	2026/2	5	71	0	2	4.4	5.1	0.7
ALU0264	2026/2	1	95	0	1	6.6	6.8	0.2
ALU0265	2026/2	0	100	0	3	8.5	7.5	-1.0
ALU0266	2026/2	1	94	0	1	6.7	7.0	0.3
ALU0267	2026/2	1	97	0	0	5.6	7.6	2.0
ALU0268	2026/2	3	83	0	1	6.3	6.3	0.0
ALU0269	2026/2	1	94	0	2	9.4	7.6	-1.8
ALU0270	2026/2	8	58	0	1	3.8	4.7	0.9
ALU0271	2026/2	4	77	1	0	6.9	8.1	1.2
ALU0272	2026/2	5	72	0	2	3.2	3.8	0.6
ALU0273	2026/2	3	85	1	2	9.5	7.5	-2.0
ALU0274	2026/2	3	85	0	1	6.4	6.1	-0.3
ALU0275	2026/2	6	69	1	2	4.2	4.5	0.3
ALU0276	2026/2	2	88	0	1	5.0	6.3	1.3
ALU0277	2026/2	3	82	1	0	5.9	7.0	1.1
ALU0278	2026/2	4	75	1	2	4.3	5.5	1.2
ALU0279	2026/2	3	85	1	2	5.1	5.7	0.6
ALU0280	2026/2	4	79	0	1	7.4	7.6	0.2
ALU0281	2026/2	2	91	0	3	5.5	6.9	1.4
ALU0282	2026/2	9	52	0	3	2.9	3.5	0.6
ALU0283	2026/2	7	63	0	3	3.4	3.1	-0.3
ALU0284	2026/2	0	100	0	0	5.7	6.3	0.6
ALU0285	2026/2	3	81	0	4	5.3	6.2	0.9
ALU0286	2026/2	0	100	1	2	6.5	6.7	0.2
ALU0287	2026/2	1	93	0	0	5.0	6.1	1.1
ALU0288	2026/2	0	98	1	0	6.7	6.4	-0.3
ALU0289	2026/2	0	100	0	1	6.8	6.9	0.1
ALU0290	2026/2	2	88	0	1	5.3	5.3	0.0
ALU0291	2026/2	2	87	0	1	6.4	7.3	0.9
ALU0292	2026/2	4	80	1	1	5.8	6.9	1.1
ALU0293	2026/2	4	80	0	0	6.7	7.4	0.7
ALU0294	2026/2	1	92	1	1	7.8	7.7	-0.1
ALU0295	2026/2	4	75	1	2	5.3	4.6	-0.7
ALU0296	2026/2	2	87	0	2	7.0	8.0	1.0
ALU0297	2026/2	3	84	0	3	8.8	7.1	-1.7
ALU0298	2026/2	3	85	0	1	6.8	6.3	-0.5
ALU0299	2026/2	0	100	0	2	6.2	7.4	1.2
ALU0300	2026/2	4	75	0	1	6.6	7.7	1.1
ALU0301	2026/2	2	91	0	0	6.2	8.0	1.8
ALU0302	2026/2	3	85	0	3	7.2	7.6	0.4
ALU0303	2026/2	4	75	0	0	5.7	7.1	1.4
ALU0304	2026/2	2	91	0	0	6.6	6.0	-0.6
ALU0305	2026/2	3	82	1	3	6.6	7.5	0.9
ALU0306	2026/2	5	74	0	1	10.0	8.5	-1.5
ALU0307	2026/2	5	71	0	3	6.5	5.4	-1.1
ALU0308	2026/2	1	92	1	1	7.9	6.1	-1.8
ALU0309	2026/2	3	86	0	0	5.8	5.3	-0.5
ALU0310	2026/2	5	70	0	1	4.0	4.9	0.9
ALU0311	2026/2	2	90	0	1	9.4	7.9	-1.5
ALU0312	2026/2	1	92	0	1	6.4	7.4	1.0
ALU0313	2026/2	3	85	0	1	8.5	7.9	-0.6
ALU0314	2026/2	3	85	0	1	8.5	7.2	-1.3
ALU0315	2026/2	4	78	1	0	8.1	8.5	0.4
ALU0316	2026/2	5	74	0	0	5.9	5.4	-0.5
ALU0317	2026/2	3	81	0	1	4.5	5.4	0.9
ALU0318	2026/2	7	60	0	1	6.8	5.1	-1.7
ALU0319	2026/2	0	98	1	1	6.5	6.1	-0.4
ALU0320	2026/2	3	83	0	4	6.1	6.8	0.7
ALU0321	2026/2	3	86	1	2	5.4	7.4	2.0
ALU0322	2026/2	3	84	1	2	8.1	7.1	-1.0
ALU0323	2026/2	4	80	0	1	5.4	6.6	1.2
ALU0324	2026/2	3	84	0	1	6.9	7.9	1.0
ALU0325	2026/2	2	88	0	0	6.9	6.5	-0.4
ALU0326	2026/2	1	95	1	1	8.0	8.0	0.0
ALU0327	2026/2	1	93	0	3	6.9	6.6	-0.3
ALU0328	2026/2	1	95	0	1	7.3	7.7	0.4
ALU0329	2026/2	6	69	1	2	4.2	6.4	2.2
ALU0330	2026/2	1	92	0	1	7.6	7.2	-0.4
ALU0331	2026/2	3	85	1	3	5.5	6.1	0.6
ALU0332	2026/2	3	82	2	2	6.6	7.6	1.0
ALU0333	2026/2	5	73	0	0	5.1	5.8	0.7
ALU0334	2026/2	3	84	0	2	4.6	6.3	1.7
ALU0335	2026/2	0	100	0	0	7.0	6.5	-0.5
ALU0336	2026/2	7	60	0	0	2.7	4.0	1.3
ALU0337	2026/2	3	85	2	0	7.6	7.5	-0.1
ALU0338	2026/2	6	68	0	1	7.6	7.4	-0.2
ALU0339	2026/2	1	97	0	0	6.8	7.5	0.7
ALU0340	2026/2	3	85	0	1	6.0	7.1	1.1
ALU0341	2026/2	0	100	0	2	8.0	8.0	0.0
ALU0342	2026/2	2	88	2	0	6.0	6.3	0.3
ALU0343	2026/2	2	89	0	0	6.9	8.5	1.6
ALU0344	2026/2	1	96	1	1	8.4	7.3	-1.1
ALU0345	2026/2	5	70	0	1	8.8	8.0	-0.8
ALU0346	2026/2	0	99	1	2	7.5	7.3	-0.2
ALU0347	2026/2	4	75	0	2	6.5	5.4	-1.1
ALU0348	2026/2	8	55	0	4	3.6	3.6	0.0
ALU0349	2026/2	4	77	1	2	7.3	7.3	0.0
ALU0350	2026/2	4	78	1	0	5.3	5.8	0.5
ALU0351	2026/2	4	78	1	0	8.3	7.8	-0.5
ALU0352	2026/2	10	47	0	0	1.6	3.8	2.2
ALU0353	2026/2	5	70	0	2	4.0	4.5	0.5
ALU0354	2026/2	2	90	2	4	5.0	6.4	1.4
ALU0355	2026/2	7	63	1	3	7.4	7.9	0.5
ALU0356	2026/2	3	84	0	0	6.6	7.0	0.4
ALU0357	2026/2	0	98	0	1	6.9	7.2	0.3
ALU0358	2026/2	4	78	0	2	7.4	6.1	-1.3
ALU0359	2026/2	3	86	0	3	5.7	6.2	0.5
ALU0360	2026/2	0	100	0	0	6.5	6.5	0.0
ALU0361	2026/2	3	82	0	0	7.4	6.1	-1.3
ALU0362	2026/2	7	61	0	0	7.9	8.7	0.8
ALU0363	2026/2	1	97	0	1	8.1	8.8	0.7
ALU0364	2026/2	4	77	0	0	6.0	4.8	-1.2
ALU0365	2026/2	5	72	0	1	7.2	6.9	-0.3
ALU0366	2026/2	5	72	0	2	5.4	5.2	-0.2
ALU0367	2026/2	4	78	0	0	9.6	8.2	-1.4
ALU0368	2026/2	2	91	0	1	5.0	7.4	2.4
ALU0369	2026/2	6	68	0	1	5.6	6.5	0.9
ALU0370	2026/2	3	83	1	0	7.4	7.4	0.0
ALU0371	2026/2	2	89	2	2	6.7	6.6	-0.1
ALU0372	2026/2	3	85	1	1	6.5	6.5	0.0
ALU0373	2026/2	6	68	0	0	4.9	4.2	-0.7
ALU0374	2026/2	0	100	0	1	6.9	6.2	-0.7
ALU0375	2026/2	3	86	0	0	6.1	7.1	1.0
ALU0376	2026/2	2	90	1	1	7.1	7.3	0.2
ALU0377	2026/2	1	96	0	0	5.4	4.2	-1.2
ALU0378	2026/2	3	83	1	2	5.2	5.8	0.6
ALU0379	2026/2	3	86	0	2	3.5	5.7	2.2
ALU0380	2026/2	4	77	0	2	4.7	5.6	0.9
ALU0381	2026/2	4	80	0	0	7.4	6.9	-0.5
ALU0382	2026/2	1	92	0	0	7.7	8.7	1.0
ALU0383	2026/2	1	93	0	0	5.3	7.3	2.0
ALU0384	2026/2	4	78	0	1	6.3	4.7	-1.6
ALU0385	2026/2	0	100	0	1	6.2	7.4	1.2
ALU0386	2026/2	1	97	0	0	7.0	6.6	-0.4
ALU0387	2026/2	5	74	0	3	5.6	4.8	-0.8
ALU0388	2026/2	1	97	0	0	7.7	8.6	0.9
ALU0389	2026/2	3	86	0	0	7.5	7.4	-0.1
ALU0390	2026/2	2	87	1	2	5.3	6.1	0.8
ALU0391	2026/2	0	100	1	0	6.8	7.1	0.3
ALU0392	2026/2	6	65	0	3	3.6	5.2	1.6
ALU0393	2026/2	0	100	0	0	7.1	7.5	0.4
ALU0394	2026/2	4	77	0	2	5.5	5.0	-0.5
ALU0395	2026/2	3	82	0	0	7.1	6.3	-0.8
ALU0396	2026/2	4	77	0	0	9.8	7.8	-2.0
ALU0397	2026/2	2	88	0	0	7.6	6.9	-0.7
ALU0398	2026/2	2	91	0	0	6.4	5.7	-0.7
ALU0399	2026/2	2	90	0	2	8.2	7.5	-0.7
ALU0400	2026/2	0	100	1	0	7.6	9.6	2.0
ALU0401	2026/2	4	80	0	1	7.3	5.6	-1.7
ALU0402	2026/2	0	100	0	3	5.9	6.1	0.2
ALU0403	2026/2	0	98	1	0	7.4	6.2	-1.2
ALU0404	2026/2	3	85	0	2	7.9	7.3	-0.6
ALU0405	2026/2	1	92	0	1	7.3	7.2	-0.1
ALU0406	2026/2	2	90	0	0	5.6	6.1	0.5
ALU0407	2026/2	5	74	1	2	5.7	5.6	-0.1
ALU0408	2026/2	2	91	0	2	8.3	6.6	-1.7
ALU0409	2026/2	2	89	0	2	7.1	7.0	-0.1
ALU0410	2026/2	6	67	0	1	5.3	4.9	-0.4
ALU0411	2026/2	3	84	0	1	8.8	6.7	-2.1
ALU0412	2026/2	5	73	0	1	5.2	4.0	-1.2
ALU0413	2026/2	1	92	1	1	4.7	5.8	1.1
ALU0414	2026/2	3	82	1	1	5.4	6.6	1.2
ALU0415	2026/2	3	84	0	1	4.2	5.4	1.2
ALU0416	2026/2	2	89	0	1	7.2	7.1	-0.1
ALU0417	2026/2	8	57	0	5	6.6	4.7	-1.9
ALU0418	2026/2	0	100	1	1	7.2	6.5	-0.7
ALU0419	2026/2	4	79	0	2	6.6	6.4	-0.2
ALU0420	2026/2	3	83	0	1	7.2	8.0	0.8
ALU0421	2026/2	4	79	0	1	6.0	5.3	-0.7
ALU0422	2026/2	1	93	0	0	6.8	6.6	-0.2
ALU0423	2026/2	3	83	0	1	6.9	6.9	0.0
ALU0424	2026/2	1	93	1	0	5.9	7.0	1.1
ALU0425	2026/2	0	100	2	0	7.7	8.2	0.5
ALU0426	2026/2	2	91	1	3	4.6	4.7	0.1
ALU0427	2026/2	1	96	0	1	7.3	7.7	0.4
ALU0428	2026/2	1	95	0	2	7.3	7.0	-0.3
ALU0429	2026/2	5	73	0	1	4.7	7.4	2.7
ALU0430	2026/2	4	78	0	3	3.9	4.3	0.4
ALU0431	2026/2	3	81	1	1	6.1	6.1	0.0
ALU0432	2026/2	2	87	0	0	7.2	6.8	-0.4
ALU0433	2026/2	3	83	1	0	7.6	7.1	-0.5
ALU0434	2026/2	3	86	0	1	7.1	7.7	0.6
ALU0435	2026/2	4	80	1	1	6.5	5.6	-0.9
ALU0436	2026/2	3	84	0	1	7.5	8.4	0.9
ALU0437	2026/2	2	89	0	1	6.1	5.0	-1.1
ALU0438	2026/2	0	99	1	3	5.4	6.3	0.9
ALU0439	2026/2	5	70	0	3	6.3	5.9	-0.4
ALU0440	2026/2	0	100	2	1	6.3	6.6	0.3
ALU0441	2026/2	2	87	0	0	8.9	8.4	-0.5
ALU0442	2026/2	2	87	0	1	7.7	6.1	-1.6
ALU0443	2026/2	2	87	0	0	7.5	5.9	-1.6
ALU0444	2026/2	4	75	0	0	7.0	7.3	0.3
ALU0445	2026/2	2	90	1	2	5.6	4.7	-0.9
ALU0446	2026/2	3	85	0	2	7.2	7.4	0.2
ALU0447	2026/2	1	92	2	0	10.0	7.9	-2.1
ALU0448	2026/2	1	92	1	0	7.0	6.9	-0.1
ALU0449	2026/2	3	82	0	1	5.9	7.3	1.4
ALU0450	2026/2	3	84	0	4	8.4	8.3	-0.1
ALU0451	2026/2	4	80	0	1	4.5	5.8	1.3
ALU0452	2026/2	3	86	1	0	7.0	7.2	0.2
ALU0453	2026/2	4	79	0	1	6.6	5.3	-1.3
ALU0454	2026/2	4	79	1	1	6.2	6.6	0.4
ALU0455	2026/2	5	74	0	0	5.7	4.4	-1.3
ALU0456	2026/2	3	86	0	1	6.0	5.7	-0.3
ALU0457	2026/2	4	75	0	2	8.6	6.7	-1.9
ALU0458	2026/2	4	78	0	1	9.4	9.0	-0.4
ALU0459	2026/2	1	94	0	2	5.2	4.6	-0.6
ALU0460	2026/2	0	100	0	1	6.6	6.0	-0.6
ALU0461	2026/2	2	88	0	1	5.9	5.8	-0.1
ALU0462	2026/2	2	88	0	0	6.9	7.9	1.0
ALU0463	2026/2	5	70	0	2	3.4	5.4	2.0
ALU0464	2026/2	1	92	0	1	8.4	7.0	-1.4
ALU0465	2026/2	6	64	0	3	7.0	5.6	-1.4
ALU0466	2026/2	4	77	0	2	7.5	6.5	-1.0
ALU0467	2026/2	5	72	0	1	5.8	6.5	0.7
ALU0468	2026/2	5	70	0	1	9.2	7.0	-2.2
ALU0469	2026/2	2	88	0	2	6.1	6.8	0.7
ALU0470	2026/2	3	81	0	2	7.1	6.1	-1.0
ALU0471	2026/2	0	100	0	0	6.2	6.6	0.4
ALU0472	2026/2	2	91	0	2	6.4	7.5	1.1
ALU0473	2026/2	3	82	1	2	7.8	4.5	-3.3
ALU0474	2026/2	2	91	0	3	8.8	7.1	-1.7
ALU0475	2026/2	2	91	0	0	6.5	7.7	1.2
ALU0476	2026/2	1	93	1	2	8.6	8.1	-0.5
ALU0477	2026/2	3	82	1	0	8.0	8.1	0.1
ALU0478	2026/2	3	85	0	2	10.0	8.4	-1.6
ALU0479	2026/2	2	89	0	2	5.4	6.2	0.8
ALU0480	2026/2	1	95	0	0	7.0	7.7	0.7
ALU0481	2026/2	4	77	0	1	5.3	6.7	1.4
ALU0482	2026/2	1	97	0	1	5.1	7.1	2.0
ALU0483	2026/2	2	89	0	3	7.4	6.8	-0.6
ALU0484	2026/2	5	72	2	1	9.2	9.0	-0.2
ALU0485	2026/2	4	76	0	1	4.8	6.1	1.3
ALU0486	2026/2	4	79	0	3	7.7	8.4	0.7
ALU0487	2026/2	3	86	0	0	5.7	6.6	0.9
ALU0488	2026/2	2	87	0	0	7.4	6.8	-0.6
ALU0489	2026/2	5	71	0	2	2.5	5.2	2.7
ALU0490	2026/2	1	96	0	0	8.4	8.4	0.0
ALU0491	2026/2	1	97	0	2	7.9	7.8	-0.1
ALU0492	2026/2	2	89	0	2	5.5	6.4	0.9
ALU0493	2026/2	4	80	0	2	4.3	6.6	2.3
ALU0494	2026/2	4	79	1	1	8.9	9.3	0.4
ALU0495	2026/2	0	100	0	1	8.8	7.2	-1.6
ALU0496	2026/2	0	98	0	1	7.6	8.1	0.5
ALU0497	2026/2	1	92	0	0	6.4	6.5	0.1
ALU0498	2026/2	5	70	0	2	6.8	8.1	1.3
ALU0499	2026/2	4	75	0	2	4.4	5.1	0.7
ALU0500	2026/2	0	100	0	0	9.6	8.9	-0.7
ALU0501	2026/2	6	64	0	4	4.5	3.8	-0.7
ALU0502	2026/2	7	63	0	3	4.8	4.6	-0.2
ALU0503	2026/2	0	100	0	2	8.3	7.7	-0.6
ALU0504	2026/2	4	76	0	0	6.8	6.5	-0.3
ALU0505	2026/2	4	76	1	3	9.0	8.4	-0.6
ALU0506	2026/2	4	80	1	1	5.6	6.8	1.2
ALU0507	2026/2	3	82	0	2	7.2	7.5	0.3
ALU0508	2026/2	5	70	0	2	4.9	5.9	1.0
ALU0509	2026/2	3	86	0	2	8.3	7.9	-0.4
ALU0510	2026/2	5	71	0	0	8.0	8.0	0.0
ALU0511	2026/2	3	86	0	2	6.4	6.8	0.4
ALU0512	2026/2	0	100	0	1	5.6	6.9	1.3
ALU0513	2026/2	2	89	0	0	5.7	5.9	0.2
ALU0514	2026/2	4	80	0	1	7.6	7.3	-0.3
ALU0515	2026/2	2	88	0	1	5.9	6.9	1.0
ALU0516	2026/2	3	81	0	0	7.2	6.5	-0.7
ALU0517	2026/2	0	100	1	0	6.6	5.8	-0.8
ALU0518	2026/2	3	82	0	0	7.6	8.0	0.4
ALU0519	2026/2	4	80	0	0	6.0	5.6	-0.4
ALU0520	2026/2	1	92	0	1	7.7	6.6	-1.1
ALU0521	2026/2	3	82	0	0	9.4	7.2	-2.2
ALU0522	2026/2	1	93	0	1	6.3	6.6	0.3
ALU0523	2026/2	3	81	1	5	7.7	6.8	-0.9
ALU0524	2026/2	6	67	0	4	2.6	4.0	1.4
ALU0525	2026/2	3	86	0	0	6.5	6.1	-0.4
ALU0526	2026/2	4	78	0	1	5.6	5.5	-0.1
ALU0527	2026/2	3	82	0	0	4.6	6.1	1.5
ALU0528	2026/2	2	91	0	2	6.7	5.7	-1.0
ALU0529	2026/2	0	100	0	1	4.5	5.8	1.3
ALU0530	2026/2	4	78	1	1	4.7	4.7	0.0
ALU0531	2026/2	2	87	0	0	6.2	5.9	-0.3
ALU0532	2026/2	6	64	0	5	3.3	3.8	0.5
ALU0533	2026/2	3	83	0	0	7.0	6.9	-0.1
ALU0534	2026/2	5	71	0	2	5.5	5.8	0.3
ALU0535	2026/2	5	74	0	2	7.1	3.9	-3.2
ALU0536	2026/2	3	86	0	1	8.0	6.7	-1.3
ALU0537	2026/2	6	68	0	0	5.3	6.2	0.9
ALU0538	2026/2	2	91	0	1	5.9	7.1	1.2
ALU0539	2026/2	2	89	0	3	5.1	7.5	2.4
ALU0540	2026/2	2	89	0	1	8.8	8.2	-0.6
ALU0541	2026/2	0	100	1	0	7.3	5.9	-1.4
ALU0542	2026/2	4	80	0	3	6.3	6.7	0.4
ALU0543	2026/2	0	100	0	1	6.7	6.6	-0.1
ALU0544	2026/2	5	74	0	0	5.6	6.0	0.4
ALU0545	2026/2	1	92	0	1	3.8	4.6	0.8
ALU0546	2026/2	4	77	0	1	9.2	7.9	-1.3
ALU0547	2026/2	5	73	1	3	3.1	4.5	1.4
ALU0548	2026/2	1	96	0	3	6.2	4.6	-1.6
ALU0549	2026/2	1	96	0	1	7.9	7.5	-0.4
ALU0550	2026/2	0	100	1	3	7.3	5.4	-1.9
ALU0551	2026/2	2	89	0	1	7.4	7.4	0.0
ALU0552	2026/2	2	87	0	3	5.9	5.9	0.0
ALU0553	2026/2	1	96	0	1	7.7	7.0	-0.7
ALU0554	2026/2	4	75	0	0	4.5	5.0	0.5
ALU0555	2026/2	2	90	0	2	7.2	7.7	0.5
ALU0556	2026/2	4	75	0	1	4.4	5.4	1.0
ALU0557	2026/2	0	100	0	0	6.2	6.6	0.4
ALU0558	2026/2	6	69	1	0	8.6	7.4	-1.2
ALU0559	2026/2	2	89	0	0	5.9	6.4	0.5
ALU0560	2026/2	4	77	1	0	4.8	6.1	1.3
ALU0561	2026/2	1	96	0	0	6.6	6.1	-0.5
ALU0562	2026/2	3	83	0	1	9.4	7.6	-1.8
ALU0563	2026/2	2	89	0	0	8.2	7.2	-1.0
ALU0564	2026/2	4	77	1	1	7.1	6.6	-0.5
ALU0565	2026/2	1	93	0	1	7.0	7.1	0.1
ALU0566	2026/2	2	90	1	3	6.8	6.6	-0.2
ALU0567	2026/2	3	85	0	2	7.1	6.8	-0.3
ALU0568	2026/2	5	71	0	0	7.6	8.0	0.4
ALU0569	2026/2	6	67	1	2	5.8	4.8	-1.0
ALU0570	2026/2	1	95	0	1	7.3	5.0	-2.3
ALU0571	2026/2	4	78	1	0	8.9	8.5	-0.4
ALU0572	2026/2	4	77	0	2	5.9	4.2	-1.7
ALU0573	2026/2	3	83	1	3	7.2	6.0	-1.2
ALU0574	2026/2	1	96	0	0	5.8	6.5	0.7
ALU0575	2026/2	3	84	0	3	8.3	8.1	-0.2
ALU0576	2026/2	3	83	0	1	5.7	6.0	0.3
ALU0577	2026/2	3	85	1	0	7.6	6.9	-0.7
ALU0578	2026/2	4	76	0	1	8.0	6.9	-1.1
ALU0579	2026/2	1	93	1	2	6.1	5.1	-1.0
ALU0580	2026/2	2	88	0	1	5.9	6.3	0.4
ALU0581	2026/2	5	72	1	1	7.8	7.3	-0.5
ALU0582	2026/2	2	91	0	0	6.5	8.1	1.6
ALU0583	2026/2	4	79	0	0	4.9	6.9	2.0
ALU0584	2026/2	1	96	0	0	6.9	7.1	0.2
ALU0585	2026/2	3	85	0	0	7.3	6.5	-0.8
ALU0586	2026/2	2	89	0	0	6.7	7.2	0.5
ALU0587	2026/2	4	78	2	1	5.8	5.0	-0.8
ALU0588	2026/2	2	87	0	1	5.5	6.6	1.1
ALU0589	2026/2	4	77	0	0	6.1	5.6	-0.5
ALU0590	2026/2	4	78	0	1	7.0	6.5	-0.5
ALU0591	2026/2	1	93	1	0	8.7	7.0	-1.7
ALU0592	2026/2	3	85	0	2	6.4	7.9	1.5
ALU0593	2026/2	4	78	2	4	3.9	4.5	0.6
ALU0594	2026/2	3	81	0	3	6.2	6.4	0.2
ALU0595	2026/2	3	85	0	0	8.5	8.0	-0.5
ALU0596	2026/2	2	91	0	3	5.7	7.0	1.3
ALU0597	2026/2	3	86	0	2	6.6	6.0	-0.6
ALU0598	2026/2	4	80	0	0	5.0	5.5	0.5
ALU0599	2026/2	2	90	1	2	6.1	6.1	0.0
ALU0600	2026/2	3	86	0	0	7.7	8.5	0.8
ALU0601	2026/2	0	100	0	0	9.2	7.0	-2.2
ALU0602	2026/2	4	75	2	2	4.4	4.9	0.5
ALU0603	2026/2	2	91	1	1	6.5	6.4	-0.1
ALU0604	2026/2	7	63	0	2	5.3	5.1	-0.2
ALU0605	2026/2	2	91	0	0	9.1	8.0	-1.1
ALU0606	2026/2	5	70	0	3	3.7	5.3	1.6
ALU0607	2026/2	4	75	0	0	6.5	6.0	-0.5
ALU0608	2026/2	5	72	0	0	5.5	5.1	-0.4
ALU0609	2026/2	5	70	0	2	7.7	7.0	-0.7
ALU0610	2026/2	0	99	0	0	9.9	7.6	-2.3
ALU0611	2026/2	6	66	1	5	5.3	4.7	-0.6
ALU0612	2026/2	1	93	0	1	5.6	4.5	-1.1
ALU0613	2026/2	0	100	1	0	7.4	7.8	0.4
ALU0614	2026/2	3	81	0	1	8.1	7.5	-0.6
ALU0615	2026/2	4	75	0	2	8.8	6.7	-2.1
ALU0616	2026/2	2	88	0	0	6.1	5.8	-0.3
ALU0617	2026/2	4	79	0	3	5.4	4.0	-1.4
ALU0618	2026/2	0	99	0	3	4.8	5.2	0.4
ALU0619	2026/2	3	85	0	1	7.2	6.4	-0.8
ALU0620	2026/2	6	67	1	0	5.4	5.8	0.4
ALU0621	2026/2	5	72	1	1	5.7	5.6	-0.1
ALU0622	2026/2	7	62	2	6	3.9	4.8	0.9
ALU0623	2026/2	0	100	0	1	7.6	7.8	0.2
ALU0624	2026/2	2	88	0	1	8.2	8.0	-0.2
ALU0625	2026/2	3	84	1	1	5.0	6.0	1.0
ALU0626	2026/2	3	86	0	1	9.8	8.4	-1.4
ALU0627	2026/2	3	83	0	1	6.8	5.8	-1.0
ALU0628	2026/2	4	76	0	0	6.8	6.5	-0.3
ALU0629	2026/2	2	90	1	1	6.0	6.9	0.9
ALU0630	2026/2	1	93	0	1	9.3	8.3	-1.0
ALU0631	2026/2	2	88	0	0	8.2	6.8	-1.4
ALU0632	2026/2	6	64	0	0	6.3	6.1	-0.2
ALU0633	2026/2	5	73	0	3	7.4	5.2	-2.2
ALU0634	2026/2	2	89	1	3	7.4	8.6	1.2
ALU0635	2026/2	2	90	0	1	8.1	7.9	-0.2
ALU0636	2026/2	5	73	0	0	6.6	5.2	-1.4
ALU0637	2026/2	4	78	0	3	8.7	8.5	-0.2
ALU0638	2026/2	0	99	0	1	8.5	8.9	0.4
ALU0639	2026/2	4	79	1	1	9.6	6.9	-2.7
ALU0640	2026/2	0	100	0	0	7.9	7.5	-0.4
ALU0641	2026/2	0	100	0	2	8.6	7.8	-0.8
ALU0642	2026/2	5	73	0	4	6.0	6.6	0.6
ALU0643	2026/2	0	100	1	0	5.8	5.1	-0.7
ALU0644	2026/2	3	85	0	1	8.6	7.2	-1.4
ALU0645	2026/2	2	89	1	0	6.2	6.3	0.1
ALU0646	2026/2	2	91	0	0	4.9	7.1	2.2
ALU0647	2026/2	5	71	1	1	3.2	4.0	0.8
ALU0648	2026/2	6	64	1	0	6.3	6.0	-0.3
ALU0649	2026/2	1	94	1	0	5.8	7.2	1.4
ALU0650	2026/2	3	86	0	1	6.7	6.0	-0.7
ALU0651	2026/2	4	78	1	0	5.4	6.3	0.9
ALU0652	2026/2	3	82	0	0	5.5	5.4	-0.1
ALU0653	2026/2	4	79	0	0	9.4	7.1	-2.3
ALU0654	2026/2	4	79	0	1	6.6	7.1	0.5
ALU0655	2026/2	1	94	1	1	7.2	7.7	0.5
ALU0656	2026/2	4	80	1	1	9.8	7.7	-2.1
ALU0657	2026/2	3	81	1	3	5.9	6.6	0.7
ALU0658	2026/2	7	63	0	1	6.6	7.1	0.5
ALU0659	2026/2	3	84	0	3	6.1	7.4	1.3
ALU0660	2026/2	4	78	0	0	4.6	4.9	0.3
ALU0661	2026/2	2	88	2	1	5.9	5.6	-0.3
ALU0662	2026/2	7	62	1	0	5.0	6.0	1.0
ALU0663	2026/2	3	86	0	0	7.4	5.5	-1.9
ALU0664	2026/2	4	78	0	1	5.7	5.9	0.2
ALU0665	2026/2	5	70	0	2	7.5	7.0	-0.5
ALU0666	2026/2	3	81	0	0	5.1	5.6	0.5
ALU0667	2026/2	4	77	0	1	7.3	7.5	0.2
ALU0668	2026/2	3	85	1	1	6.8	6.8	0.0
ALU0669	2026/2	3	83	1	1	5.6	5.6	0.0
ALU0670	2026/2	3	85	1	0	5.5	7.0	1.5
ALU0671	2026/2	3	85	0	1	5.3	5.7	0.4
ALU0672	2026/2	3	81	0	2	6.4	5.5	-0.9
ALU0673	2026/2	1	96	0	1	6.2	6.6	0.4
ALU0674	2026/2	6	69	0	1	6.0	6.8	0.8
ALU0675	2026/2	5	73	0	0	2.3	4.3	2.0
ALU0676	2026/2	3	82	0	2	8.5	8.4	-0.1
ALU0677	2026/2	2	89	0	1	6.5	6.9	0.4
ALU0678	2026/2	3	81	0	0	5.7	6.9	1.2
ALU0679	2026/2	3	86	0	2	6.6	7.8	1.2
ALU0680	2026/2	2	90	1	1	7.7	7.6	-0.1
ALU0681	2026/2	3	86	1	0	6.5	5.4	-1.1
ALU0682	2026/2	3	81	0	1	6.8	6.8	0.0
ALU0683	2026/2	4	80	0	1	10.0	8.5	-1.5
ALU0684	2026/2	2	87	0	1	7.7	7.7	0.0
ALU0685	2026/2	6	66	0	2	5.7	4.9	-0.8
ALU0686	2026/2	2	91	1	0	6.7	6.3	-0.4
ALU0687	2026/2	3	85	0	2	6.2	6.0	-0.2
ALU0688	2026/2	1	93	0	2	5.4	6.0	0.6
ALU0689	2026/2	3	81	0	4	5.6	5.1	-0.5
ALU0690	2026/2	4	77	0	1	4.6	6.9	2.3
ALU0691	2026/2	4	76	0	1	3.4	3.0	-0.4
ALU0692	2026/2	5	74	0	2	4.2	3.7	-0.5
ALU0693	2026/2	4	76	0	0	7.3	7.0	-0.3
ALU0694	2026/2	3	82	0	1	6.2	5.5	-0.7
ALU0695	2026/2	3	84	2	2	8.0	7.0	-1.0
ALU0696	2026/2	2	87	0	4	4.9	6.0	1.1
ALU0697	2026/2	3	81	0	1	5.1	6.0	0.9
ALU0698	2026/2	3	84	0	0	7.2	7.5	0.3
ALU0699	2026/2	6	67	1	1	5.8	7.4	1.6
ALU0700	2026/2	0	99	0	0	6.9	7.5	0.6
ALU0701	2026/2	2	87	2	1	6.9	7.4	0.5
ALU0702	2026/2	2	90	0	1	6.3	6.0	-0.3
ALU0703	2026/2	6	64	0	1	4.9	5.7	0.8
ALU0704	2026/2	4	79	2	2	5.6	6.1	0.5
ALU0705	2026/2	3	86	0	2	6.5	6.0	-0.5
ALU0706	2026/2	3	81	1	0	6.5	8.0	1.5
ALU0707	2026/2	5	73	0	0	7.7	7.4	-0.3
ALU0708	2026/2	2	91	0	0	8.1	8.6	0.5
ALU0709	2026/2	2	89	1	1	6.2	6.7	0.5
ALU0710	2026/2	4	80	1	0	6.8	6.3	-0.5
ALU0711	2026/2	0	100	0	0	7.4	6.1	-1.3
ALU0712	2026/2	6	69	0	1	6.2	5.6	-0.6
ALU0713	2026/2	3	83	0	1	8.3	7.9	-0.4
ALU0714	2026/2	3	83	0	1	4.8	6.2	1.4
ALU0715	2026/2	4	77	0	2	5.6	5.7	0.1
ALU0716	2026/2	3	83	0	0	9.2	7.9	-1.3
ALU0717	2026/2	1	93	1	1	7.8	8.4	0.6
ALU0718	2026/2	2	88	1	1	7.2	6.7	-0.5
ALU0719	2026/2	4	80	1	0	6.5	7.1	0.6
ALU0720	2026/2	3	83	0	1	9.3	8.2	-1.1
ALU0721	2026/2	4	79	0	0	6.4	6.9	0.5
ALU0722	2026/2	2	89	0	1	9.2	7.0	-2.2
ALU0723	2026/2	1	95	0	0	6.6	7.3	0.7
ALU0724	2026/2	2	91	0	1	7.3	6.8	-0.5
ALU0725	2026/2	1	95	1	1	6.3	6.3	0.0
ALU0726	2026/2	2	88	0	1	5.7	6.4	0.7
ALU0727	2026/2	2	88	0	2	3.7	3.5	-0.2
ALU0728	2026/2	2	88	0	1	5.5	6.4	0.9
ALU0729	2026/2	2	87	0	0	7.7	7.5	-0.2
ALU0730	2026/2	3	85	0	1	3.9	5.3	1.4
ALU0731	2026/2	3	85	0	2	5.8	6.3	0.5
ALU0732	2026/2	1	92	1	2	8.0	7.1	-0.9
ALU0733	2026/2	1	96	0	0	6.8	7.9	1.1
ALU0734	2026/2	1	97	0	0	9.1	7.2	-1.9
ALU0735	2026/2	4	77	2	2	6.7	6.1	-0.6
ALU0736	2026/2	4	77	0	3	7.0	5.5	-1.5
ALU0737	2026/2	2	89	0	2	5.5	7.5	2.0
ALU0738	2026/2	5	71	0	1	5.0	3.2	-1.8
ALU0739	2026/2	1	95	1	1	6.0	6.5	0.5
ALU0740	2026/2	4	77	0	1	6.2	6.4	0.2
ALU0741	2026/2	0	100	2	3	4.8	6.6	1.8
ALU0742	2026/2	4	77	0	1	7.1	8.1	1.0
ALU0743	2026/2	2	90	0	1	7.1	6.3	-0.8
ALU0744	2026/2	4	78	1	1	6.0	6.9	0.9
ALU0745	2026/2	2	89	1	2	4.9	7.2	2.3
ALU0746	2026/2	3	85	0	2	6.0	5.6	-0.4
ALU0747	2026/2	5	71	0	2	6.0	5.0	-1.0
ALU0748	2026/2	5	74	0	4	3.3	3.4	0.1
ALU0749	2026/2	3	84	0	0	6.1	6.1	0.0
ALU0750	2026/2	1	95	1	1	7.6	7.7	0.1
ALU0751	2026/2	1	95	0	2	3.8	6.6	2.8
ALU0752	2026/2	4	80	1	0	4.7	6.6	1.9
ALU0753	2026/2	1	95	1	1	7.1	7.3	0.2
ALU0754	2026/2	0	98	0	0	6.1	6.5	0.4
ALU0755	2026/2	2	87	0	0	6.7	7.3	0.6
ALU0756	2026/2	2	88	0	0	6.6	6.8	0.2
ALU0757	2026/2	1	94	1	1	8.8	7.8	-1.0
ALU0758	2026/2	3	81	0	0	6.9	5.0	-1.9
ALU0759	2026/2	2	87	0	0	6.3	6.8	0.5
ALU0760	2026/2	2	91	0	0	7.5	5.7	-1.8
ALU0761	2026/2	1	95	1	3	7.2	6.3	-0.9
ALU0762	2026/2	1	92	0	0	7.7	7.8	0.1
ALU0763	2026/2	2	90	0	0	5.2	6.4	1.2
ALU0764	2026/2	6	69	0	1	5.8	4.9	-0.9
ALU0765	2026/2	4	78	0	0	6.6	5.6	-1.0
ALU0766	2026/2	2	87	0	1	4.2	5.9	1.7
ALU0767	2026/2	4	78	0	2	4.0	6.5	2.5
ALU0768	2026/2	4	80	0	2	2.2	3.3	1.1
ALU0769	2026/2	3	83	0	1	7.0	5.3	-1.7
ALU0770	2026/2	7	60	0	3	6.3	4.3	-2.0
ALU0771	2026/2	2	88	0	1	6.5	6.9	0.4
ALU0772	2026/2	2	90	1	0	7.0	5.4	-1.6
ALU0773	2026/2	0	99	0	0	8.1	8.3	0.2
ALU0774	2026/2	3	85	0	1	6.7	8.2	1.5
ALU0775	2026/2	3	82	0	0	7.5	7.9	0.4
ALU0776	2026/2	4	79	0	1	8.6	7.5	-1.1
ALU0777	2026/2	3	84	0	3	4.8	6.1	1.3
ALU0778	2026/2	4	76	0	0	3.9	4.5	0.6
ALU0779	2026/2	3	82	0	0	5.9	6.6	0.7
ALU0780	2026/2	2	88	0	1	7.7	8.0	0.3
ALU0781	2026/2	4	75	0	0	4.2	4.3	0.1
ALU0782	2026/2	3	83	0	0	7.4	7.6	0.2
ALU0783	2026/2	4	78	0	0	4.5	5.7	1.2
ALU0784	2026/2	4	77	0	1	7.3	7.0	-0.3
ALU0785	2026/2	4	80	0	0	6.7	6.6	-0.1
ALU0786	2026/2	2	91	0	2	8.1	7.8	-0.3
ALU0787	2026/2	2	91	1	2	8.0	7.9	-0.1
ALU0788	2026/2	3	83	0	0	4.9	6.7	1.8
ALU0789	2026/2	2	88	0	0	8.9	8.4	-0.5
ALU0790	2026/2	5	74	0	1	5.7	6.4	0.7
ALU0791	2026/2	5	70	0	0	6.0	6.9	0.9
ALU0792	2026/2	4	75	1	1	6.1	7.1	1.0
ALU0793	2026/2	1	93	1	3	7.5	6.6	-0.9
ALU0794	2026/2	4	78	0	1	7.8	7.7	-0.1
ALU0795	2026/2	3	84	0	1	6.5	7.3	0.8
ALU0796	2026/2	2	87	1	0	5.8	6.1	0.3
ALU0797	2026/2	2	87	0	2	6.9	6.5	-0.4
ALU0798	2026/2	2	87	1	0	7.6	7.4	-0.2
ALU0799	2026/2	6	64	0	1	7.7	7.9	0.2
ALU0800	2026/2	3	86	0	1	6.5	6.3	-0.2
ALU0801	2026/2	3	84	0	0	9.0	6.9	-2.1
ALU0802	2026/2	3	84	0	0	6.6	6.2	-0.4
ALU0803	2026/2	4	76	1	0	5.7	4.9	-0.8
ALU0804	2026/2	2	88	0	0	7.3	6.0	-1.3
ALU0805	2026/2	3	83	1	0	5.7	6.1	0.4
ALU0806	2026/2	7	60	1	3	5.1	5.6	0.5
ALU0807	2026/2	6	66	0	7	3.7	5.8	2.1
ALU0808	2026/2	4	79	0	0	4.2	4.6	0.4
ALU0809	2026/2	5	70	1	1	8.2	7.3	-0.9
ALU0810	2026/2	1	94	0	0	7.1	8.0	0.9
ALU0811	2026/2	3	85	1	5	8.2	7.1	-1.1
ALU0812	2026/2	1	92	2	0	7.1	6.8	-0.3
ALU0813	2026/2	5	71	1	1	5.1	5.7	0.6
ALU0814	2026/2	0	98	0	1	7.8	7.4	-0.4
ALU0815	2026/2	3	86	2	1	7.7	6.5	-1.2
ALU0816	2026/2	1	92	0	1	9.2	9.2	0.0
ALU0817	2026/2	3	83	0	0	7.8	7.8	0.0
ALU0818	2026/2	5	74	0	1	5.5	5.9	0.4
ALU0819	2026/2	2	90	0	0	6.8	7.0	0.2
ALU0820	2026/2	0	99	1	1	5.5	6.6	1.1
ALU0821	2026/2	0	98	0	1	9.4	7.6	-1.8
ALU0822	2026/2	4	78	0	0	6.4	4.7	-1.7
ALU0823	2026/2	3	83	0	0	7.1	7.0	-0.1
ALU0824	2026/2	4	76	0	0	6.5	6.7	0.2
ALU0825	2026/2	2	88	0	2	7.5	7.0	-0.5
ALU0826	2026/2	3	85	0	2	6.7	8.0	1.3
ALU0827	2026/2	3	84	0	3	3.3	4.3	1.0
ALU0828	2026/2	1	92	0	1	7.6	7.0	-0.6
ALU0829	2026/2	3	82	0	1	5.1	5.1	0.0
ALU0830	2026/2	6	66	0	1	6.7	5.9	-0.8
ALU0831	2026/2	3	81	0	1	6.2	5.8	-0.4
ALU0832	2026/2	3	85	0	1	8.4	8.3	-0.1
ALU0833	2026/2	0	100	0	1	6.9	7.5	0.6
ALU0834	2026/2	4	75	1	1	8.2	7.4	-0.8
ALU0835	2026/2	3	81	0	0	5.2	5.6	0.4
ALU0836	2026/2	6	64	1	1	4.9	6.2	1.3
ALU0837	2026/2	2	89	1	1	8.9	8.2	-0.7
ALU0838	2026/2	1	94	1	0	5.0	6.2	1.2
ALU0839	2026/2	1	93	0	1	8.8	7.7	-1.1
ALU0840	2026/2	2	90	0	1	7.1	7.2	0.1
ALU0841	2026/2	4	77	1	2	8.9	8.0	-0.9
ALU0842	2026/2	2	88	2	1	6.0	6.5	0.5
ALU0843	2026/2	5	74	0	3	3.0	3.7	0.7
ALU0844	2026/2	4	76	0	1	5.6	3.8	-1.8
ALU0845	2026/2	3	82	0	1	4.8	5.9	1.1
ALU0846	2026/2	3	85	1	1	6.7	5.6	-1.1
ALU0847	2026/2	6	66	1	2	5.3	5.4	0.1
ALU0848	2026/2	3	85	1	0	6.0	6.3	0.3
ALU0849	2026/2	0	100	0	0	5.6	5.5	-0.1
ALU0850	2026/2	5	73	0	1	7.7	7.2	-0.5
ALU0851	2026/2	1	97	0	2	4.6	5.8	1.2
ALU0852	2026/2	2	88	0	1	7.5	7.0	-0.5
ALU0853	2026/2	3	85	2	2	7.2	6.4	-0.8
ALU0854	2026/2	0	98	0	1	6.6	8.5	1.9
ALU0855	2026/2	6	64	0	1	4.2	5.2	1.0
ALU0856	2026/2	3	86	0	1	6.0	6.6	0.6
ALU0857	2026/2	4	76	0	2	5.9	7.3	1.4
ALU0858	2026/2	2	87	0	0	4.6	4.3	-0.3
ALU0859	2026/2	6	66	0	2	3.1	3.8	0.7
ALU0860	2026/2	3	86	0	0	5.7	6.7	1.0
ALU0861	2026/2	6	69	1	0	5.3	6.2	0.9
ALU0862	2026/2	4	78	1	1	4.4	5.7	1.3
ALU0863	2026/2	6	69	2	0	6.6	5.3	-1.3
ALU0864	2026/2	3	86	0	1	5.5	7.3	1.8
ALU0865	2026/2	1	95	0	0	7.3	6.7	-0.6
ALU0866	2026/2	9	51	0	2	5.6	3.9	-1.7
ALU0867	2026/2	1	93	0	0	6.5	7.0	0.5
ALU0868	2026/2	2	89	0	1	6.6	7.3	0.7
ALU0869	2026/2	3	86	0	2	6.6	6.8	0.2
ALU0870	2026/2	1	94	1	0	5.9	7.8	1.9
ALU0871	2026/2	4	77	0	1	7.4	8.7	1.3
ALU0872	2026/2	1	93	0	0	8.0	6.4	-1.6
ALU0873	2026/2	4	76	0	1	8.1	7.1	-1.0
ALU0874	2026/2	3	85	0	0	6.6	6.1	-0.5
ALU0875	2026/2	3	83	0	1	6.3	6.3	0.0
ALU0876	2026/2	4	78	0	0	7.3	5.8	-1.5
ALU0877	2026/2	0	100	0	0	6.7	6.5	-0.2
ALU0878	2026/2	6	65	0	3	4.4	5.0	0.6
ALU0879	2026/2	1	93	0	2	6.1	7.0	0.9
ALU0880	2026/2	5	72	0	0	6.2	6.9	0.7
ALU0881	2026/2	0	100	0	2	8.4	7.9	-0.5
ALU0882	2026/2	5	74	0	1	4.7	3.7	-1.0
ALU0883	2026/2	4	79	0	0	8.9	7.5	-1.4
ALU0884	2026/2	3	85	0	0	7.9	7.3	-0.6
ALU0885	2026/2	3	84	0	1	6.8	5.7	-1.1
ALU0886	2026/2	0	100	0	0	7.2	7.0	-0.2
ALU0887	2026/2	1	95	0	0	5.7	5.9	0.2
ALU0888	2026/2	3	84	1	0	8.0	5.7	-2.3
ALU0889	2026/2	4	79	0	2	7.4	6.3	-1.1
ALU0890	2026/2	2	87	0	2	4.6	5.9	1.3
ALU0891	2026/2	2	87	0	2	5.9	6.9	1.0
ALU0892	2026/2	2	88	0	2	7.4	7.0	-0.4
ALU0893	2026/2	6	68	0	0	3.9	4.6	0.7
ALU0894	2026/2	0	100	0	0	3.8	5.4	1.6
ALU0895	2026/2	6	64	0	1	6.2	6.1	-0.1
ALU0896	2026/2	4	80	0	1	7.0	6.8	-0.2
ALU0897	2026/2	2	87	0	1	6.0	7.0	1.0
ALU0898	2026/2	1	95	0	1	4.4	6.4	2.0
ALU0899	2026/2	5	72	1	3	4.3	4.7	0.4
ALU0900	2026/2	0	100	0	0	10.0	8.2	-1.8
ALU0901	2026/2	4	79	0	0	4.7	5.2	0.5
ALU0902	2026/2	2	89	0	0	4.4	6.4	2.0
ALU0903	2026/2	4	80	0	1	5.1	3.6	-1.5
ALU0904	2026/2	3	85	0	2	3.9	4.9	1.0
ALU0905	2026/2	3	85	0	0	8.3	6.9	-1.4
ALU0906	2026/2	4	80	0	0	7.0	6.6	-0.4
ALU0907	2026/2	5	74	2	3	7.0	6.7	-0.3
ALU0908	2026/2	1	92	0	3	5.1	5.8	0.7
ALU0909	2026/2	3	86	0	0	6.8	6.5	-0.3
ALU0910	2026/2	1	94	0	0	5.7	5.5	-0.2
ALU0911	2026/2	2	90	0	1	9.0	8.0	-1.0
ALU0912	2026/2	4	75	0	0	6.2	6.4	0.2
ALU0913	2026/2	2	90	0	1	8.0	6.9	-1.1
ALU0914	2026/2	0	100	0	5	7.9	8.3	0.4
ALU0915	2026/2	5	70	0	2	6.2	4.5	-1.7
ALU0916	2026/2	4	76	0	3	5.7	6.6	0.9
ALU0917	2026/2	4	76	0	1	5.4	6.2	0.8
ALU0918	2026/2	6	67	0	1	7.3	6.4	-0.9
ALU0919	2026/2	8	58	0	3	4.2	4.7	0.5
ALU0920	2026/2	1	95	2	0	6.9	6.4	-0.5
ALU0921	2026/2	4	78	0	4	6.1	5.9	-0.2
ALU0922	2026/2	4	75	0	2	6.7	7.9	1.2
ALU0923	2026/2	3	86	0	2	4.7	6.0	1.3
ALU0924	2026/2	5	70	0	0	7.0	7.0	0.0
ALU0925	2026/2	3	82	0	0	6.6	8.4	1.8
ALU0926	2026/2	2	91	0	0	5.1	4.8	-0.3
ALU0927	2026/2	3	85	0	0	7.7	7.4	-0.3
ALU0928	2026/2	4	76	0	2	6.3	5.7	-0.6
ALU0929	2026/2	5	74	0	2	5.1	5.8	0.7
ALU0930	2026/2	1	95	0	0	7.1	5.2	-1.9
ALU0931	2026/2	4	80	1	1	9.5	8.5	-1.0
ALU0932	2026/2	3	86	1	1	8.1	8.4	0.3
ALU0933	2026/2	4	76	0	1	6.9	6.1	-0.8
ALU0934	2026/2	5	73	1	0	8.9	7.4	-1.5
ALU0935	2026/2	2	89	0	2	3.4	3.7	0.3
ALU0936	2026/2	3	83	0	2	7.6	8.3	0.7
ALU0937	2026/2	5	73	0	4	4.4	6.4	2.0
ALU0938	2026/2	4	75	0	1	8.1	7.2	-0.9
ALU0939	2026/2	4	77	0	1	6.8	6.8	0.0
ALU0940	2026/2	2	91	1	1	7.5	6.6	-0.9
ALU0941	2026/2	2	89	0	0	8.5	7.9	-0.6
ALU0942	2026/2	2	87	0	0	5.4	6.3	0.9
ALU0943	2026/2	6	69	0	2	5.6	5.6	0.0
ALU0944	2026/2	5	74	2	3	4.9	4.5	-0.4
ALU0945	2026/2	2	87	0	1	9.1	8.3	-0.8
ALU0946	2026/2	0	100	0	1	6.5	5.5	-1.0
ALU0947	2026/2	4	77	0	2	6.0	4.9	-1.1
ALU0948	2026/2	1	94	0	2	6.5	7.4	0.9
ALU0949	2026/2	2	87	1	3	3.9	4.8	0.9
ALU0950	2026/2	5	72	0	1	8.5	8.2	-0.3
ALU0951	2026/2	5	73	0	2	4.0	5.4	1.4
ALU0952	2026/2	3	82	1	1	6.3	6.9	0.6
ALU0953	2026/2	6	69	0	0	6.3	6.6	0.3
ALU0954	2026/2	6	68	0	1	6.7	7.8	1.1
ALU0955	2026/2	2	91	0	0	6.1	6.2	0.1
ALU0956	2026/2	3	86	0	2	4.8	5.4	0.6
ALU0957	2026/2	0	99	0	1	8.4	7.8	-0.6
ALU0958	2026/2	3	84	0	3	5.8	6.4	0.6
ALU0959	2026/2	3	82	0	0	5.1	6.0	0.9
ALU0960	2026/2	0	98	0	0	6.1	6.0	-0.1
ALU0961	2026/2	7	62	0	2	5.1	5.1	0.0
ALU0962	2026/2	2	87	0	0	7.8	6.2	-1.6
ALU0963	2026/2	2	90	0	2	5.8	7.2	1.4
ALU0964	2026/2	1	92	0	2	4.6	6.6	2.0
ALU0965	2026/2	5	74	0	0	8.8	8.4	-0.4
ALU0966	2026/2	6	69	1	0	4.7	4.8	0.1
ALU0967	2026/2	3	81	0	0	7.2	6.1	-1.1
ALU0968	2026/2	4	80	0	4	6.0	6.4	0.4
ALU0969	2026/2	3	86	0	0	7.4	7.1	-0.3
ALU0970	2026/2	3	82	0	1	8.2	7.6	-0.6
ALU0971	2026/2	3	85	1	0	7.6	7.3	-0.3
ALU0972	2026/2	5	73	0	2	6.5	5.8	-0.7
ALU0973	2026/2	2	87	0	3	7.2	6.1	-1.1
ALU0974	2026/2	2	91	0	3	7.4	7.0	-0.4
ALU0975	2026/2	4	78	1	3	6.7	6.3	-0.4
ALU0976	2026/2	5	70	0	0	6.6	5.2	-1.4
ALU0977	2026/2	5	74	1	1	9.1	7.6	-1.5
ALU0978	2026/2	5	73	0	0	6.2	6.5	0.3
ALU0979	2026/2	0	98	1	1	7.5	8.9	1.4
ALU0980	2026/2	3	81	0	3	5.9	6.0	0.1
ALU0981	2026/2	4	77	0	1	8.7	7.5	-1.2
ALU0982	2026/2	5	71	0	2	4.1	6.3	2.2
ALU0983	2026/2	2	89	0	0	7.9	8.2	0.3
ALU0984	2026/2	1	96	0	0	5.5	7.5	2.0
ALU0985	2026/2	1	94	0	0	6.5	7.5	1.0
ALU0986	2026/2	3	82	1	0	8.4	7.5	-0.9
ALU0987	2026/2	1	97	0	1	7.9	6.5	-1.4
ALU0988	2026/2	2	88	2	2	7.8	7.8	0.0
ALU0989	2026/2	3	86	0	2	5.1	5.4	0.3
ALU0990	2026/2	7	62	1	1	4.3	5.1	0.8
ALU0991	2026/2	4	76	1	0	4.1	5.6	1.5
ALU0992	2026/2	2	88	0	2	6.2	6.6	0.4
ALU0993	2026/2	3	85	0	1	7.1	6.8	-0.3
ALU0994	2026/2	3	82	1	2	8.0	6.8	-1.2
ALU0995	2026/2	3	82	0	2	5.7	6.9	1.2
ALU0996	2026/2	4	78	0	2	8.0	7.9	-0.1
ALU0997	2026/2	4	78	0	0	7.6	7.2	-0.4
ALU0998	2026/2	0	100	0	0	8.1	7.2	-0.9
ALU0999	2026/2	0	100	0	1	8.3	7.5	-0.8
ALU1000	2026/2	2	87	1	1	5.7	6.6	0.9
\.


--
-- TOC entry 4920 (class 0 OID 16674)
-- Dependencies: 218
-- Data for Name: materias; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.materias (id_materia, id_curso, nome, semestre_grade, carga_horaria_h, media_aprovacao, frequencia_minima_pct) FROM stdin;
IA101	CUR01	Lógica de Programação	1	60	6	75
IA102	CUR01	Algoritmos e Programação I	1	80	6	75
IA103	CUR01	Cálculo I	1	80	6	75
IA104	CUR01	Fundamentos de Inteligência Artificial	1	60	6	75
IA105	CUR01	Matemática Discreta	1	60	6	75
IA106	CUR01	Comunicação e Ética em Tecnologia	1	40	6	75
IA201	CUR01	Algoritmos e Programação II	2	80	6	75
IA202	CUR01	Cálculo II	2	80	6	75
IA203	CUR01	Álgebra Linear	2	60	6	75
IA204	CUR01	Estruturas de Dados	2	80	6	75
IA205	CUR01	Probabilidade e Estatística	2	60	6	75
IA206	CUR01	Arquitetura de Computadores	2	60	6	75
IA301	CUR01	Banco de Dados	3	80	6	75
IA302	CUR01	Programação Orientada a Objetos	3	80	6	75
IA303	CUR01	Estatística Aplicada	3	60	6	75
IA304	CUR01	Sistemas Operacionais	3	60	6	75
IA305	CUR01	Análise de Algoritmos	3	60	6	75
IA306	CUR01	Python para Ciência de Dados	3	60	6	75
IA401	CUR01	Aprendizado de Máquina I	4	80	6	75
IA402	CUR01	Mineração de Dados	4	60	6	75
IA403	CUR01	Engenharia de Software	4	60	6	75
IA404	CUR01	Redes de Computadores	4	60	6	75
IA405	CUR01	Otimização	4	60	6	75
IA406	CUR01	Visualização de Dados	4	40	6	75
IA501	CUR01	Aprendizado de Máquina II	5	80	6	75
IA502	CUR01	Redes Neurais	5	80	6	75
IA503	CUR01	Processamento de Linguagem Natural	5	60	6	75
IA504	CUR01	Banco de Dados Não Relacional	5	60	6	75
IA505	CUR01	Computação em Nuvem	5	60	6	75
IA506	CUR01	Ética e Regulação em IA	5	40	6	75
IA601	CUR01	Aprendizado Profundo	6	80	6	75
IA602	CUR01	Visão Computacional	6	60	6	75
IA603	CUR01	Big Data	6	60	6	75
IA604	CUR01	Sistemas Multiagentes	6	60	6	75
IA605	CUR01	Aprendizado por Reforço	6	60	6	75
IA606	CUR01	Engenharia de Dados	6	60	6	75
IA701	CUR01	IA Generativa	7	60	6	75
IA702	CUR01	MLOps	7	60	6	75
IA703	CUR01	Robótica Inteligente	7	60	6	75
IA704	CUR01	Metodologia Científica	7	40	6	75
IA705	CUR01	Segurança e Privacidade de Dados	7	60	6	75
IA706	CUR01	Trabalho de Conclusão de Curso I	7	80	6	75
IA801	CUR01	Trabalho de Conclusão de Curso II	8	80	6	75
IA802	CUR01	Tópicos Avançados em IA	8	60	6	75
IA803	CUR01	Empreendedorismo em Tecnologia	8	40	6	75
IA804	CUR01	Interação Humano-IA	8	60	6	75
IA805	CUR01	Gestão de Projetos de IA	8	60	6	75
IA806	CUR01	Estágio Supervisionado	8	120	6	75
\.


--
-- TOC entry 4926 (class 0 OID 16704)
-- Dependencies: 224
-- Data for Name: matriculas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.matriculas (id_matricula, id_aluno, id_turma, nota_final, frequencia_pct, situacao, va1, va2, va3) FROM stdin;
MAT01557	ALU0260	IA803-B	74.67	77	Aprovado	77	66	81
MAT05457	ALU0910	IA303-A	79.33	86	Aprovado	63	91	84
MAT02965	ALU0495	IA401-A	79.00	80	Aprovado	93	78	66
MAT01801	ALU0301	IA101-B	72.00	82	Aprovado	72	80	64
MAT05717	ALU0953	IA405-B	81.67	75	Aprovado	88	94	63
MAT03736	ALU0623	IA604-A	84.67	82	Aprovado	74	90	90
MAT05806	ALU0968	IA504-B	77.00	98	Aprovado	88	81	62
MAT05811	ALU0969	IA203-B	78.33	86	Aprovado	71	82	82
MAT02001	ALU0334	IA203-A	91.33	88	Aprovado	81	96	97
MAT01163	ALU0194	IA505-A	76.67	86	Aprovado	90	73	67
MAT00298	ALU0050	IA304-B	86.67	80	Aprovado	100	77	83
MAT04147	ALU0692	IA201-B	78.00	88	Aprovado	75	90	69
MAT00734	ALU0123	IA102-B	73.00	99	Aprovado	68	89	62
MAT02755	ALU0460	IA501-B	74.33	78	Aprovado	69	67	87
MAT04660	ALU0777	IA304-B	72.67	75	Aprovado	64	86	68
MAT05162	ALU0861	IA202-B	86.00	97	Aprovado	95	73	90
MAT05853	ALU0976	IA303-A	83.33	91	Aprovado	73	93	84
MAT04903	ALU0818	IA701-A	91.67	77	Aprovado	91	99	85
MAT00270	ALU0045	IA106-B	76.00	99	Aprovado	82	70	76
MAT01075	ALU0180	IA501-B	79.67	95	Aprovado	74	86	79
MAT05437	ALU0907	IA201-B	82.00	84	Aprovado	70	83	93
MAT04143	ALU0691	IA503-B	75.00	78	Aprovado	89	73	63
MAT05772	ALU0962	IA306-B	86.00	88	Aprovado	97	81	80
MAT00020	ALU0004	IA702-A	87.00	87	Aprovado	99	66	96
MAT05288	ALU0882	IA402-B	82.67	89	Aprovado	63	88	97
MAT00461	ALU0077	IA405-A	81.67	84	Aprovado	63	85	97
MAT00406	ALU0068	IA104-A	85.00	85	Aprovado	97	64	94
MAT03379	ALU0564	IA201-B	86.00	78	Aprovado	67	99	92
MAT05173	ALU0863	IA601-B	73.00	86	Aprovado	81	61	77
MAT00316	ALU0053	IA804-A	85.33	99	Aprovado	88	83	85
MAT02488	ALU0415	IA804-B	82.00	86	Aprovado	60	93	93
MAT00524	ALU0088	IA802-B	78.33	81	Aprovado	88	82	65
MAT05068	ALU0845	IA504-B	77.33	78	Aprovado	71	93	68
MAT05576	ALU0930	IA102-A	83.33	80	Aprovado	100	85	65
MAT00245	ALU0041	IA305-A	71.00	86	Aprovado	84	66	63
MAT02461	ALU0411	IA401-B	79.33	87	Aprovado	85	67	86
MAT02240	ALU0374	IA302-B	73.67	92	Aprovado	60	93	68
MAT00147	ALU0025	IA703-B	79.67	97	Aprovado	70	79	90
MAT00667	ALU0112	IA401-B	72.00	84	Aprovado	60	86	70
MAT01910	ALU0319	IA302-B	69.33	97	Aprovado	66	78	64
MAT03790	ALU0632	IA804-B	74.00	100	Aprovado	70	72	80
MAT05660	ALU0944	IA102-B	91.33	77	Aprovado	90	89	95
MAT05395	ALU0900	IA301-A	74.67	84	Aprovado	74	83	67
MAT02964	ALU0494	IA506-A	81.00	99	Aprovado	65	90	88
MAT02758	ALU0460	IA504-B	72.33	82	Aprovado	74	76	67
MAT00675	ALU0113	IA703-B	80.00	97	Aprovado	77	78	85
MAT03472	ALU0579	IA104-A	76.00	98	Aprovado	64	94	70
MAT01846	ALU0308	IA104-A	86.67	75	Aprovado	78	87	95
MAT03725	ALU0621	IA405-B	73.67	79	Aprovado	78	79	64
MAT02541	ALU0424	IA603-A	82.67	79	Aprovado	100	66	82
MAT05744	ALU0958	IA502-B	75.67	77	Aprovado	69	63	95
MAT00922	ALU0154	IA604-A	88.00	80	Aprovado	94	98	72
MAT04302	ALU0717	IA106-B	82.33	83	Aprovado	93	81	73
MAT00220	ALU0037	IA304-B	90.00	91	Aprovado	82	90	98
MAT01999	ALU0334	IA201-A	77.00	90	Aprovado	71	80	80
MAT01417	ALU0237	IA301-B	76.00	87	Aprovado	96	61	71
MAT01553	ALU0259	IA405-A	68.00	90	Aprovado	81	60	63
MAT02252	ALU0376	IA802-B	81.33	91	Aprovado	91	74	79
MAT02172	ALU0362	IA406-B	79.67	82	Aprovado	68	96	75
MAT00206	ALU0035	IA502-B	67.00	96	Aprovado	62	70	69
MAT05604	ALU0934	IA606-A	69.33	87	Aprovado	65	71	72
MAT00195	ALU0033	IA203-B	73.67	81	Aprovado	67	78	76
MAT02004	ALU0334	IA206-A	74.67	88	Aprovado	74	76	74
MAT02869	ALU0479	IA401-B	91.33	78	Aprovado	100	97	77
MAT01268	ALU0212	IA402-B	86.33	95	Aprovado	94	75	90
MAT01372	ALU0229	IA204-A	73.67	90	Aprovado	74	67	80
MAT03536	ALU0590	IA102-B	76.33	96	Aprovado	73	78	78
MAT00744	ALU0124	IA806-B	87.00	83	Aprovado	87	93	81
MAT02937	ALU0490	IA403-B	75.00	85	Aprovado	79	73	73
MAT02366	ALU0395	IA302-B	77.00	99	Aprovado	80	85	66
MAT02996	ALU0500	IA702-A	81.67	92	Aprovado	94	66	85
MAT01717	ALU0287	IA501-A	79.33	93	Aprovado	63	99	76
MAT05946	ALU0991	IA206-B	82.67	99	Aprovado	76	76	96
MAT02956	ALU0493	IA304-A	85.67	96	Aprovado	98	82	77
MAT04140	ALU0690	IA306-B	83.67	82	Aprovado	62	99	90
MAT01638	ALU0273	IA406-A	80.00	88	Aprovado	88	76	76
MAT01806	ALU0301	IA106-B	86.33	77	Aprovado	82	100	77
MAT00883	ALU0148	IA201-A	93.00	92	Aprovado	93	87	99
MAT02538	ALU0423	IA606-A	73.00	86	Aprovado	75	73	71
MAT02316	ALU0386	IA606-A	84.67	98	Aprovado	97	79	78
MAT04045	ALU0675	IA301-A	77.33	82	Aprovado	72	98	62
MAT05924	ALU0988	IA202-B	85.67	81	Aprovado	81	94	82
MAT00954	ALU0159	IA306-B	76.00	79	Aprovado	96	69	63
MAT01151	ALU0192	IA405-B	88.00	90	Aprovado	91	82	91
MAT02037	ALU0340	IA103-B	72.00	84	Aprovado	84	66	66
MAT02826	ALU0471	IA306-B	73.00	76	Aprovado	78	76	65
MAT00425	ALU0071	IA405-B	72.33	85	Aprovado	71	72	74
MAT05755	ALU0960	IA801-A	84.33	79	Aprovado	88	89	76
MAT00528	ALU0088	IA806-B	80.00	95	Aprovado	81	65	94
MAT04799	ALU0800	IA605-B	78.00	87	Aprovado	60	76	98
MAT02548	ALU0425	IA804-B	73.67	91	Aprovado	62	83	76
MAT05626	ALU0938	IA304-B	79.33	85	Aprovado	84	78	76
MAT05354	ALU0893	IA802-B	80.00	89	Aprovado	85	83	72
MAT01711	ALU0286	IA201-A	88.00	83	Aprovado	91	79	94
MAT03727	ALU0622	IA101-B	70.33	77	Aprovado	79	61	71
MAT00274	ALU0046	IA504-B	89.67	79	Aprovado	94	83	92
MAT00205	ALU0035	IA501-B	76.00	99	Aprovado	85	81	62
MAT01527	ALU0255	IA503-A	88.33	84	Aprovado	87	78	100
MAT00740	ALU0124	IA802-B	91.00	97	Aprovado	85	95	93
MAT05009	ALU0835	IA305-B	77.67	92	Aprovado	71	75	87
MAT00604	ALU0101	IA204-A	78.33	92	Aprovado	66	69	100
MAT03466	ALU0578	IA204-A	87.67	98	Aprovado	97	96	70
MAT02569	ALU0429	IA401-A	84.33	84	Aprovado	77	98	78
MAT00909	ALU0152	IA403-A	79.33	93	Aprovado	69	71	98
MAT00798	ALU0133	IA706-B	76.67	84	Aprovado	91	73	66
MAT00946	ALU0158	IA104-B	82.00	92	Aprovado	89	65	92
MAT03205	ALU0535	IA101-B	72.00	80	Aprovado	70	67	79
MAT00512	ALU0086	IA802-A	87.00	78	Aprovado	77	88	96
MAT01277	ALU0213	IA205-B	95.00	80	Aprovado	95	99	91
MAT01319	ALU0220	IA605-B	88.33	87	Aprovado	97	74	94
MAT01228	ALU0205	IA604-A	70.00	86	Aprovado	77	63	70
MAT02129	ALU0355	IA505-B	91.00	92	Aprovado	87	98	88
MAT02044	ALU0341	IA404-B	77.33	91	Aprovado	82	82	68
MAT01364	ALU0228	IA402-B	87.00	78	Aprovado	97	64	100
MAT02938	ALU0490	IA404-B	80.00	85	Aprovado	72	98	70
MAT00724	ALU0121	IA504-B	74.67	95	Aprovado	64	79	81
MAT00325	ALU0055	IA201-A	80.00	88	Aprovado	90	75	75
MAT01260	ALU0210	IA206-B	72.33	82	Aprovado	69	84	64
MAT03990	ALU0665	IA606-B	86.33	79	Aprovado	94	83	82
MAT01221	ALU0204	IA803-B	79.67	76	Aprovado	87	71	81
MAT00792	ALU0132	IA606-B	73.33	83	Aprovado	62	78	80
MAT05826	ALU0971	IA606-B	81.67	88	Aprovado	86	86	73
MAT02394	ALU0399	IA806-B	78.67	76	Aprovado	96	71	69
MAT03711	ALU0619	IA203-B	92.67	75	Aprovado	95	86	97
MAT05613	ALU0936	IA303-B	77.00	85	Aprovado	61	89	81
MAT00843	ALU0141	IA803-B	88.00	76	Aprovado	76	100	88
MAT05533	ALU0923	IA501-A	83.33	80	Aprovado	87	65	98
MAT03203	ALU0534	IA605-B	87.00	89	Aprovado	85	100	76
MAT02520	ALU0420	IA606-A	64.00	76	Aprovado	68	63	61
MAT04228	ALU0705	IA204-A	77.67	92	Aprovado	75	73	85
MAT03523	ALU0588	IA401-A	75.00	95	Aprovado	78	73	74
MAT04418	ALU0737	IA702-B	83.67	91	Aprovado	87	100	64
MAT03034	ALU0506	IA604-B	75.67	82	Aprovado	65	71	91
MAT01550	ALU0259	IA402-A	84.00	94	Aprovado	91	97	64
MAT00238	ALU0040	IA304-A	87.33	98	Aprovado	82	84	96
MAT05099	ALU0850	IA105-B	75.00	97	Aprovado	74	85	66
MAT03460	ALU0577	IA804-A	81.33	98	Aprovado	69	94	81
MAT03106	ALU0518	IA104-B	84.00	92	Aprovado	64	96	92
MAT05523	ALU0921	IA703-A	70.67	78	Aprovado	65	78	69
MAT02603	ALU0434	IA705-A	75.67	92	Aprovado	98	66	63
MAT05520	ALU0920	IA806-A	77.33	75	Aprovado	93	66	73
MAT02943	ALU0491	IA203-B	82.67	77	Aprovado	86	69	93
MAT05560	ALU0927	IA604-B	68.67	77	Aprovado	69	63	74
MAT01471	ALU0246	IA801-A	71.00	82	Aprovado	62	63	88
MAT03732	ALU0622	IA106-B	68.67	90	Aprovado	68	63	75
MAT01190	ALU0199	IA302-A	84.67	90	Aprovado	95	60	99
MAT01549	ALU0259	IA401-A	85.00	83	Aprovado	89	87	79
MAT01259	ALU0210	IA205-B	77.67	93	Aprovado	80	69	84
MAT04844	ALU0808	IA302-B	79.00	98	Aprovado	85	65	87
MAT01312	ALU0219	IA104-A	83.67	97	Aprovado	78	74	99
MAT00796	ALU0133	IA704-B	79.67	93	Aprovado	81	87	71
MAT03073	ALU0513	IA201-A	80.00	82	Aprovado	98	72	70
MAT03258	ALU0543	IA206-A	83.33	96	Aprovado	73	98	79
MAT02962	ALU0494	IA504-A	81.00	90	Aprovado	81	82	80
MAT05801	ALU0967	IA405-B	74.67	78	Aprovado	72	67	85
MAT01169	ALU0195	IA305-B	74.67	96	Aprovado	88	67	69
MAT02721	ALU0454	IA603-B	76.67	76	Aprovado	60	74	96
MAT01964	ALU0328	IA202-B	79.67	77	Aprovado	70	83	86
MAT00725	ALU0121	IA505-B	88.33	93	Aprovado	82	100	83
MAT02599	ALU0434	IA701-A	79.67	87	Aprovado	79	72	88
MAT05807	ALU0968	IA505-B	74.00	97	Aprovado	93	65	64
MAT00062	ALU0011	IA102-A	89.67	75	Aprovado	75	94	100
MAT02476	ALU0413	IA204-B	79.33	97	Aprovado	97	78	63
MAT01700	ALU0284	IA602-A	77.67	88	Aprovado	97	68	68
MAT01281	ALU0214	IA503-A	73.33	94	Aprovado	93	61	66
MAT02959	ALU0494	IA501-A	83.00	95	Aprovado	64	86	99
MAT01561	ALU0261	IA101-A	75.00	91	Aprovado	67	62	96
MAT02039	ALU0340	IA105-B	84.00	100	Aprovado	100	60	92
MAT03350	ALU0559	IA402-A	83.67	79	Aprovado	91	67	93
MAT05809	ALU0969	IA201-B	72.00	75	Aprovado	64	85	67
MAT04886	ALU0815	IA202-A	69.67	75	Aprovado	63	64	82
MAT04406	ALU0735	IA402-A	87.67	75	Aprovado	99	92	72
MAT04652	ALU0776	IA402-B	77.33	83	Aprovado	65	85	82
MAT02471	ALU0412	IA605-B	74.67	86	Aprovado	72	91	61
MAT03625	ALU0605	IA301-A	77.33	84	Aprovado	92	60	80
MAT01610	ALU0269	IA602-B	73.00	84	Aprovado	82	63	74
MAT01183	ALU0198	IA401-A	77.33	79	Aprovado	62	95	75
MAT00694	ALU0116	IA704-A	74.00	85	Aprovado	100	62	60
MAT00217	ALU0037	IA301-B	83.67	77	Aprovado	90	81	80
MAT05231	ALU0872	IA205-A	81.33	100	Aprovado	74	72	98
MAT01240	ALU0207	IA304-A	91.00	85	Aprovado	91	95	87
MAT01581	ALU0264	IA103-B	66.33	75	Aprovado	75	61	63
MAT02138	ALU0357	IA802-A	75.67	98	Aprovado	81	66	80
MAT04874	ALU0813	IA502-A	78.33	96	Aprovado	61	86	88
MAT02487	ALU0415	IA803-B	84.67	91	Aprovado	67	93	94
MAT01303	ALU0218	IA401-B	73.00	84	Aprovado	75	64	80
MAT04288	ALU0715	IA304-B	75.67	86	Aprovado	60	99	68
MAT05999	ALU1000	IA105-A	65.33	84	Aprovado	63	69	64
MAT03217	ALU0537	IA401-B	83.33	98	Aprovado	70	80	100
MAT05943	ALU0991	IA203-B	71.00	77	Aprovado	69	70	74
MAT05322	ALU0887	IA606-B	76.00	83	Aprovado	62	85	81
MAT02850	ALU0475	IA806-B	93.67	93	Aprovado	92	96	93
MAT01187	ALU0198	IA405-A	72.67	75	Aprovado	70	63	85
MAT01117	ALU0187	IA101-B	93.00	92	Aprovado	98	86	95
MAT00743	ALU0124	IA805-B	85.33	83	Aprovado	93	83	80
MAT03922	ALU0654	IA404-B	78.67	76	Aprovado	78	96	62
MAT05511	ALU0919	IA103-A	71.33	77	Aprovado	64	83	67
MAT05194	ALU0866	IA304-B	88.67	82	Aprovado	89	98	79
MAT00713	ALU0119	IA405-B	77.67	78	Aprovado	80	91	62
MAT05167	ALU0862	IA501-B	82.00	93	Aprovado	69	91	86
MAT00700	ALU0117	IA504-A	88.33	81	Aprovado	100	94	71
MAT00422	ALU0071	IA402-B	81.33	79	Aprovado	90	72	82
MAT04964	ALU0828	IA802-B	73.67	84	Aprovado	66	93	62
MAT03819	ALU0637	IA603-B	81.00	83	Aprovado	95	88	60
MAT04796	ALU0800	IA602-B	78.67	95	Aprovado	100	72	64
MAT02747	ALU0458	IA205-B	74.00	96	Aprovado	60	64	98
MAT03651	ALU0609	IA303-A	78.00	82	Aprovado	94	71	69
MAT02489	ALU0415	IA805-B	73.67	99	Aprovado	83	62	76
MAT02154	ALU0359	IA406-B	70.67	80	Aprovado	75	72	65
MAT04986	ALU0831	IA506-B	87.33	75	Aprovado	98	95	69
MAT05070	ALU0845	IA506-B	80.67	81	Aprovado	84	61	97
MAT01083	ALU0181	IA703-B	78.67	79	Aprovado	65	72	99
MAT05951	ALU0992	IA305-A	68.33	89	Aprovado	61	65	79
MAT00407	ALU0068	IA105-A	70.33	92	Aprovado	62	69	80
MAT05507	ALU0918	IA805-A	80.00	95	Aprovado	94	81	65
MAT02116	ALU0353	IA304-B	85.00	89	Aprovado	80	97	78
MAT00947	ALU0158	IA105-B	78.00	79	Aprovado	98	68	68
MAT05258	ALU0877	IA102-B	95.33	82	Aprovado	98	91	97
MAT01724	ALU0288	IA202-B	92.00	92	Aprovado	92	90	94
MAT04386	ALU0731	IA806-B	82.33	96	Aprovado	89	72	86
MAT03406	ALU0568	IA704-A	78.33	78	Aprovado	73	72	90
MAT05829	ALU0972	IA303-A	82.00	82	Aprovado	71	81	94
MAT03084	ALU0514	IA206-B	77.00	87	Aprovado	76	73	82
MAT00287	ALU0048	IA805-A	78.00	82	Aprovado	100	60	74
MAT03190	ALU0532	IA204-A	81.33	93	Aprovado	91	89	64
MAT01940	ALU0324	IA602-B	68.00	93	Aprovado	60	74	70
MAT04130	ALU0689	IA602-A	70.33	80	Aprovado	76	63	72
MAT01974	ALU0329	IA106-B	86.33	99	Aprovado	76	89	94
MAT00125	ALU0021	IA105-B	81.67	86	Aprovado	95	62	88
MAT00939	ALU0157	IA203-A	78.00	98	Aprovado	73	62	99
MAT01064	ALU0178	IA602-B	75.00	79	Aprovado	66	65	94
MAT02887	ALU0482	IA801-B	84.67	78	Aprovado	89	73	92
MAT04432	ALU0739	IA104-A	84.67	81	Aprovado	75	94	85
MAT02107	ALU0352	IA201-A	88.67	98	Aprovado	69	100	97
MAT01950	ALU0325	IA606-B	74.33	98	Aprovado	70	64	89
MAT05802	ALU0967	IA406-B	65.00	75	Aprovado	62	68	65
MAT01215	ALU0203	IA103-A	87.00	83	Aprovado	97	70	94
MAT01805	ALU0301	IA105-B	76.33	77	Aprovado	84	65	80
MAT00680	ALU0114	IA802-B	81.33	91	Aprovado	91	87	66
MAT00625	ALU0105	IA801-B	89.00	79	Aprovado	71	96	100
MAT00793	ALU0133	IA701-B	89.00	80	Aprovado	75	95	97
MAT01807	ALU0302	IA801-B	78.33	87	Aprovado	100	64	71
MAT02951	ALU0492	IA705-B	88.67	91	Aprovado	99	68	99
MAT01231	ALU0206	IA501-A	92.33	92	Aprovado	96	85	96
MAT03518	ALU0587	IA802-A	44.00	59	Reprovado	48	43	41
MAT02819	ALU0470	IA205-B	15.33	54	Reprovado	19	27	0
MAT02536	ALU0423	IA604-A	46.33	62	Reprovado	46	36	57
MAT03427	ALU0572	IA201-A	30.67	66	Reprovado	8	49	35
MAT02757	ALU0460	IA503-B	41.33	73	Reprovado	43	25	56
MAT01161	ALU0194	IA503-A	8.67	42	Reprovado	0	18	8
MAT01309	ALU0219	IA101-A	36.00	99	Reprovado	13	41	54
MAT02273	ALU0379	IA705-A	22.33	72	Reprovado	21	2	44
MAT01579	ALU0264	IA101-B	43.67	46	Reprovado	48	58	25
MAT01302	ALU0217	IA506-B	28.67	40	Reprovado	30	12	44
MAT00800	ALU0134	IA502-A	12.33	77	Reprovado	4	16	17
MAT05404	ALU0901	IA204-A	83.67	100	Aprovado	75	94	82
MAT01572	ALU0262	IA406-B	37.00	53	Reprovado	54	46	11
MAT05369	ALU0895	IA505-A	27.00	55	Reprovado	39	35	7
MAT03616	ALU0603	IA804-A	20.00	75	Reprovado	27	21	12
MAT02794	ALU0466	IA604-B	3.67	71	Reprovado	10	0	1
MAT04474	ALU0746	IA104-B	47.67	47	Reprovado	54	54	35
MAT02708	ALU0452	IA402-B	24.00	93	Reprovado	27	8	37
MAT01904	ALU0318	IA402-A	28.33	73	Reprovado	46	39	0
MAT01569	ALU0262	IA403-B	34.33	56	Reprovado	33	45	25
MAT04144	ALU0691	IA504-B	48.33	77	Reprovado	56	47	42
MAT04438	ALU0740	IA804-B	43.00	36	Reprovado	23	57	49
MAT00650	ALU0109	IA202-A	36.00	40	Reprovado	40	37	31
MAT02305	ALU0385	IA501-B	41.00	80	Reprovado	54	17	52
MAT02205	ALU0368	IA403-B	21.33	43	Reprovado	40	21	3
MAT05389	ALU0899	IA701-B	29.67	76	Reprovado	20	36	33
MAT02038	ALU0340	IA104-B	19.33	66	Reprovado	49	3	6
MAT05663	ALU0944	IA105-B	27.00	68	Reprovado	19	29	33
MAT00247	ALU0042	IA501-B	28.67	81	Reprovado	29	9	48
MAT05059	ALU0844	IA201-A	43.33	33	Reprovado	57	29	44
MAT05810	ALU0969	IA202-B	10.67	45	Reprovado	12	5	15
MAT03709	ALU0619	IA201-B	24.33	79	Reprovado	0	28	45
MAT04649	ALU0775	IA805-B	33.00	41	Reprovado	16	26	57
MAT00612	ALU0102	IA506-A	20.00	89	Reprovado	4	7	49
MAT04873	ALU0813	IA501-A	42.00	97	Reprovado	27	57	42
MAT05076	ALU0846	IA206-A	26.33	93	Reprovado	18	24	37
MAT01474	ALU0246	IA804-A	24.33	72	Reprovado	1	47	25
MAT00827	ALU0138	IA205-A	48.00	83	Reprovado	51	41	52
MAT05566	ALU0928	IA804-B	27.00	42	Reprovado	7	26	48
MAT00837	ALU0140	IA203-A	28.33	78	Reprovado	19	28	38
MAT00179	ALU0030	IA705-B	33.00	38	Reprovado	4	50	45
MAT01153	ALU0193	IA501-A	39.33	79	Reprovado	43	37	38
MAT02436	ALU0406	IA406-B	32.33	50	Reprovado	17	22	58
MAT01601	ALU0267	IA605-A	26.33	49	Reprovado	57	0	22
MAT04037	ALU0673	IA405-B	32.67	93	Reprovado	36	7	55
MAT03451	ALU0576	IA501-A	9.33	55	Reprovado	19	0	9
MAT01480	ALU0247	IA204-B	19.67	61	Reprovado	21	38	0
MAT02329	ALU0389	IA701-B	18.33	91	Reprovado	34	21	0
MAT02667	ALU0445	IA803-B	19.00	91	Reprovado	35	14	8
MAT02430	ALU0405	IA806-A	21.00	61	Reprovado	25	15	23
MAT05561	ALU0927	IA605-B	14.33	55	Reprovado	12	18	13
MAT00289	ALU0049	IA501-B	17.33	88	Reprovado	17	34	1
MAT03446	ALU0575	IA402-A	29.33	47	Reprovado	14	54	20
MAT01983	ALU0331	IA403-A	33.67	68	Reprovado	28	16	57
MAT02429	ALU0405	IA805-A	51.33	40	Reprovado	55	50	49
MAT00457	ALU0077	IA401-A	11.33	100	Reprovado	18	5	11
MAT01057	ALU0177	IA701-B	34.00	91	Reprovado	24	47	31
MAT03102	ALU0517	IA606-B	27.67	89	Reprovado	33	28	22
MAT02528	ALU0422	IA402-B	40.00	41	Reprovado	37	26	57
MAT00290	ALU0049	IA502-B	26.33	49	Reprovado	2	51	26
MAT03648	ALU0608	IA506-B	26.00	65	Reprovado	49	18	11
MAT03999	ALU0667	IA603-A	35.33	77	Reprovado	24	50	32
MAT02814	ALU0469	IA606-B	21.33	100	Reprovado	31	25	8
MAT04861	ALU0811	IA401-B	38.00	37	Reprovado	41	44	29
MAT04976	ALU0830	IA202-B	35.00	56	Reprovado	0	47	58
MAT01769	ALU0295	IA405-B	31.33	65	Reprovado	39	54	1
MAT01462	ALU0244	IA304-B	25.67	49	Reprovado	3	35	39
MAT02855	ALU0476	IA405-B	28.67	57	Reprovado	25	15	46
MAT04963	ALU0828	IA801-B	29.00	49	Reprovado	59	4	24
MAT02953	ALU0493	IA301-A	20.00	55	Reprovado	27	3	30
MAT01224	ALU0204	IA806-B	25.00	57	Reprovado	39	35	1
MAT00671	ALU0112	IA405-B	15.33	92	Reprovado	17	12	17
MAT05148	ALU0858	IA206-B	19.33	80	Reprovado	12	12	34
MAT00646	ALU0108	IA404-A	34.33	75	Reprovado	53	40	10
MAT05791	ALU0966	IA601-B	33.67	33	Reprovado	58	38	5
MAT01588	ALU0265	IA304-B	33.00	30	Reprovado	33	55	11
MAT03426	ALU0571	IA806-A	15.33	39	Reprovado	29	9	8
MAT05192	ALU0866	IA302-B	75.00	95	Aprovado	68	97	60
MAT04817	ALU0803	IA805-B	56.00	39	Reprovado	54	57	57
MAT05320	ALU0887	IA604-B	53.33	82	Reprovado	58	57	45
MAT01059	ALU0177	IA703-B	23.33	73	Reprovado	14	36	20
MAT01626	ALU0271	IA106-B	33.00	51	Reprovado	39	5	55
MAT02566	ALU0428	IA204-A	17.67	57	Reprovado	26	23	4
MAT01912	ALU0319	IA304-B	50.33	44	Reprovado	44	55	52
MAT01046	ALU0175	IA302-B	13.00	59	Reprovado	21	12	6
MAT00409	ALU0069	IA101-A	42.33	65	Reprovado	54	35	38
MAT05542	ALU0924	IA604-B	36.67	42	Reprovado	16	58	36
MAT01977	ALU0330	IA603-B	22.67	34	Reprovado	34	28	6
MAT03512	ALU0586	IA202-B	21.00	91	Reprovado	5	21	37
MAT02251	ALU0376	IA801-B	20.00	42	Reprovado	19	15	26
MAT00634	ALU0106	IA504-B	27.67	49	Reprovado	26	55	2
MAT02676	ALU0446	IA206-B	26.00	52	Reprovado	31	41	6
MAT00467	ALU0078	IA105-A	38.00	39	Reprovado	44	38	32
MAT02426	ALU0405	IA802-A	43.00	37	Reprovado	43	29	57
MAT00656	ALU0110	IA202-B	25.00	54	Reprovado	37	15	23
MAT05181	ALU0864	IA103-A	16.67	89	Reprovado	16	31	3
MAT00940	ALU0157	IA204-A	20.67	85	Reprovado	31	27	4
MAT03986	ALU0665	IA602-B	32.67	44	Reprovado	14	30	54
MAT02597	ALU0433	IA805-A	43.33	39	Reprovado	49	47	34
MAT02444	ALU0408	IA602-B	34.00	31	Reprovado	52	47	3
MAT02880	ALU0480	IA306-A	24.67	32	Reprovado	29	6	39
MAT02226	ALU0371	IA706-B	22.33	42	Reprovado	1	29	37
MAT02462	ALU0411	IA402-B	41.67	81	Reprovado	35	50	40
MAT04146	ALU0691	IA506-B	20.00	39	Reprovado	25	18	17
MAT03988	ALU0665	IA604-B	18.67	63	Reprovado	48	4	4
MAT05272	ALU0879	IA304-B	28.33	57	Reprovado	33	16	36
MAT02342	ALU0391	IA702-A	10.67	94	Reprovado	16	15	1
MAT01754	ALU0293	IA802-B	27.67	55	Reprovado	49	20	14
MAT01854	ALU0309	IA106-B	36.00	80	Reprovado	22	42	44
MAT00595	ALU0100	IA401-B	31.67	45	Reprovado	28	53	14
MAT02162	ALU0361	IA202-B	40.33	69	Reprovado	57	34	30
MAT04951	ALU0826	IA601-B	25.00	68	Reprovado	47	18	10
MAT00005	ALU0001	IA205-B	23.00	69	Reprovado	13	42	14
MAT05502	ALU0917	IA206-B	31.67	86	Reprovado	45	42	8
MAT00239	ALU0040	IA305-A	35.33	42	Reprovado	31	44	31
MAT03468	ALU0578	IA206-A	31.67	34	Reprovado	28	31	36
MAT05105	ALU0851	IA305-A	34.33	94	Reprovado	55	39	9
MAT05394	ALU0899	IA706-B	29.67	86	Reprovado	0	44	45
MAT02530	ALU0422	IA404-B	33.67	75	Reprovado	49	12	40
MAT05950	ALU0992	IA304-A	26.33	57	Reprovado	1	55	23
MAT01731	ALU0289	IA403-B	46.33	58	Reprovado	58	22	59
MAT05058	ALU0843	IA706-B	51.67	97	Reprovado	58	44	53
MAT02760	ALU0460	IA506-B	50.33	44	Reprovado	57	49	45
MAT05418	ALU0903	IA306-B	12.67	38	Reprovado	12	15	11
MAT02567	ALU0428	IA205-A	20.67	95	Reprovado	14	23	25
MAT01317	ALU0220	IA603-B	47.33	94	Reprovado	54	35	53
MAT00699	ALU0117	IA503-A	20.33	48	Reprovado	21	25	15
MAT01918	ALU0320	IA704-B	38.33	51	Reprovado	44	43	28
MAT04000	ALU0667	IA604-A	30.00	96	Reprovado	44	12	34
MAT01307	ALU0218	IA405-B	24.67	73	Reprovado	44	7	23
MAT00823	ALU0138	IA201-A	14.00	32	Reprovado	5	21	16
MAT00482	ALU0081	IA402-B	31.00	97	Reprovado	20	39	34
MAT00747	ALU0125	IA303-B	43.33	67	Reprovado	45	55	30
MAT02218	ALU0370	IA604-B	27.00	61	Reprovado	43	3	35
MAT01304	ALU0218	IA402-B	37.00	38	Reprovado	47	39	25
MAT01357	ALU0227	IA501-B	28.33	79	Reprovado	23	24	38
MAT01376	ALU0230	IA802-B	14.67	46	Reprovado	4	38	2
MAT00727	ALU0122	IA501-B	14.33	81	Reprovado	8	20	15
MAT01271	ALU0212	IA405-B	48.33	78	Reprovado	44	47	54
MAT03257	ALU0543	IA205-A	13.33	86	Reprovado	25	7	8
MAT00503	ALU0084	IA205-B	73.00	77	Aprovado	88	68	63
MAT00025	ALU0005	IA401-B	22.33	87	Reprovado	45	3	19
MAT02323	ALU0388	IA801-B	21.33	76	Reprovado	23	27	14
MAT03541	ALU0591	IA601-B	36.00	36	Reprovado	45	33	30
MAT01913	ALU0319	IA305-B	37.67	92	Reprovado	28	37	48
MAT01968	ALU0328	IA206-B	27.67	68	Reprovado	46	7	30
MAT00183	ALU0031	IA603-B	33.33	87	Reprovado	8	33	59
MAT05316	ALU0886	IA706-B	30.33	71	Reprovado	25	29	37
MAT00677	ALU0113	IA705-B	22.67	100	Reprovado	12	41	15
MAT05419	ALU0904	IA501-B	45.33	53	Reprovado	40	42	54
MAT01056	ALU0176	IA206-B	29.33	67	Reprovado	13	22	53
MAT04526	ALU0755	IA602-B	18.67	80	Reprovado	24	7	25
MAT02540	ALU0424	IA602-A	28.67	71	Reprovado	17	43	26
MAT05054	ALU0843	IA702-B	39.67	91	Reprovado	37	29	53
MAT02283	ALU0381	IA703-B	37.33	55	Reprovado	47	37	28
MAT02677	ALU0447	IA101-B	41.33	70	Reprovado	19	52	53
MAT02295	ALU0383	IA503-A	16.67	53	Reprovado	15	3	32
MAT03430	ALU0572	IA204-A	30.00	44	Reprovado	55	26	9
MAT02645	ALU0441	IA605-B	18.33	81	Reprovado	1	5	49
MAT01882	ALU0314	IA104-B	24.33	75	Reprovado	44	26	3
MAT01092	ALU0182	IA806-A	45.33	49	Reprovado	48	41	47
MAT05382	ALU0897	IA506-B	44.00	31	Reprovado	59	26	47
MAT02749	ALU0459	IA701-A	32.67	77	Reprovado	38	7	53
MAT02767	ALU0462	IA601-A	39.67	51	Reprovado	6	57	56
MAT01908	ALU0318	IA406-A	24.00	38	Reprovado	2	38	32
MAT00536	ALU0090	IA102-B	45.00	88	Reprovado	57	26	52
MAT01829	ALU0305	IA305-B	32.67	30	Reprovado	29	38	31
MAT02978	ALU0497	IA602-B	12.67	60	Reprovado	16	6	16
MAT02056	ALU0343	IA404-A	40.00	97	Reprovado	39	54	27
MAT03018	ALU0503	IA706-B	24.33	98	Reprovado	9	35	29
MAT02896	ALU0483	IA504-B	31.67	69	Reprovado	38	52	5
MAT00881	ALU0147	IA205-B	28.67	32	Reprovado	12	42	32
MAT05109	ALU0852	IA703-A	31.00	33	Reprovado	30	22	41
MAT03707	ALU0618	IA205-B	45.33	84	Reprovado	46	50	40
MAT02221	ALU0371	IA701-B	35.33	93	Reprovado	34	59	13
MAT00711	ALU0119	IA403-B	29.67	78	Reprovado	47	42	0
MAT01843	ALU0308	IA101-A	36.00	45	Reprovado	9	43	56
MAT01401	ALU0234	IA203-A	25.67	80	Reprovado	42	4	31
MAT00561	ALU0094	IA603-A	35.33	63	Reprovado	35	39	32
MAT05923	ALU0988	IA201-B	17.67	55	Reprovado	29	19	5
MAT05001	ALU0834	IA103-B	35.00	50	Reprovado	45	56	4
MAT05032	ALU0839	IA204-B	43.33	99	Reprovado	49	56	25
MAT05152	ALU0859	IA204-B	32.33	63	Reprovado	20	59	18
MAT00659	ALU0110	IA205-B	34.67	40	Reprovado	53	22	29
MAT00850	ALU0142	IA604-B	22.33	74	Reprovado	19	46	2
MAT02093	ALU0349	IA805-B	16.00	92	Reprovado	6	1	41
MAT02485	ALU0415	IA801-B	35.33	99	Reprovado	21	52	33
MAT01101	ALU0184	IA303-A	32.33	79	Reprovado	45	9	43
MAT02845	ALU0475	IA801-B	13.67	82	Reprovado	4	4	33
MAT02059	ALU0344	IA401-B	35.33	49	Reprovado	19	37	50
MAT01155	ALU0193	IA503-A	45.00	57	Reprovado	59	45	31
MAT02881	ALU0481	IA201-B	22.33	49	Reprovado	10	55	2
MAT04308	ALU0718	IA706-A	37.33	77	Reprovado	21	40	51
MAT05734	ALU0956	IA404-A	37.67	61	Reprovado	42	30	41
MAT00539	ALU0090	IA105-B	34.00	46	Reprovado	44	46	12
MAT03062	ALU0511	IA602-B	39.00	65	Reprovado	44	14	59
MAT01350	ALU0225	IA306-A	7.67	56	Reprovado	17	6	0
MAT01116	ALU0186	IA206-B	43.00	70	Reprovado	41	53	35
MAT04142	ALU0691	IA502-B	20.00	58	Reprovado	21	22	17
MAT04950	ALU0825	IA506-B	14.00	55	Reprovado	1	16	25
MAT05699	ALU0950	IA205-A	24.67	58	Reprovado	24	35	15
MAT02490	ALU0415	IA806-B	40.00	98	Reprovado	54	52	14
MAT05254	ALU0876	IA804-B	23.00	72	Reprovado	18	6	45
MAT01825	ALU0305	IA301-B	32.33	72	Reprovado	18	21	58
MAT02939	ALU0490	IA405-B	33.33	44	Reprovado	45	2	53
MAT02157	ALU0360	IA203-A	25.00	59	Reprovado	13	7	55
MAT00532	ALU0089	IA204-A	49.67	96	Reprovado	58	38	53
MAT03670	ALU0612	IA304-B	29.00	51	Reprovado	19	50	18
MAT01143	ALU0191	IA603-A	21.00	42	Reprovado	8	7	48
MAT04198	ALU0700	IA504-B	39.67	79	Reprovado	35	54	30
MAT01746	ALU0291	IA106-B	28.67	36	Reprovado	38	34	14
MAT01440	ALU0240	IA206-B	17.00	41	Reprovado	33	3	15
MAT03617	ALU0603	IA805-A	37.67	75	Reprovado	14	43	56
MAT02395	ALU0400	IA401-B	14.33	95	Reprovado	21	19	3
MAT02064	ALU0344	IA406-B	43.00	90	Reprovado	22	50	57
MAT05202	ALU0867	IA806-B	44.00	59	Reprovado	49	37	46
MAT04127	ALU0688	IA305-B	53.33	97	Reprovado	49	54	57
MAT00878	ALU0147	IA202-B	25.67	81	Reprovado	42	0	35
MAT01933	ALU0323	IA401-A	25.33	66	Reprovado	56	17	3
MAT01248	ALU0208	IA106-A	39.33	100	Reprovado	56	12	50
MAT02830	ALU0472	IA704-B	32.33	84	Reprovado	34	12	51
MAT03210	ALU0535	IA106-B	37.33	93	Reprovado	36	47	29
MAT05715	ALU0953	IA403-B	16.33	42	Reprovado	15	34	0
MAT03606	ALU0601	IA606-B	17.00	78	Reprovado	15	31	5
MAT05685	ALU0948	IA203-B	35.00	86	Reprovado	52	46	7
MAT00208	ALU0035	IA504-B	29.00	64	Reprovado	8	26	53
MAT04709	ALU0785	IA305-A	43.33	35	Reprovado	36	53	41
MAT04930	ALU0822	IA404-B	33.67	54	Reprovado	49	28	24
MAT00259	ALU0044	IA301-A	42.67	37	Reprovado	53	36	39
MAT04222	ALU0704	IA404-B	17.00	70	Reprovado	8	8	35
MAT01804	ALU0301	IA104-B	38.33	94	Reprovado	56	40	19
MAT04757	ALU0793	IA805-B	23.67	67	Reprovado	14	1	56
MAT05416	ALU0903	IA304-B	12.00	56	Reprovado	4	4	28
MAT00686	ALU0115	IA302-A	31.00	90	Reprovado	13	57	23
MAT03471	ALU0579	IA103-A	27.33	97	Reprovado	35	22	25
MAT03371	ALU0562	IA405-B	28.33	31	Reprovado	31	31	23
MAT03090	ALU0515	IA206-B	16.67	88	Reprovado	38	2	10
MAT00976	ALU0163	IA604-B	38.67	72	Reprovado	47	50	19
MAT05510	ALU0919	IA102-A	26.00	96	Reprovado	30	19	29
MAT01826	ALU0305	IA302-B	27.67	74	Reprovado	34	45	4
MAT00788	ALU0132	IA602-B	34.00	88	Reprovado	37	36	29
MAT00653	ALU0109	IA205-A	35.33	77	Reprovado	33	57	16
MAT02969	ALU0495	IA405-A	26.67	84	Reprovado	41	29	10
MAT02024	ALU0338	IA102-B	28.00	36	Reprovado	29	35	20
MAT02289	ALU0382	IA203-A	24.67	85	Reprovado	18	31	25
MAT00707	ALU0118	IA805-B	16.67	70	Reprovado	4	14	32
MAT02766	ALU0461	IA106-B	33.33	90	Reprovado	47	0	53
MAT03977	ALU0663	IA805-B	23.00	35	Reprovado	45	10	14
MAT05500	ALU0917	IA204-B	18.00	45	Reprovado	5	10	39
MAT05524	ALU0921	IA704-A	27.67	49	Reprovado	21	45	17
MAT02945	ALU0491	IA205-B	18.33	53	Reprovado	21	10	24
MAT05011	ALU0836	IA601-B	46.67	95	Reprovado	45	37	58
MAT05174	ALU0863	IA602-B	43.67	85	Reprovado	34	51	46
MAT00729	ALU0122	IA503-B	32.33	97	Reprovado	49	32	16
MAT02663	ALU0444	IA805-B	22.00	81	Reprovado	4	56	6
MAT02291	ALU0382	IA205-A	34.67	39	Reprovado	21	58	25
MAT01787	ALU0298	IA805-B	37.00	49	Reprovado	8	54	49
MAT00506	ALU0085	IA302-B	22.67	58	Reprovado	15	41	12
MAT05402	ALU0901	IA202-A	6.00	40	Reprovado	11	4	3
MAT02920	ALU0487	IA804-B	27.67	33	Reprovado	20	49	14
MAT05609	ALU0935	IA505-A	36.67	64	Reprovado	19	49	42
MAT00647	ALU0108	IA405-A	38.00	74	Reprovado	48	27	39
MAT00285	ALU0048	IA803-A	47.33	36	Reprovado	25	59	58
MAT00143	ALU0024	IA205-B	32.00	65	Reprovado	31	53	12
MAT04840	ALU0807	IA604-B	38.67	41	Reprovado	51	56	9
MAT04299	ALU0717	IA103-B	48.33	68	Reprovado	58	47	40
MAT00216	ALU0036	IA206-A	52.33	37	Reprovado	42	58	57
MAT00824	ALU0138	IA202-A	31.33	75	Reprovado	50	9	35
MAT00424	ALU0071	IA404-B	44.00	57	Reprovado	41	55	36
MAT00421	ALU0071	IA401-B	51.67	98	Reprovado	51	58	46
MAT01545	ALU0258	IA103-B	19.33	58	Reprovado	12	37	9
MAT01666	ALU0278	IA504-B	20.00	52	Reprovado	49	1	10
MAT00801	ALU0134	IA503-A	29.00	55	Reprovado	23	21	43
MAT05168	ALU0862	IA502-B	24.33	58	Reprovado	54	10	9
MAT00665	ALU0111	IA805-A	12.00	74	Reprovado	10	1	25
MAT05497	ALU0917	IA201-B	25.00	59	Reprovado	36	17	22
MAT00658	ALU0110	IA204-B	27.33	82	Reprovado	45	10	27
MAT01495	ALU0250	IA301-B	41.00	50	Reprovado	32	50	41
MAT05541	ALU0924	IA603-B	38.67	52	Reprovado	41	58	17
MAT04965	ALU0828	IA803-B	50.33	56	Reprovado	54	45	52
MAT04955	ALU0826	IA605-B	33.67	64	Reprovado	28	31	42
MAT00609	ALU0102	IA503-A	36.00	76	Reprovado	57	31	20
MAT03054	ALU0509	IA806-B	33.33	45	Reprovado	29	23	48
MAT02498	ALU0417	IA502-B	45.67	66	Reprovado	54	58	25
MAT01941	ALU0324	IA603-B	37.67	30	Reprovado	14	41	58
MAT01605	ALU0268	IA203-B	8.67	78	Reprovado	4	2	20
MAT03179	ALU0530	IA805-B	34.33	36	Reprovado	28	53	22
MAT00785	ALU0131	IA805-A	36.00	63	Reprovado	35	33	40
MAT04309	ALU0719	IA801-A	44.67	56	Reprovado	50	57	27
MAT03987	ALU0665	IA603-B	41.00	77	Reprovado	53	39	31
MAT03456	ALU0576	IA506-A	43.67	78	Reprovado	38	42	51
MAT04028	ALU0672	IA802-B	19.00	89	Reprovado	2	37	18
MAT01021	ALU0171	IA101-A	36.33	62	Reprovado	59	40	10
MAT04021	ALU0671	IA801-A	29.00	32	Reprovado	32	34	21
MAT01926	ALU0321	IA206-B	44.00	92	Reprovado	48	46	38
MAT05084	ALU0848	IA102-A	32.00	71	Reprovado	39	55	2
MAT00607	ALU0102	IA501-A	30.00	60	Reprovado	31	15	44
MAT05287	ALU0882	IA401-B	22.33	55	Reprovado	18	7	42
MAT00712	ALU0119	IA404-B	11.00	63	Reprovado	11	13	9
MAT05945	ALU0991	IA205-B	26.00	37	Reprovado	31	4	43
MAT02410	ALU0402	IA304-A	24.00	53	Reprovado	14	50	8
MAT02572	ALU0429	IA404-A	23.33	72	Reprovado	9	46	15
MAT03254	ALU0543	IA202-A	27.00	61	Reprovado	14	52	15
MAT02842	ALU0474	IA204-B	27.00	69	Reprovado	39	39	3
MAT01772	ALU0296	IA802-A	47.67	43	Reprovado	52	35	56
MAT01909	ALU0319	IA301-B	35.67	72	Reprovado	19	59	29
MAT00242	ALU0041	IA302-A	12.67	91	Reprovado	16	9	13
MAT02507	ALU0418	IA605-B	33.67	90	Reprovado	56	0	45
MAT02494	ALU0416	IA804-B	33.33	43	Reprovado	41	31	28
MAT00684	ALU0114	IA806-B	38.00	33	Reprovado	39	16	59
MAT02804	ALU0468	IA202-B	36.67	32	Reprovado	43	21	46
MAT00960	ALU0160	IA506-A	27.00	52	Reprovado	4	26	51
MAT01815	ALU0303	IA503-B	25.00	86	Reprovado	20	33	22
MAT02259	ALU0377	IA103-A	23.67	57	Reprovado	30	18	23
MAT01976	ALU0330	IA602-B	23.00	83	Reprovado	15	25	29
MAT03479	ALU0580	IA305-A	21.00	75	Reprovado	34	14	15
MAT05653	ALU0943	IA501-A	38.00	98	Reprovado	49	33	32
MAT04672	ALU0779	IA804-A	29.00	79	Reprovado	11	24	52
MAT01227	ALU0205	IA603-A	20.67	98	Reprovado	16	41	5
MAT03607	ALU0602	IA501-A	28.00	31	Reprovado	43	33	8
MAT04440	ALU0740	IA806-B	43.33	68	Reprovado	54	52	24
MAT03738	ALU0623	IA606-A	26.67	31	Reprovado	5	46	29
MAT01916	ALU0320	IA702-B	36.33	52	Reprovado	13	46	50
MAT04426	ALU0738	IA804-B	27.33	77	Reprovado	21	13	48
MAT01556	ALU0260	IA802-B	13.33	75	Reprovado	6	6	28
MAT02557	ALU0427	IA401-B	41.00	33	Reprovado	22	47	54
MAT02341	ALU0391	IA701-A	32.33	79	Reprovado	47	21	29
MAT01524	ALU0254	IA606-A	39.00	97	Reprovado	30	42	45
MAT03612	ALU0602	IA506-A	21.67	62	Reprovado	47	11	7
MAT04626	ALU0771	IA606-A	27.00	95	Reprovado	27	19	35
MAT01104	ALU0184	IA306-A	26.67	87	Reprovado	37	13	30
MAT04825	ALU0805	IA801-A	46.33	48	Reprovado	52	40	47
MAT02334	ALU0389	IA706-B	19.33	38	Reprovado	2	7	49
MAT02103	ALU0351	IA503-B	42.67	87	Reprovado	34	46	48
MAT05387	ALU0898	IA105-B	43.00	42	Reprovado	45	26	58
MAT00462	ALU0077	IA406-A	32.33	63	Reprovado	30	19	48
MAT01457	ALU0243	IA305-A	33.67	53	Reprovado	26	50	25
MAT01087	ALU0182	IA801-A	31.67	93	Reprovado	40	19	36
MAT05370	ALU0895	IA506-A	33.33	54	Reprovado	42	0	58
MAT02132	ALU0356	IA802-B	21.33	40	Reprovado	13	31	20
MAT05103	ALU0851	IA303-A	16.00	80	Reprovado	1	15	32
MAT01369	ALU0229	IA201-A	35.00	79	Reprovado	48	15	42
MAT01422	ALU0237	IA306-B	30.00	100	Reprovado	18	46	26
MAT00639	ALU0107	IA303-B	50.00	57	Reprovado	57	43	50
MAT00696	ALU0116	IA706-A	11.67	30	Reprovado	3	17	15
MAT02668	ALU0445	IA804-B	28.67	73	Reprovado	41	23	22
MAT03992	ALU0666	IA802-B	28.67	47	Reprovado	27	17	42
MAT03875	ALU0646	IA505-B	46.00	37	Reprovado	54	50	34
MAT00296	ALU0050	IA302-B	31.67	83	Reprovado	0	57	38
MAT05036	ALU0840	IA602-B	52.33	48	Reprovado	59	43	55
MAT03454	ALU0576	IA504-A	25.33	33	Reprovado	33	13	30
MAT01492	ALU0249	IA204-A	30.33	89	Reprovado	18	44	29
MAT00501	ALU0084	IA203-B	14.00	79	Reprovado	0	20	22
MAT04286	ALU0715	IA302-B	32.00	36	Reprovado	25	43	28
MAT00319	ALU0054	IA401-A	14.00	88	Reprovado	11	18	13
MAT03726	ALU0621	IA406-B	15.33	37	Reprovado	2	15	29
MAT03067	ALU0512	IA201-A	22.33	77	Reprovado	23	44	0
MAT02314	ALU0386	IA604-A	35.67	52	Reprovado	46	14	47
MAT01602	ALU0267	IA606-A	16.33	41	Reprovado	5	26	18
MAT01768	ALU0295	IA404-B	50.00	67	Reprovado	46	48	56
MAT00435	ALU0073	IA603-B	46.33	33	Reprovado	51	46	42
MAT03964	ALU0661	IA404-A	31.33	72	Reprovado	52	10	32
MAT04032	ALU0672	IA806-B	49.33	81	Reprovado	44	55	49
MAT05516	ALU0920	IA802-A	42.00	53	Reprovado	23	47	56
MAT05319	ALU0887	IA603-B	26.67	86	Reprovado	43	25	12
MAT04269	ALU0712	IA803-A	46.67	49	Reprovado	56	25	59
MAT05127	ALU0855	IA403-B	35.00	99	Reprovado	45	42	18
MAT02832	ALU0472	IA706-B	31.00	59	Reprovado	15	53	25
MAT02537	ALU0423	IA605-A	28.33	44	Reprovado	45	8	32
MAT00369	ALU0062	IA203-A	29.67	90	Reprovado	10	58	21
MAT03026	ALU0505	IA602-A	23.33	35	Reprovado	46	7	17
MAT04002	ALU0667	IA606-A	23.33	79	Reprovado	57	13	0
MAT00821	ALU0137	IA205-A	21.33	63	Reprovado	23	5	36
MAT00973	ALU0163	IA601-B	19.33	94	Reprovado	8	1	49
MAT02547	ALU0425	IA803-B	23.67	70	Reprovado	4	20	47
MAT00263	ALU0044	IA305-A	29.67	72	Reprovado	53	23	13
MAT03806	ALU0635	IA402-B	11.33	44	Reprovado	1	24	9
MAT05517	ALU0920	IA803-A	23.00	80	Reprovado	50	16	3
MAT00955	ALU0160	IA501-A	23.33	70	Reprovado	19	48	3
MAT04149	ALU0692	IA203-B	29.33	76	Reprovado	20	16	52
MAT00530	ALU0089	IA202-A	35.00	57	Reprovado	44	35	26
MAT03729	ALU0622	IA103-B	48.67	89	Reprovado	49	50	47
MAT05932	ALU0989	IA504-A	18.67	78	Reprovado	10	20	26
MAT00533	ALU0089	IA205-A	21.67	48	Reprovado	11	39	15
MAT02723	ALU0454	IA605-B	10.67	56	Reprovado	4	0	28
MAT05577	ALU0930	IA103-A	31.67	62	Reprovado	52	8	35
MAT02071	ALU0346	IA701-B	31.67	65	Reprovado	38	24	33
MAT02110	ALU0352	IA204-A	27.67	63	Reprovado	28	5	50
MAT04290	ALU0715	IA306-B	19.67	88	Reprovado	28	6	25
MAT05854	ALU0976	IA304-A	56.00	62	Reprovado	52	57	59
MAT05821	ALU0971	IA601-B	25.67	77	Reprovado	59	8	10
MAT03120	ALU0520	IA306-A	19.33	54	Reprovado	9	39	10
MAT02838	ALU0473	IA606-A	53.67	42	Reprovado	56	56	49
MAT02777	ALU0463	IA605-A	21.00	82	Reprovado	24	13	26
MAT04282	ALU0714	IA804-B	20.67	78	Reprovado	27	32	3
MAT02616	ALU0436	IA206-A	29.00	33	Reprovado	17	19	51
MAT01040	ALU0174	IA702-B	27.67	87	Reprovado	20	9	54
MAT05086	ALU0848	IA104-A	12.67	94	Reprovado	30	7	1
MAT03482	ALU0581	IA302-B	33.00	97	Reprovado	32	10	57
MAT01597	ALU0267	IA601-A	28.33	41	Reprovado	11	15	59
MAT01732	ALU0289	IA404-B	42.33	64	Reprovado	55	54	18
MAT05602	ALU0934	IA604-A	31.67	51	Reprovado	41	9	45
MAT02018	ALU0337	IA302-B	19.33	33	Reprovado	3	1	54
MAT01636	ALU0273	IA404-A	13.33	86	Reprovado	9	14	17
MAT00268	ALU0045	IA104-B	21.33	93	Reprovado	26	33	5
MAT03989	ALU0665	IA605-B	7.00	57	Reprovado	16	2	3
MAT00980	ALU0164	IA502-A	24.67	47	Reprovado	27	45	2
MAT02734	ALU0456	IA604-A	36.33	59	Reprovado	36	58	15
MAT01017	ALU0170	IA403-B	22.00	84	Reprovado	44	7	15
MAT02346	ALU0391	IA706-A	19.33	84	Reprovado	36	18	4
MAT00364	ALU0061	IA804-B	30.00	68	Reprovado	20	50	20
MAT00871	ALU0146	IA201-B	28.00	44	Reprovado	17	40	27
MAT03962	ALU0661	IA402-A	20.67	63	Reprovado	18	12	32
MAT01291	ALU0216	IA201-A	43.33	70	Reprovado	45	33	52
MAT01481	ALU0247	IA205-B	52.00	80	Reprovado	59	52	45
MAT01691	ALU0282	IA805-B	26.00	69	Reprovado	14	9	55
MAT03809	ALU0635	IA405-B	28.00	71	Reprovado	38	2	44
MAT01576	ALU0263	IA804-B	29.00	97	Reprovado	23	7	57
MAT01860	ALU0310	IA506-B	38.33	80	Reprovado	44	21	50
MAT02408	ALU0402	IA302-A	29.33	66	Reprovado	26	18	44
MAT02803	ALU0468	IA201-B	18.67	60	Reprovado	23	6	27
MAT05434	ALU0906	IA104-B	30.67	49	Reprovado	0	35	57
MAT02142	ALU0357	IA806-A	34.00	30	Reprovado	43	43	16
MAT00716	ALU0120	IA802-B	20.67	79	Reprovado	39	2	21
MAT05207	ALU0868	IA305-B	41.67	81	Reprovado	36	52	37
MAT00944	ALU0158	IA102-B	31.00	94	Reprovado	39	54	0
MAT01363	ALU0228	IA401-B	29.33	48	Reprovado	41	47	0
MAT02053	ALU0343	IA401-A	32.00	38	Reprovado	43	49	4
MAT01235	ALU0206	IA505-A	24.67	45	Reprovado	12	13	49
MAT00438	ALU0073	IA606-B	33.67	38	Reprovado	54	10	37
MAT02239	ALU0374	IA301-B	29.00	54	Reprovado	13	24	50
MAT01055	ALU0176	IA205-B	18.33	39	Reprovado	21	2	32
MAT00702	ALU0117	IA506-A	26.00	40	Reprovado	59	3	16
MAT05948	ALU0992	IA302-A	14.00	53	Reprovado	31	2	9
MAT01656	ALU0276	IA606-B	29.33	54	Reprovado	42	31	15
MAT02875	ALU0480	IA301-A	18.00	43	Reprovado	31	23	0
MAT01866	ALU0311	IA406-A	12.00	41	Reprovado	19	7	10
MAT01346	ALU0225	IA302-A	31.33	73	Reprovado	21	29	44
MAT02398	ALU0400	IA404-B	36.67	100	Reprovado	43	25	42
MAT03461	ALU0577	IA805-A	6.67	73	Reprovado	2	15	3
MAT05471	ALU0912	IA605-B	27.33	97	Reprovado	2	58	22
MAT00166	ALU0028	IA304-B	35.67	35	Reprovado	31	51	25
MAT05193	ALU0866	IA303-B	50.00	87	Reprovado	54	47	49
MAT01504	ALU0251	IA504-A	16.00	93	Reprovado	9	24	15
MAT01262	ALU0211	IA202-B	26.33	93	Reprovado	39	25	15
MAT01961	ALU0327	IA105-A	32.00	73	Reprovado	0	57	39
MAT02054	ALU0343	IA402-A	29.33	72	Reprovado	26	39	23
MAT04429	ALU0739	IA101-A	45.67	48	Reprovado	26	58	53
MAT00235	ALU0040	IA301-A	37.00	79	Reprovado	40	50	21
MAT04202	ALU0701	IA702-B	20.00	65	Reprovado	51	9	0
MAT00654	ALU0109	IA206-A	28.67	59	Reprovado	31	55	0
MAT00752	ALU0126	IA702-B	38.33	42	Reprovado	36	28	51
MAT02698	ALU0450	IA504-A	16.67	50	Reprovado	47	2	1
MAT03050	ALU0509	IA802-B	35.33	64	Reprovado	57	4	45
MAT02653	ALU0443	IA101-A	36.33	53	Reprovado	17	42	50
MAT03267	ALU0545	IA403-B	28.00	83	Reprovado	19	13	52
MAT04795	ALU0800	IA601-B	33.33	47	Reprovado	23	47	30
MAT00221	ALU0037	IA305-B	23.33	71	Reprovado	12	8	50
MAT01821	ALU0304	IA803-B	44.00	79	Reprovado	34	41	57
MAT00892	ALU0149	IA404-A	16.67	54	Reprovado	1	18	31
MAT02036	ALU0340	IA102-B	32.33	67	Reprovado	47	17	33
MAT05307	ALU0885	IA203-B	34.33	78	Reprovado	22	36	45
MAT01593	ALU0266	IA803-A	12.67	96	Reprovado	13	1	24
MAT05439	ALU0907	IA203-B	32.00	63	Reprovado	21	16	59
MAT00608	ALU0102	IA502-A	34.00	84	Reprovado	33	29	40
MAT04427	ALU0738	IA805-B	36.00	73	Reprovado	53	23	32
MAT00715	ALU0120	IA801-B	19.67	50	Reprovado	6	49	4
MAT05677	ALU0947	IA801-A	19.67	47	Reprovado	36	5	18
MAT01582	ALU0264	IA104-B	20.00	72	Reprovado	28	24	8
MAT01288	ALU0215	IA604-B	38.67	75	Reprovado	17	45	54
MAT01877	ALU0313	IA805-A	14.67	39	Reprovado	20	24	0
MAT05688	ALU0948	IA206-B	26.33	35	Reprovado	17	18	44
MAT02401	ALU0401	IA301-A	19.67	66	Reprovado	1	35	23
MAT01113	ALU0186	IA203-B	31.33	75	Reprovado	50	15	29
MAT05696	ALU0950	IA202-A	21.33	63	Reprovado	5	41	18
MAT05697	ALU0950	IA203-A	32.00	41	Reprovado	6	38	52
MAT03585	ALU0598	IA103-A	53.67	53	Reprovado	53	52	56
MAT01503	ALU0251	IA503-A	33.33	90	Reprovado	27	47	26
MAT00392	ALU0066	IA302-B	27.67	32	Reprovado	46	6	31
MAT04289	ALU0715	IA305-B	5.67	30	Reprovado	0	1	16
MAT02895	ALU0483	IA503-B	28.67	59	Reprovado	27	3	56
MAT05364	ALU0894	IA306-B	20.67	53	Reprovado	37	5	20
MAT02418	ALU0403	IA106-B	29.67	88	Reprovado	45	41	3
MAT01741	ALU0291	IA101-B	44.33	61	Reprovado	59	45	29
MAT05735	ALU0956	IA405-A	36.33	59	Reprovado	51	29	29
MAT05177	ALU0863	IA605-B	36.67	100	Reprovado	32	36	42
MAT00505	ALU0085	IA301-B	30.67	61	Reprovado	36	36	20
MAT03408	ALU0568	IA706-A	36.33	43	Reprovado	53	47	9
MAT05265	ALU0878	IA803-B	20.67	80	Reprovado	54	3	5
MAT00709	ALU0119	IA401-B	31.33	30	Reprovado	16	41	37
MAT00343	ALU0058	IA101-B	31.33	81	Reprovado	40	49	5
MAT02303	ALU0384	IA205-B	18.33	69	Reprovado	31	14	10
MAT04025	ALU0671	IA805-A	35.67	97	Reprovado	10	52	45
MAT02176	ALU0363	IA804-B	38.00	64	Reprovado	16	49	49
MAT02000	ALU0334	IA202-A	41.33	56	Reprovado	58	54	12
MAT02618	ALU0437	IA202-A	19.00	74	Reprovado	40	5	12
MAT04431	ALU0739	IA103-A	12.67	100	Reprovado	19	19	0
MAT01342	ALU0224	IA704-B	27.33	78	Reprovado	51	0	31
MAT00624	ALU0104	IA706-B	33.67	75	Reprovado	17	44	40
MAT00508	ALU0085	IA304-B	43.67	89	Reprovado	47	34	50
MAT05046	ALU0841	IA606-B	28.33	36	Reprovado	11	51	23
MAT05530	ALU0922	IA504-B	10.67	94	Reprovado	10	3	19
MAT02655	ALU0443	IA103-A	38.00	58	Reprovado	41	45	28
MAT00682	ALU0114	IA804-B	26.67	74	Reprovado	18	10	52
MAT02199	ALU0367	IA803-B	27.00	54	Reprovado	28	47	6
MAT02388	ALU0398	IA606-B	40.67	69	Reprovado	24	39	59
MAT01702	ALU0284	IA604-A	35.00	83	Reprovado	36	11	58
MAT03653	ALU0609	IA305-A	24.33	82	Reprovado	5	36	32
MAT02284	ALU0381	IA704-B	35.33	47	Reprovado	33	17	56
MAT04373	ALU0729	IA605-A	56.33	100	Reprovado	54	57	58
MAT00820	ALU0137	IA204-A	30.67	74	Reprovado	12	32	48
MAT03100	ALU0517	IA604-B	17.67	40	Reprovado	3	44	6
MAT02506	ALU0418	IA604-B	21.67	44	Reprovado	43	4	18
MAT00393	ALU0066	IA303-B	21.33	45	Reprovado	6	36	22
MAT00398	ALU0067	IA602-B	43.67	96	Reprovado	31	52	48
MAT02499	ALU0417	IA503-B	32.00	30	Reprovado	23	52	21
MAT05048	ALU0842	IA502-B	42.00	83	Reprovado	59	26	41
MAT01063	ALU0178	IA601-B	12.33	80	Reprovado	12	2	23
MAT01361	ALU0227	IA505-B	31.00	43	Reprovado	21	19	53
MAT00537	ALU0090	IA103-B	20.33	45	Reprovado	13	6	42
MAT05792	ALU0966	IA602-B	37.67	60	Reprovado	13	55	45
MAT02828	ALU0472	IA702-B	53.00	40	Reprovado	51	55	53
MAT04384	ALU0731	IA804-B	12.67	85	Reprovado	27	10	1
MAT01458	ALU0243	IA306-A	38.00	100	Reprovado	36	54	24
MAT03542	ALU0591	IA602-B	25.67	88	Reprovado	18	56	3
MAT01525	ALU0255	IA501-A	19.00	79	Reprovado	6	21	30
MAT01453	ALU0243	IA301-A	17.67	90	Reprovado	0	53	0
MAT00321	ALU0054	IA403-A	26.67	73	Reprovado	50	29	1
MAT02913	ALU0486	IA403-A	10.67	43	Reprovado	24	2	6
MAT05515	ALU0920	IA801-A	43.33	48	Reprovado	53	27	50
MAT02515	ALU0420	IA601-A	25.00	75	Reprovado	24	42	9
MAT05330	ALU0889	IA502-B	16.00	49	Reprovado	20	9	19
MAT00492	ALU0082	IA106-A	30.67	91	Reprovado	24	55	13
MAT05628	ALU0938	IA306-B	27.67	33	Reprovado	31	17	35
MAT04372	ALU0729	IA604-A	12.67	41	Reprovado	3	10	25
MAT01142	ALU0191	IA602-A	45.67	77	Reprovado	54	52	31
MAT02595	ALU0433	IA803-A	8.33	38	Reprovado	5	19	1
MAT01367	ALU0228	IA405-B	35.33	65	Reprovado	45	48	13
MAT03368	ALU0562	IA402-B	34.33	90	Reprovado	38	7	58
MAT02995	ALU0500	IA701-A	29.00	40	Reprovado	51	8	28
MAT01862	ALU0311	IA402-A	9.00	96	Reprovado	11	11	5
MAT00138	ALU0023	IA606-A	23.00	57	Reprovado	32	18	19
MAT05203	ALU0868	IA301-B	26.67	32	Reprovado	21	40	19
MAT00799	ALU0134	IA501-A	27.00	71	Reprovado	52	12	17
MAT05078	ALU0847	IA802-A	24.33	34	Reprovado	11	30	32
MAT03969	ALU0662	IA103-B	22.00	63	Reprovado	21	40	5
MAT01710	ALU0285	IA506-A	22.67	94	Reprovado	9	33	26
MAT01412	ALU0236	IA602-B	20.00	83	Reprovado	18	31	11
MAT00085	ALU0015	IA201-B	56.00	85	Reprovado	55	58	55
MAT02310	ALU0385	IA506-B	22.00	73	Reprovado	45	10	11
MAT00637	ALU0107	IA301-B	31.33	90	Reprovado	14	43	37
MAT02853	ALU0476	IA403-B	47.67	37	Reprovado	36	54	53
MAT05271	ALU0879	IA303-B	23.67	50	Reprovado	48	18	5
MAT03973	ALU0663	IA801-B	6.67	95	Reprovado	0	6	14
MAT05601	ALU0934	IA603-A	38.00	69	Reprovado	23	40	51
MAT01045	ALU0175	IA301-B	18.00	63	Reprovado	17	37	0
MAT05603	ALU0934	IA605-A	26.67	77	Reprovado	31	45	4
MAT00116	ALU0020	IA702-B	18.67	75	Reprovado	15	36	5
MAT02446	ALU0408	IA604-B	27.00	86	Reprovado	50	6	25
MAT03178	ALU0530	IA804-B	32.33	34	Reprovado	2	53	42
MAT02854	ALU0476	IA404-B	37.33	99	Reprovado	17	44	51
MAT03101	ALU0517	IA605-B	31.00	54	Reprovado	17	40	36
MAT02867	ALU0478	IA405-B	23.33	31	Reprovado	55	13	2
MAT03206	ALU0535	IA102-B	15.00	80	Reprovado	25	15	5
MAT01989	ALU0332	IA703-B	19.00	47	Reprovado	19	19	19
MAT01438	ALU0240	IA204-B	25.00	98	Reprovado	29	10	36
MAT00182	ALU0031	IA602-B	27.00	91	Reprovado	9	53	19
MAT03268	ALU0545	IA404-B	24.67	58	Reprovado	12	28	34
MAT03037	ALU0507	IA301-B	38.33	33	Reprovado	15	55	45
MAT02260	ALU0377	IA104-A	21.33	92	Reprovado	26	6	32
MAT03546	ALU0591	IA606-B	30.67	67	Reprovado	42	32	18
MAT05532	ALU0922	IA506-B	49.33	89	Reprovado	46	51	51
MAT05496	ALU0916	IA406-B	23.67	83	Reprovado	16	45	10
MAT01399	ALU0234	IA201-A	44.00	31	Reprovado	35	54	43
MAT03892	ALU0649	IA304-B	44.67	34	Reprovado	47	49	38
MAT05154	ALU0859	IA206-B	28.67	73	Reprovado	47	33	6
MAT02097	ALU0350	IA803-B	37.00	34	Reprovado	50	50	11
MAT00636	ALU0106	IA506-B	28.67	98	Reprovado	49	26	11
MAT00672	ALU0112	IA406-B	25.67	56	Reprovado	15	35	27
MAT04416	ALU0736	IA106-B	36.67	76	Reprovado	33	28	49
MAT05279	ALU0880	IA105-B	20.00	85	Reprovado	33	25	2
MAT01682	ALU0281	IA102-B	32.67	70	Reprovado	28	17	53
MAT02627	ALU0438	IA105-B	21.33	86	Reprovado	12	33	19
MAT05353	ALU0893	IA801-B	22.33	47	Reprovado	12	37	18
MAT02256	ALU0376	IA806-B	44.33	82	Reprovado	43	56	34
MAT00852	ALU0142	IA606-B	33.33	44	Reprovado	39	16	45
MAT01327	ALU0222	IA701-B	45.00	94	Reprovado	53	28	54
MAT01375	ALU0230	IA801-B	30.00	46	Reprovado	33	55	2
MAT05365	ALU0895	IA501-A	11.00	60	Reprovado	25	8	0
MAT02756	ALU0460	IA502-B	32.00	57	Reprovado	33	51	12
MAT05732	ALU0956	IA402-A	26.67	53	Reprovado	18	11	51
MAT00594	ALU0099	IA406-B	12.00	80	Reprovado	16	6	14
MAT01365	ALU0228	IA403-B	39.33	89	Reprovado	44	49	25
MAT00230	ALU0039	IA202-B	35.00	53	Reprovado	34	37	34
MAT00965	ALU0161	IA205-B	10.33	84	Reprovado	5	22	4
MAT01979	ALU0330	IA605-B	28.33	70	Reprovado	48	31	6
MAT02818	ALU0470	IA204-B	15.00	75	Reprovado	7	4	34
MAT05947	ALU0992	IA301-A	22.33	81	Reprovado	17	13	37
MAT05379	ALU0897	IA503-B	30.67	74	Reprovado	38	21	33
MAT02770	ALU0462	IA604-A	17.33	79	Reprovado	14	10	28
MAT01436	ALU0240	IA202-B	37.67	56	Reprovado	12	55	46
MAT04933	ALU0823	IA401-B	48.00	53	Reprovado	53	39	52
MAT05089	ALU0849	IA501-B	16.00	52	Reprovado	24	2	22
MAT05750	ALU0959	IA602-B	34.00	75	Reprovado	44	52	6
MAT00605	ALU0101	IA205-A	39.67	30	Reprovado	51	45	23
MAT04297	ALU0717	IA101-B	26.33	53	Reprovado	20	52	7
MAT03520	ALU0587	IA804-A	31.67	91	Reprovado	18	57	20
MAT01216	ALU0203	IA104-A	39.00	90	Reprovado	57	23	37
MAT02002	ALU0334	IA204-A	15.33	43	Reprovado	1	22	23
MAT00894	ALU0149	IA406-A	20.33	32	Reprovado	22	3	36
MAT02451	ALU0409	IA403-B	20.67	67	Reprovado	10	26	26
MAT02452	ALU0409	IA404-B	37.33	42	Reprovado	44	9	59
MAT02175	ALU0363	IA803-B	12.33	61	Reprovado	16	11	10
MAT01292	ALU0216	IA202-A	26.67	49	Reprovado	20	16	44
MAT05102	ALU0851	IA302-A	29.00	44	Reprovado	20	14	53
MAT02533	ALU0423	IA601-A	9.00	35	Reprovado	14	10	3
MAT00509	ALU0085	IA305-B	42.67	55	Reprovado	14	56	58
MAT02453	ALU0409	IA405-B	17.00	69	Reprovado	24	16	11
MAT05706	ALU0951	IA306-A	30.33	47	Reprovado	34	44	13
MAT05396	ALU0900	IA302-A	48.00	86	Reprovado	44	49	51
MAT01879	ALU0314	IA101-B	27.00	90	Reprovado	35	35	11
MAT05664	ALU0944	IA106-B	48.00	87	Reprovado	48	49	47
MAT01191	ALU0199	IA303-A	22.00	66	Reprovado	26	3	37
MAT00368	ALU0062	IA202-A	24.33	57	Reprovado	12	51	10
MAT02117	ALU0353	IA305-B	19.67	39	Reprovado	4	7	48
MAT05363	ALU0894	IA305-B	13.33	82	Reprovado	33	6	1
MAT02058	ALU0343	IA406-A	29.33	69	Reprovado	42	20	26
MAT00014	ALU0003	IA302-B	27.33	80	Reprovado	19	13	50
MAT05553	ALU0926	IA703-B	23.33	83	Reprovado	50	15	5
MAT04023	ALU0671	IA803-A	17.00	35	Reprovado	5	40	6
MAT01749	ALU0292	IA703-A	13.33	89	Reprovado	31	3	6
MAT00978	ALU0163	IA606-B	15.33	41	Reprovado	8	10	28
MAT03072	ALU0512	IA206-A	42.33	94	Reprovado	43	54	30
MAT01735	ALU0290	IA401-B	42.00	55	Reprovado	36	34	56
MAT00599	ALU0100	IA405-B	26.33	77	Reprovado	6	47	26
MAT01023	ALU0171	IA103-A	18.67	62	Reprovado	6	46	4
MAT03063	ALU0511	IA603-B	36.33	33	Reprovado	24	26	59
MAT02100	ALU0350	IA806-B	28.33	79	Reprovado	10	26	49
MAT02927	ALU0488	IA405-B	22.33	36	Reprovado	28	31	8
MAT00388	ALU0065	IA704-A	39.33	91	Reprovado	41	43	34
MAT03192	ALU0532	IA206-A	45.00	32	Reprovado	58	46	31
MAT02780	ALU0464	IA302-B	33.33	58	Reprovado	32	59	9
MAT01546	ALU0258	IA104-B	20.67	77	Reprovado	25	18	19
MAT01086	ALU0181	IA706-B	22.33	42	Reprovado	13	6	48
MAT03043	ALU0508	IA501-B	30.67	62	Reprovado	56	32	4
MAT00177	ALU0030	IA703-B	26.67	68	Reprovado	52	12	16
MAT03208	ALU0535	IA104-B	25.00	49	Reprovado	9	35	31
MAT05067	ALU0845	IA503-B	33.33	73	Reprovado	15	35	50
MAT01599	ALU0267	IA603-A	35.00	99	Reprovado	37	11	57
MAT02140	ALU0357	IA804-A	41.33	37	Reprovado	38	54	32
MAT01097	ALU0183	IA805-B	32.67	49	Reprovado	22	41	35
MAT03981	ALU0664	IA103-B	37.33	53	Reprovado	56	41	15
MAT00401	ALU0067	IA605-B	34.00	55	Reprovado	39	20	43
MAT01853	ALU0309	IA105-B	32.00	35	Reprovado	38	23	35
MAT00953	ALU0159	IA305-B	31.00	92	Reprovado	29	21	43
MAT02527	ALU0422	IA401-B	35.67	50	Reprovado	53	40	14
MAT00260	ALU0044	IA302-A	16.67	77	Reprovado	21	5	24
MAT00691	ALU0116	IA701-A	36.67	91	Reprovado	1	54	55
MAT00812	ALU0136	IA302-A	38.33	65	Reprovado	32	36	47
MAT03474	ALU0579	IA106-A	39.67	76	Reprovado	36	25	58
MAT04665	ALU0778	IA703-A	38.33	78	Reprovado	42	51	22
MAT05485	ALU0915	IA701-B	50.00	79	Reprovado	39	59	52
MAT01088	ALU0182	IA802-A	29.00	38	Reprovado	37	18	32
MAT02877	ALU0480	IA303-A	37.00	91	Reprovado	28	52	31
MAT00031	ALU0006	IA101-A	39.00	65	Reprovado	56	15	46
MAT01766	ALU0295	IA402-B	24.00	44	Reprovado	25	23	24
MAT00480	ALU0080	IA206-A	22.67	89	Reprovado	50	4	14
MAT03030	ALU0505	IA606-A	30.67	92	Reprovado	7	33	52
MAT01081	ALU0181	IA701-B	10.67	50	Reprovado	3	26	3
MAT00127	ALU0022	IA401-A	19.00	59	Reprovado	45	3	9
MAT00945	ALU0158	IA103-B	39.00	98	Reprovado	41	48	28
MAT05337	ALU0890	IA103-A	51.67	48	Reprovado	52	57	46
MAT02368	ALU0395	IA304-B	47.00	86	Reprovado	51	42	48
MAT04898	ALU0817	IA702-A	21.00	44	Reprovado	23	39	1
MAT05830	ALU0972	IA304-A	29.33	91	Reprovado	13	38	37
MAT05467	ALU0912	IA601-B	28.33	66	Reprovado	18	40	27
MAT05388	ALU0898	IA106-B	18.00	89	Reprovado	8	36	10
MAT02492	ALU0416	IA802-B	38.33	39	Reprovado	41	47	27
MAT01654	ALU0276	IA604-B	30.67	48	Reprovado	13	58	21
MAT02238	ALU0373	IA606-B	26.00	73	Reprovado	28	30	20
MAT01823	ALU0304	IA805-B	21.00	68	Reprovado	7	53	3
MAT02206	ALU0368	IA404-B	37.33	76	Reprovado	20	43	49
MAT01819	ALU0304	IA801-B	24.33	96	Reprovado	23	8	42
MAT02859	ALU0477	IA303-A	41.33	40	Reprovado	52	32	40
MAT02404	ALU0401	IA304-A	36.00	95	Reprovado	47	19	42
MAT02318	ALU0387	IA302-B	28.33	30	Reprovado	28	10	47
MAT04304	ALU0718	IA702-A	31.33	47	Reprovado	18	41	35
MAT02613	ALU0436	IA203-A	39.00	53	Reprovado	52	31	34
MAT04971	ALU0829	IA403-A	26.67	78	Reprovado	48	21	11
MAT00294	ALU0049	IA506-B	47.33	46	Reprovado	52	49	41
MAT03107	ALU0518	IA105-B	22.33	93	Reprovado	15	9	43
MAT01922	ALU0321	IA202-B	24.00	31	Reprovado	1	48	23
MAT04619	ALU0770	IA605-B	26.67	50	Reprovado	31	38	11
MAT01326	ALU0221	IA806-B	42.67	82	Reprovado	51	57	20
MAT05189	ALU0865	IA405-B	25.00	90	Reprovado	50	14	11
MAT00353	ALU0059	IA405-B	58.67	42	Reprovado	59	58	59
MAT04410	ALU0735	IA406-A	33.00	37	Reprovado	35	22	42
MAT03255	ALU0543	IA203-A	21.00	56	Reprovado	5	35	23
MAT05759	ALU0960	IA805-A	26.00	88	Reprovado	6	33	39
MAT05201	ALU0867	IA805-B	28.67	94	Reprovado	56	10	20
MAT05079	ALU0847	IA803-A	47.00	81	Reprovado	59	41	41
MAT03085	ALU0515	IA201-B	53.33	88	Reprovado	54	49	57
MAT01944	ALU0324	IA606-B	12.67	43	Reprovado	22	6	10
MAT00602	ALU0101	IA202-A	23.67	73	Reprovado	18	24	29
MAT05304	ALU0884	IA606-A	4.00	68	Reprovado	10	2	0
MAT00664	ALU0111	IA804-A	26.67	46	Reprovado	38	26	16
MAT03486	ALU0581	IA306-B	48.33	92	Reprovado	58	48	39
MAT01781	ALU0297	IA805-B	44.67	76	Reprovado	48	27	59
MAT05845	ALU0975	IA401-B	33.00	57	Reprovado	57	38	4
MAT05049	ALU0842	IA503-B	31.33	32	Reprovado	48	11	35
MAT02983	ALU0498	IA301-B	21.33	86	Reprovado	3	27	34
MAT02612	ALU0436	IA202-A	33.67	33	Reprovado	42	10	49
MAT01929	ALU0322	IA503-B	23.33	34	Reprovado	3	46	21
MAT02638	ALU0440	IA504-A	48.67	63	Reprovado	52	48	46
MAT00301	ALU0051	IA101-A	31.00	59	Reprovado	38	20	35
MAT01339	ALU0224	IA701-B	38.67	63	Reprovado	41	50	25
MAT00540	ALU0090	IA106-B	36.00	79	Reprovado	38	37	33
MAT02642	ALU0441	IA602-B	13.67	42	Reprovado	23	14	4
MAT02980	ALU0497	IA604-B	21.00	46	Reprovado	48	10	5
MAT02975	ALU0496	IA405-A	13.67	70	Reprovado	8	14	19
MAT02386	ALU0398	IA604-B	37.67	46	Reprovado	51	52	10
MAT00212	ALU0036	IA202-A	26.33	77	Reprovado	22	34	23
MAT00286	ALU0048	IA804-A	11.00	40	Reprovado	17	16	0
MAT05145	ALU0858	IA203-B	40.33	99	Reprovado	14	55	52
MAT01920	ALU0320	IA706-B	15.67	94	Reprovado	10	20	17
MAT02561	ALU0427	IA405-B	28.67	93	Reprovado	18	51	17
MAT04458	ALU0743	IA506-A	13.33	53	Reprovado	9	24	7
MAT04836	ALU0806	IA306-A	33.33	98	Reprovado	1	41	58
MAT00219	ALU0037	IA303-B	32.33	52	Reprovado	54	28	15
MAT02387	ALU0398	IA605-B	47.00	60	Reprovado	56	57	28
MAT05936	ALU0990	IA102-A	41.00	42	Reprovado	59	35	29
MAT05574	ALU0929	IA806-A	33.00	69	Reprovado	50	8	41
MAT03044	ALU0508	IA502-B	34.00	66	Reprovado	38	14	50
MAT00399	ALU0067	IA603-B	17.67	53	Reprovado	2	0	51
MAT01137	ALU0190	IA403-A	35.67	95	Reprovado	17	47	43
MAT00633	ALU0106	IA503-B	45.00	35	Reprovado	49	50	36
MAT05819	ALU0970	IA505-B	37.33	31	Reprovado	46	18	48
MAT02497	ALU0417	IA501-B	23.00	76	Reprovado	3	45	21
MAT03033	ALU0506	IA603-B	32.67	55	Reprovado	44	35	19
MAT03528	ALU0588	IA406-A	17.33	94	Reprovado	3	36	13
MAT05702	ALU0951	IA302-A	33.67	32	Reprovado	14	30	57
MAT01845	ALU0308	IA103-A	33.00	77	Reprovado	44	35	20
MAT05015	ALU0836	IA605-B	37.67	74	Reprovado	45	57	11
MAT05687	ALU0948	IA205-B	36.00	100	Reprovado	38	31	39
MAT00331	ALU0056	IA101-B	21.33	34	Reprovado	2	40	22
MAT01773	ALU0296	IA803-A	16.67	93	Reprovado	17	23	10
MAT02403	ALU0401	IA303-A	36.67	30	Reprovado	6	58	46
MAT00745	ALU0125	IA301-B	12.33	50	Reprovado	12	8	17
MAT00811	ALU0136	IA301-A	11.00	88	Reprovado	12	10	11
MAT01814	ALU0303	IA502-B	29.33	62	Reprovado	46	18	24
MAT01282	ALU0214	IA504-A	39.67	39	Reprovado	6	56	57
MAT02182	ALU0364	IA104-A	48.33	73	Reprovado	44	59	42
MAT00359	ALU0060	IA105-A	22.67	83	Reprovado	1	51	16
MAT01089	ALU0182	IA803-A	44.33	35	Reprovado	50	28	55
MAT00265	ALU0045	IA101-B	34.00	33	Reprovado	36	23	43
MAT05808	ALU0968	IA506-B	11.00	51	Reprovado	2	18	13
MAT02562	ALU0427	IA406-B	26.33	61	Reprovado	4	30	45
MAT01883	ALU0314	IA105-B	20.00	75	Reprovado	34	12	14
MAT05672	ALU0946	IA102-B	25.00	34	Reprovado	42	32	1
MAT05655	ALU0943	IA503-A	38.67	96	Reprovado	22	39	55
MAT01683	ALU0281	IA103-B	33.67	87	Reprovado	9	49	43
MAT02247	ALU0375	IA603-A	31.67	66	Reprovado	55	0	40
MAT01279	ALU0214	IA501-A	27.00	56	Reprovado	24	26	31
MAT01370	ALU0229	IA202-A	38.67	83	Reprovado	15	51	50
MAT01598	ALU0267	IA602-A	42.00	85	Reprovado	38	59	29
MAT01809	ALU0302	IA803-B	44.00	62	Reprovado	54	52	26
MAT01094	ALU0183	IA802-B	26.33	62	Reprovado	47	17	15
MAT01567	ALU0262	IA401-B	25.00	72	Reprovado	37	29	9
MAT01286	ALU0215	IA602-B	27.33	100	Reprovado	52	20	10
MAT01035	ALU0173	IA303-A	41.33	75	Reprovado	19	57	48
MAT02246	ALU0375	IA602-A	34.00	73	Reprovado	57	19	26
MAT01552	ALU0259	IA404-A	25.33	48	Reprovado	40	32	4
MAT04831	ALU0806	IA301-A	28.67	43	Reprovado	25	41	20
MAT00988	ALU0165	IA504-B	16.67	99	Reprovado	19	7	24
MAT05593	ALU0933	IA701-B	45.33	84	Reprovado	23	59	54
MAT02716	ALU0453	IA804-A	35.67	83	Reprovado	46	37	24
MAT03611	ALU0602	IA505-A	29.67	58	Reprovado	23	19	47
MAT00496	ALU0083	IA104-B	25.00	75	Reprovado	57	12	6
MAT05805	ALU0968	IA503-B	36.00	74	Reprovado	3	48	57
MAT04366	ALU0728	IA404-B	44.67	61	Reprovado	54	50	30
MAT04186	ALU0698	IA604-B	26.00	77	Reprovado	23	13	42
MAT05357	ALU0893	IA805-B	27.00	94	Reprovado	29	16	36
MAT00196	ALU0033	IA204-B	44.33	34	Reprovado	47	42	44
MAT01828	ALU0305	IA304-B	30.33	82	Reprovado	17	22	52
MAT00644	ALU0108	IA402-A	33.33	63	Reprovado	18	36	46
MAT05037	ALU0840	IA603-B	40.33	34	Reprovado	41	55	25
MAT02007	ALU0335	IA503-B	26.67	33	Reprovado	29	6	45
MAT02807	ALU0468	IA205-B	34.00	73	Reprovado	30	23	49
MAT02420	ALU0404	IA302-B	11.33	44	Reprovado	17	3	14
MAT00210	ALU0035	IA506-B	47.33	80	Reprovado	43	49	50
MAT01998	ALU0333	IA106-A	25.33	92	Reprovado	28	5	43
MAT00452	ALU0076	IA802-B	23.67	34	Reprovado	24	32	15
MAT01932	ALU0322	IA506-B	35.33	71	Reprovado	43	56	7
MAT01209	ALU0202	IA603-B	40.33	96	Reprovado	30	44	47
MAT02742	ALU0457	IA706-A	20.67	44	Reprovado	37	24	1
MAT02465	ALU0411	IA405-B	52.33	84	Reprovado	52	58	47
MAT03647	ALU0608	IA505-B	44.00	42	Reprovado	54	53	25
MAT03691	ALU0616	IA301-B	27.67	93	Reprovado	4	29	50
MAT05221	ALU0871	IA701-A	48.67	98	Reprovado	42	54	50
MAT04311	ALU0719	IA803-A	20.00	54	Reprovado	6	22	32
MAT03075	ALU0513	IA203-A	39.67	84	Reprovado	50	56	13
MAT00835	ALU0140	IA201-A	40.33	72	Reprovado	40	35	46
MAT02792	ALU0466	IA602-B	10.67	51	Reprovado	3	11	18
MAT03222	ALU0537	IA406-B	28.00	51	Reprovado	47	29	8
MAT01794	ALU0299	IA206-A	36.67	56	Reprovado	45	45	20
MAT04931	ALU0822	IA405-B	18.00	30	Reprovado	5	39	10
MAT01434	ALU0239	IA106-B	39.33	74	Reprovado	29	35	54
MAT00426	ALU0071	IA406-B	45.33	40	Reprovado	19	59	58
MAT01757	ALU0293	IA805-B	28.00	62	Reprovado	2	52	30
MAT05912	ALU0986	IA602-B	16.67	54	Reprovado	18	3	29
MAT02614	ALU0436	IA204-A	15.00	93	Reprovado	16	19	10
MAT05065	ALU0845	IA501-B	30.33	48	Reprovado	49	17	25
MAT05212	ALU0869	IA804-B	33.00	58	Reprovado	25	43	31
MAT03039	ALU0507	IA303-B	10.33	69	Reprovado	6	12	13
MAT05338	ALU0890	IA104-A	35.00	32	Reprovado	29	26	50
MAT02534	ALU0423	IA602-A	37.33	38	Reprovado	22	57	33
MAT02810	ALU0469	IA602-B	38.00	77	Reprovado	49	14	51
MAT03620	ALU0604	IA402-A	29.67	93	Reprovado	17	25	47
MAT00880	ALU0147	IA204-B	25.33	44	Reprovado	2	43	31
MAT01010	ALU0169	IA202-B	31.67	81	Reprovado	34	9	52
MAT02330	ALU0389	IA702-B	14.00	37	Reprovado	20	7	15
MAT05311	ALU0886	IA701-B	36.33	91	Reprovado	42	36	31
MAT01126	ALU0188	IA804-B	18.00	71	Reprovado	24	16	14
MAT02560	ALU0427	IA404-B	35.33	80	Reprovado	36	19	51
MAT05925	ALU0988	IA203-B	33.33	69	Reprovado	13	49	38
MAT03028	ALU0505	IA604-A	26.33	76	Reprovado	3	40	36
MAT05472	ALU0912	IA606-B	15.00	88	Reprovado	11	8	26
MAT03219	ALU0537	IA403-B	36.67	67	Reprovado	7	55	48
MAT00924	ALU0154	IA606-A	21.00	33	Reprovado	1	50	12
MAT02652	ALU0442	IA306-B	20.00	72	Reprovado	5	27	28
MAT02654	ALU0443	IA102-A	28.67	79	Reprovado	11	27	48
MAT05206	ALU0868	IA304-B	13.00	84	Reprovado	31	3	5
MAT04210	ALU0702	IA804-B	34.00	53	Reprovado	54	15	33
MAT04977	ALU0830	IA203-B	41.00	72	Reprovado	59	23	41
MAT02228	ALU0372	IA802-B	34.67	53	Reprovado	57	23	24
MAT05556	ALU0926	IA706-B	27.33	69	Reprovado	31	37	14
MAT01134	ALU0189	IA806-A	23.00	48	Reprovado	33	19	17
MAT00834	ALU0139	IA506-B	44.00	38	Reprovado	57	40	35
MAT04878	ALU0813	IA506-A	28.33	51	Reprovado	21	46	18
MAT05073	ALU0846	IA203-A	32.67	42	Reprovado	32	43	23
MAT03070	ALU0512	IA204-A	34.00	75	Reprovado	18	42	42
MAT00673	ALU0113	IA701-B	34.00	46	Reprovado	51	13	38
MAT02285	ALU0381	IA705-B	42.00	84	Reprovado	56	25	45
MAT00430	ALU0072	IA404-B	26.67	54	Reprovado	5	29	46
MAT01585	ALU0265	IA301-B	37.67	36	Reprovado	57	22	34
MAT02148	ALU0358	IA706-A	41.00	75	Reprovado	45	59	19
MAT01014	ALU0169	IA206-B	17.33	93	Reprovado	2	20	30
MAT02123	ALU0354	IA705-B	27.33	32	Reprovado	26	19	37
MAT02356	ALU0393	IA404-B	35.33	74	Reprovado	23	48	35
MAT01336	ALU0223	IA404-B	46.33	65	Reprovado	50	41	48
MAT01229	ALU0205	IA605-A	41.33	36	Reprovado	42	26	56
MAT00431	ALU0072	IA405-B	36.33	81	Reprovado	48	20	41
MAT02043	ALU0341	IA403-B	34.67	79	Reprovado	47	17	40
MAT00565	ALU0095	IA301-A	32.33	94	Reprovado	32	49	16
MAT02392	ALU0399	IA804-B	39.67	91	Reprovado	40	36	43
MAT01496	ALU0250	IA302-B	35.33	76	Reprovado	47	22	37
MAT01937	ALU0323	IA405-A	22.33	71	Reprovado	2	29	36
MAT01560	ALU0260	IA806-B	18.67	80	Reprovado	44	8	4
MAT00226	ALU0038	IA704-B	36.67	35	Reprovado	33	54	23
MAT01478	ALU0247	IA202-B	18.00	64	Reprovado	1	47	6
MAT02358	ALU0393	IA406-B	23.00	66	Reprovado	10	56	3
MAT03731	ALU0622	IA105-B	41.00	45	Reprovado	46	32	45
MAT05823	ALU0971	IA603-B	31.00	100	Reprovado	6	31	56
MAT04338	ALU0723	IA206-A	16.33	78	Reprovado	25	17	7
MAT02857	ALU0477	IA301-A	16.00	65	Reprovado	22	10	16
MAT00967	ALU0162	IA401-B	11.33	44	Reprovado	23	0	11
MAT04350	ALU0725	IA206-B	38.33	36	Reprovado	50	16	49
MAT05704	ALU0951	IA304-A	25.33	54	Reprovado	42	9	25
MAT04370	ALU0729	IA602-A	52.67	33	Reprovado	52	51	55
MAT00920	ALU0154	IA602-A	18.33	100	Reprovado	17	20	18
MAT04517	ALU0753	IA205-A	23.33	68	Reprovado	30	12	28
MAT03644	ALU0608	IA502-B	24.00	37	Reprovado	27	38	7
MAT02952	ALU0492	IA706-B	31.67	47	Reprovado	19	57	19
MAT04129	ALU0689	IA601-A	31.33	47	Reprovado	44	14	36
MAT03429	ALU0572	IA203-A	23.67	30	Reprovado	3	58	10
MAT00419	ALU0070	IA105-B	48.33	78	Reprovado	53	40	52
MAT03091	ALU0516	IA601-A	30.00	46	Reprovado	45	23	22
MAT00468	ALU0078	IA106-A	39.00	70	Reprovado	57	37	23
MAT02563	ALU0428	IA201-A	41.00	59	Reprovado	53	40	30
MAT03104	ALU0518	IA102-B	31.67	48	Reprovado	52	34	9
MAT02958	ALU0493	IA306-A	35.33	98	Reprovado	30	49	27
MAT02861	ALU0477	IA305-A	31.00	48	Reprovado	58	33	2
MAT05839	ALU0974	IA301-B	28.00	77	Reprovado	47	31	6
MAT00390	ALU0065	IA706-A	30.33	85	Reprovado	6	54	31
MAT00531	ALU0089	IA203-A	47.67	33	Reprovado	38	49	56
MAT05631	ALU0939	IA103-B	17.33	30	Reprovado	41	10	1
MAT01090	ALU0182	IA804-A	36.33	96	Reprovado	31	36	42
MAT01516	ALU0253	IA604-B	23.33	68	Reprovado	16	48	6
MAT03375	ALU0563	IA203-B	27.67	31	Reprovado	2	22	59
MAT03934	ALU0656	IA404-B	31.67	71	Reprovado	55	30	10
MAT05420	ALU0904	IA502-B	36.00	81	Reprovado	29	31	48
MAT01680	ALU0280	IA706-A	25.33	31	Reprovado	15	27	34
MAT05277	ALU0880	IA103-B	39.67	46	Reprovado	51	24	44
MAT03965	ALU0661	IA405-A	7.67	95	Reprovado	6	8	9
MAT05481	ALU0914	IA603-A	34.00	40	Reprovado	46	34	22
MAT05824	ALU0971	IA604-B	54.67	39	Reprovado	57	58	49
MAT04787	ALU0798	IA605-B	31.00	80	Reprovado	30	55	8
MAT01095	ALU0183	IA803-B	20.33	89	Reprovado	51	9	1
MAT00443	ALU0074	IA305-B	41.33	48	Reprovado	44	35	45
MAT00814	ALU0136	IA304-A	29.00	46	Reprovado	0	56	31
MAT01934	ALU0323	IA402-A	34.33	58	Reprovado	42	13	48
MAT00952	ALU0159	IA304-B	36.00	30	Reprovado	32	36	40
MAT05684	ALU0948	IA202-B	35.00	39	Reprovado	33	54	18
MAT02936	ALU0490	IA402-B	38.00	60	Reprovado	20	54	40
MAT02402	ALU0401	IA302-A	25.00	48	Reprovado	17	2	56
MAT02518	ALU0420	IA604-A	25.67	51	Reprovado	32	0	45
MAT00246	ALU0041	IA306-A	34.00	83	Reprovado	58	21	23
MAT01679	ALU0280	IA705-A	22.67	34	Reprovado	54	8	6
MAT03411	ALU0569	IA103-B	39.67	56	Reprovado	58	30	31
MAT00291	ALU0049	IA503-B	20.00	35	Reprovado	19	2	39
MAT05594	ALU0933	IA702-B	39.33	58	Reprovado	37	24	57
MAT04554	ALU0759	IA106-B	32.33	54	Reprovado	16	46	35
MAT03509	ALU0585	IA705-A	26.67	90	Reprovado	15	34	31
MAT00391	ALU0066	IA301-B	19.67	95	Reprovado	10	38	11
MAT00280	ALU0047	IA404-A	29.00	85	Reprovado	31	24	32
MAT02475	ALU0413	IA203-B	22.67	36	Reprovado	29	4	35
MAT00627	ALU0105	IA803-B	18.67	99	Reprovado	35	10	11
MAT00542	ALU0091	IA602-B	17.67	97	Reprovado	6	12	35
MAT00923	ALU0154	IA605-A	18.33	77	Reprovado	35	1	19
MAT01355	ALU0226	IA305-A	35.67	64	Reprovado	52	19	36
MAT01867	ALU0312	IA801-A	14.00	85	Reprovado	1	31	10
MAT02738	ALU0457	IA702-A	18.00	31	Reprovado	33	17	4
MAT03351	ALU0559	IA403-A	15.67	36	Reprovado	8	38	1
MAT00970	ALU0162	IA404-B	38.33	51	Reprovado	41	53	21
MAT03820	ALU0637	IA604-B	28.33	83	Reprovado	29	34	22
MAT04985	ALU0831	IA505-B	43.00	31	Reprovado	45	50	34
MAT04525	ALU0755	IA601-B	8.67	72	Reprovado	3	2	21
MAT00638	ALU0107	IA302-B	31.33	49	Reprovado	49	32	13
MAT05600	ALU0934	IA602-A	47.67	77	Reprovado	43	58	42
MAT00826	ALU0138	IA204-A	10.00	67	Reprovado	14	15	1
MAT01256	ALU0210	IA202-B	31.67	87	Reprovado	8	58	29
MAT04383	ALU0731	IA803-B	47.00	60	Reprovado	36	55	50
MAT02844	ALU0474	IA206-B	43.00	62	Reprovado	19	53	57
MAT03615	ALU0603	IA803-A	3.33	90	Reprovado	1	7	2
MAT05762	ALU0961	IA302-B	34.67	60	Reprovado	36	14	54
MAT03221	ALU0537	IA405-B	43.00	58	Reprovado	29	52	48
MAT03024	ALU0504	IA506-B	22.67	98	Reprovado	20	46	2
MAT00882	ALU0147	IA206-B	22.67	41	Reprovado	30	1	37
MAT03095	ALU0516	IA605-A	15.00	64	Reprovado	15	3	27
MAT02764	ALU0461	IA104-B	15.00	75	Reprovado	30	8	7
MAT04128	ALU0688	IA306-B	8.67	92	Reprovado	25	0	1
MAT03516	ALU0586	IA206-B	16.00	36	Reprovado	30	3	15
MAT03891	ALU0649	IA303-B	27.67	51	Reprovado	7	37	39
MAT04959	ALU0827	IA203-B	30.33	34	Reprovado	43	42	6
MAT01402	ALU0234	IA204-A	38.67	91	Reprovado	30	47	39
MAT05538	ALU0923	IA506-A	46.33	82	Reprovado	33	58	48
MAT03071	ALU0512	IA205-A	36.00	60	Reprovado	46	10	52
MAT05753	ALU0959	IA605-B	29.33	80	Reprovado	32	56	0
MAT01543	ALU0258	IA101-B	16.33	94	Reprovado	29	13	7
MAT04022	ALU0671	IA802-A	18.67	77	Reprovado	6	21	29
MAT00886	ALU0148	IA204-A	32.00	59	Reprovado	41	51	4
MAT00404	ALU0068	IA102-A	20.00	73	Reprovado	1	20	39
MAT05549	ALU0925	IA205-B	24.67	60	Reprovado	12	26	36
MAT03436	ALU0573	IA304-B	41.00	45	Reprovado	33	48	42
MAT04970	ALU0829	IA402-A	14.00	49	Reprovado	16	1	25
MAT02345	ALU0391	IA705-A	31.00	57	Reprovado	23	20	50
MAT01729	ALU0289	IA401-B	48.00	72	Reprovado	49	53	42
MAT01507	ALU0252	IA701-A	36.00	52	Reprovado	28	46	34
MAT04730	ALU0789	IA702-B	33.33	63	Reprovado	38	16	46
MAT02390	ALU0399	IA802-B	29.33	73	Reprovado	37	4	47
MAT02144	ALU0358	IA702-A	10.00	83	Reprovado	6	24	0
MAT05815	ALU0970	IA501-B	23.00	57	Reprovado	45	14	10
MAT05693	ALU0949	IA305-A	36.00	46	Reprovado	16	51	41
MAT05669	ALU0945	IA305-B	39.67	44	Reprovado	58	33	28
MAT00261	ALU0044	IA303-A	24.67	42	Reprovado	2	43	29
MAT05605	ALU0935	IA501-A	44.67	68	Reprovado	47	50	37
MAT02746	ALU0458	IA204-B	44.67	99	Reprovado	39	36	59
MAT00228	ALU0038	IA706-B	12.67	58	Reprovado	27	4	7
MAT00657	ALU0110	IA203-B	27.00	81	Reprovado	24	8	49
MAT05679	ALU0947	IA803-A	35.33	76	Reprovado	33	32	41
MAT00877	ALU0147	IA201-B	31.67	73	Reprovado	29	34	32
MAT02517	ALU0420	IA603-A	26.67	31	Reprovado	33	9	38
MAT00921	ALU0154	IA603-A	21.67	73	Reprovado	26	27	12
MAT00705	ALU0118	IA803-B	25.00	93	Reprovado	29	11	35
MAT01690	ALU0282	IA804-B	36.67	62	Reprovado	43	58	9
MAT01175	ALU0196	IA105-A	29.33	66	Reprovado	12	24	52
MAT00543	ALU0091	IA603-B	42.00	41	Reprovado	9	59	58
MAT04422	ALU0737	IA706-B	12.33	39	Reprovado	6	31	0
MAT01721	ALU0287	IA505-A	21.33	46	Reprovado	16	11	37
MAT04647	ALU0775	IA803-B	32.33	64	Reprovado	24	44	29
MAT00295	ALU0050	IA301-B	21.00	30	Reprovado	32	1	30
MAT01812	ALU0302	IA806-B	22.33	87	Reprovado	16	1	50
MAT01237	ALU0207	IA301-A	18.00	88	Reprovado	4	44	6
MAT03186	ALU0531	IA306-B	30.33	68	Reprovado	35	8	48
MAT05368	ALU0895	IA504-A	30.67	93	Reprovado	28	21	43
MAT05714	ALU0953	IA402-B	17.67	92	Reprovado	33	10	10
MAT02651	ALU0442	IA305-B	43.33	48	Reprovado	24	53	53
MAT01250	ALU0209	IA302-B	15.67	62	Reprovado	29	2	16
MAT03116	ALU0520	IA302-A	36.00	58	Reprovado	54	42	12
MAT05939	ALU0990	IA105-A	16.33	36	Reprovado	15	3	31
MAT02827	ALU0472	IA701-B	34.67	66	Reprovado	46	33	25
MAT00840	ALU0140	IA206-A	17.33	75	Reprovado	19	30	3
MAT02223	ALU0371	IA703-B	13.00	30	Reprovado	9	17	13
MAT03211	ALU0536	IA301-B	18.33	97	Reprovado	38	10	7
MAT02033	ALU0339	IA305-B	30.67	69	Reprovado	22	52	18
MAT04975	ALU0830	IA201-B	8.33	86	Reprovado	0	4	21
MAT01284	ALU0214	IA506-A	26.00	55	Reprovado	3	34	41
MAT01707	ALU0285	IA503-A	29.33	100	Reprovado	59	19	10
MAT02683	ALU0448	IA501-A	14.67	36	Reprovado	13	13	18
MAT00412	ALU0069	IA104-A	43.67	49	Reprovado	54	28	49
MAT01748	ALU0292	IA702-A	45.00	97	Reprovado	55	29	51
MAT02384	ALU0398	IA602-B	25.00	93	Reprovado	18	11	46
MAT02270	ALU0379	IA702-A	41.33	96	Reprovado	54	19	51
MAT03632	ALU0606	IA302-B	32.67	45	Reprovado	2	37	59
MAT00623	ALU0104	IA705-B	19.67	49	Reprovado	11	9	39
MAT00863	ALU0144	IA605-B	31.33	53	Reprovado	44	10	40
MAT04629	ALU0772	IA803-B	39.67	71	Reprovado	35	33	51
MAT04806	ALU0801	IA406-B	23.67	34	Reprovado	28	14	29
MAT01795	ALU0300	IA701-B	9.00	42	Reprovado	12	8	7
MAT05661	ALU0944	IA103-B	40.33	91	Reprovado	22	40	59
MAT02029	ALU0339	IA301-B	41.67	78	Reprovado	48	59	18
MAT04471	ALU0746	IA101-B	42.67	49	Reprovado	32	48	48
MAT01283	ALU0214	IA505-A	24.33	45	Reprovado	20	20	33
MAT02158	ALU0360	IA204-A	43.00	99	Reprovado	34	55	40
MAT04139	ALU0690	IA305-B	3.67	46	Reprovado	3	7	1
MAT03146	ALU0525	IA802-A	24.67	51	Reprovado	22	26	26
MAT03074	ALU0513	IA202-A	10.00	75	Reprovado	6	16	8
MAT00510	ALU0085	IA306-B	27.00	72	Reprovado	20	39	22
MAT00515	ALU0086	IA805-A	25.00	30	Reprovado	25	19	31
MAT04239	ALU0707	IA703-A	34.67	100	Reprovado	9	44	51
MAT01222	ALU0204	IA804-B	40.00	32	Reprovado	54	47	19
MAT00335	ALU0056	IA105-B	29.33	61	Reprovado	15	29	44
MAT01509	ALU0252	IA703-A	26.00	42	Reprovado	31	23	24
MAT03201	ALU0534	IA603-B	28.00	52	Reprovado	33	4	47
MAT00494	ALU0083	IA102-B	48.33	60	Reprovado	55	49	41
MAT05042	ALU0841	IA602-B	26.33	39	Reprovado	0	58	21
MAT01305	ALU0218	IA403-B	21.33	55	Reprovado	55	8	1
MAT00396	ALU0066	IA306-B	29.67	62	Reprovado	36	13	40
MAT02383	ALU0398	IA601-B	6.67	91	Reprovado	9	10	1
MAT02588	ALU0432	IA202-A	13.33	49	Reprovado	11	27	2
MAT04522	ALU0754	IA404-A	35.00	63	Reprovado	19	38	48
MAT01096	ALU0183	IA804-B	42.00	36	Reprovado	48	58	20
MAT05678	ALU0947	IA802-A	9.00	91	Reprovado	4	12	11
MAT00397	ALU0067	IA601-B	27.33	82	Reprovado	6	19	57
MAT05838	ALU0973	IA406-A	27.00	97	Reprovado	58	16	7
MAT05149	ALU0859	IA201-B	18.67	82	Reprovado	13	26	17
MAT03207	ALU0535	IA103-B	51.00	38	Reprovado	51	53	49
MAT02055	ALU0343	IA403-A	33.00	75	Reprovado	5	51	43
MAT02997	ALU0500	IA703-A	4.67	36	Reprovado	10	1	3
MAT01368	ALU0228	IA406-B	36.33	86	Reprovado	45	8	56
MAT02032	ALU0339	IA304-B	26.67	34	Reprovado	9	14	57
MAT05204	ALU0868	IA302-B	36.33	70	Reprovado	58	12	39
MAT00628	ALU0105	IA804-B	42.33	46	Reprovado	50	21	56
MAT03972	ALU0662	IA106-B	34.00	51	Reprovado	17	43	42
MAT05409	ALU0902	IA403-B	19.33	40	Reprovado	7	48	3
MAT03549	ALU0592	IA603-B	41.33	37	Reprovado	51	27	46
MAT01193	ALU0199	IA305-A	32.33	57	Reprovado	17	43	37
MAT01263	ALU0211	IA203-B	30.33	70	Reprovado	29	22	40
MAT05116	ALU0853	IA404-B	28.33	77	Reprovado	11	45	29
MAT00557	ALU0093	IA405-A	12.33	85	Reprovado	22	10	5
MAT04369	ALU0729	IA601-A	26.00	34	Reprovado	25	24	29
MAT04974	ALU0829	IA406-A	34.67	60	Reprovado	33	54	17
MAT01886	ALU0315	IA202-A	13.33	88	Reprovado	18	2	20
MAT05064	ALU0844	IA206-A	23.67	81	Reprovado	29	30	12
MAT05973	ALU0996	IA103-A	37.33	79	Reprovado	49	5	58
MAT02109	ALU0352	IA203-A	35.67	79	Reprovado	21	43	43
MAT02539	ALU0424	IA601-A	29.67	72	Reprovado	30	13	46
MAT05198	ALU0867	IA802-B	29.33	97	Reprovado	14	55	19
MAT02378	ALU0397	IA302-B	33.67	44	Reprovado	46	45	10
MAT01076	ALU0180	IA502-B	35.00	73	Reprovado	30	51	24
MAT00622	ALU0104	IA704-B	31.00	52	Reprovado	50	27	16
MAT04148	ALU0692	IA202-B	32.33	36	Reprovado	55	2	40
MAT02916	ALU0486	IA406-A	25.33	69	Reprovado	38	15	23
MAT02108	ALU0352	IA202-A	25.33	96	Reprovado	24	40	12
MAT05263	ALU0878	IA801-B	28.33	90	Reprovado	36	18	31
MAT03918	ALU0653	IA606-B	24.33	42	Reprovado	21	8	44
MAT02412	ALU0402	IA306-A	16.33	60	Reprovado	1	15	33
MAT01978	ALU0330	IA604-B	40.67	94	Reprovado	49	52	21
MAT05707	ALU0952	IA201-B	30.33	65	Reprovado	45	12	34
MAT01433	ALU0239	IA105-B	21.67	64	Reprovado	16	11	38
MAT02839	ALU0474	IA201-B	16.33	55	Reprovado	26	1	22
MAT05814	ALU0969	IA206-B	19.00	69	Reprovado	18	23	16
MAT04271	ALU0712	IA805-A	30.00	54	Reprovado	55	21	14
MAT03942	ALU0657	IA806-B	26.67	87	Reprovado	16	50	14
MAT02984	ALU0498	IA302-B	35.00	44	Reprovado	33	27	45
MAT01013	ALU0169	IA205-B	37.00	30	Reprovado	40	31	40
MAT00475	ALU0080	IA201-A	22.33	65	Reprovado	21	43	3
MAT02924	ALU0488	IA402-B	34.67	72	Reprovado	33	12	59
MAT00498	ALU0083	IA106-B	27.33	87	Reprovado	30	39	13
MAT01362	ALU0227	IA506-B	11.33	34	Reprovado	12	17	5
MAT00756	ALU0126	IA706-B	31.67	71	Reprovado	53	7	35
MAT02702	ALU0451	IA402-B	17.67	49	Reprovado	33	20	0
MAT03899	ALU0650	IA805-B	45.67	81	Reprovado	47	37	53
MAT01635	ALU0273	IA403-A	13.33	74	Reprovado	13	24	3
MAT01594	ALU0266	IA804-A	23.33	95	Reprovado	5	14	51
MAT01316	ALU0220	IA602-B	31.33	81	Reprovado	10	59	25
MAT00051	ALU0009	IA203-A	9.33	70	Reprovado	6	18	4
MAT00544	ALU0091	IA604-B	20.00	69	Reprovado	23	0	37
MAT04307	ALU0718	IA705-A	55.00	70	Reprovado	55	58	52
MAT02021	ALU0337	IA305-B	42.00	99	Reprovado	48	23	55
MAT03053	ALU0509	IA805-B	21.00	78	Reprovado	5	42	16
MAT05093	ALU0849	IA505-B	24.67	55	Reprovado	6	55	13
MAT00491	ALU0082	IA105-A	46.67	70	Reprovado	58	26	56
MAT03407	ALU0568	IA705-A	13.00	91	Reprovado	10	12	17
MAT00300	ALU0050	IA306-B	29.33	58	Reprovado	17	53	18
MAT05092	ALU0849	IA504-B	49.00	96	Reprovado	55	55	37
MAT04789	ALU0799	IA801-B	18.67	52	Reprovado	30	9	17
MAT00500	ALU0084	IA202-B	34.67	47	Reprovado	23	22	59
MAT03514	ALU0586	IA204-B	32.67	49	Reprovado	38	10	50
MAT00145	ALU0025	IA701-B	11.67	44	Reprovado	18	9	8
MAT04846	ALU0808	IA304-B	17.67	43	Reprovado	18	13	22
MAT01280	ALU0214	IA502-A	42.33	52	Reprovado	22	54	51
MAT02421	ALU0404	IA303-B	24.67	73	Reprovado	19	52	3
MAT01479	ALU0247	IA203-B	32.67	95	Reprovado	47	47	4
MAT05004	ALU0834	IA106-B	31.00	66	Reprovado	25	10	58
MAT02649	ALU0442	IA303-B	19.67	40	Reprovado	32	18	9
MAT04272	ALU0712	IA806-A	21.33	76	Reprovado	39	10	15
MAT00949	ALU0159	IA301-B	26.33	85	Reprovado	30	8	41
MAT00762	ALU0127	IA806-B	39.33	47	Reprovado	31	58	29
MAT01520	ALU0254	IA602-A	26.00	75	Reprovado	36	32	10
MAT02306	ALU0385	IA502-B	15.33	72	Reprovado	37	4	5
MAT00552	ALU0092	IA106-A	24.67	42	Reprovado	6	21	47
MAT01701	ALU0284	IA603-A	27.33	72	Reprovado	14	11	57
MAT00849	ALU0142	IA603-B	22.67	92	Reprovado	26	22	20
MAT05176	ALU0863	IA604-B	17.33	81	Reprovado	10	33	9
MAT00701	ALU0117	IA505-A	36.33	48	Reprovado	51	38	20
MAT05584	ALU0931	IA504-A	32.00	96	Reprovado	39	43	14
MAT01007	ALU0168	IA405-A	35.67	50	Reprovado	39	31	37
MAT01760	ALU0294	IA502-A	35.67	65	Reprovado	42	24	41
MAT02101	ALU0351	IA501-B	15.33	94	Reprovado	1	36	9
MAT01839	ALU0307	IA403-A	29.67	82	Reprovado	13	38	38
MAT05787	ALU0965	IA703-B	19.33	39	Reprovado	12	39	7
MAT01832	ALU0306	IA502-A	23.00	45	Reprovado	8	30	31
MAT03808	ALU0635	IA404-B	28.00	76	Reprovado	32	50	2
MAT04620	ALU0770	IA606-B	54.33	97	Reprovado	58	50	55
MAT00983	ALU0164	IA505-A	33.33	51	Reprovado	42	8	50
MAT01394	ALU0233	IA402-B	37.00	97	Reprovado	26	58	27
MAT05522	ALU0921	IA702-A	30.33	94	Reprovado	35	16	40
MAT02664	ALU0444	IA806-B	19.33	71	Reprovado	3	28	27
MAT00258	ALU0043	IA306-A	31.67	74	Reprovado	42	51	2
MAT02669	ALU0445	IA805-B	33.33	92	Reprovado	54	21	25
MAT00447	ALU0075	IA503-B	32.67	58	Reprovado	5	42	51
MAT02596	ALU0433	IA804-A	23.33	70	Reprovado	12	40	18
MAT03975	ALU0663	IA803-B	20.00	90	Reprovado	22	27	11
MAT04999	ALU0834	IA101-B	32.67	40	Reprovado	8	48	42
MAT01782	ALU0297	IA806-B	20.67	100	Reprovado	23	10	29
MAT00651	ALU0109	IA203-A	28.67	61	Reprovado	57	7	22
MAT02331	ALU0389	IA703-B	21.33	34	Reprovado	3	37	24
MAT01310	ALU0219	IA102-A	20.67	50	Reprovado	6	45	11
MAT00578	ALU0097	IA602-A	29.67	31	Reprovado	25	52	12
MAT04197	ALU0700	IA503-B	18.67	54	Reprovado	6	5	45
MAT04285	ALU0715	IA301-B	21.67	80	Reprovado	9	39	17
MAT04797	ALU0800	IA603-B	20.00	98	Reprovado	13	45	2
MAT03618	ALU0603	IA806-A	14.00	54	Reprovado	7	1	34
MAT05521	ALU0921	IA701-A	25.00	39	Reprovado	54	10	11
MAT04413	ALU0736	IA103-B	18.00	77	Reprovado	50	2	2
MAT05703	ALU0951	IA303-A	33.00	92	Reprovado	18	31	50
MAT02131	ALU0356	IA801-B	31.67	63	Reprovado	31	15	49
MAT01511	ALU0252	IA705-A	38.67	76	Reprovado	51	40	25
MAT03609	ALU0602	IA503-A	15.67	58	Reprovado	4	22	21
MAT00486	ALU0081	IA406-B	11.67	72	Reprovado	26	8	1
MAT05509	ALU0919	IA101-A	25.00	95	Reprovado	47	13	15
MAT00936	ALU0156	IA606-A	38.67	87	Reprovado	36	39	41
MAT01159	ALU0194	IA501-A	9.33	72	Reprovado	20	6	2
MAT03199	ALU0534	IA601-B	43.00	64	Reprovado	46	40	43
MAT05166	ALU0861	IA206-B	30.00	66	Reprovado	51	31	8
MAT05315	ALU0886	IA705-B	41.33	92	Reprovado	54	28	42
MAT02187	ALU0365	IA203-A	21.33	97	Reprovado	24	15	25
MAT00767	ALU0128	IA305-A	27.00	41	Reprovado	27	29	25
MAT01145	ALU0191	IA605-A	37.00	54	Reprovado	24	59	28
MAT01738	ALU0290	IA404-B	30.67	93	Reprovado	45	42	5
MAT02197	ALU0367	IA801-B	34.67	56	Reprovado	34	48	22
MAT01539	ALU0257	IA403-B	14.67	38	Reprovado	19	25	0
MAT02641	ALU0441	IA601-B	47.67	69	Reprovado	34	56	53
MAT03173	ALU0529	IA205-B	37.67	55	Reprovado	30	47	36
MAT02230	ALU0372	IA804-B	8.67	41	Reprovado	2	12	12
MAT01799	ALU0300	IA705-B	34.33	100	Reprovado	21	58	24
MAT04195	ALU0700	IA501-B	28.67	37	Reprovado	0	41	45
MAT03409	ALU0569	IA101-B	25.33	88	Reprovado	17	29	30
MAT01623	ALU0271	IA103-B	23.33	41	Reprovado	11	58	1
MAT02248	ALU0375	IA604-A	24.33	37	Reprovado	16	27	30
MAT05749	ALU0959	IA601-B	18.67	68	Reprovado	15	34	7
MAT02374	ALU0396	IA504-B	33.67	76	Reprovado	38	36	27
MAT02903	ALU0484	IA205-B	16.67	65	Reprovado	5	41	4
MAT01928	ALU0322	IA502-B	29.67	62	Reprovado	41	24	24
MAT01512	ALU0252	IA706-A	16.33	83	Reprovado	7	0	42
MAT04956	ALU0826	IA606-B	25.67	61	Reprovado	1	33	43
MAT02399	ALU0400	IA405-B	25.67	83	Reprovado	17	31	29
MAT02785	ALU0465	IA501-A	49.00	54	Reprovado	56	40	51
MAT02255	ALU0376	IA805-B	26.67	94	Reprovado	1	53	26
MAT05328	ALU0888	IA506-B	19.33	87	Reprovado	53	2	3
MAT05935	ALU0990	IA101-A	36.00	83	Reprovado	38	29	41
MAT01966	ALU0328	IA204-B	17.33	53	Reprovado	25	19	8
MAT03626	ALU0605	IA302-A	39.00	52	Reprovado	52	51	14
MAT01337	ALU0223	IA405-B	35.00	67	Reprovado	10	50	45
MAT02529	ALU0422	IA403-B	38.33	91	Reprovado	16	43	56
MAT02405	ALU0401	IA305-A	28.67	83	Reprovado	40	28	18
MAT01230	ALU0205	IA606-A	19.67	91	Reprovado	48	9	2
MAT02840	ALU0474	IA202-B	27.33	83	Reprovado	40	32	10
MAT02784	ALU0464	IA306-B	36.33	53	Reprovado	59	40	10
MAT03510	ALU0585	IA706-A	35.33	31	Reprovado	12	43	51
MAT02709	ALU0452	IA403-B	29.67	38	Reprovado	40	42	7
MAT01612	ALU0269	IA604-B	42.67	98	Reprovado	42	53	33
MAT02532	ALU0422	IA406-B	26.33	52	Reprovado	21	2	56
MAT00299	ALU0050	IA305-B	28.00	54	Reprovado	47	29	8
MAT00209	ALU0035	IA505-B	18.33	48	Reprovado	31	12	12
MAT00836	ALU0140	IA202-A	40.67	68	Reprovado	31	43	48
MAT05075	ALU0846	IA205-A	26.00	68	Reprovado	1	52	25
MAT01813	ALU0303	IA501-B	24.67	66	Reprovado	1	57	16
MAT05794	ALU0966	IA604-B	20.00	43	Reprovado	7	34	19
MAT02375	ALU0396	IA505-B	28.67	51	Reprovado	28	50	8
MAT02017	ALU0337	IA301-B	17.00	34	Reprovado	5	45	1
MAT04854	ALU0809	IA306-A	19.33	74	Reprovado	33	5	20
MAT03550	ALU0592	IA604-B	20.33	30	Reprovado	43	7	11
MAT03149	ALU0525	IA805-A	42.67	86	Reprovado	56	23	49
MAT01233	ALU0206	IA503-A	32.00	96	Reprovado	13	37	46
MAT03161	ALU0527	IA205-A	14.33	58	Reprovado	20	8	15
MAT05847	ALU0975	IA403-B	24.67	53	Reprovado	27	14	33
MAT05812	ALU0969	IA204-B	42.33	92	Reprovado	51	55	21
MAT01765	ALU0295	IA401-B	42.00	38	Reprovado	26	41	59
MAT05424	ALU0904	IA506-B	30.33	96	Reprovado	42	0	49
MAT03013	ALU0503	IA701-B	15.33	91	Reprovado	39	2	5
MAT01736	ALU0290	IA402-B	39.00	74	Reprovado	54	21	42
MAT02928	ALU0488	IA406-B	36.33	36	Reprovado	30	51	28
MAT05974	ALU0996	IA104-A	12.67	97	Reprovado	2	23	13
MAT05367	ALU0895	IA503-A	25.67	53	Reprovado	13	52	12
MAT01874	ALU0313	IA802-A	21.33	59	Reprovado	31	14	19
MAT01016	ALU0170	IA402-B	17.67	72	Reprovado	19	30	4
MAT05719	ALU0954	IA501-B	25.67	83	Reprovado	24	45	8
MAT00804	ALU0134	IA506-A	33.00	79	Reprovado	4	45	50
MAT00847	ALU0142	IA601-B	34.67	53	Reprovado	11	58	35
MAT02752	ALU0459	IA704-A	33.33	68	Reprovado	43	8	49
MAT02647	ALU0442	IA301-B	41.33	45	Reprovado	47	59	18
MAT01580	ALU0264	IA102-B	25.00	73	Reprovado	48	9	18
MAT01270	ALU0212	IA404-B	29.33	70	Reprovado	59	22	7
MAT05508	ALU0918	IA806-A	33.00	68	Reprovado	44	53	2
MAT01665	ALU0278	IA503-B	22.67	78	Reprovado	11	23	34
MAT04033	ALU0673	IA401-B	27.33	62	Reprovado	9	31	42
MAT00481	ALU0081	IA401-B	32.33	43	Reprovado	20	39	38
MAT01851	ALU0309	IA103-B	33.67	33	Reprovado	31	46	24
MAT01981	ALU0331	IA401-A	14.33	56	Reprovado	0	1	42
MAT00993	ALU0166	IA103-B	27.67	77	Reprovado	56	6	21
MAT01907	ALU0318	IA405-A	38.33	90	Reprovado	44	25	46
MAT02508	ALU0418	IA606-B	32.33	36	Reprovado	56	29	12
MAT01138	ALU0190	IA404-A	38.67	81	Reprovado	33	45	38
MAT03995	ALU0666	IA805-B	41.67	63	Reprovado	50	29	46
MAT03216	ALU0536	IA306-B	21.00	39	Reprovado	34	4	25
MAT02146	ALU0358	IA704-A	32.67	62	Reprovado	53	11	34
MAT00768	ALU0128	IA306-A	30.33	50	Reprovado	45	14	32
MAT02648	ALU0442	IA302-B	35.67	100	Reprovado	56	23	28
MAT05513	ALU0919	IA105-A	22.00	40	Reprovado	54	3	9
MAT04688	ALU0782	IA102-B	37.67	93	Reprovado	13	59	41
MAT02391	ALU0399	IA803-B	28.67	77	Reprovado	47	3	36
MAT02046	ALU0341	IA406-B	35.33	46	Reprovado	27	29	50
MAT00218	ALU0037	IA302-B	17.67	88	Reprovado	22	4	27
MAT05673	ALU0946	IA103-B	35.00	30	Reprovado	3	47	55
MAT03049	ALU0509	IA801-B	28.00	66	Reprovado	42	25	17
MAT01993	ALU0333	IA101-A	35.00	95	Reprovado	29	54	22
MAT04415	ALU0736	IA105-B	24.00	40	Reprovado	15	46	11
MAT05567	ALU0928	IA805-B	37.67	92	Reprovado	51	48	14
MAT03357	ALU0560	IA603-B	47.33	41	Reprovado	50	42	50
MAT02882	ALU0481	IA202-B	9.33	96	Reprovado	8	16	4
MAT02168	ALU0362	IA402-B	29.00	36	Reprovado	33	41	13
MAT04313	ALU0719	IA805-A	37.33	31	Reprovado	44	36	32
MAT03662	ALU0611	IA302-B	23.00	40	Reprovado	27	16	26
MAT02831	ALU0472	IA705-B	33.67	98	Reprovado	46	37	18
MAT02165	ALU0361	IA205-B	18.33	50	Reprovado	35	2	18
MAT03204	ALU0534	IA606-B	31.33	64	Reprovado	14	54	26
MAT01194	ALU0199	IA306-A	26.33	97	Reprovado	9	58	12
MAT00948	ALU0158	IA106-B	28.67	70	Reprovado	14	53	19
MAT01220	ALU0204	IA802-B	22.33	41	Reprovado	17	22	28
MAT01506	ALU0251	IA506-A	26.00	82	Reprovado	8	19	51
MAT01673	ALU0279	IA205-B	52.67	36	Reprovado	53	48	57
MAT02480	ALU0414	IA502-A	21.33	78	Reprovado	15	25	24
MAT02411	ALU0402	IA305-A	35.33	85	Reprovado	15	50	41
MAT01831	ALU0306	IA501-A	9.00	47	Reprovado	19	8	0
MAT01774	ALU0296	IA804-A	26.33	77	Reprovado	31	19	29
MAT03386	ALU0565	IA702-B	17.00	99	Reprovado	0	9	42
MAT02008	ALU0335	IA504-B	22.33	59	Reprovado	3	21	43
MAT02173	ALU0363	IA801-B	27.00	66	Reprovado	59	2	20
MAT00507	ALU0085	IA303-B	47.67	78	Reprovado	43	54	46
MAT01967	ALU0328	IA205-B	30.67	32	Reprovado	33	3	56
MAT02174	ALU0363	IA802-B	7.33	35	Reprovado	0	16	6
MAT01144	ALU0191	IA604-A	45.33	42	Reprovado	51	36	49
MAT02009	ALU0335	IA505-B	45.67	77	Reprovado	57	42	38
MAT03092	ALU0516	IA602-A	18.00	72	Reprovado	22	7	25
MAT05456	ALU0910	IA302-A	28.00	75	Reprovado	29	38	17
MAT03020	ALU0504	IA502-B	28.00	71	Reprovado	8	51	25
MAT02849	ALU0475	IA805-B	29.67	34	Reprovado	4	34	51
MAT05580	ALU0930	IA106-A	41.33	63	Reprovado	34	57	33
MAT05400	ALU0900	IA306-A	44.00	81	Reprovado	52	38	42
MAT03060	ALU0510	IA606-B	21.67	30	Reprovado	7	41	17
MAT00403	ALU0068	IA101-A	14.67	90	Reprovado	8	29	7
MAT04184	ALU0698	IA602-B	30.00	34	Reprovado	3	33	54
MAT05074	ALU0846	IA204-A	35.67	98	Reprovado	50	14	43
MAT01792	ALU0299	IA204-A	15.00	99	Reprovado	14	13	18
MAT05443	ALU0908	IA701-B	25.67	60	Reprovado	31	33	13
MAT02419	ALU0404	IA301-B	34.33	83	Reprovado	31	43	29
MAT04512	ALU0752	IA406-B	23.00	34	Reprovado	43	13	13
MAT03392	ALU0566	IA602-B	23.67	86	Reprovado	45	10	16
MAT01551	ALU0259	IA403-A	33.00	68	Reprovado	32	16	51
MAT00975	ALU0163	IA603-B	22.67	53	Reprovado	31	17	20
MAT01497	ALU0250	IA303-B	26.00	69	Reprovado	11	48	19
MAT03996	ALU0666	IA806-B	41.00	47	Reprovado	15	57	51
MAT03453	ALU0576	IA503-A	25.00	62	Reprovado	28	1	46
MAT02261	ALU0377	IA105-A	46.00	59	Reprovado	46	58	34
MAT02972	ALU0496	IA402-A	22.33	61	Reprovado	39	11	17
MAT05392	ALU0899	IA704-B	12.00	95	Reprovado	0	9	27
MAT03943	ALU0658	IA801-B	31.67	94	Reprovado	38	7	50
MAT04409	ALU0735	IA405-A	20.00	58	Reprovado	9	10	41
MAT01038	ALU0173	IA306-A	37.67	33	Reprovado	43	24	46
MAT00603	ALU0101	IA203-A	32.67	41	Reprovado	50	18	30
MAT02512	ALU0419	IA504-B	26.33	55	Reprovado	22	24	33
MAT04401	ALU0734	IA203-B	28.67	48	Reprovado	35	11	40
MAT05470	ALU0912	IA604-B	9.67	67	Reprovado	5	21	3
MAT05153	ALU0859	IA205-B	25.00	72	Reprovado	13	58	4
MAT02600	ALU0434	IA702-A	46.00	49	Reprovado	45	38	55
MAT00717	ALU0120	IA803-B	13.67	82	Reprovado	18	22	1
MAT01070	ALU0179	IA102-B	26.00	71	Reprovado	25	22	31
MAT03457	ALU0577	IA801-A	36.00	96	Reprovado	14	56	38
MAT03438	ALU0573	IA306-B	23.67	80	Reprovado	10	15	46
MAT04412	ALU0736	IA102-B	16.67	93	Reprovado	15	15	20
MAT03270	ALU0545	IA406-B	29.67	69	Reprovado	7	47	35
MAT00413	ALU0069	IA105-A	38.33	30	Reprovado	50	48	17
MAT05494	ALU0916	IA404-B	37.33	67	Reprovado	47	51	14
MAT00142	ALU0024	IA204-B	34.33	69	Reprovado	29	41	33
MAT05710	ALU0952	IA204-B	29.67	56	Reprovado	27	39	23
MAT05293	ALU0883	IA701-B	29.67	68	Reprovado	57	3	29
MAT01565	ALU0261	IA105-A	45.33	93	Reprovado	48	47	41
MAT02864	ALU0478	IA402-B	14.00	67	Reprovado	18	22	2
MAT00969	ALU0162	IA403-B	34.67	64	Reprovado	7	45	52
MAT01591	ALU0266	IA801-A	25.67	65	Reprovado	37	2	38
MAT03792	ALU0632	IA806-B	40.67	93	Reprovado	57	46	19
MAT02212	ALU0369	IA304-B	31.00	38	Reprovado	19	47	27
MAT04246	ALU0708	IA804-B	16.67	36	Reprovado	31	16	3
MAT05957	ALU0993	IA405-B	26.00	93	Reprovado	16	44	18
MAT05393	ALU0899	IA705-B	25.67	82	Reprovado	23	20	34
MAT00950	ALU0159	IA302-B	35.00	39	Reprovado	56	12	37
MAT02503	ALU0418	IA601-B	29.00	82	Reprovado	25	37	25
MAT00354	ALU0059	IA406-B	38.33	87	Reprovado	59	51	5
MAT01590	ALU0265	IA306-B	11.33	56	Reprovado	14	8	12
MAT03416	ALU0570	IA402-B	47.00	81	Reprovado	52	50	39
MAT01872	ALU0312	IA806-A	38.33	80	Reprovado	33	58	24
MAT00997	ALU0167	IA701-B	42.67	78	Reprovado	43	39	46
MAT04292	ALU0716	IA102-B	20.00	84	Reprovado	15	24	21
MAT02706	ALU0451	IA406-B	36.33	53	Reprovado	44	53	12
MAT01562	ALU0261	IA102-A	27.33	32	Reprovado	14	32	36
MAT01488	ALU0248	IA406-B	22.00	84	Reprovado	1	16	49
MAT05526	ALU0921	IA706-A	14.33	62	Reprovado	4	21	18
MAT03916	ALU0653	IA604-B	24.33	67	Reprovado	54	17	2
MAT03191	ALU0532	IA205-A	33.00	78	Reprovado	54	8	37
MAT02590	ALU0432	IA204-A	34.33	95	Reprovado	44	47	12
MAT00730	ALU0122	IA504-B	32.33	57	Reprovado	10	41	46
MAT05441	ALU0907	IA205-B	37.67	33	Reprovado	45	40	28
MAT01685	ALU0281	IA105-B	29.00	90	Reprovado	8	47	32
MAT01596	ALU0266	IA806-A	30.33	59	Reprovado	47	10	34
MAT03537	ALU0590	IA103-B	33.33	41	Reprovado	25	44	31
MAT01951	ALU0326	IA701-A	31.00	64	Reprovado	7	38	48
MAT02332	ALU0389	IA704-B	33.33	95	Reprovado	25	37	38
MAT03501	ALU0584	IA103-A	36.67	71	Reprovado	45	37	28
MAT00739	ALU0124	IA801-B	23.67	54	Reprovado	5	16	50
MAT03666	ALU0611	IA306-B	31.33	49	Reprovado	23	53	18
MAT01077	ALU0180	IA503-B	8.33	39	Reprovado	17	3	5
MAT01322	ALU0221	IA802-B	35.33	68	Reprovado	24	36	46
MAT00215	ALU0036	IA205-A	14.00	47	Reprovado	16	26	0
MAT00490	ALU0082	IA104-A	31.00	79	Reprovado	58	6	29
MAT05713	ALU0953	IA401-B	46.00	51	Reprovado	49	38	51
MAT03056	ALU0510	IA602-B	39.67	54	Reprovado	23	40	56
MAT04978	ALU0830	IA204-B	23.00	32	Reprovado	4	40	25
MAT03793	ALU0633	IA301-A	18.67	90	Reprovado	18	24	14
MAT02105	ALU0351	IA505-B	35.33	56	Reprovado	27	36	43
MAT04193	ALU0699	IA805-B	34.00	91	Reprovado	53	18	31
MAT00614	ALU0103	IA802-B	40.00	54	Reprovado	6	58	56
MAT03970	ALU0662	IA104-B	37.33	100	Reprovado	15	42	55
MAT00448	ALU0075	IA504-B	36.67	73	Reprovado	47	58	5
MAT05683	ALU0948	IA201-B	31.33	97	Reprovado	17	31	46
MAT00721	ALU0121	IA501-B	29.00	62	Reprovado	12	30	45
MAT02660	ALU0444	IA802-B	38.67	76	Reprovado	51	33	32
MAT00916	ALU0153	IA204-B	29.33	56	Reprovado	6	23	59
MAT03103	ALU0518	IA101-B	32.00	31	Reprovado	28	32	36
MAT05492	ALU0916	IA402-B	20.67	84	Reprovado	7	55	0
MAT00815	ALU0136	IA305-A	43.00	77	Reprovado	56	57	16
MAT02133	ALU0356	IA803-B	28.00	58	Reprovado	40	9	35
MAT00361	ALU0061	IA801-B	25.67	98	Reprovado	52	8	17
MAT01352	ALU0226	IA302-A	34.67	70	Reprovado	40	6	58
MAT00631	ALU0106	IA501-B	32.33	68	Reprovado	12	41	44
MAT05332	ALU0889	IA504-B	23.33	37	Reprovado	30	22	18
MAT05455	ALU0910	IA301-A	27.67	89	Reprovado	45	10	28
MAT05718	ALU0953	IA406-B	31.67	50	Reprovado	29	51	15
MAT03979	ALU0664	IA101-B	32.00	81	Reprovado	59	30	7
MAT02343	ALU0391	IA703-A	32.67	96	Reprovado	48	41	9
MAT01330	ALU0222	IA704-B	23.67	85	Reprovado	21	33	17
MAT05700	ALU0950	IA206-A	29.67	53	Reprovado	34	9	46
MAT01855	ALU0310	IA501-B	21.67	30	Reprovado	21	16	28
MAT02788	ALU0465	IA504-A	15.67	83	Reprovado	21	15	11
MAT02606	ALU0435	IA602-B	22.67	41	Reprovado	11	14	43
MAT00956	ALU0160	IA502-A	13.00	36	Reprovado	14	15	10
MAT00273	ALU0046	IA503-B	39.33	51	Reprovado	38	35	45
MAT01510	ALU0252	IA704-A	35.33	64	Reprovado	3	58	45
MAT02712	ALU0452	IA406-B	20.33	79	Reprovado	17	34	10
MAT03664	ALU0611	IA304-B	24.67	48	Reprovado	17	22	35
MAT01489	ALU0249	IA201-A	29.33	54	Reprovado	13	22	53
MAT01840	ALU0307	IA404-A	38.33	96	Reprovado	44	40	31
MAT02802	ALU0467	IA306-B	20.33	63	Reprovado	27	25	9
MAT05101	ALU0851	IA301-A	22.33	67	Reprovado	17	27	23
MAT05317	ALU0887	IA601-B	21.00	49	Reprovado	14	37	12
MAT03723	ALU0621	IA403-B	23.67	88	Reprovado	46	2	23
MAT05491	ALU0916	IA401-B	26.33	99	Reprovado	34	14	31
MAT05380	ALU0897	IA504-B	29.00	52	Reprovado	1	40	46
MAT00545	ALU0091	IA605-B	41.00	100	Reprovado	39	52	32
MAT03023	ALU0504	IA505-B	29.33	56	Reprovado	26	16	46
MAT01267	ALU0212	IA401-B	21.67	81	Reprovado	18	4	43
MAT00972	ALU0162	IA406-B	7.00	53	Reprovado	1	1	19
MAT02848	ALU0475	IA804-B	40.33	80	Reprovado	39	57	25
MAT01535	ALU0256	IA505-A	34.33	33	Reprovado	29	46	28
MAT03078	ALU0513	IA206-A	34.33	65	Reprovado	47	41	15
MAT02868	ALU0478	IA406-B	16.67	54	Reprovado	15	27	8
MAT00194	ALU0033	IA202-B	28.00	62	Reprovado	46	14	24
MAT05237	ALU0873	IA305-B	16.00	84	Reprovado	1	13	34
MAT00049	ALU0009	IA201-A	30.00	80	Reprovado	53	23	14
MAT03507	ALU0585	IA703-A	18.67	77	Reprovado	37	11	8
MAT02806	ALU0468	IA204-B	39.00	87	Reprovado	44	55	18
MAT03412	ALU0569	IA104-B	40.00	35	Reprovado	34	53	33
MAT00499	ALU0084	IA201-B	36.67	36	Reprovado	27	31	52
MAT04824	ALU0804	IA506-B	24.67	83	Reprovado	34	29	11
MAT01049	ALU0175	IA305-B	18.67	80	Reprovado	18	36	2
MAT04280	ALU0714	IA802-B	38.67	32	Reprovado	43	50	23
MAT01574	ALU0263	IA802-B	20.33	32	Reprovado	1	36	24
MAT00649	ALU0109	IA201-A	24.67	38	Reprovado	29	10	35
MAT05374	ALU0896	IA604-B	25.33	80	Reprovado	4	38	34
MAT02992	ALU0499	IA304-B	36.00	80	Reprovado	36	49	23
MAT01661	ALU0277	IA105-A	21.33	70	Reprovado	7	34	23
MAT01992	ALU0332	IA706-B	29.67	43	Reprovado	13	47	29
MAT04636	ALU0773	IA104-B	40.00	100	Reprovado	6	59	55
MAT04876	ALU0813	IA504-A	24.00	89	Reprovado	1	59	12
MAT00180	ALU0030	IA706-B	30.67	69	Reprovado	58	6	28
MAT01323	ALU0221	IA803-B	39.33	42	Reprovado	40	56	22
MAT01965	ALU0328	IA203-B	40.00	84	Reprovado	55	40	25
MAT00794	ALU0133	IA702-B	22.00	86	Reprovado	19	12	35
MAT01299	ALU0217	IA503-B	40.00	84	Reprovado	27	37	56
MAT03180	ALU0530	IA806-B	27.33	31	Reprovado	7	30	45
MAT02796	ALU0466	IA606-B	24.00	57	Reprovado	20	8	44
MAT05359	ALU0894	IA301-B	31.67	30	Reprovado	22	54	19
MAT02722	ALU0454	IA604-B	21.00	41	Reprovado	31	11	21
MAT03264	ALU0544	IA506-A	34.33	62	Reprovado	6	52	45
MAT04724	ALU0788	IA102-A	32.00	50	Reprovado	39	41	16
MAT00434	ALU0073	IA602-B	22.00	35	Reprovado	20	14	32
MAT00943	ALU0158	IA101-B	13.33	73	Reprovado	16	21	3
MAT00890	ALU0149	IA402-A	18.67	52	Reprovado	15	30	11
MAT03997	ALU0667	IA601-A	38.67	86	Reprovado	49	47	20
MAT04194	ALU0699	IA806-B	24.67	58	Reprovado	37	14	23
MAT02693	ALU0449	IA805-A	30.33	56	Reprovado	57	28	6
MAT02820	ALU0470	IA206-B	24.33	85	Reprovado	40	33	0
MAT02233	ALU0373	IA601-B	12.67	79	Reprovado	26	6	6
MAT05233	ALU0873	IA301-B	37.67	67	Reprovado	21	37	55
MAT01783	ALU0298	IA801-B	27.67	32	Reprovado	7	43	33
MAT05937	ALU0990	IA103-A	36.00	55	Reprovado	41	49	18
MAT01100	ALU0184	IA302-A	27.67	95	Reprovado	37	36	10
MAT01715	ALU0286	IA205-A	53.00	53	Reprovado	50	55	54
MAT03080	ALU0514	IA202-B	42.67	77	Reprovado	26	59	43
MAT05405	ALU0901	IA205-A	18.33	32	Reprovado	49	0	6
MAT01005	ALU0168	IA403-A	23.67	32	Reprovado	13	45	13
MAT02292	ALU0382	IA206-A	36.00	92	Reprovado	10	43	55
MAT04088	ALU0682	IA402-B	43.00	43	Reprovado	47	45	37
MAT02293	ALU0383	IA501-A	16.33	77	Reprovado	22	10	17
MAT04411	ALU0736	IA101-B	31.67	48	Reprovado	27	31	37
MAT02783	ALU0464	IA305-B	15.00	51	Reprovado	11	22	12
MAT03649	ALU0609	IA301-A	45.67	93	Reprovado	47	59	31
MAT02229	ALU0372	IA803-B	24.33	82	Reprovado	5	33	35
MAT00613	ALU0103	IA801-B	32.33	59	Reprovado	22	19	56
MAT05505	ALU0918	IA803-A	36.67	55	Reprovado	26	43	41
MAT03387	ALU0565	IA703-B	16.67	64	Reprovado	0	21	29
MAT00851	ALU0142	IA605-B	43.00	58	Reprovado	39	41	49
MAT03578	ALU0597	IA702-A	21.33	45	Reprovado	5	11	48
MAT03480	ALU0580	IA306-A	48.33	57	Reprovado	49	37	59
MAT03323	ALU0554	IA305-B	33.67	56	Reprovado	34	52	15
MAT02278	ALU0380	IA104-B	23.00	41	Reprovado	8	42	19
MAT02811	ALU0469	IA603-B	31.67	100	Reprovado	50	20	25
MAT03682	ALU0614	IA704-A	12.00	87	Reprovado	4	1	31
MAT02060	ALU0344	IA402-B	37.33	72	Reprovado	51	35	26
MAT03619	ALU0604	IA401-A	39.67	43	Reprovado	17	45	57
MAT02288	ALU0382	IA202-A	14.67	87	Reprovado	5	24	15
MAT02812	ALU0469	IA604-B	33.33	93	Reprovado	32	12	56
MAT04850	ALU0809	IA302-A	37.00	38	Reprovado	32	50	29
MAT03098	ALU0517	IA602-B	22.67	43	Reprovado	28	32	8
MAT04628	ALU0772	IA802-B	16.00	36	Reprovado	20	19	9
MAT01245	ALU0208	IA103-A	40.67	87	Reprovado	40	27	55
MAT04053	ALU0676	IA103-B	29.00	52	Reprovado	56	10	21
MAT02482	ALU0414	IA504-A	21.67	96	Reprovado	8	10	47
MAT05529	ALU0922	IA503-B	22.67	73	Reprovado	44	6	18
MAT04385	ALU0731	IA805-B	26.67	62	Reprovado	38	37	5
MAT01400	ALU0234	IA202-A	42.33	31	Reprovado	55	14	58
MAT03448	ALU0575	IA404-A	29.00	82	Reprovado	28	14	45
MAT02020	ALU0337	IA304-B	18.67	43	Reprovado	10	19	27
MAT02674	ALU0446	IA204-B	22.33	34	Reprovado	1	38	28
MAT03843	ALU0641	IA803-B	37.67	32	Reprovado	33	35	45
MAT02988	ALU0498	IA306-B	40.33	44	Reprovado	58	39	24
MAT03805	ALU0635	IA401-B	20.00	53	Reprovado	3	5	52
MAT03079	ALU0514	IA201-B	38.33	31	Reprovado	35	57	23
MAT03188	ALU0532	IA202-A	33.00	79	Reprovado	32	16	51
MAT01727	ALU0288	IA205-B	23.67	56	Reprovado	47	6	18
MAT05634	ALU0939	IA106-B	13.33	62	Reprovado	14	16	10
MAT01160	ALU0194	IA502-A	27.00	92	Reprovado	18	24	39
MAT05129	ALU0855	IA405-B	37.00	84	Reprovado	45	41	25
MAT05143	ALU0858	IA201-B	32.67	63	Reprovado	36	42	20
MAT05737	ALU0957	IA501-B	28.33	88	Reprovado	34	51	0
MAT02852	ALU0476	IA402-B	20.33	99	Reprovado	48	3	10
MAT05475	ALU0913	IA203-B	28.00	47	Reprovado	40	39	5
MAT00433	ALU0073	IA601-B	43.00	38	Reprovado	42	53	34
MAT05383	ALU0898	IA101-B	25.67	32	Reprovado	36	41	0
MAT02308	ALU0385	IA504-B	40.00	57	Reprovado	22	59	39
MAT05490	ALU0915	IA706-B	29.67	74	Reprovado	21	11	57
MAT04353	ALU0726	IA703-B	9.00	58	Reprovado	10	7	10
MAT02876	ALU0480	IA302-A	37.00	100	Reprovado	16	36	59
MAT04983	ALU0831	IA503-B	20.67	34	Reprovado	44	5	13
MAT05034	ALU0839	IA206-B	30.67	35	Reprovado	32	1	59
MAT02128	ALU0355	IA504-B	39.67	88	Reprovado	19	47	53
MAT03890	ALU0649	IA302-B	32.00	60	Reprovado	46	6	44
MAT02687	ALU0448	IA505-A	38.67	60	Reprovado	48	53	15
MAT00387	ALU0065	IA703-A	23.33	36	Reprovado	12	33	25
MAT04655	ALU0776	IA405-B	25.67	99	Reprovado	35	19	23
MAT05264	ALU0878	IA802-B	23.00	38	Reprovado	13	23	33
MAT03088	ALU0515	IA204-B	23.67	39	Reprovado	22	41	8
MAT02954	ALU0493	IA302-A	19.33	72	Reprovado	9	21	28
MAT04111	ALU0686	IA301-B	31.67	63	Reprovado	57	14	24
MAT05188	ALU0865	IA404-B	34.33	36	Reprovado	26	32	45
MAT05754	ALU0959	IA606-B	28.67	39	Reprovado	32	8	46
MAT05681	ALU0947	IA805-A	30.33	99	Reprovado	35	42	14
MAT05969	ALU0995	IA605-B	46.00	92	Reprovado	30	51	57
MAT03245	ALU0541	IA605-A	38.67	69	Reprovado	35	42	39
MAT00698	ALU0117	IA502-A	27.33	49	Reprovado	12	21	49
MAT01188	ALU0198	IA406-A	27.67	53	Reprovado	39	12	32
MAT05469	ALU0912	IA603-B	36.00	57	Reprovado	41	38	29
MAT05571	ALU0929	IA803-A	32.33	71	Reprovado	29	17	51
MAT01864	ALU0311	IA404-A	25.33	56	Reprovado	23	48	5
MAT03517	ALU0587	IA801-A	23.67	92	Reprovado	1	56	14
MAT00408	ALU0068	IA106-A	20.00	95	Reprovado	21	26	13
MAT03269	ALU0545	IA405-B	34.67	92	Reprovado	33	35	36
MAT03035	ALU0506	IA605-B	41.00	77	Reprovado	56	53	14
MAT04648	ALU0775	IA804-B	25.00	55	Reprovado	18	50	7
MAT05671	ALU0946	IA101-B	26.00	89	Reprovado	40	7	31
MAT00676	ALU0113	IA704-B	16.00	91	Reprovado	3	19	26
MAT02258	ALU0377	IA102-A	34.67	69	Reprovado	24	46	34
MAT00803	ALU0134	IA505-A	38.67	30	Reprovado	58	4	54
MAT00523	ALU0088	IA801-B	33.00	33	Reprovado	9	54	36
MAT03437	ALU0573	IA305-B	21.33	65	Reprovado	3	51	10
MAT05498	ALU0917	IA202-B	39.33	93	Reprovado	39	27	52
MAT01609	ALU0269	IA601-B	25.33	38	Reprovado	49	25	2
MAT00402	ALU0067	IA606-B	23.33	74	Reprovado	9	53	8
MAT01842	ALU0307	IA406-A	2.00	86	Reprovado	4	0	2
MAT02062	ALU0344	IA404-B	44.67	48	Reprovado	23	52	59
MAT05610	ALU0935	IA506-A	11.00	54	Reprovado	16	3	14
MAT00416	ALU0070	IA102-B	27.00	79	Reprovado	21	51	9
MAT00526	ALU0088	IA804-B	30.67	84	Reprovado	50	39	3
MAT04185	ALU0698	IA603-B	16.33	93	Reprovado	13	8	28
MAT03634	ALU0606	IA304-B	28.00	95	Reprovado	11	24	49
MAT01009	ALU0169	IA201-B	33.67	57	Reprovado	35	20	46
MAT04164	ALU0694	IA306-B	48.33	76	Reprovado	45	48	52
MAT05087	ALU0848	IA105-A	16.67	60	Reprovado	43	2	5
MAT00772	ALU0129	IA604-B	27.00	71	Reprovado	0	58	23
MAT05512	ALU0919	IA104-A	37.67	61	Reprovado	53	59	1
MAT00655	ALU0110	IA201-B	19.33	38	Reprovado	52	3	3
MAT01720	ALU0287	IA504-A	44.00	86	Reprovado	58	22	52
MAT02216	ALU0370	IA602-B	44.00	89	Reprovado	48	29	55
MAT03325	ALU0555	IA301-B	38.67	83	Reprovado	59	34	23
MAT00941	ALU0157	IA205-A	45.67	40	Reprovado	45	47	45
MAT05406	ALU0901	IA206-A	33.67	49	Reprovado	51	33	17
MAT04277	ALU0713	IA305-A	21.33	96	Reprovado	8	9	47
MAT01164	ALU0194	IA506-A	23.00	45	Reprovado	8	27	34
MAT00893	ALU0149	IA405-A	19.33	87	Reprovado	28	28	2
MAT05938	ALU0990	IA104-A	30.33	85	Reprovado	52	10	29
MAT05446	ALU0908	IA704-B	4.33	33	Reprovado	4	0	9
MAT01844	ALU0308	IA102-A	44.00	43	Reprovado	51	23	58
MAT01589	ALU0265	IA305-B	35.00	50	Reprovado	9	38	58
MAT01189	ALU0199	IA301-A	44.67	39	Reprovado	56	37	41
MAT05044	ALU0841	IA604-B	23.67	43	Reprovado	31	16	24
MAT05024	ALU0838	IA502-A	33.67	71	Reprovado	37	25	39
MAT03280	ALU0547	IA604-A	27.00	79	Reprovado	45	35	1
MAT04953	ALU0826	IA603-B	34.00	42	Reprovado	45	54	3
MAT02553	ALU0426	IA503-B	36.00	43	Reprovado	58	5	45
MAT03569	ALU0595	IA405-A	24.00	52	Reprovado	12	13	47
MAT04890	ALU0815	IA206-A	43.00	61	Reprovado	33	49	47
MAT00858	ALU0143	IA206-A	7.00	46	Reprovado	3	16	2
MAT01269	ALU0212	IA403-B	27.67	44	Reprovado	14	57	12
MAT03991	ALU0666	IA801-B	31.00	43	Reprovado	29	32	32
MAT02245	ALU0375	IA601-A	13.67	99	Reprovado	4	0	37
MAT02678	ALU0447	IA102-B	33.67	38	Reprovado	47	29	25
MAT03105	ALU0518	IA103-B	19.33	42	Reprovado	36	8	14
MAT00244	ALU0041	IA304-A	14.00	43	Reprovado	7	35	0
MAT04469	ALU0745	IA305-B	38.00	81	Reprovado	25	45	44
MAT01404	ALU0234	IA206-A	22.67	72	Reprovado	45	0	23
MAT05401	ALU0901	IA201-A	24.00	34	Reprovado	13	11	48
MAT05544	ALU0924	IA606-B	22.33	88	Reprovado	28	0	39
MAT02267	ALU0378	IA605-B	40.67	49	Reprovado	38	51	33
MAT01986	ALU0331	IA406-A	45.33	47	Reprovado	35	50	51
MAT00144	ALU0024	IA206-B	37.00	90	Reprovado	19	53	39
MAT00415	ALU0070	IA101-B	13.00	51	Reprovado	14	22	3
MAT03189	ALU0532	IA203-A	36.33	50	Reprovado	52	3	54
MAT04875	ALU0813	IA503-A	47.67	39	Reprovado	34	55	54
MAT00362	ALU0061	IA802-B	53.00	51	Reprovado	54	51	54
MAT00439	ALU0074	IA301-B	23.00	56	Reprovado	6	24	39
MAT00825	ALU0138	IA203-A	20.33	83	Reprovado	4	10	47
MAT01211	ALU0202	IA605-B	31.67	38	Reprovado	5	52	38
MAT01447	ALU0242	IA401-A	30.33	69	Reprovado	4	38	49
MAT00455	ALU0076	IA805-B	32.00	58	Reprovado	23	56	17
MAT05568	ALU0928	IA806-B	41.33	47	Reprovado	56	22	46
MAT03143	ALU0524	IA205-B	34.67	90	Reprovado	57	32	15
MAT01066	ALU0178	IA604-B	28.00	38	Reprovado	21	12	51
MAT02741	ALU0457	IA705-A	50.33	46	Reprovado	59	41	51
MAT05000	ALU0834	IA102-B	27.67	41	Reprovado	14	18	51
MAT02666	ALU0445	IA802-B	14.00	72	Reprovado	10	6	26
MAT02628	ALU0438	IA106-B	16.67	44	Reprovado	12	33	5
MAT01093	ALU0183	IA801-B	34.67	49	Reprovado	15	31	58
MAT03898	ALU0650	IA804-B	27.00	43	Reprovado	18	38	25
MAT05953	ALU0993	IA401-B	21.00	39	Reprovado	33	4	26
MAT02099	ALU0350	IA805-B	40.00	69	Reprovado	54	49	17
MAT05476	ALU0913	IA204-B	25.33	75	Reprovado	15	53	8
MAT04404	ALU0734	IA206-B	16.33	53	Reprovado	11	15	23
MAT03763	ALU0628	IA401-B	36.67	84	Reprovado	15	36	59
MAT00140	ALU0024	IA202-B	38.00	68	Reprovado	37	18	59
MAT05985	ALU0998	IA703-B	36.67	77	Reprovado	35	58	17
MAT01899	ALU0317	IA803-A	8.33	65	Reprovado	15	9	1
MAT01185	ALU0198	IA403-A	17.33	83	Reprovado	12	10	30
MAT05764	ALU0961	IA304-B	19.00	60	Reprovado	12	28	17
MAT05793	ALU0966	IA603-B	20.00	92	Reprovado	40	20	0
MAT03496	ALU0583	IA104-A	34.00	81	Reprovado	43	50	9
MAT05835	ALU0973	IA403-A	22.33	32	Reprovado	5	45	17
MAT05514	ALU0919	IA106-A	26.00	87	Reprovado	1	21	56
MAT00564	ALU0094	IA606-A	40.67	96	Reprovado	44	33	45
MAT03202	ALU0534	IA604-B	20.67	37	Reprovado	36	12	14
MAT02789	ALU0465	IA505-A	21.67	89	Reprovado	8	18	39
MAT00995	ALU0166	IA105-B	27.00	83	Reprovado	4	40	37
MAT04012	ALU0669	IA304-A	40.00	55	Reprovado	43	39	38
MAT04160	ALU0694	IA302-B	18.00	51	Reprovado	14	37	3
MAT01053	ALU0176	IA203-B	26.00	44	Reprovado	55	19	4
MAT03832	ALU0639	IA304-B	38.33	57	Reprovado	15	53	47
MAT00146	ALU0025	IA702-B	42.00	42	Reprovado	58	22	46
MAT05200	ALU0867	IA804-B	30.67	93	Reprovado	31	29	32
MAT03230	ALU0539	IA702-B	29.33	61	Reprovado	22	54	12
MAT03552	ALU0592	IA606-B	44.67	37	Reprovado	51	32	51
MAT05440	ALU0907	IA204-B	40.00	82	Reprovado	50	49	21
MAT03842	ALU0641	IA802-B	14.67	64	Reprovado	12	6	26
MAT01505	ALU0251	IA505-A	24.67	45	Reprovado	25	38	11
MAT05837	ALU0973	IA405-A	31.33	45	Reprovado	33	29	32
MAT00472	ALU0079	IA404-B	7.67	91	Reprovado	4	13	6
MAT02296	ALU0383	IA504-A	17.00	74	Reprovado	32	1	18
MAT00726	ALU0121	IA506-B	26.33	35	Reprovado	5	16	58
MAT02949	ALU0492	IA703-B	34.33	33	Reprovado	18	26	59
MAT03789	ALU0632	IA803-B	30.00	41	Reprovado	11	38	41
MAT00525	ALU0088	IA803-B	30.67	46	Reprovado	16	47	29
MAT01335	ALU0223	IA403-B	44.67	71	Reprovado	36	51	47
MAT04174	ALU0696	IA704-B	8.33	87	Reprovado	14	8	3
MAT02901	ALU0484	IA203-B	25.33	43	Reprovado	5	15	56
MAT02870	ALU0479	IA402-B	35.33	54	Reprovado	27	42	37
MAT01500	ALU0250	IA306-B	34.67	88	Reprovado	54	43	7
MAT02019	ALU0337	IA303-B	21.67	62	Reprovado	14	39	12
MAT02396	ALU0400	IA402-B	50.67	90	Reprovado	54	40	58
MAT05579	ALU0930	IA105-A	36.33	87	Reprovado	41	17	51
MAT05468	ALU0912	IA602-B	44.00	55	Reprovado	39	36	57
MAT03893	ALU0649	IA305-B	28.33	90	Reprovado	54	3	28
MAT05113	ALU0853	IA401-B	40.33	69	Reprovado	13	56	52
MAT00913	ALU0153	IA201-B	37.67	80	Reprovado	40	55	18
MAT02879	ALU0480	IA305-A	34.67	87	Reprovado	35	55	14
MAT01065	ALU0178	IA603-B	29.67	42	Reprovado	35	5	49
MAT03110	ALU0519	IA502-B	50.00	75	Reprovado	52	57	41
MAT05386	ALU0898	IA104-B	31.00	34	Reprovado	28	29	36
MAT00985	ALU0165	IA501-B	23.00	97	Reprovado	3	35	31
MAT02294	ALU0383	IA502-A	41.00	82	Reprovado	58	22	43
MAT02243	ALU0374	IA305-B	38.67	53	Reprovado	7	54	55
MAT01296	ALU0216	IA206-A	19.67	76	Reprovado	38	10	11
MAT01371	ALU0229	IA203-A	18.33	31	Reprovado	26	0	29
MAT00841	ALU0141	IA801-B	34.67	72	Reprovado	32	21	51
MAT01254	ALU0209	IA306-B	25.33	86	Reprovado	56	15	5
MAT05244	ALU0874	IA206-B	34.67	82	Reprovado	54	48	2
MAT00241	ALU0041	IA301-A	19.67	76	Reprovado	17	8	34
MAT01948	ALU0325	IA604-B	39.67	83	Reprovado	39	22	58
MAT05110	ALU0852	IA704-A	23.67	93	Reprovado	31	33	7
MAT00618	ALU0103	IA806-B	16.00	67	Reprovado	8	31	9
MAT02847	ALU0475	IA803-B	25.67	80	Reprovado	33	4	40
MAT03131	ALU0522	IA405-B	36.67	70	Reprovado	57	24	29
MAT04462	ALU0744	IA304-B	27.33	32	Reprovado	12	39	31
MAT03132	ALU0522	IA406-B	35.00	82	Reprovado	24	59	22
MAT05453	ALU0909	IA405-B	13.67	47	Reprovado	4	19	18
MAT04857	ALU0810	IA803-B	19.33	68	Reprovado	39	2	17
MAT01129	ALU0189	IA801-A	30.33	99	Reprovado	44	27	20
MAT02118	ALU0353	IA306-B	20.67	72	Reprovado	27	25	10
MAT02636	ALU0440	IA502-A	29.33	62	Reprovado	53	8	27
MAT02909	ALU0485	IA305-B	26.00	35	Reprovado	14	8	56
MAT02231	ALU0372	IA805-B	33.67	86	Reprovado	35	52	14
MAT01820	ALU0304	IA802-B	39.67	63	Reprovado	49	46	24
MAT02543	ALU0424	IA605-A	28.67	40	Reprovado	27	23	36
MAT04835	ALU0806	IA305-A	36.00	70	Reprovado	59	43	6
MAT01226	ALU0205	IA602-A	21.00	38	Reprovado	35	14	14
MAT05125	ALU0855	IA401-B	10.00	50	Reprovado	22	5	3
MAT01861	ALU0311	IA401-A	38.00	63	Reprovado	21	41	52
MAT03490	ALU0582	IA204-B	37.00	40	Reprovado	45	16	50
MAT02633	ALU0439	IA805-B	37.67	86	Reprovado	41	27	45
MAT02558	ALU0427	IA402-B	11.67	46	Reprovado	22	1	12
MAT02491	ALU0416	IA801-B	19.33	95	Reprovado	30	16	12
MAT03801	ALU0634	IA303-B	32.00	85	Reprovado	16	47	33
MAT05081	ALU0847	IA805-A	27.00	90	Reprovado	8	51	22
MAT05799	ALU0967	IA403-B	27.00	71	Reprovado	25	16	40
MAT00666	ALU0111	IA806-A	41.33	68	Reprovado	48	36	40
MAT03591	ALU0599	IA703-B	14.00	97	Reprovado	3	12	27
MAT01611	ALU0269	IA603-B	33.00	50	Reprovado	52	9	38
MAT02200	ALU0367	IA804-B	39.00	51	Reprovado	59	24	34
MAT00460	ALU0077	IA404-A	46.00	93	Reprovado	54	40	44
MAT04720	ALU0787	IA504-A	25.67	52	Reprovado	20	17	40
MAT03019	ALU0504	IA501-B	31.67	59	Reprovado	35	3	57
MAT02899	ALU0484	IA201-B	29.67	59	Reprovado	28	40	21
MAT00497	ALU0083	IA105-B	24.67	53	Reprovado	27	26	21
MAT05266	ALU0878	IA804-B	46.00	45	Reprovado	35	59	44
MAT05051	ALU0842	IA505-B	32.33	72	Reprovado	41	45	11
MAT01566	ALU0261	IA106-A	30.33	76	Reprovado	31	4	56
MAT00283	ALU0048	IA801-A	15.00	63	Reprovado	2	21	22
MAT02878	ALU0480	IA304-A	29.67	70	Reprovado	37	37	15
MAT04555	ALU0760	IA501-B	40.33	95	Reprovado	38	29	54
MAT00414	ALU0069	IA106-A	32.33	31	Reprovado	22	22	53
MAT04177	ALU0697	IA201-B	16.33	87	Reprovado	24	1	24
MAT01959	ALU0327	IA103-A	25.67	84	Reprovado	23	29	25
MAT05267	ALU0878	IA805-B	3.67	92	Reprovado	0	4	7
MAT02686	ALU0448	IA504-A	47.00	37	Reprovado	36	51	54
MAT01054	ALU0176	IA204-B	30.67	36	Reprovado	28	45	19
MAT03157	ALU0527	IA201-A	38.00	37	Reprovado	56	17	41
MAT00141	ALU0024	IA203-B	30.33	54	Reprovado	49	13	29
MAT00197	ALU0033	IA205-B	32.00	84	Reprovado	23	40	33
MAT01996	ALU0333	IA104-A	36.33	61	Reprovado	52	21	36
MAT02923	ALU0488	IA401-B	29.33	52	Reprovado	26	44	18
MAT00233	ALU0039	IA205-B	32.67	45	Reprovado	46	6	46
MAT03370	ALU0562	IA404-B	20.00	86	Reprovado	21	14	25
MAT00495	ALU0083	IA103-B	29.00	98	Reprovado	17	43	27
MAT02976	ALU0496	IA406-A	14.67	32	Reprovado	33	6	5
MAT03213	ALU0536	IA303-B	10.00	67	Reprovado	24	5	1
MAT02979	ALU0497	IA603-B	35.00	40	Reprovado	50	1	54
MAT02786	ALU0465	IA502-A	16.67	82	Reprovado	24	18	8
MAT00148	ALU0025	IA704-B	36.33	69	Reprovado	48	26	35
MAT02371	ALU0396	IA501-B	37.67	93	Reprovado	33	55	25
MAT02312	ALU0386	IA602-A	14.00	33	Reprovado	11	6	25
MAT00323	ALU0054	IA405-A	26.00	36	Reprovado	30	22	26
MAT00929	ALU0155	IA105-A	8.00	53	Reprovado	18	3	3
MAT02304	ALU0384	IA206-B	23.00	47	Reprovado	50	8	11
MAT05171	ALU0862	IA505-B	4.33	57	Reprovado	0	1	12
MAT00007	ALU0002	IA101-B	24.00	83	Reprovado	29	29	14
MAT00786	ALU0131	IA806-A	40.33	90	Reprovado	44	28	49
MAT01925	ALU0321	IA205-B	30.00	68	Reprovado	38	18	34
MAT01863	ALU0311	IA403-A	27.00	63	Reprovado	31	32	18
MAT00131	ALU0022	IA405-A	22.00	69	Reprovado	3	51	12
MAT04187	ALU0698	IA605-B	25.67	90	Reprovado	27	37	13
MAT00075	ALU0013	IA703-A	24.00	55	Reprovado	50	19	3
MAT02192	ALU0366	IA302-B	14.67	33	Reprovado	6	1	37
MAT02790	ALU0465	IA506-A	28.00	48	Reprovado	19	34	31
MAT03845	ALU0641	IA805-B	27.33	90	Reprovado	15	43	24
MAT03679	ALU0614	IA701-A	22.00	80	Reprovado	19	33	14
MAT01251	ALU0209	IA303-B	26.33	81	Reprovado	22	5	52
MAT04334	ALU0723	IA202-A	15.00	100	Reprovado	40	4	1
MAT05463	ALU0911	IA503-A	25.33	31	Reprovado	9	34	33
MAT05169	ALU0862	IA503-B	38.33	53	Reprovado	47	53	15
MAT02929	ALU0489	IA601-A	17.33	62	Reprovado	7	12	33
MAT01377	ALU0230	IA803-B	20.33	66	Reprovado	10	17	34
MAT01586	ALU0265	IA302-B	37.67	35	Reprovado	54	0	59
MAT04484	ALU0748	IA602-B	22.00	62	Reprovado	11	18	37
MAT02940	ALU0490	IA406-B	46.00	51	Reprovado	34	51	53
MAT01217	ALU0203	IA105-A	35.33	50	Reprovado	23	31	52
MAT03742	ALU0624	IA704-B	30.67	83	Reprovado	56	8	28
MAT02659	ALU0444	IA801-B	16.33	53	Reprovado	43	2	4
MAT05390	ALU0899	IA702-B	17.33	73	Reprovado	10	24	18
MAT01743	ALU0291	IA103-B	26.67	75	Reprovado	34	23	23
MAT02568	ALU0428	IA206-A	35.33	84	Reprovado	38	18	50
MAT02773	ALU0463	IA601-A	33.33	95	Reprovado	12	58	30
MAT03036	ALU0506	IA606-B	20.67	41	Reprovado	2	38	22
MAT02309	ALU0385	IA505-B	39.67	75	Reprovado	55	14	50
MAT05381	ALU0897	IA505-B	16.67	45	Reprovado	27	20	3
MAT05795	ALU0966	IA605-B	54.33	38	Reprovado	55	49	59
MAT05674	ALU0946	IA104-B	26.33	80	Reprovado	9	53	17
MAT03152	ALU0526	IA502-B	33.33	50	Reprovado	29	40	31
MAT02114	ALU0353	IA302-B	31.00	83	Reprovado	44	12	37
MAT02155	ALU0360	IA201-A	45.00	91	Reprovado	50	56	29
MAT01026	ALU0171	IA106-A	43.00	100	Reprovado	55	28	46
MAT00708	ALU0118	IA806-B	35.67	33	Reprovado	22	26	59
MAT01784	ALU0298	IA802-B	34.67	60	Reprovado	45	44	15
MAT04179	ALU0697	IA203-B	25.00	99	Reprovado	10	15	50
MAT05770	ALU0962	IA304-B	24.67	43	Reprovado	28	13	33
MAT01455	ALU0243	IA303-A	48.33	84	Reprovado	52	56	37
MAT03931	ALU0656	IA401-B	34.33	92	Reprovado	36	22	45
MAT01830	ALU0305	IA306-B	34.33	69	Reprovado	29	15	59
MAT01517	ALU0253	IA605-B	26.67	87	Reprovado	4	57	19
MAT01295	ALU0216	IA205-A	23.00	89	Reprovado	1	46	22
MAT05144	ALU0858	IA202-B	32.67	97	Reprovado	53	10	35
MAT02519	ALU0420	IA605-A	16.67	45	Reprovado	4	31	15
MAT03040	ALU0507	IA304-B	88.33	95	Aprovado	94	100	71
MAT03123	ALU0521	IA503-B	22.33	66	Reprovado	44	16	7
MAT05140	ALU0857	IA404-A	21.33	63	Reprovado	40	16	8
MAT00417	ALU0070	IA103-B	30.00	58	Reprovado	12	31	47
MAT04013	ALU0669	IA305-A	29.00	55	Reprovado	20	24	43
MAT03650	ALU0609	IA302-A	25.67	59	Reprovado	14	49	14
MAT03484	ALU0581	IA304-B	47.67	87	Reprovado	57	35	51
MAT00478	ALU0080	IA204-A	33.67	64	Reprovado	57	26	18
MAT03066	ALU0511	IA606-B	44.00	45	Reprovado	44	30	58
MAT01796	ALU0300	IA702-B	45.67	67	Reprovado	52	45	40
MAT02217	ALU0370	IA603-B	33.00	43	Reprovado	26	47	26
MAT03029	ALU0505	IA605-A	39.33	73	Reprovado	16	57	45
MAT04364	ALU0728	IA402-B	18.00	73	Reprovado	2	11	41
MAT03735	ALU0623	IA603-A	14.67	38	Reprovado	14	16	14
MAT00611	ALU0102	IA505-A	21.00	64	Reprovado	13	14	36
MAT01791	ALU0299	IA203-A	17.67	94	Reprovado	18	17	18
MAT01084	ALU0181	IA704-B	29.00	72	Reprovado	58	15	14
MAT02496	ALU0416	IA806-B	24.00	87	Reprovado	8	53	11
MAT00648	ALU0108	IA406-A	18.67	95	Reprovado	51	3	2
MAT03866	ALU0645	IA602-B	37.33	60	Reprovado	29	24	59
MAT04944	ALU0824	IA306-B	20.33	41	Reprovado	19	2	40
MAT03439	ALU0574	IA501-A	28.33	86	Reprovado	39	15	31
MAT05928	ALU0988	IA206-B	33.67	35	Reprovado	22	34	45
MAT03740	ALU0624	IA702-B	25.00	64	Reprovado	38	12	25
MAT00168	ALU0028	IA306-B	39.33	91	Reprovado	55	29	34
MAT04538	ALU0757	IA202-A	22.67	57	Reprovado	28	4	36
MAT03083	ALU0514	IA205-B	23.33	84	Reprovado	39	12	19
MAT00304	ALU0051	IA104-A	39.67	50	Reprovado	23	40	56
MAT01667	ALU0278	IA505-B	43.00	80	Reprovado	25	52	52
MAT05199	ALU0867	IA803-B	36.67	84	Reprovado	52	24	34
MAT01002	ALU0167	IA706-B	35.00	61	Reprovado	5	53	47
MAT00931	ALU0156	IA601-A	29.33	96	Reprovado	39	42	7
MAT03344	ALU0558	IA102-B	35.33	76	Reprovado	34	52	20
MAT03570	ALU0595	IA406-A	42.00	99	Reprovado	15	53	58
MAT00592	ALU0099	IA404-B	42.33	83	Reprovado	59	43	25
MAT03404	ALU0568	IA702-A	16.67	60	Reprovado	21	24	5
MAT02957	ALU0493	IA305-A	32.00	75	Reprovado	2	36	58
MAT05482	ALU0914	IA604-A	34.00	30	Reprovado	32	48	22
MAT05071	ALU0846	IA201-A	22.67	71	Reprovado	26	41	1
MAT04232	ALU0706	IA702-B	23.00	50	Reprovado	26	13	30
MAT05539	ALU0924	IA601-B	41.67	45	Reprovado	41	29	55
MAT05954	ALU0993	IA402-B	38.33	54	Reprovado	55	14	46
MAT02075	ALU0346	IA705-B	20.00	50	Reprovado	6	25	29
MAT01637	ALU0273	IA405-A	36.67	59	Reprovado	13	51	46
MAT01464	ALU0244	IA306-B	23.67	49	Reprovado	8	54	9
MAT00813	ALU0136	IA303-A	40.33	49	Reprovado	53	23	45
MAT05128	ALU0855	IA404-B	39.33	32	Reprovado	12	55	51
MAT02682	ALU0447	IA106-B	29.00	65	Reprovado	24	28	35
MAT00784	ALU0131	IA804-A	29.33	42	Reprovado	45	18	25
MAT00869	ALU0145	IA705-B	20.00	43	Reprovado	25	23	12
MAT04056	ALU0676	IA106-B	46.67	34	Reprovado	46	58	36
MAT03548	ALU0592	IA602-B	36.00	56	Reprovado	16	42	50
MAT05178	ALU0863	IA606-B	24.33	75	Reprovado	41	28	4
MAT04275	ALU0713	IA303-A	36.33	39	Reprovado	3	53	53
MAT02751	ALU0459	IA703-A	36.33	93	Reprovado	40	16	53
MAT05662	ALU0944	IA104-B	31.33	64	Reprovado	46	48	0
MAT01252	ALU0209	IA304-B	14.67	74	Reprovado	23	0	21
MAT00534	ALU0089	IA206-A	24.00	62	Reprovado	13	52	7
MAT01501	ALU0251	IA501-A	37.33	99	Reprovado	50	41	21
MAT03420	ALU0570	IA406-B	19.67	37	Reprovado	8	44	7
MAT03431	ALU0572	IA205-A	37.67	49	Reprovado	54	10	49
MAT04437	ALU0740	IA803-B	32.67	58	Reprovado	14	31	53
MAT00930	ALU0155	IA106-A	44.67	96	Reprovado	33	46	55
MAT04192	ALU0699	IA804-B	40.67	99	Reprovado	37	38	47
MAT02710	ALU0452	IA404-B	32.67	98	Reprovado	5	34	59
MAT02707	ALU0452	IA401-B	41.33	100	Reprovado	37	29	58
MAT03646	ALU0608	IA504-B	32.00	61	Reprovado	23	14	59
MAT01876	ALU0313	IA804-A	19.33	46	Reprovado	10	27	21
MAT00855	ALU0143	IA203-A	38.67	41	Reprovado	24	35	57
MAT04618	ALU0770	IA604-B	28.00	35	Reprovado	47	18	19
MAT03055	ALU0510	IA601-B	26.00	56	Reprovado	52	14	12
MAT01847	ALU0308	IA105-A	17.00	85	Reprovado	42	8	1
MAT05444	ALU0908	IA702-B	38.33	90	Reprovado	44	29	42
MAT04020	ALU0670	IA206-A	31.67	61	Reprovado	2	40	53
MAT05941	ALU0991	IA201-B	24.00	70	Reprovado	9	23	40
MAT03015	ALU0503	IA703-B	32.00	39	Reprovado	31	31	34
MAT01956	ALU0326	IA706-A	11.67	54	Reprovado	15	20	0
MAT05391	ALU0899	IA703-B	27.33	87	Reprovado	21	50	11
MAT01459	ALU0244	IA301-B	38.67	86	Reprovado	10	58	48
MAT00831	ALU0139	IA503-B	28.00	64	Reprovado	33	11	40
MAT04941	ALU0824	IA303-B	31.33	84	Reprovado	32	19	43
MAT01197	ALU0200	IA603-A	14.33	88	Reprovado	2	9	32
MAT04838	ALU0807	IA602-B	15.33	62	Reprovado	30	6	10
MAT05378	ALU0897	IA502-B	34.33	89	Reprovado	38	56	9
MAT02971	ALU0496	IA401-A	21.67	39	Reprovado	30	20	15
MAT01272	ALU0212	IA406-B	43.33	41	Reprovado	56	26	48
MAT03565	ALU0595	IA401-A	25.00	68	Reprovado	9	50	16
MAT03499	ALU0584	IA101-A	30.33	74	Reprovado	50	22	19
MAT03115	ALU0520	IA301-A	28.00	31	Reprovado	29	3	52
MAT01583	ALU0264	IA105-B	17.33	98	Reprovado	0	37	15
MAT02904	ALU0484	IA206-B	25.67	68	Reprovado	55	12	10
MAT00845	ALU0141	IA805-B	34.67	81	Reprovado	22	42	40
MAT04122	ALU0687	IA206-A	23.00	48	Reprovado	0	23	46
MAT01150	ALU0192	IA404-B	41.33	70	Reprovado	52	26	46
MAT00538	ALU0090	IA104-B	24.67	77	Reprovado	49	11	14
MAT05426	ALU0905	IA202-B	42.67	85	Reprovado	40	33	55
MAT00722	ALU0121	IA502-B	41.67	91	Reprovado	33	46	46
MAT01333	ALU0223	IA401-B	21.67	98	Reprovado	4	11	50
MAT03187	ALU0532	IA201-A	45.00	39	Reprovado	53	37	45
MAT03047	ALU0508	IA505-B	18.00	74	Reprovado	9	25	20
MAT02689	ALU0449	IA801-A	41.33	46	Reprovado	21	45	58
MAT02816	ALU0470	IA202-B	27.33	76	Reprovado	53	2	27
MAT02754	ALU0459	IA706-A	35.33	88	Reprovado	52	19	35
MAT02355	ALU0393	IA403-B	41.67	83	Reprovado	30	43	52
MAT00662	ALU0111	IA802-A	31.67	69	Reprovado	6	34	55
MAT00822	ALU0137	IA206-A	40.67	94	Reprovado	10	54	58
MAT03007	ALU0502	IA101-B	37.33	42	Reprovado	55	8	49
MAT04115	ALU0686	IA305-B	33.67	43	Reprovado	17	39	45
MAT00303	ALU0051	IA103-A	25.00	85	Reprovado	27	17	31
MAT04932	ALU0822	IA406-B	35.33	57	Reprovado	29	28	49
MAT00790	ALU0132	IA604-B	27.33	86	Reprovado	8	38	36
MAT02960	ALU0494	IA502-A	12.67	65	Reprovado	7	0	31
MAT02894	ALU0483	IA502-B	34.67	74	Reprovado	13	41	50
MAT03452	ALU0576	IA502-A	13.67	30	Reprovado	5	24	12
MAT05527	ALU0922	IA501-B	27.00	70	Reprovado	5	52	24
MAT04667	ALU0778	IA705-A	26.67	44	Reprovado	41	12	27
MAT02068	ALU0345	IA704-A	32.00	78	Reprovado	32	30	34
MAT04957	ALU0827	IA201-B	44.00	85	Reprovado	46	53	33
MAT01770	ALU0295	IA406-B	18.33	48	Reprovado	12	41	2
MAT02141	ALU0357	IA805-A	19.67	69	Reprovado	24	22	13
MAT02279	ALU0380	IA105-B	28.67	99	Reprovado	57	16	13
MAT01103	ALU0184	IA305-A	44.67	63	Reprovado	56	37	41
MAT04791	ALU0799	IA803-B	39.00	82	Reprovado	35	53	29
MAT03983	ALU0664	IA105-B	44.00	60	Reprovado	38	37	57
MAT01011	ALU0169	IA203-B	22.67	51	Reprovado	30	35	3
MAT02336	ALU0390	IA702-B	32.00	54	Reprovado	3	52	41
MAT02991	ALU0499	IA303-B	35.00	76	Reprovado	20	31	54
MAT04435	ALU0740	IA801-B	16.33	44	Reprovado	26	15	8
MAT00160	ALU0027	IA204-B	25.33	53	Reprovado	27	37	12
MAT01437	ALU0240	IA203-B	29.33	90	Reprovado	10	54	24
MAT00350	ALU0059	IA402-B	21.33	80	Reprovado	42	1	21
MAT01592	ALU0266	IA802-A	37.33	38	Reprovado	44	12	56
MAT05356	ALU0893	IA804-B	25.00	45	Reprovado	2	25	48
MAT02944	ALU0491	IA204-B	11.67	94	Reprovado	9	9	17
MAT00610	ALU0102	IA504-A	19.67	59	Reprovado	27	28	4
MAT02469	ALU0412	IA603-B	17.33	43	Reprovado	5	37	10
MAT03153	ALU0526	IA503-B	38.00	96	Reprovado	49	7	58
MAT02127	ALU0355	IA503-B	42.00	51	Reprovado	52	28	46
MAT00589	ALU0099	IA401-B	26.67	62	Reprovado	40	31	9
MAT04954	ALU0826	IA604-B	9.67	68	Reprovado	5	8	16
MAT04832	ALU0806	IA302-A	29.67	83	Reprovado	33	34	22
MAT05624	ALU0938	IA302-B	32.67	70	Reprovado	44	25	29
MAT05375	ALU0896	IA605-B	47.67	70	Reprovado	55	29	59
MAT00919	ALU0154	IA601-A	10.67	36	Reprovado	11	7	14
MAT00621	ALU0104	IA703-B	38.67	39	Reprovado	49	46	21
MAT05118	ALU0853	IA406-B	40.00	56	Reprovado	19	48	53
MAT04030	ALU0672	IA804-B	30.00	73	Reprovado	34	11	45
MAT04721	ALU0787	IA505-A	24.00	93	Reprovado	27	34	11
MAT02045	ALU0341	IA405-B	28.67	57	Reprovado	44	16	26
MAT03930	ALU0655	IA806-A	27.67	80	Reprovado	14	11	58
MAT01587	ALU0265	IA303-B	38.67	56	Reprovado	38	42	36
MAT03590	ALU0599	IA702-B	36.33	48	Reprovado	51	41	17
MAT01466	ALU0245	IA402-B	12.67	56	Reprovado	14	1	23
MAT00889	ALU0149	IA401-A	36.33	50	Reprovado	19	45	45
MAT00360	ALU0060	IA106-A	26.33	31	Reprovado	4	42	33
MAT00829	ALU0139	IA501-B	25.00	95	Reprovado	9	49	17
MAT02930	ALU0489	IA602-A	38.00	54	Reprovado	31	56	27
MAT02578	ALU0430	IA104-B	29.33	85	Reprovado	15	40	33
MAT02776	ALU0463	IA604-A	31.33	96	Reprovado	53	2	39
MAT00405	ALU0068	IA103-A	25.33	60	Reprovado	28	3	45
MAT05137	ALU0857	IA401-A	23.67	99	Reprovado	19	12	40
MAT01298	ALU0217	IA502-B	34.00	66	Reprovado	28	59	15
MAT02748	ALU0458	IA206-B	27.33	91	Reprovado	40	26	16
MAT04240	ALU0707	IA704-A	42.33	63	Reprovado	31	50	46
MAT04348	ALU0725	IA204-B	27.33	58	Reprovado	5	57	20
MAT00518	ALU0087	IA802-B	13.33	30	Reprovado	17	2	21
MAT01119	ALU0187	IA103-B	20.33	90	Reprovado	17	15	29
MAT02800	ALU0467	IA304-B	25.67	53	Reprovado	35	31	11
MAT00928	ALU0155	IA104-A	24.33	63	Reprovado	7	22	44
MAT01875	ALU0313	IA803-A	37.33	44	Reprovado	4	51	57
MAT04399	ALU0734	IA201-B	36.00	50	Reprovado	44	16	48
MAT00022	ALU0004	IA704-A	38.33	97	Reprovado	14	54	47
MAT01048	ALU0175	IA304-B	42.33	47	Reprovado	32	38	57
MAT01980	ALU0330	IA606-B	26.33	43	Reprovado	30	21	28
MAT02768	ALU0462	IA602-A	14.67	96	Reprovado	17	17	10
MAT04101	ALU0684	IA703-A	43.67	34	Reprovado	44	45	42
MAT00313	ALU0053	IA801-A	50.33	70	Reprovado	52	53	46
MAT03830	ALU0639	IA302-B	19.00	56	Reprovado	5	27	25
MAT03002	ALU0501	IA702-A	39.00	86	Reprovado	31	48	38
MAT02198	ALU0367	IA802-B	35.33	49	Reprovado	54	9	43
MAT03469	ALU0579	IA101-A	29.67	37	Reprovado	55	1	33
MAT02325	ALU0388	IA803-B	28.33	66	Reprovado	1	30	54
MAT04511	ALU0752	IA405-B	19.67	33	Reprovado	6	38	15
MAT03641	ALU0607	IA305-A	24.00	53	Reprovado	9	27	36
MAT01441	ALU0241	IA201-B	28.67	40	Reprovado	25	39	22
MAT04972	ALU0829	IA404-A	25.33	61	Reprovado	37	11	28
MAT04478	ALU0747	IA702-B	31.00	39	Reprovado	51	22	20
MAT03902	ALU0651	IA202-B	39.33	93	Reprovado	54	42	22
MAT04860	ALU0810	IA806-B	12.67	95	Reprovado	13	9	16
MAT00986	ALU0165	IA502-B	29.33	38	Reprovado	39	36	13
MAT01213	ALU0203	IA101-A	15.67	75	Reprovado	4	11	32
MAT01445	ALU0241	IA205-B	27.67	94	Reprovado	20	7	56
MAT02347	ALU0392	IA501-B	36.00	39	Reprovado	37	37	34
MAT03846	ALU0641	IA806-B	25.00	60	Reprovado	58	6	11
MAT01484	ALU0248	IA402-B	34.00	78	Reprovado	27	32	43
MAT02865	ALU0478	IA403-B	23.33	88	Reprovado	11	55	4
MAT05479	ALU0914	IA601-A	16.67	31	Reprovado	12	33	5
MAT03016	ALU0503	IA704-B	34.00	68	Reprovado	56	0	46
MAT04793	ALU0799	IA805-B	38.00	39	Reprovado	24	47	43
MAT01850	ALU0309	IA102-B	25.00	45	Reprovado	46	26	3
MAT00951	ALU0159	IA303-B	20.00	32	Reprovado	14	21	25
MAT01852	ALU0309	IA104-B	33.00	77	Reprovado	39	20	40
MAT04178	ALU0697	IA202-B	21.00	61	Reprovado	15	41	7
MAT03097	ALU0517	IA601-B	37.67	66	Reprovado	43	57	13
MAT04476	ALU0746	IA106-B	40.00	72	Reprovado	29	37	54
MAT05131	ALU0856	IA601-B	31.00	78	Reprovado	35	0	58
MAT03373	ALU0563	IA201-B	25.33	61	Reprovado	43	18	15
MAT03218	ALU0537	IA402-B	18.33	50	Reprovado	8	29	18
MAT03241	ALU0541	IA601-A	15.33	63	Reprovado	1	35	10
MAT03675	ALU0613	IA103-B	22.67	54	Reprovado	27	18	23
MAT01425	ALU0238	IA803-A	28.00	62	Reprovado	41	13	30
MAT03599	ALU0600	IA105-B	28.33	38	Reprovado	32	11	42
MAT01029	ALU0172	IA503-B	42.00	72	Reprovado	59	54	13
MAT02737	ALU0457	IA701-A	38.67	62	Reprovado	57	54	5
MAT02717	ALU0453	IA805-A	26.67	79	Reprovado	41	25	14
MAT05828	ALU0972	IA302-A	40.33	39	Reprovado	55	36	30
MAT04196	ALU0700	IA502-B	38.67	40	Reprovado	27	52	37
MAT05746	ALU0958	IA504-B	33.33	33	Reprovado	5	54	41
MAT01257	ALU0210	IA203-B	29.33	57	Reprovado	11	49	28
MAT05573	ALU0929	IA805-A	34.67	52	Reprovado	16	37	51
MAT05725	ALU0955	IA701-B	37.33	52	Reprovado	47	34	31
MAT03032	ALU0506	IA602-B	10.33	50	Reprovado	0	2	29
MAT04162	ALU0694	IA304-B	12.67	82	Reprovado	1	9	28
MAT02836	ALU0473	IA604-A	37.67	85	Reprovado	49	41	23
MAT02635	ALU0440	IA501-A	25.33	56	Reprovado	18	5	53
MAT00854	ALU0143	IA202-A	42.33	50	Reprovado	49	43	35
MAT03614	ALU0603	IA802-A	45.00	68	Reprovado	37	43	55
MAT01570	ALU0262	IA404-B	26.00	66	Reprovado	50	11	17
MAT04355	ALU0726	IA705-B	47.00	31	Reprovado	44	42	55
MAT02277	ALU0380	IA103-B	21.33	39	Reprovado	37	16	11
MAT02057	ALU0343	IA405-A	12.67	85	Reprovado	31	7	0
MAT02700	ALU0450	IA506-A	20.00	62	Reprovado	29	20	11
MAT05686	ALU0948	IA204-B	38.33	63	Reprovado	31	37	47
MAT00115	ALU0020	IA701-B	24.00	80	Reprovado	4	53	15
MAT02763	ALU0461	IA103-B	21.67	98	Reprovado	26	35	4
MAT03831	ALU0639	IA303-B	52.67	74	Reprovado	45	56	57
MAT01554	ALU0259	IA406-A	11.33	92	Reprovado	8	13	13
MAT05727	ALU0955	IA703-B	43.67	76	Reprovado	45	38	48
MAT01198	ALU0200	IA604-A	45.00	71	Reprovado	30	53	52
MAT02602	ALU0434	IA704-A	26.67	60	Reprovado	25	10	45
MAT03160	ALU0527	IA204-A	11.33	81	Reprovado	20	8	6
MAT03925	ALU0655	IA801-A	48.00	82	Reprovado	57	47	40
MAT04481	ALU0747	IA705-B	28.00	47	Reprovado	30	18	36
MAT05164	ALU0861	IA204-B	36.00	67	Reprovado	22	46	40
MAT05619	ALU0937	IA503-B	30.33	58	Reprovado	50	18	23
MAT02317	ALU0387	IA301-B	51.67	91	Reprovado	55	58	42
MAT04851	ALU0809	IA303-A	34.67	86	Reprovado	46	29	29
MAT02611	ALU0436	IA201-A	16.67	59	Reprovado	11	3	36
MAT03048	ALU0508	IA506-B	22.00	97	Reprovado	2	53	11
MAT01811	ALU0302	IA805-B	35.00	77	Reprovado	33	37	35
MAT05625	ALU0938	IA303-B	22.67	30	Reprovado	34	29	5
MAT00795	ALU0133	IA703-B	32.00	32	Reprovado	35	10	51
MAT00689	ALU0115	IA305-A	19.33	55	Reprovado	1	15	42
MAT05431	ALU0906	IA101-B	19.33	47	Reprovado	33	20	5
MAT04405	ALU0735	IA401-A	23.67	96	Reprovado	6	25	40
MAT05020	ALU0837	IA404-A	32.33	63	Reprovado	16	49	32
MAT04859	ALU0810	IA805-B	30.33	62	Reprovado	39	8	44
MAT03328	ALU0555	IA304-B	29.33	34	Reprovado	10	54	24
MAT03786	ALU0631	IA306-B	27.67	45	Reprovado	33	4	46
MAT00596	ALU0100	IA402-B	51.33	58	Reprovado	51	59	44
MAT03861	ALU0644	IA503-A	21.33	36	Reprovado	1	24	39
MAT00891	ALU0149	IA403-A	31.67	94	Reprovado	33	55	7
MAT02282	ALU0381	IA702-B	28.67	71	Reprovado	19	21	46
MAT05813	ALU0969	IA205-B	23.33	89	Reprovado	23	42	5
MAT04318	ALU0720	IA704-B	30.33	38	Reprovado	12	37	42
MAT04847	ALU0808	IA305-B	32.67	89	Reprovado	59	33	6
MAT00086	ALU0015	IA202-B	21.33	74	Reprovado	49	1	14
MAT01641	ALU0274	IA203-A	10.00	76	Reprovado	5	15	10
MAT05825	ALU0971	IA605-B	27.67	58	Reprovado	46	16	21
MAT03046	ALU0508	IA504-B	38.67	70	Reprovado	18	57	41
MAT00064	ALU0011	IA104-A	20.67	62	Reprovado	16	33	13
MAT05465	ALU0911	IA505-A	54.00	35	Reprovado	57	57	48
MAT02942	ALU0491	IA202-B	31.67	36	Reprovado	38	14	43
MAT03181	ALU0531	IA301-B	36.00	58	Reprovado	39	46	23
MAT01767	ALU0295	IA403-B	38.33	49	Reprovado	51	59	5
MAT05094	ALU0849	IA506-B	27.67	52	Reprovado	19	58	6
MAT02335	ALU0390	IA701-B	38.33	84	Reprovado	11	55	49
MAT01354	ALU0226	IA304-A	22.00	64	Reprovado	19	26	21
MAT04183	ALU0698	IA601-B	29.67	87	Reprovado	4	40	45
MAT03867	ALU0645	IA603-B	24.67	73	Reprovado	17	47	10
MAT05620	ALU0937	IA504-B	33.33	91	Reprovado	17	50	33
MAT02823	ALU0471	IA303-B	26.33	36	Reprovado	58	9	12
MAT00555	ALU0093	IA403-A	39.00	40	Reprovado	44	18	55
MAT02313	ALU0386	IA603-A	42.67	74	Reprovado	40	48	40
MAT03481	ALU0581	IA301-B	17.00	45	Reprovado	36	8	7
MAT05499	ALU0917	IA203-B	17.33	51	Reprovado	11	24	17
MAT04882	ALU0814	IA204-B	30.33	57	Reprovado	42	37	12
MAT05091	ALU0849	IA503-B	22.33	62	Reprovado	3	19	45
MAT03082	ALU0514	IA204-B	24.33	71	Reprovado	26	23	24
MAT01047	ALU0175	IA303-B	45.00	54	Reprovado	54	37	44
MAT01564	ALU0261	IA104-A	34.67	49	Reprovado	38	44	22
MAT00073	ALU0013	IA701-A	26.33	57	Reprovado	30	28	21
MAT05276	ALU0880	IA102-B	21.67	39	Reprovado	37	19	9
MAT00257	ALU0043	IA305-A	33.33	84	Reprovado	56	43	1
MAT02160	ALU0360	IA206-A	37.00	67	Reprovado	10	51	50
MAT01606	ALU0268	IA204-B	25.00	32	Reprovado	7	16	52
MAT03844	ALU0641	IA804-B	13.67	100	Reprovado	10	26	5
MAT02385	ALU0398	IA603-B	38.00	89	Reprovado	52	21	41
MAT00035	ALU0006	IA105-A	23.00	64	Reprovado	23	7	39
MAT02907	ALU0485	IA303-B	29.33	45	Reprovado	41	47	0
MAT00556	ALU0093	IA404-A	28.00	49	Reprovado	9	33	42
MAT01360	ALU0227	IA504-B	45.67	86	Reprovado	54	33	50
MAT02888	ALU0482	IA802-B	26.67	96	Reprovado	2	29	49
MAT03017	ALU0503	IA705-B	43.00	98	Reprovado	21	58	50
MAT03579	ALU0597	IA703-A	36.33	99	Reprovado	38	40	31
MAT01133	ALU0189	IA805-A	40.00	43	Reprovado	57	27	36
MAT02319	ALU0387	IA303-B	32.33	31	Reprovado	38	9	50
MAT00989	ALU0165	IA505-B	32.00	81	Reprovado	47	43	6
MAT03129	ALU0522	IA403-B	12.33	45	Reprovado	11	19	7
MAT03758	ALU0627	IA102-B	26.33	84	Reprovado	41	12	26
MAT05241	ALU0874	IA203-B	37.33	60	Reprovado	54	26	32
MAT00579	ALU0097	IA603-A	37.67	39	Reprovado	26	29	58
MAT01759	ALU0294	IA501-A	46.33	88	Reprovado	44	36	59
MAT02765	ALU0461	IA105-B	21.67	88	Reprovado	16	33	16
MAT05260	ALU0877	IA104-B	28.33	62	Reprovado	49	0	36
MAT02031	ALU0339	IA303-B	51.67	83	Reprovado	58	54	43
MAT04296	ALU0716	IA106-B	21.33	64	Reprovado	30	9	25
MAT05452	ALU0909	IA404-B	26.33	73	Reprovado	12	27	40
MAT03926	ALU0655	IA802-A	32.00	89	Reprovado	28	53	15
MAT00846	ALU0141	IA806-B	27.33	55	Reprovado	19	16	47
MAT02095	ALU0350	IA801-B	41.67	91	Reprovado	34	39	52
MAT00032	ALU0006	IA102-A	29.33	57	Reprovado	22	11	55
MAT03138	ALU0523	IA506-B	26.00	67	Reprovado	11	37	30
MAT04248	ALU0708	IA806-B	32.33	48	Reprovado	32	30	35
MAT05098	ALU0850	IA104-B	34.33	68	Reprovado	56	45	2
MAT02841	ALU0474	IA203-B	35.67	94	Reprovado	41	10	56
MAT03500	ALU0584	IA102-A	21.33	91	Reprovado	30	5	29
MAT05608	ALU0935	IA504-A	14.00	95	Reprovado	20	4	18
MAT03933	ALU0656	IA403-B	33.00	99	Reprovado	49	32	18
MAT01705	ALU0285	IA501-A	28.00	91	Reprovado	18	55	11
MAT02269	ALU0379	IA701-A	14.33	61	Reprovado	19	22	2
MAT05016	ALU0836	IA606-B	44.67	59	Reprovado	49	32	53
MAT05743	ALU0958	IA501-B	19.33	94	Reprovado	37	12	9
MAT00600	ALU0100	IA406-B	34.00	51	Reprovado	52	23	27
MAT03447	ALU0575	IA403-A	44.67	42	Reprovado	26	56	52
MAT02701	ALU0451	IA401-B	42.33	34	Reprovado	43	36	48
MAT03756	ALU0626	IA706-B	21.00	88	Reprovado	42	5	16
MAT01341	ALU0224	IA703-B	50.33	89	Reprovado	44	50	57
MAT00527	ALU0088	IA805-B	26.67	83	Reprovado	56	15	9
MAT04233	ALU0706	IA703-B	31.33	95	Reprovado	57	4	33
MAT03421	ALU0571	IA801-A	27.33	59	Reprovado	22	24	36
MAT04150	ALU0692	IA204-B	15.33	59	Reprovado	4	11	31
MAT05326	ALU0888	IA504-B	20.33	53	Reprovado	17	6	38
MAT01395	ALU0233	IA403-B	29.00	56	Reprovado	35	31	21
MAT04436	ALU0740	IA802-B	27.00	81	Reprovado	25	39	17
MAT05305	ALU0885	IA201-B	23.67	37	Reprovado	37	33	1
MAT05179	ALU0864	IA101-A	41.67	31	Reprovado	19	48	58
MAT01502	ALU0251	IA502-A	39.67	55	Reprovado	40	21	58
MAT00243	ALU0041	IA303-A	26.67	75	Reprovado	17	15	48
MAT01789	ALU0299	IA201-A	11.00	40	Reprovado	4	23	6
MAT05306	ALU0885	IA202-B	30.33	94	Reprovado	28	57	6
MAT03847	ALU0642	IA401-B	40.00	69	Reprovado	24	49	47
MAT03220	ALU0537	IA404-B	9.00	88	Reprovado	11	1	15
MAT05358	ALU0893	IA806-B	20.00	87	Reprovado	0	35	25
MAT05327	ALU0888	IA505-B	46.33	95	Reprovado	59	55	25
MAT02546	ALU0425	IA802-B	29.00	35	Reprovado	10	20	57
MAT01671	ALU0279	IA203-B	12.33	94	Reprovado	3	28	6
MAT01793	ALU0299	IA205-A	36.33	49	Reprovado	27	36	46
MAT04098	ALU0683	IA606-B	47.67	55	Reprovado	57	31	55
MAT02594	ALU0433	IA802-A	42.00	98	Reprovado	35	47	44
MAT01468	ALU0245	IA404-B	28.33	45	Reprovado	20	15	50
MAT05543	ALU0924	IA605-B	20.33	98	Reprovado	9	5	47
MAT01802	ALU0301	IA102-B	34.33	52	Reprovado	18	58	27
MAT02379	ALU0397	IA303-B	23.67	51	Reprovado	3	9	59
MAT01448	ALU0242	IA402-A	28.00	44	Reprovado	12	37	35
MAT05611	ALU0936	IA301-B	14.67	32	Reprovado	17	16	11
MAT05335	ALU0890	IA101-A	44.33	73	Reprovado	44	53	36
MAT05789	ALU0965	IA705-B	48.00	83	Reprovado	58	44	42
MAT02711	ALU0452	IA405-B	44.67	79	Reprovado	46	29	59
MAT02675	ALU0446	IA205-B	24.00	35	Reprovado	21	26	25
MAT04339	ALU0724	IA401-B	31.00	30	Reprovado	38	2	53
MAT00632	ALU0106	IA502-B	37.33	61	Reprovado	42	45	25
MAT01373	ALU0229	IA205-A	17.33	97	Reprovado	18	6	28
MAT01775	ALU0296	IA805-A	31.67	43	Reprovado	33	59	3
MAT05540	ALU0924	IA602-B	29.00	65	Reprovado	40	16	31
MAT03347	ALU0558	IA105-B	46.67	62	Reprovado	59	22	59
MAT05536	ALU0923	IA504-A	29.33	40	Reprovado	53	13	22
MAT00723	ALU0121	IA503-B	28.67	67	Reprovado	32	8	46
MAT05779	ALU0964	IA501-B	26.67	52	Reprovado	52	25	3
MAT00030	ALU0005	IA406-B	37.33	59	Reprovado	30	35	47
MAT02149	ALU0359	IA401-B	37.00	37	Reprovado	47	30	34
MAT03010	ALU0502	IA104-B	8.33	61	Reprovado	3	17	5
MAT01670	ALU0279	IA202-B	29.33	36	Reprovado	42	39	7
MAT01528	ALU0255	IA504-A	9.33	65	Reprovado	17	0	11
MAT05842	ALU0974	IA304-B	44.00	52	Reprovado	38	51	43
MAT01340	ALU0224	IA702-B	32.33	57	Reprovado	58	23	16
MAT01942	ALU0324	IA604-B	22.00	75	Reprovado	13	28	25
MAT00379	ALU0064	IA501-B	24.00	96	Reprovado	50	19	3
MAT00635	ALU0106	IA505-B	30.00	45	Reprovado	51	1	38
MAT02974	ALU0496	IA404-A	50.33	53	Reprovado	53	57	41
MAT01293	ALU0216	IA203-A	19.67	66	Reprovado	11	34	14
MAT02908	ALU0485	IA304-B	26.33	60	Reprovado	29	14	36
MAT04116	ALU0686	IA306-B	28.67	57	Reprovado	21	10	55
MAT03535	ALU0590	IA101-B	27.00	60	Reprovado	16	20	45
MAT02681	ALU0447	IA105-B	32.33	36	Reprovado	40	44	13
MAT02159	ALU0360	IA205-A	14.67	94	Reprovado	0	41	3
MAT01834	ALU0306	IA504-A	28.00	44	Reprovado	22	24	38
MAT03643	ALU0608	IA501-B	27.00	76	Reprovado	11	29	41
MAT05023	ALU0838	IA501-A	35.33	51	Reprovado	17	51	38
MAT02479	ALU0414	IA501-A	23.67	80	Reprovado	18	1	52
MAT05736	ALU0956	IA406-A	22.33	90	Reprovado	59	2	6
MAT00844	ALU0141	IA804-B	17.67	40	Reprovado	0	33	20
MAT03663	ALU0611	IA303-B	23.00	58	Reprovado	8	10	51
MAT00520	ALU0087	IA804-B	41.67	82	Reprovado	43	43	39
MAT01042	ALU0174	IA704-B	45.00	62	Reprovado	40	51	44
MAT03749	ALU0625	IA605-B	42.00	98	Reprovado	55	15	56
MAT03547	ALU0592	IA601-B	26.67	94	Reprovado	11	49	20
MAT04407	ALU0735	IA403-A	36.67	99	Reprovado	42	58	10
MAT05483	ALU0914	IA605-A	29.33	86	Reprovado	18	11	59
MAT03045	ALU0508	IA503-B	25.67	82	Reprovado	44	6	27
MAT04316	ALU0720	IA702-B	31.00	46	Reprovado	51	17	25
MAT02180	ALU0364	IA102-A	13.67	67	Reprovado	36	0	5
MAT03027	ALU0505	IA603-A	23.67	60	Reprovado	10	11	50
MAT05077	ALU0847	IA801-A	28.67	64	Reprovado	55	7	24
MAT01653	ALU0276	IA603-B	21.33	45	Reprovado	50	1	13
MAT02778	ALU0463	IA606-A	31.00	90	Reprovado	49	37	7
MAT04877	ALU0813	IA505-A	14.33	60	Reprovado	12	24	7
MAT02377	ALU0397	IA301-B	46.67	57	Reprovado	59	43	38
MAT03833	ALU0639	IA305-B	29.67	43	Reprovado	20	49	20
MAT01706	ALU0285	IA502-A	23.33	78	Reprovado	0	59	11
MAT03168	ALU0528	IA306-B	21.67	73	Reprovado	11	39	15
MAT01236	ALU0206	IA506-A	30.33	83	Reprovado	45	20	26
MAT05197	ALU0867	IA801-B	33.67	78	Reprovado	53	6	42
MAT05607	ALU0935	IA503-A	43.67	38	Reprovado	57	24	50
MAT04498	ALU0750	IA604-B	34.67	83	Reprovado	36	40	28
MAT04270	ALU0712	IA804-A	24.67	50	Reprovado	10	34	30
MAT02153	ALU0359	IA405-B	50.33	69	Reprovado	46	47	58
MAT02040	ALU0340	IA106-B	18.33	31	Reprovado	6	0	49
MAT03744	ALU0624	IA706-B	17.00	34	Reprovado	32	18	1
MAT05300	ALU0884	IA602-A	36.67	76	Reprovado	34	20	56
MAT01273	ALU0213	IA201-B	33.67	66	Reprovado	48	11	42
MAT03932	ALU0656	IA402-B	36.67	34	Reprovado	33	50	27
MAT01467	ALU0245	IA403-B	29.33	31	Reprovado	36	49	3
MAT02967	ALU0495	IA403-A	32.67	82	Reprovado	9	45	44
MAT01383	ALU0231	IA503-B	19.00	30	Reprovado	22	1	34
MAT00981	ALU0164	IA503-A	50.33	33	Reprovado	59	48	44
MAT05758	ALU0960	IA804-A	37.00	40	Reprovado	13	40	58
MAT00484	ALU0081	IA404-B	34.33	69	Reprovado	35	37	31
MAT00907	ALU0152	IA401-A	26.33	67	Reprovado	12	21	46
MAT01427	ALU0238	IA805-A	27.67	33	Reprovado	12	35	36
MAT02063	ALU0344	IA405-B	19.00	45	Reprovado	24	25	8
MAT01678	ALU0280	IA704-A	29.33	63	Reprovado	12	40	36
MAT05355	ALU0893	IA803-B	42.67	59	Reprovado	45	26	57
MAT04414	ALU0736	IA104-B	34.67	58	Reprovado	44	51	9
MAT05827	ALU0972	IA301-A	18.00	92	Reprovado	0	54	0
MAT05572	ALU0929	IA804-A	32.00	54	Reprovado	50	25	21
MAT01204	ALU0201	IA404-A	38.33	50	Reprovado	39	44	32
MAT01332	ALU0222	IA706-B	20.33	72	Reprovado	20	23	18
MAT01714	ALU0286	IA204-A	31.33	55	Reprovado	21	39	34
MAT05323	ALU0888	IA501-B	32.00	53	Reprovado	47	1	48
MAT02302	ALU0384	IA204-B	18.67	54	Reprovado	23	17	16
MAT05120	ALU0854	IA802-B	9.33	88	Reprovado	1	25	2
MAT04445	ALU0741	IA405-B	14.00	85	Reprovado	12	30	0
MAT04094	ALU0683	IA602-B	42.00	77	Reprovado	28	49	49
MAT01019	ALU0170	IA405-B	24.33	61	Reprovado	48	20	5
MAT00381	ALU0064	IA503-B	40.00	91	Reprovado	46	30	44
MAT02584	ALU0431	IA204-A	31.33	37	Reprovado	17	50	27
MAT03004	ALU0501	IA704-A	26.67	84	Reprovado	23	21	36
MAT03265	ALU0545	IA401-B	21.33	79	Reprovado	20	38	6
MAT00383	ALU0064	IA505-B	35.67	64	Reprovado	39	30	38
MAT05528	ALU0922	IA502-B	52.00	31	Reprovado	52	57	47
MAT03433	ALU0573	IA301-B	31.67	70	Reprovado	10	49	36
MAT01903	ALU0318	IA401-A	41.67	38	Reprovado	58	21	46
MAT05488	ALU0915	IA704-B	44.33	77	Reprovado	34	55	44
MAT00577	ALU0097	IA601-A	50.33	52	Reprovado	49	47	55
MAT02380	ALU0397	IA304-B	25.67	53	Reprovado	27	27	23
MAT03428	ALU0572	IA202-A	50.33	73	Reprovado	48	57	46
MAT05191	ALU0866	IA301-B	29.67	47	Reprovado	0	44	45
MAT02504	ALU0418	IA602-B	28.00	55	Reprovado	29	30	25
MAT04935	ALU0823	IA403-B	25.67	83	Reprovado	15	29	33
MAT00728	ALU0122	IA502-B	32.00	56	Reprovado	32	42	22
MAT00690	ALU0115	IA306-A	30.67	35	Reprovado	55	21	16
MAT02699	ALU0450	IA505-A	34.33	65	Reprovado	44	18	41
MAT02509	ALU0419	IA501-B	34.67	93	Reprovado	5	42	57
MAT04909	ALU0819	IA201-B	26.67	30	Reprovado	22	46	12
MAT03064	ALU0511	IA604-B	23.33	32	Reprovado	9	40	21
MAT01135	ALU0190	IA401-A	41.33	65	Reprovado	46	40	38
MAT02697	ALU0450	IA503-A	20.33	72	Reprovado	42	5	14
MAT05931	ALU0989	IA503-A	25.33	64	Reprovado	34	15	27
MAT03838	ALU0640	IA104-B	31.33	43	Reprovado	26	50	18
MAT02449	ALU0409	IA401-B	41.33	56	Reprovado	23	42	59
MAT05313	ALU0886	IA703-B	33.67	70	Reprovado	15	48	38
MAT00489	ALU0082	IA103-A	41.00	91	Reprovado	58	50	15
MAT03677	ALU0613	IA105-B	45.33	39	Reprovado	52	49	35
MAT01614	ALU0269	IA606-B	24.33	77	Reprovado	59	5	9
MAT05599	ALU0934	IA601-A	38.33	49	Reprovado	46	59	10
MAT02372	ALU0396	IA502-B	14.67	54	Reprovado	18	12	14
MAT05397	ALU0900	IA303-A	47.67	98	Reprovado	58	27	58
MAT00306	ALU0051	IA106-A	34.33	38	Reprovado	8	40	55
MAT00184	ALU0031	IA604-B	30.67	77	Reprovado	53	23	16
MAT03563	ALU0594	IA405-A	40.33	51	Reprovado	41	44	36
MAT01285	ALU0215	IA601-B	18.00	87	Reprovado	13	41	0
MAT05585	ALU0931	IA505-A	31.67	78	Reprovado	38	8	49
MAT02338	ALU0390	IA704-B	44.67	44	Reprovado	54	55	25
MAT02673	ALU0446	IA203-B	10.33	50	Reprovado	3	25	3
MAT02203	ALU0368	IA401-B	45.33	51	Reprovado	47	50	39
MAT03113	ALU0519	IA505-B	27.33	39	Reprovado	13	18	51
MAT03145	ALU0525	IA801-A	36.67	83	Reprovado	47	27	36
MAT00572	ALU0096	IA102-A	29.00	50	Reprovado	17	44	26
MAT03365	ALU0561	IA805-B	19.33	73	Reprovado	5	15	38
MAT04091	ALU0682	IA405-B	35.33	40	Reprovado	33	36	37
MAT05151	ALU0859	IA203-B	35.67	35	Reprovado	49	28	30
MAT04079	ALU0680	IA305-B	23.33	100	Reprovado	8	53	9
MAT05005	ALU0835	IA301-B	24.33	59	Reprovado	16	10	47
MAT04852	ALU0809	IA304-A	26.00	98	Reprovado	28	17	33
MAT01374	ALU0229	IA206-A	47.33	38	Reprovado	56	58	28
MAT03876	ALU0646	IA506-B	47.67	53	Reprovado	46	39	58
MAT05955	ALU0993	IA403-B	38.67	53	Reprovado	41	57	18
MAT04182	ALU0697	IA206-B	22.33	38	Reprovado	52	2	13
MAT04265	ALU0711	IA505-A	29.33	61	Reprovado	46	27	15
MAT02740	ALU0457	IA704-A	43.00	99	Reprovado	48	37	44
MAT01274	ALU0213	IA202-B	26.00	89	Reprovado	2	50	26
MAT03025	ALU0505	IA601-A	31.33	70	Reprovado	35	6	53
MAT01935	ALU0323	IA403-A	38.67	38	Reprovado	57	6	53
MAT02985	ALU0498	IA303-B	24.67	79	Reprovado	29	43	2
MAT00554	ALU0093	IA402-A	42.67	99	Reprovado	17	57	54
MAT00315	ALU0053	IA803-A	22.67	89	Reprovado	11	19	38
MAT05104	ALU0851	IA304-A	12.33	60	Reprovado	21	8	8
MAT02587	ALU0432	IA201-A	28.67	57	Reprovado	33	42	11
MAT00487	ALU0082	IA101-A	16.67	94	Reprovado	16	11	23
MAT04231	ALU0706	IA701-B	13.00	66	Reprovado	0	38	1
MAT03669	ALU0612	IA303-B	47.00	84	Reprovado	57	54	30
MAT03660	ALU0610	IA306-B	32.33	84	Reprovado	46	23	28
MAT05729	ALU0955	IA705-B	36.00	50	Reprovado	39	53	16
MAT04442	ALU0741	IA402-B	23.00	48	Reprovado	25	19	25
MAT02935	ALU0490	IA401-B	34.33	100	Reprovado	36	51	16
MAT02884	ALU0481	IA204-B	14.00	31	Reprovado	28	8	6
MAT01763	ALU0294	IA505-A	22.00	54	Reprovado	5	30	31
MAT01051	ALU0176	IA201-B	34.67	74	Reprovado	42	58	4
MAT05834	ALU0973	IA402-A	22.67	76	Reprovado	10	8	50
MAT00926	ALU0155	IA102-A	11.00	63	Reprovado	3	13	17
MAT00582	ALU0097	IA606-A	45.33	100	Reprovado	38	55	43
MAT04320	ALU0720	IA706-B	32.33	94	Reprovado	46	6	45
MAT04945	ALU0825	IA501-B	18.67	83	Reprovado	19	5	32
MAT05112	ALU0852	IA706-A	31.33	64	Reprovado	49	24	21
MAT03994	ALU0666	IA804-B	16.67	99	Reprovado	34	1	15
MAT00763	ALU0128	IA301-A	23.33	42	Reprovado	23	32	15
MAT02593	ALU0433	IA801-A	25.00	100	Reprovado	15	5	55
MAT02073	ALU0346	IA703-B	29.00	86	Reprovado	35	9	43
MAT04345	ALU0725	IA201-B	43.67	82	Reprovado	51	54	26
MAT01253	ALU0209	IA305-B	24.33	64	Reprovado	4	36	33
MAT05061	ALU0844	IA203-A	13.33	60	Reprovado	13	14	13
MAT02263	ALU0378	IA601-B	30.00	92	Reprovado	47	24	19
MAT02970	ALU0495	IA406-A	35.33	36	Reprovado	56	14	36
MAT01247	ALU0208	IA105-A	27.67	41	Reprovado	31	17	35
MAT02999	ALU0500	IA705-A	23.67	69	Reprovado	41	22	8
MAT01242	ALU0207	IA306-A	43.67	31	Reprovado	43	50	38
MAT01239	ALU0207	IA303-A	19.33	47	Reprovado	12	38	8
MAT02241	ALU0374	IA303-B	46.00	73	Reprovado	39	41	58
MAT02156	ALU0360	IA202-A	28.00	31	Reprovado	57	25	2
MAT02559	ALU0427	IA403-B	42.00	70	Reprovado	48	53	25
MAT05454	ALU0909	IA406-B	14.33	100	Reprovado	32	10	1
MAT05014	ALU0836	IA604-B	27.00	69	Reprovado	32	10	39
MAT05816	ALU0970	IA502-B	30.67	69	Reprovado	18	36	38
MAT02905	ALU0485	IA301-B	20.67	92	Reprovado	53	0	9
MAT00013	ALU0003	IA301-B	21.00	69	Reprovado	40	14	9
MAT01218	ALU0203	IA106-A	38.33	64	Reprovado	36	39	40
MAT00483	ALU0081	IA403-B	42.33	45	Reprovado	45	41	41
MAT04155	ALU0693	IA203-B	17.67	62	Reprovado	17	3	33
MAT04927	ALU0822	IA401-B	29.33	46	Reprovado	40	25	23
MAT04889	ALU0815	IA205-A	19.67	33	Reprovado	5	14	40
MAT00828	ALU0138	IA206-A	44.00	58	Reprovado	27	50	55
MAT05414	ALU0903	IA302-B	37.67	84	Reprovado	55	32	26
MAT01068	ALU0178	IA606-B	5.00	77	Reprovado	5	4	6
MAT04664	ALU0778	IA702-A	28.33	92	Reprovado	47	7	31
MAT01034	ALU0173	IA302-A	38.00	37	Reprovado	37	50	27
MAT02137	ALU0357	IA801-A	26.67	36	Reprovado	48	10	22
MAT03031	ALU0506	IA601-B	31.67	77	Reprovado	24	41	30
MAT02034	ALU0339	IA306-B	31.00	83	Reprovado	49	29	15
MAT03272	ALU0546	IA202-B	47.33	37	Reprovado	55	43	44
MAT00933	ALU0156	IA603-A	29.67	77	Reprovado	10	34	45
MAT04007	ALU0668	IA305-B	36.33	66	Reprovado	32	19	58
MAT03993	ALU0666	IA803-B	17.33	94	Reprovado	13	20	19
MAT05096	ALU0850	IA102-B	27.67	83	Reprovado	13	33	37
MAT04842	ALU0807	IA606-B	38.00	50	Reprovado	14	59	41
MAT05344	ALU0891	IA304-B	21.33	89	Reprovado	19	44	1
MAT02470	ALU0412	IA604-B	33.67	60	Reprovado	38	31	32
MAT05618	ALU0937	IA502-B	12.67	53	Reprovado	5	4	29
MAT03449	ALU0575	IA405-A	7.67	71	Reprovado	0	17	6
MAT05460	ALU0910	IA306-A	29.00	90	Reprovado	13	48	26
MAT00464	ALU0078	IA102-A	19.67	100	Reprovado	2	2	55
MAT03330	ALU0555	IA306-B	27.00	31	Reprovado	0	43	38
MAT05240	ALU0874	IA202-B	44.00	43	Reprovado	39	47	46
MAT05090	ALU0849	IA502-B	31.33	44	Reprovado	27	27	40
MAT01742	ALU0291	IA102-B	32.67	77	Reprovado	33	51	14
MAT05175	ALU0863	IA603-B	37.67	51	Reprovado	30	25	58
MAT05698	ALU0950	IA204-A	26.00	50	Reprovado	18	17	43
MAT02680	ALU0447	IA104-B	26.67	37	Reprovado	3	44	33
MAT01651	ALU0276	IA601-B	31.67	84	Reprovado	21	32	42
MAT04038	ALU0673	IA406-B	27.33	51	Reprovado	14	36	32
MAT00781	ALU0131	IA801-A	36.67	61	Reprovado	20	58	32
MAT02463	ALU0411	IA403-B	47.00	63	Reprovado	52	40	49
MAT02915	ALU0486	IA405-A	19.67	88	Reprovado	2	10	47
MAT02744	ALU0458	IA202-B	16.33	52	Reprovado	6	40	3
MAT01320	ALU0220	IA606-B	15.67	85	Reprovado	19	23	5
MAT00806	ALU0135	IA302-B	15.00	81	Reprovado	24	10	11
MAT00958	ALU0160	IA504-A	21.67	45	Reprovado	16	27	22
MAT00567	ALU0095	IA303-A	34.33	45	Reprovado	37	33	33
MAT03415	ALU0570	IA401-B	34.33	78	Reprovado	38	39	26
MAT05239	ALU0874	IA201-B	28.67	90	Reprovado	51	17	18
MAT05121	ALU0854	IA803-B	32.33	50	Reprovado	32	18	47
MAT03665	ALU0611	IA305-B	39.33	51	Reprovado	55	22	41
MAT03748	ALU0625	IA604-B	7.67	65	Reprovado	20	2	1
MAT05122	ALU0854	IA804-B	35.00	79	Reprovado	49	31	25
MAT00575	ALU0096	IA105-A	48.33	71	Reprovado	52	49	44
MAT04801	ALU0801	IA401-B	27.67	62	Reprovado	40	35	8
MAT04138	ALU0690	IA304-B	35.00	84	Reprovado	50	0	55
MAT04421	ALU0737	IA705-B	25.33	41	Reprovado	54	15	7
MAT05922	ALU0987	IA506-A	5.00	74	Reprovado	5	5	5
MAT05552	ALU0926	IA702-B	37.33	75	Reprovado	48	57	7
MAT03402	ALU0567	IA106-B	33.67	83	Reprovado	6	50	45
MAT04287	ALU0715	IA303-B	14.67	33	Reprovado	22	2	20
MAT02906	ALU0485	IA302-B	47.00	61	Reprovado	54	40	47
MAT05052	ALU0842	IA506-B	29.33	44	Reprovado	45	37	6
MAT02467	ALU0412	IA601-B	36.67	37	Reprovado	40	36	34
MAT01386	ALU0231	IA506-B	33.33	69	Reprovado	24	30	46
MAT01947	ALU0325	IA603-B	53.67	81	Reprovado	59	54	48
MAT05124	ALU0854	IA806-B	25.00	42	Reprovado	11	34	30
MAT03122	ALU0521	IA502-B	23.33	84	Reprovado	6	54	10
MAT05280	ALU0880	IA106-B	30.33	66	Reprovado	52	29	10
MAT04058	ALU0677	IA102-B	13.67	99	Reprovado	0	5	36
MAT00998	ALU0167	IA702-B	19.67	44	Reprovado	3	33	23
MAT05551	ALU0926	IA701-B	19.33	58	Reprovado	25	25	8
MAT02466	ALU0411	IA406-B	25.67	54	Reprovado	29	23	25
MAT05442	ALU0907	IA206-B	37.00	97	Reprovado	44	56	11
MAT04131	ALU0689	IA603-A	18.33	54	Reprovado	0	47	8
MAT00365	ALU0061	IA805-B	9.00	90	Reprovado	4	15	8
MAT02963	ALU0494	IA505-A	15.33	48	Reprovado	41	4	1
MAT05780	ALU0964	IA502-B	24.67	69	Reprovado	9	44	21
MAT03172	ALU0529	IA204-B	27.33	51	Reprovado	11	23	48
MAT02147	ALU0358	IA705-A	37.00	84	Reprovado	44	27	40
MAT02505	ALU0418	IA603-B	24.33	78	Reprovado	38	14	21
MAT04865	ALU0811	IA405-B	24.67	62	Reprovado	29	27	18
MAT00111	ALU0019	IA103-B	33.00	53	Reprovado	28	20	51
MAT01750	ALU0292	IA704-A	38.67	67	Reprovado	55	48	13
MAT01078	ALU0180	IA504-B	25.33	62	Reprovado	19	22	35
MAT02125	ALU0355	IA501-B	6.67	37	Reprovado	7	11	2
MAT00703	ALU0118	IA801-B	42.67	78	Reprovado	18	58	52
MAT04837	ALU0807	IA601-B	17.00	77	Reprovado	33	16	2
MAT01776	ALU0296	IA806-A	45.33	63	Reprovado	51	40	45
MAT04132	ALU0689	IA604-A	14.67	91	Reprovado	6	13	25
MAT01465	ALU0245	IA401-B	25.67	88	Reprovado	36	2	39
MAT01454	ALU0243	IA302-A	42.33	100	Reprovado	44	28	55
MAT03718	ALU0620	IA404-B	8.00	71	Reprovado	5	16	3
MAT01568	ALU0262	IA402-B	32.67	59	Reprovado	1	54	43
MAT05451	ALU0909	IA403-B	14.67	45	Reprovado	3	31	10
MAT04794	ALU0799	IA806-B	33.00	40	Reprovado	28	26	45
MAT03464	ALU0578	IA202-A	32.00	56	Reprovado	56	32	8
MAT02474	ALU0413	IA202-B	49.33	39	Reprovado	52	41	55
MAT01558	ALU0260	IA804-B	51.33	39	Reprovado	54	56	44
MAT03929	ALU0655	IA805-A	20.33	43	Reprovado	17	19	25
MAT01356	ALU0226	IA306-A	44.00	37	Reprovado	32	48	52
MAT02897	ALU0483	IA505-B	41.00	59	Reprovado	44	47	32
MAT01390	ALU0232	IA404-B	7.67	44	Reprovado	7	3	13
MAT04303	ALU0718	IA701-A	27.00	96	Reprovado	22	29	30
MAT03705	ALU0618	IA203-B	24.00	73	Reprovado	29	38	5
MAT05372	ALU0896	IA602-B	17.33	95	Reprovado	48	0	4
MAT03414	ALU0569	IA106-B	30.67	66	Reprovado	48	29	15
MAT03315	ALU0553	IA803-A	27.33	53	Reprovado	24	20	38
MAT05459	ALU0910	IA305-A	25.67	81	Reprovado	15	24	38
MAT05581	ALU0931	IA501-A	16.67	75	Reprovado	21	16	13
MAT05635	ALU0940	IA301-B	31.00	46	Reprovado	10	41	42
MAT05371	ALU0896	IA601-B	26.00	54	Reprovado	43	30	5
MAT03544	ALU0591	IA604-B	31.67	61	Reprovado	36	22	37
MAT05117	ALU0853	IA405-B	1.33	71	Reprovado	1	1	2
MAT03628	ALU0605	IA304-A	27.67	88	Reprovado	11	27	45
MAT01675	ALU0280	IA701-A	28.00	72	Reprovado	44	4	36
MAT05056	ALU0843	IA704-B	26.33	40	Reprovado	20	58	1
MAT05895	ALU0983	IA603-B	32.67	58	Reprovado	50	44	4
MAT03418	ALU0570	IA404-B	48.00	38	Reprovado	34	58	52
MAT02545	ALU0425	IA801-B	30.00	94	Reprovado	29	39	22
MAT00991	ALU0166	IA101-B	27.33	63	Reprovado	26	20	36
MAT04428	ALU0738	IA806-B	18.00	78	Reprovado	30	10	14
MAT05902	ALU0984	IA504-B	35.67	33	Reprovado	9	55	43
MAT05428	ALU0905	IA204-B	18.00	62	Reprovado	37	0	17
MAT02646	ALU0441	IA606-B	27.33	58	Reprovado	59	8	15
MAT03440	ALU0574	IA502-A	36.33	100	Reprovado	34	58	17
MAT03671	ALU0612	IA305-B	18.67	45	Reprovado	7	48	1
MAT00642	ALU0107	IA306-B	41.00	100	Reprovado	58	18	47
MAT03470	ALU0579	IA102-A	31.00	71	Reprovado	21	13	59
MAT05297	ALU0883	IA705-B	28.00	76	Reprovado	27	13	44
MAT00961	ALU0161	IA201-B	18.00	79	Reprovado	15	15	24
MAT05495	ALU0916	IA405-B	24.33	73	Reprovado	24	41	8
MAT02771	ALU0462	IA605-A	37.33	51	Reprovado	52	36	24
MAT04051	ALU0676	IA101-B	6.00	60	Reprovado	6	7	5
MAT03596	ALU0600	IA102-B	15.67	36	Reprovado	12	12	23
MAT02139	ALU0357	IA803-A	23.00	75	Reprovado	19	42	8
MAT05377	ALU0897	IA501-B	23.67	41	Reprovado	13	52	6
MAT05636	ALU0940	IA302-B	40.67	96	Reprovado	14	51	57
MAT00152	ALU0026	IA402-A	32.67	66	Reprovado	57	39	2
MAT01868	ALU0312	IA802-A	32.33	79	Reprovado	37	39	21
MAT05025	ALU0838	IA503-A	40.67	98	Reprovado	48	22	52
MAT03142	ALU0524	IA204-B	18.33	54	Reprovado	9	33	13
MAT01297	ALU0217	IA501-B	31.33	91	Reprovado	41	18	35
MAT03041	ALU0507	IA305-B	23.00	40	Reprovado	17	23	29
MAT01688	ALU0282	IA802-B	19.67	75	Reprovado	10	31	18
MAT02183	ALU0364	IA105-A	26.67	69	Reprovado	24	55	1
MAT01555	ALU0260	IA801-B	19.00	46	Reprovado	3	29	25
MAT04759	ALU0794	IA701-B	34.67	55	Reprovado	11	44	49
MAT02111	ALU0352	IA205-A	11.00	50	Reprovado	12	13	8
MAT03364	ALU0561	IA804-B	17.33	96	Reprovado	16	2	34
MAT04145	ALU0691	IA505-B	30.00	53	Reprovado	3	57	30
MAT02281	ALU0381	IA701-B	17.33	70	Reprovado	8	37	7
MAT05846	ALU0975	IA402-B	22.00	57	Reprovado	28	38	0
MAT00802	ALU0134	IA504-A	28.33	95	Reprovado	26	57	2
MAT00377	ALU0063	IA805-B	22.67	93	Reprovado	29	14	25
MAT00336	ALU0056	IA106-B	39.00	53	Reprovado	8	56	53
MAT03052	ALU0509	IA804-B	22.33	38	Reprovado	44	11	12
MAT01513	ALU0253	IA601-B	41.33	86	Reprovado	38	38	48
MAT02115	ALU0353	IA303-B	22.00	46	Reprovado	29	8	29
MAT04904	ALU0818	IA702-A	30.33	48	Reprovado	21	49	21
MAT00683	ALU0114	IA805-B	25.67	47	Reprovado	23	30	24
MAT04159	ALU0694	IA301-B	11.67	56	Reprovado	16	13	6
MAT03162	ALU0527	IA206-A	37.67	45	Reprovado	56	11	46
MAT01381	ALU0231	IA501-B	30.67	77	Reprovado	47	1	44
MAT02389	ALU0399	IA801-B	17.33	54	Reprovado	15	1	36
MAT04723	ALU0788	IA101-A	32.00	39	Reprovado	50	1	45
MAT00710	ALU0119	IA402-B	22.67	34	Reprovado	46	12	10
MAT01419	ALU0237	IA303-B	17.33	81	Reprovado	27	22	3
MAT03051	ALU0509	IA803-B	26.33	80	Reprovado	30	39	10
MAT03637	ALU0607	IA301-A	11.67	98	Reprovado	5	4	26
MAT00351	ALU0059	IA403-B	17.33	46	Reprovado	9	6	37
MAT01677	ALU0280	IA703-A	19.00	92	Reprovado	36	6	15
MAT01405	ALU0235	IA601-A	7.00	51	Reprovado	18	0	3
MAT01518	ALU0253	IA606-B	36.33	94	Reprovado	34	26	49
MAT02585	ALU0431	IA205-A	29.67	48	Reprovado	54	21	14
MAT00832	ALU0139	IA504-B	23.33	77	Reprovado	19	19	32
MAT03155	ALU0526	IA505-B	44.00	64	Reprovado	52	36	44
MAT01146	ALU0191	IA606-A	47.00	40	Reprovado	54	51	36
MAT02610	ALU0435	IA606-B	43.33	85	Reprovado	36	36	58
MAT05250	ALU0875	IA706-B	28.67	34	Reprovado	2	42	42
MAT05161	ALU0861	IA201-B	33.00	73	Reprovado	36	50	13
MAT03717	ALU0620	IA403-B	25.33	50	Reprovado	6	38	32
MAT01730	ALU0289	IA402-B	41.00	98	Reprovado	25	56	42
MAT00363	ALU0061	IA803-B	25.00	72	Reprovado	1	39	35
MAT02091	ALU0349	IA803-B	20.00	80	Reprovado	18	12	30
MAT05949	ALU0992	IA303-A	27.33	95	Reprovado	14	44	24
MAT05215	ALU0870	IA801-B	31.00	75	Reprovado	29	15	49
MAT03394	ALU0566	IA604-B	30.67	45	Reprovado	11	26	55
MAT02324	ALU0388	IA802-B	14.33	66	Reprovado	4	23	16
MAT02891	ALU0482	IA805-B	34.33	63	Reprovado	8	44	51
MAT00571	ALU0096	IA101-A	43.33	98	Reprovado	50	43	37
MAT05352	ALU0892	IA406-B	35.33	88	Reprovado	22	41	43
MAT01900	ALU0317	IA804-A	31.67	30	Reprovado	33	59	3
MAT00276	ALU0046	IA506-B	21.00	44	Reprovado	26	10	27
MAT01420	ALU0237	IA304-B	24.33	65	Reprovado	12	20	41
MAT01890	ALU0315	IA206-A	38.33	57	Reprovado	42	32	41
MAT01024	ALU0171	IA104-A	39.33	62	Reprovado	13	51	54
MAT05906	ALU0985	IA802-B	40.00	82	Reprovado	51	32	37
MAT02122	ALU0354	IA704-B	46.00	46	Reprovado	59	38	41
MAT01756	ALU0293	IA804-B	32.67	38	Reprovado	0	47	51
MAT02658	ALU0443	IA106-A	19.33	87	Reprovado	25	6	27
MAT03636	ALU0606	IA306-B	20.33	60	Reprovado	9	41	11
MAT02782	ALU0464	IA304-B	35.67	71	Reprovado	10	53	44
MAT02607	ALU0435	IA603-B	52.67	61	Reprovado	53	53	52
MAT00234	ALU0039	IA206-B	32.67	39	Reprovado	59	34	5
MAT03603	ALU0601	IA603-B	18.00	62	Reprovado	20	22	12
MAT03543	ALU0591	IA603-B	33.67	93	Reprovado	17	34	50
MAT02415	ALU0403	IA103-B	35.67	30	Reprovado	55	27	25
MAT04242	ALU0707	IA706-A	16.33	82	Reprovado	34	15	0
MAT05432	ALU0906	IA102-B	19.00	84	Reprovado	10	37	10
MAT04092	ALU0682	IA406-B	29.00	90	Reprovado	0	46	41
MAT03503	ALU0584	IA105-A	33.00	80	Reprovado	8	54	37
MAT00719	ALU0120	IA805-B	26.33	85	Reprovado	25	32	22
MAT05003	ALU0834	IA105-B	38.00	92	Reprovado	43	43	28
MAT03623	ALU0604	IA405-A	3.33	68	Reprovado	2	8	0
MAT04305	ALU0718	IA703-A	23.67	77	Reprovado	12	45	14
MAT03124	ALU0521	IA504-B	42.67	100	Reprovado	30	46	52
MAT03865	ALU0645	IA601-B	27.67	55	Reprovado	22	20	41
MAT05752	ALU0959	IA604-B	31.00	52	Reprovado	52	38	3
MAT05150	ALU0859	IA202-B	24.33	50	Reprovado	59	5	9
MAT03237	ALU0540	IA403-A	42.00	81	Reprovado	50	41	35
MAT04829	ALU0805	IA805-A	42.33	54	Reprovado	21	54	52
MAT04400	ALU0734	IA202-B	16.33	37	Reprovado	2	10	37
MAT01532	ALU0256	IA502-A	37.33	52	Reprovado	53	31	28
MAT01633	ALU0273	IA401-A	33.33	67	Reprovado	21	21	58
MAT00109	ALU0019	IA101-B	46.67	46	Reprovado	28	57	55
MAT02762	ALU0461	IA102-B	15.33	86	Reprovado	11	6	29
MAT00514	ALU0086	IA804-A	28.67	59	Reprovado	11	57	18
MAT03802	ALU0634	IA304-B	22.67	42	Reprovado	7	30	31
MAT03266	ALU0545	IA402-B	40.67	47	Reprovado	16	49	57
MAT01681	ALU0281	IA101-B	30.33	99	Reprovado	40	37	14
MAT00477	ALU0080	IA203-A	38.00	99	Reprovado	57	2	55
MAT03571	ALU0596	IA101-B	21.67	85	Reprovado	3	58	4
MAT04979	ALU0830	IA205-B	36.67	90	Reprovado	22	59	29
MAT00645	ALU0108	IA403-A	49.67	83	Reprovado	57	37	55
MAT02871	ALU0479	IA403-B	30.33	73	Reprovado	39	4	48
MAT05797	ALU0967	IA401-B	44.33	69	Reprovado	28	48	57
MAT01716	ALU0286	IA206-A	37.00	56	Reprovado	49	11	51
MAT02987	ALU0498	IA305-B	48.00	97	Reprovado	47	38	59
MAT04268	ALU0712	IA802-A	23.33	67	Reprovado	6	52	12
MAT01082	ALU0181	IA702-B	28.67	98	Reprovado	11	46	29
MAT05186	ALU0865	IA402-B	33.00	60	Reprovado	46	49	4
MAT03384	ALU0564	IA206-B	25.00	33	Reprovado	49	23	3
MAT00732	ALU0122	IA506-B	28.67	57	Reprovado	11	34	41
MAT05555	ALU0926	IA705-B	30.00	36	Reprovado	21	21	48
MAT04617	ALU0770	IA603-B	21.00	83	Reprovado	24	9	30
MAT02582	ALU0431	IA202-A	25.00	32	Reprovado	8	22	45
MAT05130	ALU0855	IA406-B	24.33	68	Reprovado	17	5	51
MAT01156	ALU0193	IA504-A	29.33	74	Reprovado	34	36	18
MAT05873	ALU0979	IA605-B	30.00	36	Reprovado	31	1	58
MAT04942	ALU0824	IA304-B	10.67	90	Reprovado	1	10	21
MAT04133	ALU0689	IA605-A	28.00	97	Reprovado	4	45	35
MAT04908	ALU0818	IA706-A	26.33	77	Reprovado	47	31	1
MAT00324	ALU0054	IA406-A	21.33	100	Reprovado	40	1	23
MAT05640	ALU0940	IA306-B	35.00	56	Reprovado	48	12	45
MAT03069	ALU0512	IA203-A	23.00	58	Reprovado	6	59	4
MAT05862	ALU0977	IA106-B	14.33	93	Reprovado	12	7	24
MAT05657	ALU0943	IA505-A	37.67	31	Reprovado	55	21	37
MAT00560	ALU0094	IA602-A	13.33	65	Reprovado	8	2	30
MAT05654	ALU0943	IA502-A	29.33	59	Reprovado	55	15	18
MAT02481	ALU0414	IA503-A	30.33	45	Reprovado	27	28	36
MAT01669	ALU0279	IA201-B	34.00	33	Reprovado	55	40	7
MAT00517	ALU0087	IA801-B	27.00	69	Reprovado	12	51	18
MAT03089	ALU0515	IA205-B	25.67	43	Reprovado	40	14	23
MAT02966	ALU0495	IA402-A	28.33	32	Reprovado	53	28	4
MAT04858	ALU0810	IA804-B	30.33	46	Reprovado	46	35	10
MAT00370	ALU0062	IA204-A	10.00	75	Reprovado	16	9	5
MAT03382	ALU0564	IA204-B	25.33	56	Reprovado	11	7	58
MAT03605	ALU0601	IA605-B	25.33	60	Reprovado	31	14	31
MAT05724	ALU0954	IA506-B	25.67	59	Reprovado	22	50	5
MAT02006	ALU0335	IA502-B	10.33	32	Reprovado	14	2	15
MAT03803	ALU0634	IA305-B	38.00	58	Reprovado	21	53	40
MAT00312	ALU0052	IA706-A	23.00	89	Reprovado	20	49	0
MAT02860	ALU0477	IA304-A	39.00	41	Reprovado	51	16	50
MAT00292	ALU0049	IA504-B	29.33	77	Reprovado	40	23	25
MAT01498	ALU0250	IA304-B	29.33	34	Reprovado	13	54	21
MAT03336	ALU0556	IA606-B	18.00	93	Reprovado	34	4	16
MAT02023	ALU0338	IA101-B	47.67	32	Reprovado	50	45	48
MAT00899	ALU0150	IA605-B	46.33	86	Reprovado	29	58	52
MAT02493	ALU0416	IA803-B	14.67	86	Reprovado	1	4	39
MAT01739	ALU0290	IA405-B	9.67	44	Reprovado	4	22	3
MAT02759	ALU0460	IA505-B	37.67	85	Reprovado	28	51	34
MAT01771	ALU0296	IA801-A	35.00	38	Reprovado	28	49	28
MAT00697	ALU0117	IA501-A	37.33	73	Reprovado	51	32	29
MAT03696	ALU0616	IA306-B	10.33	59	Reprovado	4	15	12
MAT04997	ALU0833	IA605-B	24.67	86	Reprovado	55	1	18
MAT02775	ALU0463	IA603-A	29.67	91	Reprovado	52	5	32
MAT02990	ALU0499	IA302-B	25.33	65	Reprovado	45	14	17
MAT05788	ALU0965	IA704-B	23.33	46	Reprovado	35	24	11
MAT05464	ALU0911	IA504-A	20.67	66	Reprovado	10	19	33
MAT01266	ALU0211	IA206-B	24.67	89	Reprovado	3	26	45
MAT04926	ALU0821	IA806-A	19.00	56	Reprovado	17	21	19
MAT01884	ALU0314	IA106-B	33.33	77	Reprovado	5	52	43
MAT05841	ALU0974	IA303-B	29.67	47	Reprovado	41	2	46
MAT04792	ALU0799	IA804-B	23.33	100	Reprovado	38	1	31
MAT00288	ALU0048	IA806-A	31.33	78	Reprovado	17	21	56
MAT04019	ALU0670	IA205-A	39.33	67	Reprovado	21	48	49
MAT01988	ALU0332	IA702-B	37.00	65	Reprovado	33	51	27
MAT04006	ALU0668	IA304-B	27.00	33	Reprovado	38	2	41
MAT01158	ALU0193	IA506-A	34.33	43	Reprovado	40	14	49
MAT01315	ALU0220	IA601-B	40.67	71	Reprovado	49	53	20
MAT03783	ALU0631	IA303-B	31.00	40	Reprovado	31	19	43
MAT01001	ALU0167	IA705-B	30.67	57	Reprovado	32	42	18
MAT00773	ALU0129	IA605-B	27.00	52	Reprovado	26	12	43
MAT01091	ALU0182	IA805-A	20.33	60	Reprovado	29	14	18
MAT00942	ALU0157	IA206-A	19.33	46	Reprovado	20	2	36
MAT03580	ALU0597	IA704-A	32.67	45	Reprovado	32	24	42
MAT01243	ALU0208	IA101-A	22.00	71	Reprovado	42	10	14
MAT00692	ALU0116	IA702-A	24.67	47	Reprovado	42	12	20
MAT01148	ALU0192	IA402-B	31.33	90	Reprovado	24	40	30
MAT01923	ALU0321	IA203-B	37.33	49	Reprovado	58	35	19
MAT02657	ALU0443	IA105-A	23.00	53	Reprovado	53	12	4
MAT01225	ALU0205	IA601-A	37.67	90	Reprovado	42	26	45
MAT05246	ALU0875	IA702-B	26.00	53	Reprovado	57	2	19
MAT05487	ALU0915	IA703-B	8.33	63	Reprovado	19	0	6
MAT01234	ALU0206	IA504-A	14.67	81	Reprovado	11	29	4
MAT00535	ALU0090	IA101-B	37.67	72	Reprovado	48	53	12
MAT04472	ALU0746	IA102-B	28.00	43	Reprovado	50	3	31
MAT03652	ALU0609	IA304-A	41.00	88	Reprovado	57	37	29
MAT05486	ALU0915	IA702-B	27.33	67	Reprovado	18	38	26
MAT05818	ALU0970	IA504-B	24.00	82	Reprovado	1	34	37
MAT00587	ALU0098	IA205-A	31.00	97	Reprovado	36	10	47
MAT01604	ALU0268	IA202-B	12.67	54	Reprovado	23	12	3
MAT00870	ALU0145	IA706-B	25.00	55	Reprovado	4	21	50
MAT02822	ALU0471	IA302-B	23.00	40	Reprovado	18	8	43
MAT02554	ALU0426	IA504-B	17.67	30	Reprovado	25	20	8
MAT03151	ALU0526	IA501-B	23.33	63	Reprovado	38	15	17
MAT04798	ALU0800	IA604-B	32.00	77	Reprovado	4	44	48
MAT02311	ALU0386	IA601-A	38.00	52	Reprovado	29	38	47
MAT00714	ALU0119	IA406-B	38.00	79	Reprovado	41	59	14
MAT03326	ALU0555	IA302-B	24.33	61	Reprovado	21	47	5
MAT01859	ALU0310	IA505-B	35.33	30	Reprovado	19	28	59
MAT03308	ALU0552	IA402-B	57.33	93	Reprovado	58	59	55
MAT05213	ALU0869	IA805-B	34.00	65	Reprovado	47	51	4
MAT02565	ALU0428	IA203-A	26.67	95	Reprovado	19	5	56
MAT03668	ALU0612	IA302-B	49.33	65	Reprovado	56	40	52
MAT04204	ALU0701	IA704-B	12.33	41	Reprovado	3	1	33
MAT00308	ALU0052	IA702-A	26.33	53	Reprovado	15	49	15
MAT01000	ALU0167	IA704-B	43.33	36	Reprovado	40	53	37
MAT01917	ALU0320	IA703-B	53.00	32	Reprovado	57	58	44
MAT02824	ALU0471	IA304-B	25.00	79	Reprovado	19	29	27
MAT01099	ALU0184	IA301-A	19.33	61	Reprovado	9	5	44
MAT02625	ALU0438	IA103-B	46.00	34	Reprovado	50	44	44
MAT02210	ALU0369	IA302-B	33.00	35	Reprovado	15	38	46
MAT00990	ALU0165	IA506-B	32.67	35	Reprovado	8	57	33
MAT04027	ALU0672	IA801-B	33.33	55	Reprovado	1	54	45
MAT01519	ALU0254	IA601-A	29.00	76	Reprovado	25	17	45
MAT00513	ALU0086	IA803-A	43.67	66	Reprovado	52	27	52
MAT04582	ALU0764	IA404-A	11.33	72	Reprovado	17	6	11
MAT05972	ALU0996	IA102-A	24.00	83	Reprovado	10	32	30
MAT02883	ALU0481	IA203-B	20.33	33	Reprovado	25	30	6
MAT04055	ALU0676	IA105-B	20.00	34	Reprovado	9	11	40
MAT05072	ALU0846	IA202-A	22.33	33	Reprovado	12	23	32
MAT01115	ALU0186	IA205-B	36.67	97	Reprovado	0	52	58
MAT05248	ALU0875	IA704-B	24.67	43	Reprovado	40	9	25
MAT03042	ALU0507	IA306-B	31.67	78	Reprovado	28	22	45
MAT01192	ALU0199	IA304-A	17.33	94	Reprovado	7	17	28
MAT00334	ALU0056	IA104-B	18.67	40	Reprovado	43	13	0
MAT00521	ALU0087	IA805-B	28.00	44	Reprovado	11	41	32
MAT05462	ALU0911	IA502-A	32.33	99	Reprovado	45	29	23
MAT04506	ALU0751	IA606-B	18.67	70	Reprovado	27	2	27
MAT00663	ALU0111	IA803-A	20.33	98	Reprovado	1	36	24
MAT00938	ALU0157	IA202-A	20.00	33	Reprovado	21	29	10
MAT03642	ALU0607	IA306-A	18.33	40	Reprovado	2	7	46
MAT04928	ALU0822	IA402-B	31.33	84	Reprovado	58	9	27
MAT00445	ALU0075	IA501-B	14.33	54	Reprovado	4	11	28
MAT01878	ALU0313	IA806-A	20.33	66	Reprovado	22	28	11
MAT02772	ALU0462	IA606-A	49.67	99	Reprovado	52	41	56
MAT00348	ALU0058	IA106-B	19.33	40	Reprovado	32	6	20
MAT03506	ALU0585	IA702-A	34.67	56	Reprovado	58	30	16
MAT00355	ALU0060	IA101-A	24.67	65	Reprovado	25	11	38
MAT00810	ALU0135	IA306-B	26.33	82	Reprovado	18	35	26
MAT03716	ALU0620	IA402-B	26.00	92	Reprovado	29	26	23
MAT01244	ALU0208	IA102-A	43.67	72	Reprovado	51	55	25
MAT05695	ALU0950	IA201-A	43.00	61	Reprovado	40	33	56
MAT02637	ALU0440	IA503-A	29.00	76	Reprovado	53	17	17
MAT01881	ALU0314	IA103-B	23.67	52	Reprovado	3	24	44
MAT03128	ALU0522	IA402-B	36.00	97	Reprovado	49	44	15
MAT03823	ALU0638	IA401-B	21.67	47	Reprovado	10	34	21
MAT01124	ALU0188	IA802-B	25.33	98	Reprovado	42	34	0
MAT04863	ALU0811	IA403-B	29.00	72	Reprovado	6	31	50
MAT03774	ALU0629	IA406-A	19.00	55	Reprovado	25	12	20
MAT04841	ALU0807	IA605-B	42.67	31	Reprovado	46	51	31
MAT02483	ALU0414	IA505-A	31.00	51	Reprovado	52	3	38
MAT02787	ALU0465	IA503-A	7.67	78	Reprovado	2	15	6
MAT00158	ALU0027	IA202-B	25.00	54	Reprovado	10	22	43
MAT02169	ALU0362	IA403-B	31.00	96	Reprovado	29	43	21
MAT02779	ALU0464	IA301-B	31.67	69	Reprovado	7	43	45
MAT03296	ALU0550	IA502-A	21.33	32	Reprovado	22	42	0
MAT01686	ALU0281	IA106-B	21.33	70	Reprovado	43	5	16
MAT01745	ALU0291	IA105-B	18.33	68	Reprovado	12	8	35
MAT05563	ALU0928	IA801-B	13.67	71	Reprovado	2	30	9
MAT04141	ALU0691	IA501-B	21.00	91	Reprovado	10	30	23
MAT03417	ALU0570	IA403-B	19.00	34	Reprovado	8	13	36
MAT03125	ALU0521	IA505-B	25.33	34	Reprovado	6	56	14
MAT04126	ALU0688	IA304-B	23.33	77	Reprovado	31	15	24
MAT01523	ALU0254	IA605-A	30.00	65	Reprovado	41	23	26
MAT03119	ALU0520	IA305-A	22.67	77	Reprovado	3	46	19
MAT01071	ALU0179	IA103-B	32.33	98	Reprovado	3	56	38
MAT00816	ALU0136	IA306-A	29.00	80	Reprovado	49	23	15
MAT01058	ALU0177	IA702-B	18.33	66	Reprovado	34	7	14
MAT00169	ALU0029	IA801-A	16.67	42	Reprovado	33	14	3
MAT03000	ALU0500	IA706-A	30.00	88	Reprovado	2	40	48
MAT02113	ALU0353	IA301-B	25.67	83	Reprovado	31	28	18
MAT04335	ALU0723	IA203-A	31.67	59	Reprovado	50	35	10
MAT04475	ALU0746	IA105-B	11.00	93	Reprovado	4	0	29
MAT05413	ALU0903	IA301-B	15.00	76	Reprovado	2	8	35
MAT04546	ALU0758	IA704-A	11.67	64	Reprovado	17	9	9
MAT01575	ALU0263	IA803-B	28.00	58	Reprovado	21	37	26
MAT02858	ALU0477	IA302-A	42.33	76	Reprovado	57	21	49
MAT00593	ALU0099	IA405-B	23.67	68	Reprovado	17	45	9
MAT01325	ALU0221	IA805-B	21.33	76	Reprovado	4	2	58
MAT01797	ALU0300	IA703-B	41.00	94	Reprovado	35	37	51
MAT01321	ALU0221	IA801-B	23.33	90	Reprovado	20	37	13
MAT05255	ALU0876	IA805-B	38.00	42	Reprovado	26	35	53
MAT05840	ALU0974	IA302-B	27.00	39	Reprovado	31	32	18
MAT00493	ALU0083	IA101-B	40.33	63	Reprovado	33	33	55
MAT01848	ALU0308	IA106-A	31.33	58	Reprovado	29	27	38
MAT02104	ALU0351	IA504-B	30.00	30	Reprovado	38	17	35
MAT01391	ALU0232	IA405-B	39.33	59	Reprovado	35	55	28
MAT05050	ALU0842	IA504-B	10.33	57	Reprovado	19	4	8
MAT03345	ALU0558	IA103-B	30.33	34	Reprovado	46	0	45
MAT05915	ALU0986	IA605-B	22.67	91	Reprovado	4	24	40
MAT01987	ALU0332	IA701-B	34.67	42	Reprovado	31	31	42
MAT03005	ALU0501	IA705-A	23.67	49	Reprovado	13	21	37
MAT00999	ALU0167	IA703-B	50.00	61	Reprovado	47	55	48
MAT02382	ALU0397	IA306-B	37.33	75	Reprovado	27	50	35
MAT00819	ALU0137	IA203-A	9.00	49	Reprovado	17	1	9
MAT03282	ALU0547	IA606-A	9.33	33	Reprovado	12	9	7
MAT03730	ALU0622	IA104-B	18.67	79	Reprovado	6	19	31
MAT04982	ALU0831	IA502-B	34.00	51	Reprovado	31	20	51
MAT02087	ALU0348	IA705-A	26.33	30	Reprovado	7	51	21
MAT04772	ALU0796	IA702-A	19.00	51	Reprovado	10	47	0
MAT03672	ALU0612	IA306-B	29.00	65	Reprovado	18	24	45
MAT00352	ALU0059	IA404-B	24.33	63	Reprovado	31	38	4
MAT05800	ALU0967	IA404-B	50.33	72	Reprovado	57	54	40
MAT05329	ALU0889	IA501-B	37.33	32	Reprovado	31	55	26
MAT05564	ALU0928	IA802-B	9.67	78	Reprovado	12	17	0
MAT01031	ALU0172	IA505-B	9.33	36	Reprovado	5	6	17
MAT04821	ALU0804	IA503-B	28.00	69	Reprovado	29	50	5
MAT02544	ALU0424	IA606-A	24.33	46	Reprovado	29	33	11
MAT05546	ALU0925	IA202-B	36.33	94	Reprovado	26	34	49
MAT00117	ALU0020	IA703-B	31.00	60	Reprovado	43	35	15
MAT04839	ALU0807	IA603-B	43.33	87	Reprovado	38	43	49
MAT00366	ALU0061	IA806-B	25.33	31	Reprovado	0	51	25
MAT04663	ALU0778	IA701-A	14.33	45	Reprovado	5	34	4
MAT00470	ALU0079	IA402-B	23.33	35	Reprovado	24	27	19
MAT03690	ALU0615	IA306-B	16.33	64	Reprovado	5	26	18
MAT01473	ALU0246	IA803-A	40.00	47	Reprovado	30	44	46
MAT04310	ALU0719	IA802-A	54.33	51	Reprovado	53	55	55
MAT03747	ALU0625	IA603-B	18.00	98	Reprovado	4	19	31
MAT01824	ALU0304	IA806-B	34.33	37	Reprovado	36	48	19
MAT03329	ALU0555	IA305-B	40.67	31	Reprovado	5	59	58
MAT02863	ALU0478	IA401-B	52.00	36	Reprovado	39	59	58
MAT00776	ALU0130	IA702-A	15.00	45	Reprovado	11	14	20
MAT04862	ALU0811	IA402-B	25.33	71	Reprovado	57	7	12
MAT03150	ALU0525	IA806-A	34.00	35	Reprovado	56	35	11
MAT03601	ALU0601	IA601-B	25.33	46	Reprovado	21	2	53
MAT03134	ALU0523	IA502-B	23.00	45	Reprovado	26	39	4
MAT00262	ALU0044	IA304-A	19.00	96	Reprovado	23	33	1
MAT03200	ALU0534	IA602-B	31.67	32	Reprovado	38	20	37
MAT03183	ALU0531	IA303-B	38.33	96	Reprovado	13	43	59
MAT02950	ALU0492	IA704-B	13.00	69	Reprovado	14	12	13
MAT02262	ALU0377	IA106-A	29.00	60	Reprovado	51	17	19
MAT02354	ALU0393	IA402-B	38.00	32	Reprovado	59	42	13
MAT03435	ALU0573	IA303-B	27.67	68	Reprovado	35	36	12
MAT04439	ALU0740	IA805-B	15.33	41	Reprovado	14	7	25
MAT02424	ALU0404	IA306-B	39.33	30	Reprovado	59	35	24
MAT00271	ALU0046	IA501-B	26.00	52	Reprovado	10	11	57
MAT05691	ALU0949	IA303-A	31.33	70	Reprovado	7	39	48
MAT00224	ALU0038	IA702-B	34.33	58	Reprovado	15	35	53
MAT03868	ALU0645	IA604-B	20.00	94	Reprovado	0	55	5
MAT02575	ALU0430	IA101-B	31.67	99	Reprovado	33	30	32
MAT01577	ALU0263	IA805-B	45.00	48	Reprovado	26	51	58
MAT01460	ALU0244	IA302-B	14.33	50	Reprovado	7	25	11
MAT01238	ALU0207	IA302-A	22.00	77	Reprovado	15	38	13
MAT03629	ALU0605	IA305-A	13.00	92	Reprovado	6	28	5
MAT03164	ALU0528	IA302-B	42.67	45	Reprovado	50	40	38
MAT01764	ALU0294	IA506-A	28.33	96	Reprovado	22	34	29
MAT02434	ALU0406	IA404-B	22.33	88	Reprovado	43	9	15
MAT01062	ALU0177	IA706-B	17.67	43	Reprovado	9	16	28
MAT04510	ALU0752	IA404-B	32.33	30	Reprovado	31	32	34
MAT00389	ALU0065	IA705-A	7.33	89	Reprovado	7	0	15
MAT03524	ALU0588	IA402-A	25.67	54	Reprovado	25	6	46
MAT03984	ALU0664	IA106-B	25.00	89	Reprovado	35	32	8
MAT04879	ALU0814	IA201-B	36.00	94	Reprovado	31	58	19
MAT01744	ALU0291	IA104-B	27.33	64	Reprovado	14	22	46
MAT05373	ALU0896	IA603-B	28.00	63	Reprovado	41	14	29
MAT04527	ALU0755	IA603-B	23.33	82	Reprovado	14	10	46
MAT03980	ALU0664	IA102-B	53.33	85	Reprovado	58	43	59
MAT02254	ALU0376	IA804-B	26.67	95	Reprovado	53	23	4
MAT04046	ALU0675	IA302-A	25.67	39	Reprovado	18	53	6
MAT03539	ALU0590	IA105-B	31.67	87	Reprovado	5	39	51
MAT01758	ALU0293	IA806-B	16.33	58	Reprovado	17	7	25
MAT02817	ALU0470	IA203-B	28.67	52	Reprovado	4	47	35
MAT02204	ALU0368	IA402-B	25.33	34	Reprovado	3	19	54
MAT02094	ALU0349	IA806-B	30.33	40	Reprovado	44	20	27
MAT01676	ALU0280	IA702-A	14.67	100	Reprovado	42	1	1
MAT01785	ALU0298	IA803-B	25.33	82	Reprovado	40	28	8
MAT05694	ALU0949	IA306-A	19.33	89	Reprovado	21	10	27
MAT01972	ALU0329	IA104-B	33.00	54	Reprovado	44	17	38
MAT01946	ALU0325	IA602-B	31.33	98	Reprovado	6	48	40
MAT02743	ALU0458	IA201-B	41.33	58	Reprovado	47	22	55
MAT01044	ALU0174	IA706-B	34.33	80	Reprovado	31	48	24
MAT04745	ALU0791	IA105-A	25.67	81	Reprovado	35	35	7
MAT01475	ALU0246	IA805-A	36.00	93	Reprovado	39	28	41
MAT04096	ALU0683	IA604-B	23.33	95	Reprovado	49	5	16
MAT05720	ALU0954	IA502-B	29.67	31	Reprovado	42	10	37
MAT01880	ALU0314	IA102-B	30.67	99	Reprovado	55	2	35
MAT02902	ALU0484	IA204-B	43.67	53	Reprovado	41	56	34
MAT04650	ALU0775	IA806-B	44.00	82	Reprovado	58	46	28
MAT02124	ALU0354	IA706-B	33.00	58	Reprovado	45	37	17
MAT05776	ALU0963	IA304-B	12.67	94	Reprovado	14	4	20
MAT00309	ALU0052	IA703-A	27.00	70	Reprovado	10	44	27
MAT02092	ALU0349	IA804-B	48.00	57	Reprovado	27	59	58
MAT05411	ALU0902	IA405-B	29.00	40	Reprovado	0	37	50
MAT04443	ALU0741	IA403-B	32.00	98	Reprovado	35	9	52
MAT03710	ALU0619	IA202-B	39.00	36	Reprovado	48	56	13
MAT00591	ALU0099	IA403-B	2.33	98	Reprovado	3	1	3
MAT01345	ALU0225	IA301-A	19.67	69	Reprovado	31	25	3
MAT05591	ALU0932	IA305-B	43.67	63	Reprovado	59	20	52
MAT00344	ALU0058	IA102-B	21.33	39	Reprovado	1	41	22
MAT02178	ALU0363	IA806-B	47.00	94	Reprovado	58	27	56
MAT01515	ALU0253	IA603-B	50.00	60	Reprovado	49	52	49
MAT05738	ALU0957	IA502-B	36.67	51	Reprovado	53	27	30
MAT05478	ALU0913	IA206-B	18.33	51	Reprovado	1	32	22
MAT01871	ALU0312	IA805-A	18.33	46	Reprovado	33	9	13
MAT03021	ALU0504	IA503-B	28.00	49	Reprovado	38	21	25
MAT00994	ALU0166	IA104-B	23.67	96	Reprovado	33	37	1
MAT04948	ALU0825	IA504-B	35.67	84	Reprovado	26	54	27
MAT02589	ALU0432	IA203-A	22.00	64	Reprovado	10	44	12
MAT03256	ALU0543	IA204-A	38.33	55	Reprovado	28	43	44
MAT03001	ALU0501	IA701-A	28.00	58	Reprovado	25	39	20
MAT00529	ALU0089	IA201-A	41.33	56	Reprovado	31	50	43
MAT00857	ALU0143	IA205-A	29.67	89	Reprovado	19	57	13
MAT05438	ALU0907	IA202-B	31.67	58	Reprovado	13	35	47
MAT02253	ALU0376	IA803-B	25.00	31	Reprovado	41	32	2
MAT01012	ALU0169	IA204-B	49.00	44	Reprovado	40	54	53
MAT03545	ALU0591	IA605-B	30.67	38	Reprovado	35	5	52
MAT03498	ALU0583	IA106-A	17.33	62	Reprovado	27	11	14
MAT05341	ALU0891	IA301-B	22.67	38	Reprovado	58	3	7
MAT03485	ALU0581	IA305-B	45.33	36	Reprovado	54	38	44
MAT00968	ALU0162	IA402-B	28.00	97	Reprovado	45	5	34
MAT00428	ALU0072	IA402-B	21.67	43	Reprovado	7	13	45
MAT05196	ALU0866	IA306-B	34.33	72	Reprovado	49	42	12
MAT04899	ALU0817	IA703-A	40.33	61	Reprovado	20	43	58
MAT03594	ALU0599	IA706-B	52.33	50	Reprovado	53	55	49
MAT02510	ALU0419	IA502-B	28.67	31	Reprovado	36	32	18
MAT00349	ALU0059	IA401-B	13.00	44	Reprovado	11	21	7
MAT00742	ALU0124	IA804-B	49.67	93	Reprovado	53	41	55
MAT03766	ALU0628	IA404-B	30.33	99	Reprovado	35	10	46
MAT01613	ALU0269	IA605-B	46.33	92	Reprovado	35	58	46
MAT04946	ALU0825	IA502-B	38.00	64	Reprovado	55	35	24
MAT02208	ALU0368	IA406-B	35.33	42	Reprovado	47	46	13
MAT00437	ALU0073	IA605-B	38.00	56	Reprovado	38	44	32
MAT01810	ALU0302	IA804-B	21.33	92	Reprovado	38	18	8
MAT02729	ALU0455	IA805-B	21.67	76	Reprovado	2	57	6
MAT01786	ALU0298	IA804-B	30.00	63	Reprovado	28	39	23
MAT04374	ALU0729	IA606-A	41.67	46	Reprovado	55	57	13
MAT03737	ALU0623	IA605-A	29.67	61	Reprovado	29	27	33
MAT04761	ALU0794	IA703-B	27.67	33	Reprovado	35	38	10
MAT03600	ALU0600	IA106-B	28.67	90	Reprovado	17	59	10
MAT01674	ALU0279	IA206-B	26.00	76	Reprovado	7	51	20
MAT00154	ALU0026	IA404-A	42.67	45	Reprovado	44	54	30
MAT04747	ALU0792	IA601-B	20.67	94	Reprovado	8	3	51
MAT02171	ALU0362	IA405-B	29.00	49	Reprovado	29	58	0
MAT02993	ALU0499	IA305-B	44.67	92	Reprovado	41	51	42
MAT00598	ALU0100	IA404-B	34.67	57	Reprovado	32	49	23
MAT00833	ALU0139	IA505-B	11.00	38	Reprovado	0	25	8
MAT03109	ALU0519	IA501-B	54.33	57	Reprovado	54	57	52
MAT05960	ALU0994	IA802-A	21.67	89	Reprovado	32	27	6
MAT01718	ALU0287	IA502-A	34.67	90	Reprovado	45	9	50
MAT05518	ALU0920	IA804-A	32.33	46	Reprovado	41	1	55
MAT05083	ALU0848	IA101-A	21.33	88	Reprovado	15	14	35
MAT03121	ALU0521	IA501-B	24.00	92	Reprovado	51	10	11
MAT04008	ALU0668	IA306-B	33.67	50	Reprovado	57	10	34
MAT05682	ALU0947	IA806-A	28.33	68	Reprovado	13	39	33
MAT00848	ALU0142	IA602-B	41.00	74	Reprovado	35	30	58
MAT04918	ALU0820	IA204-A	35.33	88	Reprovado	19	41	46
MAT05350	ALU0892	IA404-B	18.33	100	Reprovado	15	25	15
MAT03715	ALU0620	IA401-B	35.33	38	Reprovado	47	47	12
MAT02801	ALU0467	IA305-B	23.33	71	Reprovado	37	11	22
MAT03177	ALU0530	IA803-B	29.00	47	Reprovado	23	46	18
MAT05489	ALU0915	IA705-B	42.33	89	Reprovado	48	46	33
MAT02586	ALU0431	IA206-A	28.33	86	Reprovado	26	50	9
MAT04392	ALU0732	IA306-A	23.67	34	Reprovado	27	19	25
MAT01300	ALU0217	IA504-B	33.00	41	Reprovado	46	14	39
MAT05598	ALU0933	IA706-B	25.00	67	Reprovado	30	12	33
MAT02679	ALU0447	IA103-B	46.33	80	Reprovado	37	56	46
MAT04063	ALU0678	IA201-B	36.00	78	Reprovado	43	22	43
MAT03311	ALU0552	IA405-B	37.33	35	Reprovado	42	42	28
MAT02542	ALU0424	IA604-A	44.00	79	Reprovado	54	57	21
MAT02846	ALU0475	IA802-B	40.67	65	Reprovado	29	46	47
MAT05422	ALU0904	IA504-B	13.33	49	Reprovado	18	7	15
MAT00082	ALU0014	IA304-B	38.67	49	Reprovado	7	59	50
MAT00001	ALU0001	IA201-B	26.00	55	Reprovado	11	45	22
MAT02185	ALU0365	IA201-A	40.67	93	Reprovado	55	28	39
MAT03410	ALU0569	IA102-B	40.67	57	Reprovado	51	25	46
MAT01275	ALU0213	IA203-B	10.67	99	Reprovado	2	7	23
MAT02257	ALU0377	IA101-A	25.33	43	Reprovado	14	33	29
MAT05063	ALU0844	IA205-A	36.67	96	Reprovado	55	48	7
MAT04403	ALU0734	IA205-B	38.67	84	Reprovado	52	19	45
MAT02370	ALU0395	IA306-B	24.00	49	Reprovado	36	31	5
MAT02955	ALU0493	IA303-A	13.33	32	Reprovado	11	24	5
MAT02290	ALU0382	IA204-A	33.33	79	Reprovado	38	44	18
MAT00293	ALU0049	IA505-B	39.33	97	Reprovado	54	20	44
MAT03502	ALU0584	IA104-A	14.00	42	Reprovado	22	15	5
MAT05670	ALU0945	IA306-B	50.00	39	Reprovado	46	55	49
MAT03405	ALU0568	IA703-A	24.33	93	Reprovado	18	39	16
MAT05135	ALU0856	IA605-B	18.67	30	Reprovado	38	6	12
MAT04189	ALU0699	IA801-B	38.33	33	Reprovado	27	46	42
MAT00314	ALU0053	IA802-A	49.00	86	Reprovado	55	37	55
MAT05852	ALU0976	IA302-A	29.00	43	Reprovado	42	10	35
MAT00302	ALU0051	IA102-A	46.33	66	Reprovado	33	52	54
MAT03366	ALU0561	IA806-B	36.00	56	Reprovado	28	49	31
MAT01379	ALU0230	IA805-B	26.67	55	Reprovado	12	51	17
MAT03086	ALU0515	IA202-B	22.67	83	Reprovado	12	35	21
MAT01728	ALU0288	IA206-B	18.00	87	Reprovado	32	4	18
MAT02624	ALU0438	IA102-B	30.00	80	Reprovado	20	49	21
MAT00394	ALU0066	IA304-B	36.67	90	Reprovado	31	35	44
MAT01430	ALU0239	IA102-B	21.33	51	Reprovado	12	29	23
MAT04693	ALU0783	IA501-A	45.33	99	Reprovado	54	56	26
MAT02605	ALU0435	IA601-B	23.00	42	Reprovado	11	58	0
MAT00971	ALU0162	IA405-B	49.33	90	Reprovado	49	44	55
MAT05501	ALU0917	IA205-B	22.33	40	Reprovado	17	15	35
MAT02524	ALU0421	IA304-B	36.00	59	Reprovado	39	28	41
MAT04998	ALU0833	IA606-B	35.67	46	Reprovado	47	7	53
MAT01311	ALU0219	IA103-A	40.67	30	Reprovado	48	48	26
MAT05975	ALU0996	IA105-A	16.00	32	Reprovado	10	9	29
MAT02136	ALU0356	IA806-B	26.00	40	Reprovado	32	21	25
MAT04833	ALU0806	IA303-A	22.33	60	Reprovado	5	50	12
MAT00751	ALU0126	IA701-B	28.67	49	Reprovado	7	43	36
MAT05597	ALU0933	IA705-B	42.00	80	Reprovado	49	57	20
MAT04112	ALU0686	IA302-B	32.67	79	Reprovado	38	52	8
MAT04867	ALU0812	IA401-A	37.33	77	Reprovado	9	57	46
MAT01032	ALU0172	IA506-B	34.67	86	Reprovado	43	43	18
MAT03443	ALU0574	IA505-A	16.33	32	Reprovado	1	17	31
MAT05030	ALU0839	IA202-B	11.00	35	Reprovado	5	26	2
MAT00198	ALU0033	IA206-B	26.00	99	Reprovado	43	5	30
MAT04455	ALU0743	IA503-A	27.33	72	Reprovado	59	1	22
MAT01015	ALU0170	IA401-B	24.67	96	Reprovado	18	33	23
MAT00326	ALU0055	IA202-A	29.00	36	Reprovado	45	23	19
MAT05570	ALU0929	IA802-A	8.33	81	Reprovado	12	4	9
MAT04036	ALU0673	IA404-B	15.00	34	Reprovado	19	0	26
MAT00959	ALU0160	IA505-A	19.33	97	Reprovado	8	27	23
MAT04315	ALU0720	IA701-B	39.33	64	Reprovado	49	53	16
MAT04295	ALU0716	IA105-B	40.00	59	Reprovado	50	33	37
MAT01128	ALU0188	IA806-B	42.00	40	Reprovado	56	54	16
MAT02190	ALU0365	IA206-A	36.00	68	Reprovado	28	44	36
MAT05562	ALU0927	IA606-B	23.33	53	Reprovado	47	16	7
MAT00207	ALU0035	IA503-B	33.67	77	Reprovado	31	35	35
MAT05458	ALU0910	IA304-A	26.00	69	Reprovado	34	0	44
MAT03322	ALU0554	IA304-B	30.00	79	Reprovado	11	34	45
MAT01184	ALU0198	IA402-A	48.67	94	Reprovado	55	33	58
MAT02010	ALU0335	IA506-B	22.67	97	Reprovado	20	32	16
MAT00149	ALU0025	IA705-B	43.00	38	Reprovado	43	45	41
MAT05045	ALU0841	IA605-B	36.33	54	Reprovado	53	41	15
MAT05766	ALU0961	IA306-B	31.67	30	Reprovado	39	7	49
MAT01366	ALU0228	IA404-B	47.00	99	Reprovado	44	58	39
MAT01214	ALU0203	IA102-A	37.33	76	Reprovado	33	54	25
MAT02381	ALU0397	IA305-B	14.67	75	Reprovado	23	0	21
MAT05537	ALU0923	IA505-A	37.67	98	Reprovado	57	0	56
MAT02866	ALU0478	IA404-B	27.00	46	Reprovado	37	3	41
MAT01927	ALU0322	IA501-B	27.33	92	Reprovado	43	20	19
MAT01450	ALU0242	IA404-A	34.67	92	Reprovado	59	3	42
MAT01414	ALU0236	IA604-B	17.67	31	Reprovado	4	26	23
MAT01061	ALU0177	IA705-B	30.00	43	Reprovado	53	16	21
MAT02207	ALU0368	IA405-B	21.67	65	Reprovado	19	5	41
MAT02003	ALU0334	IA205-A	17.67	36	Reprovado	45	5	3
MAT04962	ALU0827	IA206-B	12.00	95	Reprovado	13	15	8
MAT05940	ALU0990	IA106-A	28.33	84	Reprovado	33	48	4
MAT02315	ALU0386	IA605-A	36.67	59	Reprovado	48	49	13
MAT01127	ALU0188	IA805-B	7.67	64	Reprovado	5	4	14
MAT03353	ALU0559	IA405-A	13.33	80	Reprovado	40	0	0
MAT05820	ALU0970	IA506-B	33.67	58	Reprovado	43	28	30
MAT05259	ALU0877	IA103-B	7.67	34	Reprovado	0	21	2
MAT01924	ALU0321	IA204-B	41.33	30	Reprovado	43	47	34
MAT02998	ALU0500	IA704-A	90.00	82	Aprovado	80	100	90
MAT05933	ALU0989	IA505-A	88.00	100	Aprovado	81	99	84
MAT03894	ALU0649	IA306-B	78.00	90	Aprovado	91	76	67
MAT00962	ALU0161	IA202-B	89.33	88	Aprovado	89	87	92
MAT04417	ALU0737	IA701-B	83.33	93	Aprovado	91	96	63
MAT03788	ALU0632	IA802-B	44.00	73	Reprovado	51	46	35
MAT05747	ALU0958	IA505-B	37.33	58	Reprovado	48	32	32
MAT05097	ALU0850	IA103-B	32.67	52	Reprovado	6	54	38
MAT02022	ALU0337	IA306-B	40.33	34	Reprovado	43	55	23
MAT04424	ALU0738	IA802-B	26.33	65	Reprovado	27	39	13
MAT05934	ALU0989	IA506-A	30.67	75	Reprovado	25	50	17
MAT01435	ALU0240	IA201-B	44.00	48	Reprovado	46	46	40
MAT01798	ALU0300	IA704-B	29.33	64	Reprovado	1	49	38
MAT02445	ALU0408	IA603-B	36.33	68	Reprovado	6	54	49
MAT03724	ALU0621	IA404-B	37.67	54	Reprovado	50	47	16
MAT00136	ALU0023	IA604-A	13.00	93	Reprovado	12	1	26
MAT02298	ALU0383	IA506-A	25.33	87	Reprovado	20	16	40
MAT00410	ALU0069	IA102-A	22.33	42	Reprovado	24	8	35
MAT02564	ALU0428	IA202-A	16.67	62	Reprovado	2	36	12
MAT01470	ALU0245	IA406-B	39.00	56	Reprovado	46	18	53
MAT03495	ALU0583	IA103-A	26.00	33	Reprovado	15	30	33
MAT00766	ALU0128	IA304-A	21.00	86	Reprovado	33	1	29
MAT05730	ALU0955	IA706-B	35.33	96	Reprovado	32	27	47
MAT03624	ALU0604	IA406-A	43.33	65	Reprovado	42	59	29
MAT01790	ALU0299	IA202-A	19.67	95	Reprovado	12	2	45
MAT03755	ALU0626	IA705-B	22.00	47	Reprovado	19	19	28
MAT00652	ALU0109	IA204-A	39.67	49	Reprovado	51	32	36
MAT02862	ALU0477	IA306-A	26.33	78	Reprovado	16	11	52
MAT00332	ALU0056	IA102-B	23.33	61	Reprovado	36	27	7
MAT00748	ALU0125	IA304-B	33.67	88	Reprovado	42	11	48
MAT02327	ALU0388	IA805-B	19.67	93	Reprovado	2	21	36
MAT05726	ALU0955	IA702-B	46.33	33	Reprovado	56	25	58
MAT05284	ALU0881	IA104-A	50.00	98	Reprovado	59	59	32
MAT01905	ALU0318	IA403-A	39.67	63	Reprovado	49	28	42
MAT03655	ALU0610	IA301-B	46.67	65	Reprovado	49	53	38
MAT01423	ALU0238	IA801-A	27.67	83	Reprovado	24	49	10
MAT02473	ALU0413	IA201-B	9.67	37	Reprovado	16	1	12
MAT04775	ALU0796	IA705-A	31.33	57	Reprovado	43	32	19
MAT00479	ALU0080	IA205-A	49.67	63	Reprovado	42	53	54
MAT05822	ALU0971	IA602-B	46.67	79	Reprovado	40	46	54
MAT01196	ALU0200	IA602-A	21.33	70	Reprovado	51	5	8
MAT00441	ALU0074	IA303-B	13.00	87	Reprovado	2	7	30
MAT01514	ALU0253	IA602-B	25.00	46	Reprovado	45	25	5
MAT01308	ALU0218	IA406-B	46.67	33	Reprovado	47	41	52
MAT04293	ALU0716	IA103-B	23.00	74	Reprovado	9	21	39
MAT02170	ALU0362	IA404-B	32.00	35	Reprovado	32	35	29
MAT03099	ALU0517	IA603-B	37.33	47	Reprovado	28	40	44
MAT02973	ALU0496	IA403-A	32.00	56	Reprovado	24	25	47
MAT01439	ALU0240	IA205-B	26.67	73	Reprovado	41	12	27
MAT03511	ALU0586	IA201-B	29.67	35	Reprovado	42	23	24
MAT01687	ALU0282	IA801-B	28.67	42	Reprovado	33	13	40
MAT05942	ALU0991	IA202-B	35.33	35	Reprovado	20	28	58
MAT05417	ALU0903	IA305-B	30.33	56	Reprovado	0	45	46
MAT01713	ALU0286	IA203-A	25.00	48	Reprovado	22	22	31
MAT04790	ALU0799	IA802-B	28.00	68	Reprovado	43	1	40
MAT01689	ALU0282	IA803-B	30.33	58	Reprovado	16	51	24
MAT02326	ALU0388	IA804-B	34.67	39	Reprovado	43	6	55
MAT00559	ALU0094	IA601-A	37.00	39	Reprovado	37	49	25
MAT01200	ALU0200	IA606-A	29.33	80	Reprovado	10	43	35
MAT05548	ALU0925	IA204-B	21.00	70	Reprovado	8	8	47
MAT05333	ALU0889	IA505-B	71.33	95	Aprovado	76	74	64
MAT05384	ALU0898	IA102-B	91.33	91	Aprovado	80	100	94
MAT00563	ALU0094	IA605-A	90.33	84	Aprovado	98	84	89
MAT05366	ALU0895	IA502-A	85.67	75	Aprovado	98	83	76
MAT01889	ALU0315	IA205-A	77.67	97	Aprovado	80	71	82
MAT04237	ALU0707	IA701-A	91.67	100	Aprovado	98	85	92
MAT00758	ALU0127	IA802-B	70.33	99	Aprovado	66	62	83
MAT00161	ALU0027	IA205-B	78.00	76	Aprovado	70	97	67
MAT00681	ALU0114	IA803-B	72.33	80	Aprovado	63	73	81
MAT01241	ALU0207	IA305-A	80.67	97	Aprovado	80	97	65
MAT05062	ALU0844	IA204-A	93.00	79	Aprovado	81	98	100
MAT02120	ALU0354	IA702-B	80.67	93	Aprovado	67	75	100
\N	\N	IA1794-A	17.33	37	Reprovado	27	1	24
\N	\N	IA1795-A	30.33	73	Reprovado	37	25	29
\N	\N	IA1796-A	37.33	33	Reprovado	40	47	25
\N	\N	IA1797-A	17.33	94	Reprovado	2	14	36
\N	\N	IA1798-A	31.33	57	Reprovado	25	11	58
\N	\N	IA1799-A	21.67	35	Reprovado	5	18	42
\N	\N	IA1800-A	14.33	87	Reprovado	35	8	0
\N	\N	IA1801-A	42.33	71	Reprovado	40	45	42
\N	\N	IA1802-A	26.33	39	Reprovado	15	27	37
\N	\N	IA1803-A	32.33	61	Reprovado	36	47	14
\N	\N	IA1804-A	34.67	40	Reprovado	6	53	45
\N	\N	IA1805-A	37.33	35	Reprovado	46	52	14
\N	\N	IA1806-A	20.33	75	Reprovado	57	1	3
MAT01028	ALU0172	IA502-B	83.67	98	Aprovado	69	85	97
\N	\N	IA2769-A	36.00	90	Reprovado	45	19	44
\N	\N	IA2770-A	33.67	97	Reprovado	27	51	23
\N	\N	IA2771-A	31.33	72	Reprovado	36	35	23
\N	\N	IA2772-A	35.33	82	Reprovado	41	47	18
\N	\N	IA2773-A	36.33	70	Reprovado	45	12	52
\N	\N	IA2774-A	36.67	61	Reprovado	14	49	47
\N	\N	IA2775-A	40.33	55	Reprovado	10	59	52
\N	\N	IA2776-A	36.33	97	Reprovado	20	41	48
\N	\N	IA2777-A	24.33	64	Reprovado	23	11	39
\N	\N	IA2778-A	35.00	70	Reprovado	52	53	0
\N	\N	IA2779-A	32.67	100	Reprovado	35	54	9
\N	\N	IA2780-A	15.33	91	Reprovado	14	3	29
\N	\N	IA2781-A	35.67	48	Reprovado	22	56	29
\N	\N	IA2782-A	28.33	41	Reprovado	16	45	24
\N	\N	IA2783-A	29.33	95	Reprovado	37	45	6
\N	\N	IA2784-A	32.67	54	Reprovado	33	55	10
\N	\N	IA2785-A	37.33	31	Reprovado	48	26	38
\N	\N	IA2786-A	27.67	64	Reprovado	38	11	34
\N	\N	IA2787-A	35.00	58	Reprovado	42	21	42
\N	\N	IA2788-A	32.33	85	Reprovado	21	20	56
\N	\N	IA2789-A	36.33	68	Reprovado	31	28	50
\N	\N	IA2790-A	30.33	44	Reprovado	30	17	44
\N	\N	IA2791-A	4.33	48	Reprovado	0	8	5
\N	\N	IA2792-A	33.33	94	Reprovado	32	14	54
\N	\N	IA2793-A	20.67	54	Reprovado	23	16	23
\N	\N	IA2794-A	36.67	52	Reprovado	27	41	42
\N	\N	IA2795-A	30.33	87	Reprovado	10	27	54
\N	\N	IA2796-A	36.00	89	Reprovado	53	48	7
\N	\N	IA2797-A	14.67	40	Reprovado	26	6	12
\N	\N	IA2798-A	16.00	81	Reprovado	12	29	7
\N	\N	IA2799-A	23.67	31	Reprovado	2	47	22
\N	\N	IA2800-A	34.00	67	Reprovado	32	34	36
\N	\N	IA2801-A	38.67	90	Reprovado	9	57	50
\N	\N	IA2802-A	26.33	62	Reprovado	14	31	34
\N	\N	IA2803-A	26.33	35	Reprovado	23	16	40
\N	\N	IA2804-A	43.00	76	Reprovado	50	50	29
\N	\N	IA2805-A	36.00	60	Reprovado	52	56	0
\N	\N	IA2806-A	42.33	47	Reprovado	45	32	50
\N	\N	IA807-A	67.67	85	Aprovado	73	67	63
\N	\N	IA808-A	65.67	82	Aprovado	69	64	64
\N	\N	IA809-A	73.33	78	Aprovado	93	62	65
\N	\N	IA810-A	71.00	92	Aprovado	78	74	61
\N	\N	IA811-A	81.00	95	Aprovado	76	76	91
\N	\N	IA812-A	73.33	80	Aprovado	62	70	88
\N	\N	IA813-A	76.33	97	Aprovado	70	87	72
\N	\N	IA814-A	83.33	90	Aprovado	94	60	96
\N	\N	IA815-A	71.67	88	Aprovado	71	79	65
\N	\N	IA816-A	80.33	78	Aprovado	90	71	80
\N	\N	IA817-A	69.67	91	Aprovado	63	65	81
\N	\N	IA818-A	79.00	76	Aprovado	89	80	68
\N	\N	IA819-A	69.33	79	Aprovado	61	69	78
\N	\N	IA820-A	80.33	76	Aprovado	87	65	89
\N	\N	IA821-A	73.33	90	Aprovado	60	72	88
\N	\N	IA822-A	77.67	89	Aprovado	61	86	86
\N	\N	IA823-A	76.33	92	Aprovado	68	90	71
\N	\N	IA824-A	81.67	77	Aprovado	86	91	68
\N	\N	IA825-A	78.67	95	Aprovado	82	91	63
\N	\N	IA826-A	80.00	76	Aprovado	60	88	92
\N	\N	IA827-A	74.00	84	Aprovado	76	68	78
\N	\N	IA828-A	81.00	88	Aprovado	74	73	96
\N	\N	IA829-A	82.67	81	Aprovado	85	65	98
\N	\N	IA830-A	79.00	96	Aprovado	62	82	93
\N	\N	IA831-A	72.67	87	Aprovado	68	73	77
\N	\N	IA832-A	68.67	98	Aprovado	82	60	64
\N	\N	IA833-A	77.67	90	Aprovado	83	82	68
\N	\N	IA834-A	78.33	80	Aprovado	85	79	71
\N	\N	IA835-A	79.33	85	Aprovado	66	92	80
\N	\N	IA836-A	80.67	89	Aprovado	92	80	70
\N	\N	IA837-A	69.33	98	Aprovado	68	69	71
\N	\N	IA838-A	81.33	85	Aprovado	93	88	63
\N	\N	IA839-A	90.67	78	Aprovado	81	95	96
\N	\N	IA840-A	92.00	84	Aprovado	99	85	92
\N	\N	IA841-A	65.67	88	Aprovado	65	60	72
\N	\N	IA842-A	79.00	87	Aprovado	96	61	80
\N	\N	IA843-A	76.33	93	Aprovado	71	95	63
\N	\N	IA844-A	72.33	97	Aprovado	68	67	82
\N	\N	IA845-A	78.00	83	Aprovado	75	94	65
\N	\N	IA846-A	80.33	98	Aprovado	93	85	63
\N	\N	IA847-A	77.00	97	Aprovado	84	66	81
\N	\N	IA848-A	95.33	85	Aprovado	86	100	100
\N	\N	IA849-A	73.67	75	Aprovado	67	87	67
\N	\N	IA850-A	72.33	99	Aprovado	63	86	68
\N	\N	IA851-A	90.67	84	Aprovado	96	98	78
\N	\N	IA852-A	81.33	83	Aprovado	80	69	95
\N	\N	IA853-A	76.67	84	Aprovado	79	79	72
\N	\N	IA854-A	76.67	80	Aprovado	66	92	72
\N	\N	IA855-A	85.00	75	Aprovado	92	85	78
\N	\N	IA856-A	94.33	89	Aprovado	89	99	95
\N	\N	IA857-A	82.67	80	Aprovado	98	70	80
\N	\N	IA858-A	78.67	95	Aprovado	79	62	95
\N	\N	IA859-A	82.00	75	Aprovado	64	90	92
\N	\N	IA860-A	82.67	81	Aprovado	63	90	95
\N	\N	IA861-A	77.00	85	Aprovado	90	67	74
\N	\N	IA862-A	90.33	95	Aprovado	97	78	96
\N	\N	IA863-A	84.67	94	Aprovado	81	83	90
\N	\N	IA864-A	80.67	80	Aprovado	78	80	84
\N	\N	IA865-A	79.00	94	Aprovado	78	64	95
\N	\N	IA866-A	85.00	81	Aprovado	86	95	74
\N	\N	IA867-A	82.00	78	Aprovado	99	66	81
\N	\N	IA868-A	67.33	91	Aprovado	70	62	70
\N	\N	IA869-A	81.33	77	Aprovado	81	97	66
\N	\N	IA870-A	72.00	95	Aprovado	83	66	67
\N	\N	IA871-A	81.00	79	Aprovado	79	75	89
\N	\N	IA872-A	85.33	96	Aprovado	69	94	93
\N	\N	IA873-A	76.00	84	Aprovado	71	94	63
\N	\N	IA874-A	72.00	93	Aprovado	82	67	67
\N	\N	IA875-A	83.00	91	Aprovado	80	98	71
\N	\N	IA876-A	85.33	91	Aprovado	86	88	82
\N	\N	IA877-A	73.33	98	Aprovado	65	61	94
\N	\N	IA878-A	82.67	89	Aprovado	88	79	81
\N	\N	IA879-A	70.00	84	Aprovado	62	71	77
\N	\N	IA880-A	80.67	98	Aprovado	91	66	85
\N	\N	IA881-A	86.33	95	Aprovado	71	96	92
\N	\N	IA882-A	80.33	81	Aprovado	73	72	96
\N	\N	IA883-A	92.67	90	Aprovado	90	98	90
\N	\N	IA884-A	93.00	77	Aprovado	99	93	87
\N	\N	IA885-A	89.33	77	Aprovado	95	90	83
\N	\N	IA886-A	80.33	92	Aprovado	78	83	80
\N	\N	IA887-A	75.33	93	Aprovado	76	86	64
\N	\N	IA888-A	69.67	96	Aprovado	64	78	67
\N	\N	IA889-A	81.67	91	Aprovado	99	73	73
\N	\N	IA890-A	82.33	95	Aprovado	89	69	89
\N	\N	IA891-A	82.67	91	Aprovado	92	78	78
\N	\N	IA892-A	81.00	80	Aprovado	80	66	97
\N	\N	IA893-A	76.33	79	Aprovado	64	92	73
\N	\N	IA894-A	76.00	81	Aprovado	100	64	64
\N	\N	IA895-A	77.00	76	Aprovado	73	68	90
\N	\N	IA896-A	86.67	89	Aprovado	64	99	97
\N	\N	IA897-A	92.00	98	Aprovado	97	89	90
\N	\N	IA898-A	86.00	92	Aprovado	87	91	80
\N	\N	IA899-A	75.33	94	Aprovado	74	67	85
\N	\N	IA900-A	71.67	79	Aprovado	71	74	70
\N	\N	IA901-A	77.00	81	Aprovado	69	95	67
\N	\N	IA902-A	88.33	91	Aprovado	94	87	84
\N	\N	IA903-A	78.67	94	Aprovado	93	63	80
\N	\N	IA904-A	80.00	98	Aprovado	74	89	77
\N	\N	IA905-A	79.33	80	Aprovado	65	85	88
\N	\N	IA906-A	89.00	90	Aprovado	100	91	76
\N	\N	IA907-A	73.67	79	Aprovado	70	75	76
\N	\N	IA908-A	88.00	81	Aprovado	84	88	92
\N	\N	IA909-A	75.33	96	Aprovado	64	91	71
\N	\N	IA910-A	85.00	86	Aprovado	93	68	94
\N	\N	IA911-A	80.33	92	Aprovado	88	72	81
\N	\N	IA912-A	70.33	86	Aprovado	60	76	75
\N	\N	IA913-A	69.67	75	Aprovado	79	60	70
\N	\N	IA914-A	73.00	97	Aprovado	85	64	70
\N	\N	IA915-A	82.33	89	Aprovado	66	82	99
\N	\N	IA916-A	89.67	84	Aprovado	92	80	97
\N	\N	IA917-A	75.00	96	Aprovado	76	64	85
\N	\N	IA918-A	82.67	88	Aprovado	61	98	89
\N	\N	IA919-A	83.00	83	Aprovado	74	90	85
\N	\N	IA920-A	80.33	92	Aprovado	73	86	82
\N	\N	IA921-A	74.00	97	Aprovado	69	90	63
\N	\N	IA922-A	87.00	97	Aprovado	71	92	98
\N	\N	IA923-A	89.00	100	Aprovado	93	85	89
\N	\N	IA924-A	95.00	91	Aprovado	97	91	97
\N	\N	IA925-A	69.67	93	Aprovado	74	70	65
\N	\N	IA926-A	85.00	89	Aprovado	95	95	65
\N	\N	IA927-A	68.33	78	Aprovado	71	62	72
\N	\N	IA928-A	76.00	75	Aprovado	84	81	63
\N	\N	IA929-A	85.00	86	Aprovado	94	92	69
\N	\N	IA930-A	87.00	100	Aprovado	78	96	87
\N	\N	IA931-A	73.67	95	Aprovado	63	77	81
\N	\N	IA932-A	81.33	76	Aprovado	73	84	87
\N	\N	IA933-A	80.67	91	Aprovado	81	82	79
\N	\N	IA934-A	78.33	79	Aprovado	80	62	93
\N	\N	IA935-A	72.67	90	Aprovado	66	83	69
\N	\N	IA936-A	82.33	77	Aprovado	90	80	77
\N	\N	IA937-A	93.67	91	Aprovado	91	94	96
\N	\N	IA938-A	86.33	91	Aprovado	81	95	83
\N	\N	IA939-A	75.67	95	Aprovado	98	61	68
\N	\N	IA940-A	76.33	95	Aprovado	69	82	78
\N	\N	IA941-A	76.33	87	Aprovado	76	74	79
\N	\N	IA942-A	71.67	87	Aprovado	80	63	72
\N	\N	IA943-A	71.67	86	Aprovado	86	62	67
\N	\N	IA944-A	80.33	96	Aprovado	93	74	74
\N	\N	IA945-A	77.67	96	Aprovado	86	71	76
\N	\N	IA946-A	81.33	88	Aprovado	89	86	69
\N	\N	IA947-A	80.67	92	Aprovado	96	68	78
\N	\N	IA948-A	83.00	89	Aprovado	100	85	64
\N	\N	IA949-A	77.33	94	Aprovado	90	71	71
\N	\N	IA950-A	69.00	94	Aprovado	79	61	67
\N	\N	IA951-A	84.33	79	Aprovado	60	93	100
\N	\N	IA952-A	86.00	99	Aprovado	71	97	90
\N	\N	IA953-A	87.67	92	Aprovado	79	93	91
\N	\N	IA954-A	79.00	76	Aprovado	87	65	85
\N	\N	IA955-A	90.00	99	Aprovado	91	87	92
\N	\N	IA956-A	78.67	85	Aprovado	82	61	93
\N	\N	IA957-A	87.00	100	Aprovado	72	96	93
\N	\N	IA958-A	83.00	90	Aprovado	76	97	76
\N	\N	IA959-A	85.67	92	Aprovado	100	64	93
\N	\N	IA960-A	83.00	78	Aprovado	76	100	73
\N	\N	IA961-A	75.00	86	Aprovado	83	81	61
\N	\N	IA962-A	95.67	83	Aprovado	98	100	89
\N	\N	IA963-A	76.67	79	Aprovado	66	93	71
\N	\N	IA964-A	83.33	91	Aprovado	84	69	97
\N	\N	IA965-A	82.67	95	Aprovado	82	91	75
\N	\N	IA966-A	75.33	85	Aprovado	89	77	60
\N	\N	IA967-A	71.33	75	Aprovado	65	81	68
\N	\N	IA968-A	84.67	78	Aprovado	91	71	92
\N	\N	IA969-A	84.67	75	Aprovado	74	94	86
\N	\N	IA970-A	78.33	86	Aprovado	91	60	84
\N	\N	IA971-A	76.33	86	Aprovado	67	71	91
\N	\N	IA972-A	68.67	98	Aprovado	71	61	74
\N	\N	IA973-A	76.67	85	Aprovado	76	64	90
\N	\N	IA974-A	88.67	75	Aprovado	84	92	90
\N	\N	IA975-A	82.33	78	Aprovado	90	90	67
\N	\N	IA976-A	67.33	89	Aprovado	80	62	60
\N	\N	IA977-A	77.33	88	Aprovado	75	70	87
\N	\N	IA978-A	79.67	94	Aprovado	79	87	73
\N	\N	IA979-A	76.33	90	Aprovado	72	85	72
\N	\N	IA980-A	86.67	83	Aprovado	76	99	85
\N	\N	IA981-A	73.00	91	Aprovado	63	79	77
\N	\N	IA982-A	69.67	81	Aprovado	61	61	87
\N	\N	IA983-A	80.00	82	Aprovado	98	72	70
\N	\N	IA984-A	75.00	96	Aprovado	74	62	89
\N	\N	IA985-A	81.67	91	Aprovado	85	91	69
\N	\N	IA986-A	86.00	89	Aprovado	100	72	86
\N	\N	IA987-A	67.00	94	Aprovado	73	62	66
\N	\N	IA988-A	79.00	79	Aprovado	98	67	72
\N	\N	IA989-A	73.67	81	Aprovado	82	60	79
\N	\N	IA990-A	76.67	92	Aprovado	75	71	84
\N	\N	IA991-A	84.67	95	Aprovado	99	61	94
\N	\N	IA992-A	83.67	85	Aprovado	92	68	91
\N	\N	IA993-A	84.00	86	Aprovado	74	98	80
\N	\N	IA994-A	85.00	75	Aprovado	88	73	94
\N	\N	IA995-A	84.00	100	Aprovado	99	83	70
\N	\N	IA996-A	75.33	96	Aprovado	77	85	64
\N	\N	IA997-A	81.00	75	Aprovado	67	84	92
\N	\N	IA998-A	64.67	91	Aprovado	61	70	63
\N	\N	IA999-A	89.33	94	Aprovado	90	97	81
\N	\N	IA1000-A	81.67	78	Aprovado	75	72	98
\N	\N	IA1001-A	88.67	87	Aprovado	77	99	90
\N	\N	IA1002-A	94.67	83	Aprovado	99	93	92
\N	\N	IA1003-A	84.67	94	Aprovado	98	65	91
\N	\N	IA1004-A	66.33	83	Aprovado	70	61	68
\N	\N	IA1005-A	81.33	99	Aprovado	87	96	61
\N	\N	IA1006-A	78.00	92	Aprovado	74	78	82
\N	\N	IA1007-A	80.67	84	Aprovado	89	90	63
\N	\N	IA1008-A	75.00	92	Aprovado	62	91	72
\N	\N	IA1009-A	71.67	76	Aprovado	89	63	63
\N	\N	IA1010-A	80.67	81	Aprovado	68	80	94
\N	\N	IA1011-A	78.67	84	Aprovado	72	89	75
\N	\N	IA1012-A	90.33	91	Aprovado	78	98	95
\N	\N	IA1013-A	87.33	92	Aprovado	99	84	79
\N	\N	IA1014-A	75.67	93	Aprovado	73	74	80
\N	\N	IA1015-A	76.67	94	Aprovado	74	95	61
\N	\N	IA1016-A	73.00	82	Aprovado	69	80	70
\N	\N	IA1017-A	86.00	100	Aprovado	69	90	99
\N	\N	IA1018-A	71.33	76	Aprovado	63	67	84
\N	\N	IA1019-A	76.67	100	Aprovado	66	79	85
\N	\N	IA1020-A	75.67	85	Aprovado	75	87	65
\N	\N	IA1021-A	82.67	77	Aprovado	80	88	80
\N	\N	IA1022-A	75.33	86	Aprovado	79	87	60
\N	\N	IA1023-A	82.67	88	Aprovado	90	77	81
\N	\N	IA1024-A	72.33	92	Aprovado	83	66	68
\N	\N	IA1025-A	80.67	90	Aprovado	85	92	65
\N	\N	IA1026-A	84.33	93	Aprovado	60	93	100
\N	\N	IA1027-A	85.00	93	Aprovado	82	85	88
\N	\N	IA1028-A	85.33	78	Aprovado	89	79	88
\N	\N	IA1029-A	89.67	96	Aprovado	76	97	96
\N	\N	IA1030-A	79.00	97	Aprovado	85	69	83
\N	\N	IA1031-A	85.67	76	Aprovado	72	93	92
\N	\N	IA1032-A	77.67	99	Aprovado	70	65	98
\N	\N	IA1033-A	79.33	80	Aprovado	85	74	79
\N	\N	IA1034-A	77.33	94	Aprovado	95	77	60
\N	\N	IA1035-A	70.33	86	Aprovado	65	86	60
\N	\N	IA1036-A	77.00	92	Aprovado	69	74	88
\N	\N	IA1037-A	71.33	76	Aprovado	66	80	68
\N	\N	IA1038-A	80.67	86	Aprovado	76	89	77
\N	\N	IA1039-A	69.67	89	Aprovado	67	66	76
\N	\N	IA1040-A	97.33	84	Aprovado	95	100	97
\N	\N	IA1041-A	85.00	75	Aprovado	98	67	90
\N	\N	IA1042-A	79.33	99	Aprovado	88	73	77
\N	\N	IA1043-A	76.33	93	Aprovado	72	97	60
\N	\N	IA1044-A	85.00	86	Aprovado	69	96	90
\N	\N	IA1045-A	84.00	83	Aprovado	100	70	82
\N	\N	IA1046-A	80.00	80	Aprovado	77	70	93
\N	\N	IA1047-A	87.33	90	Aprovado	73	90	99
\N	\N	IA1048-A	89.67	94	Aprovado	92	97	80
\N	\N	IA1049-A	68.33	91	Aprovado	60	80	65
\N	\N	IA1050-A	88.00	82	Aprovado	88	92	84
\N	\N	IA1051-A	86.67	82	Aprovado	94	69	97
\N	\N	IA1052-A	77.00	96	Aprovado	91	68	72
\N	\N	IA1053-A	69.00	95	Aprovado	83	62	62
\N	\N	IA1054-A	83.33	91	Aprovado	74	81	95
\N	\N	IA1055-A	81.33	76	Aprovado	92	75	77
\N	\N	IA1056-A	81.00	77	Aprovado	90	63	90
\N	\N	IA1057-A	75.67	85	Aprovado	62	86	79
\N	\N	IA1058-A	73.00	94	Aprovado	77	63	79
\N	\N	IA1059-A	93.00	91	Aprovado	99	94	86
\N	\N	IA1060-A	84.00	81	Aprovado	65	89	98
\N	\N	IA1061-A	76.67	99	Aprovado	64	73	93
\N	\N	IA1062-A	78.67	75	Aprovado	63	88	85
\N	\N	IA1063-A	81.33	80	Aprovado	64	97	83
\N	\N	IA1064-A	88.67	87	Aprovado	95	79	92
\N	\N	IA1065-A	77.67	100	Aprovado	82	66	85
\N	\N	IA1066-A	86.00	84	Aprovado	98	67	93
\N	\N	IA1067-A	83.33	91	Aprovado	88	97	65
\N	\N	IA1068-A	78.67	96	Aprovado	69	69	98
\N	\N	IA1069-A	73.00	76	Aprovado	89	65	65
\N	\N	IA1070-A	80.67	91	Aprovado	70	92	80
\N	\N	IA1071-A	87.67	76	Aprovado	95	68	100
\N	\N	IA1072-A	87.67	92	Aprovado	98	92	73
\N	\N	IA1073-A	83.67	91	Aprovado	82	83	86
\N	\N	IA1074-A	79.00	95	Aprovado	87	73	77
\N	\N	IA1075-A	79.67	75	Aprovado	69	86	84
\N	\N	IA1076-A	73.33	82	Aprovado	64	65	91
\N	\N	IA1077-A	71.33	84	Aprovado	73	68	73
\N	\N	IA1078-A	82.67	77	Aprovado	80	74	94
\N	\N	IA1079-A	84.00	90	Aprovado	75	99	78
\N	\N	IA1080-A	70.33	76	Aprovado	83	63	65
\N	\N	IA1081-A	72.67	93	Aprovado	60	96	62
\N	\N	IA1082-A	82.67	95	Aprovado	68	86	94
\N	\N	IA1083-A	74.33	94	Aprovado	65	75	83
\N	\N	IA1084-A	76.67	82	Aprovado	73	96	61
\N	\N	IA1085-A	77.67	97	Aprovado	94	63	76
\N	\N	IA1086-A	80.00	91	Aprovado	80	82	78
\N	\N	IA1087-A	80.00	94	Aprovado	60	86	94
\N	\N	IA1088-A	87.67	91	Aprovado	78	99	86
\N	\N	IA1089-A	82.00	85	Aprovado	82	86	78
\N	\N	IA1090-A	90.33	88	Aprovado	95	84	92
\N	\N	IA1091-A	79.00	94	Aprovado	89	79	69
\N	\N	IA1092-A	91.67	84	Aprovado	82	93	100
\N	\N	IA1093-A	91.33	84	Aprovado	100	97	77
\N	\N	IA1094-A	77.67	98	Aprovado	68	77	88
\N	\N	IA1095-A	91.67	98	Aprovado	100	93	82
\N	\N	IA1096-A	84.33	82	Aprovado	94	85	74
\N	\N	IA1097-A	74.67	96	Aprovado	83	64	77
\N	\N	IA1098-A	83.33	81	Aprovado	92	65	93
\N	\N	IA1099-A	87.33	93	Aprovado	98	87	77
\N	\N	IA1100-A	85.67	99	Aprovado	83	96	78
\N	\N	IA1101-A	68.67	84	Aprovado	61	60	85
\N	\N	IA1102-A	82.33	87	Aprovado	75	94	78
\N	\N	IA1103-A	78.33	81	Aprovado	95	61	79
\N	\N	IA1104-A	74.33	83	Aprovado	69	74	80
\N	\N	IA1105-A	77.33	90	Aprovado	64	82	86
\N	\N	IA1106-A	72.00	98	Aprovado	78	71	67
\N	\N	IA1107-A	86.67	79	Aprovado	76	88	96
\N	\N	IA1108-A	89.00	88	Aprovado	99	83	85
\N	\N	IA1109-A	65.67	100	Aprovado	61	67	69
\N	\N	IA1110-A	84.67	87	Aprovado	100	66	88
\N	\N	IA1111-A	76.00	88	Aprovado	71	75	82
\N	\N	IA1112-A	87.00	98	Aprovado	91	89	81
\N	\N	IA1113-A	74.00	75	Aprovado	70	62	90
\N	\N	IA1114-A	75.33	78	Aprovado	93	62	71
\N	\N	IA1115-A	78.33	96	Aprovado	65	70	100
\N	\N	IA1116-A	77.00	99	Aprovado	77	68	86
\N	\N	IA1117-A	81.33	96	Aprovado	78	67	99
\N	\N	IA1118-A	82.00	96	Aprovado	85	78	83
\N	\N	IA1119-A	80.67	87	Aprovado	91	61	90
\N	\N	IA1120-A	73.00	86	Aprovado	71	79	69
\N	\N	IA1121-A	85.33	89	Aprovado	99	91	66
\N	\N	IA1122-A	86.33	97	Aprovado	78	95	86
\N	\N	IA1123-A	78.00	94	Aprovado	98	73	63
\N	\N	IA1124-A	88.33	91	Aprovado	88	80	97
\N	\N	IA1125-A	66.00	84	Aprovado	63	66	69
\N	\N	IA1126-A	80.33	92	Aprovado	71	82	88
\N	\N	IA1127-A	82.33	89	Aprovado	69	87	91
\N	\N	IA1128-A	67.67	86	Aprovado	65	72	66
\N	\N	IA1129-A	85.00	91	Aprovado	81	92	82
\N	\N	IA1130-A	80.00	84	Aprovado	88	71	81
\N	\N	IA1131-A	84.00	82	Aprovado	72	83	97
\N	\N	IA1132-A	92.67	76	Aprovado	87	99	92
\N	\N	IA1133-A	81.33	77	Aprovado	73	87	84
\N	\N	IA1134-A	79.33	85	Aprovado	97	71	70
\N	\N	IA1135-A	71.67	84	Aprovado	88	67	60
\N	\N	IA1136-A	75.33	83	Aprovado	63	75	88
\N	\N	IA1137-A	82.00	100	Aprovado	63	92	91
\N	\N	IA1138-A	77.33	97	Aprovado	80	88	64
\N	\N	IA1139-A	80.00	78	Aprovado	83	87	70
\N	\N	IA1140-A	81.33	99	Aprovado	68	77	99
\N	\N	IA1141-A	68.33	94	Aprovado	65	79	61
\N	\N	IA1142-A	90.00	90	Aprovado	94	78	98
\N	\N	IA1143-A	85.00	77	Aprovado	92	72	91
\N	\N	IA1144-A	83.67	99	Aprovado	95	77	79
\N	\N	IA1145-A	79.67	79	Aprovado	77	92	70
\N	\N	IA1146-A	76.00	77	Aprovado	79	85	64
\N	\N	IA1147-A	87.67	88	Aprovado	89	86	88
\N	\N	IA1148-A	84.33	78	Aprovado	61	94	98
\N	\N	IA1149-A	83.33	81	Aprovado	93	92	65
\N	\N	IA1150-A	76.67	77	Aprovado	71	67	92
\N	\N	IA1151-A	84.33	79	Aprovado	61	92	100
\N	\N	IA1152-A	71.00	88	Aprovado	66	71	76
\N	\N	IA1153-A	87.00	78	Aprovado	98	93	70
\N	\N	IA1154-A	83.33	92	Aprovado	64	88	98
\N	\N	IA1155-A	79.33	97	Aprovado	79	84	75
\N	\N	IA1156-A	81.00	77	Aprovado	72	86	85
\N	\N	IA1157-A	84.33	90	Aprovado	83	70	100
\N	\N	IA1158-A	76.00	88	Aprovado	60	98	70
\N	\N	IA1159-A	84.33	79	Aprovado	90	65	98
\N	\N	IA1160-A	80.67	92	Aprovado	98	81	63
\N	\N	IA1161-A	75.00	93	Aprovado	90	63	72
\N	\N	IA1162-A	83.00	75	Aprovado	98	69	82
\N	\N	IA1163-A	73.33	91	Aprovado	68	79	73
\N	\N	IA1164-A	72.33	75	Aprovado	76	77	64
\N	\N	IA1165-A	73.33	78	Aprovado	75	78	67
\N	\N	IA1166-A	78.67	100	Aprovado	63	96	77
\N	\N	IA1167-A	85.00	77	Aprovado	80	94	81
\N	\N	IA1168-A	90.67	82	Aprovado	99	86	87
\N	\N	IA1169-A	85.00	92	Aprovado	77	94	84
\N	\N	IA1170-A	86.33	98	Aprovado	98	74	87
\N	\N	IA1171-A	69.33	91	Aprovado	74	66	68
\N	\N	IA1172-A	72.33	78	Aprovado	76	61	80
\N	\N	IA1173-A	79.00	77	Aprovado	83	64	90
\N	\N	IA1174-A	83.33	94	Aprovado	96	91	63
\N	\N	IA1175-A	85.00	100	Aprovado	95	88	72
\N	\N	IA1176-A	87.33	89	Aprovado	76	91	95
\N	\N	IA1177-A	87.67	77	Aprovado	97	82	84
\N	\N	IA1178-A	74.33	86	Aprovado	81	82	60
\N	\N	IA1179-A	80.67	92	Aprovado	67	85	90
\N	\N	IA1180-A	96.00	96	Aprovado	95	97	96
\N	\N	IA1181-A	81.33	85	Aprovado	68	100	76
\N	\N	IA1182-A	82.33	96	Aprovado	87	77	83
\N	\N	IA1183-A	88.33	89	Aprovado	91	92	82
\N	\N	IA1184-A	77.00	93	Aprovado	80	81	70
\N	\N	IA1185-A	90.33	78	Aprovado	94	95	82
\N	\N	IA1186-A	76.33	93	Aprovado	85	64	80
\N	\N	IA1187-A	83.00	94	Aprovado	93	60	96
\N	\N	IA1188-A	79.67	95	Aprovado	82	82	75
\N	\N	IA1189-A	79.67	100	Aprovado	98	67	74
\N	\N	IA1190-A	75.33	82	Aprovado	99	67	60
\N	\N	IA1191-A	79.33	89	Aprovado	65	81	92
\N	\N	IA1192-A	83.67	93	Aprovado	62	93	96
\N	\N	IA1193-A	75.33	81	Aprovado	68	83	75
\N	\N	IA1194-A	83.33	95	Aprovado	82	86	82
\N	\N	IA1195-A	80.67	100	Aprovado	76	79	87
\N	\N	IA1196-A	75.33	99	Aprovado	82	64	80
\N	\N	IA1197-A	84.33	80	Aprovado	87	74	92
\N	\N	IA1198-A	79.33	100	Aprovado	79	65	94
\N	\N	IA1199-A	89.67	93	Aprovado	84	86	99
\N	\N	IA1200-A	97.33	98	Aprovado	98	97	97
\N	\N	IA1201-A	74.33	78	Aprovado	72	81	70
\N	\N	IA1202-A	85.33	84	Aprovado	76	88	92
\N	\N	IA1203-A	84.00	87	Aprovado	83	99	70
\N	\N	IA1204-A	78.67	95	Aprovado	72	65	99
\N	\N	IA1205-A	85.00	100	Aprovado	88	91	76
\N	\N	IA1206-A	85.67	90	Aprovado	88	78	91
\N	\N	IA1207-A	88.00	84	Aprovado	99	72	93
\N	\N	IA1208-A	78.33	87	Aprovado	91	70	74
\N	\N	IA1209-A	84.00	92	Aprovado	98	84	70
\N	\N	IA1210-A	71.33	94	Aprovado	69	64	81
\N	\N	IA1211-A	80.00	82	Aprovado	74	74	92
\N	\N	IA1212-A	88.00	88	Aprovado	67	98	99
\N	\N	IA1213-A	83.00	91	Aprovado	94	87	68
\N	\N	IA1214-A	82.33	99	Aprovado	70	90	87
\N	\N	IA1215-A	89.33	100	Aprovado	82	100	86
\N	\N	IA1216-A	79.67	86	Aprovado	93	72	74
\N	\N	IA1217-A	87.33	78	Aprovado	88	84	90
\N	\N	IA1218-A	73.00	75	Aprovado	77	76	66
\N	\N	IA1219-A	84.67	89	Aprovado	98	90	66
\N	\N	IA1220-A	96.33	98	Aprovado	97	100	92
\N	\N	IA1221-A	70.33	86	Aprovado	65	80	66
\N	\N	IA1222-A	78.67	78	Aprovado	61	94	81
\N	\N	IA1223-A	89.33	76	Aprovado	100	81	87
\N	\N	IA1224-A	89.67	91	Aprovado	99	95	75
\N	\N	IA1225-A	96.33	97	Aprovado	97	97	95
\N	\N	IA1226-A	79.00	76	Aprovado	71	92	74
\N	\N	IA1227-A	80.67	76	Aprovado	69	78	95
\N	\N	IA1228-A	83.33	75	Aprovado	80	87	83
\N	\N	IA1229-A	79.67	93	Aprovado	83	71	85
\N	\N	IA1230-A	75.00	76	Aprovado	62	95	68
\N	\N	IA1231-A	75.33	97	Aprovado	66	64	96
\N	\N	IA1232-A	92.67	97	Aprovado	96	82	100
\N	\N	IA1233-A	67.33	83	Aprovado	60	76	66
\N	\N	IA1234-A	67.00	77	Aprovado	63	62	76
\N	\N	IA1235-A	84.67	95	Aprovado	100	81	73
\N	\N	IA1236-A	83.00	95	Aprovado	92	77	80
\N	\N	IA1237-A	74.67	89	Aprovado	79	65	80
\N	\N	IA1238-A	84.33	94	Aprovado	81	90	82
\N	\N	IA1239-A	73.67	93	Aprovado	66	86	69
\N	\N	IA1240-A	81.00	95	Aprovado	91	67	85
\N	\N	IA1241-A	88.00	95	Aprovado	98	90	76
\N	\N	IA1242-A	81.67	97	Aprovado	96	76	73
\N	\N	IA1243-A	90.67	85	Aprovado	100	94	78
\N	\N	IA1244-A	87.00	88	Aprovado	92	77	92
\N	\N	IA1245-A	82.33	88	Aprovado	100	64	83
\N	\N	IA1246-A	72.67	94	Aprovado	95	63	60
\N	\N	IA1247-A	78.33	77	Aprovado	94	63	78
\N	\N	IA1248-A	81.33	85	Aprovado	90	82	72
\N	\N	IA1249-A	80.00	92	Aprovado	94	75	71
\N	\N	IA1250-A	83.00	96	Aprovado	73	79	97
\N	\N	IA1251-A	83.67	93	Aprovado	73	97	81
\N	\N	IA1252-A	81.33	81	Aprovado	90	81	73
\N	\N	IA1253-A	79.00	99	Aprovado	67	92	78
\N	\N	IA1254-A	87.00	96	Aprovado	73	93	95
\N	\N	IA1255-A	73.00	97	Aprovado	70	80	69
\N	\N	IA1256-A	75.00	84	Aprovado	69	84	72
\N	\N	IA1257-A	89.33	99	Aprovado	94	85	89
\N	\N	IA1258-A	69.67	89	Aprovado	65	64	80
\N	\N	IA1259-A	75.00	96	Aprovado	80	78	67
\N	\N	IA1260-A	76.67	81	Aprovado	86	64	80
\N	\N	IA1261-A	83.67	93	Aprovado	69	90	92
\N	\N	IA1262-A	77.67	90	Aprovado	69	77	87
\N	\N	IA1263-A	81.33	91	Aprovado	88	68	88
\N	\N	IA1264-A	79.67	100	Aprovado	79	77	83
\N	\N	IA1265-A	73.00	80	Aprovado	61	80	78
\N	\N	IA1266-A	81.00	98	Aprovado	68	79	96
\N	\N	IA1267-A	95.00	82	Aprovado	98	87	100
\N	\N	IA1268-A	76.00	79	Aprovado	63	100	65
\N	\N	IA1269-A	69.00	81	Aprovado	68	66	73
\N	\N	IA1270-A	83.67	96	Aprovado	64	91	96
\N	\N	IA1271-A	76.67	86	Aprovado	71	97	62
\N	\N	IA1272-A	88.33	89	Aprovado	99	79	87
\N	\N	IA1273-A	73.67	78	Aprovado	85	74	62
\N	\N	IA1274-A	75.67	84	Aprovado	64	88	75
\N	\N	IA1275-A	81.67	77	Aprovado	80	90	75
\N	\N	IA1276-A	84.33	82	Aprovado	90	85	78
\N	\N	IA1277-A	79.33	100	Aprovado	72	96	70
\N	\N	IA1278-A	80.67	94	Aprovado	100	82	60
\N	\N	IA1279-A	74.67	89	Aprovado	78	68	78
\N	\N	IA1280-A	83.00	93	Aprovado	80	72	97
\N	\N	IA1281-A	73.33	83	Aprovado	87	67	66
\N	\N	IA1282-A	91.33	94	Aprovado	81	96	97
\N	\N	IA1283-A	80.33	99	Aprovado	90	67	84
\N	\N	IA1284-A	72.00	96	Aprovado	73	65	78
\N	\N	IA1285-A	75.67	100	Aprovado	68	88	71
\N	\N	IA1286-A	77.00	91	Aprovado	70	90	71
\N	\N	IA1287-A	85.67	76	Aprovado	69	93	95
\N	\N	IA1288-A	71.33	82	Aprovado	82	69	63
\N	\N	IA1289-A	78.33	97	Aprovado	98	63	74
\N	\N	IA1290-A	90.33	81	Aprovado	94	86	91
\N	\N	IA1291-A	82.67	100	Aprovado	78	85	85
\N	\N	IA1292-A	79.00	97	Aprovado	70	84	83
\N	\N	IA1293-A	80.00	81	Aprovado	79	96	65
\N	\N	IA1294-A	79.00	77	Aprovado	85	63	89
\N	\N	IA1295-A	96.00	96	Aprovado	99	92	97
\N	\N	IA1296-A	84.00	77	Aprovado	82	78	92
\N	\N	IA1297-A	85.00	77	Aprovado	88	99	68
\N	\N	IA1298-A	79.67	90	Aprovado	88	83	68
\N	\N	IA1299-A	83.33	80	Aprovado	78	96	76
\N	\N	IA1300-A	80.67	77	Aprovado	88	70	84
\N	\N	IA1301-A	85.00	81	Aprovado	94	74	87
\N	\N	IA1302-A	78.67	95	Aprovado	87	87	62
\N	\N	IA1303-A	88.00	77	Aprovado	91	80	93
\N	\N	IA1304-A	78.67	80	Aprovado	100	73	63
\N	\N	IA1305-A	71.33	85	Aprovado	60	63	91
\N	\N	IA1306-A	72.33	98	Aprovado	78	67	72
\N	\N	IA1307-A	79.33	82	Aprovado	82	81	75
\N	\N	IA1308-A	72.00	91	Aprovado	63	61	92
\N	\N	IA1309-A	74.33	80	Aprovado	86	66	71
\N	\N	IA1310-A	69.00	78	Aprovado	69	61	77
\N	\N	IA1311-A	79.33	99	Aprovado	84	92	62
\N	\N	IA1312-A	81.67	97	Aprovado	84	79	82
\N	\N	IA1313-A	80.67	78	Aprovado	80	62	100
\N	\N	IA1314-A	79.67	87	Aprovado	77	80	82
\N	\N	IA1315-A	88.67	96	Aprovado	100	83	83
\N	\N	IA1316-A	87.33	99	Aprovado	97	74	91
\N	\N	IA1317-A	95.33	77	Aprovado	97	92	97
\N	\N	IA1318-A	93.00	99	Aprovado	93	86	100
\N	\N	IA1319-A	94.00	80	Aprovado	89	100	93
\N	\N	IA1320-A	82.67	85	Aprovado	95	90	63
\N	\N	IA1321-A	92.33	91	Aprovado	89	96	92
\N	\N	IA1322-A	70.67	87	Aprovado	79	70	63
\N	\N	IA1323-A	80.00	84	Aprovado	74	84	82
\N	\N	IA1324-A	73.00	76	Aprovado	72	87	60
\N	\N	IA1325-A	75.33	76	Aprovado	76	82	68
\N	\N	IA1326-A	78.33	97	Aprovado	96	69	70
\N	\N	IA1327-A	93.00	96	Aprovado	83	97	99
\N	\N	IA1328-A	80.00	84	Aprovado	81	82	77
\N	\N	IA1329-A	82.67	81	Aprovado	66	87	95
\N	\N	IA1330-A	81.00	99	Aprovado	90	88	65
\N	\N	IA1331-A	93.33	96	Aprovado	100	85	95
\N	\N	IA1332-A	81.33	88	Aprovado	75	70	99
\N	\N	IA1333-A	87.67	82	Aprovado	79	84	100
\N	\N	IA1334-A	81.33	87	Aprovado	73	77	94
\N	\N	IA1335-A	83.33	79	Aprovado	76	85	89
\N	\N	IA1336-A	94.67	81	Aprovado	94	99	91
\N	\N	IA1337-A	73.33	87	Aprovado	74	81	65
\N	\N	IA1338-A	82.33	88	Aprovado	76	81	90
\N	\N	IA1339-A	69.33	82	Aprovado	64	64	80
\N	\N	IA1340-A	76.33	90	Aprovado	94	64	71
\N	\N	IA1341-A	76.33	78	Aprovado	73	74	82
\N	\N	IA1342-A	82.33	95	Aprovado	92	72	83
\N	\N	IA1343-A	85.00	83	Aprovado	91	66	98
\N	\N	IA1344-A	79.00	86	Aprovado	76	65	96
\N	\N	IA1345-A	88.33	78	Aprovado	91	76	98
\N	\N	IA1346-A	65.67	92	Aprovado	64	62	71
\N	\N	IA1347-A	75.33	94	Aprovado	88	70	68
\N	\N	IA1348-A	76.33	76	Aprovado	70	83	76
\N	\N	IA1349-A	74.00	77	Aprovado	72	88	62
\N	\N	IA1350-A	84.00	98	Aprovado	87	67	98
\N	\N	IA1351-A	93.33	78	Aprovado	89	95	96
\N	\N	IA1352-A	77.00	82	Aprovado	68	79	84
\N	\N	IA1353-A	70.00	92	Aprovado	78	60	72
\N	\N	IA1354-A	64.00	93	Aprovado	64	68	60
\N	\N	IA1355-A	90.67	90	Aprovado	80	92	100
\N	\N	IA1356-A	75.67	91	Aprovado	78	78	71
\N	\N	IA1357-A	75.67	86	Aprovado	98	68	61
\N	\N	IA1358-A	84.67	79	Aprovado	99	63	92
\N	\N	IA1359-A	80.67	100	Aprovado	96	65	81
\N	\N	IA1360-A	91.33	82	Aprovado	78	100	96
\N	\N	IA1361-A	68.00	81	Aprovado	69	65	70
\N	\N	IA1362-A	87.00	91	Aprovado	65	97	99
\N	\N	IA1363-A	86.00	82	Aprovado	96	94	68
\N	\N	IA1364-A	75.33	77	Aprovado	84	68	74
\N	\N	IA1365-A	72.33	78	Aprovado	71	86	60
\N	\N	IA1366-A	79.33	79	Aprovado	76	69	93
\N	\N	IA1367-A	67.00	87	Aprovado	68	62	71
\N	\N	IA1368-A	97.33	77	Aprovado	97	98	97
\N	\N	IA1369-A	81.33	88	Aprovado	85	83	76
\N	\N	IA1370-A	78.00	79	Aprovado	78	94	62
\N	\N	IA1371-A	94.00	82	Aprovado	96	96	90
\N	\N	IA1372-A	87.00	94	Aprovado	89	88	84
\N	\N	IA1373-A	68.33	93	Aprovado	60	80	65
\N	\N	IA1374-A	79.33	90	Aprovado	79	96	63
\N	\N	IA1375-A	86.33	83	Aprovado	96	84	79
\N	\N	IA1376-A	81.00	96	Aprovado	69	94	80
\N	\N	IA1377-A	72.00	77	Aprovado	74	79	63
\N	\N	IA1378-A	82.33	93	Aprovado	85	90	72
\N	\N	IA1379-A	78.00	89	Aprovado	67	84	83
\N	\N	IA1380-A	83.67	78	Aprovado	83	94	74
\N	\N	IA1381-A	72.00	81	Aprovado	88	68	60
\N	\N	IA1382-A	91.33	100	Aprovado	92	93	89
\N	\N	IA1383-A	75.33	79	Aprovado	81	78	67
\N	\N	IA1384-A	92.33	83	Aprovado	97	87	93
\N	\N	IA1385-A	84.33	88	Aprovado	93	100	60
\N	\N	IA1386-A	73.33	100	Aprovado	67	62	91
\N	\N	IA1387-A	83.00	89	Aprovado	77	100	72
\N	\N	IA1388-A	89.67	94	Aprovado	100	85	84
\N	\N	IA1389-A	88.33	92	Aprovado	72	100	93
\N	\N	IA1390-A	78.00	89	Aprovado	78	94	62
\N	\N	IA1391-A	69.00	91	Aprovado	70	62	75
\N	\N	IA1392-A	73.00	75	Aprovado	73	75	71
\N	\N	IA1393-A	84.67	76	Aprovado	99	86	69
\N	\N	IA1394-A	84.33	88	Aprovado	77	83	93
\N	\N	IA1395-A	71.00	84	Aprovado	89	60	64
\N	\N	IA1396-A	84.00	78	Aprovado	95	80	77
\N	\N	IA1397-A	67.00	88	Aprovado	72	61	68
\N	\N	IA1398-A	75.33	88	Aprovado	73	65	88
\N	\N	IA1399-A	96.00	94	Aprovado	97	96	95
\N	\N	IA1400-A	71.33	83	Aprovado	66	73	75
\N	\N	IA1401-A	80.67	81	Aprovado	67	94	81
\N	\N	IA1402-A	89.67	85	Aprovado	86	97	86
\N	\N	IA1403-A	87.33	97	Aprovado	97	82	83
\N	\N	IA1404-A	86.67	84	Aprovado	98	88	74
\N	\N	IA1405-A	83.67	100	Aprovado	97	91	63
\N	\N	IA1406-A	82.00	98	Aprovado	93	63	90
\N	\N	IA1407-A	32.00	34	Reprovado	31	44	21
\N	\N	IA1408-A	10.33	96	Reprovado	26	1	4
\N	\N	IA1409-A	43.33	74	Reprovado	24	51	55
\N	\N	IA1410-A	20.67	49	Reprovado	14	38	10
\N	\N	IA1411-A	39.33	76	Reprovado	30	40	48
\N	\N	IA1412-A	41.33	39	Reprovado	55	57	12
\N	\N	IA1413-A	30.00	84	Reprovado	42	19	29
\N	\N	IA1414-A	39.33	89	Reprovado	15	52	51
\N	\N	IA1415-A	11.00	76	Reprovado	1	14	18
\N	\N	IA1416-A	34.67	70	Reprovado	55	20	29
\N	\N	IA1417-A	29.67	34	Reprovado	3	27	59
\N	\N	IA1418-A	20.33	42	Reprovado	18	9	34
\N	\N	IA1419-A	21.00	89	Reprovado	33	16	14
\N	\N	IA1420-A	35.67	76	Reprovado	25	31	51
\N	\N	IA1421-A	34.67	59	Reprovado	51	18	35
\N	\N	IA1422-A	32.00	64	Reprovado	19	34	43
\N	\N	IA1423-A	39.33	30	Reprovado	27	55	36
\N	\N	IA1424-A	36.00	66	Reprovado	15	38	55
\N	\N	IA1425-A	28.00	85	Reprovado	24	40	20
\N	\N	IA1426-A	27.67	47	Reprovado	37	0	46
\N	\N	IA1427-A	31.67	77	Reprovado	52	30	13
\N	\N	IA1428-A	39.00	33	Reprovado	5	57	55
\N	\N	IA1429-A	19.33	68	Reprovado	33	6	19
\N	\N	IA1430-A	30.67	52	Reprovado	29	42	21
\N	\N	IA1431-A	30.67	64	Reprovado	42	40	10
\N	\N	IA1432-A	33.00	74	Reprovado	59	4	36
\N	\N	IA1433-A	32.00	42	Reprovado	45	34	17
\N	\N	IA1434-A	21.33	34	Reprovado	52	2	10
\N	\N	IA1435-A	37.33	80	Reprovado	34	53	25
\N	\N	IA1436-A	30.00	53	Reprovado	48	9	33
\N	\N	IA1437-A	23.67	39	Reprovado	40	30	1
\N	\N	IA1438-A	33.67	64	Reprovado	12	59	30
\N	\N	IA1439-A	26.67	86	Reprovado	19	28	33
\N	\N	IA1440-A	36.67	43	Reprovado	26	54	30
\N	\N	IA1441-A	36.67	89	Reprovado	26	45	39
\N	\N	IA1442-A	36.33	100	Reprovado	1	56	52
\N	\N	IA1443-A	15.33	37	Reprovado	13	4	29
\N	\N	IA1444-A	38.67	57	Reprovado	33	57	26
\N	\N	IA1445-A	22.33	45	Reprovado	15	47	5
\N	\N	IA1446-A	35.67	75	Reprovado	26	44	37
\N	\N	IA1447-A	29.33	88	Reprovado	5	54	29
\N	\N	IA1448-A	36.67	87	Reprovado	30	28	52
\N	\N	IA1449-A	48.00	80	Reprovado	51	40	53
\N	\N	IA1450-A	33.00	65	Reprovado	26	14	59
\N	\N	IA1451-A	22.33	46	Reprovado	24	32	11
\N	\N	IA1452-A	31.67	64	Reprovado	34	26	35
\N	\N	IA1453-A	26.67	35	Reprovado	44	11	25
\N	\N	IA1454-A	31.33	79	Reprovado	50	7	37
\N	\N	IA1455-A	18.00	81	Reprovado	3	26	25
\N	\N	IA1456-A	28.00	79	Reprovado	48	36	0
\N	\N	IA1457-A	35.67	57	Reprovado	46	29	32
\N	\N	IA1458-A	38.33	71	Reprovado	50	35	30
\N	\N	IA1459-A	30.67	70	Reprovado	43	26	23
\N	\N	IA1460-A	21.67	50	Reprovado	1	10	54
\N	\N	IA1461-A	22.33	50	Reprovado	33	34	0
\N	\N	IA1462-A	40.67	58	Reprovado	25	42	55
\N	\N	IA1463-A	35.00	59	Reprovado	27	53	25
\N	\N	IA1464-A	29.67	99	Reprovado	44	7	38
\N	\N	IA1465-A	30.67	38	Reprovado	57	8	27
\N	\N	IA1466-A	28.33	49	Reprovado	17	9	59
\N	\N	IA1467-A	40.67	89	Reprovado	32	51	39
\N	\N	IA1468-A	34.67	73	Reprovado	39	41	24
\N	\N	IA1469-A	40.67	85	Reprovado	51	24	47
\N	\N	IA1470-A	27.67	74	Reprovado	11	18	54
\N	\N	IA1471-A	20.67	57	Reprovado	14	3	45
\N	\N	IA1472-A	25.67	61	Reprovado	44	26	7
\N	\N	IA1473-A	29.67	97	Reprovado	28	17	44
\N	\N	IA1474-A	35.67	37	Reprovado	30	33	44
\N	\N	IA1475-A	31.67	63	Reprovado	48	11	36
\N	\N	IA1476-A	27.67	70	Reprovado	6	55	22
\N	\N	IA1477-A	51.33	100	Reprovado	55	42	57
\N	\N	IA1478-A	32.67	100	Reprovado	39	51	8
\N	\N	IA1479-A	27.67	78	Reprovado	50	4	29
\N	\N	IA1480-A	37.00	50	Reprovado	10	57	44
\N	\N	IA1481-A	36.00	76	Reprovado	58	38	12
\N	\N	IA1482-A	35.00	35	Reprovado	43	32	30
\N	\N	IA1483-A	29.33	52	Reprovado	39	30	19
\N	\N	IA1484-A	33.00	93	Reprovado	55	12	32
\N	\N	IA1485-A	34.33	89	Reprovado	1	58	44
\N	\N	IA1486-A	46.33	61	Reprovado	50	59	30
\N	\N	IA1487-A	22.33	58	Reprovado	53	4	10
\N	\N	IA1488-A	49.33	34	Reprovado	55	55	38
\N	\N	IA1489-A	18.67	97	Reprovado	32	20	4
\N	\N	IA1490-A	25.33	55	Reprovado	37	34	5
\N	\N	IA1491-A	41.33	61	Reprovado	8	58	58
\N	\N	IA1492-A	27.33	79	Reprovado	27	21	34
\N	\N	IA1493-A	28.33	32	Reprovado	37	26	22
\N	\N	IA1494-A	35.33	68	Reprovado	52	6	48
\N	\N	IA1495-A	16.00	59	Reprovado	22	8	18
\N	\N	IA1496-A	41.33	99	Reprovado	51	43	30
\N	\N	IA1497-A	37.67	52	Reprovado	54	35	24
\N	\N	IA1498-A	44.67	87	Reprovado	36	42	56
\N	\N	IA1499-A	37.67	43	Reprovado	37	24	52
\N	\N	IA1500-A	29.67	95	Reprovado	14	57	18
\N	\N	IA1501-A	30.67	80	Reprovado	15	21	56
\N	\N	IA1502-A	33.00	55	Reprovado	48	3	48
\N	\N	IA1503-A	27.67	87	Reprovado	1	27	55
\N	\N	IA1504-A	29.00	93	Reprovado	1	42	44
\N	\N	IA1505-A	30.67	34	Reprovado	19	40	33
\N	\N	IA1506-A	22.00	65	Reprovado	38	9	19
\N	\N	IA1507-A	28.33	61	Reprovado	3	55	27
\N	\N	IA1508-A	42.67	81	Reprovado	43	54	31
\N	\N	IA1509-A	35.67	67	Reprovado	49	35	23
\N	\N	IA1510-A	31.67	84	Reprovado	48	9	38
\N	\N	IA1511-A	4.00	94	Reprovado	1	6	5
\N	\N	IA1512-A	24.00	31	Reprovado	12	4	56
\N	\N	IA1513-A	11.33	30	Reprovado	13	2	19
\N	\N	IA1514-A	24.67	61	Reprovado	8	22	44
\N	\N	IA1515-A	23.00	94	Reprovado	44	13	12
\N	\N	IA1516-A	36.67	74	Reprovado	32	19	59
\N	\N	IA1517-A	50.67	51	Reprovado	40	57	55
\N	\N	IA1518-A	25.00	39	Reprovado	45	22	8
\N	\N	IA1519-A	19.00	44	Reprovado	14	14	29
\N	\N	IA1520-A	27.00	39	Reprovado	24	28	29
\N	\N	IA1521-A	16.00	72	Reprovado	0	46	2
\N	\N	IA1522-A	46.67	91	Reprovado	36	59	45
\N	\N	IA1523-A	25.00	34	Reprovado	4	54	17
\N	\N	IA1524-A	36.33	74	Reprovado	10	50	49
\N	\N	IA1525-A	32.33	43	Reprovado	45	9	43
\N	\N	IA1526-A	11.00	79	Reprovado	21	9	3
\N	\N	IA1527-A	31.00	72	Reprovado	27	27	39
\N	\N	IA1528-A	25.67	86	Reprovado	28	42	7
\N	\N	IA1529-A	21.00	55	Reprovado	6	33	24
\N	\N	IA1530-A	11.33	78	Reprovado	25	6	3
\N	\N	IA1531-A	27.33	79	Reprovado	48	18	16
\N	\N	IA1532-A	13.33	40	Reprovado	10	29	1
\N	\N	IA1533-A	29.33	35	Reprovado	11	41	36
\N	\N	IA1534-A	26.67	37	Reprovado	22	16	42
\N	\N	IA1535-A	29.33	69	Reprovado	37	22	29
\N	\N	IA1536-A	21.67	74	Reprovado	28	7	30
\N	\N	IA1537-A	43.33	77	Reprovado	32	53	45
\N	\N	IA1538-A	22.67	89	Reprovado	14	38	16
\N	\N	IA1539-A	29.33	39	Reprovado	44	27	17
\N	\N	IA1540-A	29.67	43	Reprovado	47	13	29
\N	\N	IA1541-A	18.00	44	Reprovado	35	10	9
\N	\N	IA1542-A	35.33	91	Reprovado	38	39	29
\N	\N	IA1543-A	27.33	65	Reprovado	34	18	30
\N	\N	IA1544-A	33.67	58	Reprovado	41	32	28
\N	\N	IA1545-A	28.67	87	Reprovado	25	7	54
\N	\N	IA1546-A	31.00	34	Reprovado	20	57	16
\N	\N	IA1547-A	25.67	68	Reprovado	19	54	4
\N	\N	IA1548-A	45.67	79	Reprovado	47	55	35
\N	\N	IA1549-A	43.33	59	Reprovado	50	40	40
\N	\N	IA1550-A	31.67	61	Reprovado	25	53	17
\N	\N	IA1551-A	38.67	99	Reprovado	34	38	44
\N	\N	IA1552-A	27.00	97	Reprovado	4	53	24
\N	\N	IA1553-A	41.33	41	Reprovado	57	21	46
\N	\N	IA1554-A	34.33	90	Reprovado	40	26	37
\N	\N	IA1555-A	38.00	52	Reprovado	51	52	11
\N	\N	IA1556-A	18.33	70	Reprovado	33	16	6
\N	\N	IA1557-A	36.33	86	Reprovado	9	44	56
\N	\N	IA1558-A	39.00	38	Reprovado	57	27	33
\N	\N	IA1559-A	32.00	43	Reprovado	50	43	3
\N	\N	IA1560-A	17.33	35	Reprovado	14	13	25
\N	\N	IA1561-A	28.33	32	Reprovado	41	35	9
\N	\N	IA1562-A	31.67	63	Reprovado	23	59	13
\N	\N	IA1563-A	32.00	58	Reprovado	38	28	30
\N	\N	IA1564-A	36.33	34	Reprovado	38	49	22
\N	\N	IA1565-A	32.67	83	Reprovado	14	40	44
\N	\N	IA1566-A	15.33	88	Reprovado	12	34	0
\N	\N	IA1567-A	46.00	97	Reprovado	51	42	45
\N	\N	IA1568-A	11.67	98	Reprovado	19	13	3
\N	\N	IA1569-A	15.33	81	Reprovado	16	16	14
\N	\N	IA1570-A	25.00	95	Reprovado	28	7	40
\N	\N	IA1571-A	35.67	84	Reprovado	43	49	15
\N	\N	IA1572-A	27.67	76	Reprovado	11	38	34
\N	\N	IA1573-A	34.00	90	Reprovado	44	52	6
\N	\N	IA1574-A	26.00	58	Reprovado	49	28	1
\N	\N	IA1575-A	44.00	57	Reprovado	57	52	23
\N	\N	IA1576-A	19.67	56	Reprovado	41	6	12
\N	\N	IA1577-A	23.00	53	Reprovado	16	3	50
\N	\N	IA1578-A	21.00	43	Reprovado	36	9	18
\N	\N	IA1579-A	15.67	51	Reprovado	25	15	7
\N	\N	IA1580-A	23.67	37	Reprovado	23	27	21
\N	\N	IA1581-A	29.00	39	Reprovado	31	8	48
\N	\N	IA1582-A	32.67	30	Reprovado	48	21	29
MAT04482	ALU0747	IA706-B	80.33	98	Aprovado	85	86	70
MAT01856	ALU0310	IA502-B	86.00	94	Aprovado	89	90	79
\N	\N	IA1583-A	19.00	83	Reprovado	0	47	10
\N	\N	IA1584-A	33.67	89	Reprovado	55	20	26
\N	\N	IA1585-A	36.00	64	Reprovado	59	47	2
\N	\N	IA1586-A	14.00	89	Reprovado	0	19	23
\N	\N	IA1587-A	28.00	74	Reprovado	34	34	16
\N	\N	IA1588-A	36.67	86	Reprovado	42	41	27
\N	\N	IA1589-A	29.00	31	Reprovado	26	4	57
\N	\N	IA1590-A	37.67	97	Reprovado	48	23	42
\N	\N	IA1591-A	49.67	55	Reprovado	54	44	51
\N	\N	IA1592-A	26.00	57	Reprovado	23	15	40
\N	\N	IA1593-A	37.33	68	Reprovado	22	41	49
\N	\N	IA1594-A	30.33	93	Reprovado	45	2	44
\N	\N	IA1595-A	44.00	77	Reprovado	27	46	59
\N	\N	IA1596-A	26.00	68	Reprovado	1	48	29
\N	\N	IA1597-A	34.33	95	Reprovado	53	1	49
\N	\N	IA1598-A	43.00	61	Reprovado	34	38	57
\N	\N	IA1599-A	28.67	56	Reprovado	51	22	13
\N	\N	IA1600-A	29.67	47	Reprovado	24	40	25
\N	\N	IA1601-A	44.00	63	Reprovado	32	58	42
\N	\N	IA1602-A	26.33	96	Reprovado	33	20	26
\N	\N	IA1603-A	27.33	72	Reprovado	26	52	4
\N	\N	IA1604-A	27.33	53	Reprovado	37	21	24
\N	\N	IA1605-A	32.00	78	Reprovado	37	53	6
\N	\N	IA1606-A	30.67	65	Reprovado	16	34	42
\N	\N	IA1607-A	12.33	79	Reprovado	28	5	4
\N	\N	IA1608-A	37.33	68	Reprovado	28	31	53
\N	\N	IA1609-A	30.00	70	Reprovado	30	43	17
\N	\N	IA1610-A	50.67	86	Reprovado	51	42	59
\N	\N	IA1611-A	39.33	40	Reprovado	35	42	41
\N	\N	IA1612-A	35.00	35	Reprovado	50	25	30
\N	\N	IA1613-A	29.00	37	Reprovado	55	17	15
\N	\N	IA1614-A	14.33	87	Reprovado	6	25	12
\N	\N	IA1615-A	10.67	71	Reprovado	19	5	8
\N	\N	IA1616-A	44.33	52	Reprovado	48	33	52
\N	\N	IA1617-A	14.33	63	Reprovado	23	14	6
\N	\N	IA1618-A	22.33	68	Reprovado	3	32	32
\N	\N	IA1619-A	25.33	80	Reprovado	48	12	16
\N	\N	IA1620-A	30.33	88	Reprovado	31	26	34
\N	\N	IA1621-A	43.33	75	Reprovado	51	22	57
\N	\N	IA1622-A	25.67	90	Reprovado	40	8	29
\N	\N	IA1623-A	30.00	88	Reprovado	43	37	10
\N	\N	IA1624-A	47.00	81	Reprovado	57	49	35
\N	\N	IA1625-A	36.00	84	Reprovado	49	36	23
\N	\N	IA1626-A	18.00	91	Reprovado	5	14	35
\N	\N	IA1627-A	23.67	70	Reprovado	16	2	53
\N	\N	IA1628-A	27.33	54	Reprovado	39	13	30
\N	\N	IA1629-A	27.00	43	Reprovado	26	6	49
\N	\N	IA1630-A	20.33	57	Reprovado	46	10	5
\N	\N	IA1631-A	20.33	66	Reprovado	27	1	33
\N	\N	IA1632-A	28.00	57	Reprovado	5	54	25
\N	\N	IA1633-A	27.00	73	Reprovado	26	28	27
\N	\N	IA1634-A	8.67	81	Reprovado	5	13	8
\N	\N	IA1635-A	29.00	43	Reprovado	10	47	30
\N	\N	IA1636-A	22.00	41	Reprovado	12	43	11
\N	\N	IA1637-A	40.33	98	Reprovado	28	45	48
\N	\N	IA1638-A	39.33	93	Reprovado	33	33	52
\N	\N	IA1639-A	14.67	33	Reprovado	5	13	26
\N	\N	IA1640-A	20.33	52	Reprovado	46	7	8
\N	\N	IA1641-A	21.00	70	Reprovado	26	27	10
\N	\N	IA1642-A	31.33	97	Reprovado	13	48	33
\N	\N	IA1643-A	28.00	51	Reprovado	23	16	45
\N	\N	IA1644-A	16.67	46	Reprovado	5	26	19
\N	\N	IA1645-A	48.67	91	Reprovado	33	55	58
\N	\N	IA1646-A	23.00	49	Reprovado	40	4	25
\N	\N	IA1647-A	47.67	75	Reprovado	36	48	59
\N	\N	IA1648-A	13.33	87	Reprovado	2	18	20
\N	\N	IA1649-A	15.33	62	Reprovado	2	40	4
\N	\N	IA1650-A	20.33	43	Reprovado	5	4	52
\N	\N	IA1651-A	44.00	45	Reprovado	42	52	38
\N	\N	IA1652-A	19.67	67	Reprovado	10	28	21
\N	\N	IA1653-A	19.67	46	Reprovado	18	21	20
\N	\N	IA1654-A	37.00	89	Reprovado	24	31	56
\N	\N	IA1655-A	19.00	79	Reprovado	17	38	2
\N	\N	IA1656-A	25.67	39	Reprovado	31	17	29
\N	\N	IA1657-A	19.33	69	Reprovado	30	8	20
\N	\N	IA1658-A	32.67	55	Reprovado	41	15	42
\N	\N	IA1659-A	8.67	33	Reprovado	12	12	2
\N	\N	IA1660-A	27.00	92	Reprovado	22	51	8
\N	\N	IA1661-A	7.33	42	Reprovado	10	8	4
\N	\N	IA1662-A	34.67	41	Reprovado	34	38	32
\N	\N	IA1663-A	49.67	49	Reprovado	55	47	47
\N	\N	IA1664-A	36.00	100	Reprovado	22	54	32
\N	\N	IA1665-A	37.33	66	Reprovado	49	55	8
\N	\N	IA1666-A	14.33	66	Reprovado	10	11	22
\N	\N	IA1667-A	16.67	70	Reprovado	32	7	11
\N	\N	IA1668-A	46.33	60	Reprovado	38	56	45
\N	\N	IA1669-A	44.00	58	Reprovado	38	44	50
\N	\N	IA1670-A	46.00	68	Reprovado	45	47	46
\N	\N	IA1671-A	15.00	40	Reprovado	9	33	3
\N	\N	IA1672-A	31.67	57	Reprovado	41	15	39
\N	\N	IA1673-A	40.00	64	Reprovado	18	45	57
\N	\N	IA1674-A	8.00	78	Reprovado	2	3	19
\N	\N	IA1675-A	46.00	67	Reprovado	45	55	38
\N	\N	IA1676-A	49.00	43	Reprovado	59	50	38
MAT05952	ALU0992	IA306-A	87.33	87	Aprovado	93	100	69
MAT03133	ALU0523	IA501-B	77.00	83	Aprovado	65	66	100
MAT03148	ALU0525	IA804-A	84.00	94	Aprovado	82	88	82
MAT03135	ALU0523	IA503-B	32.00	75	Reprovado	41	42	13
MAT05126	ALU0855	IA402-B	43.00	67	Reprovado	59	34	36
MAT02797	ALU0467	IA301-B	15.67	38	Reprovado	12	10	25
MAT03130	ALU0522	IA404-B	35.00	68	Reprovado	53	47	5
MAT02307	ALU0385	IA503-B	25.00	74	Reprovado	35	39	1
MAT01522	ALU0254	IA604-A	20.00	30	Reprovado	23	15	22
MAT04317	ALU0720	IA703-B	34.33	60	Reprovado	35	53	15
MAT01477	ALU0247	IA201-B	31.00	88	Reprovado	30	57	6
MAT03928	ALU0655	IA804-A	25.33	83	Reprovado	20	36	20
MAT03158	ALU0527	IA202-A	53.67	37	Reprovado	46	58	57
MAT04387	ALU0732	IA301-A	18.67	65	Reprovado	21	31	4
MAT02287	ALU0382	IA201-A	12.33	47	Reprovado	8	13	16
MAT03154	ALU0526	IA504-B	30.67	76	Reprovado	35	12	45
MAT00451	ALU0076	IA801-B	15.33	70	Reprovado	3	32	11
MAT05055	ALU0843	IA703-B	21.00	98	Reprovado	12	37	14
MAT02066	ALU0345	IA702-A	26.67	86	Reprovado	54	21	5
MAT02550	ALU0425	IA806-B	31.33	66	Reprovado	39	15	40
MAT02912	ALU0486	IA402-A	16.67	36	Reprovado	31	19	0
MAT02656	ALU0443	IA104-A	30.00	48	Reprovado	31	51	8
MAT00516	ALU0086	IA806-A	34.00	62	Reprovado	52	29	21
\N	\N	IA1677-A	19.33	61	Reprovado	4	50	4
\N	\N	IA1678-A	12.33	50	Reprovado	19	9	9
\N	\N	IA1679-A	30.67	86	Reprovado	46	23	23
\N	\N	IA1680-A	36.33	86	Reprovado	41	59	9
\N	\N	IA1681-A	40.00	63	Reprovado	49	50	21
\N	\N	IA1682-A	11.00	86	Reprovado	4	23	6
\N	\N	IA1683-A	36.00	48	Reprovado	44	48	16
\N	\N	IA1684-A	28.33	33	Reprovado	15	57	13
\N	\N	IA1685-A	24.00	93	Reprovado	4	13	55
\N	\N	IA1686-A	7.67	48	Reprovado	5	3	15
\N	\N	IA1687-A	16.33	88	Reprovado	1	32	16
\N	\N	IA1688-A	26.00	39	Reprovado	6	30	42
\N	\N	IA1689-A	24.00	45	Reprovado	49	8	15
\N	\N	IA1690-A	33.67	75	Reprovado	29	47	25
\N	\N	IA1691-A	34.33	88	Reprovado	29	41	33
\N	\N	IA1692-A	45.00	84	Reprovado	47	35	53
\N	\N	IA1693-A	36.00	58	Reprovado	55	12	41
\N	\N	IA1694-A	43.67	50	Reprovado	21	52	58
\N	\N	IA1695-A	26.67	49	Reprovado	20	44	16
\N	\N	IA1696-A	25.33	97	Reprovado	28	35	13
\N	\N	IA1697-A	16.00	73	Reprovado	18	5	25
\N	\N	IA1698-A	46.33	36	Reprovado	27	58	54
\N	\N	IA1699-A	25.67	76	Reprovado	16	41	20
\N	\N	IA1700-A	20.33	39	Reprovado	18	1	42
\N	\N	IA1701-A	41.00	42	Reprovado	46	42	35
\N	\N	IA1702-A	38.00	34	Reprovado	34	26	54
\N	\N	IA1703-A	42.00	36	Reprovado	34	54	38
\N	\N	IA1704-A	43.00	73	Reprovado	34	52	43
\N	\N	IA1705-A	21.67	50	Reprovado	18	32	15
\N	\N	IA1706-A	24.33	48	Reprovado	30	17	26
\N	\N	IA1707-A	23.33	71	Reprovado	37	8	25
\N	\N	IA1708-A	49.67	90	Reprovado	49	54	46
\N	\N	IA1709-A	20.67	56	Reprovado	16	15	31
\N	\N	IA1710-A	40.33	91	Reprovado	17	46	58
\N	\N	IA1711-A	20.33	43	Reprovado	5	3	53
\N	\N	IA1712-A	33.00	81	Reprovado	32	56	11
\N	\N	IA1713-A	45.67	68	Reprovado	57	53	27
\N	\N	IA1714-A	21.67	99	Reprovado	54	5	6
\N	\N	IA1715-A	27.67	62	Reprovado	14	40	29
\N	\N	IA1716-A	35.67	50	Reprovado	44	19	44
\N	\N	IA1717-A	19.33	63	Reprovado	9	3	46
\N	\N	IA1718-A	24.67	97	Reprovado	4	43	27
\N	\N	IA1719-A	21.00	63	Reprovado	7	45	11
\N	\N	IA1720-A	38.00	36	Reprovado	6	59	49
\N	\N	IA1721-A	22.33	94	Reprovado	35	19	13
\N	\N	IA1722-A	36.33	45	Reprovado	46	52	11
\N	\N	IA1723-A	26.33	71	Reprovado	9	39	31
\N	\N	IA1724-A	24.00	95	Reprovado	54	9	9
\N	\N	IA1725-A	19.67	78	Reprovado	32	9	18
\N	\N	IA1726-A	47.67	68	Reprovado	51	34	58
\N	\N	IA1727-A	35.67	99	Reprovado	59	30	18
\N	\N	IA1728-A	23.00	93	Reprovado	13	51	5
\N	\N	IA1729-A	31.67	99	Reprovado	10	49	36
\N	\N	IA1730-A	15.67	93	Reprovado	0	19	28
\N	\N	IA1731-A	31.33	94	Reprovado	12	26	56
\N	\N	IA1732-A	21.00	77	Reprovado	26	4	33
\N	\N	IA1733-A	15.33	81	Reprovado	8	9	29
\N	\N	IA1734-A	28.67	45	Reprovado	35	47	4
\N	\N	IA1735-A	30.67	86	Reprovado	35	19	38
\N	\N	IA1736-A	27.00	99	Reprovado	58	13	10
\N	\N	IA1737-A	28.67	79	Reprovado	40	23	23
\N	\N	IA1738-A	17.00	76	Reprovado	22	29	0
\N	\N	IA1739-A	18.00	37	Reprovado	0	35	19
\N	\N	IA1740-A	21.33	61	Reprovado	34	4	26
\N	\N	IA1741-A	48.33	70	Reprovado	44	48	53
\N	\N	IA1742-A	28.00	92	Reprovado	11	25	48
\N	\N	IA1743-A	33.00	60	Reprovado	32	44	23
\N	\N	IA1744-A	16.33	50	Reprovado	9	16	24
\N	\N	IA1745-A	39.00	44	Reprovado	20	51	46
\N	\N	IA1746-A	52.67	87	Reprovado	59	55	44
MAT03166	ALU0528	IA304-B	68.33	81	Aprovado	69	67	69
MAT03251	ALU0542	IA405-B	71.67	98	Aprovado	64	61	90
MAT03197	ALU0533	IA705-B	80.00	80	Aprovado	74	88	78
MAT03244	ALU0541	IA604-A	86.00	86	Aprovado	98	98	62
MAT03194	ALU0533	IA702-B	82.00	96	Aprovado	89	65	92
MAT03193	ALU0533	IA701-B	79.33	83	Aprovado	70	87	81
MAT04123	ALU0688	IA301-B	76.33	80	Aprovado	76	82	71
MAT03170	ALU0529	IA202-B	20.33	76	Reprovado	14	45	2
MAT02406	ALU0401	IA306-A	9.67	57	Reprovado	19	4	6
MAT03226	ALU0538	IA204-A	33.33	30	Reprovado	45	14	41
MAT03236	ALU0540	IA402-A	35.67	40	Reprovado	41	59	7
MAT04430	ALU0739	IA102-A	25.00	38	Reprovado	54	19	2
MAT03250	ALU0542	IA404-B	24.00	50	Reprovado	51	1	20
MAT03196	ALU0533	IA704-B	37.33	74	Reprovado	7	47	58
MAT01306	ALU0218	IA404-B	30.33	42	Reprovado	27	21	43
MAT03240	ALU0540	IA406-A	22.67	90	Reprovado	2	15	51
\N	\N	IA1747-A	42.33	34	Reprovado	39	53	35
MAT01334	ALU0223	IA402-B	13.67	95	Reprovado	1	16	24
MAT00704	ALU0118	IA802-B	41.67	98	Reprovado	55	57	13
MAT03215	ALU0536	IA305-B	21.00	62	Reprovado	57	1	5
MAT03239	ALU0540	IA405-A	37.33	88	Reprovado	44	26	42
MAT03252	ALU0542	IA406-B	29.33	43	Reprovado	26	51	11
MAT01915	ALU0320	IA701-B	21.67	84	Reprovado	14	29	22
MAT03212	ALU0536	IA302-B	16.33	53	Reprovado	13	23	13
MAT03165	ALU0528	IA303-B	25.67	80	Reprovado	25	5	47
MAT03214	ALU0536	IA304-B	35.33	71	Reprovado	36	31	39
MAT04234	ALU0706	IA704-B	28.67	97	Reprovado	6	24	56
MAT03253	ALU0543	IA201-A	39.67	49	Reprovado	56	58	5
MAT03195	ALU0533	IA703-B	42.00	86	Reprovado	34	38	54
MAT05308	ALU0885	IA204-B	30.33	98	Reprovado	34	39	18
MAT03248	ALU0542	IA402-B	32.67	33	Reprovado	33	23	42
MAT02126	ALU0355	IA502-B	19.67	50	Reprovado	8	0	51
MAT03223	ALU0538	IA201-A	28.00	53	Reprovado	18	42	24
MAT03232	ALU0539	IA704-B	36.33	95	Reprovado	49	44	16
MAT03229	ALU0539	IA701-B	35.33	91	Reprovado	13	37	56
MAT03249	ALU0542	IA403-B	35.33	95	Reprovado	55	11	40
MAT03167	ALU0528	IA305-B	35.67	64	Reprovado	34	47	26
MAT03231	ALU0539	IA703-B	25.33	67	Reprovado	31	41	4
MAT03228	ALU0538	IA206-A	31.00	59	Reprovado	32	56	5
MAT03233	ALU0539	IA705-B	32.00	38	Reprovado	24	20	52
MAT03163	ALU0528	IA301-B	35.67	46	Reprovado	45	20	42
MAT03198	ALU0533	IA706-B	36.67	77	Reprovado	33	49	28
MAT03224	ALU0538	IA202-A	22.33	48	Reprovado	1	21	45
\N	\N	IA1748-A	23.33	59	Reprovado	30	9	31
\N	\N	IA1749-A	22.33	46	Reprovado	14	23	30
\N	\N	IA1750-A	28.67	80	Reprovado	56	26	4
\N	\N	IA1751-A	40.33	89	Reprovado	51	48	22
\N	\N	IA1752-A	22.67	46	Reprovado	9	36	23
\N	\N	IA1753-A	11.00	39	Reprovado	15	3	15
\N	\N	IA1754-A	36.00	83	Reprovado	25	33	50
\N	\N	IA1755-A	36.00	73	Reprovado	44	43	21
\N	\N	IA1756-A	34.33	59	Reprovado	55	33	15
\N	\N	IA1757-A	19.00	89	Reprovado	38	17	2
\N	\N	IA1758-A	42.00	51	Reprovado	35	47	44
\N	\N	IA1759-A	42.67	37	Reprovado	50	40	38
\N	\N	IA1760-A	50.67	78	Reprovado	37	59	56
\N	\N	IA1761-A	37.67	43	Reprovado	49	45	19
\N	\N	IA1762-A	39.33	74	Reprovado	40	48	30
\N	\N	IA1763-A	11.00	41	Reprovado	6	26	1
\N	\N	IA1764-A	29.67	30	Reprovado	46	16	27
\N	\N	IA1765-A	26.00	85	Reprovado	37	31	10
\N	\N	IA1766-A	31.00	86	Reprovado	42	23	28
\N	\N	IA1767-A	30.33	92	Reprovado	2	55	34
\N	\N	IA1768-A	25.00	65	Reprovado	19	40	16
\N	\N	IA1769-A	52.00	93	Reprovado	58	45	53
\N	\N	IA1770-A	37.67	94	Reprovado	56	25	32
\N	\N	IA1771-A	33.33	45	Reprovado	51	11	38
\N	\N	IA1772-A	22.00	73	Reprovado	30	7	29
\N	\N	IA1773-A	29.00	81	Reprovado	24	13	50
\N	\N	IA1774-A	30.00	52	Reprovado	42	40	8
\N	\N	IA1775-A	28.33	39	Reprovado	24	19	42
\N	\N	IA1776-A	40.67	72	Reprovado	41	41	40
\N	\N	IA1777-A	50.33	74	Reprovado	57	40	54
\N	\N	IA1778-A	35.33	64	Reprovado	41	23	42
\N	\N	IA1779-A	14.00	63	Reprovado	12	22	8
\N	\N	IA1780-A	37.67	85	Reprovado	43	24	46
\N	\N	IA1781-A	17.67	32	Reprovado	13	18	22
\N	\N	IA1782-A	17.00	55	Reprovado	17	29	5
\N	\N	IA1783-A	36.00	69	Reprovado	50	4	54
\N	\N	IA1784-A	44.33	69	Reprovado	22	59	52
\N	\N	IA1785-A	28.33	95	Reprovado	31	5	49
\N	\N	IA1786-A	32.33	68	Reprovado	37	41	19
\N	\N	IA1787-A	23.33	98	Reprovado	38	31	1
\N	\N	IA1788-A	32.33	71	Reprovado	36	43	18
\N	\N	IA1789-A	21.33	74	Reprovado	39	4	21
\N	\N	IA1790-A	27.33	49	Reprovado	36	8	38
\N	\N	IA1791-A	30.33	99	Reprovado	21	42	28
\N	\N	IA1792-A	41.00	86	Reprovado	59	34	30
\N	\N	IA1793-A	39.67	30	Reprovado	16	49	54
\N	\N	IA1807-A	82.00	80	Aprovado	95	72	79
\N	\N	IA1808-A	81.33	78	Aprovado	62	87	95
MAT03341	ALU0557	IA405-B	88.00	85	Aprovado	92	80	92
MAT03349	ALU0559	IA401-A	81.00	85	Aprovado	66	83	94
MAT02672	ALU0446	IA202-B	43.33	77	Reprovado	22	57	51
MAT03340	ALU0557	IA404-B	37.67	86	Reprovado	59	24	30
MAT01808	ALU0302	IA802-B	33.33	84	Reprovado	26	43	31
MAT01123	ALU0188	IA801-B	13.00	83	Reprovado	0	33	6
MAT03289	ALU0549	IA101-B	18.33	95	Reprovado	33	11	11
MAT03327	ALU0555	IA303-B	35.33	73	Reprovado	14	57	35
MAT01640	ALU0274	IA202-A	40.67	73	Reprovado	32	48	42
MAT03339	ALU0557	IA403-B	24.33	72	Reprovado	26	40	7
MAT03022	ALU0504	IA504-B	22.33	68	Reprovado	26	6	35
MAT03302	ALU0551	IA402-B	19.33	79	Reprovado	5	20	33
MAT03293	ALU0549	IA105-B	27.33	44	Reprovado	2	40	40
MAT03303	ALU0551	IA403-B	27.00	70	Reprovado	35	34	12
MAT00695	ALU0116	IA705-A	31.33	37	Reprovado	31	53	10
MAT03292	ALU0549	IA104-B	35.67	69	Reprovado	39	9	59
MAT03285	ALU0548	IA103-B	19.67	70	Reprovado	17	32	10
MAT05170	ALU0862	IA504-B	31.33	76	Reprovado	15	46	33
MAT03337	ALU0557	IA401-B	23.00	79	Reprovado	26	11	32
MAT03314	ALU0553	IA802-A	10.33	32	Reprovado	7	5	19
MAT03301	ALU0551	IA401-B	41.00	73	Reprovado	55	11	57
MAT03271	ALU0546	IA201-B	27.00	75	Reprovado	54	0	27
MAT03260	ALU0544	IA502-A	34.33	75	Reprovado	55	17	31
MAT02472	ALU0412	IA606-B	35.33	71	Reprovado	54	41	11
MAT04298	ALU0717	IA102-B	20.33	54	Reprovado	7	2	52
MAT02890	ALU0482	IA804-B	28.67	77	Reprovado	44	42	0
MAT03316	ALU0553	IA804-A	33.67	52	Reprovado	28	34	39
MAT03320	ALU0554	IA302-B	23.33	49	Reprovado	13	19	38
MAT03294	ALU0549	IA106-B	43.33	74	Reprovado	40	49	41
MAT03306	ALU0551	IA406-B	41.33	50	Reprovado	39	40	45
MAT03305	ALU0551	IA405-B	18.00	80	Reprovado	12	21	21
MAT03318	ALU0553	IA806-A	34.00	45	Reprovado	57	39	6
MAT03290	ALU0549	IA102-B	48.00	94	Reprovado	54	44	46
MAT03238	ALU0540	IA404-A	37.00	33	Reprovado	24	41	46
MAT03310	ALU0552	IA404-B	54.33	55	Reprovado	57	56	50
MAT03273	ALU0546	IA203-B	23.33	45	Reprovado	23	47	0
MAT03334	ALU0556	IA604-B	32.67	48	Reprovado	31	46	21
MAT03298	ALU0550	IA504-A	26.00	55	Reprovado	51	22	5
MAT02893	ALU0483	IA501-B	42.00	96	Reprovado	25	48	53
MAT03274	ALU0546	IA204-B	29.67	65	Reprovado	0	43	46
\N	\N	IA1809-A	75.67	98	Aprovado	72	73	82
\N	\N	IA1810-A	76.33	89	Aprovado	81	68	80
\N	\N	IA1811-A	78.33	98	Aprovado	78	88	69
\N	\N	IA1812-A	83.67	81	Aprovado	82	83	86
\N	\N	IA1813-A	95.00	82	Aprovado	96	94	95
\N	\N	IA1814-A	85.33	91	Aprovado	83	73	100
\N	\N	IA1815-A	73.00	91	Aprovado	87	71	61
\N	\N	IA1816-A	79.00	99	Aprovado	84	75	78
\N	\N	IA1817-A	80.67	99	Aprovado	80	82	80
\N	\N	IA1818-A	72.00	77	Aprovado	74	66	76
\N	\N	IA1819-A	73.67	85	Aprovado	65	71	85
\N	\N	IA1820-A	75.67	80	Aprovado	62	69	96
\N	\N	IA1821-A	67.00	83	Aprovado	67	73	61
\N	\N	IA1822-A	88.67	88	Aprovado	79	92	95
\N	\N	IA1823-A	78.67	84	Aprovado	85	69	82
\N	\N	IA1824-A	70.67	88	Aprovado	63	69	80
\N	\N	IA1825-A	88.33	90	Aprovado	95	83	87
\N	\N	IA1826-A	73.67	84	Aprovado	62	85	74
\N	\N	IA1827-A	74.67	87	Aprovado	78	74	72
\N	\N	IA1828-A	84.33	87	Aprovado	97	95	61
\N	\N	IA1829-A	88.33	81	Aprovado	99	68	98
\N	\N	IA1830-A	85.33	83	Aprovado	100	64	92
\N	\N	IA1831-A	91.00	78	Aprovado	84	95	94
\N	\N	IA1832-A	72.00	98	Aprovado	73	74	69
\N	\N	IA1833-A	93.00	78	Aprovado	90	97	92
\N	\N	IA1834-A	68.00	94	Aprovado	73	66	65
\N	\N	IA1835-A	90.00	89	Aprovado	96	85	89
\N	\N	IA1836-A	88.33	76	Aprovado	66	99	100
\N	\N	IA1837-A	87.00	83	Aprovado	91	99	71
\N	\N	IA1838-A	84.33	99	Aprovado	84	87	82
\N	\N	IA1839-A	84.33	92	Aprovado	97	74	82
\N	\N	IA1840-A	75.67	91	Aprovado	85	75	67
\N	\N	IA1841-A	67.33	77	Aprovado	68	66	68
\N	\N	IA1842-A	83.00	89	Aprovado	86	94	69
\N	\N	IA1843-A	87.00	99	Aprovado	80	96	85
\N	\N	IA1844-A	87.33	100	Aprovado	94	70	98
\N	\N	IA1845-A	83.67	91	Aprovado	95	82	74
\N	\N	IA1846-A	97.00	80	Aprovado	97	94	100
\N	\N	IA1847-A	68.67	94	Aprovado	77	60	69
\N	\N	IA1848-A	74.00	76	Aprovado	84	61	77
\N	\N	IA1849-A	96.33	93	Aprovado	96	94	99
\N	\N	IA1850-A	82.00	81	Aprovado	93	91	62
\N	\N	IA1851-A	74.67	88	Aprovado	100	60	64
\N	\N	IA1852-A	84.67	95	Aprovado	81	81	92
\N	\N	IA1853-A	82.00	80	Aprovado	80	70	96
\N	\N	IA1854-A	78.00	94	Aprovado	60	87	87
\N	\N	IA1855-A	85.00	93	Aprovado	96	84	75
\N	\N	IA1856-A	77.00	75	Aprovado	73	67	91
\N	\N	IA1857-A	71.67	77	Aprovado	66	76	73
\N	\N	IA1858-A	77.00	75	Aprovado	95	73	63
\N	\N	IA1859-A	86.33	94	Aprovado	73	92	94
MAT03444	ALU0574	IA506-A	66.00	96	Aprovado	64	66	68
MAT01800	ALU0300	IA706-B	64.33	82	Aprovado	68	63	62
MAT01223	ALU0204	IA805-B	79.67	92	Aprovado	70	95	74
MAT02941	ALU0491	IA201-B	66.33	100	Aprovado	66	73	60
MAT03445	ALU0575	IA401-A	90.33	96	Aprovado	91	93	87
MAT03396	ALU0566	IA606-B	42.33	46	Reprovado	56	39	32
MAT03395	ALU0566	IA605-B	25.67	46	Reprovado	26	31	20
MAT03096	ALU0516	IA606-A	26.67	92	Reprovado	10	59	11
MAT02977	ALU0497	IA601-B	39.67	95	Reprovado	53	56	10
MAT03399	ALU0567	IA103-B	25.00	40	Reprovado	23	23	29
MAT03383	ALU0564	IA205-B	25.33	93	Reprovado	46	9	21
MAT03389	ALU0565	IA705-B	24.33	47	Reprovado	46	12	15
MAT03378	ALU0563	IA206-B	19.33	87	Reprovado	19	24	15
MAT00620	ALU0104	IA702-B	31.00	85	Reprovado	39	40	14
MAT04902	ALU0817	IA706-A	26.67	54	Reprovado	20	6	54
MAT03367	ALU0562	IA401-B	5.00	35	Reprovado	2	9	4
MAT01020	ALU0170	IA406-B	35.33	77	Reprovado	44	28	34
MAT03391	ALU0566	IA601-B	21.00	67	Reprovado	17	13	33
MAT03401	ALU0567	IA105-B	37.00	75	Reprovado	33	21	57
MAT03390	ALU0565	IA706-B	39.00	41	Reprovado	39	26	52
MAT03434	ALU0573	IA302-B	31.00	39	Reprovado	1	44	48
MAT03442	ALU0574	IA504-A	24.00	49	Reprovado	3	40	29
MAT03393	ALU0566	IA603-B	21.67	53	Reprovado	45	0	20
MAT03423	ALU0571	IA803-A	39.00	64	Reprovado	32	50	35
MAT00606	ALU0101	IA206-A	40.33	68	Reprovado	52	13	56
MAT01313	ALU0219	IA105-A	39.33	97	Reprovado	40	40	38
MAT03377	ALU0563	IA205-B	23.67	89	Reprovado	37	28	6
MAT03521	ALU0587	IA805-A	49.00	35	Reprovado	51	41	55
MAT03400	ALU0567	IA104-B	24.33	73	Reprovado	11	8	54
MAT03385	ALU0565	IA701-B	9.33	58	Reprovado	8	15	5
MAT03441	ALU0574	IA503-A	44.67	80	Reprovado	23	58	53
MAT03422	ALU0571	IA802-A	32.33	63	Reprovado	17	40	40
MAT03381	ALU0564	IA203-B	49.67	94	Reprovado	58	39	52
MAT01991	ALU0332	IA705-B	35.67	79	Reprovado	18	30	59
MAT03388	ALU0565	IA704-B	26.33	42	Reprovado	18	16	45
MAT03424	ALU0571	IA804-A	18.00	35	Reprovado	1	37	16
MAT03372	ALU0562	IA406-B	48.33	73	Reprovado	51	41	53
MAT05728	ALU0955	IA704-B	28.33	34	Reprovado	44	37	4
MAT03397	ALU0567	IA101-B	32.67	47	Reprovado	49	36	13
MAT01870	ALU0312	IA804-A	33.00	41	Reprovado	44	32	23
\N	\N	IA1860-A	79.00	88	Aprovado	81	65	91
\N	\N	IA1861-A	90.33	94	Aprovado	72	100	99
\N	\N	IA1862-A	72.67	79	Aprovado	70	86	62
\N	\N	IA1863-A	84.00	93	Aprovado	92	82	78
\N	\N	IA1864-A	84.33	83	Aprovado	97	91	65
\N	\N	IA1865-A	78.00	91	Aprovado	81	61	92
\N	\N	IA1866-A	84.33	78	Aprovado	89	95	69
\N	\N	IA1867-A	82.33	75	Aprovado	95	85	67
\N	\N	IA1868-A	78.33	77	Aprovado	90	71	74
\N	\N	IA1869-A	71.67	89	Aprovado	67	67	81
\N	\N	IA1870-A	83.33	94	Aprovado	72	94	84
\N	\N	IA1871-A	81.33	97	Aprovado	85	88	71
\N	\N	IA1872-A	75.33	94	Aprovado	94	62	70
\N	\N	IA1873-A	78.67	81	Aprovado	70	69	97
\N	\N	IA1874-A	83.67	77	Aprovado	99	92	60
\N	\N	IA1875-A	75.67	100	Aprovado	69	85	73
\N	\N	IA1876-A	82.33	91	Aprovado	83	96	68
\N	\N	IA1877-A	74.33	82	Aprovado	77	67	79
\N	\N	IA1878-A	88.33	89	Aprovado	98	83	84
\N	\N	IA1879-A	83.33	96	Aprovado	98	80	72
\N	\N	IA1880-A	84.33	81	Aprovado	62	100	91
\N	\N	IA1881-A	77.67	96	Aprovado	74	64	95
\N	\N	IA1882-A	84.33	94	Aprovado	82	84	87
\N	\N	IA1883-A	86.00	95	Aprovado	93	76	89
\N	\N	IA1884-A	88.33	92	Aprovado	91	91	83
\N	\N	IA1885-A	84.00	95	Aprovado	83	89	80
\N	\N	IA1886-A	75.67	92	Aprovado	94	67	66
\N	\N	IA1887-A	79.67	83	Aprovado	81	88	70
\N	\N	IA1888-A	83.00	85	Aprovado	87	91	71
\N	\N	IA1889-A	70.33	98	Aprovado	83	60	68
\N	\N	IA1890-A	79.67	97	Aprovado	81	78	80
\N	\N	IA1891-A	78.00	82	Aprovado	75	79	80
\N	\N	IA1892-A	70.33	100	Aprovado	83	62	66
\N	\N	IA1893-A	81.00	85	Aprovado	85	93	65
\N	\N	IA1894-A	77.67	93	Aprovado	99	71	63
\N	\N	IA1895-A	79.00	83	Aprovado	64	90	83
\N	\N	IA1896-A	77.67	84	Aprovado	80	86	67
\N	\N	IA1897-A	77.33	78	Aprovado	74	86	72
\N	\N	IA1898-A	71.33	82	Aprovado	76	69	69
\N	\N	IA1899-A	89.33	83	Aprovado	99	69	100
\N	\N	IA1900-A	76.33	85	Aprovado	77	68	84
\N	\N	IA1901-A	83.00	86	Aprovado	77	89	83
\N	\N	IA1902-A	84.00	79	Aprovado	71	86	95
\N	\N	IA1903-A	69.67	75	Aprovado	60	69	80
\N	\N	IA1904-A	63.33	93	Aprovado	60	68	62
\N	\N	IA1905-A	89.00	82	Aprovado	77	95	95
\N	\N	IA1906-A	73.00	98	Aprovado	61	91	67
\N	\N	IA1907-A	85.33	81	Aprovado	89	71	96
\N	\N	IA1908-A	93.00	81	Aprovado	97	95	87
\N	\N	IA1909-A	76.00	99	Aprovado	75	61	92
\N	\N	IA1910-A	78.67	89	Aprovado	61	84	91
MAT03508	ALU0585	IA704-A	88.67	93	Aprovado	89	99	78
MAT03493	ALU0583	IA101-A	86.33	75	Aprovado	82	92	85
MAT03483	ALU0581	IA303-B	75.33	94	Aprovado	67	72	87
MAT04516	ALU0753	IA204-A	71.67	98	Aprovado	81	68	66
MAT03487	ALU0582	IA201-B	92.33	75	Aprovado	99	89	89
MAT03462	ALU0577	IA806-A	28.00	62	Reprovado	35	0	49
MAT00685	ALU0115	IA301-A	35.67	93	Reprovado	6	55	46
MAT03473	ALU0579	IA105-A	21.33	30	Reprovado	32	9	23
MAT03504	ALU0584	IA106-A	42.33	81	Reprovado	55	40	32
MAT01085	ALU0181	IA705-B	42.33	93	Reprovado	26	43	58
MAT03494	ALU0583	IA102-A	46.67	55	Reprovado	38	53	49
MAT05336	ALU0890	IA102-A	30.33	32	Reprovado	27	40	24
MAT01652	ALU0276	IA602-B	48.33	98	Reprovado	46	53	46
MAT03492	ALU0582	IA206-B	50.00	97	Reprovado	37	55	58
MAT03463	ALU0578	IA201-A	17.33	57	Reprovado	26	26	0
MAT03489	ALU0582	IA203-B	24.00	62	Reprovado	38	12	22
MAT04518	ALU0753	IA206-A	30.33	84	Reprovado	8	34	49
MAT03458	ALU0577	IA802-A	42.00	34	Reprovado	48	19	59
MAT05525	ALU0921	IA705-A	29.67	90	Reprovado	16	14	59
MAT01548	ALU0258	IA106-B	36.67	39	Reprovado	31	38	41
MAT01152	ALU0192	IA406-B	51.33	92	Reprovado	43	59	52
MAT03478	ALU0580	IA304-A	17.33	85	Reprovado	9	17	26
MAT03374	ALU0563	IA202-B	30.67	67	Reprovado	46	17	29
MAT02150	ALU0359	IA402-B	35.33	30	Reprovado	47	26	33
MAT03505	ALU0585	IA701-A	33.33	70	Reprovado	32	16	52
MAT03475	ALU0580	IA301-A	36.00	34	Reprovado	43	26	39
MAT05559	ALU0927	IA603-B	45.67	66	Reprovado	29	59	49
MAT04943	ALU0824	IA305-B	18.33	43	Reprovado	6	47	2
MAT00284	ALU0048	IA802-A	28.33	48	Reprovado	57	5	23
MAT03476	ALU0580	IA302-A	19.67	87	Reprovado	15	39	5
MAT05680	ALU0947	IA804-A	18.33	53	Reprovado	33	2	20
MAT01421	ALU0237	IA305-B	20.33	90	Reprovado	10	6	45
\N	\N	IA1911-A	71.33	89	Aprovado	65	60	89
\N	\N	IA1912-A	65.67	85	Aprovado	64	65	68
\N	\N	IA1913-A	77.00	75	Aprovado	72	95	64
\N	\N	IA1914-A	78.67	84	Aprovado	68	78	90
\N	\N	IA1915-A	89.67	79	Aprovado	89	95	85
\N	\N	IA1916-A	80.00	94	Aprovado	64	96	80
\N	\N	IA1917-A	79.67	97	Aprovado	77	64	98
\N	\N	IA1918-A	79.67	89	Aprovado	81	91	67
\N	\N	IA1919-A	78.67	80	Aprovado	79	60	97
\N	\N	IA1920-A	76.67	81	Aprovado	64	92	74
\N	\N	IA1921-A	78.33	76	Aprovado	100	69	66
\N	\N	IA1922-A	82.67	96	Aprovado	89	79	80
\N	\N	IA1923-A	89.33	94	Aprovado	77	94	97
\N	\N	IA1924-A	89.00	97	Aprovado	96	89	82
\N	\N	IA1925-A	85.33	93	Aprovado	71	100	85
\N	\N	IA1926-A	83.33	75	Aprovado	97	74	79
\N	\N	IA1927-A	67.00	83	Aprovado	63	78	60
\N	\N	IA1928-A	89.67	92	Aprovado	90	80	99
\N	\N	IA1929-A	91.00	95	Aprovado	82	91	100
\N	\N	IA1930-A	72.00	89	Aprovado	68	80	68
\N	\N	IA1931-A	77.67	85	Aprovado	87	83	63
\N	\N	IA1932-A	80.33	75	Aprovado	66	81	94
\N	\N	IA1933-A	68.33	81	Aprovado	73	66	66
\N	\N	IA1934-A	88.33	75	Aprovado	86	80	99
\N	\N	IA1935-A	79.33	91	Aprovado	82	85	71
\N	\N	IA1936-A	78.00	99	Aprovado	77	70	87
\N	\N	IA1937-A	75.67	88	Aprovado	63	80	84
\N	\N	IA1938-A	79.00	96	Aprovado	65	78	94
\N	\N	IA1939-A	78.33	86	Aprovado	88	61	86
\N	\N	IA1940-A	70.00	87	Aprovado	79	65	66
\N	\N	IA1941-A	75.00	86	Aprovado	72	77	76
\N	\N	IA1942-A	78.00	81	Aprovado	72	93	69
\N	\N	IA1943-A	83.67	99	Aprovado	63	100	88
\N	\N	IA1944-A	73.67	96	Aprovado	63	90	68
\N	\N	IA1945-A	82.33	95	Aprovado	61	90	96
\N	\N	IA1946-A	76.67	87	Aprovado	82	82	66
\N	\N	IA1947-A	77.33	98	Aprovado	78	74	80
\N	\N	IA1948-A	65.67	96	Aprovado	62	64	71
\N	\N	IA1949-A	73.67	79	Aprovado	83	71	67
\N	\N	IA1950-A	78.67	90	Aprovado	77	73	86
\N	\N	IA1951-A	69.33	85	Aprovado	73	72	63
\N	\N	IA1952-A	72.33	82	Aprovado	62	74	81
\N	\N	IA1953-A	84.67	95	Aprovado	90	68	96
\N	\N	IA1954-A	79.67	100	Aprovado	78	66	95
\N	\N	IA1955-A	72.67	98	Aprovado	63	89	66
\N	\N	IA1956-A	84.00	89	Aprovado	90	98	64
\N	\N	IA1957-A	77.33	87	Aprovado	64	89	79
\N	\N	IA1958-A	76.33	94	Aprovado	90	62	77
\N	\N	IA1959-A	87.33	78	Aprovado	99	63	100
\N	\N	IA1960-A	74.33	78	Aprovado	87	74	62
\N	\N	IA1961-A	97.00	79	Aprovado	100	96	95
\N	\N	IA1962-A	86.33	98	Aprovado	85	76	98
\N	\N	IA1963-A	94.33	86	Aprovado	84	100	99
\N	\N	IA1964-A	85.67	99	Aprovado	92	85	80
\N	\N	IA1965-A	84.33	98	Aprovado	82	96	75
\N	\N	IA1966-A	77.00	86	Aprovado	61	96	74
\N	\N	IA1967-A	73.00	75	Aprovado	82	72	65
\N	\N	IA1968-A	86.33	83	Aprovado	77	86	96
\N	\N	IA1969-A	74.00	99	Aprovado	72	89	61
\N	\N	IA1970-A	80.33	94	Aprovado	72	85	84
MAT05506	ALU0918	IA804-A	76.33	81	Aprovado	65	96	68
MAT03595	ALU0600	IA101-B	87.67	75	Aprovado	96	68	99
MAT03584	ALU0598	IA102-A	84.33	78	Aprovado	78	81	94
MAT02333	ALU0389	IA705-B	38.33	73	Reprovado	57	29	29
MAT03631	ALU0606	IA301-B	31.33	88	Reprovado	27	8	59
MAT05964	ALU0994	IA806-A	43.33	51	Reprovado	49	52	29
MAT03681	ALU0614	IA703-A	19.67	82	Reprovado	7	36	16
MAT03554	ALU0593	IA502-A	22.00	76	Reprovado	9	31	26
MAT03597	ALU0600	IA103-B	17.67	49	Reprovado	12	27	14
MAT05763	ALU0961	IA303-B	49.33	55	Reprovado	43	54	51
MAT03593	ALU0599	IA705-B	27.67	32	Reprovado	44	13	26
MAT03561	ALU0594	IA403-A	28.33	99	Reprovado	58	14	13
MAT03567	ALU0595	IA403-A	33.33	67	Reprovado	41	50	9
MAT03598	ALU0600	IA104-B	19.00	79	Reprovado	50	0	7
MAT01625	ALU0271	IA105-B	40.67	97	Reprovado	53	43	26
MAT03627	ALU0605	IA303-A	45.33	69	Reprovado	32	49	55
MAT03654	ALU0609	IA306-A	24.67	91	Reprovado	27	2	45
MAT00782	ALU0131	IA802-A	29.67	37	Reprovado	45	13	31
MAT05944	ALU0991	IA204-B	38.67	81	Reprovado	55	51	10
MAT03638	ALU0607	IA302-A	31.00	69	Reprovado	41	27	25
MAT03038	ALU0507	IA302-B	27.67	60	Reprovado	35	47	1
MAT03575	ALU0596	IA105-B	22.00	98	Reprovado	1	44	21
MAT03564	ALU0594	IA406-A	31.33	73	Reprovado	29	36	29
MAT03630	ALU0605	IA306-A	20.00	95	Reprovado	15	44	1
MAT01634	ALU0273	IA402-A	49.00	34	Reprovado	46	59	42
MAT03583	ALU0598	IA101-A	33.33	100	Reprovado	6	50	44
MAT03568	ALU0595	IA404-A	30.33	41	Reprovado	6	53	32
MAT01600	ALU0267	IA604-A	33.00	34	Reprovado	6	46	47
MAT01954	ALU0326	IA704-A	21.67	57	Reprovado	8	44	13
MAT03680	ALU0614	IA702-A	25.33	33	Reprovado	44	15	17
MAT00791	ALU0132	IA605-B	41.33	67	Reprovado	59	33	32
MAT03574	ALU0596	IA104-B	14.33	66	Reprovado	31	1	11
MAT03559	ALU0594	IA401-A	33.67	57	Reprovado	44	53	4
MAT05804	ALU0968	IA502-B	23.00	45	Reprovado	40	11	18
MAT03566	ALU0595	IA402-A	35.00	76	Reprovado	17	41	47
\N	\N	IA1971-A	76.33	76	Aprovado	89	61	79
\N	\N	IA1972-A	83.33	86	Aprovado	86	94	70
\N	\N	IA1973-A	83.00	75	Aprovado	79	88	82
\N	\N	IA1974-A	75.33	89	Aprovado	87	69	70
\N	\N	IA1975-A	70.00	84	Aprovado	67	83	60
\N	\N	IA1976-A	84.00	96	Aprovado	94	62	96
\N	\N	IA1977-A	74.33	86	Aprovado	91	67	65
\N	\N	IA1978-A	86.67	91	Aprovado	95	87	78
\N	\N	IA1979-A	77.33	75	Aprovado	67	67	98
\N	\N	IA1980-A	89.00	96	Aprovado	95	87	85
\N	\N	IA1981-A	91.00	76	Aprovado	84	89	100
\N	\N	IA1982-A	81.33	96	Aprovado	65	86	93
\N	\N	IA1983-A	76.00	75	Aprovado	81	84	63
\N	\N	IA1984-A	85.00	87	Aprovado	87	79	89
\N	\N	IA1985-A	63.67	83	Aprovado	62	65	64
\N	\N	IA1986-A	77.67	83	Aprovado	77	75	81
\N	\N	IA1987-A	85.00	78	Aprovado	70	100	85
\N	\N	IA1988-A	86.33	75	Aprovado	96	68	95
\N	\N	IA1989-A	86.33	90	Aprovado	97	72	90
\N	\N	IA1990-A	81.67	100	Aprovado	90	73	82
\N	\N	IA1991-A	77.00	87	Aprovado	83	70	78
\N	\N	IA1992-A	92.33	77	Aprovado	95	88	94
\N	\N	IA1993-A	72.33	82	Aprovado	65	73	79
\N	\N	IA1994-A	79.33	79	Aprovado	79	91	68
\N	\N	IA1995-A	82.00	90	Aprovado	83	85	78
\N	\N	IA1996-A	92.33	79	Aprovado	82	99	96
\N	\N	IA1997-A	89.00	97	Aprovado	100	100	67
\N	\N	IA1998-A	90.00	81	Aprovado	76	97	97
\N	\N	IA1999-A	85.33	86	Aprovado	81	82	93
\N	\N	IA2000-A	84.33	84	Aprovado	91	72	90
\N	\N	IA2001-A	66.00	79	Aprovado	68	63	67
\N	\N	IA2002-A	82.33	94	Aprovado	79	74	94
\N	\N	IA2003-A	85.00	92	Aprovado	84	89	82
\N	\N	IA2004-A	75.33	77	Aprovado	83	83	60
\N	\N	IA2005-A	76.33	75	Aprovado	61	100	68
\N	\N	IA2006-A	86.00	86	Aprovado	90	80	88
\N	\N	IA2007-A	70.67	94	Aprovado	76	65	71
\N	\N	IA2008-A	85.67	91	Aprovado	96	62	99
\N	\N	IA2009-A	86.67	80	Aprovado	85	79	96
\N	\N	IA2010-A	81.67	81	Aprovado	79	100	66
\N	\N	IA2011-A	90.33	89	Aprovado	99	78	94
\N	\N	IA2012-A	79.00	84	Aprovado	70	82	85
\N	\N	IA2013-A	75.67	88	Aprovado	93	65	69
\N	\N	IA2014-A	83.33	98	Aprovado	87	100	63
\N	\N	IA2015-A	63.67	80	Aprovado	60	63	68
\N	\N	IA2016-A	75.67	97	Aprovado	96	66	65
\N	\N	IA2017-A	78.67	82	Aprovado	95	69	72
\N	\N	IA2018-A	68.00	76	Aprovado	60	65	79
\N	\N	IA2019-A	91.33	77	Aprovado	87	94	93
\N	\N	IA2020-A	75.33	90	Aprovado	68	92	66
\N	\N	IA2021-A	84.67	82	Aprovado	81	76	97
\N	\N	IA2022-A	85.33	76	Aprovado	88	99	69
\N	\N	IA2023-A	75.67	93	Aprovado	66	99	62
\N	\N	IA2024-A	67.00	98	Aprovado	63	65	73
\N	\N	IA2025-A	74.00	78	Aprovado	61	74	87
\N	\N	IA2026-A	71.00	97	Aprovado	71	62	80
\N	\N	IA2027-A	87.67	76	Aprovado	85	96	82
MAT03784	ALU0631	IA304-B	72.00	96	Aprovado	62	83	71
MAT01255	ALU0210	IA201-B	80.33	88	Aprovado	90	61	90
MAT03782	ALU0631	IA302-B	80.00	93	Aprovado	85	93	62
MAT03751	ALU0626	IA701-B	78.00	77	Aprovado	74	62	98
MAT04047	ALU0675	IA303-A	72.00	89	Aprovado	74	67	75
MAT02813	ALU0469	IA605-B	87.00	80	Aprovado	72	93	96
MAT03778	ALU0630	IA104-B	91.00	94	Aprovado	96	98	79
MAT05765	ALU0961	IA305-B	15.00	56	Reprovado	17	27	1
MAT03800	ALU0634	IA302-B	27.67	37	Reprovado	4	20	59
MAT03741	ALU0624	IA703-B	28.00	86	Reprovado	58	11	15
MAT03799	ALU0634	IA301-B	15.33	47	Reprovado	36	7	3
MAT02478	ALU0413	IA206-B	48.67	51	Reprovado	41	55	50
MAT03764	ALU0628	IA402-B	29.33	33	Reprovado	20	54	14
MAT01887	ALU0315	IA203-A	18.67	66	Reprovado	8	34	14
MAT03743	ALU0624	IA705-B	44.67	39	Reprovado	47	53	34
MAT03773	ALU0629	IA405-A	30.67	82	Reprovado	53	28	11
MAT03750	ALU0625	IA606-B	16.67	47	Reprovado	37	1	12
MAT05569	ALU0929	IA801-A	42.67	40	Reprovado	19	51	58
MAT03746	ALU0625	IA602-B	41.00	58	Reprovado	31	58	34
MAT05318	ALU0887	IA602-B	43.67	43	Reprovado	54	25	52
MAT03760	ALU0627	IA104-B	40.67	44	Reprovado	35	32	55
MAT05100	ALU0850	IA106-B	27.33	87	Reprovado	20	24	38
MAT03771	ALU0629	IA403-A	34.67	66	Reprovado	54	45	5
MAT03777	ALU0630	IA103-B	22.33	72	Reprovado	6	35	26
MAT05309	ALU0885	IA205-B	38.67	85	Reprovado	44	50	22
MAT03779	ALU0630	IA105-B	22.00	75	Reprovado	15	24	27
MAT03772	ALU0629	IA404-A	34.67	33	Reprovado	56	3	45
MAT02220	ALU0370	IA606-B	39.00	60	Reprovado	59	54	4
MAT03765	ALU0628	IA403-B	18.00	53	Reprovado	30	17	7
MAT01888	ALU0315	IA204-A	15.67	72	Reprovado	12	14	21
MAT01079	ALU0180	IA505-B	25.67	96	Reprovado	1	25	51
MAT03769	ALU0629	IA401-A	28.33	78	Reprovado	22	43	20
MAT03745	ALU0625	IA601-B	25.00	58	Reprovado	37	28	10
MAT03770	ALU0629	IA402-A	51.33	79	Reprovado	53	45	56
MAT03752	ALU0626	IA702-B	24.00	88	Reprovado	11	49	12
MAT03781	ALU0631	IA301-B	47.00	32	Reprovado	57	32	52
MAT03780	ALU0630	IA106-B	28.33	99	Reprovado	33	50	2
\N	\N	IA2028-A	80.67	86	Aprovado	83	61	98
\N	\N	IA2029-A	85.67	92	Aprovado	94	68	95
\N	\N	IA2030-A	79.67	81	Aprovado	97	79	63
\N	\N	IA2031-A	79.00	80	Aprovado	95	63	79
\N	\N	IA2032-A	81.33	98	Aprovado	70	84	90
\N	\N	IA2033-A	75.33	85	Aprovado	82	63	81
\N	\N	IA2034-A	85.33	96	Aprovado	85	99	72
\N	\N	IA2035-A	89.33	91	Aprovado	74	96	98
\N	\N	IA2036-A	68.00	86	Aprovado	68	70	66
\N	\N	IA2037-A	75.33	98	Aprovado	70	78	78
\N	\N	IA2038-A	75.67	97	Aprovado	80	82	65
\N	\N	IA2039-A	70.33	77	Aprovado	77	68	66
\N	\N	IA2040-A	85.67	85	Aprovado	100	96	61
\N	\N	IA2041-A	90.33	94	Aprovado	98	79	94
\N	\N	IA2042-A	87.00	87	Aprovado	96	84	81
\N	\N	IA2043-A	76.33	76	Aprovado	73	93	63
\N	\N	IA2044-A	73.33	98	Aprovado	69	84	67
\N	\N	IA2045-A	77.33	95	Aprovado	65	97	70
\N	\N	IA2046-A	76.67	98	Aprovado	84	80	66
\N	\N	IA2047-A	78.33	90	Aprovado	76	94	65
\N	\N	IA2048-A	84.67	82	Aprovado	79	99	76
\N	\N	IA2049-A	69.67	82	Aprovado	78	61	70
\N	\N	IA2050-A	91.33	86	Aprovado	99	88	87
\N	\N	IA2051-A	85.67	86	Aprovado	94	78	85
\N	\N	IA2052-A	74.33	81	Aprovado	67	78	78
\N	\N	IA2053-A	69.33	89	Aprovado	72	67	69
\N	\N	IA2054-A	80.67	80	Aprovado	83	68	91
\N	\N	IA2055-A	67.00	81	Aprovado	73	62	66
\N	\N	IA2056-A	75.33	76	Aprovado	71	71	84
\N	\N	IA2057-A	82.00	98	Aprovado	95	71	80
\N	\N	IA2058-A	78.33	77	Aprovado	73	91	71
\N	\N	IA2059-A	66.00	78	Aprovado	61	66	71
\N	\N	IA2060-A	71.67	100	Aprovado	64	79	72
\N	\N	IA2061-A	79.33	88	Aprovado	100	74	64
\N	\N	IA2062-A	68.67	75	Aprovado	61	79	66
\N	\N	IA2063-A	81.67	77	Aprovado	96	86	63
\N	\N	IA2064-A	85.33	81	Aprovado	90	91	75
\N	\N	IA2065-A	91.33	88	Aprovado	90	94	90
\N	\N	IA2066-A	87.33	85	Aprovado	90	85	87
\N	\N	IA2067-A	90.67	75	Aprovado	87	89	96
\N	\N	IA2068-A	85.33	89	Aprovado	100	76	80
\N	\N	IA2069-A	77.67	99	Aprovado	79	78	76
\N	\N	IA2070-A	74.67	83	Aprovado	88	76	60
\N	\N	IA2071-A	80.33	98	Aprovado	60	83	98
\N	\N	IA2072-A	77.33	80	Aprovado	63	91	78
\N	\N	IA2073-A	81.00	100	Aprovado	86	93	64
\N	\N	IA2074-A	81.33	80	Aprovado	87	60	97
\N	\N	IA2075-A	76.33	83	Aprovado	69	87	73
\N	\N	IA2076-A	70.67	83	Aprovado	83	67	62
\N	\N	IA2077-A	69.00	96	Aprovado	79	62	66
\N	\N	IA2078-A	80.67	86	Aprovado	94	88	60
\N	\N	IA2079-A	91.00	100	Aprovado	97	89	87
\N	\N	IA2080-A	85.00	78	Aprovado	75	98	82
\N	\N	IA2081-A	80.67	87	Aprovado	85	63	94
MAT02151	ALU0359	IA403-B	89.00	100	Aprovado	100	100	67
MAT01329	ALU0222	IA703-B	76.00	78	Aprovado	84	69	75
MAT03840	ALU0640	IA106-B	80.00	75	Aprovado	92	65	83
MAT03829	ALU0639	IA301-B	71.33	77	Aprovado	81	65	68
MAT03860	ALU0644	IA502-A	34.00	56	Reprovado	41	43	18
MAT04853	ALU0809	IA305-A	39.33	32	Reprovado	51	21	46
MAT01622	ALU0271	IA102-B	16.00	42	Reprovado	7	27	14
MAT03853	ALU0643	IA401-A	14.00	86	Reprovado	5	3	34
MAT02549	ALU0425	IA805-B	14.33	80	Reprovado	23	1	19
MAT02297	ALU0383	IA505-A	42.00	91	Reprovado	55	35	36
MAT02622	ALU0437	IA206-A	35.67	39	Reprovado	18	40	49
MAT03835	ALU0640	IA101-B	5.67	50	Reprovado	0	3	14
MAT03827	ALU0638	IA405-B	27.00	50	Reprovado	12	16	53
MAT00185	ALU0031	IA605-B	48.33	79	Reprovado	56	35	54
MAT03869	ALU0645	IA605-B	36.33	59	Reprovado	55	20	34
MAT00601	ALU0101	IA201-A	50.67	66	Reprovado	46	49	57
MAT01624	ALU0271	IA104-B	20.33	56	Reprovado	20	27	14
MAT02464	ALU0411	IA404-B	25.67	46	Reprovado	5	24	48
MAT02119	ALU0354	IA701-B	30.33	64	Reprovado	24	11	56
MAT01780	ALU0297	IA804-B	18.33	79	Reprovado	19	14	22
MAT01149	ALU0192	IA403-B	38.00	97	Reprovado	59	27	28
MAT03841	ALU0641	IA801-B	29.33	93	Reprovado	16	28	44
MAT03759	ALU0627	IA103-B	36.33	46	Reprovado	43	56	10
MAT03857	ALU0643	IA405-A	33.00	31	Reprovado	10	44	45
MAT05731	ALU0956	IA401-A	25.00	68	Reprovado	6	50	19
MAT02477	ALU0413	IA205-B	23.33	65	Reprovado	13	42	15
MAT03862	ALU0644	IA504-A	47.33	80	Reprovado	54	34	54
MAT01165	ALU0195	IA301-B	23.33	74	Reprovado	19	32	19
MAT03828	ALU0638	IA406-B	28.00	82	Reprovado	8	32	44
MAT03873	ALU0646	IA503-B	30.67	97	Reprovado	44	5	43
MAT03836	ALU0640	IA102-B	26.67	52	Reprovado	52	7	21
MAT01837	ALU0307	IA401-A	34.67	77	Reprovado	47	22	35
MAT05312	ALU0886	IA702-B	38.33	53	Reprovado	58	1	56
\N	\N	IA2082-A	80.33	86	Aprovado	74	91	76
\N	\N	IA2083-A	78.67	91	Aprovado	68	95	73
\N	\N	IA2084-A	64.33	100	Aprovado	64	60	69
\N	\N	IA2085-A	77.67	96	Aprovado	81	76	76
\N	\N	IA2086-A	76.00	81	Aprovado	95	70	63
\N	\N	IA2087-A	71.00	97	Aprovado	62	67	84
\N	\N	IA2088-A	72.00	89	Aprovado	68	85	63
\N	\N	IA2089-A	83.67	92	Aprovado	81	82	88
\N	\N	IA2090-A	80.67	89	Aprovado	72	74	96
\N	\N	IA2091-A	88.00	91	Aprovado	98	68	98
\N	\N	IA2092-A	92.00	98	Aprovado	93	84	99
\N	\N	IA2093-A	71.67	81	Aprovado	67	66	82
\N	\N	IA2094-A	72.33	80	Aprovado	71	86	60
\N	\N	IA2095-A	70.00	82	Aprovado	62	62	86
\N	\N	IA2096-A	86.33	96	Aprovado	87	79	93
\N	\N	IA2097-A	91.33	90	Aprovado	88	99	87
\N	\N	IA2098-A	81.00	98	Aprovado	70	85	88
\N	\N	IA2099-A	92.33	93	Aprovado	97	86	94
\N	\N	IA2100-A	64.00	79	Aprovado	60	70	62
\N	\N	IA2101-A	70.00	77	Aprovado	63	76	71
\N	\N	IA2102-A	90.67	86	Aprovado	79	95	98
\N	\N	IA2103-A	88.67	97	Aprovado	100	66	100
\N	\N	IA2104-A	85.67	88	Aprovado	98	67	92
\N	\N	IA2105-A	79.33	95	Aprovado	91	86	61
\N	\N	IA2106-A	84.67	94	Aprovado	93	74	87
\N	\N	IA2107-A	72.00	87	Aprovado	60	82	74
\N	\N	IA2108-A	91.67	89	Aprovado	91	89	95
\N	\N	IA2109-A	77.33	100	Aprovado	89	81	62
\N	\N	IA2110-A	80.67	76	Aprovado	78	73	91
\N	\N	IA2111-A	83.00	82	Aprovado	83	70	96
\N	\N	IA2112-A	82.67	94	Aprovado	82	76	90
\N	\N	IA2113-A	85.67	85	Aprovado	97	90	70
\N	\N	IA2114-A	79.33	81	Aprovado	72	79	87
\N	\N	IA2115-A	79.33	88	Aprovado	64	98	76
\N	\N	IA2116-A	78.00	76	Aprovado	79	90	65
\N	\N	IA2117-A	78.00	79	Aprovado	90	71	73
\N	\N	IA2118-A	67.33	91	Aprovado	76	60	66
\N	\N	IA2119-A	79.33	76	Aprovado	70	78	90
\N	\N	IA2120-A	81.33	79	Aprovado	85	78	81
\N	\N	IA2121-A	82.00	79	Aprovado	96	83	67
\N	\N	IA2122-A	88.67	76	Aprovado	92	87	87
\N	\N	IA2123-A	77.00	95	Aprovado	65	97	69
\N	\N	IA2124-A	64.00	88	Aprovado	66	63	63
\N	\N	IA2125-A	75.33	95	Aprovado	68	78	80
\N	\N	IA2126-A	80.00	100	Aprovado	90	71	79
\N	\N	IA2127-A	77.33	85	Aprovado	70	63	99
\N	\N	IA2128-A	82.67	99	Aprovado	87	95	66
\N	\N	IA2129-A	62.33	95	Aprovado	60	66	61
\N	\N	IA2130-A	80.33	85	Aprovado	73	69	99
\N	\N	IA2131-A	78.00	99	Aprovado	84	83	67
\N	\N	IA2132-A	74.33	97	Aprovado	64	70	89
\N	\N	IA2133-A	88.00	80	Aprovado	97	77	90
\N	\N	IA2134-A	75.00	80	Aprovado	88	74	63
\N	\N	IA2135-A	80.33	88	Aprovado	83	69	89
\N	\N	IA2136-A	86.67	87	Aprovado	99	90	71
\N	\N	IA2137-A	80.33	79	Aprovado	72	100	69
\N	\N	IA2138-A	78.00	94	Aprovado	85	85	64
\N	\N	IA2139-A	83.00	89	Aprovado	71	90	88
\N	\N	IA2140-A	74.67	95	Aprovado	82	79	63
MAT03998	ALU0667	IA602-A	72.33	86	Aprovado	76	67	74
MAT04003	ALU0668	IA301-B	73.67	90	Aprovado	78	79	64
MAT04477	ALU0747	IA701-B	23.67	50	Reprovado	22	1	48
MAT03985	ALU0665	IA601-B	32.00	94	Reprovado	1	44	51
MAT03937	ALU0657	IA801-B	28.00	74	Reprovado	37	24	23
MAT04061	ALU0677	IA105-B	39.00	89	Reprovado	56	26	35
MAT04072	ALU0679	IA104-B	42.33	47	Reprovado	39	34	54
MAT04018	ALU0670	IA204-A	27.67	86	Reprovado	26	32	25
MAT04015	ALU0670	IA201-A	48.33	78	Reprovado	51	37	57
MAT03974	ALU0663	IA802-B	40.33	63	Reprovado	39	40	42
MAT03952	ALU0659	IA604-A	31.67	94	Reprovado	14	51	30
MAT03982	ALU0664	IA104-B	20.33	68	Reprovado	6	50	5
MAT03940	ALU0657	IA804-B	26.33	48	Reprovado	25	11	43
MAT03938	ALU0657	IA802-B	29.33	96	Reprovado	22	38	28
MAT03953	ALU0659	IA605-A	26.00	67	Reprovado	8	16	54
MAT03068	ALU0512	IA202-A	41.67	49	Reprovado	26	58	41
MAT04062	ALU0677	IA106-B	23.33	43	Reprovado	33	25	12
MAT03954	ALU0659	IA606-A	20.33	82	Reprovado	13	42	6
MAT04069	ALU0679	IA101-B	41.33	58	Reprovado	47	36	41
MAT04064	ALU0678	IA202-B	37.00	68	Reprovado	43	57	11
MAT02130	ALU0355	IA506-B	48.33	92	Reprovado	45	49	51
MAT04001	ALU0667	IA605-A	25.67	66	Reprovado	4	37	36
MAT03978	ALU0663	IA806-B	29.00	50	Reprovado	16	52	19
MAT01289	ALU0215	IA605-B	45.00	62	Reprovado	34	52	49
MAT03963	ALU0661	IA403-A	24.67	38	Reprovado	19	45	10
MAT03425	ALU0571	IA805-A	48.67	38	Reprovado	58	52	36
MAT03949	ALU0659	IA601-A	39.67	71	Reprovado	53	7	59
MAT04010	ALU0669	IA302-A	30.67	37	Reprovado	38	30	24
MAT02745	ALU0458	IA203-B	17.67	85	Reprovado	36	11	6
MAT04073	ALU0679	IA105-B	37.00	96	Reprovado	57	20	34
MAT00432	ALU0072	IA406-B	47.67	88	Reprovado	58	41	44
MAT03941	ALU0657	IA805-B	19.33	35	Reprovado	23	24	11
MAT04071	ALU0679	IA103-B	33.33	75	Reprovado	41	18	41
MAT04004	ALU0668	IA302-B	29.00	46	Reprovado	28	51	8
MAT03936	ALU0656	IA406-B	29.00	83	Reprovado	10	47	30
MAT03951	ALU0659	IA603-A	26.00	90	Reprovado	33	2	43
MAT04067	ALU0678	IA205-B	36.00	76	Reprovado	54	17	37
MAT04005	ALU0668	IA303-B	27.00	79	Reprovado	19	14	48
MAT04016	ALU0670	IA202-A	25.33	79	Reprovado	42	15	19
MAT04011	ALU0669	IA303-A	8.33	59	Reprovado	3	10	12
MAT04200	ALU0700	IA506-B	46.33	36	Reprovado	47	40	52
MAT05701	ALU0951	IA301-A	26.00	88	Reprovado	34	2	42
MAT04066	ALU0678	IA204-B	37.67	69	Reprovado	32	32	49
\N	\N	IA2141-A	82.00	95	Aprovado	88	81	77
\N	\N	IA2142-A	78.00	94	Aprovado	85	76	73
\N	\N	IA2143-A	74.00	97	Aprovado	78	80	64
\N	\N	IA2144-A	84.00	80	Aprovado	96	68	88
\N	\N	IA2145-A	81.00	93	Aprovado	85	67	91
\N	\N	IA2146-A	86.67	92	Aprovado	99	73	88
\N	\N	IA2147-A	80.67	80	Aprovado	68	81	93
\N	\N	IA2148-A	77.00	88	Aprovado	75	70	86
\N	\N	IA2149-A	73.33	81	Aprovado	63	77	80
\N	\N	IA2150-A	71.33	96	Aprovado	67	70	77
\N	\N	IA2151-A	86.67	89	Aprovado	75	98	87
\N	\N	IA2152-A	77.67	82	Aprovado	68	88	77
\N	\N	IA2153-A	94.33	95	Aprovado	90	100	93
\N	\N	IA2154-A	74.67	92	Aprovado	69	68	87
\N	\N	IA2155-A	79.67	100	Aprovado	95	70	74
\N	\N	IA2156-A	70.67	82	Aprovado	65	78	69
\N	\N	IA2157-A	85.67	99	Aprovado	99	73	85
\N	\N	IA2158-A	90.33	76	Aprovado	96	100	75
\N	\N	IA2159-A	81.00	92	Aprovado	89	78	76
\N	\N	IA2160-A	75.67	86	Aprovado	92	60	75
\N	\N	IA2161-A	80.00	91	Aprovado	95	80	65
\N	\N	IA2162-A	77.67	80	Aprovado	86	61	86
\N	\N	IA2163-A	78.00	99	Aprovado	82	77	75
\N	\N	IA2164-A	68.67	87	Aprovado	69	65	72
\N	\N	IA2165-A	75.33	85	Aprovado	69	76	81
\N	\N	IA2166-A	74.67	87	Aprovado	72	74	78
\N	\N	IA2167-A	75.00	86	Aprovado	96	67	62
\N	\N	IA2168-A	69.67	81	Aprovado	77	72	60
\N	\N	IA2169-A	71.33	82	Aprovado	63	76	75
\N	\N	IA2170-A	73.33	95	Aprovado	73	76	71
\N	\N	IA2171-A	77.33	84	Aprovado	66	70	96
\N	\N	IA2172-A	75.67	95	Aprovado	60	100	67
\N	\N	IA2173-A	89.00	79	Aprovado	91	80	96
\N	\N	IA2174-A	77.67	84	Aprovado	69	72	92
\N	\N	IA2175-A	76.33	80	Aprovado	84	70	75
\N	\N	IA2176-A	82.67	91	Aprovado	60	89	99
\N	\N	IA2177-A	74.33	84	Aprovado	85	63	75
\N	\N	IA2178-A	87.00	94	Aprovado	98	68	95
\N	\N	IA2179-A	83.67	90	Aprovado	84	71	96
\N	\N	IA2180-A	77.33	99	Aprovado	71	91	70
\N	\N	IA2181-A	69.00	90	Aprovado	73	72	62
\N	\N	IA2182-A	73.67	92	Aprovado	66	70	85
\N	\N	IA2183-A	66.67	100	Aprovado	61	76	63
\N	\N	IA2184-A	89.67	98	Aprovado	90	86	93
\N	\N	IA2185-A	72.00	84	Aprovado	65	71	80
\N	\N	IA2186-A	83.00	93	Aprovado	79	82	88
\N	\N	IA2187-A	94.00	96	Aprovado	99	93	90
\N	\N	IA2188-A	73.33	99	Aprovado	60	96	64
MAT04076	ALU0680	IA302-B	76.00	91	Aprovado	86	82	60
MAT05060	ALU0844	IA202-A	80.67	80	Aprovado	83	86	73
MAT05423	ALU0904	IA505-B	85.33	90	Aprovado	87	75	94
MAT04161	ALU0694	IA303-B	24.67	77	Reprovado	16	15	43
MAT02968	ALU0495	IA404-A	28.00	56	Reprovado	27	31	26
MAT03734	ALU0623	IA602-A	22.33	91	Reprovado	26	11	30
MAT02225	ALU0371	IA705-B	51.67	36	Reprovado	45	57	53
MAT04102	ALU0684	IA704-A	19.00	46	Reprovado	12	12	33
MAT04166	ALU0695	IA202-B	32.00	83	Reprovado	22	29	45
MAT04163	ALU0694	IA305-B	25.00	33	Reprovado	10	28	37
MAT02143	ALU0358	IA701-A	26.00	56	Reprovado	20	23	35
MAT01397	ALU0233	IA405-B	39.67	66	Reprovado	45	30	44
MAT04100	ALU0684	IA702-A	43.00	99	Reprovado	43	36	50
MAT04093	ALU0683	IA601-B	38.00	67	Reprovado	41	32	41
MAT00674	ALU0113	IA702-B	38.33	89	Reprovado	18	45	52
MAT04081	ALU0681	IA601-B	29.33	73	Reprovado	8	27	53
MAT04167	ALU0695	IA203-B	24.00	72	Reprovado	0	22	50
MAT01704	ALU0284	IA606-A	22.00	68	Reprovado	47	5	14
MAT00173	ALU0029	IA805-A	25.33	44	Reprovado	20	22	34
MAT04169	ALU0695	IA205-B	39.67	59	Reprovado	54	22	43
MAT02761	ALU0461	IA101-B	21.67	37	Reprovado	9	46	10
MAT04077	ALU0680	IA303-B	36.67	46	Reprovado	33	26	51
MAT02851	ALU0476	IA401-B	29.00	61	Reprovado	34	7	46
MAT04157	ALU0693	IA205-B	33.33	39	Reprovado	10	34	56
MAT04074	ALU0679	IA106-B	25.67	97	Reprovado	6	48	23
MAT04075	ALU0680	IA301-B	43.33	91	Reprovado	55	25	50
MAT02222	ALU0371	IA702-B	26.67	41	Reprovado	55	2	23
MAT04078	ALU0680	IA304-B	33.00	78	Reprovado	2	53	44
MAT00974	ALU0163	IA602-B	25.00	56	Reprovado	30	2	43
MAT01154	ALU0193	IA502-A	25.33	54	Reprovado	21	29	26
MAT04080	ALU0680	IA306-B	30.33	83	Reprovado	11	48	32
MAT04106	ALU0685	IA202-A	34.67	76	Reprovado	58	27	19
MAT04156	ALU0693	IA204-B	21.00	86	Reprovado	51	1	11
MAT04104	ALU0684	IA706-A	38.67	54	Reprovado	49	20	47
MAT00669	ALU0112	IA403-B	21.67	36	Reprovado	34	6	25
MAT04103	ALU0684	IA705-A	32.33	61	Reprovado	35	35	27
MAT04181	ALU0697	IA205-B	26.00	33	Reprovado	25	37	16
\N	\N	IA2189-A	73.67	81	Aprovado	83	66	72
\N	\N	IA2190-A	74.67	94	Aprovado	77	78	69
\N	\N	IA2191-A	79.33	99	Aprovado	97	66	75
\N	\N	IA2192-A	75.00	93	Aprovado	97	66	62
\N	\N	IA2193-A	79.33	79	Aprovado	76	62	100
\N	\N	IA2194-A	79.67	77	Aprovado	68	92	79
\N	\N	IA2195-A	80.33	81	Aprovado	81	85	75
\N	\N	IA2196-A	74.67	91	Aprovado	80	77	67
\N	\N	IA2197-A	74.67	86	Aprovado	84	76	64
\N	\N	IA2198-A	83.00	99	Aprovado	87	63	99
\N	\N	IA2199-A	74.33	99	Aprovado	80	73	70
\N	\N	IA2200-A	85.33	87	Aprovado	96	64	96
\N	\N	IA2201-A	66.33	96	Aprovado	63	60	76
\N	\N	IA2202-A	79.33	83	Aprovado	94	74	70
\N	\N	IA2203-A	83.33	91	Aprovado	89	67	94
\N	\N	IA2204-A	90.33	98	Aprovado	97	83	91
\N	\N	IA2205-A	82.00	95	Aprovado	85	74	87
\N	\N	IA2206-A	84.67	85	Aprovado	86	77	91
\N	\N	IA2207-A	69.33	95	Aprovado	73	61	74
\N	\N	IA2208-A	69.33	82	Aprovado	79	64	65
\N	\N	IA2209-A	81.33	87	Aprovado	97	82	65
\N	\N	IA2210-A	77.33	87	Aprovado	86	82	64
\N	\N	IA2211-A	95.67	79	Aprovado	92	99	96
\N	\N	IA2212-A	79.00	86	Aprovado	100	75	62
\N	\N	IA2213-A	77.67	92	Aprovado	72	75	86
\N	\N	IA2214-A	88.33	90	Aprovado	97	71	97
\N	\N	IA2215-A	75.33	85	Aprovado	75	72	79
\N	\N	IA2216-A	96.67	93	Aprovado	99	95	96
\N	\N	IA2217-A	81.67	87	Aprovado	85	84	76
\N	\N	IA2218-A	83.67	100	Aprovado	64	97	90
\N	\N	IA2219-A	73.67	81	Aprovado	80	79	62
\N	\N	IA2220-A	80.67	86	Aprovado	67	86	89
\N	\N	IA2221-A	74.00	78	Aprovado	82	61	79
\N	\N	IA2222-A	69.67	91	Aprovado	70	64	75
\N	\N	IA2223-A	87.00	83	Aprovado	91	75	95
\N	\N	IA2224-A	78.67	78	Aprovado	93	75	68
\N	\N	IA2225-A	86.00	84	Aprovado	66	93	99
\N	\N	IA2226-A	78.67	77	Aprovado	68	94	74
\N	\N	IA2227-A	82.67	98	Aprovado	100	81	67
\N	\N	IA2228-A	83.33	97	Aprovado	88	74	88
\N	\N	IA2229-A	87.33	87	Aprovado	95	85	82
\N	\N	IA2230-A	79.00	89	Aprovado	91	73	73
\N	\N	IA2231-A	78.67	89	Aprovado	93	69	74
\N	\N	IA2232-A	90.00	100	Aprovado	99	85	86
\N	\N	IA2233-A	73.33	76	Aprovado	77	74	69
\N	\N	IA2234-A	81.00	81	Aprovado	89	91	63
\N	\N	IA2235-A	92.33	80	Aprovado	93	91	93
\N	\N	IA2236-A	83.33	87	Aprovado	64	86	100
\N	\N	IA2237-A	85.67	88	Aprovado	80	77	100
\N	\N	IA2238-A	84.67	97	Aprovado	79	86	89
\N	\N	IA2239-A	88.00	77	Aprovado	100	81	83
\N	\N	IA2240-A	76.33	85	Aprovado	80	85	64
\N	\N	IA2241-A	84.67	96	Aprovado	76	93	85
\N	\N	IA2242-A	77.00	82	Aprovado	71	89	71
MAT04294	ALU0716	IA104-B	82.33	89	Aprovado	89	79	79
MAT04095	ALU0683	IA603-B	68.33	79	Aprovado	77	68	60
MAT04235	ALU0706	IA705-B	19.67	90	Reprovado	16	20	23
MAT04274	ALU0713	IA302-A	34.67	97	Reprovado	37	47	20
MAT04278	ALU0713	IA306-A	35.33	51	Reprovado	9	40	57
MAT04283	ALU0714	IA805-B	16.67	73	Reprovado	7	15	28
MAT02393	ALU0399	IA805-B	31.67	58	Reprovado	46	45	4
MAT04241	ALU0707	IA705-A	25.00	100	Reprovado	24	33	18
MAT04255	ALU0710	IA701-B	28.00	69	Reprovado	37	26	21
MAT04254	ALU0709	IA306-A	29.00	41	Reprovado	7	49	31
MAT05290	ALU0882	IA404-B	16.67	62	Reprovado	0	41	9
MAT01338	ALU0223	IA406-B	16.33	70	Reprovado	31	12	6
MAT04249	ALU0709	IA301-A	53.67	52	Reprovado	59	45	57
MAT04259	ALU0710	IA705-B	21.00	33	Reprovado	59	2	2
MAT04243	ALU0708	IA801-B	31.67	67	Reprovado	30	56	9
MAT04420	ALU0737	IA704-B	27.00	50	Reprovado	24	18	39
MAT04252	ALU0709	IA304-A	30.00	98	Reprovado	20	20	50
MAT04207	ALU0702	IA801-B	13.00	39	Reprovado	12	17	10
MAT04291	ALU0716	IA101-B	12.00	90	Reprovado	12	10	14
MAT01547	ALU0258	IA105-B	34.33	69	Reprovado	24	22	57
MAT04212	ALU0702	IA806-B	24.33	99	Reprovado	15	41	17
MAT04238	ALU0707	IA702-A	21.33	72	Reprovado	32	8	24
MAT01803	ALU0301	IA103-B	25.00	94	Reprovado	8	11	56
MAT04279	ALU0714	IA801-B	33.00	76	Reprovado	9	44	46
MAT05637	ALU0940	IA303-B	33.33	36	Reprovado	14	47	39
MAT04251	ALU0709	IA303-A	26.00	74	Reprovado	25	43	10
MAT04284	ALU0714	IA806-B	39.67	97	Reprovado	35	32	52
MAT00547	ALU0092	IA101-A	29.67	69	Reprovado	29	19	41
MAT01955	ALU0326	IA705-A	23.33	98	Reprovado	29	7	34
MAT04273	ALU0713	IA301-A	38.67	89	Reprovado	43	58	15
MAT04245	ALU0708	IA803-B	21.67	99	Reprovado	22	7	36
MAT04211	ALU0702	IA805-B	36.00	36	Reprovado	52	6	50
MAT00541	ALU0091	IA601-B	30.00	69	Reprovado	6	56	28
MAT04151	ALU0692	IA205-B	28.67	83	Reprovado	32	44	10
MAT04206	ALU0701	IA706-B	29.33	50	Reprovado	11	58	19
MAT04244	ALU0708	IA802-B	30.00	99	Reprovado	27	33	30
MAT04208	ALU0702	IA802-B	32.00	66	Reprovado	1	45	50
MAT04250	ALU0709	IA302-A	22.00	45	Reprovado	16	22	28
\N	\N	IA2243-A	87.33	95	Aprovado	95	94	73
\N	\N	IA2244-A	78.33	93	Aprovado	86	78	71
\N	\N	IA2245-A	77.67	75	Aprovado	64	98	71
\N	\N	IA2246-A	85.33	95	Aprovado	81	79	96
\N	\N	IA2247-A	85.00	86	Aprovado	89	89	77
\N	\N	IA2248-A	72.33	75	Aprovado	76	74	67
\N	\N	IA2249-A	73.00	94	Aprovado	80	73	66
\N	\N	IA2250-A	90.33	85	Aprovado	81	95	95
\N	\N	IA2251-A	73.33	93	Aprovado	66	89	65
\N	\N	IA2252-A	78.00	96	Aprovado	71	71	92
\N	\N	IA2253-A	85.67	77	Aprovado	86	86	85
\N	\N	IA2254-A	68.67	78	Aprovado	62	79	65
\N	\N	IA2255-A	70.67	89	Aprovado	65	80	67
\N	\N	IA2256-A	69.67	99	Aprovado	63	66	80
\N	\N	IA2257-A	67.00	82	Aprovado	75	64	62
\N	\N	IA2258-A	78.33	75	Aprovado	75	82	78
\N	\N	IA2259-A	77.67	100	Aprovado	60	82	91
\N	\N	IA2260-A	89.00	95	Aprovado	97	89	81
\N	\N	IA2261-A	82.67	91	Aprovado	81	79	88
\N	\N	IA2262-A	72.33	95	Aprovado	60	85	72
\N	\N	IA2263-A	72.67	97	Aprovado	75	68	75
\N	\N	IA2264-A	85.33	78	Aprovado	90	67	99
\N	\N	IA2265-A	91.00	77	Aprovado	92	94	87
\N	\N	IA2266-A	84.00	93	Aprovado	84	97	71
\N	\N	IA2267-A	74.33	78	Aprovado	77	74	72
\N	\N	IA2268-A	71.33	93	Aprovado	68	71	75
\N	\N	IA2269-A	73.33	84	Aprovado	77	73	70
\N	\N	IA2270-A	84.67	97	Aprovado	80	97	77
\N	\N	IA2271-A	72.67	87	Aprovado	66	91	61
\N	\N	IA2272-A	74.33	84	Aprovado	75	71	77
\N	\N	IA2273-A	71.67	94	Aprovado	68	74	73
\N	\N	IA2274-A	87.33	97	Aprovado	87	78	97
\N	\N	IA2275-A	71.67	86	Aprovado	81	70	64
\N	\N	IA2276-A	81.67	93	Aprovado	72	77	96
\N	\N	IA2277-A	71.33	79	Aprovado	70	74	70
\N	\N	IA2278-A	90.33	90	Aprovado	92	97	82
\N	\N	IA2279-A	84.33	81	Aprovado	87	73	93
\N	\N	IA2280-A	75.67	98	Aprovado	81	67	79
\N	\N	IA2281-A	85.67	95	Aprovado	84	86	87
\N	\N	IA2282-A	87.67	88	Aprovado	88	97	78
\N	\N	IA2283-A	76.67	93	Aprovado	81	85	64
\N	\N	IA2284-A	73.67	88	Aprovado	80	73	68
\N	\N	IA2285-A	68.00	81	Aprovado	68	75	61
\N	\N	IA2286-A	66.67	85	Aprovado	74	64	62
\N	\N	IA2287-A	85.00	96	Aprovado	90	86	79
\N	\N	IA2288-A	75.33	80	Aprovado	98	61	67
\N	\N	IA2289-A	75.67	96	Aprovado	91	65	71
\N	\N	IA2290-A	64.67	80	Aprovado	69	60	65
\N	\N	IA2291-A	73.00	99	Aprovado	96	60	63
\N	\N	IA2292-A	72.67	87	Aprovado	74	60	84
\N	\N	IA2293-A	80.33	96	Aprovado	86	73	82
\N	\N	IA2294-A	70.33	78	Aprovado	78	61	72
\N	\N	IA2295-A	89.33	88	Aprovado	92	87	89
MAT04351	ALU0726	IA701-B	81.00	99	Aprovado	88	69	86
MAT04134	ALU0689	IA606-A	85.67	94	Aprovado	94	73	90
MAT05721	ALU0954	IA503-B	82.33	94	Aprovado	81	94	72
MAT04336	ALU0723	IA204-A	83.00	91	Aprovado	72	80	97
MAT04347	ALU0725	IA203-B	81.33	89	Aprovado	61	94	89
MAT02640	ALU0440	IA506-A	71.67	80	Aprovado	92	63	60
MAT04365	ALU0728	IA403-B	75.67	83	Aprovado	76	68	83
MAT00957	ALU0160	IA503-A	69.00	81	Aprovado	75	71	61
MAT02400	ALU0400	IA406-B	72.00	90	Aprovado	69	83	64
MAT04332	ALU0722	IA806-B	79.33	87	Aprovado	68	85	85
MAT02644	ALU0441	IA604-B	35.67	74	Reprovado	56	15	36
MAT05962	ALU0994	IA804-A	31.67	67	Reprovado	46	2	47
MAT01287	ALU0215	IA603-B	29.00	30	Reprovado	23	42	22
MAT04343	ALU0724	IA405-B	20.67	67	Reprovado	28	32	2
MAT04346	ALU0725	IA202-B	24.33	58	Reprovado	23	27	23
MAT01709	ALU0285	IA505-A	24.33	36	Reprovado	9	43	21
MAT04371	ALU0729	IA603-A	23.67	91	Reprovado	30	31	10
MAT01672	ALU0279	IA204-B	42.00	83	Reprovado	47	42	37
MAT02692	ALU0449	IA804-A	28.67	74	Reprovado	56	23	7
MAT00485	ALU0081	IA405-B	28.00	34	Reprovado	25	10	49
MAT00504	ALU0084	IA206-B	40.33	78	Reprovado	51	52	18
MAT05733	ALU0956	IA403-A	34.67	89	Reprovado	30	24	50
MAT05292	ALU0882	IA406-B	34.33	61	Reprovado	17	48	38
MAT02570	ALU0429	IA402-A	33.67	78	Reprovado	29	44	28
MAT01973	ALU0329	IA105-B	29.00	91	Reprovado	22	12	53
MAT02825	ALU0471	IA305-B	19.00	99	Reprovado	15	31	11
MAT04090	ALU0682	IA404-B	17.67	36	Reprovado	9	31	13
MAT05223	ALU0871	IA703-A	42.00	75	Reprovado	32	59	35
MAT01953	ALU0326	IA703-A	26.00	39	Reprovado	1	20	57
\N	\N	IA2296-A	90.67	75	Aprovado	86	90	96
\N	\N	IA2297-A	84.33	83	Aprovado	97	66	90
\N	\N	IA2298-A	77.33	83	Aprovado	85	74	73
\N	\N	IA2299-A	81.67	99	Aprovado	66	99	80
\N	\N	IA2300-A	86.00	87	Aprovado	85	99	74
\N	\N	IA2301-A	79.00	82	Aprovado	66	98	73
\N	\N	IA2302-A	66.33	100	Aprovado	69	68	62
\N	\N	IA2303-A	78.00	83	Aprovado	65	92	77
\N	\N	IA2304-A	78.67	85	Aprovado	89	85	62
\N	\N	IA2305-A	66.00	86	Aprovado	64	69	65
\N	\N	IA2306-A	79.33	81	Aprovado	88	88	62
\N	\N	IA2307-A	86.00	79	Aprovado	98	83	77
\N	\N	IA2308-A	90.33	84	Aprovado	98	84	89
\N	\N	IA2309-A	74.67	82	Aprovado	83	68	73
\N	\N	IA2310-A	79.33	88	Aprovado	98	77	63
\N	\N	IA2311-A	89.33	83	Aprovado	92	98	78
\N	\N	IA2312-A	72.33	85	Aprovado	65	61	91
\N	\N	IA2313-A	75.00	79	Aprovado	88	77	60
\N	\N	IA2314-A	84.00	91	Aprovado	87	97	68
\N	\N	IA2315-A	79.33	82	Aprovado	66	86	86
\N	\N	IA2316-A	81.67	75	Aprovado	88	77	80
\N	\N	IA2317-A	78.00	92	Aprovado	73	64	97
\N	\N	IA2318-A	84.33	88	Aprovado	92	84	77
\N	\N	IA2319-A	75.67	94	Aprovado	65	67	95
\N	\N	IA2320-A	92.67	88	Aprovado	99	95	84
\N	\N	IA2321-A	86.00	98	Aprovado	70	89	99
\N	\N	IA2322-A	74.67	95	Aprovado	87	77	60
\N	\N	IA2323-A	73.33	85	Aprovado	60	68	92
\N	\N	IA2324-A	78.00	75	Aprovado	79	75	80
\N	\N	IA2325-A	91.33	77	Aprovado	99	81	94
\N	\N	IA2326-A	82.00	95	Aprovado	83	70	93
\N	\N	IA2327-A	69.33	78	Aprovado	61	78	69
\N	\N	IA2328-A	93.67	99	Aprovado	86	98	97
\N	\N	IA2329-A	89.00	75	Aprovado	76	100	91
\N	\N	IA2330-A	84.00	94	Aprovado	88	85	79
\N	\N	IA2331-A	85.67	85	Aprovado	86	87	84
\N	\N	IA2332-A	81.00	94	Aprovado	96	78	69
\N	\N	IA2333-A	84.33	76	Aprovado	86	76	91
\N	\N	IA2334-A	71.33	78	Aprovado	61	76	77
\N	\N	IA2335-A	82.00	92	Aprovado	100	77	69
\N	\N	IA2336-A	85.33	89	Aprovado	83	92	81
\N	\N	IA2337-A	74.67	97	Aprovado	80	76	68
\N	\N	IA2338-A	90.33	92	Aprovado	88	95	88
\N	\N	IA2339-A	81.33	89	Aprovado	95	80	69
\N	\N	IA2340-A	81.67	80	Aprovado	60	94	91
\N	\N	IA2341-A	85.33	95	Aprovado	99	64	93
\N	\N	IA2342-A	88.67	90	Aprovado	71	95	100
\N	\N	IA2343-A	66.33	79	Aprovado	62	69	68
\N	\N	IA2344-A	71.67	80	Aprovado	76	64	75
\N	\N	IA2345-A	85.00	80	Aprovado	84	73	98
\N	\N	IA2346-A	73.33	77	Aprovado	68	88	64
\N	\N	IA2347-A	77.33	98	Aprovado	70	69	93
\N	\N	IA2348-A	71.33	94	Aprovado	66	67	81
\N	\N	IA2349-A	74.33	95	Aprovado	60	97	66
\N	\N	IA2350-A	69.33	91	Aprovado	64	63	81
\N	\N	IA2351-A	84.67	90	Aprovado	89	84	81
\N	\N	IA2352-A	89.33	99	Aprovado	86	90	92
\N	\N	IA2353-A	81.33	88	Aprovado	73	91	80
\N	\N	IA2354-A	74.00	96	Aprovado	97	65	60
\N	\N	IA2355-A	72.67	81	Aprovado	67	80	71
\N	\N	IA2356-A	77.00	93	Aprovado	71	92	68
\N	\N	IA2357-A	87.00	97	Aprovado	99	82	80
\N	\N	IA2358-A	72.67	76	Aprovado	75	61	82
\N	\N	IA2359-A	75.67	76	Aprovado	81	66	80
MAT04441	ALU0741	IA401-B	77.67	98	Aprovado	66	67	100
MAT04507	ALU0752	IA401-B	83.33	76	Aprovado	90	86	74
MAT04456	ALU0743	IA504-A	90.67	91	Aprovado	87	87	98
MAT05689	ALU0949	IA301-A	35.33	85	Reprovado	44	26	36
MAT04468	ALU0745	IA304-B	35.67	94	Reprovado	46	13	48
MAT04515	ALU0753	IA203-A	35.33	95	Reprovado	6	54	46
MAT04513	ALU0753	IA201-A	30.67	94	Reprovado	8	50	34
MAT04473	ALU0746	IA103-B	31.67	45	Reprovado	29	58	8
MAT04489	ALU0749	IA401-B	31.33	45	Reprovado	47	0	47
MAT04494	ALU0749	IA406-B	26.00	83	Reprovado	34	1	43
MAT04497	ALU0750	IA603-B	25.33	95	Reprovado	32	43	1
MAT02365	ALU0395	IA301-B	14.67	95	Reprovado	28	0	16
MAT04466	ALU0745	IA302-B	18.33	49	Reprovado	25	24	6
MAT04467	ALU0745	IA303-B	21.67	32	Reprovado	10	25	30
MAT01508	ALU0252	IA702-A	28.33	79	Reprovado	21	49	15
MAT05504	ALU0918	IA802-A	30.00	56	Reprovado	36	12	42
MAT02598	ALU0433	IA806-A	20.67	75	Reprovado	43	13	6
MAT04451	ALU0742	IA105-A	32.00	76	Reprovado	26	29	41
MAT03376	ALU0563	IA204-B	16.67	34	Reprovado	7	2	41
MAT04459	ALU0744	IA301-B	25.33	34	Reprovado	50	25	1
MAT05621	ALU0937	IA505-B	27.33	72	Reprovado	32	16	34
MAT04504	ALU0751	IA604-B	47.00	33	Reprovado	48	55	38
MAT04470	ALU0745	IA306-B	35.00	65	Reprovado	32	44	29
MAT04457	ALU0743	IA505-A	38.67	37	Reprovado	57	13	46
MAT05057	ALU0843	IA705-B	37.67	87	Reprovado	51	52	10
MAT01931	ALU0322	IA505-B	13.33	35	Reprovado	14	22	4
MAT05449	ALU0909	IA401-B	18.00	46	Reprovado	5	41	8
MAT04502	ALU0751	IA602-B	18.33	92	Reprovado	25	25	5
MAT04446	ALU0741	IA406-B	31.67	74	Reprovado	16	41	38
MAT01232	ALU0206	IA502-A	25.67	75	Reprovado	24	49	4
MAT04514	ALU0753	IA202-A	14.67	61	Reprovado	3	13	28
MAT04491	ALU0749	IA403-B	9.67	58	Reprovado	12	2	15
MAT04465	ALU0745	IA301-B	41.00	93	Reprovado	58	40	25
MAT04500	ALU0750	IA606-B	38.67	47	Reprovado	49	24	43
MAT04503	ALU0751	IA603-B	41.67	58	Reprovado	25	54	46
MAT04453	ALU0743	IA501-A	30.00	74	Reprovado	8	51	31
MAT04447	ALU0742	IA101-A	23.67	46	Reprovado	17	2	52
MAT00839	ALU0140	IA205-A	33.00	40	Reprovado	2	45	52
MAT04495	ALU0750	IA601-B	28.33	100	Reprovado	54	19	12
MAT00225	ALU0038	IA703-B	41.33	55	Reprovado	23	59	42
\N	\N	IA2360-A	68.33	96	Aprovado	62	66	77
\N	\N	IA2361-A	69.00	78	Aprovado	82	62	63
\N	\N	IA2362-A	82.33	82	Aprovado	73	99	75
\N	\N	IA2363-A	87.00	90	Aprovado	93	68	100
\N	\N	IA2364-A	73.00	80	Aprovado	68	64	87
\N	\N	IA2365-A	83.00	80	Aprovado	92	71	86
\N	\N	IA2366-A	84.00	84	Aprovado	69	94	89
\N	\N	IA2367-A	78.67	76	Aprovado	81	81	74
\N	\N	IA2368-A	83.00	89	Aprovado	65	98	86
\N	\N	IA2369-A	73.67	76	Aprovado	75	84	62
\N	\N	IA2370-A	68.33	84	Aprovado	69	62	74
\N	\N	IA2371-A	85.00	89	Aprovado	80	84	91
\N	\N	IA2372-A	67.00	76	Aprovado	72	67	62
\N	\N	IA2373-A	85.00	95	Aprovado	88	76	91
\N	\N	IA2374-A	80.67	82	Aprovado	93	87	62
\N	\N	IA2375-A	85.33	88	Aprovado	96	63	97
\N	\N	IA2376-A	83.00	87	Aprovado	72	88	89
\N	\N	IA2377-A	75.67	95	Aprovado	66	80	81
\N	\N	IA2378-A	75.67	83	Aprovado	90	66	71
\N	\N	IA2379-A	79.00	82	Aprovado	88	85	64
\N	\N	IA2380-A	65.33	81	Aprovado	67	69	60
\N	\N	IA2381-A	86.67	77	Aprovado	100	95	65
\N	\N	IA2382-A	67.67	82	Aprovado	65	67	71
\N	\N	IA2383-A	71.00	96	Aprovado	63	74	76
\N	\N	IA2384-A	79.33	93	Aprovado	97	69	72
\N	\N	IA2385-A	69.00	96	Aprovado	60	67	80
\N	\N	IA2386-A	87.67	100	Aprovado	77	99	87
\N	\N	IA2387-A	72.33	82	Aprovado	64	71	82
\N	\N	IA2388-A	79.67	81	Aprovado	84	74	81
\N	\N	IA2389-A	87.33	89	Aprovado	86	91	85
\N	\N	IA2390-A	67.33	88	Aprovado	70	67	65
\N	\N	IA2391-A	75.33	97	Aprovado	73	91	62
\N	\N	IA2392-A	81.33	79	Aprovado	92	60	92
\N	\N	IA2393-A	95.00	94	Aprovado	95	99	91
\N	\N	IA2394-A	81.00	89	Aprovado	67	81	95
\N	\N	IA2395-A	81.33	88	Aprovado	65	83	96
\N	\N	IA2396-A	84.33	91	Aprovado	99	60	94
\N	\N	IA2397-A	78.00	89	Aprovado	70	77	87
\N	\N	IA2398-A	70.33	76	Aprovado	64	72	75
\N	\N	IA2399-A	70.00	88	Aprovado	60	71	79
\N	\N	IA2400-A	74.00	83	Aprovado	66	91	65
\N	\N	IA2401-A	73.67	80	Aprovado	70	90	61
\N	\N	IA2402-A	89.33	100	Aprovado	98	98	72
\N	\N	IA2403-A	76.00	82	Aprovado	64	66	98
\N	\N	IA2404-A	84.00	89	Aprovado	84	95	73
\N	\N	IA2405-A	68.33	95	Aprovado	70	72	63
\N	\N	IA2406-A	65.33	97	Aprovado	66	67	63
\N	\N	IA2407-A	54.33	60	Reprovado	57	47	59
\N	\N	IA2408-A	19.33	71	Reprovado	12	1	45
\N	\N	IA2409-A	29.00	87	Reprovado	40	17	30
\N	\N	IA2410-A	17.67	47	Reprovado	24	12	17
MAT04561	ALU0761	IA701-A	79.00	98	Aprovado	75	73	89
MAT04621	ALU0771	IA601-A	88.67	98	Aprovado	77	94	95
MAT04535	ALU0756	IA805-B	77.33	92	Aprovado	74	80	78
MAT04573	ALU0763	IA301-A	83.33	75	Aprovado	93	66	91
MAT04575	ALU0763	IA303-A	43.00	57	Reprovado	50	51	28
MAT04623	ALU0771	IA603-A	28.33	77	Reprovado	7	31	47
MAT04568	ALU0762	IA502-A	37.33	96	Reprovado	50	48	14
MAT04610	ALU0769	IA102-A	29.67	34	Reprovado	56	8	25
MAT04530	ALU0755	IA606-B	13.67	67	Reprovado	0	14	27
MAT04596	ALU0766	IA106-A	28.67	32	Reprovado	45	0	41
MAT04597	ALU0767	IA101-B	23.67	53	Reprovado	10	54	7
MAT04558	ALU0760	IA504-B	17.00	55	Reprovado	2	42	7
MAT04633	ALU0773	IA101-B	11.00	31	Reprovado	12	14	7
MAT04599	ALU0767	IA103-B	32.33	36	Reprovado	53	15	29
MAT04577	ALU0763	IA305-A	3.33	97	Reprovado	6	3	1
MAT04574	ALU0763	IA302-A	17.00	67	Reprovado	30	0	21
MAT04578	ALU0763	IA306-A	37.00	76	Reprovado	57	54	0
MAT04569	ALU0762	IA503-A	25.33	32	Reprovado	47	14	15
MAT04624	ALU0771	IA604-A	24.33	62	Reprovado	13	47	13
MAT04528	ALU0755	IA604-B	3.00	50	Reprovado	2	5	2
MAT04625	ALU0771	IA605-A	33.33	52	Reprovado	1	58	41
MAT04567	ALU0762	IA501-A	30.67	73	Reprovado	42	50	0
MAT04533	ALU0756	IA803-B	29.67	44	Reprovado	39	34	16
MAT04534	ALU0756	IA804-B	33.33	43	Reprovado	26	42	32
MAT04602	ALU0767	IA106-B	17.00	78	Reprovado	8	14	29
MAT04570	ALU0762	IA504-A	40.00	73	Reprovado	46	26	48
MAT04594	ALU0766	IA104-A	31.67	86	Reprovado	25	52	18
MAT04589	ALU0765	IA705-B	16.33	59	Reprovado	4	37	8
MAT04529	ALU0755	IA605-B	30.67	45	Reprovado	37	2	53
MAT04632	ALU0772	IA806-B	11.33	67	Reprovado	12	22	0
MAT04559	ALU0760	IA505-B	39.33	40	Reprovado	18	46	54
MAT04634	ALU0773	IA102-B	20.67	57	Reprovado	21	8	33
MAT04571	ALU0762	IA505-A	34.67	79	Reprovado	33	23	48
MAT04630	ALU0772	IA804-B	24.67	55	Reprovado	28	14	32
MAT04635	ALU0773	IA103-B	36.33	53	Reprovado	40	45	24
MAT04627	ALU0772	IA801-B	21.67	100	Reprovado	4	58	3
MAT04980	ALU0830	IA206-B	21.33	88	Reprovado	18	18	28
MAT00036	ALU0006	IA106-A	8.67	92	Reprovado	1	2	23
MAT04572	ALU0762	IA506-A	39.67	79	Reprovado	50	30	39
MAT02601	ALU0434	IA703-A	41.00	63	Reprovado	49	39	35
MAT04560	ALU0760	IA506-B	30.67	45	Reprovado	19	56	17
MAT03966	ALU0661	IA406-A	28.67	50	Reprovado	11	54	21
MAT01037	ALU0173	IA305-A	12.67	98	Reprovado	4	22	12
\N	\N	IA2411-A	34.00	69	Reprovado	44	42	16
\N	\N	IA2412-A	45.33	67	Reprovado	36	51	49
\N	\N	IA2413-A	38.33	35	Reprovado	4	55	56
\N	\N	IA2414-A	22.67	42	Reprovado	17	48	3
\N	\N	IA2415-A	20.33	50	Reprovado	1	54	6
\N	\N	IA2416-A	25.33	47	Reprovado	29	30	17
\N	\N	IA2417-A	29.00	43	Reprovado	20	29	38
\N	\N	IA2418-A	40.67	34	Reprovado	52	48	22
\N	\N	IA2419-A	42.00	88	Reprovado	20	54	52
\N	\N	IA2420-A	37.67	42	Reprovado	54	42	17
\N	\N	IA2421-A	33.33	73	Reprovado	42	41	17
\N	\N	IA2422-A	27.33	45	Reprovado	11	28	43
\N	\N	IA2423-A	20.00	62	Reprovado	0	42	18
\N	\N	IA2424-A	33.00	49	Reprovado	0	53	46
\N	\N	IA2425-A	27.33	72	Reprovado	12	52	18
\N	\N	IA2426-A	32.67	36	Reprovado	55	28	15
\N	\N	IA2427-A	34.33	97	Reprovado	33	58	12
\N	\N	IA2428-A	20.67	62	Reprovado	0	27	35
\N	\N	IA2429-A	10.00	55	Reprovado	14	5	11
\N	\N	IA2430-A	29.67	41	Reprovado	40	2	47
\N	\N	IA2431-A	26.33	50	Reprovado	32	15	32
\N	\N	IA2432-A	24.33	80	Reprovado	49	11	13
\N	\N	IA2433-A	32.00	63	Reprovado	31	7	58
\N	\N	IA2434-A	40.33	71	Reprovado	50	18	53
\N	\N	IA2435-A	27.00	36	Reprovado	42	26	13
\N	\N	IA2436-A	20.67	35	Reprovado	38	9	15
\N	\N	IA2437-A	25.33	60	Reprovado	18	18	40
\N	\N	IA2438-A	36.33	100	Reprovado	4	57	48
\N	\N	IA2439-A	31.67	97	Reprovado	1	50	44
\N	\N	IA2440-A	21.00	42	Reprovado	10	28	25
\N	\N	IA2441-A	14.33	63	Reprovado	34	9	0
\N	\N	IA2442-A	29.33	67	Reprovado	25	6	57
\N	\N	IA2443-A	16.00	59	Reprovado	13	25	10
\N	\N	IA2444-A	9.67	52	Reprovado	2	18	9
\N	\N	IA2445-A	50.33	58	Reprovado	50	55	46
\N	\N	IA2446-A	22.67	80	Reprovado	17	6	45
\N	\N	IA2447-A	41.00	61	Reprovado	37	55	31
\N	\N	IA2448-A	18.33	53	Reprovado	6	1	48
\N	\N	IA2449-A	31.67	82	Reprovado	37	4	54
\N	\N	IA2450-A	24.67	94	Reprovado	0	35	39
\N	\N	IA2451-A	46.67	32	Reprovado	53	32	55
\N	\N	IA2452-A	41.00	55	Reprovado	27	45	51
\N	\N	IA2453-A	26.67	72	Reprovado	55	24	1
\N	\N	IA2454-A	32.33	70	Reprovado	11	38	48
\N	\N	IA2455-A	25.67	75	Reprovado	24	2	51
\N	\N	IA2456-A	15.33	32	Reprovado	8	35	3
\N	\N	IA2457-A	20.67	88	Reprovado	12	6	44
\N	\N	IA2458-A	35.33	46	Reprovado	45	50	11
MAT04710	ALU0785	IA306-A	70.67	91	Aprovado	62	77	73
MAT04702	ALU0784	IA404-A	74.00	77	Aprovado	76	83	63
MAT04713	ALU0786	IA603-A	66.33	83	Aprovado	68	69	62
MAT04639	ALU0774	IA401-B	75.33	99	Aprovado	70	64	92
MAT04640	ALU0774	IA402-B	74.33	94	Aprovado	60	99	64
MAT04638	ALU0773	IA106-B	39.67	64	Reprovado	57	39	23
MAT04714	ALU0786	IA604-A	42.00	51	Reprovado	49	44	33
MAT04637	ALU0773	IA105-B	26.33	80	Reprovado	47	9	23
MAT04644	ALU0774	IA406-B	46.67	97	Reprovado	52	40	48
MAT04670	ALU0779	IA802-A	33.33	61	Reprovado	12	59	29
MAT04700	ALU0784	IA402-A	41.67	63	Reprovado	17	56	52
MAT04716	ALU0786	IA606-A	49.67	89	Reprovado	43	57	49
MAT04643	ALU0774	IA405-B	15.33	32	Reprovado	32	9	5
MAT04641	ALU0774	IA403-B	17.33	52	Reprovado	23	11	18
MAT04674	ALU0779	IA806-A	27.33	68	Reprovado	25	19	38
MAT02898	ALU0483	IA506-B	25.67	43	Reprovado	19	7	51
MAT04671	ALU0779	IA803-A	30.00	47	Reprovado	54	7	29
MAT04717	ALU0787	IA501-A	29.33	35	Reprovado	28	42	18
MAT04203	ALU0701	IA703-B	11.33	59	Reprovado	18	1	15
MAT04645	ALU0775	IA801-B	38.00	61	Reprovado	28	29	57
MAT04646	ALU0775	IA802-B	38.33	70	Reprovado	4	52	59
MAT04711	ALU0786	IA601-A	30.67	68	Reprovado	35	33	24
MAT04678	ALU0780	IA504-A	35.33	62	Reprovado	21	34	51
MAT05114	ALU0853	IA402-B	52.00	38	Reprovado	46	54	56
MAT04725	ALU0788	IA103-A	24.00	60	Reprovado	26	6	40
MAT04679	ALU0780	IA505-A	25.00	42	Reprovado	44	26	5
MAT04701	ALU0784	IA403-A	46.67	69	Reprovado	32	51	57
MAT04696	ALU0783	IA504-A	22.33	46	Reprovado	57	7	3
MAT04729	ALU0789	IA701-B	26.67	86	Reprovado	4	47	29
MAT04705	ALU0785	IA301-A	22.33	30	Reprovado	36	14	17
MAT04689	ALU0782	IA103-B	29.33	80	Reprovado	6	36	46
MAT04680	ALU0780	IA506-A	12.33	67	Reprovado	15	7	15
MAT04715	ALU0786	IA605-A	39.00	100	Reprovado	47	41	29
MAT04673	ALU0779	IA805-A	22.33	93	Reprovado	14	21	32
MAT04726	ALU0788	IA104-A	18.33	89	Reprovado	1	36	18
MAT04690	ALU0782	IA104-B	39.00	36	Reprovado	43	44	30
MAT04692	ALU0782	IA106-B	18.00	98	Reprovado	1	43	10
MAT04687	ALU0782	IA101-B	31.67	31	Reprovado	33	19	43
MAT04659	ALU0777	IA303-B	20.33	87	Reprovado	38	6	17
MAT04677	ALU0780	IA503-A	41.00	63	Reprovado	9	59	55
MAT04712	ALU0786	IA602-A	23.00	73	Reprovado	4	57	8
MAT04691	ALU0782	IA105-B	24.33	100	Reprovado	26	7	40
MAT01963	ALU0328	IA201-B	34.33	51	Reprovado	34	15	54
\N	\N	IA2459-A	25.33	48	Reprovado	20	33	23
\N	\N	IA2460-A	37.33	55	Reprovado	39	27	46
\N	\N	IA2461-A	21.67	36	Reprovado	30	2	33
\N	\N	IA2462-A	28.33	78	Reprovado	11	52	22
\N	\N	IA2463-A	43.00	77	Reprovado	41	40	48
\N	\N	IA2464-A	30.00	31	Reprovado	33	32	25
\N	\N	IA2465-A	31.00	63	Reprovado	41	49	3
\N	\N	IA2466-A	24.67	53	Reprovado	24	48	2
\N	\N	IA2467-A	18.67	87	Reprovado	28	12	16
\N	\N	IA2468-A	25.00	84	Reprovado	28	21	26
\N	\N	IA2469-A	22.00	88	Reprovado	48	8	10
\N	\N	IA2470-A	27.00	86	Reprovado	10	44	27
\N	\N	IA2471-A	33.00	92	Reprovado	6	34	59
\N	\N	IA2472-A	31.33	97	Reprovado	57	0	37
\N	\N	IA2473-A	25.33	80	Reprovado	23	42	11
\N	\N	IA2474-A	20.00	72	Reprovado	8	45	7
\N	\N	IA2475-A	19.67	98	Reprovado	4	49	6
\N	\N	IA2476-A	37.67	66	Reprovado	53	50	10
\N	\N	IA2477-A	25.67	39	Reprovado	12	11	54
\N	\N	IA2478-A	38.33	67	Reprovado	47	59	9
\N	\N	IA2479-A	36.67	58	Reprovado	36	40	34
\N	\N	IA2480-A	26.33	39	Reprovado	26	17	36
\N	\N	IA2481-A	7.33	86	Reprovado	2	19	1
\N	\N	IA2482-A	31.33	81	Reprovado	45	18	31
\N	\N	IA2483-A	23.67	69	Reprovado	39	2	30
\N	\N	IA2484-A	39.67	30	Reprovado	33	31	55
\N	\N	IA2485-A	26.67	68	Reprovado	40	16	24
\N	\N	IA2486-A	41.00	76	Reprovado	59	59	5
\N	\N	IA2487-A	5.00	44	Reprovado	0	14	1
\N	\N	IA2488-A	31.67	89	Reprovado	21	36	38
\N	\N	IA2489-A	14.00	37	Reprovado	10	3	29
\N	\N	IA2490-A	22.33	58	Reprovado	2	29	36
\N	\N	IA2491-A	23.00	74	Reprovado	37	23	9
\N	\N	IA2492-A	40.67	76	Reprovado	37	39	46
\N	\N	IA2493-A	36.33	37	Reprovado	49	29	31
\N	\N	IA2494-A	40.67	60	Reprovado	32	32	58
\N	\N	IA2495-A	30.33	53	Reprovado	32	27	32
\N	\N	IA2496-A	35.00	78	Reprovado	1	58	46
\N	\N	IA2497-A	25.00	75	Reprovado	19	31	25
\N	\N	IA2498-A	34.67	68	Reprovado	36	41	27
\N	\N	IA2499-A	37.00	79	Reprovado	53	34	24
\N	\N	IA2500-A	34.00	92	Reprovado	36	24	42
\N	\N	IA2501-A	17.00	78	Reprovado	2	30	19
\N	\N	IA2502-A	48.33	64	Reprovado	56	53	36
\N	\N	IA2503-A	8.33	97	Reprovado	2	13	10
\N	\N	IA2504-A	43.67	65	Reprovado	46	35	50
\N	\N	IA2505-A	30.67	37	Reprovado	59	22	11
\N	\N	IA2506-A	13.67	75	Reprovado	2	13	26
MAT04762	ALU0794	IA704-B	93.67	75	Aprovado	90	97	94
MAT03093	ALU0516	IA603-A	31.33	63	Reprovado	26	12	56
MAT04751	ALU0792	IA605-B	15.67	85	Reprovado	3	34	10
MAT04760	ALU0794	IA702-B	24.67	55	Reprovado	24	38	12
MAT05659	ALU0944	IA101-B	14.67	72	Reprovado	6	25	13
MAT04822	ALU0804	IA504-B	40.33	89	Reprovado	59	54	8
MAT04731	ALU0789	IA703-B	38.00	72	Reprovado	42	59	13
MAT04849	ALU0809	IA301-A	11.33	48	Reprovado	0	14	20
MAT04779	ALU0797	IA703-A	34.33	89	Reprovado	1	53	49
MAT04753	ALU0793	IA801-B	24.33	91	Reprovado	24	49	0
MAT04827	ALU0805	IA803-A	11.00	64	Reprovado	3	0	30
MAT04777	ALU0797	IA701-A	27.00	88	Reprovado	6	41	34
MAT02639	ALU0440	IA505-A	36.67	68	Reprovado	52	31	27
MAT04820	ALU0804	IA502-B	40.00	48	Reprovado	53	33	34
MAT04767	ALU0795	IA503-B	41.33	60	Reprovado	59	14	51
MAT04752	ALU0792	IA606-B	30.67	52	Reprovado	19	38	35
MAT04823	ALU0804	IA505-B	37.67	78	Reprovado	21	34	58
MAT04855	ALU0810	IA801-B	35.00	58	Reprovado	57	45	3
MAT00167	ALU0028	IA305-B	49.33	44	Reprovado	41	57	50
MAT02167	ALU0362	IA401-B	20.33	56	Reprovado	42	0	19
MAT05978	ALU0997	IA202-A	19.33	37	Reprovado	13	21	24
MAT04856	ALU0810	IA802-B	16.33	97	Reprovado	2	3	44
MAT00395	ALU0066	IA305-B	33.00	76	Reprovado	45	38	16
MAT04764	ALU0794	IA706-B	42.67	51	Reprovado	27	47	54
MAT04732	ALU0789	IA704-B	29.33	77	Reprovado	39	26	23
MAT04749	ALU0792	IA603-B	41.00	60	Reprovado	56	8	59
MAT00463	ALU0078	IA101-A	26.33	94	Reprovado	18	22	39
MAT04771	ALU0796	IA701-A	40.67	86	Reprovado	29	35	58
MAT04782	ALU0797	IA706-A	37.67	86	Reprovado	50	41	22
MAT04781	ALU0797	IA705-A	12.33	92	Reprovado	4	10	23
MAT04766	ALU0795	IA502-B	37.33	54	Reprovado	29	47	36
MAT03863	ALU0644	IA505-A	37.33	76	Reprovado	43	10	59
MAT04733	ALU0789	IA705-B	24.00	99	Reprovado	13	35	24
MAT04763	ALU0794	IA705-B	18.67	67	Reprovado	1	8	47
MAT04734	ALU0789	IA706-B	45.00	51	Reprovado	42	59	34
MAT04765	ALU0795	IA501-B	27.67	55	Reprovado	41	16	26
MAT04830	ALU0805	IA806-A	25.00	82	Reprovado	31	37	7
MAT04769	ALU0795	IA505-B	15.00	45	Reprovado	3	34	8
MAT04748	ALU0792	IA602-B	44.33	37	Reprovado	37	57	39
MAT04819	ALU0804	IA501-B	18.67	81	Reprovado	10	16	30
\N	\N	IA2507-A	7.67	43	Reprovado	14	1	8
\N	\N	IA2508-A	21.33	96	Reprovado	0	51	13
\N	\N	IA2509-A	26.33	53	Reprovado	22	38	19
\N	\N	IA2510-A	33.00	61	Reprovado	14	52	33
\N	\N	IA2511-A	30.00	46	Reprovado	7	44	39
\N	\N	IA2512-A	26.67	46	Reprovado	23	46	11
\N	\N	IA2513-A	33.00	48	Reprovado	29	23	47
\N	\N	IA2514-A	29.33	47	Reprovado	14	20	54
\N	\N	IA2515-A	27.00	46	Reprovado	40	8	33
\N	\N	IA2516-A	44.33	53	Reprovado	57	59	17
\N	\N	IA2517-A	51.33	81	Reprovado	56	54	44
\N	\N	IA2518-A	42.33	30	Reprovado	32	40	55
\N	\N	IA2519-A	22.67	79	Reprovado	6	43	19
\N	\N	IA2520-A	35.00	46	Reprovado	37	44	24
\N	\N	IA2521-A	40.00	65	Reprovado	22	45	53
\N	\N	IA2522-A	21.00	56	Reprovado	39	15	9
\N	\N	IA2523-A	22.00	49	Reprovado	18	30	18
\N	\N	IA2524-A	43.67	85	Reprovado	49	28	54
\N	\N	IA2525-A	27.67	54	Reprovado	7	52	24
\N	\N	IA2526-A	36.33	68	Reprovado	14	50	45
\N	\N	IA2527-A	9.00	72	Reprovado	5	4	18
\N	\N	IA2528-A	21.67	81	Reprovado	35	24	6
\N	\N	IA2529-A	33.67	64	Reprovado	16	38	47
\N	\N	IA2530-A	19.67	69	Reprovado	29	1	29
\N	\N	IA2531-A	33.00	71	Reprovado	35	58	6
\N	\N	IA2532-A	34.00	39	Reprovado	48	21	33
\N	\N	IA2533-A	27.33	54	Reprovado	26	36	20
\N	\N	IA2534-A	28.00	97	Reprovado	43	17	24
\N	\N	IA2535-A	18.00	40	Reprovado	6	19	29
\N	\N	IA2536-A	30.00	37	Reprovado	45	25	20
\N	\N	IA2537-A	29.00	73	Reprovado	31	47	9
\N	\N	IA2538-A	43.67	63	Reprovado	25	47	59
\N	\N	IA2539-A	22.00	72	Reprovado	52	13	1
\N	\N	IA2540-A	44.33	54	Reprovado	42	57	34
\N	\N	IA2541-A	37.67	47	Reprovado	53	9	51
\N	\N	IA2542-A	33.67	34	Reprovado	41	29	31
\N	\N	IA2543-A	30.67	64	Reprovado	28	20	44
\N	\N	IA2544-A	29.00	51	Reprovado	27	19	41
\N	\N	IA2545-A	11.67	45	Reprovado	1	18	16
\N	\N	IA2546-A	24.67	92	Reprovado	54	14	6
\N	\N	IA2547-A	30.33	94	Reprovado	53	33	5
\N	\N	IA2548-A	19.33	32	Reprovado	11	33	14
\N	\N	IA2549-A	26.00	48	Reprovado	30	42	6
\N	\N	IA2550-A	38.33	36	Reprovado	44	49	22
\N	\N	IA2551-A	41.67	75	Reprovado	45	24	56
\N	\N	IA2552-A	25.67	59	Reprovado	47	18	12
\N	\N	IA2553-A	20.33	63	Reprovado	49	7	5
\N	\N	IA2554-A	21.00	69	Reprovado	18	12	33
\N	\N	IA2555-A	35.00	66	Reprovado	35	33	37
\N	\N	IA2556-A	24.00	61	Reprovado	4	19	49
\N	\N	IA2557-A	38.00	45	Reprovado	18	45	51
MAT04925	ALU0821	IA805-A	77.67	86	Aprovado	66	78	89
MAT04901	ALU0817	IA705-A	77.33	78	Aprovado	81	65	86
MAT03065	ALU0511	IA605-B	79.33	96	Aprovado	67	82	89
MAT04938	ALU0823	IA406-B	72.67	84	Aprovado	71	64	83
MAT00162	ALU0027	IA206-B	74.33	81	Aprovado	67	90	66
MAT04920	ALU0820	IA206-A	86.33	86	Aprovado	70	92	97
MAT04911	ALU0819	IA203-B	39.00	45	Reprovado	55	34	28
MAT04940	ALU0824	IA302-B	27.00	67	Reprovado	38	12	31
MAT04913	ALU0819	IA205-B	34.33	91	Reprovado	38	12	53
MAT04917	ALU0820	IA203-A	21.33	99	Reprovado	51	0	13
MAT04869	ALU0812	IA403-A	24.00	76	Reprovado	15	1	56
MAT04929	ALU0822	IA403-B	15.67	85	Reprovado	17	21	9
MAT04868	ALU0812	IA402-A	29.67	65	Reprovado	49	22	18
MAT04870	ALU0812	IA404-A	42.00	41	Reprovado	47	21	58
MAT04924	ALU0821	IA804-A	32.00	96	Reprovado	10	48	38
MAT05053	ALU0843	IA701-B	40.00	100	Reprovado	32	51	37
MAT04871	ALU0812	IA405-A	46.67	61	Reprovado	44	42	54
MAT03592	ALU0599	IA704-B	47.00	51	Reprovado	55	58	28
MAT04937	ALU0823	IA405-B	39.00	47	Reprovado	38	34	45
MAT00741	ALU0124	IA803-B	30.33	50	Reprovado	22	53	16
MAT04880	ALU0814	IA202-B	34.00	64	Reprovado	10	57	35
MAT05361	ALU0894	IA303-B	18.33	51	Reprovado	4	49	2
MAT04910	ALU0819	IA202-B	27.33	85	Reprovado	24	2	56
MAT04922	ALU0821	IA802-A	26.00	74	Reprovado	35	7	36
MAT04921	ALU0821	IA801-A	29.33	68	Reprovado	4	28	56
MAT03225	ALU0538	IA203-A	17.67	92	Reprovado	4	35	14
MAT03477	ALU0580	IA303-A	14.00	73	Reprovado	31	7	4
MAT04864	ALU0811	IA404-B	33.33	42	Reprovado	2	43	55
MAT04900	ALU0817	IA704-A	42.33	99	Reprovado	30	38	59
MAT04915	ALU0820	IA201-A	30.67	53	Reprovado	41	30	21
MAT04936	ALU0823	IA404-B	38.33	40	Reprovado	43	58	14
MAT04872	ALU0812	IA406-A	47.00	54	Reprovado	47	40	54
MAT04881	ALU0814	IA203-B	35.33	46	Reprovado	47	40	19
MAT04916	ALU0820	IA202-A	32.00	91	Reprovado	30	19	47
MAT04866	ALU0811	IA406-B	44.00	43	Reprovado	49	41	42
MAT04848	ALU0808	IA306-B	22.33	34	Reprovado	7	24	36
MAT05785	ALU0965	IA701-B	56.33	65	Reprovado	59	52	58
MAT04923	ALU0821	IA803-A	12.33	32	Reprovado	7	24	6
MAT04906	ALU0818	IA704-A	38.67	50	Reprovado	26	50	40
\N	\N	IA2558-A	15.67	56	Reprovado	29	14	4
\N	\N	IA2559-A	34.67	91	Reprovado	26	57	21
\N	\N	IA2560-A	17.00	52	Reprovado	39	3	9
\N	\N	IA2561-A	48.33	72	Reprovado	40	49	56
\N	\N	IA2562-A	23.00	75	Reprovado	1	27	41
\N	\N	IA2563-A	27.67	95	Reprovado	43	26	14
\N	\N	IA2564-A	19.00	100	Reprovado	9	34	14
\N	\N	IA2565-A	22.33	64	Reprovado	10	44	13
\N	\N	IA2566-A	13.33	72	Reprovado	26	14	0
\N	\N	IA2567-A	23.00	74	Reprovado	59	1	9
\N	\N	IA2568-A	23.33	70	Reprovado	14	0	56
\N	\N	IA2569-A	22.00	69	Reprovado	19	24	23
\N	\N	IA2570-A	34.67	85	Reprovado	10	39	55
\N	\N	IA2571-A	24.33	86	Reprovado	15	9	49
\N	\N	IA2572-A	16.67	39	Reprovado	4	37	9
\N	\N	IA2573-A	36.67	60	Reprovado	46	18	46
\N	\N	IA2574-A	16.33	84	Reprovado	9	17	23
\N	\N	IA2575-A	17.33	53	Reprovado	24	17	11
\N	\N	IA2576-A	32.67	91	Reprovado	20	39	39
\N	\N	IA2577-A	12.33	61	Reprovado	15	8	14
\N	\N	IA2578-A	30.33	92	Reprovado	29	28	34
\N	\N	IA2579-A	17.33	46	Reprovado	14	19	19
\N	\N	IA2580-A	35.00	73	Reprovado	5	43	57
\N	\N	IA2581-A	6.33	33	Reprovado	5	0	14
\N	\N	IA2582-A	25.00	91	Reprovado	17	9	49
\N	\N	IA2583-A	26.33	78	Reprovado	25	23	31
\N	\N	IA2584-A	42.33	65	Reprovado	43	35	49
\N	\N	IA2585-A	41.33	33	Reprovado	31	40	53
\N	\N	IA2586-A	41.67	56	Reprovado	29	50	46
\N	\N	IA2587-A	17.67	35	Reprovado	14	11	28
\N	\N	IA2588-A	17.33	71	Reprovado	32	0	20
\N	\N	IA2589-A	15.33	60	Reprovado	2	17	27
\N	\N	IA2590-A	26.33	67	Reprovado	13	58	8
\N	\N	IA2591-A	30.00	37	Reprovado	18	26	46
\N	\N	IA2592-A	26.00	65	Reprovado	39	23	16
\N	\N	IA2593-A	17.67	58	Reprovado	20	33	0
\N	\N	IA2594-A	26.33	95	Reprovado	27	19	33
\N	\N	IA2595-A	17.67	62	Reprovado	14	32	7
\N	\N	IA2596-A	26.33	53	Reprovado	6	38	35
\N	\N	IA2597-A	9.67	67	Reprovado	12	2	15
\N	\N	IA2598-A	25.00	54	Reprovado	46	7	22
\N	\N	IA2599-A	12.33	81	Reprovado	19	14	4
\N	\N	IA2600-A	26.33	34	Reprovado	29	10	40
\N	\N	IA2601-A	44.00	83	Reprovado	34	47	51
\N	\N	IA2602-A	23.33	52	Reprovado	32	34	4
\N	\N	IA2603-A	51.67	81	Reprovado	53	54	48
\N	\N	IA2604-A	38.33	44	Reprovado	54	14	47
\N	\N	IA2605-A	35.33	48	Reprovado	19	30	57
\N	\N	IA2606-A	24.33	36	Reprovado	40	21	12
\N	\N	IA2607-A	29.67	47	Reprovado	36	38	15
\N	\N	IA2608-A	47.67	73	Reprovado	44	49	50
\N	\N	IA2609-A	48.33	33	Reprovado	56	41	48
MAT03465	ALU0578	IA203-A	68.00	75	Aprovado	63	75	66
MAT04989	ALU0832	IA703-B	83.67	95	Aprovado	90	76	85
MAT05040	ALU0840	IA606-B	84.00	87	Aprovado	84	75	93
MAT00097	ALU0017	IA501-B	90.00	98	Aprovado	100	89	81
MAT05027	ALU0838	IA505-A	73.33	92	Aprovado	74	73	73
MAT05010	ALU0835	IA306-B	79.67	82	Aprovado	79	69	91
MAT05554	ALU0926	IA704-B	38.33	48	Reprovado	48	55	12
MAT04993	ALU0833	IA601-B	19.67	48	Reprovado	17	22	20
MAT02753	ALU0459	IA705-A	27.67	83	Reprovado	9	35	39
MAT04981	ALU0831	IA501-B	53.33	54	Reprovado	49	55	56
MAT04987	ALU0832	IA701-B	15.00	46	Reprovado	27	13	5
MAT04992	ALU0832	IA706-B	55.33	78	Reprovado	54	57	55
MAT04968	ALU0828	IA806-B	21.67	80	Reprovado	27	35	3
MAT05843	ALU0974	IA305-B	25.67	32	Reprovado	1	59	17
MAT05021	ALU0837	IA405-A	39.00	60	Reprovado	50	54	13
MAT05017	ALU0837	IA401-A	33.00	35	Reprovado	54	31	14
MAT04205	ALU0701	IA705-B	37.00	55	Reprovado	29	24	58
MAT03804	ALU0634	IA306-B	35.67	93	Reprovado	52	2	53
MAT05028	ALU0838	IA506-A	31.33	59	Reprovado	53	31	10
MAT05031	ALU0839	IA203-B	32.33	76	Reprovado	2	46	49
MAT04966	ALU0828	IA804-B	17.00	56	Reprovado	42	8	1
MAT04969	ALU0829	IA401-A	30.00	88	Reprovado	15	51	24
MAT04990	ALU0832	IA704-B	37.00	61	Reprovado	27	49	35
MAT03108	ALU0518	IA106-B	46.33	57	Reprovado	54	27	58
MAT04994	ALU0833	IA602-B	21.33	87	Reprovado	44	2	18
MAT05026	ALU0838	IA504-A	39.67	80	Reprovado	51	43	25
MAT04995	ALU0833	IA603-B	14.33	46	Reprovado	34	7	2
MAT01668	ALU0278	IA506-B	41.67	44	Reprovado	28	57	40
MAT05043	ALU0841	IA603-B	22.00	65	Reprovado	32	0	34
MAT05029	ALU0839	IA201-B	17.67	37	Reprovado	2	30	21
MAT05041	ALU0841	IA601-B	29.00	75	Reprovado	36	48	3
MAT04988	ALU0832	IA702-B	36.00	56	Reprovado	14	41	53
MAT04991	ALU0832	IA705-B	32.00	56	Reprovado	36	53	7
MAT04996	ALU0833	IA604-B	33.33	50	Reprovado	29	14	57
MAT05146	ALU0858	IA204-B	42.67	65	Reprovado	18	56	54
MAT05002	ALU0834	IA104-B	11.67	48	Reprovado	19	12	4
MAT05019	ALU0837	IA403-A	31.67	91	Reprovado	16	52	27
\N	\N	IA2610-A	36.67	39	Reprovado	49	12	49
\N	\N	IA2611-A	36.33	43	Reprovado	10	49	50
\N	\N	IA2612-A	32.33	64	Reprovado	2	39	56
\N	\N	IA2613-A	46.00	53	Reprovado	57	33	48
\N	\N	IA2614-A	42.00	89	Reprovado	42	31	53
\N	\N	IA2615-A	33.33	83	Reprovado	53	2	45
\N	\N	IA2616-A	24.33	98	Reprovado	9	23	41
\N	\N	IA2617-A	15.67	80	Reprovado	6	6	35
\N	\N	IA2618-A	46.33	39	Reprovado	49	44	46
\N	\N	IA2619-A	24.00	47	Reprovado	56	14	2
\N	\N	IA2620-A	24.33	48	Reprovado	16	55	2
\N	\N	IA2621-A	39.00	45	Reprovado	45	37	35
\N	\N	IA2622-A	22.33	80	Reprovado	28	32	7
\N	\N	IA2623-A	43.33	64	Reprovado	31	43	56
\N	\N	IA2624-A	27.00	78	Reprovado	38	32	11
\N	\N	IA2625-A	43.00	98	Reprovado	48	52	29
\N	\N	IA2626-A	28.33	34	Reprovado	24	11	50
\N	\N	IA2627-A	39.00	48	Reprovado	52	30	35
\N	\N	IA2628-A	40.33	42	Reprovado	29	36	56
\N	\N	IA2629-A	9.33	58	Reprovado	11	1	16
\N	\N	IA2630-A	22.67	87	Reprovado	12	30	26
\N	\N	IA2631-A	21.33	98	Reprovado	12	39	13
\N	\N	IA2632-A	40.00	89	Reprovado	37	40	43
\N	\N	IA2633-A	34.00	67	Reprovado	21	45	36
\N	\N	IA2634-A	33.33	76	Reprovado	49	35	16
\N	\N	IA2635-A	31.67	49	Reprovado	52	26	17
\N	\N	IA2636-A	25.33	42	Reprovado	58	1	17
\N	\N	IA2637-A	44.33	68	Reprovado	53	45	35
\N	\N	IA2638-A	23.33	92	Reprovado	10	22	38
\N	\N	IA2639-A	24.67	53	Reprovado	3	18	53
\N	\N	IA2640-A	12.33	90	Reprovado	2	10	25
\N	\N	IA2641-A	28.33	82	Reprovado	7	56	22
\N	\N	IA2642-A	39.67	45	Reprovado	46	41	32
\N	\N	IA2643-A	34.67	75	Reprovado	39	34	31
\N	\N	IA2644-A	20.00	50	Reprovado	41	12	7
\N	\N	IA2645-A	35.00	93	Reprovado	28	55	22
\N	\N	IA2646-A	35.67	71	Reprovado	58	4	45
\N	\N	IA2647-A	28.67	47	Reprovado	22	12	52
\N	\N	IA2648-A	27.67	65	Reprovado	16	43	24
\N	\N	IA2649-A	51.33	94	Reprovado	50	59	45
\N	\N	IA2650-A	16.33	47	Reprovado	25	7	17
\N	\N	IA2651-A	34.67	97	Reprovado	36	58	10
\N	\N	IA2652-A	45.67	88	Reprovado	56	44	37
\N	\N	IA2653-A	29.33	35	Reprovado	46	35	7
\N	\N	IA2654-A	29.00	36	Reprovado	44	7	36
\N	\N	IA2655-A	30.67	100	Reprovado	19	14	59
\N	\N	IA2656-A	44.67	59	Reprovado	43	44	47
\N	\N	IA2657-A	28.00	44	Reprovado	51	1	32
\N	\N	IA2658-A	28.33	90	Reprovado	28	25	32
\N	\N	IA2659-A	32.00	47	Reprovado	53	5	38
\N	\N	IA2660-A	37.00	61	Reprovado	52	44	15
\N	\N	IA2661-A	36.33	67	Reprovado	48	50	11
\N	\N	IA2662-A	31.33	33	Reprovado	21	39	34
\N	\N	IA2663-A	15.67	60	Reprovado	18	8	21
MAT05183	ALU0864	IA105-A	87.33	87	Aprovado	97	65	100
MAT05107	ALU0852	IA701-A	86.33	91	Aprovado	99	96	64
MAT05133	ALU0856	IA603-B	82.67	95	Aprovado	92	95	61
MAT05158	ALU0860	IA204-B	76.00	86	Aprovado	85	63	80
MAT05723	ALU0954	IA505-B	74.33	85	Aprovado	66	72	85
MAT05796	ALU0966	IA606-B	66.67	86	Aprovado	61	68	71
MAT05111	ALU0852	IA705-A	89.33	98	Aprovado	92	84	92
MAT02516	ALU0420	IA602-A	87.00	86	Aprovado	89	83	89
MAT05141	ALU0857	IA405-A	38.33	96	Reprovado	46	18	51
MAT05134	ALU0856	IA604-B	42.33	46	Reprovado	28	52	47
MAT05362	ALU0894	IA304-B	31.00	74	Reprovado	37	5	51
MAT02634	ALU0439	IA806-B	28.00	32	Reprovado	10	49	25
MAT05108	ALU0852	IA702-A	31.00	81	Reprovado	39	47	7
MAT05187	ALU0865	IA403-B	29.67	86	Reprovado	10	25	54
MAT05157	ALU0860	IA203-B	25.00	39	Reprovado	15	6	54
MAT05119	ALU0854	IA801-B	37.00	30	Reprovado	50	29	32
MAT05106	ALU0851	IA306-A	38.67	37	Reprovado	18	47	51
MAT05159	ALU0860	IA205-B	44.67	97	Reprovado	46	56	32
MAT01033	ALU0173	IA301-A	51.33	80	Reprovado	55	48	51
MAT05182	ALU0864	IA104-A	38.00	31	Reprovado	34	38	42
MAT05856	ALU0976	IA306-A	30.33	90	Reprovado	34	57	0
MAT05160	ALU0860	IA206-B	27.33	40	Reprovado	9	59	14
MAT03613	ALU0603	IA801-A	20.00	88	Reprovado	34	16	10
MAT00746	ALU0125	IA302-B	37.67	73	Reprovado	38	35	40
MAT05184	ALU0864	IA106-A	21.33	36	Reprovado	5	30	29
MAT05155	ALU0860	IA201-B	40.33	68	Reprovado	52	19	50
MAT03243	ALU0541	IA603-A	40.00	70	Reprovado	26	51	43
MAT05139	ALU0857	IA403-A	28.00	77	Reprovado	52	30	2
MAT02328	ALU0388	IA806-B	34.33	84	Reprovado	19	44	40
MAT05565	ALU0928	IA803-B	38.00	84	Reprovado	38	44	32
MAT03432	ALU0572	IA206-A	21.67	64	Reprovado	9	27	29
MAT05156	ALU0860	IA202-B	49.33	46	Reprovado	58	37	53
MAT05132	ALU0856	IA602-B	41.67	44	Reprovado	25	45	55
MAT02750	ALU0459	IA702-A	23.67	82	Reprovado	17	42	12
MAT05185	ALU0865	IA401-B	57.00	52	Reprovado	57	59	55
MAT04344	ALU0724	IA406-B	33.33	82	Reprovado	38	33	29
MAT03312	ALU0552	IA406-B	18.00	46	Reprovado	5	4	45
\N	\N	IA2664-A	34.67	69	Reprovado	18	50	36
\N	\N	IA2665-A	12.00	74	Reprovado	11	25	0
\N	\N	IA2666-A	27.33	40	Reprovado	7	57	18
\N	\N	IA2667-A	35.00	55	Reprovado	13	48	44
\N	\N	IA2668-A	29.33	85	Reprovado	49	7	32
\N	\N	IA2669-A	39.00	86	Reprovado	52	38	27
\N	\N	IA2670-A	32.67	78	Reprovado	28	50	20
\N	\N	IA2671-A	35.67	66	Reprovado	30	44	33
\N	\N	IA2672-A	31.00	63	Reprovado	49	2	42
\N	\N	IA2673-A	27.33	47	Reprovado	38	25	19
\N	\N	IA2674-A	16.00	81	Reprovado	34	0	14
\N	\N	IA2675-A	37.00	33	Reprovado	22	48	41
\N	\N	IA2676-A	18.67	90	Reprovado	4	22	30
\N	\N	IA2677-A	33.33	95	Reprovado	37	7	56
\N	\N	IA2678-A	14.67	46	Reprovado	8	29	7
\N	\N	IA2679-A	13.33	39	Reprovado	4	10	26
\N	\N	IA2680-A	41.33	73	Reprovado	54	50	20
\N	\N	IA2681-A	20.00	83	Reprovado	14	25	21
\N	\N	IA2682-A	33.67	67	Reprovado	32	52	17
\N	\N	IA2683-A	34.00	32	Reprovado	47	42	13
\N	\N	IA2684-A	29.67	68	Reprovado	22	28	39
\N	\N	IA2685-A	31.67	90	Reprovado	50	29	16
\N	\N	IA2686-A	37.33	50	Reprovado	9	59	44
\N	\N	IA2687-A	36.67	34	Reprovado	27	45	38
\N	\N	IA2688-A	10.00	47	Reprovado	1	23	6
\N	\N	IA2689-A	19.67	82	Reprovado	2	40	17
\N	\N	IA2690-A	41.67	63	Reprovado	54	33	38
\N	\N	IA2691-A	43.00	75	Reprovado	55	17	57
\N	\N	IA2692-A	13.00	40	Reprovado	16	17	6
\N	\N	IA2693-A	27.33	32	Reprovado	4	20	58
\N	\N	IA2694-A	29.33	94	Reprovado	1	42	45
\N	\N	IA2695-A	25.00	79	Reprovado	23	31	21
\N	\N	IA2696-A	19.67	57	Reprovado	26	10	23
\N	\N	IA2697-A	30.67	37	Reprovado	57	1	34
\N	\N	IA2698-A	52.00	45	Reprovado	47	54	55
\N	\N	IA2699-A	38.67	71	Reprovado	49	26	41
\N	\N	IA2700-A	42.00	96	Reprovado	14	53	59
\N	\N	IA2701-A	45.67	41	Reprovado	56	49	32
\N	\N	IA2702-A	44.33	37	Reprovado	34	50	49
\N	\N	IA2703-A	24.33	81	Reprovado	55	10	8
\N	\N	IA2704-A	40.00	34	Reprovado	32	43	45
\N	\N	IA2705-A	22.67	66	Reprovado	33	12	23
\N	\N	IA2706-A	35.67	67	Reprovado	51	36	20
\N	\N	IA2707-A	20.67	38	Reprovado	48	11	3
\N	\N	IA2708-A	21.00	60	Reprovado	32	26	5
\N	\N	IA2709-A	37.67	73	Reprovado	0	55	58
\N	\N	IA2710-A	17.33	40	Reprovado	5	42	5
\N	\N	IA2711-A	38.00	89	Reprovado	40	31	43
\N	\N	IA2712-A	47.00	35	Reprovado	41	53	47
\N	\N	IA2713-A	33.67	77	Reprovado	33	23	45
\N	\N	IA2714-A	47.33	35	Reprovado	51	34	57
\N	\N	IA2715-A	30.33	83	Reprovado	4	51	36
\N	\N	IA2716-A	40.00	41	Reprovado	59	33	28
\N	\N	IA2717-A	47.67	85	Reprovado	59	31	53
MAT05247	ALU0875	IA703-B	91.00	78	Aprovado	91	98	84
MAT05210	ALU0869	IA802-B	86.00	86	Aprovado	88	71	99
MAT02025	ALU0338	IA103-B	87.33	99	Aprovado	95	68	99
MAT05262	ALU0877	IA106-B	77.67	84	Aprovado	72	84	77
MAT05218	ALU0870	IA804-B	82.33	78	Aprovado	88	90	69
MAT01542	ALU0257	IA406-B	34.67	86	Reprovado	35	43	26
MAT05274	ALU0879	IA306-B	42.00	66	Reprovado	31	47	48
MAT05225	ALU0871	IA705-A	41.00	57	Reprovado	59	39	25
MAT05249	ALU0875	IA705-B	36.67	32	Reprovado	1	59	50
MAT05261	ALU0877	IA105-B	21.00	36	Reprovado	5	8	50
MAT05214	ALU0869	IA806-B	20.00	48	Reprovado	33	26	1
MAT05217	ALU0870	IA803-B	25.67	30	Reprovado	44	1	32
MAT05227	ALU0872	IA201-A	31.33	63	Reprovado	18	53	23
MAT05220	ALU0870	IA806-B	31.67	42	Reprovado	19	46	30
MAT05226	ALU0871	IA706-A	27.00	46	Reprovado	28	28	25
MAT05216	ALU0870	IA802-B	47.33	60	Reprovado	45	45	52
MAT05269	ALU0879	IA301-B	23.33	63	Reprovado	47	2	21
MAT00411	ALU0069	IA103-A	15.67	52	Reprovado	24	23	0
MAT05243	ALU0874	IA205-B	23.33	53	Reprovado	22	32	16
MAT01559	ALU0260	IA805-B	21.33	81	Reprovado	22	8	34
MAT05234	ALU0873	IA302-B	23.67	53	Reprovado	9	38	24
MAT05230	ALU0872	IA204-A	31.33	31	Reprovado	55	14	25
MAT05251	ALU0876	IA801-B	22.33	100	Reprovado	53	3	11
MAT05209	ALU0869	IA801-B	48.00	65	Reprovado	51	39	54
MAT05219	ALU0870	IA805-B	13.33	66	Reprovado	3	6	31
MAT05275	ALU0880	IA101-B	51.67	43	Reprovado	56	41	58
MAT05245	ALU0875	IA701-B	21.33	74	Reprovado	3	52	9
MAT05270	ALU0879	IA302-B	19.33	45	Reprovado	28	25	5
MAT05222	ALU0871	IA702-A	27.67	46	Reprovado	56	27	0
MAT04960	ALU0827	IA204-B	15.33	56	Reprovado	23	22	1
MAT05035	ALU0840	IA601-B	28.33	71	Reprovado	33	7	45
MAT05224	ALU0871	IA704-A	32.00	60	Reprovado	57	8	31
MAT05228	ALU0872	IA202-A	30.00	63	Reprovado	17	36	37
MAT05253	ALU0876	IA803-B	35.67	87	Reprovado	59	33	15
MAT05242	ALU0874	IA204-B	45.00	50	Reprovado	51	56	28
MAT05232	ALU0872	IA206-A	31.33	58	Reprovado	40	39	15
MAT05257	ALU0877	IA101-B	9.00	93	Reprovado	19	8	0
MAT05256	ALU0876	IA806-B	29.00	94	Reprovado	21	29	37
MAT05211	ALU0869	IA803-B	34.00	36	Reprovado	40	47	15
MAT05273	ALU0879	IA305-B	31.67	71	Reprovado	44	44	7
\N	\N	IA2718-A	26.33	89	Reprovado	40	25	14
\N	\N	IA2719-A	24.00	58	Reprovado	19	12	41
\N	\N	IA2720-A	9.33	95	Reprovado	10	10	8
\N	\N	IA2721-A	33.00	94	Reprovado	17	36	46
\N	\N	IA2722-A	33.33	98	Reprovado	32	23	45
\N	\N	IA2723-A	9.33	55	Reprovado	0	19	9
\N	\N	IA2724-A	30.00	61	Reprovado	52	24	14
\N	\N	IA2725-A	15.33	65	Reprovado	29	6	11
\N	\N	IA2726-A	44.33	46	Reprovado	45	53	35
\N	\N	IA2727-A	21.67	53	Reprovado	37	20	8
\N	\N	IA2728-A	31.00	63	Reprovado	28	31	34
\N	\N	IA2729-A	16.33	34	Reprovado	27	4	18
\N	\N	IA2730-A	45.33	43	Reprovado	31	57	48
\N	\N	IA2731-A	31.00	90	Reprovado	41	1	51
\N	\N	IA2732-A	26.67	81	Reprovado	35	20	25
\N	\N	IA2733-A	20.67	49	Reprovado	15	7	40
\N	\N	IA2734-A	19.33	78	Reprovado	42	0	16
\N	\N	IA2735-A	36.33	79	Reprovado	57	21	31
\N	\N	IA2736-A	40.33	53	Reprovado	44	23	54
\N	\N	IA2737-A	28.33	44	Reprovado	22	51	12
\N	\N	IA2738-A	29.00	94	Reprovado	37	34	16
\N	\N	IA2739-A	41.67	50	Reprovado	50	18	57
\N	\N	IA2740-A	32.33	51	Reprovado	28	49	20
\N	\N	IA2741-A	48.67	63	Reprovado	58	31	57
\N	\N	IA2742-A	34.33	69	Reprovado	21	43	39
\N	\N	IA2743-A	29.33	54	Reprovado	1	38	49
\N	\N	IA2744-A	31.67	94	Reprovado	36	49	10
\N	\N	IA2745-A	43.67	75	Reprovado	51	48	32
\N	\N	IA2746-A	8.00	48	Reprovado	10	4	10
\N	\N	IA2747-A	27.33	67	Reprovado	37	25	20
\N	\N	IA2748-A	25.67	69	Reprovado	25	45	7
\N	\N	IA2749-A	27.00	74	Reprovado	24	8	49
\N	\N	IA2750-A	42.33	35	Reprovado	57	25	45
\N	\N	IA2751-A	25.33	67	Reprovado	21	0	55
\N	\N	IA2752-A	42.00	60	Reprovado	49	26	51
\N	\N	IA2753-A	29.33	99	Reprovado	19	27	42
\N	\N	IA2754-A	24.67	70	Reprovado	10	45	19
\N	\N	IA2755-A	27.00	47	Reprovado	36	28	17
\N	\N	IA2756-A	19.33	67	Reprovado	9	45	4
\N	\N	IA2757-A	21.00	99	Reprovado	4	29	30
\N	\N	IA2758-A	22.67	43	Reprovado	21	25	22
\N	\N	IA2759-A	15.67	72	Reprovado	9	37	1
\N	\N	IA2760-A	26.67	83	Reprovado	18	26	36
\N	\N	IA2761-A	33.00	57	Reprovado	40	41	18
\N	\N	IA2762-A	48.33	53	Reprovado	35	55	55
\N	\N	IA2763-A	23.33	69	Reprovado	41	27	2
\N	\N	IA2764-A	21.33	38	Reprovado	17	35	12
\N	\N	IA2765-A	32.67	73	Reprovado	49	35	14
\N	\N	IA2766-A	23.33	81	Reprovado	25	2	43
\N	\N	IA2767-A	37.33	73	Reprovado	29	39	44
\N	\N	IA2768-A	23.00	74	Reprovado	1	19	49
MAT03976	ALU0663	IA804-B	86.33	86	Aprovado	99	62	98
MAT02695	ALU0450	IA501-A	83.67	83	Aprovado	69	96	86
MAT05286	ALU0881	IA106-A	84.00	88	Aprovado	76	90	86
MAT05295	ALU0883	IA703-B	92.33	95	Aprovado	86	95	96
MAT05278	ALU0880	IA104-B	82.00	88	Aprovado	87	70	89
MAT05281	ALU0881	IA101-A	32.00	63	Reprovado	34	45	17
MAT03733	ALU0623	IA601-A	33.67	75	Reprovado	44	56	1
MAT00305	ALU0051	IA105-A	29.00	66	Reprovado	27	48	12
MAT00519	ALU0087	IA803-B	6.33	99	Reprovado	0	17	2
MAT05340	ALU0890	IA106-A	33.00	82	Reprovado	39	25	35
MAT03927	ALU0655	IA803-A	26.33	58	Reprovado	9	30	40
MAT03246	ALU0541	IA606-A	45.00	80	Reprovado	40	54	41
MAT05283	ALU0881	IA103-A	16.00	48	Reprovado	22	7	19
MAT03757	ALU0627	IA101-B	27.67	56	Reprovado	33	11	39
MAT05324	ALU0888	IA502-B	52.00	38	Reprovado	47	56	53
MAT02344	ALU0391	IA704-A	28.67	88	Reprovado	45	9	32
MAT05334	ALU0889	IA506-B	41.33	67	Reprovado	48	57	19
MAT05299	ALU0884	IA601-A	43.33	72	Reprovado	42	46	42
MAT01301	ALU0217	IA505-B	16.33	71	Reprovado	2	3	44
MAT05294	ALU0883	IA702-B	37.33	73	Reprovado	12	45	55
MAT02249	ALU0375	IA605-A	29.00	83	Reprovado	24	28	35
MAT02357	ALU0393	IA405-B	36.67	54	Reprovado	57	47	6
MAT05339	ALU0890	IA105-A	47.33	65	Reprovado	53	53	36
MAT01541	ALU0257	IA405-B	7.33	48	Reprovado	7	12	3
MAT05325	ALU0888	IA503-B	26.67	49	Reprovado	23	50	7
MAT05303	ALU0884	IA605-A	14.00	98	Reprovado	6	1	35
MAT05147	ALU0858	IA205-B	48.00	47	Reprovado	50	52	42
MAT05349	ALU0892	IA403-B	4.67	53	Reprovado	7	6	1
MAT05343	ALU0891	IA303-B	29.00	82	Reprovado	30	23	34
MAT05342	ALU0891	IA302-B	21.33	63	Reprovado	58	3	3
MAT05347	ALU0892	IA401-B	32.67	46	Reprovado	19	48	31
MAT05345	ALU0891	IA305-B	30.33	32	Reprovado	1	44	46
MAT05298	ALU0883	IA706-B	34.33	31	Reprovado	57	23	23
MAT05348	ALU0892	IA402-B	40.67	69	Reprovado	59	38	25
MAT05360	ALU0894	IA302-B	31.33	34	Reprovado	39	19	36
MAT05296	ALU0883	IA704-B	35.33	42	Reprovado	11	54	41
MAT05430	ALU0905	IA206-B	81.67	92	Aprovado	88	64	93
MAT03209	ALU0535	IA105-B	91.33	76	Aprovado	97	84	93
MAT05921	ALU0987	IA505-A	92.33	82	Aprovado	94	87	96
MAT00568	ALU0095	IA304-A	80.67	78	Aprovado	97	66	79
MAT00581	ALU0097	IA605-A	72.00	80	Aprovado	74	69	73
MAT03917	ALU0653	IA605-B	33.33	46	Reprovado	22	30	48
MAT05398	ALU0900	IA304-A	15.67	70	Reprovado	11	30	6
MAT01621	ALU0271	IA101-B	38.67	38	Reprovado	53	54	9
MAT04770	ALU0795	IA506-B	34.33	84	Reprovado	17	38	48
MAT00753	ALU0126	IA703-B	31.33	64	Reprovado	51	38	5
MAT02177	ALU0363	IA805-B	24.67	59	Reprovado	9	59	6
MAT05403	ALU0901	IA203-A	33.33	39	Reprovado	45	36	19
MAT05136	ALU0856	IA606-B	35.33	35	Reprovado	30	25	51
MAT05012	ALU0836	IA602-B	40.00	93	Reprovado	22	53	45
MAT01493	ALU0249	IA205-A	35.67	30	Reprovado	42	14	51
MAT05436	ALU0906	IA106-B	36.67	90	Reprovado	50	6	54
MAT05473	ALU0913	IA201-B	36.00	41	Reprovado	17	36	55
MAT05450	ALU0909	IA402-B	23.67	70	Reprovado	49	21	1
MAT04199	ALU0700	IA505-B	38.00	36	Reprovado	53	7	54
MAT03182	ALU0531	IA302-B	50.33	63	Reprovado	49	58	44
MAT05448	ALU0908	IA706-B	40.00	60	Reprovado	54	48	18
MAT05461	ALU0911	IA501-A	23.33	42	Reprovado	51	0	19
MAT05493	ALU0916	IA403-B	25.33	52	Reprovado	3	44	29
MAT05445	ALU0908	IA703-B	30.33	37	Reprovado	28	50	13
MAT05229	ALU0872	IA203-A	33.00	77	Reprovado	28	23	48
MAT05427	ALU0905	IA203-B	17.33	85	Reprovado	34	5	13
MAT02369	ALU0395	IA305-B	26.67	82	Reprovado	28	3	49
MAT04479	ALU0747	IA703-B	40.33	81	Reprovado	58	10	53
MAT05474	ALU0913	IA202-B	35.33	80	Reprovado	36	29	41
MAT05558	ALU0927	IA602-B	19.00	89	Reprovado	15	15	27
MAT05399	ALU0900	IA305-A	20.00	48	Reprovado	0	26	34
MAT02643	ALU0441	IA603-B	89.00	84	Aprovado	86	89	92
MAT04247	ALU0708	IA805-B	84.00	80	Aprovado	97	71	84
MAT02791	ALU0466	IA601-B	69.67	85	Aprovado	72	64	73
MAT05588	ALU0932	IA302-B	24.33	66	Reprovado	36	4	33
MAT02041	ALU0341	IA401-B	42.67	85	Reprovado	26	48	54
MAT04201	ALU0701	IA701-B	30.67	72	Reprovado	56	22	14
MAT05615	ALU0936	IA305-B	29.67	89	Reprovado	33	25	31
MAT05617	ALU0937	IA501-B	25.00	81	Reprovado	38	2	35
MAT05667	ALU0945	IA303-B	16.33	100	Reprovado	43	4	2
MAT05652	ALU0942	IA706-B	18.33	70	Reprovado	4	24	27
MAT01431	ALU0239	IA103-B	40.33	43	Reprovado	51	47	23
MAT05641	ALU0941	IA201-B	40.00	46	Reprovado	17	52	51
MAT04845	ALU0808	IA303-B	25.67	63	Reprovado	8	44	25
MAT05638	ALU0940	IA304-B	35.67	51	Reprovado	31	52	24
MAT05612	ALU0936	IA302-B	41.67	40	Reprovado	22	54	49
MAT05596	ALU0933	IA704-B	21.67	68	Reprovado	19	3	43
MAT02121	ALU0354	IA703-B	33.00	79	Reprovado	41	30	28
MAT03235	ALU0540	IA401-A	20.00	67	Reprovado	0	38	22
MAT00678	ALU0113	IA706-B	34.00	45	Reprovado	53	35	14
MAT05616	ALU0936	IA306-B	32.33	91	Reprovado	54	43	0
MAT05589	ALU0932	IA303-B	20.00	42	Reprovado	15	37	8
MAT05582	ALU0931	IA502-A	18.67	47	Reprovado	53	1	2
MAT05587	ALU0932	IA301-B	20.33	85	Reprovado	21	34	6
MAT05668	ALU0945	IA304-B	48.00	68	Reprovado	38	53	53
MAT05592	ALU0932	IA306-B	27.67	46	Reprovado	16	50	17
MAT05632	ALU0939	IA104-B	33.33	50	Reprovado	59	26	15
MAT05614	ALU0936	IA304-B	23.00	73	Reprovado	9	29	31
MAT05590	ALU0932	IA304-B	49.67	59	Reprovado	56	55	38
MAT04828	ALU0805	IA804-A	20.00	86	Reprovado	3	10	47
MAT05583	ALU0931	IA503-A	37.00	68	Reprovado	31	29	51
MAT05627	ALU0938	IA305-B	36.67	73	Reprovado	45	13	52
MAT05666	ALU0945	IA302-B	40.33	91	Reprovado	53	38	30
MAT05650	ALU0942	IA704-B	33.33	89	Reprovado	47	1	52
MAT05586	ALU0931	IA506-A	32.67	33	Reprovado	14	49	35
MAT05639	ALU0940	IA305-B	20.67	56	Reprovado	25	37	0
MAT05665	ALU0945	IA301-B	35.00	86	Reprovado	43	13	49
MAT05630	ALU0939	IA102-B	23.33	44	Reprovado	41	7	22
MAT05095	ALU0850	IA101-B	73.33	96	Aprovado	60	89	71
MAT05190	ALU0865	IA406-B	72.33	90	Aprovado	86	69	62
MAT04024	ALU0671	IA804-A	80.33	76	Aprovado	98	78	65
MAT05022	ALU0837	IA406-A	81.33	100	Aprovado	86	75	83
MAT05712	ALU0952	IA206-B	79.00	78	Aprovado	75	90	72
MAT05790	ALU0965	IA706-B	67.00	93	Aprovado	60	70	71
MAT05748	ALU0958	IA506-B	79.00	85	Aprovado	69	88	80
MAT00679	ALU0114	IA801-B	85.00	97	Aprovado	81	85	89
MAT05757	ALU0960	IA803-A	64.67	99	Aprovado	63	68	63
MAT05767	ALU0962	IA301-B	73.00	83	Aprovado	74	61	84
MAT05708	ALU0952	IA202-B	26.33	67	Reprovado	25	6	48
MAT04464	ALU0744	IA306-B	21.67	89	Reprovado	8	4	53
MAT01563	ALU0261	IA103-A	18.67	85	Reprovado	17	3	36
MAT03712	ALU0619	IA204-B	29.00	67	Reprovado	50	3	34
MAT01344	ALU0224	IA706-B	27.33	98	Reprovado	29	36	17
MAT05739	ALU0957	IA503-B	26.67	86	Reprovado	24	29	27
MAT01157	ALU0193	IA505-A	31.00	46	Reprovado	11	23	59
MAT05740	ALU0957	IA504-B	34.67	46	Reprovado	18	56	30
MAT05709	ALU0952	IA203-B	27.00	33	Reprovado	51	11	19
MAT05742	ALU0957	IA506-B	37.00	70	Reprovado	12	42	57
MAT03061	ALU0511	IA601-B	23.00	84	Reprovado	9	12	48
MAT02733	ALU0456	IA603-A	8.67	86	Reprovado	9	8	9
MAT01294	ALU0216	IA204-A	12.33	95	Reprovado	11	15	11
MAT05716	ALU0953	IA404-B	34.67	54	Reprovado	31	34	39
MAT05756	ALU0960	IA802-A	16.33	39	Reprovado	17	14	18
MAT05745	ALU0958	IA503-B	33.00	41	Reprovado	24	59	16
MAT05741	ALU0957	IA505-B	31.00	46	Reprovado	59	4	30
MAT00838	ALU0140	IA204-A	19.33	51	Reprovado	33	17	8
MAT05798	ALU0967	IA402-B	28.33	52	Reprovado	22	22	41
MAT03602	ALU0601	IA602-B	28.33	54	Reprovado	18	29	38
MAT05869	ALU0979	IA601-B	80.67	95	Aprovado	79	79	84
MAT05907	ALU0985	IA803-B	64.00	97	Aprovado	60	69	63
MAT05905	ALU0985	IA801-B	81.67	96	Aprovado	72	89	84
MAT05876	ALU0980	IA202-B	28.33	78	Reprovado	39	37	9
MAT00465	ALU0078	IA103-A	17.00	94	Reprovado	17	11	23
MAT05874	ALU0979	IA606-B	42.67	48	Reprovado	38	53	37
MAT05918	ALU0987	IA502-A	39.67	81	Reprovado	47	30	42
MAT04565	ALU0761	IA705-A	39.00	68	Reprovado	20	47	50
MAT05893	ALU0983	IA601-B	29.67	79	Reprovado	1	42	46
MAT02665	ALU0445	IA801-B	30.33	94	Reprovado	6	36	49
MAT05899	ALU0984	IA501-B	29.00	52	Reprovado	56	24	7
MAT05871	ALU0979	IA603-B	11.67	73	Reprovado	13	13	9
MAT05870	ALU0979	IA602-B	18.00	67	Reprovado	9	25	20
MAT05927	ALU0988	IA205-B	27.67	78	Reprovado	33	44	6
MAT05882	ALU0981	IA602-B	19.67	63	Reprovado	41	12	6
MAT01573	ALU0263	IA801-B	20.00	71	Reprovado	11	20	29
MAT05903	ALU0984	IA505-B	10.33	58	Reprovado	22	5	4
MAT05904	ALU0984	IA506-B	27.33	84	Reprovado	8	50	24
MAT05909	ALU0985	IA805-B	37.67	71	Reprovado	49	9	55
MAT05887	ALU0982	IA201-B	51.33	33	Reprovado	46	51	57
MAT05908	ALU0985	IA804-B	30.67	90	Reprovado	8	57	27
MAT05675	ALU0946	IA105-B	10.00	36	Reprovado	6	24	0
MAT05911	ALU0986	IA601-B	24.00	77	Reprovado	2	54	16
MAT05910	ALU0985	IA806-B	31.33	37	Reprovado	45	14	35
MAT05926	ALU0988	IA204-B	32.33	82	Reprovado	31	10	56
MAT05857	ALU0977	IA101-B	44.67	57	Reprovado	55	23	56
MAT05879	ALU0980	IA205-B	23.00	30	Reprovado	19	27	23
MAT05872	ALU0979	IA604-B	19.00	96	Reprovado	8	12	37
MAT05897	ALU0983	IA605-B	38.33	85	Reprovado	54	48	13
MAT05896	ALU0983	IA604-B	51.67	59	Reprovado	43	56	56
MAT05885	ALU0981	IA605-B	18.33	95	Reprovado	17	10	28
MAT05894	ALU0983	IA602-B	23.33	97	Reprovado	28	39	3
MAT04300	ALU0717	IA104-B	29.33	54	Reprovado	11	54	23
MAT05898	ALU0983	IA606-B	10.00	62	Reprovado	12	12	6
MAT05900	ALU0984	IA502-B	20.33	77	Reprovado	7	53	1
MAT05892	ALU0982	IA206-B	31.67	44	Reprovado	50	5	40
MAT05916	ALU0986	IA606-B	24.67	55	Reprovado	13	52	9
MAT05115	ALU0853	IA403-B	33.67	92	Reprovado	37	6	58
MAT05858	ALU0977	IA102-B	16.00	50	Reprovado	16	31	1
MAT05861	ALU0977	IA105-B	32.33	81	Reprovado	54	15	28
MAT00128	ALU0022	IA402-A	80.00	79	Aprovado	86	74	80
MAT05965	ALU0995	IA601-B	62.67	82	Aprovado	61	62	65
MAT04907	ALU0818	IA705-A	74.33	89	Aprovado	94	69	60
MAT00003	ALU0001	IA203-B	69.00	99	Aprovado	60	78	69
MAT00006	ALU0001	IA206-B	76.67	98	Aprovado	85	78	67
MAT05968	ALU0995	IA604-B	70.00	90	Aprovado	69	67	74
MAT05976	ALU0996	IA106-A	20.00	98	Reprovado	17	20	23
MAT00118	ALU0020	IA704-B	16.67	94	Reprovado	18	13	19
MAT05967	ALU0995	IA603-B	35.00	84	Reprovado	48	41	16
MAT05961	ALU0994	IA803-A	38.67	64	Reprovado	35	39	42
MAT05970	ALU0995	IA606-B	39.00	95	Reprovado	28	41	48
MAT05971	ALU0996	IA101-A	29.33	51	Reprovado	31	0	57
MAT00038	ALU0007	IA502-B	30.33	100	Reprovado	33	33	25
MAT00029	ALU0005	IA405-B	27.00	75	Reprovado	8	56	17
MAT00040	ALU0007	IA504-B	29.00	68	Reprovado	22	32	33
MAT00039	ALU0007	IA503-B	14.67	33	Reprovado	1	34	9
MAT00042	ALU0007	IA506-B	14.00	88	Reprovado	8	19	15
MAT05966	ALU0995	IA602-B	23.33	45	Reprovado	19	32	19
MAT03807	ALU0635	IA403-B	51.33	76	Reprovado	43	53	58
MAT00076	ALU0013	IA704-A	47.00	92	Reprovado	47	38	56
MAT00046	ALU0008	IA204-A	12.67	38	Reprovado	30	8	0
MAT00004	ALU0001	IA204-B	24.33	36	Reprovado	0	47	26
MAT00106	ALU0018	IA604-B	12.67	82	Reprovado	15	4	19
MAT03491	ALU0582	IA205-B	42.67	66	Reprovado	43	28	57
MAT00078	ALU0013	IA706-A	30.33	64	Reprovado	17	56	18
MAT00037	ALU0007	IA501-B	31.33	61	Reprovado	49	31	14
MAT05963	ALU0994	IA805-A	45.00	83	Reprovado	49	56	30
MAT00151	ALU0026	IA401-A	36.33	66	Reprovado	35	55	19
MAT05958	ALU0993	IA406-B	44.00	91	Reprovado	45	41	46
MAT00155	ALU0026	IA405-A	29.67	81	Reprovado	39	10	40
MAT00093	ALU0016	IA203-A	36.67	47	Reprovado	37	27	46
MAT05959	ALU0994	IA801-A	12.67	62	Reprovado	14	20	4
MAT02615	ALU0436	IA205-A	2.67	37	Reprovado	4	4	0
MAT05082	ALU0847	IA806-A	27.67	94	Reprovado	41	41	1
MAT00153	ALU0026	IA403-A	43.00	93	Reprovado	31	49	49
MAT04631	ALU0772	IA805-B	38.00	74	Reprovado	47	14	53
MAT04949	ALU0825	IA505-B	32.00	71	Reprovado	25	45	26
MAT01865	ALU0311	IA405-A	20.33	33	Reprovado	12	16	33
MAT05956	ALU0993	IA404-B	36.67	37	Reprovado	27	39	44
MAT05803	ALU0968	IA501-B	34.67	51	Reprovado	29	26	49
MAT00551	ALU0092	IA105-A	86.33	76	Aprovado	92	67	100
MAT03761	ALU0627	IA105-B	74.67	94	Aprovado	74	68	82
MAT00476	ALU0080	IA202-A	81.33	96	Aprovado	77	99	68
MAT00269	ALU0045	IA105-B	77.00	91	Aprovado	66	79	86
MAT00371	ALU0062	IA205-A	32.33	61	Reprovado	34	12	51
MAT00574	ALU0096	IA104-A	44.33	32	Reprovado	21	54	58
MAT00456	ALU0076	IA806-B	42.67	82	Reprovado	35	46	47
MAT00375	ALU0063	IA803-B	29.00	52	Reprovado	16	21	50
MAT02407	ALU0402	IA301-A	24.00	56	Reprovado	27	24	21
MAT05722	ALU0954	IA504-B	24.33	48	Reprovado	36	26	11
MAT02947	ALU0492	IA701-B	47.67	57	Reprovado	46	53	44
MAT04070	ALU0679	IA102-B	30.33	75	Reprovado	25	34	32
MAT00471	ALU0079	IA403-B	33.00	69	Reprovado	14	47	38
MAT00643	ALU0108	IA401-A	22.67	43	Reprovado	10	46	12
MAT00459	ALU0077	IA403-A	24.00	81	Reprovado	9	51	12
MAT00569	ALU0095	IA305-A	18.33	65	Reprovado	12	10	33
MAT00570	ALU0095	IA306-A	28.00	35	Reprovado	15	43	26
MAT00458	ALU0077	IA402-A	29.67	58	Reprovado	18	35	36
MAT00442	ALU0074	IA304-B	19.67	60	Reprovado	45	3	11
MAT00549	ALU0092	IA103-A	25.00	46	Reprovado	1	31	43
MAT00385	ALU0065	IA701-A	9.00	87	Reprovado	19	3	5
MAT00367	ALU0062	IA201-A	17.33	95	Reprovado	1	19	32
MAT00629	ALU0105	IA805-B	24.00	51	Reprovado	32	11	29
MAT00640	ALU0107	IA304-B	24.33	81	Reprovado	38	21	14
MAT00474	ALU0079	IA406-B	27.33	47	Reprovado	32	8	42
MAT05851	ALU0976	IA301-A	31.67	43	Reprovado	47	35	13
MAT00440	ALU0074	IA302-B	24.00	73	Reprovado	26	14	32
MAT00548	ALU0092	IA102-A	31.67	30	Reprovado	29	28	38
MAT03939	ALU0657	IA803-B	42.33	77	Reprovado	39	30	58
MAT00630	ALU0105	IA806-B	33.67	62	Reprovado	55	5	41
MAT00473	ALU0079	IA405-B	38.33	42	Reprovado	41	35	39
MAT03689	ALU0615	IA305-B	10.00	30	Reprovado	3	5	22
MAT05165	ALU0861	IA205-B	35.00	85	Reprovado	49	27	29
MAT00347	ALU0058	IA105-B	33.00	84	Reprovado	54	38	7
MAT00550	ALU0092	IA104-A	37.00	51	Reprovado	46	23	42
MAT00444	ALU0074	IA306-B	44.33	78	Reprovado	59	47	27
MAT00453	ALU0076	IA803-B	48.33	47	Reprovado	56	40	49
MAT00573	ALU0096	IA103-A	17.67	76	Reprovado	6	0	47
MAT00469	ALU0079	IA401-B	36.33	44	Reprovado	37	49	23
MAT00436	ALU0073	IA604-B	28.00	44	Reprovado	2	38	44
MAT01060	ALU0177	IA704-B	65.67	97	Aprovado	65	65	67
MAT01069	ALU0179	IA101-B	85.33	75	Aprovado	93	95	68
MAT05208	ALU0868	IA306-B	84.67	75	Aprovado	81	94	79
MAT00873	ALU0146	IA203-B	66.67	94	Aprovado	75	62	63
MAT05282	ALU0881	IA102-A	84.33	80	Aprovado	93	67	93
MAT01050	ALU0175	IA306-B	78.33	76	Aprovado	68	91	76
MAT00770	ALU0129	IA602-B	84.00	83	Aprovado	95	82	75
MAT05760	ALU0960	IA806-A	86.67	97	Aprovado	86	79	95
MAT00996	ALU0166	IA106-B	89.33	82	Aprovado	74	100	94
MAT01382	ALU0231	IA502-B	35.67	31	Reprovado	42	37	28
MAT00842	ALU0141	IA802-B	23.33	94	Reprovado	13	36	21
MAT02030	ALU0339	IA302-B	33.33	31	Reprovado	33	44	23
MAT00992	ALU0166	IA102-B	40.67	90	Reprovado	54	23	45
MAT00807	ALU0135	IA303-B	37.67	78	Reprovado	41	29	43
MAT00879	ALU0147	IA203-B	38.00	85	Reprovado	53	8	53
MAT02202	ALU0367	IA806-B	28.00	73	Reprovado	28	1	55
MAT04419	ALU0737	IA703-B	8.00	55	Reprovado	7	6	11
MAT01827	ALU0305	IA303-B	22.33	88	Reprovado	1	27	39
MAT00771	ALU0129	IA603-B	28.00	45	Reprovado	18	44	22
MAT01869	ALU0312	IA803-A	24.00	37	Reprovado	8	22	42
MAT00937	ALU0157	IA201-A	17.00	74	Reprovado	3	40	8
MAT04340	ALU0724	IA402-B	24.33	39	Reprovado	51	14	8
MAT05844	ALU0974	IA306-B	6.00	85	Reprovado	1	12	5
MAT00733	ALU0123	IA101-B	9.67	48	Reprovado	2	13	14
MAT01039	ALU0174	IA701-B	43.67	49	Reprovado	52	58	21
MAT02799	ALU0467	IA303-B	40.00	81	Reprovado	52	16	52
MAT00862	ALU0144	IA604-B	29.33	69	Reprovado	32	40	16
MAT01073	ALU0179	IA105-B	27.67	34	Reprovado	36	17	30
MAT01074	ALU0179	IA106-B	45.00	77	Reprovado	34	54	47
MAT00876	ALU0146	IA206-B	28.00	58	Reprovado	8	32	44
MAT00522	ALU0087	IA806-B	17.67	65	Reprovado	22	14	17
MAT01424	ALU0238	IA802-A	41.33	64	Reprovado	44	31	49
MAT01072	ALU0179	IA104-B	18.67	39	Reprovado	2	52	2
MAT01409	ALU0235	IA605-A	80.00	99	Aprovado	69	74	97
MAT05018	ALU0837	IA402-A	72.67	76	Aprovado	61	77	80
MAT01331	ALU0222	IA705-B	82.00	88	Aprovado	81	74	91
MAT01835	ALU0306	IA505-A	81.33	95	Aprovado	78	79	87
MAT01358	ALU0227	IA502-B	84.00	85	Aprovado	80	76	96
MAT01413	ALU0236	IA603-B	23.00	41	Reprovado	22	22	25
MAT01571	ALU0262	IA405-B	33.67	87	Reprovado	11	55	35
MAT01895	ALU0316	IA805-B	31.33	68	Reprovado	26	37	31
MAT04939	ALU0824	IA301-B	46.33	46	Reprovado	57	26	56
MAT00597	ALU0100	IA403-B	34.67	37	Reprovado	51	7	46
MAT01385	ALU0231	IA505-B	41.67	50	Reprovado	28	57	40
MAT05817	ALU0970	IA503-B	23.67	52	Reprovado	47	19	5
MAT05658	ALU0943	IA506-A	34.00	67	Reprovado	36	16	50
MAT01836	ALU0306	IA506-A	27.67	64	Reprovado	28	40	15
MAT05013	ALU0836	IA603-B	19.67	83	Reprovado	23	0	36
MAT01818	ALU0303	IA506-B	37.00	58	Reprovado	7	55	49
MAT01841	ALU0307	IA405-A	26.33	37	Reprovado	10	33	36
MAT01384	ALU0231	IA504-B	32.33	89	Reprovado	49	24	24
MAT01838	ALU0307	IA402-A	24.00	93	Reprovado	9	4	59
MAT03360	ALU0560	IA606-B	46.33	32	Reprovado	59	55	25
MAT00987	ALU0165	IA503-B	41.00	92	Reprovado	21	55	47
MAT01708	ALU0285	IA504-A	44.00	70	Reprovado	40	33	59
MAT01817	ALU0303	IA505-B	21.33	33	Reprovado	48	1	15
MAT01816	ALU0303	IA504-B	22.33	38	Reprovado	12	18	37
MAT01392	ALU0232	IA406-B	31.00	43	Reprovado	17	46	30
MAT01857	ALU0310	IA503-B	44.33	39	Reprovado	33	55	45
MAT01858	ALU0310	IA504-B	33.00	91	Reprovado	29	47	23
MAT01753	ALU0293	IA801-B	19.33	53	Reprovado	11	11	36
MAT01380	ALU0230	IA806-B	6.33	79	Reprovado	6	1	12
MAT01314	ALU0219	IA106-A	30.67	80	Reprovado	22	47	23
MAT00754	ALU0126	IA704-B	38.00	88	Reprovado	12	45	57
MAT01415	ALU0236	IA605-B	29.67	78	Reprovado	27	24	38
MAT01747	ALU0292	IA701-A	39.33	74	Reprovado	27	38	53
MAT04402	ALU0734	IA204-B	33.00	52	Reprovado	18	46	35
MAT01885	ALU0315	IA201-A	40.33	58	Reprovado	41	55	25
MAT01328	ALU0222	IA702-B	31.33	98	Reprovado	2	40	52
MAT01378	ALU0230	IA804-B	32.67	50	Reprovado	11	52	35
MAT05069	ALU0845	IA505-B	31.67	54	Reprovado	42	40	13
MAT02070	ALU0345	IA706-A	87.00	75	Aprovado	100	62	99
MAT02631	ALU0439	IA803-B	72.33	96	Aprovado	66	82	69
MAT02573	ALU0429	IA405-A	83.33	78	Aprovado	87	69	94
MAT02376	ALU0396	IA506-B	19.33	97	Reprovado	21	13	24
MAT02209	ALU0369	IA301-B	40.00	97	Reprovado	43	39	38
MAT02026	ALU0338	IA104-B	26.00	100	Reprovado	12	52	14
MAT02280	ALU0380	IA106-B	15.00	52	Reprovado	7	28	10
MAT02373	ALU0396	IA503-B	36.00	86	Reprovado	44	7	57
MAT02714	ALU0453	IA802-A	11.33	48	Reprovado	8	7	19
MAT02583	ALU0431	IA203-A	23.00	72	Reprovado	9	7	53
MAT02069	ALU0345	IA705-A	33.00	71	Reprovado	54	4	41
MAT02440	ALU0407	IA404-B	38.67	79	Reprovado	44	51	21
MAT02629	ALU0439	IA801-B	45.67	37	Reprovado	51	27	59
MAT02457	ALU0410	IA803-A	20.33	73	Reprovado	17	30	14
MAT02135	ALU0356	IA805-B	50.67	58	Reprovado	55	43	54
MAT02690	ALU0449	IA802-A	34.00	47	Reprovado	20	26	56
MAT02438	ALU0407	IA402-B	28.33	73	Reprovado	22	17	46
MAT02048	ALU0342	IA202-A	46.00	56	Reprovado	33	49	56
MAT02106	ALU0351	IA506-B	46.33	30	Reprovado	52	36	51
MAT02214	ALU0369	IA306-B	22.00	36	Reprovado	6	37	23
MAT02102	ALU0351	IA502-B	37.33	38	Reprovado	46	49	17
MAT02360	ALU0394	IA402-B	49.00	42	Reprovado	45	59	43
MAT02286	ALU0381	IA706-B	35.67	33	Reprovado	18	32	57
MAT02065	ALU0345	IA701-A	44.67	91	Reprovado	53	46	35
MAT02051	ALU0342	IA205-A	50.00	59	Reprovado	52	40	58
MAT02713	ALU0453	IA801-A	43.67	67	Reprovado	57	28	46
MAT02067	ALU0345	IA703-A	23.67	72	Reprovado	23	38	10
MAT02417	ALU0403	IA105-B	20.67	74	Reprovado	3	24	35
MAT01432	ALU0239	IA104-B	35.00	47	Reprovado	29	41	35
MAT02696	ALU0450	IA502-A	45.67	45	Reprovado	58	36	43
MAT02299	ALU0384	IA201-B	41.33	58	Reprovado	53	55	16
MAT02359	ALU0394	IA401-B	39.00	71	Reprovado	53	33	31
MAT02661	ALU0444	IA803-B	40.33	73	Reprovado	45	48	28
MAT02662	ALU0444	IA804-B	35.33	68	Reprovado	52	20	34
MAT02571	ALU0429	IA403-A	17.33	74	Reprovado	6	10	36
MAT02250	ALU0375	IA606-A	33.00	73	Reprovado	42	12	45
MAT00050	ALU0009	IA202-A	32.67	82	Reprovado	30	11	57
MAT02098	ALU0350	IA804-B	32.00	34	Reprovado	42	42	12
MAT02276	ALU0380	IA102-B	23.33	75	Reprovado	23	17	30
MAT02089	ALU0349	IA801-B	24.67	61	Reprovado	56	3	15
MAT05085	ALU0848	IA103-A	30.33	85	Reprovado	25	17	49
MAT02090	ALU0349	IA802-B	28.33	45	Reprovado	7	39	39
MAT02163	ALU0361	IA203-B	27.67	78	Reprovado	33	47	3
MAT02730	ALU0455	IA806-B	71.33	93	Aprovado	63	77	74
MAT00333	ALU0056	IA103-B	80.33	78	Aprovado	83	79	79
MAT03450	ALU0575	IA406-A	87.00	89	Aprovado	90	71	100
MAT03874	ALU0646	IA504-B	77.00	100	Aprovado	82	79	70
MAT02719	ALU0454	IA601-B	36.00	38	Reprovado	54	23	31
MAT01121	ALU0187	IA105-B	26.67	50	Reprovado	44	0	36
MAT00019	ALU0004	IA701-A	23.00	44	Reprovado	21	44	4
MAT02843	ALU0474	IA205-B	36.67	37	Reprovado	50	20	40
MAT03455	ALU0576	IA505-A	30.00	49	Reprovado	49	26	15
MAT02650	ALU0442	IA304-B	35.00	34	Reprovado	57	14	34
MAT04912	ALU0819	IA204-B	12.67	47	Reprovado	30	5	3
MAT00012	ALU0002	IA106-B	48.33	41	Reprovado	59	42	44
MAT00074	ALU0013	IA702-A	29.33	99	Reprovado	5	58	25
MAT00023	ALU0004	IA705-A	25.67	43	Reprovado	24	12	41
MAT05996	ALU1000	IA102-A	31.00	89	Reprovado	25	48	20
MAT01822	ALU0304	IA804-B	45.67	93	Reprovado	33	45	59
MAT04958	ALU0827	IA202-B	31.33	86	Reprovado	25	45	24
MAT01990	ALU0332	IA704-B	17.67	76	Reprovado	11	2	40
MAT03459	ALU0577	IA803-A	32.33	44	Reprovado	34	40	23
MAT00171	ALU0029	IA803-A	14.67	55	Reprovado	18	26	0
MAT00027	ALU0005	IA403-B	35.00	71	Reprovado	30	30	45
MAT00011	ALU0002	IA105-B	25.00	72	Reprovado	3	37	35
MAT00026	ALU0005	IA402-B	35.67	91	Reprovado	57	35	15
MAT00077	ALU0013	IA705-A	29.67	34	Reprovado	18	31	40
MAT03175	ALU0530	IA801-B	27.33	73	Reprovado	53	5	24
MAT02720	ALU0454	IA602-B	17.00	74	Reprovado	42	2	7
MAT04984	ALU0831	IA504-B	24.00	77	Reprovado	24	44	4
MAT00009	ALU0002	IA103-B	20.33	98	Reprovado	20	7	34
MAT00008	ALU0002	IA102-B	23.00	30	Reprovado	48	17	4
MAT00174	ALU0029	IA806-A	25.00	67	Reprovado	56	4	15
MAT01761	ALU0294	IA503-A	38.33	83	Reprovado	48	22	45
MAT00018	ALU0003	IA306-B	48.00	49	Reprovado	48	50	46
MAT02739	ALU0457	IA703-A	19.00	64	Reprovado	44	7	6
MAT02856	ALU0476	IA406-B	73.00	98	Aprovado	76	68	75
MAT00110	ALU0019	IA102-B	69.67	79	Aprovado	60	64	85
MAT00070	ALU0012	IA504-B	84.33	79	Aprovado	98	60	95
MAT03659	ALU0610	IA305-B	69.00	91	Aprovado	75	67	65
MAT00059	ALU0010	IA705-A	69.00	78	Aprovado	62	65	80
MAT00069	ALU0012	IA503-B	31.33	39	Reprovado	54	26	14
MAT00058	ALU0010	IA704-A	31.00	44	Reprovado	51	13	29
MAT03673	ALU0613	IA101-B	26.00	47	Reprovado	38	35	5
MAT00056	ALU0010	IA702-A	21.67	87	Reprovado	19	35	11
MAT00114	ALU0019	IA106-B	38.00	32	Reprovado	53	44	17
MAT00112	ALU0019	IA104-B	31.00	59	Reprovado	50	4	39
MAT05711	ALU0952	IA205-B	39.67	41	Reprovado	53	45	21
MAT04281	ALU0714	IA803-B	14.33	99	Reprovado	0	3	40
MAT00087	ALU0015	IA203-B	46.33	40	Reprovado	46	50	43
MAT05836	ALU0973	IA404-A	42.67	82	Reprovado	24	56	48
MAT00420	ALU0070	IA106-B	32.67	68	Reprovado	57	3	38
MAT00060	ALU0010	IA706-A	20.67	81	Reprovado	17	13	32
MAT03658	ALU0610	IA304-B	40.00	30	Reprovado	49	39	32
MAT03676	ALU0613	IA104-B	31.67	73	Reprovado	25	15	55
MAT00067	ALU0012	IA501-B	24.33	97	Reprovado	31	28	14
MAT00083	ALU0014	IA305-B	23.00	70	Reprovado	28	31	10
MAT00068	ALU0012	IA502-B	25.33	97	Reprovado	6	18	52
MAT00072	ALU0012	IA506-B	29.67	38	Reprovado	16	14	59
MAT00080	ALU0014	IA302-B	44.00	81	Reprovado	59	41	32
MAT03657	ALU0610	IA303-B	15.67	41	Reprovado	0	25	22
MAT00084	ALU0014	IA306-B	37.00	65	Reprovado	56	34	21
MAT02961	ALU0494	IA503-A	17.00	64	Reprovado	14	22	15
MAT00065	ALU0011	IA105-A	23.00	72	Reprovado	0	28	41
MAT03678	ALU0613	IA106-B	15.00	38	Reprovado	15	26	4
MAT03247	ALU0542	IA401-B	19.67	97	Reprovado	22	25	12
MAT04342	ALU0724	IA404-B	20.33	30	Reprovado	46	12	3
MAT00061	ALU0011	IA101-A	25.67	97	Reprovado	1	20	56
MAT00107	ALU0018	IA605-B	36.33	91	Reprovado	57	4	48
MAT00079	ALU0014	IA301-B	4.33	52	Reprovado	10	2	1
MAT04035	ALU0673	IA403-B	30.67	98	Reprovado	39	49	4
MAT03656	ALU0610	IA302-B	14.00	71	Reprovado	14	19	9
MAT00054	ALU0009	IA206-A	40.00	52	Reprovado	30	38	52
MAT00052	ALU0009	IA204-A	41.33	97	Reprovado	46	53	25
MAT00113	ALU0019	IA105-B	36.00	84	Reprovado	46	58	4
MAT00254	ALU0043	IA302-A	80.00	75	Aprovado	72	93	75
MAT00164	ALU0028	IA302-B	82.33	97	Aprovado	78	73	96
MAT00150	ALU0025	IA706-B	84.33	81	Aprovado	83	87	83
MAT00186	ALU0031	IA606-B	39.33	31	Reprovado	37	58	23
MAT00202	ALU0034	IA404-A	31.00	100	Reprovado	39	53	1
MAT00249	ALU0042	IA503-B	40.00	58	Reprovado	28	43	49
MAT00223	ALU0038	IA701-B	11.00	47	Reprovado	28	5	0
MAT00256	ALU0043	IA304-A	24.67	32	Reprovado	55	18	1
MAT00199	ALU0034	IA401-A	29.67	52	Reprovado	36	43	10
MAT00252	ALU0042	IA506-B	19.00	58	Reprovado	3	0	54
MAT00250	ALU0042	IA504-B	26.67	88	Reprovado	2	45	33
MAT00176	ALU0030	IA702-B	24.33	55	Reprovado	50	8	15
MAT00188	ALU0032	IA102-A	30.00	58	Reprovado	23	15	52
MAT00201	ALU0034	IA403-A	27.00	79	Reprovado	52	14	15
MAT00232	ALU0039	IA204-B	34.67	98	Reprovado	53	29	22
MAT00165	ALU0028	IA303-B	47.67	83	Reprovado	36	57	50
MAT00191	ALU0032	IA105-A	27.00	36	Reprovado	4	21	56
MAT03753	ALU0626	IA703-B	24.33	53	Reprovado	19	48	6
MAT00251	ALU0042	IA505-B	19.00	34	Reprovado	11	21	25
MAT00200	ALU0034	IA402-A	45.33	66	Reprovado	44	53	39
MAT00248	ALU0042	IA502-B	27.00	79	Reprovado	4	25	52
MAT00175	ALU0030	IA701-B	34.00	96	Reprovado	21	31	50
MAT05123	ALU0854	IA805-B	21.00	42	Reprovado	27	29	7
MAT00240	ALU0040	IA306-A	23.00	55	Reprovado	24	39	6
MAT00178	ALU0030	IA704-B	31.33	69	Reprovado	35	44	15
MAT00203	ALU0034	IA405-A	32.67	31	Reprovado	36	34	28
MAT00237	ALU0040	IA303-A	24.00	79	Reprovado	34	8	30
MAT00159	ALU0027	IA203-B	30.00	44	Reprovado	42	11	37
MAT01723	ALU0288	IA201-B	24.33	98	Reprovado	43	5	25
MAT00189	ALU0032	IA103-A	20.67	92	Reprovado	41	7	14
MAT01290	ALU0215	IA606-B	40.67	68	Reprovado	41	26	55
MAT00229	ALU0039	IA201-B	40.33	49	Reprovado	56	6	59
MAT03754	ALU0626	IA704-B	15.00	88	Reprovado	31	7	7
MAT00193	ALU0033	IA201-B	36.33	91	Reprovado	33	21	55
MAT00253	ALU0043	IA301-A	36.67	80	Reprovado	46	22	42
MAT01318	ALU0220	IA604-B	54.33	40	Reprovado	53	59	51
MAT00213	ALU0036	IA203-A	47.67	34	Reprovado	42	59	42
MAT00192	ALU0032	IA106-A	39.00	80	Reprovado	22	48	47
MAT00190	ALU0032	IA104-A	39.33	97	Reprovado	43	41	34
MAT00172	ALU0029	IA804-A	24.67	96	Reprovado	5	50	19
MAT00255	ALU0043	IA303-A	18.33	82	Reprovado	19	27	9
MAT00187	ALU0032	IA101-A	36.67	87	Reprovado	58	34	18
MAT00357	ALU0060	IA103-A	84.67	75	Aprovado	99	75	80
MAT00342	ALU0057	IA306-A	89.67	81	Aprovado	92	79	98
MAT00626	ALU0105	IA802-B	81.67	89	Aprovado	60	92	93
MAT00266	ALU0045	IA102-B	85.33	95	Aprovado	76	83	97
MAT00337	ALU0057	IA301-A	91.00	97	Aprovado	86	88	99
MAT00330	ALU0055	IA206-A	42.33	82	Reprovado	56	57	14
MAT00311	ALU0052	IA705-A	32.67	83	Reprovado	19	55	24
MAT00297	ALU0050	IA303-B	37.67	57	Reprovado	5	57	51
MAT03825	ALU0638	IA403-B	28.33	36	Reprovado	3	54	28
MAT05235	ALU0873	IA303-B	39.00	73	Reprovado	37	33	47
MAT00317	ALU0053	IA805-A	32.33	59	Reprovado	57	18	22
MAT00281	ALU0047	IA405-A	29.67	30	Reprovado	45	11	33
MAT00310	ALU0052	IA704-A	50.67	61	Reprovado	43	54	55
MAT00264	ALU0044	IA306-A	21.67	58	Reprovado	28	32	5
MAT00340	ALU0057	IA304-A	27.33	40	Reprovado	35	38	9
MAT05477	ALU0913	IA205-B	32.33	36	Reprovado	34	4	59
MAT01521	ALU0254	IA603-A	35.67	76	Reprovado	51	8	48
MAT00282	ALU0047	IA406-A	30.33	71	Reprovado	41	26	24
MAT00278	ALU0047	IA402-A	29.33	48	Reprovado	27	16	45
MAT00277	ALU0047	IA401-A	24.67	66	Reprovado	40	23	11
MAT00341	ALU0057	IA305-A	24.00	61	Reprovado	4	12	56
MAT00329	ALU0055	IA205-A	25.33	67	Reprovado	27	27	22
MAT00345	ALU0058	IA103-B	38.00	34	Reprovado	59	8	47
MAT03826	ALU0638	IA404-B	41.00	69	Reprovado	23	48	52
MAT00338	ALU0057	IA302-A	29.33	82	Reprovado	42	24	22
MAT00346	ALU0058	IA104-B	48.33	98	Reprovado	52	36	57
MAT00279	ALU0047	IA403-A	33.67	41	Reprovado	29	52	20
MAT05575	ALU0930	IA101-A	28.00	53	Reprovado	28	25	31
MAT00272	ALU0046	IA502-B	48.00	44	Reprovado	41	48	55
MAT00322	ALU0054	IA404-A	39.00	99	Reprovado	40	24	53
MAT00267	ALU0045	IA103-B	11.33	69	Reprovado	20	6	8
MAT00356	ALU0060	IA102-A	18.00	66	Reprovado	11	25	18
MAT00307	ALU0052	IA701-A	30.67	30	Reprovado	20	39	33
MAT00328	ALU0055	IA204-A	38.33	63	Reprovado	58	16	41
MAT03824	ALU0638	IA402-B	31.00	52	Reprovado	25	49	19
MAT00320	ALU0054	IA402-A	16.33	57	Reprovado	13	32	4
MAT00339	ALU0057	IA303-A	23.33	73	Reprovado	20	18	32
MAT05268	ALU0878	IA806-B	20.67	93	Reprovado	32	11	19
MAT04333	ALU0723	IA201-A	21.67	81	Reprovado	14	35	16
MAT02781	ALU0464	IA303-B	44.67	90	Reprovado	53	41	40
MAT04029	ALU0672	IA803-B	73.33	92	Aprovado	70	60	90
MAT00374	ALU0063	IA802-B	80.67	90	Aprovado	73	76	93
MAT00382	ALU0064	IA504-B	68.00	95	Aprovado	71	72	61
MAT00446	ALU0075	IA502-B	79.33	81	Aprovado	71	96	71
MAT03722	ALU0621	IA402-B	74.00	84	Aprovado	72	82	68
MAT04054	ALU0676	IA104-B	75.67	87	Aprovado	72	65	90
MAT00859	ALU0144	IA601-B	95.33	95	Aprovado	95	97	94
MAT00373	ALU0063	IA801-B	77.00	85	Aprovado	96	67	68
MAT03354	ALU0559	IA406-A	40.67	75	Reprovado	20	45	57
MAT00380	ALU0064	IA502-B	39.67	37	Reprovado	27	52	40
MAT00384	ALU0064	IA506-B	29.33	58	Reprovado	56	17	15
MAT03901	ALU0651	IA201-B	39.33	72	Reprovado	40	53	25
MAT02484	ALU0414	IA506-A	25.67	93	Reprovado	13	34	30
MAT04052	ALU0676	IA102-B	27.00	80	Reprovado	9	28	44
MAT04026	ALU0671	IA806-A	37.00	90	Reprovado	40	35	36
MAT00358	ALU0060	IA104-A	5.00	79	Reprovado	6	8	1
MAT04060	ALU0677	IA104-B	9.67	78	Reprovado	16	9	4
MAT00378	ALU0063	IA806-B	39.33	71	Reprovado	45	20	53
MAT04754	ALU0793	IA802-B	21.33	62	Reprovado	41	18	5
MAT00372	ALU0062	IA206-A	40.67	74	Reprovado	40	55	27
MAT03914	ALU0653	IA602-B	42.33	74	Reprovado	54	41	32
MAT00641	ALU0107	IA305-B	40.00	94	Reprovado	46	22	52
MAT04031	ALU0672	IA805-B	28.67	96	Reprovado	54	5	27
MAT00449	ALU0075	IA505-B	40.00	95	Reprovado	33	34	53
MAT00454	ALU0076	IA804-B	29.67	86	Reprovado	59	4	26
MAT00376	ALU0063	IA804-B	36.00	73	Reprovado	19	50	39
MAT04651	ALU0776	IA401-B	29.67	92	Reprovado	16	43	30
MAT04727	ALU0788	IA105-A	26.67	90	Reprovado	34	46	0
MAT03908	ALU0652	IA502-B	8.67	100	Reprovado	10	15	1
MAT00318	ALU0053	IA806-A	29.33	43	Reprovado	51	22	15
MAT03185	ALU0531	IA305-B	20.67	97	Reprovado	47	8	7
MAT02076	ALU0346	IA706-B	78.33	99	Aprovado	80	93	62
MAT05578	ALU0930	IA104-A	78.00	91	Aprovado	68	93	73
MAT02145	ALU0358	IA703-A	78.00	94	Aprovado	67	75	92
MAT02671	ALU0446	IA201-B	78.33	94	Aprovado	93	67	75
MAT00616	ALU0103	IA804-B	73.33	89	Aprovado	62	74	84
MAT00588	ALU0098	IA206-A	84.33	95	Aprovado	79	89	85
MAT00590	ALU0099	IA402-B	82.33	90	Aprovado	81	100	66
MAT00619	ALU0104	IA701-B	40.00	52	Reprovado	43	56	21
MAT04153	ALU0693	IA201-B	13.67	76	Reprovado	29	10	2
MAT00580	ALU0097	IA604-A	41.33	38	Reprovado	45	58	21
MAT04117	ALU0687	IA201-A	25.33	95	Reprovado	17	39	20
MAT01018	ALU0170	IA404-B	51.67	75	Reprovado	55	51	49
MAT00617	ALU0103	IA805-B	10.67	81	Reprovado	0	3	29
MAT03762	ALU0627	IA106-B	7.67	95	Reprovado	2	14	7
MAT04124	ALU0688	IA302-B	20.67	70	Reprovado	17	17	28
MAT00137	ALU0023	IA605-A	23.67	67	Reprovado	5	41	25
MAT03304	ALU0551	IA404-B	28.00	95	Reprovado	25	18	41
MAT00558	ALU0093	IA406-A	26.00	36	Reprovado	20	58	0
MAT04152	ALU0692	IA206-B	24.33	52	Reprovado	14	38	21
MAT05863	ALU0978	IA701-A	14.33	50	Reprovado	30	5	8
MAT02179	ALU0364	IA101-A	40.67	36	Reprovado	44	49	29
MAT00227	ALU0038	IA705-B	15.67	91	Reprovado	14	8	25
MAT00615	ALU0103	IA803-B	34.00	87	Reprovado	43	37	22
MAT01052	ALU0176	IA202-B	47.67	74	Reprovado	41	53	49
MAT00585	ALU0098	IA203-A	33.00	87	Reprovado	43	26	30
MAT00546	ALU0091	IA606-B	45.33	61	Reprovado	58	24	54
MAT05415	ALU0903	IA303-B	23.67	43	Reprovado	12	2	57
MAT00583	ALU0098	IA201-A	19.00	99	Reprovado	20	0	37
MAT05606	ALU0935	IA502-A	14.67	99	Reprovado	30	2	12
MAT01788	ALU0298	IA806-B	84.33	82	Aprovado	69	86	98
MAT00750	ALU0125	IA306-B	88.67	83	Aprovado	94	98	74
MAT00778	ALU0130	IA704-A	73.67	84	Aprovado	69	69	83
MAT04363	ALU0728	IA401-B	42.00	77	Reprovado	42	26	58
MAT00718	ALU0120	IA804-B	49.00	55	Reprovado	50	59	38
MAT00818	ALU0137	IA202-A	44.67	94	Reprovado	53	41	40
MAT04423	ALU0738	IA801-B	23.67	100	Reprovado	33	13	25
MAT00738	ALU0123	IA106-B	28.00	82	Reprovado	40	35	9
MAT02028	ALU0338	IA106-B	28.67	43	Reprovado	38	43	5
MAT03839	ALU0640	IA105-B	35.33	38	Reprovado	39	12	55
MAT01343	ALU0224	IA705-B	37.33	78	Reprovado	4	49	59
MAT00749	ALU0125	IA305-B	27.33	97	Reprovado	49	4	29
MAT03497	ALU0583	IA105-A	33.00	59	Reprovado	32	43	24
MAT00809	ALU0135	IA305-B	40.33	40	Reprovado	52	43	26
MAT00668	ALU0112	IA402-B	19.33	46	Reprovado	7	23	28
MAT00764	ALU0128	IA302-A	17.33	52	Reprovado	35	2	15
MAT00777	ALU0130	IA703-A	18.33	62	Reprovado	30	22	3
MAT00737	ALU0123	IA105-B	16.67	83	Reprovado	6	4	40
MAT00757	ALU0127	IA801-B	39.00	45	Reprovado	53	49	15
MAT00780	ALU0130	IA706-A	12.00	94	Reprovado	5	7	24
MAT00765	ALU0128	IA303-A	32.00	95	Reprovado	44	31	21
MAT00735	ALU0123	IA103-B	37.00	66	Reprovado	46	11	54
MAT00805	ALU0135	IA301-B	38.67	47	Reprovado	39	21	56
MAT00775	ALU0130	IA701-A	18.67	76	Reprovado	15	37	4
MAT00760	ALU0127	IA804-B	15.00	75	Reprovado	2	17	26
MAT00731	ALU0122	IA505-B	20.33	46	Reprovado	12	39	10
MAT00817	ALU0137	IA201-A	34.33	82	Reprovado	39	9	55
MAT04329	ALU0722	IA803-B	33.00	33	Reprovado	54	30	15
MAT00736	ALU0123	IA104-B	29.67	33	Reprovado	10	28	51
MAT04322	ALU0721	IA202-A	42.67	42	Reprovado	35	56	37
MAT00783	ALU0131	IA803-A	50.67	91	Reprovado	55	52	45
MAT04324	ALU0721	IA204-A	29.00	80	Reprovado	50	34	3
MAT00797	ALU0133	IA705-B	40.33	40	Reprovado	53	14	54
MAT00429	ALU0072	IA403-B	30.67	75	Reprovado	40	2	50
MAT05676	ALU0946	IA106-B	14.00	99	Reprovado	5	22	15
MAT04330	ALU0722	IA804-B	27.67	38	Reprovado	35	9	39
MAT00769	ALU0129	IA601-B	24.67	81	Reprovado	31	22	21
MAT00720	ALU0120	IA806-B	21.33	66	Reprovado	14	16	34
MAT04327	ALU0722	IA801-B	21.67	38	Reprovado	8	34	23
MAT03818	ALU0637	IA602-B	35.33	63	Reprovado	32	35	39
MAT00867	ALU0145	IA703-B	72.00	100	Aprovado	65	68	83
MAT00884	ALU0148	IA202-A	88.00	82	Aprovado	90	87	87
MAT00901	ALU0151	IA701-B	86.67	93	Aprovado	68	96	96
MAT04393	ALU0733	IA601-B	26.33	92	Reprovado	34	18	27
MAT00860	ALU0144	IA602-B	24.00	66	Reprovado	25	27	20
MAT00903	ALU0151	IA703-B	19.67	79	Reprovado	2	13	44
MAT00902	ALU0151	IA702-B	29.67	82	Reprovado	45	26	18
MAT00864	ALU0144	IA606-B	33.33	34	Reprovado	54	46	0
MAT00897	ALU0150	IA603-B	25.33	81	Reprovado	9	48	19
MAT00904	ALU0151	IA704-B	32.33	64	Reprovado	48	39	10
MAT00865	ALU0145	IA701-B	30.00	82	Reprovado	21	11	58
MAT00906	ALU0151	IA706-B	39.33	74	Reprovado	37	54	27
MAT00911	ALU0152	IA405-A	28.67	58	Reprovado	0	42	44
MAT04394	ALU0733	IA602-B	29.33	50	Reprovado	17	32	39
MAT04388	ALU0732	IA302-A	26.67	52	Reprovado	19	40	21
MAT00872	ALU0146	IA202-B	22.67	44	Reprovado	19	26	23
MAT03787	ALU0632	IA801-B	27.67	82	Reprovado	32	38	13
MAT00868	ALU0145	IA704-B	32.67	42	Reprovado	23	56	19
MAT01118	ALU0187	IA102-B	32.67	47	Reprovado	23	39	36
MAT04391	ALU0732	IA305-A	29.33	99	Reprovado	22	13	53
MAT00888	ALU0148	IA206-A	31.33	71	Reprovado	13	51	30
MAT00874	ALU0146	IA204-B	16.67	69	Reprovado	31	12	7
MAT00914	ALU0153	IA202-B	26.67	33	Reprovado	36	27	17
MAT00885	ALU0148	IA203-A	42.33	92	Reprovado	44	47	36
MAT00905	ALU0151	IA705-B	39.00	36	Reprovado	25	35	57
MAT00912	ALU0152	IA406-A	35.67	81	Reprovado	13	41	53
MAT04397	ALU0733	IA605-B	35.00	95	Reprovado	56	5	44
MAT04390	ALU0732	IA304-A	33.33	71	Reprovado	30	46	24
MAT00910	ALU0152	IA404-A	20.00	77	Reprovado	6	46	8
MAT04389	ALU0732	IA303-A	29.67	64	Reprovado	14	56	19
MAT00908	ALU0152	IA402-A	18.33	62	Reprovado	53	0	2
MAT00887	ALU0148	IA205-A	17.00	57	Reprovado	8	25	18
MAT00900	ALU0150	IA606-B	30.67	86	Reprovado	16	27	49
MAT00866	ALU0145	IA702-B	29.33	85	Reprovado	58	18	12
MAT04398	ALU0733	IA606-B	28.33	61	Reprovado	18	44	23
MAT00875	ALU0146	IA205-B	26.67	57	Reprovado	6	42	32
MAT04396	ALU0733	IA604-B	35.00	30	Reprovado	45	31	29
MAT04460	ALU0744	IA302-B	11.67	82	Reprovado	11	0	24
MAT04395	ALU0733	IA603-B	13.33	37	Reprovado	9	27	4
MAT00915	ALU0153	IA203-B	30.33	41	Reprovado	41	29	21
MAT00898	ALU0150	IA604-B	20.67	47	Reprovado	7	20	35
MAT00896	ALU0150	IA602-B	20.67	48	Reprovado	9	27	26
MAT00895	ALU0150	IA601-B	35.00	37	Reprovado	14	48	43
MAT04826	ALU0805	IA802-A	81.00	78	Aprovado	95	78	70
MAT02027	ALU0338	IA105-B	91.00	89	Aprovado	100	77	96
MAT01952	ALU0326	IA702-A	82.33	86	Aprovado	96	69	82
MAT03871	ALU0646	IA501-B	86.33	86	Aprovado	97	97	65
MAT04553	ALU0759	IA105-B	72.00	100	Aprovado	66	73	77
MAT01030	ALU0172	IA504-B	79.33	79	Aprovado	71	99	68
MAT01027	ALU0172	IA501-B	69.67	84	Aprovado	72	75	62
MAT04552	ALU0759	IA104-B	73.33	91	Aprovado	62	84	74
MAT00010	ALU0002	IA104-B	75.33	91	Aprovado	78	87	61
MAT05172	ALU0862	IA506-B	34.67	78	Reprovado	44	51	9
MAT00935	ALU0156	IA605-A	24.33	46	Reprovado	34	29	10
MAT00925	ALU0155	IA101-A	27.67	32	Reprovado	24	55	4
MAT04550	ALU0759	IA102-B	25.33	96	Reprovado	19	45	12
MAT04542	ALU0757	IA206-A	13.33	93	Reprovado	1	23	16
MAT00979	ALU0164	IA501-A	47.00	80	Reprovado	48	52	41
MAT04540	ALU0757	IA204-A	23.67	45	Reprovado	24	39	8
MAT04461	ALU0744	IA303-B	31.67	80	Reprovado	15	39	41
MAT01891	ALU0316	IA801-B	28.00	46	Reprovado	18	35	31
MAT00932	ALU0156	IA602-A	19.33	86	Reprovado	15	0	43
MAT01004	ALU0168	IA402-A	27.00	81	Reprovado	46	27	8
MAT00927	ALU0155	IA103-A	6.00	73	Reprovado	12	3	3
MAT01022	ALU0171	IA102-A	43.00	64	Reprovado	57	36	36
MAT00982	ALU0164	IA504-A	28.33	63	Reprovado	0	54	31
MAT04539	ALU0757	IA203-A	21.33	57	Reprovado	33	20	11
MAT00918	ALU0153	IA206-B	19.67	55	Reprovado	7	31	21
MAT00977	ALU0163	IA605-B	46.33	42	Reprovado	34	47	58
MAT01003	ALU0168	IA401-A	18.67	99	Reprovado	12	2	42
MAT02685	ALU0448	IA503-A	13.00	77	Reprovado	28	4	7
MAT02914	ALU0486	IA404-A	41.67	99	Reprovado	51	53	21
MAT05346	ALU0891	IA306-B	29.33	48	Reprovado	19	47	22
MAT01595	ALU0266	IA805-A	29.00	36	Reprovado	52	34	1
MAT01043	ALU0174	IA705-B	7.33	91	Reprovado	6	2	14
MAT01025	ALU0171	IA105-A	21.33	91	Reprovado	22	20	22
MAT00917	ALU0153	IA205-B	44.00	62	Reprovado	51	26	55
MAT04499	ALU0750	IA605-B	31.67	77	Reprovado	0	44	51
MAT03176	ALU0530	IA802-B	37.00	76	Reprovado	24	53	34
MAT01041	ALU0174	IA703-B	41.00	31	Reprovado	17	57	49
MAT01172	ALU0196	IA102-A	75.67	79	Aprovado	85	67	75
MAT01110	ALU0185	IA306-B	12.67	52	Reprovado	10	24	4
MAT05692	ALU0949	IA304-A	23.67	40	Reprovado	7	5	59
MAT04669	ALU0779	IA801-A	12.00	70	Reprovado	18	1	17
MAT01109	ALU0185	IA305-B	21.67	69	Reprovado	19	25	21
MAT01140	ALU0190	IA406-A	13.33	33	Reprovado	20	11	9
MAT01177	ALU0197	IA401-A	17.33	97	Reprovado	7	15	30
MAT01112	ALU0186	IA202-B	43.67	39	Reprovado	41	57	33
MAT04662	ALU0777	IA306-B	29.00	62	Reprovado	27	5	55
MAT01125	ALU0188	IA803-B	27.33	78	Reprovado	16	31	35
MAT01181	ALU0197	IA405-A	25.67	88	Reprovado	15	55	7
MAT01174	ALU0196	IA104-A	22.33	83	Reprovado	49	15	3
MAT04656	ALU0776	IA406-B	43.00	59	Reprovado	50	26	53
MAT01180	ALU0197	IA404-A	51.67	38	Reprovado	50	49	56
MAT01166	ALU0195	IA302-B	32.00	43	Reprovado	55	27	14
MAT02244	ALU0374	IA306-B	36.67	62	Reprovado	43	31	36
MAT04718	ALU0787	IA502-A	34.33	30	Reprovado	49	47	7
MAT04661	ALU0777	IA305-B	30.33	97	Reprovado	16	24	51
MAT04653	ALU0776	IA403-B	49.33	84	Reprovado	53	56	39
MAT01178	ALU0197	IA402-A	40.67	90	Reprovado	51	28	43
MAT01107	ALU0185	IA303-B	12.33	98	Reprovado	15	18	4
MAT00861	ALU0144	IA603-B	33.67	33	Reprovado	52	48	1
MAT01173	ALU0196	IA103-A	25.00	32	Reprovado	38	19	18
MAT01120	ALU0187	IA104-B	29.67	71	Reprovado	2	31	56
MAT04657	ALU0777	IA301-B	41.00	92	Reprovado	19	48	56
MAT01176	ALU0196	IA106-A	19.67	41	Reprovado	3	13	43
MAT01130	ALU0189	IA802-A	27.33	32	Reprovado	56	15	11
MAT04658	ALU0777	IA302-B	32.67	38	Reprovado	53	30	15
MAT01111	ALU0186	IA201-B	32.00	84	Reprovado	34	11	51
MAT01114	ALU0186	IA204-B	31.33	96	Reprovado	52	12	30
MAT01179	ALU0197	IA403-A	19.33	57	Reprovado	1	53	4
MAT01170	ALU0195	IA306-B	13.33	62	Reprovado	8	31	1
MAT01108	ALU0185	IA304-B	33.33	97	Reprovado	51	12	37
MAT04666	ALU0778	IA704-A	39.00	62	Reprovado	58	40	19
MAT01182	ALU0197	IA406-A	37.00	62	Reprovado	45	34	32
MAT01162	ALU0194	IA504-A	47.67	47	Reprovado	58	56	29
MAT01131	ALU0189	IA803-A	35.67	74	Reprovado	50	46	11
MAT01098	ALU0183	IA806-B	29.67	30	Reprovado	50	19	20
MAT01168	ALU0195	IA304-B	19.33	70	Reprovado	13	27	18
MAT01171	ALU0196	IA101-A	11.33	45	Reprovado	7	15	12
MAT01105	ALU0185	IA301-B	10.00	49	Reprovado	17	9	4
MAT04654	ALU0776	IA404-B	31.33	44	Reprovado	53	33	8
MAT01106	ALU0185	IA302-B	28.00	73	Reprovado	24	6	54
MAT05331	ALU0889	IA503-B	62.67	87	Aprovado	67	60	61
MAT01203	ALU0201	IA403-A	72.33	84	Aprovado	84	72	61
MAT04784	ALU0798	IA602-B	74.33	97	Aprovado	81	65	77
MAT01207	ALU0202	IA601-B	72.00	78	Aprovado	61	90	65
MAT01833	ALU0306	IA503-A	74.67	92	Aprovado	81	82	61
MAT01276	ALU0213	IA204-B	70.67	98	Aprovado	60	65	87
MAT01212	ALU0202	IA606-B	76.33	96	Aprovado	78	80	71
MAT01205	ALU0201	IA405-A	8.00	96	Reprovado	15	3	6
MAT04722	ALU0787	IA506-A	9.33	85	Reprovado	6	6	16
MAT01264	ALU0211	IA204-B	25.33	98	Reprovado	22	48	6
MAT01201	ALU0201	IA401-A	19.67	59	Reprovado	11	16	32
MAT00779	ALU0130	IA705-A	48.67	31	Reprovado	38	51	57
MAT05629	ALU0939	IA101-B	23.33	89	Reprovado	48	14	8
MAT02769	ALU0462	IA603-A	44.33	65	Reprovado	58	43	32
MAT01195	ALU0200	IA601-A	27.67	45	Reprovado	31	46	6
MAT01206	ALU0201	IA406-A	17.00	87	Reprovado	37	0	14
MAT04425	ALU0738	IA803-B	39.67	95	Reprovado	57	18	44
MAT00774	ALU0129	IA606-B	9.67	43	Reprovado	6	19	4
MAT01202	ALU0201	IA402-A	37.33	47	Reprovado	14	59	39
MAT00423	ALU0071	IA403-B	41.67	58	Reprovado	35	31	59
MAT03667	ALU0612	IA301-B	17.00	52	Reprovado	6	13	32
MAT01494	ALU0249	IA206-A	29.33	76	Reprovado	25	13	50
MAT04301	ALU0717	IA105-B	29.00	87	Reprovado	11	50	26
MAT01210	ALU0202	IA604-B	28.67	68	Reprovado	26	35	25
MAT01249	ALU0209	IA301-B	43.33	50	Reprovado	47	42	41
MAT01265	ALU0211	IA205-B	36.33	75	Reprovado	19	48	42
MAT01246	ALU0208	IA104-A	12.67	94	Reprovado	23	1	14
MAT01006	ALU0168	IA404-A	43.67	95	Reprovado	37	41	53
MAT02367	ALU0395	IA303-B	24.67	50	Reprovado	17	27	30
MAT01584	ALU0264	IA106-B	33.67	36	Reprovado	42	54	5
MAT03234	ALU0539	IA706-B	30.67	64	Reprovado	36	41	15
MAT01348	ALU0225	IA304-A	81.67	96	Aprovado	88	71	86
MAT04883	ALU0814	IA205-B	75.33	99	Aprovado	76	60	90
MAT04884	ALU0814	IA206-B	89.67	91	Aprovado	95	80	94
MAT01349	ALU0225	IA305-A	81.00	86	Aprovado	83	97	63
MAT01351	ALU0226	IA301-A	90.67	86	Aprovado	86	89	97
MAT04017	ALU0670	IA203-A	87.33	91	Aprovado	99	70	93
MAT01396	ALU0233	IA404-B	77.33	77	Aprovado	73	89	70
MAT04894	ALU0816	IA304-B	37.33	72	Reprovado	33	45	34
MAT01398	ALU0233	IA406-B	36.67	95	Reprovado	48	31	31
MAT04891	ALU0816	IA301-B	48.67	55	Reprovado	50	45	51
MAT01347	ALU0225	IA303-A	33.00	34	Reprovado	27	42	30
MAT02926	ALU0488	IA404-B	39.33	46	Reprovado	31	46	41
MAT04896	ALU0816	IA306-B	50.67	56	Reprovado	50	51	51
MAT04887	ALU0815	IA203-A	36.33	74	Reprovado	47	4	58
MAT01393	ALU0233	IA401-B	41.33	75	Reprovado	36	33	55
MAT01406	ALU0235	IA602-A	44.67	51	Reprovado	57	36	41
MAT04802	ALU0801	IA402-B	30.67	96	Reprovado	33	45	14
MAT01324	ALU0221	IA804-B	26.33	65	Reprovado	23	48	8
MAT01408	ALU0235	IA604-A	7.33	59	Reprovado	13	6	3
MAT01388	ALU0232	IA402-B	41.00	92	Reprovado	57	9	57
MAT01407	ALU0235	IA603-A	25.00	87	Reprovado	57	5	13
MAT01147	ALU0192	IA401-B	38.67	59	Reprovado	58	58	0
MAT04885	ALU0815	IA201-A	16.67	48	Reprovado	5	40	5
MAT01387	ALU0232	IA401-B	42.33	88	Reprovado	42	31	54
MAT04895	ALU0816	IA305-B	28.33	84	Reprovado	40	17	28
MAT04408	ALU0735	IA404-A	34.00	34	Reprovado	24	36	42
MAT01353	ALU0226	IA303-A	33.00	31	Reprovado	58	14	27
MAT04892	ALU0816	IA302-B	33.00	88	Reprovado	28	28	43
MAT04812	ALU0802	IA806-B	26.00	60	Reprovado	55	9	14
MAT05484	ALU0914	IA606-A	17.67	57	Reprovado	23	0	30
MAT00204	ALU0034	IA406-A	10.00	98	Reprovado	11	12	7
MAT01410	ALU0235	IA606-A	28.67	100	Reprovado	23	34	29
MAT00156	ALU0026	IA406-A	22.67	63	Reprovado	49	13	6
MAT01403	ALU0234	IA205-A	51.67	93	Reprovado	50	47	58
MAT02152	ALU0359	IA404-B	26.67	64	Reprovado	46	24	10
MAT04893	ALU0816	IA303-B	25.33	89	Reprovado	38	6	32
MAT01411	ALU0236	IA601-B	33.33	74	Reprovado	8	40	52
MAT00170	ALU0029	IA802-A	32.00	41	Reprovado	42	47	7
MAT00759	ALU0127	IA803-B	84.33	85	Aprovado	81	79	93
MAT01533	ALU0256	IA503-A	82.33	93	Aprovado	84	79	84
MAT04191	ALU0699	IA803-B	94.33	88	Aprovado	97	97	89
MAT01476	ALU0246	IA806-A	84.33	81	Aprovado	84	89	80
MAT01442	ALU0241	IA202-B	30.00	80	Reprovado	27	32	31
MAT00934	ALU0156	IA604-A	32.00	77	Reprovado	2	54	40
MAT01449	ALU0242	IA403-A	8.33	93	Reprovado	1	19	5
MAT01536	ALU0256	IA506-A	24.00	33	Reprovado	27	5	40
MAT05033	ALU0839	IA205-B	32.67	53	Reprovado	43	14	41
MAT05138	ALU0857	IA402-A	26.67	98	Reprovado	57	8	15
MAT01446	ALU0241	IA206-B	29.00	66	Reprovado	1	28	58
MAT01036	ALU0173	IA304-A	25.33	86	Reprovado	29	14	33
MAT04947	ALU0825	IA503-B	25.67	88	Reprovado	55	15	7
MAT05623	ALU0938	IA301-B	46.00	61	Reprovado	58	41	39
MAT01452	ALU0242	IA406-A	21.67	99	Reprovado	31	10	24
MAT01443	ALU0241	IA203-B	27.67	100	Reprovado	23	22	38
MAT01534	ALU0256	IA504-A	25.00	45	Reprovado	0	46	29
MAT01529	ALU0255	IA505-A	23.67	84	Reprovado	29	29	13
MAT01487	ALU0248	IA405-B	28.67	53	Reprovado	26	4	56
MAT03633	ALU0606	IA303-B	24.00	92	Reprovado	1	31	40
MAT01486	ALU0248	IA404-B	43.67	30	Reprovado	48	42	41
MAT01456	ALU0243	IA304-A	25.00	87	Reprovado	48	17	10
MAT05314	ALU0886	IA704-B	23.00	95	Reprovado	14	34	21
MAT03488	ALU0582	IA202-B	19.00	46	Reprovado	13	20	24
MAT04952	ALU0826	IA602-B	36.67	86	Reprovado	15	58	37
MAT01444	ALU0241	IA204-B	35.67	90	Reprovado	29	42	36
MAT02219	ALU0370	IA605-B	36.33	49	Reprovado	45	59	5
MAT01490	ALU0249	IA202-A	38.33	39	Reprovado	21	43	51
MAT01491	ALU0249	IA203-A	49.67	34	Reprovado	56	49	44
MAT01451	ALU0242	IA405-A	19.00	38	Reprovado	14	11	32
MAT03645	ALU0608	IA503-B	21.67	82	Reprovado	2	38	25
MAT01530	ALU0255	IA506-A	24.67	33	Reprovado	36	26	12
MAT01483	ALU0248	IA401-B	17.00	87	Reprovado	41	5	5
MAT01531	ALU0256	IA501-A	34.67	51	Reprovado	14	50	40
MAT01615	ALU0270	IA801-B	86.00	91	Aprovado	70	90	98
MAT05236	ALU0873	IA304-B	78.00	86	Aprovado	82	87	65
MAT01628	ALU0272	IA402-B	76.00	83	Aprovado	76	89	63
MAT05038	ALU0840	IA604-B	21.67	98	Reprovado	18	9	38
MAT01659	ALU0277	IA103-A	43.67	38	Reprovado	36	58	37
MAT01692	ALU0282	IA806-B	24.00	59	Reprovado	12	50	10
MAT01655	ALU0276	IA605-B	36.00	94	Reprovado	31	39	38
MAT01642	ALU0274	IA204-A	20.67	55	Reprovado	6	27	29
MAT01616	ALU0270	IA802-B	15.67	40	Reprovado	40	0	7
MAT01608	ALU0268	IA206-B	32.00	73	Reprovado	49	16	31
MAT05039	ALU0840	IA605-B	32.67	60	Reprovado	50	43	5
MAT01645	ALU0275	IA201-B	37.00	53	Reprovado	55	30	26
MAT01632	ALU0272	IA406-B	35.00	33	Reprovado	36	12	57
MAT01658	ALU0277	IA102-A	12.67	66	Reprovado	27	9	2
MAT01627	ALU0272	IA401-B	20.00	48	Reprovado	8	26	26
MAT01578	ALU0263	IA806-B	40.00	99	Reprovado	10	51	59
MAT01649	ALU0275	IA205-B	40.67	85	Reprovado	57	16	49
MAT01631	ALU0272	IA405-B	30.00	54	Reprovado	47	41	2
MAT01618	ALU0270	IA804-B	24.67	30	Reprovado	1	33	40
MAT01619	ALU0270	IA805-B	24.00	90	Reprovado	21	4	47
MAT01639	ALU0274	IA201-A	33.33	84	Reprovado	5	37	58
MAT01648	ALU0275	IA204-B	37.00	43	Reprovado	55	27	29
MAT01617	ALU0270	IA803-B	25.33	76	Reprovado	42	23	11
MAT01657	ALU0277	IA101-A	30.00	88	Reprovado	42	34	14
MAT01629	ALU0272	IA403-B	43.00	40	Reprovado	51	35	43
MAT01643	ALU0274	IA205-A	26.67	61	Reprovado	22	54	4
MAT01650	ALU0275	IA206-B	7.67	85	Reprovado	12	3	8
MAT01646	ALU0275	IA202-B	34.67	70	Reprovado	40	16	48
MAT05901	ALU0984	IA503-B	23.67	70	Reprovado	11	50	10
MAT01644	ALU0274	IA206-A	15.00	92	Reprovado	18	10	17
MAT01697	ALU0283	IA705-A	41.33	34	Reprovado	20	45	59
MAT01695	ALU0283	IA703-A	41.67	31	Reprovado	56	23	46
MAT01630	ALU0272	IA404-B	30.00	74	Reprovado	10	57	23
MAT01620	ALU0270	IA806-B	6.67	62	Reprovado	0	9	11
MAT01647	ALU0275	IA203-B	25.33	85	Reprovado	15	8	53
MAT01663	ALU0278	IA501-B	20.00	64	Reprovado	33	24	3
MAT01607	ALU0268	IA205-B	19.33	97	Reprovado	39	14	5
MAT01693	ALU0283	IA701-A	36.33	49	Reprovado	33	57	19
MAT01662	ALU0277	IA106-A	23.33	87	Reprovado	56	5	9
MAT01664	ALU0278	IA502-B	26.33	71	Reprovado	42	18	19
MAT01694	ALU0283	IA702-A	21.33	92	Reprovado	16	14	34
MAT01696	ALU0283	IA704-A	39.00	89	Reprovado	25	33	59
MAT01698	ALU0283	IA706-A	42.00	38	Reprovado	13	54	59
MAT01722	ALU0287	IA506-A	82.67	90	Aprovado	82	98	68
MAT01712	ALU0286	IA202-A	66.33	100	Aprovado	65	72	62
MAT01740	ALU0290	IA406-B	87.00	94	Aprovado	91	84	86
MAT01703	ALU0284	IA605-A	86.33	93	Aprovado	69	93	97
MAT01725	ALU0288	IA203-B	24.67	97	Reprovado	32	7	35
MAT04450	ALU0742	IA104-A	5.00	34	Reprovado	5	8	2
MAT03184	ALU0531	IA304-B	35.33	68	Reprovado	6	54	46
MAT01752	ALU0292	IA706-A	25.00	77	Reprovado	46	29	0
MAT05656	ALU0943	IA504-A	27.33	51	Reprovado	23	28	31
MAT00964	ALU0161	IA204-B	31.00	58	Reprovado	30	51	12
MAT03515	ALU0586	IA205-B	35.00	33	Reprovado	9	38	58
MAT01751	ALU0292	IA705-A	35.67	30	Reprovado	31	32	44
MAT02911	ALU0486	IA401-A	22.00	32	Reprovado	25	11	30
MAT01684	ALU0281	IA104-B	30.33	44	Reprovado	41	50	0
MAT01733	ALU0289	IA405-B	27.67	84	Reprovado	27	47	9
MAT04675	ALU0780	IA501-A	28.33	73	Reprovado	27	51	7
MAT04276	ALU0713	IA304-A	38.33	51	Reprovado	46	46	23
MAT04818	ALU0803	IA806-B	30.00	40	Reprovado	36	49	5
MAT04236	ALU0706	IA706-B	20.67	64	Reprovado	14	29	19
MAT01719	ALU0287	IA503-A	20.67	48	Reprovado	8	44	10
MAT01726	ALU0288	IA204-B	41.00	43	Reprovado	34	49	40
MAT01930	ALU0322	IA504-B	42.67	98	Reprovado	45	51	32
MAT01737	ALU0290	IA403-B	32.33	34	Reprovado	51	37	9
MAT01762	ALU0294	IA504-A	29.00	65	Reprovado	42	41	4
MAT05376	ALU0896	IA606-B	45.33	68	Reprovado	40	48	48
MAT01894	ALU0316	IA804-B	87.33	90	Aprovado	88	84	90
MAT01911	ALU0319	IA303-B	23.67	73	Reprovado	19	29	23
MAT00693	ALU0116	IA703-A	25.00	52	Reprovado	20	18	37
MAT01897	ALU0317	IA801-A	27.67	92	Reprovado	0	49	34
MAT05408	ALU0902	IA402-B	39.00	61	Reprovado	4	55	58
MAT01938	ALU0323	IA406-A	17.67	81	Reprovado	33	17	3
MAT01949	ALU0325	IA605-B	19.00	36	Reprovado	11	32	14
MAT01982	ALU0331	IA402-A	19.33	64	Reprovado	3	0	55
MAT01945	ALU0325	IA601-B	18.33	88	Reprovado	24	26	5
MAT01995	ALU0333	IA103-A	12.00	91	Reprovado	13	0	23
MAT01971	ALU0329	IA103-B	27.33	63	Reprovado	10	49	23
MAT01901	ALU0317	IA805-A	23.67	46	Reprovado	15	22	34
MAT05412	ALU0902	IA406-B	15.67	88	Reprovado	42	4	1
MAT02005	ALU0335	IA501-B	47.67	43	Reprovado	49	36	58
MAT05535	ALU0923	IA503-A	24.33	47	Reprovado	20	18	35
MAT01893	ALU0316	IA803-B	29.67	94	Reprovado	8	25	56
MAT05407	ALU0902	IA401-B	8.67	61	Reprovado	17	3	6
MAT01921	ALU0321	IA201-B	34.33	30	Reprovado	58	34	11
MAT05410	ALU0902	IA404-B	16.00	60	Reprovado	21	12	15
MAT05321	ALU0887	IA605-B	11.67	62	Reprovado	0	15	20
MAT01970	ALU0329	IA102-B	29.67	34	Reprovado	51	37	1
MAT05425	ALU0905	IA201-B	23.00	43	Reprovado	6	27	36
MAT04563	ALU0761	IA703-A	28.00	64	Reprovado	42	38	4
MAT01914	ALU0319	IA306-B	34.33	69	Reprovado	47	3	53
MAT01896	ALU0316	IA806-B	24.67	90	Reprovado	31	15	28
MAT01898	ALU0317	IA802-A	43.00	78	Reprovado	26	54	49
MAT01906	ALU0318	IA404-A	40.00	93	Reprovado	20	50	50
MAT01892	ALU0316	IA802-B	24.67	42	Reprovado	21	12	41
MAT00418	ALU0070	IA104-B	30.33	76	Reprovado	28	13	50
MAT01984	ALU0331	IA404-A	27.00	71	Reprovado	42	21	18
MAT01936	ALU0323	IA404-A	47.00	90	Reprovado	57	25	59
MAT01939	ALU0324	IA601-B	12.00	36	Reprovado	34	1	1
MAT01962	ALU0327	IA106-A	26.67	88	Reprovado	44	33	3
MAT05531	ALU0922	IA505-B	19.33	90	Reprovado	41	1	16
MAT01943	ALU0324	IA605-B	35.33	73	Reprovado	33	38	35
MAT01994	ALU0333	IA102-A	48.33	91	Reprovado	36	54	55
MAT01958	ALU0327	IA102-A	41.00	99	Reprovado	32	42	49
MAT01902	ALU0317	IA806-A	28.67	82	Reprovado	22	57	7
MAT01969	ALU0329	IA101-B	28.00	71	Reprovado	2	50	32
MAT05534	ALU0923	IA502-A	40.00	49	Reprovado	59	52	9
MAT05421	ALU0904	IA503-B	39.67	83	Reprovado	16	55	48
MAT01919	ALU0320	IA705-B	25.67	37	Reprovado	39	31	7
MAT05646	ALU0941	IA206-B	79.67	99	Aprovado	94	68	77
MAT02016	ALU0336	IA506-B	89.00	83	Aprovado	88	80	99
MAT05643	ALU0941	IA203-B	86.00	75	Aprovado	89	70	99
MAT02012	ALU0336	IA502-B	88.67	84	Aprovado	94	90	82
MAT02014	ALU0336	IA504-B	81.67	92	Aprovado	88	84	73
MAT05550	ALU0925	IA206-B	30.00	90	Reprovado	34	36	20
MAT02061	ALU0344	IA403-B	45.00	44	Reprovado	41	45	49
MAT02088	ALU0348	IA706-A	23.67	47	Reprovado	33	37	1
MAT03822	ALU0637	IA606-B	25.33	38	Reprovado	23	29	24
MAT02082	ALU0347	IA306-B	37.33	71	Reprovado	52	27	33
MAT05238	ALU0873	IA306-B	20.67	68	Reprovado	55	4	3
MAT02079	ALU0347	IA303-B	54.00	87	Reprovado	55	56	51
MAT05545	ALU0925	IA201-B	3.33	95	Reprovado	1	7	2
MAT02078	ALU0347	IA302-B	26.33	92	Reprovado	44	30	5
MAT02072	ALU0346	IA702-B	46.00	90	Reprovado	36	50	52
MAT05547	ALU0925	IA203-B	52.67	68	Reprovado	55	56	47
MAT02052	ALU0342	IA206-A	26.33	67	Reprovado	12	18	49
MAT00214	ALU0036	IA204-A	32.00	75	Reprovado	57	12	27
MAT05648	ALU0942	IA702-B	22.00	90	Reprovado	10	43	13
MAT05642	ALU0941	IA202-B	32.33	33	Reprovado	58	8	31
MAT00236	ALU0040	IA302-A	53.33	71	Reprovado	59	55	46
MAT02047	ALU0342	IA201-A	16.33	99	Reprovado	7	34	8
MAT02085	ALU0348	IA703-A	37.67	44	Reprovado	35	21	57
MAT05644	ALU0941	IA204-B	42.33	96	Reprovado	39	44	44
MAT02050	ALU0342	IA204-A	42.67	68	Reprovado	33	57	38
MAT02013	ALU0336	IA503-B	32.33	81	Reprovado	1	37	59
MAT02096	ALU0350	IA802-B	26.00	97	Reprovado	19	16	43
MAT02084	ALU0348	IA702-A	23.00	56	Reprovado	11	43	15
MAT05649	ALU0942	IA703-B	5.67	95	Reprovado	3	5	9
MAT00002	ALU0001	IA202-B	39.33	43	Reprovado	57	8	53
MAT02080	ALU0347	IA304-B	25.33	92	Reprovado	26	12	38
MAT05557	ALU0927	IA601-B	33.00	68	Reprovado	27	35	37
MAT05645	ALU0941	IA205-B	27.33	44	Reprovado	35	23	24
MAT02083	ALU0348	IA701-A	24.00	37	Reprovado	26	33	13
MAT02011	ALU0336	IA501-B	32.67	98	Reprovado	36	8	54
MAT02086	ALU0348	IA704-A	39.33	39	Reprovado	41	43	34
MAT02081	ALU0347	IA305-B	32.67	89	Reprovado	37	44	17
MAT05647	ALU0942	IA701-B	33.00	50	Reprovado	0	46	53
MAT02015	ALU0336	IA505-B	33.67	86	Reprovado	24	54	23
MAT02077	ALU0347	IA301-B	26.33	39	Reprovado	20	54	5
MAT02196	ALU0366	IA306-B	68.00	87	Aprovado	72	65	67
MAT01102	ALU0184	IA304-A	77.67	99	Aprovado	82	71	80
MAT05466	ALU0911	IA506-A	97.67	82	Aprovado	100	93	100
MAT02166	ALU0361	IA206-B	76.67	87	Aprovado	64	91	75
MAT02213	ALU0369	IA305-B	75.00	94	Aprovado	77	61	87
MAT05782	ALU0964	IA504-B	65.33	95	Aprovado	69	67	60
MAT02181	ALU0364	IA103-A	81.00	83	Aprovado	62	93	88
MAT03227	ALU0538	IA205-A	22.00	64	Reprovado	9	24	33
MAT05768	ALU0962	IA302-B	34.67	63	Reprovado	39	22	43
MAT04158	ALU0693	IA206-B	29.00	52	Reprovado	5	56	26
MAT05778	ALU0963	IA306-B	34.00	44	Reprovado	24	26	52
MAT05775	ALU0963	IA303-B	27.33	55	Reprovado	20	29	33
MAT03661	ALU0611	IA301-B	28.33	61	Reprovado	24	3	58
MAT02193	ALU0366	IA303-B	39.67	34	Reprovado	34	29	56
MAT02195	ALU0366	IA305-B	38.67	91	Reprovado	40	24	52
MAT05781	ALU0964	IA503-B	36.33	32	Reprovado	47	26	36
MAT02161	ALU0361	IA201-B	13.00	54	Reprovado	22	8	9
MAT02234	ALU0373	IA602-B	32.33	67	Reprovado	43	34	20
MAT04331	ALU0722	IA805-B	49.33	80	Reprovado	53	43	52
MAT05777	ALU0963	IA305-B	14.00	52	Reprovado	15	2	25
MAT05310	ALU0885	IA206-B	35.00	55	Reprovado	36	14	55
MAT02211	ALU0369	IA303-B	32.00	53	Reprovado	24	23	49
MAT02237	ALU0373	IA605-B	28.67	99	Reprovado	22	15	49
MAT05784	ALU0964	IA506-B	44.00	70	Reprovado	32	55	45
MAT02184	ALU0364	IA106-A	36.33	36	Reprovado	43	55	11
MAT02235	ALU0373	IA603-B	42.00	81	Reprovado	44	59	23
MAT02164	ALU0361	IA204-B	25.33	50	Reprovado	54	9	13
MAT02236	ALU0373	IA604-B	45.67	57	Reprovado	59	58	20
MAT02194	ALU0366	IA304-B	35.00	90	Reprovado	59	39	7
MAT02191	ALU0366	IA301-B	37.67	51	Reprovado	33	53	27
MAT03674	ALU0613	IA102-B	36.00	63	Reprovado	35	40	33
MAT05774	ALU0963	IA302-B	36.67	83	Reprovado	55	27	28
MAT02186	ALU0365	IA202-A	26.67	73	Reprovado	20	10	50
MAT02232	ALU0372	IA806-B	20.67	54	Reprovado	8	29	25
MAT05771	ALU0962	IA305-B	38.67	86	Reprovado	46	18	52
MAT05773	ALU0963	IA301-B	36.33	89	Reprovado	46	42	21
MAT05783	ALU0964	IA505-B	25.67	87	Reprovado	27	20	30
MAT02362	ALU0394	IA404-B	84.00	86	Aprovado	81	81	90
MAT02266	ALU0378	IA604-B	83.67	88	Aprovado	83	68	100
MAT02321	ALU0387	IA305-B	91.00	91	Aprovado	91	82	100
MAT02348	ALU0392	IA502-B	80.00	81	Aprovado	85	63	92
MAT02271	ALU0379	IA703-A	77.33	75	Aprovado	78	68	86
MAT02363	ALU0394	IA405-B	17.33	32	Reprovado	28	3	21
MAT02352	ALU0392	IA506-B	29.67	57	Reprovado	22	9	58
MAT02339	ALU0390	IA705-B	20.00	95	Reprovado	49	5	6
MAT02350	ALU0392	IA504-B	33.67	54	Reprovado	52	13	36
MAT00275	ALU0046	IA505-B	38.67	81	Reprovado	25	56	35
MAT02275	ALU0380	IA101-B	41.33	72	Reprovado	36	36	52
MAT02349	ALU0392	IA503-B	43.67	51	Reprovado	40	48	43
MAT03081	ALU0514	IA203-B	14.33	91	Reprovado	18	14	11
MAT04059	ALU0677	IA103-B	36.00	69	Reprovado	40	10	58
MAT05769	ALU0962	IA303-B	12.00	49	Reprovado	1	28	7
MAT02268	ALU0378	IA606-B	35.67	88	Reprovado	53	3	51
MAT02274	ALU0379	IA706-A	45.67	56	Reprovado	50	50	37
MAT02042	ALU0341	IA402-B	19.67	39	Reprovado	21	14	24
MAT04719	ALU0787	IA503-A	41.33	33	Reprovado	25	58	41
MAT05849	ALU0975	IA405-B	25.00	93	Reprovado	41	12	22
MAT02265	ALU0378	IA603-B	22.33	47	Reprovado	21	0	46
MAT03076	ALU0513	IA204-A	37.00	87	Reprovado	50	44	17
MAT02340	ALU0390	IA706-B	19.00	70	Reprovado	8	37	12
MAT02300	ALU0384	IA202-B	19.67	69	Reprovado	10	14	35
MAT04973	ALU0829	IA405-A	22.33	39	Reprovado	21	34	12
MAT02468	ALU0412	IA602-B	32.33	76	Reprovado	21	40	36
MAT02351	ALU0392	IA505-B	23.00	100	Reprovado	9	36	24
MAT02320	ALU0387	IA304-B	50.67	69	Reprovado	52	47	53
MAT05008	ALU0835	IA304-B	38.33	75	Reprovado	56	36	23
MAT02364	ALU0394	IA406-B	20.00	67	Reprovado	21	31	8
MAT02353	ALU0393	IA401-B	35.67	92	Reprovado	44	13	50
MAT02272	ALU0379	IA704-A	28.00	63	Reprovado	6	33	45
MAT02361	ALU0394	IA403-B	18.67	48	Reprovado	40	0	16
MAT02301	ALU0384	IA203-B	25.67	81	Reprovado	48	4	25
MAT02724	ALU0454	IA606-B	31.67	44	Reprovado	59	23	13
MAT02439	ALU0407	IA403-B	75.67	82	Aprovado	73	91	63
MAT02435	ALU0406	IA405-B	72.00	83	Aprovado	73	77	66
MAT00088	ALU0015	IA204-B	86.33	95	Aprovado	100	98	61
MAT00066	ALU0011	IA106-A	91.00	86	Aprovado	92	100	81
MAT02521	ALU0421	IA301-B	82.67	80	Aprovado	87	69	92
MAT02458	ALU0410	IA804-A	17.00	51	Reprovado	39	11	1
MAT02502	ALU0417	IA506-B	20.33	71	Reprovado	7	8	46
MAT02427	ALU0405	IA803-A	34.00	31	Reprovado	45	57	0
MAT02459	ALU0410	IA805-A	18.00	100	Reprovado	14	12	28
MAT02422	ALU0404	IA304-B	45.33	91	Reprovado	55	56	25
MAT02443	ALU0408	IA601-B	40.33	65	Reprovado	58	49	14
MAT02500	ALU0417	IA504-B	45.33	67	Reprovado	31	57	48
MAT02454	ALU0409	IA406-B	42.67	82	Reprovado	57	23	48
MAT02437	ALU0407	IA401-B	40.33	89	Reprovado	37	29	55
MAT02423	ALU0404	IA305-B	11.33	43	Reprovado	9	13	12
MAT02432	ALU0406	IA402-B	36.00	56	Reprovado	32	51	25
MAT02522	ALU0421	IA302-B	11.00	50	Reprovado	0	8	25
MAT04788	ALU0798	IA606-B	22.00	60	Reprovado	8	42	16
MAT05142	ALU0857	IA406-A	26.00	62	Reprovado	29	26	23
MAT02531	ALU0422	IA405-B	28.00	62	Reprovado	26	15	43
MAT02460	ALU0410	IA806-A	41.67	97	Reprovado	27	48	50
MAT02526	ALU0421	IA306-B	23.00	78	Reprovado	42	0	27
MAT00091	ALU0016	IA201-A	34.00	91	Reprovado	32	24	46
MAT02450	ALU0409	IA402-B	28.00	39	Reprovado	39	34	11
MAT02431	ALU0406	IA401-B	40.67	48	Reprovado	40	27	55
MAT02501	ALU0417	IA505-B	46.00	35	Reprovado	49	53	36
MAT02535	ALU0423	IA603-A	27.33	69	Reprovado	15	31	36
MAT02511	ALU0419	IA503-B	18.33	51	Reprovado	49	2	4
MAT05622	ALU0937	IA506-B	24.00	64	Reprovado	58	3	11
MAT02441	ALU0407	IA405-B	22.67	82	Reprovado	36	5	27
MAT02447	ALU0408	IA605-B	31.33	50	Reprovado	29	19	46
MAT02414	ALU0403	IA102-B	23.67	38	Reprovado	29	34	8
MAT02413	ALU0403	IA101-B	25.67	63	Reprovado	35	2	40
MAT02523	ALU0421	IA303-B	33.00	57	Reprovado	0	59	40
MAT02514	ALU0419	IA506-B	32.00	44	Reprovado	47	11	38
MAT02525	ALU0421	IA305-B	18.00	68	Reprovado	0	51	3
MAT02425	ALU0405	IA801-A	25.33	34	Reprovado	50	5	21
MAT02448	ALU0408	IA606-B	38.33	42	Reprovado	51	11	53
MAT02455	ALU0410	IA801-A	35.67	82	Reprovado	47	23	37
MAT02416	ALU0403	IA104-B	31.67	61	Reprovado	12	38	45
MAT02456	ALU0410	IA802-A	32.00	40	Reprovado	38	11	47
MAT02433	ALU0406	IA403-B	30.67	48	Reprovado	10	51	31
MAT02552	ALU0426	IA502-B	63.00	98	Aprovado	65	64	60
MAT00576	ALU0096	IA106-A	73.67	81	Aprovado	79	82	60
MAT02551	ALU0426	IA501-B	79.00	80	Aprovado	68	85	84
MAT02576	ALU0430	IA102-B	29.33	43	Reprovado	19	22	47
MAT02580	ALU0430	IA106-B	44.00	77	Reprovado	50	50	32
MAT00584	ALU0098	IA202-A	21.67	69	Reprovado	50	7	8
MAT02577	ALU0430	IA103-B	33.00	47	Reprovado	49	7	43
MAT02604	ALU0434	IA706-A	25.00	79	Reprovado	2	54	19
MAT01777	ALU0297	IA801-B	30.67	35	Reprovado	9	30	53
MAT02632	ALU0439	IA804-B	41.67	83	Reprovado	52	59	14
MAT01997	ALU0333	IA105-A	24.33	45	Reprovado	0	57	16
MAT02623	ALU0438	IA101-B	35.67	84	Reprovado	18	55	34
MAT02620	ALU0437	IA204-A	31.33	30	Reprovado	14	39	41
MAT02556	ALU0426	IA506-B	23.00	74	Reprovado	24	1	44
MAT02626	ALU0438	IA104-B	38.00	71	Reprovado	39	37	38
MAT05480	ALU0914	IA602-A	32.00	61	Reprovado	42	14	40
MAT02619	ALU0437	IA203-A	27.67	55	Reprovado	41	18	24
MAT04444	ALU0741	IA404-B	34.00	51	Reprovado	36	14	52
MAT05007	ALU0835	IA303-B	25.67	93	Reprovado	53	2	22
MAT02617	ALU0437	IA201-A	25.00	65	Reprovado	41	11	23
MAT02581	ALU0431	IA201-A	20.67	46	Reprovado	38	24	0
MAT02630	ALU0439	IA802-B	32.67	92	Reprovado	31	46	21
MAT02579	ALU0430	IA105-B	22.67	77	Reprovado	57	3	8
MAT04785	ALU0798	IA603-B	34.33	47	Reprovado	48	36	19
MAT00586	ALU0098	IA204-A	37.67	64	Reprovado	54	37	22
MAT04695	ALU0783	IA503-A	33.00	37	Reprovado	52	5	42
MAT02621	ALU0437	IA205-A	40.33	99	Reprovado	46	28	47
MAT02574	ALU0429	IA406-A	20.67	38	Reprovado	19	11	32
MAT02608	ALU0435	IA604-B	28.00	63	Reprovado	44	20	20
MAT05080	ALU0847	IA804-A	33.33	85	Reprovado	15	54	31
MAT02609	ALU0435	IA605-B	43.67	33	Reprovado	44	32	55
MAT04326	ALU0721	IA206-A	19.67	51	Reprovado	12	7	40
MAT02592	ALU0432	IA206-A	28.00	72	Reprovado	14	44	26
MAT05285	ALU0881	IA105-A	29.33	69	Reprovado	13	20	55
MAT02726	ALU0455	IA802-B	74.00	92	Aprovado	73	87	62
MAT01429	ALU0239	IA101-B	83.33	85	Aprovado	75	100	75
MAT02715	ALU0453	IA803-A	81.67	77	Aprovado	88	85	72
MAT02670	ALU0445	IA806-B	72.67	86	Aprovado	63	74	81
MAT02703	ALU0451	IA403-B	88.33	87	Aprovado	93	98	74
MAT01526	ALU0255	IA502-A	72.67	91	Aprovado	71	72	75
MAT02684	ALU0448	IA502-A	75.33	91	Aprovado	72	60	94
MAT02694	ALU0449	IA806-A	75.00	90	Aprovado	95	65	65
MAT02727	ALU0455	IA803-B	30.67	67	Reprovado	24	32	36
MAT02704	ALU0451	IA404-B	20.67	89	Reprovado	7	35	20
MAT03775	ALU0630	IA101-B	27.67	95	Reprovado	20	4	59
MAT01132	ALU0189	IA804-A	37.67	30	Reprovado	10	52	51
MAT01538	ALU0257	IA402-B	31.33	99	Reprovado	16	26	52
MAT01540	ALU0257	IA404-B	9.67	59	Reprovado	6	18	5
MAT04914	ALU0819	IA206-B	25.67	60	Reprovado	16	33	28
MAT01428	ALU0238	IA806-A	25.67	63	Reprovado	3	50	24
MAT01485	ALU0248	IA403-B	23.33	51	Reprovado	7	55	8
MAT02688	ALU0448	IA506-A	19.00	71	Reprovado	16	22	19
MAT02725	ALU0455	IA801-B	50.00	51	Reprovado	45	46	59
MAT02774	ALU0463	IA602-A	30.67	69	Reprovado	28	15	49
MAT03776	ALU0630	IA102-B	19.00	78	Reprovado	16	10	31
MAT02691	ALU0449	IA803-A	28.33	38	Reprovado	9	24	52
MAT05301	ALU0884	IA603-A	16.33	74	Reprovado	12	7	30
MAT01537	ALU0257	IA401-B	37.67	72	Reprovado	50	29	34
MAT00053	ALU0009	IA205-A	26.67	57	Reprovado	2	31	47
MAT04843	ALU0808	IA301-B	21.00	58	Reprovado	10	16	37
MAT02731	ALU0456	IA601-A	16.67	45	Reprovado	37	3	10
MAT01472	ALU0246	IA802-A	40.67	42	Reprovado	39	41	42
MAT05761	ALU0961	IA301-B	27.67	43	Reprovado	31	13	39
MAT01482	ALU0247	IA206-B	35.67	68	Reprovado	35	27	45
MAT02718	ALU0453	IA806-A	9.67	31	Reprovado	7	5	17
MAT02736	ALU0456	IA606-A	48.00	55	Reprovado	56	57	31
MAT01416	ALU0236	IA606-B	25.00	97	Reprovado	42	9	24
MAT02728	ALU0455	IA804-B	30.33	60	Reprovado	3	38	50
MAT02705	ALU0451	IA405-B	21.67	71	Reprovado	17	19	29
MAT01139	ALU0190	IA405-A	35.00	52	Reprovado	42	5	58
MAT03684	ALU0614	IA706-A	34.00	81	Reprovado	8	46	48
MAT02793	ALU0466	IA603-B	94.00	75	Aprovado	97	97	88
MAT02834	ALU0473	IA602-A	87.33	95	Aprovado	100	73	89
MAT02837	ALU0473	IA605-A	75.67	85	Aprovado	70	86	71
MAT05447	ALU0908	IA705-B	95.00	96	Aprovado	100	94	91
MAT02934	ALU0489	IA606-A	94.33	98	Aprovado	100	88	95
MAT02922	ALU0487	IA806-B	84.67	93	Aprovado	66	97	91
MAT02874	ALU0479	IA406-B	23.67	42	Reprovado	19	47	5
MAT02835	ALU0473	IA603-A	35.00	95	Reprovado	46	58	1
MAT02873	ALU0479	IA405-B	34.00	48	Reprovado	42	4	56
MAT02946	ALU0491	IA206-B	32.67	70	Reprovado	27	28	43
MAT02833	ALU0473	IA601-A	42.00	85	Reprovado	44	36	46
MAT00034	ALU0006	IA104-A	33.33	71	Reprovado	44	51	5
MAT02805	ALU0468	IA203-B	18.00	50	Reprovado	20	11	23
MAT02917	ALU0487	IA801-B	27.00	47	Reprovado	6	43	32
MAT00856	ALU0143	IA204-A	29.33	76	Reprovado	11	43	34
MAT02815	ALU0470	IA201-B	20.00	74	Reprovado	14	9	37
MAT02829	ALU0472	IA703-B	32.67	67	Reprovado	37	8	53
MAT02189	ALU0365	IA205-A	25.67	43	Reprovado	33	26	18
MAT02798	ALU0467	IA302-B	27.33	78	Reprovado	38	13	31
MAT05088	ALU0848	IA106-A	27.33	47	Reprovado	9	33	40
MAT04009	ALU0669	IA301-A	25.00	79	Reprovado	7	37	31
MAT00400	ALU0067	IA604-B	39.33	40	Reprovado	44	49	25
MAT02201	ALU0367	IA805-B	22.67	53	Reprovado	13	39	16
MAT02808	ALU0468	IA206-B	29.33	37	Reprovado	6	45	37
MAT00450	ALU0075	IA506-B	13.00	61	Reprovado	1	12	26
MAT02932	ALU0489	IA604-A	35.67	53	Reprovado	37	39	31
MAT02821	ALU0471	IA301-B	34.00	56	Reprovado	56	26	20
MAT02925	ALU0488	IA403-B	27.33	86	Reprovado	31	4	47
MAT02795	ALU0466	IA605-B	31.67	49	Reprovado	23	26	46
MAT00386	ALU0065	IA702-A	22.00	56	Reprovado	5	9	52
MAT02933	ALU0489	IA605-A	41.00	57	Reprovado	50	37	36
MAT03291	ALU0549	IA103-B	27.33	64	Reprovado	56	23	3
MAT05252	ALU0876	IA802-B	19.33	88	Reprovado	49	1	8
MAT02188	ALU0365	IA204-A	37.00	51	Reprovado	59	41	11
MAT04961	ALU0827	IA205-B	26.67	42	Reprovado	12	38	30
MAT02948	ALU0492	IA702-B	32.00	76	Reprovado	53	38	5
MAT03006	ALU0501	IA706-A	79.00	85	Aprovado	84	93	60
MAT01461	ALU0244	IA303-B	73.33	94	Aprovado	100	60	60
MAT03011	ALU0502	IA105-B	74.67	92	Aprovado	95	66	63
MAT03003	ALU0501	IA703-A	93.00	82	Aprovado	100	91	88
MAT02986	ALU0498	IA304-B	72.00	88	Aprovado	71	77	68
MAT04834	ALU0806	IA304-A	82.67	84	Aprovado	86	99	63
MAT03014	ALU0503	IA702-B	75.33	97	Aprovado	82	76	68
MAT03467	ALU0578	IA205-A	68.33	92	Aprovado	61	63	81
MAT02982	ALU0497	IA606-B	23.67	58	Reprovado	2	29	40
MAT03551	ALU0592	IA605-B	31.00	62	Reprovado	40	3	50
MAT02885	ALU0481	IA205-B	33.67	43	Reprovado	23	35	43
MAT04034	ALU0673	IA402-B	35.33	66	Reprovado	34	52	20
MAT02900	ALU0484	IA202-B	22.33	51	Reprovado	24	14	29
MAT02989	ALU0499	IA301-B	17.33	82	Reprovado	8	40	4
MAT04190	ALU0699	IA802-B	48.33	81	Reprovado	56	31	58
MAT00488	ALU0082	IA102-A	25.00	38	Reprovado	12	30	33
MAT05006	ALU0835	IA302-B	23.67	98	Reprovado	7	19	45
MAT02886	ALU0481	IA206-B	38.00	92	Reprovado	17	49	48
MAT02035	ALU0340	IA101-B	30.67	94	Reprovado	45	25	22
MAT02981	ALU0497	IA605-B	37.67	78	Reprovado	37	34	42
MAT02442	ALU0407	IA406-B	21.67	51	Reprovado	51	0	14
MAT03012	ALU0502	IA106-B	43.67	92	Reprovado	49	48	34
MAT03513	ALU0586	IA203-B	27.67	33	Reprovado	38	23	22
MAT05690	ALU0949	IA302-A	32.00	55	Reprovado	15	24	57
MAT02994	ALU0499	IA306-B	37.33	35	Reprovado	40	28	44
MAT05291	ALU0882	IA405-B	15.33	78	Reprovado	6	0	40
MAT03009	ALU0502	IA103-B	11.00	44	Reprovado	3	0	30
MAT02931	ALU0489	IA603-A	22.67	69	Reprovado	20	9	39
MAT02910	ALU0485	IA306-B	21.67	88	Reprovado	7	44	14
MAT03008	ALU0502	IA102-B	39.00	67	Reprovado	11	51	55
MAT04483	ALU0748	IA601-B	15.67	90	Reprovado	5	42	0
MAT00761	ALU0127	IA805-B	76.00	75	Aprovado	87	80	61
MAT03144	ALU0524	IA206-B	77.33	94	Aprovado	71	63	98
MAT03112	ALU0519	IA504-B	86.00	76	Aprovado	89	72	97
MAT03117	ALU0520	IA303-A	43.33	98	Reprovado	47	50	33
MAT01136	ALU0190	IA402-A	7.00	45	Reprovado	4	10	7
MAT03141	ALU0524	IA203-B	19.00	62	Reprovado	4	2	51
MAT05705	ALU0951	IA305-A	39.00	85	Reprovado	56	30	31
MAT04905	ALU0818	IA703-A	15.67	98	Reprovado	17	0	30
MAT03059	ALU0510	IA605-B	38.00	84	Reprovado	35	36	43
MAT05503	ALU0918	IA801-A	8.67	69	Reprovado	2	16	8
MAT03058	ALU0510	IA604-B	44.00	39	Reprovado	52	32	48
MAT03137	ALU0523	IA505-B	34.00	48	Reprovado	52	36	14
MAT03127	ALU0522	IA401-B	19.00	81	Reprovado	10	9	38
MAT03136	ALU0523	IA504-B	31.67	32	Reprovado	15	35	45
MAT03057	ALU0510	IA603-B	23.33	53	Reprovado	9	23	38
MAT03140	ALU0524	IA202-B	46.00	99	Reprovado	55	24	59
MAT03094	ALU0516	IA604-A	47.67	53	Reprovado	52	45	46
MAT03171	ALU0529	IA203-B	35.00	64	Reprovado	19	51	35
MAT03169	ALU0529	IA201-B	39.33	36	Reprovado	57	37	24
MAT02872	ALU0479	IA404-B	26.00	43	Reprovado	35	24	19
MAT03139	ALU0524	IA201-B	31.00	78	Reprovado	25	56	12
MAT03519	ALU0587	IA803-A	19.67	45	Reprovado	17	2	40
MAT04743	ALU0791	IA103-A	21.00	33	Reprovado	23	11	29
MAT00071	ALU0012	IA505-B	29.67	92	Reprovado	38	0	51
MAT02397	ALU0400	IA403-B	41.00	72	Reprovado	45	59	19
MAT05433	ALU0906	IA103-B	31.00	89	Reprovado	43	2	48
MAT03111	ALU0519	IA503-B	32.00	83	Reprovado	27	15	54
MAT00966	ALU0161	IA206-B	28.33	66	Reprovado	45	30	10
MAT04934	ALU0823	IA402-B	4.67	95	Reprovado	8	1	5
MAT04897	ALU0817	IA701-A	32.67	37	Reprovado	47	50	1
MAT03156	ALU0526	IA506-B	29.67	98	Reprovado	1	47	41
MAT03114	ALU0519	IA506-B	25.00	50	Reprovado	26	17	32
MAT03284	ALU0548	IA102-B	88.33	98	Aprovado	100	71	94
MAT03346	ALU0558	IA104-B	79.67	78	Aprovado	63	79	97
MAT03355	ALU0560	IA601-B	85.33	76	Aprovado	92	82	82
MAT03319	ALU0554	IA301-B	74.00	83	Aprovado	75	69	78
MAT03335	ALU0556	IA605-B	75.33	85	Aprovado	91	75	60
MAT05595	ALU0933	IA703-B	85.67	91	Aprovado	97	77	83
MAT03278	ALU0547	IA602-A	66.00	98	Aprovado	61	77	60
MAT03087	ALU0515	IA203-B	85.67	100	Aprovado	68	89	100
MAT03342	ALU0557	IA406-B	84.00	95	Aprovado	76	76	100
MAT03297	ALU0550	IA503-A	82.00	94	Aprovado	78	75	93
MAT03287	ALU0548	IA105-B	35.33	62	Reprovado	29	39	38
MAT03263	ALU0544	IA505-A	25.00	57	Reprovado	50	9	16
MAT03259	ALU0544	IA501-A	32.00	37	Reprovado	30	10	56
MAT03262	ALU0544	IA504-A	46.00	40	Reprovado	37	50	51
MAT03362	ALU0561	IA802-B	15.67	94	Reprovado	13	3	31
MAT03332	ALU0556	IA602-B	27.00	84	Reprovado	31	22	28
MAT03275	ALU0546	IA205-B	21.33	57	Reprovado	15	10	39
MAT03321	ALU0554	IA303-B	36.33	59	Reprovado	23	54	32
MAT03358	ALU0560	IA604-B	32.67	85	Reprovado	29	34	35
MAT03281	ALU0547	IA605-A	36.67	41	Reprovado	34	50	26
MAT03307	ALU0552	IA401-B	28.33	66	Reprovado	9	38	38
MAT03324	ALU0554	IA306-B	32.67	48	Reprovado	14	58	26
MAT03363	ALU0561	IA803-B	39.00	98	Reprovado	39	54	24
MAT03356	ALU0560	IA602-B	35.67	92	Reprovado	2	47	58
MAT03317	ALU0553	IA805-A	15.00	66	Reprovado	22	0	23
MAT03277	ALU0547	IA601-A	29.00	35	Reprovado	36	15	36
MAT03288	ALU0548	IA106-B	40.67	41	Reprovado	52	13	57
MAT03352	ALU0559	IA404-A	20.67	73	Reprovado	0	42	20
MAT03309	ALU0552	IA403-B	24.33	95	Reprovado	21	6	46
MAT03333	ALU0556	IA603-B	27.33	35	Reprovado	36	7	39
MAT03338	ALU0557	IA402-B	25.00	64	Reprovado	57	11	7
MAT03299	ALU0550	IA505-A	23.67	84	Reprovado	12	48	11
MAT03295	ALU0550	IA501-A	47.67	87	Reprovado	54	31	58
MAT03279	ALU0547	IA603-A	24.67	84	Reprovado	37	12	25
MAT03286	ALU0548	IA104-B	37.00	86	Reprovado	19	49	43
MAT02227	ALU0372	IA801-B	35.33	33	Reprovado	7	47	52
MAT03261	ALU0544	IA503-A	33.33	45	Reprovado	15	41	44
MAT03283	ALU0548	IA101-B	21.33	35	Reprovado	3	57	4
MAT03276	ALU0546	IA206-B	34.67	86	Reprovado	13	36	55
MAT03126	ALU0521	IA506-B	17.67	89	Reprovado	30	21	2
MAT05855	ALU0976	IA305-A	81.33	97	Aprovado	76	86	82
MAT03359	ALU0560	IA605-B	84.67	90	Aprovado	86	79	89
MAT02322	ALU0387	IA306-B	78.00	89	Aprovado	65	95	74
MAT03403	ALU0568	IA701-A	85.67	81	Aprovado	67	93	97
MAT03785	ALU0631	IA305-B	30.00	85	Reprovado	23	56	11
MAT03348	ALU0558	IA106-B	18.33	54	Reprovado	10	32	13
MAT00706	ALU0118	IA804-B	40.33	77	Reprovado	55	32	34
MAT00502	ALU0084	IA204-B	33.33	33	Reprovado	46	5	49
MAT03331	ALU0556	IA601-B	22.67	46	Reprovado	12	31	25
MAT02112	ALU0352	IA206-A	32.33	96	Reprovado	27	42	28
MAT03413	ALU0569	IA105-B	38.00	38	Reprovado	48	39	27
MAT03728	ALU0622	IA102-B	39.67	48	Reprovado	48	52	19
MAT03739	ALU0624	IA701-B	43.33	97	Reprovado	36	45	49
MAT03380	ALU0564	IA202-B	43.67	68	Reprovado	50	27	54
MAT00466	ALU0078	IA104-A	40.67	81	Reprovado	48	55	19
MAT00670	ALU0112	IA404-B	20.67	37	Reprovado	26	3	33
MAT02486	ALU0415	IA802-B	20.67	55	Reprovado	10	2	50
MAT03398	ALU0567	IA102-B	38.67	32	Reprovado	56	56	4
MAT04531	ALU0756	IA801-B	38.00	58	Reprovado	41	42	31
MAT02735	ALU0456	IA605-A	47.67	47	Reprovado	53	34	56
MAT03300	ALU0550	IA506-A	36.00	60	Reprovado	45	22	41
MAT03419	ALU0570	IA405-B	29.00	70	Reprovado	20	21	46
MAT01359	ALU0227	IA503-B	34.00	89	Reprovado	27	36	39
MAT03343	ALU0558	IA101-B	31.67	42	Reprovado	1	52	42
MAT00211	ALU0036	IA201-A	23.67	37	Reprovado	14	5	52
MAT00028	ALU0005	IA404-B	17.67	37	Reprovado	16	8	29
MAT01469	ALU0245	IA405-B	40.67	34	Reprovado	34	56	32
MAT00566	ALU0095	IA302-A	80.00	94	Aprovado	98	70	72
MAT03582	ALU0597	IA706-A	89.67	79	Aprovado	100	96	73
MAT03553	ALU0593	IA501-A	79.67	81	Aprovado	75	94	70
MAT03530	ALU0589	IA702-B	90.00	87	Aprovado	73	99	98
MAT03529	ALU0589	IA701-B	72.33	87	Aprovado	81	71	65
MAT03534	ALU0589	IA706-B	77.00	99	Aprovado	77	87	67
MAT03604	ALU0601	IA604-B	65.33	81	Aprovado	72	62	62
MAT03573	ALU0596	IA103-B	22.00	93	Reprovado	34	8	24
MAT03588	ALU0598	IA106-A	33.33	73	Reprovado	57	43	0
MAT03572	ALU0596	IA102-B	12.67	76	Reprovado	9	14	15
MAT04537	ALU0757	IA201-A	44.33	60	Reprovado	47	51	35
MAT03538	ALU0590	IA104-B	29.67	100	Reprovado	8	55	26
MAT03522	ALU0587	IA806-A	7.00	61	Reprovado	5	0	16
MAT05195	ALU0866	IA305-B	38.67	58	Reprovado	35	26	55
MAT03526	ALU0588	IA404-A	44.67	71	Reprovado	57	39	38
MAT03525	ALU0588	IA403-A	25.00	81	Reprovado	46	6	23
MAT03577	ALU0597	IA701-A	19.33	69	Reprovado	32	16	10
MAT03589	ALU0599	IA701-B	41.67	90	Reprovado	50	31	44
MAT03369	ALU0562	IA403-B	8.33	39	Reprovado	0	14	11
MAT03581	ALU0597	IA705-A	20.33	57	Reprovado	8	8	45
MAT03527	ALU0588	IA405-A	28.67	68	Reprovado	46	32	8
MAT00984	ALU0164	IA506-A	37.33	54	Reprovado	37	44	31
MAT03558	ALU0593	IA506-A	38.67	82	Reprovado	51	43	22
MAT03560	ALU0594	IA402-A	22.67	39	Reprovado	14	37	17
MAT03532	ALU0589	IA704-B	31.67	72	Reprovado	49	9	37
MAT03557	ALU0593	IA505-A	32.00	38	Reprovado	8	54	34
MAT03533	ALU0589	IA705-B	39.67	70	Reprovado	24	40	55
MAT03556	ALU0593	IA504-A	35.33	92	Reprovado	21	38	47
MAT00163	ALU0028	IA301-B	29.33	31	Reprovado	50	1	37
MAT03540	ALU0590	IA106-B	47.33	70	Reprovado	36	55	51
MAT03576	ALU0596	IA106-B	34.67	59	Reprovado	7	56	41
MAT05986	ALU0998	IA704-B	35.33	62	Reprovado	49	33	24
MAT03555	ALU0593	IA503-A	11.33	41	Reprovado	3	0	31
MAT03587	ALU0598	IA105-A	26.33	51	Reprovado	14	49	16
MAT03562	ALU0594	IA404-A	23.67	48	Reprovado	12	40	19
MAT01261	ALU0211	IA201-B	31.67	65	Reprovado	35	15	45
MAT03586	ALU0598	IA104-A	21.67	86	Reprovado	3	43	19
MAT03531	ALU0589	IA703-B	32.67	76	Reprovado	13	35	50
MAT03720	ALU0620	IA406-B	79.00	77	Aprovado	96	72	69
MAT03639	ALU0607	IA303-A	29.00	77	Reprovado	45	28	14
MAT03700	ALU0617	IA704-A	32.33	75	Reprovado	39	54	4
MAT03719	ALU0620	IA405-B	49.33	42	Reprovado	52	51	45
MAT05786	ALU0965	IA702-B	42.00	81	Reprovado	28	41	57
MAT03683	ALU0614	IA705-A	44.67	90	Reprovado	59	28	47
MAT03698	ALU0617	IA702-A	36.67	84	Reprovado	26	39	45
MAT03610	ALU0602	IA504-A	25.00	63	Reprovado	23	44	8
MAT03687	ALU0615	IA303-B	45.33	54	Reprovado	49	57	30
MAT03621	ALU0604	IA403-A	27.33	74	Reprovado	19	37	26
MAT03703	ALU0618	IA201-B	29.67	75	Reprovado	32	55	2
MAT03708	ALU0618	IA206-B	22.33	30	Reprovado	21	33	13
MAT03686	ALU0615	IA302-B	20.33	73	Reprovado	51	1	9
MAT03693	ALU0616	IA303-B	24.33	32	Reprovado	12	55	6
MAT03622	ALU0604	IA404-A	32.33	70	Reprovado	8	57	32
MAT03699	ALU0617	IA703-A	23.33	45	Reprovado	35	3	32
MAT03702	ALU0617	IA706-A	23.33	90	Reprovado	3	24	43
MAT03688	ALU0615	IA304-B	17.33	48	Reprovado	16	15	21
MAT03714	ALU0619	IA206-B	8.33	70	Reprovado	3	4	18
MAT03713	ALU0619	IA205-B	31.00	100	Reprovado	15	19	59
MAT03694	ALU0616	IA304-B	33.67	70	Reprovado	10	34	57
MAT03706	ALU0618	IA204-B	17.33	55	Reprovado	17	10	25
MAT01463	ALU0244	IA305-B	32.67	60	Reprovado	54	5	39
MAT03721	ALU0621	IA401-B	46.67	42	Reprovado	27	54	59
MAT01426	ALU0238	IA804-A	37.33	31	Reprovado	8	59	45
MAT01699	ALU0284	IA601-A	27.33	88	Reprovado	40	18	24
MAT01778	ALU0297	IA802-B	23.00	99	Reprovado	21	33	15
MAT04642	ALU0774	IA404-B	25.67	62	Reprovado	11	7	59
MAT02892	ALU0482	IA806-B	25.00	60	Reprovado	14	17	44
MAT05163	ALU0861	IA203-B	36.00	99	Reprovado	29	43	36
MAT05066	ALU0845	IA502-B	33.67	92	Reprovado	34	43	24
MAT05289	ALU0882	IA403-B	27.33	63	Reprovado	57	4	21
MAT03640	ALU0607	IA304-A	40.00	76	Reprovado	42	32	46
MAT03695	ALU0616	IA305-B	33.67	86	Reprovado	40	44	17
MAT03697	ALU0617	IA701-A	17.33	46	Reprovado	5	42	5
MAT03692	ALU0616	IA302-B	26.00	31	Reprovado	44	21	13
MAT03685	ALU0615	IA301-B	38.00	79	Reprovado	59	4	51
MAT03635	ALU0606	IA305-B	38.00	69	Reprovado	51	22	41
MAT03701	ALU0617	IA705-A	29.00	98	Reprovado	28	40	19
MAT03879	ALU0647	IA503-A	73.00	89	Aprovado	63	88	68
MAT03796	ALU0633	IA304-A	75.67	80	Aprovado	70	68	89
MAT03849	ALU0642	IA403-B	83.67	99	Aprovado	87	90	74
MAT03813	ALU0636	IA303-B	72.33	79	Aprovado	62	79	76
MAT03878	ALU0647	IA502-A	72.33	94	Aprovado	68	64	85
MAT03816	ALU0636	IA306-B	70.33	87	Aprovado	75	65	71
MAT03797	ALU0633	IA305-A	84.67	98	Aprovado	80	97	77
MAT03885	ALU0648	IA703-B	34.00	87	Reprovado	36	34	32
MAT03856	ALU0643	IA404-A	28.00	96	Reprovado	34	49	1
MAT03854	ALU0643	IA402-A	32.33	95	Reprovado	20	36	41
MAT03882	ALU0647	IA506-A	27.67	77	Reprovado	54	7	22
MAT03821	ALU0637	IA605-B	19.33	59	Reprovado	15	16	27
MAT03795	ALU0633	IA303-A	11.33	47	Reprovado	25	9	0
MAT03837	ALU0640	IA103-B	36.33	59	Reprovado	36	15	58
MAT03870	ALU0645	IA606-B	28.67	43	Reprovado	33	5	48
MAT03872	ALU0646	IA502-B	38.00	66	Reprovado	1	59	54
MAT03855	ALU0643	IA403-A	27.33	78	Reprovado	40	2	40
MAT03814	ALU0636	IA304-B	14.67	39	Reprovado	3	26	15
MAT03767	ALU0628	IA405-B	27.00	67	Reprovado	16	36	29
MAT03850	ALU0642	IA404-B	23.33	69	Reprovado	43	18	9
MAT03834	ALU0639	IA306-B	20.00	79	Reprovado	2	49	9
MAT03768	ALU0628	IA406-B	48.67	58	Reprovado	55	46	45
MAT03798	ALU0633	IA306-A	23.33	36	Reprovado	29	5	36
MAT03881	ALU0647	IA505-A	6.33	76	Reprovado	10	7	2
MAT03880	ALU0647	IA504-A	21.33	59	Reprovado	15	12	37
MAT03794	ALU0633	IA302-A	22.67	60	Reprovado	24	37	7
MAT03812	ALU0636	IA302-B	9.00	76	Reprovado	9	9	9
MAT03859	ALU0644	IA501-A	8.67	46	Reprovado	12	6	8
MAT03887	ALU0648	IA705-B	18.00	100	Reprovado	9	11	34
MAT03791	ALU0632	IA805-B	46.00	53	Reprovado	42	53	43
MAT03848	ALU0642	IA402-B	32.67	54	Reprovado	45	2	51
MAT03810	ALU0635	IA406-B	40.33	48	Reprovado	24	48	49
MAT03883	ALU0648	IA701-B	24.00	71	Reprovado	0	56	16
MAT03886	ALU0648	IA704-B	38.33	69	Reprovado	55	14	46
MAT03817	ALU0637	IA601-B	40.67	46	Reprovado	25	43	54
MAT03877	ALU0647	IA501-A	20.33	49	Reprovado	16	18	27
MAT03889	ALU0649	IA301-B	34.33	74	Reprovado	45	52	6
MAT03858	ALU0643	IA406-A	21.00	82	Reprovado	5	40	18
MAT03815	ALU0636	IA305-B	27.33	74	Reprovado	6	44	32
MAT03852	ALU0642	IA406-B	37.67	62	Reprovado	29	37	47
MAT03811	ALU0636	IA301-B	49.00	59	Reprovado	55	34	58
MAT03888	ALU0648	IA706-B	48.00	36	Reprovado	53	57	34
MAT01199	ALU0200	IA605-A	19.00	37	Reprovado	16	39	2
MAT00688	ALU0115	IA304-A	34.33	84	Reprovado	56	23	24
MAT03884	ALU0648	IA702-B	81.00	87	Aprovado	92	77	74
MAT03971	ALU0662	IA105-B	14.33	38	Reprovado	11	9	23
MAT03961	ALU0661	IA401-A	39.33	50	Reprovado	51	50	17
MAT03968	ALU0662	IA102-B	36.67	99	Reprovado	50	13	47
MAT03955	ALU0660	IA401-B	48.00	82	Reprovado	53	39	52
MAT03957	ALU0660	IA403-B	20.67	69	Reprovado	25	21	16
MAT03956	ALU0660	IA402-B	19.33	56	Reprovado	5	7	46
MAT03958	ALU0660	IA404-B	17.00	41	Reprovado	8	9	34
MAT03915	ALU0653	IA603-B	19.00	43	Reprovado	26	27	4
MAT03948	ALU0658	IA806-B	12.33	58	Reprovado	21	16	0
MAT03935	ALU0656	IA405-B	32.67	56	Reprovado	38	13	47
MAT03923	ALU0654	IA405-B	27.67	81	Reprovado	44	34	5
MAT03910	ALU0652	IA504-B	41.33	96	Reprovado	37	59	28
MAT03967	ALU0662	IA101-B	27.33	80	Reprovado	19	5	58
MAT03920	ALU0654	IA402-B	49.00	59	Reprovado	44	44	59
MAT03905	ALU0651	IA205-B	44.33	51	Reprovado	39	54	40
MAT03946	ALU0658	IA804-B	11.33	72	Reprovado	3	16	15
MAT03906	ALU0651	IA206-B	34.67	50	Reprovado	2	45	57
MAT03945	ALU0658	IA803-B	37.00	72	Reprovado	15	56	40
MAT03895	ALU0650	IA801-B	31.33	56	Reprovado	41	28	25
MAT03950	ALU0659	IA602-A	13.67	35	Reprovado	16	0	25
MAT03912	ALU0652	IA506-B	24.00	40	Reprovado	40	21	11
MAT03864	ALU0644	IA506-A	29.00	97	Reprovado	30	51	6
MAT03909	ALU0652	IA503-B	43.00	30	Reprovado	21	50	58
MAT03903	ALU0651	IA203-B	29.00	93	Reprovado	59	26	2
MAT03919	ALU0654	IA401-B	34.00	81	Reprovado	35	43	24
MAT03896	ALU0650	IA802-B	39.67	40	Reprovado	45	40	34
MAT03960	ALU0660	IA406-B	26.00	79	Reprovado	19	9	50
MAT03907	ALU0652	IA501-B	40.67	45	Reprovado	56	19	47
MAT03904	ALU0651	IA204-B	24.67	30	Reprovado	22	24	28
MAT03944	ALU0658	IA802-B	40.00	81	Reprovado	22	43	55
MAT03947	ALU0658	IA805-B	16.33	54	Reprovado	30	13	6
MAT03913	ALU0653	IA601-B	34.33	37	Reprovado	6	49	48
MAT03921	ALU0654	IA403-B	16.33	31	Reprovado	15	24	10
MAT03924	ALU0654	IA406-B	27.00	34	Reprovado	18	43	20
MAT03959	ALU0660	IA405-B	35.67	60	Reprovado	45	36	26
MAT05633	ALU0939	IA105-B	11.00	94	Reprovado	0	21	12
MAT02409	ALU0402	IA303-A	25.33	49	Reprovado	52	5	19
MAT01975	ALU0330	IA601-B	26.33	64	Reprovado	19	29	31
MAT04082	ALU0681	IA602-B	32.00	92	Reprovado	23	16	57
MAT04097	ALU0683	IA605-B	23.00	71	Reprovado	5	38	26
MAT04050	ALU0675	IA306-A	13.00	32	Reprovado	19	19	1
MAT04107	ALU0685	IA203-A	36.33	37	Reprovado	47	59	3
MAT04057	ALU0677	IA101-B	28.33	92	Reprovado	23	29	33
MAT04118	ALU0687	IA202-A	38.33	48	Reprovado	34	53	28
MAT04108	ALU0685	IA204-A	32.00	36	Reprovado	32	30	34
MAT04048	ALU0675	IA304-A	28.33	61	Reprovado	8	57	20
MAT04114	ALU0686	IA304-B	42.67	60	Reprovado	20	55	53
MAT04043	ALU0674	IA305-B	47.67	55	Reprovado	45	44	54
MAT04120	ALU0687	IA204-A	44.67	38	Reprovado	27	57	50
MAT04084	ALU0681	IA604-B	40.67	40	Reprovado	52	55	15
MAT04065	ALU0678	IA203-B	45.00	94	Reprovado	37	53	45
MAT04113	ALU0686	IA303-B	46.33	49	Reprovado	51	40	48
MAT04042	ALU0674	IA304-B	33.67	33	Reprovado	28	30	43
MAT04040	ALU0674	IA302-B	36.00	59	Reprovado	29	37	42
MAT04049	ALU0675	IA305-A	52.00	45	Reprovado	56	50	50
MAT04099	ALU0684	IA701-A	17.67	69	Reprovado	52	1	0
MAT04110	ALU0685	IA206-A	34.00	56	Reprovado	23	28	51
MAT04085	ALU0681	IA605-B	31.33	62	Reprovado	20	16	58
MAT04039	ALU0674	IA301-B	19.67	65	Reprovado	11	38	10
MAT04087	ALU0682	IA401-B	27.33	83	Reprovado	1	50	31
MAT04089	ALU0682	IA403-B	30.00	66	Reprovado	28	27	35
MAT04041	ALU0674	IA303-B	21.67	70	Reprovado	6	57	2
MAT04119	ALU0687	IA203-A	14.67	82	Reprovado	10	23	11
MAT04109	ALU0685	IA205-A	33.67	91	Reprovado	3	58	40
MAT04086	ALU0681	IA606-B	33.67	61	Reprovado	25	56	20
MAT04044	ALU0674	IA306-B	37.00	73	Reprovado	50	7	54
MAT04105	ALU0685	IA201-A	26.67	65	Reprovado	33	2	45
MAT04068	ALU0678	IA206-B	27.00	57	Reprovado	3	50	28
MAT04121	ALU0687	IA205-A	36.33	76	Reprovado	51	13	45
MAT04137	ALU0690	IA303-B	77.33	88	Aprovado	64	88	80
MAT04135	ALU0690	IA301-B	82.67	77	Aprovado	62	100	86
MAT04227	ALU0705	IA203-A	87.00	97	Aprovado	93	74	94
MAT04225	ALU0705	IA201-A	36.67	80	Reprovado	52	57	1
MAT04230	ALU0705	IA206-A	32.33	69	Reprovado	47	25	25
MAT04172	ALU0696	IA702-B	8.33	68	Reprovado	1	13	11
MAT04219	ALU0704	IA401-B	36.00	51	Reprovado	23	30	55
MAT04168	ALU0695	IA204-B	16.33	74	Reprovado	23	4	22
MAT04258	ALU0710	IA704-B	25.00	97	Reprovado	48	13	14
MAT04175	ALU0696	IA705-B	32.33	40	Reprovado	47	48	2
MAT04215	ALU0703	IA603-A	44.00	63	Reprovado	28	58	46
MAT04257	ALU0710	IA703-B	30.33	42	Reprovado	15	42	34
MAT04260	ALU0710	IA706-B	26.33	48	Reprovado	27	41	11
MAT04224	ALU0704	IA406-B	21.00	51	Reprovado	55	5	3
MAT04262	ALU0711	IA502-A	20.33	70	Reprovado	24	24	13
MAT04267	ALU0712	IA801-A	38.00	32	Reprovado	23	43	48
MAT04223	ALU0704	IA405-B	37.00	67	Reprovado	56	14	41
MAT04213	ALU0703	IA601-A	37.67	98	Reprovado	21	37	55
MAT04214	ALU0703	IA602-A	49.33	30	Reprovado	52	59	37
MAT04264	ALU0711	IA504-A	15.00	97	Reprovado	8	16	21
MAT04256	ALU0710	IA702-B	19.00	53	Reprovado	10	26	21
MAT04261	ALU0711	IA501-A	35.33	58	Reprovado	20	51	35
MAT04154	ALU0693	IA202-B	40.00	81	Reprovado	29	39	52
MAT04136	ALU0690	IA302-B	32.00	95	Reprovado	16	50	30
MAT04173	ALU0696	IA703-B	30.00	37	Reprovado	33	38	19
MAT04218	ALU0703	IA606-A	33.00	99	Reprovado	22	39	38
MAT04165	ALU0695	IA201-B	33.67	89	Reprovado	49	33	19
MAT04229	ALU0705	IA205-A	52.00	76	Reprovado	59	42	55
MAT04216	ALU0703	IA604-A	39.00	91	Reprovado	48	47	22
MAT04263	ALU0711	IA503-A	36.33	32	Reprovado	30	59	20
MAT04180	ALU0697	IA204-B	32.67	58	Reprovado	40	53	5
MAT04217	ALU0703	IA605-A	23.67	79	Reprovado	37	25	9
MAT04253	ALU0709	IA305-A	36.00	68	Reprovado	28	46	34
MAT04266	ALU0711	IA506-A	7.00	92	Reprovado	6	13	2
MAT04226	ALU0705	IA202-A	30.33	79	Reprovado	55	4	32
MAT04221	ALU0704	IA403-B	26.33	75	Reprovado	17	53	9
MAT04176	ALU0696	IA706-B	28.67	90	Reprovado	27	5	54
MAT04220	ALU0704	IA402-B	38.00	67	Reprovado	13	42	59
MAT04367	ALU0728	IA405-B	41.00	70	Reprovado	55	10	58
MAT04354	ALU0726	IA704-B	28.00	98	Reprovado	41	32	11
MAT04328	ALU0722	IA802-B	6.33	76	Reprovado	6	5	8
MAT04319	ALU0720	IA705-B	22.00	99	Reprovado	23	33	10
MAT04376	ALU0730	IA702-A	18.67	37	Reprovado	4	7	45
MAT04368	ALU0728	IA406-B	27.67	57	Reprovado	1	46	36
MAT04337	ALU0723	IA205-A	24.33	44	Reprovado	18	7	48
MAT04381	ALU0731	IA801-B	16.33	83	Reprovado	8	0	41
MAT04360	ALU0727	IA404-B	21.67	54	Reprovado	7	51	7
MAT04321	ALU0721	IA201-A	33.67	62	Reprovado	42	37	22
MAT04357	ALU0727	IA401-B	17.33	50	Reprovado	41	7	4
MAT04378	ALU0730	IA704-A	22.00	31	Reprovado	17	10	39
MAT04375	ALU0730	IA701-A	31.67	81	Reprovado	48	11	36
MAT04379	ALU0730	IA705-A	45.67	53	Reprovado	29	53	55
MAT04358	ALU0727	IA402-B	23.00	40	Reprovado	47	5	17
MAT04314	ALU0719	IA806-A	47.00	59	Reprovado	55	37	49
MAT04352	ALU0726	IA702-B	35.67	49	Reprovado	22	54	31
MAT04359	ALU0727	IA403-B	29.33	97	Reprovado	22	48	18
MAT04382	ALU0731	IA802-B	48.33	53	Reprovado	54	34	57
MAT04312	ALU0719	IA804-A	26.00	80	Reprovado	6	17	55
MAT04323	ALU0721	IA203-A	31.67	98	Reprovado	41	14	40
MAT04362	ALU0727	IA406-B	20.67	92	Reprovado	5	20	37
MAT04361	ALU0727	IA405-B	33.67	64	Reprovado	52	44	5
MAT04377	ALU0730	IA703-A	49.00	69	Reprovado	41	53	53
MAT04325	ALU0721	IA205-A	39.33	38	Reprovado	24	51	43
MAT04349	ALU0725	IA205-B	20.33	46	Reprovado	14	29	18
MAT04380	ALU0730	IA706-A	19.67	98	Reprovado	21	12	26
MAT04501	ALU0751	IA601-B	73.33	93	Aprovado	81	62	77
MAT04523	ALU0754	IA405-A	37.33	51	Reprovado	48	37	27
MAT04524	ALU0754	IA406-A	46.67	44	Reprovado	44	57	39
MAT04584	ALU0764	IA406-A	27.67	99	Reprovado	20	44	19
MAT04487	ALU0748	IA605-B	9.00	49	Reprovado	3	18	6
MAT04449	ALU0742	IA103-A	35.33	84	Reprovado	52	37	17
MAT04448	ALU0742	IA102-A	28.67	94	Reprovado	16	42	28
MAT04551	ALU0759	IA103-B	53.00	79	Reprovado	58	57	44
MAT04544	ALU0758	IA702-A	23.67	52	Reprovado	48	12	11
MAT04505	ALU0751	IA605-B	24.00	83	Reprovado	38	17	17
MAT04520	ALU0754	IA402-A	38.00	90	Reprovado	25	31	58
MAT04586	ALU0765	IA702-B	47.67	50	Reprovado	43	50	50
MAT04492	ALU0749	IA404-B	39.33	92	Reprovado	47	55	16
MAT04496	ALU0750	IA602-B	32.33	46	Reprovado	39	56	2
MAT04509	ALU0752	IA403-B	35.00	82	Reprovado	48	30	27
MAT04583	ALU0764	IA405-A	39.67	84	Reprovado	49	20	50
MAT04485	ALU0748	IA603-B	24.00	99	Reprovado	17	54	1
MAT04581	ALU0764	IA403-A	29.67	39	Reprovado	2	42	45
MAT04579	ALU0764	IA401-A	38.67	71	Reprovado	58	51	7
MAT04452	ALU0742	IA106-A	14.00	48	Reprovado	20	6	16
MAT04519	ALU0754	IA401-A	32.33	36	Reprovado	24	44	29
MAT04580	ALU0764	IA402-A	19.33	63	Reprovado	10	46	2
MAT04493	ALU0749	IA405-B	35.67	84	Reprovado	8	43	56
MAT04486	ALU0748	IA604-B	19.67	66	Reprovado	36	22	1
MAT04532	ALU0756	IA802-B	19.33	74	Reprovado	18	33	7
MAT04463	ALU0744	IA305-B	19.33	80	Reprovado	5	7	46
MAT04480	ALU0747	IA704-B	45.67	77	Reprovado	33	46	58
MAT04585	ALU0765	IA701-B	33.33	81	Reprovado	29	15	56
MAT04556	ALU0760	IA502-B	9.00	78	Reprovado	8	3	16
MAT04490	ALU0749	IA402-B	23.00	72	Reprovado	3	36	30
MAT04564	ALU0761	IA704-A	25.67	85	Reprovado	4	38	35
MAT04549	ALU0759	IA101-B	32.67	77	Reprovado	22	53	23
MAT04576	ALU0763	IA304-A	21.67	58	Reprovado	4	54	7
MAT04536	ALU0756	IA806-B	37.67	73	Reprovado	34	50	29
MAT04557	ALU0760	IA503-B	43.33	65	Reprovado	58	19	53
MAT04488	ALU0748	IA606-B	44.00	68	Reprovado	57	54	21
MAT04562	ALU0761	IA702-A	37.00	52	Reprovado	31	54	26
MAT04541	ALU0757	IA205-A	29.33	35	Reprovado	47	7	34
MAT04545	ALU0758	IA703-A	43.00	94	Reprovado	21	59	49
MAT04508	ALU0752	IA402-B	25.00	71	Reprovado	26	24	25
MAT04548	ALU0758	IA706-A	24.67	88	Reprovado	44	21	9
MAT04521	ALU0754	IA403-A	14.00	72	Reprovado	11	9	22
MAT04547	ALU0758	IA705-A	22.00	97	Reprovado	24	6	36
MAT04590	ALU0765	IA706-B	82.00	97	Aprovado	63	84	99
MAT04611	ALU0769	IA103-A	73.67	93	Aprovado	75	63	83
MAT04607	ALU0768	IA605-A	86.00	79	Aprovado	97	95	66
MAT04707	ALU0785	IA303-A	72.00	91	Aprovado	86	62	68
MAT04756	ALU0793	IA804-B	73.00	82	Aprovado	68	67	84
MAT04738	ALU0790	IA104-B	83.00	83	Aprovado	90	61	98
MAT04622	ALU0771	IA602-A	14.67	35	Reprovado	13	18	13
MAT04612	ALU0769	IA104-A	37.67	94	Reprovado	56	44	13
MAT04605	ALU0768	IA603-A	31.33	93	Reprovado	35	30	29
MAT04613	ALU0769	IA105-A	20.67	81	Reprovado	59	0	3
MAT04698	ALU0783	IA506-A	45.33	34	Reprovado	54	55	27
MAT04595	ALU0766	IA105-A	24.00	67	Reprovado	25	25	22
MAT04600	ALU0767	IA104-B	18.00	39	Reprovado	8	11	35
MAT04728	ALU0788	IA106-A	32.67	65	Reprovado	31	29	38
MAT04598	ALU0767	IA102-B	27.33	72	Reprovado	5	26	51
MAT04609	ALU0769	IA101-A	33.67	84	Reprovado	39	16	46
MAT04736	ALU0790	IA102-B	36.00	47	Reprovado	13	45	50
MAT04588	ALU0765	IA704-B	22.33	37	Reprovado	22	7	38
MAT04604	ALU0768	IA602-A	42.00	70	Reprovado	35	37	54
MAT04614	ALU0769	IA106-A	19.33	41	Reprovado	20	3	35
MAT04601	ALU0767	IA105-B	31.33	67	Reprovado	39	37	18
MAT04706	ALU0785	IA302-A	40.33	44	Reprovado	39	51	31
MAT04697	ALU0783	IA505-A	30.33	69	Reprovado	35	24	32
MAT04603	ALU0768	IA601-A	24.33	99	Reprovado	12	15	46
MAT04615	ALU0770	IA601-B	43.00	86	Reprovado	48	52	29
MAT04606	ALU0768	IA604-A	29.33	97	Reprovado	25	12	51
MAT04668	ALU0778	IA706-A	33.67	61	Reprovado	22	43	36
MAT04682	ALU0781	IA502-A	28.67	37	Reprovado	12	19	55
MAT04708	ALU0785	IA304-A	50.00	49	Reprovado	43	59	48
MAT04591	ALU0766	IA101-A	35.00	62	Reprovado	57	24	24
MAT04755	ALU0793	IA803-B	15.33	69	Reprovado	14	28	4
MAT04684	ALU0781	IA504-A	26.67	40	Reprovado	23	21	36
MAT04681	ALU0781	IA501-A	38.00	74	Reprovado	57	53	4
MAT04593	ALU0766	IA103-A	33.00	38	Reprovado	50	43	6
MAT04683	ALU0781	IA503-A	15.00	64	Reprovado	21	1	23
MAT04592	ALU0766	IA102-A	25.33	82	Reprovado	47	12	17
MAT04694	ALU0783	IA502-A	32.67	77	Reprovado	20	50	28
MAT04685	ALU0781	IA505-A	33.33	44	Reprovado	47	53	0
MAT04608	ALU0768	IA606-A	54.33	39	Reprovado	52	57	54
MAT04686	ALU0781	IA506-A	32.00	70	Reprovado	33	7	56
MAT04587	ALU0765	IA703-B	38.33	45	Reprovado	2	57	56
MAT04616	ALU0770	IA602-B	46.33	80	Reprovado	59	51	29
MAT04740	ALU0790	IA106-B	69.67	85	Aprovado	77	62	70
MAT04816	ALU0803	IA804-B	81.00	91	Aprovado	67	93	83
MAT04768	ALU0795	IA504-B	79.33	94	Aprovado	87	70	81
MAT04811	ALU0802	IA805-B	76.67	76	Aprovado	79	61	90
MAT04778	ALU0797	IA702-A	16.67	75	Reprovado	22	25	3
MAT04807	ALU0802	IA801-B	43.00	82	Reprovado	37	35	57
MAT04810	ALU0802	IA804-B	27.33	86	Reprovado	34	39	9
MAT04750	ALU0792	IA604-B	33.00	56	Reprovado	54	2	43
MAT04803	ALU0801	IA403-B	45.67	48	Reprovado	23	57	57
MAT04758	ALU0793	IA806-B	27.33	75	Reprovado	12	37	33
MAT04804	ALU0801	IA404-B	33.67	54	Reprovado	32	49	20
MAT04704	ALU0784	IA406-A	35.00	97	Reprovado	7	47	51
MAT04780	ALU0797	IA704-A	25.67	36	Reprovado	18	17	42
MAT04809	ALU0802	IA803-B	38.33	100	Reprovado	30	56	29
MAT04739	ALU0790	IA105-B	39.33	69	Reprovado	55	40	23
MAT04744	ALU0791	IA104-A	34.33	35	Reprovado	34	11	58
MAT04774	ALU0796	IA704-A	32.33	86	Reprovado	48	39	10
MAT04737	ALU0790	IA103-B	31.67	94	Reprovado	25	46	24
MAT04805	ALU0801	IA405-B	23.00	46	Reprovado	4	38	27
MAT04815	ALU0803	IA803-B	32.33	48	Reprovado	40	36	21
MAT04783	ALU0798	IA601-B	27.00	69	Reprovado	11	34	36
MAT04703	ALU0784	IA405-A	22.33	36	Reprovado	11	54	2
MAT04746	ALU0791	IA106-A	44.33	54	Reprovado	42	53	38
MAT04808	ALU0802	IA802-B	23.67	67	Reprovado	24	8	39
MAT04741	ALU0791	IA101-A	16.67	70	Reprovado	3	29	18
MAT04813	ALU0803	IA801-B	37.33	40	Reprovado	52	8	52
MAT04735	ALU0790	IA101-B	37.67	66	Reprovado	44	22	47
MAT04776	ALU0796	IA706-A	18.67	33	Reprovado	24	21	11
MAT04742	ALU0791	IA102-A	29.67	52	Reprovado	23	35	31
MAT04800	ALU0800	IA606-B	30.00	34	Reprovado	30	21	39
MAT04814	ALU0803	IA802-B	36.33	86	Reprovado	9	59	41
MAT04699	ALU0784	IA401-A	20.33	30	Reprovado	6	20	35
MAT04773	ALU0796	IA703-A	32.67	69	Reprovado	53	0	45
MAT05831	ALU0972	IA305-A	81.33	81	Aprovado	79	76	89
MAT05884	ALU0981	IA604-B	82.00	85	Aprovado	92	94	60
MAT05850	ALU0975	IA406-B	15.00	70	Reprovado	26	19	0
MAT05891	ALU0982	IA205-B	25.00	71	Reprovado	44	20	11
MAT05875	ALU0980	IA201-B	16.33	99	Reprovado	6	14	29
MAT05832	ALU0972	IA306-A	21.33	89	Reprovado	3	33	28
MAT05848	ALU0975	IA404-B	37.67	65	Reprovado	29	53	31
MAT05864	ALU0978	IA702-A	27.33	69	Reprovado	32	42	8
MAT05930	ALU0989	IA502-A	25.67	40	Reprovado	28	40	9
MAT05867	ALU0978	IA705-A	42.33	86	Reprovado	50	34	43
MAT05880	ALU0980	IA206-B	28.00	89	Reprovado	22	20	42
MAT05886	ALU0981	IA606-B	32.67	33	Reprovado	50	21	27
MAT05877	ALU0980	IA203-B	31.67	90	Reprovado	30	58	7
MAT05883	ALU0981	IA603-B	27.67	94	Reprovado	20	53	10
MAT05859	ALU0977	IA103-B	27.67	89	Reprovado	0	47	36
MAT05889	ALU0982	IA203-B	34.00	33	Reprovado	32	28	42
MAT05860	ALU0977	IA104-B	41.33	64	Reprovado	57	34	33
MAT05878	ALU0980	IA204-B	29.67	81	Reprovado	19	54	16
MAT05865	ALU0978	IA703-A	32.00	51	Reprovado	21	19	56
MAT05868	ALU0978	IA706-A	31.00	86	Reprovado	13	52	28
MAT05917	ALU0987	IA501-A	33.00	44	Reprovado	55	40	4
MAT05929	ALU0989	IA501-A	25.67	96	Reprovado	39	27	11
MAT05866	ALU0978	IA704-A	22.33	84	Reprovado	46	11	10
MAT05888	ALU0982	IA202-B	30.67	90	Reprovado	38	9	45
MAT05913	ALU0986	IA603-B	45.00	59	Reprovado	46	45	44
MAT05881	ALU0981	IA601-B	28.67	86	Reprovado	8	32	46
MAT05833	ALU0973	IA401-A	20.00	30	Reprovado	30	19	11
MAT05914	ALU0986	IA604-B	40.33	91	Reprovado	22	49	50
MAT05890	ALU0982	IA204-B	26.00	59	Reprovado	25	10	43
MAT05920	ALU0987	IA504-A	17.67	56	Reprovado	6	45	2
MAT01258	ALU0210	IA204-B	48.00	91	Reprovado	55	32	57
MAT04170	ALU0695	IA206-B	17.33	73	Reprovado	25	24	3
MAT04888	ALU0815	IA204-A	15.67	88	Reprovado	2	14	31
MAT00044	ALU0008	IA202-A	82.00	100	Aprovado	92	93	61
MAT00045	ALU0008	IA203-A	18.33	85	Reprovado	36	12	7
MAT00016	ALU0003	IA304-B	43.00	71	Reprovado	53	33	43
MAT00015	ALU0003	IA303-B	30.00	95	Reprovado	23	33	34
MAT00033	ALU0006	IA103-A	30.00	99	Reprovado	25	24	41
MAT00043	ALU0008	IA201-A	19.67	32	Reprovado	41	12	6
MAT00021	ALU0004	IA703-A	34.33	100	Reprovado	36	40	27
MAT00017	ALU0003	IA305-B	31.67	84	Reprovado	17	47	31
MAT00024	ALU0004	IA706-A	31.67	88	Reprovado	13	59	23
MAT00041	ALU0007	IA505-B	38.00	33	Reprovado	52	43	19
MAT00055	ALU0010	IA701-A	54.00	71	Reprovado	58	46	58
MAT01141	ALU0191	IA601-A	81.00	78	Aprovado	71	89	83
MAT00096	ALU0016	IA206-A	30.00	84	Reprovado	12	37	41
MAT00123	ALU0021	IA103-B	32.00	86	Reprovado	27	16	53
MAT00119	ALU0020	IA705-B	29.33	87	Reprovado	45	24	19
MAT00105	ALU0018	IA603-B	42.33	56	Reprovado	21	52	54
MAT00129	ALU0022	IA403-A	22.00	86	Reprovado	28	23	15
MAT00135	ALU0023	IA603-A	7.67	51	Reprovado	19	2	2
MAT00089	ALU0015	IA205-B	40.00	66	Reprovado	27	45	48
MAT00103	ALU0018	IA601-B	16.00	42	Reprovado	13	21	14
MAT00121	ALU0021	IA101-B	29.33	31	Reprovado	44	20	24
MAT00100	ALU0017	IA504-B	45.00	63	Reprovado	57	28	50
MAT00098	ALU0017	IA502-B	38.67	89	Reprovado	55	14	47
MAT00133	ALU0023	IA601-A	21.00	84	Reprovado	5	45	13
MAT00126	ALU0021	IA106-B	31.33	65	Reprovado	15	46	33
MAT00057	ALU0010	IA703-A	18.33	63	Reprovado	28	8	19
MAT00048	ALU0008	IA206-A	31.00	40	Reprovado	10	35	48
MAT00095	ALU0016	IA205-A	32.00	51	Reprovado	30	42	24
MAT00092	ALU0016	IA202-A	30.67	57	Reprovado	35	11	46
MAT00108	ALU0018	IA606-B	25.00	31	Reprovado	20	46	9
MAT00063	ALU0011	IA103-A	45.67	78	Reprovado	39	43	55
MAT00120	ALU0020	IA706-B	28.33	96	Reprovado	55	5	25
MAT00132	ALU0022	IA406-A	26.33	60	Reprovado	46	24	9
MAT00104	ALU0018	IA602-B	29.33	78	Reprovado	49	29	10
MAT00047	ALU0008	IA205-A	25.33	83	Reprovado	23	32	21
MAT00124	ALU0021	IA104-B	25.33	62	Reprovado	23	5	48
MAT00134	ALU0023	IA602-A	43.00	83	Reprovado	47	23	59
MAT00090	ALU0015	IA206-B	27.33	92	Reprovado	2	40	40
MAT00099	ALU0017	IA503-B	23.00	36	Reprovado	13	25	31
MAT00122	ALU0021	IA102-B	12.67	55	Reprovado	0	9	29
MAT00130	ALU0022	IA404-A	33.67	43	Reprovado	46	29	26
MAT00081	ALU0014	IA303-B	38.67	82	Reprovado	34	27	55
MAT00102	ALU0017	IA506-B	15.33	95	Reprovado	24	5	17
MAT00101	ALU0017	IA505-B	39.00	55	Reprovado	36	59	22
MAT00094	ALU0016	IA204-A	32.00	92	Reprovado	35	59	2
MAT00157	ALU0027	IA201-B	8.67	94	Reprovado	17	6	3
MAT00222	ALU0037	IA306-B	28.33	77	Reprovado	27	38	20
MAT00231	ALU0039	IA203-B	23.33	39	Reprovado	53	6	11
MAT00181	ALU0031	IA601-B	27.00	54	Reprovado	58	12	11
MAT00139	ALU0024	IA201-B	16.33	62	Reprovado	42	3	4
MAT00327	ALU0055	IA203-A	48.33	54	Reprovado	55	51	39
MAT00553	ALU0093	IA401-A	32.00	80	Reprovado	40	0	56
MAT00427	ALU0072	IA401-B	21.00	89	Reprovado	6	43	14
MAT00511	ALU0086	IA801-A	26.33	98	Reprovado	1	28	50
MAT00562	ALU0094	IA604-A	29.33	59	Reprovado	34	24	30
MAT00660	ALU0110	IA206-B	95.67	77	Aprovado	99	89	99
MAT00687	ALU0115	IA303-A	15.33	44	Reprovado	17	21	8
MAT00755	ALU0126	IA705-B	22.00	50	Reprovado	40	0	26
MAT00661	ALU0111	IA801-A	30.00	89	Reprovado	28	21	41
MAT00787	ALU0132	IA601-B	76.67	77	Aprovado	65	89	76
MAT00808	ALU0135	IA304-B	36.67	81	Reprovado	54	22	34
MAT00789	ALU0132	IA603-B	35.33	61	Reprovado	28	49	29
MAT00853	ALU0143	IA201-A	33.67	63	Reprovado	19	49	33
MAT00830	ALU0139	IA502-B	30.33	94	Reprovado	33	26	32
MAT01008	ALU0168	IA406-A	35.00	92	Reprovado	51	38	16
MAT00963	ALU0161	IA203-B	32.33	69	Reprovado	27	44	26
MAT01122	ALU0187	IA106-B	26.67	42	Reprovado	30	42	8
MAT01167	ALU0195	IA303-B	30.67	81	Reprovado	15	33	44
MAT01186	ALU0198	IA404-A	30.33	79	Reprovado	4	50	37
MAT01067	ALU0178	IA605-B	33.00	85	Reprovado	47	20	32
MAT01080	ALU0180	IA506-B	12.67	46	Reprovado	11	2	25
MAT01219	ALU0204	IA801-B	25.33	30	Reprovado	41	3	32
MAT01278	ALU0213	IA206-B	25.00	31	Reprovado	13	34	28
MAT01208	ALU0202	IA602-B	46.00	35	Reprovado	56	55	27
MAT01389	ALU0232	IA403-B	22.33	50	Reprovado	52	6	9
MAT01418	ALU0237	IA302-B	26.00	46	Reprovado	38	27	13
MAT01603	ALU0268	IA201-B	33.33	49	Reprovado	25	52	23
MAT01544	ALU0258	IA102-B	47.67	93	Reprovado	42	46	55
MAT01499	ALU0250	IA305-B	34.33	34	Reprovado	55	4	44
MAT01734	ALU0289	IA406-B	28.67	80	Reprovado	32	15	39
MAT01779	ALU0297	IA803-B	37.33	41	Reprovado	18	41	53
MAT01755	ALU0293	IA803-B	47.67	69	Reprovado	37	58	48
MAT01660	ALU0277	IA104-A	43.33	96	Reprovado	57	26	47
MAT01873	ALU0313	IA801-A	78.00	84	Aprovado	98	67	69
MAT01849	ALU0309	IA101-B	27.67	64	Reprovado	34	14	35
MAT02049	ALU0342	IA203-A	83.00	91	Aprovado	99	88	62
MAT01985	ALU0331	IA405-A	24.00	88	Reprovado	0	21	51
MAT01957	ALU0327	IA101-A	43.67	33	Reprovado	38	46	47
MAT01960	ALU0327	IA104-A	28.67	65	Reprovado	14	58	14
MAT02134	ALU0356	IA804-B	92.67	86	Aprovado	86	93	99
MAT02074	ALU0346	IA704-B	28.00	61	Reprovado	57	26	1
MAT02224	ALU0371	IA704-B	38.33	56	Reprovado	36	52	27
MAT02215	ALU0370	IA601-B	32.00	96	Reprovado	52	20	24
MAT02337	ALU0390	IA703-B	26.33	87	Reprovado	18	44	17
MAT02264	ALU0378	IA602-B	37.00	73	Reprovado	59	21	31
MAT02242	ALU0374	IA304-B	31.00	78	Reprovado	47	39	7
MAT02513	ALU0419	IA505-B	71.33	99	Aprovado	61	60	93
MAT02495	ALU0416	IA805-B	30.33	47	Reprovado	19	26	46
MAT02428	ALU0405	IA804-A	41.00	96	Reprovado	19	57	47
MAT02555	ALU0426	IA505-B	49.00	50	Reprovado	45	51	51
MAT02591	ALU0432	IA205-A	43.67	43	Reprovado	42	38	51
MAT02809	ALU0469	IA601-B	48.00	81	Reprovado	37	52	55
MAT02732	ALU0456	IA602-A	21.00	48	Reprovado	30	12	21
MAT02918	ALU0487	IA802-B	34.67	88	Reprovado	18	40	46
MAT02889	ALU0482	IA803-B	30.67	81	Reprovado	2	31	59
MAT02919	ALU0487	IA803-B	42.33	50	Reprovado	29	43	55
MAT02921	ALU0487	IA805-B	34.67	85	Reprovado	28	53	23
MAT03077	ALU0513	IA205-A	82.67	99	Aprovado	62	90	96
MAT03159	ALU0527	IA203-A	81.33	89	Aprovado	61	94	89
MAT03147	ALU0525	IA803-A	74.00	83	Aprovado	66	92	64
MAT03242	ALU0541	IA602-A	37.00	90	Reprovado	36	56	19
MAT03118	ALU0520	IA304-A	46.00	63	Reprovado	41	54	43
MAT03174	ALU0529	IA206-B	34.00	95	Reprovado	38	30	34
MAT03361	ALU0561	IA801-B	16.33	61	Reprovado	26	3	20
MAT03313	ALU0553	IA801-A	16.33	50	Reprovado	5	11	33
MAT03608	ALU0602	IA502-A	79.33	91	Aprovado	87	76	75
MAT03704	ALU0618	IA202-B	54.00	32	Reprovado	58	56	48
MAT03900	ALU0650	IA806-B	80.33	76	Aprovado	86	78	77
MAT03897	ALU0650	IA803-B	45.67	33	Reprovado	46	55	36
MAT03851	ALU0642	IA405-B	38.00	75	Reprovado	32	46	36
MAT04014	ALU0669	IA306-A	34.00	79	Reprovado	34	49	19
MAT03911	ALU0652	IA505-B	39.00	99	Reprovado	40	44	33
MAT04125	ALU0688	IA303-B	80.33	99	Aprovado	79	90	72
MAT04083	ALU0681	IA603-B	38.67	32	Reprovado	26	54	36
MAT04209	ALU0702	IA803-B	16.33	82	Reprovado	6	41	2
MAT04171	ALU0696	IA701-B	22.00	50	Reprovado	39	0	27
MAT04188	ALU0698	IA606-B	33.33	66	Reprovado	29	22	49
MAT04356	ALU0726	IA706-B	87.33	97	Aprovado	90	79	93
MAT04341	ALU0724	IA403-B	32.00	44	Reprovado	59	18	19
MAT04306	ALU0718	IA704-A	34.67	78	Reprovado	30	27	47
MAT04454	ALU0743	IA502-A	30.33	94	Reprovado	34	54	3
MAT04434	ALU0739	IA106-A	36.00	100	Reprovado	51	12	45
MAT04433	ALU0739	IA105-A	26.67	85	Reprovado	6	56	18
MAT04566	ALU0761	IA706-A	34.00	81	Reprovado	11	41	50
MAT04543	ALU0758	IA701-A	28.67	44	Reprovado	36	23	27
MAT04786	ALU0798	IA604-B	32.00	91	Reprovado	28	41	27
MAT04676	ALU0780	IA502-A	16.33	45	Reprovado	11	20	18
MAT04919	ALU0820	IA205-A	17.00	50	Reprovado	39	9	3
MAT04967	ALU0828	IA805-B	34.00	75	Reprovado	0	52	50
MAT05047	ALU0842	IA501-B	22.33	98	Reprovado	2	10	55
MAT05180	ALU0864	IA102-A	85.67	81	Aprovado	86	94	77
MAT05205	ALU0868	IA303-B	28.00	87	Reprovado	28	6	50
MAT05435	ALU0906	IA105-B	20.67	32	Reprovado	56	0	6
MAT05429	ALU0905	IA205-B	26.67	84	Reprovado	37	43	0
MAT05351	ALU0892	IA405-B	33.00	31	Reprovado	21	19	59
MAT05385	ALU0898	IA103-B	4.67	46	Reprovado	3	8	3
MAT05302	ALU0884	IA604-A	28.67	98	Reprovado	11	32	43
MAT05519	ALU0920	IA805-A	23.00	74	Reprovado	3	59	7
MAT05651	ALU0942	IA705-B	15.67	67	Reprovado	3	26	18
MAT05751	ALU0959	IA603-B	29.33	38	Reprovado	18	11	59
MAT05919	ALU0987	IA503-A	31.00	86	Reprovado	44	39	10
MAT05993	ALU0999	IA805-A	86.33	98	Aprovado	82	91	86
MAT05994	ALU0999	IA806-A	79.33	90	Aprovado	67	86	85
MAT05984	ALU0998	IA702-B	30.67	39	Reprovado	12	25	55
MAT05981	ALU0997	IA205-A	27.00	50	Reprovado	23	47	11
MAT05980	ALU0997	IA204-A	20.67	42	Reprovado	27	6	29
MAT05983	ALU0998	IA701-B	38.67	97	Reprovado	57	15	44
MAT05989	ALU0999	IA801-A	30.00	69	Reprovado	34	50	6
MAT05987	ALU0998	IA705-B	45.33	55	Reprovado	53	51	32
MAT05992	ALU0999	IA804-A	42.33	59	Reprovado	57	53	17
MAT05990	ALU0999	IA802-A	30.67	31	Reprovado	43	12	37
MAT05997	ALU1000	IA103-A	18.67	67	Reprovado	33	6	17
MAT05979	ALU0997	IA203-A	30.00	44	Reprovado	22	22	46
MAT05982	ALU0997	IA206-A	8.33	76	Reprovado	9	1	15
MAT05991	ALU0999	IA803-A	19.67	96	Reprovado	23	7	29
MAT05998	ALU1000	IA104-A	23.33	90	Reprovado	46	20	4
MAT05995	ALU1000	IA101-A	32.00	53	Reprovado	29	59	8
MAT06000	ALU1000	IA106-A	25.67	50	Reprovado	46	28	3
MAT05988	ALU0998	IA706-B	27.33	76	Reprovado	45	10	27
MAT05977	ALU0997	IA201-A	42.00	92	Reprovado	28	41	57
\.


--
-- TOC entry 4919 (class 0 OID 16669)
-- Dependencies: 217
-- Data for Name: professores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.professores (id_professor, nome, titulacao, area_atuacao, regime_trabalho, email_institucional, data_admissao) FROM stdin;
PROF001	Ricardo Almeida Prado	Especialização	Programação	Integral	ricardo.prado@docente.uma.example	2008-08-01
PROF002	Fernanda Lopes Teixeira	Doutorado	Programação	Integral	fernanda.teixeira@docente.uma.example	2012-02-01
PROF003	Marcos Vinícius Rocha	Especialização	Programação	Integral	marcos.rocha@docente.uma.example	2021-02-01
PROF004	Patrícia Nunes Barros	Doutorado	Programação	Integral	patricia.barros@docente.uma.example	2014-02-01
PROF005	Helena Duarte Campos	Mestrado	Matemática e Estatística	Integral	helena.campos@docente.uma.example	2014-08-01
PROF006	Eduardo Siqueira Melo	Doutorado	Matemática e Estatística	Horista	eduardo.melo@docente.uma.example	2016-02-01
PROF007	Luciana Freitas Moura	Doutorado	Matemática e Estatística	Horista	luciana.moura@docente.uma.example	2018-08-01
PROF008	Rogério Batista Lima	Doutorado	Matemática e Estatística	Integral	rogerio.lima@docente.uma.example	2018-02-01
PROF009	Juliana Castro Reis	Doutorado	Inteligência Artificial	Horista	juliana.reis@docente.uma.example	2011-08-01
PROF010	André Luiz Monteiro	Mestrado	Inteligência Artificial	Parcial	andre.monteiro@docente.uma.example	2009-08-01
PROF011	Carolina Vieira Paiva	Mestrado	Inteligência Artificial	Integral	carolina.paiva@docente.uma.example	2020-02-01
PROF012	Thiago Moreira Dias	Mestrado	Inteligência Artificial	Parcial	thiago.dias@docente.uma.example	2019-02-01
PROF013	Renata Cardoso Pires	Especialização	Dados	Integral	renata.pires@docente.uma.example	2009-02-01
PROF014	Gustavo Henrique Brito	Mestrado	Dados	Integral	gustavo.brito@docente.uma.example	2015-02-01
PROF015	Aline Correia Fonseca	Doutorado	Dados	Parcial	aline.fonseca@docente.uma.example	2022-08-01
PROF016	Leandro Pacheco Souto	Doutorado	Dados	Parcial	leandro.souto@docente.uma.example	2019-02-01
PROF017	Sérgio Antunes Farias	Especialização	Sistemas e Infraestrutura	Parcial	sergio.farias@docente.uma.example	2010-02-01
PROF018	Mariana Queiroz Leal	Mestrado	Sistemas e Infraestrutura	Integral	mariana.leal@docente.uma.example	2013-08-01
PROF019	Daniel Ferraz Coelho	Doutorado	Sistemas e Infraestrutura	Parcial	daniel.coelho@docente.uma.example	2015-08-01
PROF020	Vanessa Rezende Cunha	Doutorado	Sistemas e Infraestrutura	Integral	vanessa.cunha@docente.uma.example	2009-08-01
PROF021	Cláudia Matos Ventura	Doutorado	Humanidades e Gestão	Parcial	claudia.ventura@docente.uma.example	2010-02-01
PROF022	Paulo Roberto Sales	Mestrado	Humanidades e Gestão	Parcial	paulo.sales@docente.uma.example	2014-08-01
PROF023	Beatriz Fontes Amaral	Doutorado	Humanidades e Gestão	Horista	beatriz.amaral@docente.uma.example	2012-08-01
PROF024	Fábio Torres Medeiros	Doutorado	Humanidades e Gestão	Integral	fabio.medeiros@docente.uma.example	2016-08-01
\.


--
-- TOC entry 4927 (class 0 OID 16709)
-- Dependencies: 225
-- Data for Name: regras_risco; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regras_risco (id_regra, regra, condicao, pontuacao, interpretacao) FROM stdin;
REG01	nota_baixa	media_atual < 6	15	Indicador acadêmico crítico
REG02	frequencia_baixa	frequencia_pct < 75	15	Risco de reprovação/falta de vínculo
REG03	queda_desempenho	tendencia_media <= -1	10	Queda relevante vs. período anterior
REG04	reprovacoes	disciplinas_reprovadas_historico >= 2	10	Repetição de disciplinas
REG05	pendencias	atividades_pendentes >= 4	8	Acúmulo de atividades
REG06	financeiro	renda_per_capita < 1500	10	Possível necessidade de apoio
REG07	jornada_trabalho	horas_trabalho_dia >= 8 e horas_estudo_semana < 7	8	Conciliação trabalho-estudo desfavorável
REG08	deslocamento	distancia_km >= 20 ou tempo_deslocamento_min >= 90	10	Deslocamento relevante
REG09	responsabilidades	responsabilidades_familiares_h_semana >= 12	6	Carga familiar relevante
REG10	apoio	apoio_psicossocial_solicitado = Sim	4	Sinal de necessidade de acolhimento; não é diagnóstico
REG11	faixas	0-19 baixo; 20-34 moderado; 35-54 alto; 55+ crítico	-	Triagem individual; não sentença de evasão
\.


--
-- TOC entry 4923 (class 0 OID 16689)
-- Dependencies: 221
-- Data for Name: socioeconomico; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.socioeconomico (id_aluno, renda_familiar_mensal, moradores_domicilio, renda_per_capita, auxilio_bolsa, trabalha, horas_trabalho_dia, horas_estudo_semana, responsabilidades_familiares_h_semana, distancia_km, tempo_deslocamento_min, meio_transporte, prouni, fies, desconto_funcionario) FROM stdin;
ALU0268	2975	5	595.0	sim	Tempo integral	8	2.2	0	11.7	65	Carro	sim	não	não
ALU0101	3890	3	1296.67	sim	Meio período	6	6.3	8	6.6	36	Ônibus	sim	não	não
ALU0622	4121	1	4121.0	sim	Tempo integral	8	5.3	4	20.5	121	Moto	sim	não	não
ALU0954	901	4	225.25	sim	Meio período	6	6.4	8	7.0	29	Ônibus	sim	não	não
ALU0454	3264	4	816.0	sim	Tempo integral	8	6.0	12	16.3	87	Bicicleta	sim	não	não
ALU0456	2514	5	502.8	sim	Não trabalha	0	7.3	4	21.0	121	Ônibus	sim	não	não
ALU0019	1355	5	271.0	sim	Tempo integral	8	6.0	0	12.3	49	Carro	sim	não	não
ALU0968	3430	1	3430.0	sim	Tempo integral	8	4.8	4	21.2	87	Moto	sim	não	não
ALU0849	1550	4	387.5	sim	Não trabalha	0	10.1	0	8.4	34	Bicicleta	sim	não	não
ALU0936	4347	3	1449.0	sim	Não trabalha	0	9.8	0	30.6	138	Carro	sim	não	não
ALU0951	2341	2	1170.5	sim	Meio período	6	8.2	12	9.2	47	Ônibus	sim	não	não
ALU0215	2651	5	530.2	sim	Não trabalha	0	8.7	4	4.8	26	Ônibus	sim	não	não
ALU0531	5343	3	1781.0	sim	Meio período	6	6.3	0	10.9	60	Ônibus	sim	não	não
ALU0471	2017	2	1008.5	sim	Não trabalha	0	12.1	0	5.1	26	Ônibus	sim	não	não
ALU0649	7523	5	1504.6	sim	Tempo integral	8	4.0	8	4.6	21	Ônibus	sim	não	não
ALU0638	6518	2	3259.0	sim	Não trabalha	0	11.6	4	10.8	59	Moto	sim	não	não
ALU0303	1807	4	451.75	sim	Tempo integral	8	8.1	4	13.4	72	Carro	sim	não	não
ALU0859	1556	6	259.33	sim	Não trabalha	0	10.5	0	2.6	12	Aplicativo	sim	não	não
ALU0189	2456	5	491.2	sim	Não trabalha	0	16.1	8	23.4	100	A pé	sim	não	não
ALU0483	810	6	135.0	sim	Meio período	6	2.7	0	5.4	21	Moto	sim	não	não
ALU0312	3860	4	965.0	sim	Não trabalha	0	11.2	12	7.9	35	Ônibus	sim	não	não
ALU0832	3348	4	837.0	sim	Não trabalha	0	8.0	0	5.6	31	Moto	sim	não	não
ALU0333	3358	1	3358.0	sim	Não trabalha	0	14.5	4	13.5	54	Ônibus	sim	não	não
ALU0266	3519	2	1759.5	sim	Meio período	6	8.6	4	6.1	32	Aplicativo	sim	não	não
ALU0338	2150	1	2150.0	sim	Tempo integral	8	9.4	4	19.2	89	Ônibus	sim	não	não
ALU0696	3868	1	3868.0	sim	Não trabalha	0	11.2	8	6.3	25	Ônibus	sim	não	não
ALU0201	2867	3	955.67	sim	Não trabalha	0	11.9	12	6.4	38	Carro	sim	não	não
ALU0417	2719	3	906.33	sim	Meio período	6	6.7	0	13.1	74	Ônibus	sim	não	não
ALU0502	2734	4	683.5	sim	Tempo integral	8	7.6	8	5.9	34	Ônibus	sim	não	não
ALU0228	1028	2	514.0	sim	Tempo integral	8	9.2	0	10.1	59	Aplicativo	sim	não	não
ALU0774	4424	6	737.33	sim	Não trabalha	0	12.3	12	5.8	30	Moto	sim	não	não
ALU0927	10476	2	5238.0	sim	Tempo integral	8	5.3	0	2.0	8	Ônibus	sim	não	não
ALU0956	2244	6	374.0	sim	Meio período	6	10.3	0	22.8	104	Ônibus	sim	não	não
ALU0523	1676	2	838.0	sim	Não trabalha	0	9.9	4	5.8	25	Moto	sim	não	não
ALU0314	1412	2	706.0	sim	Tempo integral	8	6.7	12	3.7	19	Moto	sim	não	não
ALU0238	1414	1	1414.0	sim	Não trabalha	0	11.6	4	7.1	34	Ônibus	sim	não	não
ALU0881	3063	3	1021.0	sim	Não trabalha	0	10.0	8	7.4	43	Ônibus	sim	não	não
ALU0167	3942	1	3942.0	sim	Meio período	6	10.6	12	4.0	19	Carro	sim	não	não
ALU0480	4166	3	1388.67	sim	Não trabalha	0	14.2	0	3.4	14	Bicicleta	sim	não	não
ALU0808	4435	4	1108.75	sim	Meio período	6	12.7	8	7.8	38	Carro	sim	não	não
ALU0347	1872	5	374.4	sim	Tempo integral	8	7.7	0	14.8	78	Aplicativo	sim	não	não
ALU0154	1772	2	886.0	sim	Meio período	6	9.6	16	2.5	14	Carro	sim	não	não
ALU0132	5236	3	1745.33	sim	Meio período	6	10.6	8	10.6	47	Bicicleta	sim	não	não
ALU0571	4747	1	4747.0	sim	Não trabalha	0	10.3	12	3.1	15	Ônibus	sim	não	não
ALU0407	1828	5	365.6	sim	Tempo integral	8	2.2	4	5.7	23	Ônibus	sim	não	não
ALU0123	3241	1	3241.0	sim	Tempo integral	8	6.7	0	7.0	41	Aplicativo	sim	não	não
ALU0673	6181	6	1030.17	sim	Não trabalha	0	8.7	0	10.8	47	Ônibus	sim	não	não
ALU0699	1996	3	665.33	sim	Não trabalha	0	8.8	0	23.4	106	Moto	sim	não	não
ALU0329	3254	2	1627.0	sim	Não trabalha	0	9.9	0	10.8	61	Ônibus	sim	não	não
ALU0770	1390	2	695.0	sim	Meio período	6	11.9	0	19.9	87	Carro	sim	não	não
ALU0712	1954	4	488.5	sim	Meio período	6	7.7	8	7.9	40	Ônibus	sim	não	não
ALU0404	6274	5	1254.8	sim	Não trabalha	0	13.2	0	9.1	43	Ônibus	sim	não	não
ALU0485	1192	2	596.0	sim	Tempo integral	8	7.8	16	14.7	67	Bicicleta	sim	não	não
ALU0392	2461	1	2461.0	sim	Não trabalha	0	11.2	20	17.8	95	Moto	sim	não	não
ALU0060	1428	6	238.0	sim	Não trabalha	0	8.4	0	10.8	43	Ônibus	sim	não	não
ALU0250	1447	4	361.75	sim	Meio período	6	6.2	8	1.5	6	Carro	sim	não	não
ALU0703	5265	3	1755.0	sim	Meio período	6	3.6	16	18.9	92	Ônibus	sim	não	não
ALU0367	2340	3	780.0	sim	Meio período	6	10.7	4	13.5	59	Moto	sim	não	não
ALU0846	2358	3	786.0	sim	Não trabalha	0	16.1	4	14.0	73	Ônibus	sim	não	não
ALU0071	2393	1	2393.0	sim	Meio período	6	13.9	20	8.0	40	Aplicativo	sim	não	não
ALU0704	1819	2	909.5	sim	Tempo integral	8	7.1	4	27.1	158	Aplicativo	sim	não	não
ALU0544	3268	5	653.6	sim	Não trabalha	0	10.9	16	14.4	81	Ônibus	sim	não	não
ALU0988	3713	6	618.83	sim	Não trabalha	0	6.7	8	6.0	35	Carro	sim	não	não
ALU0984	1683	1	1683.0	sim	Tempo integral	8	5.8	8	3.8	17	Moto	sim	não	não
ALU0496	1534	2	767.0	sim	Não trabalha	0	10.3	0	4.0	23	Moto	sim	não	não
ALU0079	3186	3	1062.0	sim	Tempo integral	8	6.0	0	6.0	27	Aplicativo	sim	não	não
ALU0584	1499	3	499.67	sim	Não trabalha	0	13.8	0	14.1	77	Ônibus	sim	não	não
ALU0518	2619	6	436.5	sim	Meio período	6	6.3	0	4.0	22	Aplicativo	sim	não	não
ALU0878	2298	6	383.0	sim	Não trabalha	0	9.0	4	29.7	120	Moto	sim	não	não
ALU0194	2030	5	406.0	sim	Não trabalha	0	13.0	0	9.9	57	Aplicativo	sim	não	não
ALU0741	1793	6	298.83	sim	Não trabalha	0	11.4	20	16.8	96	Carro	sim	não	não
ALU0355	1669	6	278.17	sim	Não trabalha	0	11.1	4	19.0	78	Ônibus	sim	não	não
ALU0223	2148	4	537.0	sim	Tempo integral	8	9.6	4	11.1	60	Aplicativo	sim	não	não
ALU0552	1910	5	382.0	sim	Tempo integral	8	10.0	8	8.4	40	Carro	sim	não	não
ALU0376	7606	2	3803.0	sim	Não trabalha	0	4.8	16	5.6	32	Ônibus	sim	não	não
ALU1000	3283	1	3283.0	sim	Não trabalha	0	8.4	4	16.7	84	Ônibus	sim	não	não
ALU0530	3294	2	1647.0	sim	Tempo integral	8	8.1	0	10.0	53	Carro	sim	não	não
ALU0251	4295	3	1431.67	sim	Não trabalha	0	10.0	0	3.1	12	Ônibus	sim	não	não
ALU0326	2881	1	2881.0	sim	Não trabalha	0	17.8	0	2.9	16	A pé	sim	não	não
ALU0935	3267	2	1633.5	sim	Não trabalha	0	9.9	16	8.1	41	Moto	sim	não	não
ALU0742	4663	3	1554.33	sim	Meio período	6	5.3	0	10.8	49	Carro	sim	não	não
ALU0902	5120	3	1706.67	sim	Meio período	6	8.3	16	13.9	77	Ônibus	sim	não	não
ALU0513	3130	4	782.5	sim	Meio período	6	7.7	20	8.2	47	Bicicleta	sim	não	não
ALU0033	4006	6	667.67	sim	Meio período	6	4.7	0	13.4	59	Carro	sim	não	não
ALU0179	3617	2	1808.5	sim	Meio período	6	11.8	8	55.0	180	Ônibus	sim	não	não
ALU0466	1617	2	808.5	sim	Não trabalha	0	10.5	12	19.9	115	Ônibus	sim	não	não
ALU0917	5752	6	958.67	sim	Não trabalha	0	9.6	0	18.8	87	Ônibus	sim	não	não
ALU0034	2433	1	2433.0	sim	Meio período	6	9.3	16	3.8	21	Moto	sim	não	não
ALU0724	4987	4	1246.75	sim	Tempo integral	8	11.7	16	14.2	72	Moto	sim	não	não
ALU0538	1238	2	619.0	sim	Não trabalha	0	8.2	4	5.5	26	Moto	sim	não	não
ALU0069	3281	5	656.2	sim	Não trabalha	0	15.7	0	11.4	67	Ônibus	sim	não	não
ALU0874	6757	5	1351.4	sim	Não trabalha	0	3.5	4	2.2	12	Carro	sim	não	não
ALU0922	2446	4	611.5	sim	Meio período	6	9.5	12	7.5	40	Aplicativo	sim	não	não
ALU0615	4264	4	1066.0	sim	Tempo integral	8	6.5	4	5.5	29	Ônibus	sim	não	não
ALU0634	1816	3	605.33	sim	Não trabalha	0	13.0	0	4.4	26	Moto	sim	não	não
ALU0269	3369	6	561.5	sim	Meio período	6	10.2	4	12.2	63	Moto	sim	não	não
ALU0325	6023	1	6023.0	sim	Não trabalha	0	7.9	8	10.1	46	A pé	sim	não	não
ALU0027	1701	4	425.25	sim	Não trabalha	0	8.7	0	12.7	52	Carro	sim	não	não
ALU0099	4280	6	713.33	sim	Não trabalha	0	12.3	16	6.8	30	Ônibus	sim	não	não
ALU0933	4924	3	1641.33	sim	Não trabalha	0	15.6	0	7.2	35	Aplicativo	sim	não	não
ALU0005	8346	1	8346.0	sim	Tempo integral	8	5.2	12	8.5	39	Bicicleta	não	sim	não
ALU0226	1067	3	355.67	sim	Não trabalha	0	13.5	4	4.3	18	Carro	não	sim	não
ALU0294	1568	2	784.0	sim	Não trabalha	0	11.0	4	6.8	33	Bicicleta	não	sim	não
ALU0479	6440	4	1610.0	sim	Meio período	6	10.7	0	2.6	11	Ônibus	não	sim	não
ALU0840	1708	6	284.67	sim	Tempo integral	8	8.2	4	11.4	59	A pé	não	sim	não
ALU0606	2931	6	488.5	sim	Meio período	6	9.6	12	8.6	47	Aplicativo	não	sim	não
ALU0557	4977	4	1244.25	sim	Tempo integral	8	10.1	0	12.0	54	Ônibus	não	sim	não
ALU0507	2681	4	670.25	sim	Não trabalha	0	14.6	0	6.2	33	Bicicleta	não	sim	não
ALU0059	2000	4	500.0	sim	Tempo integral	8	8.8	0	5.6	28	Aplicativo	não	sim	não
ALU0608	1396	5	279.2	sim	Tempo integral	8	2.0	12	7.8	39	Ônibus	não	sim	não
ALU0898	2428	3	809.33	sim	Tempo integral	8	6.3	4	4.4	26	Ônibus	não	sim	não
ALU0940	5274	2	2637.0	sim	Não trabalha	0	19.8	0	12.8	73	Ônibus	não	sim	não
ALU0715	5556	5	1111.2	sim	Não trabalha	0	6.7	0	21.3	107	Ônibus	não	sim	não
ALU0133	2708	1	2708.0	sim	Não trabalha	0	13.1	0	4.3	17	Ônibus	não	sim	não
ALU0656	5197	6	866.17	sim	Não trabalha	0	15.4	4	10.3	60	Aplicativo	não	sim	não
ALU0088	3046	1	3046.0	sim	Tempo integral	8	3.6	8	17.1	79	Aplicativo	não	sim	não
ALU0093	4735	6	789.17	sim	Não trabalha	0	10.1	8	3.7	18	Ônibus	não	sim	não
ALU0229	17457	3	5819.0	sim	Meio período	6	8.5	0	3.3	15	Aplicativo	não	sim	não
ALU0855	2756	6	459.33	sim	Tempo integral	8	11.8	8	5.7	26	Moto	não	sim	não
ALU0001	1583	4	395.75	sim	Não trabalha	0	18.3	4	28.7	161	Ônibus	não	sim	não
ALU0848	2088	2	1044.0	sim	Meio período	6	13.6	0	23.8	126	Ônibus	não	sim	não
ALU0187	8035	5	1607.0	sim	Tempo integral	8	5.3	16	8.3	44	Carro	não	sim	não
ALU0331	5327	3	1775.67	sim	Não trabalha	0	15.5	8	36.2	180	Carro	não	sim	não
ALU0371	3089	6	514.83	sim	Não trabalha	0	11.0	12	3.7	18	Ônibus	não	sim	não
ALU0684	3457	1	3457.0	sim	Não trabalha	0	7.6	0	3.9	22	Bicicleta	não	sim	não
ALU0403	3245	3	1081.67	sim	Não trabalha	0	6.8	16	15.0	79	Carro	não	sim	não
ALU0192	4917	6	819.5	sim	Não trabalha	0	9.5	12	9.2	53	Ônibus	não	sim	não
ALU0293	2817	1	2817.0	sim	Não trabalha	0	8.8	0	2.3	13	Ônibus	não	sim	não
ALU0637	6125	2	3062.5	sim	Não trabalha	0	13.1	4	3.3	13	Moto	não	sim	não
ALU0301	2662	4	665.5	sim	Tempo integral	8	9.7	12	6.5	36	Carro	não	sim	não
ALU0700	3969	6	661.5	sim	Não trabalha	0	10.6	0	4.3	20	Ônibus	não	sim	não
ALU0819	3554	4	888.5	sim	Tempo integral	8	2.6	12	3.0	12	Moto	não	sim	não
ALU0904	5558	6	926.33	sim	Tempo integral	8	10.2	16	8.5	41	Ônibus	não	sim	não
ALU0527	1878	1	1878.0	sim	Meio período	6	9.8	16	6.4	35	Carro	não	sim	não
ALU0171	2386	6	397.67	sim	Meio período	6	3.4	12	8.3	40	Carro	não	sim	não
ALU0373	5113	2	2556.5	sim	Tempo integral	8	4.6	4	7.9	34	Bicicleta	não	sim	não
ALU0299	4869	5	973.8	sim	Meio período	6	9.1	4	7.5	44	Carro	não	sim	não
ALU0235	7606	4	1901.5	sim	Meio período	6	8.5	0	13.3	57	Carro	não	sim	não
ALU0048	5795	2	2897.5	sim	Não trabalha	0	9.9	0	3.5	18	Bicicleta	não	sim	não
ALU0383	1943	1	1943.0	sim	Meio período	6	7.0	8	7.0	37	Ônibus	não	sim	não
ALU0115	4974	1	4974.0	sim	Não trabalha	0	8.5	0	4.2	21	Ônibus	não	sim	não
ALU0130	3498	2	1749.0	sim	Meio período	6	5.2	8	12.2	49	Moto	não	sim	não
ALU0654	2954	3	984.67	sim	Tempo integral	8	10.3	20	9.7	52	Ônibus	não	sim	não
ALU0366	2686	1	2686.0	sim	Não trabalha	0	13.0	16	9.6	49	A pé	não	sim	não
ALU0769	5518	3	1839.33	sim	Não trabalha	0	8.8	0	3.4	17	Ônibus	não	sim	não
ALU0730	2563	3	854.33	sim	Meio período	6	9.1	4	8.9	37	Carro	não	sim	não
ALU0919	1800	3	600.0	sim	Não trabalha	0	11.5	0	12.2	50	Moto	não	sim	não
ALU0039	6987	1	6987.0	sim	Não trabalha	0	11.2	0	3.0	13	Ônibus	não	sim	não
ALU0682	2722	4	680.5	sim	Não trabalha	0	10.3	8	2.7	15	Ônibus	não	sim	não
ALU0014	5045	4	1261.25	sim	Tempo integral	8	10.7	4	7.4	31	Moto	não	sim	não
ALU0745	1389	6	231.5	sim	Tempo integral	8	4.5	12	8.3	36	Ônibus	não	sim	não
ALU0960	2357	4	589.25	sim	Não trabalha	0	14.3	0	3.4	14	A pé	não	sim	não
ALU0165	3891	5	778.2	sim	Tempo integral	8	5.7	12	14.8	76	Ônibus	não	sim	não
ALU0482	2025	3	675.0	sim	Meio período	6	3.8	16	5.6	33	Carro	não	sim	não
ALU0925	2025	5	405.0	sim	Tempo integral	8	10.8	16	8.5	36	Ônibus	não	sim	não
ALU0489	2338	4	584.5	sim	Meio período	6	6.3	0	10.4	56	Ônibus	não	sim	não
ALU0751	2024	4	506.0	sim	Não trabalha	0	13.7	4	6.0	33	Moto	não	sim	não
ALU0522	1220	6	203.33	sim	Não trabalha	0	8.9	0	9.8	50	Carro	não	sim	não
ALU0472	2316	1	2316.0	sim	Meio período	6	8.9	0	7.0	30	Carro	não	sim	não
ALU0910	4971	1	4971.0	sim	Meio período	6	3.6	0	9.9	39	Moto	não	sim	não
ALU0828	2650	6	441.67	sim	Não trabalha	0	13.1	4	6.0	27	Carro	não	sim	não
ALU0116	2085	1	2085.0	sim	Meio período	6	5.4	0	3.4	15	Ônibus	não	sim	não
ALU0834	3446	4	861.5	sim	Meio período	6	9.5	0	6.7	36	Ônibus	não	sim	não
ALU0918	1744	5	348.8	sim	Meio período	6	7.4	0	1.4	7	Aplicativo	não	sim	não
ALU0343	3583	5	716.6	sim	Não trabalha	0	15.3	0	10.0	58	Moto	não	sim	não
ALU0363	2393	3	797.67	sim	Tempo integral	8	16.5	0	16.2	79	Bicicleta	não	sim	não
ALU0369	6316	5	1263.2	sim	Tempo integral	8	5.0	16	8.2	33	Ônibus	não	sim	não
ALU0335	3634	1	3634.0	sim	Não trabalha	0	8.1	0	6.4	28	Carro	não	sim	não
ALU0915	3198	4	799.5	sim	Meio período	6	14.0	0	3.7	19	Aplicativo	não	sim	não
ALU0439	2810	2	1405.0	sim	Não trabalha	0	13.7	0	2.3	12	Ônibus	não	sim	não
ALU0230	3815	4	953.75	sim	Tempo integral	8	6.5	0	11.2	49	Ônibus	não	sim	não
ALU0534	1630	4	407.5	sim	Não trabalha	0	9.2	20	4.3	19	Ônibus	não	sim	não
ALU0698	5990	3	1996.67	sim	Não trabalha	0	13.7	0	14.2	79	Carro	não	sim	não
ALU0160	6170	2	3085.0	sim	Não trabalha	0	6.8	16	1.6	6	Carro	não	sim	não
ALU0249	1076	5	215.2	sim	Não trabalha	0	12.6	0	5.5	23	Ônibus	não	sim	não
ALU0563	1764	1	1764.0	sim	Não trabalha	0	14.5	8	8.4	39	Aplicativo	não	sim	não
ALU0149	3703	1	3703.0	sim	Não trabalha	0	9.0	16	9.8	49	Carro	não	sim	não
ALU0311	2158	3	719.33	sim	Não trabalha	0	10.5	0	12.7	63	Aplicativo	não	sim	não
ALU0281	1887	6	314.5	sim	Não trabalha	0	8.8	0	18.0	81	Ônibus	não	sim	não
ALU0486	5788	1	5788.0	sim	Não trabalha	0	8.5	0	4.1	19	Ônibus	não	sim	não
ALU0356	3402	6	567.0	sim	Não trabalha	0	13.0	4	7.0	32	Aplicativo	não	sim	não
ALU0776	2521	4	630.25	sim	Não trabalha	0	9.7	12	12.2	66	Ônibus	não	sim	não
ALU0112	5792	1	5792.0	sim	Não trabalha	0	6.4	12	1.4	8	Carro	não	sim	não
ALU0743	1396	1	1396.0	sim	Meio período	6	5.9	0	41.2	176	Carro	não	sim	não
ALU0514	1416	1	1416.0	sim	Meio período	6	10.9	16	3.7	20	Ônibus	não	sim	não
ALU0868	2365	2	1182.5	sim	Meio período	6	10.5	8	2.3	9	Carro	não	sim	não
ALU0800	2362	3	787.33	sim	Tempo integral	8	10.0	8	5.3	31	Ônibus	não	sim	não
ALU0446	5071	4	1267.75	sim	Tempo integral	8	9.2	4	5.9	25	Ônibus	não	sim	não
ALU0274	1784	3	594.67	sim	Meio período	6	6.4	0	11.5	66	Ônibus	não	sim	não
ALU0662	4404	5	880.8	sim	Não trabalha	0	16.8	8	12.8	53	Carro	não	sim	não
ALU0793	8308	2	4154.0	sim	Meio período	6	10.8	12	4.7	22	Aplicativo	não	sim	não
ALU0257	5012	4	1253.0	sim	Meio período	6	6.2	8	13.6	67	Ônibus	não	sim	não
ALU0860	5826	6	971.0	sim	Não trabalha	0	13.9	0	10.4	58	Ônibus	não	sim	não
ALU0537	4313	4	1078.25	sim	Meio período	6	2.9	16	8.7	44	Ônibus	não	sim	não
ALU0038	6009	4	1502.25	sim	Tempo integral	8	4.2	0	15.3	90	Carro	não	sim	não
ALU0065	2043	6	340.5	sim	Não trabalha	0	15.8	0	19.5	91	Ônibus	não	sim	não
ALU0989	2791	5	558.2	sim	Não trabalha	0	16.1	4	2.3	12	Bicicleta	não	sim	não
ALU0082	4787	3	1595.67	sim	Não trabalha	0	10.5	0	6.6	37	Ônibus	não	sim	não
ALU0628	2391	6	398.5	sim	Tempo integral	8	11.0	8	2.2	12	Ônibus	não	sim	não
ALU0863	3155	3	1051.67	sim	Tempo integral	8	6.6	12	10.4	54	Moto	não	sim	não
ALU0558	5383	2	2691.5	sim	Tempo integral	8	8.2	4	6.4	38	Ônibus	não	não	sim
ALU0259	2589	1	2589.0	sim	Não trabalha	0	16.3	0	16.2	89	Ônibus	não	não	sim
ALU0078	3857	4	964.25	sim	Não trabalha	0	13.7	0	8.2	39	Ônibus	não	não	sim
ALU0911	6342	4	1585.5	sim	Não trabalha	0	6.5	0	6.6	31	Carro	não	não	sim
ALU0755	1965	5	393.0	sim	Não trabalha	0	14.2	0	4.6	19	Ônibus	não	não	sim
ALU0946	6007	6	1001.17	sim	Tempo integral	8	3.4	0	4.2	21	A pé	não	não	sim
ALU0024	5040	1	5040.0	sim	Não trabalha	0	6.5	4	12.3	73	Aplicativo	não	não	sim
ALU0924	4358	1	4358.0	sim	Tempo integral	8	8.5	12	6.7	38	Moto	não	não	sim
ALU0958	1959	2	979.5	sim	Meio período	6	8.0	12	3.1	15	Carro	não	não	sim
ALU0567	2760	1	2760.0	sim	Meio período	6	10.5	0	3.4	14	Ônibus	não	não	sim
ALU0067	3344	4	836.0	sim	Meio período	6	4.1	12	25.8	145	Ônibus	não	não	sim
ALU0492	4397	4	1099.25	sim	Meio período	6	10.9	4	12.5	65	Ônibus	não	não	sim
ALU0752	4357	3	1452.33	sim	Meio período	6	10.9	0	19.2	77	Ônibus	não	não	sim
ALU0663	3042	1	3042.0	sim	Não trabalha	0	8.6	0	13.3	63	Ônibus	não	não	sim
ALU0550	2610	6	435.0	sim	Não trabalha	0	9.4	8	6.4	26	Bicicleta	não	não	sim
ALU0170	800	4	200.0	sim	Tempo integral	8	9.4	12	55.0	180	Carro	não	não	sim
ALU0429	2912	3	970.67	sim	Meio período	6	8.6	0	15.1	62	Carro	não	não	sim
ALU0732	1907	1	1907.0	sim	Meio período	6	10.7	0	1.9	9	Ônibus	não	não	sim
ALU0211	4490	2	2245.0	sim	Meio período	6	12.1	12	14.7	72	Ônibus	não	não	sim
ALU0870	3463	6	577.17	sim	Não trabalha	0	9.7	20	11.8	67	Carro	não	não	sim
ALU0546	5105	4	1276.25	sim	Não trabalha	0	11.8	12	10.7	57	Aplicativo	não	não	sim
ALU0204	3469	5	693.8	sim	Meio período	6	12.0	12	7.7	45	Moto	não	não	sim
ALU0998	2146	1	2146.0	sim	Meio período	6	10.9	0	20.0	100	Ônibus	não	não	sim
ALU0413	5040	2	2520.0	sim	Não trabalha	0	13.5	0	5.2	27	Aplicativo	não	não	sim
ALU0448	2258	3	752.67	sim	Não trabalha	0	14.9	0	1.2	7	Moto	não	não	sim
ALU0385	4184	1	4184.0	sim	Não trabalha	0	10.8	0	2.4	9	Moto	não	não	sim
ALU0841	2878	5	575.6	sim	Meio período	6	3.5	8	2.9	12	Ônibus	não	não	sim
ALU0055	5167	4	1291.75	sim	Não trabalha	0	15.0	0	4.6	22	Ônibus	não	não	sim
ALU0178	4614	6	769.0	sim	Não trabalha	0	6.4	20	5.5	27	Ônibus	não	não	sim
ALU0999	3631	4	907.75	sim	Meio período	6	7.7	16	4.7	21	Ônibus	não	não	sim
ALU0073	6078	3	2026.0	sim	Não trabalha	0	12.6	0	28.6	145	Carro	não	não	sim
ALU0872	2924	5	584.8	sim	Não trabalha	0	11.6	8	20.7	105	A pé	não	não	sim
ALU0601	1805	3	601.67	sim	Meio período	6	9.3	12	2.1	8	Ônibus	não	não	sim
ALU0265	3341	1	3341.0	sim	Tempo integral	8	8.5	4	3.9	22	Ônibus	não	não	sim
ALU0280	4754	4	1188.5	sim	Não trabalha	0	12.1	0	6.2	31	A pé	não	não	sim
ALU0495	2474	2	1237.0	sim	Meio período	6	9.6	16	4.0	23	Ônibus	não	não	sim
ALU0585	1812	1	1812.0	sim	Meio período	6	3.6	0	9.8	41	Bicicleta	não	não	sim
ALU0342	4157	4	1039.25	sim	Meio período	6	12.9	12	13.3	58	Aplicativo	não	não	sim
ALU0686	2197	6	366.17	sim	Não trabalha	0	9.5	0	21.6	111	Moto	não	não	sim
ALU0519	4873	5	974.6	sim	Não trabalha	0	11.7	0	14.1	72	Ônibus	não	não	sim
ALU0581	2979	6	496.5	sim	Tempo integral	8	7.8	0	4.7	21	Ônibus	não	não	sim
ALU0023	4057	5	811.4	sim	Não trabalha	0	9.6	0	6.6	35	Carro	não	não	sim
ALU0421	1161	3	387.0	sim	Tempo integral	8	12.8	0	6.3	28	Ônibus	não	não	sim
ALU0096	4930	4	1232.5	sim	Meio período	6	7.2	16	9.3	50	Ônibus	não	não	sim
ALU0777	1289	4	322.25	sim	Não trabalha	0	10.4	0	7.7	35	Bicicleta	não	não	sim
ALU0568	3287	5	657.4	sim	Meio período	6	4.7	0	30.2	136	Ônibus	não	não	sim
ALU0206	6259	1	6259.0	sim	Não trabalha	0	12.2	4	14.2	68	Ônibus	não	não	sim
ALU0555	2296	1	2296.0	sim	Meio período	6	8.3	4	5.0	24	Ônibus	não	não	sim
ALU0473	3053	2	1526.5	sim	Não trabalha	0	10.1	8	6.5	32	Carro	não	não	sim
ALU0114	3925	2	1962.5	sim	Não trabalha	0	14.2	8	6.6	37	Aplicativo	não	não	sim
ALU0406	997	3	332.33	sim	Meio período	6	10.9	12	8.7	39	Ônibus	não	não	sim
ALU0939	3496	3	1165.33	sim	Não trabalha	0	15.0	12	10.2	47	Bicicleta	não	não	sim
ALU0813	2040	5	408.0	sim	Meio período	6	9.5	16	32.7	155	Moto	não	não	sim
ALU0080	3195	1	3195.0	sim	Não trabalha	0	10.0	12	5.6	32	Moto	não	não	sim
ALU0648	2949	3	983.0	sim	Meio período	6	9.6	0	6.1	33	Ônibus	não	não	sim
ALU0524	1923	3	641.0	sim	Não trabalha	0	2.8	12	15.8	75	Ônibus	não	não	sim
ALU0600	2338	3	779.33	sim	Meio período	6	5.3	4	10.5	43	A pé	não	não	sim
ALU0328	3110	4	777.5	sim	Tempo integral	8	10.7	0	10.0	47	Ônibus	não	não	sim
ALU0375	4244	6	707.33	sim	Não trabalha	0	8.3	0	7.3	32	Carro	não	não	sim
ALU0438	5345	1	5345.0	sim	Tempo integral	8	9.4	0	13.1	52	Carro	não	não	sim
ALU0424	3763	1	3763.0	sim	Não trabalha	0	8.2	0	6.8	27	Ônibus	não	não	sim
ALU0270	3432	4	858.0	sim	Tempo integral	8	7.8	0	6.6	35	Carro	não	não	sim
ALU0817	1795	6	299.17	sim	Não trabalha	0	11.8	12	5.5	30	Ônibus	não	não	sim
ALU0361	1135	5	227.0	sim	Meio período	6	7.6	8	30.5	129	Ônibus	não	não	sim
ALU0790	3292	3	1097.33	sim	Tempo integral	8	8.0	0	5.2	29	Bicicleta	não	não	sim
ALU0899	2273	5	454.6	sim	Não trabalha	0	5.5	0	9.0	47	Moto	não	não	sim
ALU0897	3736	6	622.67	sim	Não trabalha	0	14.5	4	55.0	180	Ônibus	não	não	sim
ALU0461	2624	5	524.8	sim	Tempo integral	8	9.6	0	10.1	55	Carro	não	não	sim
ALU0583	6013	2	3006.5	sim	Meio período	6	7.1	0	1.3	7	Ônibus	não	não	sim
ALU0653	3124	2	1562.0	sim	Não trabalha	0	6.8	4	5.3	26	Ônibus	não	não	sim
ALU0928	2805	1	2805.0	sim	Tempo integral	8	11.7	0	2.0	11	Carro	não	não	sim
ALU0757	3587	6	597.83	sim	Meio período	6	11.0	8	5.3	23	A pé	não	não	sim
ALU0107	4621	4	1155.25	sim	Tempo integral	8	11.2	4	7.9	43	Moto	não	não	sim
ALU0089	3021	2	1510.5	sim	Não trabalha	0	12.4	8	10.1	44	Moto	não	não	sim
ALU0118	1893	6	315.5	sim	Meio período	6	7.8	12	21.9	94	Carro	não	não	sim
ALU0510	3309	1	3309.0	sim	Não trabalha	0	10.6	4	2.4	11	Carro	não	não	sim
ALU0645	3533	1	3533.0	sim	Não trabalha	0	11.1	0	2.0	10	Ônibus	não	não	sim
ALU0390	2608	2	1304.0	sim	Meio período	6	10.6	0	24.4	137	Ônibus	não	não	sim
ALU0209	1780	4	445.0	sim	Não trabalha	0	14.1	0	7.8	46	Moto	não	não	sim
ALU0575	4071	6	678.5	sim	Não trabalha	0	12.2	0	3.0	17	A pé	não	não	sim
ALU0232	1568	4	392.0	sim	Tempo integral	8	13.9	8	7.3	41	Carro	não	não	sim
ALU0997	2920	3	973.33	sim	Meio período	6	7.3	8	6.0	29	Carro	não	não	sim
ALU0254	1198	6	199.67	sim	Não trabalha	0	12.1	8	9.8	46	Ônibus	não	não	sim
ALU0599	2533	3	844.33	sim	Não trabalha	0	5.3	0	13.3	79	Carro	não	não	sim
ALU0260	6320	2	3160.0	sim	Não trabalha	0	10.9	8	5.9	30	Moto	não	não	sim
ALU0789	1879	1	1879.0	sim	Tempo integral	8	5.7	0	8.9	36	Ônibus	não	não	sim
ALU0296	4668	1	4668.0	sim	Não trabalha	0	9.9	16	24.7	132	Ônibus	não	não	sim
ALU0240	1085	2	542.5	sim	Tempo integral	8	7.1	0	3.0	16	Moto	não	não	sim
ALU0681	3130	2	1565.0	sim	Tempo integral	8	4.7	4	3.0	13	Ônibus	não	não	sim
ALU0761	1448	4	362.0	sim	Meio período	6	10.6	0	5.2	27	Ônibus	não	não	sim
ALU0440	4624	1	4624.0	sim	Meio período	6	3.3	0	14.3	67	Ônibus	não	não	sim
ALU0620	2833	5	566.6	sim	Tempo integral	8	3.9	20	19.5	98	Moto	não	não	sim
ALU0788	2568	5	513.6	sim	Meio período	6	13.7	12	33.1	180	Ônibus	não	não	sim
ALU0465	3196	1	3196.0	sim	Não trabalha	0	11.2	12	16.0	81	Bicicleta	não	não	sim
ALU0586	2883	1	2883.0	sim	Não trabalha	0	11.0	8	16.2	88	Ônibus	não	não	sim
ALU0664	2510	4	627.5	sim	Não trabalha	0	12.7	8	12.5	61	Ônibus	não	não	sim
ALU0506	2615	5	523.0	sim	Não trabalha	0	9.7	20	17.2	100	Moto	não	não	sim
ALU0012	1911	5	382.2	sim	Tempo integral	8	3.3	8	16.6	88	Ônibus	não	não	sim
ALU0346	2783	2	1391.5	sim	Tempo integral	8	11.4	0	21.9	112	Carro	não	não	sim
ALU0574	1755	4	438.75	sim	Não trabalha	0	12.3	12	7.9	41	Ônibus	não	não	sim
ALU0384	2269	3	756.33	não	Meio período	6	11.0	4	6.0	24	Ônibus	não	não	não
ALU0961	3421	3	1140.33	não	Meio período	6	12.6	4	3.1	13	Carro	não	não	não
ALU0054	4110	2	2055.0	não	Meio período	6	8.9	4	33.7	175	Carro	não	não	não
ALU0674	2515	2	1257.5	não	Tempo integral	8	8.1	4	2.8	14	Moto	não	não	não
ALU0148	2275	3	758.33	não	Não trabalha	0	8.1	0	20.9	104	Ônibus	não	não	não
ALU0695	4519	2	2259.5	não	Tempo integral	8	5.2	0	5.7	23	Ônibus	não	não	não
ALU0282	824	1	824.0	não	Não trabalha	0	14.5	4	21.7	120	Ônibus	não	não	não
ALU0166	4656	2	2328.0	não	Tempo integral	8	3.2	0	21.5	116	Carro	não	não	não
ALU0221	3428	1	3428.0	não	Não trabalha	0	11.6	8	5.2	26	Ônibus	não	não	não
ALU0665	1793	6	298.83	não	Meio período	6	12.1	4	9.4	38	Ônibus	não	não	não
ALU0030	6387	5	1277.4	não	Tempo integral	8	5.3	4	8.0	36	Ônibus	não	não	não
ALU0837	1895	6	315.83	não	Meio período	6	15.7	0	3.5	20	Bicicleta	não	não	não
ALU0744	3301	2	1650.5	não	Tempo integral	8	10.5	0	6.2	26	Aplicativo	não	não	não
ALU0503	4409	6	734.83	não	Tempo integral	8	2.0	8	20.4	96	Aplicativo	não	não	não
ALU0009	3458	6	576.33	não	Não trabalha	0	13.4	12	11.8	64	Ônibus	não	não	não
ALU0671	2546	2	1273.0	não	Não trabalha	0	14.4	12	13.4	71	Moto	não	não	não
ALU0124	2261	6	376.83	não	Não trabalha	0	13.5	0	3.2	17	Bicicleta	não	não	não
ALU0592	4520	4	1130.0	não	Meio período	6	9.8	8	5.7	29	Aplicativo	não	não	não
ALU0862	5639	6	939.83	não	Tempo integral	8	8.0	16	10.5	44	Carro	não	não	não
ALU0420	2561	5	512.2	não	Não trabalha	0	5.4	8	15.7	67	Ônibus	não	não	não
ALU0953	4060	2	2030.0	não	Meio período	6	11.1	0	6.1	28	A pé	não	não	não
ALU0566	4963	5	992.6	não	Tempo integral	8	9.3	0	8.1	47	Ônibus	não	não	não
ALU0127	8921	2	4460.5	não	Não trabalha	0	10.5	20	5.2	21	Ônibus	não	não	não
ALU0224	4454	3	1484.67	não	Não trabalha	0	12.1	4	4.4	25	A pé	não	não	não
ALU0458	5936	5	1187.2	não	Meio período	6	12.6	0	4.4	26	Ônibus	não	não	não
ALU0739	4290	4	1072.5	não	Não trabalha	0	13.1	8	20.0	116	Moto	não	não	não
ALU0937	5004	3	1668.0	não	Não trabalha	0	8.9	0	12.2	51	Bicicleta	não	não	não
ALU0738	3726	6	621.0	não	Tempo integral	8	5.3	0	28.8	121	Aplicativo	não	não	não
ALU0437	6361	6	1060.17	não	Meio período	6	10.1	12	12.6	66	Bicicleta	não	não	não
ALU0434	2809	6	468.17	não	Meio período	6	13.1	4	8.6	41	Moto	não	não	não
ALU0842	3276	6	546.0	não	Tempo integral	8	2.0	0	3.3	16	Aplicativo	não	não	não
ALU0108	4838	3	1612.67	não	Meio período	6	6.4	12	4.3	23	Carro	não	não	não
ALU0561	2548	1	2548.0	não	Meio período	6	8.5	0	6.6	26	Carro	não	não	não
ALU0016	4417	2	2208.5	não	Não trabalha	0	12.2	12	9.4	41	Ônibus	não	não	não
ALU0864	3385	5	677.0	não	Não trabalha	0	14.8	0	4.7	20	Ônibus	não	não	não
ALU0042	2051	1	2051.0	não	Não trabalha	0	12.0	0	4.8	22	Ônibus	não	não	não
ALU0200	3551	2	1775.5	não	Meio período	6	8.5	0	7.0	29	Bicicleta	não	não	não
ALU0943	3313	4	828.25	não	Não trabalha	0	10.1	0	2.0	9	Ônibus	não	não	não
ALU0857	1838	5	367.6	não	Não trabalha	0	9.1	8	10.1	56	A pé	não	não	não
ALU0549	1878	4	469.5	não	Meio período	6	10.8	12	14.0	71	Carro	não	não	não
ALU0710	1910	5	382.0	não	Tempo integral	8	8.8	12	7.9	46	Ônibus	não	não	não
ALU0217	1782	4	445.5	não	Não trabalha	0	12.5	12	14.3	66	Moto	não	não	não
ALU0156	5811	3	1937.0	não	Não trabalha	0	12.5	0	7.9	40	Ônibus	não	não	não
ALU0147	2800	6	466.67	não	Tempo integral	8	13.8	8	7.4	42	A pé	não	não	não
ALU0136	1381	5	276.2	não	Meio período	6	9.1	0	7.0	41	Moto	não	não	não
ALU0767	2766	2	1383.0	não	Tempo integral	8	10.2	16	8.6	45	Ônibus	não	não	não
ALU0981	1497	3	499.0	não	Não trabalha	0	13.5	8	16.1	91	Aplicativo	não	não	não
ALU0786	1582	1	1582.0	não	Não trabalha	0	8.2	8	7.4	30	Moto	não	não	não
ALU0892	3994	3	1331.33	não	Tempo integral	8	5.5	4	5.7	24	Carro	não	não	não
ALU0647	11936	4	2984.0	não	Meio período	6	11.7	16	7.4	32	A pé	não	não	não
ALU0515	4177	5	835.4	não	Não trabalha	0	8.9	0	3.7	18	Carro	não	não	não
ALU0351	2333	6	388.83	não	Meio período	6	12.9	8	2.2	10	Ônibus	não	não	não
ALU0950	1873	3	624.33	não	Não trabalha	0	14.1	8	22.4	92	Ônibus	não	não	não
ALU0883	2728	3	909.33	não	Não trabalha	0	11.6	0	5.0	20	A pé	não	não	não
ALU0891	1887	4	471.75	não	Tempo integral	8	8.0	20	10.2	60	Moto	não	não	não
ALU0146	3536	3	1178.67	não	Tempo integral	8	6.4	0	3.7	16	Moto	não	não	não
ALU0317	6421	4	1605.25	não	Não trabalha	0	10.2	0	3.4	20	Ônibus	não	não	não
ALU0181	5408	3	1802.67	não	Meio período	6	8.7	8	4.1	24	Bicicleta	não	não	não
ALU0379	2679	2	1339.5	não	Meio período	6	12.0	4	3.1	17	Ônibus	não	não	não
ALU0128	4240	4	1060.0	não	Não trabalha	0	17.7	12	8.0	38	Moto	não	não	não
ALU0701	4131	1	4131.0	não	Não trabalha	0	13.6	8	6.5	35	Moto	não	não	não
ALU0416	1782	2	891.0	não	Meio período	6	12.1	4	1.9	9	Ônibus	não	não	não
ALU0364	3625	1	3625.0	não	Meio período	6	18.1	0	15.7	85	A pé	não	não	não
ALU0358	1730	3	576.67	não	Meio período	6	8.2	4	10.5	60	Carro	não	não	não
ALU0174	2932	5	586.4	não	Tempo integral	8	5.7	0	13.3	78	Ônibus	não	não	não
ALU0046	1918	2	959.0	não	Meio período	6	8.4	0	17.6	100	Ônibus	não	não	não
ALU0560	1377	4	344.25	não	Meio período	6	8.8	8	8.2	41	Ônibus	não	não	não
ALU0809	1197	1	1197.0	não	Meio período	6	10.3	4	18.6	105	Ônibus	não	não	não
ALU0022	3116	3	1038.67	não	Não trabalha	0	7.6	0	10.0	42	Ônibus	não	não	não
ALU0975	5124	3	1708.0	não	Tempo integral	8	10.6	4	9.4	38	Moto	não	não	não
ALU0488	2066	4	516.5	não	Tempo integral	8	4.9	4	4.5	26	Aplicativo	não	não	não
ALU0412	1351	4	337.75	não	Tempo integral	8	7.0	12	19.3	97	Ônibus	não	não	não
ALU0213	2618	1	2618.0	não	Não trabalha	0	9.5	12	31.6	151	Ônibus	não	não	não
ALU0733	1835	1	1835.0	não	Tempo integral	8	6.0	16	9.2	42	Bicicleta	não	não	não
ALU0511	1457	2	728.5	não	Tempo integral	8	8.7	8	5.7	28	Ônibus	não	não	não
ALU0097	1169	1	1169.0	não	Não trabalha	0	13.9	12	5.4	25	Carro	não	não	não
ALU0494	8424	1	8424.0	não	Não trabalha	0	10.8	12	3.8	16	Ônibus	não	não	não
ALU0839	1514	3	504.67	não	Meio período	6	4.3	0	5.4	31	Bicicleta	não	não	não
ALU0141	1584	5	316.8	não	Tempo integral	8	10.5	8	19.2	108	Moto	não	não	não
ALU0641	2485	4	621.25	não	Meio período	6	14.4	4	5.9	32	Ônibus	não	não	não
ALU0370	2659	1	2659.0	não	Tempo integral	8	4.1	4	9.7	41	Ônibus	não	não	não
ALU0105	2828	1	2828.0	não	Tempo integral	8	5.6	12	22.2	105	Ônibus	não	não	não
ALU0795	1759	2	879.5	não	Meio período	6	7.5	0	6.2	37	Aplicativo	não	não	não
ALU0184	3731	2	1865.5	não	Meio período	6	10.0	4	5.5	25	Ônibus	não	não	não
ALU0066	5998	6	999.67	não	Não trabalha	0	11.9	12	11.6	64	Ônibus	não	não	não
ALU0723	3338	3	1112.67	não	Não trabalha	0	9.0	12	11.5	64	Ônibus	não	não	não
ALU0244	5162	3	1720.67	não	Meio período	6	8.3	8	4.0	20	Carro	não	não	não
ALU0843	2862	2	1431.0	não	Não trabalha	0	8.5	0	9.5	48	Moto	não	não	não
ALU0090	2864	2	1432.0	não	Tempo integral	8	3.3	0	7.8	46	Bicicleta	não	não	não
ALU0028	1566	4	391.5	não	Não trabalha	0	17.7	8	16.4	93	Ônibus	não	não	não
ALU0186	2005	3	668.33	não	Tempo integral	8	9.7	0	14.7	84	Moto	não	não	não
ALU0750	4945	6	824.17	não	Não trabalha	0	8.0	0	8.9	49	Moto	não	não	não
ALU0163	1331	6	221.83	não	Não trabalha	0	5.9	0	7.2	29	Moto	não	não	não
ALU0714	5586	6	931.0	não	Tempo integral	8	8.0	0	1.0	5	Bicicleta	não	não	não
ALU0091	4460	2	2230.0	não	Tempo integral	8	7.6	20	5.7	29	Ônibus	não	não	não
ALU0320	2448	2	1224.0	não	Tempo integral	8	10.5	0	29.2	159	Aplicativo	não	não	não
ALU0748	2887	3	962.33	não	Tempo integral	8	2.0	0	12.3	53	Ônibus	não	não	não
ALU0782	1539	3	513.0	não	Não trabalha	0	11.2	8	10.2	47	Aplicativo	não	não	não
ALU0467	4115	2	2057.5	não	Tempo integral	8	9.0	16	6.5	32	Moto	não	não	não
ALU0791	3633	4	908.25	não	Meio período	6	11.3	12	5.2	30	Carro	não	não	não
ALU0155	3133	2	1566.5	não	Meio período	6	9.6	0	26.2	130	Carro	não	não	não
ALU0802	4490	2	2245.0	não	Tempo integral	8	4.0	4	31.9	146	Carro	não	não	não
ALU0804	3532	5	706.4	não	Não trabalha	0	14.7	0	14.4	85	Ônibus	não	não	não
ALU0619	3415	3	1138.33	não	Meio período	6	7.7	0	5.3	29	Carro	não	não	não
ALU0013	8661	4	2165.25	não	Meio período	6	11.8	12	4.8	25	Ônibus	não	não	não
ALU0610	4678	2	2339.0	não	Não trabalha	0	7.5	0	9.8	48	Ônibus	não	não	não
ALU0003	3218	1	3218.0	não	Meio período	6	5.1	16	8.7	43	Carro	não	não	não
ALU0193	3564	5	712.8	não	Meio período	6	7.9	16	5.9	33	A pé	não	não	não
ALU0966	2815	3	938.33	não	Não trabalha	0	3.9	8	4.3	19	A pé	não	não	não
ALU0512	6096	1	6096.0	não	Não trabalha	0	10.4	0	3.9	18	Moto	não	não	não
ALU0267	2277	5	455.4	não	Não trabalha	0	12.8	8	2.5	11	Ônibus	não	não	não
ALU0002	3455	4	863.75	não	Tempo integral	8	8.1	0	26.8	159	A pé	não	não	não
ALU0669	2814	1	2814.0	não	Meio período	6	11.5	0	25.4	149	Carro	não	não	não
ALU0321	961	4	240.25	não	Meio período	6	6.4	8	18.5	81	Carro	não	não	não
ALU0858	1744	1	1744.0	não	Tempo integral	8	12.9	16	20.7	103	Moto	não	não	não
ALU0276	6925	5	1385.0	não	Tempo integral	8	6.6	0	8.8	43	Carro	não	não	não
ALU0948	2961	2	1480.5	não	Não trabalha	0	13.4	0	4.9	22	Ônibus	não	não	não
ALU0548	2616	2	1308.0	não	Tempo integral	8	5.7	8	2.9	13	Ônibus	não	não	não
ALU0307	4542	6	757.0	não	Não trabalha	0	10.2	16	3.8	21	Moto	não	não	não
ALU0140	3379	4	844.75	não	Não trabalha	0	13.4	4	7.9	36	Aplicativo	não	não	não
ALU0533	1357	3	452.33	não	Não trabalha	0	14.7	4	17.7	76	Ônibus	não	não	não
ALU0945	2330	1	2330.0	não	Não trabalha	0	13.8	0	12.8	56	Ônibus	não	não	não
ALU0474	1286	3	428.67	não	Meio período	6	10.0	8	9.5	53	Carro	não	não	não
ALU0151	1690	4	422.5	não	Não trabalha	0	11.3	8	4.0	16	Carro	não	não	não
ALU0234	5542	4	1385.5	não	Não trabalha	0	8.8	12	4.7	27	Moto	não	não	não
ALU0041	1428	5	285.6	não	Não trabalha	0	9.3	0	1.7	8	Carro	não	não	não
ALU0887	2351	2	1175.5	não	Tempo integral	8	11.6	4	14.3	71	Ônibus	não	não	não
ALU0241	6908	2	3454.0	não	Tempo integral	8	5.8	0	5.5	26	Carro	não	não	não
ALU0017	3933	1	3933.0	não	Meio período	6	12.4	0	3.9	17	Ônibus	não	não	não
ALU0469	1585	1	1585.0	não	Meio período	6	6.1	0	5.1	28	Bicicleta	não	não	não
ALU0675	2790	5	558.0	não	Não trabalha	0	16.6	4	6.7	37	A pé	não	não	não
ALU0255	4740	4	1185.0	não	Não trabalha	0	13.4	8	38.3	164	Carro	não	não	não
ALU0521	2289	6	381.5	não	Não trabalha	0	7.7	0	23.2	103	A pé	não	não	não
ALU0273	1750	3	583.33	não	Meio período	6	11.1	8	4.5	25	Carro	não	não	não
ALU0129	6777	3	2259.0	não	Tempo integral	8	7.0	0	13.5	78	Carro	não	não	não
ALU0497	3095	2	1547.5	não	Tempo integral	8	8.9	8	3.6	21	Carro	não	não	não
ALU0721	5369	3	1789.67	não	Não trabalha	0	7.7	0	47.4	180	Moto	não	não	não
ALU0063	7920	3	2640.0	não	Tempo integral	8	9.9	0	5.8	25	Bicicleta	não	não	não
ALU0650	6808	5	1361.6	não	Tempo integral	8	6.4	20	6.9	29	Ônibus	não	não	não
ALU0884	2831	6	471.83	não	Meio período	6	6.6	8	9.1	38	Ônibus	não	não	não
ALU0476	3652	2	1826.0	não	Meio período	6	6.9	4	12.2	55	Ônibus	não	não	não
ALU0785	2275	2	1137.5	não	Não trabalha	0	15.1	0	9.9	47	Carro	não	não	não
ALU0969	4267	5	853.4	não	Meio período	6	8.7	8	5.6	27	Ônibus	não	não	não
ALU0794	2163	3	721.0	não	Meio período	6	6.7	8	10.6	54	Bicicleta	não	não	não
ALU0400	2255	4	563.75	não	Meio período	6	4.7	0	5.2	21	Carro	não	não	não
ALU0444	3271	3	1090.33	não	Não trabalha	0	12.2	0	4.0	19	Ônibus	não	não	não
ALU0636	3233	6	538.83	não	Meio período	6	6.7	0	43.4	180	Carro	não	não	não
ALU0853	2399	5	479.8	não	Não trabalha	0	13.0	0	8.0	33	Ônibus	não	não	não
ALU0816	3802	5	760.4	não	Meio período	6	8.4	0	2.1	8	Carro	não	não	não
ALU0826	2089	4	522.25	não	Tempo integral	8	7.8	12	9.7	38	Ônibus	não	não	não
ALU0909	2781	2	1390.5	não	Tempo integral	8	7.3	0	31.4	150	Moto	não	não	não
ALU0341	9253	2	4626.5	não	Não trabalha	0	15.7	8	6.6	31	Bicicleta	não	não	não
ALU0778	5142	3	1714.0	não	Não trabalha	0	8.1	0	29.3	132	Moto	não	não	não
ALU0944	3263	3	1087.67	não	Tempo integral	8	9.7	0	9.5	45	Moto	não	não	não
ALU0616	3065	5	613.0	não	Meio período	6	9.3	8	15.6	74	A pé	não	não	não
ALU0871	2317	1	2317.0	não	Não trabalha	0	7.0	20	3.5	20	Ônibus	não	não	não
ALU0302	2481	2	1240.5	não	Meio período	6	9.8	8	6.6	29	A pé	não	não	não
ALU0876	4637	4	1159.25	não	Não trabalha	0	9.1	0	10.4	47	Carro	não	não	não
ALU0460	1647	4	411.75	não	Tempo integral	8	5.3	0	25.7	125	Ônibus	não	não	não
ALU0315	2638	3	879.33	não	Não trabalha	0	6.8	8	3.9	22	Bicicleta	não	não	não
ALU0459	1686	2	843.0	não	Não trabalha	0	11.3	8	50.2	180	Ônibus	não	não	não
ALU0907	4597	5	919.4	não	Meio período	6	6.2	0	9.2	52	Aplicativo	não	não	não
ALU0113	1538	6	256.33	não	Tempo integral	8	11.2	0	4.5	23	Aplicativo	não	não	não
ALU0111	3658	3	1219.33	não	Não trabalha	0	10.2	0	12.6	66	Ônibus	não	não	não
ALU0191	5122	2	2561.0	não	Meio período	6	9.2	8	16.4	87	Ônibus	não	não	não
ALU0504	4428	4	1107.0	não	Tempo integral	8	9.1	0	6.6	30	Ônibus	não	não	não
ALU0938	6209	4	1552.25	não	Não trabalha	0	14.3	0	15.4	70	Carro	não	não	não
ALU0798	2628	4	657.0	não	Não trabalha	0	5.7	4	12.4	53	Ônibus	não	não	não
ALU0463	2876	5	575.2	não	Não trabalha	0	8.4	20	13.8	78	Ônibus	não	não	não
ALU0624	2774	6	462.33	não	Meio período	6	3.6	4	4.8	24	Ônibus	não	não	não
ALU0122	4857	2	2428.5	não	Tempo integral	8	2.9	0	10.7	57	Carro	não	não	não
ALU0205	5017	3	1672.33	não	Não trabalha	0	10.8	16	7.2	30	Ônibus	não	não	não
ALU0239	6217	3	2072.33	não	Meio período	6	5.3	0	6.2	25	Carro	não	não	não
ALU0920	3344	1	3344.0	não	Não trabalha	0	15.3	20	5.2	20	Carro	não	não	não
ALU0158	3145	2	1572.5	não	Tempo integral	8	2.0	8	11.6	52	Carro	não	não	não
ALU0252	2850	1	2850.0	não	Não trabalha	0	6.9	4	2.4	10	Moto	não	não	não
ALU0345	4366	6	727.67	não	Meio período	6	7.7	4	4.3	17	Ônibus	não	não	não
ALU0490	2924	1	2924.0	não	Não trabalha	0	8.6	4	7.6	35	Ônibus	não	não	não
ALU0787	1811	2	905.5	não	Não trabalha	0	11.4	0	5.0	24	Carro	não	não	não
ALU0283	4740	4	1185.0	não	Meio período	6	12.1	0	1.9	10	Ônibus	não	não	não
ALU0903	4825	2	2412.5	não	Tempo integral	8	10.7	0	27.9	125	Moto	não	não	não
ALU0457	4242	6	707.0	não	Não trabalha	0	12.6	8	4.3	18	Carro	não	não	não
ALU0464	3029	6	504.83	não	Não trabalha	0	15.9	12	12.7	64	Moto	não	não	não
ALU0690	1748	2	874.0	não	Não trabalha	0	13.8	4	12.5	72	Carro	não	não	não
ALU0258	2321	2	1160.5	não	Não trabalha	0	11.1	8	19.9	98	Ônibus	não	não	não
ALU0353	4083	4	1020.75	não	Não trabalha	0	13.7	0	10.2	56	Aplicativo	não	não	não
ALU0287	4006	4	1001.5	não	Meio período	6	10.2	0	32.1	146	Ônibus	não	não	não
ALU0718	3013	3	1004.33	não	Não trabalha	0	8.8	8	4.3	18	Ônibus	não	não	não
ALU0298	3766	4	941.5	não	Não trabalha	0	10.3	0	5.3	29	Moto	não	não	não
ALU0913	2514	5	502.8	não	Tempo integral	8	10.8	4	3.6	19	Moto	não	não	não
ALU0589	2287	6	381.17	não	Meio período	6	9.6	12	4.6	21	Ônibus	não	não	não
ALU0487	2952	3	984.0	não	Meio período	6	5.4	0	2.4	10	Ônibus	não	não	não
ALU0985	3940	1	3940.0	não	Não trabalha	0	6.0	0	5.5	26	Carro	não	não	não
ALU0605	3373	6	562.17	não	Meio período	6	13.7	4	6.8	39	Ônibus	não	não	não
ALU0011	2124	4	531.0	não	Não trabalha	0	9.8	8	11.5	48	Carro	não	não	não
ALU0894	2020	4	505.0	não	Não trabalha	0	10.9	0	5.6	32	Ônibus	não	não	não
ALU0685	3281	6	546.83	não	Não trabalha	0	17.6	0	2.0	10	Bicicleta	não	não	não
ALU0797	3200	3	1066.67	não	Meio período	6	9.6	4	5.3	29	Moto	não	não	não
ALU0735	3289	2	1644.5	não	Não trabalha	0	12.0	0	7.4	30	Ônibus	não	não	não
ALU0157	2735	1	2735.0	não	Não trabalha	0	7.9	8	12.2	68	Ônibus	não	não	não
ALU0926	2416	4	604.0	não	Meio período	6	4.8	12	11.1	62	Moto	não	não	não
ALU0177	4357	5	871.4	não	Meio período	6	11.2	12	19.4	82	Bicicleta	não	não	não
ALU0773	1062	6	177.0	não	Não trabalha	0	9.6	20	15.8	69	A pé	não	não	não
ALU0137	2057	2	1028.5	não	Meio período	6	11.1	0	24.5	118	Moto	não	não	não
ALU0243	3795	2	1897.5	não	Não trabalha	0	11.2	0	7.8	44	Ônibus	não	não	não
ALU0655	1749	5	349.8	não	Meio período	6	3.2	16	2.6	14	Carro	não	não	não
ALU0784	6699	1	6699.0	não	Não trabalha	0	15.5	20	6.4	34	Ônibus	não	não	não
ALU0175	2622	2	1311.0	não	Tempo integral	8	5.1	0	9.7	40	Ônibus	não	não	não
ALU0153	3056	4	764.0	não	Tempo integral	8	4.2	0	7.2	33	Ônibus	não	não	não
ALU0196	6995	3	2331.67	não	Meio período	6	6.2	0	15.2	61	Ônibus	não	não	não
ALU0676	2410	2	1205.0	não	Meio período	6	8.9	4	8.9	45	Ônibus	não	não	não
ALU0365	3226	4	806.5	não	Não trabalha	0	14.2	4	6.7	35	Ônibus	não	não	não
ALU0861	2771	3	923.67	não	Tempo integral	8	7.2	4	42.2	180	Ônibus	não	não	não
ALU0083	2395	6	399.17	não	Meio período	6	12.6	0	5.4	29	Carro	não	não	não
ALU0359	3667	5	733.4	não	Não trabalha	0	12.0	4	7.0	40	Ônibus	não	não	não
ALU0587	1427	1	1427.0	não	Meio período	6	4.4	4	7.0	35	Aplicativo	não	não	não
ALU0921	6679	2	3339.5	não	Meio período	6	8.9	8	17.2	69	Ônibus	não	não	não
ALU0337	2383	3	794.33	não	Tempo integral	8	11.4	8	18.9	76	Ônibus	não	não	não
ALU0607	6902	1	6902.0	não	Não trabalha	0	14.2	16	10.2	49	Carro	não	não	não
ALU0245	2876	1	2876.0	não	Não trabalha	0	11.4	8	5.3	29	Carro	não	não	não
ALU0965	2516	2	1258.0	não	Meio período	6	11.1	12	4.4	18	Carro	não	não	não
ALU0947	3000	4	750.0	não	Não trabalha	0	14.4	8	9.5	49	Bicicleta	não	não	não
ALU0044	2413	6	402.17	não	Não trabalha	0	13.2	12	8.2	37	Ônibus	não	não	não
ALU0626	16127	2	8063.5	não	Tempo integral	8	9.9	12	9.8	51	Carro	não	não	não
ALU0851	4393	2	2196.5	não	Não trabalha	0	6.5	0	22.0	116	Carro	não	não	não
ALU0639	2851	6	475.17	não	Tempo integral	8	5.6	0	2.5	10	Ônibus	não	não	não
ALU0104	5822	5	1164.4	não	Meio período	6	7.2	0	7.7	34	Carro	não	não	não
ALU0931	2379	5	475.8	não	Meio período	6	10.8	0	11.1	58	Carro	não	não	não
ALU0316	3738	2	1869.0	não	Não trabalha	0	9.1	0	6.3	30	A pé	não	não	não
ALU0445	6310	1	6310.0	não	Não trabalha	0	16.9	12	5.5	30	Carro	não	não	não
ALU0658	2000	1	2000.0	não	Tempo integral	8	3.4	20	7.3	36	Carro	não	não	não
ALU0717	3719	2	1859.5	não	Meio período	6	7.9	8	7.7	40	Carro	não	não	não
ALU0271	3906	5	781.2	não	Tempo integral	8	14.6	0	3.6	19	A pé	não	não	não
ALU0766	2253	5	450.6	não	Não trabalha	0	10.5	0	8.1	34	Bicicleta	não	não	não
ALU0428	6001	4	1500.25	não	Não trabalha	0	16.0	12	2.8	14	Carro	não	não	não
ALU0765	3123	6	520.5	não	Não trabalha	0	10.0	4	13.7	70	Ônibus	não	não	não
ALU0579	2533	3	844.33	não	Não trabalha	0	16.0	12	5.6	25	Carro	não	não	não
ALU0289	3046	1	3046.0	não	Tempo integral	8	9.0	4	34.6	166	Moto	não	não	não
ALU0644	1331	4	332.75	não	Não trabalha	0	11.8	8	4.7	22	Ônibus	não	não	não
ALU0505	3538	4	884.5	não	Não trabalha	0	6.3	16	21.7	123	Bicicleta	não	não	não
ALU0916	1107	5	221.4	não	Meio período	6	14.8	16	21.3	107	Aplicativo	não	não	não
ALU0197	3592	1	3592.0	não	Não trabalha	0	16.9	16	7.6	44	Carro	não	não	não
ALU0866	4418	4	1104.5	não	Meio período	6	13.1	0	16.5	95	Ônibus	não	não	não
ALU0106	3010	5	602.0	não	Não trabalha	0	12.7	0	9.6	47	Ônibus	não	não	não
ALU0694	3791	5	758.2	não	Meio período	6	13.4	4	4.7	27	Moto	não	não	não
ALU0779	3639	6	606.5	não	Não trabalha	0	13.2	0	14.5	58	Carro	não	não	não
ALU0632	4222	6	703.67	não	Tempo integral	8	12.0	8	15.2	72	Ônibus	não	não	não
ALU0540	1522	5	304.4	não	Não trabalha	0	11.0	0	11.2	63	Moto	não	não	não
ALU0980	908	4	227.0	não	Tempo integral	8	10.8	0	21.0	114	Ônibus	não	não	não
ALU0199	2496	6	416.0	não	Não trabalha	0	18.4	0	5.9	33	Carro	não	não	não
ALU0542	5972	4	1493.0	não	Meio período	6	7.8	8	18.1	104	Carro	não	não	não
ALU0216	4387	4	1096.75	não	Meio período	6	11.8	4	10.0	42	Ônibus	não	não	não
ALU0015	2203	5	440.6	não	Não trabalha	0	10.0	8	23.7	104	Moto	não	não	não
ALU0886	3629	2	1814.5	não	Tempo integral	8	6.4	20	16.0	77	Ônibus	não	não	não
ALU0253	2619	6	436.5	não	Não trabalha	0	8.4	4	11.8	60	Carro	não	não	não
ALU0135	3757	1	3757.0	não	Tempo integral	8	7.9	0	6.8	32	Carro	não	não	não
ALU0668	3770	3	1256.67	não	Tempo integral	8	9.4	0	4.3	22	Bicicleta	não	não	não
ALU0734	2002	6	333.67	não	Tempo integral	8	12.1	0	5.0	28	Moto	não	não	não
ALU0890	1758	5	351.6	não	Não trabalha	0	11.1	4	5.0	28	Carro	não	não	não
ALU0679	1729	5	345.8	não	Tempo integral	8	8.6	0	3.2	16	Aplicativo	não	não	não
ALU0749	1999	6	333.17	não	Tempo integral	8	10.8	0	12.1	60	Moto	não	não	não
ALU0630	7577	5	1515.4	não	Não trabalha	0	18.2	12	17.0	73	Ônibus	não	não	não
ALU0409	3773	6	628.83	não	Meio período	6	6.2	12	21.8	99	Aplicativo	não	não	não
ALU0623	1287	4	321.75	não	Não trabalha	0	14.6	0	16.4	68	Moto	não	não	não
ALU0529	1799	4	449.75	não	Meio período	6	7.7	0	6.7	29	Ônibus	não	não	não
ALU0905	2216	3	738.67	não	Tempo integral	8	7.6	8	14.5	77	Ônibus	não	não	não
ALU0692	2158	5	431.6	não	Meio período	6	9.3	4	6.0	28	Ônibus	não	não	não
ALU0278	2036	3	678.67	não	Tempo integral	8	6.2	0	10.9	49	Ônibus	não	não	não
ALU0053	8921	2	4460.5	não	Não trabalha	0	8.6	8	19.9	103	Aplicativo	não	não	não
ALU0279	2521	4	630.25	não	Meio período	6	6.9	0	10.7	48	Carro	não	não	não
ALU0006	2047	4	511.75	não	Meio período	6	8.9	0	17.2	69	Ônibus	não	não	não
ALU0025	7382	1	7382.0	não	Meio período	6	12.1	4	18.0	105	Bicicleta	não	não	não
ALU0499	1991	5	398.2	não	Tempo integral	8	10.5	4	5.8	23	Carro	não	não	não
ALU0095	2379	1	2379.0	não	Não trabalha	0	9.9	4	7.9	39	Ônibus	não	não	não
ALU0103	5268	4	1317.0	não	Tempo integral	8	9.6	8	5.9	32	Aplicativo	não	não	não
ALU0045	2119	2	1059.5	não	Não trabalha	0	14.3	0	16.2	70	Ônibus	não	não	não
ALU0602	2455	3	818.33	não	Não trabalha	0	13.9	4	9.9	56	Ônibus	não	não	não
ALU0572	2149	2	1074.5	não	Meio período	6	6.9	12	5.2	25	Bicicleta	não	não	não
ALU0126	3678	1	3678.0	não	Meio período	6	9.8	0	1.2	5	Carro	não	não	não
ALU0451	1506	3	502.0	não	Tempo integral	8	5.2	16	5.7	29	Carro	não	não	não
ALU0470	5869	5	1173.8	não	Meio período	6	8.2	8	22.0	124	Ônibus	não	não	não
ALU0594	2237	3	745.67	não	Não trabalha	0	9.0	12	2.7	11	Ônibus	não	não	não
ALU0660	3727	4	931.75	não	Não trabalha	0	12.1	8	2.0	10	Ônibus	não	não	não
ALU0719	4300	6	716.67	não	Não trabalha	0	6.6	8	20.0	89	Ônibus	não	não	não
ALU0618	3792	2	1896.0	não	Tempo integral	8	3.9	0	14.8	81	Aplicativo	não	não	não
ALU0593	2882	1	2882.0	não	Não trabalha	0	7.4	8	14.6	71	Moto	não	não	não
ALU0070	3230	3	1076.67	não	Meio período	6	4.0	0	10.1	53	Aplicativo	não	não	não
ALU0856	1431	4	357.75	não	Não trabalha	0	8.9	16	27.3	138	Moto	não	não	não
ALU0098	3382	4	845.5	não	Meio período	6	3.7	4	4.2	20	Ônibus	não	não	não
ALU0423	1742	5	348.4	não	Não trabalha	0	17.4	0	2.8	15	Ônibus	não	não	não
ALU0100	3795	4	948.75	não	Tempo integral	8	8.0	0	8.7	44	Aplicativo	não	não	não
ALU0419	4167	3	1389.0	não	Meio período	6	15.2	0	12.3	49	Carro	não	não	não
ALU0453	4303	1	4303.0	não	Não trabalha	0	7.1	0	2.9	12	Aplicativo	não	não	não
ALU0183	2344	1	2344.0	não	Tempo integral	8	2.2	20	25.5	109	Ônibus	não	não	não
ALU0498	2382	6	397.0	não	Meio período	6	13.1	0	5.0	21	Moto	não	não	não
ALU0783	1653	1	1653.0	não	Não trabalha	0	13.1	8	13.2	62	Ônibus	não	não	não
ALU0180	2442	2	1221.0	não	Meio período	6	8.4	8	5.8	24	Ônibus	não	não	não
ALU0227	1979	6	329.83	não	Não trabalha	0	9.9	20	10.8	55	Ônibus	não	não	não
ALU0176	4538	2	2269.0	não	Meio período	6	6.0	8	10.0	45	Moto	não	não	não
ALU0570	4877	2	2438.5	não	Meio período	6	10.9	4	7.8	39	Ônibus	não	não	não
ALU0882	3997	4	999.25	não	Tempo integral	8	9.0	0	19.1	84	Moto	não	não	não
ALU0284	4359	5	871.8	não	Não trabalha	0	6.5	16	21.8	122	Carro	não	não	não
ALU0117	1331	6	221.83	não	Meio período	6	12.0	12	15.5	67	Ônibus	não	não	não
ALU0349	7313	2	3656.5	não	Meio período	6	12.7	20	15.2	67	Ônibus	não	não	não
ALU0173	7717	3	2572.33	não	Não trabalha	0	14.6	0	8.6	42	Ônibus	não	não	não
ALU0323	2649	5	529.8	não	Não trabalha	0	10.7	4	33.6	180	Ônibus	não	não	não
ALU0426	2341	1	2341.0	não	Meio período	6	5.3	0	9.0	52	Ônibus	não	não	não
ALU0352	1590	1	1590.0	não	Meio período	6	7.0	8	3.7	20	Moto	não	não	não
ALU0290	7078	4	1769.5	não	Tempo integral	8	7.6	20	3.3	15	Bicicleta	não	não	não
ALU0222	14196	2	7098.0	não	Não trabalha	0	12.8	0	22.6	102	Carro	não	não	não
ALU0058	6277	1	6277.0	não	Tempo integral	8	4.5	0	4.3	22	Ônibus	não	não	não
ALU0578	2860	2	1430.0	não	Meio período	6	13.4	0	12.2	57	Carro	não	não	não
ALU0214	1940	3	646.67	não	Não trabalha	0	13.2	0	14.3	76	Ônibus	não	não	não
ALU0941	3520	3	1173.33	não	Tempo integral	8	7.4	0	5.9	26	Bicicleta	não	não	não
ALU0869	4548	2	2274.0	não	Não trabalha	0	11.6	0	2.9	12	Bicicleta	não	não	não
ALU0821	2497	5	499.4	não	Não trabalha	0	12.3	12	5.5	30	Carro	não	não	não
ALU0414	4749	5	949.8	não	Meio período	6	2.4	0	5.7	23	Moto	não	não	não
ALU0362	3210	1	3210.0	não	Tempo integral	8	8.1	0	2.6	12	Ônibus	não	não	não
ALU0535	1873	4	468.25	não	Tempo integral	8	7.5	0	9.9	51	Bicicleta	não	não	não
ALU0964	1537	1	1537.0	não	Meio período	6	5.3	0	3.9	20	Moto	não	não	não
ALU0029	7116	2	3558.0	não	Meio período	6	8.2	8	5.5	31	Bicicleta	não	não	não
ALU0332	1774	6	295.67	não	Não trabalha	0	7.0	20	2.0	10	Aplicativo	não	não	não
ALU0491	5183	3	1727.67	não	Não trabalha	0	11.6	4	6.8	39	Ônibus	não	não	não
ALU0659	8401	5	1680.2	não	Meio período	6	8.0	8	3.1	15	Carro	não	não	não
ALU0726	2068	6	344.67	não	Tempo integral	8	6.5	8	9.4	55	Carro	não	não	não
ALU0021	3407	1	3407.0	não	Não trabalha	0	8.7	8	14.2	71	Ônibus	não	não	não
ALU0150	3497	6	582.83	não	Tempo integral	8	13.8	12	13.2	72	Moto	não	não	não
ALU0613	4569	5	913.8	não	Tempo integral	8	7.8	4	12.9	56	Ônibus	não	não	não
ALU0617	2737	6	456.17	não	Não trabalha	0	14.9	0	12.8	70	Carro	não	não	não
ALU0979	1477	3	492.33	não	Tempo integral	8	5.4	4	6.7	32	Ônibus	não	não	não
ALU0520	5321	6	886.83	não	Meio período	6	7.5	8	9.3	50	Carro	não	não	não
ALU0597	3433	6	572.17	não	Meio período	6	11.3	0	9.2	40	Bicicleta	não	não	não
ALU0643	4348	4	1087.0	não	Meio período	6	6.6	12	8.9	38	Ônibus	não	não	não
ALU0275	1862	5	372.4	não	Meio período	6	9.5	4	5.4	29	Bicicleta	não	não	não
ALU0640	3017	2	1508.5	não	Tempo integral	8	4.2	12	7.6	36	Ônibus	não	não	não
ALU0008	9696	6	1616.0	não	Meio período	6	11.7	0	7.3	33	Carro	não	não	não
ALU0242	2125	6	354.17	não	Meio período	6	8.7	0	4.8	21	Carro	não	não	não
ALU0565	2426	5	485.2	não	Não trabalha	0	4.7	0	7.0	41	Ônibus	não	não	não
ALU0064	2941	4	735.25	não	Meio período	6	3.7	8	7.8	46	Moto	não	não	não
ALU0481	3155	4	788.75	não	Tempo integral	8	13.5	8	6.2	35	Aplicativo	não	não	não
ALU0528	2612	5	522.4	não	Não trabalha	0	13.8	12	4.6	24	Moto	não	não	não
ALU0468	2271	1	2271.0	não	Tempo integral	8	6.7	0	7.1	32	Ônibus	não	não	não
ALU0085	2484	1	2484.0	não	Tempo integral	8	5.9	8	13.3	67	A pé	não	não	não
ALU0576	5127	3	1709.0	não	Meio período	6	5.9	16	16.7	97	Ônibus	não	não	não
ALU0740	3821	1	3821.0	não	Tempo integral	8	8.8	0	3.3	17	Ônibus	não	não	não
ALU0172	5366	2	2683.0	não	Não trabalha	0	2.6	0	3.9	17	Carro	não	não	não
ALU0411	4811	3	1603.67	não	Meio período	6	5.6	0	6.6	28	Ônibus	não	não	não
ALU0185	2750	6	458.33	não	Não trabalha	0	13.4	0	16.0	70	Moto	não	não	não
ALU0397	6433	1	6433.0	não	Tempo integral	8	9.4	0	16.3	96	Ônibus	não	não	não
ALU0159	3223	6	537.17	não	Tempo integral	8	8.3	0	8.0	46	Ônibus	não	não	não
ALU0934	4714	1	4714.0	não	Meio período	6	6.0	8	18.5	108	Bicicleta	não	não	não
ALU0756	1868	4	467.0	não	Não trabalha	0	13.4	0	5.9	32	Ônibus	não	não	não
ALU0987	1578	5	315.6	não	Não trabalha	0	11.9	0	13.6	63	Bicicleta	não	não	não
ALU0932	1814	5	362.8	não	Tempo integral	8	5.1	4	6.9	41	Ônibus	não	não	não
ALU0248	1443	1	1443.0	não	Não trabalha	0	10.3	0	11.6	69	Ônibus	não	não	não
ALU0393	1410	1	1410.0	não	Tempo integral	8	4.6	4	7.6	34	Moto	não	não	não
ALU0713	2338	3	779.33	não	Meio período	6	9.7	0	9.0	38	Ônibus	não	não	não
ALU0295	1818	6	303.0	não	Tempo integral	8	13.0	0	10.6	50	Moto	não	não	não
ALU0415	6603	5	1320.6	não	Meio período	6	12.4	20	8.2	49	A pé	não	não	não
ALU0801	1507	5	301.4	não	Tempo integral	8	8.0	8	9.9	44	Moto	não	não	não
ALU0263	2166	2	1083.0	não	Não trabalha	0	11.4	8	23.2	113	Ônibus	não	não	não
ALU0829	4171	2	2085.5	não	Não trabalha	0	7.5	0	9.1	37	Carro	não	não	não
ALU0344	5014	4	1253.5	não	Tempo integral	8	11.9	0	24.2	141	Ônibus	não	não	não
ALU0553	1861	5	372.2	não	Meio período	6	7.1	16	16.3	79	Ônibus	não	não	não
ALU0501	3042	5	608.4	não	Meio período	6	7.1	0	3.4	15	Ônibus	não	não	não
ALU0667	5503	3	1834.33	não	Não trabalha	0	12.9	8	2.6	14	Ônibus	não	não	não
ALU0705	5548	5	1109.6	não	Não trabalha	0	7.7	0	2.9	13	Ônibus	não	não	não
ALU0075	3099	4	774.75	não	Meio período	6	3.9	4	4.7	28	Ônibus	não	não	não
ALU0330	2691	1	2691.0	não	Tempo integral	8	6.9	8	15.3	77	Ônibus	não	não	não
ALU0203	2242	5	448.4	não	Meio período	6	12.9	20	11.6	61	Carro	não	não	não
ALU0475	2057	2	1028.5	não	Meio período	6	7.8	0	2.5	10	Ônibus	não	não	não
ALU0247	3254	4	813.5	não	Não trabalha	0	8.9	8	21.7	98	Ônibus	não	não	não
ALU0182	1310	4	327.5	não	Não trabalha	0	15.0	0	5.8	28	Moto	não	não	não
ALU0666	1387	2	693.5	não	Não trabalha	0	17.3	0	10.7	63	Ônibus	não	não	não
ALU0963	12458	3	4152.67	não	Tempo integral	8	10.7	0	2.7	11	Moto	não	não	não
ALU0895	2253	2	1126.5	não	Não trabalha	0	11.4	0	5.7	26	Ônibus	não	não	não
ALU0208	2821	5	564.2	não	Não trabalha	0	11.4	20	2.6	11	Aplicativo	não	não	não
ALU0010	2389	5	477.8	não	Meio período	6	10.1	0	4.7	25	Ônibus	não	não	não
ALU0994	3668	6	611.33	não	Meio período	6	7.9	0	6.9	29	Carro	não	não	não
ALU0746	3359	1	3359.0	não	Não trabalha	0	2.0	12	7.3	38	Moto	não	não	não
ALU0803	3999	4	999.75	não	Tempo integral	8	11.4	0	3.1	16	Carro	não	não	não
ALU0877	2343	3	781.0	não	Não trabalha	0	15.1	0	3.3	19	Ônibus	não	não	não
ALU0162	3699	3	1233.0	não	Não trabalha	0	16.8	4	5.1	24	Ônibus	não	não	não
ALU0825	4650	1	4650.0	não	Tempo integral	8	8.4	8	8.5	38	Moto	não	não	não
ALU0758	2490	5	498.0	não	Meio período	6	3.8	0	3.5	14	Ônibus	não	não	não
ALU0799	1970	5	394.0	não	Não trabalha	0	12.5	20	16.8	90	Ônibus	não	não	não
ALU0094	1729	4	432.25	não	Não trabalha	0	9.0	8	11.0	46	Bicicleta	não	não	não
ALU0753	2102	4	525.5	não	Não trabalha	0	8.9	0	11.2	62	Ônibus	não	não	não
ALU0762	1486	5	297.2	não	Não trabalha	0	14.8	20	14.1	69	Ônibus	não	não	não
ALU0716	6362	3	2120.67	não	Não trabalha	0	11.9	0	4.6	24	Ônibus	não	não	não
ALU0677	2393	2	1196.5	não	Não trabalha	0	14.0	20	21.0	119	Ônibus	não	não	não
ALU0422	7203	5	1440.6	não	Não trabalha	0	8.9	4	1.4	6	Ônibus	não	não	não
ALU0139	6703	4	1675.75	não	Meio período	6	16.6	16	8.3	33	Bicicleta	não	não	não
ALU0305	1909	6	318.17	não	Tempo integral	8	2.0	20	4.5	20	Carro	não	não	não
ALU0378	4356	4	1089.0	não	Meio período	6	9.1	0	12.5	54	Ônibus	não	não	não
ALU0759	5469	3	1823.0	não	Não trabalha	0	10.8	16	11.0	60	Ônibus	não	não	não
ALU0577	1185	4	296.25	não	Não trabalha	0	11.8	4	2.8	14	A pé	não	não	não
ALU0277	2361	5	472.2	não	Não trabalha	0	10.4	20	15.3	67	Moto	não	não	não
ALU0865	1989	1	1989.0	não	Tempo integral	8	8.6	4	6.9	29	Ônibus	não	não	não
ALU0264	6756	1	6756.0	não	Meio período	6	10.7	12	5.7	23	Ônibus	não	não	não
ALU0339	2226	4	556.5	não	Tempo integral	8	10.7	0	7.8	39	Ônibus	não	não	não
ALU0955	1632	3	544.0	não	Não trabalha	0	18.4	4	17.8	75	Moto	não	não	não
ALU0395	864	2	432.0	não	Meio período	6	9.6	0	5.5	22	Bicicleta	não	não	não
ALU0256	6300	1	6300.0	não	Não trabalha	0	11.9	0	2.8	15	Ônibus	não	não	não
ALU0702	3725	5	745.0	não	Tempo integral	8	9.1	20	4.7	22	Ônibus	não	não	não
ALU0092	2574	6	429.0	não	Não trabalha	0	14.6	4	2.2	11	Ônibus	não	não	não
ALU0318	2940	6	490.0	não	Meio período	6	8.0	0	17.7	90	Carro	não	não	não
ALU0545	4358	2	2179.0	não	Tempo integral	8	9.9	0	6.5	27	Ônibus	não	não	não
ALU0525	2675	5	535.0	não	Não trabalha	0	13.1	4	12.2	57	Carro	não	não	não
ALU0631	5639	3	1879.67	não	Tempo integral	8	4.6	0	16.6	89	Carro	não	não	não
ALU0040	4149	5	829.8	não	Meio período	6	9.3	0	15.6	67	Ônibus	não	não	não
ALU0635	1708	4	427.0	não	Não trabalha	0	12.8	20	19.2	87	Moto	não	não	não
ALU0818	6039	6	1006.5	não	Não trabalha	0	13.5	20	42.3	180	Ônibus	não	não	não
ALU0388	4679	4	1169.75	não	Tempo integral	8	10.8	0	27.2	150	Bicicleta	não	não	não
ALU0792	4330	1	4330.0	não	Não trabalha	0	13.6	8	16.8	100	Moto	não	não	não
ALU0993	2426	6	404.33	não	Não trabalha	0	15.5	8	14.9	71	Carro	não	não	não
ALU0074	2052	2	1026.0	não	Tempo integral	8	10.5	0	5.6	25	Carro	não	não	não
ALU0687	2207	4	551.75	não	Não trabalha	0	11.5	16	33.0	180	Moto	não	não	não
ALU0532	2147	3	715.67	não	Meio período	6	5.0	8	19.6	91	Moto	não	não	não
ALU0541	2994	2	1497.0	não	Não trabalha	0	15.1	0	26.9	109	Moto	não	não	não
ALU0873	3577	2	1788.5	não	Tempo integral	8	13.0	16	2.0	10	Carro	não	não	não
ALU0056	4589	5	917.8	não	Não trabalha	0	15.0	8	21.4	104	Aplicativo	não	não	não
ALU0212	2838	2	1419.0	não	Tempo integral	8	4.2	20	15.7	74	Ônibus	não	não	não
ALU0219	3880	3	1293.33	não	Não trabalha	0	14.8	0	12.5	55	Ônibus	não	não	não
ALU0322	2218	6	369.67	não	Tempo integral	8	5.7	0	4.0	16	Ônibus	não	não	não
ALU0722	3262	3	1087.33	não	Meio período	6	9.9	12	11.9	64	Moto	não	não	não
ALU0573	7116	2	3558.0	não	Não trabalha	0	8.8	16	12.9	70	Ônibus	não	não	não
ALU0554	2869	3	956.33	não	Não trabalha	0	13.1	4	8.0	39	Ônibus	não	não	não
ALU0043	4439	4	1109.75	não	Meio período	6	8.3	4	18.6	89	Ônibus	não	não	não
ALU0603	2746	6	457.67	não	Não trabalha	0	10.6	20	12.5	65	A pé	não	não	não
ALU0327	1651	4	412.75	não	Não trabalha	0	12.0	0	9.3	46	Moto	não	não	não
ALU0707	4543	6	757.17	não	Não trabalha	0	12.7	20	7.1	36	Carro	não	não	não
ALU0564	3586	5	717.2	não	Meio período	6	6.8	8	19.3	102	Moto	não	não	não
ALU0399	2342	1	2342.0	não	Não trabalha	0	12.8	0	5.1	27	Bicicleta	não	não	não
ALU0447	2611	4	652.75	não	Não trabalha	0	9.6	0	6.2	35	Ônibus	não	não	não
ALU0430	3475	3	1158.33	não	Não trabalha	0	9.8	12	6.9	32	A pé	não	não	não
ALU0087	1924	5	384.8	não	Tempo integral	8	11.9	12	15.8	73	Moto	não	não	não
ALU0729	1985	6	330.83	não	Não trabalha	0	9.6	4	1.5	6	Ônibus	não	não	não
ALU0854	2777	6	462.83	não	Não trabalha	0	13.3	0	13.0	74	Carro	não	não	não
ALU0982	1498	1	1498.0	não	Meio período	6	10.9	0	17.1	87	Ônibus	não	não	não
ALU0068	4626	2	2313.0	não	Meio período	6	10.8	0	6.3	26	A pé	não	não	não
ALU0970	1929	4	482.25	não	Não trabalha	0	4.5	20	13.7	66	Aplicativo	não	não	não
ALU0086	3196	1	3196.0	não	Não trabalha	0	3.2	0	12.4	69	Ônibus	não	não	não
ALU0233	3489	4	872.25	não	Tempo integral	8	9.3	16	8.5	39	Carro	não	não	não
ALU0991	5003	1	5003.0	não	Não trabalha	0	10.7	12	4.2	22	Moto	não	não	não
ALU0901	1909	4	477.25	não	Não trabalha	0	10.4	12	4.7	23	Ônibus	não	não	não
ALU0768	4610	6	768.33	não	Não trabalha	0	8.0	4	6.1	30	Ônibus	não	não	não
ALU0830	3174	4	793.5	não	Tempo integral	8	12.6	0	5.4	25	Ônibus	não	não	não
ALU0225	800	6	133.33	não	Não trabalha	0	12.9	8	10.1	44	Moto	não	não	não
ALU0972	9915	4	2478.75	não	Não trabalha	0	15.3	0	19.5	87	Ônibus	não	não	não
ALU0402	3011	3	1003.67	não	Não trabalha	0	11.9	12	10.8	48	Ônibus	não	não	não
ALU0974	4971	6	828.5	não	Meio período	6	9.0	4	7.0	39	Ônibus	não	não	não
ALU0164	2757	6	459.5	não	Não trabalha	0	11.1	16	3.3	19	Carro	não	não	não
ALU0435	1820	2	910.0	não	Tempo integral	8	10.4	0	10.1	41	Aplicativo	não	não	não
ALU0262	3590	3	1196.67	não	Meio período	6	2.1	8	20.4	121	Ônibus	não	não	não
ALU0334	2114	4	528.5	não	Meio período	6	9.6	4	9.3	45	Carro	não	não	não
ALU0381	2141	6	356.83	não	Meio período	6	8.6	8	3.4	15	Carro	não	não	não
ALU0906	4189	3	1396.33	não	Meio período	6	10.5	0	2.1	8	Ônibus	não	não	não
ALU0218	4361	5	872.2	não	Não trabalha	0	14.3	0	14.0	61	Carro	não	não	não
ALU0680	1668	1	1668.0	não	Tempo integral	8	4.8	4	20.7	111	Moto	não	não	não
ALU0374	1976	4	494.0	não	Tempo integral	8	4.1	0	7.6	33	Moto	não	não	não
ALU0354	2514	4	628.5	não	Não trabalha	0	8.7	0	10.3	52	Carro	não	não	não
ALU0807	5248	5	1049.6	não	Tempo integral	8	4.2	8	6.7	34	Ônibus	não	não	não
ALU0462	1360	1	1360.0	não	Meio período	6	10.5	0	19.4	114	Ônibus	não	não	não
ALU0651	2079	6	346.5	não	Tempo integral	8	7.8	0	7.0	28	Ônibus	não	não	não
ALU0609	3925	1	3925.0	não	Não trabalha	0	11.9	8	8.1	37	Carro	não	não	não
ALU0812	6875	4	1718.75	não	Meio período	6	14.5	0	4.4	19	A pé	não	não	não
ALU0967	11876	4	2969.0	não	Tempo integral	8	9.0	8	2.5	11	Ônibus	não	não	não
ALU0621	1683	1	1683.0	não	Não trabalha	0	11.6	0	6.1	29	Moto	não	não	não
ALU0760	3940	4	985.0	não	Não trabalha	0	10.3	0	6.5	28	Ônibus	não	não	não
ALU0983	3170	3	1056.67	não	Tempo integral	8	8.3	0	6.8	33	Ônibus	não	não	não
ALU0037	2149	3	716.33	não	Tempo integral	8	10.0	0	12.1	50	Ônibus	não	não	não
ALU0138	3473	4	868.25	não	Não trabalha	0	13.5	0	11.7	64	Ônibus	não	não	não
ALU0425	6334	6	1055.67	não	Meio período	6	4.5	16	4.3	20	Moto	não	não	não
ALU0357	2466	6	411.0	não	Meio período	6	9.1	12	3.4	18	A pé	não	não	não
ALU0588	2124	6	354.0	não	Meio período	6	10.3	0	13.3	60	Moto	não	não	não
ALU0077	2817	6	469.5	não	Meio período	6	7.8	0	8.5	47	Carro	não	não	não
ALU0478	2191	4	547.75	não	Não trabalha	0	14.5	0	5.8	34	Carro	não	não	não
ALU0509	3298	2	1649.0	não	Não trabalha	0	8.2	8	11.0	57	Ônibus	não	não	não
ALU0035	4791	6	798.5	não	Tempo integral	8	5.5	0	9.3	51	Moto	não	não	não
ALU0285	3725	1	3725.0	não	Não trabalha	0	11.8	0	9.1	54	Moto	não	não	não
ALU0880	2249	4	562.25	não	Tempo integral	8	7.5	0	4.5	26	Carro	não	não	não
ALU0844	4444	4	1111.0	não	Meio período	6	8.3	8	6.3	32	Ônibus	não	não	não
ALU0500	5332	4	1333.0	não	Não trabalha	0	11.3	8	2.5	10	Ônibus	não	não	não
ALU0591	3277	1	3277.0	não	Tempo integral	8	6.6	16	10.6	43	Ônibus	não	não	não
ALU0477	2513	2	1256.5	não	Não trabalha	0	9.8	0	6.2	28	Bicicleta	não	não	não
ALU0728	6284	2	3142.0	não	Não trabalha	0	8.0	0	5.1	25	Ônibus	não	não	não
ALU0508	5287	1	5287.0	não	Meio período	6	6.2	0	23.5	128	Moto	não	não	não
ALU0720	2462	6	410.33	não	Meio período	6	7.7	0	14.6	60	Ônibus	não	não	não
ALU0814	6695	1	6695.0	não	Tempo integral	8	6.7	0	16.3	88	Moto	não	não	não
ALU0145	6499	5	1299.8	não	Meio período	6	7.7	4	12.7	72	Ônibus	não	não	não
ALU0949	1154	6	192.33	não	Meio período	6	8.1	0	29.8	138	Carro	não	não	não
ALU0493	1803	5	360.6	não	Não trabalha	0	11.7	4	12.9	52	Ônibus	não	não	não
ALU0838	3615	4	903.75	não	Meio período	6	11.3	8	2.4	10	Carro	não	não	não
ALU0340	2097	1	2097.0	não	Tempo integral	8	12.3	0	29.4	144	Carro	não	não	não
ALU0036	2837	6	472.83	não	Meio período	6	10.3	20	6.8	38	Ônibus	não	não	não
ALU0401	5494	6	915.67	não	Não trabalha	0	12.0	20	5.7	31	Ônibus	não	não	não
ALU0161	6246	5	1249.2	não	Meio período	6	6.2	0	13.5	76	Carro	não	não	não
ALU0595	4154	2	2077.0	não	Meio período	6	7.5	0	7.4	39	Ônibus	não	não	não
ALU0771	1855	6	309.17	não	Não trabalha	0	9.2	0	11.5	64	Ônibus	não	não	não
ALU0688	3182	1	3182.0	não	Meio período	6	12.7	0	3.9	22	Carro	não	não	não
ALU0657	4146	2	2073.0	não	Não trabalha	0	9.4	0	4.4	20	Moto	não	não	não
ALU0971	2349	6	391.5	não	Não trabalha	0	7.7	8	9.6	41	Carro	não	não	não
ALU0308	2737	1	2737.0	não	Não trabalha	0	11.8	0	47.8	180	Ônibus	não	não	não
ALU0210	1995	6	332.5	não	Tempo integral	8	6.3	4	3.3	14	Moto	não	não	não
ALU0661	3775	2	1887.5	não	Não trabalha	0	12.1	0	4.5	19	Ônibus	não	não	não
ALU0772	3020	2	1510.0	não	Não trabalha	0	14.8	4	33.1	176	Ônibus	não	não	não
ALU0543	2448	4	612.0	não	Meio período	6	4.8	0	14.0	81	Aplicativo	não	não	não
ALU0747	2782	6	463.67	não	Meio período	6	7.9	4	9.2	44	Moto	não	não	não
ALU0845	2427	6	404.5	não	Tempo integral	8	7.6	0	3.3	16	Ônibus	não	não	não
ALU0912	5678	3	1892.67	não	Não trabalha	0	19.3	0	8.6	35	Ônibus	não	não	não
ALU0559	2010	6	335.0	não	Não trabalha	0	7.2	0	7.7	39	A pé	não	não	não
ALU0996	800	3	266.67	não	Não trabalha	0	13.8	4	12.7	73	A pé	não	não	não
ALU0394	2496	1	2496.0	não	Não trabalha	0	11.9	0	20.1	91	Moto	não	não	não
ALU0450	4683	4	1170.75	não	Meio período	6	6.9	20	5.6	31	A pé	não	não	não
ALU0893	3887	2	1943.5	não	Tempo integral	8	7.0	4	7.3	32	Ônibus	não	não	não
ALU0709	3273	3	1091.0	não	Não trabalha	0	17.2	4	6.0	26	Carro	não	não	não
ALU0930	2048	6	341.33	não	Não trabalha	0	13.2	12	2.2	10	Ônibus	não	não	não
ALU0962	2792	1	2792.0	não	Tempo integral	8	3.3	0	12.0	69	Carro	não	não	não
ALU0691	3792	4	948.0	não	Não trabalha	0	8.1	0	11.5	63	Carro	não	não	não
ALU0539	3630	1	3630.0	não	Meio período	6	7.9	20	29.0	127	Aplicativo	não	não	não
ALU0050	4453	6	742.17	não	Não trabalha	0	2.3	16	6.0	24	Ônibus	não	não	não
ALU0386	1484	1	1484.0	não	Meio período	6	6.2	16	4.1	21	Ônibus	não	não	não
ALU0049	2876	3	958.67	não	Não trabalha	0	17.0	12	6.3	25	Carro	não	não	não
ALU0433	3878	3	1292.67	não	Não trabalha	0	10.8	12	3.3	19	Carro	não	não	não
ALU0125	2004	6	334.0	não	Tempo integral	8	3.7	8	5.8	33	Bicicleta	não	não	não
ALU0823	3620	1	3620.0	não	Tempo integral	8	9.9	0	37.3	151	Ônibus	não	não	não
ALU0449	1882	5	376.4	não	Não trabalha	0	14.6	0	9.8	43	Ônibus	não	não	não
ALU0885	4371	2	2185.5	não	Não trabalha	0	11.3	0	4.9	27	Carro	não	não	não
ALU0057	2130	5	426.0	não	Meio período	6	2.0	16	17.7	105	Ônibus	não	não	não
ALU0850	4900	2	2450.0	não	Tempo integral	8	11.3	0	14.3	72	Moto	não	não	não
ALU0806	3265	2	1632.5	não	Meio período	6	7.0	4	9.9	40	Aplicativo	não	não	não
ALU0556	2355	1	2355.0	não	Não trabalha	0	18.0	8	4.4	21	Moto	não	não	não
ALU0711	1878	3	626.0	não	Não trabalha	0	13.7	0	10.2	48	Moto	não	não	não
ALU0004	4452	5	890.4	não	Não trabalha	0	8.9	16	2.7	11	Ônibus	não	não	não
ALU0811	1663	6	277.17	não	Não trabalha	0	9.7	8	7.4	29	Ônibus	não	não	não
ALU0220	3177	3	1059.0	não	Tempo integral	8	7.1	12	32.1	145	Aplicativo	não	não	não
ALU0888	1473	5	294.6	não	Não trabalha	0	11.8	20	3.1	13	Moto	não	não	não
ALU0007	5425	3	1808.33	não	Meio período	6	6.1	8	9.6	53	Carro	não	não	não
ALU0781	3732	3	1244.0	não	Meio período	6	11.0	0	10.7	57	Ônibus	não	não	não
ALU0820	2394	4	598.5	não	Meio período	6	10.9	8	4.1	16	Carro	não	não	não
ALU0978	2847	6	474.5	não	Não trabalha	0	4.3	16	9.0	42	Aplicativo	não	não	não
ALU0612	2625	6	437.5	não	Não trabalha	0	13.2	0	11.6	65	Bicicleta	não	não	não
ALU0796	3103	3	1034.33	não	Não trabalha	0	9.2	12	1.0	5	Carro	não	não	não
ALU0387	4006	1	4006.0	não	Tempo integral	8	3.1	8	31.9	153	Moto	não	não	não
ALU0484	3375	2	1687.5	não	Tempo integral	8	5.5	4	10.6	47	Moto	não	não	não
ALU0109	6448	1	6448.0	não	Não trabalha	0	7.8	12	5.3	25	Carro	não	não	não
ALU0427	5530	5	1106.0	não	Tempo integral	8	11.9	20	8.7	40	Ônibus	não	não	não
ALU0896	2917	4	729.25	não	Tempo integral	8	9.6	16	7.8	36	Carro	não	não	não
ALU0551	3323	2	1661.5	não	Tempo integral	8	10.0	0	10.4	45	Ônibus	não	não	não
ALU0288	3064	1	3064.0	não	Tempo integral	8	7.1	12	7.1	37	Ônibus	não	não	não
ALU0986	1522	3	507.33	não	Meio período	6	12.9	16	14.7	62	Moto	não	não	não
ALU0580	1880	6	313.33	não	Não trabalha	0	8.1	16	2.7	15	Ônibus	não	não	não
ALU0389	7446	2	3723.0	não	Não trabalha	0	11.4	0	11.8	69	Ônibus	não	não	não
ALU0763	800	3	266.67	não	Meio período	6	8.7	8	3.5	14	Ônibus	não	não	não
ALU0360	4192	2	2096.0	não	Meio período	6	11.0	12	3.3	18	Moto	não	não	não
ALU0062	1373	3	457.67	não	Meio período	6	10.3	0	14.7	69	Ônibus	não	não	não
ALU0431	1952	5	390.4	não	Meio período	6	13.5	0	4.4	25	Ônibus	não	não	não
ALU0536	3514	3	1171.33	não	Tempo integral	8	11.7	0	20.5	92	Aplicativo	não	não	não
ALU0372	1477	5	295.4	não	Meio período	6	7.8	12	2.8	13	Moto	não	não	não
ALU0646	2254	4	563.5	não	Não trabalha	0	10.6	16	6.1	31	Aplicativo	não	não	não
ALU0516	2677	2	1338.5	não	Meio período	6	12.0	20	4.7	24	Carro	não	não	não
ALU0441	4083	1	4083.0	não	Não trabalha	0	13.0	20	25.2	133	Ônibus	não	não	não
ALU0562	4354	5	870.8	não	Meio período	6	8.0	0	8.6	41	A pé	não	não	não
ALU0942	4862	6	810.33	não	Não trabalha	0	9.5	4	4.7	27	Moto	não	não	não
ALU0300	2291	6	381.83	não	Tempo integral	8	10.7	16	4.3	21	Moto	não	não	não
ALU0380	1614	3	538.0	não	Tempo integral	8	8.7	20	18.8	79	Moto	não	não	não
ALU0143	2372	2	1186.0	não	Meio período	6	11.5	0	8.5	43	Ônibus	não	não	não
ALU0526	2916	2	1458.0	não	Não trabalha	0	13.7	0	7.1	32	Ônibus	não	não	não
ALU0708	3663	3	1221.0	não	Meio período	6	12.9	0	15.8	89	Ônibus	não	não	não
ALU0642	2625	2	1312.5	não	Tempo integral	8	8.3	0	5.6	25	Ônibus	não	não	não
ALU0261	1681	6	280.17	não	Meio período	6	4.6	0	3.3	17	Moto	não	não	não
ALU0436	2516	1	2516.0	não	Não trabalha	0	11.9	4	3.0	12	Carro	não	não	não
ALU0168	1290	6	215.0	não	Não trabalha	0	11.3	4	22.1	104	Bicicleta	não	não	não
ALU0683	5116	1	5116.0	não	Tempo integral	8	7.5	12	3.2	14	Moto	não	não	não
ALU0026	3948	5	789.6	não	Não trabalha	0	12.1	4	8.0	42	Bicicleta	não	não	não
ALU0134	5014	4	1253.5	não	Não trabalha	0	12.5	0	9.7	52	Ônibus	não	não	não
ALU0835	1592	6	265.33	não	Não trabalha	0	10.6	0	19.8	112	Ônibus	não	não	não
ALU0678	2873	2	1436.5	não	Tempo integral	8	10.2	0	10.9	54	Aplicativo	não	não	não
ALU0336	1928	6	321.33	não	Não trabalha	0	12.4	12	9.0	39	Ônibus	não	não	não
ALU0625	2598	5	519.6	não	Não trabalha	0	12.3	8	20.6	87	Ônibus	não	não	não
ALU0313	2118	2	1059.0	não	Não trabalha	0	11.6	8	5.6	32	Moto	não	não	não
ALU0324	1254	1	1254.0	não	Tempo integral	8	5.4	4	5.1	29	Moto	não	não	não
ALU0810	2497	2	1248.5	não	Tempo integral	8	11.8	8	5.5	31	Bicicleta	não	não	não
ALU0775	6385	2	3192.5	não	Meio período	6	10.8	16	3.1	14	Moto	não	não	não
ALU0418	3164	4	791.0	não	Meio período	6	10.1	8	6.9	38	A pé	não	não	não
ALU0780	3688	4	922.0	não	Não trabalha	0	10.4	0	2.6	12	Moto	não	não	não
ALU0110	2678	1	2678.0	não	Não trabalha	0	15.6	16	3.3	13	Carro	não	não	não
ALU0833	2774	3	924.67	não	Meio período	6	11.4	0	20.2	87	Carro	não	não	não
ALU0900	4291	2	2145.5	não	Não trabalha	0	11.3	0	8.4	37	Aplicativo	não	não	não
ALU0455	2392	4	598.0	não	Não trabalha	0	10.6	20	1.3	7	Ônibus	não	não	não
ALU0144	4260	1	4260.0	não	Não trabalha	0	11.0	0	19.7	85	Moto	não	não	não
ALU0081	938	5	187.6	não	Tempo integral	8	2.0	0	3.7	20	A pé	não	não	não
ALU0952	2005	5	401.0	não	Meio período	6	11.7	8	8.3	49	Moto	não	não	não
ALU0990	3492	5	698.4	não	Não trabalha	0	6.9	8	2.9	13	Ônibus	não	não	não
ALU0310	1614	6	269.0	não	Meio período	6	9.6	0	7.6	40	Bicicleta	não	não	não
ALU0764	3918	2	1959.0	não	Não trabalha	0	10.0	0	6.4	28	Bicicleta	não	não	não
ALU0142	1618	1	1618.0	não	Meio período	6	10.8	12	4.1	20	Carro	não	não	não
ALU0350	1436	3	478.67	não	Não trabalha	0	16.9	0	9.6	45	Bicicleta	não	não	não
ALU0697	4310	5	862.0	não	Não trabalha	0	15.9	20	10.6	59	Carro	não	não	não
ALU0377	3007	1	3007.0	não	Meio período	6	10.4	0	24.0	113	Ônibus	não	não	não
ALU0957	4965	1	4965.0	não	Meio período	6	8.4	0	15.1	85	A pé	não	não	não
ALU0992	2996	3	998.67	não	Não trabalha	0	15.0	0	12.9	60	Bicicleta	não	não	não
ALU0731	1752	4	438.0	não	Meio período	6	9.8	12	16.2	77	Ônibus	não	não	não
ALU0297	4139	3	1379.67	não	Não trabalha	0	9.2	8	16.3	96	Ônibus	não	não	não
ALU0031	3011	5	602.2	não	Meio período	6	5.5	4	3.1	14	Ônibus	não	não	não
ALU0410	5154	3	1718.0	não	Não trabalha	0	14.5	20	8.3	46	Moto	não	não	não
ALU0976	2191	2	1095.5	não	Meio período	6	6.7	0	4.3	24	Ônibus	não	não	não
ALU0736	14848	3	4949.33	não	Meio período	6	10.2	0	19.2	103	Carro	não	não	não
ALU0020	5376	3	1792.0	não	Não trabalha	0	7.0	0	12.1	70	Ônibus	não	não	não
ALU0973	3788	1	3788.0	não	Não trabalha	0	12.7	4	6.4	37	Ônibus	não	não	não
ALU0627	4352	1	4352.0	não	Não trabalha	0	8.5	8	5.1	24	Ônibus	não	não	não
ALU0725	2840	2	1420.0	não	Tempo integral	8	8.1	0	6.6	30	Aplicativo	não	não	não
ALU0604	7600	5	1520.0	não	Não trabalha	0	13.4	16	1.6	7	Ônibus	não	não	não
ALU0304	1784	3	594.67	não	Tempo integral	8	13.5	0	5.0	28	Carro	não	não	não
ALU0706	2561	4	640.25	não	Tempo integral	8	8.6	4	5.3	25	A pé	não	não	não
ALU0852	2531	4	632.75	não	Não trabalha	0	14.1	4	14.9	63	Ônibus	não	não	não
ALU0396	1377	1	1377.0	não	Tempo integral	8	12.1	12	10.2	42	Carro	não	não	não
ALU0084	2672	1	2672.0	não	Tempo integral	8	7.1	0	16.3	95	Moto	não	não	não
ALU0614	1140	6	190.0	não	Não trabalha	0	10.5	8	21.9	122	Ônibus	não	não	não
ALU0052	2687	3	895.67	não	Não trabalha	0	12.0	8	6.2	35	Carro	não	não	não
ALU0190	5640	6	940.0	não	Meio período	6	7.0	0	7.7	33	Carro	não	não	não
ALU0405	4414	4	1103.5	não	Não trabalha	0	13.6	4	5.8	25	Bicicleta	não	não	não
ALU0805	2751	4	687.75	não	Meio período	6	11.4	0	11.6	63	Ônibus	não	não	não
ALU0867	2486	2	1243.0	não	Não trabalha	0	9.2	8	7.7	33	A pé	não	não	não
ALU0443	1626	5	325.2	não	Meio período	6	6.4	20	8.2	42	Aplicativo	não	não	não
ALU0908	1867	1	1867.0	não	Tempo integral	8	10.8	4	13.6	70	Bicicleta	não	não	não
ALU0452	3911	4	977.75	não	Tempo integral	8	9.0	0	4.1	23	A pé	não	não	não
ALU0831	9282	4	2320.5	não	Meio período	6	13.8	12	14.1	71	Moto	não	não	não
ALU0047	1093	4	273.25	não	Meio período	6	12.0	4	8.4	46	Ônibus	não	não	não
ALU0670	5094	4	1273.5	não	Não trabalha	0	11.0	4	11.1	64	Ônibus	não	não	não
ALU0061	1679	6	279.83	não	Tempo integral	8	6.4	12	29.6	143	Carro	não	não	não
ALU0319	7107	4	1776.75	não	Não trabalha	0	10.7	8	10.1	47	Aplicativo	não	não	não
ALU0076	3134	4	783.5	não	Tempo integral	8	4.3	0	7.1	38	Ônibus	não	não	não
ALU0822	1900	4	475.0	não	Meio período	6	5.0	0	8.2	48	Ônibus	não	não	não
ALU0051	2640	2	1320.0	não	Meio período	6	9.9	12	3.6	20	Carro	não	não	não
ALU0672	2242	6	373.67	não	Não trabalha	0	12.9	0	6.8	34	Carro	não	não	não
ALU0959	1917	3	639.0	não	Não trabalha	0	12.4	8	4.9	26	Bicicleta	não	não	não
ALU0827	3542	1	3542.0	não	Tempo integral	8	8.2	8	10.0	51	Moto	não	não	não
ALU0391	6739	1	6739.0	não	Meio período	6	8.5	8	4.1	20	Bicicleta	não	não	não
ALU0547	2549	6	424.83	não	Meio período	6	10.4	0	28.4	134	Aplicativo	não	não	não
ALU0306	2471	6	411.83	não	Não trabalha	0	17.8	8	4.5	24	Ônibus	não	não	não
ALU0652	2141	2	1070.5	não	Não trabalha	0	14.2	0	7.2	32	Carro	não	não	não
ALU0348	1535	6	255.83	não	Não trabalha	0	7.1	0	8.0	46	Ônibus	não	não	não
ALU0188	3806	1	3806.0	não	Tempo integral	8	8.3	0	5.8	26	Carro	não	não	não
ALU0923	1534	6	255.67	não	Meio período	6	6.6	0	8.0	46	Moto	não	não	não
ALU0598	2465	6	410.83	não	Meio período	6	9.6	20	1.2	5	Ônibus	não	não	não
ALU0292	2296	6	382.67	não	Não trabalha	0	8.0	12	11.2	45	Ônibus	não	não	não
ALU0754	2875	2	1437.5	não	Meio período	6	10.0	4	9.4	48	Ônibus	não	não	não
ALU0590	5540	1	5540.0	não	Não trabalha	0	9.5	8	16.1	64	Ônibus	não	não	não
ALU0291	2407	6	401.17	não	Meio período	6	4.0	20	8.6	42	Ônibus	não	não	não
ALU0929	5264	3	1754.67	não	Não trabalha	0	5.9	0	6.9	27	Ônibus	não	não	não
ALU0977	5608	4	1402.0	não	Meio período	6	6.1	8	9.0	46	Bicicleta	não	não	não
ALU0689	2560	4	640.0	não	Meio período	6	11.2	0	4.5	22	Moto	não	não	não
ALU0398	3251	3	1083.67	não	Não trabalha	0	15.9	0	35.6	180	Ônibus	não	não	não
ALU0875	2201	1	2201.0	não	Tempo integral	8	16.3	16	1.5	6	Ônibus	não	não	não
ALU0815	4803	3	1601.0	não	Não trabalha	0	10.0	12	6.1	26	Ônibus	não	não	não
ALU0408	2214	2	1107.0	não	Tempo integral	8	7.4	4	15.7	78	Carro	não	não	não
ALU0236	3889	1	3889.0	não	Tempo integral	8	11.4	0	14.0	79	Bicicleta	não	não	não
ALU0246	7211	5	1442.2	não	Não trabalha	0	11.6	0	3.9	19	Moto	não	não	não
ALU0737	3340	2	1670.0	não	Tempo integral	8	5.7	8	3.1	18	Moto	não	não	não
ALU0569	3329	2	1664.5	não	Tempo integral	8	6.9	12	5.6	31	Ônibus	não	não	não
ALU0231	2221	5	444.2	não	Tempo integral	8	3.1	0	3.2	18	Carro	não	não	não
ALU0131	1429	3	476.33	não	Meio período	6	7.4	0	3.7	20	Carro	não	não	não
ALU0727	1438	5	287.6	não	Tempo integral	8	13.1	12	34.4	157	Ônibus	não	não	não
ALU0237	1575	1	1575.0	não	Não trabalha	0	14.3	16	15.8	74	Ônibus	não	não	não
ALU0836	1708	2	854.0	não	Meio período	6	6.4	4	15.7	75	Ônibus	não	não	não
ALU0582	2035	6	339.17	não	Tempo integral	8	10.4	4	11.0	50	Ônibus	não	não	não
ALU0018	4755	3	1585.0	não	Não trabalha	0	5.8	0	16.9	75	Ônibus	não	não	não
ALU0152	5041	3	1680.33	não	Meio período	6	6.6	0	2.8	11	A pé	não	não	não
ALU0633	2176	1	2176.0	não	Não trabalha	0	12.5	0	5.7	24	Moto	não	não	não
ALU0286	1723	5	344.6	não	Meio período	6	7.7	16	13.1	73	A pé	não	não	não
ALU0309	1852	2	926.0	não	Não trabalha	0	12.9	0	6.6	37	Ônibus	não	não	não
ALU0995	3796	6	632.67	não	Meio período	6	6.6	0	5.2	27	Moto	não	não	não
ALU0121	1969	6	328.17	não	Tempo integral	8	2.6	0	2.9	15	Moto	não	não	não
ALU0442	2319	3	773.0	não	Meio período	6	8.1	8	18.0	107	Bicicleta	não	não	não
ALU0207	1264	1	1264.0	não	Não trabalha	0	16.1	8	3.5	14	Ônibus	não	não	não
ALU0195	3618	2	1809.0	não	Meio período	6	7.9	8	9.7	56	Aplicativo	não	não	não
ALU0169	4589	4	1147.25	não	Tempo integral	8	11.2	12	23.5	109	A pé	não	não	não
ALU0914	7591	1	7591.0	não	Meio período	6	6.7	0	4.3	18	Moto	não	não	não
ALU0611	3800	4	950.0	não	Meio período	6	4.2	0	4.5	22	Aplicativo	não	não	não
ALU0629	3279	1	3279.0	não	Não trabalha	0	11.9	8	7.1	38	Bicicleta	não	não	não
ALU0879	2353	3	784.33	não	Meio período	6	9.3	0	11.8	63	Ônibus	não	não	não
ALU0119	4439	6	739.83	não	Não trabalha	0	13.9	16	3.7	16	Ônibus	não	não	não
ALU0432	5487	4	1371.75	não	Meio período	6	11.9	16	26.3	139	Moto	não	não	não
ALU0596	4650	2	2325.0	não	Meio período	6	6.3	20	2.7	11	Ônibus	não	não	não
ALU0517	2063	4	515.75	não	Tempo integral	8	6.5	0	8.1	38	Ônibus	não	não	não
ALU0198	3801	2	1900.5	não	Não trabalha	0	7.0	0	1.6	8	Ônibus	não	não	não
ALU0824	3708	3	1236.0	não	Não trabalha	0	12.9	0	3.9	19	Ônibus	não	não	não
ALU0120	1767	6	294.5	não	Tempo integral	8	6.0	16	2.8	16	Aplicativo	não	não	não
ALU0847	1459	6	243.17	não	Meio período	6	6.3	0	21.3	88	Moto	não	não	não
ALU0272	1746	1	1746.0	não	Meio período	6	7.8	20	4.9	25	Ônibus	não	não	não
ALU0382	2987	2	1493.5	não	Meio período	6	8.5	0	9.5	49	Moto	não	não	não
ALU0102	10459	6	1743.17	não	Meio período	6	10.1	0	6.0	25	Moto	não	não	não
ALU0032	7370	6	1228.33	não	Não trabalha	0	13.0	4	5.6	30	Carro	não	não	não
ALU0368	3628	4	907.0	não	Tempo integral	8	8.3	0	11.0	50	Ônibus	não	não	não
ALU0693	1742	4	435.5	não	Não trabalha	0	14.7	12	3.6	15	Ônibus	não	não	não
ALU0072	6705	3	2235.0	não	Não trabalha	0	11.9	0	6.0	29	Ônibus	não	não	não
ALU0202	6648	1	6648.0	não	Tempo integral	8	13.7	0	10.6	63	Ônibus	não	não	não
ALU0889	2590	4	647.5	não	Não trabalha	0	7.3	8	19.0	80	Ônibus	não	não	não
\.


--
-- TOC entry 4921 (class 0 OID 16679)
-- Dependencies: 219
-- Data for Name: turmas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.turmas (id_turma, id_materia, id_professor, periodo_letivo, turma, turno) FROM stdin;
IA101-A	IA101	PROF001	2026/2	A	Matutino
IA101-B	IA101	PROF002	2026/2	B	Noturno
IA102-A	IA102	PROF003	2026/2	A	Matutino
IA102-B	IA102	PROF004	2026/2	B	Noturno
IA103-A	IA103	PROF005	2026/2	A	Matutino
IA103-B	IA103	PROF006	2026/2	B	Noturno
IA104-A	IA104	PROF009	2026/2	A	Matutino
IA104-B	IA104	PROF010	2026/2	B	Noturno
IA105-A	IA105	PROF007	2026/2	A	Matutino
IA105-B	IA105	PROF008	2026/2	B	Noturno
IA106-A	IA106	PROF021	2026/2	A	Matutino
IA106-B	IA106	PROF022	2026/2	B	Noturno
IA201-A	IA201	PROF001	2026/2	A	Matutino
IA201-B	IA201	PROF002	2026/2	B	Noturno
IA202-A	IA202	PROF005	2026/2	A	Matutino
IA202-B	IA202	PROF006	2026/2	B	Noturno
IA203-A	IA203	PROF007	2026/2	A	Matutino
IA203-B	IA203	PROF008	2026/2	B	Noturno
IA204-A	IA204	PROF003	2026/2	A	Matutino
IA204-B	IA204	PROF004	2026/2	B	Noturno
IA205-A	IA205	PROF005	2026/2	A	Matutino
IA205-B	IA205	PROF006	2026/2	B	Noturno
IA206-A	IA206	PROF017	2026/2	A	Matutino
IA206-B	IA206	PROF018	2026/2	B	Noturno
IA301-A	IA301	PROF013	2026/2	A	Matutino
IA301-B	IA301	PROF014	2026/2	B	Noturno
IA302-A	IA302	PROF001	2026/2	A	Matutino
IA302-B	IA302	PROF002	2026/2	B	Noturno
IA303-A	IA303	PROF007	2026/2	A	Matutino
IA303-B	IA303	PROF008	2026/2	B	Noturno
IA304-A	IA304	PROF019	2026/2	A	Matutino
IA304-B	IA304	PROF020	2026/2	B	Noturno
IA305-A	IA305	PROF003	2026/2	A	Matutino
IA305-B	IA305	PROF004	2026/2	B	Noturno
IA306-A	IA306	PROF015	2026/2	A	Matutino
IA306-B	IA306	PROF016	2026/2	B	Noturno
IA401-A	IA401	PROF011	2026/2	A	Matutino
IA401-B	IA401	PROF012	2026/2	B	Noturno
IA402-A	IA402	PROF013	2026/2	A	Matutino
IA402-B	IA402	PROF014	2026/2	B	Noturno
IA403-A	IA403	PROF001	2026/2	A	Matutino
IA403-B	IA403	PROF002	2026/2	B	Noturno
IA404-A	IA404	PROF017	2026/2	A	Matutino
IA404-B	IA404	PROF018	2026/2	B	Noturno
IA405-A	IA405	PROF005	2026/2	A	Matutino
IA405-B	IA405	PROF006	2026/2	B	Noturno
IA406-A	IA406	PROF015	2026/2	A	Matutino
IA406-B	IA406	PROF016	2026/2	B	Noturno
IA501-A	IA501	PROF009	2026/2	A	Matutino
IA501-B	IA501	PROF010	2026/2	B	Noturno
IA502-A	IA502	PROF011	2026/2	A	Matutino
IA502-B	IA502	PROF012	2026/2	B	Noturno
IA503-A	IA503	PROF009	2026/2	A	Matutino
IA503-B	IA503	PROF010	2026/2	B	Noturno
IA504-A	IA504	PROF013	2026/2	A	Matutino
IA504-B	IA504	PROF014	2026/2	B	Noturno
IA505-A	IA505	PROF019	2026/2	A	Matutino
IA505-B	IA505	PROF020	2026/2	B	Noturno
IA506-A	IA506	PROF023	2026/2	A	Matutino
IA506-B	IA506	PROF024	2026/2	B	Noturno
IA601-A	IA601	PROF011	2026/2	A	Matutino
IA601-B	IA601	PROF012	2026/2	B	Noturno
IA602-A	IA602	PROF009	2026/2	A	Matutino
IA602-B	IA602	PROF010	2026/2	B	Noturno
IA603-A	IA603	PROF015	2026/2	A	Matutino
IA603-B	IA603	PROF016	2026/2	B	Noturno
IA604-A	IA604	PROF011	2026/2	A	Matutino
IA604-B	IA604	PROF012	2026/2	B	Noturno
IA605-A	IA605	PROF009	2026/2	A	Matutino
IA605-B	IA605	PROF010	2026/2	B	Noturno
IA606-A	IA606	PROF013	2026/2	A	Matutino
IA606-B	IA606	PROF014	2026/2	B	Noturno
IA701-A	IA701	PROF011	2026/2	A	Matutino
IA701-B	IA701	PROF012	2026/2	B	Noturno
IA702-A	IA702	PROF017	2026/2	A	Matutino
IA702-B	IA702	PROF018	2026/2	B	Noturno
IA703-A	IA703	PROF009	2026/2	A	Matutino
IA703-B	IA703	PROF010	2026/2	B	Noturno
IA704-A	IA704	PROF021	2026/2	A	Matutino
IA704-B	IA704	PROF022	2026/2	B	Noturno
IA705-A	IA705	PROF019	2026/2	A	Matutino
IA705-B	IA705	PROF020	2026/2	B	Noturno
IA706-A	IA706	PROF023	2026/2	A	Matutino
IA706-B	IA706	PROF024	2026/2	B	Noturno
IA801-A	IA801	PROF021	2026/2	A	Matutino
IA801-B	IA801	PROF022	2026/2	B	Noturno
IA802-A	IA802	PROF011	2026/2	A	Matutino
IA802-B	IA802	PROF012	2026/2	B	Noturno
IA803-A	IA803	PROF023	2026/2	A	Matutino
IA803-B	IA803	PROF024	2026/2	B	Noturno
IA804-A	IA804	PROF009	2026/2	A	Matutino
IA804-B	IA804	PROF010	2026/2	B	Noturno
IA805-A	IA805	PROF021	2026/2	A	Matutino
IA805-B	IA805	PROF022	2026/2	B	Noturno
IA806-A	IA806	PROF023	2026/2	A	Matutino
IA806-B	IA806	PROF024	2026/2	B	Noturno
\.


--
-- TOC entry 4917 (class 0 OID 16659)
-- Dependencies: 215
-- Data for Name: universidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.universidades (id_universidade, nome, cidade, uf) FROM stdin;
UNI01	Universidade Modelo de Anápolis	Anápolis	GO
\.


-- Completed on 2026-10-26 23:17:05

--
-- PostgreSQL database dump complete
--

\unrestrict ZQ4gFzwVffDWmS8gylf1GFMpyqbPefQVkBsYJIEpmeavYsOpNohTvwzLS5gRDnU

