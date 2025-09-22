import 'package:everesports/core/page/profile/view/contents_display_gridview.dart';
import 'package:flutter/material.dart';

class NavigatinBarProfile extends StatefulWidget {
  const NavigatinBarProfile({super.key});

  @override
  State<NavigatinBarProfile> createState() => _NavigatinBarProfileState();
}

class _NavigatinBarProfileState extends State<NavigatinBarProfile> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ContentsDisplayGridview(),
      Center(child: Text('Private')),
      Center(child: Text('Bookmarks')),
      Center(child: Text('Favorites')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (i) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      i == 0
                          ? (_selectedIndex == 0
                                ? Icons.calendar_view_day_rounded
                                : Icons.calendar_view_day_outlined)
                          : i == 1
                          ? (_selectedIndex == 1
                                ? Icons.lock
                                : Icons.lock_outline)
                          : i == 2
                          ? (_selectedIndex == 2
                                ? Icons.bookmark
                                : Icons.bookmark_outline)
                          : (_selectedIndex == 3
                                ? Icons.favorite
                                : Icons.favorite_outline),
                      color: _selectedIndex == i ? indicatorColor : Colors.grey,
                    ),
                    onPressed: () => setState(() => _selectedIndex = i),
                  ),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    height: 3,
                    width: 28,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: _selectedIndex == i
                          ? indicatorColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _pages[_selectedIndex],
      ],
    );
  }
}
