import 'package:employee_attendance_app/core/database/attendance_db.dart';
import 'package:employee_attendance_app/core/models/attendance_model.dart';
import 'package:employee_attendance_app/core/native_channels/camera_channel.dart';
import 'package:employee_attendance_app/core/utils/location_helper.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_event.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceDatabase db;

  AttendanceBloc(this.db) : super(AttendanceInitial()) {
    on<CheckInRequested>(_onCheckIn);
    on<CheckOutRequested>(_onCheckOut);
    on<LoadAttendanceLogs>(_onLoadLogs);
    on<LoadAttendancelastsevenLogs>(_onLoadlastLogs);
  }

  Future<void> _onCheckIn(CheckInRequested event, Emitter emit) async {
    print("object checkin");
    emit(AttendanceLoading());
    try {
      final imagePath = await NativeCamera.captureSelfie();
      final location = await LocationHelper.getCurrentLocation();
      final now = DateTime.now();

      final entry = AttendanceModel(
        id: null,
        timestamp: now,
        type: 'check-in',
        imagePath: imagePath,
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        address: location['address']!,
      );
      await db.insertLog(entry);
      add(LoadAttendanceLogs());
    } catch (e) {
      emit(AttendanceFailure(e.toString()));
    }
  }

  Future<void> _onCheckOut(CheckOutRequested event, Emitter emit) async {
    emit(AttendanceLoading());
    try {
      final imagePath = await NativeCamera.captureSelfie();
      final location = await LocationHelper.getCurrentLocation();
      final now = DateTime.now();

      final entry = AttendanceModel(
        id: null,
        timestamp: now,
        type: 'check-out',
        imagePath: imagePath,
        latitude: location['latitude']!,
        longitude: location['longitude']!,
        address: location['address']!,
      );

      await db.insertLog(entry);
      add(LoadAttendanceLogs()); // reload logs
    } catch (e) {
      emit(AttendanceFailure(e.toString()));
    }
  }

  Future<void> _onLoadLogs(LoadAttendanceLogs event, Emitter emit) async {
    final logs = await db.getLogs();
    emit(AttendanceSuccess(logs));
  }

  Future<void> _onLoadlastLogs(
      LoadAttendancelastsevenLogs event, Emitter emit) async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(Duration(days: 7));

      // Fetch all logs from the database
      final logs = await db.getLogs();

      // Filter logs that are from the last 7 days
      final filteredLogs = logs.where((log) {
        return log.timestamp.isAfter(sevenDaysAgo);
      }).toList();

      emit(AttendanceSuccess(filteredLogs));
    } catch (e) {
      emit(AttendanceFailure(e.toString()));
    }
  }
}
