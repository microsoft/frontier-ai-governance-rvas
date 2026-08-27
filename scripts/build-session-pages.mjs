import {
  access,
  cp,
  mkdir,
  readFile,
  readdir,
  rm,
  unlink,
  writeFile,
} from "node:fs/promises";
import { join, posix, relative } from "node:path";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = join(fileURLToPath(new URL(".", import.meta.url)), "..");
const sessionsRoot = join(root, "sessions");
const modulesRoot = join(root, "modules");
const sessionsOutputRoot = join(root, "site", "sessions");
const modulesOutputRoot = join(root, "site", "modules");
const siteRoot = join(root, "site");
const serviceRegistryPath = join(root, "services.json");
const serviceIconRoot = join(siteRoot, "assets", "icons");
const marp = join(
  root,
  "node_modules",
  ".bin",
  process.platform === "win32" ? "marp.cmd" : "marp",
);

function shouldPublishAsset(source) {
  const normalized = source.replaceAll("\\", "/");
  return (
    !normalized.endsWith(".excalidraw") &&
    !normalized.endsWith("/assets/diagrams/README.md")
  );
}

const chapterDefinitionsByKind = {
  session: [
    {
      id: "scope-and-outcomes",
      title: "Scope and outcomes",
      headings: ["Session scope"],
      file: "index.html",
    },
    {
      id: "architecture",
      title: "Architecture",
      headings: ["Architecture"],
      file: "architecture.html",
    },
    {
      id: "before-you-start",
      title: "Before you start",
      headings: ["Before you start"],
      file: "before-you-start.html",
    },
    {
      id: "decisions-and-boundaries",
      title: "Decisions and boundaries",
      headings: ["Decisions and stop conditions", "Field reference"],
      file: "decisions-and-boundaries.html",
    },
    {
      id: "implementation",
      title: "Implementation",
      headings: ["Implement"],
      file: "implementation.html",
    },
    {
      id: "validation-and-operations",
      title: "Validation and operations",
      headings: ["Confirm the result", "After implementation"],
      file: "validation-and-operations.html",
    },
  ],
  module: [
    {
      id: "scope-and-outcomes",
      title: "Scope and outcomes",
      headings: ["Module scope"],
      file: "index.html",
    },
    {
      id: "architecture",
      title: "Architecture",
      headings: ["Architecture"],
      file: "architecture.html",
    },
    {
      id: "before-you-start",
      title: "Before you start",
      headings: ["Before you start"],
      file: "before-you-start.html",
    },
    {
      id: "decisions-and-boundaries",
      title: "Decisions and boundaries",
      headings: ["Decisions and stop conditions", "Field reference"],
      file: "decisions-and-boundaries.html",
    },
    {
      id: "implementation",
      title: "Implementation",
      headings: ["Implement"],
      file: "implementation.html",
    },
    {
      id: "validation-and-operations",
      title: "Validation and operations",
      headings: ["Confirm the result", "After implementation"],
      file: "validation-and-operations.html",
    },
  ],
};

const requiredImplementationHeadingsByKind = {
  session: [
    "Session scope",
    "Architecture",
    "Before you start",
    "Decisions and stop conditions",
    "Implement",
    "Confirm the result",
    "After implementation",
  ],
  module: [
    "Module scope",
    "Architecture",
    "Before you start",
    "Decisions and stop conditions",
    "Implement",
    "Confirm the result",
    "After implementation",
  ],
};

const escapeHtml = (value) =>
  value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");

const stripQuotes = (value) => value.trim().replace(/^"|"$/g, "");

const scalar = (yaml, key) => {
  const match = yaml.match(new RegExp(`^  ${key}:\\s*(.+)$`, "m"));
  return match ? stripQuotes(match[1]) : "";
};

const list = (yaml, key, indent = 2) => {
  const padding = " ".repeat(indent);
  const itemPadding = " ".repeat(indent + 2);
  const match = yaml.match(
    new RegExp(`^${padding}${key}:\\n((?:${itemPadding}- .+(?:\\n|$))+)`, "m"),
  );

  return match
    ? match[1]
        .trim()
        .split("\n")
        .map((item) => stripQuotes(item.replace(/^\s*-\s*/, "")))
    : [];
};

const formatShortDuration = (minutes) => {
  const hours = Number(minutes) / 60;
  return `${Number.isInteger(hours) ? hours : hours.toFixed(1)}h`;
};

const titleCase = (value) =>
  value ? `${value.charAt(0).toUpperCase()}${value.slice(1)}` : "";

const loadServiceRegistry = async () => {
  let registry;
  try {
    registry = JSON.parse(await readFile(serviceRegistryPath, "utf8"));
  } catch (error) {
    throw new Error(`Cannot read services.json: ${error.message}`);
  }

  if (!registry || !Array.isArray(registry.services)) {
    throw new Error('services.json must contain a "services" array.');
  }

  const byId = new Map();
  for (const [index, service] of registry.services.entries()) {
    const location = `services.json services[${index}]`;
    if (!service || typeof service !== "object") {
      throw new Error(`${location} must be an object.`);
    }
    for (const field of ["id", "label", "category", "icon"]) {
      if (typeof service[field] !== "string" || !service[field].trim()) {
        throw new Error(`${location} is missing ${field}.`);
      }
    }
    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(service.id)) {
      throw new Error(`${location} id must be lower-case kebab-case.`);
    }
    if (!/^[a-z0-9]+(?:-[a-z0-9]+)*\.svg$/.test(service.icon)) {
      throw new Error(`${location} icon must be a plain SVG filename.`);
    }
    if (byId.has(service.id)) {
      throw new Error(`services.json contains duplicate service ID "${service.id}".`);
    }
    try {
      await access(join(serviceIconRoot, service.icon));
    } catch {
      throw new Error(
        `Service "${service.id}" references missing icon site/assets/icons/${service.icon}.`,
      );
    }
    byId.set(service.id, Object.freeze({ ...service }));
  }

  return {
    services: [...byId.values()],
    byId,
  };
};

const resolveServices = ({ ids, registry, sourceLabel }) => {
  if (ids.length === 0) {
    throw new Error(`${sourceLabel} must contain at least one service ID.`);
  }
  const seen = new Set();
  return ids.map((id) => {
    if (seen.has(id)) {
      throw new Error(`${sourceLabel} contains duplicate service ID "${id}".`);
    }
    seen.add(id);
    const service = registry.byId.get(id);
    if (!service) {
      throw new Error(`${sourceLabel} references unknown service ID "${id}".`);
    }
    return service;
  });
};

