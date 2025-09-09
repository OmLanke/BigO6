"use client";

import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import Link from "next/link";
import { AlertTriangle, BellRing } from "lucide-react";

export default function PoliceDashboard() {
  return (
    <div className="mx-auto max-w-7xl space-y-6 p-6">
      <h1 className="text-3xl font-semibold tracking-tight">Live Alerts</h1>

      {/* KPIs */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <Card className="bg-white border border-red-200 shadow-sm rounded-xl">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2 text-red-600">
              <AlertTriangle className="h-4 w-4" />
              <CardTitle className="text-sm font-semibold">Active SOS</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="pt-0">
            <div className="text-4xl font-bold text-red-600 tracking-tight leading-none">
              3
            </div>
            <p className="text-xs text-zinc-500 mt-1">Priority incidents</p>
          </CardContent>
        </Card>

        <Card className="bg-white border border-amber-200 shadow-sm rounded-xl">
          <CardHeader className="pb-2">
            <div className="flex items-center gap-2 text-amber-600">
              <BellRing className="h-4 w-4" />
              <CardTitle className="text-sm font-semibold">Open Alerts</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="pt-0">
            <div className="text-4xl font-bold text-amber-600 tracking-tight leading-none">
              10
            </div>
            <p className="text-xs text-zinc-500 mt-1">Awaiting action</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Card className="overflow-hidden bg-white border shadow-sm rounded-xl">
          <CardHeader className="py-4">
            <CardTitle className="text-base font-semibold">Emergency SOS</CardTitle>
          </CardHeader>
          <CardContent className="pt-0">
            <div className="rounded-lg border bg-white overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="bg-zinc-50/80 sticky top-0 z-10">
                    <TableHead className="w-[110px]">ID</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Location</TableHead>
                    <TableHead className="w-[140px]">Time</TableHead>
                    <TableHead className="w-[140px]">Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody className="[&>tr:nth-child(odd)]:bg-zinc-50/40">
                  <TableRow className="hover:bg-zinc-100/70 transition-colors">
                    <TableCell>
                      <Link
                        href={`/police/tourist-details/${"SOS-001"}`}
                        className="text-blue-600 hover:underline"
                      >
                        SOS-001
                      </Link>
                    </TableCell>
                    <TableCell className="font-medium">Panic</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell>
                      <Badge className="rounded-full bg-red-100 text-red-900 ring-1 ring-red-200">
                        Critical
                      </Badge>
                    </TableCell>
                  </TableRow>
                  <TableRow className="hover:bg-zinc-100/70 transition-colors">
                    <TableCell>
                      <Link
                        href={`/police/tourist-details/${"SOS-002"}`}
                        className="text-blue-600 hover:underline"
                      >
                        SOS-002
                      </Link>
                    </TableCell>
                    <TableCell className="font-medium">Assistance</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell>
                      <Badge className="rounded-full bg-red-100 text-red-900 ring-1 ring-red-200">
                        Critical
                      </Badge>
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>

        {/* Alerts */}
        <Card className="overflow-hidden bg-white border shadow-sm rounded-xl">
          <CardHeader className="py-4">
            <CardTitle className="text-base font-semibold">Alerts</CardTitle>
          </CardHeader>
          <CardContent className="pt-0">
            <div className="rounded-lg border bg-white overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="bg-zinc-50/80 sticky top-0 z-10">
                    <TableHead className="w-[110px]">ID</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Location</TableHead>
                    <TableHead className="w-[140px]">Time</TableHead>
                    <TableHead className="w-[140px]">Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody className="[&>tr:nth-child(odd)]:bg-zinc-50/40">
                  <TableRow className="hover:bg-zinc-100/70 transition-colors">
                    <TableCell>
                      <Link
                        href={`/police/tourist-details/${"A-101"}`}
                        className="text-blue-600 hover:underline"
                      >
                        A-101
                      </Link>
                    </TableCell>
                    <TableCell className="font-medium">Geo-fence</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell>
                      <Badge className="rounded-full bg-emerald-100 text-emerald-900 ring-1 ring-emerald-200">
                        Open
                      </Badge>
                    </TableCell>
                  </TableRow>
                  {/* example row */}
                  <TableRow className="hover:bg-zinc-100/70 transition-colors">
                    <TableCell>
                      <Link
                        href={`/police/tourist-details/${"A-102"}`}
                        className="text-blue-600 hover:underline"
                      >
                        A-102
                      </Link>
                    </TableCell>
                    <TableCell className="font-medium">Crowd Spike</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell className="text-zinc-600">—</TableCell>
                    <TableCell>
                      <Badge className="rounded-full bg-zinc-100 text-zinc-900 ring-1 ring-blue-200">
                        Closed
                      </Badge>
                    </TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
