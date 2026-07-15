import { Nav } from "@/components/Nav";
import { Hero } from "@/components/Hero";
import { TwoLayer } from "@/components/TwoLayer";
import { GlobalSkills } from "@/components/GlobalSkills";
import { Catalog } from "@/components/Catalog";
import { HowItsMade } from "@/components/HowItsMade";
import { Install } from "@/components/Install";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Nav />
      <main>
        <Hero />
        <TwoLayer />
        <GlobalSkills />
        <Catalog />
        <HowItsMade />
        <Install />
      </main>
      <Footer />
    </>
  );
}
