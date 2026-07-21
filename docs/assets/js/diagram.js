/* AI Governance Platform — client-side mermaid rendering for guide bodies.
   Loads mermaid lazily from CDN only when a diagram is present; degrades to a
   readable code block if the module can't load. */
(function () {
  'use strict';
  const FP = (window.FP = window.FP || {});

  FP.enhanceDiagrams = async function (root) {
    const blocks = root.querySelectorAll('pre > code.language-mermaid, code.language-mermaid');
    if (!blocks.length) return;

    const nodes = [];
    blocks.forEach((code) => {
      const pre = code.closest('pre') || code;
      const div = document.createElement('div');
      div.className = 'mermaid';
      div.textContent = code.textContent;
      pre.replaceWith(div);
      nodes.push(div);
    });

    const reduce = window.matchMedia &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    try {
      const mod = await import('https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs');
      const mermaid = mod.default;
      mermaid.initialize({
        startOnLoad: false,
        theme: 'neutral',
        securityLevel: 'strict',
        fontFamily: '"Inter", "Segoe UI", system-ui, sans-serif',
        flowchart: { curve: 'basis' },
        themeVariables: { primaryColor: '#DDE6F7', primaryBorderColor: '#1A77E3', lineColor: '#47494E' },
      });
      // mermaid.run animates draw; nothing motion-heavy, but honor the flag by
      // not deferring — render is instant either way.
      void reduce;
      await mermaid.run({ nodes });
    } catch (e) {
      nodes.forEach((n) => {
        const pre = document.createElement('pre');
        const code = document.createElement('code');
        code.textContent = n.textContent;
        pre.appendChild(code);
        n.replaceWith(pre);
      });
    }
  };

  /* ── Image lightbox ──────────────────────────────────────────────────────
     Makes rendered diagram images (docs/assets/diagrams/*) clickable to expand
     in a full-screen overlay. The overlay closes on Escape or any left click. */
  let _lb = null;
  let _lbLastFocus = null;

  function _ensureLightbox() {
    if (_lb) return _lb;
    const overlay = document.createElement('div');
    overlay.className = 'fp-lightbox';
    overlay.setAttribute('role', 'dialog');
    overlay.setAttribute('aria-modal', 'true');
    overlay.setAttribute('aria-label', 'Expanded diagram');
    overlay.hidden = true;

    const img = document.createElement('img');
    img.className = 'fp-lightbox-img';
    img.alt = '';
    overlay.appendChild(img);
    document.body.appendChild(overlay);

    const close = () => {
      if (overlay.hidden) return;
      overlay.hidden = true;
      document.body.classList.remove('fp-lightbox-open');
      img.removeAttribute('src');
      img.alt = '';
      if (_lbLastFocus && typeof _lbLastFocus.focus === 'function') _lbLastFocus.focus();
      _lbLastFocus = null;
    };

    // Any left click on the overlay (image included) closes it.
    overlay.addEventListener('click', (e) => {
      if (e.button === 0) close();
    });
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') close();
    });

    _lb = { overlay, img, close };
    return _lb;
  }

  function _openLightbox(src, alt, opener) {
    const lb = _ensureLightbox();
    lb.img.src = src;
    lb.img.alt = alt || '';
    _lbLastFocus = opener || null;
    lb.overlay.hidden = false;
    document.body.classList.add('fp-lightbox-open');
  }

  FP.enhanceImages = function (root) {
    if (!root) return;
    const imgs = root.querySelectorAll('img[src*="assets/diagrams/"]');
    imgs.forEach((img) => {
      if (img.dataset.zoomable === '1') return;
      img.dataset.zoomable = '1';
      img.classList.add('diagram-zoomable');
      img.setAttribute('role', 'button');
      img.setAttribute('tabindex', '0');
      const label = (img.getAttribute('alt') || 'diagram').trim();
      img.setAttribute('aria-label', 'Expand diagram: ' + label);
      img.addEventListener('click', () => _openLightbox(img.currentSrc || img.src, img.alt, img));
      img.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          _openLightbox(img.currentSrc || img.src, img.alt, img);
        }
      });
    });
  };
})();
