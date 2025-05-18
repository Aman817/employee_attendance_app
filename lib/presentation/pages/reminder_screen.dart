import 'package:employee_attendance_app/core/utils/app_colors.dart';
import 'package:employee_attendance_app/core/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employee_attendance_app/logic/reminder/bloc/reminder_bloc.dart';
import 'package:employee_attendance_app/logic/reminder/bloc/reminder_event.dart';
import 'package:employee_attendance_app/logic/reminder/bloc/reminder_state.dart';
import 'package:intl/intl.dart';

class ReminderScreen extends StatefulWidget {
  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final TextEditingController checkInController = TextEditingController();
  final TextEditingController checkOutController = TextEditingController();

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final formattedTime = selectedTime.format(context);
      controller.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReminderBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Set Daily Reminders"),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Set your daily reminders for Check-in and Check-out times.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 30),
              _buildTimeField(
                controller: checkInController,
                label: "Check-in Time",
                onTap: () => _selectTime(context, checkInController),
              ),
              SizedBox(height: 24),
              _buildTimeField(
                controller: checkOutController,
                label: "Check-out Time",
                onTap: () => _selectTime(context, checkOutController),
              ),
              SizedBox(height: 40),
              BlocConsumer<ReminderBloc, ReminderState>(
                listener: (context, state) {
                  if (state is ReminderSetSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is ReminderFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ReminderInitial ||
                      state is ReminderFailure ||
                      state is ReminderSetSuccess) {
                    return Column(
                      children: [
                        _buildSetReminderButton(
                          label: "Set Check-in Reminder",
                          onPressed: () async {
                            final checkInTime = checkInController.text;
                            if (checkInTime.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Please set Check-in time")),
                              );
                            } else {
                              await context
                                  .read<ReminderBloc>()
                                  .requestExactAlarmPermission();
                              context.read<ReminderBloc>().add(
                                  SetCheckInReminderEvent(time: checkInTime));
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        _buildSetReminderButton(
                          label: "Set Check-out Reminder",
                          onPressed: () async {
                            final checkOutTime = checkOutController.text;
                            if (checkOutTime.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("Please set Check-out time")),
                              );
                            } else {
                              await context
                                  .read<ReminderBloc>()
                                  .requestExactAlarmPermission();
                              context.read<ReminderBloc>().add(
                                  SetCheckOutReminderEvent(time: checkOutTime));
                            }
                          },
                        ),
                      ],
                    );
                  }

                  return Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.teal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal),
            ),
            hintText: "Select Time",
            suffixIcon: Icon(Icons.access_time, color: Colors.teal),
            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          ),
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildSetReminderButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          label,
          style: AppStyle.mediumtitle.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
