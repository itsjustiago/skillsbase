import catalog from "./catalog.json";

export const repoUrl = "https://github.com/itsjustiago/skillsbase";

export type CatalogSkill = {
  name: string;
  path: string;
  description: string;
  tags: string[];
  project_types: string[];
  cost_tokens: number;
};

export const catalogSkills = catalog.skills as CatalogSkill[];

// ---- Families (derived from tags; first match wins, verified 62/62) ----
type FamilyDef = { id: string; label: string; blurb: string; keys: string[] };

export const FAMILY_DEFS: FamilyDef[] = [
  {
    id: "ai",
    label: "AI · Agents · LLM",
    blurb: "Agent harnesses, evals, RAG, the Claude API and MCP servers.",
    keys: ["agent", "agents", "llm", "mcp", "claude-api", "anthropic", "rag", "retrieval", "harness", "agent-harness", "evaluation", "eval", "research", "prompt-engineering", "prompt-caching", "tool-use", "synthesis", "learning", "iterative"],
  },
  {
    id: "security",
    label: "Security",
    blurb: "SAST, audits, supply-chain and variant analysis.",
    keys: ["security", "sast", "codeql", "semgrep", "sarif", "supply-chain", "scanning", "static-analysis", "variant-analysis", "insecure", "audit", "secrets", "hardcoded", "risk-assessment", "data-flow", "dependencies", "pattern-matching", "bug-hunting", "context-building"],
  },
  {
    id: "devops",
    label: "DevOps · Runtime · Git",
    blurb: "Deploys, Docker, the Bun runtime and Git workflow.",
    keys: ["deployment", "ci-cd", "docker", "container", "bun", "runtime", "package-manager", "git", "github", "pr", "workflow"],
  },
  {
    id: "testing",
    label: "Testing · Quality",
    blurb: "TDD, e2e, mutation & property-based testing, reviews.",
    keys: ["testing", "tdd", "test-driven-development", "e2e", "playwright", "mutation-testing", "property-based-testing", "pbt", "benchmark", "coverage", "code-review", "review", "dast", "browser-testing", "qa", "visual-testing", "metrics", "jest", "vitest", "best-practices", "quality"],
  },
  {
    id: "decks",
    label: "Presentations · Decks",
    blurb: "HTML pitch, product-launch and tech-sharing decks.",
    keys: ["presentation", "deck", "slides", "print-design", "editorial", "serif"],
  },
  {
    id: "design",
    label: "Design · UI · Web",
    blurb: "Landing pages, dashboards, mockups and Tailwind v4.",
    keys: ["design", "ui", "mockup", "landing-page", "html", "css", "tailwindcss", "tailwind-v4", "postcss", "wireframe", "low-fidelity", "prototype", "exploration", "sketch", "email", "carousel", "social", "invoice", "dashboard", "blog", "video", "brief", "planning", "discovery"],
  },
  {
    id: "backend",
    label: "Backend · Data · APIs",
    blurb: "APIs, Postgres, Drizzle, Supabase and storage.",
    keys: ["api", "rest", "graphql", "http", "status-codes", "rate-limiting", "pagination", "backend", "nodejs", "express", "database", "postgres", "sql", "drizzle", "neon", "prisma", "orm", "supabase", "storage", "blob", "uploads", "files", "cdn", "migration", "migrations", "serverless", "caching", "rls", "realtime", "architecture"],
  },
  {
    id: "frontend",
    label: "Frontend · React · Next",
    blurb: "React 19, the Next App Router, PWAs and auth.",
    keys: ["react", "react-19", "nextjs", "app-router", "ssr", "server-components", "server-actions", "hooks", "actions", "forms", "state-management", "accessibility", "component-patterns", "frontend", "pwa", "service-worker", "manifest", "mobile", "ios", "android", "jwt", "jose", "auth", "cookies", "middleware", "bcrypt", "turbopack", "webpack", "bundler", "dev-tools", "build"],
  },
];

export function familyOf(tags: string[]): string {
  for (const f of FAMILY_DEFS) {
    if (tags.some((t) => f.keys.includes(t))) return f.id;
  }
  return "other";
}

export type Family = FamilyDef & { count: number; skills: CatalogSkill[] };

export const families: Family[] = FAMILY_DEFS.map((f) => {
  const skills = catalogSkills
    .filter((s) => familyOf(s.tags) === f.id)
    .sort((a, b) => a.name.localeCompare(b.name));
  return { ...f, count: skills.length, skills };
});

