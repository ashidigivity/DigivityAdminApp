import 'package:digivity_admin_app/AdminPanel/Components/PopupNetworkImage.dart';
import 'package:flutter/material.dart';

class ResponsiveUserCard extends StatelessWidget {
  final Map<String, dynamic> user;

  const ResponsiveUserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 📱 Responsive sizes
    final isTablet = screenWidth > 600;
    final imageRadius = isTablet ? 90.0 : 40.0;
    final titleFontSize = isTablet ? 22.0 : 16.0;
    final textFontSize = isTablet ? 16.0 : 13.0;
    final iconSize = isTablet ? 20.0 : 14.0;

    return IntrinsicHeight(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Accent Border
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: Colors.purple.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Profile Image
            ClipRRect(
              borderRadius: BorderRadius.circular(imageRadius),
              child: PopupNetworkImage(imageUrl: user["profile_image"],radius: imageRadius,),
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  Text(
                    user['full_name'] ?? '',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),

                  _infoRow(Icons.person_outline, user['role'] ?? '', iconSize, textFontSize),
                  _infoRow(Icons.phone_android, user['mobile_no'] ?? user['email_id'] ?? '', iconSize, textFontSize),
                  _infoRow(Icons.location_city, 'Branch: ${user['branchname'] ?? '-'}', iconSize, textFontSize),
                  _infoRow(Icons.event_note, 'Session: ${user['session'] ?? '-'}', iconSize, textFontSize),
                  _infoRow(Icons.access_time, 'Last Login: ${user['lastlogin'] ?? '-'}', iconSize, textFontSize),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper for each info row
  Widget _infoRow(IconData icon, String text, double iconSize, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: iconSize, color: Colors.black54),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
