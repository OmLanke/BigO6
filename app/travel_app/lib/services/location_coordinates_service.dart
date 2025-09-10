import 'package:latlong2/latlong.dart';

class LocationCoordinatesService {
  // Sample coordinates for planned locations in India
  static final Map<String, LatLng> _locationCoordinates = {
    // Delhi locations
    'Red Fort, Delhi': const LatLng(28.6562, 77.2410),
    'India Gate, Delhi': const LatLng(28.6129, 77.2295),
    'Qutub Minar, Delhi': const LatLng(28.5245, 77.1855),
    'Lotus Temple, Delhi': const LatLng(28.5535, 77.2588),
    'Humayun\'s Tomb, Delhi': const LatLng(28.5933, 77.2507),
    'Jama Masjid, Delhi': const LatLng(28.6507, 77.2334),
    'Akshardham Temple, Delhi': const LatLng(28.6127, 77.2773),
    'Connaught Place, Delhi': const LatLng(28.6304, 77.2177),
    'Rajghat, Delhi': const LatLng(28.6413, 77.2494),
    'Purana Qila, Delhi': const LatLng(28.6095, 77.2424),

    // Agra locations
    'Taj Mahal, Agra': const LatLng(27.1751, 78.0421),
    'Agra Fort, Agra': const LatLng(27.1795, 78.0211),
    'Fatehpur Sikri, Agra': const LatLng(27.0937, 77.6615),
    'Mehtab Bagh, Agra': const LatLng(27.1776, 78.0422),
    'Itimad-ud-Daulah, Agra': const LatLng(27.1816, 78.0259),

    // Mumbai locations
    'Gateway of India, Mumbai': const LatLng(18.9220, 72.8347),
    'Marine Drive, Mumbai': const LatLng(18.9439, 72.8234),
    'Chhatrapati Shivaji Terminus, Mumbai': const LatLng(18.9401, 72.8352),
    'Elephanta Caves, Mumbai': const LatLng(18.9633, 72.9313),
    'Haji Ali Dargah, Mumbai': const LatLng(18.9826, 72.8093),
    'Juhu Beach, Mumbai': const LatLng(19.0968, 72.8268),
    'Siddhivinayak Temple, Mumbai': const LatLng(19.0167, 72.8306),
    'Bandra-Worli Sea Link, Mumbai': const LatLng(19.0377, 72.8187),

    // Jaipur locations
    'Hawa Mahal, Jaipur': const LatLng(26.9239, 75.8267),
    'Amer Fort, Jaipur': const LatLng(26.9855, 75.8513),
    'City Palace, Jaipur': const LatLng(26.9255, 75.8236),
    'Jantar Mantar, Jaipur': const LatLng(26.9247, 75.8249),
    'Nahargarh Fort, Jaipur': const LatLng(26.9344, 75.8155),
    'Jaigarh Fort, Jaipur': const LatLng(26.9853, 75.8515),

    // Goa locations
    'Basilica of Bom Jesus, Goa': const LatLng(15.5007, 73.9117),
    'Calangute Beach, Goa': const LatLng(15.5438, 73.7651),
    'Baga Beach, Goa': const LatLng(15.5564, 73.7516),
    'Dudhsagar Falls, Goa': const LatLng(15.3144, 74.3144),
    'Fort Aguada, Goa': const LatLng(15.4969, 73.7737),
    'Anjuna Beach, Goa': const LatLng(15.5731, 73.7401),

    // Kerala locations
    'Munnar, Kerala': const LatLng(10.0889, 77.0595),
    'Alleppey Backwaters, Kerala': const LatLng(9.4981, 76.3388),
    'Kumarakom, Kerala': const LatLng(9.6177, 76.4278),
    'Cochin, Kerala': const LatLng(9.9312, 76.2673),
    'Wayanad, Kerala': const LatLng(11.6054, 76.0861),
    'Thekkady, Kerala': const LatLng(9.5916, 77.1603),

    // Rajasthan locations
    'Udaipur City Palace, Rajasthan': const LatLng(24.5764, 73.6837),
    'Lake Pichola, Udaipur': const LatLng(24.5714, 73.6783),
    'Jaisalmer Fort, Rajasthan': const LatLng(26.9157, 70.9083),
    'Mehrangarh Fort, Jodhpur': const LatLng(26.2971, 73.0187),
    'Pushkar Lake, Rajasthan': const LatLng(26.4899, 74.5511),

    // Tamil Nadu locations
    'Meenakshi Temple, Madurai': const LatLng(9.9195, 78.1194),
    'Marina Beach, Chennai': const LatLng(13.0487, 80.2832),
    'Mahabalipuram, Tamil Nadu': const LatLng(12.6269, 80.1927),
    'Ooty, Tamil Nadu': const LatLng(11.4064, 76.6932),
    'Kodaikanal, Tamil Nadu': const LatLng(10.2381, 77.4892),

    // Karnataka locations
    'Mysore Palace, Karnataka': const LatLng(12.3051, 76.6551),
    'Hampi, Karnataka': const LatLng(15.3350, 76.4600),
    'Coorg, Karnataka': const LatLng(12.3375, 75.8069),
    'Bangalore Palace, Karnataka': const LatLng(12.9988, 77.5924),
    'Belur Halebidu, Karnataka': const LatLng(13.1624, 75.8648),

    // Himachal Pradesh locations
    'Shimla, Himachal Pradesh': const LatLng(31.1048, 77.1734),
    'Manali, Himachal Pradesh': const LatLng(32.2396, 77.1887),
    'Dharamshala, Himachal Pradesh': const LatLng(32.2190, 76.3234),
    'Dalhousie, Himachal Pradesh': const LatLng(32.5448, 75.9618),
    'Kasol, Himachal Pradesh': const LatLng(32.0096, 77.3071),

    // Uttarakhand locations
    'Rishikesh, Uttarakhand': const LatLng(30.0869, 78.2676),
    'Haridwar, Uttarakhand': const LatLng(29.9457, 78.1642),
    'Nainital, Uttarakhand': const LatLng(29.3803, 79.4636),
    'Mussoorie, Uttarakhand': const LatLng(30.4598, 78.0664),
    'Valley of Flowers, Uttarakhand': const LatLng(30.7268, 79.6044),
  };

