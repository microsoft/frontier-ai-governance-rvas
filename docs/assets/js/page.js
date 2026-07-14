/* Frontier AI Governance — standalone document page (How to Deliver,
   Assessment, Reference and its sub-pages). */
(function () {
  'use strict';

  const REFERENCE_GROUP = [
    { slug: 'reference-platform-technical', label: 'Platform technical guide' },
    { slug: 'reference-governance-capabilities', label: 'Governance capability guide' },
  ];
  const START_HERE_GROUP = [
    { slug: 'start-understand-rvas', label: 'About RVAS AI Governance' },
    { slug: 'start-plan-engagement', label: 'Plan the engagement' },
  ];

  async function init() {
    const slug = FP.qp('p');
    if (!slug) return fail('No page specified.');

    let site;
    try {
      const res = await fetch('assets/data/site.json', { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load site data (' + res.status + ')');
      site = await res.json();
    } catch (e) { return fail(e.message); }

    const page = (site.pages || []).find((p) => p.slug === slug);
    if (!page) return fail('Unknown page: ' + slug);

    document.title = `${page.title} — Frontier AI Governance`;
    document.getElementById('pageTitle').textContent = page.title;
    document.getElementById('pageCrumb').textContent = page.group || page.title;

    await renderBody(slug, page);
  }

  async function renderBody(slug, page) {
    const body = document.getElementById('guideBody');
    try {
      const res = await fetch(`assets/data/pages/${slug}.md`, { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load page (' + res.status + ')');
      const md = await res.text();
      FP.renderMd(md, body);
      if (FP.enhanceDiagrams) FP.enhanceDiagrams(body);
      buildAside(slug, page, body);
      appendReviewed(body, page);
    } catch (e) {
      body.innerHTML = `<div class="empty" role="alert"><strong>Could not load this page.</strong><br>${FP.esc(e.message)}</div>`;
    }
  }

  // Every content page gets a meaningful right column: an "On this page" table
  // of contents, plus the cross-page navigator on Reference pages.
  function buildAside(slug, page, body) {
    const aside = document.getElementById('docAside');
    const layout = document.getElementById('docLayout');
    if (!aside) return;

    const panels = [];
    const toc = tocFromBody(body);
    if (toc) panels.push(panel('On this page', `<ul class="spine-list">${toc}</ul>`));
    if (page.group === 'Reference') {
      const links = REFERENCE_GROUP.map((r) =>
        `<li><a href="page.html?p=${r.slug}"${r.slug === slug ? ' aria-current="page"' : ''}>${FP.esc(r.label)}</a></li>`
      ).join('');
      panels.push(panel('Reference set', `<ul class="spine-list">${links}</ul>`));
    }
    if (page.group === 'Start here') {
      const links = START_HERE_GROUP.map((r) =>
        `<li><a href="page.html?p=${r.slug}"${r.slug === slug ? ' aria-current="page"' : ''}>${FP.esc(r.label)}</a></li>`
      ).join('');
      panels.push(panel('Start here', `<ul class="spine-list">${links}</ul>`));
      appendSequenceNav(body, slug);
    }
    if (!panels.length) return;

    aside.innerHTML = panels.join('');
    aside.hidden = false;
    layout.classList.add('has-aside');
  }

  function appendSequenceNav(body, slug) {
    const index = START_HERE_GROUP.findIndex((page) => page.slug === slug);
    if (index === -1) return;
    const previous = START_HERE_GROUP[index - 1];
    const next = START_HERE_GROUP[index + 1];
    if (!previous && !next) return;
    const links = [
      previous && `<a href="page.html?p=${previous.slug}"><span class="snav-dir">← Previous</span><span class="snav-title">${FP.esc(previous.label)}</span></a>`,
      next && `<a class="snav-next" href="page.html?p=${next.slug}"><span class="snav-dir">Next →</span><span class="snav-title">${FP.esc(next.label)}</span></a>`,
    ].filter(Boolean).join('');
    const nav = document.createElement('nav');
    nav.className = 'session-nav';
    nav.setAttribute('aria-label', 'Start here navigation');
    nav.innerHTML = links;
    body.appendChild(nav);
  }

  function panel(head, inner) {
    return `<div class="panel"><div class="panel-head">${FP.esc(head)}</div><div class="panel-body">${inner}</div></div>`;
  }

  function tocFromBody(body) {
    const heads = body.querySelectorAll('h2');
    const items = [];
    heads.forEach((h, i) => {
      const label = (h.textContent || '').trim();
      if (!label) return;
      const id = ensureId(h, 'sec-' + (i + 1));
      items.push(`<li><a href="#${id}">${FP.esc(label)}</a></li>`);
    });
    return items.join('');
  }

  function ensureId(el, fallback) {
    if (!el.id) {
      const slug = (el.textContent || fallback).toLowerCase()
        .replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-').slice(0, 48) || fallback;
      el.id = slug;
    }
    return el.id;
  }

  function appendReviewed(body, page) {
    if (!page || !page.reviewed) return;
    const note = page.reviewedNote ? ` · ${FP.renderInlineMd(page.reviewedNote)}` : '';
    const el = document.createElement('footer');
    el.className = 'guide-meta';
    el.innerHTML =
      `<span class="guide-meta-k">Last reviewed</span> ` +
      `<time datetime="${FP.esc(page.reviewed)}">${FP.esc(page.reviewed)}</time>${note}`;
    body.appendChild(el);
  }

  function fail(msg) {
    document.getElementById('pageTitle').textContent = 'Page not found';
    const body = document.getElementById('guideBody');
    if (body) body.innerHTML = `<div class="empty" role="alert"><strong>${FP.esc(msg)}</strong><br><a href="index.html" style="color:var(--c-gold)">Back to home →</a></div>`;
  }

  document.addEventListener('DOMContentLoaded', init);
})();
