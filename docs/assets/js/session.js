/* Frontier AI Governance - focused session chapter pages. */
(function () {
  'use strict';

  const REPO = 'https://github.com/microsoft/frontier-ai-governance-rvas';
  const DEFAULT_CHAPTER = 'prepare';

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
    const sessionIndex = sessions.findIndex((s) => s.slug === slug);
    if (sessionIndex === -1) return fail('Unknown session: ' + slug);
    const session = sessions[sessionIndex];
    const kiosk = FP.kioskParams();
    const navigationSessions = kiosk
      ? sessions.filter((candidate) => kiosk.ids.includes(candidate.slug))
      : sessions;
    const navigationIndex = navigationSessions.findIndex((candidate) => candidate.slug === slug);
    if (navigationIndex === -1) return fail('This session is not part of the selected set.');
    const chapters = session.chapters || [];
    const requested = FP.qp('chapter') || DEFAULT_CHAPTER;
    const chapterIndex = chapters.findIndex((chapter) => chapter.slug === requested);
    const chapter = chapters[chapterIndex];
    if (!chapter) return fail('Unknown session chapter.');

    document.title = `${session.code} · ${session.title} · ${chapter.label} - Frontier AI Governance`;
    document.getElementById('sessionHero').style.setProperty('--mod-color', session.accent);
    document.getElementById('sessionCrumb').textContent = session.code;
    document.getElementById('sessionChip').textContent = session.code;
    document.getElementById('sessionChip').style.display = 'inline-flex';
    document.getElementById('sessionTitle').textContent = session.title;
    document.getElementById('sessionChapterLabel').textContent = chapter.label;

    renderMeta(session);
    renderFacts(session);
    renderChapterNav(session, chapters, chapter.slug);
    renderKit(session);
    renderSetReturn(kiosk);
    renderSessionNav(navigationSessions, navigationIndex, chapters, chapterIndex);
    await renderChapter(session, chapter);
  }

  function renderMeta(session) {
    const el = document.getElementById('sessionMeta');
    el.innerHTML =
      `<span class="badge badge-persona">${FP.esc(session.persona)}</span>` +
      `<span class="badge badge-nist">NIST · ${FP.esc(session.nist)}</span>` +
      (session.optional ? '<span class="badge badge-nist">Optional extension</span>' : '');
  }

  function renderFacts(session) {
    document.getElementById('factRows').innerHTML = [
      row('Durable outcome', session.outcome),
      row('Primary persona', session.persona),
      row('NIST AI RMF function', session.nist),
      row('Curriculum phase', session.phase || 'Curriculum'),
      row('Applicability', session.optional ? 'Run when an in-process tool-call boundary is relevant' : 'Selected by scope and prerequisites'),
    ].join('');
  }

  function renderChapterNav(session, chapters, activeSlug) {
    const links = chapters.map((chapter) =>
      `<li><a href="${chapterHref(session.slug, chapter.slug)}"${chapter.slug === activeSlug ? ' aria-current="page"' : ''}>${FP.esc(chapter.label)}</a></li>`
    ).join('');
    document.getElementById('sessionChapterNav').innerHTML = `<ul class="session-chapter-list">${links}</ul>`;
  }

  function row(key, value) {
    return `<div class="fact-row"><span class="fact-k">${FP.esc(key)}</span><span class="fact-v">${FP.esc(value)}</span></div>`;
  }

  function renderKit(session) {
    const path = `labs/${session.slug}/`;
    document.getElementById('kitPath').textContent = path;
    document.getElementById('kitLink').href = `${REPO}/tree/main/${path}`;
  }

  function renderSetReturn(kiosk) {
    if (!kiosk) return;
    const link = document.getElementById('allSessionsLink');
    if (!link) return;
    link.href = FP.setUrl(kiosk.ids, kiosk.name);
    link.textContent = '← Back to session set';
  }

  function renderSessionNav(sessions, sessionIndex, chapters, chapterIndex) {
    const nav = document.getElementById('sessionNav');
    const current = sessionIndex * chapters.length + chapterIndex;
    const allChapters = sessions.flatMap((session) =>
      chapters.map((chapter) => ({ session, chapter }))
    );
    const previous = allChapters[current - 1];
    const next = allChapters[current + 1];
    const links = [
      previous && chapterLink(previous, '← Previous'),
      next && chapterLink(next, 'Next →', true),
    ].filter(Boolean);
    nav.innerHTML = links.join('');
  }

  function chapterLink(entry, direction, next = false) {
    return `<a${next ? ' class="snav-next"' : ''} href="${chapterHref(entry.session.slug, entry.chapter.slug)}">` +
      `<span class="snav-dir">${direction}</span>` +
      `<span class="snav-title">${FP.esc(entry.session.code)} · ${FP.esc(entry.chapter.label)}</span>` +
      `</a>`;
  }

  function chapterHref(sessionSlug, chapterSlug) {
    return `session.html?s=${encodeURIComponent(sessionSlug)}&chapter=${encodeURIComponent(chapterSlug)}`;
  }

  async function renderChapter(session, chapter) {
    const body = document.getElementById('guideBody');
    try {
      const res = await fetch(`assets/data/pages/${session.slug}-${chapter.slug}.md`, { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load session chapter (' + res.status + ')');
      FP.renderMd(await res.text(), body);
      if (FP.enhanceDiagrams) FP.enhanceDiagrams(body);
      appendReviewed(body, session, chapter.slug);
    } catch (e) {
      body.innerHTML = `<div class="empty" role="alert"><strong>Could not load this chapter.</strong><br>${FP.esc(e.message)}</div>`;
    }
  }

  function appendReviewed(body, session, chapterSlug) {
    const reviewedByChapter = {
      concepts: [session.conceptsReviewed, session.conceptsReviewedNote],
      technical: [session.technicalReviewed, session.technicalReviewedNote],
    };
    const [reviewed, reviewedNote] = reviewedByChapter[chapterSlug] || [session.reviewed, session.reviewedNote];
    if (!reviewed) return;
    const note = reviewedNote ? ` · ${FP.renderInlineMd(reviewedNote)}` : '';
    const el = document.createElement('footer');
    el.className = 'guide-meta';
    el.innerHTML =
      `<span class="guide-meta-k">Last reviewed</span> ` +
      `<time datetime="${FP.esc(reviewed)}">${FP.esc(reviewed)}</time>${note}`;
    body.appendChild(el);
  }

  function fail(message) {
    document.getElementById('sessionTitle').textContent = 'Session not found';
    const body = document.getElementById('guideBody');
    if (body) {
      body.innerHTML = `<div class="empty" role="alert"><strong>${FP.esc(message)}</strong><br>` +
        `<a href="index.html#sessions" style="color:var(--c-gold)">Back to all sessions →</a></div>`;
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();
