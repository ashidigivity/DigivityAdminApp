import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:digivity_admin_app/Components/ApiMessageWidget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InteractiveStudentCard extends StatefulWidget {
  final String? imageUrl;
  final String? studentName;
  final String? course;
  final String? admissionNo;
  final VoidCallback? onTap;
  final String? fatherName;
  final int studentId;

  const InteractiveStudentCard({
    super.key,
    this.imageUrl,
    this.studentName,
    this.course,
    this.admissionNo,
    this.fatherName,
    this.onTap,
    required this.studentId

  });

  @override
  State<InteractiveStudentCard> createState() => _InteractiveStudentCardState();
}

class _InteractiveStudentCardState extends State<InteractiveStudentCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: _isPressed
              ? [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black12,
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: (){
              try
              {
                context.pushNamed("student-information-global-search",extra: {"studentId":widget.studentId});
              }catch(e){
                showBottomMessage(context, "${e}", true);
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              leading: PopupNetworkImage(imageUrl:widget.imageUrl!),
              title: Text(
                "${widget.studentName ?? 'Unknown'} (${widget.course ?? 'N/A'})",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                "Father: ${widget.fatherName ?? 'N/A'}\nAdmission No: ${widget.admissionNo ?? 'N/A'}\nStudent Id : ${widget.studentId ?? 'N/A'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[400]),
            ),
          )
        ),
      ),
    );
  }
}
