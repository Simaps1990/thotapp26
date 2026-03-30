import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:thot/data/exercise_step.dart';

part 'app_strings_achievements.dart';
part 'app_strings_home.dart';
part 'app_strings_settings.dart';
part 'app_strings_exercise_steps.dart';

/// Simple in-app string provider for manual i18n.
///
/// We key on languageCode only (fr, en, de, it, es) and fall back to fr.
class AppStrings {
  final String languageCode;

  AppStrings._(this.languageCode);

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static const supportedLocales = <Locale>[
    Locale('fr'),
    Locale('en'),
    Locale('de'),
    Locale('it'),
    Locale('es'),
  ];

  static AppStrings? maybeOf(BuildContext context) {
    return Localizations.of<AppStrings>(context, AppStrings);
  }

  static AppStrings of(BuildContext context) {
    return maybeOf(context) ?? AppStrings.forLocale(Localizations.localeOf(context));
  }

  static AppStrings forLocale(Locale locale) {
    final code = locale.languageCode;
    final resolved = supportedLocales.any((l) => l.languageCode == code)
        ? code
        : 'en';
    return AppStrings._(resolved);
  }

  bool get _isFr => languageCode == 'fr' || languageCode.isEmpty;
  bool get _isEn => languageCode == 'en';
  bool get _isDe => languageCode == 'de';
  bool get _isIt => languageCode == 'it';
  bool get _isEs => languageCode == 'es';

  // --- Onboarding ---

  String get onboardingTitle1 => _pick(
        fr: 'Bienvenue sur THOT',
        en: 'Welcome to THOT',
        de: 'Willkommen bei THOT',
        it: 'Benvenuto su THOT',
        es: 'Bienvenido a THOT',
      );

  String get onboardingDescription1 => _pick(
        fr: 'Le carnet de tir numérique incontournable pour les utilisateurs d\'arme à feu.',
        en: 'The essential digital shooting logbook for firearm users.',
        de: 'Das unverzichtbare digitale Schießbuch für Waffenbesitzer.',
        it: 'Il taccuino digitale di tiro essenziale per gli utilizzatori di armi da fuoco.',
        es: 'El cuaderno de tiro digital imprescindible para los usuarios de armas de fuego.',
      );

  String get onboardingTitle2 => _pick(
        fr: '100% Hors-ligne & Sécurisé',
        en: '100% Offline & Secure',
        de: '100% Offline & Sicher',
        it: '100% Offline e Sicuro',
        es: '100% Sin conexión y seguro',
      );

String get onboardingDescription2 => _pick(
        fr: 'Vos données ne quittent jamais votre appareil. Aucun serveur, aucun compte, aucune fuite possible — tout est chiffré localement avec AES-256 et protégé par votre code PIN ou votre biométrie.',
        en: 'Your data never leaves your device. No server, no account, no possible leak — everything is encrypted locally with AES-256 and protected by your PIN or biometrics.',
        de: 'Ihre Daten verlassen Ihr Gerät nie. Kein Server, kein Konto, kein möglicher Datenverlust — alles wird lokal mit AES-256 verschlüsselt und durch Ihre PIN oder Biometrie geschützt.',
        it: 'I tuoi dati non lasciano mai il dispositivo. Nessun server, nessun account, nessuna fuga possibile — tutto è cifrato localmente con AES-256 e protetto dal tuo PIN o dalla tua biometria.',
        es: 'Tus datos nunca salen de tu dispositivo. Sin servidor, sin cuenta, sin posible fuga — todo está cifrado localmente con AES-256 y protegido por tu PIN o biometría.',
      );

  String get onboardingTitle3 => _pick(
        fr: 'Gérez votre équipement',
        en: 'Manage your equipment',
        de: 'Verwalten Sie Ihre Ausrüstung',
        it: 'Gestisci la tua attrezzatura',
        es: 'Gestiona tu equipo',
      );

  String get onboardingDescription3 => _pick(
        fr: 'Suivez vos armes, vos munitions, votre équipement, documentez vos séances et analysez vos statistiques de tir avec précision.',
        en: 'Track your firearms, ammo and gear, log your sessions and analyze your shooting statistics with precision.',
        de: 'Verfolgen Sie Ihre Waffen, Munition und Ausrüstung, dokumentieren Sie Ihre Sitzungen und analysieren Sie Ihre Schießstatistiken präzise.',
        it: 'Tieni traccia delle tue armi, munizioni e attrezzature, documenta le tue sessioni e analizza con precisione le tue statistiche di tiro.',
        es: 'Haz un seguimiento de tus armas, municiones y equipo, documenta tus sesiones y analiza con precisión tus estadísticas de tiro.',
      );

  String get onboardingDontShowAgain => _pick(
        fr: 'Ne plus afficher',
        en: 'Don\'t show again',
        de: 'Nicht mehr anzeigen',
        it: 'Non mostrare più',
        es: 'No mostrar de nuevo',
      );

  String get onboardingSkip => _pick(
        fr: 'Passer',
        en: 'Skip',
        de: 'Überspringen',
        it: 'Salta',
        es: 'Omitir',
      );

  String get clear => _pick(
        fr: 'Effacer',
        en: 'Clear',
        de: 'Löschen',
        it: 'Cancella',
        es: 'Borrar',
      );

  String get onboardingNext => _pick(
        fr: 'Suivant',
        en: 'Next',
        de: 'Weiter',
        it: 'Avanti',
        es: 'Siguiente',
      );

  String get onboardingStart => _pick(
        fr: 'Commencer',
        en: 'Get started',
        de: 'Los geht\'s',
        it: 'Inizia',
        es: 'Empezar',
      );

  // --- Shooting Timer ---

  String get timerToolTitle => _pick(
        fr: 'TIMER DE TIR',
        en: 'SHOOTING TIMER',
        de: 'SCHIESS-TIMER',
        it: 'TIMER DI TIRO',
        es: 'TEMPORIZADOR DE TIRO',
      );

  String get timerToolSubtitle => _pick(
        fr: 'Gérez vos départs, fenêtres de tir et répétitions.',
        en: 'Control start delays, par times and repetitions.',
        de: 'Steuern Sie Startverzögerungen, Par-Zeiten und Wiederholungen.',
        it: 'Gestisci ritardi di partenza, par time e ripetizioni.',
        es: 'Gestiona retrasos de salida, par times y repeticiones.',
      );

  String get timerModesTitle => _pick(
        fr: 'Modes de timer',
        en: 'Timer modes',
        de: 'Timer-Modi',
        it: 'Modalità timer',
        es: 'Modos de temporizador',
      );

  String get timerSettingsTitle => _pick(
        fr: 'Réglages du timer',
        en: 'Timer settings',
        de: 'Timer-Einstellungen',
        it: 'Impostazioni del timer',
        es: 'Ajustes del temporizador',
      );

  String get timerFeedbackTitle => _pick(
        fr: 'Retour audio et vibration',
        en: 'Sound and haptic feedback',
        de: 'Ton- und Vibrationsfeedback',
        it: 'Feedback sonoro e aptico',
        es: 'Sonido y vibración',
      );

  String get timerShotDetectionTitle => _pick(
        fr: 'Détection du coup de feu',
        en: 'Shot detection',
        de: 'Schusserkennung',
        it: 'Rilevamento dello sparo',
        es: 'Detección de disparo',
      );

  String get timerModeSimple => _pick(
        fr: 'Simple',
        en: 'Simple',
        de: 'Einfach',
        it: 'Semplice',
        es: 'Simple',
      );

  String get timerModeParTime => _pick(
        fr: 'Par time',
        en: 'Par time',
        de: 'Par-Zeit',
        it: 'Par time',
        es: 'Par time',
      );

  String get timerModeRepeat => _pick(
        fr: 'Répétitions',
        en: 'Repeats',
        de: 'Wiederholungen',
        it: 'Ripetizioni',
        es: 'Repeticiones',
      );

  String get timerModeRandomDelay => _pick(
fr: 'Bip aléatoire',
en: 'Random beep',
de: 'Zufälliger Signalton',
it: 'Bip casuale',
es: 'Bip aleatorio',
      );

  String get timerModeStartAndMic => _pick(
fr: 'Réaction au bip',
en: 'Reaction to beep',
de: 'Reaktion auf Signalton',
it: 'Reazione al bip',
es: 'Reacción al bip',
      );

  String get timerModeStartAndShots => _pick(
fr: 'Chaque coup compte',
en: 'Every shot counts',
de: 'Jeder Schuss zählt',
it: 'Ogni colpo conta',
es: 'Cada disparo cuenta',
      );

  String get timerModeSimpleDescription => _pick(
        fr: 'Un bip après le délai choisi, idéal pour un départ simple.',
        en: 'One beep after the selected delay, ideal for a simple start.',
        de: 'Ein Signalton nach der gewählten Verzögerung, ideal für einen einfachen Start.',
        it: 'Un bip dopo il ritardo selezionato, ideale per una partenza semplice.',
        es: 'Un pitido tras el retraso seleccionado, ideal para una salida simple.',
      );

  String get timerModeParTimeDescription => _pick(
        fr: 'Délai puis fenêtre de tir (Par time) avant le bip final.',
        en: 'Delay then a shooting window (Par time) before the final beep.',
        de: 'Verzögerung, dann ein Schussfenster (Par-Zeit) vor dem letzten Signalton.',
        it: 'Ritardo poi finestra di tiro (Par time) prima del bip finale.',
        es: 'Retraso y luego ventana de tiro (Par time) antes del pitido final.',
      );

  String get timerModeRepeatDescription => _pick(
        fr: 'Plusieurs départs espacés du même délai, pour enchaîner les séries.',
        en: 'Multiple starts separated by the same delay, to chain shooting strings.',
        de: 'Mehrere Starts mit derselben Verzögerung, um Serien hintereinander zu schießen.',
        it: 'Più partenze separate dallo stesso ritardo, per concatenare le serie.',
        es: 'Varias salidas separadas por el mismo retraso, para encadenar series.',
      );

  String get timerModeRandomDelayDescription => _pick(
        fr: 'Délai de départ aléatoire entre 50 % et 100 % du délai choisi.',
        en: 'Random start delay between 50% and 100% of the selected delay.',
        de: 'Zufällige Startverzögerung zwischen 50 % und 100 % der gewählten Zeit.',
        it: 'Ritardo di partenza casuale tra il 50% e il 100% del ritardo scelto.',
        es: 'Retraso de salida aleatorio entre el 50 % y el 100 % del retraso elegido.',
      );

  String get timerModeStartAndMicDescription => _pick(
        fr: 'Un bip de départ après le délai choisi, puis le compteur tourne jusqu’à la détonation (ou arrêt manuel).',
        en: 'A start beep after the selected delay, then the timer runs until the shot (or manual stop).',
        de: 'Ein Startsignalton nach der gewählten Verzögerung, dann läuft der Timer bis zum Schuss (oder manueller Stopp).',
        it: 'Un bip di partenza dopo il ritardo scelto, poi il timer continua fino allo sparo (o stop manuale).',
        es: 'Un pitido de salida tras el retraso elegido, luego el temporizador sigue hasta el disparo (o parada manual).',
      );

  String get timerModeStartAndShotsDescription => _pick(
        fr: 'Un bip de départ après le délai choisi, puis le micro enregistre chaque coup et affiche les temps jusqu’au stop.',
        en: 'A start beep after the selected delay, then the mic records each shot time until you stop.',
        de: 'Ein Startsignalton nach der gewählten Verzögerung, dann zeichnet das Mikro jeden Schusszeitpunkt bis zum Stopp auf.',
        it: 'Un bip di partenza dopo il ritardo scelto, poi il micro registra ogni tempo di colpo fino allo stop.',
        es: 'Un pitido de salida tras el retraso elegido, luego el mic registra cada tiempo de disparo hasta detener.',
      );

  String get timerModeSimpleExample => _pick(
        fr: 'Ex: Face à la cible, tu fixes un délai avant départ, au bip tu dégaines et tire un coup.',
        en: 'Ex: Facing the target, set a start delay. On the beep, draw and fire one shot.',
        de: 'Bsp.: Du stehst vor dem Ziel und stellst eine Startverzögerung ein. Beim Signalton ziehst du und gibst einen Schuss ab.',
        it: 'Es: Di fronte al bersaglio, imposti un ritardo di partenza. Al bip estrai e spari un colpo.',
        es: 'Ej: Frente al blanco, ajustas un retardo de salida. Al pitido desenfundas y disparas un tiro.',
      );

  String get timerModeParTimeExample => _pick(
        fr: 'Ex: Au bip tu as X secondes pour déclencher X cartouches avant le second bip.',
        en: 'Ex: On the beep, you have X seconds to fire X rounds before the second beep.',
        de: 'Bsp.: Beim Signalton hast du X Sekunden, um X Schüsse abzugeben, bevor der zweite Signalton ertönt.',
        it: 'Es: Al bip hai X secondi per sparare X colpi prima del secondo bip.',
        es: 'Ej: Al pitido tienes X segundos para disparar X cartuchos antes del segundo pitido.',
      );

  String get timerModeRepeatExample => _pick(
        fr: 'Ex: Au bip tu as X secondes pour déclencher X cartouches au pistolet avant le second bip. Le cycle redémarre tu as X secondes pour déclencher X cartouches au fusil etc...',
        en: 'Ex: On the beep, you have X seconds to fire X rounds with the pistol before the second beep. The cycle restarts: you have X seconds to fire X rounds with the rifle, etc.',
        de: 'Bsp.: Beim Signalton hast du X Sekunden, um X Schüsse mit der Pistole abzugeben, bevor der zweite Signalton ertönt. Dann startet der Zyklus erneut: X Sekunden für X Schüsse mit dem Gewehr usw.',
        it: 'Es: Al bip hai X secondi per sparare X colpi con la pistola prima del secondo bip. Il ciclo riparte: hai X secondi per sparare X colpi con il fucile, ecc.',
        es: 'Ej: Al pitido tienes X segundos para disparar X cartuchos con la pistola antes del segundo pitido. El ciclo se reinicia: tienes X segundos para disparar X cartuchos con el fusil, etc.',
      );

  String get timerModeRandomDelayExample => _pick(
        fr: 'Ex: Au bip, le timer se déclenche aléatoirement, tu dégaines et tu tires.',
        en: 'Ex: On the beep, the timer triggers randomly. Draw and fire.',
        de: 'Bsp.: Beim Signalton wird der Start zufällig ausgelöst. Zieh und schieß.',
        it: 'Es: Al bip, la partenza avviene in modo casuale. Estrai e spara.',
        es: 'Ej: Al pitido, el inicio se dispara aleatoriamente. Desenfundas y disparas.',
      );

  String get timerModeStartAndMicExample => _pick(
        fr: 'Ex: Au bip, tu dégaines et tu tires, le téléphone enregistre le coup de feu et te donne le temps de réaction en secondes.',
        en: 'Ex: On the beep, draw and fire. The phone detects the shot and gives your reaction time in seconds.',
        de: 'Bsp.: Beim Signalton ziehst du und schießt. Das Telefon erkennt den Schuss und gibt dir deine Reaktionszeit in Sekunden.',
        it: 'Es: Al bip estrai e spari. Il telefono rileva lo sparo e ti dà il tempo di reazione in secondi.',
        es: 'Ej: Al pitido desenfundas y disparas. El teléfono detecta el disparo y te da el tiempo de reacción en segundos.',
      );

  String get timerModeStartAndShotsExample => _pick(
        fr: 'Ex: Au bip, tu dégaines, tu tires, chaque coup de feu est enregistré.',
        en: 'Ex: On the beep, draw and fire. Each shot is detected and recorded.',
        de: 'Bsp.: Beim Signalton ziehst du und schießt. Jeder Schuss wird erkannt und aufgezeichnet.',
        it: 'Es: Al bip estrai e spari. Ogni colpo viene rilevato e registrato.',
        es: 'Ej: Al pitido desenfundas y disparas. Cada disparo se detecta y se registra.',
      );

  String get timerShotTimesTitle => _pick(
        fr: 'Temps enregistrés',
        en: 'Recorded times',
        de: 'Aufgezeichnete Zeiten',
        it: 'Tempi registrati',
        es: 'Tiempos registrados',
      );

  String get timerMicDisclaimerShort => _pick(
        fr: 'Le micro est utilisé uniquement pendant ce mode pour écouter une détonation. Aucun son n’est enregistré ni envoyé.',
        en: 'The microphone is used only in this mode to listen for a shot. No audio is recorded or sent.',
        de: 'Das Mikrofon wird nur in diesem Modus verwendet, um einen Schuss zu erkennen. Es wird kein Audio aufgezeichnet oder übertragen.',
        it: 'Il microfono viene usato solo in questa modalità per rilevare uno sparo. Nessun audio viene registrato o inviato.',
        es: 'El micrófono se usa solo en este modo para detectar un disparo. No se graba ni se envía audio.',
      );

  String get diagnosticToolSubtitle => _pick(
        fr: 'Analyse guidée des incidents de tir.',
        en: 'Guided analysis of shooting incidents.',
        de: 'Geführte Analyse von Schießzwischenfällen.',
        it: 'Analisi guidata degli incidenti di tiro.',
        es: 'Análisis guiado de incidentes de tiro.',
      );

  String get timerStartDelayLabel => _pick(
        fr: 'Délai avant départ (s)',
        en: 'Start delay (s)',
        de: 'Startverzögerung (s)',
        it: 'Ritardo di avvio (s)',
        es: 'Retardo de inicio (s)',
      );

  String get timerParTimeLabel => _pick(
        fr: 'Fenêtre de tir (Par time, s)',
        en: 'Shooting window (Par time, s)',
        de: 'Schussfenster (Par-Zeit, s)',
        it: 'Finestra di tiro (Par time, s)',
        es: 'Ventana de tiro (Par time, s)',
      );

  String get timerCycleDurationLabel => _pick(
        fr: "Durée d'un cycle (s)",
        en: 'Cycle duration (s)',
        de: 'Zyklusdauer (s)',
        it: 'Durata di un ciclo (s)',
        es: 'Duración de un ciclo (s)',
      );

  String get timerRepetitionsLabel => _pick(
        fr: 'Nombre de répétitions',
        en: 'Number of repetitions',
        de: 'Anzahl Wiederholungen',
        it: 'Numero di ripetizioni',
        es: 'Número de repeticiones',
      );

  String get timerRandomBaseLabel => _pick(
        fr: 'Base de délai aléatoire (s)',
        en: 'Random delay base (s)',
        de: 'Basis für Zufallsverzögerung (s)',
        it: 'Base ritardo casuale (s)',
        es: 'Base de retraso aleatorio (s)',
      );

  String get timerEnableSound => _pick(
        fr: 'Activer le bip puissant',
        en: 'Enable loud beep',
        de: 'Lauten Signalton aktivieren',
        it: 'Abilita bip potente',
        es: 'Activar pitido fuerte',
      );

  String get timerEnableVibration => _pick(
        fr: 'Activer la vibration',
        en: 'Enable vibration',
        de: 'Vibration aktivieren',
        it: 'Abilita vibrazione',
        es: 'Activar vibración',
      );

  String get timerEnableShotDetection => _pick(
        fr: 'Activer la détection du son du tir',
        en: 'Enable shot sound detection',
        de: 'Erkennung des Schussgeräuschs aktivieren',
        it: 'Abilita rilevamento del suono dello sparo',
        es: 'Activar detección de sonido de disparo',
      );

  String get timerShotSensitivityLabel => _pick(
        fr: 'Sensibilité de détection',
        en: 'Detection sensitivity',
        de: 'Erkennungsempfindlichkeit',
        it: 'Sensibilità di rilevamento',
        es: 'Sensibilidad de detección',
      );

  String get timerSensitivityCoarse => _pick(
        fr: 'Sourd',
        en: 'Coarse',
        de: 'Grob',
        it: 'Grossolana',
        es: 'Baja',
      );

  String get timerSensitivityBalanced => _pick(
        fr: 'Normal',
        en: 'Balanced',
        de: 'Ausgewogen',
        it: 'Bilanciata',
        es: 'Normal',
      );

  String get timerSensitivityFine => _pick(
        fr: 'Fine',
        en: 'Fine',
        de: 'Fein',
        it: 'Fine',
        es: 'Fina',
      );

  String get timerSensitivityHint => _pick(
        fr: 'Plus la sensibilité est fine, plus la détection peut réagir aux bruits ambiants.',
        en: 'The finer the sensitivity, the more it may react to ambient noise.',
        de: 'Je feiner die Empfindlichkeit, desto eher kann die Erkennung auf Umgebungsgeräusche reagieren.',
        it: 'Più la sensibilità è fine, più il rilevamento può reagire ai rumori ambientali.',
        es: 'Cuanto más fina la sensibilidad, más puede reaccionar al ruido ambiental.',
      );

  String get timerMicDisclaimer => _pick(
        fr: 'Le micro est utilisé uniquement sur l’appareil pour détecter les pics sonores. Aucun son n’est envoyé à l’extérieur. Les performances de détection peuvent varier selon le stand et l’arme utilisée.',
        en: 'The microphone is used only on-device to detect sound peaks. No audio is sent outside the app. Detection performance may vary depending on range and firearm.',
        de: 'Das Mikrofon wird nur auf dem Gerät verwendet, um Schalldruckspitzen zu erkennen. Es wird kein Audio nach außen gesendet. Die Erkennung kann je nach Schießstand und Waffe variieren.',
        it: 'Il microfono è utilizzato solo sul dispositivo per rilevare i picchi sonori. Nessun audio viene inviato all’esterno. Le prestazioni di rilevamento possono variare a seconda del poligono e dell’arma.',
        es: 'El micrófono se usa solo en el dispositivo para detectar picos de sonido. No se envía audio fuera de la app. El rendimiento de detección puede variar según el campo y el arma.',
      );

  String get timerMicPermissionDenied => _pick(
        fr: 'La détection sonore nécessite l’autorisation micro.',
        en: 'Shot detection requires microphone permission.',
        de: 'Die Schusserkennung erfordert die Mikrofonberechtigung.',
        it: 'Il rilevamento degli spari richiede l’autorizzazione al microfono.',
        es: 'La detección de disparos requiere permiso de micrófono.',
      );

  String get timerStatusReady => _pick(
        fr: 'Prêt',
        en: 'Ready',
        de: 'Bereit',
        it: 'Pronto',
        es: 'Listo',
      );

  String get timerStatusRunning => _pick(
        fr: 'En cours',
        en: 'Running',
        de: 'Läuft',
        it: 'In esecuzione',
        es: 'En curso',
      );

  String get timerStatusFinished => _pick(
        fr: 'Terminé',
        en: 'Finished',
        de: 'Beendet',
        it: 'Terminato',
        es: 'Terminado',
      );

  String get timerStartButton => _pick(
        fr: 'Démarrer',
        en: 'Start',
        de: 'Start',
        it: 'Avvia',
        es: 'Iniciar',
      );

  String get timerPauseButton => _pick(
        fr: 'PAUSE',
        en: 'PAUSE',
        de: 'PAUSE',
        it: 'PAUSE',
        es: 'PAUSE',
      );

  String get timerResumeButton => _pick(
        fr: 'REPRENDRE',
        en: 'RESUME',
        de: 'FORTSETZEN',
        it: 'RIPRENDI',
        es: 'REANUDAR',
      );

  String get timerStopButton => _pick(
        fr: 'Arrêter',
        en: 'Stop',
        de: 'Stopp',
        it: 'Stop',
        es: 'Detener',
      );

  String get timerStatusPaused => _pick(
        fr: 'En pause',
        en: 'Paused',
        de: 'Pausiert',
        it: 'In pausa',
        es: 'En pausa',
      );

  String get timerResetButton => _pick(
fr: 'Relancer',
en: 'Restart',
de: 'Neu starten',
it: 'Riavviare',
es: 'Reiniciar',
      );

  String get homeVersionProLabel => _pick(
        fr: 'Version PRO',
        en: 'Pro version',
        de: 'PRO-Version',
        it: 'Versione PRO',
        es: 'Versión PRO',
      );

  String get homeVersionFreeLabel => _pick(
        fr: 'Version gratuite',
        en: 'Free version',
        de: 'Kostenlose Version',
        it: 'Versione gratuita',
        es: 'Versión gratuita',
      );

  String get shortcutsGroupTitle => _pick(
        fr: 'RACCOURCIS ACCUEIL (MAX 4)',
        en: 'HOME SHORTCUTS (MAX 4)',
        de: 'STARTSEITENKÜRZEL (MAX 4)',
        it: 'SCORCIATOIE HOME (MAX 4)',
        es: 'ATAJOS INICIO (MÁX 4)',
      );

  String get shortcutNewSession => _pick(
        fr: 'Nouvelle séance',
        en: 'New session',
        de: 'Neue Trainingseinheit',
        it: 'Nuova sessione',
        es: 'Nueva sesión',
      );

  String get shortcutNewWeapon => _pick(
        fr: 'Nouvelle arme',
        en: 'New weapon',
        de: 'Neue Waffe',
        it: 'Nuova arma',
        es: 'Nueva arma',
      );

  String get shortcutNewAmmo => _pick(
        fr: 'Nouvelle munition',
        en: 'New ammo',
        de: 'Neue Munition',
        it: 'Nuova munizione',
        es: 'Nueva munición',
      );

  String get shortcutNewAccessory => _pick(
        fr: 'Nouvel accessoire',
        en: 'New accessory',
        de: 'Neues Zubehör',
        it: 'Nuovo accessorio',
        es: 'Nuevo accesorio',
      );

  String get shortcutToggleTheme => _pick(
        fr: 'Basculer Mode Nuit',
        en: 'Toggle dark mode',
        de: 'Dunkelmodus umschalten',
        it: 'Attiva/disattiva tema scuro',
        es: 'Alternar modo oscuro',
      );

  String get shortcutTimer => _pick(
        fr: 'Timer de tir',
        en: 'Shooting timer',
        de: 'Schieß-Timer',
        it: 'Timer di tiro',
        es: 'Temporizador de tiro',
      );

  String get quickActionLabelTheme => _pick(
        fr: 'Mode nuit',
        en: 'Dark mode',
        de: 'Dunkelmodus',
        it: 'Modalità scura',
        es: 'Modo oscuro',
      );

  String get securityGroupTitle => _pick(
        fr: 'SÉCURITÉ',
        en: 'SECURITY',
        de: 'SICHERHEIT',
        it: 'SICUREZZA',
        es: 'SEGURIDAD',
      );

  String get pinCodeLabel => _pick(
        fr: 'Code PIN',
        en: 'PIN code',
        de: 'PIN-Code',
        it: 'Codice PIN',
        es: 'Código PIN',
      );

  String get biometricLabel => _pick(
        fr: 'Face ID / Touch ID',
        en: 'Face ID / Touch ID',
        de: 'Face ID / Touch ID',
        it: 'Face ID / Touch ID',
        es: 'Face ID / Touch ID',
      );

  String get statusEnabled => _pick(
        fr: 'Activé',
        en: 'Enabled',
        de: 'Aktiviert',
        it: 'Attivato',
        es: 'Activado',
      );

  String get statusDisabled => _pick(
        fr: 'Désactivé',
        en: 'Disabled',
        de: 'Deaktiviert',
        it: 'Disattivato',
        es: 'Desactivado',
      );

  String get pinDisabledSnack => _pick(
        fr: 'Code PIN désactivé',
        en: 'PIN code disabled',
        de: 'PIN-Code deaktiviert',
        it: 'Codice PIN disattivato',
        es: 'Código PIN desactivado',
      );

  String get biometricRequiresPinSnack => _pick(
        fr: "Veuillez d'abord configurer un code PIN",
        en: 'Please configure a PIN code first',
        de: 'Bitte richte zuerst einen PIN-Code ein',
        it: 'Configura prima un codice PIN',
        es: 'Configura primero un código PIN',
      );

  String biometricStatusChangedSnack(bool enabled) => enabled
      ? _pick(
          fr: 'Authentification biométrique activée',
          en: 'Biometric authentication enabled',
          de: 'Biometrische Authentifizierung aktiviert',
          it: 'Autenticazione biometrica attivata',
          es: 'Autenticación biométrica activada',
        )
      : _pick(
          fr: 'Authentification biométrique désactivée',
          en: 'Biometric authentication disabled',
          de: 'Biometrische Authentifizierung deaktiviert',
          it: 'Autenticazione biometrica disattivata',
          es: 'Autenticación biométrica desactivada',
        );

  String get supportGroupTitle => _pick(
        fr: 'SUPPORT & SÉCURITÉ',
        en: 'SUPPORT & SECURITY',
        de: 'SUPPORT & SICHERHEIT',
        it: 'SUPPORTO & SICUREZZA',
        es: 'SOPORTE Y SEGURIDAD',
      );

  // Contact / Support
  String get contactMeLabel => _pick(
        fr: 'Nous contacter',
        en: 'Contact us',
        de: 'Kontaktieren Sie uns',
        it: 'Contattaci',
        es: 'Contáctanos',
      );

