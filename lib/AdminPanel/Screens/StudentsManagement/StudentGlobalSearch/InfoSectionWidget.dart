import 'package:flutter/material.dart';

class InfoSectionWidget extends StatelessWidget {
  final String title;
  final Map<String, dynamic> infoData;

  const InfoSectionWidget({super.key, required this.title, required this.infoData});

  @override
  Widget build(BuildContext context) {
    final entries = infoData.entries.toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const Divider(),
            ...entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      e.key.replaceAll("_", " ").toUpperCase(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      e.value?.toString() ?? "N/A",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
