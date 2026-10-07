import 'package:find_pharma/features/map/domain/entities/map_pharmacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'pharmacy_summary.dart';

/// Screen-space grouping avoids offsetting real coordinates. A group opens a
/// chooser, including at maximum zoom when coordinates are exactly identical.
class PharmacyMarkers extends StatelessWidget {
  const PharmacyMarkers({
    super.key,
    required this.pharmacies,
    required this.selectedId,
    required this.onChoose,
  });
  final List<MapPharmacy> pharmacies;
  final String? selectedId;
  final ValueChanged<List<MapPharmacy>> onChoose;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final groups = <List<MapPharmacy>>[];
    for (final pharmacy in pharmacies) {
      final point = camera.projectAtZoom(pharmacy.point);
      List<MapPharmacy>? nearby;
      for (final group in groups) {
        if ((camera.projectAtZoom(group.first.point) - point).distance < 56) {
          nearby = group;
          break;
        }
      }
      if (nearby == null) {
        groups.add([pharmacy]);
      } else {
        nearby.add(pharmacy);
      }
    }
    return MarkerLayer(
      markers: groups.map((group) {
        final pharmacy = group.first;
        final selected = group.any((p) => p.id == selectedId);
        final label = group.length > 1
            ? '${group.length} pharmacies${selected ? ', sélection incluse' : ''}'
            : '${pharmacy.name}, ${openingLabel(pharmacy.opening)}${selected ? ', sélectionnée' : ''}';
        return Marker(
          point: pharmacy.point,
          width: 52,
          height: 52,
          child: Semantics(
            button: true,
            label: label,
            selected: selected,
            child: Tooltip(
              message: label,
              child: Material(
                color: selected
                    ? Colors.indigo.shade700
                    : group.length > 1
                    ? Colors.grey.shade800
                    : openingColor(pharmacy.opening),
                shape: CircleBorder(
                  side: BorderSide(
                    color: Colors.white,
                    width: selected ? 4 : 2,
                  ),
                ),
                elevation: 3,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onChoose(group),
                  child: Center(
                    child: group.length > 1
                        ? Text(
                            '${group.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Icon(
                            selected
                                ? Icons.check_circle
                                : openingIcon(pharmacy.opening),
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
