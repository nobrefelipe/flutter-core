import 'package:flutter/material.dart';

import '../ui/text.dart';
import 'notification_types.dart';

class ForegroundNotificationBanner {
  static OverlayEntry? _currentOverlay;

  /// Display-only — shows the notification as an overlay banner.
  /// Routing on tap is handled by NotificationService via onNotificationTapped callback.
  static void show(BuildContext context, AppNotification notification, {Duration duration = const Duration(seconds: 4)}) {
    hide();
    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => _BannerWidget(notification: notification, onDismiss: hide),
    );
    overlay.insert(_currentOverlay!);
    Future.delayed(duration, hide);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _BannerWidget extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onDismiss;

  const _BannerWidget({required this.notification, required this.onDismiss});

  @override
  State<_BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<_BannerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() => _controller.reverse().then((_) => widget.onDismiss());

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: InkWell(
                  onTap: _dismiss,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: widget.notification.type.color,
                          child: Icon(widget.notification.type.icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              UIKText.small(widget.notification.title, maxLines: 1),
                              const SizedBox(height: 2),
                              UIKText.small(widget.notification.body, maxLines: 2, color: Colors.grey[600]),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
