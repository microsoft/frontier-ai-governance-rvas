/* Frontier AI Governance — home page: stats + session cards from site.json. */
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

    renderStats(data.stats || {});
    renderSessionCards(data.sessions || []);
  }

  function renderStats(stats) {
    _set('stat-sessions', stats.sessions);
    _set('stat-domains', stats.domains);
    _set('stat-frameworks', stats.frameworks);
    _set('stat-personas', stats.personas);
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
        <p class="session-card-outcome"><span class="session-outcome-label">Durable outcome</span>${FP.esc(s.outcome)}</p>
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

  document.addEventListener('DOMContentLoaded', init);
})();
