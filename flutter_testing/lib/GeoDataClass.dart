class GeoData {
  final String name;
  double latitude;
  double longitude;
  double? distance;
  double? bearing;

  // Constructor
  GeoData({required this.name, required this.latitude, required this.longitude,this.distance,this.bearing});

  // Override toString for better debugging
  @override
  String toString() => 'Location(name: $name, latitude: $latitude, longitude: $longitude)';

  // Override == and hashCode for value equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeoData &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => Object.hash(name, latitude, longitude);

  // Copy with method
  GeoData copyWith({String? name, double? latitude, double? longitude}) {
    return GeoData(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}