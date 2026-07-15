import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { globalGroups } from "@/data/skills";

export function GlobalSkills() {
  return (
    <section id="skills" className="scroll-mt-24 py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            eyebrow="Always on"
            title={
              <>
                Skills in <span className="text-violet">every</span> project.
              </>
            }
            intro="Set up once by setup.sh, then available everywhere. Five are ours; nine are pulled from their original sources and patched on install."
          />
        </Reveal>

        <div className="mt-14 grid gap-12">
          {globalGroups.map((g) => (
            <div key={g.id}>
              <h3 className="mb-5 font-mono text-[12px] uppercase tracking-[0.14em] text-muted">
                {g.label}
              </h3>
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
                {g.skills.map((s, i) => (
                  <Reveal key={s.name} delay={i * 0.05}>
                    <div className="h-full rounded-2xl border border-line bg-white p-5 transition-all duration-300 hover:-translate-y-0.5 hover:border-violet/40 hover:shadow-[0_20px_50px_-24px_rgba(90,43,240,0.35)]">
                      <div className="flex items-center justify-between gap-2">
                        <h4 className="font-display text-[15px] font-bold tracking-tight">
                          {s.name}
                        </h4>
                        <span
                          className={`shrink-0 rounded px-1.5 py-0.5 font-mono text-[9.5px] uppercase tracking-wider ${
                            s.kind === "own"
                              ? "bg-[#ece9ff] text-violet-deep"
                              : "border border-line text-muted"
                          }`}
                        >
                          {s.kind}
                        </span>
                      </div>
                      <p className="mt-2 text-[13px] leading-relaxed text-ink-soft">
                        {s.blurb}
                      </p>
                      {s.trigger && (
                        <span className="mt-3 inline-block font-mono text-[11px] text-violet">
                          {s.trigger}
                        </span>
                      )}
                    </div>
                  </Reveal>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
}
