import 'package:flutter/material.dart';
import '../models/student_model.dart';

class StudentDetailPage extends StatelessWidget {
  const StudentDetailPage({super.key, required this.student});

  final StudentApplication student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Details')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                student.fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text('Student Number: ${student.studentNumber}'),

                      const SizedBox(height: 10),

                      Text('Year of Study: ${student.yearOfStudy}'),

                      const SizedBox(height: 10),

                      Text('First Module: ${student.firstModule}'),

                      const SizedBox(height: 10),

                      Text('Module Level: ${student.firstModuleLevel}'),

                      const SizedBox(height: 10),

                      if (student.secondModule != null &&
                          student.secondModule!.isNotEmpty)
                        Text('Second Module: ${student.secondModule}'),

                      const SizedBox(height: 10),

                      if (student.secondModuleLevel != null &&
                          student.secondModuleLevel!.isNotEmpty)
                        Text(
                          'Second Module Level: ${student.secondModuleLevel}',
                        ),

                      const SizedBox(height: 10),

                      Text(
                        'Requirements Met: '
                        '${student.meetsRequirements ? 'Yes' : 'No'}',
                      ),

                      const SizedBox(height: 20),

                      Chip(label: Text(student.status)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(Icons.arrow_back),

                  label: const Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
