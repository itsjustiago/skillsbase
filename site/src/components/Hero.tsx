import { Button, Container, Contours, DotGrid } from "./ui/primitives";
import { CopyBar } from "./ui/CopyBar";
import { families, stats, smartInstall } from "@/data/skills";

export function Hero() {
  return (
    <section
      id="top"
      className="relative flex min-h-[92vh] items-center overflow-hidden pt-[68px]"
    >
      <DotGrid />
      <Contours intensity={1.1} />

      <Container className="relative py-20 text-center">
        <span className="font-mono text-[12px] uppercase tracking-[0.14em] text-violet">
          ↑ {stats.global} global · {stats.catalog} on-demand · {stats.plugins}{" "}
          plugins
        </span>

        <h1 className="mx-auto mt-5 max-w-[16ch] font-display text-[clamp(2.4rem,8vw,5rem)] font-extrabold leading-[0.92] tracking-[-0.025em] text-balance">
          Clone it. Claude&rsquo;s <span className="text-violet">ready</span>
          <span className="text-tangerine">.</span>
        </h1>

        <p className="mx-auto mt-6 max-w-[48ch] text-[clamp(15px,1.7vw,18px)] leading-relaxed text-ink-soft">
          One repo bootstraps every skill, the global instructions and the
          matchmaker. File-based — no plugins, no hooks.
        </p>

        <div className="mx-auto mt-9 max-w-xl text-left">
          <CopyBar command={smartInstall} kind="claude" compact />
          <p className="mt-2.5 text-center font-mono text-[11px] uppercase tracking-[0.13em] text-muted">
            Paste into Claude — it asks how you want it
          </p>
        </div>

        <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
          <Button href="#install" variant="outline">
            How it installs
          </Button>
          <Button href="#skills" variant="outline">
            Browse {stats.global + stats.catalog} skills
          </Button>
        </div>

        <div className="mt-14 flex flex-wrap justify-center gap-2">
          {families.map((f) => (
            <span
              key={f.id}
              className="inline-flex items-center gap-2 rounded-full bg-[#ece9ff] px-3.5 py-1.5 text-[12.5px] font-semibold text-violet-deep"
            >
              {f.label.split(" · ")[0]}
              <b className="font-mono tabular-nums">{f.count}</b>
            </span>
          ))}
        </div>
      </Container>
    </section>
  );
}
