import 'package:digivity_admin_app/AdminPanel/Models/MainDashboardModel/CourseData.dart';
import 'package:digivity_admin_app/AdminPanel/Models/MainDashboardModel/DashboardResponse.dart';
import 'package:digivity_admin_app/AdminPanel/Models/MainDashboardModel/DataInfo.dart';
import 'package:digivity_admin_app/AdminPanel/Models/MainDashboardModel/AttendanceModel.dart';
import 'package:digivity_admin_app/AdminPanel/Models/MainDashboardModel/class_strength_data.dart';
import 'package:digivity_admin_app/AdminPanel/Models/MainDashboardModel/paymode_data.dart';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/Components/Loader.dart';
import 'package:digivity_admin_app/Helpers/getApiService.dart';
import 'package:flutter/cupertino.dart';

class DashboardProvider extends ChangeNotifier {
  bool isLoading = false;

  List<String> labelsofpaymodes = [];
  List<double> totalcountsofpaumodes = [];

  List<String> labelsofclass = [];
  List<double> totalclassmalecount = [];
  List<double> totalclassfemalecount = [];

  List<String> labelsofattendance = [];
  List<double> coutofattendance = [];
  List<String> labelsofstudentattendance = [];
  List<double> coutofstudentattendance = [];

  List<DataInfo> sliderdata = [];
  List<CourseData> courseeslist = [];
  List<ClassStrengthData> classStrengthList = [];
  List<PaymodeData> paymodeList = [];

  AttendanceModel? attendanceSummary;
  AttendanceModel? studentattendanceSummary;


  Future<void> fetchDashboardData(BuildContext context) async {
    try {
      notifyListeners();

      final userid = await SharedPrefHelper.getPreferenceValue('user_id');
      final token = await SharedPrefHelper.getPreferenceValue('access_token');
      final url = "api/MobileApp/master-admin/$userid/home";

      showLoaderDialog(context);
      final response = await getApiService.getRequestData(url, token);
      final dashboardResponse = DashboardResponse.fromJson(response);
      final dataInfo = dashboardResponse.success[0].dataInfo;



      /// Slider Info
      final allowedKeys = [
        'Total Student',
        'Total Staff',
        'today_fee_collection',
        'Communication Balance',
        'today_expense'
      ];

      sliderdata = dataInfo
          .where((item) => allowedKeys.contains(item.key))
          .toList();

      /// Paymode Data
      final paymodeEntry = dataInfo.firstWhere(
            (e) => e.key == 'paymodedata',
        orElse: () => DataInfo(key: '', value: []),
      );

      paymodeList = (paymodeEntry.value as List)
          .map((e) => PaymodeData.fromJson(e))
          .toList();

      labelsofpaymodes = paymodeList.map((e) => e.paymode).toList();
      totalcountsofpaumodes = paymodeList
          .map((e) => double.tryParse(e.total.toString()) ?? 0.0)
          .toList();

      /// Classwise Gender Count
      final classCourseData = dataInfo.firstWhere(
            (e) => e.key == 'classwisestudentstreanth',
        orElse: () => DataInfo(key: '', value: []),
      );

      classStrengthList = (classCourseData.value as List)
          .map((e) => ClassStrengthData.fromJson(e))
          .toList();

      labelsofclass = classStrengthList.map((e) => e.course).toList();
      totalclassmalecount =
          classStrengthList.map((e) => e.maleCount.toDouble()).toList();
      totalclassfemalecount =
          classStrengthList.map((e) => e.femaleCount.toDouble()).toList();

      /// Course Data
      final courseJson = response['success'][0]['course'] as List;
      courseeslist = courseJson
          .map((e) => CourseData.fromJson(e as Map<String, dynamic>))
          .toList();

      /// Staff Attendance Section
      final attendace = dataInfo.firstWhere(
            (e) => e.key == 'staff_attendacen',
        orElse: () => DataInfo(key: '', value: {}),
      );

      attendanceSummary = AttendanceModel.fromJson(
        Map<String, dynamic>.from(attendace.value),
      );

      labelsofattendance = [
        'Present',
        'Absent',
        'Leave',
        'Late',
        'Unmarked',
      ];

      coutofattendance = [
        attendanceSummary?.present.toDouble() ?? 0.0,
        attendanceSummary?.absent.toDouble() ?? 0.0,
        attendanceSummary?.leave.toDouble() ?? 0.0,
        attendanceSummary?.late.toDouble() ?? 0.0,
        attendanceSummary?.unmarked.toDouble() ?? 0.0,
      ];


      ///student attendance summary
      /// student attendance summary
      final studentattendace = dataInfo.firstWhere(
            (e) => e.key == 'student_attendacen',
        orElse: () => DataInfo(key: '', value: {}),
      );

      studentattendanceSummary = AttendanceModel.fromJson(
        Map<String, dynamic>.from(studentattendace.value),
      );

      labelsofstudentattendance = [
        'Present',
        'Absent',
        'Leave',
        'Late',
        'Unmarked',
      ];

      coutofstudentattendance = [
        studentattendanceSummary?.present.toDouble() ?? 0.0,
        studentattendanceSummary?.absent.toDouble() ?? 0.0,
        studentattendanceSummary?.leave.toDouble() ?? 0.0,
        studentattendanceSummary?.late.toDouble() ?? 0.0,
        studentattendanceSummary?.unmarked.toDouble() ?? 0.0,
      ];


      hideLoaderDialog(context);
    } catch (e, st) {
      debugPrint("Error fetching dashboard data: $e\n$st");
    } finally {
      notifyListeners();
    }
  }

  /// Optional: Getter for dropdown with Map
  List<Map<String, String>> get courseDropdownMap =>
      courseeslist.map((e) =>
      {
        'id': e.keyid,
        'value': e.value,
        'count': e.count?.toString() ?? '0',
      }).toList();
}
