
import 'package:everesports/core/page/setting/page/kyc/verifie_account_refactored.dart';
import 'package:everesports/widget/common_navigation.dart';
import 'package:flutter/material.dart';

class KYCView extends StatelessWidget {
  final VoidCallback? onLogoutSuccess;

  const KYCView({super.key, this.onLogoutSuccess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.verified_outlined),
      title: Text(
        "Verifie Account",
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () =>
          commonNavigationbuild(context, VerifieAccountPageRefactored()),
      trailing: Icon(Icons.arrow_forward_ios, size: 15),
    );
  }
}
