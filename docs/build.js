#!/usr/bin/env node
/**
 * AI Governance Platform — build step (dependency-free, Node core only).
 *
 * Reads the curriculum Markdown under docs/ (the source of truth), transforms
 * MkDocs-flavoured syntax into the site's runtime Markdown dialect, and emits
 * site-consumable data under docs/assets/data/.
 *
 *   node docs/build.js
 *
 * Outputs:
 *   docs/assets/data/site.json            — sessions + pages catalog + stats
 *   docs/assets/data/pages/<slug>.md      — transformed guide bodies
 *
 * Transforms (MkDocs → runtime dialect consumed by marked + core.js):
 *   - `!!! type "Title"` / `???` admonitions → GitHub-style alert blockquotes
 *   - `=== "Tab"` content tabs            → `#### Tab` sections
 *   - `[^id]` footnotes                   → linked refs + a Sources list
 *   - `mermaid` fences                    → left intact (rendered client-side)
 *   - image / internal `.md` links        → rewritten to the static routes
 *
 * Exits non-zero if a declared source file is missing.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const DOCS = __dirname;
const DATA = path.join(DOCS, 'assets', 'data');
const PAGES_OUT = path.join(DATA, 'pages');
const DECKS_OUT = path.join(DATA, 'decks');

/* ─── Curriculum config (curated metadata, mirrors docs/index.md) ─────────── */

const SITE = {
  name: 'AI Governance Platform',
  tagline: 'A facilitator-led platform for governing enterprise AI agents.',
  lastReviewed: '2026-07-06',
  repo: 'https://github.com/microsoft/frontier-ai-governance-rvas',
};

const SESSIONS = [
  { slug: 's0-foundations', code: 'S0', phase: 'Govern', accent: '#032254', persona: 'Governance lead', nist: 'Govern · Map', outcome: 'Governance baseline and operating-model decision + first backlog', services: ['agent-365', 'copilot-studio', 'microsoft-teams', 'microsoft-purview'] },
  { slug: 's1-identity', code: 'S1', phase: 'Govern', accent: '#1A77E3', persona: 'Identity admin', nist: 'Govern · Map · Manage', outcome: 'Agent identity-path decision + implementation handoff', services: ['microsoft-entra-id', 'microsoft-entra-agent-id', 'microsoft-entra-workload-id', 'agent-365', 'azure-key-vault', 'azure-api-management'] },
  { slug: 's2-data-compliance', code: 'S2', phase: 'Govern', accent: '#14868A', persona: 'Compliance / Data admin', nist: 'Map · Manage', outcome: 'Data-path trace and control-map decision + evidence handoff', services: ['microsoft-purview', 'azure-ai-content-safety', 'sharepoint', 'azure-api-management', 'application-insights'] },
  { slug: 's3-platform-foundation', code: 'S3', phase: 'Establish', accent: '#0F766E', persona: 'Platform owner', nist: 'Govern · Map · Manage', outcome: 'Platform-route readiness decision + implementation work package', services: ['azure-ai-foundry', 'azure-openai', 'azure-ai-search', 'azure-api-management', 'azure-api-center', 'azure-container-apps', 'azure-kubernetes-service', 'log-analytics', 'microsoft-purview'] },
  { slug: 's4-agent-engineering', code: 'S4', phase: 'Establish', accent: '#7C3AED', persona: 'AI developer / maker', nist: 'Govern · Map · Measure', outcome: 'Agent build-path and admission decision + build handoff', services: ['foundry-agent-service', 'copilot-studio', 'microsoft-365-copilot', 'agent-365', 'power-automate', 'azure-api-management', 'application-insights', 'microsoft-purview'] },
  { slug: 's5-tool-api-governance', code: 'S5', phase: 'Establish', accent: '#C2410C', persona: 'Platform owner', nist: 'Govern · Map · Manage', outcome: 'Tool/API admission and withdrawal decision + controlled handoff', services: ['azure-api-management', 'azure-api-center', 'microsoft-entra-id', 'azure-ai-content-safety', 'copilot-studio', 'azure-policy', 'microsoft-purview'] },
  { slug: 's6-security-runtime', code: 'S6', phase: 'Assure', accent: '#DC2626', persona: 'Security / SOC', nist: 'Measure · Manage', outcome: 'Runtime-path evidence and response decision + acceptance package', services: ['microsoft-defender-for-cloud', 'microsoft-defender-xdr', 'microsoft-sentinel', 'azure-api-management', 'azure-monitor', 'application-insights', 'azure-ai-content-safety', 'microsoft-purview'] },
  { slug: 's7-evaluation', code: 'S7', phase: 'Assure', accent: '#504092', persona: 'AI developer / maker', nist: 'Measure · Manage', outcome: 'Evaluation evidence and release-readiness decision + evidence package', services: ['azure-ai-foundry', 'azure-ai-content-safety', 'azure-load-testing', 'application-insights', 'azure-monitor', 'microsoft-teams', 'microsoft-purview'] },
  { slug: 's8-red-teaming', code: 'S8', phase: 'Assure', accent: '#EA580C', persona: 'Security / SOC', nist: 'Govern · Measure · Manage', outcome: 'Authorized red-team finding and retest decision + remediation handoff', services: ['microsoft-defender-for-cloud', 'microsoft-defender-xdr', 'microsoft-sentinel', 'azure-ai-foundry', 'azure-ai-content-safety'] },
  { slug: 's9-control-plane', code: 'S9', phase: 'Operate', accent: '#0078D4', persona: 'Governance lead', nist: 'Govern · Map · Manage', outcome: 'Control-plane reconciliation and lifecycle decision + cadence', services: ['microsoft-entra-id', 'microsoft-entra-agent-id', 'azure-ai-foundry', 'azure-api-management', 'azure-api-center', 'azure-monitor', 'application-insights', 'microsoft-teams', 'microsoft-purview'] },
  { slug: 's10-operate-measure', code: 'S10', phase: 'Operate', accent: '#7C3AED', persona: 'Governance lead', nist: 'Govern · Measure · Manage', outcome: 'Operating evidence and FinOps decision + remediation handoff', services: ['microsoft-defender-for-cloud', 'azure-ai-foundry', 'azure-monitor', 'log-analytics', 'application-insights', 'azure-cost-management', 'microsoft-purview'] },
  { slug: 's11-llm-operations', code: 'S11', phase: 'Operate', accent: '#2563EB', persona: 'LLMOps owner', nist: 'Govern · Map · Measure · Manage', outcome: 'LLMOps change-control decision + implementation backlog', services: ['azure-ai-foundry', 'azure-api-management', 'azure-monitor', 'log-analytics', 'application-insights', 'microsoft-teams'] },
  { slug: 's12-portfolio-governance', code: 'S12', phase: 'Operate', accent: '#475569', persona: 'Executive sponsor', nist: 'Govern · Map · Measure · Manage', outcome: 'Portfolio evidence and roadmap decision + dated governance backlog', services: ['agent-365', 'azure-ai-foundry', 'azure-api-center', 'azure-monitor', 'application-insights', 'azure-cost-management', 'microsoft-teams', 'microsoft-purview'] },
];

