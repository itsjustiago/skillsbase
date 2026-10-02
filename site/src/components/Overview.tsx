import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { agents, extras, stats } from "@/data/skills";

function Check() {
  return (
    <span className="mt-0.5 grid h-4 w-4 shrink-0 place-items-center rounded-full bg-[#ece9ff] text-violet">
      <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
        <path d="M20 6 9 17l-5-5" />
      </svg>
    </span>
  );
}

const cards = [
  {
    label: "Global · always on",
    title: `${stats.skills} skills`,
    body: "Plain files in ~/.claude/skills, available the moment you open any project.",
    points: [
      `${stats.own} written by us, vendored in the repo`,
      `${stats.external} pulled from their authors' repos at install`,
      `${stats.groups} groups, from kickoff to quality & security`,
    ],
  },
  {
    label: "Subagents",
    title: `${stats.agents} agents`,
    body: "One writes the code; the others map, research, review, test and audit. financas covers Portuguese tax and money.",
    points: [
      `${agents.filter((a) => a.canEdit).length} have edit tools: engenheiro writes code, financas writes research notes`,
      `${agents.filter((a) => !a.canEdit).length} have none: they map, research, review, test and audit`,
      "Prompts are written in Portuguese",
    ],
  },
  {
    label: "Guardrails + instructions",
    title: `${extras.length} pieces`,
    body: "Rules that apply in every session, from the hook to the global CLAUDE.md.",
    points: extras.map((e) => `${e.kind}: ${e.name}`),
  },
];

export function Overview() {
  return (
    <section id="build" className="py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            align="center"
            eyebrow="The build"
            title={
              <>
                What one <span className="text-violet">clone</span> gives you.
              </>
            }
            intro="Skills, agents and guardrails, all in one repo. Paste one prompt on a new machine and Claude is configured."
          />
        </Reveal>

        <div className="mt-14 grid gap-5 lg:grid-cols-3">
          {cards.map((c) => (
            <Reveal key={c.label}>
              <div className="h-full rounded-2xl border border-line bg-white p-8">
                <span className="font-mono text-[12px] uppercase tracking-[0.14em] text-violet">
                  {c.label}
                </span>
                <h3 className="mt-4 font-display text-[26px] font-bold leading-tight tracking-tight">
                  {c.title}
                </h3>
                <p className="mt-3 text-[15px] leading-relaxed text-ink-soft">
                  {c.body}
                </p>
                <ul className="mt-6 grid gap-2.5">
                  {c.points.map((p) => (
                    <li key={p} className="flex items-start gap-2.5 break-words text-[14px] text-ink-soft">
                      <Check />
                      <span className="min-w-0">{p}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </Reveal>
          ))}
        </div>
      </Container>
    </section>
  );
}
