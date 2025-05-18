abstract class ReminderState {}

class ReminderInitial extends ReminderState {}

class ReminderSetSuccess extends ReminderState {
  final String message;

  ReminderSetSuccess({required this.message});
}

class ReminderFailure extends ReminderState {
  final String error;

  ReminderFailure({required this.error});
}