const SESSION_CHAPTERS = [
  {
    slug: 'prepare',
    label: 'Prepare',
    heading: /^(?:1\. Outcome|2\. Prerequisites|3\. Why|4\. (?:Customer-owned )?(?:Rollback|Change boundary))/i,
  },
  { slug: 'concepts', label: 'Concepts', standalone: true },
  { slug: 'technical', label: 'Technical decisions', standalone: true, optional: true },
  { slug: 'co-deliver', label: 'Practical workshop', standalone: true },
];

const SERVICE_ICONS = {
  'agent-365': { label: 'Microsoft Agent 365', category: 'Agent governance', icon: 'assets/img/microsoft-icons/agent-365.svg' },
  'application-insights': { label: 'Application Insights', category: 'Telemetry', icon: 'assets/img/microsoft-icons/application-insights.svg' },
  'azure-ai-content-safety': { label: 'Azure AI Content Safety', category: 'AI safety', icon: 'assets/img/microsoft-icons/azure-ai-content-safety.svg' },
  'azure-ai-foundry': { label: 'Microsoft Foundry', category: 'AI platform', icon: 'assets/img/microsoft-icons/azure-ai-foundry.svg' },
  'azure-ai-search': { label: 'Azure AI Search', category: 'Retrieval', icon: 'assets/img/microsoft-icons/azure-ai-search.svg' },
  'azure-api-center': { label: 'Azure API Center', category: 'API catalog', icon: 'assets/img/microsoft-icons/azure-api-center.svg' },
  'azure-api-management': { label: 'Azure API Management', category: 'Gateway', icon: 'assets/img/microsoft-icons/azure-api-management.svg' },
  'azure-container-apps': { label: 'Azure Container Apps', category: 'Runtime', icon: 'assets/img/microsoft-icons/azure-container-apps.svg' },
  'azure-cost-management': { label: 'Azure Cost Management', category: 'FinOps', icon: 'assets/img/microsoft-icons/azure-cost-management.svg' },
  'azure-key-vault': { label: 'Azure Key Vault', category: 'Secrets', icon: 'assets/img/microsoft-icons/azure-key-vault.svg' },
  'azure-kubernetes-service': { label: 'Azure Kubernetes Service', category: 'Runtime', icon: 'assets/img/microsoft-icons/azure-kubernetes-service.svg' },
  'azure-logic-apps': { label: 'Azure Logic Apps', category: 'Workflow', icon: 'assets/img/microsoft-icons/azure-logic-apps.svg' },
  'azure-load-testing': { label: 'Azure Load Testing', category: 'Performance', icon: 'assets/img/microsoft-icons/azure-load-testing.svg' },
  'azure-monitor': { label: 'Azure Monitor', category: 'Observability', icon: 'assets/img/microsoft-icons/azure-monitor.svg' },
  'azure-openai': { label: 'Azure OpenAI', category: 'Model service', icon: 'assets/img/microsoft-icons/azure-openai.svg' },
  'azure-policy': { label: 'Azure Policy', category: 'Governance', icon: 'assets/img/microsoft-icons/azure-policy.svg' },
  'copilot-studio': { label: 'Microsoft Copilot Studio', category: 'Agent builder', icon: 'assets/img/microsoft-icons/copilot-studio.svg' },
  'foundry-agent-service': { label: 'Foundry Agent Service', category: 'Agent runtime', icon: 'assets/img/microsoft-icons/foundry-agent-service.svg' },
  'log-analytics': { label: 'Log Analytics', category: 'Observability', icon: 'assets/img/microsoft-icons/log-analytics.svg' },
  'microsoft-365-copilot': { label: 'Microsoft 365 Copilot', category: 'Copilot', icon: 'assets/img/microsoft-icons/microsoft-365-copilot.svg' },
  'microsoft-defender-for-cloud': { label: 'Microsoft Defender for Cloud', category: 'Security', icon: 'assets/img/microsoft-icons/microsoft-defender-for-cloud.svg' },
  'microsoft-defender-xdr': { label: 'Microsoft Defender XDR', category: 'Security', icon: 'assets/img/microsoft-icons/microsoft-defender-xdr.svg' },
  'microsoft-entra-agent-id': { label: 'Microsoft Entra Agent ID', category: 'Agent identity', icon: 'assets/img/microsoft-icons/microsoft-entra-agent-id.svg' },
  'microsoft-entra-id': { label: 'Microsoft Entra ID', category: 'Identity', icon: 'assets/img/microsoft-icons/microsoft-entra-id.svg' },
  'microsoft-entra-workload-id': { label: 'Microsoft Entra Workload ID', category: 'Workload identity', icon: 'assets/img/microsoft-icons/microsoft-entra-workload-id.svg' },
  'microsoft-purview': { label: 'Microsoft Purview', category: 'Data governance', icon: 'assets/img/microsoft-icons/microsoft-purview.svg' },
  'microsoft-sentinel': { label: 'Microsoft Sentinel', category: 'SIEM', icon: 'assets/img/microsoft-icons/microsoft-sentinel.svg' },
  'microsoft-teams': { label: 'Microsoft Teams', category: 'Collaboration', icon: 'assets/img/microsoft-icons/microsoft-teams.svg' },
  'power-automate': { label: 'Power Automate', category: 'Workflow', icon: 'assets/img/microsoft-icons/power-automate.svg' },
  'power-platform': { label: 'Microsoft Power Platform', category: 'Business apps', icon: 'assets/img/microsoft-icons/power-platform.svg' },
  'sharepoint': { label: 'SharePoint', category: 'Content', icon: 'assets/img/microsoft-icons/sharepoint.svg' },
};