  /// Get coordinates for a location name
  static LatLng? getCoordinates(String locationName) {
    // Try exact match first
    if (_locationCoordinates.containsKey(locationName)) {
      return _locationCoordinates[locationName];
    }

    // Try partial match (case insensitive)
    final lowerCaseName = locationName.toLowerCase();
    for (final entry in _locationCoordinates.entries) {
      if (entry.key.toLowerCase().contains(lowerCaseName) ||
          lowerCaseName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // If no match found, return null
    return null;
  }

  /// Get all planned location coordinates from a list of location names
  static List<PlannedLocationMarker> getPlannedLocationMarkers(
    List<String> locationNames,
  ) {
    final List<PlannedLocationMarker> markers = [];

    for (int i = 0; i < locationNames.length; i++) {
      final locationName = locationNames[i];
      final coordinates = getCoordinates(locationName);

      if (coordinates != null) {
        markers.add(
          PlannedLocationMarker(
            id: 'planned_$i',
            name: locationName,
            coordinates: coordinates,
            order: i + 1,
          ),
        );
      }
    }

    return markers;
  }

  /// Get center point for a list of coordinates (for map centering)
  static LatLng getCenterPoint(List<LatLng> coordinates) {
    if (coordinates.isEmpty) {
      return const LatLng(28.6139, 77.2090); // Default to Delhi
    }

    if (coordinates.length == 1) {
      return coordinates.first;
    }

    double totalLat = 0;
    double totalLng = 0;

    for (final coord in coordinates) {
      totalLat += coord.latitude;
      totalLng += coord.longitude;
    }

    return LatLng(totalLat / coordinates.length, totalLng / coordinates.length);
  }

  /// Get appropriate zoom level based on the spread of coordinates
  static double getAppropriateZoom(List<LatLng> coordinates) {
    if (coordinates.isEmpty || coordinates.length == 1) {
      return 15.0;
    }

    double minLat = coordinates.first.latitude;
    double maxLat = coordinates.first.latitude;
    double minLng = coordinates.first.longitude;
    double maxLng = coordinates.first.longitude;

    for (final coord in coordinates) {
      minLat = minLat < coord.latitude ? minLat : coord.latitude;
      maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
      minLng = minLng < coord.longitude ? minLng : coord.longitude;
      maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
    }

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Rough zoom calculation based on coordinate spread
    if (maxDiff > 10) return 5.0; // Country level
    if (maxDiff > 5) return 7.0; // Multi-state level
    if (maxDiff > 1) return 9.0; // State level
    if (maxDiff > 0.5) return 11.0; // City level
    if (maxDiff > 0.1) return 13.0; // District level
    return 15.0; // Local level
  }
}

/// Class to represent a planned location marker
class PlannedLocationMarker {
  final String id;
  final String name;
  final LatLng coordinates;
  final int order; // Order in the planned itinerary

  PlannedLocationMarker({
    required this.id,
    required this.name,
    required this.coordinates,
    required this.order,
  });
}
