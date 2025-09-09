// app/feedback/page.tsx
import Link from "next/link";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import {
  Table, TableHeader, TableRow, TableHead, TableBody, TableCell,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Star } from "lucide-react";

type Category = "Crowd" | "Transport" | "Staff" | "Cleanliness" | "Security" | "Other";

type Feedback = {
  id: string;
  rating: number; // 1..5
  category: Category;
  comment: string;
  date: string; // YYYY-MM-DD
};

const DATA: Feedback[] = [
  { id: "FB-1207", rating: 2, category: "Crowd", comment: "Queues too long near Gate 3.", date: "2025-09-09" },
  { id: "FB-1208", rating: 5, category: "Staff", comment: "Officers were very helpful with directions.", date: "2025-09-09" },
  { id: "FB-1210", rating: 3, category: "Transport", comment: "Hard to find verified taxis late evening.", date: "2025-09-08" },
  { id: "FB-1213", rating: 4, category: "Cleanliness", comment: "Rest areas were tidy, could add more bins.", date: "2025-09-08" },
  { id: "FB-1216", rating: 1, category: "Security", comment: "Felt unsafe near dark parking zone.", date: "2025-09-07" },
  { id: "FB-1218", rating: 4, category: "Crowd", comment: "Crowded but managed well by staff.", date: "2025-09-07" },
  { id: "FB-1220", rating: 3, category: "Other", comment: "App notifications delayed.", date: "2025-09-07" },
  { id: "FB-1222", rating: 5, category: "Staff", comment: "First-aid help was quick. Thanks!", date: "2025-09-06" },
  { id: "FB-1223", rating: 2, category: "Transport", comment: "Auto drivers overcharging outside east gate.", date: "2025-09-06" },
  { id: "FB-1224", rating: 4, category: "Cleanliness", comment: "Toilets clean, add signage.", date: "2025-09-06" },
];

function ratingColor(r: number) {
  if (r <= 2) return "text-rose-600";
  if (r <= 4) return "text-amber-600";
  return "text-emerald-700";
}

export default function FeedbackPage() {
  return (
    <div className="mx-auto max-w-7xl space-y-6 p-6">
      <div className="flex items-baseline justify-between">
        <h1 className="text-2xl font-semibold tracking-tight">Tourist Feedback</h1>
      </div>

      <Card className="bg-white border shadow-sm rounded-xl overflow-hidden">
        <CardHeader className="py-4">
          <CardTitle className="text-base font-semibold">All Feedback</CardTitle>
        </CardHeader>
        <CardContent className="pt-0">
          <div className="rounded-lg border overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-zinc-50 sticky top-0 z-10">
                  <TableHead className="p-3 w-[110px]">ID</TableHead>
                  <TableHead className="p-3 w-[120px]">Rating</TableHead>
                  <TableHead className="p-3 w-[140px]">Category</TableHead>
                  <TableHead className="p-3">Comment</TableHead>
                  <TableHead className="p-3 w-[130px]">Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody className="[&>tr:nth-child(odd)]:bg-zinc-50/50">
                {DATA.map((r) => {
                  const color = ratingColor(r.rating);
                  return (
                    <TableRow key={r.id} className="hover:bg-zinc-100/70 transition-colors">
                      <TableCell className="p-3">{r.id}</TableCell>
                      <TableCell className="p-3">
                        <span className={`inline-flex items-center gap-1 ${color}`}>
                          <span className="font-medium">{r.rating}★</span>
                        </span>
                      </TableCell>
                      <TableCell className="p-3">{r.category}</TableCell>
                      <TableCell className="p-3">{r.comment}</TableCell>
                      <TableCell className="p-3">{r.date}</TableCell>
                    </TableRow>
                  );
                })}
                {DATA.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={5} className="p-6 text-center text-sm text-muted-foreground">
                      No feedback yet.
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
