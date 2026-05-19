/*
TPG316C GROUP ASSINGMENT:Group C
CHAUKE S   223032277
KGATUKE M  222029835
MASHELE PV 224120975
Malepe T   223015611
 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_model.dart';

import 'services/supabase_service.dart';

import 'view_models/auth_view_model.dart';
import 'view_models/student_view_model.dart';

import 'views/home_page.dart';
import 'views/login_page.dart';
import 'views/student_form_page.dart';
import 'views/student_detail_page.dart';
import '../views/admin_dashBoard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartPage() async {
    final user = Supabase.instance.client.auth.currentUser;

    // Not logged in
    if (user == null) {
      return const LoginPage();
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = response?['role'].toString().trim().toLowerCase();

      print("USER ROLE: $role");

      // Admin login
      if (role == 'admin') {
        return const AdminDashboard();
      }

      // Student login
      return const HomePage();
    } catch (e) {
      print("ROLE ERROR: $e");

      // fallback
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Assistant Application',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),

        home: FutureBuilder<Widget>(
          future: _getStartPage(),
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Show correct page
            return snapshot.data ?? const LoginPage();
          },
        ),

        routes: {
          '/login': (_) => const LoginPage(),

          '/students': (_) => const HomePage(),

          '/admin': (_) => const AdminDashboard(),

          '/student-form': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            return StudentFormPage(
              student: args is StudentApplication ? args : null,
            );
          },

          '/student-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;

            return StudentDetailPage(student: args as StudentApplication);
          },
        },
      ),
    );
  }
}
