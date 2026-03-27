import 'package:thot/data/thot_provider.dart';

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String tier; // bronze | silver | gold
  final int target;
  final int Function(ThotProvider provider) progress;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.tier,
    required this.target,
    required this.progress,
  });
}

int perfectSessionsCount(ThotProvider provider) {
  return provider.sessions
      .where((s) => s.hasCountedPrecision && s.averagePrecision >= 100)
      .length;
}

int countedPrecisionSessionsCount(ThotProvider provider) {
  return provider.sessions.where((s) => s.hasCountedPrecision).length;
}

int historyCount(ThotProvider provider, String type) {
  return provider.weapons
      .expand((w) => w.history)
      .where((h) => h.type == type)
      .length;
}

int totalWeaponHistoryEntries(ThotProvider provider) {
  return provider.weapons.expand((w) => w.history).length;
}

final List<AchievementDefinition> achievementDefinitions = [
  AchievementDefinition(id: 'first_session', title: 'Première séance', description: 'Créez votre première séance de tir.', tier: 'bronze', target: 1, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'five_sessions', title: 'Échauffement', description: 'Complétez 5 séances de tir.', tier: 'bronze', target: 5, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'ten_sessions', title: 'Tireur assidu', description: 'Complétez 10 séances de tir.', tier: 'bronze', target: 10, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'twenty_five_sessions', title: 'Régulier', description: 'Atteignez les 25 séances documentées.', tier: 'silver', target: 25, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'fifty_sessions', title: 'Habitué du stand', description: 'Complétez 50 séances de tir.', tier: 'silver', target: 50, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'hundred_sessions', title: 'Centurion', description: 'Célébrez votre 100e séance de tir.', tier: 'gold', target: 100, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'two_hundred_sessions', title: 'Pilier du carnet', description: 'Enregistrez 200 séances de tir.', tier: 'gold', target: 200, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'thousand_sessions', title: 'Légende du pas de tir', description: 'Passez le cap mythique des 1000 séances.', tier: 'gold', target: 1000, progress: (p) => p.sessions.length),

  AchievementDefinition(id: 'first_weapon', title: 'Première arme', description: 'Ajoutez une première arme à votre râtelier.', tier: 'bronze', target: 1, progress: (p) => p.weapons.length),
  AchievementDefinition(id: 'three_weapons', title: 'Petit arsenal', description: 'Possédez 3 armes dans votre inventaire.', tier: 'bronze', target: 3, progress: (p) => p.weapons.length),
  AchievementDefinition(id: 'five_weapons', title: 'Équipé', description: 'Montez votre inventaire à 5 armes.', tier: 'silver', target: 5, progress: (p) => p.weapons.length),
  AchievementDefinition(id: 'ten_weapons', title: 'Le collectionneur', description: 'Gérez 10 armes dans votre râtelier.', tier: 'gold', target: 10, progress: (p) => p.weapons.length),

  AchievementDefinition(id: 'first_ammo', title: 'Première munition', description: 'Ajoutez votre première référence de munition.', tier: 'bronze', target: 1, progress: (p) => p.ammos.length),
  AchievementDefinition(id: 'three_ammos', title: 'Approvisionné', description: 'Enregistrez 3 références de munitions.', tier: 'bronze', target: 3, progress: (p) => p.ammos.length),
  AchievementDefinition(id: 'ten_ammos', title: 'Réserve sérieuse', description: 'Variété absolue : 10 références de munitions différentes.', tier: 'silver', target: 10, progress: (p) => p.ammos.length),

  AchievementDefinition(id: 'first_accessory', title: 'Premier accessoire', description: 'Ajoutez un accessoire à votre inventaire.', tier: 'bronze', target: 1, progress: (p) => p.accessories.length),
  AchievementDefinition(id: 'three_accessories', title: 'Bien équipé', description: 'Possédez 3 accessoires différents.', tier: 'bronze', target: 3, progress: (p) => p.accessories.length),
  AchievementDefinition(id: 'ten_accessories', title: 'Configuration complète', description: 'Gérez 10 accessoires pour vos tirs.', tier: 'silver', target: 10, progress: (p) => p.accessories.length),

  AchievementDefinition(id: 'first_precision_session', title: 'Première précision mesurée', description: 'Scorez au moins une séance avec la précision activée.', tier: 'bronze', target: 1, progress: countedPrecisionSessionsCount),
  AchievementDefinition(id: 'ten_precision_sessions', title: 'Œil affûté', description: 'Enregistrez 10 séances avec calcul de précision.', tier: 'silver', target: 10, progress: countedPrecisionSessionsCount),
  AchievementDefinition(id: 'fifty_precision_sessions', title: 'Analyseur confirmé', description: 'Mesurez votre précision sur 50 séances.', tier: 'gold', target: 50, progress: countedPrecisionSessionsCount),

  AchievementDefinition(id: 'first_perfect_session', title: 'Tir parfait', description: 'Réalisez un score de 100% de précision sur une séance.', tier: 'bronze', target: 1, progress: perfectSessionsCount),
  AchievementDefinition(id: 'three_perfect_sessions', title: 'Zéro défaut', description: 'Atteignez les 100% de précision lors de 3 séances.', tier: 'silver', target: 3, progress: perfectSessionsCount),
  AchievementDefinition(id: 'ten_perfect_sessions', title: 'Maître de précision', description: 'Conservez une précision parfaite (100%) sur 10 séances.', tier: 'gold', target: 10, progress: perfectSessionsCount),

  AchievementDefinition(id: 'first_cleaning', title: 'Premier entretien', description: 'Renseignez un nettoyage d\'arme complet.', tier: 'bronze', target: 1, progress: (p) => historyCount(p, 'entretien')),
  AchievementDefinition(id: 'five_cleanings', title: 'Soigneux', description: 'Effectuez 5 nettoyages consignés dans l\'historique.', tier: 'bronze', target: 5, progress: (p) => historyCount(p, 'entretien')),
  AchievementDefinition(id: 'ten_cleanings', title: 'Intendant', description: 'Maintenez vos armes propres avec 10 entretiens.', tier: 'silver', target: 10, progress: (p) => historyCount(p, 'entretien')),
  AchievementDefinition(id: 'fifty_cleanings', title: 'Maniaque mécanique', description: 'Un soin exceptionnel : 50 entretiens documentés.', tier: 'gold', target: 50, progress: (p) => historyCount(p, 'entretien')),

  AchievementDefinition(id: 'first_revision', title: 'Première révision', description: 'Cochez votre première révision de pièce chez l\'armurier.', tier: 'bronze', target: 1, progress: (p) => historyCount(p, 'revision')),
  AchievementDefinition(id: 'five_revisions', title: 'Maintenance sérieuse', description: 'Effectuez 5 révisions majeures sur vos armes.', tier: 'silver', target: 5, progress: (p) => historyCount(p, 'revision')),
  AchievementDefinition(id: 'ten_revisions', title: 'Armurier', description: 'Assurez la sécurité de vos armes via 10 révisions.', tier: 'gold', target: 10, progress: (p) => historyCount(p, 'revision')),

  AchievementDefinition(id: 'hundred_rounds', title: '100 coups', description: 'Atteignez les 100 coups tirés au total.', tier: 'bronze', target: 100, progress: (p) => p.totalRoundsFired),
  AchievementDefinition(id: 'thousand_rounds', title: '1 000 coups', description: 'Faites parler la poudre avec 1 000 coups tirés.', tier: 'silver', target: 1000, progress: (p) => p.totalRoundsFired),
  AchievementDefinition(id: 'five_thousand_rounds', title: '5 000 coups', description: 'Une étape majeure : 5 000 coups cumulés.', tier: 'gold', target: 5000, progress: (p) => p.totalRoundsFired),
  AchievementDefinition(id: 'ten_thousand_rounds', title: '10 000 coups', description: 'Le statut de vétéran, 10 000 coups tirés enregistrés.', tier: 'gold', target: 10000, progress: (p) => p.totalRoundsFired),

  AchievementDefinition(id: 'history_started', title: 'Carnet vivant', description: 'Alimentez l\'historique détaillé de votre matériel 10 fois.', tier: 'bronze', target: 10, progress: totalWeaponHistoryEntries),
  AchievementDefinition(id: 'history_extended', title: 'Historique riche', description: 'Créez 50 entrées dans les historiques matériels.', tier: 'silver', target: 50, progress: totalWeaponHistoryEntries),
  AchievementDefinition(id: 'history_master', title: 'Mémoire d’armurerie', description: 'Un suivi exemplaire avec 100 événements d\'historique.', tier: 'gold', target: 100, progress: totalWeaponHistoryEntries),

  AchievementDefinition(id: 'session_editor', title: 'Perfectionniste', description: 'Créez ou modifiez 20 séances différentes.', tier: 'bronze', target: 20, progress: (p) => p.sessions.length),
  AchievementDefinition(id: 'data_builder', title: 'Architecte de données', description: 'Regroupez 20 éléments dans votre inventaire total.', tier: 'silver', target: 20, progress: (p) => p.weapons.length + p.ammos.length + p.accessories.length),
  AchievementDefinition(id: 'full_ecosystem', title: 'Écosystème complet', description: 'Vivez avec THOT : 40 matériels différents répertoriés.', tier: 'gold', target: 40, progress: (p) => p.weapons.length + p.ammos.length + p.accessories.length),
];

int unlockedAchievementsCount(ThotProvider provider) {
  return achievementDefinitions
      .where((a) => a.progress(provider) >= a.target)
      .length;
}

String nextAchievementRemaining(ThotProvider provider) {
  final pending = achievementDefinitions
      .where((a) => a.progress(provider) < a.target)
      .toList();

  if (pending.isEmpty) return '0';

  pending.sort((a, b) {
    final ra = a.target - a.progress(provider);
    final rb = b.target - b.progress(provider);
    return ra.compareTo(rb);
  });

  final next = pending.first;
  return (next.target - next.progress(provider)).toString();
}