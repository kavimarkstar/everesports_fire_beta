import 'package:everesports/core/page/auth/include/view/contents_display_gridview.dart';
import 'package:flutter/material.dart';

class NavigatinBarUsersProfile extends StatefulWidget {
  final String userId;
  const NavigatinBarUsersProfile({super.key, required this.userId});

  @override
  State<NavigatinBarUsersProfile> createState() =>
      _NavigatinBarUsersProfileState();
}

class _NavigatinBarUsersProfileState extends State<NavigatinBarUsersProfile> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ContentsDisplayGridviewUser(userId: widget.userId),

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
              2,
              (i) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      i == 0
                          ? (_selectedIndex == 0
                                ? Icons.calendar_view_day_rounded
                                : Icons.calendar_view_day_outlined)
                          : (_selectedIndex == 1
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
