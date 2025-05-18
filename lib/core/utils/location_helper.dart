import 'package:flutter/services.dart';

class LocationHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.employee_attendance_app/location');

  static Future<Map<String, dynamic>> getCurrentLocation() async {
    final result = await _channel.invokeMethod<Map>('getCurrentLocation');
    return {
      'latitude': result!['latitude'],
      'longitude': result['longitude'],
      'address': result['address'],
    };
  }
}
