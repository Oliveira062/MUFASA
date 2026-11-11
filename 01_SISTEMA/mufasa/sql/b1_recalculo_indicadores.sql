-- MUFASA — indicadores do aluno recalculados a partir das disciplinas
-- (decisao do João, 2026-10-28; achados B1-2 e B1-3 de docs/AUDITORIA_CHATBOT.md)
--
-- Aplicar DEPOIS de sql/b1_correcoes.sql (notas ja na escala 0 a 10) e de
-- sql/painel.sql (os gatilhos colocam todos os alunos na fila de recalculo):
--     psql -d mufasa -f sql/b1_recalculo_indicadores.sql
--
-- No dump do B1, a media e a frequencia de indicadores_academicos nao tinham
-- relacao com as notas e frequencias das disciplinas (correlacao -0,03).
-- As matriculas sao o dado detalhado, entao os indicadores passam a sair delas:
--   media_atual     = media das notas finais ponderada pela carga horaria
--                     (SRS v1.1, B.2.1: M = soma(nota x CH) / soma(CH))
--   frequencia_pct  = frequencia das disciplinas ponderada pela carga horaria
--                     (B.2.2 usa faltas / aulas; o B1 so tem o percentual por
--                     disciplina, e a carga horaria e a proporcao das aulas)
--   tendencia_media = media_atual - media_semestre_anterior (mesma regra do dump)
-- Ficam como estao, porque as matriculas nao tem o dado: faltas_total
-- (falta o total de aulas), disciplinas_reprovadas_historico (historico de
-- periodos anteriores), atividades_pendentes e media_semestre_anterior.
-- Os valores originais ficam em b1_indicadores_originais.
-- Daqui em diante, um gatilho em matriculas mantem os indicadores em dia.

BEGIN;

CREATE TABLE IF NOT EXISTS b1_indicadores_originais (
    id_aluno        VARCHAR(255) NOT NULL,
    periodo_letivo  VARCHAR(255) NOT NULL,
    frequencia_pct  INTEGER,
    media_atual     NUMERIC,
    tendencia_media NUMERIC,
    copiado_em      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    PRIMARY KEY (id_aluno, periodo_letivo),
    FOREIGN KEY (id_aluno, periodo_letivo) REFERENCES indicadores_academicos(id_aluno, periodo_letivo)
);
COMMENT ON TABLE b1_indicadores_originais IS
    'Media, frequencia e tendencia como vieram do dump do B1, antes do recalculo pelas disciplinas.';
ALTER TABLE b1_indicadores_originais OWNER TO mufasa_dono;

INSERT INTO b1_indicadores_originais (id_aluno, periodo_letivo, frequencia_pct, media_atual, tendencia_media)
SELECT id_aluno, periodo_letivo, frequencia_pct, media_atual, tendencia_media FROM indicadores_academicos
ON CONFLICT (id_aluno, periodo_letivo) DO NOTHING;

-- Mesma conta, para um aluno: usada pelo gatilho abaixo quando uma nota ou
-- frequencia de disciplina muda (carga de notas ou correcao da secretaria).
CREATE OR REPLACE FUNCTION recalcular_indicadores_do_aluno(aluno VARCHAR) RETURNS void
LANGUAGE sql SECURITY DEFINER SET search_path = public, pg_temp AS $$
    WITH por_disciplinas AS (
        SELECT m.id_aluno, t.periodo_letivo,
               round(sum(m.nota_final * mt.carga_horaria_h) / sum(mt.carga_horaria_h), 2) AS media,
               round(sum(m.frequencia_pct * mt.carga_horaria_h) / sum(mt.carga_horaria_h)) AS frequencia
          FROM matriculas m
          JOIN turmas t ON t.id_turma = m.id_turma
          JOIN materias mt ON mt.id_materia = t.id_materia
         WHERE m.id_aluno = aluno AND mt.carga_horaria_h > 0 AND m.nota_final IS NOT NULL AND m.frequencia_pct IS NOT NULL
         GROUP BY m.id_aluno, t.periodo_letivo
    )
    UPDATE indicadores_academicos i
       SET media_atual     = d.media,
           frequencia_pct  = d.frequencia,
           tendencia_media = CASE WHEN i.media_semestre_anterior IS NULL THEN NULL
                                  ELSE round(d.media - i.media_semestre_anterior, 2) END
      FROM por_disciplinas d
     WHERE d.id_aluno = i.id_aluno AND d.periodo_letivo = i.periodo_letivo
       AND (i.media_atual IS DISTINCT FROM d.media OR i.frequencia_pct IS DISTINCT FROM d.frequencia);
$$;

CREATE OR REPLACE FUNCTION tg_matriculas_indicadores() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    IF TG_OP IN ('UPDATE', 'DELETE') THEN
        PERFORM recalcular_indicadores_do_aluno(OLD.id_aluno);
    END IF;
    IF TG_OP IN ('INSERT', 'UPDATE') AND (TG_OP = 'INSERT' OR NEW.id_aluno IS DISTINCT FROM OLD.id_aluno) THEN
        PERFORM recalcular_indicadores_do_aluno(NEW.id_aluno);
    END IF;
    RETURN NULL;
END $$;

ALTER FUNCTION recalcular_indicadores_do_aluno(VARCHAR) OWNER TO mufasa_dono;
ALTER FUNCTION tg_matriculas_indicadores() OWNER TO mufasa_dono;

-- Nota ou frequencia de disciplina mudou: indicadores do aluno sao refeitos,
-- o que dispara o recalculo do score (sql/painel.sql) e atualiza os paineis.
DROP TRIGGER IF EXISTS tg_matriculas_recalculo ON matriculas;
CREATE TRIGGER tg_matriculas_recalculo
    AFTER INSERT OR DELETE OR UPDATE OF nota_final, frequencia_pct, id_aluno, id_turma ON matriculas
    FOR EACH ROW EXECUTE FUNCTION tg_matriculas_indicadores();

WITH por_disciplinas AS (
    SELECT m.id_aluno, t.periodo_letivo,
           round(sum(m.nota_final * mt.carga_horaria_h) / sum(mt.carga_horaria_h), 2) AS media,
           round(sum(m.frequencia_pct * mt.carga_horaria_h) / sum(mt.carga_horaria_h)) AS frequencia
      FROM matriculas m
      JOIN turmas t ON t.id_turma = m.id_turma
      JOIN materias mt ON mt.id_materia = t.id_materia
     WHERE mt.carga_horaria_h > 0 AND m.nota_final IS NOT NULL AND m.frequencia_pct IS NOT NULL
     GROUP BY m.id_aluno, t.periodo_letivo
)
UPDATE indicadores_academicos i
   SET media_atual     = d.media,
       frequencia_pct  = d.frequencia,
       tendencia_media = CASE WHEN i.media_semestre_anterior IS NULL THEN NULL
                              ELSE round(d.media - i.media_semestre_anterior, 2) END
  FROM por_disciplinas d
 WHERE d.id_aluno = i.id_aluno AND d.periodo_letivo = i.periodo_letivo;

COMMIT;
