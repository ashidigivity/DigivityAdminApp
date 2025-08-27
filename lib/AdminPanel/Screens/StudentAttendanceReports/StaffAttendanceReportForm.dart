import 'package:digivity_admin_app/AdminPanel/Screens/StudentAttendanceReports/AttendanceReportHtmlShowScreen.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/BackgrounWeapper.dart';
import 'package:digivity_admin_app/Components/CustomBlueButton.dart';
import 'package:digivity_admin_app/Components/DatePickerField.dart';
import 'package:digivity_admin_app/Components/Loader.dart';
import 'package:digivity_admin_app/Components/SimpleAppBar.dart';
import 'package:digivity_admin_app/helpers/AttendanceReportsHelperFunctions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StaffAttendanceReportForm extends StatefulWidget {
  @override
  State<StaffAttendanceReportForm> createState() {
    return _StaffAttendanceReportForm();
  }
}



class _StaffAttendanceReportForm extends State<StaffAttendanceReportForm> {
  TextEditingController _reportdate = TextEditingController();

  void submitForm() async {
    showLoaderDialog(context);
    final formdata = {
      'date': _reportdate.text.trim(),
    };

    try {
      String? htmlData = await AttendanceReportsHelperFunctions().apiAttendanceReport('staff-attendance-report',formdata);
      if (htmlData != null && htmlData.isNotEmpty) {
        hideLoaderDialog(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceReportHtmlShowScreen(
              HtmlViewData: htmlData,
              appbartext: "Staff Attendance Report",
            ),
          ),
        );
      } else {
        hideLoaderDialog(context);
       showBottomMessage(context, "Report Not Found", true);
      }
    } catch (e) {
      hideLoaderDialog(context);
      showBottomMessage(context, "${e}", true);
    }


  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SimpleAppBar(
          titleText: 'Staff Attendance Report',
          routeName: 'back',
        ),
      ),
      body: BackgroundWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    DatePickerField(
                      controller: _reportdate,
                      label: 'Attendance Date',
                    ),

                    const SizedBox(height: 40),
                    CustomBlueButton(
                      width: double.infinity,
                      text: "Get Result",
                      icon: Icons.arrow_forward,
                      onPressed: () {
                        if (_reportdate != null) {
                        submitForm();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please select course and date")),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


