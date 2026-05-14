import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'address_map_picker_screen.dart';
import 'agri_product_repository.dart';
import 'auth_controller.dart';
import 'auth_session.dart';
import 'delivery_location_service.dart';
import 'farmer_profile_storage.dart';

class _CountryOption {
  const _CountryOption(this.label, this.dial, this.name);
  final String label;
  final String dial;
  final String name;
}

/// Farmer registration with a fixed bottom primary action so "Create account"
/// stays visible above the soft keyboard (requires `adjustResize` on Android).
class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen> {
  static const List<_CountryOption> _countries = [
    _CountryOption('IN', '+91', 'India'),
    _CountryOption('NP', '+977', 'Nepal'),
    _CountryOption('RU', '+7', 'Russia'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  int _countryIndex = 0;
  bool _obscurePassword = true;
  bool _locatingAddress = false;

  _CountryOption get _country => _countries[_countryIndex];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromStorage());
  }

  Future<void> _prefillFromStorage() async {
    final p = await FarmerProfileStorage.load();
    if (!mounted) return;
    if (p.fullName.isEmpty &&
        p.email.isEmpty &&
        p.address.isEmpty &&
        p.phoneDisplay.isEmpty) {
      return;
    }
    setState(() {
      _nameCtrl.text = p.fullName;
      _emailCtrl.text = p.email;
      _addressCtrl.text = p.address;
      final phone = p.phoneDisplay;
      for (var i = 0; i < _countries.length; i++) {
        if (phone.startsWith(_countries[i].dial)) {
          _countryIndex = i;
          _phoneCtrl.text = phone.substring(_countries[i].dial.length).trim();
          break;
        }
      }
      if (_phoneCtrl.text.isEmpty && phone.isNotEmpty) {
        _phoneCtrl.text = phone;
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await FarmerProfileStorage.save(
      FarmerProfile(
        fullName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phoneDisplay: '${_country.dial} ${_phoneCtrl.text.trim()}',
        address: _addressCtrl.text.trim(),
      ),
    );
    await AuthSession.saveFarmerPassword(_passwordCtrl.text);
    await AgriProductRepository.instance.recordFarmerRegistration(
      email: _emailCtrl.text.trim(),
      fullName: _nameCtrl.text.trim(),
      phone: '${_country.dial} ${_phoneCtrl.text.trim()}',
      address: _addressCtrl.text.trim(),
    );
    await AuthController.instance.loginAsFarmer(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account ready. You are signed in.')),
    );
    Navigator.of(context).maybePop();
  }

  Future<void> _fillAddressFromGps() async {
    setState(() => _locatingAddress = true);
    try {
      final addr = await DeliveryLocationService.getCurrentAddress();
      if (!mounted) return;
      if (addr == null || addr.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not read your location. Turn on GPS, allow location permission, '
              'and try again.',
            ),
          ),
        );
        return;
      }
      setState(() => _addressCtrl.text = addr);
    } finally {
      if (mounted) setState(() => _locatingAddress = false);
    }
  }

  Future<void> _openMapPicker() async {
    final center = await DeliveryLocationService.initialMapCenter();
    if (!mounted) return;
    final pin = await DeliveryLocationService.getCurrentLatLng();
    if (!mounted) return;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => AddressMapPickerScreen(
          initialCenter: center,
          initialPin: pin,
        ),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() => _addressCtrl.text = result);
    }
  }

  Future<void> _openGoogleMapsForAddress() async {
    final q = _addressCtrl.text.trim();
    final ok = await DeliveryLocationService.openGoogleMapsSearch(
      q.isEmpty ? null : q,
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: Brightness.light,
    );

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.primary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create your farmer profile',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: scheme.primary.withValues(alpha: 0.75),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          hintText: 'Your name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 2) {
                            return 'Enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Country',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(_countries.length, (i) {
                          final c = _countries[i];
                          final selected = i == _countryIndex;
                          return FilterChip(
                            label: Text('${c.label} ${c.dial} ${c.name}'),
                            selected: selected,
                            onSelected: (_) => setState(() => _countryIndex = i),
                            showCheckmark: false,
                            selectedColor: scheme.primary,
                            labelStyle: TextStyle(
                              color: selected ? scheme.onPrimary : scheme.onSurface,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 13,
                            ),
                            side: BorderSide(
                              color: selected ? scheme.primary : scheme.outlineVariant,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                        ],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Mobile number (${_country.dial})',
                          hintText: '10-digit number',
                          prefixIcon: const Icon(Icons.smartphone_outlined),
                        ),
                        validator: (v) {
                          final digits = RegExp(r'\d').allMatches(v ?? '').length;
                          if (digits < 8) return 'Enter a valid mobile number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Delivery address',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _locatingAddress ? null : _fillAddressFromGps,
                            icon: _locatingAddress
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: scheme.primary,
                                    ),
                                  )
                                : const Icon(Icons.my_location_outlined, size: 20),
                            label: const Text('Use current location'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _locatingAddress ? null : _openMapPicker,
                            icon: const Icon(Icons.map_outlined, size: 20),
                            label: const Text('Select on map'),
                          ),
                          TextButton.icon(
                            onPressed: _openGoogleMapsForAddress,
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('Open in Google Maps'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressCtrl,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.newline,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Address details',
                          hintText: 'Plot, street, village, district, state, PIN',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.home_work_outlined),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().length < 12) {
                            return 'Enter your full delivery address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: (v) {
                          if (v == null || !v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'At least 8 characters',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 8) {
                            return 'Use at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Material(
              elevation: 8,
              shadowColor: Colors.black26,
              color: Theme.of(context).colorScheme.surface,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            elevation: 0,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Create account'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
