import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';

/// Display helpers for exercises when weapon/ammo may be:
/// - an inventory item (id exists)
/// - borrowed (id == 'borrowed')
/// - none (id == 'none')
String weaponDisplayName(ThotProvider provider, Exercise ex) {
  if (ex.weaponId == 'none') return 'Aucune arme';
  if (ex.weaponId == 'borrowed') {
    final label = (ex.weaponLabel ?? '').trim();
    return label.isEmpty ? 'Arme prêtée' : 'Arme prêtée — $label';
  }
  return provider.getWeaponById(ex.weaponId)?.name ?? 'Arme inconnue';
}

String ammoDisplayName(ThotProvider provider, Exercise ex) {
  if (ex.ammoId == 'none') return 'Aucune munition';
  if (ex.ammoId == 'borrowed') {
    final label = (ex.ammoLabel ?? '').trim();
    return label.isEmpty ? 'Munition prêtée' : 'Munition prêtée — $label';
  }
  return provider.getAmmoById(ex.ammoId)?.name ?? 'Munition inconnue';
}
