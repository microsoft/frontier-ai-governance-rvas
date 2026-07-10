/* Frontier AI Governance — session detail page. */
(function () {
  'use strict';

  const REPO = 'https://github.com/microsoft/frontier-ai-governance-rvas';

  async function init() {
    const slug = FP.qp('s');
    if (!slug) return fail('No session specified.');

    let site;
    try {
      const res = await fetch('assets/data/site.json', { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load site data (' + res.status + ')');
      site = await res.json();
    } catch (e) { return fail(e.message); }

    const sessions = site.sessions || [];
    const idx = sessions.findIndex((s) => s.slug === slug);
    if (idx === -1) return fail('Unknown session: ' + slug);
    const s = sessions[idx];

    document.title = `${s.code} · ${s.title} — Frontier AI Governance`;
    document.getElementById('sessionHero').style.setProperty('--mod-color', s.accent);

    const crumb = document.getElementById('sessionCrumb');
    if (crumb) crumb.textContent = s.code;

    const chip = document.getElementById('sessionChip');
    if (chip) { chip.textContent = s.code; chip.style.display = 'inline-flex'; }

    document.getElementById('sessionTitle').textContent = s.title;

    renderMeta(s);
    renderFacts(s);
    renderKit(s);
    renderSessionNav(sessions, idx);
    await renderGuide(slug, s);
  }

  function renderMeta(s) {
    const el = document.getElementById('sessionMeta');
    el.innerHTML =
      `<span class="badge badge-persona">${FP.esc(s.persona)}</span>` +
      `<span class="badge badge-nist">NIST · ${FP.esc(s.nist)}</span>`;
  }

  function renderFacts(s) {
    const el = document.getElementById('factRows');
    el.innerHTML = [
      row('Durable outcome', s.outcome),
      row('Primary persona', s.persona),
      row('NIST AI RMF function', s.nist),
      row('Session', `${s.code} of S0–S6`),
    ].join('');
  }

  function row(k, v) {
    return `<div class="fact-row"><span class="fact-k">${FP.esc(k)}</span><span class="fact-v">${FP.esc(v)}</span></div>`;
  }

  function renderKit(s) {
    const path = `labs/${s.slug}/`;
    document.getElementById('kitPath').textContent = path;
    document.getElementById('kitLink').href = `${REPO}/tree/main/${path}`;
  }

  function renderSessionNav(sessions, idx) {
    const nav = document.getElementById('sessionNav');
    const prev = sessions[idx - 1];
    const next = sessions[idx + 1];
    let html = '';
    if (prev) {
      html += `<a href="session.html?s=${encodeURIComponent(prev.slug)}"><span class="snav-dir">← ${FP.esc(prev.code)}</span><span class="snav-title">${FP.esc(prev.title)}</span></a>`;
    }
    if (next) {
      html += `<a class="snav-next" href="session.html?s=${encodeURIComponent(next.slug)}"><span class="snav-dir">${FP.esc(next.code)} →</span><span class="snav-title">${FP.esc(next.title)}</span></a>`;
    }
    nav.innerHTML = html;
  }

  async function renderGuide(slug, s) {
    const body = document.getElementById('guideBody');
    try {
      const res = await fetch(`assets/data/pages/${slug}.md`, { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load session guide (' + res.status + ')');
      const md = await res.text();
      FP.renderMd(md, body);
      buildSpine(body);
      if (FP.enhanceDiagrams) FP.enhanceDiagrams(body);
      appendReviewed(body, s);
    } catch (e) {
      body.innerHTML = `<div class="empty" role="alert"><strong>Could not load the session guide.</strong><br>${FP.esc(e.message)}</div>`;
    }
  }

  // Subtle "last reviewed" line at the very bottom of the guide, replacing the
  // former prominent top-of-page Freshness alert.
  function appendReviewed(body, s) {
    if (!s || !s.reviewed) return;
    const note = s.reviewedNote ? ` · ${FP.renderInlineMd(s.reviewedNote)}` : '';
    const el = document.createElement('footer');
    el.className = 'guide-meta';
    el.innerHTML =
      `<span class="guide-meta-k">Last reviewed</span> ` +
      `<time datetime="${FP.esc(s.reviewed)}">${FP.esc(s.reviewed)}</time>${note}`;
    body.appendChild(el);
  }

  // Build the "In this session" TOC from the rendered H2s, adding anchor ids.
  function buildSpine(body) {
    const list = document.getElementById('spineList');
    if (!list) return;
    const heads = body.querySelectorAll('h2');
    const items = [];
    heads.forEach((h, i) => {
      const label = (h.textContent || '').trim();
      if (!label || /^sources$/i.test(label)) { if (/^sources$/i.test(label)) ensureId(h, 'sources'); return; }
      const id = ensureId(h, 'sec-' + (i + 1));
      items.push(`<li><a href="#${id}">${FP.esc(label)}</a></li>`);
    });
    list.innerHTML = items.join('') || '<li style="color:var(--c-faint);font-size:0.82rem;padding:6px 8px">No sections.</li>';
  }

  function ensureId(el, fallback) {
    if (!el.id) {
      const slug = (el.textContent || fallback).toLowerCase()
        .replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-').slice(0, 48) || fallback;
      el.id = slug;
    }
    return el.id;
  }

  function fail(msg) {
    const body = document.getElementById('guideBody');
    document.getElementById('sessionTitle').textContent = 'Session not found';
    if (body) body.innerHTML = `<div class="empty" role="alert"><strong>${FP.esc(msg)}</strong><br><a href="index.html#sessions" style="color:var(--c-gold)">Back to all sessions →</a></div>`;
  }

  document.addEventListener('DOMContentLoaded', init);
})();
