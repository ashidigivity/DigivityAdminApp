import 'package:flutter/material.dart';

class PopupNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final double popupSize;

  const PopupNetworkImage({
    super.key,
    required this.imageUrl,
    this.radius = 30,
    this.popupSize = 400,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true, // Tap outside to close
          barrierLabel: "Image Preview",
          pageBuilder: (_, __, ___) {
            return Container(
              margin: EdgeInsets.all(20),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: popupSize,
                          height: popupSize,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0,
                      right: MediaQuery.of(context).size.width * 0.5 - popupSize / 2 - 1,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 28, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.6),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[200],
      ),
    );
  }
}
