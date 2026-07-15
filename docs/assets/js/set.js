/* Frontier AI Governance - client-side session set builder. */
(function () {
  'use strict';

  let selected = new Set();
  let site;

  async function init() {
    try {
      const res = await fetch('assets/data/site.json', { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load site data (' + res.status + ')');
      site = await res.json();
    } catch (e) {
      FP.renderError('setCatalog', e.message);
      return;
    }

    const params = FP.kioskParams();
    if (params) {
      renderSetPage(params);
      return;
    }

    bindBuilder();
    renderCatalog();
  }

  function bindBuilder() {
    document.getElementById('setName').addEventListener('input', updateSetLink);
    document.getElementById('openSet').addEventListener('click', () => {
      window.location.assign(pageUrl());
    });
    document.getElementById('copySetLink').addEventListener('click', copySetLink);
  }

  function renderCatalog() {
    const catalog = document.getElementById('setCatalog');
    catalog.innerHTML = site.sessions.map((session) => `
      <button class="sel-card" type="button" data-session="${FP.esc(session.slug)}"
        aria-pressed="${selected.has(session.slug)}" style="--mod-color:${FP.esc(session.accent)}">
        <span class="sel-check" aria-hidden="true">
          <svg width="12" height="12" viewBox="0 0 16 16" fill="none" stroke="white" stroke-width="2.5"><path d="m3 8 3 3 7-7"/></svg>
        </span>
        <span class="session-card-head">
          <span class="session-chip">${FP.esc(session.code)}</span>
          <span class="session-card-title">${FP.esc(session.title)}</span>
        </span>
        <span class="session-card-outcome"><span class="session-outcome-label">Durable outcome</span>${FP.esc(session.outcome)}</span>
        <span class="session-card-foot">
          <span class="badge badge-persona">${FP.esc(session.persona)}</span>
          <span class="badge badge-nist">NIST · ${FP.esc(session.nist)}</span>
        </span>
      </button>`).join('');

    catalog.querySelectorAll('[data-session]').forEach((button) => {
      button.addEventListener('click', () => {
        const id = button.dataset.session;
        if (selected.has(id)) selected.delete(id);
        else selected.add(id);
        button.setAttribute('aria-pressed', String(selected.has(id)));
        updateSetLink();
      });
    });
  }

  function pageUrl() {
    const orderedIds = site.sessions.filter((session) => selected.has(session.slug)).map((session) => session.slug);
    return FP.setUrl(orderedIds, document.getElementById('setName').value.trim());
  }

  function updateSetLink() {
    const count = selected.size;
    document.getElementById('setCount').innerHTML = `<strong>${count}</strong> session${count === 1 ? '' : 's'} selected`;
    const open = document.getElementById('openSet');
    open.disabled = count === 0;
    const linkRow = document.getElementById('setLinkRow');
    linkRow.hidden = count === 0;
    document.getElementById('setLink').value = count ? new URL(pageUrl(), window.location.href).href : '';
  }

  async function copySetLink() {
    const button = document.getElementById('copySetLink');
    try {
      await navigator.clipboard.writeText(document.getElementById('setLink').value);
      button.textContent = 'Copied';
      window.setTimeout(() => { button.textContent = 'Copy link'; }, 1600);
    } catch (e) {
      document.getElementById('setLink').select();
      document.execCommand('copy');
    }
  }

  function renderSetPage(params) {
    document.getElementById('builderSection').hidden = true;
    document.getElementById('setTray').hidden = true;
    const selectedSessions = site.sessions.filter((session) => params.ids.includes(session.slug));
    const title = params.name || 'Curated session set';

    document.title = `${title} · Frontier AI Governance`;
    document.getElementById('setView').hidden = false;
    document.getElementById('setViewHeading').textContent = title;
    document.getElementById('setViewDescription').textContent =
      `${selectedSessions.length} selected session${selectedSessions.length === 1 ? '' : 's'} from the RVAS AI Governance curriculum.`;
    document.getElementById('setSessions').innerHTML = selectedSessions.map((session) => `
      <a href="${sessionUrl(session, params)}" class="session-card reveal" style="--mod-color:${FP.esc(session.accent)}">
        <div class="session-card-head">
          <span class="session-chip">${FP.esc(session.code)}</span>
          <div class="session-card-title">${FP.esc(session.title)}</div>
        </div>
        <p class="session-card-outcome"><span class="session-outcome-label">Durable outcome</span>${FP.esc(session.outcome)}</p>
        <div class="session-card-foot">
          <span class="badge badge-persona">${FP.esc(session.persona)}</span>
          <span class="badge badge-nist">NIST · ${FP.esc(session.nist)}</span>
        </div>
      </a>`).join('') || '<div class="empty">This custom page has no available sessions.</div>';
    FP.initReveal();
    if (window.RVASShell) window.RVASShell.refresh();
  }

  function sessionUrl(session, params) {
    const query = new URLSearchParams();
    query.set('s', session.slug);
    query.set('set', params.ids.join(','));
    if (params.name) query.set('name', params.name);
    return `session.html?${query.toString()}`;
  }

  document.addEventListener('DOMContentLoaded', init);
})();
