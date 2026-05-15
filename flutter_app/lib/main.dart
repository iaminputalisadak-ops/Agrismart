import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'agri_product_repository.dart';
import 'auth_controller.dart';
import 'auth_gate.dart';
import 'camera_holder.dart';
import 'farmer_profile_storage.dart';
import 'l10n/app_localizations.dart';
import 'locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FarmerProfileController.instance.refresh();
  await AgriProductRepository.instance.open();
  await AuthController.instance.restoreSession();
  await LocaleController.instance.load();
  try {
    appCameras = await availableCameras();
  } catch (e) {
    appCameras = const [];
    debugPrint('Failed to enumerate cameras: $e');
  }
  runApp(const InsectCropApp());
}

class InsectCropApp extends StatelessWidget {
  const InsectCropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'AgriSmart',
          debugShowCheckedModeBanner: false,
          locale: LocaleController.instance.locale,
          supportedLocales: LocaleController.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.light,
            ),
          ),
          home: const AuthGate(),
        );
      },
    );
  }
}