const PAGES = [
  { slug: 'start-understand-rvas',        src: 'start/understand-rvas.md',    title: 'About AI Governance Platform', nav: true, group: 'Start here' },
  { slug: 'start-customer-journey',       src: 'start/customer-journey.md',   title: 'What customers get',         nav: true, group: 'Start here' },
  { slug: 'start-plan-engagement',        src: 'start/plan-engagement.md',    title: 'Plan the engagement',       nav: true, group: 'Start here' },
  { slug: 'how-to-deliver',               src: 'how-to-deliver.md',            title: 'How to deliver',            nav: true, group: 'Delivery' },
  { slug: 'delivery-session-readiness',   src: 'delivery/session-readiness.md', title: 'Check whether a session is ready', nav: true, group: 'Delivery' },
  { slug: 'delivery-facilitation-pattern', src: 'delivery/facilitation-pattern.md', title: 'Facilitate a working session', nav: true, group: 'Delivery' },
  { slug: 'assessment',                   src: 'assessment/index.md',          title: 'Readiness Assessment',      nav: true,  group: null },
  { slug: 'platform-citadel-installation', src: 'delivery/platform-foundation/installation-work-package.md', title: 'Install Citadel platform', nav: true, group: 'Platform foundation' },
  { slug: 'platform-citadel-intake', src: 'delivery/platform-foundation/intake.md', title: 'Platform intake', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-raci', src: 'delivery/platform-foundation/raci.md', title: 'Platform RACI', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-accelerator-handoff', src: 'delivery/platform-foundation/accelerator-handoff.md', title: 'Accelerator handoff', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-gateway-acceptance', src: 'delivery/platform-foundation/non-production-gateway-acceptance.md', title: 'Non-production gateway acceptance', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-gateway-evidence', src: 'delivery/platform-foundation/gateway-evidence-manifest.md', title: 'Gateway evidence manifest', nav: false, group: 'Platform foundation' },
  { slug: 'reference-platform-technical', src: 'reference/platform-technical-guide.md', title: 'Platform technical guide', nav: true, group: 'Reference' },
  { slug: 'reference-governance-capabilities', src: 'reference/governance-capability-guide.md', title: 'Governance capability guide', nav: true, group: 'Reference' },
  { slug: 'reference-nist-session-map', src: 'reference/nist-ai-rmf-session-map.md', title: 'NIST AI RMF session map', nav: true, group: 'Reference' },
  { slug: 'reference-ai-governance-map', src: 'reference/ai-governance-reference-map.md', title: 'Microsoft AI governance reference map', nav: true, group: 'Reference' },
  { slug: 'reference-microsoft-platform-governance-playbook', src: 'reference/microsoft-platform-governance-playbook.md', title: 'Microsoft platform governance playbook', nav: true, group: 'Reference' },
  { slug: 'reference-quality-cost-latency', src: 'reference/quality-cost-latency-guide.md', title: 'Quality, cost, latency, and rollout governance', nav: true, group: 'Reference' },
  { slug: 'reference-performance-testing', src: 'reference/performance-testing-guide.md', title: 'Agent performance-testing governance', nav: true, group: 'Reference' },
];

