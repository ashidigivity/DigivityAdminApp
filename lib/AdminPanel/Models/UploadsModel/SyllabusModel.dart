class SyllabusModel {
  final int syllabusId;
  final String subject;
  final String course;
  final String syllabusTitle;
  final String syllabusDetail;
  final String? icon;
  final String uploadDate;
  final List<Attachment> attachment;
  final String submittedBy;
  final String submittedByProfile;
  final String withApp;
  final String withWebsite;

  SyllabusModel({
    required this.syllabusId,
    required this.subject,
    required this.course,
    required this.syllabusTitle,
    required this.syllabusDetail,
    this.icon,
    required this.uploadDate,
    required this.attachment,
    required this.submittedBy,
    required this.submittedByProfile,
    required this.withApp,
    required this.withWebsite
  });

  factory SyllabusModel.fromJson(Map<String, dynamic> json) {
    return SyllabusModel(
      syllabusId: json['syllabus_id'],
      subject: json['subject'],
      course:json['course'],
      syllabusTitle: json['syllabus_title'],
      syllabusDetail: json['syllabus_detail'],
      icon: json['icon'],
      withApp:json['with_app'],
      withWebsite: json['with_website'],
      uploadDate: json['upload_date'],
      attachment: json['attachment'] != null
          ? List<Attachment>.from(
          json['attachment'].map((x) => Attachment.fromJson(x)))
          : [],
      submittedBy: json['submitted_by'],
      submittedByProfile: json['submitted_by_profile'],
    );
  }

  @override
  String toString() {
    return 'Syllabus(id: $syllabusId, subject: $subject,course:$course, title: $syllabusTitle, date: $uploadDate, attachments: $attachment,withApp:$withApp,with_website:$withWebsite)';
  }
}

class Attachment {
  final String fileName;
  final String extension;
  final String filePath;

  Attachment({
    required this.fileName,
    required this.extension,
    required this.filePath,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['file_name'],
      extension: json['extension'],
      filePath: json['file_path'],
    );
  }

  @override
  String toString() {
    return 'Attachment(fileName: $fileName, extension: $extension, path: $filePath)';
  }
}