part of 'app_strings.dart';

extension AppStringsAchievements on AppStrings {
  String achievementTitle(String id) {
    switch (id) {
      case 'first_session':
        return _pick(fr: 'Première séance', en: 'First session', de: 'Erste Sitzung', it: 'Prima sessione', es: 'Primera sesión');
      case 'five_sessions':
        return _pick(fr: 'Échauffement', en: 'Warm-up', de: 'Aufwärmen', it: 'Riscaldamento', es: 'Calentamiento');
      case 'ten_sessions':
        return _pick(fr: 'Tireur assidu', en: 'Steady shooter', de: 'Regelmäßiger Schütze', it: 'Tiratore assiduo', es: 'Tirador constante');
      case 'twenty_five_sessions':
        return _pick(fr: 'Régulier', en: 'Consistent', de: 'Beständig', it: 'Costante', es: 'Constante');
      case 'fifty_sessions':
        return _pick(fr: 'Habitué du stand', en: 'Range regular', de: 'Stammgast am Stand', it: 'Abituato al poligono', es: 'Habitual del campo');
      case 'hundred_sessions':
        return _pick(fr: 'Centurion', en: 'Centurion', de: 'Zenturio', it: 'Centurione', es: 'Centurión');
      case 'two_hundred_sessions':
        return _pick(fr: 'Pilier du carnet', en: 'Logbook pillar', de: 'Stütze des Schießbuchs', it: 'Pilastro del registro', es: 'Pilar del cuaderno');
      case 'thousand_sessions':
        return _pick(fr: 'Légende du pas de tir', en: 'Range legend', de: 'Legende des Schießstands', it: 'Leggenda del poligono', es: 'Leyenda del campo');
      case 'first_weapon':
        return _pick(fr: 'Première arme', en: 'First weapon', de: 'Erste Waffe', it: 'Prima arma', es: 'Primera arma');
      case 'three_weapons':
        return _pick(fr: 'Petit arsenal', en: 'Small arsenal', de: 'Kleines Arsenal', it: 'Piccolo arsenale', es: 'Pequeño arsenal');
      case 'five_weapons':
        return _pick(fr: 'Équipé', en: 'Well equipped', de: 'Gut ausgerüstet', it: 'Ben equipaggiato', es: 'Bien equipado');
      case 'ten_weapons':
        return _pick(fr: 'Le collectionneur', en: 'Collector', de: 'Sammler', it: 'Collezionista', es: 'Coleccionista');
      case 'first_ammo':
        return _pick(fr: 'Première munition', en: 'First ammo', de: 'Erste Munition', it: 'Prima munizione', es: 'Primera munición');
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
        return _pick(fr: 'Première précision mesurée', en: 'First measured precision', de: 'Erste gemessene Präzision', it: 'Prima precisione misurata', es: 'Primera precisión medida');
      case 'ten_precision_sessions':
        return _pick(fr: 'Œil affûté', en: 'Sharp eye', de: 'Scharfes Auge', it: 'Occhio allenato', es: 'Ojo afilado');
      case 'fifty_precision_sessions':
        return _pick(fr: 'Analyseur confirmé', en: 'Seasoned analyst', de: 'Erfahrener Analytiker', it: 'Analista esperto', es: 'Analista experimentado');
      case 'first_perfect_session':
        return _pick(fr: 'Tir parfait', en: 'Perfect shot', de: 'Perfekter Schuss', it: 'Tiro perfetto', es: 'Tiro perfecto');
      case 'three_perfect_sessions':
        return _pick(fr: 'Zéro défaut', en: 'Flawless', de: 'Fehlerfrei', it: 'Senza difetti', es: 'Sin fallos');
      case 'ten_perfect_sessions':
        return _pick(fr: 'Maître de précision', en: 'Master of precision', de: 'Meister der Präzision', it: 'Maestro della precisione', es: 'Maestro de la precisión');
      case 'first_cleaning':
        return _pick(fr: 'Premier entretien', en: 'First cleaning', de: 'Erste Reinigung', it: 'Prima pulizia', es: 'Primer mantenimiento');
      case 'five_cleanings':
        return _pick(fr: 'Soigneux', en: 'Careful', de: 'Sorgfältig', it: 'Scrupoloso', es: 'Cuidadoso');
      case 'ten_cleanings':
        return _pick(fr: 'Intendant', en: 'Quartermaster', de: 'Quartiermeister', it: 'Intendente', es: 'Intendente');
      case 'fifty_cleanings':
        return _pick(fr: 'Maniaque mécanique', en: 'Mechanical maniac', de: 'Mechanikfanatiker', it: 'Maniaco della meccanica', es: 'Maniático mecánico');
      case 'first_revision':
        return _pick(fr: 'Première révision', en: 'First revision', de: 'Erste Revision', it: 'Prima revisione', es: 'Primera revisión');
      case 'five_revisions':
        return _pick(fr: 'Maintenance sérieuse', en: 'Serious maintenance', de: 'Ernsthafte Wartung', it: 'Manutenzione seria', es: 'Mantenimiento serio');
      case 'ten_revisions':
        return _pick(fr: 'Armurier', en: 'Gunsmith', de: 'Büchsenmacher', it: 'Armaiolo', es: 'Armero');
      case 'hundred_rounds':
        return _pick(fr: '100 coups', en: '100 shots', de: '100 Schüsse', it: '100 colpi', es: '100 disparos');
      case 'thousand_rounds':
        return _pick(fr: '1 000 coups', en: '1,000 shots', de: '1.000 Schüsse', it: '1.000 colpi', es: '1.000 disparos');
      case 'five_thousand_rounds':
        return _pick(fr: '5 000 coups', en: '5,000 shots', de: '5.000 Schüsse', it: '5.000 colpi', es: '5.000 disparos');
      case 'ten_thousand_rounds':
        return _pick(fr: '10 000 coups', en: '10,000 shots', de: '10.000 Schüsse', it: '10.000 colpi', es: '10.000 disparos');
      case 'history_started':
        return _pick(fr: 'Carnet vivant', en: 'Living logbook', de: 'Lebendiges Schießbuch', it: 'Registro vivo', es: 'Cuaderno vivo');
      case 'history_extended':
        return _pick(fr: 'Historique riche', en: 'Rich history', de: 'Umfangreiche Historie', it: 'Storico ricco', es: 'Historial rico');
      case 'history_master':
        return _pick(fr: 'Mémoire d’armurerie', en: 'Armory memory', de: 'Waffenkammer-Gedächtnis', it: 'Memoria d’armeria', es: 'Memoria de armería');
      case 'session_editor':
        return _pick(fr: 'Perfectionniste', en: 'Perfectionist', de: 'Perfektionist', it: 'Perfezionista', es: 'Perfeccionista');
      case 'data_builder':
        return _pick(fr: 'Architecte de données', en: 'Data architect', de: 'Datenarchitekt', it: 'Architetto dei dati', es: 'Arquitecto de datos');
      case 'full_ecosystem':
        return _pick(fr: 'Écosystème complet', en: 'Complete ecosystem', de: 'Komplettes Ökosystem', it: 'Ecosistema completo', es: 'Ecosistema completo');
      default:
        return id;
    }
  }

