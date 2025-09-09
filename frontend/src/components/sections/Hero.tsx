"use client";
import Image from "next/image";
import React from "react";
import TourRakshaLogo from "../../../public/images/TourRakshaLogo.png"
import { AuroraText } from "../magicui/aurora-text";
export default function Hero() {
    return (
        <section className="w-full min-h-screen bg-white flex items-center justify-center px-8">
            <div className="max-w-7xl w-full grid grid-cols-1 md:grid-cols-2 gap-12 items-center">

                <div className="flex flex-col gap-6">
                    <h1 className="text-4xl md:text-6xl font-bold text-gray-900 leading-tight">
                        Smart Tourist Safety <br /> with <span 
                        
                        className="text-blue-600"><AuroraText>Tourरक्षा</AuroraText></span>
                    </h1>
                    <p className="text-lg text-gray-600">
                        AI, Geo-Fencing, and Blockchain powered digital IDs to keep tourists safe in real time.
                    </p>
                    <div className="flex gap-4">
                        <button className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
                            Get Started
                        </button>
                        <button className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100">
                            Download App
                        </button>
                    </div>
                </div>

                <div className="flex justify-center md:justify-end">
                    <div className="flex justify-center ">
                        <Image
                            src={TourRakshaLogo}
                            alt="Tourरक्षा Logo"
                            width={1800}
                            height={1800}
                            className="h-auto object-contain w-[680px] md:w-[980px] lg:w-[1200px] xl:w-[1400px] mb-16"
                            priority
                        />
                    </div>



                </div>
            </div>
        </section>
    );
}
