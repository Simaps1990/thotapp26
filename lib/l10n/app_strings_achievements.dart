part of 'app_strings.dart';

extension AppStringsAchievements on AppStrings {
  String achievementTitle(String id) {
    switch (id) {
      case 'first_session':
        return _pick(fr: 'Première session', en: 'First session', de: 'Erste Sitzung', it: 'Prima sessione', es: 'Primera sesión');
      case 'five_sessions':
        return _pick(fr: 'Échauffement', en: 'Warm-up', de: 'Aufwärmen', it: 'Riscaldamento', es: 'Calentamiento');
      case 'ten_sessions':
        return _pick(fr: 'Opérationnel', en: 'Operational', de: 'Einsatzbereit', it: 'Operativo', es: 'Operativo');
      case 'twenty_five_sessions':
        return _pick(fr: 'Régulier', en: 'Consistent', de: 'Beständig', it: 'Costante', es: 'Constante');
      case 'fifty_sessions':
        return _pick(fr: 'Valeur sûre', en: 'Proven', de: 'Bewährt', it: 'Collaudato', es: 'Veterano');
      case 'hundred_sessions':
        return _pick(fr: 'Centurion', en: 'Centurion', de: 'Zenturio', it: 'Centurione', es: 'Centurión');
      case 'two_hundred_sessions':
        return _pick(fr: 'Pilier du carnet', en: 'Logbook pillar', de: 'Stütze des Logbuchs', it: 'Pilastro del registro', es: 'Pilar del cuaderno');
      case 'thousand_sessions':
        return _pick(fr: 'Légende', en: 'Legend', de: 'Legende', it: 'Leggenda', es: 'Leyenda');
      case 'first_platform':
        return _pick(fr: 'Première plateforme', en: 'First platform', de: 'Erste Plattform', it: 'Prima piattaforma', es: 'Primera plataforma');
      case 'three_platforms':
        return _pick(fr: 'Râtelier garni', en: 'Stacked rack', de: 'Gefüllter Ständer', it: 'Rastrelliera fornita', es: 'Armero surtido');
      case 'five_platforms':
        return _pick(fr: 'Équipé', en: 'Well equipped', de: 'Gut ausgerüstet', it: 'Ben equipaggiato', es: 'Bien equipado');
      case 'ten_platforms':
        return _pick(fr: 'Technicien', en: 'Technician', de: 'Techniker', it: 'Tecnico', es: 'Técnico');
      case 'first_ammo':
        return _pick(fr: 'Première boîte', en: 'First cartridge', de: 'Erste Box', it: 'Prima cartuccia', es: 'Primera cartucho');
      case 'three_ammos':
        return _pick(fr: 'Approvisionné', en: 'Stocked up', de: 'Gut versorgt', it: 'Ben rifornito', es: 'Bien abastecido');
      case 'ten_ammos':
        return _pick(fr: 'Réserve sérieuse', en: 'Serious reserve', de: 'Großer Vorrat', it: 'Scorta seria', es: 'Reserva seria');
      case 'first_accessory':
        return _pick(fr: 'Premier accessoire', en: 'First accessory', de: 'Erstes Zubehör', it: 'Primo accessorio', es: 'Primer accesorio');
      case 'three_accessories':
        return _pick(fr: 'Bien équipé', en: 'Fully equipped', de: 'Gut ausgestattet', it: 'Ben equipaggiato', es: 'Bien equipado');
      case 'ten_accessories':
        return _pick(fr: 'Configuration complète', en: 'Full setup', de: 'Komplettausstattung', it: 'Configurazione completa', es: 'Configuración completa');
      case 'first_precision_session':
        return _pick(fr: 'Première précision mesurée', en: 'First measured precision', de: 'Erste Präzisionsmessung', it: 'Prima precisione misurata', es: 'Primera precisión medida');
      case 'ten_precision_sessions':
        return _pick(fr: 'Œil affûté', en: 'Sharp eye', de: 'Scharfes Auge', it: 'Occhio allenato', es: 'Ojo afilado');
      case 'fifty_precision_sessions':
        return _pick(fr: 'Analyseur confirmé', en: 'Seasoned analyst', de: 'Erfahrener Analytiker', it: 'Analista esperto', es: 'Analista experimentado');
      case 'first_perfect_session':
        return _pick(fr: 'Sans faute', en: 'Flawless run', de: 'Fehlerlos', it: 'Senza errori', es: 'Sin fallo');
      case 'three_perfect_sessions':
        return _pick(fr: 'Zéro défaut', en: 'Flawless', de: 'Fehlerfrei', it: 'Senza difetti', es: 'Sin fallos');
      case 'ten_perfect_sessions':
        return _pick(fr: 'Maître de précision', en: 'Master of precision', de: 'Präzisionsmeister', it: 'Maestro di precisione', es: 'Maestro de precisión');
      case 'first_cleaning':
        return _pick(fr: 'Premier entretien', en: 'First cleaning', de: 'Erste Reinigung', it: 'Prima pulizia', es: 'Primer mantenimiento');
      case 'five_cleanings':
        return _pick(fr: 'Soigneux', en: 'Careful', de: 'Sorgfältig', it: 'Scrupoloso', es: 'Cuidadoso');
      case 'ten_cleanings':
        return _pick(fr: 'Intendant', en: 'Quartermaster', de: 'Quartiermeister', it: 'Intendente', es: 'Intendente');
      case 'fifty_cleanings':
        return _pick(fr: 'Obsédé du détail', en: 'OCD-level care', de: 'Detailversessen', it: 'Ossessivo del dettaglio', es: 'Obsesivo del detalle');
      case 'first_revision':
        return _pick(fr: 'Première révision', en: 'First revision', de: 'Erste Revision', it: 'Prima revisione', es: 'Primera revisión');
      case 'five_revisions':
        return _pick(fr: 'Maintenance sérieuse', en: 'Serious maintenance', de: 'Ernsthafte Wartung', it: 'Manutenzione seria', es: 'Mantenimiento serio');
      case 'ten_revisions':
        return _pick(fr: 'Technicien', en: 'Technician', de: 'Techniker', it: 'Tecnico', es: 'Técnico');
      case 'hundred_rounds':
        return _pick(fr: '100 tirs', en: '100 shots', de: '100 Schüsse', it: '100 tiri', es: '100 tiros');
      case 'thousand_rounds':
        return _pick(fr: '1 000 tirs', en: '1,000 shots', de: '1.000 Schüsse', it: '1.000 tiri', es: '1.000 tiros');
      case 'five_thousand_rounds':
        return _pick(fr: '5 000 tirs', en: '5,000 shots', de: '5.000 Schüsse', it: '5.000 tiri', es: '5.000 tiros');
      case 'ten_thousand_rounds':
        return _pick(fr: '10 000 tirs', en: '10,000 shots', de: '10.000 Schüsse', it: '10.000 tiri', es: '10.000 tiros');
      case 'history_started':
        return _pick(fr: 'Carnet vivant', en: 'Living logbook', de: 'Lebendiges Logbuch', it: 'Registro vivo', es: 'Cuaderno vivo');
      case 'history_extended':
        return _pick(fr: 'Historique riche', en: 'Rich history', de: 'Umfangreiche Historie', it: 'Storico ricco', es: 'Historial rico');
      case 'history_master':
        return _pick(fr: 'Mémoire d\'atelier', en: 'Workshop memory', de: 'Werkstatt-Gedächtnis', it: 'Memoria d\'atelier', es: 'Memoria de taller');
      case 'session_editor':
        return _pick(fr: 'Perfectionniste', en: 'Perfectionist', de: 'Perfektionist', it: 'Perfezionista', es: 'Perfeccionista');
      case 'data_builder':
        return _pick(fr: 'Architecte de données', en: 'Data architect', de: 'Datenarchitekt', it: 'Architetto dei dati', es: 'Arquitecto de datos');
      case 'full_ecosystem':
        return _pick(fr: 'Écosystème complet', en: 'Complete ecosystem', de: 'Komplettes Ökosystem', it: 'Ecosistema completo', es: 'Ecosistema completo');
      case 'reflex_week_7':
        return _pick(fr: 'Semaine parfaite', en: 'Perfect week', de: 'Perfekte Woche', it: 'Settimana perfetta', es: 'Semana perfecta');
      case 'reflex_month_30':
        return _pick(fr: 'Mois complet', en: 'Full month', de: 'Ganzer Monat', it: 'Mese completo', es: 'Mes completo');
      case 'reflex_total_50':
        return _pick(fr: 'Entraînement régulier', en: 'Regular training', de: 'Regelmäßiges Training', it: 'Allenamento regolare', es: 'Entrenamiento regular');
      case 'reflex_total_100':
        return _pick(fr: 'Athlète mental', en: 'Mental athlete', de: 'Mentaler Athlet', it: 'Atleta mentale', es: 'Atleta mental');
      case 'reflex_total_500':
        return _pick(fr: 'Maître des réflexes', en: 'Reflex master', de: 'Reflex-Meister', it: 'Maestro dei riflessi', es: 'Maestro de reflejos');
      default:
        return id;
    }
  }

