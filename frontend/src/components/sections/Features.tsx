"use client";

import {
    Card,
    CardContent,
    CardDescription,
    CardFooter,
    CardHeader,
    CardTitle,
} from "@/components/ui/card";
import { ShineBorder } from "@/components/magicui/shine-border";
import {
    IdCard,
    Gauge,
    MapPin,
    BellRing,
    Languages,
    Users,
    Activity,
    LayoutDashboard,
} from "lucide-react";

const features = [
    {
        icon: IdCard,
        title: "Blockchain Digital ID",
        text:
            "Secure tourist ID issued at entry points with KYC, itinerary, and emergency contacts.",
    },
    {
        icon: Gauge,
        title: "Auto Safety Score",
        text:
            "Dynamic score based on area sensitivity to guide safer choices.",
    },
    {
        icon: MapPin,
        title: "Geo-fencing Alerts",
        text:
            "Instant notifications on entering high-risk or restricted zones with safer-route suggestions.",
    },
    {
        icon: BellRing,
        title: "Panic SOS + Live Location",
        text:
            "One tap SOS shares live location and ID to nearest police, tourism dept, and family.",
    },
    {
        icon: Languages,
        title: "Multilingual Support",
        text:
            "Accessible UI in local Indian languages and English, with voice/text emergency access.",
    },
    {
        icon: Users,
        title: "Family Tracking",
        text:
            "Trusted family can view live location and receive inactivity and SOS alerts when enabled.",
    },
    {
        icon: LayoutDashboard,
        title: "Authority Dashboards",
        text:
            "Heatmaps, clusters, alert history, and ID verification for police & tourism departments.",
    },
    {
        icon: Activity,
        title: "AI Anomaly Detection",
        text:
            "Detects deviations, prolonged inactivity, and distress patterns to reduce false alarms.",
        featured: true,
    },
];

const Features = () => {
    return (
        <section id="features" className="relative bg-white text-zinc-900">
            <div className="mx-20 max-w-7xl px-6 md:px-10 py-16 md:py-24 relative">
                <h2 className="text-4xl md:text-5xl font-semibold tracking-tight">
                    Features
                </h2>
                <p className="mt-3 text-zinc-600 max-w-2xl">
                    Core features that make travel safer for the toursist.
                </p>

                <div className="mt-12 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    {features.map(({ icon: Icon, title, text, featured }) => {
                        if (featured) {
                            return (
                                <Card
                                    key={title}
                                    className="relative overflow-hidden border border-zinc-200 bg-white text-center min-h-[220px] "
                                >
                                    <ShineBorder
                                        shineColor={["#5FA4E6", "#BA2193", "#FFFFFF"]}
                                    />
                                    <CardHeader className="relative z-10">
                                        <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-xl bg-zinc-100 ring-1 ring-zinc-200 mx-auto">
                                            <Icon className="h-6 w-6 text-zinc-800" aria-hidden="true" />
                                        </div>
                                        <CardTitle className="text-lg font-semibold">
                                            {title}
                                        </CardTitle>
                                        <CardDescription className="text-zinc-600">
                                            {text}
                                        </CardDescription>
                                    </CardHeader>
                                    <CardContent className="relative z-10" />
                                    <CardFooter className="relative z-10" />
                                </Card>
                            );
                        }

                        return (
                            <article
                                key={title}
                                className="relative z-10 rounded-2xl border border-zinc-200 bg-white p-6 min-h-[220px]
                               transition-all duration-100 hover:border-blue-400
                               hover:shadow-[0_12px_48px_-12px_rgba(59,130,246,0.35)]"
                            >
                                <div className="mb-4 inline-flex h-12 w-12 items-center justify-center rounded-xl bg-zinc-100 ring-1 ring-zinc-200">
                                    <Icon className="h-6 w-6 text-zinc-800" aria-hidden="true" />
                                </div>
                                <h3 className="text-lg font-semibold text-zinc-900">{title}</h3>
                                <p className="mt-2 text-sm leading-6 text-zinc-600">{text}</p>
                            </article>
                        );
                    })}
                </div>
            </div>
        </section>
    );
};

export default Features;
