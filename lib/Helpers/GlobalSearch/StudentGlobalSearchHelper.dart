import 'dart:ffi';
import 'dart:math';

import 'package:digivity_admin_app/AdminPanel/Models/GlobalSearchModel/StudentInformationForGlobalSearch.dart';
import 'package:digivity_admin_app/AdminPanel/Models/Studdent/StudentGlobalSearch/StudentGlobalSearchModel.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/Helpers/getApiService.dart';
import 'package:flutter/cupertino.dart';

import '../../AdminPanel/Models/GlobalSearchModel/StudentGlobalSearchModel.dart';

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

  /// Get Particular Student Data
  Future<StudentInformationForGlobalSearch?> getStudentListForGlobalSearch(int? studentId) async {
    if (userId == null || token == null) {
      await init();
    }

    final String url = "api/MobileApp/StudentGlobalSearch/GetStudentData/$userId/$studentId";
    print("Controller Function Section: $url");

    try {
      final response = await getApiService.getRequestData(url, token!);

      if (response["result"] == 1 && response["success"] is List && response["success"].isNotEmpty) {
        final Map<String, dynamic> firstStudent = Map<String, dynamic>.from(response["success"][0]);
        final studentInformation = StudentInformationForGlobalSearch.fromJson(firstStudent);
        print("Student Info: $studentInformation");
        return studentInformation;
      } else {
        print("No student data found or invalid response");
        return null;
      }
    } catch (e) {
      print("Error in getStudentListForGlobalSearch: $e");
      return null;
    }
  }

/// Get Report Data For A Particular Student Data Like Attendance And Finance
  Future<String?> apiGetStudentDataGlobalSearch(dynamic studentId,String reportName) async {
    if (userId == null || token == null) {
      await init();
    }

    // Map of report names to endpoint suffixes
    final reportEndpoints = {
      'feeInformation': 'GetStudentFeeDetails',
      'attendanceinformation': 'GetStudentAttendanceDetails',
      "commitmentinformation":'GetStudentCommitmentDetails'
    };

    final endpoint = reportEndpoints[reportName];
    if (endpoint == null) return null;

    final url = "api/MobileApp/StudentGlobalSearch/$endpoint/$userId/$studentId";

    print("Final Url For The Student Attendance IS : ");
    print(url);

    final response = await getApiService.getRequestData(url, token!);

    if (response['result'] == 1 &&
        response['success'] != null &&
        response['success'].isNotEmpty &&
        response['success'][0]['data'] != null) {
      return response['success'][0]['data'];
    }

    return null;
  }


  /// Get Data For The Student Commitments Data
Future<void> getStudentCommitment(dynamic studentId) async{
    if(userId == null || token == null){
      await init();
    }

    try{
      final String url = "api/MobileApp/GetStudentCommitmentDetails/$userId/$studentId";
      final response  = getApiService.getRequestData(url, token!);
      
    }catch(e){

    }
}



 }
