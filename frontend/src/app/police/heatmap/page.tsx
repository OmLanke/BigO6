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
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { MapIcon, Shield, AlertTriangle, Users, Activity, Play, Layers, RotateCcw } from "lucide-react";
import { useCallback, useMemo } from 'react';

// Import the optimized map component
const OptimizedMap = dynamic(() => import('@/components/OptimizedMap'), {
  ssr: false,
  loading: () => (
    <div className="h-[700px] w-full rounded-lg bg-muted animate-pulse flex items-center justify-center">
      <div className="text-center space-y-4">
        <MapIcon className="h-16 w-16 text-muted-foreground animate-pulse mx-auto" />
        <div className="text-sm text-muted-foreground">Loading advanced heatmap...</div>
      </div>
    </div>
  )
});

const locations = [
  { id: 'mumbai', name: 'Mumbai', coordinates: [72.8777, 19.0760] as [number, number] },
  { id: 'guwahati', name: 'Guwahati', coordinates: [91.7362, 26.1445] as [number, number] },
  { id: 'delhi', name: 'New Delhi', coordinates: [77.2090, 28.6139] as [number, number] },
  { id: 'kolkata', name: 'Kolkata', coordinates: [88.3639, 22.5726] as [number, number] }
];

interface Tourist {
  id: string;
  name: string;
  location: [number, number];
  lastSeen: string;
  status: 'safe' | 'warning' | 'danger';
  safetyScore: number;
}

interface AlertData {
  id: string;
  touristId: string;
  touristName: string;
  type: string;
  message: string;
  location: [number, number];
  timestamp: string;
}

