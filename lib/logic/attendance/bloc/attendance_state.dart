import 'package:employee_attendance_app/core/models/attendance_model.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final List<AttendanceModel> logs;
  AttendanceSuccess(this.logs);
}

class AttendanceFailure extends AttendanceState {
  final String error;
  AttendanceFailure(this.error);
}