/* ─── Link routing map (docs-relative path → static route) ────────────────── */

const ROUTES = {
  'index.md': 'index.html',
  'start/understand-rvas.md': 'page.html?p=start-understand-rvas',
  'start/customer-journey.md': 'page.html?p=start-customer-journey',
  'start/plan-engagement.md': 'page.html?p=start-plan-engagement',
  'how-to-deliver.md': 'page.html?p=how-to-deliver',
  'delivery/session-readiness.md': 'page.html?p=delivery-session-readiness',
  'delivery/facilitation-pattern.md': 'page.html?p=delivery-facilitation-pattern',
  'assessment/index.md': 'page.html?p=assessment',
  'delivery/platform-foundation/installation-work-package.md': 'page.html?p=platform-citadel-installation',
  'delivery/platform-foundation/intake.md': 'page.html?p=platform-citadel-intake',
  'delivery/platform-foundation/raci.md': 'page.html?p=platform-citadel-raci',
  'delivery/platform-foundation/accelerator-handoff.md': 'page.html?p=platform-citadel-accelerator-handoff',
  'delivery/platform-foundation/non-production-gateway-acceptance.md': 'page.html?p=platform-citadel-gateway-acceptance',
  'delivery/platform-foundation/gateway-evidence-manifest.md': 'page.html?p=platform-citadel-gateway-evidence',
  'reference/platform-technical-guide.md': 'page.html?p=reference-platform-technical',
  'reference/governance-capability-guide.md': 'page.html?p=reference-governance-capabilities',
  'reference/nist-ai-rmf-session-map.md': 'page.html?p=reference-nist-session-map',
  'reference/ai-governance-reference-map.md': 'page.html?p=reference-ai-governance-map',
  'reference/microsoft-platform-governance-playbook.md': 'page.html?p=reference-microsoft-platform-governance-playbook',
  'reference/quality-cost-latency-guide.md': 'page.html?p=reference-quality-cost-latency',
  'reference/performance-testing-guide.md': 'page.html?p=reference-performance-testing',
};
SESSIONS.forEach((s) => {
  ROUTES[`${s.slug}/index.md`] = `session.html?s=${s.slug}`;
  ROUTES[`${s.slug}/concepts.md`] = `session.html?s=${s.slug}&chapter=concepts`;
  ROUTES[`${s.slug}/technical.md`] = `session.html?s=${s.slug}&chapter=technical`;
  ROUTES[`${s.slug}/practical.md`] = `session.html?s=${s.slug}&chapter=co-deliver`;
});

