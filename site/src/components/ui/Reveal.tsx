import type { ReactNode } from "react";

// Scroll-driven reveal via the `.reveal` class (see globals.css).
// Pure CSS `animation-timeline: view()` — no JS, no IntersectionObserver, no
// rAF — so it works even where framer-motion's animation loop is throttled,
// and content stays visible by default where scroll timelines are unsupported.
// Keeps the previous API (delay/y) so call sites don't change; they're no-ops now.
export function Reveal({
  children,
  className = "",
  as: Tag = "div",
}: {
  children: ReactNode;
  delay?: number;
  y?: number;
  className?: string;
  as?: "div" | "li" | "section";
}) {
  return <Tag className={`reveal ${className}`}>{children}</Tag>;
}
