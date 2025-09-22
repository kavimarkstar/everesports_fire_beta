import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:everesports/Theme/colors.dart';

class CommonSearchTextfield extends StatefulWidget {
  final TextEditingController controller;
  final bool showSuggestions;
  final List<Map<String, dynamic>> suggestions;
  final bool showClear;
  final bool isSearching;
  final Function(Map<String, dynamic>) onSearchResults;
  final Function() onSearch;
  const CommonSearchTextfield({
    super.key,
    required this.controller,
    required this.showSuggestions,
    required this.suggestions,
    required this.showClear,
    required this.isSearching,
    required this.onSearchResults,
    required this.onSearch,
  });

  @override
  State<CommonSearchTextfield> createState() => _CommonSearchTextfieldState();
}

class _CommonSearchTextfieldState extends State<CommonSearchTextfield> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.all(isMobile(context) ? 6 : 16),
      child: TextField(
        controller: widget.controller,
        onSubmitted: (_) => widget.onSearch(),
        style: theme.textTheme.bodyLarge,
        cursorColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode ? secondBlackColor : secondWhiteGrayColor,
          hintText: 'Search',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile(context) ? 50 : 16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile(context) ? 50 : 16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile(context) ? 50 : 16),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Padding(
            padding: EdgeInsets.all(isMobile(context) ? 0 : 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showClear)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    color: isDarkMode ? mainWhiteColor : mainBlackColor,
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        widget.showSuggestions;
                        widget.suggestions.clear();
                      });
                      widget.onSearchResults.call({
                        'tournaments': [],
                        'users': [],
                      });
                    },
                    tooltip: 'Clear',
                  ),
                IconButton(
                  icon: widget.isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  color: isDarkMode ? mainWhiteColor : mainBlackColor,
                  onPressed: widget.isSearching
                      ? null
                      : () => widget.onSearch(),
                  tooltip: 'Search',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
