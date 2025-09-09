"use client";

import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import Link from "next/link";

type FIR = {
  firNo?: string;
  year?: string;
  policeStation?: string;
  district?: string;

  occFrom?: string;         
  placeAddress?: string;     

  infoReceivedAt?: string;
  infoType?: "Oral" | "Written";
  gdEntry?: string;

  cName?: string;           
  cPhone?: string;           
  cAddress?: string;         
  cIdDoc?: string;           


  ioNameRank?: string;
  preparedOn?: string;
};

const sample: FIR = {
  firNo: "540",
  year: "2025",
  policeStation: "Colaba PS",
  district: "Mumbai City",

  occFrom: "2025-09-09 15:20",
  placeAddress: "Gate 3, West Plaza, Mumbai",

  infoReceivedAt: "2025-09-09 16:05",
  infoType: "Oral",
  gdEntry: "GD 238/15:50",

  cName: "Craig R",
  cPhone: "+91 98XXXXXX10",
  cAddress: "—",
  cIdDoc: "Passport P1234567",


  ioNameRank: "SI A. Sharma (Buckle 1123)",
  preparedOn: "2025-09-09 18:30",
};

export default function FIRLayoutPage() {
  const data = sample; 

  return (
    <div className="mx-auto max-w-[850px] p-6 print:p-0">
      <div className="mb-4 flex justify-end gap-2 no-print">
        <Link href={`/police/tourist-details/${"SOS-001"}`}>
        
        <Button variant="outline">Back</Button>
        </Link>
        <Button onClick={() => window.print()} variant="outline">Print</Button>
      </div>

      <Card className="bg-white border shadow-sm rounded-xl print:shadow-none print:border-0">
        <CardHeader className="pb-3">
          <CardTitle className="text-lg font-semibold text-center">
            FIRST INFORMATION REPORT (FIR)
          </CardTitle>
          <p className="text-center text-xs text-muted-foreground">
            (Section 154, Code of Criminal Procedure)
          </p>
        </CardHeader>

        <CardContent className="space-y-5 text-sm">
          <Section title="Basic Information">
            <Row a="FIR No." av={data.firNo} b="Year" bv={data.year} />
            <Row a="Police Station" av={data.policeStation} b="District" bv={data.district} />
            <Row a="Date/Time of Occurrence" av={data.occFrom} b="Location" bv={data.placeAddress} />
            <Row a="Complainant Name" av={data.cName} b="Phone" bv={data.cPhone} />
          </Section>

          <Section title="Incident Intake (Light)">
            <Row a="Information Received At" av={data.infoReceivedAt} b="Type of Information" bv={data.infoType || ""} />
            <RowFull a="GD Entry No./Time" av={data.gdEntry} />
          </Section>

          <Section title="Complainant (Extras)">
            <RowFull a="Address" av={data.cAddress} />
            <RowFull a="ID/Passport" av={data.cIdDoc} />
          </Section>

          <Section title="Officer & Signatures">
            <Row a="Investigating Officer (Name/Rank)" av={data.ioNameRank} b="Prepared On" bv={data.preparedOn} />
            <div className="grid grid-cols-2 gap-6 mt-2">
              <Sig label="Complainant / Informant" />
              <Sig label="Duty Officer / SHO" />
            </div>
          </Section>
        </CardContent>
      </Card>

      <style jsx global>{`
        @media print {
          .no-print { display: none !important; }
          @page { size: A4; margin: 12mm; }
          html, body { background: white; }
        }
      `}</style>
    </div>
  );
}


function Section({ title, children }: React.PropsWithChildren<{ title: string }>) {
  return (
    <section className="rounded-lg border p-3">
      <h2 className="text-xs font-semibold mb-2">{title}</h2>
      <div className="[&>div+div]:mt-2">{children}</div>
    </section>
  );
}

function Row({
  a, av, b, bv,
}: { a: string; av?: string; b: string; bv?: string }) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
      <KV label={a} value={av} />
      <KV label={b} value={bv} />
    </div>
  );
}

function RowFull({ a, av, large }: { a: string; av?: string; large?: boolean }) {
  return (
    <div className="grid grid-cols-1">
      <KV label={a} value={av} large={large} />
    </div>
  );
}

function KV({ label, value, large }: { label: string; value?: string; large?: boolean }) {
  return (
    <div className="space-y-1">
      <div className="text-[11px] text-muted-foreground">{label}</div>
      <div
        className={`rounded-md border bg-white px-2 py-1 whitespace-pre-wrap ${
          large ? "min-h-[96px]" : "min-h-[40px]"
        }`}
      >
        {value || "\u00A0"}
      </div>
    </div>
  );
}

function Sig({ label }: { label: string }) {
  return (
    <div className="space-y-1">
      <div className="min-h-[40px] rounded-md border bg-white" />
      <div className="text-[11px] text-muted-foreground">{label}</div>
    </div>
  );
}
