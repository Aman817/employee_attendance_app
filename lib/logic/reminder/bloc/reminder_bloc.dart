import 'package:bloc/bloc.dart';
import 'package:employee_attendance_app/core/database/reminder_db.dart';
import 'package:employee_attendance_app/logic/reminder/bloc/reminder_event.dart';
import 'package:employee_attendance_app/logic/reminder/bloc/reminder_state.dart';
import 'package:flutter/services.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  static const platform =
      MethodChannel('com.example.employee_attendance_app/reminder');
  final ReminderDatabaseHelper _databaseHelper = ReminderDatabaseHelper();

  ReminderBloc() : super(ReminderInitial()) {
    on<SetCheckInReminderEvent>((event, emit) async {
      try {
        final checkInTime = event.time;
        await platform.invokeMethod('scheduleReminder', {
          'checkInEnabled': true,
          'checkInTime': checkInTime,
          'checkOutEnabled': false,
          'checkOutTime': '',
          'message': "Hi Aman Gangwar, don’t forget to check-in!"
        });

        await _databaseHelper.saveReminder(checkInTime, '');

        emit(ReminderSetSuccess(
            message: "Check-in Reminder set for $checkInTime"));
      } catch (e) {
        emit(ReminderFailure(error: "Failed to set Check-in Reminder"));
      }
    });

    on<SetCheckOutReminderEvent>((event, emit) async {
      try {
        final checkOutTime = event.time;
        await platform.invokeMethod('scheduleReminder', {
          'checkInEnabled': false,
          'checkInTime': '',
          'checkOutEnabled': true,
          'checkOutTime': checkOutTime,
          'message': "Time to check-out for the day!"
        });

        await _databaseHelper.saveReminder('', checkOutTime);

        emit(ReminderSetSuccess(
            message: "Check-out Reminder set for $checkOutTime"));
      } catch (e) {
        emit(ReminderFailure(error: "Failed to set Check-out Reminder"));
      }
    });
  }

  Future<void> requestExactAlarmPermission() async {
    try {
      final result =
          await platform.invokeMethod<String>('requestExactAlarmPermission');
      print("Exact Alarm Permission Result: $result");
    } on PlatformException catch (e) {
      print("Error requesting exact alarm permission: ${e.message}");
    }
  }
}
