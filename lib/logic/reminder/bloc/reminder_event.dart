abstract class ReminderEvent {}

class SetCheckInReminderEvent extends ReminderEvent {
  final String time;

  SetCheckInReminderEvent({required this.time});
}

class SetCheckOutReminderEvent extends ReminderEvent {
  final String time;

  SetCheckOutReminderEvent({required this.time});
}
