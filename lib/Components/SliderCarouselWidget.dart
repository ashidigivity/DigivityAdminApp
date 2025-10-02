import 'package:flutter/material.dart';
import 'dart:async';

class SliderCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const SliderCarouselWidget({super.key, required this.data});

  @override
  State<SliderCarouselWidget> createState() => _SliderCarouselWidgetState();
}

class _SliderCarouselWidgetState extends State<SliderCarouselWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    if (widget.data.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % widget.data.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  String _extractMainValue(String value) {
    return value.contains("~") ? value.split("~")[0] : value;
  }

  String _formatKey(String key) {
    return key
        .replaceAll("_", " ")
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  final List<Color> iconColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.red,
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.data.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = widget.data[index];
              final key = _formatKey(item['key']);
              final rawValue = item['value'].toString();
              final mainValue = _extractMainValue(rawValue);
              final iconColor = iconColors[index % iconColors.length];

              return AnimatedScale(
                scale: _currentPage == index ? 1 : 0.95,
                duration: const Duration(milliseconds: 350),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Bottom-left accent image
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double imgSize =
                                    constraints.maxWidth *
                                    1; // 40% of card width
                                return Opacity(
                                  opacity: 1,
                                  child: Image.asset(
                                    'assets/images/background-img.png', // local image
                                    width: imgSize,
                                    height: imgSize,
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Card content
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        iconColor.withOpacity(0.25),
                                        iconColor.withOpacity(0.45),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.pie_chart_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        key,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        mainValue,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            onPageChanged: (page) {
              setState(() => _currentPage = page);
            },
          ),
        ),

        const SizedBox(height: 10),

        /// Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.data.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 22 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.black.withOpacity(0.85)
                    : Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
