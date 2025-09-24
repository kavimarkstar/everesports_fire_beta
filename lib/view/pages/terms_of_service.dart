import 'package:everesports/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  static const _collectionName = 'terms_of_service';

  List<Map<String, dynamic>> terms = [];
  int selectedIndex = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(_collectionName)
          .orderBy('order', descending: false)
          .get();

      final data = querySnapshot.docs.map((doc) {
        final d = doc.data();
        return {
          'title': d['title']?.toString() ?? 'Untitled',
          'description': d['description']?.toString() ?? 'No content',
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        terms = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to load terms. Please try again later.';
        isLoading = false;
      });
      debugPrint('Error fetching terms: $e');
    }
  }

  Widget _buildDesktopLayout() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Terms of Service",
          style: TextStyle(
            fontFamily: "Poppins",
            fontWeight: FontWeight.w800,
            fontSize: 50,
          ),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: BoxDecoration(
            color: isDarkMode ? mainWhiteColor : mainBlackColor,
          ),
          child: Center(
            child: Text(
              "data",
              style: TextStyle(
                color: isDarkMode ? mainBlackColor : mainWhiteColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Row(
            children: [
              SizedBox(width: 250, child: _buildTermsList()),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Text(
                      terms.isNotEmpty
                          ? terms[selectedIndex]['description']
                          : '',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 200, child: _buildTermsList()),
        const Divider(height: 1),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(
                terms.isNotEmpty ? terms[selectedIndex]['description'] : '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsList() {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      itemCount: terms.length,
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        return ListTile(
          selected: isSelected,
          selectedTileColor: isSelected
              ? (isDarkMode ? mainWhiteColor : mainBlackColor)
              : null,
          title: Text(
            terms[index]['title'],
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? mainColor : null,
            ),
          ),
          onTap: () => setState(() => selectedIndex = index),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error ?? '',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _fetchTerms, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.blue),
          SizedBox(height: 16),
          Text('No terms of service available', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading terms of service...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: () {
            if (isLoading) return _buildLoadingState();
            if (error != null) return _buildErrorState();
            if (terms.isEmpty) return _buildEmptyState();

            final isWide = MediaQuery.of(context).size.width > 600;
            return isWide ? _buildDesktopLayout() : _buildMobileLayout();
          }(),
        ),
      ),
    );
  }
}