export default function HeatmapPage() {
  const [selectedLocationId, setSelectedLocationId] = useState(locations[0].id);
  const [selectedTourist, setSelectedTourist] = useState<Tourist | null>(null);
  const [recentAlerts, setRecentAlerts] = useState<AlertData[]>([]);

  const selectedLocation = useMemo(() => {
    const location = locations.find(loc => loc.id === selectedLocationId);
    return location ? location.coordinates : locations[0].coordinates;
  }, [selectedLocationId]);

  const selectedLocationName = useMemo(() => {
    const location = locations.find(loc => loc.id === selectedLocationId);
    return location ? location.name : 'Unknown Location';
  }, [selectedLocationId]);

  const handleTouristSelect = useCallback((tourist: Tourist) => {
    setSelectedTourist(tourist);
  }, []);

  const handleAlertGenerated = useCallback((alert: AlertData) => {
    setRecentAlerts(prev => {
      // Keep only the last 10 alerts and avoid duplicates
      const filtered = prev.filter(a => a.id !== alert.id);
      return [alert, ...filtered].slice(0, 10);
    });
  }, []);

  return (
    <div className="container py-6 space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Shield className="h-8 w-8 text-blue-600" />
            <div>
              <h1 className="text-3xl font-semibold">Advanced Safety Heatmaps</h1>
              <p className="text-muted-foreground">Real-time tourist safety monitoring and risk analysis</p>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <Badge variant="outline" className="bg-green-50 text-green-700 border-green-200">
              <Activity className="w-3 h-3 mr-1" />
              Live Monitoring
            </Badge>
          </div>
        </div>
      </div>

      {/* Location Selector and Quick Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="col-span-1 md:col-span-2">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">Location Selection</CardTitle>
            <CardDescription>Choose a region to analyze tourist safety patterns</CardDescription>
          </CardHeader>
          <CardContent>
            <Select
              onValueChange={setSelectedLocationId}
              value={selectedLocationId}
            >
              <SelectTrigger className="w-full">
                <SelectValue placeholder="Select a location" />
              </SelectTrigger>
              <SelectContent>
                <SelectGroup>
                  <SelectLabel>Available Cities</SelectLabel>
                  {locations.map((location) => (
                    <SelectItem key={location.id} value={location.id}>
                      <div className="flex items-center gap-2">
                        <MapIcon className="w-4 h-4" />
                        {location.name}
                      </div>
                    </SelectItem>
                  ))}
                </SelectGroup>
              </SelectContent>
            </Select>
            <div className="mt-3 text-sm text-muted-foreground">
              Currently viewing: <span className="font-medium">{selectedLocationName}</span>
            </div>
          </CardContent>
        </Card>

        <Card className="col-span-1 md:col-span-2">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">Active Monitoring</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-3 gap-4 text-center">
              <div>
                <div className="text-2xl font-bold text-blue-600">
                  <Users className="w-6 h-6 mx-auto mb-1" />
                  6
                </div>
                <div className="text-xs text-muted-foreground">Active Tourists</div>
              </div>
              <div>
                <div className="text-2xl font-bold text-green-600">
                  <Shield className="w-6 h-6 mx-auto mb-1" />
                  4
                </div>
                <div className="text-xs text-muted-foreground">Safe Zones</div>
              </div>
              <div>
                <div className="text-2xl font-bold text-amber-600">
                  <AlertTriangle className="w-6 h-6 mx-auto mb-1" />
                  {recentAlerts.length}
                </div>
                <div className="text-xs text-muted-foreground">Recent Alerts</div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Map and Tourist Details */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Heatmap */}
        <Card className="col-span-1 lg:col-span-3">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <MapIcon className="w-5 h-5" />
              Interactive Safety Heatmap
            </CardTitle>
            <CardDescription>
              Real-time visualization of tourist locations, safety scores, and risk zones
            </CardDescription>
          </CardHeader>
          <CardContent className="p-0">
            <div className="h-[700px] w-full rounded-lg overflow-hidden">
              <OptimizedMap 
                center={selectedLocation} 
                onTouristSelect={handleTouristSelect}
                onAlertGenerated={handleAlertGenerated}
              />
            </div>
          </CardContent>
        </Card>

        {/* Tourist Details & Recent Alerts */}
        <div className="space-y-6">
          {/* Selected Tourist */}
          {selectedTourist && (
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Tourist Details</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex items-center gap-3">
                  <div 
                    className="w-12 h-12 rounded-full flex items-center justify-center text-white font-bold"
                    style={{ 
                      backgroundColor: selectedTourist.status === 'safe' ? '#10B981' : 
                                     selectedTourist.status === 'warning' ? '#F59E0B' : '#EF4444' 
                    }}
                  >
                    {selectedTourist.name.charAt(0)}
                  </div>
                  <div>
                    <h3 className="font-semibold">{selectedTourist.name}</h3>
                    <p className="text-sm text-muted-foreground">{selectedTourist.id}</p>
                  </div>
                </div>
                
                <div className="space-y-3">
                  <div className="flex justify-between">
                    <span className="text-sm">Status:</span>
                    <Badge 
                      variant="secondary"
                      className={
                        selectedTourist.status === 'safe' ? 'bg-green-50 text-green-700' :
                        selectedTourist.status === 'warning' ? 'bg-amber-50 text-amber-700' :
                        'bg-red-50 text-red-700'
                      }
                    >
                      {selectedTourist.status.toUpperCase()}
                    </Badge>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Safety Score:</span>
                    <span className="font-medium">{selectedTourist.safetyScore}/100</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-sm">Last Seen:</span>
                    <span className="font-medium">{selectedTourist.lastSeen}</span>
                  </div>
                </div>

                <div className="pt-4 border-t space-y-2">
                  <button className="w-full px-3 py-2 text-sm font-medium text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors">
                    View Full Profile
                  </button>
                  <button className="w-full px-3 py-2 text-sm font-medium text-gray-600 bg-gray-50 rounded-lg hover:bg-gray-100 transition-colors">
                    Send Alert
                  </button>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Recent Alerts */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg flex items-center gap-2">
                <AlertTriangle className="w-5 h-5 text-amber-500" />
                Recent Alerts
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {recentAlerts.length === 0 ? (
                <div className="text-center py-6 text-muted-foreground">
                  <Shield className="w-12 h-12 mx-auto mb-2 opacity-50" />
                  <p className="text-sm">No recent alerts</p>
                  <p className="text-xs">All tourists are safe</p>
                </div>
              ) : (
                <div className="space-y-3 max-h-96 overflow-y-auto">
                  {recentAlerts.map((alert) => (
                    <Alert key={alert.id} className="border-amber-200 bg-amber-50">
                      <AlertTriangle className="h-4 w-4 text-amber-600" />
                      <AlertDescription className="text-sm">
                        <div className="font-medium text-amber-800">{alert.touristName}</div>
                        <div className="text-amber-700">{alert.message}</div>
                        <div className="text-xs text-amber-600 mt-1">
                          {new Date(alert.timestamp).toLocaleTimeString()}
                        </div>
                      </AlertDescription>
                    </Alert>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>

          {/* Map Controls Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-sm">Map Controls</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2 text-xs text-muted-foreground">
              <div className="flex items-center gap-2">
                <Play className="w-3 h-3" />
                <span>Play/Pause real-time updates</span>
              </div>
              <div className="flex items-center gap-2">
                <Layers className="w-3 h-3" />
                <span>Switch between heatmap/points/both</span>
              </div>
              <div className="flex items-center gap-2">
                <RotateCcw className="w-3 h-3" />
                <span>Reset view to original position</span>
              </div>
              <div className="pt-2 border-t text-xs">
                <p>Click on tourists or safety points for detailed information</p>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
