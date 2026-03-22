import 'package:flutter/material.dart';

import '../text.dart';
import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';
import 'popup_card_content.dart';

class PopupCardTileItem {
  final String key;
  final String value;
  PopupCardTileItem({required this.key, required this.value});
}

class PopupCardTile extends StatefulWidget {
  final String id;
  final String cardTitle;
  final String cardSubtitle;
  final Function(PopupCardTileItem?)? callBack;
  final bool readOnly;
  final Widget child;
  final bool showOnInit;
  final bool barrierDismissible;
  const PopupCardTile({
    super.key,
    required this.id,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.child,
    this.showOnInit = false,
    this.callBack,
    this.readOnly = false,
    this.barrierDismissible = true,
  });

  @override
  State<PopupCardTile> createState() => _PopupCardTileState();
}

class _PopupCardTileState extends State<PopupCardTile> {
  PopupCardTileItem? selectedValue;

  @override
  void initState() {
    super.initState();
    if (widget.showOnInit) {
      Future(() => show());
    }
  }

  void show() async {
    final result = await Navigator.of(context).push(
      HeroDialogRoute(
        barrierDismissible: widget.barrierDismissible,
        builder: (context) => Center(
          child: PopupCardContent(
            id: widget.id,
            cardTitle: widget.cardTitle,
            cardSubtitle: widget.cardSubtitle,
            child: widget.child,
          ),
        ),
      ),
    );
    setState(() {
      selectedValue = result as PopupCardTileItem?;
    });
    if (widget.callBack != null) {
      widget.callBack!(result as PopupCardTileItem?);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Open card popup
      onTap: () async {
        if (widget.readOnly) return;
        show();
      },
      // Visible content
      child: Hero(
        tag: widget.id,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: Material(
          borderRadius: BorderRadius.circular(12),
          child: AnimatedSize(
            duration: Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 1,
                  color: Colors.black12,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(100, 100, 100, 0.0),
                    blurRadius: 10,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIKText.h5(widget.cardTitle),
                    UIKText.body(selectedValue?.value ?? widget.cardSubtitle),
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
