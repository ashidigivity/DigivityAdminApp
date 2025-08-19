import 'dart:convert';
import 'package:digivity_admin_app/Authentication/SharedPrefHelper.dart';
import 'package:digivity_admin_app/Helpers/getApiService.dart';

class UserPermissions {
  UserPermissions();

  Future<Map<String, List<Map<String, dynamic>>>> getPermissions() async {
    final userId = await SharedPrefHelper.getPreferenceValue('user_id');
    final token = await SharedPrefHelper.getPreferenceValue('access_token');

    final url = "api/MobileApp/master-admin/$userId/home";
    final response = await getApiService.getRequestData(url, token);

    if (response != null && response['success'][0]['module'] != null) {
      final modules = response['success'][0]['module'];

      // FIXED HERE: modules is a List, so we access [0] first
      final quickActions = List<Map<String, dynamic>>.from(modules[0]['quick-action']);
      final reports = List<Map<String, dynamic>>.from(modules[0]['reports']);

      return {
        'quickActions': quickActions,
        'reports': reports,
      };
    }

    return {
      'quickActions': [],
      'reports': [],
    };
  }

}