  String get contactMeSubtitle => _pick(
        fr: 'Partenariat ou Support',
        en: 'Partnership or Support',
        de: 'Partnerschaft oder Support',
        it: 'Partnership o Supporto',
        es: 'Colaboración o Soporte',
      );

  String get contactPartnership => _pick(
        fr: 'Demande de partenariat',
        en: 'Partnership request',
        de: 'Partnerschaftsanfrage',
        it: 'Richiesta di partnership',
        es: 'Solicitud de colaboración',
      );

  String get contactSupport => _pick(
        fr: 'Contacter le support',
        en: 'Contact support',
        de: 'Support kontaktieren',
        it: 'Contatta il supporto',
        es: 'Contactar soporte',
      );

  String get contactSubjectPartnership => _pick(
        fr: 'Demande de partenariat - THOT',
        en: 'Partnership request - THOT',
        de: 'Partnerschaftsanfrage - THOT',
        it: 'Richiesta di partnership - THOT',
        es: 'Solicitud de colaboración - THOT',
      );

  String get contactSubjectSupport => _pick(
        fr: 'Support - THOT',
        en: 'Support - THOT',
        de: 'Support - THOT',
        it: 'Supporto - THOT',
        es: 'Soporte - THOT',
      );

  // Achievements sorting
  String get achievementsSortRecent => _pick(
        fr: 'Plus récents',
        en: 'Most recent',
        de: 'Neueste zuerst',
        it: 'Più recenti',
        es: 'Más recientes',
      );

  String get achievementsSortOldest => _pick(
        fr: 'Plus anciens',
        en: 'Oldest first',
        de: 'Älteste zuerst',
        it: 'Più vecchi',
        es: 'Más antiguos',
      );

  String get achievementsSortLevelHigh => _pick(
        fr: "Niveau élevé d'abord",
        en: 'Higher tier first',
        de: 'Höherer Rang zuerst',
        it: 'Livello alto prima',
        es: 'Nivel alto primero',
      );

  String get achievementsSortLevelLow => _pick(
        fr: "Niveau bas d'abord",
        en: 'Lower tier first',
        de: 'Niedriger Rang zuerst',
        it: 'Livello basso prima',
        es: 'Nivel bajo primero',
      );

  String get exportPdfLabel => _pick(
        fr: 'Exporter mes données (PDF)',
        en: 'Export my data (PDF)',
        de: 'Meine Daten exportieren (PDF)',
        it: 'Esporta i miei dati (PDF)',
        es: 'Exportar mis datos (PDF)',
      );

  String get exportPdfSubtitlePremium => _pick(
        fr: 'Export complet de votre carnet',
        en: 'Full export of your logbook',
        de: 'Vollständiger Export Ihres Schießbuchs',
        it: 'Esportazione completa del tuo registro',
        es: 'Exportación completa de tu cuaderno',
      );

  String get exportPdfSubtitleProOnly => _pick(
        fr: 'Fonctionnalité Pro',
        en: 'Pro feature',
        de: 'Pro-Funktion',
        it: 'Funzione Pro',
        es: 'Función Pro',
      );

  String get dataPrivacyLabel => _pick(
        fr: 'Données & confidentialité',
        en: 'Data & privacy',
        de: 'Daten & Datenschutz',
        it: 'Dati & privacy',
        es: 'Datos y privacidad',
      );

  String get dataPrivacySubtitle => _pick(
        fr: 'Chiffrement AES-256 · Zéro serveur · 100% local',
        en: 'AES-256 encryption · Zero server · 100% local',
        de: 'AES-256-Verschlüsselung · Kein Server · 100% lokal',
        it: 'Crittografia AES-256 · Zero server · 100% locale',
        es: 'Cifrado AES-256 · Sin servidor · 100% local',
      );

  String get aboutLabel => _pick(
        fr: 'À propos & confidentialité',
        en: 'About & privacy',
        de: 'Über & Datenschutz',
        it: 'Informazioni & privacy',
        es: 'Acerca de y privacidad',
      );

  String get aboutSubtitle => _pick(
        fr: 'Mentions légales, CGU, politique de confidentialité',
        en: 'Legal, Terms of Use, Privacy Policy',
        de: 'Impressum, Nutzungsbedingungen, Datenschutzrichtlinie',
        it: 'Note legali, Termini d’uso, Informativa privacy',
        es: 'Aviso legal, Términos de uso, Política de privacidad',
      );

  // --- Home screen ---


  String get statisticsPageTitle => _pick(
        fr: 'STATISTIQUES',
        en: 'STATISTICS',
        de: 'STATISTIKEN',
        it: 'STATISTICHE',
        es: 'ESTADÍSTICAS',
      );

  String get statisticsPageSubtitle => _pick(
        fr: 'VUE GLOBALE',
        en: 'OVERVIEW',
        de: 'GESAMTANSICHT',
        it: 'PANORAMICA',
        es: 'VISTA GENERAL',
      );

  String get statisticsGlobalSummaryTitle => _pick(
        fr: 'RÉSUMÉ GLOBAL',
        en: 'GLOBAL SUMMARY',
        de: 'GESAMTZUSAMMENFASSUNG',
        it: 'RIEPILOGO GENERALE',
        es: 'RESUMEN GLOBAL',
      );

  String get statisticsSessionsLabel => _pick(
        fr: 'Séances',
        en: 'Sessions',
        de: 'Sitzungen',
        it: 'Sessioni',
        es: 'Sesiones',
      );

  String get statisticsShotsFiredLabel => _pick(
        fr: 'Coups tirés',
        en: 'Shots fired',
        de: 'Schüsse',
        it: 'Colpi sparati',
        es: 'Disparos',
      );

  String get statisticsWeaponsLabel => _pick(
        fr: 'Armes',
        en: 'Weapons',
        de: 'Waffen',
        it: 'Armi',
        es: 'Armas',
      );

  String get statisticsAmmosLabel => _pick(
        fr: 'Munitions',
        en: 'Ammunition',
        de: 'Munition',
        it: 'Munizioni',
        es: 'Munición',
      );

  String get statisticsAccessoriesLabel => _pick(
        fr: 'Accessoires',
        en: 'Accessories',
        de: 'Zubehör',
        it: 'Accessori',
        es: 'Accesorios',
      );

  String get statisticsShotsPerSessionLabel => _pick(
fr: 'Cps / séance',
en: 'Shots / sess.',
de: 'Sch. / Serie',
it: 'Colpi / sess.',
es: 'Disp. / sesión',
      );

  String get statisticsPrecisionTitle => _pick(
        fr: 'PRÉCISION',
        en: 'PRECISION',
        de: 'PRÄZISION',
        it: 'PRECISIONE',
        es: 'PRECISIÓN',
      );

  String get statisticsAveragePrecisionLabel => _pick(
        fr: 'Précision moyenne',
        en: 'Average precision',
        de: 'Durchschnittliche Präzision',
        it: 'Precisione media',
        es: 'Precisión media',
      );

  String get statisticsPerfectSessionsLabel => _pick(
        fr: 'Séances à 100%',
        en: '100% sessions',
        de: '100%-Sitzungen',
        it: 'Sessioni al 100%',
        es: 'Sesiones al 100%',
      );

  String get statisticsBestSessionLabel => _pick(
        fr: 'Meilleure séance',
        en: 'Best session',
        de: 'Beste Sitzung',
        it: 'Migliore sessione',
        es: 'Mejor sesión',
      );

  String get statisticsBestSessionDateLabel => _pick(
        fr: 'Date meilleure',
        en: 'Best date',
        de: 'Bestes Datum',
        it: 'Data migliore',
        es: 'Mejor fecha',
      );

  String get statisticsRhythmTitle => _pick(
        fr: 'RYTHME',
        en: 'PACE',
        de: 'RHYTHMUS',
        it: 'RITMO',
        es: 'RITMO',
      );

  String get statisticsThisWeekLabel => _pick(
        fr: 'Cette semaine',
        en: 'This week',
        de: 'Diese Woche',
        it: 'Questa settimana',
        es: 'Esta semana',
      );

  String get statisticsThisMonthLabel => _pick(
        fr: 'Ce mois',
        en: 'This month',
        de: 'Diesen Monat',
        it: 'Questo mese',
        es: 'Este mes',
      );

  String get statisticsExercisesPerSessionLabel => _pick(
        fr: 'Exercices / séance',
        en: 'Exercises / session',
        de: 'Übungen / Sitzung',
        it: 'Esercizi / sessione',
        es: 'Ejercicios / sesión',
      );

  String get statisticsSessionsWithPrecisionLabel => _pick(
        fr: 'Séances avec précision',
        en: 'Sessions with precision',
        de: 'Sitzungen mit Präzision',
        it: 'Sessioni con precisione',
        es: 'Sesiones con precisión',
      );

  String get statisticsMaintenanceTitle => _pick(
        fr: 'MAINTENANCE',
        en: 'MAINTENANCE',
        de: 'WARTUNG',
        it: 'MANUTENZIONE',
        es: 'MANTENIMIENTO',
      );

  String get statisticsCleaningsLabel => _pick(
        fr: 'Entretiens',
        en: 'Cleanings',
        de: 'Reinigungen',
        it: 'Pulizie',
        es: 'Limpiezas',
      );

  String get statisticsRevisionsLabel => _pick(
        fr: 'Révisions',
        en: 'Revisions',
        de: 'Revisionen',
        it: 'Revisioni',
        es: 'Revisiones',
      );

  String get statisticsClosestRevisionWeaponLabel => _pick(
        fr: 'Arme la plus proche d’une révision',
        en: 'Weapon closest to revision',
        de: 'Waffe am nächsten an einer Revision',
        it: 'Arma più vicina alla revisione',
        es: 'Arma más cercana a revisión',
      );

  String get statisticsClosestCleaningWeaponLabel => _pick(
        fr: 'Arme la plus proche d’un entretien',
        en: 'Weapon closest to cleaning',
        de: 'Waffe am nächsten an einer Reinigung',
        it: 'Arma più vicina alla pulizia',
        es: 'Arma más cercana al mantenimiento',
      );

  String get statisticsSmartIndicatorsTitle => _pick(
        fr: 'INDICATEURS INTELLIGENTS',
        en: 'SMART INDICATORS',
        de: 'INTELLIGENTE INDIKATOREN',
        it: 'INDICATORI INTELLIGENTI',
        es: 'INDICADORES INTELIGENTES',
      );

  String get statisticsMostUsedWeaponLabel => _pick(
        fr: 'Arme la plus utilisée',
        en: 'Most used weapon',
        de: 'Am häufigsten verwendete Waffe',
        it: 'Arma più usata',
        es: 'Arma más usada',
      );

  String get statisticsMostCriticalAmmoLabel => _pick(
        fr: 'Munition la plus critique',
        en: 'Most critical ammo',
        de: 'Kritischste Munition',
        it: 'Munizione più critica',
        es: 'Munición más crítica',
      );

  String get statisticsLongestSessionLabel => _pick(
        fr: 'Séance la plus dense',
        en: 'Most intense session',
        de: 'Intensivste Sitzung',
        it: 'Sessione più intensa',
        es: 'Sesión más intensa',
      );

  String get statisticsLastSessionLabel => _pick(
        fr: 'Dernière séance',
        en: 'Last session',
        de: 'Letzte Sitzung',
        it: 'Ultima sessione',
        es: 'Última sesión',
      );

  String statisticsSmartIndicatorShotsValue(int shots) => _pick(
        fr: '$shots ${shots > 1 ? 'coups' : 'coup'}',
        en: '$shots ${shots == 1 ? 'shot' : 'shots'}',
        de: '$shots ${shots == 1 ? 'Schuss' : 'Schüsse'}',
        it: '$shots ${shots == 1 ? 'colpo' : 'colpi'}',
        es: '$shots ${shots == 1 ? 'disparo' : 'disparos'}',
      );

  String statisticsSmartIndicatorAmmoValue(
    int remaining,
    int threshold,
  ) =>
      _pick(
        fr: '$remaining restantes / seuil $threshold',
        en: '$remaining remaining / threshold $threshold',
        de: '$remaining verbleibend / Schwelle $threshold',
        it: '$remaining rimanenti / soglia $threshold',
        es: '$remaining restantes / umbral $threshold',
      );

  String get statisticsShotsChartTitle => _pick(
        fr: 'Nombre de tirs',
        en: 'Number of shots',
        de: 'Anzahl der Schüsse',
        it: 'Numero di colpi',
        es: 'Número de disparos',
      );

  String get statisticsSessionsChartTitle => _pick(
        fr: 'Nombre de séances',
        en: 'Number of sessions',
        de: 'Anzahl der Sitzungen',
        it: 'Numero di sessioni',
        es: 'Número de sesiones',
      );

  String get statisticsWeaponsByTypeTitle => _pick(
        fr: 'RÉPARTITION PAR TYPE D\'ARME',
        en: 'WEAPONS BY TYPE',
        de: 'WAFFEN NACH TYP',
        it: 'ARMI PER TIPO',
        es: 'ARMAS POR TIPO',
      );

  String get diagnosticDisclaimerTitle => _pick(
        fr: 'Avertissement avant diagnostique',
        en: 'Diagnostic warning',
        de: 'Warnhinweis vor der Diagnose',
        it: 'Avvertenza prima della diagnostica',
        es: 'Advertencia antes del diagnóstico',
      );

  String get diagnosticDisclaimerBody => _pick(
        fr: "Cet outil ne peut pas se substituer à l’expertise d’un armurier qualifié. Toute manipulation d’une arme doit être effectuée dans le strict respect des règles de sécurité. Les résultats fournis par le diagnostique ne constituent qu’une piste de recherche d’incident et ne remplacent ni une inspection physique, ni un contrôle professionnel.",
        en: 'This tool cannot replace the expertise of a qualified gunsmith. Any handling of a firearm must be performed in strict compliance with safety rules. The results provided by the diagnostic are only a troubleshooting lead and do not replace a physical inspection or professional assessment.',
        de: 'Dieses Werkzeug ersetzt nicht die Expertise eines qualifizierten Büchsenmachers. Jede Handhabung einer Waffe muss unter strikter Einhaltung der Sicherheitsregeln erfolgen. Die Diagnoseergebnisse stellen lediglich einen Ansatz zur Fehlersuche dar und ersetzen weder eine physische Inspektion noch eine fachliche Prüfung.',
        it: "Questo strumento non può sostituire l'esperienza di un armaiolo qualificato. Qualsiasi manipolazione di un'arma deve essere effettuata nel rigoroso rispetto delle regole di sicurezza. I risultati forniti dalla diagnostica costituiscono solo una pista di ricerca del guasto e non sostituiscono né un'ispezione fisica né una verifica professionale.",
        es: 'Esta herramienta no puede sustituir la experiencia de un armero cualificado. Cualquier manipulación de un arma debe realizarse respetando estrictamente las normas de seguridad. Los resultados proporcionados por el diagnóstico solo constituyen una pista de investigación del incidente y no sustituyen una inspección física ni una evaluación profesional.',
      );

  String get diagnosticDisclaimerConfirm => _pick(
        fr: 'Je comprends',
        en: 'I understand',
        de: 'Ich verstehe',
        it: 'Ho capito',
        es: 'Entiendo',
      );

  String get legalInfoTitle => _pick(
        fr: 'Documents & informations légales',
        en: 'Legal documents & information',
        de: 'Rechtliche Dokumente & Informationen',
        it: 'Documenti e informazioni legali',
        es: 'Documentos e información legal',
      );

  String get legalInfoSubtitle => _pick(
        fr: "Tout le contenu ci-dessous est affiché directement dans l'application.",
        en: 'All content below is displayed directly in the application.',
        de: 'Der gesamte untenstehende Inhalt wird direkt in der Anwendung angezeigt.',
        it: "Tutto il contenuto seguente è visualizzato direttamente nell'applicazione.",
        es: 'Todo el contenido a continuación se muestra directamente en la aplicación.',
      );

  String get legalAboutTitle => _pick(
        fr: 'À propos de THOT',
        en: 'About THOT',
        de: 'Über THOT',
        it: 'Informazioni su THOT',
        es: 'Acerca de THOT',
      );

  String get legalPresentationTitle => _pick(
        fr: 'Présentation',
        en: 'Overview',
        de: 'Vorstellung',
        it: 'Presentazione',
        es: 'Presentación',
      );

  String get legalSupportTitle => _pick(
        fr: 'Support',
        en: 'Support',
        de: 'Support',
        it: 'Supporto',
        es: 'Soporte',
      );

  String get legalCguTitle => _pick(
        fr: "Conditions Générales d’Utilisation (CGU)",
        en: 'Terms of Use',
        de: 'Nutzungsbedingungen',
        it: 'Condizioni generali di utilizzo',
        es: 'Condiciones generales de uso',
      );

  String get legalDiagnosticDisclaimerSectionTitle => _pick(
        fr: 'Diagnostique et sécurité',
        en: 'Diagnostic and safety',
        de: 'Diagnose und Sicherheit',
        it: 'Diagnostica e sicurezza',
        es: 'Diagnóstico y seguridad',
      );

  String get quickActionLabelMillieme => _pick(
fr: 'Formule du millième',
en: 'Mil formula',
de: 'Mil-Formel',
it: 'Formula del mil',
es: 'Fórmula del mil',
      );

  String get milliemeTitle => _pick(
fr: 'Formule du millième',
en: 'Mil formula',
de: 'Mil-Formel',
it: 'Formula del mil',
es: 'Fórmula del mil',
      );

  String get milliemeSubtitle => _pick(
        fr: 'Calculez votre distance de tir en millième',
        en: 'Calculate your shooting distance in mils',
        de: 'Berechnen Sie Ihre Schussdistanz in Mil',
        it: 'Calcola la tua distanza di tiro in mil',
        es: 'Calcula tu distancia de tiro en mil',
      );

  String get milliemeLabelDistance => _pick(
        fr: 'Distance',
        en: 'Distance',
        de: 'Entfernung',
        it: 'Distanza',
        es: 'Distancia',
      );

  String get milliemeLabelHeight => _pick(
        fr: 'Hauteur',
        en: 'Height',
        de: 'Höhe',
        it: 'Altezza',
        es: 'Altura',
      );

  String get milliemeLabelMil => _pick(
        fr: 'Mil',
        en: 'Mil',
        de: 'Mil',
        it: 'Mil',
        es: 'Mil',
      );

  String get milliemeHelpText => _pick(
        fr: 'Entrez la distance et la hauteur pour obtenir la valeur en mil',
        en: 'Enter the distance and height to get the mil value',
        de: 'Geben Sie die Entfernung und Höhe ein, um den Mil-Wert zu erhalten',
        it: 'Inserisci la distanza e l\'altezza per ottenere il valore in mil',
        es: 'Ingrese la distancia y la altura para obtener el valor en mil',
      );

  String get milliemeResetLabel => _pick(
        fr: 'Réinitialiser',
        en: 'Reset',
        de: 'Zurücksetzen',
        it: 'Reimpostare',
        es: 'Reiniciar',
      );

  String get milliemeResetConfirmationLabel => _pick(
        fr: 'Voulez-vous réinitialiser les valeurs?',
        en: 'Do you want to reset the values?',
        de: 'Möchten Sie die Werte zurücksetzen?',
        it: 'Vuoi reimpostare i valori?',
        es: '¿Quiere reiniciar los valores?',
      );

  // --- Sessions ---

  String get sessionsSubtitle => _pick(
        fr: 'SÉANCES',
        en: 'SESSIONS',
        de: 'SITZUNGEN',
        it: 'SESSIONI',
        es: 'SESIONES',
      );

  String get newSessionCta => _pick(
        fr: 'Nouvelle séance',
        en: 'New session',
        de: 'Neue Sitzung',
        it: 'Nuova sessione',
        es: 'Nueva sesión',
      );

  String get sessionsFilterAll => _pick(
        fr: 'Toutes',
        en: 'All',
        de: 'Alle',
        it: 'Tutte',
        es: 'Todas',
      );

  String get sessionsFilterMonth => _pick(
        fr: 'Mois',
        en: 'Month',
        de: 'Monat',
        it: 'Mese',
        es: 'Mes',
      );

  String get sessionsFilter7Days => _pick(
        fr: '7 jours',
        en: '7 days',
        de: '7 Tage',
        it: '7 giorni',
        es: '7 días',
      );

  String get sessionsSearchHint => _pick(
        fr: 'Rechercher par arme, munition, accessoire, jour...',
        en: 'Search by weapon, ammo, accessory, date...',
        de: 'Suche nach Waffe, Munition, Zubehör, Datum...',
        it: 'Cerca per arma, munizioni, accessorio, data...',
        es: 'Buscar por arma, munición, accesorio, fecha...',
      );

  String sessionExerciseDefaultTitle(int index) => _pick(
        fr: 'Exercice $index',
        en: 'Exercise $index',
        de: 'Übung $index',
        it: 'Esercizio $index',
        es: 'Ejercicio $index',
      );

  String get sessionWeaponAndEquipmentDetailsTitle => _pick(
        fr: 'Détails de l’arme et équipement',
        en: 'Weapon and equipment details',
        de: 'Waffen- und Ausrüstungsdetails',
        it: 'Dettagli arma e attrezzatura',
        es: 'Detalles del arma y equipo',
      );

  String get sessionShootingResultsTitle => _pick(
        fr: 'Résultat du tir',
        en: 'Shooting results',
        de: 'Schießergebnisse',
        it: 'Risultati di tiro',
        es: 'Resultados de tiro',
      );

  String get sessionsEmptySearchTitle => _pick(
        fr: 'Aucune séance trouvée',
        en: 'No session found',
        de: 'Keine Sitzung gefunden',
        it: 'Nessuna sessione trovata',
        es: 'No se encontró ninguna sesión',
      );

  String get sessionsEmptySearchSubtitle => _pick(
        fr: 'Essayez une autre recherche',
        en: 'Try another search',
        de: 'Versuche eine andere Suche',
        it: 'Prova un’altra ricerca',
        es: 'Prueba otra búsqueda',
      );

  String get sessionsEmptyPeriodTitle => _pick(
        fr: 'Aucune séance pour cette période',
        en: 'No session for this period',
        de: 'Keine Sitzung in diesem Zeitraum',
        it: 'Nessuna sessione per questo periodo',
        es: 'No hay sesiones para este período',
      );

  String get sessionsEmptyPeriodSubtitle => _pick(
        fr: 'Créez votre première séance',
        en: 'Create your first session',
        de: 'Erstelle deine erste Sitzung',
        it: 'Crea la tua prima sessione',
        es: 'Crea tu primera sesión',
      );

  String get sessionMenuEdit => _pick(
        fr: 'Éditer',
        en: 'Edit',
        de: 'Bearbeiten',
        it: 'Modifica',
        es: 'Editar',
      );

  String get sessionMenuDuplicate => _pick(
        fr: 'Dupliquer',
        en: 'Duplicate',
        de: 'Duplizieren',
        it: 'Duplica',
        es: 'Duplicar',
      );

  String get sessionMenuShare => _pick(
        fr: 'Partager',
        en: 'Share',
        de: 'Teilen',
        it: 'Condividi',
        es: 'Compartir',
      );

  String get sessionMenuDelete => _pick(
        fr: 'Supprimer',
        en: 'Delete',
        de: 'Löschen',
        it: 'Elimina',
        es: 'Eliminar',
      );

  String get newSessionTitle => _pick(
        fr: 'NOUVELLE SÉANCE',
        en: 'NEW SESSION',
        de: 'NEUE SITZUNG',
        it: 'NUOVA SESSIONE',
        es: 'NUEVA SESIÓN',
      );

  String get generalInfoSectionTitle => _pick(
        fr: 'Informations générales',
        en: 'General Information',
        de: 'Allgemeine Informationen',
        it: 'Informazioni generali',
        es: 'Información general',
      );

  String get sessionNameLabel => _pick(
        fr: 'Nom de la séance *',
        en: 'Session name *',
        de: 'Sitzungsname *',
        it: 'Nome sessione *',
        es: 'Nombre de la sesión *',
      );

  String get sessionNameHint => _pick(
        fr: 'Ex: Entraînement hebdomadaire',
        en: 'Ex: Weekly training',
        de: 'Ex: Wöchentliches Training',
        it: 'Ex: Allenamento settimanale',
        es: 'Ej: Entrenamiento semanal',
      );

  String get requiredFieldError => _pick(
        fr: 'Champ obligatoire',
        en: 'Required field',
        de: 'Pflichtfeld',
        it: 'Campo obbligatorio',
        es: 'Campo obligatorio',
      );

  String get sessionDateTimeLabel => _pick(
        fr: 'Date et heure de la séance',
        en: 'Session date and time',
        de: 'Sitzungsdatum und -uhrzeit',
        it: 'Data e ora della sessione',
        es: 'Fecha y hora de la sesión',
      );

  String get locationLabel => _pick(
fr: 'Ville',
en: 'City',
de: 'Stadt',
it: 'Città',
es: 'Ciudad',
      );

  String get locationHint => _pick(
fr: 'Ex. : Club de tir de la ville',
en: 'E.g. City shooting club',
de: 'Z. B. Schützenverein der Stadt',
it: 'Es.: club di tiro della città',
es: 'Ej.: club de tiro de la ciudad',
      );

  String get shootingDistanceLabel => _pick(
        fr: 'Quel stand de tir?',
        en: 'Which shooting lane?',
        de: 'Welche Schießbahn?',
        it: 'Quale linea di tiro?',
        es: '¿Qué puesto de tiro?',
      );

  String get shootingDistanceHint => _pick(
        fr: 'Ex: Stand couvert',
        en: 'E.g. Lane 3',
        de: 'Z. B. Bahn 3',
        it: 'Es.: linea 3',
        es: 'Ej.: puesto 3',
      );

  // --- Exercise editor (new_session_screen) ---

  String get exerciseNameLabel => _pick(
        fr: 'Nom de l\'exercice',
        en: 'Exercise name',
        de: 'Übungsname',
        it: 'Nome esercizio',
        es: 'Nombre del ejercicio',
      );

  String get exerciseNameHint => _pick(
        fr: 'Ex: Groupement à 25 m',
        en: 'Ex: 25 m grouping',
        de: 'Z.B.: 25-m-Gruppe',
        it: 'Es: Rosata a 25 m',
        es: 'Ej: Agrupación a 25 m',
      );

  String get targetNameHint => _pick(
        fr: 'Ex: Cible C50, silhouette, gongs…',
        en: 'Ex: C50 target, silhouette, steel plates…',
        de: 'Z.B.: C50-Scheibe, Silhouette, Stahlziele…',
        it: 'Es: Bersaglio C50, sagoma, gong…',
        es: 'Ej: Diana C50, silueta, gong…',
      );

  String get targetPhotosHint => _pick(
        fr: 'Ajoutez des photos de vos cibles pour suivre vos groupements.',
        en: 'Add photos of your targets to track your groups.',
        de: 'Fügen Sie Fotos Ihrer Scheiben hinzu, um Ihre Gruppen zu verfolgen.',
        it: 'Aggiungi foto dei bersagli per seguire le rosate.',
        es: 'Añade fotos de tus dianas para seguir tus agrupaciones.',
      );

  String get targetPhotoNameLabel => _pick(
        fr: 'Nom de la photo',
        en: 'Photo name',
        de: 'Foto-Name',
        it: 'Nome foto',
        es: 'Nombre de la foto',
      );

  String get removePhoto => _pick(
        fr: 'Supprimer la photo',
        en: 'Remove photo',
        de: 'Foto entfernen',
        it: 'Rimuovi foto',
        es: 'Eliminar foto',
      );

  String get shotsFiredLabel => _pick(
        fr: 'Coups tirés',
        en: 'Shots fired',
        de: 'Schüsse',
        it: 'Colpi sparati',
        es: 'Disparos',
      );

  String get shotsCountLabel => _pick(
        fr: 'Nombre de coups',
        en: 'Number of shots',
        de: 'Anzahl der Schüsse',
        it: 'Numero di colpi',
        es: 'Número de disparos',
      );

  String get shotsFiredError => _pick(
        fr: 'Saisissez un nombre de coups (> 0).',
        en: 'Enter a number of shots (> 0).',
        de: 'Geben Sie eine Anzahl an Schüssen ein (> 0).',
        it: 'Inserisci un numero di colpi (> 0).',
        es: 'Introduce un número de disparos (> 0).',
      );

  String get distanceLabel => _pick(
        fr: 'Distance',
        en: 'Distance',
        de: 'Entfernung',
        it: 'Distanza',
        es: 'Distancia',
      );

  String get distanceError => _pick(
        fr: 'Renseignez une distance valide (> 0).',
        en: 'Enter a valid distance (> 0).',
        de: 'Geben Sie eine gültige Entfernung ein (> 0).',
        it: 'Inserisci una distanza valida (> 0).',
        es: 'Introduce una distancia válida (> 0).',
      );

  String get sessionTypeLabel => _pick(
        fr: 'Type de séance',
        en: 'Session type',
        de: 'Sitzungstyp',
        it: 'Tipo di sessione',
        es: 'Tipo de sesión',
      );

