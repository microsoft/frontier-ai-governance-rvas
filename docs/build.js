#!/usr/bin/env node
/**
 * Frontier AI Governance — build step (dependency-free, Node core only).
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

/* ─── Curriculum config (curated metadata, mirrors docs/index.md) ─────────── */

const SITE = {
  name: 'Frontier AI Governance',
  tagline: 'Governing AI agents in your tenant, session by session.',
  lastReviewed: '2026-07-06',
  repo: 'https://github.com/microsoft/frontier-ai-governance-rvas',
};

const SESSIONS = [
  { slug: 's0-foundations',      code: 'S0', accent: '#032254', persona: 'Governance lead',        nist: 'Govern',            outcome: 'Baseline maturity assessment + prioritized roadmap' },
  { slug: 's1-identity',         code: 'S1', accent: '#1A77E3', persona: 'Identity admin',         nist: 'Govern · Manage',   outcome: 'Entra Agent ID blueprints + Conditional Access + ID Protection' },
  { slug: 's2-data-compliance',  code: 'S2', accent: '#14868A', persona: 'Compliance / Data admin', nist: 'Map · Manage',     outcome: 'Purview DSPM for AI + DLP + IRM + audit' },
  { slug: 's3-security-runtime', code: 'S3', accent: '#DC2626', persona: 'Security / SOC',         nist: 'Measure · Manage',  outcome: 'Defender AI-SPM + threat protection + Content Safety' },
  { slug: 's4-evaluation',       code: 'S4', accent: '#504092', persona: 'AI developer / maker',   nist: 'Measure',           outcome: 'Foundry evaluation suite + CI/CD gate' },
  { slug: 's5-red-teaming',      code: 'S5', accent: '#EA580C', persona: 'Security / SOC',         nist: 'Measure · Manage',  outcome: 'PyRIT / AI Red Teaming Agent scan + ASR scorecard' },
  { slug: 's6-control-plane',    code: 'S6', accent: '#0078D4', persona: 'Governance lead',        nist: 'Govern · Manage',   outcome: 'Agent 365 registry + capstone re-score' },
];

const PAGES = [
  { slug: 'start-why-governance',         src: 'start/why-governance.md',     title: 'Why AI-agent governance now', nav: true, group: 'Start here' },
  { slug: 'governance-on-citadel',        src: 'governance-on-citadel.md',    title: 'Citadel + RVAS together', nav: true, group: 'Start here' },
  { slug: 'start-your-journey',           src: 'start/your-journey.md',       title: 'Your journey', nav: true, group: 'Start here' },
  { slug: 'how-to-deliver',               src: 'how-to-deliver.md',            title: 'How to Deliver',            nav: true,  group: null },
  { slug: 'assessment',                   src: 'assessment/index.md',          title: 'Readiness Assessment',      nav: true,  group: null },
  { slug: 'reference',                    src: 'reference/index.md',           title: 'Reference · Landscape',     nav: true,  group: 'Reference' },
  { slug: 'reference-architectures',      src: 'reference/reference-architectures.md', title: 'Reference Architectures', nav: false, group: 'Reference' },
  { slug: 'reference-citadel-rvas-playbook', src: 'reference/citadel-rvas-playbook.md', title: 'Citadel + RVAS Playbook', nav: false, group: 'Reference' },
  { slug: 'reference-product-status',     src: 'reference/product-status.md',  title: 'Product & Feature Status',  nav: false, group: 'Reference' },
];

/* ─── Link routing map (docs-relative path → static route) ────────────────── */