const slugify = (value) =>
  value
    .toLowerCase()
    .replace(/[`*_]/g, "")
    .replace(/&(?:amp;)?/g, "and")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");

const outputPrefixFor = (sourceKind, targetKind) =>
  sourceKind === targetKind ? "../" : `../../${targetKind}s/`;

const sourceRepository = process.env.SOURCE_REPOSITORY ?? process.env.GITHUB_REPOSITORY ?? "";
const sourceRevision = process.env.SOURCE_REVISION ?? process.env.GITHUB_SHA ?? "";
const sourceServerUrl = (
  process.env.SOURCE_SERVER_URL ??
  process.env.GITHUB_SERVER_URL ??
  "https://github.com"
).replace(/\/+$/, "");

const githubSourceUrl = ({ href, sourceKind, sourceSlug }) => {
  if (!sourceRepository || !sourceRevision || !sourceSlug) {
    return "";
  }

  const implementationPath = posix.normalize(href.replace(/^\.\//, ""));
  if (
    implementationPath === ".." ||
    implementationPath.startsWith("../") ||
    posix.isAbsolute(implementationPath)
  ) {
    throw new Error(`Implementation link escapes its source folder: ${href}`);
  }

  const collection = sourceKind === "module" ? "modules" : "sessions";
  const filePath = `${collection}/${sourceSlug}/implementation/${implementationPath}`;
  const encodedPath = filePath
    .split("/")
    .map((segment) => encodeURIComponent(segment))
    .join("/");

  return `${sourceServerUrl}/${sourceRepository}/blob/${encodeURIComponent(sourceRevision)}/${encodedPath}`;
};

const rewriteLink = (
  href,
  { resolveAnchor, sourceKind = "session", sourceSlug = "" } = {},
) => {
  if (href.startsWith("#")) {
    return resolveAnchor ? resolveAnchor(href.slice(1)) : href;
  }
  if (/^(?:https?:|mailto:|\/)/.test(href)) {
    return href;
  }

  const siblingGuide = href.match(
    /^\.\.\/\.\.\/([a-z0-9-]+)\/implementation\/README\.md$/,
  );
  if (siblingGuide) {
    return `../${siblingGuide[1]}/`;
  }

  const collectionGuide = href.match(
    /^\.\.\/\.\.\/\.\.\/(sessions|modules)\/([a-z0-9-]+)(?:\/implementation\/README\.md|\/?)$/,
  );
  if (collectionGuide) {
    const [, collection, slug] = collectionGuide;
    const targetKind = collection === "sessions" ? "session" : "module";
    return `${outputPrefixFor(sourceKind, targetKind)}${slug}/`;
  }

  return (
    githubSourceUrl({ href, sourceKind, sourceSlug }) ||
    `implementation/${href.replace(/^\.\//, "")}`
  );
};

const rewriteImage = (href) => {
  if (/^(?:https?:|\/)/.test(href)) {
    return href;
  }

  const implementationAsset = href.match(/^\.\.\/assets\/(.+)$/);
  if (implementationAsset) {
    return `assets/${implementationAsset[1]}`;
  }

  return href.replace(/^\.\//, "");
};

const inlineMarkdown = (value, resolveLink) => {
  const tokens = [];
  let output = escapeHtml(value);
  const hold = (html) => {
    const token = `\u0000${tokens.length}\u0000`;
    tokens.push(html);
    return token;
  };

  output = output.replace(/&lt;br\s*\/?&gt;/gi, () => hold("<br>"));
  output = output.replace(/`([^`]+)`/g, (_, code) =>
    hold(`<code>${code}</code>`),
  );
  output = output.replace(/\[([^\]]+)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g, (_, text, href) =>
    hold(`<a href="${escapeHtml(resolveLink(href))}">${text}</a>`),
  );
  output = output
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/(?<!\*)\*([^*]+)\*(?!\*)/g, "<em>$1</em>");

  while (/\u0000\d+\u0000/.test(output)) {
    output = output.replace(/\u0000(\d+)\u0000/g, (_, index) => tokens[Number(index)]);
  }

  return output;
};

const isTableDivider = (line) =>
  /^\s*\|?\s*:?-{3,}:?\s*(?:\|\s*:?-{3,}:?\s*)+\|?\s*$/.test(line);

const splitTableRow = (line) =>
  line
    .trim()
    .replace(/^\||\|$/g, "")
    .split("|")
    .map((cell) => cell.trim());

const isBlockStart = (lines, index) => {
  const line = lines[index] ?? "";
  const next = lines[index + 1] ?? "";
  return (
    !line.trim() ||
    /^#{1,4}\s+/.test(line) ||
    /^\s*```/.test(line) ||
    /^>\s?/.test(line) ||
    /^\s*[-*]\s+/.test(line) ||
    /^\s*\d+\.\s+/.test(line) ||
    /^---+$/.test(line.trim()) ||
    (line.includes("|") && isTableDivider(next))
  );
};

const shellForLanguage = (language) => {
  if (["powershell", "pwsh"].includes(language.toLowerCase())) {
    return "powershell";
  }
  if (["bash", "sh", "shell"].includes(language.toLowerCase())) {
    return "bash";
  }
  return null;
};

const readCodeFence = (lines, start) => {
  const opening = lines[start].match(/^(\s*)```(.*)$/);
  const indent = opening?.[1].length ?? 0;
  const language = opening?.[2].trim() ?? "";
  const code = [];
  let index = start + 1;

  while (index < lines.length && !lines[index].trimStart().startsWith("```")) {
    const leadingSpaces = lines[index].match(/^ */)?.[0].length ?? 0;
    code.push(lines[index].slice(Math.min(indent, leadingSpaces)));
    index += 1;
  }

  return {
    code: code.join("\n"),
    language,
    nextIndex: Math.min(index + 1, lines.length),
  };
};

const renderCodeBlock = ({ code, language }) =>
  `<pre><code${language ? ` class="language-${escapeHtml(language)}"` : ""}>${escapeHtml(code)}</code></pre>`;

const renderShellTabs = (powershell, bash, groupIndex) => {
  const id = `command-shell-${groupIndex}`;
  return `<section class="code-tabs" data-code-tabs>
  <div class="code-tabs__tabs" role="tablist" aria-label="Command shell">
    <button type="button" role="tab" id="${id}-powershell-tab" aria-controls="${id}-powershell-panel" aria-selected="true" data-shell-tab="powershell">PowerShell</button>
    <button type="button" role="tab" id="${id}-bash-tab" aria-controls="${id}-bash-panel" aria-selected="false" tabindex="-1" data-shell-tab="bash">Bash</button>
  </div>
  <div class="code-tabs__panel" id="${id}-powershell-panel" role="tabpanel" aria-labelledby="${id}-powershell-tab" tabindex="0" data-shell-panel="powershell">
    <p class="code-tabs__fallback-label">PowerShell</p>
    ${renderCodeBlock(powershell)}
  </div>
  <div class="code-tabs__panel" id="${id}-bash-panel" role="tabpanel" aria-labelledby="${id}-bash-tab" tabindex="0" data-shell-panel="bash">
    <p class="code-tabs__fallback-label">Bash</p>
    ${renderCodeBlock(bash)}
  </div>
</section>`;
};

const renderMarkdown = (
  markdown,
  {
    resolveLink = (href) => rewriteLink(href),
    resolveImage = (href) => rewriteImage(href),
  } = {},
) => {
  const lines = markdown.replace(/\r\n/g, "\n").split("\n");
  const html = [];
  const headings = [];
  const renderInline = (value) => inlineMarkdown(value, resolveLink);
  let index = 0;
  let commandGroupIndex = 0;
  let skippedTitle = false;

  while (index < lines.length) {
    const line = lines[index];

    if (!line.trim()) {
      index += 1;
      continue;
    }

    if (line.trim().startsWith("<!--")) {
      while (index < lines.length && !lines[index].includes("-->")) {
        index += 1;
      }
      index += 1;
      continue;
    }

    if (line.trimStart().startsWith("```")) {
      const first = readCodeFence(lines, index);
      let nextBlockIndex = first.nextIndex;
      while (nextBlockIndex < lines.length && !lines[nextBlockIndex].trim()) {
        nextBlockIndex += 1;
      }

      const firstShell = shellForLanguage(first.language);
      const second =
        firstShell === "powershell" &&
        lines[nextBlockIndex]?.trimStart().startsWith("```")
          ? readCodeFence(lines, nextBlockIndex)
          : null;

      if (second && shellForLanguage(second.language) === "bash") {
        commandGroupIndex += 1;
        html.push(renderShellTabs(first, second, commandGroupIndex));
        index = second.nextIndex;
      } else {
        html.push(renderCodeBlock(first));
        index = first.nextIndex;
      }
      continue;
    }

    const imageMatch = line
      .trim()
      .match(/^!\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)$/);
    if (imageMatch) {
      const [, alt, href] = imageMatch;
      html.push(
        `<figure class="session-diagram"><img src="${escapeHtml(resolveImage(href))}" alt="${escapeHtml(alt)}" loading="lazy" decoding="async"></figure>`,
      );
      index += 1;
      continue;
    }

    const headingMatch = line.match(/^(#{1,4})\s+(.+)$/);
    if (headingMatch) {
      const level = headingMatch[1].length;
      const text = headingMatch[2].replace(/\s+#+$/, "");
      if (level === 1 && !skippedTitle) {
        skippedTitle = true;
        index += 1;
        continue;
      }
      const id = slugify(text);
      headings.push({ level, text: text.replace(/[`*_]/g, ""), id });
      html.push(
        `<h${level} id="${id}">${renderInline(text)}<a class="heading-anchor" href="#${id}" aria-label="Link to ${escapeHtml(text.replace(/[`*_]/g, ""))}">#</a></h${level}>`,
      );
      index += 1;
      continue;
    }

    if (line.includes("|") && isTableDivider(lines[index + 1] ?? "")) {
      const headers = splitTableRow(line);
      const rows = [];
      index += 2;
      while (index < lines.length && lines[index].includes("|") && lines[index].trim()) {
        rows.push(splitTableRow(lines[index]));
        index += 1;
      }
      html.push(
        `<div class="table-scroll"><table><thead><tr>${headers.map((cell) => `<th scope="col">${renderInline(cell)}</th>`).join("")}</tr></thead><tbody>${rows
          .map(
            (row) =>
              `<tr>${row.map((cell) => `<td>${renderInline(cell)}</td>`).join("")}</tr>`,
          )
          .join("")}</tbody></table></div>`,
      );
      continue;
    }

    if (/^>\s?/.test(line)) {
      const quote = [];
      while (index < lines.length && /^>\s?/.test(lines[index])) {
        quote.push(lines[index].replace(/^>\s?/, ""));
        index += 1;
      }
      html.push(`<blockquote>${quote.map(renderInline).join("<br>")}</blockquote>`);
      continue;
    }

    const unordered = line.match(/^\s*[-*]\s+(.+)$/);
    const ordered = line.match(/^\s*\d+\.\s+(.+)$/);
    if (unordered || ordered) {
      const orderedList = Boolean(ordered);
      const pattern = orderedList ? /^\s*\d+\.\s+(.+)$/ : /^\s*[-*]\s+(.+)$/;
      const items = [];
      while (index < lines.length) {
        const item = lines[index].match(pattern);
        if (!item) {
          break;
        }
        const parts = [item[1]];
        index += 1;
        while (
          index < lines.length &&
          /^\s{2,}\S/.test(lines[index]) &&
          !lines[index].match(pattern) &&
          !/^\s*```/.test(lines[index])
        ) {
          parts.push(lines[index].trim());
          index += 1;
        }
        items.push(parts.join(" "));
      }
      const tag = orderedList ? "ol" : "ul";
      html.push(`<${tag}>${items.map((item) => `<li>${renderInline(item)}</li>`).join("")}</${tag}>`);
      continue;
    }

    if (/^---+$/.test(line.trim())) {
      html.push("<hr>");
      index += 1;
      continue;
    }

    const paragraph = [line.trim()];
    index += 1;
    while (index < lines.length && !isBlockStart(lines, index)) {
      paragraph.push(lines[index].trim());
      index += 1;
    }
    html.push(`<p>${renderInline(paragraph.join(" "))}</p>`);
  }

  return { html: html.join("\n"), headings };
};

const cleanHeading = (value) => value.replace(/\s+#+$/, "").replace(/[`*_]/g, "").trim();

const splitImplementation = (markdown, item) => {
  const lines = markdown.replace(/\r\n/g, "\n").split("\n");
  const sections = [];
  let current = null;

  for (const line of lines) {
    const match = line.match(/^##\s+(.+)$/);
    if (match) {
      if (current) {
        sections.push(current);
      }
      current = { heading: cleanHeading(match[1]), lines: [line] };
      continue;
    }
    if (current) {
      current.lines.push(line);
    }
  }
  if (current) {
    sections.push(current);
  }

  const actualHeadings = sections.map(({ heading }) => heading);
  const expectedHeadings = [...requiredImplementationHeadingsByKind[item.kind]];
  if (actualHeadings.includes("Field reference")) {
    expectedHeadings.splice(
      expectedHeadings.indexOf("Decisions and stop conditions") + 1,
      0,
      "Field reference",
    );
  }
  if (
    actualHeadings.length !== expectedHeadings.length ||
    actualHeadings.some((heading, index) => heading !== expectedHeadings[index])
  ) {
    throw new Error(
      `${item.slug} has an invalid implementation chapter structure. Expected: ${expectedHeadings.join(" > ")}. Found: ${actualHeadings.join(" > ")}.`,
    );
  }

  const sectionByHeading = new Map(
    sections.map((section) => [section.heading, section.lines.join("\n").trim()]),
  );

  return chapterDefinitionsByKind[item.kind].map((definition, index) => ({
    ...definition,
    index,
    markdown: definition.headings
      .map((heading) => sectionByHeading.get(heading))
      .filter(Boolean)
      .join("\n\n"),
  }));
};

const buildAnchorTargets = (chapters) => {
  const targets = new Map();
  chapters.forEach((chapter) => {
    chapter.markdown.split("\n").forEach((line) => {
      const match = line.match(/^#{2,4}\s+(.+)$/);
      if (!match) {
        return;
      }
      const id = slugify(cleanHeading(match[1]));
      if (!targets.has(id)) {
        targets.set(id, chapter.file);
      }
    });
  });
  return targets;
};

const formatDuration = (minutes) => {
  const hours = Number(minutes) / 60;
  return `${Number.isInteger(hours) ? hours : hours.toFixed(1)} hours`;
};

const phaseFor = (number) => {
  if (number <= 6) return { name: "Governed foundation", key: "foundation" };
  if (number <= 12) return { name: "Runtime assurance", key: "runtime" };
  return { name: "Operate at scale", key: "operations" };
};

const linkSessionReferences = (references, sessionLinks, sourceKind = "session") => {
  const range = references.match(/^(\d{2})\s*-\s*(\d{2})$/);
  if (range) {
    const first = Number(range[1]);
    const last = Number(range[2]);
    const numbers = Array.from(
      { length: Math.max(0, last - first + 1) },
      (_, index) => String(first + index).padStart(2, "0"),
    );
    const links = numbers.map((number) => {
      const slug = sessionLinks.get(number);
      return slug ? `<a href="${outputPrefixFor(sourceKind, "session")}${slug}/">${number}</a>` : number;
    });

    if (links.length < 2) {
      return links[0] ?? references;
    }
    return links.length === 2
      ? `${links[0]} and ${links[1]}`
      : `${links.slice(0, -1).join(", ")}, and ${links.at(-1)}`;
  }

  return references.replace(/\d{2}/g, (number) => {
    const slug = sessionLinks.get(number);
    return slug ? `<a href="${outputPrefixFor(sourceKind, "session")}${slug}/">${number}</a>` : number;
  });
};

const buildBriefSections = (item) => {
  const sections = [
    {
      className: "session-brief__audience session-brief__list",
      title: "Who should join",
      items: item.audience,
      linked: false,
      layout: "stack",
    },
    {
      className: "session-brief__requirements session-brief__list",
      title: "What you need",
      items: item.dependencies,
      linked: true,
      layout: "stack",
    },
  ];

  if (item.kind === "module" && item.relatedSessions.length) {
    sections.push({
      className: "session-brief__references session-brief__list",
      title: "Related numbered sessions",
      items: item.relatedSessions,
      linked: true,
      wholeEntryLink: true,
      layout: "stack",
    });
  }

  return sections.filter(({ items }) => items.length);
};

const pageContextFor = (item, chapter, chapters) => {
  if (item.kind === "session") {
    const numberLabel = String(item.number).padStart(2, "0");
    return {
      bodyClass: "session-page",
      collectionHref: "../../index.html#program",
      collectionLabel: "All sessions",
      collectionNavCurrent: { sessions: true, modules: false },
      deckLabel: `Session ${numberLabel}`,
      footerLabel: `Session ${numberLabel}`,
      chapterLabel: `Chapter ${chapter.index + 1} of ${chapters.length}`,
      phaseStatus: `${item.phase.name} · ${titleCase(item.status)}`,
      itemLabel: `Session ${numberLabel}`,
      identity: `Session ${numberLabel}`,
      pageTitle: `Session ${numberLabel}: ${item.title}`,
      phaseKey: item.phase.key,
    };
  }

  return {
    bodyClass: "session-page module-page",
    collectionHref: "../../index.html#optional-modules",
    collectionLabel: "Optional modules",
    collectionNavCurrent: { sessions: false, modules: true },
    deckLabel: "Optional module",
    footerLabel: "Optional module",
    chapterLabel: `Chapter ${chapter.index + 1} of ${chapters.length}`,
    phaseStatus: `Optional module · ${titleCase(item.status)}`,
    itemLabel: "Optional module",
    identity: "Optional module",
    pageTitle: `Optional module: ${item.title}`,
    phaseKey: "",
  };
};

const pageTemplate = ({
  chapter,
  chapters,
  controlObjective,
  guide,
  nextPage,
  previousPage,
  sessionLinks,
  title,
  ...item
}) => {
  const context = pageContextFor({ ...item, title }, chapter, chapters);
  const chapterLinks = chapters
    .map(
      ({ file, index, title: chapterTitle }) =>
        `<li><a href="${file}"${index === chapter.index ? ' aria-current="page"' : ""}><span>${index + 1}</span>${escapeHtml(chapterTitle)}</a></li>`,
    )
    .join("");
  const renderBriefText = (value) =>
    escapeHtml(value).replace(/`([^`]+)`/g, "<code>$1</code>");
  const listItems = (items) => items.map((item) => `<li>${renderBriefText(item)}</li>`).join("");
  const linkedSessionListItems = (items) =>
    items
      .map((entry) => {
        const escaped = renderBriefText(entry).replace(
          /\b(Sessions?)\s+(\d{2}(?:(?:\s*-\s*|\s*,\s*(?:and\s+)?|\s+and\s+)\d{2})*)/g,
          (_, label, references) =>
            `${label} ${linkSessionReferences(references, sessionLinks, item.kind)}`,
        );
        return `<li>${escaped}</li>`;
      })
      .join("");
  const linkedWholeEntryListItems = (items) =>
    items
      .map((entry) => {
        const sessionNumber = entry.match(/\bSession\s+(\d{2})\b/)?.[1];
        const slug = sessionNumber ? sessionLinks.get(sessionNumber) : "";
        const content = renderBriefText(entry);
        return slug
          ? `<li><a href="${outputPrefixFor(item.kind, "session")}${slug}/">${content}</a></li>`
          : `<li>${content}</li>`;
      })
      .join("");
  const renderBriefSection = ({
    className,
    title: sectionTitle,
    items,
    linked,
    wholeEntryLink,
    layout,
  }) =>
    `<div class="${className}" data-list-layout="${layout}">
              <h3>${escapeHtml(sectionTitle)}</h3>
              <ul>${wholeEntryLink ? linkedWholeEntryListItems(items) : linked ? linkedSessionListItems(items) : listItems(items)}</ul>
            </div>`;
  const briefSections = buildBriefSections(item);
  const briefContent = briefSections.map(renderBriefSection).join("");
  const serviceList = item.services
    .map(
      (service) => `<li>
                <img src="../../assets/icons/${escapeHtml(service.icon)}" alt="">
                <strong>${escapeHtml(service.label)}</strong>
              </li>`,
    )
    .join("");
  const facts = [
    ["Identity", context.identity],
    [item.kind === "session" ? "Phase and status" : "Status", context.phaseStatus],
    ["Duration", item.duration],
    ["Implementation mode", titleCase(item.mode)],
    ["Last verified", item.lastVerified],
  ]
    .map(
      ([label, value]) =>
        `<div><dt>${escapeHtml(label)}</dt><dd>${escapeHtml(value)}</dd></div>`,
    )
    .join("");
  const pagerLink = (page) =>
    page
      ? `<a href="${page.href}"><span>${escapeHtml(page.label)}</span><strong>${escapeHtml(page.title)}</strong></a>`
      : '<span class="session-pager__spacer" aria-hidden="true"></span>';

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#032254">
    <meta name="description" content="${escapeHtml(controlObjective)}">
    <title>${escapeHtml(chapter.title)} | ${escapeHtml(context.pageTitle)} | Practical Microsoft AI Governance</title>
    <link rel="icon" href="../../assets/img/logo-mark.png" type="image/png">
    <!-- impeccable-disable overused-font -- Inter is required by the RVAS visual reference. -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../../styles.css">
    <script src="../../script.js" defer></script>
  </head>
  <body class="${context.bodyClass}"${context.phaseKey ? ` data-session-phase="${context.phaseKey}"` : ""}>
    <!-- impeccable-disable em-dash-overuse -- The implementation guide is generated from the technical session source. -->
    <a class="skip-link" href="#implementation-guide">Skip to implementation guide</a>
    <header class="site-header">
      <div class="site-header__inner">
        <a class="brand" href="../../index.html" aria-label="RVAS AI Governance home">
          <img src="../../assets/img/logo-full.png" width="90" height="32" alt="RVAP, Real Value Acceleration Program">
        </a>
        <nav class="site-nav" id="primary-nav" aria-label="Primary navigation" data-primary-nav>
          <a href="../../index.html">Home</a>
          <a href="../../index.html#approach">Method</a>
          <a href="../../index.html#readiness">Pre-work</a>
          <a href="../../index.html#program"${context.collectionNavCurrent.sessions ? ' aria-current="page"' : ""}>Sessions</a>
          <a href="../../index.html#optional-modules"${context.collectionNavCurrent.modules ? ' aria-current="page"' : ""}>Optional modules</a>
          <a href="../../sources.html">Sources</a>
        </nav>
        <div class="nav-actions">
          <button class="nav-toggle" type="button" aria-label="Open navigation" aria-controls="primary-nav" aria-expanded="false" data-nav-toggle>
            <span></span><span></span><span></span>
          </button>
        </div>
      </div>
    </header>

    <main>
      <section class="chapter-header" aria-labelledby="${chapter.id}">
        <div class="session-content-width">
          <nav class="breadcrumb" aria-label="Breadcrumb">
            <a href="${context.collectionHref}">${context.collectionLabel}</a>
            <span aria-hidden="true">/</span>
            ${chapter.index === 0 ? `<span>${escapeHtml(context.itemLabel)}</span>` : `<a href="index.html">${escapeHtml(context.itemLabel)}</a>`}
          </nav>
          <p class="chapter-header__label">${escapeHtml(context.chapterLabel)} · ${escapeHtml(chapter.title)}</p>
          <h1 id="${chapter.id}">${escapeHtml(title)}</h1>
          <div class="chapter-header__meta" aria-label="Session details">
            <span>${escapeHtml(context.phaseStatus)}</span>
            <span>${escapeHtml(item.duration)}</span>
          </div>
        </div>
      </section>

      <nav class="chapter-tabs" aria-label="${item.kind === "session" ? "Session" : "Module"} chapters">
        <ol class="session-content-width">${chapterLinks}</ol>
      </nav>

      <div class="session-reading-layout session-content-width">
        <aside class="service-panel" aria-labelledby="service-panel-title">
          <h2 id="service-panel-title">Services in scope</h2>
          <ul>${serviceList}</ul>
        </aside>
        <article class="implementation-guide" id="implementation-guide" aria-label="${escapeHtml(chapter.title)}">
          <p class="implementation-guide__label">${escapeHtml(context.chapterLabel)}</p>
          ${guide}
${chapter.id === "scope-and-outcomes" ? `          <section class="session-brief" aria-labelledby="session-brief-title">
            <h2 id="session-brief-title">${item.kind === "module" ? "Module preparation" : "Session preparation"}</h2>
            <div class="session-brief__grid">${briefContent}</div>
          </section>
` : ""}
        </article>
        <aside class="facts-panel" aria-labelledby="facts-panel-title">
          <h2 id="facts-panel-title">Facts</h2>
          <dl>${facts}</dl>
        </aside>
      </div>

      <nav class="session-pager session-content-width" aria-label="Chapter navigation">
        ${pagerLink(previousPage)}
        ${pagerLink(nextPage)}
      </nav>
    </main>

    <footer class="site-footer">
      <div class="site-footer__brand">
        <img src="../../assets/img/logo-full.png" width="90" height="32" alt="RVAP, Real Value Acceleration Program">
        <span>Practical Microsoft AI Governance</span>
      </div>
      <p>${escapeHtml(context.footerLabel)} · ${escapeHtml(chapter.title)}</p>
    </footer>

    <button
      class="deck-launcher"
      type="button"
      aria-haspopup="dialog"
      aria-controls="session-deck-dialog"
      data-deck-open
    >
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <rect x="3.5" y="4.5" width="17" height="12" rx="1.5"></rect>
        <path d="M8 20h8M12 16.5V20"></path>
      </svg>
      <span>View slide deck</span>
    </button>

    <dialog
      class="deck-dialog"
      id="session-deck-dialog"
      aria-labelledby="session-deck-title"
      data-deck-dialog
    >
      <div class="deck-dialog__shell">
        <header class="deck-dialog__header">
          <div>
            <p>${escapeHtml(context.deckLabel)}</p>
            <h2 id="session-deck-title">${escapeHtml(title)} slide deck</h2>
          </div>
          <div class="deck-dialog__actions">
            <a href="deck.html" target="_blank" rel="noopener">Open in a new tab</a>
            <button type="button" aria-label="Close slide deck" data-deck-close>
              <svg viewBox="0 0 24 24" aria-hidden="true">
                <path d="m6 6 12 12M18 6 6 18"></path>
              </svg>
            </button>
          </div>
        </header>
        <div class="deck-dialog__frame">
          <iframe
            title="${escapeHtml(context.deckLabel)}: ${escapeHtml(title)} slide deck"
            data-deck-frame
            data-src="deck.html"
          ></iframe>
        </div>
      </div>
    </dialog>
  </body>
</html>
`;
};

const discoverDirectories = async (sourceRoot, matcher) => {
  try {
    return (await readdir(sourceRoot, { withFileTypes: true }))
      .filter((entry) => entry.isDirectory() && matcher.test(entry.name))
      .map((entry) => entry.name)
      .sort();
  } catch (error) {
    if (error && error.code === "ENOENT") {
      return [];
    }
    throw error;
  }
};

const loadSessions = async (serviceRegistry) => {
  const sessionDirectories = await discoverDirectories(sessionsRoot, /^\d{2}-/);
  const sessions = await Promise.all(
    sessionDirectories.map(async (directory) => {
      const source = join(sessionsRoot, directory);
      const yamlPath = join(source, "session.yaml");
      const yaml = (await readFile(yamlPath, "utf8")).replace(
        /\r\n/g,
        "\n",
      );
      const implementation = await readFile(
        join(source, "implementation", "README.md"),
        "utf8",
      );
      const id = scalar(yaml, "id");
      const number = Number(id);
      if (!/^\d{2}$/.test(id) || !Number.isInteger(number)) {
        throw new Error(`${relative(root, yamlPath)} has invalid session ID "${id}".`);
      }
      const durationMinutes = Number(scalar(yaml, "duration_minutes"));
      const sourceLabel = `${relative(root, yamlPath)} services_in_scope`;
      const item = {
        audience: list(yaml, "audience"),
        controlObjective: scalar(yaml, "control_objective"),
        dependencies: list(yaml, "prerequisites"),
        duration: formatDuration(durationMinutes),
        durationMinutes,
        durationShort: formatShortDuration(durationMinutes),
        implementation,
        implementationOutcomes: list(yaml, "implementation_outcomes", 0),
        kind: "session",
        lastVerified: scalar(yaml, "last_verified"),
        mode: scalar(yaml, "mode"),
        number,
        phase: phaseFor(number),
        relatedSessions: [],
        services: resolveServices({
          ids: list(yaml, "services_in_scope"),
          registry: serviceRegistry,
          sourceLabel,
        }),
        slug: directory,
        source,
        status: scalar(yaml, "status"),
        title: scalar(yaml, "title"),
      };

      if (item.services.length === 0) {
        throw new Error(`${sourceLabel} must contain at least one service ID.`);
      }
      item.chapters = splitImplementation(implementation, item);
      return item;
    }),
  );

  const ids = new Map();
  for (const session of sessions) {
    const id = String(session.number).padStart(2, "0");
    if (ids.has(id)) {
      throw new Error(
        `Duplicate session ID "${id}" in ${ids.get(id)} and sessions/${session.slug}/session.yaml.`,
      );
    }
    ids.set(id, `sessions/${session.slug}/session.yaml`);
  }
  return sessions.sort((left, right) => left.number - right.number);
};

const loadModules = async (serviceRegistry) => {
  const moduleDirectories = await discoverDirectories(modulesRoot, /^[a-z0-9-]+$/);
  return Promise.all(
    moduleDirectories.map(async (directory) => {
      const source = join(modulesRoot, directory);
      const yamlPath = join(source, "module.yaml");
      const yaml = (await readFile(yamlPath, "utf8")).replace(/\r\n/g, "\n");
      const implementation = await readFile(
        join(source, "implementation", "README.md"),
        "utf8",
      );
      const title = scalar(yaml, "title");
      const durationMinutes = Number(scalar(yaml, "duration_minutes"));
      const sourceLabel = `${relative(root, yamlPath)} services_in_scope`;
      const item = {
        audience: list(yaml, "audience"),
        controlObjective: scalar(yaml, "control_objective"),
        dependencies: list(yaml, "prerequisites"),
        duration: formatDuration(durationMinutes),
        durationMinutes,
        durationShort: formatShortDuration(durationMinutes),
        implementation,
        implementationOutcomes: list(yaml, "implementation_outcomes", 0),
        kind: "module",
        lastVerified: scalar(yaml, "last_verified"),
        mode: scalar(yaml, "mode"),
        relatedSessions: list(yaml, "related_sessions"),
        services: resolveServices({
          ids: list(yaml, "services_in_scope"),
          registry: serviceRegistry,
          sourceLabel,
        }),
        slug: directory,
        source,
        status: scalar(yaml, "status"),
        title,
      };

      if (item.services.length === 0) {
        throw new Error(`${sourceLabel} must contain at least one service ID.`);
      }
      item.chapters = splitImplementation(implementation, item);
      return item;
    }),
  );
};

const buildCollection = async ({ items, outputRoot, descriptorFile }) => {
  await rm(outputRoot, { force: true, recursive: true });
  await mkdir(outputRoot, { recursive: true });

  for (const [index, item] of items.entries()) {
    const output = join(outputRoot, item.slug);
    const implementationOutput = join(output, "implementation");
    const anchorTargets = buildAnchorTargets(item.chapters);

    await mkdir(output, { recursive: true });
    await cp(join(item.source, "assets"), join(output, "assets"), {
      recursive: true,
      filter: shouldPublishAsset,
    });
    await cp(join(item.source, "implementation"), implementationOutput, {
      recursive: true,
    });
    await unlink(join(implementationOutput, "README.md"));
    await cp(join(item.source, "deck.md"), join(output, "deck.md"));
    await cp(join(item.source, descriptorFile), join(output, descriptorFile));

    for (const chapter of item.chapters) {
      const resolveLink = (href) =>
        rewriteLink(href, {
          sourceKind: item.kind,
          sourceSlug: item.slug,
          resolveAnchor: (anchor) => {
            const target = anchorTargets.get(anchor);
            if (!target || target === chapter.file) {
              return `#${anchor}`;
            }
            return `${target}#${anchor}`;
          },
        });
      const chapterLines = chapter.markdown.split("\n");
      const firstHeading = chapterLines[0]?.match(/^##\s+(.+)$/);
      const chapterMarkdown =
        firstHeading && cleanHeading(firstHeading[1]) === chapter.title
          ? chapterLines.slice(1).join("\n").trimStart()
          : chapter.markdown;
      const { html: guide } = renderMarkdown(chapterMarkdown, {
        resolveLink,
        resolveImage: rewriteImage,
      });
      const previousChapter = item.chapters[chapter.index - 1];
      const nextChapter = item.chapters[chapter.index + 1];
      const previousItem = items[index - 1];
      const nextItem = items[index + 1];
      const previousPage = previousChapter
        ? {
            href: previousChapter.file,
            label: "Previous chapter",
            title: previousChapter.title,
          }
        : item.kind === "session"
          ? previousItem
            ? {
                href: `../${previousItem.slug}/`,
                label: "Previous session",
                title: previousItem.title,
              }
            : null
          : {
              href: "../../index.html#optional-modules",
              label: "Optional modules",
              title: "Return to optional modules",
            };
      const nextPage = nextChapter
        ? {
            href: nextChapter.file,
            label: "Next chapter",
            title: nextChapter.title,
          }
        : item.kind === "session"
          ? nextItem
            ? {
                href: `../${nextItem.slug}/`,
                label: "Next session",
                title: nextItem.title,
              }
            : {
                href: "../../index.html#program",
                label: "Program",
                title: "Return to all sessions",
              }
          : {
              href: "../../index.html#optional-modules",
              label: "Optional modules",
              title: "Return to optional modules",
            };

      await writeFile(
        join(output, chapter.file),
        pageTemplate({
          ...item,
          chapter,
          guide,
          nextPage,
          previousPage,
          sessionLinks,
        }),
        "utf8",
      );
    }
  }
};

const renderDecks = async ({ items, outputRoot }) => {
  for (const [index, item] of items.entries()) {
    console.log(
      `Rendering ${item.kind} deck ${index + 1}/${items.length}: ${item.slug}`,
    );

    await new Promise((resolve, reject) => {
      const child = spawn(
        marp,
        [
          "deck.md",
          "--theme-set",
          "assets/theme/ai-governance.css",
          "--html",
          "--allow-local-files",
          "--output",
          join(outputRoot, item.slug, "deck.html"),
        ],
        {
          cwd: item.source,
          stdio: "inherit",
        },
      );

      child.once("error", reject);
      child.once("exit", (code, signal) => {
        if (code === 0) {
          resolve();
          return;
        }

        reject(
          new Error(
            signal
              ? `Marp stopped after signal ${signal} while rendering ${item.slug}.`
              : `Marp exited with code ${code} while rendering ${item.slug}.`,
          ),
        );
      });
    });
  }
};

const arrowIcon = `<svg class="session-arrow" viewBox="0 0 20 20" aria-hidden="true"><path d="M4 10h11M11 6l4 4-4 4"></path></svg>`;

const renderServiceStrip = (services, iconPrefix = "assets/icons") =>
  `<ul class="service-strip" aria-label="Services in scope">${services
    .map(
      (service) =>
        `<li title="${escapeHtml(service.label)}"><img src="${iconPrefix}/${escapeHtml(service.icon)}" alt=""><span class="visually-hidden">${escapeHtml(service.label)}</span></li>`,
    )
    .join("")}</ul>`;

const renderSessionCard = (session) => {
  const searchable = [
    `Session ${String(session.number).padStart(2, "0")}`,
    session.title,
    session.controlObjective,
    ...session.implementationOutcomes,
    ...session.services.flatMap(({ id, label, category }) => [id, label, category]),
  ].join(" ");
  return `<a class="session-record" id="session-${session.number}" data-phase="${session.phase.key}" data-services="${session.services.map(({ id }) => id).join(" ")}" data-search="${escapeHtml(searchable)}" href="sessions/${session.slug}/" aria-label="Open Session ${session.number}: ${escapeHtml(session.title)}">
            <span class="session-number">${session.number}</span>
            <span class="session-core">
              <span class="session-service-label">${escapeHtml(session.phase.name)}</span>
              <span class="session-title">${escapeHtml(session.title)}</span>
              <span class="session-objective">${escapeHtml(session.controlObjective)}</span>
            </span>
            ${renderServiceStrip(session.services)}
            <span class="session-duration">${escapeHtml(session.durationShort)}</span>
            ${arrowIcon}
          </a>`;
};

const renderModuleCard = (module) => {
  return `<a class="module-record" role="listitem" href="modules/${module.slug}/" aria-label="Open optional module: ${escapeHtml(module.title)}">
            <span class="session-core">
              <span class="session-service-label">Optional module · ${escapeHtml(titleCase(module.mode))} mode</span>
              <span class="session-title">${escapeHtml(module.title)}</span>
              <span class="session-objective">${escapeHtml(module.controlObjective)}</span>
            </span>
            ${renderServiceStrip(module.services)}
            <span class="session-duration">${escapeHtml(module.durationShort)}</span>
            ${arrowIcon}
          </a>`;
};

const renderHomepage = ({ sessions, modules, serviceRegistry }) => {
  const totalHours = sessions.reduce(
    (sum, session) => sum + session.durationMinutes / 60,
    0,
  );
  const sessionServiceIds = new Set(
    sessions.flatMap(({ services }) => services.map(({ id }) => id)),
  );
  const sessionServices = serviceRegistry.services.filter(({ id }) =>
    sessionServiceIds.has(id),
  );
  const filterButtons = sessionServices
    .map((service) => {
      const count = sessions.filter(({ services }) =>
        services.some(({ id }) => id === service.id),
      ).length;
      return `<button type="button" data-tool-filter="${escapeHtml(service.id)}" aria-pressed="false">
                <img src="assets/icons/${escapeHtml(service.icon)}" alt="">
                <span>${escapeHtml(service.label)}</span>
                <small>${count}</small>
              </button>`;
    })
    .join("");
  const phases = [
    {
      key: "foundation",
      range: "1–6",
      label: "Governed foundation",
      sessions: sessions.filter(({ phase }) => phase.key === "foundation"),
    },
    {
      key: "runtime",
      range: "7–12",
      label: "Control live AI traffic",
      sessions: sessions.filter(({ phase }) => phase.key === "runtime"),
    },
    {
      key: "operations",
      range: "13–15",
      label: "Operate at scale",
      sessions: sessions.filter(({ phase }) => phase.key === "operations"),
    },
  ];
  const sessionCards = phases
    .map(
      (phase) => `<div class="phase-marker" id="phase-${phase.key}" data-phase-marker="${phase.key}">
            <span>${phase.range}</span><strong>${phase.label}</strong><small>${phase.sessions.length} sessions</small>
          </div>
          ${phase.sessions.map(renderSessionCard).join("\n")}`,
    )
    .join("\n");

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#032254">
    <meta name="description" content="A 15-session guided co-implementation series for practical Microsoft AI governance.">
    <title>Practical Microsoft AI Governance</title>
    <link rel="icon" href="assets/img/logo-mark.png" type="image/png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles.css">
    <script src="script.js" defer></script>
  </head>
  <body>
    <a class="skip-link" href="#main-content">Skip to content</a>
    <header class="site-header" data-header>
      <div class="site-header__inner">
        <a class="brand" href="#top" aria-label="RVAS AI Governance home"><img src="assets/img/logo-full.png" width="90" height="32" alt="RVAP, Real Value Acceleration Program"></a>
        <nav class="site-nav" id="primary-nav" aria-label="Primary navigation" data-primary-nav>
          <a href="#top" aria-current="page">Home</a>
          <a href="#approach">Method</a>
          <a href="#program">Sessions</a>
          <a href="#routes">Routes</a>
          <a href="#readiness">Pre-work</a>
          <a href="#optional-modules">Optional modules</a>
          <a href="sources.html">Sources</a>
        </nav>
        <div class="nav-actions">
          <button class="nav-icon-button" type="button" aria-label="Search sessions" data-jump-search><svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="6.5"></circle><path d="m16 16 4 4"></path></svg></button>
          <button class="nav-toggle" type="button" aria-label="Open navigation" aria-controls="primary-nav" aria-expanded="false" data-nav-toggle><span></span><span></span><span></span></button>
        </div>
      </div>
    </header>

    <main id="main-content">
      <section class="hero" id="top" aria-labelledby="hero-title">
        <div class="hero__inner">
          <div class="hero__copy">
            <p class="hero__eyebrow">RVAS · Microsoft AI governance</p>
            <h1 id="hero-title">Build the control. <span>Keep the implementation.</span></h1>
            <p class="hero__lead">Customer engineers implement each control in a sandbox or nonproduction tenant. The people who will operate it make the decisions, run the check, and keep the files.</p>
            <div class="hero__actions"><a class="button button--primary" href="#program">Browse the sessions <svg viewBox="0 0 20 20" aria-hidden="true"><path d="M4 10h11M11 6l4 4-4 4"></path></svg></a></div>
            <dl class="program-docket" aria-label="Program facts">
              <div><dd>${sessions.length}</dd><dt>Sessions</dt></div>
              <div><dd>${totalHours}</dd><dt>Working hours</dt></div>
              <div><dd>3</dd><dt>Phases</dt></div>
            </dl>
          </div>
          <aside class="program-outcome program-outcome--compact" aria-label="Customer-owned result">
            <p>Customer-owned result</p>
            <h2>A governed deployment your team can change safely.</h2>
            <ul>
              <li>A governed Microsoft Foundry deployment</li>
              <li>Source-controlled implementation files</li>
              <li>An observable check, with restore or removal ownership named in the runbook</li>
            </ul>
          </aside>
        </div>
      </section>

      <section class="section audience-section" aria-labelledby="audience-title">
        <div class="section-heading"><div><p class="section-kicker">Two ways into the same work</p><h2 id="audience-title">Read the program at the level you need.</h2></div></div>
        <div class="audience-lanes">
          <article><span>For leaders</span><h3>See the operating model and ownership.</h3><p>Review scope, dependencies, working time, and the decisions that stay with service, security, data, or release owners.</p><a href="#routes">Compare routes</a></article>
          <article><span>For practitioners</span><h3>Use the implementation as a field reference.</h3><p>Open any session for the guide, source-controlled files, safety gates, observable result, and restore or removal path.</p><a href="#program">Find a session</a></article>
        </div>
      </section>

      <section class="method-section" id="approach" aria-labelledby="approach-title">
        <div class="section">
          <div class="section-heading"><div><p class="section-kicker">Guided co-implementation</p><h2 id="approach-title">One control at a time, with its owner in the room.</h2><p>Standard mode implements the control and runs one observable check. Extended mode is reserved for work that needs an allowed path, a blocked or failure path, and a delivery-owner checkpoint.</p></div></div>
          <div class="method-grid">
            <article><span>Build</span><h3>Use production-shaped configuration.</h3><p>Customer engineers deploy through the approved change path. Reusable configuration and normal operating records stay in the customer repository.</p></article>
            <article><span>Check</span><h3>Observe a defined result.</h3><p>The listed control owner confirms the check. Consequential changes still require the appropriate service, security, data, or release owner.</p></article>
          </div>
          <div class="governance-note">
            <p><strong>Microsoft Foundry</strong> covers the project, models, agents, tools, evaluation, and tracing used in the build. <strong>Foundry Control Plane</strong> manages supported agents across accessible Azure projects. <strong>Microsoft Agent 365</strong> gives administrators a tenant-level registry and governance controls across platforms.</p>
            <p>LLMOps runs through Sessions 05, 11, and 13–15. AIOps keeps its narrower meaning: using AI to operate IT systems, which sits outside the default scope.</p>
          </div>
        </div>
      </section>

      <section class="section program" id="program" aria-labelledby="program-title">
        <div class="section-heading section-heading--program">
          <div><p class="section-kicker">Session catalog</p><h2 id="program-title">Browse all ${sessions.length} sessions.</h2><p>Phase, service, and text filters work together. Service selection is the only filter kept in the URL.</p></div>
          <p class="register-instruction">Optional modules stay outside this filter and the 15-session count.</p>
        </div>
        <div class="registry-controls">
          <div class="phase-filters" role="group" aria-label="Filter by phase">
            <button type="button" data-filter="all" aria-pressed="true">All phases</button>
            <button type="button" data-filter="foundation" aria-pressed="false">Foundation · 1–6</button>
            <button type="button" data-filter="runtime" aria-pressed="false">Live traffic · 7–12</button>
            <button type="button" data-filter="operations" aria-pressed="false">Operations · 13–15</button>
          </div>
          <label class="registry-search"><span>Search sessions</span><span class="registry-search__field"><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="8.5" cy="8.5" r="5.5"></circle><path d="m13 13 4 4"></path></svg><input type="search" autocomplete="off" placeholder="Title, control, outcome…" data-session-search></span></label>
        </div>
        <div class="tool-discovery">
          <div class="tool-discovery__head"><div><h3>Filter by tool</h3><p>Choose one tool. Counts show matching numbered sessions.</p></div><a href="service-map.html">View service map</a></div>
          <div class="tool-filters" role="group" aria-label="Filter by tool">
            <button type="button" data-tool-filter="all" aria-pressed="true"><span>All tools</span><small>${sessions.length}</small></button>
            ${filterButtons}
          </div>
        </div>
        <div class="registry-status"><output data-results-count aria-live="polite">${sessions.length} sessions shown</output><span>All session records remain available without JavaScript and in print.</span></div>
        <div class="session-register">${sessionCards}</div>
        <p class="empty-result" data-empty-state hidden>No session matches the selected phase, service, and search text.</p>
      </section>

      <section class="routes-section" id="routes" aria-labelledby="routes-title">
        <div class="section">
          <div class="section-heading"><div><p class="section-kicker">Route guidance</p><h2 id="routes-title">Keep the dependencies. Stop where your scope ends.</h2><p>The complete route produces the connected deployment across all ${sessions.length} sessions. A focused route includes the prerequisite sessions and leaves later, unrelated controls unimplemented.</p></div></div>
          <div class="route-choice">
            <div class="route-choice__primary"><div><h3>Complete build · ${totalHours} working hours</h3><p>Move from platform baseline to governed agent, live traffic controls, controlled release, and regional rehearsal.</p></div><ol class="route-choice__sequence"><li><span>1–6</span> Governed foundation</li><li><span>7–12</span> Live AI traffic controls</li><li><span>13–15</span> Operate at scale</li></ol><a class="button button--primary" href="#program">Browse all sessions</a></div>
            <details class="route-choice__alternatives" open><summary><span><strong>Focused routes</strong><small>Each route starts with its prerequisites</small></span><svg viewBox="0 0 20 20" aria-hidden="true"><path d="m5 8 5 5 5-5"></path></svg></summary>
              <div class="route-register"><div class="route-register__head"><span>Customer need</span><span>Session route</span></div>
                <div><strong>Governed pilot</strong><span><a href="#session-1">1–6 · Foundation to agent</a></span></div>
                <div><strong>Secure private platform</strong><span><a href="#session-1">1–7 · Foundation to gateway</a></span></div>
                <div><strong>API and MCP governance</strong><span><a href="#session-1">1–9 · Foundation to MCP</a></span></div>
                <div><strong>Data and compliance</strong><span><a href="#session-1">1–10 · Foundation to Purview</a></span></div>
                <div><strong>Security operations</strong><span><a href="#session-1">1–13 · Foundation to operations</a></span></div>
                <div><strong>LLMOps and release operations</strong><span><a href="#session-1">1–14 · Foundation to controlled promotion</a></span></div>
              </div>
            </details>
          </div>
        </div>
      </section>

      <section class="readiness-section" id="readiness" aria-labelledby="readiness-title">
        <div class="section">
          <div class="section-heading"><div><p class="section-kicker">Pre-work</p><h2 id="readiness-title">Set up the sandbox before Session 1.</h2><p>Missing prerequisites stop hands-on work before the first deployment.</p></div></div>
          <div class="readiness-grid">
            <article><span>Environment</span><h3>Dedicated sandbox</h3><p>Use an approved subscription and register the required resource providers.</p></article>
            <article><span>Source control</span><h3>Customer-owned repository</h3><p>Prepare the repository that will keep implementation files and decisions.</p></article>
            <article><span>Capacity</span><h3>Regions and quota checked</h3><p>Confirm service availability, quota, and any product entitlements.</p></article>
            <article><span>Access</span><h3>Named roles ready</h3><p>Give participants the time-bound access required by their selected sessions.</p></article>
            <article><span>Data</span><h3>Fictional test records</h3><p>Keep customer data out of the checks and evaluation examples.</p></article>
            <article><span>Scenario</span><h3>One bounded use case</h3><p>Use an internal policy assistant with one read-only MCP tool and one write action it must refuse.</p></article>
          </div>
        </div>
      </section>

      <section class="section optional-modules-section" id="optional-modules" aria-labelledby="optional-modules-title">
        <div class="section-heading"><div><p class="section-kicker">Optional modules</p><h2 id="optional-modules-title">Add architecture-specific work when you need it.</h2><p>These modules have their own chapter flow. They do not change session numbering, phases, or the ${sessions.length}-session count.</p></div></div>
        <div class="module-register" role="list">${modules.map(renderModuleCard).join("\n")}</div>
      </section>
    </main>

    <footer class="site-footer"><div class="site-footer__brand"><img src="assets/img/logo-full.png" width="84" height="30" alt="RVAP, Real Value Acceleration Program"><span>Practical Microsoft AI Governance</span></div><p>Check licensing, regional availability, preview status, and current product behavior before a production release.</p></footer>
  </body>
</html>`;
};

const renderServiceMap = ({ sessions, modules, serviceRegistry }) => {
  const rows = serviceRegistry.services
    .map((service) => {
      const matchingSessions = sessions.filter(({ services }) =>
        services.some(({ id }) => id === service.id),
      );
      const matchingModules = modules.filter(({ services }) =>
        services.some(({ id }) => id === service.id),
      );
      if (matchingSessions.length === 0 && matchingModules.length === 0) {
        return "";
      }
      const searchText = [
        service.label,
        service.category,
        ...matchingSessions.flatMap((session) => [
          `Session ${String(session.number).padStart(2, "0")}`,
          session.title,
        ]),
        ...matchingModules.flatMap((module) => ["Optional module", module.title]),
      ].join(" ");
      const sessionLinks = matchingSessions.length
        ? `<span class="map-count">${matchingSessions.length} ${matchingSessions.length === 1 ? "session" : "sessions"}</span><ul>${matchingSessions
            .map(
              (session) =>
                `<li><a href="sessions/${session.slug}/">Session ${String(session.number).padStart(2, "0")} · ${escapeHtml(session.title)}</a></li>`,
            )
            .join("")}</ul>`
        : '<span class="map-count">0 sessions</span><span class="map-none">None</span>';
      const moduleLinks = matchingModules.length
        ? `<span class="map-count">${matchingModules.length} ${matchingModules.length === 1 ? "module" : "modules"}</span><ul>${matchingModules
            .map(
              (module) =>
                `<li><a href="modules/${module.slug}/">${escapeHtml(module.title)}</a></li>`,
            )
            .join("")}</ul>`
        : '<span class="map-count">0 modules</span><span class="map-none">None</span>';
      const matchingLink = matchingSessions.length
        ? `<a href="index.html?tool=${encodeURIComponent(service.id)}#program">View matching sessions</a>`
        : '<span class="map-none">Optional modules only</span>';
      return `<tr data-service-row data-search="${escapeHtml(searchText)}">
              <th scope="row"><span class="map-service"><img src="assets/icons/${escapeHtml(service.icon)}" alt=""><span><strong>${escapeHtml(service.label)}</strong><small>${escapeHtml(service.category)}</small></span></span></th>
              <td>${sessionLinks}</td>
              <td>${moduleLinks}</td>
              <td>${matchingLink}</td>
            </tr>`;
    })
    .filter(Boolean);

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#032254">
    <meta name="description" content="Service-first map of the Practical Microsoft AI Governance sessions and optional modules.">
    <title>Service map | Practical Microsoft AI Governance</title>
    <link rel="icon" href="assets/img/logo-mark.png" type="image/png">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="styles.css">
    <script src="script.js" defer></script>
  </head>
  <body class="service-map-page">
    <a class="skip-link" href="#service-map">Skip to service map</a>
    <header class="site-header"><div class="site-header__inner"><a class="brand" href="index.html" aria-label="RVAS AI Governance home"><img src="assets/img/logo-full.png" width="90" height="32" alt="RVAP, Real Value Acceleration Program"></a><nav class="site-nav" id="primary-nav" aria-label="Primary navigation" data-primary-nav><a href="index.html">Home</a><a href="index.html#approach">Method</a><a href="index.html#program">Sessions</a><a href="index.html#routes">Routes</a><a href="index.html#readiness">Pre-work</a><a href="index.html#optional-modules">Optional modules</a><a href="sources.html">Sources</a></nav><div class="nav-actions"><button class="nav-toggle" type="button" aria-label="Open navigation" aria-controls="primary-nav" aria-expanded="false" data-nav-toggle><span></span><span></span><span></span></button></div></div></header>
    <main id="service-map">
      <section class="map-intro"><div class="section"><nav class="breadcrumb" aria-label="Breadcrumb"><a href="index.html#program">Session catalog</a><span aria-hidden="true">/</span><span>Service map</span></nav><p class="section-kicker">Service-first index</p><h1>Find every session and module for a service.</h1><p>The full table is available without JavaScript. Search narrows it by service, category, title, or session number.</p></div></section>
      <section class="section map-register" aria-labelledby="map-table-title">
        <div class="map-controls"><div><h2 id="map-table-title">Services in scope</h2><output data-service-map-count aria-live="polite">${rows.length} services shown</output></div><label class="registry-search"><span>Search service map</span><span class="registry-search__field"><svg viewBox="0 0 20 20" aria-hidden="true"><circle cx="8.5" cy="8.5" r="5.5"></circle><path d="m13 13 4 4"></path></svg><input type="search" autocomplete="off" placeholder="Service, category, title…" data-service-map-search></span></label></div>
        <div class="service-map-table"><table><thead><tr><th scope="col">Service</th><th scope="col">Numbered sessions</th><th scope="col">Optional modules</th><th scope="col">Discover</th></tr></thead><tbody>${rows.join("\n")}</tbody></table></div>
        <p class="empty-result" data-service-map-empty hidden>No service matches that search.</p>
      </section>
    </main>
    <footer class="site-footer"><div class="site-footer__brand"><img src="assets/img/logo-full.png" width="84" height="30" alt="RVAP, Real Value Acceleration Program"><span>Practical Microsoft AI Governance</span></div><p><a href="index.html#program">Return to the session catalog</a></p></footer>
  </body>
</html>`;
};

const generatedPaths = (items, outputRoot) =>
  items.flatMap(({ chapters, slug }) =>
    chapters.map(({ file }) => relative(root, join(outputRoot, slug, file))),
  );

const serviceRegistry = await loadServiceRegistry();
const sessions = await loadSessions(serviceRegistry);
const modules = await loadModules(serviceRegistry);
const sessionLinks = new Map(
  sessions.map((session) => [String(session.number).padStart(2, "0"), session.slug]),
);

await writeFile(
  join(siteRoot, "index.html"),
  renderHomepage({ sessions, modules, serviceRegistry }),
  "utf8",
);
await writeFile(
  join(siteRoot, "service-map.html"),
  renderServiceMap({ sessions, modules, serviceRegistry }),
  "utf8",
);

await buildCollection({
  items: sessions,
  outputRoot: sessionsOutputRoot,
  descriptorFile: "session.yaml",
});
await buildCollection({
  items: modules,
  outputRoot: modulesOutputRoot,
  descriptorFile: "module.yaml",
});

await renderDecks({ items: sessions, outputRoot: sessionsOutputRoot });
await renderDecks({ items: modules, outputRoot: modulesOutputRoot });

const generatedSessions = generatedPaths(sessions, sessionsOutputRoot);
const generatedModules = generatedPaths(modules, modulesOutputRoot);
console.log(
  `Generated ${generatedSessions.length} chapter pages for ${sessions.length} sessions in ${relative(root, sessionsOutputRoot)}.`,
);
console.log(
  `Generated ${generatedModules.length} chapter pages for ${modules.length} optional modules in ${relative(root, modulesOutputRoot)}.`,
);
console.log("Generated site/index.html and site/service-map.html from services and manifests.");
