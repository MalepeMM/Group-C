/*
TPG316C GROUP ASSINGMENT:Group C
CHAUKE S   223032277
KGATUKE M  222029835
MASHELE PV 224120975
Malepe T   223015611
 */

// ============================================================
// Student Assistant Application – Student Form Page
// Allows students to create or edit their applications.
// Includes file picking and uploading to Supabase Storage.
// ============================================================

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/student_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/student_view_model.dart';

class StudentFormPage extends StatefulWidget {
  const StudentFormPage({super.key, this.student});
  final StudentApplication? student;

  @override
  State<StudentFormPage> createState() => _StudentFormPageState();
}

class _StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _studentNumberController;
  late TextEditingController _yearController;
  late TextEditingController _firstModuleController;
  late TextEditingController _firstLevelController;
  late TextEditingController _secondModuleController;
  late TextEditingController _secondLevelController;

  bool _meetsRequirements = false;
  File? _selectedFile;
  String? _documentUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(
      text: widget.student?.fullName ?? '',
    );
    _studentNumberController = TextEditingController(
      text: widget.student?.studentNumber ?? '',
    );
    _yearController = TextEditingController(
      text: widget.student?.yearOfStudy ?? '',
    );
    _firstModuleController = TextEditingController(
      text: widget.student?.firstModule ?? '',
    );
    _firstLevelController = TextEditingController(
      text: widget.student?.firstModuleLevel ?? '',
    );
    _secondModuleController = TextEditingController(
      text: widget.student?.secondModule ?? '',
    );
    _secondLevelController = TextEditingController(
      text: widget.student?.secondModuleLevel ?? '',
    );
    _meetsRequirements = widget.student?.meetsRequirements ?? false;
    _documentUrl = widget.student?.documentUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    _yearController.dispose();
    _firstModuleController.dispose();
    _firstLevelController.dispose();
    _secondModuleController.dispose();
    _secondLevelController.dispose();
    super.dispose();
  }

  // ── Pick File ──────────────────────────────────────────────
  Future<void> _pickFile() async {
    try {
      // Use the static pickFiles method which is universally available
      final result = await FilePicker.pickFiles();

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  // ── Upload File to Storage ─────────────────────────────────
  Future<bool> _uploadFile() async {
    if (_selectedFile == null) return true; // No new file to upload

    setState(() => _isUploading = true);
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.path.split('/').last}';

      await Supabase.instance.client.storage
          .from('student-documents')
          .upload(fileName, _selectedFile!);

      _documentUrl = Supabase.instance.client.storage
          .from('student-documents')
          .getPublicUrl(fileName);

      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Upload failed: $e. Ensure "student-documents" bucket exists.',
            ),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ── Save Application ───────────────────────────────────────
  Future<void> _saveApplication() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final studentViewModel = context.read<StudentViewModel>();
    final userId = authViewModel.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }

    // 1. Upload file first if selected
    final uploadSuccess = await _uploadFile();
    if (!uploadSuccess) return;

    // 2. Prepare application object
    final application = StudentApplication(
      id: widget.student?.id ?? const Uuid().v4(),
      userId: userId,
      fullName: _fullNameController.text.trim(),
      studentNumber: _studentNumberController.text.trim(),
      yearOfStudy: _yearController.text.trim(),
      firstModule: _firstModuleController.text.trim(),
      firstModuleLevel: _firstLevelController.text.trim(),
      secondModule: _secondModuleController.text.trim(),
      secondModuleLevel: _secondLevelController.text.trim(),
      meetsRequirements: _meetsRequirements,
      status: widget.student?.status ?? 'Pending',
      documentUrl: _documentUrl,
    );

    // 3. Save to database
    final success = widget.student == null
        ? await studentViewModel.addApplication(application)
        : await studentViewModel.updateApplication(application);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.student == null
                ? 'Application submitted!'
                : 'Application updated!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(studentViewModel.errorMessage ?? 'An error occurred.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.student != null;
    final studentViewModel = context.watch<StudentViewModel>();
    final isLoading = studentViewModel.isLoading || _isUploading;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'New Application'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal & Academic Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _fullNameController,
                      'Full Name',
                      Icons.person,
                      'Enter full name',
                    ),
                    _buildTextField(
                      _studentNumberController,
                      'Student Number',
                      Icons.badge,
                      'Enter student number',
                    ),
                    _buildTextField(
                      _yearController,
                      'Year Of Study',
                      Icons.calendar_today,
                      'Enter year of study',
                    ),

                    const Divider(height: 32),
                    const Text(
                      'Module Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      _firstModuleController,
                      'Primary Module',
                      Icons.book,
                      'Enter module name',
                    ),
                    _buildTextField(
                      _firstLevelController,
                      'Academic Level (e.g. Level 6)',
                      Icons.layers,
                      'Enter level',
                    ),

                    const SizedBox(height: 16),
                    _buildTextField(
                      _secondModuleController,
                      'Secondary Module (Optional)',
                      Icons.book_outlined,
                      null,
                    ),
                    _buildTextField(
                      _secondLevelController,
                      'Secondary Module Level',
                      Icons.layers_outlined,
                      null,
                    ),

                    const Divider(height: 32),

                    CheckboxListTile(
                      value: _meetsRequirements,
                      title: const Text(
                        'I confirm that I meet the minimum requirements for this position.',
                      ),
                      activeColor: Colors.indigo,
                      onChanged: (value) {
                        setState(() => _meetsRequirements = value ?? false);
                      },
                    ),

                    const SizedBox(height: 16),

                    // File Picker UI
                    ListTile(
                      leading: const Icon(
                        Icons.attach_file,
                        color: Colors.indigo,
                      ),
                      title: Text(
                        _selectedFile != null
                            ? 'File: ${_selectedFile!.path.split('/').last}'
                            : (_documentUrl != null
                                  ? 'Current document attached'
                                  : 'Upload Supporting Document'),
                      ),
                      subtitle: const Text('PDF or Image preferred'),
                      trailing: ElevatedButton(
                        onPressed: _pickFile,
                        child: const Text('Browse'),
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveApplication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isEditing
                              ? 'UPDATE APPLICATION'
                              : 'SUBMIT APPLICATION',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? errorMsg,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: errorMsg != null
            ? (value) {
                if (value == null || value.trim().isEmpty) return errorMsg;
                return null;
              }
            : null,
      ),
    );
  }
}
