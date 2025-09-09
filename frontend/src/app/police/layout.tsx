// app/police/layout.tsx
"use client"

import type React from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import {
  Sidebar, SidebarProvider, SidebarTrigger, SidebarContent, SidebarHeader,
  SidebarFooter, SidebarMenu, SidebarMenuItem, SidebarMenuButton, SidebarInset,
} from "@/components/ui/sidebar"
import { LayoutDashboard, Bell, Shield, Map as MapIcon, IdCard, Settings, LogOut, User, Newspaper } from "lucide-react"

export default function PoliceLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()

  const isActive = (href: string) =>
    href === "/police"
      ? pathname === "/police" || pathname === "/police/dashboard"
      : pathname.startsWith(href)

  return (
    <SidebarProvider>
      <Sidebar collapsible="icon" className="bg-white text-zinc-900 border-r border-zinc-200">
        <SidebarHeader className="p-6 flex flex-col items-center space-y-4">
          <h1 className="text-2xl font-bold text-blue-600 bg-clip-text">
            <Link href="/police/dashboard">
            
            <span className="hidden group-data-[state=expanded]:block">Tourरक्षा</span>
            </Link>
            <span className="block group-data-[state=collapsed]:block group-data-[state=expanded]:hidden">T</span>
          </h1>

          <div className="flex flex-col items-center">
            <div className="flex items-center justify-center bg-zinc-100 rounded-full transition-all duration-300
              group-data-[state=expanded]:w-14 group-data-[state=expanded]:h-14
              group-data-[state=collapsed]:w-10 group-data-[state=collapsed]:h-10">
              <User className="w-7 h-7 text-zinc-700 hidden group-data-[state=expanded]:block" />
              <span className="text-sm font-semibold text-zinc-700 hidden group-data-[state=collapsed]:block">PD</span>
            </div>
            <span className="mt-2 text-zinc-600 text-sm font-medium hidden group-data-[state=expanded]:block">
              Police
            </span>
          </div>
        </SidebarHeader>

        <SidebarContent className="mt-6 pl-2">
          <SidebarMenu className="space-y-2">
            <SidebarMenuItem>
              <SidebarMenuButton
                asChild
                isActive={isActive("/police")}
                className={`px-5 py-3 text-base rounded-none transition-colors ${
                  isActive("/police")
                    ? "bg-blue-50 text-blue-700 border border-blue-100"
                    : "hover:bg-zinc-50 hover:text-zinc-900"
                }`}
              >
                <Link href="/police/dashboard">
                  <LayoutDashboard className="w-6 h-6" />
                  <span>Dashboard</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>

            <SidebarMenuItem>
              <SidebarMenuButton
                asChild
                isActive={isActive("/police/live-alerts")}
                className={`px-5 py-3 text-base rounded-none transition-colors ${
                  isActive("/police/alerts")
                    ? "bg-blue-50 text-blue-700 border border-blue-100"
                    : "hover:bg-zinc-50 hover:text-zinc-900"
                }`}
              >
                <Link href="/police/live-alerts">
                  <Bell className="w-6 h-6" />
                  <span>Live Alerts</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>

            <SidebarMenuItem>
              <SidebarMenuButton
                asChild
                isActive={isActive("/police/heatmap")}
                className={`px-5 py-3 text-base rounded-none transition-colors ${
                  isActive("/police/heatmap")
                    ? "bg-blue-50 text-blue-700 border border-blue-100"
                    : "hover:bg-zinc-50 hover:text-zinc-900"
                }`}
              >
                <Link href="/police/heatmap">
                  <MapIcon className="w-6 h-6" />
                  <span>Heatmap</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>

            <SidebarMenuItem>
              <SidebarMenuButton
                asChild
                isActive={isActive("/police/settings")}
                className={`px-5 py-3 text-base rounded-none transition-colors ${
                  isActive("/police/settings")
                    ? "bg-blue-50 text-blue-700 border border-blue-100"
                    : "hover:bg-zinc-50 hover:text-zinc-900"
                }`}
              >
                <Link href="/police/feedback">
                  <Newspaper className="w-6 h-6" />
                  <span>Feedback</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarContent>

        <SidebarFooter className="p-4 mt-auto">
          <SidebarMenu>
            <SidebarMenuItem>
              <SidebarMenuButton className="px-5 py-3 text-base rounded-none hover:bg-zinc-50 hover:text-zinc-900 transition-colors">
                <LogOut className="w-6 h-6" />
                <Link href="/">
                
                <span>Logout</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          </SidebarMenu>
        </SidebarFooter>
      </Sidebar>

      <SidebarInset>
        <div className="flex items-center justify-between p-4 border-b border-zinc-200 bg-white">
          <SidebarTrigger />
          <h2 className="text-lg font-semibold text-zinc-900" />
        </div>
        <main className="flex-1 bg-white p-6">{children}</main>
      </SidebarInset>
    </SidebarProvider>
  )
}
