import { Container, SectionHeading } from "./ui/primitives";
import { Reveal } from "./ui/Reveal";
import { CopyBar } from "./ui/CopyBar";
import { smartInstall, installModes, installNotes, repoUrl } from "@/data/skills";

export function Install() {
  return (
    <section id="install" className="py-24 md:py-32">
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
                <div className="flex items-center justify-between gap-2">
                  <h3 className="min-w-0 font-display text-[15px] font-bold tracking-tight">
                    {m.label}
                  </h3>
                  {m.recommended && (
                    <span className="shrink-0 rounded bg-[#ece9ff] px-1.5 py-0.5 font-mono text-[11px] uppercase tracking-wider text-violet-deep">
                      recommended
                    </span>
                  )}
                </div>
                <p className="mt-1.5 text-[13px] leading-relaxed text-ink-soft">
                  {m.blurb}
                </p>
              </div>
            ))}
          </div>
        </div>

        <ul className="mx-auto mt-6 grid max-w-3xl gap-2 rounded-2xl border border-tangerine/40 bg-white p-5 text-[13px] leading-relaxed text-ink-soft">
          {installNotes.map((n) => (
            <li key={n} className="flex gap-2.5">
              <span aria-hidden className="font-mono text-tangerine">!</span>
              <span className="min-w-0 break-words">{n}</span>
            </li>
          ))}
        </ul>

        <p className="mx-auto mt-10 max-w-2xl text-center text-[13px] leading-relaxed text-ink-soft">
          Fresh machine or a setup of your own, it adapts. Everything comes from
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
