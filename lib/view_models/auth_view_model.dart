/*
TPG316C GROUP ASSINGMENT:Group C
CHAUKE S   223032277
KGATUKE M  222029835
MASHELE PV 224120975
Malepe T   223015611
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;
  String? get userId => Supabase.instance.client.auth.currentUser?.id;
  String? get userEmail => Supabase.instance.client.auth.currentUser?.email;

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      isLoading = false;
      if (response.session != null) {
        notifyListeners();
        return true;
      }

      errorMessage = 'Login failed. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      isLoading = false;
      if (response.user != null) {
        notifyListeners();
        return true;
      }

      errorMessage = 'Signup failed. Please try again.';
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  // FIX: null-safe getUserRole
  Future<String> getUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;

    // No user logged in — return safe default
    if (user == null) return 'student';

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return 'student';

      return response['role'].toString().trim().toLowerCase();
    } catch (e) {
      print('getUserRole error: $e');
      return 'student';
    }
  }
}
