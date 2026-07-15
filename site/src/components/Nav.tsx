"use client";

import { useEffect, useState } from "react";
import { Container } from "./ui/primitives";
import { repoUrl } from "@/data/skills";

const links = [
  { href: "#skills", label: "Skills" },
  { href: "#how", label: "How it's made" },
  { href: "#install", label: "Install" },
];

export function Nav() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 16);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={`fixed inset-x-0 top-0 z-50 transition-all duration-300 ${
        scrolled
          ? "border-b border-line bg-background/80 backdrop-blur-md"
          : "border-b border-transparent"
      }`}
    >
      <Container className="flex h-[68px] items-center justify-between">
        <a
          href="#top"
          className="flex items-center gap-2.5 font-display text-[17px] font-bold tracking-tight"
        >
          <span className="grid h-7 w-7 place-items-center rounded-lg bg-violet text-[14px] font-extrabold text-white">
            s
          </span>
          skillsbase
        </a>

        <nav className="hidden items-center gap-7 md:flex">
          {links.map((l) => (
            <a
              key={l.href}
              href={l.href}
              className="text-[14px] font-medium text-ink-soft transition-colors hover:text-ink"
            >
              {l.label}
            </a>
          ))}
        </nav>

        <a
          href={repoUrl}
          target="_blank"
          rel="noreferrer"
          className="inline-flex items-center gap-2 rounded-full bg-ink px-4 py-2 font-mono text-[11px] uppercase tracking-[0.08em] text-white transition-transform hover:-translate-y-0.5"
        >
          GitHub ↗
        </a>
      </Container>
    </header>
  );
}
