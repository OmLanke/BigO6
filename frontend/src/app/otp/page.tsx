// app/otp/page.tsx
"use client";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import {
    InputOTP,
    InputOTPGroup,
    InputOTPSeparator,
    InputOTPSlot,
} from "@/components/ui/input-otp";

export default function OtpPage() {
    return (
        <div className="min-h-svh grid place-items-center p-6">
            <div className="w-full max-w-md space-y-6 text-center">
                <h1 className="text-4xl font-semibold tracking-tight text-blue-500">
                    Tourरक्षा
                </h1>
                <p className="text-lg text-muted-foreground">Enter your OTP here</p>

                <div className="flex justify-center">
                    <InputOTP maxLength={6} aria-label="One-time password">
                        <InputOTPGroup className="gap-2 md:gap-3">
                            <InputOTPSlot index={0} className="h-16 w-14 text-3xl" />
                            <InputOTPSlot index={1} className="h-16 w-14 text-3xl" />
                            <InputOTPSlot index={2} className="h-16 w-14 text-3xl" />
                        </InputOTPGroup>
                        <InputOTPSeparator className="mx-3" />
                        <InputOTPGroup className="gap-2 md:gap-3">
                            <InputOTPSlot index={3} className="h-16 w-14 text-3xl" />
                            <InputOTPSlot index={4} className="h-16 w-14 text-3xl" />
                            <InputOTPSlot index={5} className="h-16 w-14 text-3xl" />
                        </InputOTPGroup>
                    </InputOTP>
                </div>

                <div className="flex gap-4 justify-center">
                    <Button asChild variant="outline" className=" max-w-sm">
                        <Link href="/login">Back to Login</Link>
                    </Button>

                    <Button
                        type="submit"
                        className=" min-w-4xs bg-blue-500 hover:bg-blue-600 cursor-pointer"
                    >
                        <Link href="/police/dashboard">Submit</Link>

                    </Button>
                </div>

            </div>
        </div>
    );
}
