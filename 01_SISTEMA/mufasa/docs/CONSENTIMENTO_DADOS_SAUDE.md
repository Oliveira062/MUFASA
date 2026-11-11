# Consentimento para dados de saúde

Texto e fluxo para o painel (F1). Base: LGPD, arts. 8º, 11, I e 14, §1º; SRS, Seção 4.1 e RN16.

---

## Texto da tela

> **Você quer incluir informações sobre a sua saúde no acompanhamento?**
>
> Se você concordar, o núcleo de apoio poderá considerar as respostas sobre sua saúde física e mental ao calcular o seu nível de risco e ao planejar o apoio que pode ser oferecido a você.
>
> - Só você e o núcleo de apoio verão essas informações. Professores, coordenação e direção não verão.
> - Essas informações nunca serão usadas para avaliar, selecionar, conceder ou negar benefício.
> - **Recusar não traz nenhum prejuízo.** O sistema funciona normalmente sem esse dado.
> - Você pode mudar de ideia quando quiser, em "Preferências de privacidade".
>
> ( ) Sim, concordo em incluir informações de saúde
> ( ) Não concordo
>
> [Confirmar escolha]
>
> Versão do termo: 1.0 · [Política de Privacidade]

## Regras do fluxo

1. Nenhuma opção vem marcada. O botão "Confirmar" só ativa depois de uma escolha.
2. A tela é separada de qualquer outro aceite (termos de uso, aviso de armazenamento). Consentimento "embutido" em outro texto não vale (art. 8º, §4º).
3. A escolha é enviada para `POST /api/v1/privacidade/consentimentos` com `finalidade = DADOS_SAUDE`, `concedido` e `versao_termo`.
4. Estudante menor de 18 anos: a API recusa o consentimento dado pelo próprio estudante e explica que o termo do responsável legal é entregue à secretaria (art. 14, §1º).
5. Se o texto mudar, a versão muda e o consentimento é pedido de novo.
6. Revogar é sempre possível, pelo mesmo caminho, com um clique.

## Acessibilidade da tela

- Usar `<fieldset>` com `<legend>` na pergunta e `<label>` em cada opção.
- Mensagem de erro ligada ao grupo por `aria-describedby` e anunciada com `role="alert"`.
- Ordem de tabulação: pergunta, opções, confirmar, link da política.
- Contraste mínimo de 4,5:1 no texto e de 3:1 na borda dos controles.