  String achievementDescription(String id) {
    switch (id) {
      case 'first_session':
        return _pick(fr: 'Créez votre toute première séance.', en: 'Create your very first session.', de: 'Erstelle deine allererste Sitzung.', it: 'Crea la tua primissima sessione.', es: 'Crea tu primera sesión.');
      case 'five_sessions':
        return _pick(fr: 'Enchaînez 5 séances enregistrées.', en: 'Log 5 completed sessions.', de: 'Protokolliere 5 Sitzungen.', it: 'Registra 5 sessioni completate.', es: 'Registra 5 sesiones completadas.');
      case 'ten_sessions':
        return _pick(fr: 'Cap des 10 séances atteint.', en: 'Hit the 10-session milestone.', de: 'Erreiche 10 Sitzungen.', it: 'Raggiungi 10 sessioni.', es: 'Alcanza 10 sesiones.');
      case 'twenty_five_sessions':
        return _pick(fr: '25 séances, une vraie routine.', en: '25 sessions—solid consistency.', de: '25 Sitzungen—starke Konstanz.', it: '25 sessioni—grande costanza.', es: '25 sesiones—constancia real.');
      case 'fifty_sessions':
        return _pick(fr: '50 séances consignées. Respect.', en: '50 logged sessions. Respect.', de: '50 protokollierte Sitzungen. Respekt.', it: '50 sessioni registrate. Rispetto.', es: '50 sesiones registradas. Respeto.');
      case 'hundred_sessions':
        return _pick(fr: 'Bienvenue dans le club des 100.', en: 'Welcome to the 100 club.', de: 'Willkommen im 100er-Club.', it: 'Benvenuto nel club dei 100.', es: 'Bienvenido al club de los 100.');
      case 'two_hundred_sessions':
        return _pick(fr: '200 séances : discipline au top.', en: '200 sessions: next-level discipline.', de: '200 Sitzungen: Disziplin auf Top-Niveau.', it: '200 sessioni: disciplina al massimo.', es: '200 sesiones: disciplina al máximo.');
      case 'thousand_sessions':
        return _pick(fr: '1 000 séances. Légendaire.', en: '1,000 sessions. Legendary.', de: '1.000 Sitzungen. Legendär.', it: '1.000 sessioni. Leggendario.', es: '1.000 sesiones. Legendario.');

      case 'first_weapon':
        return _pick(fr: 'Ajoutez votre première arme au râtelier.', en: 'Add your first weapon to your rack.', de: 'Füge deine erste Waffe hinzu.', it: 'Aggiungi la tua prima arma.', es: 'Añade tu primera arma.');
      case 'three_weapons':
        return _pick(fr: '3 armes, l’arsenal prend forme.', en: '3 weapons—your arsenal takes shape.', de: '3 Waffen—dein Arsenal nimmt Form an.', it: '3 armi—il tuo arsenale cresce.', es: '3 armas—tu arsenal toma forma.');
      case 'five_weapons':
        return _pick(fr: 'Passez à 5 armes enregistrées.', en: 'Reach 5 registered weapons.', de: 'Erreiche 5 erfasste Waffen.', it: 'Raggiungi 5 armi registrate.', es: 'Alcanza 5 armas registradas.');
      case 'ten_weapons':
        return _pick(fr: '10 armes : collection assumée.', en: '10 weapons—collector status.', de: '10 Waffen—Sammlerstatus.', it: '10 armi—status collezionista.', es: '10 armas—modo coleccionista.');

      case 'first_ammo':
        return _pick(fr: 'Ajoutez votre première munition.', en: 'Add your first ammo reference.', de: 'Füge deine erste Munitionssorte hinzu.', it: 'Aggiungi la tua prima munizione.', es: 'Añade tu primera munición.');
      case 'three_ammos':
        return _pick(fr: '3 références pour couvrir l’essentiel.', en: '3 ammo types—cover the basics.', de: '3 Munitionssorten—die Basis steht.', it: '3 tipi—hai le basi.', es: '3 tipos—lo esencial.');
      case 'ten_ammos':
        return _pick(fr: '10 références : stock sérieux.', en: '10 ammo types—serious stock.', de: '10 Sorten—ernsthafter Vorrat.', it: '10 tipi—scorta seria.', es: '10 tipos—reserva seria.');

      case 'first_accessory':
        return _pick(fr: 'Ajoutez un premier accessoire.', en: 'Add your first accessory.', de: 'Füge dein erstes Zubehör hinzu.', it: 'Aggiungi il primo accessorio.', es: 'Añade tu primer accesorio.');
      case 'three_accessories':
        return _pick(fr: '3 accessoires pour être prêt.', en: '3 accessories—ready to go.', de: '3 Zubehörteile—bereit.', it: '3 accessori—pronto.', es: '3 accesorios—listo.');
      case 'ten_accessories':
        return _pick(fr: '10 accessoires : setup complet.', en: '10 accessories—full setup.', de: '10 Zubehörteile—komplettes Setup.', it: '10 accessori—setup completo.', es: '10 accesorios—config completa.');

      case 'first_precision_session':
        return _pick(fr: 'Activez la précision sur une séance.', en: 'Enable precision on a session.', de: 'Aktiviere Präzision in einer Sitzung.', it: 'Attiva la precisione in una sessione.', es: 'Activa precisión en una sesión.');
      case 'ten_precision_sessions':
        return _pick(fr: '10 séances analysées en précision.', en: '10 sessions measured for precision.', de: '10 Sitzungen mit Präzisionsmessung.', it: '10 sessioni con precisione.', es: '10 sesiones con precisión.');
      case 'fifty_precision_sessions':
        return _pick(fr: '50 séances : stats qui parlent.', en: '50 sessions—stats that matter.', de: '50 Sitzungen—Aussagekräftige Stats.', it: '50 sessioni—stat che contano.', es: '50 sesiones—estadísticas reales.');

      case 'first_perfect_session':
        return _pick(fr: 'Atteignez 100% de précision sur une séance.', en: 'Hit 100% accuracy on a session.', de: 'Erreiche 100% Präzision in einer Sitzung.', it: 'Fai 100% di precisione in una sessione.', es: 'Logra 100% de precisión en una sesión.');
      case 'three_perfect_sessions':
        return _pick(fr: '3 séances à 100%. Solide.', en: '3 perfect sessions. Solid.', de: '3 perfekte Sitzungen. Stark.', it: '3 sessioni perfette. Solido.', es: '3 sesiones perfectas. Sólido.');
      case 'ten_perfect_sessions':
        return _pick(fr: '10 séances parfaites. Maîtrise.', en: '10 perfect sessions. Mastery.', de: '10 perfekte Sitzungen. Meisterschaft.', it: '10 sessioni perfette. Maestria.', es: '10 sesiones perfectas. Maestría.');

      case 'first_cleaning':
        return _pick(fr: 'Consignez votre premier entretien.', en: 'Log your first cleaning.', de: 'Protokolliere deine erste Reinigung.', it: 'Registra la tua prima pulizia.', es: 'Registra tu primer mantenimiento.');
      case 'five_cleanings':
        return _pick(fr: '5 entretiens : rigueur.', en: '5 cleanings—discipline.', de: '5 Reinigungen—Disziplin.', it: '5 pulizie—disciplina.', es: '5 mantenimientos—disciplina.');
      case 'ten_cleanings':
        return _pick(fr: '10 entretiens, matériel impeccable.', en: '10 cleanings—gear spotless.', de: '10 Reinigungen—Top Zustand.', it: '10 pulizie—attrezzatura perfetta.', es: '10 mantenimientos—equipo impecable.');
      case 'fifty_cleanings':
        return _pick(fr: '50 entretiens. Machine de guerre.', en: '50 cleanings—war machine.', de: '50 Reinigungen—Kriegsmaschine.', it: '50 pulizie—macchina da guerra.', es: '50 mantenimientos—máquina.');

      case 'first_revision':
        return _pick(fr: 'Validez votre première révision.', en: 'Log your first revision.', de: 'Protokolliere deine erste Revision.', it: 'Registra la prima revisione.', es: 'Registra tu primera revisión.');
      case 'five_revisions':
        return _pick(fr: '5 révisions : sécurité d’abord.', en: '5 revisions—safety first.', de: '5 Revisionen—Sicherheit zuerst.', it: '5 revisioni—sicurezza prima.', es: '5 revisiones—seguridad ante todo.');
      case 'ten_revisions':
        return _pick(fr: '10 révisions : niveau armurier.', en: '10 revisions—gunsmith level.', de: '10 Revisionen—Büchsenmacher-Niveau.', it: '10 revisioni—livello armaiolo.', es: '10 revisiones—nivel armero.');

      case 'hundred_rounds':
        return _pick(fr: '100 coups tirés au total.', en: '100 total rounds fired.', de: '100 Schuss insgesamt.', it: '100 colpi totali.', es: '100 disparos totales.');
      case 'thousand_rounds':
        return _pick(fr: '1 000 coups : ça chauffe.', en: '1,000 rounds—things heat up.', de: '1.000 Schuss—es wird ernst.', it: '1.000 colpi—si fa sul serio.', es: '1.000 disparos—se pone serio.');
      case 'five_thousand_rounds':
        return _pick(fr: '5 000 coups : grosse étape.', en: '5,000 rounds—major milestone.', de: '5.000 Schuss—großer Meilenstein.', it: '5.000 colpi—grande traguardo.', es: '5.000 disparos—gran hito.');
      case 'ten_thousand_rounds':
        return _pick(fr: '10 000 coups : vétéran.', en: '10,000 rounds—veteran status.', de: '10.000 Schuss—Veteranenstatus.', it: '10.000 colpi—status veterano.', es: '10.000 disparos—veterano.');

      case 'history_started':
        return _pick(fr: 'Ajoutez 10 événements d’historique.', en: 'Add 10 history entries.', de: 'Füge 10 Historie-Einträge hinzu.', it: 'Aggiungi 10 eventi di storico.', es: 'Añade 10 entradas de historial.');
      case 'history_extended':
        return _pick(fr: 'Atteignez 50 événements d’historique.', en: 'Reach 50 history entries.', de: 'Erreiche 50 Historie-Einträge.', it: 'Raggiungi 50 eventi.', es: 'Alcanza 50 entradas.');
      case 'history_master':
        return _pick(fr: '100 événements : suivi exemplaire.', en: '100 entries—top-tier tracking.', de: '100 Einträge—vorbildliches Tracking.', it: '100 eventi—monitoraggio top.', es: '100 entradas—seguimiento top.');

      case 'session_editor':
        return _pick(fr: 'Créez/éditez 20 séances.', en: 'Create/edit 20 sessions.', de: 'Erstelle/bearbeite 20 Sitzungen.', it: 'Crea/modifica 20 sessioni.', es: 'Crea/edita 20 sesiones.');
      case 'data_builder':
        return _pick(fr: 'Atteignez 20 éléments d’inventaire.', en: 'Reach 20 inventory items.', de: 'Erreiche 20 Inventar-Elemente.', it: 'Raggiungi 20 elementi.', es: 'Alcanza 20 elementos.');
      case 'full_ecosystem':
        return _pick(fr: '40 matériels : écosystème complet.', en: '40 items—complete ecosystem.', de: '40 Teile—komplettes Ökosystem.', it: '40 elementi—ecosistema completo.', es: '40 items—ecosistema completo.');
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
