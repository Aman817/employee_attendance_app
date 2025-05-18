import 'package:flutter/services.dart';

class NativeCamera {
  static const MethodChannel _channel =
      MethodChannel('com.example.employee_attendance_app/camera');

  static Future<String> captureSelfie() async {
    try {
      final path = await _channel.invokeMethod('captureSelfie');

      return path!;
    } on PlatformException catch (e) {
      print("Failed to capture selfie: '${e.message}'.");
      return "Failed to capture selfie: '${e.message}'.";
    }
  }
}
