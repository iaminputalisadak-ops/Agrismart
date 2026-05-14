import 'package:flutter/material.dart';

import 'agri_cart.dart';
import 'farmer_profile_storage.dart';
import 'farmer_register_screen.dart';

enum _AgriPayment { card, cod }

typedef _CheckoutPayRow = ({_AgriPayment value, String title, IconData icon});

const List<_CheckoutPayRow> _kCheckoutPaymentRows = <_CheckoutPayRow>[
  (value: _AgriPayment.card, title: 'Credit / Debit card', icon: Icons.credit_card),
  (value: _AgriPayment.cod, title: 'Cash on Delivery', icon: Icons.payments_outlined),
];

/// Checkout: delivery from saved farmer profile, cart totals. Payments: card + COD only.
class AgriCheckoutScreen extends StatefulWidget {
  const AgriCheckoutScreen({super.key});

  @override
  State<AgriCheckoutScreen> createState() => _AgriCheckoutScreenState();
}

class _AgriCheckoutScreenState extends State<AgriCheckoutScreen> {
  _AgriPayment _payment = _AgriPayment.card;

  @override
  void initState() {
    super.initState();
    FarmerProfileController.instance.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: ListenableBuilder(
        listenable: AgriCart.instance,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: FarmerProfileController.instance,
            builder: (context, __) {
              final profile = FarmerProfileController.instance.profile;
              final subtotal = AgriCart.instance.subtotalInr;
              const delivery = 0;
              const discount = 0;
              final total = subtotal + delivery - discount;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                children: [
                  Text('Delivery address', style: d.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _AddressCard(
                    profile: profile,
                    scheme: scheme,
                    onEditProfile: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(builder: (_) => const FarmerRegisterScreen()),
                      );
                      await FarmerProfileController.instance.refresh();
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Payment method', style: d.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ..._kCheckoutPaymentRows.map(
                    (row) => Padding(
                      padding: EdgeInsets.only(
                        bottom: row.value == _AgriPayment.cod ? 0 : 8,
                      ),
                      child: _PaymentTile(
                        title: row.title,
                        icon: row.icon,
                        value: row.value,
                        groupValue: _payment,
                        scheme: scheme,
                        onSelect: () => setState(() => _payment = row.value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _summaryRow('Subtotal', '₹$subtotal', d),
                          _summaryRow('Delivery', '₹$delivery', d),
                          _summaryRow('Discount', '₹$discount', d),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: d.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                '₹$total',
                                style: d.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: Listenable.merge([AgriCart.instance, FarmerProfileController.instance]),
        builder: (context, _) {
          final empty = AgriCart.instance.lines.isEmpty;
          final subtotal = AgriCart.instance.subtotalInr;
          final profile = FarmerProfileController.instance.profile;
          return Material(
            elevation: 8,
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: FilledButton.icon(
                  onPressed: empty
                      ? null
                      : () {
                          if (!profile.hasDeliveryDetails) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Add your delivery address in Register or My account before placing an order.',
                                ),
                                action: SnackBarAction(
                                  label: 'Register',
                                  onPressed: () async {
                                    await Navigator.of(context).push<void>(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const FarmerRegisterScreen(),
                                      ),
                                    );
                                    await FarmerProfileController.instance.refresh();
                                  },
                                ),
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Order placed (demo). ${_payment == _AgriPayment.cod ? 'COD' : 'Card'} · ₹$subtotal',
                              ),
                            ),
                          );
                          AgriCart.instance.clear();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Place order'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _summaryRow(String label, String value, TextTheme d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: d.bodyLarge),
          Text(value, style: d.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.profile,
    required this.scheme,
    required this.onEditProfile,
  });

  final FarmerProfile profile;
  final ColorScheme scheme;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).textTheme;
    final has = profile.hasDeliveryDetails;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: has ? scheme.primaryContainer.withValues(alpha: 0.25) : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: has ? scheme.primary.withValues(alpha: 0.4) : scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, color: scheme.primary, size: 22),
            const SizedBox(width: 6),
            Icon(Icons.location_on_outlined, color: scheme.primary, size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (has) ...[
                    Text(
                      profile.displayName,
                      style: d.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(profile.address, style: d.bodyMedium?.copyWith(height: 1.35)),
                    const SizedBox(height: 8),
                    Text('Phone: ${profile.phoneDisplay}', style: d.bodySmall),
                  ] else ...[
                    Text(
                      'No saved address',
                      style: d.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Use My account or Register to save the name, phone, and address from your registration.',
                      style: d.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: onEditProfile, child: Text(has ? 'Edit' : 'Register')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.scheme,
    required this.onSelect,
  });

  final String title;
  final IconData icon;
  final _AgriPayment value;
  final _AgriPayment groupValue;
  final ColorScheme scheme;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.35) : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? scheme.primary : scheme.outline,
              ),
              const SizedBox(width: 8),
              Icon(icon, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall)),
            ],
          ),
        ),
      ),
    );
  }
}
