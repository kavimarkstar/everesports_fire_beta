import 'package:everesports/core/page/profile/view/bookmark.dart';
import 'package:everesports/core/page/profile/view/curant_login_user_posts.dart';
import 'package:everesports/core/page/profile/view/faverite.dart';
import 'package:everesports/core/page/profile/view/private.dart';
import 'package:everesports/core/page/profile/view/spark_view.dart';
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
      CurantLoginUserPostsView(),
      SparkView(),
      PrivateView(),
      BookmarkView(),
      FaveriteView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = Theme.of(context).colorScheme.primary;

    // Use LayoutBuilder so we can detect when this widget is placed inside
    // an unbounded vertical container (e.g. SingleChildScrollView). In that
    // situation we must NOT use Expanded (it causes RenderFlex errors).
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool parentProvidesBoundedHeight =
            constraints.maxHeight != double.infinity;

        final Widget pageArea = parentProvidesBoundedHeight
            ? Expanded(child: _pages[_selectedIndex])
            // Fallback height when parent does not provide bounded height.
            : SizedBox(
                // Give a sensible fallback height so inner ListViews have bounds.
                height: MediaQuery.of(context).size.height * 0.6,
                child: _pages[_selectedIndex],
              );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  5,
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
                                    ? Icons.post_add_sharp
                                    : Icons.post_add_outlined)
                              : i == 2
                              ? (_selectedIndex == 2
                                    ? Icons.lock
                                    : Icons.lock_outline)
                              : i == 3
                              ? (_selectedIndex == 3
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline)
                              : (_selectedIndex == 4
                                    ? Icons.favorite
                                    : Icons.favorite_outline),

                          color: _selectedIndex == i
                              ? indicatorColor
                              : Colors.grey,
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
            // pageArea is either an Expanded (when bounded) or a sized box fallback
            pageArea,
          ],
        );
      },
    );
  }
}
