import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import TourRakshaLogo from "../../../public/images/TourRakshaLogo.png"
import Link from "next/link"
export function LoginForm({
  className,
  ...props
}: React.ComponentProps<"form">) {
  return (
    <form className={cn("flex flex-col gap-6", className)} {...props}>
      <div className="flex flex-col items-center gap-2 text-center">
        <h1 className="text-3xl font-bold mb-5 text-blue-500">Tourरक्षा</h1>

        <h1 className="text-3xl font-semibold">Login to your account</h1>
        <p className="text-muted-foreground text-sm text-balance">
          Enter your email below to login to your account
        </p>
      </div>
      <div className="grid gap-6">
        <div className="grid gap-3">
          <Label htmlFor="email">Email</Label>
          <Input id="email" type="email" placeholder="tourraksh@example.com" required />
        </div>

        <Link href="/otp">
        
        <Button type="submit" className="w-full bg-blue-500 hover:bg-blue-600 cursor-pointer">
          Login
        </Button>
        </Link>
        <div className="after:border-border relative text-center text-sm after:absolute after:inset-0 after:top-1/2 after:z-0 after:flex after:items-center after:border-t">
        </div>

      </div>
      <div className="text-center text-sm">
        <p>Login to Police Dashboard</p>
      </div>
    </form>
  )
}
