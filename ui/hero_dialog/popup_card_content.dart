import 'package:flutter/material.dart';

import '../text.dart';
import 'custom_rect_tween.dart';

class PopupCardContent extends StatelessWidget {
  final String id;
  final String cardTitle;
  final String cardSubtitle;
  final Widget child;

  const PopupCardContent({
    required this.id,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: id,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin!, end: end!);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card title
                    UIKText.h3(cardTitle),

                    // const Text('Select an option below'),
                    const SizedBox(height: 20),

                    // Card content
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