  String get sessionTypePersonal => _pick(
        fr: 'Personnel',
        en: 'Personal',
        de: 'Persönlich',
        it: 'Personale',
        es: 'Personal',
      );

  String get sessionTypeProfessional => _pick(
        fr: 'Professionnel',
        en: 'Professional',
        de: 'Professionell',
        it: 'Professionale',
        es: 'Profesional',
      );

  String get sessionTypeCompetition => _pick(
        fr: 'Compétition',
        en: 'Competition',
        de: 'Wettbewerb',
        it: 'Competizione',
        es: 'Competición',
      );

  String get sessionSummaryTitle => _pick(
        fr: 'Résumé séance',
        en: 'Session summary',
        de: 'Sitzungsübersicht',
        it: 'Riepilogo sessione',
        es: 'Resumen sesión',
      );

  String exerciseCardTitle(int index) => _pick(
        fr: 'Exercice ${index + 1}',
        en: 'Exercise ${index + 1}',
        de: 'Übung ${index + 1}',
        it: 'Esercizio ${index + 1}',
        es: 'Ejercicio ${index + 1}',
      );

  String get exerciseDetailsTitle => _pick(
        fr: "Détails arme & équipement",
        en: 'Weapon & gear details',
        de: 'Waffen- & Ausrüstungsdetails',
        it: 'Dettagli arma e attrezzatura',
        es: 'Detalles de arma y equipo',
      );

  String get shootingResultsTitle => _pick(
        fr: 'Résultats du tir',
        en: 'Shooting results',
        de: 'Schießergebnisse',
        it: 'Risultati di tiro',
        es: 'Resultados del tiro',
      );

  String get borrowedWeaponFallback => _pick(
        fr: 'Arme prêtée',
        en: 'Borrowed weapon',
        de: 'Geliehene Waffe',
        it: 'Arma prestata',
        es: 'Arma prestada',
      );

  String get borrowedAmmoFallback => _pick(
        fr: 'Munition prêtée',
        en: 'Borrowed ammo',
        de: 'Geliehene Munition',
        it: 'Munizione prestata',
        es: 'Munición prestada',
      );

  String get equipmentTitle => _pick(
        fr: 'Équipement',
        en: 'Equipment',
        de: 'Ausrüstung',
        it: 'Attrezzatura',
        es: 'Equipo',
      );

  String get shootingDistanceDetailLabel => _pick(
        fr: 'Distance de tir',
        en: 'Shooting distance',
        de: 'Schussdistanz',
        it: 'Distanza di tiro',
        es: 'Distancia de tiro',
      );

  String sessionSummaryTotalShots(int totalShots) => _pick(
        fr: 'Total des coups tirés : $totalShots',
        en: 'Total shots fired: $totalShots',
        de: 'Gesamtschüsse: $totalShots',
        it: 'Colpi totali sparati: $totalShots',
        es: 'Disparos totales: $totalShots',
      );

  String get sessionSummaryAmmoImpactTitle => _pick(
        fr: 'Impact sur les munitions',
        en: 'Ammo impact',
        de: 'Auswirkung auf Munition',
        it: 'Impatto sulle munizioni',
        es: 'Impacto en municiones',
      );

  String get sessionSummaryWeaponsImpactTitle => _pick(
        fr: 'Impact sur les armes',
        en: 'Weapon impact',
        de: 'Auswirkung auf Waffen',
        it: 'Impatto sulle armi',
        es: 'Impacto en armas',
      );

  String get sessionSummaryAccessoriesImpactTitle => _pick(
        fr: 'Impact sur les accessoires',
        en: 'Accessory impact',
        de: 'Auswirkung auf Zubehör',
        it: 'Impatto sugli accessori',
        es: 'Impacto en accesorios',
      );

  String sessionSummaryAmmoImpactLine(String name, int shots, int remaining) =>
      _pick(
        fr: '• $name : $shots coups tirés, $remaining restantes',
        en: '• $name: $shots shots fired, $remaining remaining',
        de: '• $name: $shots Schüsse, $remaining verbleibend',
        it: '• $name: $shots colpi sparati, $remaining rimanenti',
        es: '• $name: $shots disparos, $remaining restantes',
      );

  String sessionSummaryWeaponImpactLine(String name, int shots) => _pick(
        fr: '• $name : $shots coups tirés',
        en: '• $name: $shots shots fired',
        de: '• $name: $shots Schüsse',
        it: '• $name: $shots colpi sparati',
        es: '• $name: $shots disparos',
      );

  String sessionSummaryAccessoryImpactLine(String name, int shots) => _pick(
        fr: '• $name : +$shots coups',
        en: '• $name: +$shots shots',
        de: '• $name: +$shots Schüsse',
        it: '• $name: +$shots colpi',
        es: '• $name: +$shots disparos',
      );

  String get saveSessionButton => _pick(
        fr: 'ENREGISTRER LA SÉANCE',
        en: 'SAVE SESSION',
        de: 'SITZUNG SPEICHERN',
        it: 'SALVA SESSIONE',
        es: 'GUARDAR SESIÓN',
      );

  String get exercisesSectionTitle => _pick(
        fr: 'Exercices',
        en: 'Exercises',
        de: 'Übungen',
        it: 'Esercizi',
        es: 'Ejercicios',
      );

  String get addButton => _pick(
        fr: 'Ajouter',
        en: 'Add',
        de: 'Hinzufügen',
        it: 'Aggiungi',
        es: 'Agregar',
      );

  String get noExerciseAdded => _pick(
        fr: 'Aucun exercice ajouté',
        en: 'No exercise added',
        de: 'Keine Übung hinzugefügt',
        it: 'Nessun esercizio aggiunto',
        es: 'Ningún ejercicio agregado',
      );

  String get weatherConditionsTitle => _pick(
        fr: 'Conditions Météo',
        en: 'Weather Conditions',
        de: 'Wetterbedingungen',
        it: 'Condizioni Meteo',
        es: 'Condiciones Climáticas',
      );

  String get weatherLoadingText => _pick(
        fr: 'Récupération de la météo en cours…',
        en: 'Fetching weather…',
        de: 'Wetter wird abgerufen…',
        it: 'Recupero meteo in corso…',
        es: 'Obteniendo clima…',
      );

  String get temperatureLabel => _pick(
        fr: 'Température',
        en: 'Temperature',
        de: 'Temperatur',
        it: 'Temperatura',
        es: 'Temperatura',
      );

  String get pressureLabel => _pick(
        fr: 'Pression',
        en: 'Pressure',
        de: 'Druck',
        it: 'Pressione',
        es: 'Presión',
      );

  String get windLabel => _pick(
        fr: 'Vent',
        en: 'Wind',
        de: 'Wind',
        it: 'Vento',
        es: 'Viento',
      );

  String get humidityLabel => _pick(
        fr: 'Humidité',
        en: 'Humidity',
        de: 'Feuchtigkeit',
        it: 'Umidità',
        es: 'Humedad',
      );

  String get disableTooltip => _pick(
        fr: 'Désactiver',
        en: 'Disable',
        de: 'Deaktivieren',
        it: 'Disabilita',
        es: 'Desactivar',
      );

  String get enableTooltip => _pick(
        fr: 'Réactiver',
        en: 'Re-enable',
        de: 'Reaktivieren',
        it: 'Riattiva',
        es: 'Reactivar',
      );

  String get locationPermissionDenied => _pick(
        fr: 'Autorisation de localisation refusée',
        en: 'Location permission denied',
        de: 'Standortberechtigung verweigert',
        it: 'Autorizzazione posizione negata',
        es: 'Permiso de ubicación denegado',
      );

  String get locationPermissionDeniedForever => _pick(
        fr: 'Autorisation de localisation refusée définitivement. Ouvrez les réglages de l’application pour la réactiver.',
        en: 'Location permission permanently denied. Open the app settings to re-enable it.',
        de: 'Standortberechtigung dauerhaft verweigert. Öffnen Sie die App-Einstellungen, um sie wieder zu aktivieren.',
        it: 'Autorizzazione posizione negata in modo permanente. Apri le impostazioni dell’app per riattivarla.',
        es: 'Permiso de ubicación denegado permanentemente. Abre los ajustes de la aplicación para volver a activarlo.',
      );

  String get locationServicesDisabled => _pick(
        fr: 'Localisation désactivée sur l\'appareil',
        en: 'Location services disabled on device',
        de: 'Standortdienste auf Gerät deaktiviert',
        it: 'Servizi di localizzazione disabilitati sul dispositivo',
        es: 'Servicios de ubicación desactivados en el dispositivo',
      );

  String get positionRetrievalFailed => _pick(
        fr: 'Impossible de récupérer la position',
        en: 'Unable to retrieve position',
        de: 'Position kann nicht abgerufen werden',
        it: 'Impossibile recuperare la posizione',
        es: 'No se puede recuperar la posición',
      );

  String get fetchLocalPositionButton => _pick(
        fr: 'Récupérer la position locale',
        en: 'Fetch local position',
        de: 'Lokale Position abrufen',
        it: 'Recupera posizione locale',
        es: 'Obtener posición local',
      );

String get locationUsageExplanation => _pick(
  fr: 'Position utilisée uniquement à votre demande pour renseigner la ville du stand et la météo locale.',
  en: 'Location is only used on request to fill in the range city and local weather.',
  de: 'Standort wird nur auf Anfrage verwendet, um die Stadt des Schießstands und das lokale Wetter zu ergänzen.',
  it: 'La posizione viene usata solo su richiesta per compilare la città del poligono e il meteo locale.',
  es: 'La ubicación solo se usa a petición para completar la ciudad del campo de tiro y el clima local.',
);

String get reverseGeocodingExplanation => _pick(
  fr: 'Les coordonnées servent uniquement à identifier la ville et éviter une saisie manuelle.',
  en: 'Coordinates are only used to identify the city and avoid manual entry.',
  de: 'Die Koordinaten werden nur verwendet, um die Stadt zu bestimmen und eine manuelle Eingabe zu vermeiden.',
  it: 'Le coordinate servono solo a identificare la città ed evitare l’inserimento manuale.',
  es: 'Las coordenadas solo se usan para identificar la ciudad y evitar la introducción manual.',
);

String get weatherUsageExplanation => _pick(
  fr: 'Le bouton météo récupère la météo locale utile à la séance, sans utilisation en arrière-plan.',
  en: 'The weather button fetches local weather for the session, with no background use.',
  de: 'Die Wetterschaltfläche ruft das lokale Wetter für die Sitzung ab, ohne Nutzung im Hintergrund.',
  it: 'Il pulsante meteo recupera il meteo locale per la sessione, senza uso in background.',
  es: 'El botón del clima obtiene el clima local para la sesión, sin uso en segundo plano.',
);

  String get fetchLocalWeatherButton => _pick(
        fr:
            'Récupérer la météo locale',
        en:
            'Fetch local weather',
        de:
            'Lokales Wetter abrufen',
        it:
            'Recupera meteo locale',
        es:
            'Obtener clima local',
      );

  String get weatherLocationPermissionDenied => _pick(
        fr: 'Autorisation de localisation refusée (météo).',
        en: 'Location permission denied (weather).',
        de: 'Standortberechtigung verweigert (Wetter).',
        it: 'Autorizzazione posizione negata (meteo).',
        es: 'Permiso de ubicación denegado (clima).',
      );

  String get weatherLocationPermissionDeniedForever => _pick(
        fr: 'Autorisation de localisation refusée définitivement pour la météo. Ouvrez les réglages de l’application pour la réactiver.',
        en: 'Location permission permanently denied for weather. Open the app settings to re-enable it.',
        de: 'Standortberechtigung für Wetter dauerhaft verweigert. Öffnen Sie die App-Einstellungen, um sie wieder zu aktivieren.',
        it: 'Autorizzazione posizione negata in modo permanente per il meteo. Apri le impostazioni dell’app per riattivarla.',
        es: 'Permiso de ubicación denegado permanentemente para el clima. Abre los ajustes de la aplicación para volver a activarlo.',
      );

  String get weatherLocationServicesDisabled => _pick(
        fr: 'Localisation désactivée sur l\'appareil (météo).',
        en: 'Location services disabled on device (weather).',
        de: 'Standortdienste auf Gerät deaktiviert (Wetter).',
        it: 'Servizi di localizzazione disabilitati sul dispositivo (meteo).',
        es: 'Servicios de ubicación desactivados en el dispositivo (clima).',
      );

  String get weatherNetworkError => _pick(
        fr: 'Impossible de récupérer la météo (réseau).',
        en: 'Unable to fetch weather (network).',
        de: 'Wetter kann nicht abgerufen werden (Netzwerk).',
        it: 'Impossibile recuperare il meteo (rete).',
        es: 'No se puede obtener el clima (red).',
      );

  String get weatherInvalidResponse => _pick(
        fr: 'Réponse météo invalide.',
        en: 'Invalid weather response.',
        de: 'Ungültige Wetterantwort.',
        it: 'Risposta meteo non valida.',
        es: 'Respuesta de clima inválida.',
      );

  String get weatherUnavailable => _pick(
        fr: 'Météo indisponible pour cet emplacement.',
        en: 'Weather unavailable for this location.',
        de: 'Wetter für diesen Standort nicht verfügbar.',
        it: 'Meteo non disponibile per questa posizione.',
        es: 'Clima no disponible para esta ubicación.',
      );

  String get weatherRetrievalError => _pick(
        fr: 'Erreur lors de la récupération de la météo.',
        en: 'Error retrieving weather.',
        de: 'Fehler beim Abrufen des Wetters.',
        it: 'Errore durante il recupero del meteo.',
        es: 'Error al obtener el clima.',
      );

  String get openAppSettingsLabel => _pick(
        fr: 'Ouvrir les réglages',
        en: 'Open settings',
        de: 'Einstellungen öffnen',
        it: 'Apri impostazioni',
        es: 'Abrir ajustes',
      );

  String get freeVersionWeaponLimit => _pick(
        fr:
            'Version gratuite : seule la première arme est utilisable. Passez à Pro pour débloquer tout le matériel.',
        en:
            'Free version: only the first weapon is usable. Upgrade to Pro to unlock all equipment.',
        de:
            'Kostenlose Version: nur die erste Waffe ist verwendbar. Upgrade auf Pro, um die gesamte Ausrüstung freizuschalten.',
        it:
            'Versione gratuita: solo la prima arma è utilizzabile. Passa a Pro per sbloccare tutta l’attrezzatura.',
        es:
            'Versión gratuita: solo la primera arma es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
      );

  String get freeVersionAmmoLimit => _pick(
        fr:
            'Version gratuite : seule la première munition est utilisable. Passez à Pro pour débloquer tout le matériel.',
        en:
            'Free version: only the first ammo entry is usable. Upgrade to Pro to unlock all equipment.',
        de:
            'Kostenlose Version: nur die erste Munition ist verwendbar. Upgrade auf Pro, um die gesamte Ausrüstung freizuschalten.',
        it:
            'Versione gratuita: solo la prima munizione è utilizzabile. Passa a Pro per sbloccare tutta l’attrezzatura.',
        es:
            'Versión gratuita: solo la primera munición es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
      );

  String get freeVersionAccessoryLimit => _pick(
        fr:
            'Version gratuite : seul le premier accessoire est utilisable. Passez à Pro pour débloquer tout le matériel.',
        en:
            'Free version: only the first accessory is usable. Upgrade to Pro to unlock all equipment.',
        de:
            'Kostenlose Version: nur das erste Zubehör ist verwendbar. Upgrade auf Pro, um die gesamte Ausrüstung freizuschalten.',
        it:
            'Versione gratuita: solo il primo accessorio è utilizzabile. Passa a Pro per sbloccare tutta l’attrezzatura.',
        es:
            'Versión gratuita: solo el primer accesorio es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
      );

  String get sessionDuplicatedSnack => _pick(
        fr: 'Séance dupliquée',
        en: 'Session duplicated',
        de: 'Sitzung dupliziert',
        it: 'Sessione duplicata',
        es: 'Sesión duplicada',
      );

  String get sessionLabelWeapon => _pick(
        fr: 'Arme',
        en: 'Weapon',
        de: 'Waffe',
        it: 'Arma',
        es: 'Arma',
      );

  String get sessionLabelAmmo => _pick(
        fr: 'Munition',
        en: 'Ammo',
        de: 'Munition',
        it: 'Munizione',
        es: 'Munición',
      );

  String get inventoryTitle => _pick(
        fr: 'THOT',
        en: 'THOT',
        de: 'THOT',
        it: 'THOT',
        es: 'THOT',
      );

  String get inventorySubtitle => _pick(
        fr: 'MATÉRIEL',
        en: 'EQUIPMENT',
        de: 'AUSRÜSTUNG',
        it: 'ATTREZZATURA',
        es: 'EQUIPO',
      );

  String get toolsSubtitle => _pick(
        fr: 'OUTILS',
        en: 'TOOLS',
        de: 'TOOLS',
        it: 'STRUMENTI',
        es: 'HERRAMIENTAS',
      );

  String get weaponsTab => _pick(
        fr: 'Armes',
        en: 'Weapons',
        de: 'Waffen',
        it: 'Armi',
        es: 'Armas',
      );

  String get ammosTab => _pick(
        fr: 'Munitions',
        en: 'Ammunition',
        de: 'Munition',
        it: 'Munizioni',
        es: 'Munición',
      );

  String get accessoriesTab => _pick(
        fr: 'Accessoires',
        en: 'Accessories',
        de: 'Zubehör',
        it: 'Accessori',
        es: 'Accesorios',
      );

  String get searchInventoryHint => _pick(
        fr: "Rechercher dans l'inventaire...",
        en: 'Search inventory...',
        de: 'Inventar durchsuchen...',
        it: 'Cerca inventario...',
        es: 'Buscar en inventario...',
      );

  String get addWeapon => _pick(
        fr: 'Ajouter une arme',
        en: 'Add weapon',
        de: 'Waffe hinzufügen',
        it: 'Aggiungi arma',
        es: 'Agregar arma',
      );

  String get addAmmo => _pick(
        fr: 'Ajouter une munition',
        en: 'Add ammunition',
        de: 'Munition hinzufügen',
        it: 'Aggiungi munizione',
        es: 'Agregar munición',
      );

  String get addAccessory => _pick(
        fr: 'Ajouter un accessoire',
        en: 'Add accessory',
        de: 'Zubehör hinzufügen',
        it: 'Aggiungi accessorio',
        es: 'Agregar accesorio',
      );

  String get addEquipment => _pick(
        fr: 'Ajouter du matériel',
        en: 'Add equipment',
        de: 'Ausrüstung hinzufügen',
        it: 'Aggiungi attrezzatura',
        es: 'Agregar equipo',
      );

  String get noWeaponFound => _pick(
        fr: 'Aucune arme trouvée',
        en: 'No weapon found',
        de: 'Keine Waffe gefunden',
        it: 'Nessuna arma trovata',
        es: 'No se encontró arma',
      );

  String get noWeaponInStock => _pick(
        fr: "Vous n'avez pas d'arme en stock.",
        en: "You don't have any weapons in stock.",
        de: 'Du hast keine Waffen im Bestand.',
        it: 'Non hai armi in stock.',
        es: 'No tienes armas en stock.',
      );

  String get addFirstWeapon => _pick(
        fr: 'Ajoutez votre première arme',
        en: 'Add your first weapon',
        de: 'Füge deine erste Waffe hinzu',
        it: 'Aggiungi la tua prima arma',
        es: 'Agrega tu primera arma',
      );

  String get noAmmoFound => _pick(
        fr: 'Aucune munition trouvée',
        en: 'No ammunition found',
        de: 'Keine Munition gefunden',
        it: 'Nessuna munizione trovata',
        es: 'No se encontró munición',
      );

  String get noAmmoInStock => _pick(
        fr: "Vous n'avez pas de munition en stock.",
        en: "You don't have any ammunition in stock.",
        de: 'Du hast keine Munition im Bestand.',
        it: 'Non hai munizioni in stock.',
        es: 'No tienes munición en stock.',
      );

  String get addFirstAmmo => _pick(
        fr: 'Ajoutez votre première munition',
        en: 'Add your first ammunition',
        de: 'Füge deine erste Munition hinzu',
        it: 'Aggiungi la tua prima munizione',
        es: 'Agrega tu primera munición',
      );

  String get noAccessoryFound => _pick(
        fr: 'Aucun accessoire trouvé',
        en: 'No accessory found',
        de: 'Kein Zubehör gefunden',
        it: 'Nessun accessorio trovato',
        es: 'No se encontró accesorio',
      );

  String get noAccessoryInStock => _pick(
        fr: "Vous n'avez pas d'accessoire en stock.",
        en: "You don't have any accessories in stock.",
        de: 'Du hast kein Zubehör im Bestand.',
        it: 'Non hai accessori in stock.',
        es: 'No tienes accesorios en stock.',
      );

  String get addFirstAccessory => _pick(
        fr: 'Ajoutez votre premier accessoire',
        en: 'Add your first accessory',
        de: 'Füge dein erstes Zubehör hinzu',
        it: 'Aggiungi il tuo primo accessorio',
        es: 'Agrega tu primer accesorio',
      );

  String get shotsFired => _pick(
        fr: 'Coups tirés',
        en: 'Shots fired',
        de: 'Schüsse abgefeuert',
        it: 'Colpi sparati',
        es: 'Tiros disparados',
      );

  String get stock => _pick(
        fr: 'Stock',
        en: 'Stock',
        de: 'Bestand',
        it: 'Scorte',
        es: 'Inventario',
      );

  String get lastSession => _pick(
        fr: 'Dernière séance',
        en: 'Last session',
        de: 'Letzte Sitzung',
        it: 'Ultima sessione',
        es: 'Última sesión',
      );

  String get yesterday => _pick(
        fr: 'Hier',
        en: 'Yesterday',
        de: 'Gestern',
        it: 'Ieri',
        es: 'Ayer',
      );

  String get edit => _pick(
        fr: 'Éditer',
        en: 'Edit',
        de: 'Bearbeiten',
        it: 'Modifica',
        es: 'Editar',
      );

  String get duplicate => _pick(
        fr: 'Dupliquer',
        en: 'Duplicate',
        de: 'Duplizieren',
        it: 'Duplica',
        es: 'Duplicar',
      );

  String get delete => _pick(
        fr: 'Supprimer',
        en: 'Delete',
        de: 'Löschen',
        it: 'Elimina',
        es: 'Eliminar',
      );

  String get confirmDeletion => _pick(
        fr: 'Confirmer la suppression',
        en: 'Confirm deletion',
        de: 'Löschung bestätigen',
        it: 'Conferma eliminazione',
        es: 'Confirmar eliminación',
      );

  String get deleteConfirmationMessage => _pick(
        fr: 'Voulez-vous vraiment supprimer "{name}" ?',
        en: 'Do you really want to delete "{name}"?',
        de: 'Möchten Sie "{name}" wirklich löschen?',
        it: 'Vuoi davvero eliminare "{name}"?',
        es: '¿Realmente quieres eliminar "{name}"?',
      );

  String get cancel => _pick(
        fr: 'Annuler',
        en: 'Cancel',
        de: 'Abbrechen',
        it: 'Annulla',
        es: 'Cancelar',
      );

  String get deletedSnack => _pick(
        fr: '"{name}" supprimé',
        en: '"{name}" deleted',
        de: '"{name}" gelöscht',
        it: '"{name}" eliminato',
        es: '"{name}" eliminado',
      );

  String get validate => _pick(
        fr: 'VALIDER',
        en: 'CONFIRM',
        de: 'BESTÄTIGEN',
        it: 'CONFERMA',
        es: 'CONFIRMAR',
      );

  String get close => _pick(
        fr: 'Fermer',
        en: 'Close',
        de: 'Schließen',
        it: 'Chiudi',
        es: 'Cerrar',
      );

  String get searchEllipsis => _pick(
        fr: 'Rechercher…',
        en: 'Search…',
        de: 'Suchen…',
        it: 'Cerca…',
        es: 'Buscar…',
      );

  String get tapToChooseFromInventory => _pick(
        fr: 'Appuie pour choisir dans ton stock',
        en: 'Tap to choose from your inventory',
        de: 'Tippe, um aus deinem Bestand zu wählen',
        it: 'Tocca per scegliere dal tuo inventario',
        es: 'Toca para elegir de tu inventario',
      );

  String get equipmentsTitle => _pick(
        fr: 'Équipements',
        en: 'Equipment',
        de: 'Ausrüstung',
        it: 'Attrezzatura',
        es: 'Equipo',
      );

  String get removeAll => _pick(
        fr: 'Tout retirer',
        en: 'Remove all',
        de: 'Alles entfernen',
        it: 'Rimuovi tutto',
        es: 'Quitar todo',
      );

  String get noResults => _pick(
        fr: 'Aucun résultat',
        en: 'No results',
        de: 'Keine Ergebnisse',
        it: 'Nessun risultato',
        es: 'Sin resultados',
      );

  String get noEquipmentFound => _pick(
        fr: 'Aucun équipement trouvé',
        en: 'No equipment found',
        de: 'Keine Ausrüstung gefunden',
        it: 'Nessuna attrezzatura trovata',
        es: 'No se encontró equipo',
      );

  String get searchEquipmentHint => _pick(
        fr: 'Rechercher (optique, protection, marque…)',
        en: 'Search (optic, protection, brand…)',
        de: 'Suchen (Optik, Schutz, Marke…)',
        it: 'Cerca (ottica, protezione, marca…)',
        es: 'Buscar (óptica, protección, marca…)',
      );

  String get settingsDocumentTypeWeaponPermit => _pick(
        fr: "Autorisation de port d'arme",
        en: 'Weapon carry permit',
        de: 'Waffentragegenehmigung',
        it: "Autorizzazione al porto d'armi",
        es: 'Permiso de porte de armas',
      );

  String get settingsDocumentTypeMedicalCertificate => _pick(
        fr: 'Certificat médical',
        en: 'Medical certificate',
        de: 'Ärztliches Attest',
        it: 'Certificato medico',
        es: 'Certificado médico',
      );

  String get settingsDocumentTypeOther => _pick(
        fr: 'Autre',
        en: 'Other',
        de: 'Andere',
        it: 'Altro',
        es: 'Otro',
      );

  String get settingsDocumentAddedSuccess => _pick(
        fr: 'Document ajouté avec succès',
        en: 'Document added successfully',
        de: 'Dokument erfolgreich hinzugefügt',
        it: 'Documento aggiunto con successo',
        es: 'Documento agregado correctamente',
      );

  String get settingsEditDocument => _pick(
        fr: 'Modifier le document',
        en: 'Edit document',
        de: 'Dokument bearbeiten',
        it: 'Modifica documento',
        es: 'Editar documento',
      );

  String get settingsDocumentUpdatedSuccess => _pick(
        fr: 'Document mis à jour',
        en: 'Document updated',
        de: 'Dokument aktualisiert',
        it: 'Documento aggiornato',
        es: 'Documento actualizado',
      );

  String get settingsDocumentActions => _pick(
        fr: 'Actions du document',
        en: 'Document actions',
        de: 'Dokumentaktionen',
        it: 'Azioni documento',
        es: 'Acciones del documento',
      );

  String get settingsOpenDocument => _pick(
        fr: 'Ouvrir',
        en: 'Open',
        de: 'Öffnen',
        it: 'Apri',
        es: 'Abrir',
      );

  String get settingsAdd => _pick(
        fr: 'Ajouter',
        en: 'Add',
        de: 'Hinzufügen',
        it: 'Aggiungi',
        es: 'Añadir',
      );

  String get settingsPremiumTitle => _pick(
        fr: 'THOT Premium',
        en: 'THOT Premium',
        de: 'THOT Premium',
        it: 'THOT Premium',
        es: 'THOT Premium',
      );

  String get settingsPremiumUnlockText => _pick(
        fr: 'Débloquez toutes les fonctionnalités premium :',
        en: 'Unlock all premium features:',
        de: 'Schalte alle Premium-Funktionen frei:',
        it: 'Sblocca tutte le funzionalità premium:',
        es: 'Desbloquea todas las funciones premium:',
      );

  String get settingsPremiumFeatureWeaponsDetailed => _pick(
        fr: '✓ Armes illimitées (actuellement limité à 1)',
        en: '✓ Unlimited weapons (currently limited to 1)',
        de: '✓ Unbegrenzte Waffen (derzeit auf 1 begrenzt)',
        it: '✓ Armi illimitate (attualmente limitate a 1)',
        es: '✓ Armas ilimitadas (actualmente limitado a 1)',
      );

  String get settingsPremiumFeatureAmmosDetailed => _pick(
        fr: '✓ Munitions illimitées (actuellement limité à 1)',
        en: '✓ Unlimited ammo (currently limited to 1)',
        de: '✓ Unbegrenzte Munition (derzeit auf 1 begrenzt)',
        it: '✓ Munizioni illimitate (attualmente limitate a 1)',
        es: '✓ Munición ilimitada (actualmente limitada a 1)',
      );

