import type { ReactNode } from "react";

// NOTE: intentionally static (no scroll/mount animation).
// The framer-motion whileInView/animate reveal left content stuck at opacity:0
// in the preview pane (throttled rAF). Motion will be re-added pane-safe later
// (CSS-driven, defaults-visible). Keeps the same API so call sites don't change.
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
  return <Tag className={className}>{children}</Tag>;
}
