import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/AdminPanel/MobileThemsColors/theme_provider.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:digivity_admin_app/Components/CustomConfirmationDialog.dart';
import 'package:digivity_admin_app/Components/Loader.dart';
import 'package:digivity_admin_app/helpers/launchAnyUrl.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class ShowAssignmentDetailSheet extends StatelessWidget {
  final int assignmentId;
  final String assignmentTitle;
  final String asignmentDetail;
  final String assignmentDate;
  final String? assigmetSubmissionDate;
  final String course;
  final String subject;
  final String submittedBy;
  final List<Map<String, dynamic>> attachments;
  final String? withapp;
  final String? withtextSms;
  final String? withEmail;
  final String? withWebsite;
  final String submittedByProfile;
  final Future<Map<String, dynamic>> Function()? onDelete;




  const ShowAssignmentDetailSheet({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.asignmentDetail,
    required this.assignmentDate,
    this.assigmetSubmissionDate,
    required this.course,
    required this.subject,
    required this.submittedBy,
    required this.attachments,
    this.withapp,
    this.withtextSms,
    this.withEmail,
    this.withWebsite,
    required this.submittedByProfile,
    this.onDelete,
  });

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
  @override
  Widget build(BuildContext context) {

    final uiTheme = Provider.of<UiThemeProvider>(context);


    Map<String, dynamic> getSelectedNotifyValues() {
      return {
        'with_text_sms':'Text SMS',
        'with_app': 'App',
        'with_whatsapp':'Whatsapp',
        'with_email': 'Email',
        'with_website': 'Website',
      };
    }
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.70,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          color: uiTheme.bottomSheetBgColor ?? Colors.white,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Handle Bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),


                Center(child: _notifyChip('Homewrok','green'
                ),),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(assignmentDate, style: const TextStyle(color: Colors.grey)),
                    Text("$course - $subject", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),

                  ],
                ),
                const Divider(),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      border: Border.all(
                          color: Colors.grey,
                          width: 1
                      ),
                      borderRadius: BorderRadius.circular(5)

                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Submission Date  :  $assigmetSubmissionDate", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(assignmentTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(asignmentDetail),

                const SizedBox(height: 16),
                const Divider(),

                const Text("Attachments:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (attachments.isEmpty)
                  const Text("No Attachments Found", style: TextStyle(color: Colors.grey)),
                ...attachments.map((file) {
                  final name = file['file_name'] ?? 'Unnamed';
                  final ext = file['extension'] ?? '';
                  final url = file['file_path'] ?? '';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: InkWell(
                      onTap: () async{
                        openFile(url);

                      },
                      child: Row(
                        children: [
                          Icon(ext == 'pdf' ? Icons.picture_as_pdf_sharp : Icons.link, color: ext == 'pdf' ? Colors.red : Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                            onPressed: () async{
                              openFile(url);

                            },
                          )
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 14),
                const Divider(),

                /// Notification Type
                const Text("Notify On:", style: TextStyle(fontWeight: FontWeight.bold)),

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (withapp == 'yes')
                      _notifyChip(getSelectedNotifyValues()['with_app'],''),
                    if (withtextSms == 'yes')
                      _notifyChip(getSelectedNotifyValues()['with_text_sms'],''),
                    if (withEmail == 'yes')
                      _notifyChip(getSelectedNotifyValues()['with_email'],''),
                    if (withWebsite == 'yes')
                      _notifyChip(getSelectedNotifyValues()['with_website'],''),
                  ],
                ),

                const SizedBox(height: 14),


                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      PopupNetworkImage(imageUrl: submittedByProfile,radius: 20,),
                      const SizedBox(width: 8),
                      Text("Submitted by $submittedBy", style: const TextStyle(fontSize: 13,fontWeight: FontWeight.bold)),
                    ]),
                    Text("Attachment (${attachments.length})", style: const TextStyle(color: Colors.pinkAccent,fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 24),

                /// Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close,color: Colors.white,size: 11,),
                        label: const Text("Close",style: TextStyle(fontSize:11,color: Colors.white),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 10),

                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (onDelete != null) {
                            bool confirmed = await showCustomConfirmationDialog(
                              context: context,
                              title: "Alert ?",
                              message: "Are you sure you want to delete this Assignment?",
                              confirmText: "Yes",
                              cancelText: "No",
                            );
                            if (confirmed) {
                              showLoaderDialog(context);
                              final response = await onDelete!();
                              hideLoaderDialog(context);
                              if (response['result'] == 1) {
                                Navigator.pop(context);
                                showBottomMessage(
                                    context, response['message'], false);
                              } else {
                                showBottomMessage(context, response['message'],
                                    true); // shows error instead of crashing
                              } // Call deleteAndRefresh() from parent
                            }
                          }
                        },
                        icon: const Icon(Icons.delete,color: Colors.white,size: 11,),
                        label: const Text("Remove",style: TextStyle(fontSize:11,color: Colors.white),),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
Widget _notifyChip(String? label,String? color) {
  return Chip(
    label: Text(label ?? '', style: const TextStyle(color: Colors.black87)),
    backgroundColor: color != '' ? Colors.green : Colors.grey.shade200,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  );
}
