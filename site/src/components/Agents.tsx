import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { agents, orchestration, extras } from "@/data/skills";

export function Agents() {
  return (
    <section id="agents" className="py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            eyebrow="Orchestrator model"
            title={
              <>
                One briefs. <span className="text-violet">One</span> builds.
              </>
            }
            intro="The main session briefs and reviews. The engenheiro writes the code; the other agents map, research, review, test and audit it."
          />
        </Reveal>

        <Reveal>
          <ol className="mt-12 grid gap-3 lg:grid-cols-3">
            {orchestration.map((o, i) => (
              <li
                key={o.who}
                className="flex items-start gap-4 rounded-2xl border border-line bg-white p-5"
              >
                <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-violet font-mono text-[12px] font-bold text-white">
                  {i + 1}
                </span>
                <div className="min-w-0">
                  <h3 className="font-display text-[15px] font-bold tracking-tight">
                    {o.who}
                  </h3>
                  <p className="mt-1.5 text-[13px] leading-relaxed text-ink-soft">
                    {o.what}
                  </p>
                </div>
              </li>
            ))}
          </ol>
        </Reveal>

        <h3 className="mb-5 mt-16 font-mono text-[12px] uppercase tracking-[0.14em] text-muted">
          The {agents.length} subagents
        </h3>
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {agents.map((a) => (
            <Reveal key={a.name}>
              <div className="h-full rounded-2xl border border-line bg-white p-5">
                <div className="flex flex-wrap items-center justify-between gap-x-2 gap-y-1.5">
                  <h4 className="whitespace-nowrap font-display text-[15px] font-bold tracking-tight">
                    {a.name}
                  </h4>
                  <span
                    className={`shrink-0 rounded px-1.5 py-0.5 font-mono text-[11px] uppercase tracking-wider ${
                      a.writes
                        ? "bg-[#ece9ff] text-violet-deep"
                        : "border border-line text-ink-soft"
                    }`}
                  >
                    {a.role}
                  </span>
                </div>
                <p className="mt-2 text-[13px] leading-relaxed text-ink-soft">
                  {a.blurb}
                </p>
              </div>
            </Reveal>
          ))}
        </div>

        <Reveal>
          <h3 className="mb-5 mt-16 font-mono text-[12px] uppercase tracking-[0.14em] text-muted">
            Guardrails &amp; instructions
          </h3>
          <ul className="grid gap-4 sm:grid-cols-2">
            {extras.map((e) => (
              <li
                key={e.name}
                className="rounded-2xl border border-line bg-white p-5"
              >
                <div className="flex flex-wrap items-center justify-between gap-x-2 gap-y-1.5">
                  <h4 className="min-w-0 break-words font-display text-[15px] font-bold tracking-tight">
                    {e.name}
                  </h4>
                  <span className="shrink-0 rounded border border-line px-1.5 py-0.5 font-mono text-[11px] uppercase tracking-wider text-ink-soft">
                    {e.kind}
                  </span>
                </div>
                <p className="mt-2 text-[13px] leading-relaxed text-ink-soft">
                  {e.blurb}
                </p>
              </li>
            ))}
          </ul>
        </Reveal>
      </Container>
    </section>
  );
}
