import { Container } from "./ui/primitives";
import { repoUrl, stats } from "@/data/skills";

const columns = [
  {
    title: "Build",
    links: [
      { label: "Skills", href: "#skills" },
      { label: "How it's made", href: "#how" },
      { label: "Install", href: "#install" },
    ],
  },
  {
    title: "Repo",
    links: [
      { label: "GitHub", href: repoUrl },
      { label: "DECISIONS.md", href: `${repoUrl}/blob/main/DECISIONS.md` },
      { label: "setup.sh", href: `${repoUrl}/blob/main/setup.sh` },
    ],
  },
];

export function Footer() {
  return (
    <footer className="bg-ink text-white">
      <Container className="py-16">
        <div className="grid gap-10 md:grid-cols-[1.6fr_1fr_1fr]">
          <div>
            <div className="flex items-center gap-2.5 font-display text-[18px] font-bold">
              <span className="grid h-7 w-7 place-items-center rounded-lg bg-violet text-[14px] font-extrabold text-white">
                s
              </span>
              skillsbase
            </div>
            <p className="mt-4 max-w-xs text-[14px] leading-relaxed text-white/60">
              One repo bootstraps a whole Claude Code setup — {stats.global}{" "}
              global skills, a {stats.catalog}-skill catalog and the global
              instructions.
            </p>
          </div>

          {columns.map((col) => (
            <div key={col.title}>
              <h4 className="font-mono text-[12px] uppercase tracking-wider text-white/40">
                {col.title}
              </h4>
              <ul className="mt-4 grid gap-2.5">
                {col.links.map((l) => (
                  <li key={l.label}>
                    <a
                      href={l.href}
                      target={l.href.startsWith("#") ? undefined : "_blank"}
                      rel={l.href.startsWith("#") ? undefined : "noreferrer"}
                      className="text-[14px] text-white/70 transition-colors hover:text-white"
                    >
                      {l.label}
                    </a>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-14 flex flex-col gap-3 border-t border-white/10 pt-6 sm:flex-row sm:items-center sm:justify-between">
          <p className="font-mono text-[12px] text-white/40">
            © 2026 skillsbase · built by itsjustiago
          </p>
          <p className="font-mono text-[12px] uppercase tracking-wider text-white/40">
            file-based · no plugins · no hooks
          </p>
        </div>
      </Container>
    </footer>
  );
}
