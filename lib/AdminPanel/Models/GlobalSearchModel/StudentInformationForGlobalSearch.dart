class StudentInformationForGlobalSearch {
  final Map<String, dynamic> studentPersonalInfo;
  final Map<String, dynamic> feeInformation;
  final Map<String, dynamic> fatherInformation;
  final Map<String, dynamic> academicInformation;
  final Map<String, dynamic> motherInformation;
  final Map<String, dynamic> addressInformation;
  final Map<String, dynamic> localGuardianInformation;
  final Map<String, dynamic> emergencyInformation;
  final List<Map<String, dynamic>> uploadDocs;
  final List<Map<String, dynamic>> cmmitmentDetails;

  StudentInformationForGlobalSearch({
    required this.studentPersonalInfo,
    required this.feeInformation,
    required this.fatherInformation,
    required this.motherInformation,
    required this.addressInformation,
    required this.localGuardianInformation,
    required this.emergencyInformation,
    required this.uploadDocs,
    required this.academicInformation,
    required this.cmmitmentDetails
  });

  factory StudentInformationForGlobalSearch.fromJson(Map<String, dynamic> json) {
    final studentData = json['student_data'] ?? {};

    return StudentInformationForGlobalSearch(
      studentPersonalInfo:
      Map<String, dynamic>.from(studentData['student_persional_information'] ?? {}),
      academicInformation:Map<String, dynamic>.from(studentData['academic_information'] ?? {}),
      feeInformation: Map<String, dynamic>.from(studentData['fee_information'] ?? {}),
      fatherInformation: Map<String, dynamic>.from(studentData['father_information'] ?? {}),
      motherInformation: Map<String, dynamic>.from(studentData['mother_information'] ?? {}),
      addressInformation: Map<String, dynamic>.from(studentData['address_information'] ?? {}),
      localGuardianInformation:
      Map<String, dynamic>.from(studentData['local_guardial_iformation'] ?? {}),
      emergencyInformation: Map<String, dynamic>.from(studentData['emg_information'] ?? {}),
      uploadDocs: (json['upload_docs'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      cmmitmentDetails: (json['commitments_details'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
    );
  }
}
