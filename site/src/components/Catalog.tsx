"use client";

import { useMemo, useState } from "react";
import { Container, SectionHeading } from "./ui/primitives";
import { families, stats } from "@/data/skills";

type Row = {
  name: string;
  description: string;
  tags: string[];
  cost: number;
  famId: string;
  famShort: string;
};

const short = (label: string) => label.split(" · ")[0];
const fmtCost = (t: number) => (t >= 1000 ? `${(t / 1000).toFixed(1)}k` : `${t}`);

export function Catalog() {
  const [active, setActive] = useState("all");

  const rows: Row[] = useMemo(
    () =>
      families.flatMap((f) =>
        f.skills.map((s) => ({
          name: s.name,
          description: s.description,
          tags: s.tags,
          cost: s.cost_tokens,
          famId: f.id,
          famShort: short(f.label),
        })),
      ),
    [],
  );

  const shown = active === "all" ? rows : rows.filter((r) => r.famId === active);

  return (
    <section className="scroll-mt-24 py-24 md:py-32">
      <Container>
        <SectionHeading
          eyebrow="On demand"
          title={
            <>
              The <span className="text-violet">{stats.catalog}</span>-skill
              catalog.
            </>
          }
          intro="Per-project skills the matchmaker installs where they fit. Pick the right one for the job — filter by family."
        />

        <div className="mt-10 flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => setActive("all")}
            className={pill(active === "all")}
          >
            All <span className="tabular-nums opacity-60">{stats.catalog}</span>
          </button>
          {families.map((f) => (
            <button
              key={f.id}
              type="button"
              onClick={() => setActive(f.id)}
              className={pill(active === f.id)}
            >
              {short(f.label)}{" "}
              <span className="tabular-nums opacity-60">{f.count}</span>
            </button>
          ))}
        </div>

        <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {shown.map((r) => (
            <div
              key={r.name}
              className="flex h-full flex-col rounded-2xl border border-line bg-white p-5 transition-all duration-300 hover:-translate-y-0.5 hover:border-violet/40 hover:shadow-[0_20px_50px_-24px_rgba(90,43,240,0.35)]"
            >
              <div className="flex items-center justify-between gap-2">
                <span className="rounded-full bg-[#ece9ff] px-2.5 py-1 font-mono text-[10px] uppercase tracking-wider text-violet-deep">
                  {r.famShort}
                </span>
                <span className="font-mono text-[10.5px] tabular-nums text-muted">
                  {fmtCost(r.cost)} tok
                </span>
              </div>
              <h4 className="mt-3 font-display text-[16px] font-bold tracking-tight">
                {r.name}
              </h4>
              <p className="mt-2 line-clamp-3 flex-1 text-[13px] leading-relaxed text-ink-soft">
                {r.description}
              </p>
              <div className="mt-4 flex flex-wrap gap-1.5">
                {r.tags.slice(0, 3).map((t) => (
                  <span
                    key={t}
                    className="rounded border border-line px-1.5 py-0.5 font-mono text-[10px] text-muted"
                  >
                    {t}
                  </span>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Container>
    </section>
  );
}

function pill(activeState: boolean) {
  return `rounded-full border px-4 py-2 font-mono text-[12px] uppercase tracking-wide transition-colors ${
    activeState
      ? "border-ink bg-ink text-white"
      : "border-line bg-white/50 text-ink-soft hover:border-ink/40 hover:text-ink"
  }`;
}
