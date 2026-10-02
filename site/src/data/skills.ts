export const repoUrl = "https://github.com/itsjustiago/skillsbase";

// ---- Skills (own ones are vendored, externals come from source) ----
export type GlobalSkill = {
  name: string;
  kind: "own" | "external";
  blurb: string;
  trigger?: string;
  /** Upstream repo, externals only. */
  source?: string;
};

export const globalGroups: { id: string; label: string; skills: GlobalSkill[] }[] = [
  {
    id: "kickoff",
    label: "Project kickoff",
    skills: [
      { name: "ui-ux-pro-max", kind: "external", source: "nextlevelbuilder/ui-ux-pro-max-skill", blurb: "Design direction for a new project: style, palette, type. Manual only, never auto-triggers.", trigger: "/ui-ux-pro-max" },
    ],
  },
  {
    id: "design",
    label: "Design",
    skills: [
      { name: "frontend-design", kind: "external", source: "anthropics/skills", blurb: "Aesthetic direction that avoids templated defaults. Fires on UI work." },
      { name: "impeccable", kind: "external", source: "pbakaus/impeccable", blurb: "Design process: critique, audit, polish.", trigger: "/impeccable" },
      { name: "emil-design-eng", kind: "external", source: "emilkowalski/skills", blurb: "Motion and the invisible details. Fires on UI work." },
      { name: "review-animations", kind: "external", source: "emilkowalski/skills", blurb: "Strict motion review. Default is to flag.", trigger: "/review-animations" },
    ],
  },
  {
    id: "engineering",
    label: "Engineering",
    skills: [
      { name: "systematic-debugging", kind: "external", source: "obra/superpowers", blurb: "Root cause before any fix.", trigger: "debug X" },
      { name: "verification-before-completion", kind: "external", source: "obra/superpowers", blurb: "Evidence before claiming done.", trigger: "verify" },
      { name: "supabase", kind: "external", source: "supabase/agent-skills", blurb: "Official Supabase guidance: auth, RLS, migrations, CLI." },
      { name: "supabase-postgres-best-practices", kind: "external", source: "supabase/agent-skills", blurb: "Postgres performance, the official way." },
    ],
  },
  {
    id: "quality",
    label: "Quality & security",
    skills: [
      { name: "browser-testing-with-devtools", kind: "external", source: "addyosmani/agent-skills", blurb: "Real-browser testing via the Chrome DevTools MCP: DOM, console, network." },
      { name: "security-and-hardening", kind: "external", source: "addyosmani/agent-skills", blurb: "Hardening for input, auth, storage and integrations." },
      { name: "core-web-vitals", kind: "external", source: "addyosmani/web-quality-skills", blurb: "Fixes for LCP, INP and CLS." },
      { name: "web-accessibility", kind: "external", source: "addyosmani/web-quality-skills", blurb: "WCAG 2.2 audits and fixes." },
      { name: "semgrep", kind: "external", source: "trailofbits/skills", blurb: "Static analysis scans with parallel subagents." },
      { name: "differential-review", kind: "external", source: "trailofbits/skills", blurb: "Security-focused review of PRs and diffs." },
      { name: "supply-chain-risk-auditor", kind: "external", source: "trailofbits/skills", blurb: "Flags dependencies at risk of takeover or exploitation." },
    ],
  },
  {
    id: "ship",
    label: "Ship & sessions",
    skills: [
      { name: "ship", kind: "own", blurb: "commit, push, open PR, in one shot.", trigger: "/ship" },
      { name: "ship-merge", kind: "own", blurb: "ship + CI wait + light review + squash-merge + cleanup.", trigger: "/ship-merge" },
      { name: "session-handoff", kind: "own", blurb: "A clean end-of-session handoff before /clear.", trigger: "wrap up session" },
    ],
  },
  {
    id: "discovery",
    label: "Discovery",
    skills: [
      { name: "skill-scout", kind: "own", blurb: "Finds new skills, plugins and MCPs in the wider ecosystem. Its add-to-catalog step has no catalog to write to right now." },
      { name: "skill-matchmaker", kind: "own", blurb: "Meant to install per-project skills from a catalog. There is no catalog at the moment, so it has nothing to read.", trigger: "/skills-suggest" },
      { name: "watch-youtube", kind: "own", blurb: "Transcript plus key frames from YouTube videos." },
    ],
  },
];

export const globalSkills: GlobalSkill[] = globalGroups.flatMap((g) => g.skills);

// ---- Agents (subagents in ~/.claude/agents) ----
export type Agent = {
  name: string;
  role: string;
  blurb: string;
  /** Highlighted as the one that builds. */
  writes?: boolean;
  /** Has Write/Edit among its tools (agents/*.md). */
  canEdit?: boolean;
};

