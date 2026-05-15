import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'agri_cached_product_image.dart';

import 'auth_controller.dart';
import 'farmer_register_screen.dart';
import 'language_picker_sheet.dart';
import 'l10n/app_localizations.dart';

/// AgriSmart welcome + sign-in (opens before the main shell).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  static const _heroUrl =
      'https://commons.wikimedia.org/wiki/Special:FilePath/Rice_p1160004_cropped.jpg';

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _canFarmerLogin =>
      _emailCtrl.text.trim().isNotEmpty && _passwordCtrl.text.isNotEmpty;

  Future<void> _farmerLogin() async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await AuthController.instance.loginAsFarmer(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showAdminDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => const _AdminLoginDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1B5E20),
      brightness: Brightness.light,
    );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              elevation: 0,
              backgroundColor: scheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: _heroUrl,
                      httpHeaders: AgriCachedProductImage.kImageHttpHeaders,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      placeholder: (_, __) => ColoredBox(
                        color: scheme.primaryContainer,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: scheme.primaryContainer,
                        child: Icon(Icons.agriculture, size: 72, color: scheme.primary),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.15),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.eco, color: Colors.white, size: 32),
                              const SizedBox(width: 10),
                              Text(
                                l10n.landingBrand,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.landingWelcome,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: Material(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                l10n.landingFarmerSignIn,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => showLanguagePicker(context),
                              child: Text(l10n.languageTitle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.landingFarmerSignInHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.landingGoogleSnack),
                              ),
                            );
                          },
                          icon: const Icon(Icons.mail_outline),
                          label: Text(l10n.landingGmail),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: scheme.primary, width: 1.4),
                            foregroundColor: scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: scheme.outlineVariant)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                l10n.landingOrEmail,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: scheme.outlineVariant)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: l10n.landingEmail,
                            hintText: l10n.landingEmailHint,
                            prefixIcon: const Icon(Icons.mail_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (_canFarmerLogin) _farmerLogin();
                          },
                          decoration: InputDecoration(
                            labelText: l10n.landingPassword,
                            hintText: l10n.landingPasswordHint,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton(
                          onPressed: (!_canFarmerLogin || _busy) ? null : _farmerLogin,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.landingLogin),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (_) => const FarmerRegisterScreen(),
                              ),
                            );
                            if (!context.mounted) return;
                            await AuthController.instance.restoreSession();
                          },
                          icon: const Icon(Icons.person_add_alt_1_outlined),
                          label: Text(l10n.landingCreateAccount),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.landingNewUserHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Divider(color: scheme.outlineVariant),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _showAdminDialog,
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: Text(l10n.landingAdminLogin),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.landingAdminDemoHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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

class _AdminLoginDialog extends StatefulWidget {
  const _AdminLoginDialog();

  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog> {
  final _email = TextEditingController(text: 'admin@agrismart.com');
  final _password = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await AuthController.instance.loginAsAdmin(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (mounted) Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Administrator sign-in'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Admin email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Sign in'),
        ),
      ],
    );
  }
}