  String get settingsPremiumFeatureSessionsDetailed => _pick(
        fr: '✓ Séances illimitées (actuellement limité à 5)',
        en: '✓ Unlimited sessions (currently limited to 5)',
        de: '✓ Unbegrenzte Sitzungen (derzeit auf 5 begrenzt)',
        it: '✓ Sessioni illimitate (attualmente limitate a 5)',
        es: '✓ Sesiones ilimitadas (actualmente limitadas a 5)',
      );

  String get settingsPremiumFeatureSecurityDetailed => _pick(
        fr: '✓ Protection locale renforcée',
        en: '✓ Enhanced local protection',
        de: '✓ Verstärkter lokaler Schutz',
        it: '✓ Protezione locale avanzata',
        es: '✓ Protección local reforzada',
      );

  String get settingsPremiumFeatureBackupExport => _pick(
        fr: '✓ Export de sauvegarde chiffré',
        en: '✓ Encrypted backup export',
        de: '✓ Verschlüsselter Backup-Export',
        it: '✓ Esportazione backup crittografata',
        es: '✓ Exportación de copia cifrada',
      );

  String get settingsPremiumFeatureBackupRestore => _pick(
        fr: '✓ Restauration depuis fichier de sauvegarde',
        en: '✓ Restore from backup file',
        de: '✓ Wiederherstellung aus Sicherungsdatei',
        it: '✓ Ripristino da file di backup',
        es: '✓ Restauración desde archivo de copia',
      );

  String get settingsPremiumFeatureAdvancedExports => _pick(
        fr: '✓ Exports avancés (PDF, CSV)',
        en: '✓ Advanced exports (PDF, CSV)',
        de: '✓ Erweiterte Exporte (PDF, CSV)',
        it: '✓ Esportazioni avanzate (PDF, CSV)',
        es: '✓ Exportaciones avanzadas (PDF, CSV)',
      );

  String get settingsPremiumPerMonthSuffix => _pick(
        fr: ' / mois',
        en: ' / month',
        de: ' / Monat',
        it: ' / mese',
        es: ' / mes',
      );

  String get settingsPremiumSecurePaymentPending => _pick(
        fr: "🔒 Paiement sécurisé (non connecté pour l'instant)",
        en: '🔒 Secure payment (not connected yet)',
        de: '🔒 Sichere Zahlung (noch nicht verbunden)',
        it: '🔒 Pagamento sicuro (non ancora collegato)',
        es: '🔒 Pago seguro (aún no conectado)',
      );

  String get settingsPremiumLater => _pick(
        fr: 'Plus tard',
        en: 'Later',
        de: 'Später',
        it: 'Più tardi',
        es: 'Más tarde',
      );

  String get settingsPremiumDemoActivated => _pick(
        fr: 'Paiement non encore connecté. Version complète activée pour démo.',
        en: 'Payment not connected yet. Full version enabled for demo.',
        de: 'Zahlung noch nicht verbunden. Vollversion für Demo aktiviert.',
        it: 'Pagamento non ancora collegato. Versione completa attivata per demo.',
        es: 'Pago aún no conectado. Versión completa activada para demostración.',
      );

  String get settingsPremiumSubscribeNow => _pick(
        fr: "S'abonner maintenant",
        en: 'Subscribe now',
        de: 'Jetzt abonnieren',
        it: 'Abbonati ora',
        es: 'Suscribirse ahora',
      );

  String get proBadge => _pick(
        fr: 'PRO',
        en: 'PRO',
        de: 'PRO',
        it: 'PRO',
        es: 'PRO',
      );

  String get settingsOpenDocumentFailed => _pick(
        fr: "Impossible d'ouvrir le document",
        en: 'Unable to open document',
        de: 'Dokument kann nicht geöffnet werden',
        it: 'Impossibile aprire il documento',
        es: 'No se puede abrir el documento',
      );

  String get settingsDeleteDocumentTitle => _pick(
        fr: 'Supprimer le document',
        en: 'Delete document',
        de: 'Dokument löschen',
        it: 'Elimina documento',
        es: 'Eliminar documento',
      );

  String settingsDeleteDocumentMessage(String name) => _pick(
        fr: 'Voulez-vous vraiment supprimer "$name" ?',
        en: 'Do you really want to delete "$name"?',
        de: 'Möchten Sie "$name" wirklich löschen?',
        it: 'Vuoi davvero eliminare "$name"?',
        es: '¿Realmente quieres eliminar "$name"?',
      );

  String get settingsDeleteAllDataLabel => _pick(
        fr: 'Supprimer toutes les données locales',
        en: 'Delete all local data',
        de: 'Alle lokalen Daten löschen',
        it: 'Elimina tutti i dati locali',
        es: 'Eliminar todos los datos locales',
      );

  String get settingsDeleteAllDataSubtitle => _pick(
        fr: 'Efface profil, inventaire, séances, diagnostiques et documents stockés sur cet appareil',
        en: 'Erase profile, inventory, sessions, diagnostics, and documents stored on this device',
        de: 'Löscht Profil, Inventar, Sitzungen, Diagnosen und auf diesem Gerät gespeicherte Dokumente',
        it: 'Cancella profilo, inventario, sessioni, diagnostica e documenti memorizzati su questo dispositivo',
        es: 'Borra el perfil, inventario, sesiones, diagnósticos y documentos almacenados en este dispositivo',
      );

  String get settingsDeleteAllDataTitle => _pick(
        fr: 'Supprimer toutes les données locales',
        en: 'Delete all local data',
        de: 'Alle lokalen Daten löschen',
        it: 'Elimina tutti i dati locali',
        es: 'Eliminar todos los datos locales',
      );

  String get settingsDeleteAllDataMessage => _pick(
        fr: 'Cette action supprime de cet appareil votre profil, inventaire, séances, diagnostiques et documents ajoutés dans l’application. Cette action est irréversible.',
        en: 'This action removes from this device your profile, inventory, sessions, diagnostics, and documents added in the app. This action cannot be undone.',
        de: 'Diese Aktion entfernt von diesem Gerät Ihr Profil, Inventar, Sitzungen, Diagnosen und in der App hinzugefügte Dokumente. Diese Aktion kann nicht rückgängig gemacht werden.',
        it: 'Questa azione rimuove da questo dispositivo il tuo profilo, inventario, sessioni, diagnostica e documenti aggiunti nell’app. Questa azione non può essere annullata.',
        es: 'Esta acción elimina de este dispositivo tu perfil, inventario, sesiones, diagnósticos y documentos añadidos en la aplicación. Esta acción no se puede deshacer.',
      );

  String get settingsDeleteAllDataConfirm => _pick(
        fr: 'Tout supprimer',
        en: 'Delete everything',
        de: 'Alles löschen',
        it: 'Elimina tutto',
        es: 'Eliminar todo',
      );

  String get settingsDeleteAllDataSuccess => _pick(
        fr: 'Toutes les données locales ont été supprimées',
        en: 'All local data has been deleted',
        de: 'Alle lokalen Daten wurden gelöscht',
        it: 'Tutti i dati locali sono stati eliminati',
        es: 'Se han eliminado todos los datos locales',
      );

  String get dateFormatLabel => _pick(
        fr: 'Format de date',
        en: 'Date format',
        de: 'Datumsformat',
        it: 'Formato data',
        es: 'Formato de fecha',
      );

  String get dateFormatDayMonthYear => _pick(
        fr: 'Jour Mois Année',
        en: 'Day Month Year',
        de: 'Tag Monat Jahr',
        it: 'Giorno Mese Anno',
        es: 'Día Mes Año',
      );

  String get dateFormatMonthDayYear => _pick(
        fr: 'Mois Jour Année',
        en: 'Month Day Year',
        de: 'Monat Tag Jahr',
        it: 'Mese Giorno Anno',
        es: 'Mes Día Año',
      );

  String get settingsAnonymousUserUpper => _pick(
        fr: 'Utilisateur Anonyme',
        en: 'Anonymous User',
        de: 'Anonymer Benutzer',
        it: 'Utente anonimo',
        es: 'Usuario anónimo',
      );

  String get settingsAnonymousUser => _pick(
        fr: 'Utilisateur anonyme',
        en: 'Anonymous user',
        de: 'Anonymer Benutzer',
        it: 'Utente anonimo',
        es: 'Usuario anónimo',
      );

  String get settingsDocumentsLabel => _pick(
        fr: 'Documents',
        en: 'Documents',
        de: 'Dokumente',
        it: 'Documenti',
        es: 'Documentos',
      );

  String settingsDocumentsCount(int count) => _pick(
        fr: '$count document${count > 1 ? 's' : ''}',
        en: '$count document${count > 1 ? 's' : ''}',
        de: '$count Dokument${count > 1 ? 'e' : ''}',
        it: '$count document${count > 1 ? 'i' : 'o'}',
        es: '$count documento${count > 1 ? 's' : ''}',
      );

  String get settingsUpgradeToProLabel => _pick(
        fr: 'Passer à Pro',
        en: 'Upgrade to Pro',
        de: 'Zu Pro wechseln',
        it: 'Passa a Pro',
        es: 'Pasar a Pro',
      );

  String get settingsUpgradeToProSubtitle => _pick(
        fr: 'Tout débloqué',
        en: 'Everything unlocked',
        de: 'Alles freigeschaltet',
        it: 'Tutto sbloccato',
        es: 'Todo desbloqueado',
      );

  String get settingsLicenseNotProvided => _pick(
        fr: 'Licence non renseignée',
        en: 'License not provided',
        de: 'Lizenz nicht angegeben',
        it: 'Licenza non indicata',
        es: 'Licencia no indicada',
      );

  String settingsLicenseNumber(String license) => _pick(
        fr: 'Licence #$license',
        en: 'License #$license',
        de: 'Lizenz #$license',
        it: 'Licenza #$license',
        es: 'Licencia #$license',
      );

  String get usedEquipmentLabel => _pick(
        fr: 'Équipement utilisé',
        en: 'Equipment used',
        de: 'Verwendete Ausrüstung',
        it: 'Attrezzatura usata',
        es: 'Equipo usado',
      );

  String get usedTargetLabel => _pick(
        fr: 'Cible utilisée',
        en: 'Target used',
        de: 'Verwendete Zielscheibe',
        it: 'Bersaglio utilizzato',
        es: 'Blanco utilizado',
      );

  String get noEquipmentSelected => _pick(
        fr: 'Aucun équipement sélectionné',
        en: 'No equipment selected',
        de: 'Keine Ausrüstung ausgewählt',
        it: 'Nessuna attrezzatura selezionata',
        es: 'Ningún equipo seleccionado',
      );

  String selectedEquipmentCount(int count) => _pick(
        fr: '$count équipement(s) sélectionné(s)',
        en: '$count equipment item(s) selected',
        de: '$count Ausrüstungsteil(e) ausgewählt',
        it: '$count elemento/i selezionato/i',
        es: '$count equipo(s) seleccionado(s)',
      );

  String get targetHint => _pick(
        fr: 'Ex: Cible ISSF 25m, Silhouette IPSC...',
        en: 'Ex: ISSF 25m, IPSC silhouette...',
        de: 'Bsp.: ISSF 25 m, IPSC Silhouette...',
        it: 'Es: ISSF 25m, silhouette IPSC...',
        es: 'Ej: ISSF 25m, silueta IPSC...',
      );

  String get targetPhotosTitle => _pick(
        fr: 'Photos de la cible',
        en: 'Target photos',
        de: 'Fotos der Zielscheibe',
        it: 'Foto del bersaglio',
        es: 'Fotos del blanco',
      );

  String get addTargetPhotosCta => _pick(
        fr: 'Ajouter une ou plusieurs photos de la cible',
        en: 'Add one or more target photos',
        de: 'Füge ein oder mehrere Fotos der Zielscheibe hinzu',
        it: 'Aggiungi una o più foto del bersaglio',
        es: 'Agrega una o más fotos del blanco',
      );

  String get photoNameLabel => _pick(
        fr: 'Nom de la photo',
        en: 'Photo name',
        de: 'Fotobezeichnung',
        it: 'Nome foto',
        es: 'Nombre de la foto',
      );

  String get sessionNotFoundTitle => _pick(
        fr: 'Séance introuvable',
        en: 'Session not found',
        de: 'Sitzung nicht gefunden',
        it: 'Sessione non trovata',
        es: 'Sesión no encontrada',
      );

  String get sessionNotFoundNoId => _pick(
        fr: 'Aucun identifiant de séance fourni',
        en: 'No session ID provided',
        de: 'Keine Sitzungs-ID angegeben',
        it: 'Nessun ID sessione fornito',
        es: 'No se proporcionó ID de sesión',
      );

  String sessionNotFoundId(String id) => _pick(
        fr: 'ID: $id',
        en: 'ID: $id',
        de: 'ID: $id',
        it: 'ID: $id',
        es: 'ID: $id',
      );

  String get sessionOpenFailedTitle => _pick(
        fr: "Impossible d'ouvrir cette séance",
        en: 'Unable to open this session',
        de: 'Diese Sitzung kann nicht geöffnet werden',
        it: 'Impossibile aprire questa sessione',
        es: 'No se puede abrir esta sesión',
      );

  String get sessionOpenFailedSubtitle => _pick(
        fr: 'Revenez en arrière et réessayez.',
        en: 'Go back and try again.',
        de: 'Gehe zurück und versuche es erneut.',
        it: 'Torna indietro e riprova.',
        es: 'Vuelve atrás e inténtalo de nuevo.',
      );

  String get weatherTitleShort => _pick(
        fr: 'Météo',
        en: 'Weather',
        de: 'Wetter',
        it: 'Meteo',
        es: 'Clima',
      );

  String get noExerciseForSession => _pick(
        fr: 'Aucun exercice enregistré pour cette séance',
        en: 'No exercise recorded for this session',
        de: 'Keine Übung für diese Sitzung aufgezeichnet',
        it: 'Nessun esercizio registrato per questa sessione',
        es: 'No hay ejercicios registrados para esta sesión',
      );

  String get observationsTitle => _pick(
        fr: 'Observations',
        en: 'Notes',
        de: 'Notizen',
        it: 'Osservazioni',
        es: 'Observaciones',
      );

  String get observationsExample => _pick(
        fr: 'Ex: Légère tendance à droite...',
        en: 'Ex: Slight tendency to the right...',
        de: 'Bsp.: Leichte Tendenz nach rechts...',
        it: 'Es: Leggera tendenza a destra...',
        es: 'Ej: Ligera tendencia a la derecha...',
      );

  String get progressionPrecisionTitle => _pick(
        fr: 'Progression (précision)',
        en: 'Progress (precision)',
        de: 'Verlauf (Präzision)',
        it: 'Progressi (precisione)',
        es: 'Progreso (precisión)',
      );

  String get statsShotsLabelUpper => _pick(
        fr: 'COUPS',
        en: 'SHOTS',
        de: 'SCHÜSSE',
        it: 'COLPI',
        es: 'DISPAROS',
      );

  String get statsAvgPrecisionLabelUpper => _pick(
        fr: 'PRÉCISION MOY.',
        en: 'AVG PREC.',
        de: 'Ø PRÄZ.',
        it: 'PREC. MED.',
        es: 'PREC. PROM.',
      );

  String get statsExercisesLabelUpper => _pick(
        fr: 'EXERCICES',
        en: 'EXERCISES',
        de: 'ÜBUNGEN',
        it: 'ESERCIZI',
        es: 'EJERCICIOS',
      );

  String get noWeaponInStockSwitchBorrowed => _pick(
        fr: 'Aucune arme dans le stock. Passe en “Prêtée”.',
        en: 'No weapon in inventory. Switch to “Borrowed”.',
        de: 'Keine Waffe im Bestand. Wechsle zu “Geliehen”.',
        it: 'Nessuna arma in inventario. Passa a “Prestata”.',
        es: 'No hay ninguna arma en el inventario. Cambia a “Prestada”.',
      );

  String get noAmmoInStockSwitchBorrowed => _pick(
        fr: 'Aucune munition dans le stock. Passe en “Prêtée”.',
        en: 'No ammo in inventory. Switch to “Borrowed”.',
        de: 'Keine Munition im Bestand. Wechsle zu “Geliehen”.',
        it: 'Nessuna munizione in inventario. Passa a “Prestata”.',
        es: 'No hay munición en el inventario. Cambia a “Prestada”.',
      );

  String get myInventory => _pick(
        fr: 'Mon stock',
        en: 'My inventory',
        de: 'Mein Bestand',
        it: 'Il mio inventario',
        es: 'Mi inventario',
      );

  String get borrowed => _pick(
        fr: 'Prêtée',
        en: 'Borrowed',
        de: 'Geliehen',
        it: 'Prestata',
        es: 'Prestada',
      );

  String get borrowedWeaponOptional => _pick(
        fr: 'Arme prêtée (détail optionnel)',
        en: 'Borrowed weapon (optional details)',
        de: 'Geliehene Waffe (optional)',
        it: 'Arma prestata (dettagli opzionali)',
        es: 'Arma prestada (detalles opcionales)',
      );

  String get borrowedWeaponHint => _pick(
        fr: 'Ex: Glock 17, club…',
        en: 'Ex: Glock 17, club…',
        de: 'Bsp.: Glock 17, Verein…',
        it: 'Es: Glock 17, club…',
        es: 'Ej: Glock 17, club…',
      );

  String get borrowedAmmoOptional => _pick(
        fr: 'Munition prêtée (détail optionnel)',
        en: 'Borrowed ammo (optional details)',
        de: 'Geliehene Munition (optional)',
        it: 'Munizione prestata (dettagli opzionali)',
        es: 'Munición prestada (detalles opcionales)',
      );

  String get borrowedAmmoHint => _pick(
        fr: 'Ex: 9×19 FMJ, rechargée…',
        en: 'Ex: 9×19 FMJ, reloaded…',
        de: 'Bsp.: 9×19 FMJ, wiedergeladen…',
        it: 'Es: 9×19 FMJ, ricaricata…',
        es: 'Ej: 9×19 FMJ, recargada…',
      );

  String get weaponTitle => _pick(
        fr: 'Arme',
        en: 'Weapon',
        de: 'Waffe',
        it: 'Arma',
        es: 'Arma',
      );

  String get ammoTitle => _pick(
        fr: 'Munition',
        en: 'Ammo',
        de: 'Munition',
        it: 'Munizione',
        es: 'Munición',
      );

  String get chooseWeaponFromInventory => _pick(
        fr: 'Choisir une arme dans ton stock',
        en: 'Choose a weapon from your inventory',
        de: 'Wähle eine Waffe aus deinem Bestand',
        it: 'Scegli un\'arma dal tuo inventario',
        es: 'Elige un arma de tu inventario',
      );

  String get chooseAmmoFromInventory => _pick(
        fr: 'Choisir une munition dans ton stock',
        en: 'Choose ammo from your inventory',
        de: 'Wähle eine Munition aus deinem Bestand',
        it: 'Scegli una munizione dal tuo inventario',
        es: 'Elige munición de tu inventario',
      );

  String get tapToChange => _pick(
        fr: 'Appuie pour changer',
        en: 'Tap to change',
        de: 'Tippe zum Ändern',
        it: 'Tocca per cambiare',
        es: 'Toca para cambiar',
      );

  String get addExerciseTitle => _pick(
        fr: 'Ajouter un exercice',
        en: 'Add an exercise',
        de: 'Übung hinzufügen',
        it: 'Aggiungi un esercizio',
        es: 'Agregar un ejercicio',
      );

  String get measurePrecisionTitle => _pick(
        fr: 'Mesurer la précision',
        en: 'Measure precision',
        de: 'Präzision messen',
        it: 'Misura la precisione',
        es: 'Medir la precisión',
      );

  String precisionValueLabel(String value) => _pick(
        fr: 'Précision: $value',
        en: 'Precision: $value',
        de: 'Präzision: $value',
        it: 'Precisione: $value',
        es: 'Precisión: $value',
      );

  String get saveAsTemplateButton => _pick(
    fr: 'Enregistrer comme modèle',
    en: 'Save as template',
    de: 'Als Vorlage speichern',
    it: 'Salva come modello',
    es: 'Guardar como plantilla',
  );

  String get templateNameDialogTitle => _pick(
    fr: 'Nom du modèle',
    en: 'Template name',
    de: 'Vorlagenname',
    it: 'Nome modello',
    es: 'Nombre de la plantilla',
  );

  String get templateNameHint => _pick(
    fr: 'Ex : Tir de précision 25m',
    en: 'E.g. Precision drill 25m',
    de: 'Z.B. Präzisionsübung 25m',
    it: 'Es: Tiro di precisione 25m',
    es: 'Ej: Tiro de precisión 25m',
  );

  String get templateSavedSnack => _pick(
    fr: 'Modèle enregistré',
    en: 'Template saved',
    de: 'Vorlage gespeichert',
    it: 'Modello salvato',
    es: 'Plantilla guardada',
  );

  String get createExerciseButton => _pick(
    fr: '+ Créer',
    en: '+ Create',
    de: '+ Erstellen',
    it: '+ Crea',
    es: '+ Crear',
  );

  String get importExerciseButton => _pick(
    fr: '+ Importer',
    en: '+ Import',
    de: '+ Importieren',
    it: '+ Importa',
    es: '+ Importar',
  );

  String get importTemplateTitle => _pick(
    fr: 'Importer un modèle',
    en: 'Import a template',
    de: 'Vorlage importieren',
    it: 'Importa un modello',
    es: 'Importar una plantilla',
  );

  String get noTemplatesAvailable => _pick(
    fr: 'Aucun modèle enregistré',
    en: 'No templates saved yet',
    de: 'Keine Vorlagen gespeichert',
    it: 'Nessun modello salvato',
    es: 'Sin plantillas guardadas',
  );

  String get templateImportButton => _pick(
    fr: 'Importer',
    en: 'Import',
    de: 'Importieren',
    it: 'Importa',
    es: 'Importar',
  );

  String get templateDeleteConfirmTitle => _pick(
    fr: 'Supprimer ce modèle ?',
    en: 'Delete this template?',
    de: 'Diese Vorlage löschen?',
    it: 'Eliminare questo modello?',
    es: '¿Eliminar esta plantilla?',
  );

  String get offlineWeatherUnavailable => _pick(
    fr: 'Hors ligne — météo indisponible.',
    en: 'Offline — weather unavailable.',
    de: 'Offline — Wetter nicht verfügbar.',
    it: 'Offline — meteo non disponibile.',
    es: 'Sin conexión — clima no disponible.',
  );

  String get offlineLocationUnavailable => _pick(
    fr: 'Hors ligne — géolocalisation indisponible.',
    en: 'Offline — geolocation unavailable.',
    de: 'Offline — Geolokalisierung nicht verfügbar.',
    it: 'Offline — geolocalizzazione non disponibile.',
    es: 'Sin conexión — geolocalización no disponible.',
  );

  String get offlineBadgeLabel => _pick(
    fr: 'HORS LIGNE',
    en: 'OFFLINE',
    de: 'OFFLINE',
    it: 'OFFLINE',
    es: 'SIN CONEXIÓN',
  );

  String get saveExerciseButton => _pick(
        fr: "ENREGISTRER L'EXERCICE",
        en: 'SAVE EXERCISE',
        de: 'ÜBUNG SPEICHERN',
        it: 'SALVA ESERCIZIO',
        es: 'GUARDAR EJERCICIO',
      );

  String get sessionLabelShots => _pick(
        fr: 'Coups',
        en: 'Shots',
        de: 'Schüsse',
        it: 'Colpi',
        es: 'Disparos',
      );

  String get sessionLabelDistance => _pick(
        fr: 'Distance',
        en: 'Distance',
        de: 'Distanz',
        it: 'Distanza',
        es: 'Distancia',
      );

  String get sessionLabelTarget => _pick(
        fr: 'Cible',
        en: 'Target',
        de: 'Zielscheibe',
        it: 'Bersaglio',
        es: 'Blanco',
      );

  String get confirmDeleteTitle => _pick(
        fr: 'Confirmer la suppression',
        en: 'Confirm deletion',
        de: 'Löschen bestätigen',
        it: 'Conferma eliminazione',
        es: 'Confirmar eliminación',
      );

  String confirmDeleteSessionMessage(String sessionName) => _pick(
        fr: 'Voulez-vous vraiment supprimer la séance "$sessionName" ?',
        en: 'Do you really want to delete the session "$sessionName"?',
        de: 'Möchtest du die Sitzung "$sessionName" wirklich löschen?',
        it: 'Vuoi davvero eliminare la sessione "$sessionName"?',
        es: '¿Quieres eliminar la sesión "$sessionName"?',
      );

  String get actionCancel => _pick(
        fr: 'Annuler',
        en: 'Cancel',
        de: 'Abbrechen',
        it: 'Annulla',
        es: 'Cancelar',
      );

  String get actionDelete => sessionMenuDelete;

  String sessionDeletedSnack(String sessionName) => _pick(
        fr: '"$sessionName" supprimée',
        en: '"$sessionName" deleted',
        de: '"$sessionName" gelöscht',
        it: '"$sessionName" eliminata',
        es: '"$sessionName" eliminada',
      );

  String get sessionShareSubjectPrefix => _pick(
        fr: 'Séance de tir - ',
        en: 'Shooting session - ',
        de: 'Schießsitzung - ',
        it: 'Sessione di tiro - ',
        es: 'Sesión de tiro - ',
      );

  String get exportSessionTitle => _pick(
        fr: 'Exporter la séance',
        en: 'Export session',
        de: 'Sitzung exportieren',
        it: 'Esporta sessione',
        es: 'Exportar sesión',
      );

  String get exportSessionSubtitle => _pick(
        fr: 'Résumé texte prêt à copier / enregistrer.',
        en: 'Text summary ready to copy / save.',
        de: 'Textzusammenfassung zum Kopieren / Speichern.',
        it: 'Riepilogo di testo pronto da copiare / salvare.',
        es: 'Resumen de texto listo para copiar / guardar.',
      );

  String get actionCopy => _pick(
        fr: 'Copier',
        en: 'Copy',
        de: 'Kopieren',
        it: 'Copia',
        es: 'Copiar',
      );

  String get copiedSnack => _pick(
        fr: 'Résumé copié.',
        en: 'Summary copied.',
        de: 'Zusammenfassung kopiert.',
        it: 'Riepilogo copiato.',
        es: 'Resumen copiado.',
      );

  String get actionDownloadTxt => _pick(
        fr: 'Télécharger .txt',
        en: 'Download .txt',
        de: '.txt herunterladen',
        it: 'Scarica .txt',
        es: 'Descargar .txt',
      );

  String get downloadFailedSnack => _pick(
        fr: 'Impossible de télécharger le fichier.',
        en: 'Unable to download the file.',
        de: 'Datei konnte nicht heruntergeladen werden.',
        it: 'Impossibile scaricare il file.',
        es: 'No se pudo descargar el archivo.',
      );

  String get shareUnavailableSnack => _pick(
        fr: 'Partage indisponible sur cet appareil.',
        en: 'Sharing is unavailable on this device.',
        de: 'Teilen ist auf diesem Gerät nicht verfügbar.',
        it: 'Condivisione non disponibile su questo dispositivo.',
        es: 'Compartir no está disponible en este dispositivo.',
      );

  String get actionClose => _pick(
        fr: 'Fermer',
        en: 'Close',
        de: 'Schließen',
        it: 'Chiudi',
        es: 'Cerrar',
      );

  // --- PIN Screen ---
  
  String get configurePinCode => _pick(
        fr: 'Configurer le code PIN',
        en: 'Configure PIN code',
        de: 'PIN-Code konfigurieren',
        it: 'Configura codice PIN',
        es: 'Configurar código PIN',
      );

  String get choosePin => _pick(
        fr: 'Choisissez un code PIN',
        en: 'Choose a PIN code',
        de: 'Wählen Sie einen PIN-Code',
        it: 'Scegli un codice PIN',
        es: 'Elige un código PIN',
      );

  String get confirmPin => _pick(
        fr: 'Confirmez votre code PIN',
        en: 'Confirm your PIN code',
        de: 'Bestätigen Sie Ihren PIN-Code',
        it: 'Conferma il tuo codice PIN',
        es: 'Confirma tu código PIN',
      );

  String get pin6Digits => _pick(
        fr: 'Code à 6 chiffres',
        en: '6-digit code',
        de: '6-stelliger Code',
        it: 'Codice a 6 cifre',
        es: 'Código de 6 dígitos',
      );

  String get pinsDoNotMatch => _pick(
        fr: 'Les codes ne correspondent pas',
        en: 'PINs do not match',
        de: 'PINs stimmen nicht überein',
        it: 'I PIN non corrispondono',
        es: 'Los PIN no coinciden',
      );

  String get pinSetSuccess => _pick(
        fr: 'Code PIN configuré avec succès',
        en: 'PIN code configured successfully',
        de: 'PIN-Code erfolgreich konfiguriert',
        it: 'Codice PIN configurato con successo',
        es: 'Código PIN configurado correctamente',
      );

