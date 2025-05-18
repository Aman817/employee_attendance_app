import 'dart:io';
import 'package:employee_attendance_app/presentation/widgets/attendancehistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_bloc.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_event.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_state.dart';
import 'package:employee_attendance_app/core/models/attendance_model.dart';

class TimelineScreen extends StatefulWidget {
  @override
  _TimelineScreenState createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();

    context.read<AttendanceBloc>().add(LoadAttendancelastsevenLogs());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline of Attendance'),
        centerTitle: true,
      ),
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceSuccess) {
            final logs = state.logs;
            return SingleChildScrollView(
              child: Column(
                children: [
                  for (var log in logs) _buildTimelineItem(log, size),
                ],
              ),
            );
          } else if (state is AttendanceFailure) {
            return Center(child: Text(state.error));
          }
          return const Center(child: Text("No data available"));
        },
      ),
    );
  }

  Widget _buildTimelineItem(AttendanceModel log, Size size) {
    final formattedTime = DateFormat('hh:mm a').format(log.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Attendancehistorycardstatus(
        size,
        log,
        log.type == 'check-in' ? Icons.login : Icons.logout,
        log.type == 'check-in' ? "Check In" : "Check Out",
        log.type == 'check-in' ? "On Time" : "Go Home",
      ),
    );
  }
}
