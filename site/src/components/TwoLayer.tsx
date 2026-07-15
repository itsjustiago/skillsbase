import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { stats } from "@/data/skills";

const layers = [
  {
    label: "Global · always on",
    title: `${stats.global} skills + your instructions`,
    body: "Copied into ~/.claude by setup.sh. Available the moment you open any project — kickoff, design, engineering, ship & sessions.",
    points: ["14 skills, 5 of them your own", "The global CLAUDE.md", "Slash commands", "Set up once"],
  },
  {
    label: "Per-project · on demand",
    title: `A ${stats.catalog}-skill catalog`,
    body: "The matchmaker reads a project's stack and installs only the skills it needs into .claude/skills/ — so your context never carries what it isn't using.",
    points: ["62 catalog skills", "Matched to your stack", "Loaded per project", "Run /skills-suggest"],
  },
];

export function TwoLayer() {
  return (
    <section className="py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            align="center"
            eyebrow="The model"
            title={
              <>
                Two layers, one <span className="text-violet">clone</span>.
              </>
            }
            intro="Global skills are always on. The catalog installs per project, only where it's needed — the build stays fast and the context stays lean."
          />
        </Reveal>

        <div className="mt-14 grid gap-5 md:grid-cols-2">
          {layers.map((l, i) => (
            <Reveal key={l.label} delay={i * 0.08}>
              <div className="h-full rounded-2xl border border-line bg-white p-8">
                <span className="font-mono text-[12px] uppercase tracking-[0.14em] text-violet">
                  {l.label}
                </span>
                <h3 className="mt-4 font-display text-[26px] font-bold leading-tight tracking-tight">
                  {l.title}
                </h3>
                <p className="mt-3 text-[15px] leading-relaxed text-ink-soft">
                  {l.body}
                </p>
                <ul className="mt-6 grid gap-2.5">
                  {l.points.map((p) => (
                    <li key={p} className="flex items-center gap-2.5 text-[14px] text-ink-soft">
                      <span className="grid h-4 w-4 place-items-center rounded-full bg-[#ece9ff] text-violet">
                        <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
                          <path d="M20 6 9 17l-5-5" />
                        </svg>
                      </span>
                      {p}
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