const ADMONITION_MAP = {
  info: 'NOTE', note: 'NOTE', abstract: 'NOTE', summary: 'NOTE', example: 'NOTE', quote: 'NOTE',
  tip: 'TIP', hint: 'TIP', success: 'TIP', check: 'TIP',
  question: 'IMPORTANT', help: 'IMPORTANT', faq: 'IMPORTANT',
  warning: 'WARNING', caution: 'WARNING', attention: 'WARNING',
  danger: 'CAUTION', error: 'CAUTION', failure: 'CAUTION', bug: 'CAUTION',
};

const unresolvedMdLinks = [];
const serviceIconErrors = [];

function resolveSessionServices(serviceIds, sessionSlug) {
  if (!Array.isArray(serviceIds) || !serviceIds.length) return [];
  const seen = new Set();
  return serviceIds
    .filter((id) => {
      if (!seen.has(id)) { seen.add(id); return true; }
      serviceIconErrors.push(`docs/build.js:${sessionSlug}: duplicate service id "${id}"`);
      return false;
    })
    .map((id) => {
      const service = SERVICE_ICONS[id];
      if (!service) {
        serviceIconErrors.push(`docs/build.js:${sessionSlug}: unknown service id "${id}"`);
        return null;
      }
      if (!fs.existsSync(path.join(DOCS, service.icon))) {
        serviceIconErrors.push(`docs/build.js:${sessionSlug}: missing icon for "${id}" at docs/${service.icon}`);
        return null;
      }
      return { id, ...service };
    })
    .filter(Boolean);
}

/* ─── Transform helpers ──────────────────────────────────────────────────── */

// Remove a leading run of exactly 4 spaces (one indent level).
function dedent(line) {
  return line.startsWith('    ') ? line.slice(4) : line.replace(/^\t/, '');
}

const ADMONITION_RE = /^(?:!!!|\?\?\?\+?)\s+([a-zA-Z][\w-]*)(?:\s+"([^"]*)")?\s*$/;
const TAB_RE = /^===\s+"([^"]*)"\s*$/;

// Collect the indented body block that follows an admonition / tab marker.
function collectBlock(lines, start) {
  const body = [];
  let i = start;
  while (i < lines.length) {
    const ln = lines[i];
    if (ln.trim() === '') { body.push(''); i++; continue; }
    if (/^(\s{4}|\t)/.test(ln)) { body.push(dedent(ln)); i++; continue; }
    break;
  }
  // Trim trailing blank lines.
  while (body.length && body[body.length - 1] === '') body.pop();
  return { body, next: i };
}

function transformBlocks(md) {
  const lines = md.split('\n');
  const out = [];
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    const adm = line.match(ADMONITION_RE);
    const tab = line.match(TAB_RE);

    if (adm) {
      const type = ADMONITION_MAP[adm[1].toLowerCase()] || 'NOTE';
      const title = (adm[2] || '').trim();
      const { body, next } = collectBlock(lines, i + 1);
      out.push(title ? `> [!${type}] **${title}**` : `> [!${type}]`);
      out.push('>');
      body.forEach((b) => out.push(b === '' ? '>' : `> ${b}`));
      out.push('');
      i = next;
      continue;
    }

    if (tab) {
      const title = tab[1].trim();
      const { body, next } = collectBlock(lines, i + 1);
      out.push(`#### ${title}`);
      out.push('');
      body.forEach((b) => out.push(b));
      out.push('');
      i = next;
      continue;
    }

    out.push(line);
    i++;
  }
  return out.join('\n');
}

function transformFootnotes(md) {
  const lines = md.split('\n');
  const defs = [];
  const kept = [];
  const defRe = /^\[\^([^\]]+)\]:\s*(.*)$/;
  for (const ln of lines) {
    const m = ln.match(defRe);
    if (m) defs.push({ id: m[1], text: m[2].trim() });
    else kept.push(ln);
  }
  let body = kept.join('\n');
  if (!defs.length) return body;

  const order = defs.map((d) => d.id);
  const num = (id) => order.indexOf(id) + 1;
  const safeId = (id) => String(id).toLowerCase()
    .replace(/[^a-z0-9_-]+/g, '-')
    .replace(/^-+|-+$/g, '') || 'source';
  const refCounts = new Map();
  const firstRefs = new Map();

  // Replace inline references [^id] (not definitions, already removed).
  body = body.replace(/\[\^([^\]]+)\]/g, (whole, id) => {
    const n = num(id);
    if (n < 1) return whole;
    const sourceId = `fn-${safeId(id)}`;
    const count = (refCounts.get(id) || 0) + 1;
    refCounts.set(id, count);
    const refId = `fnref-${safeId(id)}-${count}`;
    if (!firstRefs.has(id)) firstRefs.set(id, refId);
    return `<sup class="fn-ref" id="${refId}"><a href="#${sourceId}" aria-label="Source ${n}">[${n}]</a></sup>`;
  });

  const sources = defs.map((d, idx) => {
    const sourceId = `fn-${safeId(d.id)}`;
    const backRef = firstRefs.get(d.id);
    const backLink = backRef ? ` [↩](#${backRef})` : '';
    return `${idx + 1}. <span id="${sourceId}"></span>${d.text}${backLink}`;
  }).join('\n');
  body += `\n\n## Sources\n\n${sources}\n`;
  return body;
}

