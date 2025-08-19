
import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/Helpers/UserPermissions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomMenuModal extends StatefulWidget {
  const CustomMenuModal({super.key});

  @override
  State<CustomMenuModal> createState() => _CustomMenuModalState();
}

class _CustomMenuModalState extends State<CustomMenuModal> {
  List<Map<String, dynamic>> _quickActions = [];
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    final data = await UserPermissions().getPermissions();
    setState(() {
      _quickActions = data['quickActions'] ?? [];
      _reports = data['reports'] ?? [];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final uiTheme = Provider.of<UiThemeProvider>(context);

    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration:  BoxDecoration(
          color: uiTheme.bottomSheetBgColor ??  Color(0xFF514197).withOpacity(0.1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Navigation Menus",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              buildModuleGrid('Quick Actions',uiTheme, _quickActions),
              const SizedBox(height: 10),
              buildModuleGrid('Reports',uiTheme , _reports),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

}


IconData getIconForModule(String moduleId) {
  switch (moduleId) {
    case 'new-student':
      return Icons.person_add;
    case 'add-staff':
      return Icons.group_add;
    case 'student-attendance':
      return Icons.check_circle;
    case 'send-sms':
      return Icons.sms;
    case 'upload-homework':
      return Icons.upload_file;
    case 'upload-syllabus':
      return Icons.book;
    case 'student-photo':
      return Icons.photo_camera;
    case 'staff-photo':
      return Icons.camera_alt;
    case 'master-update':
      return Icons.system_update;
    case 'student-complaint':
      return Icons.report_problem;
    case 'student-list':
      return Icons.people;
    case 'staff-list':
      return Icons.people_alt;
    case 'attendance-reports':
      return Icons.insert_chart;
    case 'finance/account-reports':
      return Icons.account_balance;
    case 'upload-assignment':
      return Icons.assessment;
    case 'upload-notice':
      return Icons.notification_add;
    case 'upload-circular':
      return Icons.blur_circular_sharp;
    case 'student-documents':
      return Icons.document_scanner;
    case 'exam-entry':
      return Icons.fact_check;
    default:
      return Icons.widgets; // default icon
  }
}
getRouteForModule(String moduleId) {
  switch (moduleId) {
    case 'new-student':
      return 'student-dashboard';
    case 'add-staff':
      return 'add-staff';
    case 'student-attendance':
      return 'student-attendance';
    case 'send-sms':
      return 'communication-index';
    case 'upload-homework':
      return 'upload-homework';
    case 'upload-syllabus':
      return 'upload-syllabus';
    case 'student-photo':
      return 'student-upload-image';
    case 'staff-photo':
      return 'staff-upload-image';
    case 'master-update':
      return 'master-update';
    case 'student-complaint':
      return Icons.report_problem;
    case 'student-list':
      return 'student-list';
    case 'staff-list':
      return 'staff-list';
    case 'attendance-reports':
      return 'student-attendance-reports';
    case 'finance/account-reports':
      return 'finance/account-reports';
    case 'upload-assignment':
      return 'upload-assignment';
    case 'upload-notice':
      return 'upload-notice';
    case 'upload-circular':
        return 'upload-circular';
    case 'student-documents':
      return 'student-documents';
    case 'exam-entry':
      return 'exam-entry';
    default:
      return Icons.widgets; // default icon
  }
}


Widget buildModuleGrid(String title, UiThemeProvider uiTheme , List<Map<String, dynamic>> modules) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: modules.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final module = modules[index];
          return GestureDetector(
            onTap: () {
              // handle navigation
              context.pushNamed(getRouteForModule(module['module_id']));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: uiTheme.bottomSheetBgColor ?? Color(0xFF514197).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    getIconForModule(module['module_id']),
                    color: uiTheme.iconColor ?? Color(0xFF514197),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  module['module_text'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          );
        },
      ),
    ],
  );
}


void showCustomMenuModal(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Color(0xFFF8F1F9),
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const CustomMenuModal(),
  );
}
