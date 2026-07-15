import type { Metadata } from "next";
import { Unbounded, Hanken_Grotesk, Space_Mono } from "next/font/google";
import "./globals.css";

const unbounded = Unbounded({
  subsets: ["latin"],
  variable: "--font-unbounded",
  weight: ["600", "700", "800"],
});

const hanken = Hanken_Grotesk({
  subsets: ["latin"],
  variable: "--font-hanken",
  weight: ["400", "500", "600", "700"],
});

const spaceMono = Space_Mono({
  subsets: ["latin"],
  variable: "--font-space-mono",
  weight: ["400", "700"],
});

const DESC =
  "Clone one repo and Claude is fully configured: 14 global skills, a 62-skill catalog and the global instructions — file-based, no plugins, no hooks.";

export const metadata: Metadata = {
  metadataBase: new URL("https://skillsbase.vercel.app"),
  title: "skillsbase — a Claude Code build",
  description: DESC,
  openGraph: {
    title: "skillsbase — a Claude Code build",
    description: DESC,
    type: "website",
    siteName: "skillsbase",
  },
  twitter: { card: "summary_large_image" },
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html
      lang="en"
      data-scroll-behavior="smooth"
      className={`${unbounded.variable} ${hanken.variable} ${spaceMono.variable}`}
    >
      <body>{children}</body>
    </html>
  );
}