  String get benefits => _pick(
        fr: 'AVANTAGES',
        en: 'AVANTAGES',
        de: 'AVANTAGES',
        it: 'AVANTAGES',
        es: 'AVANTAGES',
      );

  String get viewProOffers => _pick(
        fr: 'VOIR LES OFFRES PRO',
        en: 'VIEW PRO OFFERS',
        de: 'PRO-ANGEBOTE ANSEHEN',
        it: 'VEDI LE OFFERTE PRO',
        es: 'VER OFERTAS PRO',
      );

  String premiumLimitMessage(String current, String max, String itemLabel) => _pick(
        fr: 'Limite atteinte ($current/$max). Passez à Premium pour ajouter des $itemLabel illimitées.',
        en: 'Limit reached ($current/$max). Upgrade to Premium to add unlimited $itemLabel.',
        de: 'Limit erreicht ($current/$max). Upgrade auf Premium, um unbegrenzte $itemLabel hinzuzufügen.',
        it: 'Limite raggiunto ($current/$max). Passa a Premium per aggiungere $itemLabel illimitati.',
        es: 'Límite alcanzado ($current/$max). Pasa a Premium para añadir $itemLabel ilimitados.',
      );

  String get restock => _pick(
        fr: 'Recompléter le stock',
        en: 'Restock',
        de: 'Bestand auffüllen',
        it: 'Rifornisci scorte',
        es: 'Reponer stock',
      );

  String get currentStock => _pick(
        fr: 'Stock actuel',
        en: 'Current stock',
        de: 'Aktueller Bestand',
        it: 'Scorte attuali',
        es: 'Stock actual',
      );

  String get cartridges => _pick(
        fr: 'cartouches',
        en: 'cartridges',
        de: 'Patronen',
        it: 'cartucce',
        es: 'cartuchos',
      );

  String get quantityToAdd => _pick(
        fr: 'Quantité à ajouter',
        en: 'Quantity to add',
        de: 'Menge hinzufügen',
        it: 'Quantità da aggiungere',
        es: 'Cantidad a agregar',
      );

  String get example250 => _pick(
        fr: 'Ex : 250',
        en: 'e.g.: 250',
        de: 'z.B.: 250',
        it: 'Es: 250',
        es: 'Ej: 250',
      );

  String get enterValidQuantity => _pick(
        fr: 'Entre une quantité valide (> 0).',
        en: 'Enter a valid quantity (> 0).',
        de: 'Gültige Menge eingeben (> 0).',
        it: 'Inserisci una quantità valida (> 0).',
        es: 'Ingresa una cantidad válida (> 0).',
      );

  String get stockUpdated => _pick(
        fr: 'Stock mis à jour',
        en: 'Stock updated',
        de: 'Bestand aktualisiert',
        it: 'Scorte aggiornate',
        es: 'Stock actualizado',
      );

  String get diagnosticToolTitle => _pick(
        fr: 'OUTIL DE DIAGNOSTIQUE',
        en: 'DIAGNOSTIC TOOL',
        de: 'DIAGNOSEWERKZEUG',
        it: 'DIAGNOSTICA',
        es: 'DIAGNÓSTICO',
      );

  String get diagnosticNew => _pick(
        fr: 'NOUVEAU DIAGNOSTIQUE',
        en: 'NEW DIAGNOSTIC',
        de: 'NEUE DIAGNOSE',
        it: 'NUOVA DIAGNOSI',
        es: 'NUEVO DIAGNÓSTICO',
      );

  String get diagnosticEmptyTitle => _pick(
        fr: 'Aucun diagnostique enregistré',
        en: 'No diagnostic saved',
        de: 'Keine Diagnose gespeichert',
        it: 'Nessuna diagnosi salvata',
        es: 'No hay diagnósticos guardados',
      );

  String get diagnosticEmptySubtitle => _pick(
        fr: 'Commencez un nouveau diagnostique pour\nidentifier les problèmes de vos armes',
        en: 'Start a new diagnostic to\nidentify issues with your weapons',
        de: 'Starte eine neue Diagnose, um\nProbleme mit deinen Waffen zu erkennen',
        it: 'Avvia una nuova diagnosi per\nidentificare i problemi delle tue armi',
        es: 'Inicia un nuevo diagnóstico para\nidentificar problemas con tus armas',
      );

  String get diagnosticDeleteTitle => _pick(
        fr: 'Supprimer le diagnostique',
        en: 'Delete diagnostic',
        de: 'Diagnose löschen',
        it: 'Elimina diagnosi',
        es: 'Eliminar diagnóstico',
      );

  String get diagnosticDeleteMessage => _pick(
        fr: 'Êtes-vous sûr de vouloir supprimer ce diagnostique ?',
        en: 'Are you sure you want to delete this diagnostic?',
        de: 'Möchtest du diese Diagnose wirklich löschen?',
        it: 'Sei sicuro di voler eliminare questa diagnosi?',
        es: '¿Seguro que quieres eliminar este diagnóstico?',
      );
String get diagnosticNoSpecificWeapon => _pick(
        fr: 'Diagnostique sans arme spécifique',
        en: 'Diagnostic without a specific weapon',
        de: 'Diagnose ohne bestimmte Waffe',
        it: 'Diagnosi senza arma specifica',
        es: 'Diagnóstico sin arma específica',
      );

  String get unknownWeapon => _pick(
        fr: 'Arme inconnue',
        en: 'Unknown weapon',
        de: 'Unbekannte Waffe',
        it: 'Arma sconosciuta',
        es: 'Arma desconocida',
      );

  String get decisionLabel => _pick(
        fr: 'DÉCISION',
        en: 'DECISION',
        de: 'ENTSCHEIDUNG',
        it: 'DECISIONE',
        es: 'DECISIÓN',
      );

  String get summaryLabel => _pick(
        fr: 'RÉSUMÉ',
        en: 'SUMMARY',
        de: 'ZUSAMMENFASSUNG',
        it: 'RIEPILOGO',
        es: 'RESUMEN',
      );

  String get previous => _pick(
        fr: 'PRÉCÉDENT',
        en: 'PREVIOUS',
        de: 'ZURÜCK',
        it: 'PRECEDENTE',
        es: 'ANTERIOR',
      );

  String get yesUpper => _pick(
        fr: 'OUI',
        en: 'YES',
        de: 'JA',
        it: 'SÌ',
        es: 'SÍ',
      );

  String get noUpper => _pick(
        fr: 'NON',
        en: 'NO',
        de: 'NEIN',
        it: 'NO',
        es: 'NO',
      );

  String get diagnosticOrSelectWeapon => _pick(
        fr: 'OU SÉLECTIONNEZ UNE ARME',
        en: 'OR SELECT A WEAPON',
        de: 'ODER EINE WAFFE AUSWÄHLEN',
        it: 'OPPURE SELEZIONA UN ARMA',
        es: 'O SELECCIONA UN ARMA',
      );

  String get diagnosticNoSpecificWeaponSubtitle => _pick(
        fr: 'Arbre complet - identification de la plateforme',
        en: 'Complete tree - platform identification',
        de: 'Vollständiger Ablauf - Plattformidentifikation',
        it: 'Albero completo - identificazione della piattaforma',
        es: 'Árbol completo - identificación de la plateforme',
      );

  String get diagnosticImmediateStopMessage => _pick(
        fr: "ARRÊT IMMÉDIAT\n\nProcédure de sécurisation immédiate requise.\n\nMettez l'arme en direction sûre, doigt hors détente, et interrompez toute manipulation.",
        en: 'IMMEDIATE STOP\n\nImmediate safety procedure required.\n\nPoint the weapon in a safe direction, keep your finger off the trigger, and stop all handling.',
        de: 'SOFORT STOPP\n\nSofortige Sicherheitsmaßnahme erforderlich.\n\nWaffe in sichere Richtung halten, Finger weg vom Abzug und jede Handhabung stoppen.',
        it: "STOP IMMEDIATO\n\nÈ richiesta una procedura di sicurezza immediata.\n\nPunta l'arma in una direzione sicura, tieni il dito fuori dal grilletto e interrompi ogni manipolazione.",
        es: 'PARADA INMEDIATA\n\nSe requiere un procedimiento de seguridad inmediato.\n\nApunta el arma en una dirección segura, mantén el dedo fuera del gatillo y detén cualquier manipulación.',
      );

  String get diagnosticUnknownStateMessage => _pick(
        fr: "ARRÊT - ÉTAT INCONNU\n\nConsidérez l'arme comme chargée et interrompez immédiatement toute manipulation jusqu'à identification claire de l'état.",
        en: 'STOP - UNKNOWN STATE\n\nTreat the weapon as loaded and stop all handling immediately until its state is clearly identified.',
        de: 'STOPP - UNBEKANNTER ZUSTAND\n\nBehandle die Waffe als geladen und stoppe jede Handhabung sofort, bis der Zustand eindeutig festgestellt ist.',
        it: "STOP - STATO SCONOSCIUTO\n\nConsidera l'arma carica e interrompi immediatamente ogni manipolazione finché lo stato non è chiaramente identificato.",
        es: 'PARADA - ESTADO DESCONOCIDO\n\nConsidera el arma cargada e interrumpe inmediatamente cualquier manipulación hasta identificar claramente su estado.',
      );

  String get closeUpper => _pick(
        fr: 'FERMER',
        en: 'CLOSE',
        de: 'SCHLIESSEN',
        it: 'CHIUDI',
        es: 'CERRAR',
      );

  String get immobilizeWeaponTitle => _pick(
        fr: "IMMOBILISATION DE L'ARME",
        en: 'WEAPON IMMOBILIZATION',
        de: 'WAFFE STILLLEGEN',
        it: "IMMOBILIZZAZIONE DELL'ARMA",
        es: 'INMOVILIZACIÓN DEL ARMA',
      );

  String get immobilizeWeaponMessage => _pick(
        fr: "Risque élevé.\n\nImmobilisez l'arme et faites contrôler par un armurier qualifié avant toute réutilisation.",
        en: 'High risk.\n\nTake the weapon out of service and have it checked by a qualified gunsmith before any further use.',
        de: 'Hohes Risiko.\n\nWaffe stilllegen und vor weiterer Nutzung von einem qualifizierten Büchsenmacher prüfen lassen.',
        it: "Rischio elevato.\n\nImmobilizza l'arma e falla controllare da un armaiolo qualificato prima di riutilizzarla.",
        es: 'Riesgo elevado.\n\nInmoviliza el arma y hazla revisar por un armero cualificado antes de volver a usarla.',
      );

  String get saveDiagnosticUpper => _pick(
        fr: 'ENREGISTRER LE DIAGNOSTIQUE',
        en: 'SAVE DIAGNOSTIC',
        de: 'DIAGNOSE SPEICHERN',
        it: 'SALVA DIAGNOSI',
        es: 'GUARDAR DIAGNÓSTICO',
      );

  String get diagnosticCompletedTitle => _pick(
        fr: 'DIAGNOSTIQUE TERMINÉ',
        en: 'DIAGNOSTIC COMPLETED',
        de: 'DIAGNOSE ABGESCHLOSSEN',
        it: 'DIAGNOSI COMPLETATA',
        es: 'DIAGNÓSTICO COMPLETADO',
      );

  String get finalDecisionLabel => _pick(
        fr: 'DÉCISION FINALE',
        en: 'FINAL DECISION',
        de: 'ENDGÜLTIGE ENTSCHEIDUNG',
        it: 'DECISIONE FINALE',
        es: 'DECISIÓN FINAL',
      );

  String get probableCausesLabel => _pick(
        fr: 'CAUSES PROBABLES',
        en: 'PROBABLE CAUSES',
        de: 'WAHRSCHEINLICHE URSACHEN',
        it: 'CAUSE PROBABILI',
        es: 'CAUSAS PROBABLES',
      );

  String get recommendedActionLabel => _pick(
        fr: 'CONDUITE À TENIR',
        en: 'RECOMMENDED ACTION',
        de: 'EMPFOHLENES VORGEHEN',
        it: 'AZIONE CONSIGLIATA',
        es: 'CONDUCTA RECOMENDADA',
      );

  String get diagnosticWeaponSelectionTitle => _pick(
        fr: 'Voulez-vous diagnostiquer une arme spécifique de votre inventaire ?',
        en: 'Do you want to diagnose a specific weapon from your inventory?',
        de: 'Möchtest du eine bestimmte Waffe aus deinem Bestand diagnostizieren?',
        it: 'Vuoi diagnosticare un’arma specifica del tuo inventario?',
        es: '¿Quieres diagnosticar un arma específica de tu inventario?',
      );

  String get diagnosticSafetyPhase => _pick(
        fr: 'PHASE DE SÉCURISATION IMMÉDIATE',
        en: 'IMMEDIATE SAFETY PHASE',
        de: 'SOFORTIGE SICHERHEITSPHASE',
        it: 'FASE DI SICUREZZA IMMEDIATA',
        es: 'FASE DE SEGURIDAD INMEDIATA',
      );

  String get diagnosticQuestion1 => _pick(
        fr: "L'arme est-elle immédiatement mise en direction sûre (safe direction) et doigt hors détente ?",
        en: 'Is the weapon immediately pointed in a safe direction and the finger off the trigger?',
        de: 'Wird die Waffe sofort in sichere Richtung gehalten und der Finger vom Abzug genommen?',
        it: 'L’arma è immediatamente puntata in una direzione sicura e il dito è fuori dal grilletto?',
        es: '¿Se apunta inmediatamente el arma en una dirección segura y el dedo está fuera del gatillo?',
      );

  String get diagnosticQuestion2 => _pick(
        fr: "Le tir a-t-il été interrompu immédiatement après l'anomalie ?",
        en: 'Was firing stopped immediately after the anomaly?',
        de: 'Wurde das Schießen unmittelbar nach der Störung unterbrochen?',
        it: 'Il tiro è stato interrotto immediatamente dopo l’anomalia?',
        es: '¿Se interrumpió el disparo inmediatamente después de la anomalía?',
      );

  String get diagnosticQuestion3 => _pick(
        fr: "L'état de l'arme est-il clairement identifié ?",
        en: 'Is the state of the weapon clearly identified?',
        de: 'Ist der Zustand der Waffe eindeutig festgestellt?',
        it: 'Lo stato dell’arma è chiaramente identificato?',
        es: '¿Está claramente identificado el estado del arma?',
      );

  String get diagnosticWeaponPossiblyLoaded => _pick(
        fr: 'Arme potentiellement chargée',
        en: 'Weapon potentially loaded',
        de: 'Waffe möglicherweise geladen',
        it: 'Arma potenzialmente carica',
        es: 'Arma potencialmente cargada',
      );

  String get diagnosticWeaponOpenedSafe => _pick(
        fr: 'Arme ouverte / neutralisée',
        en: 'Weapon open / neutralized',
        de: 'Waffe geöffnet / gesichert',
        it: 'Arma aperta / neutralizzata',
        es: 'Arma abierta / neutralizada',
      );

  String get diagnosticUnknownState => _pick(
        fr: 'État inconnu',
        en: 'Unknown state',
        de: 'Unbekannter Zustand',
        it: 'Stato sconosciuto',
        es: 'Estado desconocido',
      );

  String get diagnosticClassification => _pick(
        fr: 'CLASSIFICATION',
        en: 'CLASSIFICATION',
        de: 'KLASSIFIZIERUNG',
        it: 'CLASSIFICAZIONE',
        es: 'CLASIFICACIÓN',
      );

  String get diagnosticQuestion4 => _pick(
        fr: 'Quel est le problème principal observé ?',
        en: 'What is the main observed problem?',
        de: 'Was ist das hauptsächlich beobachtete Problem?',
        it: 'Qual è il problema principale osservato?',
        es: '¿Cuál es el principal problema observado?',
      );

  String get diagnosticIncidentNoFire => _pick(
        fr: 'Non-tir (clic / pas de départ)',
        en: 'Misfire (click / no shot)',
        de: 'Fehlzündung (Klick / kein Schuss)',
        it: 'Mancato sparo (clic / nessun colpo)',
        es: 'Fallo de disparo (clic / no sale el tiro)',
      );

  String get diagnosticIncidentHangfire => _pick(
        fr: 'Long feu (départ retardé / doute)',
        en: 'Hangfire (delayed shot / doubt)',
        de: 'Hangfire (verzögerter Schuss / Zweifel)',
        it: 'Fuoco ritardato (colpo ritardato / dubbio)',
        es: 'Fuego retardado (disparo tardío / duda)',
      );

  String get diagnosticIncidentUnintendedDischarge => _pick(
        fr: 'Départ intempestif',
        en: 'Unintended discharge',
        de: 'Unbeabsichtigte Schussabgabe',
        it: 'Partenza intempestiva',
        es: 'Disparo intempestivo',
      );

  String get diagnosticIncidentJam => _pick(
        fr: "Enrayage / incident d'alimentation",
        en: 'Jam / feeding incident',
        de: 'Störung / Zuführungsproblem',
        it: 'Inceppamento / problema di alimentatione',
        es: 'Atasco / fallo de alimentación',
      );

  String get diagnosticIncidentAccuracyDrop => _pick(
        fr: 'Baisse de précision',
        en: 'Accuracy drop',
        de: 'Präzisionsverlust',
        it: 'Calo di precisione',
        es: 'Bajada de precisión',
      );

  String get weaponLabel => _pick(
        fr: 'Arme',
        en: 'Weapon',
        de: 'Waffe',
        it: 'Arma',
        es: 'Arma',
      );

  String get caliberLabel => _pick(
        fr: 'Calibre',
        en: 'Caliber',
        de: 'Kaliber',
        it: 'Calibro',
        es: 'Calibre',
      );

  String get incidentLabel => _pick(
        fr: 'Incident',
        en: 'Incident',
        de: 'Vorfall',
        it: 'Incidente',
        es: 'Incidente',
      );

  String get hypothesisLabel => _pick(
        fr: 'Hypothèse',
        en: 'Hypothesis',
        de: 'Hypothese',
        it: 'Ipotesi',
        es: 'Hipótesis',
      );

  String get exercisesLabel => _pick(
        fr: 'Exercices',
        en: 'Exercises',
        de: 'Übungen',
        it: 'Esercizi',
        es: 'Ejercicios',
      );

  String get newAmmoTitle => _pick(
        fr: 'NOUVELLE MUNITION',
        en: 'NEW AMMO',
        de: 'NEUE MUNITION',
        it: 'NUOVE MUNIZIONI',
        es: 'NUEVA MUNICIÓN',
      );

  String get designationRegisterLabel => _pick(
        fr: 'Nom personnalisé',
        en: 'Custom name',
        de: 'Benutzerdefinierter Name',
        it: 'Nome personalizzato',
        es: 'Nombre personalizado',
      );

  String get brandLabel => _pick(
        fr: 'Marque',
        en: 'Brand',
        de: 'Marke',
        it: 'Marca',
        es: 'Marca',
      );

  String get typeLabel => _pick(
        fr: 'Type',
        en: 'Type',
        de: 'Typ',
        it: 'Tipo',
        es: 'Tipo',
      );

  String get initialQuantityLabel => _pick(
        fr: 'QUANTITÉ INITIALE',
        en: 'INITIAL QUANTITY',
        de: 'ANFANGSMENGE',
        it: 'QUANTITÀ INIZIALE',
        es: 'CANTIDAD INICIAL',
      );

  String get commentOptionalLabel => _pick(
        fr: 'COMMENTAIRE',
        en: 'COMMENT',
        de: 'KOMMENTAR',
        it: 'COMMENTO',
        es: 'COMENTARIO',
      );

  String get itemPhotoLabel => _pick(
        fr: 'Photo',
        en: 'Photo',
        de: 'Foto',
        it: 'Foto',
        es: 'Foto',
      );

  String get itemDocumentsLabel => _pick(
        fr: 'Documents',
        en: 'Documents',
        de: 'Dokumente',
        it: 'Documenti',
        es: 'Documentos',
      );

  String get clickToAddPhoto => _pick(
        fr: 'Cliquer pour ajouter une photo',
        en: 'Tap to add a photo',
        de: 'Tippen, um ein Foto hinzuzufügen',
        it: 'Tocca per aggiungere una foto',
        es: 'Pulsa para añadir una foto',
      );

  String get clickToAddDocument => _pick(
        fr: 'Cliquer pour ajouter un document',
        en: 'Tap to add a document',
        de: 'Tippen, um ein Dokument hinzuzufügen',
        it: 'Tocca per aggiungere un documento',
        es: 'Pulsa para añadir un documento',
      );

  String get trackingOptionsTitle => _pick(
        fr: 'OPTIONS DE SUIVI',
        en: 'TRACKING OPTIONS',
        de: 'NACHVERFOLGUNGSOPTIONEN',
        it: 'OPZIONI DI TRACCIAMENTO',
        es: 'OPCIONES DE SEGUIMIENTO',
      );

  String get trackingOptionsSubtitle => _pick(
        fr: 'Activez les indicateurs que vous souhaitez suivre',
        en: 'Enable the indicators you want to track',
        de: 'Aktiviere die Indikatoren, die du verfolgen möchtest',
        it: 'Attiva gli indicatori che vuoi monitorare',
        es: 'Activa los indicadores que quieras seguir',
      );

  String get stockTrackingLabel => _pick(
        fr: 'Suivi du stock',
        en: 'Stock tracking',
        de: 'Bestandsverfolgung',
        it: 'Monitoraggio scorte',
        es: 'Seguimiento de stock',
      );

  String get stockTrackingSubtitle => _pick(
        fr: 'Alerte quand le stock est bas',
        en: 'Alert when stock is low',
        de: 'Warnung bei niedrigem Bestand',
        it: 'Avviso quando le scorte sono basse',
        es: 'Aviso cuando el stock es bajo',
      );

  String get stockAlertThresholdLabel => _pick(
        fr: "Seuil d'alerte stock",
        en: 'Stock alert threshold',
        de: 'Bestandswarnschwelle',
        it: 'Soglia di avviso scorte',
        es: 'Umbral de alerta de stock',
      );

  String get saveItemButton => _pick(
        fr: 'ENREGISTRER LE MATÉRIEL',
        en: 'SAVE ITEM',
        de: 'AUSRÜSTUNG SPEICHERN',
        it: 'SALVA MATERIALE',
        es: 'GUARDAR MATERIAL',
      );

  String get saveChangesButton => _pick(
        fr: 'ENREGISTRER LES MODIFICATIONS',
        en: 'SAVE CHANGES',
        de: 'ÄNDERUNGEN SPEICHERN',
        it: 'SALVA MODIFICHE',
        es: 'GUARDAR CAMBIOS',
      );

  String get batteryChangeDateLabel => _pick(
        fr: 'Date de changement de pile',
        en: 'Battery change date',
        de: 'Datum des Batteriewechsels',
        it: 'Data di sostituzione batteria',
        es: 'Fecha de cambio de batería',
      );

  String get batteryChangeDateSubtitle => _pick(
        fr: 'Date du dernier remplacement',
        en: 'Last replacement date',
        de: 'Datum des letzten Austauschs',
        it: 'Data dell’ultima sostituzione',
        es: 'Fecha del último reemplazo',
      );

  String get lastChangeLabel => _pick(
        fr: 'Dernier changement',
        en: 'Last change',
        de: 'Letzter Wechsel',
        it: 'Ultimo cambio',
        es: 'Último cambio',
      );

  String get selectDateLabel => _pick(
        fr: 'Sélectionner une date',
        en: 'Select a date',
        de: 'Datum auswählen',
        it: 'Seleziona una data',
        es: 'Selecciona una fecha',
      );

  String get calendarLabel => _pick(
        fr: 'Calendrier',
        en: 'Calendar',
        de: 'Kalender',
        it: 'Calendario',
        es: 'Calendario',
      );

  String get accessoryWearTrackingLabel => _pick(
        fr: "Suivi d'usure de l'accessoire",
        en: 'Accessory wear tracking',
        de: 'Zubehörverschleiß-Tracking',
        it: 'Monitoraggio usura accessorio',
        es: 'Seguimiento de desgaste del accesorio',
      );

  String get weaponWearTrackingLabel => _pick(
        fr: 'Suivi de l’usure de l’arme',
        en: 'Weapon wear monitoring',
        de: 'Waffenverschleiß-Tracking',
        it: 'Monitoraggio usura arma',
        es: 'Monitoreo del desgaste del arma',
      );

  String get weaponWearTrackingSubtitle => _pick(
        fr: 'Usure selon tirs',
        en: 'Wear from shots',
        de: 'Verschleiß durch Schüsse',
        it: 'Usura dai colpi',
        es: 'Desgaste por disparos',
      );

  String get accessoryWearTrackingSubtitle => _pick(
        fr: 'Calculé selon les coups tirés',
        en: 'Calculated based on shots fired',
        de: 'Berechnet anhand der abgegebenen Schüsse',
        it: 'Calcolato in base ai colpi sparati',
        es: 'Calculado según los disparos realizados',
      );

  String get accessoryCleaningTrackingLabel => _pick(
        fr: "Suivi de salissure de l'arme",
        en: 'Weapon fouling tracking',
        de: 'Verfolgung der Verschmutzung der Waffe',
        it: "Monitoraggio dello sporco dell'arma",
        es: 'Seguimiento de la suciedad del arma',
      );

  String get weaponCleaningTrackingLabel => _pick(
        fr: 'Suivi de l’encrassement de l’arme',
        en: 'Weapon fouling monitoring',
        de: 'Waffenverschmutzung-Tracking',
        it: "Monitoraggio dello sporco dell'arma",
        es: 'Monitoreo de la suciedad del arma',
      );

  String get weaponCleaningTrackingSubtitle => _pick(
        fr: 'Encrassement et entretien',
        en: 'Fouling and maintenance',
        de: 'Verschmutzung und Wartung',
        it: 'Sporco e manutenzione',
        es: 'Suciedad y mantenimiento',
      );

  String get weaponRoundCounterLabel => _pick(
        fr: 'Suivi du compteur de coups',
        en: 'Shot counter monitoring',
        de: 'Schusszähler-Tracking',
        it: 'Monitoraggio contatore colpi',
        es: 'Monitoreo del contador de disparos',
      );

  String get weaponRoundCounterSubtitle => _pick(
        fr: 'Total des tirs',
        en: 'Total shots',
        de: 'Gesamtzahl der Schüsse',
        it: 'Totale colpi',
        es: 'Total de disparos',
      );

  String get initialRoundCounterLabel => _pick(
        fr: 'Valeur de départ',
        en: 'Starting value',
        de: 'Startwert',
        it: 'Valore iniziale',
        es: 'Valor inicial',
      );

  String get wearThresholdLabel => _pick(
        fr: 'Coups avant contrôle',
        en: 'Shots before check',
        de: 'Schüsse vor Kontrolle',
        it: 'Colpi prima controllo',
        es: 'Disparos antes control',
      );

  String get accessoryCleaningTrackingSubtitle => _pick(
        fr: "Rappel de nettoyage selon l'utilisation",
        en: 'Cleaning reminder based on usage',
        de: 'Reinigungserinnerung je nach Nutzung',
        it: 'Promemoria pulizia in base all’uso',
        es: 'Recordatorio de limpieza según el uso',
      );

  String get revisionThresholdShotsLabel => _pick(
        fr: 'Seuil avant révision',
        en: 'Revision threshold',
        de: 'Schwelle vor Revision',
        it: 'Soglia prima revisione',
        es: 'Umbral antes de revisión',
      );

  String get cleaningThresholdShotsLabel => _pick(
        fr: 'Coups avant nettoyage',
        en: 'Shots before cleaning',
        de: 'Schüsse vor Reinigung',
        it: 'Colpi prima pulizia',
        es: 'Disparos antes limpieza',
      );

  String get customOtherLabel => _pick(
        fr: 'Autre (personnalisé)',
        en: 'Other (custom)',
        de: 'Andere (benutzerdefiniert)',
        it: 'Altro (personalizzato)',
        es: 'Otro (personalizado)',
      );

  String get customTypeLabel => _pick(
        fr: 'TYPE (PERSONNALISÉ)',
        en: 'TYPE (CUSTOM)',
        de: 'TYP (BENUTZERDEFINIERT)',
        it: 'TIPO (PERSONALIZZATO)',
        es: 'TIPO (PERSONALIZADO)',
      );

  String get serialNumberLabel => _pick(
        fr: 'N° SÉRIE',
        en: 'SERIAL NUMBER',
        de: 'SERIENNUMMER',
        it: 'NUMERO DI SERIE',
        es: 'N.º DE SERIE',
      );

  String get weightGramsLabel => _pick(
        fr: 'POIDS (G)',
        en: 'WEIGHT (G)',
        de: 'GEWICHT (G)',
        it: 'PESO (G)',
        es: 'PESO (G)',
      );

  String get quantityRequiredError => _pick(
        fr: 'Quantité obligatoire',
        en: 'Quantity required',
        de: 'Menge erforderlich',
        it: 'Quantità obbligatoria',
        es: 'Cantidad obligatoria',
      );

