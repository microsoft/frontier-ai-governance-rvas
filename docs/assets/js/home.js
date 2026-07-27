/* AI Governance Platform — home page: stats + session cards from site.json. */
(function () {
  'use strict';

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

    renderStats(data.sessions || [], data.stats || {});
    renderSessionCards(data.sessions || []);
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

  function renderSessionCards(sessions) {
    const grid = document.getElementById('sessionGrid');
    if (!grid) return;
    if (!sessions.length) {
      grid.innerHTML = '<div class="empty">No sessions configured.</div>';
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
      </a>`).join('');

    FP.initReveal();
    if (window.RVASShell) window.RVASShell.refresh();
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
