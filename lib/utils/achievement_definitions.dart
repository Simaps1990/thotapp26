import 'package:thot/data/thot_provider.dart';
import 'package:thot/data/training_history.dart';

class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String tier; // bronze | silver | gold
  final int target;
  final int Function(ThotProvider provider) progress;

  String get category {
    if (id.contains('precision') || id.contains('perfect')) return 'precision';
    if (id.contains('reflex')) return 'speed';
    if (id.contains('cleaning') || id.contains('revision'))
      return 'maintenance';
    if (id.contains('history')) return 'diagnostic';
    if (id.contains('platform') ||
        id.contains('ammo') ||
        id.contains('accessory') ||
        id.contains('ecosystem') ||
        id.contains('data_builder') ||
        id.contains('round')) {
      return 'tools';
    }
    return 'regularity';
  }

  String get rarity {
    if (target >= 500 ||
        id.contains('thousand') ||
        id.contains('ten_thousand')) {
      return 'elite';
    }
    if (tier == 'gold') return 'expert';
    if (tier == 'silver') return 'advanced';
    return 'common';
  }

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
  return provider.platforms
      .expand((w) => w.history)
      .where((h) => h.type == type)
      .length;
}

int totalPlatformHistoryEntries(ThotProvider provider) {
  return provider.platforms.expand((w) => w.history).length;
}

