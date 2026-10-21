import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A branded, animated banner shown at the top of the screen.
class TopNotification extends StatelessWidget {
  const TopNotification({
    super.key,
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSuccess ? AppColors.success : AppColors.error,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage('images/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Owns the [OverlayEntry] and the auto-dismiss timer for [TopNotification].
///
/// Screens only need to create one controller, call [show] and dispose it.
class TopNotificationController {
  OverlayEntry? _entry;
  Timer? _timer;

  void show(
    BuildContext context, {
    required String message,
    required bool isSuccess,
  }) {
    hide();

    final overlay = Overlay.of(context, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (_) => TopNotification(
        message: message,
        isSuccess: isSuccess,
        onDismiss: hide,
      ),
    );

    overlay.insert(_entry!);
    _timer = Timer(const Duration(seconds: 3), hide);
  }

  void hide() {
    _timer?.cancel();
    _timer = null;

    final entry = _entry;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
    _entry = null;
  }

  void dispose() => hide();
}
