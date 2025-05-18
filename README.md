# employee_attendance_app

A new Flutter project.




# Setup Guide

## Prerequisites


- Flutter SDK (version 3.0.0 or higher)

- Android Studio or VSCode with Flutter & Dart plugins installed

- Android device or emulator 

## Installation & Running
 - git clone  https://github.com/Aman817/employee_attendance_app.git
 - cd employee_attendance_app
 - flutter pub get
 - flutter run

# Permissions Required

## SCHEDULE_EXACT_ALARM
    - Required on Android 12+ to schedule precise alarms for check-in and check-out reminders.
## CAMERA


# Architecture Overview

# Flutter Layer
    # Bloc Pattern (attendance_bloc,reminder_bloc ):
    The attendance_bloc manages the state and business logic for the daily attendance feature. It handles events such as check-in, check-out, fetching attendance status, and timeline data for the last 7 days. It also processes selfie captures and location data to update the UI accordingly.

    # Screens and Features:



    # Home Screen  Check-In/Check-Out Buttons:
        - Allows users to quickly mark their attendance with check-in and check-out actions.
        - Displays the current attendance status (e.g., checked in, checked out, pending).
        - Shows the latest selfie taken during check-in or check-out as a confirmation.

    # Timeline Screen:
        - Displays a timeline view for the current day plus the past 7 days.
        - Each timeline entry includes check-in/check-out times.

    # Selfie Camera:
        - Custom camera screen integrated with native Android/iOS camera services.
        - Supports background or selfie mode for capturing attendance photos seamlessly within the app workflow.

    # Set Reminder Screen:
        - Allows users to select custom check-in and check-out reminder times via a time picker UI.
        - These reminders are saved locally and scheduled through native alarm services.

    # SQLite Database:

    - Stores attendance logs including check-in/check-out times, selfie image paths, and location data.

    - The local database supports offline access and historical data retrieval for the timeline feature.

