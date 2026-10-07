import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/medicine_ui.dart';
import '../../../../core/utils/phone.dart';
import '../../domain/entities/opening_hours.dart';
import '../../domain/entities/pharmacy.dart';
import '../formatters/opening_hours_labels.dart';

/// Carte d'une pharmacie, d'après la maquette.
///
/// Trois écrans l'utilisent : la liste, la garde et les résultats de recherche.
class PharmacyCard extends StatelessWidget {
  const PharmacyCard({
    required this.pharmacy,
    this.distanceKm,
    this.onTap,
    this.onDirections,
    this.now,
    super.key,
  });

  final Pharmacy pharmacy;

  /// Distance depuis l'utilisateur, `null` si la position est inconnue.
  final double? distanceKm;

  final VoidCallback? onTap;

  /// Sans callback, le bouton Itinéraire disparaît : la carte ne connaît pas
  /// les routes de l'application, c'est la page qui les lui donne.
  final VoidCallback? onDirections;

  /// Injectable pour les tests, faute de quoi l'heure courante.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BrandColors brand = context.brand;
    final DateTime moment = now ?? DateTime.now();
    final double? distance = distanceKm;
    final DateTime? updatedAt = pharmacy.updatedAt;
    final VoidCallback? directions = onDirections;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _statusBadges(moment),
                    ),
                  ),
                  if (distance != null) ...<Widget>[
                    const SizedBox(width: 8),
                    Text(
                      formatDistance(distance),
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      pharmacy.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (pharmacy.verifiedByPharmacy) ...<Widget>[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 2),

              Text(
                pharmacy.address ?? pharmacy.district,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (updatedAt != null) ...<Widget>[
                const SizedBox(height: 10),
                _FreshnessStrip(updatedAt: updatedAt, moment: moment),
              ],

              const SizedBox(height: 12),

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
                  if (directions != null) ...<Widget>[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: directions,
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Itinéraire'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _statusBadges(DateTime moment) {
    final List<Widget> badges = <Widget>[];

    if (pharmacy.isOnDutyAt(moment)) {
      badges.add(const StatusBadge(label: 'De garde', filled: true));
    }

    final OpeningHours? hours = pharmacy.openingHours;
    if (hours == null) {
      // Horaires inconnus : aucune pastille. Ne pas savoir n'est pas être fermé.
      return badges;
    }

    final DaySchedule today = hours.scheduleFor(moment.weekday);
    badges.add(
      StatusBadge(
        label: openStatusLabel(hours, moment),
        muted: !hours.isOpenAt(moment) && today is! AllDayOpen,
      ),
    );

    return badges;

  }

}

/// Pastille d'état : pleine pour la garde, discrète pour l'ouverture.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.filled = false, this.muted = false});

  final String label;
  final bool filled;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color dot = filled
        ? theme.colorScheme.onPrimary
        : (muted ? theme.colorScheme.outline : theme.colorScheme.secondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? theme.colorScheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: filled ? null : Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: filled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bandeau de fraîcheur : depuis quand la fiche n'a pas bougé.
class _FreshnessStrip extends StatelessWidget {
  const _FreshnessStrip({required this.updatedAt, required this.moment});

  final DateTime updatedAt;
  final DateTime moment;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // Une horloge serveur en avance ne doit pas produire « il y a -3 min ».
    final Duration since = moment.isAfter(updatedAt)
        ? moment.difference(updatedAt)
        : Duration.zero;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.brand.band,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            size: 15,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Fiche à jour', style: theme.textTheme.bodySmall),
          ),
          Text(timeAgo(since), style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}