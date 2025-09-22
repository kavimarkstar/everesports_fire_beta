import 'package:everesports/core/page/search/view/search_box.dart';
import 'package:everesports/core/page/search/view/search_results.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Map<String, dynamic>? _searchResults;

  void _onSearchResults(Map<String, dynamic> results) {
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isDesktop(context)
            ? Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: SearchBoxView(onSearchResults: _onSearchResults),
                  ),
                  Expanded(
                    child: SearchResultsView(searchResults: _searchResults),
                  ),
                ],
              )
            : isTablet(context)
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    SearchBoxView(onSearchResults: _onSearchResults),
                    SearchResultsView(searchResults: _searchResults),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [SearchBoxView(onSearchResults: _onSearchResults)],
                ),
              ),
      ),
    );
  }
}
