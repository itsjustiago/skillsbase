// Keeps the site in sync with the build: copies the repo-root catalog.json
// (single source of truth) into the app before dev/build. Runs via predev/prebuild.
import { copyFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const src = join(here, "..", "..", "catalog.json"); // scripts/ -> site/ -> repo root
const dest = join(here, "..", "src", "data", "catalog.json");

copyFileSync(src, dest);
console.log("[sync-catalog] catalog.json → src/data/catalog.json");