  String achievementDescription(String id) {
    switch (id) {
      case 'first_session':
        return _pick(fr: 'Créez votre toute première session.', en: 'Create your very first session.', de: 'Erstelle deine allererste Sitzung.', it: 'Crea la tua primissima sessione.', es: 'Crea tu primera sesión.');
      case 'five_sessions':
        return _pick(fr: 'Enchaînez 5 sessions enregistrées.', en: 'Log 5 completed sessions.', de: 'Protokolliere 5 Sitzungen.', it: 'Registra 5 sessioni completate.', es: 'Registra 5 sesiones completadas.');
      case 'ten_sessions':
        return _pick(fr: 'Cap des 10 sessions atteint.', en: 'Hit the 10-session milestone.', de: 'Erreiche 10 Sitzungen.', it: 'Raggiungi 10 sessioni.', es: 'Alcanza 10 sesiones.');
      case 'twenty_five_sessions':
        return _pick(fr: '25 sessions, une vraie routine.', en: '25 sessions—solid consistency.', de: '25 Sitzungen—starke Konstanz.', it: '25 sessioni—grande costanza.', es: '25 sesiones—constancia real.');
      case 'fifty_sessions':
        return _pick(fr: '50 sessions consignées. Respect.', en: '50 logged sessions. Respect.', de: '50 protokollierte Sitzungen. Respekt.', it: '50 sessioni registrate. Rispetto.', es: '50 sesiones registradas. Respeto.');
      case 'hundred_sessions':
        return _pick(fr: 'Bienvenue dans le club des 100.', en: 'Welcome to the 100 club.', de: 'Willkommen im 100er-Club.', it: 'Benvenuto nel club dei 100.', es: 'Bienvenido al club de los 100.');
      case 'two_hundred_sessions':
        return _pick(fr: '200 sessions : discipline au top.', en: '200 sessions: next-level discipline.', de: '200 Sitzungen: Spitzendisziplin.', it: '200 sessioni: disciplina al massimo.', es: '200 sesiones: disciplina al máximo.');
      case 'thousand_sessions':
        return _pick(fr: '1 000 sessions. Légendaire.', en: '1,000 sessions. Legendary.', de: '1.000 Sitzungen. Legendär.', it: '1.000 sessioni. Leggendario.', es: '1.000 sesiones. Legendario.');

      case 'first_platform':
        return _pick(fr: 'Ajoutez votre première plateforme au râtelier.', en: 'Add your first platform to your rack.', de: 'Füge deine erste Plattform hinzu.', it: 'Aggiungi la tua prima piattaforma.', es: 'Añade tu primera plataforma.');
      case 'three_platforms':
        return _pick(fr: '3 plateformes, le râtelier prend forme.', en: '3 platforms—your rack takes shape.', de: '3 Plattformen—dein Ständer füllt sich.', it: '3 piattaforme—la rastrelliera prende forma.', es: '3 plataformas—tu soporte toma forma.');
      case 'five_platforms':
        return _pick(fr: 'Passez à 5 plateformes enregistrées.', en: 'Reach 5 registered platforms.', de: 'Erreiche 5 erfasste Plattformen.', it: 'Raggiungi 5 piattaforme registrate.', es: 'Alcanza 5 plataformas registradas.');
      case 'ten_platforms':
        return _pick(fr: '10 plateformes : niveau technicien.', en: '10 platforms—technician level.', de: '10 Plattformen—Techniker-Niveau.', it: '10 piattaforme—livello tecnico.', es: '10 plataformas—nivel técnico.');

      case 'first_ammo':
        return _pick(fr: 'Ajoutez votre première boîte.', en: 'Add your first cartridge reference.', de: 'Füge deine erste Box hinzu.', it: 'Aggiungi la tua prima cartuccia.', es: 'Añade tu primera cartucho.');
      case 'three_ammos':
        return _pick(fr: '3 références pour couvrir l\'essentiel.', en: '3 cartridge types—cover the basics.', de: '3 Boxen—die Basis steht.', it: '3 tipi—hai le basi.', es: '3 tipos—lo esencial.');
      case 'ten_ammos':
        return _pick(fr: '10 références : stock sérieux.', en: '10 cartridge types—serious stock.', de: '10 Sorten—ernsthafter Vorrat.', it: '10 tipi—scorta seria.', es: '10 tipos—reserva seria.');

      case 'first_accessory':
        return _pick(fr: 'Ajoutez un premier accessoire.', en: 'Add your first accessory.', de: 'Füge dein erstes Zubehör hinzu.', it: 'Aggiungi il primo accessorio.', es: 'Añade tu primer accesorio.');
      case 'three_accessories':
        return _pick(fr: '3 accessoires pour être prêt.', en: '3 accessories—ready to go.', de: '3 Zubehörteile—bereit.', it: '3 accessori—pronto.', es: '3 accesorios—listo.');
      case 'ten_accessories':
        return _pick(fr: '10 accessoires : setup complet.', en: '10 accessories—full setup.', de: '10 Zubehörteile—komplettes Setup.', it: '10 accessori—setup completo.', es: '10 accesorios—config completa.');

      case 'first_precision_session':
        return _pick(fr: 'Activez la précision sur une session.', en: 'Enable precision on a session.', de: 'Aktiviere Präzision in einer Sitzung.', it: 'Attiva la precisione in una sessione.', es: 'Activa precisión en una sesión.');
      case 'ten_precision_sessions':
        return _pick(fr: '10 sessions analysées en précision.', en: '10 sessions measured for precision.', de: '10 Sitzungen mit Präzisionsmessung.', it: '10 sessioni con precisione.', es: '10 sesiones con precisión.');
      case 'fifty_precision_sessions':
        return _pick(fr: '50 sessions : stats qui parlent.', en: '50 sessions—stats that matter.', de: '50 Sitzungen—Stats, die zählen.', it: '50 sessioni—stat che contano.', es: '50 sesiones—estadísticas reales.');

      case 'first_perfect_session':
        return _pick(fr: 'Atteignez 100% de précision sur une session.', en: 'Hit 100% accuracy on a session.', de: 'Erreiche 100% Präzision in einer Sitzung.', it: 'Fai 100% di precisione in una sessione.', es: 'Logra 100% de precisión en una sesión.');
      case 'three_perfect_sessions':
        return _pick(fr: '3 sessions à 100%. Solide.', en: '3 perfect sessions. Solid.', de: '3 perfekte Sitzungen. Stark.', it: '3 sessioni perfette. Solido.', es: '3 sesiones perfectas. Sólido.');
      case 'ten_perfect_sessions':
        return _pick(fr: '10 sessions parfaites. Maîtrise.', en: '10 perfect sessions. Mastery.', de: '10 perfekte Sitzungen. Meisterschaft.', it: '10 sessioni perfette. Maestria.', es: '10 sesiones perfectas. Maestría.');

      case 'first_cleaning':
        return _pick(fr: 'Consignez votre premier entretien.', en: 'Log your first cleaning.', de: 'Protokolliere deine erste Reinigung.', it: 'Registra la tua prima pulizia.', es: 'Registra tu primer mantenimiento.');
      case 'five_cleanings':
        return _pick(fr: '5 entretiens : rigueur.', en: '5 cleanings—discipline.', de: '5 Reinigungen—Disziplin.', it: '5 pulizie—disciplina.', es: '5 mantenimientos—disciplina.');
      case 'ten_cleanings':
        return _pick(fr: '10 entretiens, matériel impeccable.', en: '10 cleanings—gear spotless.', de: '10 Reinigungen—Top Zustand.', it: '10 pulizie—attrezzatura perfetta.', es: '10 mantenimientos—equipo impecable.');
      case 'fifty_cleanings':
        return _pick(fr: '50 entretiens. Rigueur absolue.', en: '50 cleanings—absolute discipline.', de: '50 Reinigungen—absolute Disziplin.', it: '50 pulizie—disciplina assoluta.', es: '50 mantenimientos—disciplina absoluta.');

      case 'first_revision':
        return _pick(fr: 'Validez votre première révision.', en: 'Log your first revision.', de: 'Protokolliere deine erste Revision.', it: 'Registra la prima revisione.', es: 'Registra tu primera revisión.');
      case 'five_revisions':
        return _pick(fr: '5 révisions : sécurité d\'abord.', en: '5 revisions—safety first.', de: '5 Revisionen—Sicherheit zuerst.', it: '5 revisioni—sicurezza prima.', es: '5 revisiones—seguridad ante todo.');
      case 'ten_revisions':
        return _pick(fr: '10 révisions : niveau technicien.', en: '10 revisions—technician level.', de: '10 Revisionen—Techniker-Niveau.', it: '10 revisioni—livello tecnico.', es: '10 revisiones—nivel técnico.');

      case 'hundred_rounds':
        return _pick(fr: '100 coups au compteur.', en: '100 impacts logged.', de: '100 Treffer protokolliert.', it: '100 impatti registrati.', es: '100 impactos registrados.');
      case 'thousand_rounds':
        return _pick(fr: '1 000 coups. Le canon chauffe.', en: '1,000 impacts. Solid pace.', de: '1.000 Treffer. Solider Rhythmus.', it: '1.000 impatti. Ritmo solido.', es: '1.000 impactos. Ritmo sólido.');
      case 'five_thousand_rounds':
        return _pick(fr: '5 000 coups. Étape majeure.', en: '5,000 impacts. Major milestone.', de: '5.000 Treffer. Großer Meilenstein.', it: '5.000 impatti. Grande traguardo.', es: '5.000 impactos. Gran hito.');
      case 'ten_thousand_rounds':
        return _pick(fr: '10 000 coups. Statut vétéran.', en: '10,000 impacts. Veteran status.', de: '10.000 Treffer. Veteranenstatus.', it: '10.000 impatti. Status veterano.', es: '10.000 impactos. Veterano.');

      case 'history_started':
        return _pick(fr: 'Ajoutez 10 événements d\'historique.', en: 'Add 10 history entries.', de: 'Füge 10 Historie-Einträge hinzu.', it: 'Aggiungi 10 eventi di storico.', es: 'Añade 10 entradas de historial.');
      case 'history_extended':
        return _pick(fr: 'Atteignez 50 événements d\'historique.', en: 'Reach 50 history entries.', de: 'Erreiche 50 Historie-Einträge.', it: 'Raggiungi 50 eventi.', es: 'Alcanza 50 entradas.');
      case 'history_master':
        return _pick(fr: '100 événements : suivi exemplaire.', en: '100 entries—top-tier tracking.', de: '100 Einträge—vorbildliches Tracking.', it: '100 eventi—monitoraggio top.', es: '100 entradas—seguimiento top.');

      case 'session_editor':
        return _pick(fr: 'Créez/éditez 20 sessions.', en: 'Create/edit 20 sessions.', de: 'Erstelle/bearbeite 20 Sitzungen.', it: 'Crea/modifica 20 sessioni.', es: 'Crea/edita 20 sesiones.');
      case 'data_builder':
        return _pick(fr: 'Atteignez 20 éléments d\'inventaire.', en: 'Reach 20 inventory items.', de: 'Erreiche 20 Inventar-Elemente.', it: 'Raggiungi 20 elementi.', es: 'Alcanza 20 elementos.');
      case 'full_ecosystem':
        return _pick(fr: '40 matériels : écosystème complet.', en: '40 items—complete ecosystem.', de: '40 Teile—komplettes Ökosystem.', it: '40 elementi—ecosistema completo.', es: '40 items—ecosistema completo.');
      case 'reflex_week_7':
        return _pick(fr: '7 jours d\'entraînement consécutifs en réflexes.', en: '7 consecutive days of reflex training.', de: '7 aufeinanderfolgende Tage Reflextraining.', it: '7 giorni consecutivi di allenamento riflessi.', es: '7 días consecutivos de entrenamiento reflejos.');
      case 'reflex_month_30':
        return _pick(fr: '30 jours d\'entraînement consécutifs en réflexes.', en: '30 consecutive days of reflex training.', de: '30 aufeinanderfolgende Tage Reflextraining.', it: '30 giorni consecutivi di allenamento riflessi.', es: '30 días consecutivos de entrenamiento reflejos.');
      case 'reflex_total_50':
        return _pick(fr: '50 séances d\'entraînement réflexes complétées.', en: '50 reflex training sessions completed.', de: '50 Reflextraining-Sitzungen abgeschlossen.', it: '50 sessioni di allenamento riflessi completate.', es: '50 sesiones de entrenamiento reflejos completadas.');
      case 'reflex_total_100':
        return _pick(fr: '100 séances d\'entraînement réflexes complétées.', en: '100 reflex training sessions completed.', de: '100 Reflextraining-Sitzungen abgeschlossen.', it: '100 sessioni di allenamento riflessi completate.', es: '100 sesiones de entrenamiento reflejos completadas.');
      case 'reflex_total_500':
        return _pick(fr: '500 séances d\'entraînement réflexes complétées.', en: '500 reflex training sessions completed.', de: '500 Reflextraining-Sitzungen abgeschlossen.', it: '500 sessioni di allenamento riflessi completate.', es: '500 sesiones de entrenamiento reflejos completadas.');
      default:
        return _pick(
          fr: 'Objectif débloqué.',
          en: 'Achievement unlocked.',
          de: 'Erfolg freigeschaltet.',
          it: 'Obiettivo sbloccato.',
          es: 'Logro desbloqueado.',
        );
    }
  }
}