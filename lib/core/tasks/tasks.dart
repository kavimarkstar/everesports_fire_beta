import 'package:everesports/Theme/colors.dart';

import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int selectedIndex = 0;

  final List<String> sidebarItems = ['Processes', 'Performance'];

  final List<Widget> pages = [
    Center(child: Text('All Tasks Page', style: TextStyle(fontSize: 24))),
    // PerformanceDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        // Sidebar
        Container(
          width: isTablet(context) ? 60 : 200,
          color: isDarkMode ? mainBlackColor : mainWhiteColor,
          child: ListView.builder(
            itemCount: sidebarItems.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return ListTile(
                selected: isSelected,
                selectedTileColor: mainColor,
                leading: Icon(
                  [
                    Icons.auto_awesome_mosaic_outlined,
                    Icons.insert_chart_outlined,
                    Icons.pending_actions,
                    Icons.settings,
                  ][index],
                  color: isSelected
                      ? mainBlackColor
                      : isDarkMode
                      ? mainWhiteColor
                      : mainBlackColor,
                ),
                title: !isTablet(context)
                    ? Text(
                        sidebarItems[index],
                        style: TextStyle(
                          color: isSelected
                              ? mainBlackColor
                              : isDarkMode
                              ? mainWhiteColor
                              : mainBlackColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      )
                    : null,
                onTap: () {
                  setState(() => selectedIndex = index);
                },
              );
            },
          ),
        ),
        // Main content
        Expanded(child: pages[selectedIndex]),
      ],
    );
  }
}
