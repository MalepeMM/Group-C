/*
TPG316C GROUP ASSINGMENT:Group C
CHAUKE S   223032277
KGATUKE M  222029835
MASHELE PV 224120975
Malepe T   223015611
 */

class StudentApplication {
  final String id;
  final String userId;
  final String fullName;
  final String studentNumber;
  final String yearOfStudy;
  final String firstModule;
  final String firstModuleLevel;
  final String? secondModule;
  final String? secondModuleLevel;
  final bool meetsRequirements;
  final String status;
  final String? documentUrl;

  StudentApplication({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.studentNumber,
    required this.yearOfStudy,
    required this.firstModule,
    required this.firstModuleLevel,
    this.secondModule,
    this.secondModuleLevel,
    required this.meetsRequirements,
    required this.status,
    this.documentUrl,
  });

  factory StudentApplication.fromMap(Map<String, dynamic> map) {
    return StudentApplication(
      id: map['id'],
      userId: map['user_id'],
      fullName: map['full_name'],
      studentNumber: map['student_number'],
      yearOfStudy: map['year_of_study'],
      firstModule: map['first_module'],
      firstModuleLevel: map['first_module_level'],
      secondModule: map['second_module'],
      secondModuleLevel: map['second_module_level'],
      meetsRequirements: map['meets_requirements'],
      status: map['status'],
      documentUrl: map['document_url'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'student_number': studentNumber,
      'year_of_study': yearOfStudy,
      'first_module': firstModule,
      'first_module_level': firstModuleLevel,
      'second_module': secondModule,
      'second_module_level': secondModuleLevel,
      'meets_requirements': meetsRequirements,
      'status': status,
      'document_url': documentUrl,
    };
  }
}