final List<AchievementDefinition> achievementDefinitions = [
  AchievementDefinition(
    id: 'first_session',
    title: 'Première session',
    description: 'Créez votre toute première session.',
    tier: 'bronze',
    target: 1,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'five_sessions',
    title: 'Échauffement',
    description: 'Complétez 5 sessions.',
    tier: 'bronze',
    target: 5,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'ten_sessions',
    title: 'Opérationnel',
    description: 'Complétez 10 sessions.',
    tier: 'bronze',
    target: 10,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'twenty_five_sessions',
    title: 'Régulier',
    description: 'Atteignez les 25 sessions documentées.',
    tier: 'silver',
    target: 25,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'fifty_sessions',
    title: 'Valeur sûre',
    description: 'Complétez 50 sessions.',
    tier: 'silver',
    target: 50,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'hundred_sessions',
    title: 'Centurion',
    description: 'Célébrez votre 100e session.',
    tier: 'gold',
    target: 100,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'two_hundred_sessions',
    title: 'Pilier du carnet',
    description: 'Enregistrez 200 sessions.',
    tier: 'gold',
    target: 200,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'thousand_sessions',
    title: 'Légende',
    description: 'Passez le cap mythique des 1 000 sessions.',
    tier: 'gold',
    target: 1000,
    progress: (p) => p.sessions.length,
  ),

  AchievementDefinition(
    id: 'first_platform',
    title: 'Première plateforme',
    description: 'Ajoutez une première plateforme à votre râtelier.',
    tier: 'bronze',
    target: 1,
    progress: (p) => p.platforms.length,
  ),
  AchievementDefinition(
    id: 'three_platforms',
    title: 'Râtelier garni',
    description: 'Possédez 3 plateformes dans votre inventaire.',
    tier: 'bronze',
    target: 3,
    progress: (p) => p.platforms.length,
  ),
  AchievementDefinition(
    id: 'five_platforms',
    title: 'Équipé',
    description: 'Montez votre inventaire à 5 plateformes.',
    tier: 'silver',
    target: 5,
    progress: (p) => p.platforms.length,
  ),
  AchievementDefinition(
    id: 'ten_platforms',
    title: 'Technicien',
    description: 'Gérez 10 plateformes dans votre râtelier.',
    tier: 'gold',
    target: 10,
    progress: (p) => p.platforms.length,
  ),

  AchievementDefinition(
    id: 'first_ammo',
    title: 'Première boîte',
    description: 'Ajoutez votre première référence de consommable.',
    tier: 'bronze',
    target: 1,
    progress: (p) => p.ammos.length,
  ),
  AchievementDefinition(
    id: 'three_ammos',
    title: 'Approvisionné',
    description: 'Enregistrez 3 références de consommables.',
    tier: 'bronze',
    target: 3,
    progress: (p) => p.ammos.length,
  ),
  AchievementDefinition(
    id: 'ten_ammos',
    title: 'Réserve sérieuse',
    description: 'Variété absolue : 10 références de consommables différentes.',
    tier: 'silver',
    target: 10,
    progress: (p) => p.ammos.length,
  ),

  AchievementDefinition(
    id: 'first_accessory',
    title: 'Premier accessoire',
    description: 'Ajoutez un accessoire à votre inventaire.',
    tier: 'bronze',
    target: 1,
    progress: (p) => p.accessories.length,
  ),
  AchievementDefinition(
    id: 'three_accessories',
    title: 'Bien équipé',
    description: 'Possédez 3 accessoires différents.',
    tier: 'bronze',
    target: 3,
    progress: (p) => p.accessories.length,
  ),
  AchievementDefinition(
    id: 'ten_accessories',
    title: 'Configuration complète',
    description: 'Gérez 10 accessoires dans votre inventaire.',
    tier: 'silver',
    target: 10,
    progress: (p) => p.accessories.length,
  ),

  const AchievementDefinition(
    id: 'first_precision_session',
    title: 'Première précision mesurée',
    description: 'Scorez au moins une session avec la précision activée.',
    tier: 'bronze',
    target: 1,
    progress: countedPrecisionSessionsCount,
  ),
  const AchievementDefinition(
    id: 'ten_precision_sessions',
    title: 'Œil affûté',
    description: 'Enregistrez 10 sessions avec calcul de précision.',
    tier: 'silver',
    target: 10,
    progress: countedPrecisionSessionsCount,
  ),
  const AchievementDefinition(
    id: 'fifty_precision_sessions',
    title: 'Analyseur confirmé',
    description: 'Mesurez votre précision sur 50 sessions.',
    tier: 'gold',
    target: 50,
    progress: countedPrecisionSessionsCount,
  ),

  const AchievementDefinition(
    id: 'first_perfect_session',
    title: 'Sans faute',
    description: 'Réalisez 100% de précision sur une session.',
    tier: 'bronze',
    target: 1,
    progress: perfectSessionsCount,
  ),
  const AchievementDefinition(
    id: 'three_perfect_sessions',
    title: 'Zéro défaut',
    description: 'Atteignez les 100% de précision lors de 3 sessions.',
    tier: 'silver',
    target: 3,
    progress: perfectSessionsCount,
  ),
  const AchievementDefinition(
    id: 'ten_perfect_sessions',
    title: 'Maître de précision',
    description: 'Conservez une précision parfaite (100%) sur 10 sessions.',
    tier: 'gold',
    target: 10,
    progress: perfectSessionsCount,
  ),

  AchievementDefinition(
    id: 'first_cleaning',
    title: 'Premier entretien',
    description: 'Renseignez un nettoyage de plateforme complet.',
    tier: 'bronze',
    target: 1,
    progress: (p) => historyCount(p, 'entretien'),
  ),
  AchievementDefinition(
    id: 'five_cleanings',
    title: 'Soigneux',
    description: 'Effectuez 5 nettoyages consignés dans l\'historique.',
    tier: 'bronze',
    target: 5,
    progress: (p) => historyCount(p, 'entretien'),
  ),
  AchievementDefinition(
    id: 'ten_cleanings',
    title: 'Intendant',
    description: 'Maintenez vos plateformes propres avec 10 entretiens.',
    tier: 'silver',
    target: 10,
    progress: (p) => historyCount(p, 'entretien'),
  ),
  AchievementDefinition(
    id: 'fifty_cleanings',
    title: 'Maniaque mécanique',
    description: 'Un soin exceptionnel : 50 entretiens documentés.',
    tier: 'gold',
    target: 50,
    progress: (p) => historyCount(p, 'entretien'),
  ),

  AchievementDefinition(
    id: 'first_revision',
    title: 'Première révision',
    description: 'Cochez votre première révision de pièce chez le technicien.',
    tier: 'bronze',
    target: 1,
    progress: (p) => historyCount(p, 'revision'),
  ),
  AchievementDefinition(
    id: 'five_revisions',
    title: 'Maintenance sérieuse',
    description: 'Effectuez 5 révisions majeures sur vos plateformes.',
    tier: 'silver',
    target: 5,
    progress: (p) => historyCount(p, 'revision'),
  ),
  AchievementDefinition(
    id: 'ten_revisions',
    title: 'Technicien',
    description: 'Assurez la sécurité de vos plateformes via 10 révisions.',
    tier: 'gold',
    target: 10,
    progress: (p) => historyCount(p, 'revision'),
  ),

  AchievementDefinition(
    id: 'hundred_rounds',
    title: '100 coups',
    description: '100 coups au compteur.',
    tier: 'bronze',
    target: 100,
    progress: (p) => p.totalRoundsFired,
  ),
  AchievementDefinition(
    id: 'thousand_rounds',
    title: '1 000 coups',
    description: 'Le canon chauffe : 1 000 coups cumulés.',
    tier: 'silver',
    target: 1000,
    progress: (p) => p.totalRoundsFired,
  ),
  AchievementDefinition(
    id: 'five_thousand_rounds',
    title: '5 000 coups',
    description: 'Étape majeure : 5 000 coups cumulés.',
    tier: 'gold',
    target: 5000,
    progress: (p) => p.totalRoundsFired,
  ),
  AchievementDefinition(
    id: 'ten_thousand_rounds',
    title: '10 000 coups',
    description: 'Statut vétéran : 10 000 coups enregistrés.',
    tier: 'gold',
    target: 10000,
    progress: (p) => p.totalRoundsFired,
  ),

  const AchievementDefinition(
    id: 'history_started',
    title: 'Carnet vivant',
    description: 'Alimentez l\'historique détaillé de votre matériel 10 fois.',
    tier: 'bronze',
    target: 10,
    progress: totalPlatformHistoryEntries,
  ),
  const AchievementDefinition(
    id: 'history_extended',
    title: 'Historique riche',
    description: 'Créez 50 entrées dans les historiques matériels.',
    tier: 'silver',
    target: 50,
    progress: totalPlatformHistoryEntries,
  ),
  const AchievementDefinition(
    id: 'history_master',
    title: 'Mémoire d\'atelier',
    description: 'Un suivi exemplaire avec 100 événements d\'historique.',
    tier: 'gold',
    target: 100,
    progress: totalPlatformHistoryEntries,
  ),

  AchievementDefinition(
    id: 'session_editor',
    title: 'Perfectionniste',
    description: 'Créez ou modifiez 20 sessions différentes.',
    tier: 'bronze',
    target: 20,
    progress: (p) => p.sessions.length,
  ),
  AchievementDefinition(
    id: 'data_builder',
    title: 'Architecte de données',
    description: 'Regroupez 20 éléments dans votre inventaire total.',
    tier: 'silver',
    target: 20,
    progress: (p) => p.platforms.length + p.ammos.length + p.accessories.length,
  ),
  AchievementDefinition(
    id: 'full_ecosystem',
    title: 'Écosystème complet',
    description: 'Vivez avec THOT : 40 matériels différents répertoriés.',
    tier: 'gold',
    target: 40,
    progress: (p) => p.platforms.length + p.ammos.length + p.accessories.length,
  ),

  // Reflex training achievements
  AchievementDefinition(
    id: 'reflex_week_7',
    title: 'Semaine régulière',
    description: '7 jours d\'entraînement réguliers en réflexes.',
    tier: 'bronze',
    target: 7,
    progress: (p) => TrainingHistory.getDailyStreakWithGrace(),
  ),
  AchievementDefinition(
    id: 'reflex_month_30',
    title: 'Mois régulier',
    description: '30 jours d\'entraînement réguliers en réflexes.',
    tier: 'silver',
    target: 30,
    progress: (p) => TrainingHistory.getDailyStreakWithGrace(),
  ),
  AchievementDefinition(
    id: 'reflex_total_50',
    title: 'Entraînement régulier',
    description: '50 séances d\'entraînement réflexes complétées.',
    tier: 'bronze',
    target: 50,
    progress: (p) => TrainingHistory.getTotalTrainingCount(),
  ),
  AchievementDefinition(
    id: 'reflex_total_100',
    title: 'Athlète mental',
    description: '100 séances d\'entraînement réflexes complétées.',
    tier: 'silver',
    target: 100,
    progress: (p) => TrainingHistory.getTotalTrainingCount(),
  ),
  AchievementDefinition(
    id: 'reflex_total_500',
    title: 'Maître des réflexes',
    description: '500 séances d\'entraînement réflexes complétées.',
    tier: 'gold',
    target: 500,
    progress: (p) => TrainingHistory.getTotalTrainingCount(),
  ),
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
