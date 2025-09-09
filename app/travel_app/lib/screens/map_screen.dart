import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart';
import '../providers/location_provider.dart';
import '../utils/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  MapController? _mapController;
  bool _isTracking = false;
  LatLng? _tappedLocation; // For user-tapped pinpoint

  // Animation controllers for markers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Default center point (can be changed to any location you prefer)
  static const LatLng _defaultCenter = LatLng(
    19.0728,
    72.8997,
  ); // Somaiya Campus
  static const double _initialZoom = 15.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _pulseController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    await locationProvider.initializeLocation();
    if (locationProvider.currentLocation != null && mounted) {
      _moveToCurrentLocation();
      _bounceController.reset();
      _bounceController.forward();
    }
  }

  void _moveToCurrentLocation() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    if (locationProvider.currentLocation != null && _mapController != null) {
      final location = locationProvider.currentLocation!;
      _mapController!.move(
        LatLng(location.latitude, location.longitude),
        _initialZoom,
      );
    }
  }

  void _toggleTracking() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
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
    if (score >= 80) return AppColors.safeTone;
    if (score >= 60) return AppColors.cautionTone;
    return AppColors.dangerTone;
  }

  void _onMapTap(LatLng point) {
    setState(() {
      _tappedLocation = point;
    });
    _bounceController.reset();
    _bounceController.forward();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Map'),
        backgroundColor: AppColors.primary,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: locationProvider.currentLocation != null
                          ? LatLng(
                              locationProvider.currentLocation!.latitude,
                              locationProvider.currentLocation!.longitude,
                            )
                          : _defaultCenter,
                      initialZoom: _initialZoom,
                      minZoom: 5.0,
                      maxZoom: 19.0,
                      cameraConstraint: CameraConstraint.unconstrained(),
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      onTap: (tapPosition, point) {
                        _onMapTap(point);
                      },
                    ),
                    children: [
                      // Simple OpenStreetMap tile layer
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.travel_app',
                        maxZoom: 19,
                        subdomains: const ['a', 'b', 'c'],
                        errorTileCallback: (tile, error, stackTrace) {
                          debugPrint('Tile loading error: $error');
                        },
                        tileProvider: NetworkTileProvider(),
                      ),
                      MarkerLayer(markers: _buildMarkers(locationProvider)),
                    ],
                  ),
                ),
              ),

              // Safety score card
              if (locationProvider.currentSafetyScore != null)
                Positioned(
                  top: 16,
                  left: 16,
                  child: _buildSafetyScoreCard(
                    locationProvider.currentSafetyScore!,
                  ),
                ),

              // Location info card
              if (locationProvider.currentLocation != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: _buildLocationInfoCard(
                    locationProvider.currentLocation!,
                  ),
                ),

              // Tapped location info
              if (_tappedLocation != null)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildTappedLocationCard(_tappedLocation!),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "clear_pin",
            onPressed: () {
              setState(() {
                _tappedLocation = null;
              });
            },
            child: const Icon(Icons.clear),
            tooltip: 'Clear Pin',
            backgroundColor: AppColors.cautionTone,
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "location",
            onPressed: _moveToCurrentLocation,
            child: const Icon(Icons.my_location),
            tooltip: 'My Location',
            backgroundColor: AppColors.primaryAccent,
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(LocationProvider locationProvider) {
    List<Marker> markers = [];

    // Current location marker with animation
    if (locationProvider.currentLocation != null) {
      markers.add(
        Marker(
          point: LatLng(
            locationProvider.currentLocation!.latitude,
            locationProvider.currentLocation!.longitude,
          ),
          width: 120,
          height: 120,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryAccent.withOpacity(0.5),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryAccent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    // Tapped location marker
    if (_tappedLocation != null) {
      markers.add(
        Marker(
          point: _tappedLocation!,
          width: 80,
          height: 80,
          child: AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.cautionTone,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // Geofence markers
    for (final geofence in locationProvider.geofences) {
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
            Text('Safety Score', style: Theme.of(context).textTheme.titleSmall),
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

  Widget _buildLocationInfoCard(dynamic location) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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

  Widget _buildTappedLocationCard(LatLng location) {
    return Card(
      color: AppColors.cautionTone,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_pin, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Pinned Location',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Lat: ${location.latitude.toStringAsFixed(6)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
            Text(
              'Lng: ${location.longitude.toStringAsFixed(6)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationErrorView(LocationProvider locationProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: AppColors.dangerTone),
          const SizedBox(height: 16),
          Text(
            'Location Permission Required',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please grant location permission to use the map',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => locationProvider.initializeLocation(),
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }
}
