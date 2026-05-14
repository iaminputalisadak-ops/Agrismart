import 'package:flutter/material.dart';

import 'auth_controller.dart';
import 'landing_screen.dart';
import 'main_app_shell.dart';

/// Shows [LandingScreen] until the user authenticates, then [MainAppShell].
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: AuthController.instance.isAuthenticated
              ? const MainAppShell(key: ValueKey('app'))
              : const LandingScreen(key: ValueKey('auth')),
        );
      },
    );
  }
}
