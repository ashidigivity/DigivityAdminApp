class HomeworkModel {
  final int id;
  final String course;
  final String subject;
  final String hwDate;
  final String hwTitle;
  final String homework;
  final String withApp;
  final String withTextSms;
  final String withEmail;
  final String withWebsite;
  final String status;
  final List<Attachment> attachments;
  final String submittedBy;
  final String submittedByProfile;

  HomeworkModel({
    required this.id,
    required this.course,
    required this.subject,
    required this.hwDate,
    required this.hwTitle,
    required this.homework,
    required this.withApp,
    required this.withTextSms,
    required this.withEmail,
    required this.withWebsite,
    required this.status,
    required this.attachments,
    required this.submittedBy,
    required this.submittedByProfile,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'],
      course: json['course'],
      subject: json['subject'],
      hwDate: json['hw_date'],
      hwTitle: json['hw_title'],
      homework: json['homework'],
      withApp: json['with_app'],
      withTextSms: json['with_text_sms'],
      withEmail: json['with_email'],
      withWebsite: json['with_website'],
      status: json['status'],
      attachments: (json['attachments'] as List)
          .map((e) => Attachment.fromJson(e))
          .toList(),
      submittedBy: json['submitted_by'],
      submittedByProfile: json['submitted_by_profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course': course,
      'subject': subject,
      'hw_date': hwDate,
      'hw_title': hwTitle,
      'homework': homework,
      'with_app': withApp,
      'with_text_sms': withTextSms,
      'with_email': withEmail,
      'with_website': withWebsite,
      'status': status,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'submitted_by': submittedBy,
      'submitted_by_profile': submittedByProfile,
    };
  }

  @override
  String toString() {
    return 'HomeworkModel(id: $id, course: $course, subject: $subject, hwDate: $hwDate, hwTitle: $hwTitle, '
        'homework: $homework, withApp: $withApp, withTextSms: $withTextSms, withEmail: $withEmail, '
        'withWebsite: $withWebsite, status: $status, attachments: $attachments, submittedBy: $submittedBy, '
        'submittedByProfile: $submittedByProfile)';
  }
}

class Attachment {
  final String fileName;
  final String filePath;
  final String extension;

  Attachment({
    required this.fileName,
    required this.filePath,
    required this.extension,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['file_name'],
      filePath: json['file_path'],
      extension: json['extension'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'file_path': filePath,
      'extension': extension,
    };
  }

  @override
  String toString() {
    return 'Attachment(fileName: $fileName, filePath: $filePath, extension: $extension)';
  }
}
