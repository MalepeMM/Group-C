
/*
TPG316C GROUP ASSINGMENT:Group C
CHAUKE S   223032277
KGATUKE M  222029835
MASHELE PV 224120975
Malepe T   223015611
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List applications = [];
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    loadApplications();
  }

  Future<void> loadApplications() async {
    dynamic query = Supabase.instance.client.from('applications').select();

    if (filter != 'All') {
      query = query.eq('status', filter);
    }

    final response = await query;

    setState(() {
      applications = response;
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await Supabase.instance.client
        .from('applications')
        .update({'status': status})
        .eq('id', id);

    loadApplications();
  }

  Future<void> deleteApplication(String id) async {
    await Supabase.instance.client.from('applications').delete().eq('id', id);

    loadApplications();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: loadApplications,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: filter,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(
                  value: 'Pending',
                  child: Text(
                    'Pending',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Approved',
                  child: Text(
                    'Approved',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
                DropdownMenuItem(
                  value: 'Rejected',
                  child: Text('Rejected', style: TextStyle(color: Colors.red)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  filter = value!;
                });
                loadApplications();
              },
            ),
          ),

          Expanded(
            child: applications.isEmpty
                ? const Center(child: Text('No applications found.'))
                : ListView.builder(
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      final app = applications[index];

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app['full_name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text('Student Number: ${app['student_number']}'),
                              Text('Module: ${app['first_module']}'),
                              Text('Status: ${app['status']}'),

                              const SizedBox(height: 10),

                              if (app['document_url'] != null)
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.description),
                                  label: const Text('Document Uploaded'),
                                ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        updateStatus(app['id'], 'Approved'),
                                    child: const Text(
                                      'Approve',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () =>
                                        updateStatus(app['id'], 'Rejected'),
                                    child: const Text(
                                      'Reject',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () =>
                                        deleteApplication(app['id']),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}