function rewriteImages(md) {
  return md.replace(/\]\((?:\.\.\/)*assets\/diagrams\//g, '](assets/diagrams/');
}

function rewriteLinks(md, srcRelPath) {
  const srcDir = path.posix.dirname(srcRelPath.split(path.sep).join('/'));
  return md.replace(/\]\(([^)]+)\)/g, (whole, target) => {
    const trimmed = target.trim();
    if (/^(https?:|mailto:|#|\/)/i.test(trimmed)) return whole;
    if (!trimmed.includes('.md')) return whole;
    const [rawPath, anchor] = trimmed.split('#');
    const resolved = path.posix.normalize(path.posix.join(srcDir === '.' ? '' : srcDir, rawPath));
    const route = ROUTES[resolved];
    if (!route) {
      unresolvedMdLinks.push({ source: srcRelPath, target: trimmed, resolved });
      return whole;
    }
    return `](${route}${anchor ? '#' + anchor : ''})`;
  });
}

// Strip the leading `# Title` line; return { title, body }.
function extractTitle(md) {
  const lines = md.split('\n');
  let title = '';
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^#\s+(.*)$/);
    if (m) {
      title = m[1].trim();
      lines.splice(i, 1);
      // drop a single trailing blank line left behind
      if (lines[i] !== undefined && lines[i].trim() === '') lines.splice(i, 1);
      break;
    }
    if (lines[i].trim() !== '') break; // content before H1 → keep as-is
  }
  return { title, body: lines.join('\n') };
}

const FRESHNESS_RE = /^(?:!!!|\?\?\?\+?)\s+[a-zA-Z][\w-]*\s+"Freshness"\s*$/i;

// Pull the "Freshness" admonition out of the body so it doesn't render as a
// prominent top-of-page alert. Returns the review date and any trailing note
// (kept as Markdown, links rewritten), plus the body with the block removed.
function extractFreshness(md, srcRelPath) {
  const lines = md.split('\n');
  for (let i = 0; i < lines.length; i++) {
    if (!FRESHNESS_RE.test(lines[i])) continue;
    const { body, next } = collectBlock(lines, i + 1);
    let end = next;
    if (lines[end] !== undefined && lines[end].trim() === '') end++;
    lines.splice(i, end - i);

    const text = body.join(' ').replace(/\s+/g, ' ').trim();
    const dateM = text.match(/(\d{4}-\d{2}-\d{2})/);
    const reviewed = dateM ? dateM[1] : '';
    let note = dateM ? text.slice(dateM.index + dateM[0].length) : text;
    note = note
      .replace(/\*\*Last reviewed:\*\*/i, '')
      .replace(/^\s*[·|,\-–—]\s*/, '')
      .trim();
    if (note) note = rewriteLinks(note, srcRelPath);
    return { reviewed, reviewedNote: note, body: lines.join('\n') };
  }
  return { reviewed: '', reviewedNote: '', body: md };
}

