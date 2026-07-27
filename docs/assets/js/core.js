/* AI Governance Platform — shared helpers: data loading, theme, nav, badges, scroll-reveal. */
(function () {
  'use strict';

  const FP = (window.FP = window.FP || {});

  /* ─────────────────────────── Data ─────────────────────────────── */
  FP.dataUrl = 'assets/data/platform.json';

  FP.loadData = async function () {
    if (FP._cache) return FP._cache;
    const res = await fetch(FP.dataUrl, { cache: 'no-cache' });
    if (!res.ok) throw new Error('Could not load platform data (' + res.status + ')');
    FP._cache = await res.json();
    return FP._cache;
  };

  /* Module accent CSS variable resolving */
  FP.moduleColor = function (moduleId) {
    const map = {
      ghec: 'var(--c-ghec)',
      ghas: 'var(--c-ghas)',
      ghaw: 'var(--c-ghaw)',
      'sre-agent': 'var(--c-agentic)',
      'agentic-devops': 'var(--c-agentic)',
    };
    return map[moduleId] || 'var(--c-gold)';
  };

  FP.moduleName = function (moduleId, modules) {
    const m = (modules || []).find((x) => x.id === moduleId);
    return m ? m.name : moduleId;
  };

  FP.applyModuleColor = function (el, moduleId) {
    el.style.setProperty('--mod-color', FP.moduleColor(moduleId));
    el.classList.add('mod-' + moduleId);
  };

  /* ─────────────────────────── Escape ───────────────────────────── */
  FP.esc = function (s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, (c) =>
      ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c])
    );
  };

  /* ─────────────────────────── Badges ───────────────────────────── */
  FP.diffBadge = function (diff) {
    diff = (diff || 'beginner').toLowerCase();
    return `<span class="badge badge-difficulty-${FP.esc(diff)}">${FP.esc(diff)}</span>`;
  };

  FP.durBadge = function (mins) {
    if (!mins) return '';
    const h = Math.floor(mins / 60);
    const m = mins % 60;
    const label = h && m ? `${h}h ${m}m` : h ? `${h}h` : `${m}m`;
    return `<span class="badge badge-duration">⏱ ${label}</span>`;
  };

  FP.emuBadge = function (compat) {
    if (compat === false) return '<span class="badge badge-emu-no">⚠ EMU N/A</span>';
    if (compat === true)  return '<span class="badge badge-emu">✓ EMU</span>';
    return '';
  };

  FP.tagBadges = function (tags, limit) {
    if (!Array.isArray(tags) || !tags.length) return '';
    const show = limit ? tags.slice(0, limit) : tags;
    return show.map((t) => `<span class="badge badge-tag">${FP.esc(t)}</span>`).join('');
  };

  /* ─────────────────────────── URL helpers ───────────────────────── */
  FP.challengeUrl = function (id) {
    return 'challenge.html?id=' + encodeURIComponent(id);
  };
  FP.moduleUrl = function (id) {
    return 'module.html?m=' + encodeURIComponent(id);
  };
  FP.catalogOutcomeUrl = function (id) {
    return 'catalog.html?outcome=' + encodeURIComponent(id);
  };
  FP.outcomeName = function (outcomeId, outcomes) {
    const o = (outcomes || []).find((x) => x.id === outcomeId);
    return o ? o.name : outcomeId;
  };

  /* ─────────────────────────── Query params ─────────────────────── */
  FP.qp = function (name) {
    return new URLSearchParams(window.location.search).get(name);
  };

  /* ─────────────────────── Kiosk / curated set ───────────────────── */
  /* A coach-built set lives entirely in the URL. `set.html` uses ?ids=…,
     challenge pages opened from a set carry ?set=… so the locked view
     persists. When either is present, kiosk mode hides outbound navigation
     and shows a small "Exit view" button. */

  FP.kioskParams = function () {
    const raw = FP.qp('ids') || FP.qp('set');
    if (!raw) return null;
    const ids = raw.split(',').map((s) => s.trim()).filter(Boolean);
    if (!ids.length) return null;
    return { ids, name: FP.qp('name') || '' };
  };

  FP.isKiosk = function () {
    return !!FP.kioskParams();
  };

  /* URL of the curated set landing page */
  FP.setUrl = function (ids, name) {
    const q = new URLSearchParams();
    q.set('ids', (ids || []).join(','));
    if (name) q.set('name', name);
    return 'set.html?' + q.toString();
  };

  /* Challenge URL that keeps the kiosk state attached */
  FP.kioskChallengeUrl = function (id, params) {
    const q = new URLSearchParams();
    q.set('id', id);
    q.set('set', (params.ids || []).join(','));
    if (params.name) q.set('name', params.name);
    return 'challenge.html?' + q.toString();
  };

  FP.applyKiosk = function () {
    const params = FP.kioskParams();
    if (!params) return null;
    document.documentElement.setAttribute('data-kiosk', 'true');
    if (document.body) document.body.setAttribute('data-kiosk', 'true');
    _injectExitButton();
    return params;
  };

  function _injectExitButton() {
    if (document.getElementById('kioskExitBtn')) return;
    const btn = document.createElement('a');
    btn.id = 'kioskExitBtn';
    btn.className = 'kiosk-exit';
    btn.href = 'index.html';
    btn.textContent = 'Exit view';
    btn.setAttribute('aria-label', 'Exit curated view and return to the full site');
    const actions = document.querySelector('.nav-actions');
    if (actions) actions.insertBefore(btn, actions.firstChild);
    else document.body.appendChild(btn);
  }

  /* ─────────────────────────── Theme (light only) ───────────────── */
  FP.initTheme = function () {
    document.documentElement.setAttribute('data-theme', 'light');
  };

  /* ─────────────────────────── Nav ──────────────────────────────── */
  FP.initNav = function () {
    const toggle = document.querySelector('.nav-toggle');
    const links  = document.querySelector('.nav-links');
    const dropdowns = Array.from(document.querySelectorAll('.nav-dropdown'));
    const closeDropdowns = (except) => {
      dropdowns.forEach((dropdown) => {
        if (dropdown !== except) {
          dropdown.classList.remove('open');
          const btn = dropdown.querySelector('.nav-dropdown-toggle');
          if (btn) btn.setAttribute('aria-expanded', 'false');
        }
      });
    };
    let boundDropdown = false;
    dropdowns.forEach((dropdown) => {
      if (dropdown.dataset.dropdownBound) return;
      dropdown.dataset.dropdownBound = '1';
      boundDropdown = true;
      const btn = dropdown.querySelector('.nav-dropdown-toggle');
      if (!btn) return;
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const open = !dropdown.classList.contains('open');
        closeDropdowns(dropdown);
        dropdown.classList.toggle('open', open);
        btn.setAttribute('aria-expanded', String(open));
      });
      dropdown.querySelectorAll('a').forEach((link) => {
        link.addEventListener('click', () => closeDropdowns());
      });
    });
    if (boundDropdown) {
      document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') closeDropdowns();
      });
      document.addEventListener('click', (e) => {
        if (!dropdowns.some((dropdown) => dropdown.contains(e.target))) closeDropdowns();
      });
    }

    if (!toggle || !links || toggle.dataset.shellBound) return;
    toggle.dataset.shellBound = '1';
    const close = () => {
      links.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
      closeDropdowns();
    };
    if (toggle && links) {
      toggle.addEventListener('click', () => {
        const open = links.classList.toggle('open');
        toggle.setAttribute('aria-expanded', String(open));
      });
      // Close on Esc
      document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape' && links.classList.contains('open')) {
          links.classList.remove('open');
          toggle.setAttribute('aria-expanded', 'false');
        }
      });
      document.addEventListener('click', (e) => {
        if (!links.classList.contains('open')) return;
        if (!links.contains(e.target) && !toggle.contains(e.target)) close();
      });
    }
  };

  /* ─────────────────────────── Reveal ───────────────────────────── */
  FP.initReveal = function () {
    if (!('IntersectionObserver' in window)) {
      document.querySelectorAll('.reveal').forEach((el) => el.classList.add('visible'));
      return;
    }
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) { e.target.classList.add('visible'); obs.unobserve(e.target); }
        });
      },
      { threshold: 0.08 }
    );
    document.querySelectorAll('.reveal').forEach((el) => obs.observe(el));
  };

  /* ─────────────────────────── Error rendering ───────────────────── */
  FP.renderError = function (container, msg) {
    if (typeof container === 'string') container = document.getElementById(container);
    if (!container) return;
    container.innerHTML = `<div class="empty" role="alert"><strong>Could not load data.</strong><br>${FP.esc(msg)}</div>`;
  };

  /* ─────────────────────────── Markdown ─────────────────────────── */
  // GitHub-style alert banners (> [!IMPORTANT] etc.). marked.js has no native
  // support, so we post-process the parsed DOM: any blockquote whose first line
  // is a recognised marker becomes a styled .md-alert banner with an icon + label.
  var MD_ALERT_TYPES = {
    note:      { label: 'Note',      icon: 'M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8Zm8-6.5a6.5 6.5 0 1 0 0 13 6.5 6.5 0 0 0 0-13ZM6.5 7.75A.75.75 0 0 1 7.25 7h1a.75.75 0 0 1 .75.75v2.75h.25a.75.75 0 0 1 0 1.5h-2a.75.75 0 0 1 0-1.5h.25v-2h-.25a.75.75 0 0 1-.75-.75ZM8 6a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z' },
    tip:       { label: 'Tip',       icon: 'M8 1.5c-2.363 0-4 1.69-4 3.75 0 .984.424 1.625.984 2.304l.214.253c.223.264.47.556.673.848.284.411.537.896.621 1.49a.75.75 0 0 1-1.484.211c-.04-.282-.163-.547-.37-.847a8.456 8.456 0 0 0-.542-.68c-.084-.1-.173-.205-.268-.32C3.201 7.75 2.5 6.766 2.5 5.25 2.5 2.31 4.863 0 8 0s5.5 2.31 5.5 5.25c0 1.516-.701 2.5-1.328 3.259-.095.115-.184.22-.268.319-.207.245-.383.453-.541.681-.208.3-.33.565-.37.847a.751.751 0 0 1-1.485-.212c.084-.593.337-1.078.621-1.489.203-.292.45-.584.673-.848.075-.088.147-.173.213-.253.561-.679.985-1.32.985-2.304 0-2.06-1.637-3.75-4-3.75ZM5.75 12h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1 0-1.5ZM6 15.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75Z' },
    important: { label: 'Important', icon: 'M0 1.75C0 .784.784 0 1.75 0h12.5C15.216 0 16 .784 16 1.75v9.5A1.75 1.75 0 0 1 14.25 13H8.06l-2.573 2.573A1.458 1.458 0 0 1 3 14.543V13H1.75A1.75 1.75 0 0 1 0 11.25Zm1.75-.25a.25.25 0 0 0-.25.25v9.5c0 .138.112.25.25.25h2a.75.75 0 0 1 .75.75v2.19l2.72-2.72a.749.749 0 0 1 .53-.22h6.5a.25.25 0 0 0 .25-.25v-9.5a.25.25 0 0 0-.25-.25Zm7 2.25v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 9a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z' },
    warning:   { label: 'Warning',   icon: 'M6.457 1.047c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0 1 14.082 15H1.918a1.75 1.75 0 0 1-1.543-2.575Zm1.763.707a.25.25 0 0 0-.44 0L1.698 13.132a.25.25 0 0 0 .22.368h12.164a.25.25 0 0 0 .22-.368Zm.53 3.996v2.5a.75.75 0 0 1-1.5 0v-2.5a.75.75 0 0 1 1.5 0ZM9 11a1 1 0 1 1-2 0 1 1 0 0 1 2 0Z' },
    caution:   { label: 'Caution',   icon: 'M4.47.22A.749.749 0 0 1 5 0h6c.199 0 .389.079.53.22l4.25 4.25c.141.14.22.331.22.53v6a.749.749 0 0 1-.22.53l-4.25 4.25A.749.749 0 0 1 11 16H5a.749.749 0 0 1-.53-.22L.22 11.53A.749.749 0 0 1 0 11V5c0-.199.079-.389.22-.53Zm.84 1.28L1.5 5.31v5.38l3.81 3.81h5.38l3.81-3.81V5.31L10.69 1.5ZM8 4a.75.75 0 0 1 .75.75v3.5a.75.75 0 0 1-1.5 0v-3.5A.75.75 0 0 1 8 4Zm0 8a1 1 0 1 1 0-2 1 1 0 0 1 0 2Z' },
  };
  var MD_ALERT_RE = /^\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*/;

  function decorateAlerts(root) {
    var quotes = root.querySelectorAll('blockquote');
    for (var i = 0; i < quotes.length; i++) {
      var bq = quotes[i];
      var first = bq.querySelector('p');
      if (!first) continue;
      var m = (first.textContent || '').match(MD_ALERT_RE);
      if (!m) continue;
      var type = m[1].toLowerCase();
      var spec = MD_ALERT_TYPES[type];
      if (!spec) continue;

      // Strip the "[!TYPE]" marker (and a following <br> or newline) from the first paragraph.
      first.innerHTML = first.innerHTML.replace(/^\s*\[!(?:NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*(?:<br\s*\/?>)?\s*/i, '');
      if (!first.textContent.trim() && !first.querySelector('*')) {
        first.parentNode.removeChild(first);
      }

      bq.classList.add('md-alert', 'md-alert-' + type);
      var head = document.createElement('p');
      head.className = 'md-alert-title';
      head.innerHTML =
        '<svg class="md-alert-icon" viewBox="0 0 16 16" width="16" height="16" aria-hidden="true" fill="currentColor"><path d="' +
        spec.icon + '"></path></svg><span>' + spec.label + '</span>';
      bq.insertBefore(head, bq.firstChild);
    }
  }

  var LAB_REPOSITORY_URL = 'https://github.com/microsoft/frontier-ai-governance-rvas';
  var LAB_PATH_RE = /^labs\/[A-Za-z0-9._/-]+\/?$/;

  function decorateLabLinks(root) {
    var codes = root.querySelectorAll('code');
    for (var i = 0; i < codes.length; i++) {
      var code = codes[i];
      if (code.closest('pre') || code.closest('a')) continue;

      var path = (code.textContent || '').trim();
      var segments = path.replace(/\/$/, '').split('/');
      if (!LAB_PATH_RE.test(path) || segments.some((segment) => segment === '.' || segment === '..')) continue;

      var isDirectory = path.endsWith('/') || !segments[segments.length - 1].includes('.');
      var encodedPath = path.replace(/\/$/, '').split('/').map(encodeURIComponent).join('/');
      var link = document.createElement('a');
      link.className = 'lab-artifact-link';
      link.href = LAB_REPOSITORY_URL + '/' + (isDirectory ? 'tree' : 'blob') + '/main/' + encodedPath;
      link.target = '_blank';
      link.rel = 'noopener';
      link.title = 'Open ' + path + ' in GitHub';
      link.setAttribute('aria-label', 'Open ' + path + ' in GitHub (new tab)');
      link.textContent = path;
      code.replaceWith(link);
    }
  }

  function compactNumberedTables(root) {
    var tables = root.querySelectorAll('table');
    for (var i = 0; i < tables.length; i++) {
      var table = tables[i];
      var headerRow = table.tHead && table.tHead.rows.length ? table.tHead.rows[0] : table.querySelector('tr');
      if (!headerRow || headerRow.cells.length < 3) continue;

      var firstHeader = headerRow.cells[0];
      if ((firstHeader.textContent || '').trim() !== '#') continue;

      table.classList.add('md-table-compact-numbered');
      firstHeader.parentNode.removeChild(firstHeader);

      var rows = table.tBodies.length ? table.tBodies[0].rows : table.querySelectorAll('tr');
      for (var r = 0; r < rows.length; r++) {
        var row = rows[r];
        if (row === headerRow || row.cells.length < 2) continue;

        var numberCell = row.cells[0];
        var labelCell = row.cells[1];
        var number = (numberCell.textContent || '').trim();
        var main = document.createElement('div');
        main.className = 'md-merged-main';
        while (labelCell.firstChild) main.appendChild(labelCell.firstChild);

        var merged = document.createElement('div');
        merged.className = 'md-merged-cell';
        if (number) {
          var index = document.createElement('span');
          index.className = 'md-merged-index';
          index.textContent = number;
          merged.appendChild(index);
        }
        merged.appendChild(main);
        labelCell.appendChild(merged);
        numberCell.parentNode.removeChild(numberCell);
      }
    }
  }

  function dropTableColumns(root, headersToDrop) {
    var targets = {};
    for (var h = 0; h < headersToDrop.length; h++) {
      targets[normalizeHeader(headersToDrop[h])] = true;
    }

    var tables = root.querySelectorAll('table');
    for (var i = 0; i < tables.length; i++) {
      var table = tables[i];
      var headerRow = table.tHead && table.tHead.rows.length ? table.tHead.rows[0] : table.querySelector('tr');
      if (!headerRow) continue;

      var dropIndexes = [];
      for (var c = 0; c < headerRow.cells.length; c++) {
        if (targets[normalizeHeader(headerRow.cells[c].textContent || '')]) dropIndexes.push(c);
      }
      if (!dropIndexes.length) continue;

      for (var r = 0; r < table.rows.length; r++) {
        var row = table.rows[r];
        for (var d = dropIndexes.length - 1; d >= 0; d--) {
          var cell = row.cells[dropIndexes[d]];
          if (cell) cell.parentNode.removeChild(cell);
        }
      }
    }
  }

  function normalizeHeader(value) {
    return String(value || '').replace(/\s+/g, ' ').trim().toLowerCase();
  }

  function addChoiceDiagrams(root) {
    var tables = root.querySelectorAll('table');
    for (var i = 0; i < tables.length; i++) {
      var table = tables[i];
      if (table.dataset.choiceDiagram === '1') continue;

      var headerRow = table.tHead && table.tHead.rows.length ? table.tHead.rows[0] : table.querySelector('tr');
      if (!headerRow) continue;

      var headers = [];
      for (var h = 0; h < headerRow.cells.length; h++) {
        headers.push(normalizeHeader(headerRow.cells[h].textContent || ''));
      }

      var optionIndex = headers.indexOf('option');
      var bestWhenIndex = headers.indexOf('best when');
      if (optionIndex === -1 || bestWhenIndex === -1) continue;

      var rows = table.tBodies.length ? table.tBodies[0].rows : [];
      if (!rows.length) continue;

      var choices = [];
      for (var r = 0; r < rows.length; r++) {
        var row = rows[r];
        if (row.cells.length <= Math.max(optionIndex, bestWhenIndex)) continue;
        choices.push({
          option: cleanChoiceText(row.cells[optionIndex].textContent || ''),
          reproducible: cellText(row, headers.indexOf('reproducible')),
          creates: cellText(row, headers.indexOf('creates storage + embedding')),
          bestWhen: cleanChoiceText(row.cells[bestWhenIndex].textContent || ''),
        });
      }
      if (choices.length < 2) continue;

      table.dataset.choiceDiagram = '1';
      table.insertAdjacentElement('beforebegin', renderChoiceDiagram(choices));
    }
  }

  function cellText(row, index) {
    if (index < 0 || !row.cells[index]) return '';
    return cleanChoiceText(row.cells[index].textContent || '');
  }

  function cleanChoiceText(value) {
    return String(value || '').replace(/\s+/g, ' ').trim();
  }

  function renderChoiceDiagram(choices) {
    var figure = document.createElement('figure');
    figure.className = 'choice-diagram';
    figure.setAttribute('aria-label', 'Choice diagram generated from the option table');

    var head = document.createElement('figcaption');
    head.className = 'choice-diagram-head';
    head.innerHTML =
      '<span class="choice-diagram-kicker">Decision sketch</span>' +
      '<strong>Pick the path by what you need to keep true.</strong>';
    figure.appendChild(head);

    var rail = document.createElement('div');
    rail.className = 'choice-diagram-rail';
    rail.setAttribute('aria-hidden', 'true');
    figure.appendChild(rail);

    var list = document.createElement('div');
    list.className = 'choice-diagram-list';
    choices.slice(0, 5).forEach(function (choice, index) {
      list.appendChild(renderChoiceCard(choice, index));
    });
    figure.appendChild(list);

    return figure;
  }

  function renderChoiceCard(choice, index) {
    var card = document.createElement('section');
    card.className = 'choice-diagram-card';
    if (/\bdefault\b/i.test(choice.option)) card.classList.add('choice-diagram-card-default');

    var title = document.createElement('h4');
    title.textContent = choice.option.replace(/\s*\(default\)\s*/i, '').trim() || 'Option ' + (index + 1);
    card.appendChild(title);

    var tags = document.createElement('div');
    tags.className = 'choice-diagram-tags';
    if (/\bdefault\b/i.test(choice.option)) tags.appendChild(choiceTag('Default'));
    if (choice.reproducible) tags.appendChild(choiceTag('Reproducible: ' + choice.reproducible));
    if (choice.creates) tags.appendChild(choiceTag(choice.creates));
    if (tags.childNodes.length) card.appendChild(tags);

    var best = document.createElement('p');
    best.textContent = choice.bestWhen || 'Use when this path best matches the customer context.';
    card.appendChild(best);

    return card;
  }

  function choiceTag(label) {
    var tag = document.createElement('span');
    tag.className = 'choice-diagram-tag';
    tag.textContent = label;
    return tag;
  }

  function addContentAccordions(root) {
    wrapOptionDetailSections(root);
    wrapTroubleshootingContent(root);
    wrapVerifyStepLists(root);
  }

  function wrapOptionDetailSections(root) {
    var optionMap = collectOptionLabels(root);
    var keys = Object.keys(optionMap);
    if (!keys.length) return;

    var headings = Array.prototype.slice.call(root.querySelectorAll('h2, h3, h4, h5, h6'));
    headings.forEach(function (heading) {
      if (!heading.parentNode || heading.closest('details')) return;
      var match = optionHeadingMatch(heading.textContent || '', optionMap);
      if (!match) return;
      wrapHeadingSection(heading, {
        summary: match.summary,
        label: 'Option ' + match.key,
        className: 'md-accordion-option',
      });
    });
  }

  function collectOptionLabels(root) {
    var optionMap = {};
    var tables = root.querySelectorAll('table');
    for (var i = 0; i < tables.length; i++) {
      var table = tables[i];
      var headerRow = table.tHead && table.tHead.rows.length ? table.tHead.rows[0] : table.querySelector('tr');
      if (!headerRow) continue;

      var optionIndex = -1;
      for (var h = 0; h < headerRow.cells.length; h++) {
        if (normalizeHeader(headerRow.cells[h].textContent || '') === 'option') {
          optionIndex = h;
          break;
        }
      }
      if (optionIndex === -1) continue;

      var rows = table.tBodies.length ? table.tBodies[0].rows : [];
      for (var r = 0; r < rows.length; r++) {
        var cell = rows[r].cells[optionIndex];
        if (!cell) continue;
        var parsed = parseOptionText(cell.textContent || '');
        if (parsed) optionMap[parsed.key] = parsed.label;
      }
    }
    return optionMap;
  }

  function parseOptionText(value) {
    var text = cleanChoiceText(value);
    var match = text.match(/^(?:option\s*)?([A-Z])(?:[\.)]|[\s:—-]+)\s*(.+)$/i);
    if (!match) return null;
    return {
      key: match[1].toUpperCase(),
      label: cleanChoiceText(match[2] || ''),
    };
  }

  function optionHeadingMatch(value, optionMap) {
    var parsed = parseOptionText(value);
    if (parsed && optionMap[parsed.key]) {
      return { key: parsed.key, summary: parsed.key + '. ' + (parsed.label || optionMap[parsed.key]) };
    }

    var heading = cleanChoiceText(value).toLowerCase();
    var keys = Object.keys(optionMap);
    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      var label = optionMap[key];
      if (label && heading === label.toLowerCase()) {
        return { key: key, summary: key + '. ' + label };
      }
    }
    return null;
  }

  function wrapTroubleshootingContent(root) {
    var headings = Array.prototype.slice.call(root.querySelectorAll('h2, h3, h4, h5, h6'));
    headings.forEach(function (heading) {
      if (!heading.parentNode || heading.closest('details')) return;
      if (!/\btroubleshoot(?:ing)?\b/i.test(heading.textContent || '')) return;
      wrapHeadingSection(heading, {
        summary: cleanChoiceText(heading.textContent || 'Troubleshooting'),
        label: 'Troubleshooting',
        className: 'md-accordion-troubleshooting',
      });
    });

    var paragraphs = Array.prototype.slice.call(root.querySelectorAll('p'));
    paragraphs.forEach(function (paragraph) {
      if (!paragraph.parentNode || paragraph.closest('details')) return;
      var text = cleanChoiceText(paragraph.textContent || '');
      var match = text.match(/^troubleshooting\s*:\s*/i);
      if (!match) return;
      wrapParagraphRun(paragraph, {
        summary: 'Troubleshooting',
        className: 'md-accordion-troubleshooting',
      });
    });
  }

  function wrapHeadingSection(heading, opts) {
    var level = headingLevel(heading);
    var details = document.createElement('details');
    details.className = 'md-accordion ' + opts.className;

    var summary = document.createElement('summary');
    summary.innerHTML =
      '<span class="md-accordion-label">' + FP.esc(opts.label) + '</span>' +
      '<span class="md-accordion-title">' + FP.esc(opts.summary) + '</span>';
    details.appendChild(summary);

    var body = document.createElement('div');
    body.className = 'md-accordion-body';

    var node = heading.nextSibling;
    while (node) {
      if (node.nodeType === 1 && /^H[1-6]$/.test(node.tagName) && headingLevel(node) <= level) break;
      var next = node.nextSibling;
      body.appendChild(node);
      node = next;
    }

    details.appendChild(body);
    heading.replaceWith(details);
  }

  function wrapParagraphRun(paragraph, opts) {
    var details = document.createElement('details');
    details.className = 'md-accordion ' + opts.className;

    var summary = document.createElement('summary');
    summary.innerHTML =
      '<span class="md-accordion-label">' + FP.esc(opts.summary) + '</span>' +
      '<span class="md-accordion-title">' + FP.esc(opts.summary) + '</span>';
    details.appendChild(summary);

    var body = document.createElement('div');
    body.className = 'md-accordion-body';
    paragraph.innerHTML = paragraph.innerHTML.replace(/^(\s*<[^>]+>)*\s*Troubleshooting\s*:\s*/i, '');
    body.appendChild(paragraph.cloneNode(true));

    var node = paragraph.nextSibling;
    while (node) {
      if (node.nodeType === 1 && /^(H[1-6]|TABLE|FIGURE|DETAILS)$/.test(node.tagName)) break;
      if (node.nodeType === 1 && node.matches && node.matches('p, ul, ol, blockquote, pre')) {
        var next = node.nextSibling;
        body.appendChild(node);
        node = next;
        continue;
      }
      if (node.nodeType === 3 && !node.textContent.trim()) {
        var nextText = node.nextSibling;
        node.parentNode.removeChild(node);
        node = nextText;
        continue;
      }
      break;
    }

    details.appendChild(body);
    paragraph.replaceWith(details);
  }

  function wrapVerifyStepLists(root) {
    var lists = Array.prototype.slice.call(root.querySelectorAll('ol'));
    lists.forEach(function (list) {
      if (!list.parentNode || list.closest('details') || list.dataset.stepAccordion === '1') return;
      var items = directListItems(list);
      if (items.length < 3 || !isVerificationStepList(list, items)) return;

      list.dataset.stepAccordion = '1';
      list.classList.add('md-step-accordion-list');
      items.forEach(function (item, index) {
        wrapListItemStep(item, index + 1);
      });
    });
  }

  function directListItems(list) {
    return Array.prototype.filter.call(list.children, function (child) {
      return child.tagName === 'LI';
    });
  }

  function isVerificationStepList(list, items) {
    var heading = nearestPreviousHeading(list);
    var headingText = heading ? cleanChoiceText(heading.textContent || '') : '';
    if (/\b(verify|verification|validate|validation|work the decision)\b/i.test(headingText)) return true;

    var joined = items.map(function (item) {
      return cleanChoiceText(item.textContent || '');
    }).join(' ');
    return /\b(inspect|fill|record|accepted when|decision tree|exception|evidence|handoff)\b/i.test(joined) &&
      /\b(customer-approved|decision|evidence|record|acceptance test)\b/i.test(joined);
  }

  function nearestPreviousHeading(node) {
    var current = node;
    while (current && current.previousSibling) {
      current = current.previousSibling;
      if (current.nodeType === 1 && /^H[1-6]$/.test(current.tagName)) return current;
    }
    var parent = node.parentElement;
    while (parent && parent !== document.body) {
      var sibling = parent.previousSibling;
      while (sibling) {
        if (sibling.nodeType === 1 && /^H[1-6]$/.test(sibling.tagName)) return sibling;
        sibling = sibling.previousSibling;
      }
      parent = parent.parentElement;
    }
    return null;
  }

  function wrapListItemStep(item, stepNumber) {
    var title = stepTitle(item) || 'Step ' + stepNumber;
    var body = document.createElement('div');
    body.className = 'md-accordion-body';
    while (item.firstChild) body.appendChild(item.firstChild);
    removeLeadingStepTitle(body, title);

    if (!hasMeaningfulContent(body)) {
      var card = document.createElement('div');
      card.className = 'md-step-card';
      card.innerHTML =
        '<span class="md-accordion-label">Step ' + FP.esc(stepNumber) + '</span>' +
        '<span class="md-accordion-title">' + FP.esc(title) + '</span>';
      item.appendChild(card);
      return;
    }

    var details = document.createElement('details');
    details.className = 'md-accordion md-step-accordion';

    var summary = document.createElement('summary');
    summary.innerHTML =
      '<span class="md-accordion-label">Step ' + FP.esc(stepNumber) + '</span>' +
      '<span class="md-accordion-title">' + FP.esc(title) + '</span>';
    details.appendChild(summary);

    details.appendChild(body);
    item.appendChild(details);
  }

  function hasMeaningfulContent(node) {
    if (cleanChoiceText(node.textContent || '')) return true;
    return !!node.querySelector('table, ul, ol, blockquote, pre, figure, img, details');
  }

  function stepTitle(item) {
    var firstBlock = firstMeaningfulChild(item);
    var text = firstBlock ? cleanChoiceText(firstBlock.textContent || '') : cleanChoiceText(item.textContent || '');
    if (!text) return '';
    var firstSentence = text.match(/^(.+?[.!?])(?:\s|$)/);
    var title = firstSentence ? firstSentence[1] : text;
    return title.length > 140 ? title.slice(0, 137).replace(/\s+\S*$/, '') + '...' : title;
  }

  function firstMeaningfulChild(node) {
    for (var child = node.firstChild; child; child = child.nextSibling) {
      if (child.nodeType === 3 && child.textContent.trim()) return child;
      if (child.nodeType === 1) return child;
    }
    return null;
  }

  function removeLeadingStepTitle(body, title) {
    var first = firstMeaningfulChild(body);
    if (!first) return;

    if (first.nodeType === 1 && /^(P|DIV)$/.test(first.tagName) && cleanChoiceText(first.textContent || '') === title) {
      first.parentNode.removeChild(first);
      return;
    }

    if (first.nodeType === 3 && cleanChoiceText(first.textContent || '') === title) {
      first.parentNode.removeChild(first);
    }
  }

  function headingLevel(el) {
    return Number((el.tagName || 'H6').slice(1)) || 6;
  }

  FP.renderMd = function (rawMd, targetEl) {
    if (!rawMd) { targetEl.innerHTML = '<p class="text-dim">No content.</p>'; return; }
    if (window.marked) {
      targetEl.innerHTML = window.marked.parse(rawMd, { breaks: false, gfm: true });
      try { decorateAlerts(targetEl); } catch (e) { /* non-fatal */ }
      try { decorateLabLinks(targetEl); } catch (e) { /* non-fatal */ }
      try { dropTableColumns(targetEl, ['Cost while idle']); } catch (e) { /* non-fatal */ }
      try { compactNumberedTables(targetEl); } catch (e) { /* non-fatal */ }
      try { addChoiceDiagrams(targetEl); } catch (e) { /* non-fatal */ }
      try { addContentAccordions(targetEl); } catch (e) { /* non-fatal */ }
    } else {
      // Fallback: wrap in <pre> if marked not available
      const pre = document.createElement('pre');
      pre.textContent = rawMd;
      pre.style.whiteSpace = 'pre-wrap';
      targetEl.innerHTML = '';
      targetEl.appendChild(pre);
    }
  };

  FP.renderInlineMd = function (rawMd) {
    if (rawMd == null || rawMd === '') return '';
    if (!window.marked || typeof window.marked.parseInline !== 'function') return FP.esc(rawMd);

    try {
      return _sanitizeInlineHtml(window.marked.parseInline(String(rawMd), { breaks: false, gfm: true }));
    } catch (e) {
      return FP.esc(rawMd);
    }
  };

  function _sanitizeInlineHtml(html) {
    const template = document.createElement('template');
    template.innerHTML = html;

    const out = document.createElement('span');
    Array.from(template.content.childNodes).forEach((node) => {
      out.appendChild(_sanitizeInlineNode(node));
    });
    return out.innerHTML;
  }

  function _sanitizeInlineNode(node) {
    if (node.nodeType === 3) return document.createTextNode(node.textContent || '');
    if (node.nodeType !== 1) return document.createTextNode('');

    const tag = node.tagName.toLowerCase();
    if (!['a', 'strong', 'em', 'code', 'del', 'br'].includes(tag)) {
      return _sanitizeInlineChildren(node);
    }

    if (tag === 'br') return document.createElement('br');

    if (tag === 'a') {
      const href = node.getAttribute('href') || '';
      if (!_isSafeInlineHref(href)) return _sanitizeInlineChildren(node);

      const a = document.createElement('a');
      a.setAttribute('href', href);
      const title = node.getAttribute('title');
      if (title) a.setAttribute('title', title);
      Array.from(node.childNodes).forEach((child) => a.appendChild(_sanitizeInlineNode(child)));
      return a;
    }

    const el = document.createElement(tag);
    Array.from(node.childNodes).forEach((child) => el.appendChild(_sanitizeInlineNode(child)));
    return el;
  }

  function _sanitizeInlineChildren(node) {
    const frag = document.createDocumentFragment();
    Array.from(node.childNodes).forEach((child) => frag.appendChild(_sanitizeInlineNode(child)));
    return frag;
  }

  function _isSafeInlineHref(href) {
    const trimmed = String(href || '').trim();
    if (!trimmed) return false;
    if (/[\u0000-\u001F\u007F]/.test(trimmed)) return false;
    if (!/^[a-z][a-z0-9+.-]*:/i.test(trimmed) && !trimmed.startsWith('//')) return true;
    try {
      return ['http:', 'https:', 'mailto:'].includes(new URL(trimmed, window.location.href).protocol);
    } catch (e) {
      return false;
    }
  }

  /* ─────────────────────────── Init ─────────────────────────────── */
  document.addEventListener('DOMContentLoaded', () => {
    FP.initTheme();
    FP.initNav();
    FP.applyKiosk();
    FP.initReveal();
  });

})();
