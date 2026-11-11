-- MUFASA — limpeza das sobras de importacao do B1 (aprovada pelo Joao em 28/10/2026)
--
-- Para quem JA carregou o dump original do B1. Quem for carregar do zero
-- pode usar "banco/Parte Samuel BackEnd B1 - limpo.sql", que ja vem sem elas.
--     psql -d mufasa -f sql/b1_limpeza_sobras.sql
--
-- O que remove: as 2.000 linhas de matriculas sem id_matricula, sem id_aluno
-- e com id_turma inexistente (IA1000-A, IA997-A...). Elas nao pertencem a
-- nenhum aluno e nenhuma consulta da API ou do chatbot as usa.
-- O que NAO toca: nenhuma outra linha, nenhuma nota, nenhuma metrica.
-- Se a contagem for diferente de 2.000, a transacao e desfeita.

BEGIN;

DO $$
DECLARE
    removidas integer;
BEGIN
    DELETE FROM matriculas m
     WHERE m.id_aluno IS NULL
       AND m.id_matricula IS NULL
       AND NOT EXISTS (SELECT 1 FROM turmas t WHERE t.id_turma = m.id_turma);
    GET DIAGNOSTICS removidas = ROW_COUNT;
    IF removidas NOT IN (0, 2000) THEN
        RAISE EXCEPTION 'Esperava 2000 linhas de sobra, encontrei %. Nada foi removido.', removidas;
    END IF;
    RAISE NOTICE 'Linhas de sobra removidas: %', removidas;
END $$;

COMMIT;
