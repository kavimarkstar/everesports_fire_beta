import 'dart:io';

import 'package:everesports/core/auth/home/login_home.dart';
import 'package:everesports/core/page/setting/page/kyc/model/kyc_request.dart';
import 'package:everesports/core/page/setting/page/kyc/service/kyc_service.dart';
import 'package:everesports/core/page/setting/page/kyc/widget/country_picker.dart';
import 'package:everesports/core/page/setting/page/kyc/widget/image_picker_card.dart';
import 'package:everesports/widget/common_textfield.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifieAccountPageRefactored extends StatefulWidget {
  const VerifieAccountPageRefactored({super.key});

  @override
  State<VerifieAccountPageRefactored> createState() =>
      _VerifieAccountPageRefactoredState();
}

class _VerifieAccountPageRefactoredState
    extends State<VerifieAccountPageRefactored> {
  String? _userId;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _fullNameCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _surnameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _idNumberCtrl = TextEditingController();
  final TextEditingController _idCardNumberCtrl = TextEditingController();

  // State variables
  IdDocumentType _idType = IdDocumentType.passport;
  File? _idDocumentFrontFile;
  File? _idDocumentBackFile;
  File? _addressProofFile;
  bool _submitting = false;
  List<String> _countries = [];
  String? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _checkSessionAndFetch();
    _loadCountries();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _surnameCtrl.dispose();
    _addressCtrl.dispose();
    _idNumberCtrl.dispose();
    _idCardNumberCtrl.dispose();
    super.dispose();
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
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await KycService.getCountries();
      if (!mounted) return;
      setState(() {
        _countries = countries;
        _selectedCountry = countries.isNotEmpty ? countries.first : null;
      });
    } catch (e) {
      // Non-fatal; keep dropdown hidden if load fails
    }
  }

  bool _validateForm() {
    if (_fullNameCtrl.text.trim().isEmpty) {
      _showError('Full name required');
      return false;
    }
    if (_firstNameCtrl.text.trim().isEmpty) {
      _showError('First name required');
      return false;
    }
    if (_surnameCtrl.text.trim().isEmpty) {
      _showError('Surname required');
      return false;
    }
    if (_addressCtrl.text.trim().length < 8) {
      _showError('Please enter a valid address');
      return false;
    }
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      _showError('Select a country');
      return false;
    }
    if (_idNumberCtrl.text.trim().isEmpty) {
      _showError('ID number is required');
      return false;
    }
    if (_idDocumentFrontFile == null || _addressProofFile == null) {
      _showError('Please attach required documents');
      return false;
    }
    // Front side is always required, back side is recommended but optional
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_userId == null) {
      _showError('Please login again');
      return;
    }

    if (!_validateForm()) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      // Upload files
      final idDocFrontPath = await KycService.uploadFile(
        _idDocumentFrontFile!,
        _userId!,
      );
      String? idDocBackPath;
      if (_idDocumentBackFile != null) {
        idDocBackPath = await KycService.uploadFile(
          _idDocumentBackFile!,
          _userId!,
        );
      }
      final addrProofPath = await KycService.uploadFile(
        _addressProofFile!,
        _userId!,
      );

      // Create KYC request
      final request = KycRequest(
        userId: _userId!,
        fullName: _fullNameCtrl.text.trim().toUpperCase(),
        firstName: _firstNameCtrl.text.trim().toUpperCase(),
        surname: _surnameCtrl.text.trim().toUpperCase(),
        address: _addressCtrl.text.trim(),
        country: _selectedCountry,
        idType: _idType.value,
        idNumber: _idNumberCtrl.text.trim().toUpperCase(),
        idCardNumber: null, // No longer using separate ID card field
        idDocumentFrontPath: idDocFrontPath,
        idDocumentBackPath: idDocBackPath,
        addressProofPath: addrProofPath,
        status: KycStatus.pending.toString(),
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );

      // Submit to database
      await KycService.submitKycRequest(request);

      if (!mounted) return;
      _showSuccess('KYC submitted. We will verify soon.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError('Submission failed: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your legal name (uppercase) and address',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),

              // Name fields
              commonTextfieldbuild(
                context,
                'Enter your full legal name',
                'Full name *',
                _fullNameCtrl,
              ),
              commonTextfieldbuild(
                context,
                'First name',
                'First name *',
                _firstNameCtrl,
              ),
              commonTextfieldbuild(
                context,
                'Surname/Last name',
                'Surname *',
                _surnameCtrl,
              ),

              // Address field
              commonTextfieldbuild(
                context,
                'Enter your full address',
                'Full address',
                _addressCtrl,
              ),

              // ID type dropdown
              commonDropdownbuild<IdDocumentType>(
                context,
                hintText: 'Select document type',
                labelText: 'ID document type',
                value: _idType,
                items: IdDocumentType.values,
                itemLabel: (v) => v.displayName,
                onChanged: (v) =>
                    setState(() => _idType = v ?? IdDocumentType.passport),
              ),

              // Country picker
              CountryPickerField(
                countries: _countries,
                selectedCountry: _selectedCountry,
                onCountrySelected: (country) =>
                    setState(() => _selectedCountry = country),
                validator: (_) =>
                    _selectedCountry == null ? 'Select a country' : null,
              ),
              // ID Number field (required for all document types)
              commonTextfieldbuild(
                context,
                'Enter your document ID number',
                'ID Number *',
                _idNumberCtrl,
              ),

              // Document image picker
              DocumentImagePicker(
                documentType: _idType.displayName,
                frontImage: _idDocumentFrontFile,
                backImage: _idDocumentBackFile,
                onFrontImageSelected: (file) =>
                    setState(() => _idDocumentFrontFile = file),
                onBackImageSelected: (file) =>
                    setState(() => _idDocumentBackFile = file),
                isRequired: true,
              ),

              // Address proof picker
              const SizedBox(height: 16),
              const Text(
                'Attach proof of address (utility/internet/bank bill)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ImagePickerCard(
                title: 'Address Proof',
                subtitle: 'Tap to select document',
                selectedFile: _addressProofFile,
                onImageSelected: (file) =>
                    setState(() => _addressProofFile = file),
              ),

              // Submit button
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit for verification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
