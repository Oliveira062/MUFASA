/*
 * Botao flutuante de acessibilidade do painel MUFASA (pedido do João, 28/10/2026).
 *
 * Roda na pagina do painel (injetado por ui.acessibilidade()). Tudo acontece no
 * navegador: as escolhas ficam no localStorage deste navegador e nada e enviado
 * ao servidor do MUFASA nem a terceiros.
 *
 * Unica excecao, por escolha da pessoa: o VLibras (Governo Federal). Ele fica
 * DESLIGADO por padrao e so e carregado de vlibras.gov.br depois que a pessoa
 * le o aviso e confirma (LGPD art. 6, I, III e VI). Ao traduzir, o texto em que
 * ela clicar vai para o servico do governo. Ver docs/POLITICA_DE_PRIVACIDADE.md.
 */
(function () {
  "use strict";
  if (window.__mufasaAcessibilidade) return;
  window.__mufasaAcessibilidade = true;

  var CHAVE = "mufasa.acessibilidade";
  var VLIBRAS = "https://vlibras.gov.br/app";
  var ESCALAS = [0.9, 1, 1.1, 1.25, 1.4, 1.6];
  var PADRAO = {
    escala: 1, contraste: false, escuro: false, cinza: false, legivel: false, espaco: false,
    links: false, guia: false, cursor: false, animacoes: false, voz: false, libras: false
  };
  var doc = document, html = doc.documentElement;
  var pref = ler();

  function ler() {
    var p = {};
    for (var k in PADRAO) p[k] = PADRAO[k];
    try {
      var salvo = JSON.parse(localStorage.getItem(CHAVE) || "{}");
      for (var c in PADRAO) if (typeof salvo[c] === typeof PADRAO[c]) p[c] = salvo[c];
    } catch (e) { /* navegador sem armazenamento: usa o padrao */ }
    if (!(p.escala >= 0 && p.escala < ESCALAS.length)) p.escala = 1;
    return p;
  }
  function salvar() {
    try { localStorage.setItem(CHAVE, JSON.stringify(pref)); } catch (e) { /* sem armazenamento */ }
  }

  // ---------- Estilos ----------
  var SETA = "data:image/svg+xml," + encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24">' +
    '<path d="M4 2l16 9.5-7 1.3 4.2 7.6-3 1.6-4.2-7.6L4 19z" fill="#000" stroke="#fff" stroke-width="1.4"/></svg>');
  var css = [
    /* botao e menu */
    "#mf-a11y-botao{position:fixed;right:18px;bottom:96px;z-index:2147483000;width:52px;height:52px;border-radius:50%;",
    " border:2px solid #FFFFFF;background:#8C6410;color:#FFFFFF;box-shadow:0 4px 14px rgba(61,43,31,.35);cursor:pointer;",
    " display:flex;align-items:center;justify-content:center;padding:0;}",
    "#mf-a11y-botao:hover{background:#6E4E0B;}",
    "#mf-a11y-botao:focus-visible,#mf-a11y-menu button:focus-visible{outline:3px solid #C99720;outline-offset:3px;}",
    "#mf-a11y-menu{position:fixed;right:18px;bottom:158px;z-index:2147483000;width:min(352px,calc(100vw - 36px));",
    " max-height:calc(100vh - 180px);overflow:auto;background:#FFFFFF;color:#3D2B1F;border:1px solid #E6D5AC;",
    " border-radius:16px;box-shadow:0 12px 32px rgba(61,43,31,.25);padding:16px;font:14px/1.4 Inter,system-ui,sans-serif;",
    " letter-spacing:normal;word-spacing:normal;zoom:1;filter:none;}",
    "#mf-a11y-menu[hidden]{display:none;}",
    "#mf-a11y-menu .cab{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;}",
    "#mf-a11y-menu h2{font-size:16px;line-height:22px;font-weight:700;margin:0;color:#3D2B1F;}",
    "#mf-a11y-menu .sub{font-size:12px;color:#6B5432;margin:0 0 12px 0;}",
    "#mf-a11y-menu h3{font-size:12px;font-weight:700;color:#8C6410;margin:14px 0 8px 0;letter-spacing:.02em;}",
    "#mf-a11y-menu .grade{display:grid;grid-template-columns:1fr 1fr;gap:8px;}",
    "#mf-a11y-menu button{font:inherit;color:#3D2B1F;background:#FBF6EA;border:1px solid #E6D5AC;border-radius:10px;",
    " padding:9px 10px;cursor:pointer;text-align:left;font-weight:600;font-size:13px;line-height:18px;}",
    "#mf-a11y-menu button:hover{border-color:#C99720;}",
    "#mf-a11y-menu button[aria-pressed=true]{background:#C99720;border-color:#8C6410;color:#3D2B1F;}",
    "#mf-a11y-menu button[aria-pressed=true]::before{content:'\\2713  ';}",
    "#mf-a11y-menu button:disabled{opacity:.5;cursor:not-allowed;}",
    "#mf-a11y-menu .fechar{background:transparent;border:none;font-size:20px;line-height:20px;padding:4px 8px;}",
    "#mf-a11y-menu .linha{display:flex;gap:8px;align-items:center;}",
    "#mf-a11y-menu .linha output{flex:1;text-align:center;font-weight:700;}",
    "#mf-a11y-menu .linha button{min-width:56px;text-align:center;}",
    "#mf-a11y-menu .largo{grid-column:1/-1;}",
    "#mf-a11y-menu .aviso{background:#FBF6EA;border:1px solid #E6D5AC;border-left:4px solid #C99720;border-radius:10px;",
    " padding:10px 12px;font-size:12.5px;line-height:18px;margin-top:8px;}",
    "#mf-a11y-menu .aviso p{margin:0 0 8px 0;}",
    "#mf-a11y-menu .aviso .linha button{flex:1;text-align:center;}",
    "#mf-a11y-menu .nota{font-size:11.5px;color:#6B5432;margin:6px 0 0 0;}",
    "#mf-a11y-menu .rodape{margin-top:14px;}",
    "#mf-a11y-menu .rodape button{width:100%;text-align:center;background:#FFFFFF;}",
    "#mf-a11y-guia{position:fixed;left:0;right:0;height:40px;margin-top:-20px;pointer-events:none;z-index:2147482999;",
    " background:rgba(201,151,32,.16);border-top:2px solid #8C6410;border-bottom:2px solid #8C6410;display:none;}",
    "html.mf-a-guia #mf-a11y-guia{display:block;}",
    /* tamanho do texto (o menu nao fica dentro de .stApp, entao nao cresce junto) */
    "html.mf-a-escala .stApp{zoom:var(--mf-a-escala);}",
    /* modo escuro e tons de cinza: filtros na pagina, imagens voltam ao normal */
    "html.mf-a-filtro .stApp{filter:var(--mf-a-filtro);}",
    "html.mf-a-escuro .stApp{background:#FFFFFF;}",
    "html.mf-a-escuro .stApp img,html.mf-a-escuro .stApp video{filter:invert(1) hue-rotate(180deg);}",
    /* alto contraste: fundo preto, texto branco, links e botoes em amarelo */
    /* selos de risco, pilulas e barras com cor propria (cor + icone + texto) ficam como estao, com contorno branco */
    "html.mf-a-contraste .stApp,html.mf-a-contraste .stApp *:not(svg):not(svg *):not(img):not(.mf-selo):not(.mf-selo *)",
    ":not([style*=background]):not([style*=background] *){background-color:#000 !important;",
    " color:#FFF !important;border-color:#FFF !important;box-shadow:none !important;background-image:none !important;}",
    "html.mf-a-contraste .stApp :is(.mf-selo,[style*=background]){outline:1px solid #FFF;}",
    "html.mf-a-contraste .stApp a,html.mf-a-contraste .stApp a *{color:#FFE600 !important;text-decoration:underline !important;}",
    "html.mf-a-contraste .stApp button,html.mf-a-contraste .stApp button *{color:#FFE600 !important;}",
    "html.mf-a-contraste .stApp button{border:2px solid #FFE600 !important;}",
    "html.mf-a-contraste .stApp svg{color:#FFF;}",
    "html.mf-a-contraste .stApp input,html.mf-a-contraste .stApp textarea{caret-color:#FFE600;}",
    /* fonte mais legivel (fontes do sistema com letras bem diferenciadas) */
    "html.mf-a-legivel .stApp,html.mf-a-legivel .stApp *:not(svg):not(svg *){font-family:Verdana,Tahoma,'Segoe UI',Arial,sans-serif !important;}",
    /* espacamento de texto (WCAG 1.4.12) */
    "html.mf-a-espaco .stApp :is(p,li,label,span,td,th,a,small,b,strong,input,textarea,h1,h2,h3,h4){",
    " line-height:1.7 !important;letter-spacing:.06em !important;word-spacing:.14em !important;}",
    "html.mf-a-espaco .stApp p{margin-bottom:1em !important;}",
    /* destacar links e botoes */
    "html.mf-a-links .stApp :is(a,button,[role=button],[role=tab],summary){outline:2px solid #8C6410 !important;",
    " outline-offset:2px !important;text-decoration:underline !important;}",
    "html.mf-a-links.mf-a-contraste .stApp :is(a,button,[role=button],[role=tab],summary){outline-color:#FFE600 !important;}",
    "html.mf-a-links .stApp :focus-visible{outline:4px solid #C99720 !important;outline-offset:3px !important;}",
    /* cursor grande */
    "html.mf-a-cursor,html.mf-a-cursor *{cursor:url(\"" + SETA + "\") 6 3,auto !important;}",
    /* pausar animacoes */
    "html.mf-a-animacoes *,html.mf-a-animacoes *::before,html.mf-a-animacoes *::after{animation-duration:0s !important;",
    " animation-iteration-count:1 !important;transition:none !important;scroll-behavior:auto !important;}",
    /* VLibras fica escondido quando desligado */
    "html:not(.mf-a-libras) [vw].enabled{display:none !important;}",
    "@media print{#mf-a11y-botao,#mf-a11y-menu,#mf-a11y-guia{display:none !important;}}"
  ].join("\n");
  var estilo = doc.createElement("style");
  estilo.id = "mf-a11y-estilo";
  estilo.textContent = css;
  doc.head.appendChild(estilo);

  // ---------- Menu ----------
  var ICONE = '<svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"' +
    ' stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">' +
    '<circle cx="12" cy="4.5" r="1.8" fill="currentColor"/><path d="M4.5 8.5c2.4.8 4.9 1.2 7.5 1.2s5.1-.4 7.5-1.2"/>' +
    '<path d="M12 9.7v4.8"/><path d="M12 14.5l-3 6.5"/><path d="M12 14.5l3 6.5"/></svg>';
  var OPCOES = [
    ["Visão", [["contraste", "Alto contraste"], ["escuro", "Modo escuro"], ["cinza", "Tons de cinza"], ["links", "Destacar links e botões"]]],
    ["Leitura", [["legivel", "Fonte mais legível"], ["espaco", "Mais espaço no texto"]]],
    ["Foco e atenção", [["guia", "Guia de leitura"], ["cursor", "Cursor grande"], ["animacoes", "Pausar animações"]]]
  ];
  var temVoz = "speechSynthesis" in window && "SpeechSynthesisUtterance" in window;

  var botao = doc.createElement("button");
  botao.id = "mf-a11y-botao";
  botao.type = "button";
  botao.setAttribute("aria-label", "Acessibilidade: abrir opções");
  botao.setAttribute("aria-expanded", "false");
  botao.setAttribute("aria-controls", "mf-a11y-menu");
  botao.title = "Acessibilidade";
  botao.innerHTML = ICONE;

  var menu = doc.createElement("div");
  menu.id = "mf-a11y-menu";
  menu.setAttribute("role", "dialog");
  menu.setAttribute("aria-modal", "false");
  menu.setAttribute("aria-labelledby", "mf-a11y-titulo");
  menu.hidden = true;
  var h = '<div class="cab"><h2 id="mf-a11y-titulo">Acessibilidade</h2>' +
    '<button type="button" class="fechar" data-acao="fechar" aria-label="Fechar opções de acessibilidade">×</button></div>' +
    '<p class="sub">As escolhas ficam salvas neste navegador.</p>' +
    '<h3 id="mf-a11y-tam">TAMANHO DO TEXTO</h3>' +
    '<div class="linha" role="group" aria-labelledby="mf-a11y-tam">' +
    '<button type="button" data-acao="menor" aria-label="Diminuir o texto">A−</button>' +
    '<output id="mf-a11y-escala" aria-live="polite"></output>' +
    '<button type="button" data-acao="maior" aria-label="Aumentar o texto">A+</button></div>';
  OPCOES.forEach(function (grupo, i) {
    h += '<h3 id="mf-a11y-g' + i + '">' + grupo[0].toUpperCase() + '</h3><div class="grade" role="group" aria-labelledby="mf-a11y-g' + i + '">';
    grupo[1].forEach(function (o) {
      h += '<button type="button" data-opcao="' + o[0] + '" aria-pressed="false">' + o[1] + "</button>";
    });
    h += "</div>";
  });
  h += '<h3 id="mf-a11y-ouvir">OUVIR E LIBRAS</h3><div class="grade" role="group" aria-labelledby="mf-a11y-ouvir">' +
    '<button type="button" data-opcao="voz" aria-pressed="false"' + (temVoz ? "" : " disabled") + '>Ler texto selecionado</button>' +
    '<button type="button" data-acao="ler"' + (temVoz ? "" : " disabled") + '>Ler a página</button>' +
    '<button type="button" data-acao="parar" class="largo"' + (temVoz ? "" : " disabled") + '>Parar a leitura</button>' +
    '<button type="button" data-opcao="libras" aria-pressed="false" class="largo">Tradutor de Libras (VLibras)</button></div>' +
    '<p class="nota">' + (temVoz ? "A leitura usa a voz do próprio navegador e não envia nada para fora."
      : "Este navegador não tem leitura em voz alta.") + "</p>" +
    '<div class="aviso" id="mf-a11y-aviso-libras" hidden role="region" aria-labelledby="mf-a11y-aviso-tit">' +
    '<p id="mf-a11y-aviso-tit"><b>Antes de ativar o VLibras</b></p>' +
    "<p>O VLibras é um serviço do Governo Federal. Ao ativar, o tradutor é carregado de vlibras.gov.br e o " +
    "texto em que você clicar para traduzir é enviado a esse serviço. Esse texto pode conter dados pessoais que " +
    "aparecem na tela, como nomes e notas. O MUFASA não envia nada sozinho.</p>" +
    "<p>Você pode desligar quando quiser. Mais detalhes na Política de Privacidade.</p>" +
    '<div class="linha"><button type="button" data-acao="libras-sim">Ativar o VLibras</button>' +
    '<button type="button" data-acao="libras-nao">Agora não</button></div></div>' +
    '<div class="rodape"><button type="button" data-acao="restaurar">Restaurar o padrão</button></div>';
  menu.innerHTML = h;

  var guia = doc.createElement("div");
  guia.id = "mf-a11y-guia";
  guia.setAttribute("aria-hidden", "true");

  // O botao e o primeiro item do Tab na pagina.
  doc.body.insertBefore(guia, doc.body.firstChild);
  doc.body.insertBefore(menu, doc.body.firstChild);
  doc.body.insertBefore(botao, doc.body.firstChild);

  function abrir(sim) {
    menu.hidden = !sim;
    botao.setAttribute("aria-expanded", sim ? "true" : "false");
    botao.setAttribute("aria-label", sim ? "Acessibilidade: fechar opções" : "Acessibilidade: abrir opções");
    if (sim) menu.querySelector("[data-acao=fechar]").focus();
  }
  botao.addEventListener("click", function () { abrir(menu.hidden); });
  doc.addEventListener("keydown", function (e) {
    if (e.key === "Escape" && !menu.hidden) { abrir(false); botao.focus(); }
  });
  doc.addEventListener("click", function (e) {
    if (!menu.hidden && !menu.contains(e.target) && !botao.contains(e.target)) abrir(false);
  });

  // ---------- Aplicar as escolhas ----------
  function aplicar() {
    var escala = ESCALAS[pref.escala];
    html.style.setProperty("--mf-a-escala", String(escala));
    html.classList.toggle("mf-a-escala", escala !== 1);
    var filtros = [];
    if (pref.escuro && !pref.contraste) filtros.push("invert(.92) hue-rotate(180deg)");
    if (pref.cinza) filtros.push("grayscale(1)");
    html.style.setProperty("--mf-a-filtro", filtros.join(" ") || "none");
    html.classList.toggle("mf-a-filtro", filtros.length > 0);
    ["contraste", "escuro", "legivel", "espaco", "links", "guia", "cursor", "animacoes", "libras"].forEach(function (k) {
      html.classList.toggle("mf-a-" + k, !!pref[k]);
    });
    menu.querySelectorAll("[data-opcao]").forEach(function (b) {
      b.setAttribute("aria-pressed", pref[b.getAttribute("data-opcao")] ? "true" : "false");
    });
    menu.querySelector("#mf-a11y-escala").textContent = Math.round(escala * 100) + "%";
    menu.querySelector("[data-acao=menor]").disabled = pref.escala === 0;
    menu.querySelector("[data-acao=maior]").disabled = pref.escala === ESCALAS.length - 1;
    if (pref.libras) carregarVLibras();
  }

  menu.addEventListener("click", function (e) {
    var alvo = e.target.closest("button");
    if (!alvo) return;
    var opcao = alvo.getAttribute("data-opcao"), acao = alvo.getAttribute("data-acao");
    var aviso = menu.querySelector("#mf-a11y-aviso-libras");
    if (opcao === "libras") {
      if (pref.libras) { pref.libras = false; desligarVLibras(); }
      else { aviso.hidden = false; aviso.querySelector("[data-acao=libras-sim]").focus(); return; }
    } else if (opcao) {
      pref[opcao] = !pref[opcao];
      if (opcao === "contraste" && pref.contraste) pref.escuro = false;
      if (opcao === "escuro" && pref.escuro) pref.contraste = false;
      if (opcao === "voz" && !pref.voz) pararLeitura();
    } else if (acao === "fechar") { abrir(false); botao.focus(); return; }
    else if (acao === "menor") pref.escala = Math.max(0, pref.escala - 1);
    else if (acao === "maior") pref.escala = Math.min(ESCALAS.length - 1, pref.escala + 1);
    else if (acao === "ler") { lerPagina(); return; }
    else if (acao === "parar") { pararLeitura(); return; }
    else if (acao === "libras-sim") { aviso.hidden = true; pref.libras = true; }
    else if (acao === "libras-nao") { aviso.hidden = true; menu.querySelector("[data-opcao=libras]").focus(); return; }
    else if (acao === "restaurar") {
      pararLeitura();
      if (pref.libras) desligarVLibras();
      for (var k in PADRAO) pref[k] = PADRAO[k];
    }
    salvar();
    aplicar();
  });

  // ---------- Guia de leitura ----------
  doc.addEventListener("mousemove", function (e) {
    if (pref.guia) guia.style.top = e.clientY + "px";
  }, { passive: true });

  // ---------- Leitura em voz alta (voz do navegador) ----------
  function falar(texto) {
    if (!temVoz) return;
    texto = (texto || "").replace(/\s+/g, " ").trim().slice(0, 6000);
    if (!texto) return;
    window.speechSynthesis.cancel();
    var u = new SpeechSynthesisUtterance(texto);
    u.lang = "pt-BR";
    var voz = window.speechSynthesis.getVoices().filter(function (v) { return /^pt(-|_)BR/i.test(v.lang); })[0];
    if (voz) u.voice = voz;
    window.speechSynthesis.speak(u);
  }
  function pararLeitura() { if (temVoz) window.speechSynthesis.cancel(); }
  function lerPagina() {
    var area = doc.querySelector('[data-testid="stMainBlockContainer"]') || doc.querySelector(".stApp");
    falar(area ? area.innerText : "");
  }
  function lerSelecao(e) {
    if (!pref.voz || menu.contains(e.target)) return;
    var sel = String(window.getSelection ? window.getSelection() : "");
    if (sel.trim().length > 1) falar(sel);
  }
  doc.addEventListener("mouseup", lerSelecao);
  doc.addEventListener("keyup", function (e) { if (e.shiftKey) lerSelecao(e); });

  // ---------- VLibras (so depois do aviso e da confirmacao) ----------
  var vlibrasCarregado = false;
  function carregarVLibras() {
    var caixa = doc.querySelector("[vw]");
    if (!caixa) {
      caixa = doc.createElement("div");
      caixa.setAttribute("vw", "");
      caixa.className = "enabled";
      caixa.innerHTML = '<div vw-access-button class="active"></div>' +
        '<div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div>';
      doc.body.appendChild(caixa);
    }
    if (vlibrasCarregado) return;
    vlibrasCarregado = true;
    var s = doc.createElement("script");
    s.src = VLIBRAS + "/vlibras-plugin.js";
    s.async = true;
    s.referrerPolicy = "no-referrer";
    s.onload = function () {
      if (!window.VLibras) return;
      new window.VLibras.Widget(VLIBRAS);
      // O VLibras inicia no evento "load" da pagina, que ja passou.
      window.dispatchEvent(new Event("load"));
    };
    s.onerror = function () {
      vlibrasCarregado = false;
      var nota = menu.querySelector(".nota");
      if (nota) nota.textContent = "Não foi possível carregar o VLibras. Verifique a conexão com a internet.";
    };
    doc.head.appendChild(s);
  }
  function desligarVLibras() {
    // A classe mf-a-libras sai do <html> em aplicar() e o CSS esconde o tradutor.
    // O script ja carregado so sai da memoria ao recarregar a pagina.
    if (window.VLibras && doc.querySelector("[vw-plugin-wrapper].active [vw-plugin-close]")) {
      doc.querySelector("[vw-plugin-close]").click();
    }
  }

  aplicar();
})();
