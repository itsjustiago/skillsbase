import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { plugins, repoUrl, stats } from "@/data/skills";

const figures = [
  { n: stats.skills, l: "global skills" },
  { n: stats.agents, l: "agents" },
  { n: stats.external, l: "pulled from source" },
  { n: stats.hooks, l: "hooks" },
];

const principles = [
  {
    t: "Files, not plugins",
    d: `Skills, agents, the hooks and the instructions are plain files in ~/.claude. It works on the desktop app without the claude CLI on PATH, and updating means re-running a script. The only plugin is ${plugins[0]}, enabled by the bundled settings.json when you have none.`,
  },
  {
    t: "Third parties from source",
    d: `The ${stats.external} external skills are never vendored. install-externals.sh clones each upstream at install time, so authors and licenses stay theirs and updates are a re-run.`,
  },
  {
    t: "Orchestrator model",
    d: "One main session briefs and reviews. The engenheiro agent writes the code; the read-only agents map, review, test and audit it.",
  },
  {
    t: "Safe by default",
    d: "Two light hooks: one blocks killing processes by name, one restores the session state on start. No per-edit hooks to add latency. Setup is additive, sync is a dry-run until --apply, every replace leaves a backup and settings.json is never overwritten.",
  },
];

export function HowItsMade() {
  return (
    <section id="how" className="py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            eyebrow="How it's made"
            title={
              <>
                Plain files, <span className="text-violet">pulled from source</span>.
              </>
            }
            intro="Rebuilt from scratch as files. The per-project catalog, the install profiles and the heavy MCP set are gone: everything left has to earn its start-up cost."
          />
        </Reveal>

        <Reveal>
          <div className="mt-12 grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-line bg-line sm:grid-cols-4">
            {figures.map((s) => (
              <div key={s.l} className="bg-white p-6 text-center">
                <div className="font-display text-[38px] font-extrabold leading-none tracking-tight tabular-nums">
                  {s.n}
                </div>
                <div className="mt-2 font-mono text-[11px] uppercase tracking-wider text-ink-soft">
                  {s.l}
                </div>
              </div>
            ))}
          </div>
        </Reveal>

        <div className="mt-5 grid gap-4 sm:grid-cols-2">
          {principles.map((p, i) => (
            <Reveal key={p.t} delay={i * 0.06}>
              <div className="h-full rounded-2xl border border-line bg-white p-7">
                <h3 className="font-display text-[19px] font-bold tracking-tight">
                  {p.t}
                </h3>
                <p className="mt-2.5 text-[14px] leading-relaxed text-ink-soft">
                  {p.d}
                </p>
              </div>
            </Reveal>
          ))}
        </div>

        <p className="mt-8 text-[14px] text-ink-soft">
          The full reasoning, what was cut and why, lives in{" "}
          <a
            href={`${repoUrl}/blob/main/DECISIONS.md`}
            target="_blank"
            rel="noreferrer"
            className="font-semibold text-violet underline-offset-4 hover:underline"
          >
            DECISIONS.md
          </a>
          ; the install logic is{" "}
          <a
            href={`${repoUrl}/blob/main/setup.sh`}
            target="_blank"
            rel="noreferrer"
            className="font-semibold text-violet underline-offset-4 hover:underline"
          >
            setup.sh
          </a>
          , and the overview is the{" "}
          <a
            href={`${repoUrl}/blob/main/README.md`}
            target="_blank"
            rel="noreferrer"
            className="font-semibold text-violet underline-offset-4 hover:underline"
          >
            README.md
          </a>
          .
        </p>
      </Container>
    </section>
  );
}
