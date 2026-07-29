/* AI Governance Platform — Microsoft service to session map. */
(function () {
  'use strict';

  let rows = [];

  async function init() {
    const body = document.getElementById('serviceMapBody');
    try {
      const res = await fetch('assets/data/site.json', { cache: 'no-cache' });
      if (!res.ok) throw new Error('Could not load site data (' + res.status + ')');
      const data = await res.json();
      rows = buildRows(data.sessions || []);
      renderRows(rows);
      bindSearch();
    } catch (e) {
      if (body) body.innerHTML = `<tr><td colspan="3">${FP.esc(e.message)}</td></tr>`;
    }
  }

  function buildRows(sessions) {
    const map = new Map();
    sessions.forEach((session) => {
      (session.services || []).forEach((service) => {
        if (!map.has(service.id)) {
          map.set(service.id, {
            ...service,
            sessions: [],
            search: '',
          });
        }
        map.get(service.id).sessions.push(session);
      });
    });
    return Array.from(map.values())
      .map((row) => ({
        ...row,
        search: [
          row.label,
          row.category,
          ...row.sessions.flatMap((session) => [session.code, session.title, session.persona, session.nist]),
        ].join(' ').toLowerCase(),
      }))
      .sort((a, b) => a.label.localeCompare(b.label));
  }

  function bindSearch() {
    const input = document.getElementById('serviceMapSearch');
    if (!input) return;
    input.addEventListener('input', () => {
      const query = input.value.trim().toLowerCase();
      renderRows(query ? rows.filter((row) => row.search.includes(query)) : rows);
    });
  }

  function renderRows(serviceRows) {
    const body = document.getElementById('serviceMapBody');
    if (!body) return;
    if (!serviceRows.length) {
      body.innerHTML = '<tr><td colspan="3">No services match this search.</td></tr>';
      return;
    }
    body.innerHTML = serviceRows.map((service) => `
      <tr>
        <th scope="row">
          <span class="service-map-service">
            <span class="service-icon-mark" aria-hidden="true"><img src="${FP.esc(service.icon)}" alt="" loading="lazy"></span>
            <span>${FP.esc(service.label)}</span>
          </span>
        </th>
        <td><span class="service-icon-category">${FP.esc(service.category)}</span></td>
        <td>
          <div class="service-map-session-list">
            ${service.sessions.map((session) => `
              <a class="service-map-session" href="session.html?s=${encodeURIComponent(session.slug)}">
                <span class="session-chip" style="--mod-color:${FP.esc(session.accent)}">${FP.esc(session.code)}</span>
                <span>
                  <strong>${FP.esc(session.title)}</strong>
                  <small>${FP.esc(session.persona)} · NIST ${FP.esc(session.nist)}</small>
                </span>
              </a>`).join('')}
          </div>
        </td>
      </tr>
    `).join('');
  }

  document.addEventListener('DOMContentLoaded', init);
})();
