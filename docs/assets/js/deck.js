/* Frontier AI Governance — facilitator deck runtime (reveal.js glue).
   Reads ?s=<session-slug>, points the reveal markdown plugin at the session's
   deck, applies the session accent, and initialises reveal with back/forward
   controls, speaker notes (S), overview (Esc), and print-to-PDF (?print-pdf). */
(function () {
  'use strict';

  var params = new URLSearchParams(window.location.search);
  var slug = (params.get('s') || '').trim();
  var printPdf = /print-pdf/gi.test(window.location.search);

  function fail(message) {
    var slides = document.querySelector('.slides');
    if (slides) {
      slides.innerHTML =
        '<section><h2>Deck unavailable</h2><p>' + escapeHtml(message) + '</p>' +
        '<p><a href="index.html#sessions">Back to all sessions</a></p></section>';
    }
    var brand = document.getElementById('deckBrand');
    if (brand) brand.style.display = 'none';
    var pdf = document.getElementById('deckPdfBtn');
    if (pdf) pdf.style.display = 'none';
  }

  function escapeHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  /* Darken a #rrggbb hex colour by `amount` (0..1) for the closing gradient. */
  function shade(hex, amount) {
    var m = /^#?([0-9a-f]{6})$/i.exec(String(hex || '').trim());
    if (!m) return hex;
    var n = parseInt(m[1], 16);
    var r = Math.round(((n >> 16) & 255) * (1 - amount));
    var g = Math.round(((n >> 8) & 255) * (1 - amount));
    var b = Math.round((n & 255) * (1 - amount));
    return 'rgb(' + r + ',' + g + ',' + b + ')';
  }

  /* Inject a branded cover as the first slide and a thank-you/questions slide
     as the last, wrapping the markdown-generated content slides. */
  function injectFrame(session) {
    var slides = document.querySelector('.slides');
    var source = document.querySelector('.slides section[data-markdown]');
    if (!slides || !source) return;

    var accent = (session && session.accent) || '#1A77E3';
    var code = (session && session.code) || '';
    var title = (session && session.title) || 'Facilitator deck';
    var heading = (code ? code + ' · ' : '') + title;

    var cover = document.createElement('section');
    cover.className = 'deck-cover';
    cover.setAttribute('data-background-gradient',
      'linear-gradient(140deg, #041a44 0%, #063a86 100%)');
    cover.innerHTML =
      '<div class="cover-inner">' +
        '<img class="cover-logo" src="assets/img/logo-full.png" alt="RVAS AI Governance" />' +
        '<div class="cover-kicker">Facilitator deck</div>' +
        '<h1 class="cover-title">' + escapeHtml(heading) + '</h1>' +
        '<div class="cover-accent"></div>' +
        '<div class="cover-sub">RVAS AI Governance · a Microsoft AI governance curriculum</div>' +
      '</div>';

    var closing = document.createElement('section');
    closing.className = 'deck-closing';
    closing.setAttribute('data-background-gradient',
      'linear-gradient(140deg, ' + accent + ' 0%, ' + shade(accent, 0.55) + ' 100%)');
    closing.innerHTML =
      '<div class="closing-inner">' +
        '<img class="closing-logo" src="assets/img/logo-full.png" alt="" />' +
        '<h1 class="closing-title">Thank you</h1>' +
        '<div class="closing-sub">Questions &amp; discussion</div>' +
        '<div class="closing-meta">' + escapeHtml(heading) + '</div>' +
      '</div>';

    slides.insertBefore(cover, source);
    slides.appendChild(closing);
  }

  /* Hide the corner chips while a full-bleed branded slide is showing. */
  function syncBrandSlide() {
    var current = Reveal.getCurrentSlide();
    var brand = current && (current.classList.contains('deck-cover') ||
      current.classList.contains('deck-closing'));
    document.body.classList.toggle('on-brand-slide', !!brand);
  }

  function initReveal() {
    Reveal.initialize({
      hash: true,
      width: 1280,
      height: 720,
      margin: 0.045,
      minScale: 0.2,
      maxScale: 1.6,
      controls: true,
      controlsTutorial: false,
      controlsLayout: 'edges',
      progress: true,
      slideNumber: 'c/t',
      center: false,
      hashOneBasedIndex: true,
      transition: 'slide',
      backgroundTransition: 'fade',
      pdfSeparateFragments: false,
      plugins: [RevealMarkdown, RevealHighlight, RevealNotes],
    }).then(function () {
      syncBrandSlide();
      Reveal.on('slidechanged', syncBrandSlide);
      Reveal.on('ready', syncBrandSlide);
      if (printPdf && typeof window.print === 'function') {
        // Give reveal a tick to lay out the print pages, then open the dialog.
        setTimeout(function () { window.print(); }, 400);
      }
    });
  }

  function boot() {
    if (!slug || !/^[a-z0-9-]+$/i.test(slug)) {
      return fail('No valid session was specified for this deck.');
    }

    var source = document.querySelector('.slides section[data-markdown]');
    if (!source) return fail('Deck container missing.');
    source.setAttribute('data-markdown', 'assets/data/decks/' + slug + '.md');

    // Enrich branding + accent from the site catalog (best-effort, non-blocking).
    fetch('assets/data/site.json', { cache: 'no-cache' })
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (site) {
        var session = site && (site.sessions || []).filter(function (s) { return s.slug === slug; })[0];
        if (session) {
          if (session.accent) {
            document.querySelector('.reveal').style.setProperty('--deck-accent', session.accent);
          }
          var label = document.getElementById('deckBrandLabel');
          if (label) label.textContent = (session.code ? session.code + ' · ' : '') + (session.title || '');
          document.title = (session.code ? session.code + ' · ' : '') +
            (session.title ? session.title + ' — ' : '') + 'Facilitator deck';
        }
        injectFrame(session);
      })
      .catch(function () { injectFrame(null); })
      .finally(initReveal);
  }

  var pdfBtn = document.getElementById('deckPdfBtn');
  if (pdfBtn) {
    pdfBtn.addEventListener('click', function () {
      var url = 'deck.html?s=' + encodeURIComponent(slug) + '&print-pdf';
      window.open(url, 'deck-pdf-' + slug);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
