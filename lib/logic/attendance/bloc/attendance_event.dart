abstract class AttendanceEvent {}

class CheckInRequested extends AttendanceEvent {}

class CheckOutRequested extends AttendanceEvent {}

class LoadAttendanceLogs extends AttendanceEvent {}

class LoadAttendancelastsevenLogs extends AttendanceEvent {}
