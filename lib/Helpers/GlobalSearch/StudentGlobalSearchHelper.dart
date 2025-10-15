import 'package:digivity_admin_app/AdminPanel/Models/Studdent/StudentGlobalSearch/StudentGlobalSearchModel.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/Helpers/getApiService.dart';
import 'package:flutter/cupertino.dart';

class StudentGlobalSearchHelper {
  int? userId;
  String? token;
  dynamic response;

  StudentGlobalSearchHelper();

  /// Proper async initializer
  Future<void> init() async {
    userId = await SharedPrefHelper.getPreferenceValue('user_id');
    token = await SharedPrefHelper.getPreferenceValue('access_token');
  }


  Future<List<StudentGlobalSearchModel>> fetchStudentRecordGlobalSearch(String query) async {
    // Ensure userId and token are initialized
    if (userId == null || token == null) {
      await init();
    }
    try {
      final url = "api/MobileApp/StudentGlobalSearch/SearchStudent/$userId/$query";
      final response = await getApiService.getRequestData(url, token!);

      if (response["result"] == 1 && response['success'] is List) {
        final List<dynamic> dataList = response['success'];

        final List<StudentGlobalSearchModel> students = dataList
            .map((item) => StudentGlobalSearchModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return students;
      } else {
        debugPrint('No students found or invalid API response.');
        return [];
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching student records: $e');
      debugPrint('$stackTrace');
      return [];
    }
  }



}
