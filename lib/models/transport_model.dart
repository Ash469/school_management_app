class Transport {
  final String id;
  final String vehicleNumber;
  final String driverName;
  final String driverContact;
  final String driverPhotoUrl;
  final int capacity;
  final String route;
  final List<RouteStop> stops;
  final GeoLocation currentLocation;
  final DateTime locationUpdatedAt;
  final String status; // "active", "inactive", "maintenance"
  final List<String> assignedStudents; // Student IDs assigned to this transport

  Transport({
    required this.id,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverContact,
    required this.driverPhotoUrl,
    required this.capacity,
    required this.route,
    required this.stops,
    required this.currentLocation,
    required this.locationUpdatedAt,
    required this.status,
    required this.assignedStudents,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json['_id'],
      vehicleNumber: json['vehicleNumber'],
      driverName: json['driverName'],
      driverContact: json['driverContact'],
      driverPhotoUrl: json['driverPhotoUrl'],
      capacity: json['capacity'],
      route: json['route'],
      stops: (json['stops'] as List)
          .map((stop) => RouteStop.fromJson(stop))
          .toList(),
      currentLocation: GeoLocation.fromJson(json['currentLocation']),
      locationUpdatedAt: DateTime.parse(json['locationUpdatedAt']),
      status: json['status'],
      assignedStudents: List<String>.from(json['assignedStudents']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vehicleNumber': vehicleNumber,
      'driverName': driverName,
      'driverContact': driverContact,
      'driverPhotoUrl': driverPhotoUrl,
      'capacity': capacity,
      'route': route,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'currentLocation': currentLocation.toJson(),
      'locationUpdatedAt': locationUpdatedAt.toIso8601String(),
      'status': status,
      'assignedStudents': assignedStudents,
    };
  }
}

class RouteStop {
  final String name;
  final GeoLocation location;
  final String arrivalTime; // 24-hour format, e.g., "07:30"
  final String departureTime; // 24-hour format, e.g., "07:35"
  final List<String> studentsForPickup; // Student IDs for this stop
  final List<String> studentsForDrop; // Student IDs for this stop

  RouteStop({
    required this.name,
    required this.location,
    required this.arrivalTime,
    required this.departureTime,
    required this.studentsForPickup,
    required this.studentsForDrop,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      name: json['name'],
      location: GeoLocation.fromJson(json['location']),
      arrivalTime: json['arrivalTime'],
      departureTime: json['departureTime'],
      studentsForPickup: List<String>.from(json['studentsForPickup']),
      studentsForDrop: List<String>.from(json['studentsForDrop']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location.toJson(),
      'arrivalTime': arrivalTime,
      'departureTime': departureTime,
      'studentsForPickup': studentsForPickup,
      'studentsForDrop': studentsForDrop,
    };
  }
}

class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
