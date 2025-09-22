import 'dart:io';

import 'package:everesports/Theme/colors.dart';
import 'package:everesports/core/page/subscription/widget/card.dart';
import 'package:everesports/core/page/subscription/widget/top_card.dart';
import 'package:everesports/core/page/subscription/service/premium_package_service.dart';
import 'package:everesports/database/config/config.dart';
import 'package:everesports/responsive/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/page/cristols/widget/cristol_button.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage>
    with WidgetsBindingObserver {
  List<PremiumPackage> premiumPlans = [];
  int? selectedIndex = 1;
  late PageController _pageController;
  bool _isLoading = true;
  String? _error;
  String? _userId;
  bool _isSubscribing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(
      initialPage: selectedIndex!,
      viewportFraction: 0.85,
    );
    _checkSessionAndFetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh cristol amount when app resumes
      _refreshCristolAmount();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cristol amount when dependencies change (e.g., when page is focused)
    _refreshCristolAmount();
  }

  Future<void> _checkSessionAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserId = prefs.getString('userId');
    if (savedUserId == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginHomePage()),
      );
      return;
    }
    _userId = savedUserId;
    await _fetchPremiumPackages();
  }

  Future<void> _fetchPremiumPackages() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final packages = await PremiumPackageService.getPremiumPackages();

      if (mounted) {
        setState(() {
          premiumPlans = packages;
          _isLoading = false;
          // Adjust selected index if needed
          if (selectedIndex! >= packages.length) {
            selectedIndex = packages.isNotEmpty ? 0 : null;
          }
        });
        // Refresh cristol amount after loading packages
        await _refreshCristolAmount();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load premium packages: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _subscribeToPackage(PremiumPackage plan) async {
    if (_userId == null) {
      _showErrorDialog('Please login to subscribe');
      return;
    }

    setState(() {
      _isSubscribing = true;
    });

    try {
      // First check if user has enough cristols
      final cristolResponse = await http.get(
        Uri.parse('$fileServerBaseUrl/api/users-cristols/$_userId'),
      );

      if (cristolResponse.statusCode == 200) {
        final cristolData = json.decode(cristolResponse.body);
        final currentCristol = cristolData['amountCristol'] ?? 0;

        // Convert price to cristol amount (assuming price is in USD)
        final priceInCristol = _convertPriceToCristol(plan.price);

        if (currentCristol < priceInCristol) {
          _showErrorDialog(
            'Insufficient cristols. You need $priceInCristol cristols to subscribe to ${plan.title}',
          );
          return;
        }

        // Activate package on server
        final activationResponse = await http.post(
          Uri.parse('$fileServerBaseUrl/api/activate-package'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'userId': _userId,
            'packageName': plan.title,
            'packageId': plan.id,
            'duration': 30, // 30 days
            'price': plan.price,
          }),
        );

        if (activationResponse.statusCode == 200) {
          final result = json.decode(activationResponse.body);
          if (result['success'] == true) {
            _showSuccessDialog(plan.title);
            // Refresh cristol amount
            await _refreshCristolAmount();
          } else {
            _showErrorDialog(result['message'] ?? 'Failed to activate package');
          }
        } else {
          _showErrorDialog('Server error: ${activationResponse.statusCode}');
        }
      } else {
        _showErrorDialog('Failed to fetch cristol balance');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubscribing = false;
        });
      }
    }
  }

  int _convertPriceToCristol(String price) {
    // Convert price string to cristol amount
    // Since prices are already in cristols (e.g., "1000", "2000")
    try {
      // Remove any non-numeric characters and parse as integer
      final cleanPrice = price.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanPrice.isNotEmpty) {
        return int.parse(cleanPrice);
      }
    } catch (e) {
      print('Error converting price: $e');
    }
    return 0;
  }

  Future<void> _refreshCristolAmount() async {
    // Refresh all CristolButton instances in the app
    await CristolButton.refreshAllInstances();
  }

  void _showSuccessDialog(String planTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Text('Success!'),
            ],
          ),
          content: Text(
            'Successfully subscribed to $planTitle plan! Your package is now active for 30 days.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 24),
              SizedBox(width: 12),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _scrollToPrevious() {
    if (selectedIndex! > 0) {
      setState(() {
        selectedIndex = selectedIndex! - 1;
      });
      _pageController.animateToPage(
        selectedIndex!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToNext() {
    if (selectedIndex! < premiumPlans.length - 1) {
      setState(() {
        selectedIndex = selectedIndex! + 1;
      });
      _pageController.animateToPage(
        selectedIndex!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive grid configuration
    double maxCrossAxisExtent;
    double childAspectRatio;

    if (screenWidth < 600) {
      // Mobile: 1 column
      maxCrossAxisExtent = screenWidth * 0.9;
      childAspectRatio = 0.4;
    } else if (screenWidth < 900) {
      // Tablet: 2 columns
      maxCrossAxisExtent = screenWidth * 0.45;
      childAspectRatio = 0.5;
    } else if (screenWidth < 1200) {
      // Small desktop: 3 columns
      maxCrossAxisExtent = screenWidth * 0.3;
      childAspectRatio = 0.6;
    } else {
      // Large desktop: 3 columns
      maxCrossAxisExtent = screenWidth * 0.3;
      childAspectRatio = 0.6;
    }

    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                'Premium Subscriptions',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
                ),
              ),
            )
          : null,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top card with modern spacing
              Container(
                width: isMobile(context)
                    ? double.infinity
                    : isTablet(context)
                    ? screenWidth * 0.8
                    : screenWidth * 0.5,
                margin: const EdgeInsets.only(top: 24),
                child: topCardbuild(context),
              ),

              // Main content area with modern layout
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    // Loading, Error, or Content states
                    _isLoading
                        ? _buildLoadingState()
                        : _error != null
                        ? _buildErrorState()
                        : premiumPlans.isEmpty
                        ? _buildEmptyState()
                        : screenWidth < 600
                        ? _buildMobileSlider()
                        : _buildResponsiveGrid(
                            maxCrossAxisExtent,
                            childAspectRatio,
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading premium packages...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _fetchPremiumPackages,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.subscriptions, size: 48, color: mainColor),
              ),
              const SizedBox(height: 24),
              Text(
                'No Premium Packages Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We\'re working on bringing you amazing premium features. Check back soon!',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: PageView.builder(
              controller: _pageController,
              padEnds: true,
              onPageChanged: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              itemCount: premiumPlans.length,
              itemBuilder: (context, index) {
                final plan = premiumPlans[index];
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 8,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: premiumCardBuild(
                      context,
                      {'title': plan.title, 'price': plan.price},
                      _isSubscribing ? null : () => _subscribeToPackage(plan),
                      selected: isSelected,
                    ),
                  ),
                );
              },
            ),
          ),

          // Modern dots indicator
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                premiumPlans.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 8,
                  width: selectedIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? mainColor
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: selectedIndex == index
                        ? [
                            BoxShadow(
                              color: mainColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Navigation arrows with modern design
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            Positioned(
              left: 20,
              top: MediaQuery.of(context).size.height * 0.3 - 30,
              child: GestureDetector(
                onTap: _scrollToPrevious,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(Icons.arrow_back_ios, color: mainColor, size: 24),
                ),
              ),
            ),
          if (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height * 0.3 - 30,
              child: GestureDetector(
                onTap: _scrollToNext,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: mainColor,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(
    double maxCrossAxisExtent,
    double childAspectRatio,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 1,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: premiumPlans.length,
        itemBuilder: (context, index) {
          final plan = premiumPlans[index];
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: premiumCardBuild(
                context,
                {
                  'title': plan.title,
                  'price': plan.price,
                  'items': plan.items.join(', '),
                },
                _isSubscribing ? null : () => _subscribeToPackage(plan),
                selected: isSelected,
              ),
            ),
          );
        },
      ),
    );
  }
}
