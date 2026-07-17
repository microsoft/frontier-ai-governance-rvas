// Renders every *.excalidraw in this folder to SVG + 2x PNG via render.mjs.
import { readdirSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";
import { spawnSync } from "child_process";

const here = dirname(fileURLToPath(import.meta.url));
const scenes = readdirSync(here)
  .filter((f) => f.endsWith(".excalidraw"))
  .sort();

let failed = 0;
for (const f of scenes) {
  const r = spawnSync(process.execPath, [resolve(here, "render.mjs"), resolve(here, f)], {
    stdio: "inherit",
  });
  if (r.status !== 0) failed++;
}
console.log(`\nrendered ${scenes.length - failed}/${scenes.length} scene(s)`);
if (failed) process.exit(1);
