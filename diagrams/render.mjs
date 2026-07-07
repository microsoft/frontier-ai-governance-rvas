import { chromium } from "playwright";
import { readFileSync, writeFileSync } from "fs";
import { resolve } from "path";

const input = process.argv[2];
if (!input) {
  console.error("usage: node render.mjs <file.excalidraw> [out.svg]");
  process.exit(1);
}
const out = process.argv[3] || input.replace(/\.excalidraw$/, ".svg");
const pngOut = out.replace(/\.svg$/, ".png");
const data = JSON.parse(readFileSync(input, "utf8"));

const html = `<!doctype html><html><head><meta charset="utf-8"></head>
<body><script type="module">
  try {
    const mod = await import("https://esm.sh/@excalidraw/excalidraw@0.17.6");
    window.__ex = mod.default;
    window.__ready = true;
  } catch (e) {
    window.__err = String(e && e.stack || e);
  }
</script></body></html>`;

const browser = await chromium.launch();
const page = await browser.newPage();
page.on("pageerror", (e) => console.log("[pageerror]", e.message));
await page.setContent(html, { waitUntil: "networkidle" });
await page.waitForFunction("window.__ready === true || window.__err", { timeout: 60000 });
const err = await page.evaluate("window.__err");
if (err) { console.error("IMPORT ERROR:\n" + err); await browser.close(); process.exit(1); }

const { svg, png } = await page.evaluate(async (scene) => {
  const ex = window.__ex;
  const elements = ex.restoreElements(scene.elements, null);
  const common = {
    elements,
    appState: { ...scene.appState, exportBackground: false, exportWithDarkMode: false },
    files: scene.files || {},
    exportPadding: 24,
  };
  const svgEl = await ex.exportToSvg(common);
  const blob = await ex.exportToBlob({ ...common, mimeType: "image/png", getDimensions: (w, h) => ({ width: w * 2, height: h * 2, scale: 2 }) });
  const b64 = await new Promise((res) => {
    const r = new FileReader();
    r.onload = () => res(r.result.split(",")[1]);
    r.readAsDataURL(blob);
  });
  return { svg: svgEl.outerHTML, png: b64 };
}, data);

writeFileSync(resolve(out), svg, "utf8");
writeFileSync(resolve(pngOut), Buffer.from(png, "base64"));
console.log("wrote", out, "and", pngOut);
await browser.close();
