/// Describes a single action button in a bottom sheet footer.
class BottomSheetAction {
  final String label;
  final Future<void> Function() onTap;

  const BottomSheetAction({
    required this.label,
    required this.onTap,
  });
}
