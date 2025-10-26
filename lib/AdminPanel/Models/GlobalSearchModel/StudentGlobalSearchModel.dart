class StudentGlobalSearchModel {
  final int dbId;
  final int studentId;
  final String? admissionNo;
  final String? rollNo;
  final String? studentName;
  final String gender;
  final int? courseId;
  final int? sectionId;
  final String? course;
  final String? fatherName;
  final String? contactNo;
  final String? profileImg;

  StudentGlobalSearchModel({
    required this.dbId,
    required this.studentId,
    this.admissionNo,
    this.rollNo,
    this.studentName,
    this.gender = 'male',
    this.courseId,
    this.sectionId,
    this.course,
    this.fatherName,
    this.contactNo,
    this.profileImg,
  });

  factory StudentGlobalSearchModel.fromJson(Map<String, dynamic> json) {
    return StudentGlobalSearchModel(
      dbId: json['db_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      admissionNo: json['admission_no'] as String?,
      rollNo: json['roll_no']?.toString(),
      studentName: json['student_name'] as String?,
      gender: json['gender'] as String? ?? 'male',
      courseId: json['course_id'] as int?,
      sectionId: json['section_id'] as int?,
      course: json['course'] as String?,
      fatherName: json['father_name'] as String?,
      contactNo: json['contact_no'] as String?,
      profileImg: json['profile_img'] as String?,
    );
  }
}
