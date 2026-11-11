# Roadmap do MUFASA

## Concluído

### 1.0.0 (28/10/2026)
- Integração das partes B1 (banco), B2 (cálculo), B3 (API e segurança), F1 (painel) e F2 (chatbot).
- Score reescrito pelo Anexo A do SRS v1.1, com parâmetros versionados.
- Painel Streamlit com hub por perfil e uma conta de demonstração para cada um dos 8 perfis.
- Logins para os 1.000 alunos.
- Serviços separados (API, chat, cálculo, painel) com isolamento de falhas.

### 1.1.0 (28/10/2026)
- Todas as telas no padrão visual do Figma. Crítico `#9A4A1E` e Alto `#523E1D`.
- Assistente Mufa mais livre, com dados anonimizados antes de chegar à IA e assuntos de saúde mantidos no servidor.
- Buscas combinadas para a equipe e atividades com prazo para o aluno.
- Botão de acessibilidade em todas as telas, com VLibras só após consentimento.
- Atalhos para ligar e desligar, registros com código de requisição e script de diagnóstico.
- Documentação LGPD (privacidade, termos, cookies, consentimento de dados de saúde) e auditorias de segurança, acessibilidade e chatbot.
- 217 testes automatizados.

## Próximos passos

### Segurança
- [ ] Definir o segundo fator de autenticação no login do aluno.


### Dados e métricas
- [ ] Alinhar `indicadores.media_atual` com as notas das matrículas do B1.
- [ ] Unificar as faixas de risco (B1 usa 20/35/56, B2 usa 25/50/75), conforme o SRS v1.1.
- [ ] Revisar a proporção de 90% de matrículas reprovadas no B1.
- [ ] Padronizar a escala de notas (0 a 10 ou 0 a 100).

### API e arquitetura
- [ ] Decidir o nome da rota de risco: `/risco` (Guia) ou `/score` (SRS, em uso).
- [ ] Executar o lote 1 da auditoria de arquitetura (SRE).
- [ ] Incluir `testserver` na configuração padrão de testes, para que rodem sem ajuste no `.env`.
- [ ] Integração contínua no GitHub rodando os testes a cada envio.

## Futuro
- [ ] Publicar o sistema em um servidor, com HTTPS e backups.
- [ ] Trocar as notas simuladas pelas notas reais da instituição.
- [ ] Aplicativo para celular conectado à API.
