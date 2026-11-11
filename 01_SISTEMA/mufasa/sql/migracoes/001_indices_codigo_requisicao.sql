-- Migracao 001 (modelo para as proximas; arquivo aplicado nao se edita).
-- Busca por codigo de requisicao, usada por scripts/diagnostico.py --requisicao:
-- o usuario informa o codigo que apareceu na tela e o suporte acha o registro.
CREATE INDEX IF NOT EXISTS ix_auditoria_requisicao ON auditoria_acessos (id_requisicao);
CREATE INDEX IF NOT EXISTS ix_logs_tecnicos_requisicao ON logs_tecnicos (id_requisicao);
