import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data saved when the farmer completes registration (used on checkout, etc.).
class FarmerProfile {
  const FarmerProfile({
    required this.fullName,
    required this.email,
    required this.phoneDisplay,
    required this.address,
  });

  final String fullName;
  final String email;
  final String phoneDisplay;
  final String address;

  static const FarmerProfile empty = FarmerProfile(
    fullName: '',
    email: '',
    phoneDisplay: '',
    address: '',
  );

  /// Trimmed full name from registration — use this everywhere for display.
  String get displayName {
    final t = fullName.trim();
    return t.isEmpty ? '' : t;
  }

  bool get hasDeliveryDetails =>
      fullName.isNotEmpty && phoneDisplay.isNotEmpty && address.isNotEmpty;
}

/// In-memory profile synced with [FarmerProfileStorage]. Listen on UI that shows the farmer name.
class FarmerProfileController extends ChangeNotifier {
  FarmerProfileController._();
  static final FarmerProfileController instance = FarmerProfileController._();

  FarmerProfile profile = FarmerProfile.empty;

  Future<void> refresh() async {
    final next = await FarmerProfileStorage.load();
    profile = next;
    notifyListeners();
  }

  void applySaved(FarmerProfile saved) {
    profile = saved;
    notifyListeners();
  }
}

class FarmerProfileStorage {
  FarmerProfileStorage._();

  static const _kName = 'farmer_profile_name';
  static const _kEmail = 'farmer_profile_email';
  static const _kPhone = 'farmer_profile_phone';
  static const _kAddress = 'farmer_profile_address';

  static Future<FarmerProfile> load() async {
    final p = await SharedPreferences.getInstance();
    return FarmerProfile(
      fullName: (p.getString(_kName) ?? '').trim(),
      email: (p.getString(_kEmail) ?? '').trim(),
      phoneDisplay: (p.getString(_kPhone) ?? '').trim(),
      address: (p.getString(_kAddress) ?? '').trim(),
    );
  }

  static Future<void> save(FarmerProfile profile) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, profile.fullName);
    await p.setString(_kEmail, profile.email);
    await p.setString(_kPhone, profile.phoneDisplay);
    await p.setString(_kAddress, profile.address);
    FarmerProfileController.instance.applySaved(profile);
  }
}
