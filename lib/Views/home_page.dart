import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/student_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    // FIX: load role and applications together on init
    _loadData();
  }

  Future<void> _loadData() async {
    // Load role
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null && mounted) {
          final role = response['role'].toString().trim().toLowerCase();
          setState(() {
            isAdmin = role == 'admin';
          });
        }
      } catch (e) {
        print('Role load error: $e');
      }
    }

    // Load applications
    if (mounted) {
      await context.read<StudentViewModel>().loadApplications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final studentViewModel = context.watch<StudentViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? 'Admin Dashboard' : 'Student Assistant Dashboard',
        ),
        actions: [
          // Admin icon button in AppBar
          if (isAdmin)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
              icon: const Icon(Icons.admin_panel_settings),
            ),

          // Refresh
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),

          // Logout
          IconButton(
            onPressed: () async {
              await authViewModel.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAdmin ? 'Hello Admin' : 'Hello Student',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 10),

            Text(
              isAdmin
                  ? 'Manage all student assistant applications below.'
                  : 'Manage your student assistant applications below.',
            ),

            const SizedBox(height: 20),

            if (studentViewModel.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (studentViewModel.applications.isEmpty)
              const Expanded(
                child: Center(child: Text('No applications found.')),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: studentViewModel.applications.length,
                  itemBuilder: (context, index) {
                    final application = studentViewModel.applications[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(application.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Number: ${application.studentNumber}',
                            ),
                            Text('Module: ${application.firstModule}'),
                            const SizedBox(height: 5),
                            Chip(label: Text(application.status)),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              if (application.status == 'Pending' || isAdmin) {
                                await Navigator.pushNamed(
                                  context,
                                  '/student-form',
                                  arguments: application,
                                );
                                if (mounted) {
                                  await context
                                      .read<StudentViewModel>()
                                      .loadApplications();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Only pending applications can be edited.',
                                    ),
                                  ),
                                );
                              }
                            }

                            if (value == 'delete') {
                              await _deleteApplication(application);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/student-detail',
                            arguments: application,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),

      // FIX: pushNamed so admin can navigate back; FAB only shows correct option
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                // FIX: pushNamed (not pushReplacementNamed) so back button works
                Navigator.pushNamed(context, '/admin');
              },
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text('Admin Dashboard'),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/student-form');
              },
              icon: const Icon(Icons.add),
              label: const Text('New Application'),
            ),
    );
  }

  Future<void> _deleteApplication(StudentApplication application) async {
    if (application.status != 'Pending' && !isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only pending applications can be deleted.'),
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Application'),
            content: const Text(
              'Are you sure you want to delete this application?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await context.read<StudentViewModel>().deleteApplication(application.id);
      if (mounted) {
        await context.read<StudentViewModel>().loadApplications();
      }
    }
  }
}
