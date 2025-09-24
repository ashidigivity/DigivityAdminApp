import 'package:digivity_admin_app/AdminPanel/Components/ImportEntryMode.dart';
import 'package:digivity_admin_app/AdminPanel/Components/ImportFeeHeads.dart';
import 'package:digivity_admin_app/AdminPanel/Components/ImportPaymode.dart';
import 'package:digivity_admin_app/AdminPanel/Components/ImportReceiptStatus.dart';
import 'package:digivity_admin_app/AdminPanel/Screens/FinanceReports/FinanceReportScreen/FeereportHtmlshowScreen.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/BackgrounWeapper.dart';
import 'package:digivity_admin_app/Components/CardContainer.dart';
import 'package:digivity_admin_app/Components/CourseComponent.dart';
import 'package:digivity_admin_app/Components/CustomBlueButton.dart';
import 'package:digivity_admin_app/Components/DatePickerField.dart';
import 'package:digivity_admin_app/Components/InputField.dart';
import 'package:digivity_admin_app/Components/Loader.dart';
import 'package:digivity_admin_app/Components/SimpleAppBar.dart';
import 'package:digivity_admin_app/helpers/FinanceHelperFunction.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeeHeadWiseCollectionReport extends StatefulWidget {
  @override
  State<FeeHeadWiseCollectionReport> createState() {
    return _FeeHeadWiseCollectionReport();
  }
}

class _FeeHeadWiseCollectionReport extends State<FeeHeadWiseCollectionReport> {
  TextEditingController _fromdate = TextEditingController();
  TextEditingController _todate = TextEditingController();
  String? paymode;
  String? feehead;

  void submitForm() async {
    showLoaderDialog(context);
    final formdata = {
      'from_date': _fromdate.text.trim(),
      'to_date': _todate.text.trim(),
      'paymode_id': paymode ?? '',
      'fee_head_id': feehead ?? '',
    };

    try {
      String? htmlData = await FinanceHelperFunction().apifeecollectionreport(
        'feehead-wise-collection-report',
        formdata,
      );
      if (htmlData != null && htmlData.isNotEmpty) {
        hideLoaderDialog(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeereportHtmlshowScreen(
              HtmlViewData: htmlData,
              appbartext: "Fee Head Wise Collection Report",
            ),
          ),
        );
      } else {
        hideLoaderDialog(context);
        showBottomMessage(context, "No report data found", true);
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
          titleText: 'Fee Head Collection Report',
          routeName: 'back',
        ),
      ),
      body: BackgroundWrapper(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CardContainer(
              child: Column(
                children: [
                  DatePickerField(label: 'From Date', controller: _fromdate),
                  SizedBox(height: 20),
                  DatePickerField(label: 'To Date', controller: _todate),
                  SizedBox(height: 20),
                  ImportFeeHeads(
                    onChanged: (value) {
                      feehead = value;
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                  ImportPaymode(
                    onChanged: (value) {
                      paymode = value;
                      setState(() {});
                    },
                  ),
                  SizedBox(height: 20),
                  SizedBox(height: 20),
                  CustomBlueButton(
                    width: double.infinity,
                    text: 'Get Result',
                    icon: Icons.arrow_forward,
                    onPressed: () async {
                      submitForm();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
