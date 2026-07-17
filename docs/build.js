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
const DECKS_OUT = path.join(DATA, 'decks');

/* ─── Curriculum config (curated metadata, mirrors docs/index.md) ─────────── */

const SITE = {
  name: 'RVAS AI Governance',
  tagline: 'The AI Governance offering in the Real Value Acceleration Solution.',
  lastReviewed: '2026-07-06',
  repo: 'https://github.com/microsoft/frontier-ai-governance-rvas',
};

const SESSIONS = [
  { slug: 's0-foundations', code: 'S0', phase: 'Govern', accent: '#032254', persona: 'Governance lead', nist: 'Govern', outcome: 'Baseline maturity assessment + prioritized roadmap' },
  { slug: 's1-identity', code: 'S1', phase: 'Govern', accent: '#1A77E3', persona: 'Identity admin', nist: 'Govern · Manage', outcome: 'Identity, authority, and ownership review' },
  { slug: 's2-data-compliance', code: 'S2', phase: 'Govern', accent: '#14868A', persona: 'Compliance / Data admin', nist: 'Map · Manage', outcome: 'Data governance, compliance evidence, and review actions' },
  { slug: 's3-platform-foundation', code: 'S3', phase: 'Establish', accent: '#0F766E', persona: 'Platform owner', nist: 'Govern · Map · Manage', outcome: 'Trust-boundary decision + platform implementation backlog' },
  { slug: 's4-agent-engineering', code: 'S4', phase: 'Establish', accent: '#7C3AED', persona: 'AI developer / maker', nist: 'Govern · Map · Measure', outcome: 'Agent admission standard + change-review record' },
  { slug: 's5-tool-api-governance', code: 'S5', phase: 'Establish', accent: '#C2410C', persona: 'Platform owner', nist: 'Govern · Map · Manage', outcome: 'Controlled tool and API publication model' },
  { slug: 's6-security-runtime', code: 'S6', phase: 'Assure', accent: '#DC2626', persona: 'Security / SOC', nist: 'Measure · Manage', outcome: 'Runtime assurance evidence + response ownership' },
  { slug: 's7-evaluation', code: 'S7', phase: 'Assure', accent: '#504092', persona: 'AI developer / maker', nist: 'Measure · Manage', outcome: 'Quality, safety, and release-assurance decision' },
  { slug: 's8-red-teaming', code: 'S8', phase: 'Assure', accent: '#EA580C', persona: 'Security / SOC', nist: 'Measure · Manage', outcome: 'Authorized adversarial-test findings + remediation decision' },
  { slug: 's9-control-plane', code: 'S9', phase: 'Operate', accent: '#0078D4', persona: 'Governance lead', nist: 'Govern · Map · Manage', outcome: 'Control-plane reconciliation + lifecycle stewardship' },
  { slug: 's10-in-process-governance', code: 'S10', phase: 'Operate', accent: '#0891B2', persona: 'AI developer / maker', nist: 'Govern · Measure · Manage', outcome: 'In-process policy applicability and adoption decision' },
  { slug: 's11-operate-measure', code: 'S11', phase: 'Operate', accent: '#7C3AED', persona: 'Governance lead', nist: 'Govern · Measure · Manage', outcome: 'Operating review, drift, FinOps, and remediation cadence' },
  { slug: 's12-portfolio-governance', code: 'S12', phase: 'Operate', accent: '#475569', persona: 'Executive sponsor', nist: 'Govern · Map · Measure · Manage', outcome: 'Portfolio governance decision + next maturity roadmap' },
];

const SESSION_CHAPTERS = [
  {
    slug: 'prepare',
    label: 'Prepare',
    heading: /^(?:1\. Outcome|2\. Prerequisites|3\. Why)/i,
  },
  { slug: 'concepts', label: 'Concepts', standalone: true },
  { slug: 'technical', label: 'Technical decisions', standalone: true, optional: true },
  {
    slug: 'co-deliver',
    label: 'Co-deliver',
    heading: /^4\. Co-delivery/i,
  },
  {
    slug: 'verify-handover',
    label: 'Verify and hand over',
    heading: /^(?:5\. Verification|6\. (?:Customer-owned )?(?:Rollback|Change boundary))/i,
  },
  {
    slug: 'facilitator-notes',
    label: 'Facilitator notes',
    heading: /^7\. Facilitator notes/i,
  },
];

