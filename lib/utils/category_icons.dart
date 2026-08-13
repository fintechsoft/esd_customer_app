import 'package:flutter/material.dart';

/// Your `cat` table only has id/name — no icon or image column — so we map
/// a reasonable icon by keyword. Falls back to a generic appliance icon for
/// anything unmatched (new categories added later won't break the UI).
IconData iconForCategory(String name) {
  final n = name.toUpperCase();

  if (n.contains('TV')) return Icons.tv_rounded;
  if (n.contains('AC ') || n.contains('AC') || n.contains('COOLER')) return Icons.ac_unit_rounded;
  if (n.contains('FRIDGE') || n.contains('REFRIGERATOR')) return Icons.kitchen_rounded;
  if (n.contains('WATER PURIFIER')) return Icons.water_drop_rounded;
  if (n.contains('MICROWAVE') || n.contains('OVEN')) return Icons.microwave_rounded;
  if (n.contains('HEATER') || n.contains('GEYSER')) return Icons.local_fire_department_rounded;
  if (n.contains('AUDIO')) return Icons.speaker_rounded;
  if (n.contains('DISHWASHER')) return Icons.local_dining_rounded;
  if (n.contains('WASHING MACHINE')) return Icons.local_laundry_service_rounded;
  if (n.contains('KITCHEN')) return Icons.blender_rounded;
  if (n.contains('IRON')) return Icons.iron_rounded;
  if (n.contains('DISPENSER')) return Icons.water_rounded;
  if (n.contains('PERSONAL CARE')) return Icons.spa_rounded;
  if (n.contains('GARMENT STEAMER')) return Icons.dry_cleaning_rounded;
  if (n.contains('STABILISER') || n.contains('INVERTER')) return Icons.bolt_rounded;
  if (n.contains('PHONE')) return Icons.smartphone_rounded;
  if (n.contains('LAPTOP')) return Icons.laptop_mac_rounded;
  if (n.contains('CHIMNEY')) return Icons.whatshot_rounded;

  return Icons.category_rounded;
}