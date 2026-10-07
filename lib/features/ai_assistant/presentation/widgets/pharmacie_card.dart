import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/pharmacy_actions.dart';

class PharmacyCardWidget extends StatelessWidget {
  final String name;
  final String district;
  final String phone;
  final String? pharmacyId;

  const PharmacyCardWidget({
    super.key,
    required this.name,
    required this.district,
    required this.phone,
    this.pharmacyId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text("Quartier : $district • Téléphone : $phone"),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: phone.trim().isEmpty
                    ? null
                    : () => callPharmacy(context, phone),
                icon: const Icon(Icons.phone),
                label: const Text("Appeler"),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: pharmacyId == null
                    ? null
                    : () => context.push(
                        Uri(
                          path: '/map',
                          queryParameters: {'pharmacyId': pharmacyId!},
                        ).toString(),
                      ),
                icon: const Icon(Icons.directions),
                label: const Text("Itinéraire"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