  String get brandModelLabel => _pick(
        fr: 'MARQUE / MODÈLE',
        en: 'BRAND / MODEL',
        de: 'MARKE / MODELL',
        it: 'MARCA / MODELLO',
        es: 'MARCA / MODELO',
      );

  String get itemDefaultDocumentName => _pick(
        fr: 'Document',
        en: 'Document',
        de: 'Dokument',
        it: 'Documento',
        es: 'Documento',
      );

  String get itemFreePdfLimitSingle => _pick(
        fr: 'Version gratuite : 1 document PDF maximum par fiche. Passez à Pro pour illimité.',
        en: 'Free version: 1 PDF document maximum per item. Upgrade to Pro for unlimited documents.',
        de: 'Kostenlose Version: maximal 1 PDF-Dokument pro Eintrag. Upgrade auf Pro für unbegrenzte Dokumente.',
        it: 'Versione gratuita: massimo 1 documento PDF per scheda. Passa a Pro per documenti illimitati.',
        es: 'Versión gratuita: máximo 1 documento PDF por ficha. Pasa a Pro para documentos ilimitados.',
      );

  String get itemFreePdfLimitReached => _pick(
        fr: 'Version gratuite : limite de documents atteinte pour cette fiche.',
        en: 'Free version: document limit reached for this item.',
        de: 'Kostenlose Version: Dokumentenlimit für diesen Eintrag erreicht.',
        it: 'Versione gratuita: limite di documenti raggiunto per questa scheda.',
        es: 'Versión gratuita: límite de documentos alcanzado para esta ficha.',
      );

  String itemPageTitle(String category, bool isEdit) {
    switch (category) {
      case 'ARME':
        return isEdit
            ? _pick(fr: 'ÉDITER ARME', en: 'EDIT WEAPON', de: 'WAFFE BEARBEITEN', it: 'MODIFICA ARMA', es: 'EDITAR ARMA')
            : _pick(fr: 'NOUVELLE ARME', en: 'NEW WEAPON', de: 'NEUE WAFFE', it: 'NUOVA ARMA', es: 'NUEVA ARMA');
      case 'MUNITION':
        return isEdit
            ? _pick(fr: 'ÉDITER MUNITION', en: 'EDIT AMMO', de: 'MUNITION BEARBEITEN', it: 'MODIFICA MUNIZIONE', es: 'EDITAR MUNICIÓN')
            : _pick(fr: 'NOUVELLE MUNITION', en: 'NEW AMMO', de: 'NEUE MUNITION', it: 'NUOVA MUNIZIONE', es: 'NUEVA MUNICIÓN');
      case 'ACCESSOIRE':
        return isEdit
            ? _pick(fr: 'ÉDITER ACCESSOIRE', en: 'EDIT ACCESSORY', de: 'ZUBEHÖR BEARBEITEN', it: 'MODIFICA ACCESSORIO', es: 'EDITAR ACCESSORIO')
            : _pick(fr: 'NOUVEL ACCESSOIRE', en: 'NEW ACCESSORY', de: 'NEUES ZUBEHÖR', it: 'NUOVO ACCESSORIO', es: 'NUEVO ACCESSORIO');
      default:
        return isEdit
            ? _pick(fr: 'ÉDITER MATÉRIEL', en: 'EDIT EQUIPMENT', de: 'AUSRÜSTUNG BEARBEITEN', it: 'MODIFICA MATERIALE', es: 'EDITAR MATERIAL')
            : _pick(fr: 'NOUVEAU MATÉRIEL', en: 'NEW EQUIPMENT', de: 'NEUE AUSRÜSTUNG', it: 'NUOVO MATERIALE', es: 'NUEVO MATERIAL');
    }
  }

  String itemPrimaryNameLabel(String category) {
    switch (category) {
      case 'ARME':
        return _pick(fr: 'Nom personnalisé', en: 'Custom name', de: 'Benutzerdefinierter Name', it: 'Nome personalizzato', es: 'Nombre personalizado');
      case 'MUNITION':
        return designationRegisterLabel;
      case 'ACCESSOIRE':
        return _pick(fr: 'Nom personnalisé', en: 'Custom name', de: 'Benutzerdefinierter Name', it: 'Nome personalizzato', es: 'Nombre personnalisé');
      default:
        return _pick(fr: 'NOM', en: 'NAME', de: 'NAME', it: 'NOME', es: 'NOMBRE');
    }
  }

  String itemPrimaryNameHint(String category) {
    switch (category) {
      case 'ARME':
        return _pick(fr: 'ex: Glock 17 Gen 5', en: 'e.g. Glock 17 Gen 5', de: 'z. B. Glock 17 Gen 5', it: 'es: Glock 17 Gen 5', es: 'ej.: Glock 17 Gen 5');
      case 'MUNITION':
        return _pick(fr: 'ex: 9x19 FMJ 124gr (boîte 50)', en: 'e.g. 9x19 FMJ 124gr (box of 50)', de: 'z. B. 9x19 FMJ 124gr (50er-Pack)', it: 'es: 9x19 FMJ 124gr (scatola da 50)', es: 'ej.: 9x19 FMJ 124gr (caja de 50)');
      case 'ACCESSOIRE':
        return _pick(fr: 'ex: HS507C / Kydex / Peltor SportTac...', en: 'e.g. HS507C / Kydex / Peltor SportTac...', de: 'z. B. HS507C / Kydex / Peltor SportTac...', it: 'es: HS507C / Kydex / Peltor SportTac...', es: 'ej.: HS507C / Kydex / Peltor SportTac...');
      default:
        return _pick(fr: 'Nom', en: 'Name', de: 'Name', it: 'Nome', es: 'Nombre');
    }
  }

  String get itemWeaponBrandHint => _pick(
        fr: 'ex: Glock',
        en: 'e.g. Glock',
        de: 'z. B. Glock',
        it: 'es: Glock',
        es: 'ej.: Glock',
      );

  String get itemAmmoBrandHint => _pick(
        fr: 'ex: Magtech',
        en: 'e.g. Magtech',
        de: 'z. B. Magtech',
        it: 'es: Magtech',
        es: 'ej.: Magtech',
      );

  String get itemAccessoryBrandHint => _pick(
        fr: 'ex: Holosun, Safariland, Peltor',
        en: 'e.g. Holosun, Safariland, Peltor',
        de: 'z. B. Holosun, Safariland, Peltor',
        it: 'es: Holosun, Safariland, Peltor',
        es: 'ej.: Holosun, Safariland, Peltor',
      );

  String get itemCaliberHint => _pick(
        fr: 'ex: 9x19mm',
        en: 'e.g. 9x19mm',
        de: 'z. B. 9x19mm',
        it: 'es: 9x19mm',
        es: 'ej.: 9x19mm',
      );

  String get itemSerialNumberHint => _pick(
        fr: 'ex: ABC-12345',
        en: 'e.g. ABC-12345',
        de: 'z. B. ABC-12345',
        it: 'es: ABC-12345',
        es: 'ej.: ABC-12345',
      );

  String get itemWeightHint => _pick(
        fr: 'ex: 705',
        en: 'e.g. 705',
        de: 'z. B. 705',
        it: 'es: 705',
        es: 'ej.: 705',
      );

  String get itemProjectileCustomHint => _pick(
        fr: 'ex: Gold Dot, JHP, FTX…',
        en: 'e.g. Gold Dot, JHP, FTX…',
        de: 'z. B. Gold Dot, JHP, FTX…',
        it: 'es: Gold Dot, JHP, FTX…',
        es: 'ej.: Gold Dot, JHP, FTX…',
      );

  String get itemQuantityHint => _pick(
        fr: 'ex: 500',
        en: 'e.g. 500',
        de: 'z. B. 500',
        it: 'es: 500',
        es: 'ej.: 500',
      );

  String get itemAccessoryCustomTypeHint => _pick(
        fr: 'ex: Support cible, Outil...',
        en: 'e.g. Target stand, Tool...',
        de: 'z. B. Zielhalter, Werkzeug...',
        it: 'es: Supporto bersaglio, Strumento...',
        es: 'ej.: Soporte de blanco, Herramienta...',
      );

  String get itemSavedSuccess => _pick(
        fr: 'Modifications enregistrées',
        en: 'Changes saved',
        de: 'Änderungen gespeichert',
        it: 'Modifiche salvate',
        es: 'Cambios guardados',
      );

  String get itemAddedSuccess => _pick(
        fr: 'Matériel ajouté',
        en: 'Equipment added',
        de: 'Ausrüstung hinzugefügt',
        it: 'Attrezzatura aggiunta',
        es: 'Equipo agregado',
      );

  String get itemCommentHint => _pick(
        fr: 'Ex: Note personnelle, lot, date d’achat, particularités…',
        en: 'Ex: Personal note, batch, purchase date, specifics…',
        de: 'z.B. Persönliche Notiz, Los, Kaufdatum, Besonderheiten…',
        it: 'Es: Nota personale, lotto, data di acquisto, particolarità…',
        es: 'Ej: Nota personal, lote, fecha de compra, particularidades…',
      );

