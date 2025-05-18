class AttendanceModel {
  final int? id;
  final DateTime timestamp;
  final String type;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String address;

  AttendanceModel(
      {this.id,
      required this.timestamp,
      required this.type,
      required this.imagePath,
      required this.latitude,
      required this.longitude,
      required this.address});

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type,
        'imagePath': imagePath,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      imagePath: json['imagePath'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'] ?? '',
    );
  }
}