export const agents: Agent[] = [
  { name: "engenheiro", role: "Builds", writes: true, canEdit: true, blurb: "Writes the code from a complete brief: features, fixes, UI, bulk edits. Prefers a worktree when it touches many files." },
  { name: "explorador", role: "Maps", blurb: "Finds where things live and returns file:line before anything is changed." },
  { name: "investigador", role: "Research", blurb: "Researches tools, repos and libraries; verifies claims and ranks options with sources." },
  { name: "revisor", role: "Review", blurb: "Reviews code before merge and points at concrete problems with file:line. No praise, no rewrites." },
  { name: "testador", role: "QA", blurb: "Runs the app for real: navigates, clicks, reads console and network, takes screenshots." },
  { name: "design", role: "Audit · read-only", blurb: "UI critique: hierarchy, tokens, type, spacing, motion, accessibility. Proposes fixes, never applies them." },
  { name: "seguranca", role: "Audit · read-only", blurb: "Security audit: exposed secrets, injection, authz, RLS, dependencies, public surfaces." },
  { name: "financas", role: "Money research", canEdit: true, blurb: "Portuguese tax and investing research from official sources, with auditable maths. No personal advice, no orders." },
];

// ---- Orchestrator model (see setup/CLAUDE.md) ----
export const orchestration = [
  { who: "Main session", what: "Talks to you, briefs the work and reviews the diff." },
  { who: "engenheiro", what: "Writes the code from the brief." },
  { who: "Other agents", what: "Map, research, review, test and audit. design and seguranca are strictly read-only." },
];

// ---- Hook, command, instructions, settings ----
export const plugins = ["security-guidance"];

export type Extra = {
  kind: "hook" | "command" | "instructions" | "settings";
  name: string;
  blurb: string;
};

export const extras: Extra[] = [
  { kind: "hook", name: "bloquear_kill_por_nome", blurb: "PreToolUse hook on Bash: blocks killing processes by name. Needs python3." },
  { kind: "command", name: "/skills-suggest", blurb: "Asks skill-matchmaker for per-project skills. With no catalog at the moment, it has nothing to suggest." },
  { kind: "instructions", name: "setup/CLAUDE.md", blurb: "The global ~/.claude/CLAUDE.md: language, git and ship rules, orchestrator mode." },
  { kind: "settings", name: "settings.json", blurb: `Created only if missing. Registers the hook and enables ${plugins.length} plugin (${plugins.join(", ")}).` },
];

// ---- Install: one prompt you paste into Claude ----
// Claude reads setup/AGENT-INSTALL.md, inspects the user's ~/.claude, and offers
// the modes below as a single question, then applies the one they pick.
export const smartInstall =
  "Set up the itsjustiago Claude Code build: clone https://github.com/itsjustiago/skillsbase and follow setup/AGENT-INSTALL.md — check what I already have in ~/.claude, show me the options, and install the one I pick.";

const ownCount = globalSkills.filter((s) => s.kind === "own").length;
const externalCount = globalSkills.length - ownCount;

export const stats = {
  skills: globalSkills.length,
  own: ownCount,
  external: externalCount,
  groups: globalGroups.length,
  agents: agents.length,
  hooks: extras.filter((e) => e.kind === "hook").length,
  commands: extras.filter((e) => e.kind === "command").length,
  plugins: plugins.length,
};

export type InstallMode = { label: string; blurb: string; recommended?: boolean };

export const installModes: InstallMode[] = [
  {
    label: "Skills only, on top",
    recommended: true,
    blurb: `Installs the ${stats.skills} skills, ${stats.agents} agents, the hook file and the command. Keeps your other skills, agents, plugins, CLAUDE.md and settings. Same-name items are replaced, with a backup in ~/.claude/backups/.`,
  },
  {
    label: "Skills + instructions",
    blurb: "Full bootstrap: everything above, and your CLAUDE.md is replaced (backup kept). Creates settings.json only if you have none.",
  },
  {
    label: "Match the build",
    blurb: "Installs everything, then removes the global skills, agents and hooks that aren't in the build. Also replaces your CLAUDE.md (backup kept). Never removes plugins or settings. Dry-run first, backup on apply.",
  },
  {
    label: "Instructions only",
    blurb: "Just the global CLAUDE.md, with a backup of your current one. Skills, agents and hooks untouched.",
  },
];

export const installNotes = [
  "Needs git and node, plus python3 for the hook. Restart Claude Code when it finishes.",
  "The instructions are the owner's: auto-merge and push without asking, written for \"Tiago\". Adapt them after installing.",
  "settings.json is never overwritten. Registering the hook is proposed, and only done with your OK.",
  "External skills are cloned from the upstream HEAD, unpinned by design. Review setup/install-externals.sh first.",
];