// ---- Global skills (always on; from global-skills/ + install-externals) ----
export type GlobalSkill = {
  name: string;
  kind: "own" | "external";
  blurb: string;
  trigger?: string;
};

export const globalGroups: { id: string; label: string; skills: GlobalSkill[] }[] = [
  {
    id: "kickoff",
    label: "Project kickoff",
    skills: [
      { name: "ui-ux-pro-max", kind: "external", blurb: "Design direction from a real database — 67 styles, 161 palettes, 57 font pairs.", trigger: "/ui-ux-pro-max" },
    ],
  },
  {
    id: "design",
    label: "Design",
    skills: [
      { name: "frontend-design", kind: "external", blurb: "Aesthetic direction — fires automatically on UI work." },
      { name: "impeccable", kind: "external", blurb: "Design process: critique → audit → polish. 23 commands.", trigger: "/impeccable" },
      { name: "emil-design-eng", kind: "external", blurb: "Motion and the invisible details — fires on UI work." },
      { name: "review-animations", kind: "external", blurb: "Strict motion review.", trigger: "/review-animations" },
    ],
  },
  {
    id: "engineering",
    label: "Engineering",
    skills: [
      { name: "systematic-debugging", kind: "external", blurb: "Root cause before any fix.", trigger: "debug X" },
      { name: "verification-before-completion", kind: "external", blurb: "Evidence before claiming done.", trigger: "verify" },
      { name: "supabase", kind: "external", blurb: "Official Supabase guidance — fires on Supabase work." },
      { name: "supabase-postgres-best-practices", kind: "external", blurb: "Postgres performance, the official way." },
    ],
  },
  {
    id: "ship",
    label: "Ship & sessions",
    skills: [
      { name: "ship", kind: "own", blurb: "commit → push → open PR, in one shot.", trigger: "/ship" },
      { name: "ship-merge", kind: "own", blurb: "ship + CI wait + light review + squash-merge + cleanup.", trigger: "/ship-merge" },
      { name: "session-handoff", kind: "own", blurb: "A clean end-of-session handoff before /clear.", trigger: "wrap up session" },
    ],
  },
  {
    id: "catalog",
    label: "Catalog engine",
    skills: [
      { name: "skill-matchmaker", kind: "own", blurb: "Installs catalog skills that match a project's stack.", trigger: "/skills-suggest" },
      { name: "skill-scout", kind: "own", blurb: "Finds new skills, plugins and MCPs in the wider ecosystem." },
    ],
  },
];

export const globalSkills: GlobalSkill[] = globalGroups.flatMap((g) => g.skills);

// ---- Install: prompts you paste into Claude ----
export type InstallCommand = {
  id: string;
  label: string;
  blurb: string;
  prompt: string;
};

export const installCommands: InstallCommand[] = [
  {
    id: "everything",
    label: "Everything",
    blurb: "Skills + instructions + slash commands. The full bootstrap.",
    prompt:
      "Clone https://github.com/itsjustiago/skillsbase and run `bash setup.sh` — install the 14 global skills, the global CLAUDE.md and the slash commands, then tell me what changed and remind me to restart Claude Code.",
  },
  {
    id: "skills",
    label: "Skills only",
    blurb: "Just the global skills. Leaves your instructions untouched.",
    prompt:
      "From github.com/itsjustiago/skillsbase, install only the global skills (`global-skills/` → `~/.claude/skills/`). Don't touch my CLAUDE.md or settings. List what you added.",
  },
  {
    id: "instructions",
    label: "Instructions only",
    blurb: "Just the global CLAUDE.md, with a backup of your current one.",
    prompt:
      "Install only the global CLAUDE.md from skillsbase (`setup/CLAUDE.md` → `~/.claude/CLAUDE.md`), backing up my existing one first. No skills.",
  },
];

export const secondaryCommands: InstallCommand[] = [
  {
    id: "sync",
    label: "Match this machine to the repo",
    blurb: "Reconcile an existing machine — dry run first.",
    prompt:
      "Make this machine match skillsbase exactly: run `bash sync.sh` (dry run), show me the diff, and apply it only if I say OK.",
  },
  {
    id: "per-project",
    label: "Add per-project skills",
    blurb: "Let the matchmaker pick catalog skills for a project.",
    prompt:
      "Run /skills-suggest — pick the catalog skills that match this project's stack and install them into .claude/skills/.",
  },
];

export const stats = {
  global: globalSkills.length,
  catalog: catalogSkills.length,
  families: FAMILY_DEFS.length,
  plugins: 0,
  hooks: 0,
};
