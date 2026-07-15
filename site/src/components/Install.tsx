import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { CopyBar } from "./ui/CopyBar";
import { smartInstall, installModes, repoUrl } from "@/data/skills";

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
                One line. <span className="text-violet">Claude</span> does the
                rest.
              </>
            }
            intro="Paste this into Claude. It checks what you already have, asks how you want it, and installs — nothing you didn't pick."
          />
        </Reveal>

        <div className="mx-auto mt-14 max-w-3xl">
          <CopyBar command={smartInstall} kind="claude" />
        </div>

        <div className="mx-auto mt-12 max-w-3xl">
          <p className="mb-5 text-center font-mono text-[12px] uppercase tracking-[0.14em] text-muted">
            Then Claude asks you how:
          </p>
          <div className="grid gap-4 sm:grid-cols-2">
            {installModes.map((m) => (
              <div
                key={m.label}
                className="rounded-2xl border border-line bg-white p-5"
              >
                <h3 className="font-display text-[15px] font-bold tracking-tight">
                  {m.label}
                </h3>
                <p className="mt-1.5 text-[13px] leading-relaxed text-ink-soft">
                  {m.blurb}
                </p>
              </div>
            ))}
          </div>
        </div>

        <p className="mx-auto mt-10 max-w-2xl text-center text-[13px] leading-relaxed text-ink-soft">
          Fresh machine or a build of your own — it adapts. Everything comes from
          one public repo:{" "}
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
