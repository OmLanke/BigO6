"use client";
import dynamic from 'next/dynamic';
import { useState } from 'react';
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { MapIcon } from "lucide-react";

const Map = dynamic(() => import('@/components/Map'), {
  ssr: false,
  loading: () => (
    <div className="h-[600px] w-full rounded-lg bg-muted animate-pulse flex items-center justify-center">
      <MapIcon className="h-12 w-12 text-muted-foreground animate-pulse" />
    </div>
  )
});

const locations = [
  { id: 'mumbai', name: 'Mumbai', coordinates: [72.8777, 19.0760] as [number, number] },
  { id: 'guwahati', name: 'Guwahati', coordinates: [91.7362, 26.1445] as [number, number] }
];

export default function Page() {
  const [selectedLocation, setSelectedLocation] = useState(locations[0].coordinates);

  return (
    <div className="container py-6 space-y-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-semibold">Heatmaps</h1>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Location Analysis</CardTitle>
              <CardDescription>Select a location to view its crime heatmap</CardDescription>
            </div>
            <Select
              onValueChange={(value: string) => {
                const location = locations.find(loc => loc.id === value);
                if (location) setSelectedLocation(location.coordinates);
              }}
              defaultValue={locations[0].id}
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Select a location" />
              </SelectTrigger>
              <SelectContent>
                <SelectGroup>
                  <SelectLabel>Cities</SelectLabel>
                  {locations.map((location) => (
                    <SelectItem key={location.id} value={location.id}>
                      {location.name}
                    </SelectItem>
                  ))}
                </SelectGroup>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          <div className="h-[600px] w-full rounded-lg overflow-hidden border">
            <Map center={selectedLocation} />
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
