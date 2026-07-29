/* AI Governance Platform — home page: stats + session cards from site.json. */
(function () {
  'use strict';

  let allSessions = [];
  let activeService = 'all';

  async function init() {
    let data;
    try {
      const res = await fetch('assets/data/site.json', { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load site data (' + res.status + ')');
      data = await res.json();
    } catch (e) {
      FP.renderError('sessionGrid', e.message);
      return;
    }

    allSessions = data.sessions || [];
    renderStats(allSessions, data.stats || {});
    renderServiceFilter(allSessions);
    applyServiceFilter();
  }

  function renderStats(sessions, stats) {
    const sessionCount = sessions.length || stats.sessions || null;
    const pathRange = getPathRange(sessions);
    const nistCount = countNistFunctions(sessions) || stats.frameworks || null;
    const roleCount = countUnique(sessions.map((s) => s.persona).filter(Boolean)) || stats.personas || null;

    _set('stat-sessions', sessionCount);
    _set('stat-path', pathRange);
    _set('stat-nist', nistCount);
    _set('stat-roles', roleCount);
  }

  function renderServiceFilter(sessions) {
    const container = document.getElementById('serviceFilterOptions');
    if (!container) return;
    const services = serviceCatalog(sessions);
    if (!services.length) {
      container.closest('.service-filter').hidden = true;
      return;
    }

    container.innerHTML = [
      filterButton({ id: 'all', label: 'All tools', icon: null }, sessions.length, true),
      ...services.map((service) => filterButton(service, service.count, false)),
    ].join('');

    container.querySelectorAll('button[data-service]').forEach((button) => {
      button.addEventListener('click', () => {
        activeService = button.dataset.service || 'all';
        applyServiceFilter();
      });
    });
  }

  function filterButton(service, count, active) {
    const icon = service.icon
      ? `<img src="${FP.esc(service.icon)}" alt="" loading="lazy" aria-hidden="true">`
      : '<span class="service-filter-all-mark" aria-hidden="true">All</span>';
    return `<button type="button" class="service-filter-chip"${active ? ' aria-pressed="true"' : ' aria-pressed="false"'} data-service="${FP.esc(service.id)}">` +
      `<span class="service-filter-icon">${icon}</span>` +
      `<span class="service-filter-name">${FP.esc(service.label)}</span>` +
      `<span class="service-filter-total">${count}</span>` +
      `</button>`;
  }

  function applyServiceFilter() {
    const sessions = activeService === 'all'
      ? allSessions
      : allSessions.filter((session) => (session.services || []).some((service) => service.id === activeService));
    document.querySelectorAll('.service-filter-chip').forEach((button) => {
      button.setAttribute('aria-pressed', String((button.dataset.service || 'all') === activeService));
    });
    const count = document.getElementById('serviceFilterCount');
    if (count) {
      count.textContent = activeService === 'all'
        ? `${allSessions.length} sessions`
        : `${sessions.length} matching session${sessions.length === 1 ? '' : 's'}`;
    }
    renderSessionCards(sessions);
  }

  function serviceCatalog(sessions) {
    const map = new Map();
    sessions.forEach((session) => {
      (session.services || []).forEach((service) => {
        if (!map.has(service.id)) map.set(service.id, { ...service, count: 0 });
        map.get(service.id).count += 1;
      });
    });
    return Array.from(map.values()).sort((a, b) => a.label.localeCompare(b.label));
  }

  function renderSessionCards(sessions) {
    const grid = document.getElementById('sessionGrid');
    if (!grid) return;
    if (!sessions.length) {
      grid.innerHTML = '<div class="empty">No sessions match this tool filter.</div>';
      return;
    }

    grid.innerHTML = sessions.map((s) => `
      <a href="session.html?s=${encodeURIComponent(s.slug)}" class="session-card reveal" style="--mod-color:${FP.esc(s.accent)}">
        <div class="session-card-head">
          <span class="session-chip">${FP.esc(s.code)}</span>
          <div class="session-card-title">${FP.esc(s.title)}</div>
        </div>
        <p class="session-card-outcome"><span class="session-outcome-label">${s.optional ? 'Optional extension outcome' : 'Durable outcome'}</span>${FP.esc(s.outcome)}</p>
        <div class="session-card-foot">
          <span class="badge badge-persona">${FP.esc(s.persona)}</span>
          <span class="badge badge-nist">NIST · ${FP.esc(s.nist)}</span>
        </div>
        ${sessionServiceStrip(s)}
      </a>`).join('');

    FP.initReveal();
    if (window.RVASShell) window.RVASShell.refresh();
  }

  function sessionServiceStrip(session) {
    const services = (session.services || []).slice(0, 6);
    if (!services.length) return '';
    return `<div class="session-card-services" aria-label="Microsoft services in scope">` +
      services.map((service) =>
        `<span class="session-card-service" title="${FP.esc(service.label)}">` +
          `<img src="${FP.esc(service.icon)}" alt="${FP.esc(service.label)}" loading="lazy">` +
        `</span>`
      ).join('') +
      `</div>`;
  }

  function _set(id, val) {
    const el = document.getElementById(id);
    if (el && val != null) el.textContent = val;
  }

  function getPathRange(sessions) {
    const codes = sessions.map((s) => s.code).filter(Boolean);
    if (!codes.length) return null;
    return codes.length === 1 ? codes[0] : codes[0] + '-' + codes[codes.length - 1];
  }

  function countNistFunctions(sessions) {
    const known = ['Govern', 'Map', 'Measure', 'Manage'];
    const found = new Set();
    sessions.forEach((session) => {
      known.forEach((fn) => {
        if (String(session.nist || '').includes(fn)) found.add(fn);
      });
    });
    return found.size;
  }

  function countUnique(values) {
    return new Set(values.map((value) => String(value).trim()).filter(Boolean)).size;
  }

  document.addEventListener('DOMContentLoaded', init);
})();
