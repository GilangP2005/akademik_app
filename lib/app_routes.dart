import 'package:flutter/material.dart';

// Auth / Home
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';

// Courses
import 'screens/courses/courses_screen.dart';
import 'screens/courses/course_form_screen.dart';
import 'screens/courses/course_detail_screen.dart'; // ✅ ada CourseDetailScreen

// Attendance
import 'screens/attendance/attendance_screen.dart';
import 'screens/attendance/attendance_form_screen.dart';

class AppRoutes {
  // Auth
  static const String login = '/login';

  // Home
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Courses
  static const String courses = '/courses';
  static const String courseForm = '/course-form';
  static const String courseDetail = '/course-detail';

  // Attendance
  static const String attendance = '/attendance';
  static const String attendanceForm = '/attendance-form';
  static const String attendanceDetail = '/attendance-detail';

  // Profile
  static const String profile = '/profile';

  static final Map<String, WidgetBuilder> routes = {
    login: (_) => const LoginScreen(),

    home: (_) => const HomeScreen(),
    dashboard: (_) => const DashboardScreen(),

    courses: (_) => const CoursesScreen(),
    courseForm: (_) => const CourseFormScreen(),
    courseDetail: (_) => const CourseDetailScreen(), // ✅ FIX: tanpa "s"

    attendance: (_) => const AttendanceScreen(),
    attendanceForm: (_) => const AttendanceFormScreen(),
    attendanceDetail: (_) => const AttendanceDetailScreen(),

    profile: (_) => const ProfileScreen(),
  };
}