function transform(raw, srcRelPath) {
  const { title, body } = extractTitle(raw);
  const { reviewed, reviewedNote, body: withoutFreshness } = extractFreshness(body, srcRelPath);
  let md = withoutFreshness;
  md = transformBlocks(md);
  md = transformFootnotes(md);
  md = rewriteImages(md);
  md = rewriteLinks(md, srcRelPath);
  md = md.replace(/\n{3,}/g, '\n\n').trim() + '\n';
  return { title, md, hasMermaid: /```mermaid/.test(md), reviewed, reviewedNote };
}

function splitRunbookChapters(md, sessionSlug) {
  const matches = [...md.matchAll(/^##\s+(.+)$/gm)];
  const prefix = matches.length ? md.slice(0, matches[0].index).trim() : '';
  const sections = matches.map((match, index) => ({
    heading: match[1].trim(),
    body: md.slice(match.index, matches[index + 1]?.index).trim(),
  }));

  return SESSION_CHAPTERS.filter((chapter) => !chapter.standalone).map((chapter) => {
    const body = sections
      .filter((section) => chapter.heading.test(section.heading))
      .map((section) => section.body);
    if (chapter.slug === 'prepare' && prefix) body.unshift(prefix);
    if (!body.length) {
      throw new Error(`Could not build ${chapter.slug} chapter for ${sessionSlug}.`);
    }
    return { ...chapter, md: `${body.join('\n\n')}\n` };
  });
}

/* ─── Search index helpers ───────────────────────────────────────────────── */

const SEARCH_TEXT_CAP = 4000;

// Reduce runtime-dialect Markdown to plain, searchable text.
function toPlainText(md) {
  let s = String(md == null ? '' : md);
  s = s.replace(/```[\s\S]*?```/g, ' ');           // fenced code / mermaid
  s = s.replace(/`([^`]*)`/g, '$1');                // inline code
  s = s.replace(/<sup class="fn-ref"[\s\S]*?<\/sup>/g, ' '); // footnote refs
  s = s.replace(/<[^>]+>/g, ' ');                   // any remaining HTML tags
  s = s.replace(/!\[[^\]]*\]\([^)]*\)/g, ' ');      // images
  s = s.replace(/\[([^\]]*)\]\([^)]*\)/g, '$1');    // links → link text
  s = s.replace(/^>\s?/gm, ' ');                    // blockquote / alert markers
  s = s.replace(/^\s{0,3}#{1,6}\s+/gm, '');         // heading markers
  s = s.replace(/^\s*[-*+]\s+/gm, ' ');             // list bullets
  s = s.replace(/^\s*\d+\.\s+/gm, ' ');             // ordered list markers
  s = s.replace(/^\s*\|.*$/gm, (row) => row.replace(/\|/g, ' ')); // tables
  s = s.replace(/[*~]{1,3}/g, '');                  // emphasis punctuation; keep underscores in code paths
  s = s.replace(/\[\^[^\]]+\]/g, ' ');              // stray footnote refs
  s = s.replace(/\s+/g, ' ').trim();
  return s.length > SEARCH_TEXT_CAP ? s.slice(0, SEARCH_TEXT_CAP) : s;
}

/* ─── Build ──────────────────────────────────────────────────────────────── */

function read(rel) {
  const abs = path.join(DOCS, rel);
  if (!fs.existsSync(abs)) {
    console.error(`✖ Missing source file: docs/${rel}`);
    process.exitCode = 1;
    return null;
  }
  return fs.readFileSync(abs, 'utf8');
}

function readOptional(rel) {
  const abs = path.join(DOCS, rel);
  return fs.existsSync(abs) ? fs.readFileSync(abs, 'utf8') : null;
}

