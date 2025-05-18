import 'dart:io';

import 'package:employee_attendance_app/core/models/attendance_model.dart';
import 'package:employee_attendance_app/core/utils/app_style.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_bloc.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_event.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_state.dart';
import 'package:employee_attendance_app/presentation/widgets/attendancecardstatus.dart';
import 'package:employee_attendance_app/presentation/widgets/attendancehistory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final today = DateTime.now();
  AttendanceModel? checkIn;
  AttendanceModel? checkOut;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(LoadAttendanceLogs());
  }

  void _handleCheckIn() {
    context.read<AttendanceBloc>().add(CheckInRequested());
  }

  void _handleCheckOut() {
    context.read<AttendanceBloc>().add(CheckOutRequested());
  }

  void handleButtonPress() {
    setState(() {
      if (checkIn == null || (checkOut != null && checkIn != null)) {
        _handleCheckIn();
        checkOut = null;
      } else if (checkOut == null) {
        _handleCheckOut();

        checkOut = AttendanceModel(
          timestamp: DateTime.now(),
          type: 'check-out',
          latitude: 0.0,
          longitude: 0.0,
          imagePath: '',
          address: '',
        );
      } else {
        checkIn = null;
        checkOut = null;
      }

      context.read<AttendanceBloc>().add(LoadAttendanceLogs());
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);

    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          String buttonText = 'Check In';
          if (checkIn != null && checkOut == null) {
            buttonText = 'Check Out';
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width - 32,
            height: 56,
            child: FloatingActionButton.extended(
              onPressed: handleButtonPress,
              label: Text(
                buttonText,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: buttonText == 'Check In'
                  ? Color(0xff4491FE)
                  : Color(0xffFE8B81),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.height * .03),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aman Gangwar",
                        style: AppStyle.mediumtitle.copyWith(
                          fontSize: size.width * .05,
                        ),
                      ),
                      Text(
                        "Sr. Software Developer",
                        style: AppStyle.ligthtitle.copyWith(
                          fontSize: size.width * .03,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    if (state is AttendanceLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is AttendanceSuccess) {
                      final logs = state.logs;
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTodayStatus(logs, size),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    } else if (state is AttendanceFailure) {
                      return Center(child: Text("Error: ${state.error}"));
                    }
                    return const Center(child: Text("No data available."));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTodayStatus(List<AttendanceModel> logs, Size size) {
    final todayLogs =
        logs.where((log) => _isSameDay(log.timestamp, today)).toList();

    checkIn = todayLogs
        .where((log) => log.type == 'check-in')
        .fold<AttendanceModel?>(null, (prev, curr) {
      if (prev == null || curr.timestamp.isAfter(prev.timestamp)) {
        return curr;
      }
      return prev;
    });

    checkOut = todayLogs
        .where((log) =>
            log.type == 'check-out' &&
            checkIn != null &&
            log.timestamp.isAfter(checkIn!.timestamp))
        .fold<AttendanceModel?>(null, (prev, curr) {
      if (prev == null || curr.timestamp.isAfter(prev.timestamp)) {
        return curr;
      }
      return prev;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Attendance",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Attendancecardstatus(
              size,
              checkIn,
              Icons.login,
              "Check In",
              checkIn != null ? "On Time" : "--",
              checkIn?.address ?? "--",
            ),
            Attendancecardstatus(
              size,
              checkOut,
              Icons.logout_rounded,
              "Check Out",
              checkOut != null ? "Go Home" : "--",
              checkOut?.address ?? "--",
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Your Today Activity",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
        ),
        if (todayLogs.isEmpty) const Text("No attendance recorded yet."),
        ...todayLogs.map((log) {
          final formattedTime = DateFormat('hh:mm a').format(log.timestamp);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Attendancehistorycardstatus(
              size,
              log,
              log.type == 'check-in' ? Icons.login : Icons.logout,
              log.type == 'check-in' ? "Check In" : "Check Out",
              log.type == 'check-in' ? "On Time" : "Go Home",
            ),
          );
        }).toList(),
      ],
    );
  }
}
