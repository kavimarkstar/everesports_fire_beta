import 'dart:async';
import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/search/service/search_service.dart';
import 'package:everesports/core/page/search/view/nosearch_box.dart';
import 'package:everesports/core/page/search/widget/search_textfield.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';

class SearchBoxView extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSearchResults;

  const SearchBoxView({super.key, this.onSearchResults});

  @override
  State<SearchBoxView> createState() => _SearchBoxViewState();
}

class _SearchBoxViewState extends State<SearchBoxView> {
  final TextEditingController _controller = TextEditingController();
  bool _showClear = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _showClear = _controller.text.isNotEmpty);
      _onTextChanged();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final suggestions = <Map<String, dynamic>>[];

      // Only fetch search suggestions from the 'search' collection
      final searchTerms = await SearchService.searchSuggestions(query);
      for (final term in searchTerms.take(10)) {
        suggestions.add({
          'type': 'search',
          'title': term,
          'subtitle': 'Search suggestion',
          'data': term,
        });
      }

      setState(() {
        _suggestions = suggestions;
        _showSuggestions = suggestions.isNotEmpty;
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    final data = suggestion['data'];
    final type = suggestion['type'];

    if (type == 'search') {
      // If a search suggestion is selected, trigger a full search for that term
      _controller.text = data;
      _onSearch(data);
    }

    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  Future<void> _onSearch([String? value]) async {
    final query = value ?? _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final results = await SearchService.searchAll(query);
      widget.onSearchResults?.call(results);
    } catch (e) {
      print('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return isMobile(context)
        ? Column(
            children: [
              AppBar(
                actions: [
                  Expanded(
                    child: CommonSearchTextfield(
                      controller: _controller,
                      showSuggestions: _showSuggestions,
                      suggestions: _suggestions,
                      showClear: _showClear,
                      isSearching: _isSearching,
                      onSearchResults: widget.onSearchResults ?? (results) {},
                      onSearch: _onSearch,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  _showSuggestions && _suggestions.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return _buildSuggestionTile(
                                suggestion,
                                isDarkMode,
                              );
                            },
                          ),
                        )
                      : NosearchBox(),
                ],
              ),
            ],
          )
        : Column(
            children: [
              Stack(
                children: [
                  CommonSearchTextfield(
                    controller: _controller,
                    showSuggestions: _showSuggestions,
                    suggestions: _suggestions,
                    showClear: _showClear,
                    isSearching: _isSearching,
                    onSearchResults: widget.onSearchResults ?? (results) {},
                    onSearch: _onSearch,
                  ),
                ],
              ),
              !isTablet(context)
                  ? _showSuggestions && _suggestions.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                return _buildSuggestionTile(
                                  suggestion,
                                  isDarkMode,
                                );
                              },
                            ),
                          )
                        : NosearchBox()
                  : _isSearching
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return _buildSuggestionTile(suggestion, isDarkMode);
                        },
                      ),
                    ),
            ],
          );
  }

  Widget _buildSuggestionTile(
    Map<String, dynamic> suggestion,
    bool isDarkMode,
  ) {
    final title = suggestion['title'];
    final subtitle = suggestion['subtitle'];

    return InkWell(
      onTap: () => _onSuggestionSelected(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: isDarkMode
                  ? mainWhiteColor.withOpacity(0.6)
                  : mainBlackColor.withOpacity(0.6),
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDarkMode ? mainWhiteColor : mainBlackColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDarkMode
                            ? mainWhiteColor.withOpacity(0.6)
                            : mainBlackColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
