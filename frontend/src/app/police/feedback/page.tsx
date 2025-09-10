// app/feedback/page.tsx
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import {
  Table, TableHeader, TableRow, TableHead, TableBody, TableCell,
} from "@/components/ui/table";

type Feedback = {
  rating: number;     
  location: string;   
  date: string;        
};

const DATA: Feedback[] = [
  { rating: 2, location: "Gate 3",         date: "2025-09-09" },
  { rating: 5, location: "Info Palace",   date: "2025-09-09" },
  { rating: 3, location: "East Taxi Stand",date: "2025-09-08" },
  { rating: 4, location: "Rest Area",    date: "2025-09-08" },
  { rating: 1, location: "Parking Lot",  date: "2025-09-07" },
  { rating: 4, location: "West Plaza",     date: "2025-09-07" },
  { rating: 3, location: "App Support",    date: "2025-09-07" },
  { rating: 5, location: "First-Aid Desk", date: "2025-09-06" },
  { rating: 2, location: "East Gate",      date: "2025-09-06" },
  { rating: 4, location: "Restrooms",  date: "2025-09-06" },
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
          <CardTitle className="text-base font-semibold">Feedback</CardTitle>
        </CardHeader>
        <CardContent className="pt-0">
          <div className="rounded-lg border overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow className="bg-zinc-50 sticky top-0 z-10">
                  <TableHead className="p-3 w-[120px]">Rating</TableHead>
                  <TableHead className="p-3">Location</TableHead>
                  <TableHead className="p-3 w-[130px]">Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody className="[&>tr:nth-child(odd)]:bg-zinc-50/50">
                {DATA.map((r, i) => (
                  <TableRow key={i} className="hover:bg-zinc-100/70 transition-colors">
                    <TableCell className="p-3">
                      <span className={`font-medium ${ratingColor(r.rating)}`}>{r.rating}★</span>
                    </TableCell>
                    <TableCell className="p-3">{r.location}</TableCell>
                    <TableCell className="p-3">{r.date}</TableCell>
                  </TableRow>
                ))}
                {DATA.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={3} className="p-6 text-center text-sm text-muted-foreground">
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
