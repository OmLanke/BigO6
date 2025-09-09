"use client";
import Image from "next/image";

export default function Showcase() {
    return (
        <section id="showcase" className="bg-white text-zinc-900 scroll-mt-24 relative">
            <span
                aria-hidden
                className="pointer-events-none absolute top-[-12%] right-[-14%] h-[36rem] w-[36rem]
                   rounded-full bg-[radial-gradient(closest-side,rgba(59,130,246,0.35),rgba(59,130,246,0.15)_60%,transparent_70%)]
                   blur-[160px]"
            />

            <span
                aria-hidden
                className="pointer-events-none absolute top-3/3 right-0/3 h-[36rem] w-[36rem]
                   rounded-full bg-[radial-gradient(closest-side,rgba(59,130,246,0.35),rgba(59,130,246,0.15)_60%,transparent_70%)]
                   blur-[160px]"
            />


            <div className="mx-auto max-w-8xl px-6 md:px-10 py-16 md:py-24">
                <h2 className="text-6xl md:text-7xl font-semibold tracking-tight text-center">
                    See <span className="text-blue-600">Tourरक्षा</span> in action
                </h2>
                <p className="mt-3 text-center text-zinc-600">
                    Heatmaps, live SOS, and blockchain ID verification built for urgent response.
                </p>

                <div className="mt-12">
                    <div className="relative mx-auto w-full max-w-7xl">
                        <span
                aria-hidden
                className="pointer-events-none absolute top-[-12%] left-[-14%] h-[36rem] w-[36rem]
                   rounded-full bg-[radial-gradient(closest-side,rgba(59,130,246,0.35),rgba(59,130,246,0.15)_60%,transparent_70%)]
                   blur-[160px]"
            />
                        <div className="pointer-events-none absolute inset-x-24 -bottom-8 h-24 rounded-full bg-zinc-300/40 blur-2xl" />

                        <div className="relative rounded-2xl border border-zinc-300 bg-white shadow-2xl px-4 pb-4">
                            <div className="absolute left-1/2 -translate-x-1/2 -top-1 h-2 w-2 rounded-full bg-zinc-300" />
                            <div className="relative aspect-[16/10] w-full overflow-hidden rounded-xl border border-zinc-200 bg-black">
                                <Image
                                    src="/images/dashboard-heatmap.png"
                                    alt="Tourरक्षा dashboard"
                                    fill
                                    className="object-cover"
                                    priority
                                    sizes="(min-width:1280px) 1152px, 100vw"
                                />
                            </div>
                        </div>
                        <div className="mx-auto mt-2 h-2 w-1/2 rounded-b-xl bg-zinc-200/80" />
                    </div>
                </div>
            </div>
        </section>
    );
}
