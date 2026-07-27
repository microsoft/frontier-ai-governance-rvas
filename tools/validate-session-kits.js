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

function files(directory) {
  if (!fs.existsSync(directory)) {
    return [];
  }
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      return files(entryPath);
    }
    return entry.isFile() ? [entryPath] : [];
  });
}

for (const entry of fs.readdirSync(labsRoot, { withFileTypes: true })) {
  if (!entry.isDirectory()) {
    continue;
  }
  if (entry.name === "helpers" || entry.name === "templates") {
    continue;
  }

  const labPath = path.join(labsRoot, entry.name);
  const sessionId = entry.name.split("-")[0];
  const readme = path.join(labPath, "README.md");

  requireFile(readme, "lab entry point");
  requireFile(path.join(docsRoot, entry.name, "index.md"), "rendered session page");
  requireFile(path.join(docsRoot, entry.name, "practical.md"), "practical activity");

  for (const retiredFile of ["runbook.md", "verify.md", "rollback.md"]) {
    const retiredPath = path.join(labPath, retiredFile);
    if (fs.existsSync(retiredPath)) {
      failures.push(
        `Retired standalone ${retiredFile} remains in ${path.relative(root, retiredPath)}`,
      );
    }
  }
  if (fs.existsSync(readme)) {
    const content = fs.readFileSync(readme, "utf8");
    if (!content.includes("templates/decision-record.template.md")) {
      failures.push(
        `Lab entry point must link to its required decision record: ${path.relative(root, readme)}`,
      );
    }

    for (const material of markdownFiles(labPath)) {
      if (material === readme) {
        continue;
      }
      const materialPath = path.relative(labPath, material).split(path.sep).join("/");
      if (!content.includes(materialPath)) {
        failures.push(
          `Lab material is not called out by its entry point: ${path.relative(root, material)}`,
        );
      }
    }
  }

  if (!/^s(?:[0-9]|1[0-3])$/.test(sessionId)) {
    failures.push(`Unexpected session directory: ${path.relative(root, labPath)}`);
  }
}

const labsReadme = path.join(labsRoot, "README.md");
if (fs.existsSync(labsReadme)) {
  const indexContent = fs.readFileSync(labsReadme, "utf8");
  for (const helper of files(path.join(labsRoot, "helpers"))) {
    const helperPath = path.relative(labsRoot, helper).split(path.sep).join("/");
    if (!indexContent.includes(helperPath)) {
      failures.push(`Shared helper is not documented in labs/README.md: labs/${helperPath}`);
    }
  }
} else {
  failures.push("Missing lab helper index: labs/README.md");
}

const sharedDecisionTemplate = path.join(labsRoot, "templates", "decision-record.template.md");
requireFile(sharedDecisionTemplate, "shared decision record template");

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}

console.log("Session-kit structure is valid.");
