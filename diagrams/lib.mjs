// Shared builder + palette for AI Governance Platform Excalidraw diagrams.
// Aligned to the site's indigo Material theme (docs/assets/extra.css).
import { writeFileSync } from "fs";

export const C = {
  // semantic fill / stroke / text triples
  indigo:  { bg: "#e0e7ff", st: "#4338ca", tx: "#312e81" },
  hero:    { bg: "#c7d2fe", st: "#3730a3", tx: "#1e1b4b" },
  identity:{ bg: "#dbeafe", st: "#1d4ed8", tx: "#1e3a8a" },
  data:    { bg: "#cffafe", st: "#0e7490", tx: "#155e63" },
  security:{ bg: "#fee2e2", st: "#dc2626", tx: "#7f1d1d" },
  amber:   { bg: "#fef3c7", st: "#d97706", tx: "#78350f" },
  eval:    { bg: "#ede9fe", st: "#7c3aed", tx: "#4c1d95" },
  advers:  { bg: "#ffe4e6", st: "#e11d48", tx: "#881337" },
  found:   { bg: "#f1f5f9", st: "#475569", tx: "#334155" },
  start:   { bg: "#dcfce7", st: "#16a34a", tx: "#14532d" },
  neutral: { bg: "#f8fafc", st: "#64748b", tx: "#334155" },
  none:    { bg: "transparent", st: "#1e1e1e", tx: "#1e1e1e" },
};

const FONT = 2; // Excalidraw normal (Nunito) — best legibility for prose labels
const LH = 1.25;
let SEED = 1000;
const seed = () => (SEED += 7);

export function scene(elements) {
  return {
    type: "excalidraw",
    version: 2,
    source: "rvas",
    elements,
    appState: { viewBackgroundColor: "#ffffff", gridSize: null },
    files: {},
  };
}

export function write(path, elements) {
  writeFileSync(path, JSON.stringify(scene(elements), null, 2));
  console.log("wrote", path, "(" + elements.length + " els)");
}

function base(type, x, y, w, h, color, extra = {}) {
  return {
    id: extra.id || type + "_" + seed(),
    type, x, y, width: w, height: h, angle: 0,
    strokeColor: color.st, backgroundColor: color.bg,
    fillStyle: "solid", strokeWidth: 2, strokeStyle: "solid",
    roughness: 0, opacity: 100, seed: seed(),
    roundness: extra.roundness === null ? null : { type: 3 },
    groupIds: [], frameId: null, boundElements: [], link: null, locked: false,
    ...extra,
  };
}

export const rect = (x, y, w, h, color, extra) => base("rectangle", x, y, w, h, color, extra);
export const ellipse = (x, y, w, h, color, extra) => base("ellipse", x, y, w, h, color, { roundness: null, ...extra });
export const diamond = (x, y, w, h, color, extra) => base("diamond", x, y, w, h, color, { roundness: null, ...extra });

// free-floating / centered text block
export function text(x, y, w, str, color, opts = {}) {
  const size = opts.size || 16;
  const lines = str.split("\n").length;
  return {
    id: opts.id || "t_" + seed(),
    type: "text", x, y, width: w, height: size * LH * lines, angle: 0,
    strokeColor: (color && color.tx) || color || "#1e1e1e",
    backgroundColor: "transparent", fillStyle: "solid", strokeWidth: 1,
    strokeStyle: "solid", roughness: 0, opacity: 100, seed: seed(),
    roundness: null, groupIds: [], frameId: null, boundElements: [], link: null, locked: false,
    fontSize: size, fontFamily: opts.family || FONT,
    textAlign: opts.align || "center", verticalAlign: "top",
    text: str, originalText: str, lineHeight: LH, baseline: size,
    containerId: null,
  };
}

// centered label inside a box at (bx,by,bw,bh)
export function labelIn(bx, by, bw, bh, str, color, opts = {}) {
  const size = opts.size || 16;
  const lines = str.split("\n").length;
  const th = size * LH * lines;
  const ty = by + (bh - th) / 2;
  return text(bx, ty, bw, str, color, { ...opts, align: "center" });
}

