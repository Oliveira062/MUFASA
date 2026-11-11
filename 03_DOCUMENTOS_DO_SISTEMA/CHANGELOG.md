# Registro de mudanças

Versão no formato MAIOR.MENOR.CORREÇÃO (ver `docs/05_EVOLUCAO_E_DIAGNOSTICO.md`, seção 5.5). A versão em uso aparece em `/saude` e em Administração → Serviços.

## 1.1.0 — 28/10/2026

**Painel e cores**
- Todas as telas seguem o padrão visual do Figma: fonte Inter, logo, menu lateral com ícones e contador de alertas, barra superior com caminho, notificações e conta, cabeçalhos de página, cartões com ícone, painéis brancos, tabelas com cabeçalho creme, pílulas de prazo e situação, linha do tempo e atalhos. Crítico e Alto mantêm o vermelho e o marrom escolhidos pelo grupo.
- Revisão de espaçamento para telas largas e notebooks: login com o fundo creme acompanhando a coluna e o formulário centralizado, ícones nos campos mesmo com preenchimento automático, fonte com hinting para o Windows, espaço padrão entre cabeçalho e conteúdo e largura máxima de 1480 px.
- Login em duas colunas; fila de alertas, ficha do aluno (escala de score e fatores com pontos), turmas do docente e início do aluno refeitos no layout do Figma. Comparações em `figma-comparacao/`, ao lado da entrega.
- Crítico passa a `#9A4A1E` e Alto a `#523E1D` nos selos e em todos os gráficos, a pedido do João. Os selos mantêm ícone e texto.
- Assistente mais livre e pessoal: a IA escreve com o próprio estilo, conversa sobre estudos e rotina e entende continuações ("e em Cálculo II?"). Recebe a pergunta só anonimizada; assuntos de saúde não saem do servidor. Respostas citam o primeiro nome, a melhor e a pior disciplina, a média comparada ao semestre anterior e os fatores do risco.
- Buscas combinadas para a equipe: "alunos com frequência perto de 60% e média abaixo de 5", "mais de 3 atividades pendentes no 2º semestre". Distância de casa só para o núcleo de apoio.
- Atividades com prazo: migração 002 com a tabela `atividades_aluno` e atividades simuladas coerentes com as pendências do B1. O aluno pergunta o que vence na semana e o que está atrasado. No Docker, `docker compose up -d --build` aplica a migração sozinho.
- Assistente: as perguntas ficam à direita e as respostas à esquerda, sempre dentro da caixa da conversa. A abertura da Mufa vira a primeira mensagem.
- Respostas do assistente reorganizadas e mais acolhedoras: frase de abertura, um item por linha (por exemplo, a disciplina com a nota final e, embaixo, VA1, VA2 e VA3), parágrafos separados e um próximo passo no fim. O aviso metodológico aparece como nota menor. O texto continua sendo escapado antes de virar HTML. A IA, quando ligada, recebe a regra de manter parágrafos curtos e a lista em bloco próprio.
- Varredura automática dos 8 perfis a 1366 e 1900 px: nomes longos do menu lateral passam a quebrar linha, o nome do usuário no topo deixa de ser cortado e a faixa "suprimido" mostra o texto inteiro.
- Tabelas com grupos suprimidos passam a ser texto, o que tira o aviso de conversão do Streamlit. Troca de `use_container_width` (descontinuado) por `width="stretch"`.

- Botão flutuante de acessibilidade em todas as telas, inclusive o login. Opções:
  - tamanho do texto;
  - alto contraste, modo escuro e tons de cinza;
  - fonte mais legível e mais espaço no texto;
  - destaque de links e botões;
  - guia de leitura, cursor grande e pausa das animações;
  - leitura em voz alta, com a voz do navegador.

  O tradutor de Libras (VLibras) vem desligado e só carrega depois de um aviso e da confirmação da pessoa (LGPD). As escolhas ficam salvas no navegador. Ver `docs/AUDITORIA_ACESSIBILIDADE.md`.

- Dados com visual novo em todas as telas: tabelas próprias no lugar das planilhas do Streamlit. Notas no formato brasileiro (6,0 e 7,8), nota e frequência abaixo do mínimo em vermelho, frequência com barra, situação e resultado em selos com ícone, faixa de resumo acima das disciplinas do aluno. Fatores do risco em cartões com ícone. Vale para portal do aluno, ficha, turma do docente, financeiro, gestão, administração e encarregado.
- Assistente: cabeçalho da Mufa, conversa com rolagem própria que acompanha a última mensagem, caixa de escrever maior com exemplo de pergunta, dica do Enter e botão de enviar visível, sugestões em destaque.
- `INICIAR_MUFASA.bat` sempre atualiza a imagem com o código da pasta antes de ligar. Antes, `docker compose up -d` reaproveitava a imagem antiga e as telas novas (inclusive o botão de acessibilidade) não apareciam.
- Chave da Groq no arquivo `groq.env`, ao lado do `.env` e ignorado pelo Git e pelo Docker. `python -m scripts.configurar --chaves` copia só as linhas GROQ_* para o `.env`, e o `INICIAR_MUFASA.bat` faz isso a cada início.

**Encontrar erros**
- Atalhos `INICIAR_MUFASA.bat` e `PARAR_MUFASA.bat` (e `iniciar_mufasa.sh` / `parar_mufasa.sh`) para ligar e desligar o sistema com duplo clique. O de ligar abre o Docker Desktop se precisar, cria o `.env` na primeira vez, espera o painel e abre o navegador.
- Registros em `logs/<serviço>.log` com rotação (5 MB × 5) e código de requisição em toda linha.
- Código para o suporte em todo erro mostrado na tela.
- `scripts/diagnostico.py`: confere o sistema inteiro e busca um erro pelo código (`--requisicao`).
- Respostas de erro 500 passam a levar o código e os cabeçalhos de segurança.

**Evoluir**
- Migrações versionadas (`sql/migracoes/`, `scripts/migrar.py`, com `--nova` e `--listar`).
- Número de versão do sistema em `app/__init__.py`, exibido em `/saude` e no sinal de vida.

**Rodar localmente**
- `scripts/configurar.py` gera o `.env`.
- `scripts/montar_banco.py` monta o banco sem `psql`, com as contas iniciais (`banco/contas_iniciais.sql`).
- `scripts/iniciar.py` sobe e reinicia cada parte.
- Docker: `Dockerfile` e `docker-compose.yml` com reinício automático e verificação de saúde.
- `requirements.lock` com as versões exatas testadas.
- Removido `scripts/montar_banco.sh`, substituído por `montar_banco.py`.

**Testes**
- Os testes passam a rodar num PostgreSQL de teste (`mufasa_teste`).
- Novos `teste_fluxos.py` e `teste_painel.py`: 201 testes no total.

**Documentação**
- Documentos 01 a 05 e a revisão das métricas contra o SRS v1.1.
- Documento 06: passo a passo do uso local com Docker.

## 1.0.0 — 28/10/2026

- Integração de B1, B2, B3, F2 e F1.
- Score reescrito pelo Anexo A do SRS v1.1, com parâmetros versionados.
- Painel Streamlit com hub por perfil.
- Logins para os 1.000 alunos e uma conta de demonstração por perfil.
- Serviços separados (API, chat, cálculo, painel) com isolamento de falhas.
