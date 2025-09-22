import 'package:everesports/language/controller/all_language.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;

  const ExpandableText(this.text, {Key? key, this.style, this.maxLines = 2})
    : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;
  bool _showButton = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if text overflows
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final span = TextSpan(text: widget.text, style: widget.style);
      final tp = TextPainter(
        text: span,
        maxLines: widget.maxLines,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: MediaQuery.of(context).size.width);
      if (mounted) {
        setState(() {
          _showButton = tp.didExceedMaxLines;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (_showButton)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                _expanded ? getShowLess(context) : getShowMore(context),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: (widget.style?.fontSize ?? 14) * 0.95,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
