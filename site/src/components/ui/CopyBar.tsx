"use client";

import { useState } from "react";

export function CopyBar({
  command,
  kind = "shell",
}: {
  command: string;
  kind?: "shell" | "claude";
}) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(command);
      setCopied(true);
      setTimeout(() => setCopied(false), 1600);
    } catch {
      /* clipboard blocked — no-op */
    }
  };

  return (
    <div className="flex items-start gap-3 rounded-2xl border border-white/10 bg-ink px-4 py-3.5">
      <span
        aria-hidden
        className="mt-px shrink-0 select-none font-mono text-[13px] text-violet"
      >
        {kind === "claude" ? "›" : "$"}
      </span>
      <code className="min-w-0 flex-1 whitespace-pre-wrap break-words font-mono text-[12.5px] leading-relaxed text-white/90">
        {command}
      </code>
      <button
        type="button"
        onClick={copy}
        aria-label="Copy to clipboard"
        className="shrink-0 inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 font-mono text-[11px] uppercase tracking-wide text-white/60 transition-colors hover:bg-white/10 hover:text-white focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-violet"
      >
        {copied ? "Copied" : "Copy"}
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden>
          {copied ? (
            <path d="M20 6 9 17l-5-5" />
          ) : (
            <>
              <rect x="9" y="9" width="12" height="12" rx="2" />
              <path d="M5 15V5a2 2 0 0 1 2-2h10" />
            </>
          )}
        </svg>
      </button>
    </div>
  );
}
