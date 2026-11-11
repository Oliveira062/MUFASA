# Política de Cookies e Consentimento do MUFASA

Versão 1.0 · 27/10/2026 · Referência: Guia Orientativo sobre Cookies e Proteção de Dados Pessoais da ANPD (2022) e LGPD, arts. 7º, 8º e 9º.

---

## 1. O que o MUFASA guarda no seu navegador

| Nome | Tipo | Para que serve | Duração | Precisa de consentimento? |
|---|---|---|---|---|
| Token de sessão | Memória da aba (não é cookie) | Manter você conectado enquanto usa o sistema | Até 30 minutos ou até fechar a aba | Não: estritamente necessário |
| `mufasa_aviso_armazenamento` | `localStorage` | Lembrar que você já viu este aviso | 12 meses | Não: estritamente necessário |

**O MUFASA não usa** cookies de publicidade, de rastreamento, de redes sociais nem de análise de terceiros. A API não grava cookie nenhum: o login trafega no cabeçalho `Authorization` de cada requisição.

## 2. Por que não há botão "aceitar todos"

O consentimento só é exigido para armazenamento que não é necessário ao funcionamento. Como o MUFASA usa apenas o estritamente necessário, o aviso é informativo, com um botão "Entendi" e o link para esta política. Pedir "aceite" de algo que não pode ser recusado daria a impressão falsa de escolha.

## 3. Se um dia o painel incluir algo opcional

Qualquer ferramenta de análise ou recurso de terceiros só pode entrar se:

1. for listada nesta política, com nome, finalidade, duração e fornecedor;
2. ficar **desligada por padrão**, carregando só depois do consentimento;
3. o aviso mostrar "Aceitar" e "Recusar" com o mesmo destaque, sem caixa pré-marcada;
4. a escolha puder ser mudada a qualquer momento em "Preferências de privacidade", tão fácil quanto foi dar;
5. o consentimento for registrado com data e versão desta política.

O componente `docs/aviso-armazenamento.html` já segue essas regras: basta acrescentar a categoria na lista `CATEGORIAS_OPCIONAIS`.

## 4. Orientações para o painel (F1)

- Guardar o token **em memória** (variável do JavaScript ou estado do Streamlit), não em `localStorage` nem em cookie. Assim um script injetado não consegue ler um token salvo, e não há cookie para um ataque CSRF usar.
- Não carregar fontes, ícones ou scripts de CDN de terceiros em produção: cada CDN recebe o IP de quem acessa. Servir tudo do próprio domínio.
- Não incluir pixel de rede social nem ferramenta de mapa de calor.

## 5. Consentimento para dados de saúde

Esse é outro consentimento, não tem relação com cookies. É o consentimento específico e destacado para usar dados de saúde no cálculo (LGPD, art. 11, I). O texto e o fluxo estão em [CONSENTIMENTO_DADOS_SAUDE.md](CONSENTIMENTO_DADOS_SAUDE.md), e a API grava cada concessão e revogação em `POST /api/v1/privacidade/consentimentos`.
