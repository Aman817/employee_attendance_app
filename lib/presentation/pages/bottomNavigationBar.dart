import 'package:employee_attendance_app/core/database/attendance_db.dart';
import 'package:employee_attendance_app/core/utils/app_colors.dart';
import 'package:employee_attendance_app/logic/attendance/bloc/attendance_bloc.dart';
import 'package:employee_attendance_app/logic/reminder/bloc/reminder_bloc.dart';
import 'package:employee_attendance_app/presentation/pages/home_page.dart';
import 'package:employee_attendance_app/presentation/pages/reminder_screen.dart';
import 'package:employee_attendance_app/presentation/pages/timelineScreen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  AttendanceDatabase? attendanceDatabase;

  final List<Widget> _pages = [
    HomeScreen(),
    TimelineScreen(),
    ReminderScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final db = await AttendanceDatabase.create();
    setState(() {
      attendanceDatabase = db;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (attendanceDatabase == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AttendanceBloc(attendanceDatabase!),
        ),
        BlocProvider(
          create: (_) => ReminderBloc(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        body: _pages[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: AppColors.background,
          color: Colors.white,
          buttonBackgroundColor: AppColors.primary,
          height: 60,
          animationDuration: Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          index: _currentIndex,
          items: <Widget>[
            Icon(Icons.home,
                size: 30,
                color: _currentIndex != 0 ? Colors.black : Colors.white),
            Icon(Icons.person,
                size: 30,
                color: _currentIndex != 1 ? Colors.black : Colors.white),
            Icon(Icons.timer,
                size: 30,
                color: _currentIndex != 2 ? Colors.black : Colors.white),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