function main() {
  fs.rmSync(PAGES_OUT, { recursive: true, force: true });
  fs.mkdirSync(PAGES_OUT, { recursive: true });
  fs.rmSync(DECKS_OUT, { recursive: true, force: true });
  fs.mkdirSync(DECKS_OUT, { recursive: true });

  const sessionMeta = [];
  const searchDocs = [];
  for (const s of SESSIONS) {
    const rel = `${s.slug}/index.md`;
    const conceptsRel = `${s.slug}/concepts.md`;
    const [raw, conceptsRaw] = [read(rel), read(conceptsRel)];
    if (raw == null || conceptsRaw == null) continue;
    const { title, md, hasMermaid, reviewed, reviewedNote } = transform(raw, rel);
    const concepts = transform(conceptsRaw, conceptsRel);
    const clean = title.replace(/^S\d+\s*·\s*/, '').trim() || title;
    const chapters = splitRunbookChapters(md, s.slug);
    chapters.forEach((chapter) => {
      fs.writeFileSync(path.join(PAGES_OUT, `${s.slug}-${chapter.slug}.md`), chapter.md);
      searchDocs.push({
        id: `${s.slug}-${chapter.slug}`,
        type: 'session',
        title: `${s.code} · ${clean}`,
        section: chapter.label,
        session: s.code,
        url: `session.html?s=${s.slug}&chapter=${chapter.slug}`,
        text: toPlainText(chapter.md),
      });
    });
    fs.writeFileSync(path.join(PAGES_OUT, `${s.slug}-concepts.md`), concepts.md);
    searchDocs.push({
      id: `${s.slug}-concepts`,
      type: 'session',
      title: `${s.code} · ${clean}`,
      section: 'Concepts',
      session: s.code,
      url: `session.html?s=${s.slug}&chapter=concepts`,
      text: toPlainText(concepts.md),
    });
    const technicalRaw = readOptional(`${s.slug}/technical.md`);
    const technical = technicalRaw == null ? null : transform(technicalRaw, `${s.slug}/technical.md`);
    if (technical) {
      fs.writeFileSync(path.join(PAGES_OUT, `${s.slug}-technical.md`), technical.md);
      searchDocs.push({
        id: `${s.slug}-technical`,
        type: 'session',
        title: `${s.code} · ${clean}`,
        section: 'Technical decisions',
        session: s.code,
        url: `session.html?s=${s.slug}&chapter=technical`,
        text: toPlainText(technical.md),
      });
    }
    const practicalRaw = readOptional(`${s.slug}/practical.md`);
    if (practicalRaw == null) {
      console.error(`✖ Missing practical activity: docs/${s.slug}/practical.md`);
      process.exitCode = 1;
      continue;
    }
    const practical = transform(practicalRaw, `${s.slug}/practical.md`);
    fs.writeFileSync(path.join(PAGES_OUT, `${s.slug}-co-deliver.md`), practical.md);
    searchDocs.push({
      id: `${s.slug}-co-deliver`,
      type: 'session',
      title: `${s.code} · ${clean}`,
      section: 'Practical workshop',
      session: s.code,
      url: `session.html?s=${s.slug}&chapter=co-deliver`,
      text: toPlainText(practical.md),
    });
    const chapterMeta = SESSION_CHAPTERS
      .filter((chapter) => chapter.slug !== 'technical' || technical)
      .map(({ slug, label }) => ({ slug, label }));
    const deckRaw = readOptional(`${s.slug}/deck.md`);
    const hasDeck = deckRaw != null;
    if (hasDeck) {
      // Decks are authored directly in reveal.js Markdown (slides split on `---`),
      // so they bypass the MkDocs transforms — only image paths are rewritten to
      // resolve from the site root (same convention as page bodies).
      fs.writeFileSync(path.join(DECKS_OUT, `${s.slug}.md`), rewriteImages(deckRaw));
    }
    sessionMeta.push({
      slug: s.slug, code: s.code, title: clean, fullTitle: title || `${s.code} · ${clean}`,
      accent: s.accent, persona: s.persona, nist: s.nist, outcome: s.outcome, optional: Boolean(s.optional),
      hasMermaid: hasMermaid || concepts.hasMermaid || practical.hasMermaid || Boolean(technical && technical.hasMermaid),
      hasDeck,
      services: resolveSessionServices(s.services, s.slug),
      chapters: chapterMeta,
      reviewed, reviewedNote, conceptsTitle: concepts.title || `${s.code} · ${clean} Concepts`,
      conceptsHasMermaid: concepts.hasMermaid, conceptsReviewed: concepts.reviewed || reviewed,
      conceptsReviewedNote: concepts.reviewedNote,
      technicalTitle: technical ? (technical.title || `${s.code} · ${clean} Technical decisions`) : undefined,
      technicalReviewed: technical ? (technical.reviewed || reviewed) : undefined,
      technicalReviewedNote: technical ? technical.reviewedNote : undefined,
    });
  }

  const pageMeta = [];
  for (const p of PAGES) {
    const raw = read(p.src);
    if (raw == null) continue;
    const { title, md, hasMermaid, reviewed, reviewedNote } = transform(raw, p.src);
    fs.writeFileSync(path.join(PAGES_OUT, `${p.slug}.md`), md);
    pageMeta.push({ slug: p.slug, title: title || p.title, nav: p.nav, group: p.group, hasMermaid, reviewed, reviewedNote });
    searchDocs.push({
      id: p.slug,
      type: 'page',
      title: title || p.title,
      section: p.group || '',
      url: `page.html?p=${p.slug}`,
      text: toPlainText(md),
    });
  }

  const site = {
    meta: SITE,
    stats: {
      sessions: sessionMeta.filter((session) => !session.optional).length,
      optionalSessions: sessionMeta.filter((session) => session.optional).length,
      domains: sessionMeta.filter((session) => !session.optional).length,
      frameworks: 3,
      personas: 5,
    },
    sessions: sessionMeta,
    pages: pageMeta,
    builtAt: new Date().toISOString(),
  };
  fs.writeFileSync(path.join(DATA, 'site.json'), JSON.stringify(site, null, 2));

  fs.writeFileSync(
    path.join(DATA, 'search-index.json'),
    JSON.stringify({ builtAt: site.builtAt, docs: searchDocs }, null, 2)
  );

  if (unresolvedMdLinks.length) {
    console.error('✖ Unresolved local Markdown links:');
    unresolvedMdLinks.forEach((link) => {
      console.error(`  docs/${link.source}: ${link.target} → ${link.resolved}`);
    });
    process.exitCode = 1;
  }

  if (serviceIconErrors.length) {
    console.error('✖ Service icon metadata errors:');
    serviceIconErrors.forEach((message) => console.error(`  ${message}`));
    process.exitCode = 1;
  }

  if (process.exitCode) {
    console.error('✖ Build completed with errors (see above).');
    return;
  }
  console.log(`✓ Built ${sessionMeta.length} sessions + ${pageMeta.length} pages → docs/assets/data/ (search index: ${searchDocs.length} docs)`);
}

main();
