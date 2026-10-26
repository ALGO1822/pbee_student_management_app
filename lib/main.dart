import 'package:flutter/material.dart';
import 'package:pbee_collate/providers/analytics_provider.dart';
import 'package:pbee_collate/providers/archived_provider.dart';
import 'package:pbee_collate/providers/course_provider.dart';
import 'package:pbee_collate/providers/notification_provider.dart';
import 'package:pbee_collate/providers/user_login_provider.dart';
import 'package:pbee_collate/providers/user_management_provider.dart';
import 'package:pbee_collate/screens/auth_gate.dart';
import 'package:pbee_collate/constant/app_theme.dart';
import 'package:pbee_collate/providers/admin_entry_provider.dart';
import 'package:pbee_collate/providers/sign_out_provider.dart';
import 'package:pbee_collate/providers/user_entry_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pglnmznltefemojpokyg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnbG5tem5sdGVmZW1vanBva3lnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzNzMzMjIsImV4cCI6MjA3Nzk0OTMyMn0.YYw5oHqoQ6-kieGD16fABsAE6J1AL4JbOOaYimMEM5Y',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminEntryProvider()),
        ChangeNotifierProvider(create: (_) => UserEntryProvider()),
        ChangeNotifierProvider(create: (_) => SignOutProvider()),
        ChangeNotifierProvider(create: (_) => UserLoginProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => ArchiveProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pbee Collate',
      theme: AppTheme.light,
      home: AuthGate(),
    );
  }
}