const PAGES = [
  { slug: 'start-understand-rvas',        src: 'start/understand-rvas.md',    title: 'About RVAS AI Governance', nav: true, group: 'Start here' },
  { slug: 'start-plan-engagement',        src: 'start/plan-engagement.md',    title: 'Plan the engagement',       nav: true, group: 'Start here' },
  { slug: 'how-to-deliver',               src: 'how-to-deliver.md',            title: 'How to deliver',            nav: true, group: 'Delivery' },
  { slug: 'delivery-facilitation-pattern', src: 'delivery/facilitation-pattern.md', title: 'Facilitate a co-delivery working session', nav: true, group: 'Delivery' },
  { slug: 'assessment',                   src: 'assessment/index.md',          title: 'Readiness Assessment',      nav: true,  group: null },
  { slug: 'platform-citadel-installation', src: 'delivery/platform-foundation/installation-work-package.md', title: 'Install Citadel platform', nav: true, group: 'Platform foundation' },
  { slug: 'platform-citadel-intake', src: 'delivery/platform-foundation/intake.md', title: 'Platform intake', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-raci', src: 'delivery/platform-foundation/raci.md', title: 'Platform RACI', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-accelerator-handoff', src: 'delivery/platform-foundation/accelerator-handoff.md', title: 'Accelerator handoff', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-gateway-acceptance', src: 'delivery/platform-foundation/non-production-gateway-acceptance.md', title: 'Non-production gateway acceptance', nav: false, group: 'Platform foundation' },
  { slug: 'platform-citadel-gateway-evidence', src: 'delivery/platform-foundation/gateway-evidence-manifest.md', title: 'Gateway evidence manifest', nav: false, group: 'Platform foundation' },
  { slug: 'reference-platform-technical', src: 'reference/platform-technical-guide.md', title: 'Platform technical guide', nav: true, group: 'Reference' },
  { slug: 'reference-governance-capabilities', src: 'reference/governance-capability-guide.md', title: 'Governance capability guide', nav: true, group: 'Reference' },
  { slug: 'reference-ai-governance-map', src: 'reference/ai-governance-reference-map.md', title: 'Microsoft AI governance reference map', nav: true, group: 'Reference' },
  { slug: 'reference-quality-cost-latency', src: 'reference/quality-cost-latency-guide.md', title: 'Quality, cost, latency, and rollout governance', nav: true, group: 'Reference' },
  { slug: 'reference-performance-testing', src: 'reference/performance-testing-guide.md', title: 'Agent performance-testing governance', nav: true, group: 'Reference' },
];

/* ─── Link routing map (docs-relative path → static route) ────────────────── */

const ROUTES = {
  'index.md': 'index.html',
  'start/understand-rvas.md': 'page.html?p=start-understand-rvas',
  'start/plan-engagement.md': 'page.html?p=start-plan-engagement',
  'how-to-deliver.md': 'page.html?p=how-to-deliver',
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
  'reference/ai-governance-reference-map.md': 'page.html?p=reference-ai-governance-map',
  'reference/quality-cost-latency-guide.md': 'page.html?p=reference-quality-cost-latency',
  'reference/performance-testing-guide.md': 'page.html?p=reference-performance-testing',
};
SESSIONS.forEach((s) => {
  ROUTES[`${s.slug}/index.md`] = `session.html?s=${s.slug}`;
  ROUTES[`${s.slug}/concepts.md`] = `session.html?s=${s.slug}&chapter=concepts`;
  ROUTES[`${s.slug}/technical.md`] = `session.html?s=${s.slug}&chapter=technical`;
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
  s = s.replace(/[*_~]{1,3}/g, '');                 // emphasis punctuation
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
      hasMermaid: hasMermaid || concepts.hasMermaid || Boolean(technical && technical.hasMermaid),
      hasDeck,
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

  if (process.exitCode) {
    console.error('✖ Build completed with errors (see above).');
    return;
  }
  console.log(`✓ Built ${sessionMeta.length} sessions + ${pageMeta.length} pages → docs/assets/data/ (search index: ${searchDocs.length} docs)`);
}

main();
