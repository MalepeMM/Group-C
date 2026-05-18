/*
TPG316C GROUP ASSINGMENT:Group C
CHAUKE S   223032277
KGATUKE M  222029835
MASHELE PV 224120975
Malepe T   223015611
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

class StudentViewModel extends ChangeNotifier {
  final List<StudentApplication> _applications = [];

  bool isLoading = false;
  String? errorMessage;

  List<StudentApplication> get applications => _applications;

  Future<void> loadApplications() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final response = await Supabase.instance.client
          .from('applications')
          .select()
          .eq('user_id', userId);

      _applications.clear();

      for (final item in response) {
        _applications.add(StudentApplication.fromMap(item));
      }
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addApplication(StudentApplication application) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await Supabase.instance.client
          .from('applications')
          .insert(application.toMap());

      await loadApplications();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateApplication(StudentApplication application) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await Supabase.instance.client
          .from('applications')
          .update(application.toMap())
          .eq('id', application.id);

      await loadApplications();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteApplication(String id) async {
    try {
      await Supabase.instance.client.from('applications').delete().eq('id', id);

      _applications.removeWhere((application) => application.id == id);

      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await Supabase.instance.client
          .from('applications')
          .update({'status': status})
          .eq('id', id);

      await loadApplications();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
