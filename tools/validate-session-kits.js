#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const labsRoot = path.join(root, "labs");
const docsRoot = path.join(root, "docs");
const failures = [];

function requireFile(filePath, description) {
  if (!fs.existsSync(filePath)) {
    failures.push(`Missing ${description}: ${path.relative(root, filePath)}`);
  }
}

function markdownFiles(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      return markdownFiles(entryPath);
    }
    return entry.isFile() && entry.name.endsWith(".md") ? [entryPath] : [];
  });
}

for (const entry of fs.readdirSync(labsRoot, { withFileTypes: true })) {
  if (!entry.isDirectory()) {
    continue;
  }

  const labPath = path.join(labsRoot, entry.name);
  const sessionId = entry.name.split("-")[0];
  const readme = path.join(labPath, "README.md");
  const runbook = path.join(labPath, "runbook.md");

  requireFile(readme, "lab entry point");
  requireFile(runbook, "lab runbook");
  requireFile(path.join(docsRoot, entry.name, "index.md"), "rendered session page");
  requireFile(path.join(docsRoot, entry.name, "practical.md"), "practical activity");
  requireFile(path.join(docsRoot, entry.name, "facilitate.md"), "facilitation guide");

  for (const retiredFile of ["verify.md", "rollback.md"]) {
    const retiredPath = path.join(labPath, retiredFile);
    if (fs.existsSync(retiredPath)) {
      failures.push(
        `Retired standalone ${retiredFile} remains in ${path.relative(root, retiredPath)}`,
      );
    }
  }

  if (fs.existsSync(readme)) {
    const content = fs.readFileSync(readme, "utf8");
    if (!content.includes("runbook.md")) {
      failures.push(
        `Lab entry point must link to its runbook: ${path.relative(root, readme)}`,
      );
    }

    const runbookContent = fs.existsSync(runbook) ? fs.readFileSync(runbook, "utf8") : "";
    for (const material of markdownFiles(labPath)) {
      if (material === readme) {
        continue;
      }
      const materialPath = path.relative(labPath, material).split(path.sep).join("/");
      if (!content.includes(materialPath) && !runbookContent.includes(materialPath)) {
        failures.push(
          `Lab material is not called out by its entry point or runbook: ${path.relative(root, material)}`,
        );
      }
    }
  }

  if (!/^s(?:[0-9]|1[0-3])$/.test(sessionId)) {
    failures.push(`Unexpected session directory: ${path.relative(root, labPath)}`);
  }
}

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log("Session-kit structure is valid.");
