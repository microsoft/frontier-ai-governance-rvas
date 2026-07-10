/* Frontier AI Governance — client-side mermaid rendering for guide bodies.
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
})();
