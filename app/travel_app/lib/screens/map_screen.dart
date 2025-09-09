import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/location_provider.dart';
import 'copyrights_page.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String _tomtomApiKey = "oP7TR9pF4oKO35fN8MQ1uD3mQIiaHx1z";
  MapController? _mapController;
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.initializeLocation();
    if (locationProvider.currentLocation != null && mounted) {
      _moveToCurrentLocation();
    }
  }

  void _moveToCurrentLocation() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.currentLocation != null && _mapController != null) {
      final location = locationProvider.currentLocation!;
      _mapController!.move(
        LatLng(location.latitude, location.longitude),
        15.0,
      );
    }
  }

  void _toggleTracking() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    setState(() {
      _isTracking = !_isTracking;
    });
    
    if (_isTracking) {
      locationProvider.startLiveTracking();
    } else {
      locationProvider.stopLiveTracking();
    }
  }

  Color _getSafetyColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Map'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
            onPressed: _toggleTracking,
            tooltip: _isTracking ? 'Stop Tracking' : 'Start Tracking',
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.hasPermission == false) {
            return _buildLocationErrorView(locationProvider);
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: locationProvider.currentLocation != null
                      ? LatLng(
                          locationProvider.currentLocation!.latitude,
                          locationProvider.currentLocation!.longitude,
                        )
                      : const LatLng(28.6139, 77.2090), // Default to Delhi
                  initialZoom: 15.0,
                  onMapReady: () {
                    if (locationProvider.currentLocation != null) {
                      _moveToCurrentLocation();
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://api.tomtom.com/map/1/tile/basic/main/"
                        "{z}/{x}/{y}.png?key={apiKey}",
                    additionalOptions: {"apiKey": _tomtomApiKey},
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(locationProvider),
                  ),
                  CircleLayer(
                    circles: _buildGeofenceCircles(locationProvider),
                  ),
                ],
              ),
              // TomTom Logo (required by terms of service)
              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/tt_logo.png",
                    height: 20,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'TomTom',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Safety Score Display
              if (locationProvider.currentSafetyScore != null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: _buildSafetyScoreCard(locationProvider.currentSafetyScore!),
                ),
              // Location Info
              if (locationProvider.currentLocation != null)
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: _buildLocationInfoCard(locationProvider),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "copyright",
            onPressed: _showCopyrights,
            child: const Icon(Icons.copyright),
            tooltip: 'Show Copyrights',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "location",
            onPressed: _moveToCurrentLocation,
            child: const Icon(Icons.my_location),
            tooltip: 'My Location',
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(LocationProvider locationProvider) {
    List<Marker> markers = [];

    // Current location marker
    if (locationProvider.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            locationProvider.currentLocation!.latitude,
            locationProvider.currentLocation!.longitude,
          ),
          width: 80,
          height: 80,
          child: const Icon(
            Icons.location_on,
            size: 40,
            color: Colors.blue,
          ),
        ),
      );
    }

    // Geofence markers
    for (final geofence in locationProvider.geofences) {
      // Calculate safety level based on geofence type
      double safetyLevel = geofence.isRestrictedZone ? 20.0 : 80.0;
      
      markers.add(
        Marker(
          point: LatLng(geofence.centerLatitude, geofence.centerLongitude),
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: _getSafetyColor(safetyLevel),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              geofence.isRestrictedZone ? Icons.warning : Icons.info,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<CircleMarker> _buildGeofenceCircles(LocationProvider locationProvider) {
    List<CircleMarker> circles = [];

    for (final geofence in locationProvider.geofences) {
      // Calculate safety level based on geofence type
      double safetyLevel = geofence.isRestrictedZone ? 20.0 : 80.0;
      
      circles.add(
        CircleMarker(
          point: LatLng(geofence.centerLatitude, geofence.centerLongitude),
          radius: geofence.radius,
          color: _getSafetyColor(safetyLevel).withOpacity(0.3),
          borderColor: _getSafetyColor(safetyLevel),
          borderStrokeWidth: 2,
        ),
      );
    }

    return circles;
  }

  Widget _buildSafetyScoreCard(dynamic safetyScore) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.security,
              color: _getSafetyColor(safetyScore.score.toDouble()),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Safety Score',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${safetyScore.score}%',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getSafetyColor(safetyScore.score.toDouble()),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfoCard(LocationProvider locationProvider) {
    final location = locationProvider.currentLocation!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${location.latitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Lng: ${location.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Accuracy: ${location.accuracy.toStringAsFixed(1)}m',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationErrorView(LocationProvider locationProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_disabled,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Location Access Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please enable location permissions to use the map.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => locationProvider.openLocationSettings(),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCopyrights() async {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CopyrightsPage(
            copyrightsText: 'TomTom Maps API Copyrights\n\n'
                'This application uses TomTom Maps API.\n'
                'For more information about copyrights and terms of use, '
                'please visit: https://developer.tomtom.com/maps-api/maps-api-documentation',
          ),
        ),
      );
    }
  }
}
