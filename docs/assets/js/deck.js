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
      progress: true,
      slideNumber: 'c/t',
      center: false,
      hashOneBasedIndex: true,
      transition: 'slide',
      backgroundTransition: 'fade',
      pdfSeparateFragments: false,
      plugins: [RevealMarkdown, RevealHighlight, RevealNotes],
    }).then(function () {
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
      })
      .catch(function () { /* branding is optional */ })
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
