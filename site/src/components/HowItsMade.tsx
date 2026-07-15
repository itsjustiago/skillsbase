import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { repoUrl } from "@/data/skills";

const stats = [
  { n: "0", l: "plugins" },
  { n: "0", l: "hooks" },
  { n: "38", l: "sessions audited" },
  { n: "14", l: "global skills" },
];

const principles = [
  {
    t: "Files, not plugins",
    d: "Skills are plain files in ~/.claude/skills/. It works on the desktop app — the claude CLI isn't required.",
  },
  {
    t: "Zero hooks",
    d: "Latency was the #1 complaint. Nothing fires automatically on every edit; enforcement lives in the instructions.",
  },
  {
    t: "Externals from source",
    d: "The 9 external skills are pulled from their upstreams and patched on install — never vendored, so updates are one command.",
  },
  {
    t: "Audited, not accumulated",
    d: "An audit of 38 sessions cut dead connectors and heavy skills. Every global skill has to earn its start-up cost.",
  },
];

export function HowItsMade() {
  return (
    <section id="how" className="scroll-mt-24 py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            eyebrow="How it's made"
            title={
              <>
                File-based. No plugins,{" "}
                <span className="text-violet">no hooks</span>.
              </>
            }
            intro="Rebuilt from an audit of 38 sessions. The old build ran 8 plugins and automatic hooks; the latency and context bloat had to go."
          />
        </Reveal>

        <Reveal>
          <div className="mt-12 grid grid-cols-2 gap-px overflow-hidden rounded-2xl border border-line bg-line sm:grid-cols-4">
            {stats.map((s) => (
              <div key={s.l} className="bg-white p-6 text-center">
                <div className="font-display text-[38px] font-extrabold leading-none tracking-tight tabular-nums">
                  {s.n}
                </div>
                <div className="mt-2 font-mono text-[11px] uppercase tracking-wider text-muted">
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
          The full reasoning — what was cut and why —{" "}
          <a
            href={`${repoUrl}/blob/main/DECISIONS.md`}
            target="_blank"
            rel="noreferrer"
            className="font-semibold text-violet underline-offset-4 hover:underline"
          >
            lives in DECISIONS.md
          </a>
          .
        </p>
      </Container>
    </section>
  );
}
