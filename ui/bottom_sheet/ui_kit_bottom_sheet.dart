import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bottom_sheet_action.dart';
import 'bottom_sheet_shell.dart';

/// Fluent static facade for showing bottom sheets.
///
/// Basic usage:
/// ```dart
/// UIKitBottomSheet.show(
///   context,
///   title: 'Settings',
///   content: SettingsWidget(),
/// );
/// ```
///
/// With a single CTA:
/// ```dart
/// UIKitBottomSheet.show(
///   context,
///   title: 'Confirm',
///   content: ConfirmWidget(),
///   primaryAction: BottomSheetAction(
///     label: 'Confirm',
///     onTap: () async => doSomething(),
///   ),
/// );
/// ```
///
/// With primary + secondary actions:
/// ```dart
/// UIKitBottomSheet.show(
///   context,
///   title: 'Delete item',
///   content: DeleteWarning(),
///   primaryAction: BottomSheetAction(label: 'Delete', onTap: () async => delete()),
///   secondaryAction: BottomSheetAction(label: 'Cancel', onTap: () async => cancel()),
/// );
/// ```
///
/// With a fully custom footer:
/// ```dart
/// UIKitBottomSheet.show(
///   context,
///   title: 'Pick a plan',
///   content: PlanPicker(),
///   footer: MyCustomFooterWidget(),
/// );
/// ```
///
/// Multi-page flow:
/// ```dart
/// UIKitBottomSheet.showPaged(
///   context,
///   pages: [
///     BottomSheetPage(title: 'Step 1', content: Step1()),
///     BottomSheetPage(title: 'Step 2', content: Step2()),
///   ],
/// );
/// ```
class UIKitBottomSheet {
  UIKitBottomSheet._();

  /// Shows a single bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    BottomSheetAction? primaryAction,
    BottomSheetAction? secondaryAction,
    Widget? footer,
  }) async {
    assert(
      footer == null || primaryAction == null,
      'Provide either a custom footer or a primaryAction, not both.',
    );
    HapticFeedback.mediumImpact();
    return FamilyModalSheet.show<T>(
      context: context,
      contentBackgroundColor: Theme.of(context).colorScheme.surface,
      safeAreaMinimum: const EdgeInsets.only(bottom: 22),
      showDragHandle: true,
      useSafeArea: false,
      useRootNavigator: true,
      builder: (ctx) => BottomSheetShell(
        title: title,
        content: content,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        footer: footer,
      ),
    );
  }

  /// Shows a multi-page bottom sheet flow.
  /// Each page is pushed onto the sheet's internal navigation stack.
  ///
  /// Pages are navigated with [FamilyModalSheet.of(context).pushPage()] —
  /// use [BottomSheetPage.pushNext] helper inside your content widgets.
  static Future<T?> showPaged<T>(
    BuildContext context, {
    required List<BottomSheetPage> pages,
  }) async {
    assert(pages.isNotEmpty, 'Must provide at least one page.');
    HapticFeedback.mediumImpact();
    return FamilyModalSheet.show<T>(
      context: context,
      contentBackgroundColor: Theme.of(context).colorScheme.surface,
      safeAreaMinimum: const EdgeInsets.only(bottom: 22),
      showDragHandle: true,
      useSafeArea: false,
      useRootNavigator: true,
      builder: (ctx) => BottomSheetShell(
        title: pages.first.title,
        content: pages.first.content,
        primaryAction: pages.first.primaryAction,
        secondaryAction: pages.first.secondaryAction,
        footer: pages.first.footer,
      ),
    );
  }
}

/// Describes a single page in a multi-page bottom sheet flow.
class BottomSheetPage {
  final String title;
  final Widget content;
  final BottomSheetAction? primaryAction;
  final BottomSheetAction? secondaryAction;
  final Widget? footer;

  const BottomSheetPage({
    required this.title,
    required this.content,
    this.primaryAction,
    this.secondaryAction,
    this.footer,
  });

  /// Call this inside a content widget to push the next page onto the sheet stack.
  ///
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => BottomSheetPage.pushNext(context, nextPage),
  ///   child: Text('Next'),
  /// )
  /// ```
  static void pushNext(BuildContext context, BottomSheetPage page) {
    FamilyModalSheet.of(context).pushPage(
      BottomSheetShell(
        title: page.title,
        content: page.content,
        primaryAction: page.primaryAction,
        secondaryAction: page.secondaryAction,
        footer: page.footer,
      ),
    );
  }

  /// Pop back to the previous page in the sheet stack.
  static void popPage(BuildContext context) {
    FamilyModalSheet.of(context).popPage();
  }
}
