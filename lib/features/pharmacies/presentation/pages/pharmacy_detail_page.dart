import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/medicine_ui.dart';
import '../../../../core/utils/phone.dart';
import '../../domain/entities/opening_hours.dart';
import '../../domain/entities/pharmacy.dart';
import '../formatters/opening_hours_labels.dart';
import '../providers/pharmacy_provider.dart';
import '../widgets/status_badge.dart';

/// Fiche détaillée d'une pharmacie.
class PharmacyDetailPage extends ConsumerWidget {
  const PharmacyDetailPage({required this.pharmacyId, super.key});

  final String pharmacyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Pharmacy> pharmacy = ref.watch(
      pharmacyByIdProvider(pharmacyId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Détails pharmacie')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: pharmacy.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object error, StackTrace stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  error is Failure
                      ? error.message
                      : 'Impossible de charger cette pharmacie.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            data: (Pharmacy found) => _DetailBody(pharmacy: found),
          ),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.pharmacy});

  final Pharmacy pharmacy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BrandColors brand = context.brand;
    final DateTime moment = DateTime.now();
    final OpeningHours? hours = pharmacy.openingHours;
    final String? address = pharmacy.address;
    final String? secondaryPhone = pharmacy.secondaryPhone;
    final String? email = pharmacy.email;
    final DateTime? updatedAt = pharmacy.updatedAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: <Widget>[
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            if (pharmacy.isOnDutyAt(moment))
              const StatusBadge(label: 'De garde', filled: true),
            if (hours != null)
              StatusBadge(
                label: openStatusLabel(hours, moment),
                muted: !hours.isOpenAt(moment),
              ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: <Widget>[
            Expanded(
              child: Text(pharmacy.name, style: theme.textTheme.headlineSmall),
            ),
            if (pharmacy.verifiedByPharmacy)
              Icon(Icons.verified, color: theme.colorScheme.primary),
          ],
        ),

        const SizedBox(height: 4),

        Text(
          address == null ? pharmacy.district : '$address · ${pharmacy.district}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: () => launchPhoneCall(pharmacy.phone),
                icon: const Icon(Icons.call, size: 18),
                label: const Text('Appeler'),
                style: FilledButton.styleFrom(
                  backgroundColor: brand.call,
                  foregroundColor: brand.onCall,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () =>
                    context.push('/map?pharmacyId=${pharmacy.id}'),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Itinéraire'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        _Section(
          icon: Icons.contact_phone_outlined,
          title: 'Contact',
          children: <Widget>[
            _ContactRow(
              icon: Icons.call_outlined,
              label: 'Téléphone',
              value: pharmacy.phone,
              onTap: () => launchPhoneCall(pharmacy.phone),
            ),
            if (secondaryPhone != null)
              _ContactRow(
                icon: Icons.call_outlined,
                label: 'Autre numéro',
                value: secondaryPhone,
                onTap: () => launchPhoneCall(secondaryPhone),
              ),
            if (email != null)
              _ContactRow(
                icon: Icons.mail_outline,
                label: 'E-mail',
                value: email,
              ),
          ],
        ),

        if (hours != null) ...<Widget>[
          const SizedBox(height: 14),
          _Section(
            icon: Icons.schedule_outlined,
            title: "Horaires d'ouverture",
            children: <Widget>[
              for (int weekday = DateTime.monday;
                  weekday <= DateTime.sunday;
                  weekday++)
                _ScheduleRow(
                  day: weekdayNames[weekday - 1],
                  label: scheduleLabel(hours.scheduleFor(weekday)),
                  isToday: weekday == moment.weekday,
                ),
            ],
          ),
        ],

        if (updatedAt != null) ...<Widget>[
          const SizedBox(height: 18),
          Text(
            'Fiche mise à jour ${timeAgo(moment.isAfter(updatedAt) ? moment.difference(updatedAt) : Duration.zero)}',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Bloc blanc à en-tête, comme les sections de la maquette.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: theme.colorScheme.secondary),
              const SizedBox(width: 8),
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: theme.colorScheme.secondary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: theme.textTheme.bodySmall),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.day,
    required this.label,
    required this.isToday,
  });

  final String day;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = isToday
        ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(day, style: style)),
          Text(label, style: style),
        ],
      ),
    );
  }
}