const ROUTES = {
  'index.md': 'index.html',
  'start/why-governance.md': 'page.html?p=start-why-governance',
  'governance-on-citadel.md': 'page.html?p=governance-on-citadel',
  'start/your-journey.md': 'page.html?p=start-your-journey',
  'how-to-deliver.md': 'page.html?p=how-to-deliver',
  'assessment/index.md': 'page.html?p=assessment',
  'reference/index.md': 'page.html?p=reference',
  'reference/reference-architectures.md': 'page.html?p=reference-architectures',
  'reference/citadel-rvas-playbook.md': 'page.html?p=reference-citadel-rvas-playbook',
  'reference/product-status.md': 'page.html?p=reference-product-status',
};
SESSIONS.forEach((s) => {
  ROUTES[`${s.slug}/index.md`] = `session.html?s=${s.slug}`;
  ROUTES[`${s.slug}/concepts.md`] = `session-concepts.html?s=${s.slug}`;
});

const ADMONITION_MAP = {
  info: 'NOTE', note: 'NOTE', abstract: 'NOTE', summary: 'NOTE', example: 'NOTE', quote: 'NOTE',
  tip: 'TIP', hint: 'TIP', success: 'TIP', check: 'TIP',
  question: 'IMPORTANT', help: 'IMPORTANT', faq: 'IMPORTANT',
  warning: 'WARNING', caution: 'WARNING', attention: 'WARNING',
  danger: 'CAUTION', error: 'CAUTION', failure: 'CAUTION', bug: 'CAUTION',
};

const unresolvedMdLinks = [];

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

function main() {
  fs.mkdirSync(PAGES_OUT, { recursive: true });

  const sessionMeta = [];
  for (const s of SESSIONS) {
    const rel = `${s.slug}/index.md`;
    const conceptsRel = `${s.slug}/concepts.md`;
    const [raw, conceptsRaw] = [read(rel), read(conceptsRel)];
    if (raw == null || conceptsRaw == null) continue;
    const { title, md, hasMermaid, reviewed, reviewedNote } = transform(raw, rel);
    const concepts = transform(conceptsRaw, conceptsRel);
    const clean = title.replace(/^S\d+\s*·\s*/, '').trim() || title;
    fs.writeFileSync(path.join(PAGES_OUT, `${s.slug}.md`), md);
    fs.writeFileSync(path.join(PAGES_OUT, `${s.slug}-concepts.md`), concepts.md);
    sessionMeta.push({
      slug: s.slug, code: s.code, title: clean, fullTitle: title || `${s.code} · ${clean}`,
      accent: s.accent, persona: s.persona, nist: s.nist, outcome: s.outcome, hasMermaid,
      reviewed, reviewedNote, conceptsTitle: concepts.title || `${s.code} · ${clean} Concepts`,
      conceptsHasMermaid: concepts.hasMermaid, conceptsReviewed: concepts.reviewed || reviewed,
      conceptsReviewedNote: concepts.reviewedNote,
    });
  }

  const pageMeta = [];
  for (const p of PAGES) {
    const raw = read(p.src);
    if (raw == null) continue;
    const { title, md, hasMermaid, reviewed, reviewedNote } = transform(raw, p.src);
    fs.writeFileSync(path.join(PAGES_OUT, `${p.slug}.md`), md);
    pageMeta.push({ slug: p.slug, title: title || p.title, nav: p.nav, group: p.group, hasMermaid, reviewed, reviewedNote });
  }

  const site = {
    meta: SITE,
    stats: {
      sessions: sessionMeta.length,
      domains: sessionMeta.length,
      frameworks: 3,
      personas: 5,
    },
    sessions: sessionMeta,
    pages: pageMeta,
    builtAt: new Date().toISOString(),
  };
  fs.writeFileSync(path.join(DATA, 'site.json'), JSON.stringify(site, null, 2));

  if (unresolvedMdLinks.length) {
    console.error('✖ Unresolved local Markdown links:');
    unresolvedMdLinks.forEach((link) => {
      console.error(`  docs/${link.source}: ${link.target} → ${link.resolved}`);
    });
    process.exitCode = 1;
  }

  if (process.exitCode) {
    console.error('✖ Build completed with errors (see above).');
    return;
  }
  console.log(`✓ Built ${sessionMeta.length} sessions + ${pageMeta.length} pages → docs/assets/data/`);
}

main();
