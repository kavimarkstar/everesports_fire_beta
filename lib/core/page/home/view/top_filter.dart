import 'package:everesports/Theme/colors.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TopFilterView extends StatefulWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onChanged;

  TopFilterView({
    Key? key,
    required this.filters,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TopFilterViewState createState() => _TopFilterViewState();
}

class _TopFilterViewState extends State<TopFilterView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.offset - 120).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.offset + 120).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktopScreen = isDesktop(context);
    return SizedBox(
      height: 40,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile(context) ? 5 : 15),
        child: Row(
          children: [
            if (isDesktopScreen)
              IconButton(
                icon: const Icon(Icons.chevron_left),
                splashRadius: 20,
                onPressed: () {
                  _scrollLeft();
                },
                tooltip: 'Scroll left',
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.filters.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return buttinBuildbuild(context, index);
                },
              ),
            ),
            if (isDesktopScreen)
              IconButton(
                icon: const Icon(Icons.chevron_right),
                splashRadius: 20,
                onPressed: () {
                  _scrollRight();
                },
                tooltip: 'Scroll right',
              ),
          ],
        ),
      ),
    );
  }

  Widget buttinBuildbuild(BuildContext context, int index) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String label = widget.filters[index];
    final bool selected = widget.selected == label;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        onPressed: () {
          widget.onChanged(label);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primary
              : (isDark ? const Color(0xff171717) : const Color(0xfff2f2f2)),
          foregroundColor: selected
              ? Colors.white
              : Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 2,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: Text(
          label,
          style: TextStyle(color: isDark ? mainWhiteColor : mainBlackColor),
        ),
      ),
    );
  }
}

@override
Widget lodingBuildbuild(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  return SizedBox(
    height: 40,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ListView.builder(
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xff171717)
                    : const Color(0xfff2f2f2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Animate(
                onPlay: (controller) => controller.repeat(), // loop shimmer
                effects: [ShimmerEffect(duration: 1800.ms)],
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.07,

                  // ignore: sort_child_properties_last
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    shape: BoxShape.rectangle,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}
