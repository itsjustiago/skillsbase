import { Nav } from "@/components/Nav";
import { Hero } from "@/components/Hero";
import { Overview } from "@/components/Overview";
import { GlobalSkills } from "@/components/GlobalSkills";
import { Agents } from "@/components/Agents";
import { HowItsMade } from "@/components/HowItsMade";
import { Install } from "@/components/Install";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Nav />
      <main>
        <Hero />
        <Overview />
        <GlobalSkills />
        <Agents />
        <HowItsMade />
        <Install />
      </main>
      <Footer />
    </>
  );
}
