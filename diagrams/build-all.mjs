// Runs every build-*.mjs in this folder (skips build-all.mjs itself).
import { readdirSync } from "fs";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";

const here = dirname(fileURLToPath(import.meta.url));
const scripts = readdirSync(here)
  .filter((f) => /^build-.+\.mjs$/.test(f) && f !== "build-all.mjs")
  .sort();

for (const f of scripts) {
  await import(resolve(here, f));
}
console.log(`\nbuilt ${scripts.length} diagram source(s)`);
