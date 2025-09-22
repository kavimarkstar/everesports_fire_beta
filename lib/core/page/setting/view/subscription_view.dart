import 'package:everesports/core/page/subscription/subscription_page.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

class SubscriptionView extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const SubscriptionView({super.key, this.onLogoutSuccess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.workspace_premium_rounded),
      title: Text(
        "EverEsports Premium",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () => commonNavigationbuild(context, SubscriptionPage()),
      trailing: Icon(Icons.arrow_forward_ios, size: 15),
    );
  }
}
