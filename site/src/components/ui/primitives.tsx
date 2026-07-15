import type { ReactNode } from "react";

export function Container({
  className = "",
  children,
}: {
  className?: string;
  children: ReactNode;
}) {
  return (
    <div className={`mx-auto w-full max-w-[1180px] px-6 md:px-8 ${className}`}>
      {children}
    </div>
  );
}

export function ArrowUpRight({
  className = "",
  size = 18,
}: {
  className?: string;
  size?: number;
}) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2.4"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden
    >
      <path d="M7 17 17 7" />
      <path d="M7 7h10v10" />
    </svg>
  );
}

export function Eyebrow({
  children,
  className = "",
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <span
      className={`inline-flex items-center gap-2 font-mono text-[12px] uppercase tracking-[0.14em] text-violet ${className}`}
    >
      <svg
        width="13"
        height="13"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2.6"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden
      >
        <path d="m6 15 6-6 6 6" />
      </svg>
      {children}
    </span>
  );
}

export function SectionHeading({
  eyebrow,
  title,
  intro,
  align = "left",
  className = "",
}: {
  eyebrow?: string;
  title: ReactNode;
  intro?: ReactNode;
  align?: "left" | "center";
  className?: string;
}) {
  const centered = align === "center";
  return (
    <div
      className={`flex flex-col gap-5 ${
        centered ? "mx-auto max-w-2xl items-center text-center" : "max-w-2xl"
      } ${className}`}
    >
      {eyebrow && <Eyebrow>{eyebrow}</Eyebrow>}
      <h2 className="font-display text-[clamp(2rem,5vw,3.35rem)] font-extrabold leading-[0.98] tracking-[-0.02em] text-ink text-balance">
        {title}
      </h2>
      {intro && (
        <p className="max-w-xl text-[17px] leading-relaxed text-ink-soft">
          {intro}
        </p>
      )}
    </div>
  );
}

export function Tag({ children }: { children: ReactNode }) {
  return (
    <span className="inline-flex items-center rounded-full border border-line bg-white/50 px-3 py-1 font-mono text-[11px] uppercase tracking-wider text-ink-soft">
      {children}
    </span>
  );
}

type ButtonProps = {
  href?: string;
  children: ReactNode;
  variant?: "primary" | "accent" | "outline";
  className?: string;
  icon?: boolean;
} & React.AnchorHTMLAttributes<HTMLAnchorElement>;

export function Button({
  href,
  children,
  variant = "primary",
  className = "",
  icon = false,
  ...props
}: ButtonProps) {
  const base =
    "group inline-flex items-center justify-center gap-2 rounded-full px-6 py-3 font-sans text-[15px] font-semibold transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-violet focus-visible:ring-offset-2 focus-visible:ring-offset-background";
  const variants = {
    primary: "bg-ink text-white hover:-translate-y-0.5",
    accent: "bg-violet text-white hover:-translate-y-0.5 hover:bg-violet-deep",
    outline: "border border-ink/15 text-ink hover:border-ink/40 hover:bg-ink/[0.03]",
  };
  const cls = `${base} ${variants[variant]} ${className}`;
  const content = (
    <>
      {children}
      {icon && (
        <ArrowUpRight className="transition-transform duration-200 group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
      )}
    </>
  );
  if (href) {
    return (
      <a href={href} className={cls} {...props}>
        {content}
      </a>
    );
  }
  return <button className={cls}>{content}</button>;
}

export function Contours({
  className = "",
  tone = "light",
  intensity = 1,
}: {
  className?: string;
  tone?: "light" | "dark";
  intensity?: number;
}) {
  const width = 1240;
  const height = 900;
  const baseStroke = tone === "dark" ? "#ffffff" : "var(--ink)";
  const baseOpacity = (tone === "dark" ? 0.07 : 0.045) * intensity;
  const violetOpacity = (tone === "dark" ? 0.18 : 0.06) * intensity;
  const lines: ReactNode[] = [];
  let i = 0;
  for (let y = 30; y < height; y += 46) {
    const s = i % 2 === 0 ? -22 : 22;
    const d = `M-40 ${y} c 170 ${s} 320 ${-s} 480 0 s 320 ${s} 480 0 s 320 ${-s} 520 0`;
    const violet = i % 3 === 2;
    lines.push(
      <path
        key={i}
        d={d}
        fill="none"
        strokeWidth={1.4}
        stroke={violet ? "var(--violet)" : baseStroke}
        strokeOpacity={violet ? violetOpacity : baseOpacity}
      />,
    );
    i++;
  }
  return (
    <div
      aria-hidden
      className={`pointer-events-none absolute inset-0 overflow-hidden ${className}`}
    >
      <svg
        className="absolute left-1/2 top-1/2 h-[135%] w-[135%] -translate-x-1/2 -translate-y-1/2"
        viewBox={`0 0 ${width} ${height}`}
        preserveAspectRatio="xMidYMid slice"
      >
        <g transform={`rotate(-3 ${width / 2} ${height / 2})`}>{lines}</g>
      </svg>
    </div>
  );
}

export function DotGrid({ className = "" }: { className?: string }) {
  return (
    <div
      aria-hidden
      className={`pointer-events-none absolute inset-0 ${className}`}
      style={{
        backgroundImage: "radial-gradient(var(--line) 1px, transparent 1px)",
        backgroundSize: "26px 26px",
        maskImage:
          "radial-gradient(ellipse 70% 60% at center, black, transparent 78%)",
        WebkitMaskImage:
          "radial-gradient(ellipse 70% 60% at center, black, transparent 78%)",
      }}
    />
  );
}
