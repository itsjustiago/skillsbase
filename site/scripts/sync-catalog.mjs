// Keeps the site in sync with the build: copies the repo-root catalog.json
// (single source of truth) into the app before dev/build. Runs via predev/prebuild.
import { copyFileSync, existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const src = join(here, "..", "..", "catalog.json"); // scripts/ -> site/ -> repo root
const dest = join(here, "..", "src", "data", "catalog.json");

// Locally, refresh the committed copy from the repo-root source of truth.
// On hosts that build only within site/ (e.g. Vercel with Root Directory =
// site/), the repo-root file is out of scope — fall back to the committed copy.
if (existsSync(src)) {
  copyFileSync(src, dest);
  console.log("[sync-catalog] catalog.json → src/data/catalog.json");
} else {
  console.log("[sync-catalog] repo-root catalog.json out of scope — using committed copy");
}
