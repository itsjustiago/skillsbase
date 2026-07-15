import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { CopyBar } from "./ui/CopyBar";
import { installCommands, secondaryCommands, repoUrl } from "@/data/skills";

export function Install() {
  return (
    <section id="install" className="scroll-mt-24 py-24 md:py-32">
      <Container>
        <Reveal>
          <SectionHeading
            align="center"
            eyebrow="Install"
            title={
              <>
                Send it to <span className="text-violet">Claude</span>.
              </>
            }
            intro="Paste a line and Claude does the rest — the whole build, just the skills, or just the instructions."
          />
        </Reveal>

        <div className="mx-auto mt-14 grid max-w-3xl gap-4">
          {installCommands.map((c, i) => (
            <Reveal key={c.id} delay={i * 0.07}>
              <div className="rounded-3xl border border-line bg-white p-6">
                <div className="flex flex-wrap items-baseline justify-between gap-x-4 gap-y-1">
                  <h3 className="font-display text-[18px] font-bold tracking-tight">
                    {c.label}
                  </h3>
                  <p className="text-[13px] text-muted">{c.blurb}</p>
                </div>
                <div className="mt-4">
                  <CopyBar command={c.prompt} kind="claude" />
                </div>
              </div>
            </Reveal>
          ))}
        </div>

        <div className="mx-auto mt-8 max-w-3xl">
          <p className="mb-3 font-mono text-[12px] uppercase tracking-[0.14em] text-muted">
            Prefer the shell?
          </p>
          <CopyBar
            command="git clone https://github.com/itsjustiago/skillsbase && cd skillsbase && bash setup.sh"
            kind="shell"
          />
          <p className="mt-3 text-[13px] leading-relaxed text-ink-soft">
            Requires git + node on PATH. The claude CLI isn&rsquo;t required — this
            works on the desktop app. Restart Claude Code after installing.
          </p>
        </div>

        <div className="mx-auto mt-10 grid max-w-3xl gap-4 sm:grid-cols-2">
          {secondaryCommands.map((c) => (
            <div key={c.id} className="rounded-2xl border border-line bg-white p-5">
              <h4 className="font-display text-[15px] font-bold tracking-tight">
                {c.label}
              </h4>
              <p className="mb-3 mt-1 text-[13px] text-muted">{c.blurb}</p>
              <CopyBar command={c.prompt} kind="claude" />
            </div>
          ))}
        </div>

        <p className="mt-10 text-center text-[13px] text-ink-soft">
          Everything comes from one public repo —{" "}
          <a
            href={repoUrl}
            target="_blank"
            rel="noreferrer"
            className="font-semibold text-violet underline-offset-4 hover:underline"
          >
            github.com/itsjustiago/skillsbase
          </a>
          .
        </p>
      </Container>
    </section>
  );
}