// arrow from (x1,y1) to (x2,y2); pts optional extra waypoints (relative)
export function arrow(x1, y1, x2, y2, opts = {}) {
  const points = opts.points || [[0, 0], [x2 - x1, y2 - y1]];
  return {
    id: opts.id || "a_" + seed(),
    type: "arrow", x: x1, y: y1,
    width: Math.abs(x2 - x1), height: Math.abs(y2 - y1), angle: 0,
    strokeColor: opts.stroke || "#475569", backgroundColor: "transparent",
    fillStyle: "solid", strokeWidth: opts.strokeWidth || 2,
    strokeStyle: opts.dashed ? "dashed" : "solid",
    roughness: 0, opacity: 100, seed: seed(),
    roundness: opts.curved === false ? null : { type: 2 },
    groupIds: [], frameId: null, boundElements: [], link: null, locked: false,
    points, lastCommittedPoint: null,
    startBinding: null, endBinding: null,
    startArrowhead: null, endArrowhead: opts.endArrowhead === null ? null : "arrow",
  };
}

// Draw a rounded rect with a centered title (and optional subtitle stacked below).
// Returns geometry { x, y, w, h, cx, cy, r, b } for connecting arrows to edges.
export function node(els, x, y, w, h, color, title, opts = {}) {
  els.push(rect(x, y, w, h, color, opts.rectExtra || {}));
  const tSize = opts.titleSize || 15;
  if (opts.sub) {
    const titleLines = title.split("\n").length;
    els.push(text(x + 6, y + 14, w - 12, title, color, { size: tSize }));
    const subY = y + 14 + titleLines * tSize * LH + 6;
    els.push(text(x + 6, subY, w - 12, opts.sub, color, { size: opts.subSize || 12.5 }));
  } else {
    els.push(labelIn(x, y, w, h, title, color, { size: tSize }));
  }
  return { x, y, w, h, cx: x + w / 2, cy: y + h / 2, r: x + w, b: y + h };
}

// Connect two node geometries edge-to-edge, choosing the nearest faces so the
// arrowhead lands on a box border (no floating / disconnected arrows).
export function connect(els, a, b, opts = {}) {
  const dx = b.cx - a.cx, dy = b.cy - a.cy;
  let x1, y1, x2, y2;
  if (Math.abs(dx) >= Math.abs(dy)) {
    if (dx >= 0) { x1 = a.r; y1 = a.cy; x2 = b.x; y2 = b.cy; }
    else { x1 = a.x; y1 = a.cy; x2 = b.r; y2 = b.cy; }
  } else {
    if (dy >= 0) { x1 = a.cx; y1 = a.b; x2 = b.cx; y2 = b.y; }
    else { x1 = a.cx; y1 = a.y; x2 = b.cx; y2 = b.b; }
  }
  els.push(arrow(x1, y1, x2, y2, { curved: false, ...opts }));
}

export function line(x1, y1, x2, y2, opts = {}) {
  const points = opts.points || [[0, 0], [x2 - x1, y2 - y1]];
  return {
    id: opts.id || "l_" + seed(),
    type: "line", x: x1, y: y1,
    width: Math.abs(x2 - x1), height: Math.abs(y2 - y1), angle: 0,
    strokeColor: opts.stroke || "#94a3b8", backgroundColor: "transparent",
    fillStyle: "solid", strokeWidth: opts.strokeWidth || 1,
    strokeStyle: opts.dashed ? "dashed" : "solid",
    roughness: 0, opacity: 100, seed: seed(),
    roundness: opts.curved ? { type: 2 } : null,
    groupIds: [], frameId: null, boundElements: [], link: null, locked: false,
    points, lastCommittedPoint: null,
    startBinding: null, endBinding: null, startArrowhead: null, endArrowhead: null,
  };
}
