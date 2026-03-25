// core/ui/icons/app_icons.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Resolves string icon keys to Lucide IconData.
/// Used by NavItem and other backend-driven UI components.
///
/// To add a new icon:
/// 1. Add the key to the switch statement
/// 2. Map it to a LucideIcons constant
/// 3. Fallback is LucideIcons.circle for unknown keys
class AppIcons {
  AppIcons._();

  /// Resolve a string icon key to IconData.
  /// Returns LucideIcons.circle if key is null or unknown.
  static IconData resolve(String? iconKey) {
    if (iconKey == null) return LucideIcons.circle;

    return switch (iconKey) {
      // Navigation
      'home' => LucideIcons.house,
      'menu' => LucideIcons.menu,
      'back' => LucideIcons.arrowLeft,
      'close' => LucideIcons.x,

      // User & Profile
      'profile' => LucideIcons.user,
      'user' => LucideIcons.user,
      'users' => LucideIcons.users,
      'settings' => LucideIcons.settings,

      // Finance & Rewards
      'wallet' => LucideIcons.wallet,
      'rewards' => LucideIcons.gift,
      'gift' => LucideIcons.gift,
      'coins' => LucideIcons.coins,
      'payment' => LucideIcons.creditCard,

      // Communication
      'notifications' => LucideIcons.bell,
      'bell' => LucideIcons.bell,
      'message' => LucideIcons.messageCircle,
      'chat' => LucideIcons.messageCircle,
      'intercom' => LucideIcons.messageSquare,
      'mail' => LucideIcons.mail,

      // Learning & Content
      'learning' => LucideIcons.bookOpen,
      'book' => LucideIcons.bookOpen,
      'video' => LucideIcons.video,
      'play' => LucideIcons.play,

      // Actions
      'search' => LucideIcons.search,
      'filter' => LucideIcons.funnel,
      'edit' => LucideIcons.pen,
      'delete' => LucideIcons.trash2,
      'add' => LucideIcons.plus,
      'check' => LucideIcons.check,

      // Status
      'info' => LucideIcons.info,
      'warning' => LucideIcons.triangle,
      'error' => LucideIcons.circleX,
      'success' => LucideIcons.circleCheck,

      // Misc
      'calendar' => LucideIcons.calendar,
      'location' => LucideIcons.mapPin,
      'camera' => LucideIcons.camera,
      'image' => LucideIcons.image,
      'file' => LucideIcons.file,
      'download' => LucideIcons.download,
      'upload' => LucideIcons.upload,
      'share' => LucideIcons.share2,
      'link' => LucideIcons.link,
      'external' => LucideIcons.externalLink,

      // Fallback
      _ => LucideIcons.circle,
    };
  }
}