  String itemDocumentTypeLabelForValue(String value) {
    switch (value) {
      case 'Facture':
        return _pick(fr: 'Facture', en: 'Invoice', de: 'Rechnung', it: 'Fattura', es: 'Factura');
      case 'Révision':
        return _pick(fr: 'Révision', en: 'Service', de: 'Inspektion', it: 'Revisione', es: 'Revisión');
      case 'Entretien':
        return _pick(fr: 'Entretien', en: 'Maintenance', de: 'Wartung', it: 'Manutenzione', es: 'Mantenimiento');
      case 'Manuel':
        return _pick(fr: 'Manuel', en: 'Manual', de: 'Handbuch', it: 'Manuale', es: 'Manual');
      case 'Garantie':
        return _pick(fr: 'Garantie', en: 'Warranty', de: 'Garantie', it: 'Garanzia', es: 'Garantía');
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String itemAccessoryTypeLabel(String value) {
    switch (value) {
      case 'Optiques':
        return _pick(fr: 'Optiques', en: 'Optics', de: 'Optiken', it: 'Ottiche', es: 'Ópticas');
      case 'Lampes':
        return _pick(fr: 'Lampes', en: 'Lights', de: 'Lampen', it: 'Luci', es: 'Linternas');
      case 'Lasers':
        return _pick(fr: 'Lasers', en: 'Lasers', de: 'Laser', it: 'Laser', es: 'Láseres');
      case 'Holsters':
        return _pick(fr: 'Holsters', en: 'Holsters', de: 'Holster', it: 'Fondine', es: 'Fundas');
      case 'Sangles':
        return _pick(fr: 'Sangles', en: 'Slings', de: 'Trageriemen', it: 'Cinghie', es: 'Correas');
      case 'Chargeurs':
        return _pick(fr: 'Chargeurs', en: 'Magazines', de: 'Magazine', it: 'Caricatori', es: 'Cargadores');
      case 'Porte-chargeurs':
        return _pick(fr: 'Porte-chargeurs', en: 'Mag pouches', de: 'Magazintaschen', it: 'Portacaricatori', es: 'Portacargadores');
      case 'Nettoyage':
        return _pick(fr: 'Nettoyage', en: 'Cleaning', de: 'Reinigung', it: 'Pulizia', es: 'Limpieza');
      case 'Modérateurs':
        return _pick(fr: 'Modérateurs', en: 'Suppressors', de: 'Schalldämpfer', it: 'Soppressori', es: 'Supresores');
      case 'Réducteur de son':
        return _pick(fr: 'Réducteur de son', en: 'Sound moderator', de: 'Schalldämpfer', it: 'Moderatore di suono', es: 'Moderador de sonido');
      case 'Compensateurs':
        return _pick(fr: 'Compensateurs', en: 'Compensators', de: 'Kompensatoren', it: 'Compensatori', es: 'Compensadores');
      case 'Poignées':
        return _pick(fr: 'Poignées', en: 'Grips', de: 'Griffe', it: 'Impugnature', es: 'Empuñaduras');
      case 'Bipieds':
        return _pick(fr: 'Bipieds', en: 'Bipods', de: 'Zweibeine', it: 'Bipiedi', es: 'Bípodes');
      case 'Montages':
        return _pick(fr: 'Montages', en: 'Mounts', de: 'Montagen', it: 'Attacchi', es: 'Montajes');
      case 'Visée mécanique':
        return _pick(fr: 'Visée mécanique', en: 'Iron sights', de: 'Mechanische Visierung', it: 'Mire meccaniche', es: 'Miras mecánicas');
      case 'Crosses':
        return _pick(fr: 'Crosses', en: 'Stocks', de: 'Schäfte', it: 'Calci', es: 'Culatas');
      case 'Détentes':
        return _pick(fr: 'Détentes', en: 'Triggers', de: 'Abzüge', it: 'Grilletti', es: 'Disparadores');
      case 'Pièces internes':
        return _pick(fr: 'Pièces internes', en: 'Internal parts', de: 'Innenteile', it: 'Componenti interni', es: 'Piezas internas');
      case 'Transport':
        return _pick(fr: 'Transport', en: 'Transport', de: 'Transport', it: 'Trasporto', es: 'Transporte');
      case 'Sécurité':
        return _pick(fr: 'Sécurité', en: 'Safety', de: 'Sicherheit', it: 'Sicurezza', es: 'Seguridad');
      case 'Protections':
        return _pick(fr: 'Protections', en: 'Protection gear', de: 'Schutzausrüstung', it: 'Protezioni', es: 'Protecciones');
      case 'Chronographes':
        return _pick(fr: 'Chronographes', en: 'Chronographs', de: 'Chronographen', it: 'Cronografi', es: 'Cronógrafos');
      case 'Timers':
        return _pick(fr: 'Timers', en: 'Timers', de: 'Timer', it: 'Timer', es: 'Temporizadores');
      case 'Cibles':
        return _pick(fr: 'Cibles', en: 'Targets', de: 'Ziele', it: 'Bersagli', es: 'Blancos');
      case 'Supports de tir':
        return _pick(fr: 'Supports de tir', en: 'Shooting rests', de: 'Schießauflagen', it: 'Supporti di tiro', es: 'Apoyos de tiro');
      case 'Outils':
        return _pick(fr: 'Outils', en: 'Tools', de: 'Werkzeuge', it: 'Strumenti', es: 'Herramientas');
      case 'Divers':
        return _pick(fr: 'Divers', en: 'Miscellaneous', de: 'Verschiedenes', it: 'Vari', es: 'Varios');
      default:
        return value;
    }
  }

  String itemWeaponTypeLabel(String value) {
    switch (value) {
      case 'Pistolet semi-auto':
        return _pick(fr: 'Pistolet semi-auto', en: 'Semi-auto pistol', de: 'Selbstladepistole', it: 'Pistola semiautomatica', es: 'Pistola semiautomática');
      case 'Révolver':
        return _pick(fr: 'Révolver', en: 'Revolver', de: 'Revolver', it: 'Revolver', es: 'Revólver');
      case 'Pistolet mitrailleur':
        return _pick(fr: 'Pistolet mitrailleur', en: 'Submachine gun', de: 'Maschinenpistole', it: 'Pistola mitragliatrice', es: 'Subfusil');
      case "Fusil d'assaut":
        return _pick(fr: "Fusil d'assaut", en: 'Assault rifle', de: 'Sturmgewehr', it: "Fucile d'assalto", es: 'Fusil de asalto');
      case 'Fusil mitrailleur':
        return _pick(fr: 'Fusil mitrailleur', en: 'Machine rifle', de: 'Maschinengewehr', it: 'Fucile mitragliatore', es: 'Fusil ametrallador');
      case 'Carabine':
        return _pick(fr: 'Carabine', en: 'Carbine', de: 'Karabiner', it: 'Carabina', es: 'Carabina');
      case 'Fusil à pompe':
        return _pick(fr: 'Fusil à pompe', en: 'Pump shotgun', de: 'Pumpflinte', it: 'Fucile a pompa', es: 'Escopeta de bombeo');
      case 'Fusil de chasse':
        return _pick(fr: 'Fusil de chasse', en: 'Shotgun', de: 'Jagdflinte', it: 'Fucile da caccia', es: 'Escopeta de caza');
      case 'Fusil de précision':
        return _pick(fr: 'Fusil de précision', en: 'Precision rifle', de: 'Präzisionsgewehr', it: 'Fucile di précisione', es: 'Rifle de precisión');
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String itemProjectileTypeLabel(String value) {
    switch (value) {
      case 'FMJ':
        return 'FMJ';
      case 'TMJ':
        return 'TMJ';
      case 'Pointe creuse (JHP)':
        return _pick(fr: 'Pointe creuse (JHP)', en: 'Hollow point (JHP)', de: 'Hohlspitze (JHP)', it: 'Punta cava (JHP)', es: 'Punta hueca (JHP)');
      case 'Gold Dot':
        return 'Gold Dot';
      case 'Soft Point':
        return 'Soft Point';
      case 'Plomb':
        return _pick(fr: 'Plomb', en: 'Lead', de: 'Blei', it: 'Piombo', es: 'Plomo');
      case 'Subsonique':
        return _pick(fr: 'Subsonique', en: 'Subsonic', de: 'Unterschall', it: 'Subsonico', es: 'Subsónico');
      case 'Traçante':
        return _pick(fr: 'Traçante', en: 'Tracer', de: 'Leuchtspur', it: 'Tracciante', es: 'Trazadora');
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String get diagnosticDefaultFinal => _pick(
        fr: 'CAUSES MULTIFACTORIELLES — CONTRÔLE RECOMMANDÉ',
        en: 'MULTIFACTORIAL CAUSES — INSPECTION RECOMMENDED',
        de: 'MULTIFAKTORIELLE URSACHEN — KONTROLLE EMPFOHLEN',
        it: 'CAUSE MULTIFATTORIALI — CONTROLLO CONSIGLIATO',
        es: 'CAUSAS MULTIFACTORIALES — CONTROL RECOMENDADO',
      );

  String get diagnosticNoFireLabel => _pick(
        fr: 'NON-TIR',
        en: 'MISFIRE',
        de: 'FEHLZÜNDUNG',
        it: 'MANCATO SPARO',
        es: 'FALLO DE DISPARO',
      );

  String get diagnosticHangfireLabel => _pick(
        fr: 'LONG FEU',
        en: 'HANGFIRE',
        de: 'HANGFIRE',
        it: 'FUOCO RITARDATO',
        es: 'FUEGO RETARDADO',
      );

  String get diagnosticUnintendedDischargeLabel => _pick(
        fr: 'DÉPART INTEMPESTIF',
        en: 'UNINTENDED DISCHARGE',
        de: 'UNBEABSICHTIGTE SCHUSSABGABE',
        it: 'PARTENZA INTEMPESTIVA',
        es: 'DISPARO INTEMPESTIVO',
      );

  String get diagnosticJamLabel => _pick(
        fr: 'ENRAYAGE',
        en: 'JAM',
        de: 'STÖRUNG',
        it: 'INCEPPAMENTO',
        es: 'ATASCO',
      );

  String get diagnosticAccuracyDropLabel => _pick(
        fr: 'BAISSE DE PRÉCISION',
        en: 'ACCURACY DROP',
        de: 'PRÄZISIONSVERLUST',
        it: 'CALO DI PRECISIONE',
        es: 'BAJADA DE PRECISIÓN',
      );

  String get diagnosticQuestion5 => _pick(
        fr: "À l'appui de détente, entendez-vous la percussion (clic) ?",
        en: 'When pulling the trigger, do you hear the striker impact (click)?',
        de: 'Hörst du beim Betätigen des Abzugs den Schlagbolzen (Klick)?',
        it: 'Premendo il grilletto, senti la percussione (clic)?',
        es: 'Al accionar el gatillo, ¿oyes la percusión (clic)?',
      );

  String get diagnosticQuestion6 => _pick(
        fr: "Après extraction, y a-t-il une empreinte de percussion sur l'amorce ?",
        en: 'After extraction, is there a firing pin mark on the primer?',
        de: 'Ist nach dem Auswerfen ein Schlagbolzenabdruck auf dem Zündhütchen sichtbar?',
        it: "Dopo l'estrazione, c'è un'impronta di percussione sull'innesco?",
        es: 'Tras la extracción, ¿hay una marca de percusión en el pistón?',
      );

  String get diagnosticQuestion6Description => _pick(
        fr: "Si l'état est douteux, considérez l'arme chargée et sécurisez avant toute extraction.",
        en: 'If the state is uncertain, consider the weapon loaded and make it safe before any extraction.',
        de: 'Wenn der Zustand unklar ist, behandle die Waffe als geladen und sichere sie vor jedem Auswerfen.',
        it: "Se lo stato è incerto, considera l'arma carica e mettila in sicurezza prima di qualsiasi estrazione.",
        es: 'Si el estado es dudoso, considera el arma cargada y asegurala antes de cualquier extracción.',
      );

  String get diagnosticQuestion7 => _pick(
        fr: "L'empreinte est-elle bien centrée et suffisamment marquée ?",
        en: 'Is the mark well centered and sufficiently pronounced?',
        de: 'Ist der Abdruck gut zentriert und deutlich genug?',
        it: 'L’impronta è ben centrata e sufficientemente marcata?',
        es: '¿La marca está bien centrada y suficientemente marcada?',
      );

  String get diagnosticQuestion7Description => _pick(
        fr: 'Une percussion décentrée/peu profonde peut indiquer: verrouillage incomplet, ressort de percuteur fatigué, canal percuteur encrassé.',
        en: 'An off-center or shallow strike may indicate incomplete lockup, a tired firing pin spring, or a dirty firing pin channel.',
        de: 'Ein außermittiger oder flacher Abdruck kann auf unvollständige Verriegelung, eine schwache Schlagbolzenfeder oder einen verschmutzten Schlagbolzenkanal hinweisen.',
        it: 'Una percussione decentrata o poco profonda può indicare chiusura incompleta, molla del percussore stanca o canale del percussore sporco.',
        es: 'Una percusión descentrada o poco profunda puede indicar cierre incompleto, muelle del percutor fatigado o canal del percutor sucio.',
      );

  String get diagnosticQuestion8 => _pick(
        fr: "La cartouche était-elle correctement chambrée / l'arme verrouillée ?",
        en: 'Was the cartridge properly chambered / the weapon locked?',
        de: 'War die Patrone korrekt im Patronenlager / die Waffe verriegelt?',
        it: 'La cartuccia era correttamente camerata / l’arma era chiusa?',
        es: '¿El cartucho estaba correctamente recamarado / el arma cerrada?',
      );

  String get diagnosticQuestion8Description => _pick(
        fr: "Sur certaines armes, une sûreté passive empêche la percussion si le verrou n'est pas totalement engagé.",
        en: 'On some weapons, a passive safety prevents firing if the lock is not fully engaged.',
        de: 'Bei manchen Waffen verhindert eine passive Sicherung den Schlag, wenn die Verriegelung nicht vollständig geschlossen ist.',
        it: 'Su alcune armi, una sicura passiva impedisce la percussione se la chiusura non è completamente ingaggiata.',
        es: 'En algunas armas, un seguro pasivo impide la percusión si el cierre no está completamente encajado.',
      );

  String get diagnosticQuestion9 => _pick(
        fr: 'Avez-vous essayé une autre munition (autre lot / autre boîte) ?',
        en: 'Have you tried another round (different lot / different box)?',
        de: 'Hast du eine andere Munition ausprobiert (anderes Los / andere Schachtel)?',
        it: 'Hai provato un’altra munizione (altro lotto / altra scatola)?',
        es: '¿Has probado otra munición (otro lote / otra caja)?',
      );

  String get diagnosticQuestion10 => _pick(
        fr: 'Le coup est-il parti avec un délai après la percussion ?',
        en: 'Did the shot fire after a delay following the strike?',
        de: 'Hat sich der Schuss verzögert nach dem Schlag gelöst?',
        it: 'Il colpo è partito con ritardo dopo la percussione?',
        es: '¿El disparo salió con retraso tras la percusión?',
      );

  String get diagnosticQuestion10Description => _pick(
        fr: "Si vous suspectez un long feu: maintenez l'arme épaulée, canon dirigé vers la cible, au moins 15 secondes avant d'ouvrir.",
        en: 'If you suspect a hangfire, keep the weapon shouldered and pointed at the target for at least 15 seconds before opening it.',
        de: 'Wenn du ein Hangfire vermutest, halte die Waffe mindestens 15 Sekunden lang angeschlagen und auf das Ziel gerichtet, bevor du sie öffnest.',
        it: "Se sospetti un fuoco ritardato, mantieni l'arma in posizione di tiro e puntata verso il bersaglio per almeno 15 secondi prima di aprirla.",
        es: 'Si sospechas un fuego retardado, mantén el arma encarada y apuntando al blanco al menos 15 segundos antes de abrirla.',
      );

  String get diagnosticNoOrUnknown => _pick(
        fr: 'NON / JE NE SAIS PAS',
        en: 'NO / I DON’T KNOW',
        de: 'NEIN / ICH WEISS NICHT',
        it: 'NO / NON LO SO',
        es: 'NO / NO LO SÉ',
      );

  String get diagnosticNoOrDoubt => _pick(
        fr: 'NON / DOUTE',
        en: 'NO / UNSURE',
        de: 'NEIN / UNSICHER',
        it: 'NO / DUBBIO',
        es: 'NO / DUDA',
      );

  String get diagnosticNoOrSeveral => _pick(
        fr: 'NON / PLUSIEURS',
        en: 'NO / SEVERAL',
        de: 'NEIN / MEHRERE',
        it: 'NO / DIVERSI',
        es: 'NO / VARIOS',
      );

  String get diagnosticQuestion11 => _pick(
        fr: "Avez-vous gardé l'arme en direction sûre au moins 15 secondes avant d'ouvrir ?",
        en: 'Did you keep the weapon pointed in a safe direction for at least 15 seconds before opening it?',
        de: 'Hast du die Waffe vor dem Öffnen mindestens 15 Sekunden in sichere Richtung gehalten?',
        it: "Hai tenuto l'arma in direzione sicura per almeno 15 secondi prima di aprirla?",
        es: '¿Mantuviste el arma en una dirección segura al menos 15 segundos antes de abrirla?',
      );

  String get diagnosticQuestion12 => _pick(
        fr: "Cartouche éjectée: essayez-vous d'éviter de tirer / manipuler le reste du lot ?",
        en: 'Ejected round: are you avoiding firing / handling the rest of the batch?',
        de: 'Ausgeworfene Patrone: vermeidest du es, den Rest des Loses zu verschießen oder zu handhaben?',
        it: 'Cartuccia espulsa: stai evitando di sparare / manipolare il resto del lotto?',
        es: 'Cartucho expulsado: ¿evitas disparar / manipular el resto del lote?',
      );

  String get diagnosticQuestion12Description => _pick(
        fr: 'Un long feu est typiquement lié à une munition défectueuse (amorçage / poudre).',
        en: 'A hangfire is typically linked to defective ammunition (primer / powder).',
        de: 'Ein Hangfire hängt typischerweise mit defekter Munition zusammen (Zündung / Pulver).',
        it: 'Un fuoco ritardato è tipicamente legato a una munizione difettosa (innesco / polvere).',
        es: 'Un fuego retardado suele estar relacionado con munición defectuosa (pistón / pólvora).',
      );

  String get diagnosticQuestion13 => _pick(
        fr: "Êtes-vous certain de ne pas avoir involontairement pressé la détente ?",
        en: 'Are you certain you did not unintentionally press the trigger?',
        de: 'Bist du sicher, dass du den Abzug nicht unbeabsichtigt betätigt hast?',
        it: 'Sei sicuro di non aver premuto involontariamente il grilletto?',
        es: '¿Estás seguro de no haber presionado involuntariamente el gatillo?',
      );

  String get diagnosticQuestion14 => _pick(
        fr: 'Le départ est-il survenu pendant une manipulation (fermeture, verrouillage, choc) ?',
        en: 'Did the discharge happen during handling (closing, locking, impact)?',
        de: 'Ist die Schussabgabe während einer Handhabung erfolgt (Schließen, Verriegeln, Stoß)?',
        it: 'La partenza è avvenuta durante una manipolazione (chiusura, bloccaggio, urto)?',
        es: '¿Se produjo el disparo durante una manipulación (cierre, bloqueo, golpe)?',
      );

  String get diagnosticQuestion15 => _pick(
        fr: 'La détente/commande a-t-elle été modifiée ou réglée récemment ?',
        en: 'Has the trigger/control been modified or adjusted recently?',
        de: 'Wurde der Abzug / die Steuerung kürzlich verändert oder eingestellt?',
        it: 'Il grilletto/comando è stato modificato o regolato di recente?',
        es: '¿Se ha modificado o ajustado recientemente el disparador/control?',
      );

  String get diagnosticQuestion16 => _pick(
        fr: "Quel type d'enrayage observez-vous ?",
        en: 'What type of jam are you observing?',
        de: 'Welche Art von Störung beobachtest du?',
        it: 'Che tipo di inceppamento osservi?',
        es: '¿Qué tipo de atasco observas?',
      );

  String get diagnosticJamFeeding => _pick(
        fr: 'Alimentation / chambrage',
        en: 'Feeding / chambering',
        de: 'Zuführung / Patronenlager',
        it: 'Alimentazione / cameratura',
        es: 'Alimentación / recámara',
      );

  String get diagnosticJamReturnToBattery => _pick(
        fr: 'Retour en batterie incomplet',
        en: 'Incomplete return to battery',
        de: 'Unvollständige Verriegelung',
        it: 'Ritorno in batteria incompleto',
        es: 'Retorno a batería incompleto',
      );

  String get diagnosticJamExtractionEjection => _pick(
        fr: 'Extraction/éjection',
        en: 'Extraction / ejection',
        de: 'Ausziehen / Auswerfen',
        it: 'Estrazione / espulsione',
        es: 'Extracción / expulsión',
      );

  String get iDoNotKnow => _pick(
        fr: 'Je ne sais pas',
        en: 'I do not know',
        de: 'Ich weiß nicht',
        it: 'Non lo so',
        es: 'No lo sé',
      );

  String get diagnosticQuestion17 => _pick(
        fr: 'Utilisez-vous un chargeur amovible ?',
        en: 'Are you using a detachable magazine?',
        de: 'Verwendest du ein herausnehmbares Magazin?',
        it: 'Stai usando un caricatore amovibile?',
        es: '¿Usas un cargador extraíble?',
      );

  String get diagnosticQuestion18 => _pick(
        fr: 'Le problème survient-il avec un chargeur en particulier ?',
        en: 'Does the problem occur with a particular magazine?',
        de: 'Tritt das Problem bei einem bestimmten Magazin auf?',
        it: 'Il problema si verifica con un caricatore in particolare?',
        es: '¿El problema ocurre con un cargador en particular?',
      );

  String get diagnosticQuestion18Description => _pick(
        fr: 'Si un seul chargeur est concerné: lèvres, ressort, saletés, présentation de cartouche.',
        en: 'If only one magazine is affected: feed lips, spring, dirt, cartridge presentation.',
        de: 'Wenn nur ein Magazin betroffen ist: Lippen, Feder, Schmutz, Patronenzuführung.',
        it: 'Se è coinvolto un solo caricatore: labbri, molla, sporco, presentazione della cartuccia.',
        es: 'Si solo afecta a un cargador: labios, muelle, suciedad, presentación del cartucho.',
      );

  String get diagnosticQuestion19 => _pick(
        fr: "L'arme est-elle propre (chambre, rampe, culasse) et lubrifiée correctement ?",
        en: 'Is the weapon clean (chamber, feed ramp, bolt) and correctly lubricated?',
        de: 'Ist die Waffe sauber (Patronenlager, Zuführrampe, Verschluss) und korrekt geschmiert?',
        it: "L'arma è pulita (camera, rampa, otturatore) e correttamente lubrificata?",
        es: '¿Está el arma limpia (recámara, rampa, cierre) y correctamente lubricada?',
      );

  String get diagnosticQuestion23 => _pick(
        fr: 'Êtes-vous sur un appui stable avec une tenue régulière ?',
        en: 'Are you on a stable rest with a consistent hold?',
        de: 'Hast du eine stabile Auflage und einen gleichmäßigen Anschlag?',
        it: 'Sei su un appoggio stabile con una tenuta regolare?',
        es: '¿Estás sobre un apoyo estable con una sujeción regular?',
      );

  String get diagnosticQuestion23Description => _pick(
        fr: "Avant d'incriminer l'arme: position, détente, lâcher, cadence, fatigue, visée.",
        en: 'Before blaming the weapon: position, trigger control, release, cadence, fatigue, sight picture.',
        de: 'Bevor du die Waffe beschuldigst: Position, Abzug, Schussabgabe, Rhythmus, Müdigkeit, Zielbild.',
        it: "Prima di accusare l'arma: posizione, grilletto, sgancio, cadenza, fatica, mira.",
        es: 'Antes de culpar al arma: posición, gatillo, suelta, ritmo, fatiga, puntería.',
      );

  String get diagnosticQuestion24 => _pick(
        fr: 'Le problème disparaît-il en changeant de munition (lot/type) ?',
        en: 'Does the problem disappear when changing ammunition (lot/type)?',
        de: 'Verschwindet das Problem mit anderer Munition (Los/Typ)?',
        it: 'Il problema scompare cambiando munizione (lotto/tipo)?',
        es: '¿Desaparece el problema al cambiar de munición (lote/tipo)?',
      );

  String get diagnosticQuestion25 => _pick(
        fr: "L'optique / montage est-il vérifié (serrage, colliers, rail) ?",
        en: 'Has the optic / mount been checked (torque, rings, rail)?',
        de: 'Wurden Optik / Montage geprüft (Drehmoment, Ringe, Schiene)?',
        it: "L'ottica / montaggio è stato verificato (serraggio, anelli, slitta)?",
        es: '¿Se ha comprobado la óptica / montaje (apriete, anillas, rail)?',
      );

  String get diagnosticQuestion26 => _pick(
        fr: "Le canon/chambre est-il propre (pas d'encrassement notable) ?",
        en: 'Is the barrel/chamber clean (no notable fouling)?',
        de: 'Sind Lauf / Patronenlager sauber (keine nennenswerte Verschmutzung)?',
        it: 'La canna/camera è pulita (senza incrostazioni rilevanti)?',
        es: '¿Está limpio el cañón/recámara (sin suciedad notable)?',
      );

  String get addToStock => _pick(
        fr: 'AJOUTER AU STOCK',
        en: 'ADD TO STOCK',
        de: 'ZUM BESTAND HINZUFÜGEN',
        it: 'AGGIUNGI ALLE SCORTE',
        es: 'AGREGAR AL STOCK',
      );

  String get itemNotFound => _pick(
        fr: 'Item non trouvé',
        en: 'Item not found',
        de: 'Artikel nicht gefunden',
        it: 'Articolo non trovato',
        es: 'Artículo no encontrado',
      );

  String get itemDoesNotExist => _pick(
        fr: "Cet item n'existe pas",
        en: 'This item does not exist',
        de: 'Dieser Artikel existiert nicht',
        it: 'Questo articolo non esiste',
        es: 'Este artículo no existe',
      );

  String get maintenanceStatus => _pick(
        fr: 'ÉTAT DE MAINTENANCE',
        en: 'MAINTENANCE STATUS',
        de: 'WARTUNGSSTATUS',
        it: 'STATO MANUTENZIONE',
        es: 'ESTADO DE MANTENIMIENTO',
      );

  String get stockAndUsage => _pick(
        fr: 'STOCK & UTILISATION',
        en: 'STOCK & USAGE',
        de: 'BESTAND & NUTZUNG',
        it: 'SCORTE E UTILIZZO',
        es: 'STOCK Y USO',
      );

  String get specificationsTitle => _pick(
        fr: 'SPÉCIFICATIONS',
        en: 'SPECIFICATIONS',
        de: 'SPEZIFIKATIONEN',
        it: 'SPECIFICHE',
        es: 'ESPECIFICACIONES',
      );

  String get commentLabel => _pick(
        fr: 'COMMENTAIRE',
        en: 'COMMENT',
        de: 'KOMMENTAR',
        it: 'COMMENTO',
        es: 'COMENTARIO',
      );

  String get usageHistoryShotsTitle => _pick(
        fr: "HISTORIQUE D'UTILISATION",
        en: 'USAGE HISTORY',
        de: 'NUTZUNGSVERLAUF',
        it: 'STORICO UTILIZZO',
        es: 'HISTORIAL DE USO',
      );

  String get noDataForThisPeriod => _pick(
        fr: 'Aucune donnée pour cette période',
        en: 'No data for this period',
        de: 'Keine Daten für diesen Zeitraum',
        it: 'Nessun dato per questo periodo',
        es: 'No hay datos para este período',
      );

  String get weekLabel => _pick(
        fr: 'Semaine',
        en: 'Week',
        de: 'Woche',
        it: 'Settimana',
        es: 'Semana',
      );

  String get monthLabel => _pick(
        fr: 'Mois',
        en: 'Month',
        de: 'Monat',
        it: 'Mese',
        es: 'Mes',
      );

  String get yearLabel => _pick(
        fr: 'Année',
        en: 'Year',
        de: 'Jahr',
        it: 'Anno',
        es: 'Año',
      );

  String get modelLabel => _pick(
        fr: 'Modèle',
        en: 'Model',
        de: 'Modell',
        it: 'Modello',
        es: 'Modelo',
      );

  String get batteryChangedLabel => _pick(
        fr: 'Pile changée',
        en: 'Battery changed',
        de: 'Batterie gewechselt',
        it: 'Batteria cambiata',
        es: 'Batería cambiada',
      );

  String get accessoryStatusTitle => _pick(
        fr: "ÉTAT DE L'ACCESSOIRE",
        en: 'ACCESSORY STATUS',
        de: 'ZUBEHÖRSTATUS',
        it: "STATO DELL'ACCESSORIO",
        es: 'ESTADO DEL ACCESORIO',
      );

  String get fullHistoryTitle => _pick(
        fr: 'HISTORIQUE COMPLET',
        en: 'FULL HISTORY',
        de: 'VOLLSTÄNDIGER VERLAUF',
        it: 'STORICO COMPLETO',
        es: 'HISTORIAL COMPLETO',
      );

  String get noMaintenanceHistoryRecorded => _pick(
        fr: "Aucun historique d'entretien/révision enregistré",
        en: 'No maintenance/revision history recorded',
        de: 'Kein Wartungs-/Revisionsverlauf erfasst',
        it: 'Nessuno storico manutenzione/revisione registrato',
        es: 'No hay historial de mantenimiento/revisión registrado',
      );

  String get emptyWeightLabel => _pick(
        fr: 'Poids (vide)',
        en: 'Weight (empty)',
        de: 'Gewicht (leer)',
        it: 'Peso (vuoto)',
        es: 'Peso (vacío)',
      );

  String get lastCleaningLabel => _pick(
        fr: 'Dernier nettoyage',
        en: 'Last cleaning',
        de: 'Letzte Reinigung',
        it: 'Ultima pulizia',
        es: 'Última limpieza',
      );

  String get lastRevisionLabel => _pick(
        fr: 'Dernière révision',
        en: 'Last revision',
        de: 'Letzte Revision',
        it: 'Ultima revisione',
        es: 'Última revisión',
      );

  String get weaponConfirmRevisionMessage => _pick(
        fr: 'Voulez-vous vraiment enregistrer une révision complète pour cette arme ? Le compteur de révision sera remis à zéro.',
        en: 'Do you really want to record a complete revision for this weapon? The revision counter will be reset to zero.',
        de: 'Möchten Sie wirklich eine vollständige Revision für diese Waffe erfassen? Der Revisionszähler wird auf Null zurückgesetzt.',
        it: 'Vuoi davvero registrare una revisione completa per questa arma? Il contatore di revisione verrà azzerato.',
        es: '¿Realmente quieres registrar una revisión completa para esta arma? El contador de revisión se reiniciará a cero.',
      );

  String get accessoryConfirmCleaningMessage => _pick(
        fr: "Voulez-vous vraiment enregistrer un nettoyage complet pour cet accessoire ? Le compteur d'entretien sera remis à zéro.",
        en: 'Do you really want to record a complete cleaning for this accessory? The maintenance counter will be reset to zero.',
        de: 'Möchten Sie wirklich eine vollständige Reinigung für dieses Zubehör erfassen? Der Wartungszähler wird auf Null zurückgesetzt.',
        it: 'Vuoi davvero registrare una pulizia completa per questo accessorio? Il contatore di manutenzione verrà azzerato.',
        es: '¿Realmente quieres registrar una limpieza completa para este accesorio? El contador de mantenimiento se reiniciará a cero.',
      );

  String get accessoryConfirmRevisionMessage => _pick(
        fr: 'Voulez-vous vraiment enregistrer une révision complète pour cet accessoire ? Le compteur de révision sera remis à zéro.',
        en: 'Do you really want to record a complete revision for this accessory? The revision counter will be reset to zero.',
        de: 'Möchten Sie wirklich eine vollständige Revision für dieses Zubehör erfassen? Der Revisionszähler wird auf Null zurückgesetzt.',
        it: 'Vuoi davvero registrare una revisione completa per questo accessorio? Il contatore di revisione verrà azzerato.',
        es: '¿Realmente quieres registrar una revisión completa para este accesorio? El contador de revisión se reiniciará a cero.',
      );

  String get revisionRecordedSuccess => _pick(
        fr: 'Révision enregistrée avec succès.',
        en: 'Revision recorded successfully.',
        de: 'Revision erfolgreich erfasst.',
        it: 'Revisione registrata con successo.',
        es: 'Revisión registrada con éxito.',
      );

  String get partChangeTitle => _pick(
        fr: 'Changement de pièce',
        en: 'Part replacement',
        de: 'Teilewechsel',
        it: 'Sostituzione pezzo',
        es: 'Cambio de pieza',
      );

  String get partNameLabel => _pick(
        fr: 'Nom de la pièce',
        en: 'Part name',
        de: 'Teilename',
        it: 'Nome del pezzo',
        es: 'Nombre de la pieza',
      );

  String get partNameHint => _pick(
        fr: 'Ex : canon',
        en: 'E.g.: barrel',
        de: 'z. B.: Lauf',
        it: 'Es.: canna',
        es: 'Ej.: cañón',
      );

  String get partChangeCommentLabel => _pick(
        fr: 'Commentaire',
        en: 'Comment',
        de: 'Kommentar',
        it: 'Commento',
        es: 'Comentario',
      );

  String get partChangeCommentHint => _pick(
        fr: 'Ex : remplacement préventif après 5 000 coups',
        en: 'E.g.: preventive replacement after 5,000 rounds',
        de: 'z. B.: vorbeugender Austausch nach 5.000 Schuss',
        it: 'Es.: sostituzione preventiva dopo 5.000 colpi',
        es: 'Ej.: sustitución preventiva tras 5.000 disparos',
      );

  String get dateLabel => _pick(
        fr: 'Date',
        en: 'Date',
        de: 'Datum',
        it: 'Data',
        es: 'Fecha',
      );

  String get partChangeRecordedSuccess => _pick(
        fr: 'Changement de pièce enregistré.',
        en: 'Part replacement recorded.',
        de: 'Teilewechsel erfasst.',
        it: 'Sostituzione pezzo registrata.',
        es: 'Cambio de pieza registrado.',
      );

  String get recordPartChange => _pick(
        fr: 'Enregistrer un changement de pièce',
        en: 'Record part replacement',
        de: 'Teilewechsel erfassen',
        it: 'Registra sostituzione pezzo',
        es: 'Registrar cambio de pieza',
      );

  String shotsWithUnit(int count) => _pick(
        fr: '$count ${count > 1 ? 'coups' : 'coup'}',
        en: '$count ${count == 1 ? 'shot' : 'shots'}',
        de: '$count ${count == 1 ? 'Schuss' : 'Schüsse'}',
        it: '$count ${count == 1 ? 'colpo' : 'colpi'}',
        es: '$count ${count == 1 ? 'disparo' : 'disparos'}',
      );

  String get revision => _pick(
        fr: 'Révision',
        en: 'Revision',
        de: 'Revision',
        it: 'Revisione',
        es: 'Revisión',
      );

  String get cleanliness => _pick(
        fr: 'Propreté',
        en: 'Cleanliness',
        de: 'Sauberkeit',
        it: 'Pulizia',
        es: 'Limpieza',
      );

  String get totalShots => _pick(
        fr: 'TOTAL COUPS',
        en: 'TOTAL SHOTS',
        de: 'GESAMTSCHÜSSE',
        it: 'COLPI TOTALI',
        es: 'TIROS TOTALES',
      );

  String get lastShot => _pick(
        fr: 'DERNIER TIR',
        en: 'LAST SHOT',
        de: 'LETZTER SCHUSS',
        it: 'ULTIMO COLPO',
        es: 'ÚLTIMO TIRO',
      );

  String get maintenance => _pick(
        fr: 'Entretien',
        en: 'Maintenance',
        de: 'Wartung',
        it: 'Manutenzione',
        es: 'Mantenimiento',
      );

  String get shotsLower => _pick(
        fr: 'coups',
        en: 'shots',
        de: 'Schüsse',
        it: 'colpi',
        es: 'tiros',
      );

  String get confirmation => _pick(
        fr: 'Confirmation',
        en: 'Confirmation',
        de: 'Bestätigung',
        it: 'Conferma',
        es: 'Confirmación',
      );

  String get confirmCleaningMessage => _pick(
        fr: "Voulez-vous vraiment enregistrer un nettoyage complet pour cette arme ? Le compteur d'entretien sera remis à zéro.",
        en: 'Do you really want to record a complete cleaning for this weapon? The maintenance counter will be reset to zero.',
        de: 'Möchten Sie wirklich eine vollständige Reinigung für diese Waffe aufzeichnen? Der Wartungszähler wird auf Null zurückgesetzt.',
        it: 'Vuoi davvero registrare una pulizia completa per questa arma? Il contatore di manutenzione verrà azzerato.',
        es: '¿Realmente quieres registrar una limpieza completa para esta arma? El contador de mantenimiento se reiniciará a cero.',
      );

  String get cleaningRecordedSuccess => _pick(
        fr: 'Entretien enregistré avec succès.',
        en: 'Maintenance recorded successfully.',
        de: 'Wartung erfolgreich erfasst.',
        it: 'Manutenzione registrata con successo.',
        es: 'Mantenimiento registrado con éxito.',
      );

  String diagnosticDecisionCauses(String decision) {
    switch (decision) {
      case 'PERCUTEUR / DÉVERROUILLAGE':
        return _pick(
          fr: "Absence d'empreinte de percussion sur l'amorce. La percussion n'atteint pas la cartouche : verrouillage incomplet, sûreté passive, percuteur empêché (encrassement/casse), ressort de percuteur.",
          en: 'No firing pin mark on the primer. The firing system is not reaching the round: incomplete lockup, passive safety, obstructed/broken firing pin, or firing pin spring issue.',
          de: 'Kein Schlagbolzenabdruck auf dem Zündhütchen. Das Schlagsystem erreicht die Patrone nicht: unvollständige Verriegelung, passive Sicherung, blockierter/gebrochener Schlagbolzen oder Schlagbolzenfeder.',
          it: "Assenza di impronta di percussione sull'innesco. La percussione non raggiunge la cartuccia: chiusura incompleta, sicura passiva, percussore bloccato/rotto o molla del percussore.",
          es: 'Ausencia de marca de percusión en el pistón. La percusión no alcanza el cartucho: cierre incompleto, seguro pasivo, percutor bloqueado/roto o resorte del percutor.',
        );
      case 'PERCUSSION FAIBLE / HORS AXE':
        return _pick(
          fr: 'Percussion présente mais faible/décentrée : verrouillage incomplet, accompagnement de culasse, ressort fatigué, canal percuteur encrassé, pièce usée.',
          en: 'The firing pin mark is present but weak/off-center: incomplete lockup, riding the slide, tired spring, dirty firing pin channel, or worn part.',
          de: 'Der Schlagbolzenabdruck ist vorhanden, aber schwach/außer Mitte: unvollständige Verriegelung, Begleiten des Verschlusses, ermüdete Feder, verschmutzter Schlagbolzenkanal oder verschlissenes Teil.',
          it: 'Percussione presente ma debole/decentrata: chiusura incompleta, accompagnamento del carrello, molla affaticata, canale del percussore sporco o componente usurato.',
          es: 'La percusión está presente pero es débil/descentrada: cierre incompleto, acompañamiento de la corredera, muelle fatigado, canal del percutor sucio o pieza desgastada.',
        );
      case 'MUNITION / LOT DÉFECTUEUX':
        return _pick(
          fr: 'Cartouche percutée correctement mais pas de départ : amorce/poudre défectueuse, lot défaillant, stockage inadéquat.',
          en: 'The round was struck correctly but did not fire: defective primer/powder, bad lot, or improper storage.',
          de: 'Die Patrone wurde korrekt getroffen, hat aber nicht gezündet: defektes Zündhütchen/Pulver, fehlerhaftes Los oder unsachgemäße Lagerung.',
          it: 'Cartuccia percossa correttamente ma non partita: innesco/polvere difettosi, lotto difettoso o conservazione inadeguata.',
          es: 'Cartucho percutido correctamente pero sin disparo: pistón/pólvora defectuosos, lote defectuoso o almacenamiento inadecuado.',
        );
      case 'DÉFAUT DE CHAMBRAGE / ALIMENTATION':
        return _pick(
          fr: "Cartouche pas correctement présentée/chambrée : problème d'alimentation, magasin/chargeur, rampe, ressort, tenue de l'arme, saletés.",
          en: 'The round is not feeding/chambering correctly: feeding issue, magazine, feed ramp, spring, grip, or debris.',
          de: 'Die Patrone wird nicht korrekt zugeführt/ins Patronenlager gebracht: Zuführstörung, Magazin, Zuführrampe, Feder, Waffenhaltung oder Verschmutzung.',
          it: "Cartuccia non presentata/camerata correttamente: problema di alimentazione, caricatore, rampa, molla, impugnatura o sporco.",
          es: 'El cartucho no se presenta/recámara correctamente: problema de alimentación, cargador, rampa, muelle, sujeción o suciedad.',
        );
      case 'LONG FEU (DANGER) — MUNITION DÉFECTUEUSE':
        return _pick(
          fr: "Long feu : mise à feu retardée. Cartouche défectueuse (amorçage/poudre). Risque d'accident grave si ouverture prématurée.",
          en: 'Hangfire: delayed ignition. Defective round (primer/powder). Serious injury risk if opened too early.',
          de: 'Hangfire: verzögerte Zündung. Defekte Patrone (Zündsatz/Pulver). Ernstes Unfallrisiko bei zu frühem Öffnen.',
          it: 'Fuoco ritardato: accensione ritardata. Cartuccia difettosa (innesco/polvere). Grave rischio se aperta troppo presto.',
          es: 'Fuego retardado: ignición tardía. Cartucho defectuoso (pistón/pólvora). Riesgo grave si se abre demasiado pronto.',
        );
      case 'INCIDENT MUNITION — PROCÉDURE LONG FEU':
        return _pick(
          fr: 'Incident compatible munition (raté/irrégularité) avec risque de long feu non exclu.',
          en: 'Ammunition-related incident (misfire/irregularity) where hangfire cannot be ruled out.',
          de: 'Munitionsbedingte Störung (Fehlzündung/Unregelmäßigkeit), bei der ein Hangfire nicht ausgeschlossen werden kann.',
          it: 'Anomalia compatibile con la munizione (mancato sparo/irregolarità) con risque de fuoco ritardato non escluso.',
          es: 'Incidente compatible con la munición (fallo/irregularidad) con riesgo de fuego retardado no descartado.',
        );
      case 'FACTEUR HUMAIN (DOIGT / SÛRETÉ / MANIPULATION)':
        return _pick(
          fr: 'Erreur de manipulation : doigt sur détente, sûreté mal gérée, manipulation sous stress, accompagnement de culasse, approvisionnement.',
          en: 'Handling error: finger on trigger, poor safety management, stress manipulation, riding the slide, or loading issue.',
          de: 'Bedienfehler: Finger am Abzug, schlechte Sicherungshandhabung, Stressmanipulation, Begleiten des Verschlusses oder Ladefehler.',
          it: 'Errore di manipolazione: dito sul grilletto, gestione errata della sicura, manipolazione sotto stress, accompagnamento del carrello o errore di alimentazione.',
          es: 'Error de manipulación: dedo en el gatillo, mala gestión del seguro, manipulación bajo estrés, acompañamiento de la corredera o error de carga.',
        );
      case 'ALIMENTATION / CHARGEUR':
        return _pick(
          fr: 'Enrayage lié au chargeur/magasin : ressort, lèvres, saletés, présentation des cartouches, remplissage.',
          en: 'Jam related to the magazine: spring, feed lips, dirt, cartridge presentation, or loading.',
          de: 'Störung im Zusammenhang mit dem Magazin: Feder, Lippen, Schmutz, Patronenzuführung oder Ladevorgang.',
          it: 'Inceppamento legato al caricatore: molla, labbri, sporco, presentazione delle cartucce o riempimento.',
          es: 'Atasco relacionado con el cargador: muelle, labios, suciedad, presentación de cartuchos o carga.',
        );
      case 'EXTRACTION / ÉJECTION':
        return _pick(
          fr: 'Problème extracteur/éjecteur, chambre encrassée, pression anormale, étui déformé.',
          en: 'Extractor/ejector problem, dirty chamber, abnormal pressure, or deformed case.',
          de: 'Problem mit Auszieher/Auswerfer, verschmutztes Patronenlager, abnormaler Druck oder deformierte Hülse.',
          it: 'Problema di estrattore/espulsore, camera sporca, pressione anomala o bossolo deformato.',
          es: 'Problema de extractor/expulsor, recámara sucia, presión anormal o vaina deformada.',
        );
      case 'CHAMBRAGE / RETOUR EN BATTERIE':
        return _pick(
          fr: "Retour en batterie incomplet : saletés, lubrification inadaptée, ressort récupérateur, cartouches hors cotes, tenue de l'arme.",
          en: 'Incomplete return to battery: debris, improper lubrication, recoil spring, out-of-spec rounds, or grip issue.',
          de: 'Unvollständige Verriegelung: Schmutz, ungeeignete Schmierung, Schließfeder, Patronen außerhalb der Toleranz oder Haltefehler.',
          it: 'Ritorno in batteria incompleto: sporco, lubrificazione inadeguata, molla di recupero, cartucce fuori tolleranza o impugnatura.',
          es: 'Retorno a batería incompleto: suciedad, lubricación inadecuada, muelle recuperador, cartuchos fuera de tolerancia o problema de sujeción.',
        );
      case 'FACTEUR HUMAIN / APPUI':
        return _pick(
          fr: "Baisse de précision liée à l'appui/tenue/lâcher/cadence/fatigue plutôt qu'à l'arme.",
          en: 'Accuracy loss is more likely due to rest/hold/trigger/cadence/fatigue than the weapon.',
          de: 'Der Präzisionsverlust hängt eher mit Auflage/Anschlag/Abzug/Rhythmus/Müdigkeit zusammen als mit der Waffe.',
          it: "Il calo di precisione è più probabilmente dovuto ad appoggio/impugnatura/scatto/cadenza/fatica che all'arma.",
          es: 'La pérdida de precisión probablemente se debe más al apoyo/sujeción/disparo/cadencia/fatiga que al arma.',
        );
      case 'MUNITION (LOT / TYPE)':
        return _pick(
          fr: 'Baisse de précision liée à la munition : lot variable, projectile inadapté, poids/vitesse non optimale, stockage.',
          en: 'Accuracy loss linked to ammunition: inconsistent lot, unsuitable projectile, non-optimal weight/velocity, or storage.',
          de: 'Präzisionsverlust durch die Munition: schwankendes Los, ungeeignetes Geschoss, nicht optimales Gewicht/Geschwindigkeit oder Lagerung.',
          it: 'Calo di precisione legato alla munizione: lotto variabile, proiettile inadatto, peso/velocità non ottimali o conservazione.',
          es: 'Pérdida de precisión ligada a la munición: lote variable, proyectil inadecuado, peso/velocidad no óptimos o almacenamiento.',
        );
      case 'OPTique / MONTAGE DESSERRÉ':
        return _pick(
          fr: 'Dérive ou dispersion due à un montage/optique desserré ou mal monté.',
          en: 'Shift or spread caused by a loose or improperly mounted optic/mount.',
          de: 'Treffpunktverlagerung oder Streuung durch eine lockere oder falsch montierte Optik/Montage.',
          it: 'Deriva o dispersione dovuta a ottica/montaggio allentati o montati male.',
          es: 'Deriva o dispersión debida a una óptica/montaje flojo o mal instalado.',
        );
      case 'ENCRASSEMENT / ENTRETIEN':
        return _pick(
          fr: 'Encrassement canon/chambre, entretien insuffisant, lubrification inadaptée.',
          en: 'Fouling in barrel/chamber, insufficient maintenance, or improper lubrication.',
          de: 'Verschmutzung von Lauf/Patronenlager, unzureichende Wartung oder ungeeignete Schmierung.',
          it: 'Incrostazioni in canna/camera, manutenzione insufficiente o lubrificazione inadeguata.',
          es: 'Suciedad en cañón/recámara, mantenimiento insuficiente o lubricación inadecuada.',
        );
      default:
        return _pick(
          fr: 'Plusieurs causes possibles (munition, mécanique, environnement, facteur humain).',
          en: 'Several causes are possible (ammunition, mechanics, environment, human factor).',
          de: 'Mehrere Ursachen sind möglich (Munition, Mechanik, Umgebung, menschlicher Faktor).',
          it: 'Sono possibili diverse cause (munizione, meccanica, ambiente, fattore umano).',
          es: 'Son posibles varias causas (munición, mecánica, entorno, factor humano).',
        );
    }
  }

  String diagnosticDecisionActions(String decision) {
    switch (decision) {
      case 'PERCUTEUR / DÉVERROUILLAGE':
        return _pick(
          fr: 'Canon dirigé en zone sûre. Vérifier sûreté / verrouillage complet. Contrôler percuteur (propreté, libre course) et ressort. Ne pas forcer. Armurier si doute ou répétition.',
          en: 'Keep the muzzle in a safe direction. Check safety and full lockup. Inspect the firing pin (cleanliness, free movement) and spring. Do not force it. See a gunsmith if unsure or repeated.',
          de: 'Mündung in sichere Richtung halten. Sicherung und vollständige Verriegelung prüfen. Schlagbolzen (Sauberkeit, freie Bewegung) und Feder kontrollieren. Nichts erzwingen. Bei Zweifel oder Wiederholung zum Büchsenmacher.',
          it: 'Mantieni la volata in direzione sicura. Verifica sicura e completa chiusura. Controlla percussore (pulizia, corsa libera) e molla. Non forzare. Armaiolo in caso di dubbio o ripetizione.',
          es: 'Mantén el cañón en dirección segura. Verifica seguro y cierre completo. Controla el percutor (limpieza, libre recorrido) y el muelle. No fuerces. Armero si hay dudas o se repite.',
        );
      case 'PERCUSSION FAIBLE / HORS AXE':
        return _pick(
          fr: 'Vérifier fermeture/verrouillage sans accompagner. Nettoyer canal percuteur si autorisé. Tester avec autre munition/lot. Armurier si persistant.',
          en: 'Check closure/lockup without riding the slide. Clean the firing pin channel if allowed. Test with different ammo/lot. See a gunsmith if it persists.',
          de: 'Verschluss/Verriegelung prüfen, ohne den Verschluss zu begleiten. Schlagbolzenkanal reinigen, falls zulässig. Mit anderer Munition/anderem Los testen. Bei Fortbestehen zum Büchsenmacher.',
          it: 'Verifica chiusura/bloccaggio senza accompagnare il carrello. Pulisci il canale del percussore se consentito. Prova con altra munizione/lotto. Armaiolo se persiste.',
          es: 'Verifica cierre/bloqueo sin acompañar la corredera. Limpia el canal del percutor si está permitido. Prueba con otra munición/lote. Armero si persiste.',
        );
      case 'MUNITION / LOT DÉFECTUEUX':
        return _pick(
          fr: 'Mettre de côté le lot. Essayer une autre boîte/lot/type. Ne pas manipuler inutilement les cartouches du même lot si incident répété. Signaler au fabricant si possible.',
          en: 'Set the lot aside. Try another box/lot/type. Do not unnecessarily handle rounds from the same lot if the incident repeats. Report it to the manufacturer if possible.',
          de: 'Das Los beiseitelegen. Eine andere Schachtel/ein anderes Los/einen anderen Typ probieren. Patronen desselben Loses bei Wiederholung nicht unnötig handhaben. Wenn möglich dem Hersteller melden.',
          it: 'Metti da parte il lotto. Prova un’altra scatola/lotto/tipo. Non maneggiare inutilmente le cartucce dello stesso lotto se il problema si ripete. Segnala al produttore se possibile.',
          es: 'Aparta el lote. Prueba otra caja/lote/tipo. No manipules innecesariamente los cartuchos del mismo lote si el incidente se repite. Notifica al fabricante si es posible.',
        );
      case 'DÉFAUT DE CHAMBRAGE / ALIMENTATION':
        return _pick(
          fr: 'Vérifier approvisionnement, chargeur, lèvres/ressort, propreté (chambre/rampe). Tester autre chargeur et munition. Nettoyage + lubrification adaptée.',
          en: 'Check feeding, magazine, lips/spring, and cleanliness (chamber/feed ramp). Test another magazine and ammo. Clean and lubricate appropriately.',
          de: 'Zuführung, Magazin, Lippen/Feder und Sauberkeit (Patronenlager/Zuführrampe) prüfen. Ein anderes Magazin und andere Munition testen. Reinigen und passend schmieren.',
          it: 'Verifica alimentazione, caricatore, labbri/molla e pulizia (camera/rampa). Prova un altro caricatore e altra munizione. Pulisci e lubrifica correttamente.',
          es: 'Verifica alimentación, cargador, labios/muelle y limpieza (recámara/rampa). Prueba otro cargador y otra munición. Limpia y lubrica adecuadamente.',
        );
      case 'LONG FEU (DANGER) — MUNITION DÉFECTUEUSE':
        return _pick(
          fr: "Maintenir en joue en direction sûre au moins 15 secondes. Ouvrir ensuite prudemment. Isoler la munition. Ne plus tirer les cartouches du même lot. Armurier si doute sur l'arme.",
          en: 'Keep aimed in a safe direction for at least 15 seconds. Then open carefully. Isolate the round. Do not fire rounds from the same lot. See a gunsmith if unsure about the weapon.',
          de: 'Mindestens 15 Sekunden in sichere Richtung gerichtet halten. Danach vorsichtig öffnen. Die Patrone isolieren. Keine Patronen desselben Loses mehr verschießen. Bei Zweifel an der Waffe zum Büchsenmacher.',
          it: 'Mantieni puntato in direzione sicura per almeno 15 secondi. Poi apri con cautela. Isola la cartuccia. Non sparare altre cartucce dello stesso lotto. Armaiolo se hai dubbi sull’arma.',
          es: 'Mantén apuntado en dirección segura al menos 15 segundos. Luego abre con cuidado. Aísla el cartucho. No dispares más cartuchos del mismo lote. Armero si dudas del arma.',
        );
      case 'INCIDENT MUNITION — PROCÉDURE LONG FEU':
        return _pick(
          fr: 'Appliquer la procédure long feu par précaution. Changer de lot/type de munition. Stockage sec/constant. Armurier si répétitif.',
          en: 'Apply hangfire procedure as a precaution. Change ammo lot/type. Keep storage dry and stable. See a gunsmith if repeated.',
          de: 'Vorsorglich das Hangfire-Verfahren anwenden. Los/Typ der Munition wechseln. Trocken und konstant lagern. Bei Wiederholung zum Büchsenmacher.',
          it: 'Applica la procedura per fuoco ritardato per precauzione. Cambia lotto/tipo di munizione. Conservazione asciutta e stabile. Armaiolo se si ripete.',
          es: 'Aplica el procedimiento de fuego retardado por precaución. Cambia lote/tipo de munición. Almacenamiento seco y estable. Armero si se repite.',
        );
      case 'FACTEUR HUMAIN (DOIGT / SÛRETÉ / MANIPULATION)':
        return _pick(
          fr: 'Revenir aux fondamentaux : doigt hors détente, sûreté, procédures de chargement/déchargement. Faire contrôler la prise en main. Si départ intempestif avéré : immobiliser et armurier.',
          en: 'Go back to the basics: finger off trigger, safety, loading/unloading procedures. Have your handling checked. If unintended discharge is confirmed: stop using it and see a gunsmith.',
          de: 'Zu den Grundlagen zurückkehren: Finger weg vom Abzug, Sicherung, Lade-/Entladeverfahren. Handhabung überprüfen lassen. Bei bestätigter ungewollter Schussabgabe: außer Betrieb nehmen und zum Büchsenmacher.',
          it: 'Torna alle basi: dito fuori dal grilletto, sicura, procedure di caricamento/scaricamento. Fatti controllare la presa. Se la partenza intempestiva è confermata: immobilizza e armaiolo.',
          es: 'Vuelve a los fundamentos: dedo fuera del gatillo, seguro, procedimientos de carga/descarga. Haz revisar la manipulación. Si se confirma un disparo intempestivo: inmoviliza y armero.',
        );
      case 'ALIMENTATION / CHARGEUR':
        return _pick(
          fr: 'Tester un autre chargeur. Nettoyer chargeur/magasin. Inspecter lèvres/ressort. Éviter munitions abîmées. Armurier si déformation/usure.',
          en: 'Test another magazine. Clean the magazine. Inspect feed lips and spring. Avoid damaged ammo. See a gunsmith if deformed or worn.',
          de: 'Ein anderes Magazin testen. Magazin reinigen. Lippen und Feder prüfen. Beschädigte Munition vermeiden. Bei Verformung/Verschleiß zum Büchsenmacher.',
          it: 'Prova un altro caricatore. Pulisci il caricatore. Ispeziona labbri e molla. Evita munizioni danneggiate. Armaiolo in caso di deformazione/usura.',
          es: 'Prueba otro cargador. Limpia el cargador. Inspecciona labios y muelle. Evita munición dañada. Armero si hay deformación/desgaste.',
        );
      case 'EXTRACTION / ÉJECTION':
        return _pick(
          fr: 'Arrêter si répétitif. Nettoyage chambre. Contrôle extracteur/éjecteur. Changer de munition. Armurier si blocage/étuis anormaux.',
          en: 'Stop if it repeats. Clean the chamber. Check extractor/ejector. Change ammunition. See a gunsmith for jams or abnormal cases.',
          de: 'Bei Wiederholung stoppen. Patronenlager reinigen. Auszieher/Auswerfer prüfen. Munition wechseln. Bei Blockaden oder abnormalen Hülsen zum Büchsenmacher.',
          it: 'Fermati se si ripete. Pulisci la camera. Controlla estrattore/espulsore. Cambia munizione. Armaiolo in caso di blocchi o bossoli anomali.',
          es: 'Detente si se repite. Limpia la recámara. Revisa extractor/expulsor. Cambia munición. Armero si hay bloqueos o vainas anormales.',
        );
      case 'CHAMBRAGE / RETOUR EN BATTERIE':
        return _pick(
          fr: 'Nettoyage + lubrification adaptée. Tester autre munition. Vérifier ressort. Ne pas accompagner la fermeture. Armurier si persistant.',
          en: 'Clean and lubricate correctly. Test other ammunition. Check the spring. Do not ride the closing movement. See a gunsmith if it persists.',
          de: 'Reinigen und passend schmieren. Andere Munition testen. Feder prüfen. Den Schließvorgang nicht begleiten. Bei Fortbestehen zum Büchsenmacher.',
          it: 'Pulisci e lubrifica correttamente. Prova altra munizione. Verifica la molla. Non accompagnare la chiusura. Armaiolo se persiste.',
          es: 'Limpia y lubrica correctamente. Prueba otra munición. Revisa el muelle. No acompañes el cierre. Armero si persiste.',
        );
      case 'FACTEUR HUMAIN / APPUI':
        return _pick(
          fr: "Stabiliser l'appui, cadence régulière, contrôle détente/visée. Faire une série de référence. Ensuite seulement investiguer munition/optique/arme.",
          en: 'Stabilize the rest, keep a regular cadence, and control trigger/sight picture. Fire a reference group first. Only then investigate ammo/optic/weapon.',
          de: 'Auflage stabilisieren, gleichmäßigen Rhythmus halten und Abzug/Zielbild kontrollieren. Erst eine Referenzserie schießen. Dann erst Munition/Optik/Waffe prüfen.',
          it: 'Stabilizza l’appoggio, mantieni una cadenza regolare e controlla scatto/mira. Fai prima una serie di riferimento. Solo dopo indaga munizione/ottica/arma.',
          es: 'Estabiliza el apoyo, mantén una cadencia regular y controla gatillo/miras. Haz primero una serie de referencia. Solo después investiga munición/óptica/arma.',
        );
      case 'MUNITION (LOT / TYPE)':
        return _pick(
          fr: 'Changer de lot/type. Tester un poids CIP de référence si semi-auto. Écarter cartouches endommagées/manipulées.',
          en: 'Change lot/type. Test a reference CIP bullet weight if semi-auto. Discard damaged or mishandled rounds.',
          de: 'Los/Typ wechseln. Bei Selbstladern ein CIP-Referenzgewicht testen. Beschädigte oder unsachgemäß behandelte Patronen aussortieren.',
          it: 'Cambia lotto/tipo. Prova un peso CIP di riferimento se semiautomatica. Scarta cartucce danneggiate o maneggiate male.',
          es: 'Cambia lote/tipo. Prueba un peso CIP de referencia si es semiautomática. Descarta cartuchos dañados o manipulados.',
        );
      case 'OPTique / MONTAGE DESSERRÉ':
        return _pick(
          fr: 'Vérifier couple de serrage, colliers/rail, frein filet si approprié. Vérifier réglages. Faire un contrôle après quelques tirs.',
          en: 'Check torque, rings/rail, and thread locker if appropriate. Verify adjustments. Re-check after a few shots.',
          de: 'Anzugsmoment, Ringe/Schiene und ggf. Schraubensicherung prüfen. Einstellungen kontrollieren. Nach einigen Schüssen erneut prüfen.',
          it: 'Verifica coppia di serraggio, anelli/slitta e frenafiletti se opportuno. Controlla le regolazioni. Ricontrolla dopo alcuni colpi.',
          es: 'Verifica par de apriete, anillas/carril y fijador de roscas si procede. Revisa los ajustes. Vuelve a comprobar tras algunos disparos.',
        );
      case 'ENCRASSEMENT / ENTRETIEN':
        return _pick(
          fr: 'Nettoyage en profondeur (chambre/canon/culasse) puis lubrification légère adaptée. Tester à nouveau.',
          en: 'Deep clean the chamber/barrel/bolt, then apply proper light lubrication. Test again.',
          de: 'Patronenlager/Lauf/Verschluss gründlich reinigen und anschließend passend leicht schmieren. Erneut testen.',
          it: 'Pulisci a fondo camera/canna/otturatore, poi applica una leggera lubrificazione adeguata. Prova di nuovo.',
          es: 'Limpia a fondo recámara/cañón/cierre y aplica una lubricación ligera adecuada. Prueba de nuevo.',
        );
      default:
        return _pick(
          fr: 'Procéder par élimination : munition (autre lot) -> propreté/lubrification -> chargeur -> contrôle armurier si le problème persiste.',
          en: 'Use elimination: ammunition (different lot) -> cleanliness/lubrication -> magazine -> gunsmith inspection if the problem persists.',
          de: 'Per Ausschluss vorgehen: Munition (anderes Los) -> Sauberkeit/Schmierung -> Magazin -> Kontrolle durch Büchsenmacher, wenn das Problem bleibt.',
          it: 'Procedi per esclusione: munizione (altro lotto) -> pulizia/lubrificazione -> caricatore -> controllo armaiolo se il problema persiste.',
          es: 'Procede por descarte: munición (otro lote) -> limpieza/lubricación -> cargador -> revisión por armero si el problema persiste.',
        );
    }
  }

  String get clean => _pick(
        fr: 'Nettoyer',
        en: 'Clean',
        de: 'Reinigen',
        it: 'Pulisci',
        es: 'Limpiar',
      );

  // Milliradian tool (Formule du millième)
  String get milliemeToolTitle => _pick(
        fr: 'FORMULE DU MILLIÈME',
        en: 'MIL FORMULA',
        de: 'MIL-FORMEL',
        it: 'FORMULA DEL MIL',
        es: 'FÓRMULA DEL MIL',
      );

  String get milliemeToolSubtitle => _pick(
        fr: 'Calculez une distance facilement',
        en: 'Calculate a distance easily',
        de: 'Berechne eine Distanz einfach',
        it: 'Calcola una distanza facilmente',
        es: 'Calcula una distancia fácilmente',
      );

  String get milliemeImperialWarning => _pick(
        fr: 'Attention : ce calcul reste exprimé en système métrique (mètres et millièmes).',
        en: 'Warning: this calculation still uses metric units (meters and mils).',
        de: 'Achtung: Diese Berechnung verwendet weiterhin metrische Einheiten (Meter und Millirad).',
        it: 'Attenzione: questo calcolo usa comunque il sistema metrico (metri e mil).',
        es: 'Atención: este cálculo sigue usando el sistema métrico (metros y mil).',
      );

  String get milliemeFrontLabel => _pick(
        fr: 'Front (taille réelle)',
        en: 'Front (real size)',
        de: 'Front (Realgröße)',
        it: 'Frontale (dimensione reale)',
        es: 'Frente (tamaño real)',
      );

  String get milliemeFrontField => _pick(
        fr: 'Front (m)',
        en: 'Front (m)',
        de: 'Front (m)',
        it: 'Frontale (m)',
        es: 'Frente (m)',
      );

  String get milliemeMilliemeLabel => _pick(
        fr: "L'angle sous lequel je le vois",
        en: 'Viewing angle',
        de: 'Sichtwinkel',
        it: 'Angolo di visione',
        es: 'Ángulo de visión',
      );

  String get milliemeMilliemeField => _pick(
        fr: 'Millièmes (₥)',
        en: 'Milliradians (₥)',
        de: 'Milliradiant (₥)',
        it: 'Milliradianti (₥)',
        es: 'Milirradianes (₥)',
      );

  String get milliemeDistanceLabel => _pick(
        fr: 'Distance',
        en: 'Distance',
        de: 'Entfernung',
        it: 'Distanza',
        es: 'Distancia',
      );

  String get milliemeDistanceField => _pick(
        fr: 'Distance (m)',
        en: 'Distance (m)',
        de: 'Entfernung (m)',
        it: 'Distanza (m)',
        es: 'Distancia (m)',
      );

  String get milliemePresetsTitle => _pick(
        fr: 'GABARITS RAPIDES',
        en: 'QUICK PRESETS',
        de: 'SCHNELLVORLAGEN',
        it: 'PRESET RAPIDI',
        es: 'PREAJUSTES RÁPIDOS',
      );

  String get milliemeResetAll => _pick(
        fr: 'RÉINITIALISER TOUT',
        en: 'RESET ALL',
        de: 'ALLES ZURÜCKSETZEN',
        it: 'RESET TUTTO',
        es: 'REINICIAR TODO',
      );

  String get milliemeCalculate => _pick(
        fr: 'CALCULER',
        en: 'CALCULATE',
        de: 'BERECHNEN',
        it: 'CALCOLA',
        es: 'CALCULAR',
      );

  String get milliemeResetField => _pick(
        fr: 'Effacer le champ',
        en: 'Clear field',
        de: 'Feld löschen',
        it: 'Pulisci campo',
        es: 'Borrar campo',
      );

  String get milliemeHelpFormula => _pick(
        fr: 'Rappel : F = m × D (F en m, D en km, m en millièmes). Distance calculée en mètres.',
        en: 'Reminder: F = m × D (F in m, D in km, m in mils). Distance shown in meters.',
        de: 'Erinnerung: F = m × D (F in m, D in km, m in Millirad). Entfernung in Metern.',
        it: 'Promemoria: F = m × D (F in m, D in km, m in mil). Distanza mostrata in metri.',
        es: 'Recordatorio: F = m × D (F en m, D en km, m en mil). Distancia en metros.',
      );

  // Milliradian tool preset labels
  String get milliemePresetPylonHeight => _pick(
        fr: 'Pylône',
        en: 'Pylon',
        de: 'Mast',
        it: 'Palo',
        es: 'Pilona',
      );

  String get milliemePresetPylonWidth => _pick(
        fr: 'Pylône',
        en: 'Pylon',
        de: 'Mast',
        it: 'Palo',
        es: 'Pilona',
      );

  String get milliemePresetTruckHeight => _pick(
        fr: 'Camion',
        en: 'Truck',
        de: 'Lkw',
        it: 'Camion',
        es: 'Camión',
      );

  String get milliemePresetTruckWidth => _pick(
        fr: 'Camion',
        en: 'Truck',
        de: 'Lkw',
        it: 'Camion',
        es: 'Camión',
      );

  String get milliemePresetCarHeight => _pick(
        fr: 'Voiture',
        en: 'Car',
        de: 'Auto',
        it: 'Auto',
        es: 'Coche',
      );

  String get milliemePresetCarWidth => _pick(
        fr: 'Voiture',
        en: 'Car',
        de: 'Auto',
        it: 'Auto',
        es: 'Coche',
      );

  String get milliemePresetHumanHeight => _pick(
        fr: 'Humain',
        en: 'Human',
        de: 'Mensch',
        it: 'Umano',
        es: 'Humano',
      );

  String get milliemePresetHeadHeight => _pick(
        fr: 'Tête',
        en: 'Head',
        de: 'Kopf',
        it: 'Testa',
        es: 'Cabeza',
      );

  String get milliemePresetHeadWidth => _pick(
        fr: 'Tête',
        en: 'Head',
        de: 'Kopf',
        it: 'Testa',
        es: 'Cabeza',
      );

  String get milliemePresetDoorHeight => _pick(
        fr: 'Porte',
        en: 'Door',
        de: 'Tür',
        it: 'Porta',
        es: 'Puerta',
      );

  String get milliemePresetDoorWidth => _pick(
        fr: 'Porte',
        en: 'Door',
        de: 'Tür',
        it: 'Porta',
        es: 'Puerta',
      );

  String get milliemePresetWindowHeight => _pick(
        fr: 'Fenêtre',
        en: 'Window',
        de: 'Fenster',
        it: 'Finestra',
        es: 'Ventana',
      );

  String get milliemePresetWindowWidth => _pick(
        fr: 'Fenêtre',
        en: 'Window',
        de: 'Fenster',
        it: 'Finestra',
        es: 'Ventana',
      );

  String get milliemePresetTreeHeight => _pick(
        fr: 'Arbre',
        en: 'Tree',
        de: 'Baum',
        it: 'Albero',
        es: 'Árbol',
      );

  String get milliemePresetTreeWidth => _pick(
        fr: 'Arbre',
        en: 'Tree',
        de: 'Baum',
        it: 'Albero',
        es: 'Árbol',
      );

  String get milliemePresetHouseHeight => _pick(
        fr: 'Maison',
        en: 'House',
        de: 'Haus',
        it: 'Casa',
        es: 'Casa',
      );

  String get milliemePresetHouseWidth => _pick(
        fr: 'Maison',
        en: 'House',
        de: 'Haus',
        it: 'Casa',
        es: 'Casa',
      );

  String get navHomeLabel => _pick(
        fr: 'Accueil',
        en: 'Home',
        de: 'Startseite',
        it: 'Home',
        es: 'Inicio',
      );

  String get navSessionsLabel => _pick(
        fr: 'Séances',
        en: 'Sessions',
        de: 'Sitzungen',
        it: 'Sessioni',
        es: 'Sesiones',
      );

  String get navInventoryLabel => _pick(
        fr: 'Matériel',
        en: 'Equipment',
        de: 'Ausrüstung',
        it: 'Materiale',
        es: 'Material',
      );

  String get navToolsLabel => _pick(
        fr: 'Outils',
        en: 'Tools',
        de: 'Werkzeuge',
        it: 'Strumenti',
        es: 'Herramientas',
      );

  String get navSettingsLabel => _pick(
        fr: 'Réglages',
        en: 'Settings',
        de: 'Einstellungen',
        it: 'Impostazioni',
        es: 'Ajustes',
      );

  String get confirm => _pick(
        fr: 'CONFIRMER',
        en: 'CONFIRM',
        de: 'BESTÄTIGEN',
        it: 'CONFERMA',
        es: 'CONFIRMAR',
      );

  String get colorPodToolTitle => _pick(fr: 'Pod de couleur', en: 'Color Pod', de: 'Farb-Pod', it: 'Color Pod', es: 'Pod de color');
  String get colorPodToolSubtitle => _pick(fr: 'Exercice de réactivité chromatique', en: 'Chromatic reaction exercise', de: 'Chromatische Reaktionsübung', it: 'Esercizio di reattività cromatica', es: 'Ejercicio de reactividad cromática');
  String get colorPodColors => _pick(fr: 'COULEURS', en: 'COLORS', de: 'FARBEN', it: 'COLORI', es: 'COLORES');
  String get colorPodActivateAll => _pick(fr: 'Tout activer', en: 'Enable all', de: 'Alle aktivieren', it: 'Attiva tutto', es: 'Activar todo');
  String get colorPodDeactivateAll => _pick(fr: 'Tout désactiver', en: 'Disable all', de: 'Alle deaktivieren', it: 'Disattiva tutto', es: 'Desactivar todo');
  String get colorPodColorDuration => _pick(fr: 'Durée affichage couleur', en: 'Color display duration', de: 'Farbanzeige-Dauer', it: 'Durata visualizzazione colore', es: 'Duración visualización color');
  String get colorPodDelay => _pick(fr: 'Délai entre couleurs (noir)', en: 'Delay between colors (black)', de: 'Pause zwischen Farben (schwarz)', it: 'Pausa tra i colori (nero)', es: 'Pausa entre colores (negro)');
  String get colorPodTotalDuration => _pick(fr: "Durée totale de l'exercice", en: 'Total exercise duration', de: 'Gesamtdauer der Übung', it: "Durata totale dell'esercizio", es: 'Duración total del ejercicio');
  String get colorPodLaunch => _pick(fr: 'LANCER', en: 'START', de: 'STARTEN', it: 'AVVIA', es: 'INICIAR');
  String get colorPodPrepare => _pick(fr: 'Préparez-vous', en: 'Get ready', de: 'Mach dich bereit', it: 'Preparati', es: 'Prepárate');
  String get colorPodSecondsLeft => _pick(fr: 'secondes restantes', en: 'seconds left', de: 'Sekunden übrig', it: 'secondi rimanenti', es: 'segundos restantes');
  String get colorPodStop => _pick(fr: 'STOP', en: 'STOP', de: 'STOP', it: 'STOP', es: 'STOP');
  String get colorPodResults => _pick(fr: 'RÉSULTATS', en: 'RESULTS', de: 'ERGEBNISSE', it: 'RISULTATI', es: 'RESULTADOS');
  String colorPodTotal(int n) => _pick(fr: '$n apparitions au total', en: '$n total appearances', de: '$n Erscheinungen insgesamt', it: '$n apparizioni totali', es: '$n apariciones en total');
  String get colorPodConfig => _pick(fr: 'CONFIG', en: 'CONFIG', de: 'CONFIG', it: 'CONFIG', es: 'CONFIG');
  String get colorPodRestart => _pick(fr: 'RECOMMENCER', en: 'RESTART', de: 'NEUSTART', it: 'RICOMINCIA', es: 'REINICIAR');
  String get colorPodRed => _pick(fr: 'Rouge', en: 'Red', de: 'Rot', it: 'Rosso', es: 'Rojo');
  String get colorPodBlue => _pick(fr: 'Bleu', en: 'Blue', de: 'Blau', it: 'Blu', es: 'Azul');
  String get colorPodGreen => _pick(fr: 'Vert', en: 'Green', de: 'Grün', it: 'Verde', es: 'Verde');
  String get colorPodYellow => _pick(fr: 'Jaune', en: 'Yellow', de: 'Gelb', it: 'Giallo', es: 'Amarillo');
  String get colorPodOrange => _pick(fr: 'Orange', en: 'Orange', de: 'Orange', it: 'Arancione', es: 'Naranja');
  String get colorPodPurple => _pick(fr: 'Violet', en: 'Purple', de: 'Lila', it: 'Viola', es: 'Morado');
  String get colorPodWhite => _pick(fr: 'Blanc', en: 'White', de: 'Weiß', it: 'Bianco', es: 'Blanco');
String get colorPodBlack => _pick(fr: 'Noir', en: 'Black', de: 'Schwarz', it: 'Nero', es: 'Negro');
String get colorPodShapes => _pick(fr: 'FORMES', en: 'SHAPES', de: 'FORMEN', it: 'FORME', es: 'FORMAS');
String get colorPodLetters => _pick(fr: 'LETTRES', en: 'LETTERS', de: 'BUCHSTABEN', it: 'LETTERE', es: 'LETRAS');
String get colorPodDigits => _pick(fr: 'CHIFFRES', en: 'DIGITS', de: 'ZIFFERN', it: 'CIFRE', es: 'DÍGITOS');
String get colorPodShapeCircle => _pick(fr: 'Cercle', en: 'Circle', de: 'Kreis', it: 'Cerchio', es: 'Círculo');
String get colorPodShapeSquare => _pick(fr: 'Carré', en: 'Square', de: 'Quadrat', it: 'Quadrato', es: 'Cuadrado');
String get colorPodShapeTriangle => _pick(fr: 'Triangle', en: 'Triangle', de: 'Dreieck', it: 'Triangolo', es: 'Triángulo');
String get colorPodShapeStar => _pick(fr: 'Étoile', en: 'Star', de: 'Stern', it: 'Stella', es: 'Estrella');
String get colorPodShapeDiamond => _pick(fr: 'Diamant', en: 'Diamond', de: 'Diamant', it: 'Diamante', es: 'Diamante');

String _pick({ 
    required String fr,
    required String en,
    required String de,
    required String it,
    required String es,
  }) {
    if (_isFr) return fr;
    if (_isEn) return en;
    if (_isDe) return de;
    if (_isIt) return it;
    if (_isEs) return es;
    return fr;
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppStrings.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppStrings> load(Locale locale) {
    return SynchronousFuture<AppStrings>(AppStrings.forLocale(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}