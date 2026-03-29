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
        fr: 'Le carnet de tir numÃ©rique incontournable pour les utilisateurs d\'arme Ã  feu.',
        en: 'The essential digital shooting logbook for firearm users.',
        de: 'Das unverzichtbare digitale SchieÃŸbuch fÃ¼r Waffenbesitzer.',
        it: 'Il taccuino digitale di tiro essenziale per gli utilizzatori di armi da fuoco.',
        es: 'El cuaderno de tiro digital imprescindible para los usuarios de armas de fuego.',
      );

  String get onboardingTitle2 => _pick(
        fr: '100% Hors-ligne & SÃ©curisÃ©',
        en: '100% Offline & Secure',
        de: '100% Offline & Sicher',
        it: '100% Offline e Sicuro',
        es: '100% Sin conexiÃ³n y seguro',
      );

String get onboardingDescription2 => _pick(
        fr: 'Vos donnÃ©es ne quittent jamais votre appareil. Aucun serveur, aucun compte, aucune fuite possible â€” tout est chiffrÃ© localement avec AES-256 et protÃ©gÃ© par votre code PIN ou votre biomÃ©trie.',
        en: 'Your data never leaves your device. No server, no account, no possible leak â€” everything is encrypted locally with AES-256 and protected by your PIN or biometrics.',
        de: 'Ihre Daten verlassen Ihr GerÃ¤t nie. Kein Server, kein Konto, kein mÃ¶glicher Datenverlust â€” alles wird lokal mit AES-256 verschlÃ¼sselt und durch Ihre PIN oder Biometrie geschÃ¼tzt.',
        it: 'I tuoi dati non lasciano mai il dispositivo. Nessun server, nessun account, nessuna fuga possibile â€” tutto Ã¨ cifrato localmente con AES-256 e protetto dal tuo PIN o dalla tua biometria.',
        es: 'Tus datos nunca salen de tu dispositivo. Sin servidor, sin cuenta, sin posible fuga â€” todo estÃ¡ cifrado localmente con AES-256 y protegido por tu PIN o biometrÃ­a.',
      );

  String get onboardingTitle3 => _pick(
        fr: 'GÃ©rez votre Ã©quipement',
        en: 'Manage your equipment',
        de: 'Verwalten Sie Ihre AusrÃ¼stung',
        it: 'Gestisci la tua attrezzatura',
        es: 'Gestiona tu equipo',
      );

  String get onboardingDescription3 => _pick(
        fr: 'Suivez vos armes, vos munitions, votre Ã©quipement, documentez vos sÃ©ances et analysez vos statistiques de tir avec prÃ©cision.',
        en: 'Track your firearms, ammo and gear, log your sessions and analyze your shooting statistics with precision.',
        de: 'Verfolgen Sie Ihre Waffen, Munition und AusrÃ¼stung, dokumentieren Sie Ihre Sitzungen und analysieren Sie Ihre SchieÃŸstatistiken prÃ¤zise.',
        it: 'Tieni traccia delle tue armi, munizioni e attrezzature, documenta le tue sessioni e analizza con precisione le tue statistiche di tiro.',
        es: 'Haz un seguimiento de tus armas, municiones y equipo, documenta tus sesiones y analiza con precisiÃ³n tus estadÃ­sticas de tiro.',
      );

  String get onboardingDontShowAgain => _pick(
        fr: 'Ne plus afficher',
        en: 'Don\'t show again',
        de: 'Nicht mehr anzeigen',
        it: 'Non mostrare piÃ¹',
        es: 'No mostrar de nuevo',
      );

  String get onboardingSkip => _pick(
        fr: 'Passer',
        en: 'Skip',
        de: 'Ãœberspringen',
        it: 'Salta',
        es: 'Omitir',
      );

  String get clear => _pick(
        fr: 'Effacer',
        en: 'Clear',
        de: 'LÃ¶schen',
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
        fr: 'GÃ©rez vos dÃ©parts, fenÃªtres de tir et rÃ©pÃ©titions.',
        en: 'Control start delays, par times and repetitions.',
        de: 'Steuern Sie StartverzÃ¶gerungen, Par-Zeiten und Wiederholungen.',
        it: 'Gestisci ritardi di partenza, par time e ripetizioni.',
        es: 'Gestiona retrasos de salida, par times y repeticiones.',
      );

  String get timerModesTitle => _pick(
        fr: 'Modes de timer',
        en: 'Timer modes',
        de: 'Timer-Modi',
        it: 'ModalitÃ  timer',
        es: 'Modos de temporizador',
      );

  String get timerSettingsTitle => _pick(
        fr: 'RÃ©glages du timer',
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
        es: 'Sonido y vibraciÃ³n',
      );

  String get timerShotDetectionTitle => _pick(
        fr: 'DÃ©tection du coup de feu',
        en: 'Shot detection',
        de: 'Schusserkennung',
        it: 'Rilevamento dello sparo',
        es: 'DetecciÃ³n de disparo',
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
        fr: 'RÃ©pÃ©titions',
        en: 'Repeats',
        de: 'Wiederholungen',
        it: 'Ripetizioni',
        es: 'Repeticiones',
      );

  String get timerModeRandomDelay => _pick(
fr: 'Bip alÃ©atoire',
en: 'Random beep',
de: 'ZufÃ¤lliger Signalton',
it: 'Bip casuale',
es: 'Bip aleatorio',
      );

  String get timerModeStartAndMic => _pick(
fr: 'RÃ©action au bip',
en: 'Reaction to beep',
de: 'Reaktion auf Signalton',
it: 'Reazione al bip',
es: 'ReacciÃ³n al bip',
      );

  String get timerModeStartAndShots => _pick(
fr: 'Chaque coup compte',
en: 'Every shot counts',
de: 'Jeder Schuss zÃ¤hlt',
it: 'Ogni colpo conta',
es: 'Cada disparo cuenta',
      );

  String get timerModeSimpleDescription => _pick(
        fr: 'Un bip aprÃ¨s le dÃ©lai choisi, idÃ©al pour un dÃ©part simple.',
        en: 'One beep after the selected delay, ideal for a simple start.',
        de: 'Ein Signalton nach der gewÃ¤hlten VerzÃ¶gerung, ideal fÃ¼r einen einfachen Start.',
        it: 'Un bip dopo il ritardo selezionato, ideale per una partenza semplice.',
        es: 'Un pitido tras el retraso seleccionado, ideal para una salida simple.',
      );

  String get timerModeParTimeDescription => _pick(
        fr: 'DÃ©lai puis fenÃªtre de tir (Par time) avant le bip final.',
        en: 'Delay then a shooting window (Par time) before the final beep.',
        de: 'VerzÃ¶gerung, dann ein Schussfenster (Par-Zeit) vor dem letzten Signalton.',
        it: 'Ritardo poi finestra di tiro (Par time) prima del bip finale.',
        es: 'Retraso y luego ventana de tiro (Par time) antes del pitido final.',
      );

  String get timerModeRepeatDescription => _pick(
        fr: 'Plusieurs dÃ©parts espacÃ©s du mÃªme dÃ©lai, pour enchaÃ®ner les sÃ©ries.',
        en: 'Multiple starts separated by the same delay, to chain shooting strings.',
        de: 'Mehrere Starts mit derselben VerzÃ¶gerung, um Serien hintereinander zu schieÃŸen.',
        it: 'PiÃ¹ partenze separate dallo stesso ritardo, per concatenare le serie.',
        es: 'Varias salidas separadas por el mismo retraso, para encadenar series.',
      );

  String get timerModeRandomDelayDescription => _pick(
        fr: 'DÃ©lai de dÃ©part alÃ©atoire entre 50Â % et 100Â % du dÃ©lai choisi.',
        en: 'Random start delay between 50% and 100% of the selected delay.',
        de: 'ZufÃ¤llige StartverzÃ¶gerung zwischen 50Â % und 100Â % der gewÃ¤hlten Zeit.',
        it: 'Ritardo di partenza casuale tra il 50% e il 100% del ritardo scelto.',
        es: 'Retraso de salida aleatorio entre el 50Â % y el 100Â % del retraso elegido.',
      );

  String get timerModeStartAndMicDescription => _pick(
        fr: 'Un bip de dÃ©part aprÃ¨s le dÃ©lai choisi, puis le compteur tourne jusquâ€™Ã  la dÃ©tonation (ou arrÃªt manuel).',
        en: 'A start beep after the selected delay, then the timer runs until the shot (or manual stop).',
        de: 'Ein Startsignalton nach der gewÃ¤hlten VerzÃ¶gerung, dann lÃ¤uft der Timer bis zum Schuss (oder manueller Stopp).',
        it: 'Un bip di partenza dopo il ritardo scelto, poi il timer continua fino allo sparo (o stop manuale).',
        es: 'Un pitido de salida tras el retraso elegido, luego el temporizador sigue hasta el disparo (o parada manual).',
      );

  String get timerModeStartAndShotsDescription => _pick(
        fr: 'Un bip de dÃ©part aprÃ¨s le dÃ©lai choisi, puis le micro enregistre chaque coup et affiche les temps jusquâ€™au stop.',
        en: 'A start beep after the selected delay, then the mic records each shot time until you stop.',
        de: 'Ein Startsignalton nach der gewÃ¤hlten VerzÃ¶gerung, dann zeichnet das Mikro jeden Schusszeitpunkt bis zum Stopp auf.',
        it: 'Un bip di partenza dopo il ritardo scelto, poi il micro registra ogni tempo di colpo fino allo stop.',
        es: 'Un pitido de salida tras el retraso elegido, luego el mic registra cada tiempo de disparo hasta detener.',
      );

  String get timerModeSimpleExample => _pick(
        fr: 'Ex: Face Ã  la cible, tu fixes un dÃ©lai avant dÃ©part, au bip tu dÃ©gaines et tire un coup.',
        en: 'Ex: Facing the target, set a start delay. On the beep, draw and fire one shot.',
        de: 'Bsp.: Du stehst vor dem Ziel und stellst eine StartverzÃ¶gerung ein. Beim Signalton ziehst du und gibst einen Schuss ab.',
        it: 'Es: Di fronte al bersaglio, imposti un ritardo di partenza. Al bip estrai e spari un colpo.',
        es: 'Ej: Frente al blanco, ajustas un retardo de salida. Al pitido desenfundas y disparas un tiro.',
      );

  String get timerModeParTimeExample => _pick(
        fr: 'Ex: Au bip tu as X secondes pour dÃ©clencher X cartouches avant le second bip.',
        en: 'Ex: On the beep, you have X seconds to fire X rounds before the second beep.',
        de: 'Bsp.: Beim Signalton hast du X Sekunden, um X SchÃ¼sse abzugeben, bevor der zweite Signalton ertÃ¶nt.',
        it: 'Es: Al bip hai X secondi per sparare X colpi prima del secondo bip.',
        es: 'Ej: Al pitido tienes X segundos para disparar X cartuchos antes del segundo pitido.',
      );

  String get timerModeRepeatExample => _pick(
        fr: 'Ex: Au bip tu as X secondes pour dÃ©clencher X cartouches au pistolet avant le second bip. Le cycle redÃ©marre tu as X secondes pour dÃ©clencher X cartouches au fusil etc...',
        en: 'Ex: On the beep, you have X seconds to fire X rounds with the pistol before the second beep. The cycle restarts: you have X seconds to fire X rounds with the rifle, etc.',
        de: 'Bsp.: Beim Signalton hast du X Sekunden, um X SchÃ¼sse mit der Pistole abzugeben, bevor der zweite Signalton ertÃ¶nt. Dann startet der Zyklus erneut: X Sekunden fÃ¼r X SchÃ¼sse mit dem Gewehr usw.',
        it: 'Es: Al bip hai X secondi per sparare X colpi con la pistola prima del secondo bip. Il ciclo riparte: hai X secondi per sparare X colpi con il fucile, ecc.',
        es: 'Ej: Al pitido tienes X segundos para disparar X cartuchos con la pistola antes del segundo pitido. El ciclo se reinicia: tienes X segundos para disparar X cartuchos con el fusil, etc.',
      );

  String get timerModeRandomDelayExample => _pick(
        fr: 'Ex: Au bip, le timer se dÃ©clenche alÃ©atoirement, tu dÃ©gaines et tu tires.',
        en: 'Ex: On the beep, the timer triggers randomly. Draw and fire.',
        de: 'Bsp.: Beim Signalton wird der Start zufÃ¤llig ausgelÃ¶st. Zieh und schieÃŸ.',
        it: 'Es: Al bip, la partenza avviene in modo casuale. Estrai e spara.',
        es: 'Ej: Al pitido, el inicio se dispara aleatoriamente. Desenfundas y disparas.',
      );

  String get timerModeStartAndMicExample => _pick(
        fr: 'Ex: Au bip, tu dÃ©gaines et tu tires, le tÃ©lÃ©phone enregistre le coup de feu et te donne le temps de rÃ©action en secondes.',
        en: 'Ex: On the beep, draw and fire. The phone detects the shot and gives your reaction time in seconds.',
        de: 'Bsp.: Beim Signalton ziehst du und schieÃŸt. Das Telefon erkennt den Schuss und gibt dir deine Reaktionszeit in Sekunden.',
        it: 'Es: Al bip estrai e spari. Il telefono rileva lo sparo e ti dÃ  il tempo di reazione in secondi.',
        es: 'Ej: Al pitido desenfundas y disparas. El telÃ©fono detecta el disparo y te da el tiempo de reacciÃ³n en segundos.',
      );

  String get timerModeStartAndShotsExample => _pick(
        fr: 'Ex: Au bip, tu dÃ©gaines, tu tires, chaque coup de feu est enregistrÃ©.',
        en: 'Ex: On the beep, draw and fire. Each shot is detected and recorded.',
        de: 'Bsp.: Beim Signalton ziehst du und schieÃŸt. Jeder Schuss wird erkannt und aufgezeichnet.',
        it: 'Es: Al bip estrai e spari. Ogni colpo viene rilevato e registrato.',
        es: 'Ej: Al pitido desenfundas y disparas. Cada disparo se detecta y se registra.',
      );

  String get timerShotTimesTitle => _pick(
        fr: 'Temps enregistrÃ©s',
        en: 'Recorded times',
        de: 'Aufgezeichnete Zeiten',
        it: 'Tempi registrati',
        es: 'Tiempos registrados',
      );

  String get timerMicDisclaimerShort => _pick(
        fr: 'Le micro est utilisÃ© uniquement pendant ce mode pour Ã©couter une dÃ©tonation. Aucun son nâ€™est enregistrÃ© ni envoyÃ©.',
        en: 'The microphone is used only in this mode to listen for a shot. No audio is recorded or sent.',
        de: 'Das Mikrofon wird nur in diesem Modus verwendet, um einen Schuss zu erkennen. Es wird kein Audio aufgezeichnet oder Ã¼bertragen.',
        it: 'Il microfono viene usato solo in questa modalitÃ  per rilevare uno sparo. Nessun audio viene registrato o inviato.',
        es: 'El micrÃ³fono se usa solo en este modo para detectar un disparo. No se graba ni se envÃ­a audio.',
      );

  String get diagnosticToolSubtitle => _pick(
        fr: 'Analyse guidÃ©e des incidents de tir.',
        en: 'Guided analysis of shooting incidents.',
        de: 'GefÃ¼hrte Analyse von SchieÃŸzwischenfÃ¤llen.',
        it: 'Analisi guidata degli incidenti di tiro.',
        es: 'AnÃ¡lisis guiado de incidentes de tiro.',
      );

  String get timerStartDelayLabel => _pick(
        fr: 'DÃ©lai avant dÃ©part (s)',
        en: 'Start delay (s)',
        de: 'StartverzÃ¶gerung (s)',
        it: 'Ritardo di avvio (s)',
        es: 'Retardo de inicio (s)',
      );

  String get timerParTimeLabel => _pick(
        fr: 'FenÃªtre de tir (Par time, s)',
        en: 'Shooting window (Par time, s)',
        de: 'Schussfenster (Par-Zeit, s)',
        it: 'Finestra di tiro (Par time, s)',
        es: 'Ventana de tiro (Par time, s)',
      );

  String get timerCycleDurationLabel => _pick(
        fr: "DurÃ©e d'un cycle (s)",
        en: 'Cycle duration (s)',
        de: 'Zyklusdauer (s)',
        it: 'Durata di un ciclo (s)',
        es: 'DuraciÃ³n de un ciclo (s)',
      );

  String get timerRepetitionsLabel => _pick(
        fr: 'Nombre de rÃ©pÃ©titions',
        en: 'Number of repetitions',
        de: 'Anzahl Wiederholungen',
        it: 'Numero di ripetizioni',
        es: 'NÃºmero de repeticiones',
      );

  String get timerRandomBaseLabel => _pick(
        fr: 'Base de dÃ©lai alÃ©atoire (s)',
        en: 'Random delay base (s)',
        de: 'Basis fÃ¼r ZufallsverzÃ¶gerung (s)',
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
        es: 'Activar vibraciÃ³n',
      );

  String get timerEnableShotDetection => _pick(
        fr: 'Activer la dÃ©tection du son du tir',
        en: 'Enable shot sound detection',
        de: 'Erkennung des SchussgerÃ¤uschs aktivieren',
        it: 'Abilita rilevamento del suono dello sparo',
        es: 'Activar detecciÃ³n de sonido de disparo',
      );

  String get timerShotSensitivityLabel => _pick(
        fr: 'SensibilitÃ© de dÃ©tection',
        en: 'Detection sensitivity',
        de: 'Erkennungsempfindlichkeit',
        it: 'SensibilitÃ  di rilevamento',
        es: 'Sensibilidad de detecciÃ³n',
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
        fr: 'Plus la sensibilitÃ© est fine, plus la dÃ©tection peut rÃ©agir aux bruits ambiants.',
        en: 'The finer the sensitivity, the more it may react to ambient noise.',
        de: 'Je feiner die Empfindlichkeit, desto eher kann die Erkennung auf UmgebungsgerÃ¤usche reagieren.',
        it: 'PiÃ¹ la sensibilitÃ  Ã¨ fine, piÃ¹ il rilevamento puÃ² reagire ai rumori ambientali.',
        es: 'Cuanto mÃ¡s fina la sensibilidad, mÃ¡s puede reaccionar al ruido ambiental.',
      );

  String get timerMicDisclaimer => _pick(
        fr: 'Le micro est utilisÃ© uniquement sur lâ€™appareil pour dÃ©tecter les pics sonores. Aucun son nâ€™est envoyÃ© Ã  lâ€™extÃ©rieur. Les performances de dÃ©tection peuvent varier selon le stand et lâ€™arme utilisÃ©e.',
        en: 'The microphone is used only on-device to detect sound peaks. No audio is sent outside the app. Detection performance may vary depending on range and firearm.',
        de: 'Das Mikrofon wird nur auf dem GerÃ¤t verwendet, um Schalldruckspitzen zu erkennen. Es wird kein Audio nach auÃŸen gesendet. Die Erkennung kann je nach SchieÃŸstand und Waffe variieren.',
        it: 'Il microfono Ã¨ utilizzato solo sul dispositivo per rilevare i picchi sonori. Nessun audio viene inviato allâ€™esterno. Le prestazioni di rilevamento possono variare a seconda del poligono e dellâ€™arma.',
        es: 'El micrÃ³fono se usa solo en el dispositivo para detectar picos de sonido. No se envÃ­a audio fuera de la app. El rendimiento de detecciÃ³n puede variar segÃºn el campo y el arma.',
      );

  String get timerMicPermissionDenied => _pick(
        fr: 'La dÃ©tection sonore nÃ©cessite lâ€™autorisation micro.',
        en: 'Shot detection requires microphone permission.',
        de: 'Die Schusserkennung erfordert die Mikrofonberechtigung.',
        it: 'Il rilevamento degli spari richiede lâ€™autorizzazione al microfono.',
        es: 'La detecciÃ³n de disparos requiere permiso de micrÃ³fono.',
      );

  String get timerStatusReady => _pick(
        fr: 'PrÃªt',
        en: 'Ready',
        de: 'Bereit',
        it: 'Pronto',
        es: 'Listo',
      );

  String get timerStatusRunning => _pick(
        fr: 'En cours',
        en: 'Running',
        de: 'LÃ¤uft',
        it: 'In esecuzione',
        es: 'En curso',
      );

  String get timerStatusFinished => _pick(
        fr: 'TerminÃ©',
        en: 'Finished',
        de: 'Beendet',
        it: 'Terminato',
        es: 'Terminado',
      );

  String get timerStartButton => _pick(
        fr: 'DÃ©marrer',
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
        fr: 'ArrÃªter',
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
        es: 'VersiÃ³n PRO',
      );

  String get homeVersionFreeLabel => _pick(
        fr: 'Version gratuite',
        en: 'Free version',
        de: 'Kostenlose Version',
        it: 'Versione gratuita',
        es: 'VersiÃ³n gratuita',
      );

  String get shortcutsGroupTitle => _pick(
        fr: 'RACCOURCIS ACCUEIL (MAX 4)',
        en: 'HOME SHORTCUTS (MAX 4)',
        de: 'STARTSEITENKÃœRZEL (MAX 4)',
        it: 'SCORCIATOIE HOME (MAX 4)',
        es: 'ATAJOS INICIO (MÃX 4)',
      );

  String get shortcutNewSession => _pick(
        fr: 'Nouvelle sÃ©ance',
        en: 'New session',
        de: 'Neue Trainingseinheit',
        it: 'Nuova sessione',
        es: 'Nueva sesiÃ³n',
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
        es: 'Nueva municiÃ³n',
      );

  String get shortcutNewAccessory => _pick(
        fr: 'Nouvel accessoire',
        en: 'New accessory',
        de: 'Neues ZubehÃ¶r',
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
        de: 'SchieÃŸ-Timer',
        it: 'Timer di tiro',
        es: 'Temporizador de tiro',
      );

  String get quickActionLabelTheme => _pick(
        fr: 'Mode nuit',
        en: 'Dark mode',
        de: 'Dunkelmodus',
        it: 'ModalitÃ  scura',
        es: 'Modo oscuro',
      );

  String get securityGroupTitle => _pick(
        fr: 'SÃ‰CURITÃ‰',
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
        es: 'CÃ³digo PIN',
      );

  String get biometricLabel => _pick(
        fr: 'Face ID / Touch ID',
        en: 'Face ID / Touch ID',
        de: 'Face ID / Touch ID',
        it: 'Face ID / Touch ID',
        es: 'Face ID / Touch ID',
      );

  String get statusEnabled => _pick(
        fr: 'ActivÃ©',
        en: 'Enabled',
        de: 'Aktiviert',
        it: 'Attivato',
        es: 'Activado',
      );

  String get statusDisabled => _pick(
        fr: 'DÃ©sactivÃ©',
        en: 'Disabled',
        de: 'Deaktiviert',
        it: 'Disattivato',
        es: 'Desactivado',
      );

  String get pinDisabledSnack => _pick(
        fr: 'Code PIN dÃ©sactivÃ©',
        en: 'PIN code disabled',
        de: 'PIN-Code deaktiviert',
        it: 'Codice PIN disattivato',
        es: 'CÃ³digo PIN desactivado',
      );

  String get biometricRequiresPinSnack => _pick(
        fr: "Veuillez d'abord configurer un code PIN",
        en: 'Please configure a PIN code first',
        de: 'Bitte richte zuerst einen PIN-Code ein',
        it: 'Configura prima un codice PIN',
        es: 'Configura primero un cÃ³digo PIN',
      );

  String biometricStatusChangedSnack(bool enabled) => enabled
      ? _pick(
          fr: 'Authentification biomÃ©trique activÃ©e',
          en: 'Biometric authentication enabled',
          de: 'Biometrische Authentifizierung aktiviert',
          it: 'Autenticazione biometrica attivata',
          es: 'AutenticaciÃ³n biomÃ©trica activada',
        )
      : _pick(
          fr: 'Authentification biomÃ©trique dÃ©sactivÃ©e',
          en: 'Biometric authentication disabled',
          de: 'Biometrische Authentifizierung deaktiviert',
          it: 'Autenticazione biometrica disattivata',
          es: 'AutenticaciÃ³n biomÃ©trica desactivada',
        );

  String get supportGroupTitle => _pick(
        fr: 'SUPPORT & SÃ‰CURITÃ‰',
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
        es: 'ContÃ¡ctanos',
      );

  String get contactMeSubtitle => _pick(
        fr: 'Partenariat ou Support',
        en: 'Partnership or Support',
        de: 'Partnerschaft oder Support',
        it: 'Partnership o Supporto',
        es: 'ColaboraciÃ³n o Soporte',
      );

  String get contactPartnership => _pick(
        fr: 'Demande de partenariat',
        en: 'Partnership request',
        de: 'Partnerschaftsanfrage',
        it: 'Richiesta di partnership',
        es: 'Solicitud de colaboraciÃ³n',
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
        es: 'Solicitud de colaboraciÃ³n - THOT',
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
        fr: 'Plus rÃ©cents',
        en: 'Most recent',
        de: 'Neueste zuerst',
        it: 'PiÃ¹ recenti',
        es: 'MÃ¡s recientes',
      );

  String get achievementsSortOldest => _pick(
        fr: 'Plus anciens',
        en: 'Oldest first',
        de: 'Ã„lteste zuerst',
        it: 'PiÃ¹ vecchi',
        es: 'MÃ¡s antiguos',
      );

  String get achievementsSortLevelHigh => _pick(
        fr: "Niveau Ã©levÃ© d'abord",
        en: 'Higher tier first',
        de: 'HÃ¶herer Rang zuerst',
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
        fr: 'Exporter mes donnÃ©es (PDF)',
        en: 'Export my data (PDF)',
        de: 'Meine Daten exportieren (PDF)',
        it: 'Esporta i miei dati (PDF)',
        es: 'Exportar mis datos (PDF)',
      );

  String get exportPdfSubtitlePremium => _pick(
        fr: 'Export complet de votre carnet',
        en: 'Full export of your logbook',
        de: 'VollstÃ¤ndiger Export Ihres SchieÃŸbuchs',
        it: 'Esportazione completa del tuo registro',
        es: 'ExportaciÃ³n completa de tu cuaderno',
      );

  String get exportPdfSubtitleProOnly => _pick(
        fr: 'FonctionnalitÃ© Pro',
        en: 'Pro feature',
        de: 'Pro-Funktion',
        it: 'Funzione Pro',
        es: 'FunciÃ³n Pro',
      );

  String get dataPrivacyLabel => _pick(
        fr: 'DonnÃ©es & confidentialitÃ©',
        en: 'Data & privacy',
        de: 'Daten & Datenschutz',
        it: 'Dati & privacy',
        es: 'Datos y privacidad',
      );

  String get dataPrivacySubtitle => _pick(
        fr: 'Chiffrement AES-256 Â· ZÃ©ro serveur Â· 100% local',
        en: 'AES-256 encryption Â· Zero server Â· 100% local',
        de: 'AES-256-VerschlÃ¼sselung Â· Kein Server Â· 100% lokal',
        it: 'Crittografia AES-256 Â· Zero server Â· 100% locale',
        es: 'Cifrado AES-256 Â· Sin servidor Â· 100% local',
      );

  String get aboutLabel => _pick(
        fr: 'Ã€ propos & confidentialitÃ©',
        en: 'About & privacy',
        de: 'Ãœber & Datenschutz',
        it: 'Informazioni & privacy',
        es: 'Acerca de y privacidad',
      );

  String get aboutSubtitle => _pick(
        fr: 'Mentions lÃ©gales, CGU, politique de confidentialitÃ©',
        en: 'Legal, Terms of Use, Privacy Policy',
        de: 'Impressum, Nutzungsbedingungen, Datenschutzrichtlinie',
        it: 'Note legali, Termini dâ€™uso, Informativa privacy',
        es: 'Aviso legal, TÃ©rminos de uso, PolÃ­tica de privacidad',
      );

  // --- Home screen ---


  String get statisticsPageTitle => _pick(
        fr: 'STATISTIQUES',
        en: 'STATISTICS',
        de: 'STATISTIKEN',
        it: 'STATISTICHE',
        es: 'ESTADÃSTICAS',
      );

  String get statisticsPageSubtitle => _pick(
        fr: 'VUE GLOBALE',
        en: 'OVERVIEW',
        de: 'GESAMTANSICHT',
        it: 'PANORAMICA',
        es: 'VISTA GENERAL',
      );

  String get statisticsGlobalSummaryTitle => _pick(
        fr: 'RÃ‰SUMÃ‰ GLOBAL',
        en: 'GLOBAL SUMMARY',
        de: 'GESAMTZUSAMMENFASSUNG',
        it: 'RIEPILOGO GENERALE',
        es: 'RESUMEN GLOBAL',
      );

  String get statisticsSessionsLabel => _pick(
        fr: 'SÃ©ances',
        en: 'Sessions',
        de: 'Sitzungen',
        it: 'Sessioni',
        es: 'Sesiones',
      );

  String get statisticsShotsFiredLabel => _pick(
        fr: 'Coups tirÃ©s',
        en: 'Shots fired',
        de: 'SchÃ¼sse',
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
        es: 'MuniciÃ³n',
      );

  String get statisticsAccessoriesLabel => _pick(
        fr: 'Accessoires',
        en: 'Accessories',
        de: 'ZubehÃ¶r',
        it: 'Accessori',
        es: 'Accesorios',
      );

  String get statisticsShotsPerSessionLabel => _pick(
fr: 'Cps / sÃ©ance',
en: 'Shots / sess.',
de: 'Sch. / Serie',
it: 'Colpi / sess.',
es: 'Disp. / sesiÃ³n',
      );

  String get statisticsPrecisionTitle => _pick(
        fr: 'PRÃ‰CISION',
        en: 'PRECISION',
        de: 'PRÃ„ZISION',
        it: 'PRECISIONE',
        es: 'PRECISIÃ“N',
      );

  String get statisticsAveragePrecisionLabel => _pick(
        fr: 'PrÃ©cision moyenne',
        en: 'Average precision',
        de: 'Durchschnittliche PrÃ¤zision',
        it: 'Precisione media',
        es: 'PrecisiÃ³n media',
      );

  String get statisticsPerfectSessionsLabel => _pick(
        fr: 'SÃ©ances Ã  100%',
        en: '100% sessions',
        de: '100%-Sitzungen',
        it: 'Sessioni al 100%',
        es: 'Sesiones al 100%',
      );

  String get statisticsBestSessionLabel => _pick(
        fr: 'Meilleure sÃ©ance',
        en: 'Best session',
        de: 'Beste Sitzung',
        it: 'Migliore sessione',
        es: 'Mejor sesiÃ³n',
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
        fr: 'Exercices / sÃ©ance',
        en: 'Exercises / session',
        de: 'Ãœbungen / Sitzung',
        it: 'Esercizi / sessione',
        es: 'Ejercicios / sesiÃ³n',
      );

  String get statisticsSessionsWithPrecisionLabel => _pick(
        fr: 'SÃ©ances avec prÃ©cision',
        en: 'Sessions with precision',
        de: 'Sitzungen mit PrÃ¤zision',
        it: 'Sessioni con precisione',
        es: 'Sesiones con precisiÃ³n',
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
        fr: 'RÃ©visions',
        en: 'Revisions',
        de: 'Revisionen',
        it: 'Revisioni',
        es: 'Revisiones',
      );

  String get statisticsClosestRevisionWeaponLabel => _pick(
        fr: 'Arme la plus proche dâ€™une rÃ©vision',
        en: 'Weapon closest to revision',
        de: 'Waffe am nÃ¤chsten an einer Revision',
        it: 'Arma piÃ¹ vicina alla revisione',
        es: 'Arma mÃ¡s cercana a revisiÃ³n',
      );

  String get statisticsClosestCleaningWeaponLabel => _pick(
        fr: 'Arme la plus proche dâ€™un entretien',
        en: 'Weapon closest to cleaning',
        de: 'Waffe am nÃ¤chsten an einer Reinigung',
        it: 'Arma piÃ¹ vicina alla pulizia',
        es: 'Arma mÃ¡s cercana al mantenimiento',
      );

  String get statisticsSmartIndicatorsTitle => _pick(
        fr: 'INDICATEURS INTELLIGENTS',
        en: 'SMART INDICATORS',
        de: 'INTELLIGENTE INDIKATOREN',
        it: 'INDICATORI INTELLIGENTI',
        es: 'INDICADORES INTELIGENTES',
      );

  String get statisticsMostUsedWeaponLabel => _pick(
        fr: 'Arme la plus utilisÃ©e',
        en: 'Most used weapon',
        de: 'Am hÃ¤ufigsten verwendete Waffe',
        it: 'Arma piÃ¹ usata',
        es: 'Arma mÃ¡s usada',
      );

  String get statisticsMostCriticalAmmoLabel => _pick(
        fr: 'Munition la plus critique',
        en: 'Most critical ammo',
        de: 'Kritischste Munition',
        it: 'Munizione piÃ¹ critica',
        es: 'MuniciÃ³n mÃ¡s crÃ­tica',
      );

  String get statisticsLongestSessionLabel => _pick(
        fr: 'SÃ©ance la plus dense',
        en: 'Most intense session',
        de: 'Intensivste Sitzung',
        it: 'Sessione piÃ¹ intensa',
        es: 'SesiÃ³n mÃ¡s intensa',
      );

  String get statisticsLastSessionLabel => _pick(
        fr: 'DerniÃ¨re sÃ©ance',
        en: 'Last session',
        de: 'Letzte Sitzung',
        it: 'Ultima sessione',
        es: 'Ãšltima sesiÃ³n',
      );

  String statisticsSmartIndicatorShotsValue(int shots) => _pick(
        fr: '$shots ${shots > 1 ? 'coups' : 'coup'}',
        en: '$shots ${shots == 1 ? 'shot' : 'shots'}',
        de: '$shots ${shots == 1 ? 'Schuss' : 'SchÃ¼sse'}',
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
        de: 'Anzahl der SchÃ¼sse',
        it: 'Numero di colpi',
        es: 'NÃºmero de disparos',
      );

  String get statisticsSessionsChartTitle => _pick(
        fr: 'Nombre de sÃ©ances',
        en: 'Number of sessions',
        de: 'Anzahl der Sitzungen',
        it: 'Numero di sessioni',
        es: 'NÃºmero de sesiones',
      );

  String get statisticsWeaponsByTypeTitle => _pick(
        fr: 'RÃ‰PARTITION PAR TYPE D\'ARME',
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
        es: 'Advertencia antes del diagnÃ³stico',
      );

  String get diagnosticDisclaimerBody => _pick(
        fr: "Cet outil ne peut pas se substituer Ã  lâ€™expertise dâ€™un armurier qualifiÃ©. Toute manipulation dâ€™une arme doit Ãªtre effectuÃ©e dans le strict respect des rÃ¨gles de sÃ©curitÃ©. Les rÃ©sultats fournis par le diagnostique ne constituent quâ€™une piste de recherche dâ€™incident et ne remplacent ni une inspection physique, ni un contrÃ´le professionnel.",
        en: 'This tool cannot replace the expertise of a qualified gunsmith. Any handling of a firearm must be performed in strict compliance with safety rules. The results provided by the diagnostic are only a troubleshooting lead and do not replace a physical inspection or professional assessment.',
        de: 'Dieses Werkzeug ersetzt nicht die Expertise eines qualifizierten BÃ¼chsenmachers. Jede Handhabung einer Waffe muss unter strikter Einhaltung der Sicherheitsregeln erfolgen. Die Diagnoseergebnisse stellen lediglich einen Ansatz zur Fehlersuche dar und ersetzen weder eine physische Inspektion noch eine fachliche PrÃ¼fung.',
        it: "Questo strumento non puÃ² sostituire l'esperienza di un armaiolo qualificato. Qualsiasi manipolazione di un'arma deve essere effettuata nel rigoroso rispetto delle regole di sicurezza. I risultati forniti dalla diagnostica costituiscono solo una pista di ricerca del guasto e non sostituiscono nÃ© un'ispezione fisica nÃ© una verifica professionale.",
        es: 'Esta herramienta no puede sustituir la experiencia de un armero cualificado. Cualquier manipulaciÃ³n de un arma debe realizarse respetando estrictamente las normas de seguridad. Los resultados proporcionados por el diagnÃ³stico solo constituyen una pista de investigaciÃ³n del incidente y no sustituyen una inspecciÃ³n fÃ­sica ni una evaluaciÃ³n profesional.',
      );

  String get diagnosticDisclaimerConfirm => _pick(
        fr: 'Je comprends',
        en: 'I understand',
        de: 'Ich verstehe',
        it: 'Ho capito',
        es: 'Entiendo',
      );

  String get legalInfoTitle => _pick(
        fr: 'Documents & informations lÃ©gales',
        en: 'Legal documents & information',
        de: 'Rechtliche Dokumente & Informationen',
        it: 'Documenti e informazioni legali',
        es: 'Documentos e informaciÃ³n legal',
      );

  String get legalInfoSubtitle => _pick(
        fr: "Tout le contenu ci-dessous est affichÃ© directement dans l'application.",
        en: 'All content below is displayed directly in the application.',
        de: 'Der gesamte untenstehende Inhalt wird direkt in der Anwendung angezeigt.',
        it: "Tutto il contenuto seguente Ã¨ visualizzato direttamente nell'applicazione.",
        es: 'Todo el contenido a continuaciÃ³n se muestra directamente en la aplicaciÃ³n.',
      );

  String get legalAboutTitle => _pick(
        fr: 'Ã€ propos de THOT',
        en: 'About THOT',
        de: 'Ãœber THOT',
        it: 'Informazioni su THOT',
        es: 'Acerca de THOT',
      );

  String get legalPresentationTitle => _pick(
        fr: 'PrÃ©sentation',
        en: 'Overview',
        de: 'Vorstellung',
        it: 'Presentazione',
        es: 'PresentaciÃ³n',
      );

  String get legalSupportTitle => _pick(
        fr: 'Support',
        en: 'Support',
        de: 'Support',
        it: 'Supporto',
        es: 'Soporte',
      );

  String get legalCguTitle => _pick(
        fr: "Conditions GÃ©nÃ©rales dâ€™Utilisation (CGU)",
        en: 'Terms of Use',
        de: 'Nutzungsbedingungen',
        it: 'Condizioni generali di utilizzo',
        es: 'Condiciones generales de uso',
      );

  String get legalDiagnosticDisclaimerSectionTitle => _pick(
        fr: 'Diagnostique et sÃ©curitÃ©',
        en: 'Diagnostic and safety',
        de: 'Diagnose und Sicherheit',
        it: 'Diagnostica e sicurezza',
        es: 'DiagnÃ³stico y seguridad',
      );

  String get quickActionLabelMillieme => _pick(
fr: 'Formule du milliÃ¨me',
en: 'Mil formula',
de: 'Mil-Formel',
it: 'Formula del mil',
es: 'FÃ³rmula del mil',
      );

  String get milliemeTitle => _pick(
fr: 'Formule du milliÃ¨me',
en: 'Mil formula',
de: 'Mil-Formel',
it: 'Formula del mil',
es: 'FÃ³rmula del mil',
      );

  String get milliemeSubtitle => _pick(
        fr: 'Calculez votre distance de tir en milliÃ¨me',
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
        de: 'HÃ¶he',
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
        de: 'Geben Sie die Entfernung und HÃ¶he ein, um den Mil-Wert zu erhalten',
        it: 'Inserisci la distanza e l\'altezza per ottenere il valore in mil',
        es: 'Ingrese la distancia y la altura para obtener el valor en mil',
      );

  String get milliemeResetLabel => _pick(
        fr: 'RÃ©initialiser',
        en: 'Reset',
        de: 'ZurÃ¼cksetzen',
        it: 'Reimpostare',
        es: 'Reiniciar',
      );

  String get milliemeResetConfirmationLabel => _pick(
        fr: 'Voulez-vous rÃ©initialiser les valeurs?',
        en: 'Do you want to reset the values?',
        de: 'MÃ¶chten Sie die Werte zurÃ¼cksetzen?',
        it: 'Vuoi reimpostare i valori?',
        es: 'Â¿Quiere reiniciar los valores?',
      );

  // --- Sessions ---

  String get sessionsSubtitle => _pick(
        fr: 'SÃ‰ANCES',
        en: 'SESSIONS',
        de: 'SITZUNGEN',
        it: 'SESSIONI',
        es: 'SESIONES',
      );

  String get newSessionCta => _pick(
        fr: 'Nouvelle sÃ©ance',
        en: 'New session',
        de: 'Neue Sitzung',
        it: 'Nuova sessione',
        es: 'Nueva sesiÃ³n',
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
        es: '7 dÃ­as',
      );

  String get sessionsSearchHint => _pick(
        fr: 'Rechercher par arme, munition, accessoire, jour...',
        en: 'Search by weapon, ammo, accessory, date...',
        de: 'Suche nach Waffe, Munition, ZubehÃ¶r, Datum...',
        it: 'Cerca per arma, munizioni, accessorio, data...',
        es: 'Buscar por arma, municiÃ³n, accesorio, fecha...',
      );

  String sessionExerciseDefaultTitle(int index) => _pick(
        fr: 'Exercice $index',
        en: 'Exercise $index',
        de: 'Ãœbung $index',
        it: 'Esercizio $index',
        es: 'Ejercicio $index',
      );

  String get sessionWeaponAndEquipmentDetailsTitle => _pick(
        fr: 'DÃ©tails de lâ€™arme et Ã©quipement',
        en: 'Weapon and equipment details',
        de: 'Waffen- und AusrÃ¼stungsdetails',
        it: 'Dettagli arma e attrezzatura',
        es: 'Detalles del arma y equipo',
      );

  String get sessionShootingResultsTitle => _pick(
        fr: 'RÃ©sultat du tir',
        en: 'Shooting results',
        de: 'SchieÃŸergebnisse',
        it: 'Risultati di tiro',
        es: 'Resultados de tiro',
      );

  String get sessionsEmptySearchTitle => _pick(
        fr: 'Aucune sÃ©ance trouvÃ©e',
        en: 'No session found',
        de: 'Keine Sitzung gefunden',
        it: 'Nessuna sessione trovata',
        es: 'No se encontrÃ³ ninguna sesiÃ³n',
      );

  String get sessionsEmptySearchSubtitle => _pick(
        fr: 'Essayez une autre recherche',
        en: 'Try another search',
        de: 'Versuche eine andere Suche',
        it: 'Prova unâ€™altra ricerca',
        es: 'Prueba otra bÃºsqueda',
      );

  String get sessionsEmptyPeriodTitle => _pick(
        fr: 'Aucune sÃ©ance pour cette pÃ©riode',
        en: 'No session for this period',
        de: 'Keine Sitzung in diesem Zeitraum',
        it: 'Nessuna sessione per questo periodo',
        es: 'No hay sesiones para este perÃ­odo',
      );

  String get sessionsEmptyPeriodSubtitle => _pick(
        fr: 'CrÃ©ez votre premiÃ¨re sÃ©ance',
        en: 'Create your first session',
        de: 'Erstelle deine erste Sitzung',
        it: 'Crea la tua prima sessione',
        es: 'Crea tu primera sesiÃ³n',
      );

  String get sessionMenuEdit => _pick(
        fr: 'Ã‰diter',
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
        de: 'LÃ¶schen',
        it: 'Elimina',
        es: 'Eliminar',
      );

  String get newSessionTitle => _pick(
        fr: 'NOUVELLE SÃ‰ANCE',
        en: 'NEW SESSION',
        de: 'NEUE SITZUNG',
        it: 'NUOVA SESSIONE',
        es: 'NUEVA SESIÃ“N',
      );

  String get generalInfoSectionTitle => _pick(
        fr: 'Informations gÃ©nÃ©rales',
        en: 'General Information',
        de: 'Allgemeine Informationen',
        it: 'Informazioni generali',
        es: 'InformaciÃ³n general',
      );

  String get sessionNameLabel => _pick(
        fr: 'Nom de la sÃ©ance *',
        en: 'Session name *',
        de: 'Sitzungsname *',
        it: 'Nome sessione *',
        es: 'Nombre de la sesiÃ³n *',
      );

  String get sessionNameHint => _pick(
        fr: 'Ex: EntraÃ®nement hebdomadaire',
        en: 'Ex: Weekly training',
        de: 'Ex: WÃ¶chentliches Training',
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
        fr: 'Date et heure de la sÃ©ance',
        en: 'Session date and time',
        de: 'Sitzungsdatum und -uhrzeit',
        it: 'Data e ora della sessione',
        es: 'Fecha y hora de la sesiÃ³n',
      );

  String get locationLabel => _pick(
fr: 'Ville',
en: 'City',
de: 'Stadt',
it: 'CittÃ ',
es: 'Ciudad',
      );

  String get locationHint => _pick(
fr: 'Ex. : Club de tir de la ville',
en: 'E.g. City shooting club',
de: 'Z. B. SchÃ¼tzenverein der Stadt',
it: 'Es.: club di tiro della cittÃ ',
es: 'Ej.: club de tiro de la ciudad',
      );

  String get shootingDistanceLabel => _pick(
        fr: 'Quel stand de tir?',
        en: 'Which shooting lane?',
        de: 'Welche SchieÃŸbahn?',
        it: 'Quale linea di tiro?',
        es: 'Â¿QuÃ© puesto de tiro?',
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
        de: 'Ãœbungsname',
        it: 'Nome esercizio',
        es: 'Nombre del ejercicio',
      );

  String get exerciseNameHint => _pick(
        fr: 'Ex: Groupement Ã  25 m',
        en: 'Ex: 25 m grouping',
        de: 'Z.B.: 25-m-Gruppe',
        it: 'Es: Rosata a 25 m',
        es: 'Ej: AgrupaciÃ³n a 25 m',
      );

  String get targetNameHint => _pick(
        fr: 'Ex: Cible C50, silhouette, gongsâ€¦',
        en: 'Ex: C50 target, silhouette, steel platesâ€¦',
        de: 'Z.B.: C50-Scheibe, Silhouette, Stahlzieleâ€¦',
        it: 'Es: Bersaglio C50, sagoma, gongâ€¦',
        es: 'Ej: Diana C50, silueta, gongâ€¦',
      );

  String get targetPhotosHint => _pick(
        fr: 'Ajoutez des photos de vos cibles pour suivre vos groupements.',
        en: 'Add photos of your targets to track your groups.',
        de: 'FÃ¼gen Sie Fotos Ihrer Scheiben hinzu, um Ihre Gruppen zu verfolgen.',
        it: 'Aggiungi foto dei bersagli per seguire le rosate.',
        es: 'AÃ±ade fotos de tus dianas para seguir tus agrupaciones.',
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
        fr: 'Coups tirÃ©s',
        en: 'Shots fired',
        de: 'SchÃ¼sse',
        it: 'Colpi sparati',
        es: 'Disparos',
      );

  String get shotsCountLabel => _pick(
        fr: 'Nombre de coups',
        en: 'Number of shots',
        de: 'Anzahl der SchÃ¼sse',
        it: 'Numero di colpi',
        es: 'NÃºmero de disparos',
      );

  String get shotsFiredError => _pick(
        fr: 'Saisissez un nombre de coups (> 0).',
        en: 'Enter a number of shots (> 0).',
        de: 'Geben Sie eine Anzahl an SchÃ¼ssen ein (> 0).',
        it: 'Inserisci un numero di colpi (> 0).',
        es: 'Introduce un nÃºmero de disparos (> 0).',
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
        de: 'Geben Sie eine gÃ¼ltige Entfernung ein (> 0).',
        it: 'Inserisci una distanza valida (> 0).',
        es: 'Introduce una distancia vÃ¡lida (> 0).',
      );

  String get sessionTypeLabel => _pick(
        fr: 'Type de sÃ©ance',
        en: 'Session type',
        de: 'Sitzungstyp',
        it: 'Tipo di sessione',
        es: 'Tipo de sesiÃ³n',
      );

  String get sessionTypePersonal => _pick(
        fr: 'Personnel',
        en: 'Personal',
        de: 'PersÃ¶nlich',
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
        fr: 'CompÃ©tition',
        en: 'Competition',
        de: 'Wettbewerb',
        it: 'Competizione',
        es: 'CompeticiÃ³n',
      );

  String get sessionSummaryTitle => _pick(
        fr: 'RÃ©sumÃ© sÃ©ance',
        en: 'Session summary',
        de: 'SitzungsÃ¼bersicht',
        it: 'Riepilogo sessione',
        es: 'Resumen sesiÃ³n',
      );

  String exerciseCardTitle(int index) => _pick(
        fr: 'Exercice ${index + 1}',
        en: 'Exercise ${index + 1}',
        de: 'Ãœbung ${index + 1}',
        it: 'Esercizio ${index + 1}',
        es: 'Ejercicio ${index + 1}',
      );

  String get exerciseDetailsTitle => _pick(
        fr: "DÃ©tails arme & Ã©quipement",
        en: 'Weapon & gear details',
        de: 'Waffen- & AusrÃ¼stungsdetails',
        it: 'Dettagli arma e attrezzatura',
        es: 'Detalles de arma y equipo',
      );

  String get shootingResultsTitle => _pick(
        fr: 'RÃ©sultats du tir',
        en: 'Shooting results',
        de: 'SchieÃŸergebnisse',
        it: 'Risultati di tiro',
        es: 'Resultados del tiro',
      );

  String get borrowedWeaponFallback => _pick(
        fr: 'Arme prÃªtÃ©e',
        en: 'Borrowed weapon',
        de: 'Geliehene Waffe',
        it: 'Arma prestata',
        es: 'Arma prestada',
      );

  String get borrowedAmmoFallback => _pick(
        fr: 'Munition prÃªtÃ©e',
        en: 'Borrowed ammo',
        de: 'Geliehene Munition',
        it: 'Munizione prestata',
        es: 'MuniciÃ³n prestada',
      );

  String get equipmentTitle => _pick(
        fr: 'Ã‰quipement',
        en: 'Equipment',
        de: 'AusrÃ¼stung',
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
        fr: 'Total des coups tirÃ©s : $totalShots',
        en: 'Total shots fired: $totalShots',
        de: 'GesamtschÃ¼sse: $totalShots',
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
        de: 'Auswirkung auf ZubehÃ¶r',
        it: 'Impatto sugli accessori',
        es: 'Impacto en accesorios',
      );

  String sessionSummaryAmmoImpactLine(String name, int shots, int remaining) =>
      _pick(
        fr: 'â€¢ $name : $shots coups tirÃ©s, $remaining restantes',
        en: 'â€¢ $name: $shots shots fired, $remaining remaining',
        de: 'â€¢ $name: $shots SchÃ¼sse, $remaining verbleibend',
        it: 'â€¢ $name: $shots colpi sparati, $remaining rimanenti',
        es: 'â€¢ $name: $shots disparos, $remaining restantes',
      );

  String sessionSummaryWeaponImpactLine(String name, int shots) => _pick(
        fr: 'â€¢ $name : $shots coups tirÃ©s',
        en: 'â€¢ $name: $shots shots fired',
        de: 'â€¢ $name: $shots SchÃ¼sse',
        it: 'â€¢ $name: $shots colpi sparati',
        es: 'â€¢ $name: $shots disparos',
      );

  String sessionSummaryAccessoryImpactLine(String name, int shots) => _pick(
        fr: 'â€¢ $name : +$shots coups',
        en: 'â€¢ $name: +$shots shots',
        de: 'â€¢ $name: +$shots SchÃ¼sse',
        it: 'â€¢ $name: +$shots colpi',
        es: 'â€¢ $name: +$shots disparos',
      );

  String get saveSessionButton => _pick(
        fr: 'ENREGISTRER LA SÃ‰ANCE',
        en: 'SAVE SESSION',
        de: 'SITZUNG SPEICHERN',
        it: 'SALVA SESSIONE',
        es: 'GUARDAR SESIÃ“N',
      );

  String get exercisesSectionTitle => _pick(
        fr: 'Exercices',
        en: 'Exercises',
        de: 'Ãœbungen',
        it: 'Esercizi',
        es: 'Ejercicios',
      );

  String get addButton => _pick(
        fr: 'Ajouter',
        en: 'Add',
        de: 'HinzufÃ¼gen',
        it: 'Aggiungi',
        es: 'Agregar',
      );

  String get noExerciseAdded => _pick(
        fr: 'Aucun exercice ajoutÃ©',
        en: 'No exercise added',
        de: 'Keine Ãœbung hinzugefÃ¼gt',
        it: 'Nessun esercizio aggiunto',
        es: 'NingÃºn ejercicio agregado',
      );

  String get weatherConditionsTitle => _pick(
        fr: 'Conditions MÃ©tÃ©o',
        en: 'Weather Conditions',
        de: 'Wetterbedingungen',
        it: 'Condizioni Meteo',
        es: 'Condiciones ClimÃ¡ticas',
      );

  String get weatherLoadingText => _pick(
        fr: 'RÃ©cupÃ©ration de la mÃ©tÃ©o en coursâ€¦',
        en: 'Fetching weatherâ€¦',
        de: 'Wetter wird abgerufenâ€¦',
        it: 'Recupero meteo in corsoâ€¦',
        es: 'Obteniendo climaâ€¦',
      );

  String get temperatureLabel => _pick(
        fr: 'TempÃ©rature',
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
        es: 'PresiÃ³n',
      );

  String get windLabel => _pick(
        fr: 'Vent',
        en: 'Wind',
        de: 'Wind',
        it: 'Vento',
        es: 'Viento',
      );

  String get humidityLabel => _pick(
        fr: 'HumiditÃ©',
        en: 'Humidity',
        de: 'Feuchtigkeit',
        it: 'UmiditÃ ',
        es: 'Humedad',
      );

  String get disableTooltip => _pick(
        fr: 'DÃ©sactiver',
        en: 'Disable',
        de: 'Deaktivieren',
        it: 'Disabilita',
        es: 'Desactivar',
      );

  String get enableTooltip => _pick(
        fr: 'RÃ©activer',
        en: 'Re-enable',
        de: 'Reaktivieren',
        it: 'Riattiva',
        es: 'Reactivar',
      );

  String get locationPermissionDenied => _pick(
        fr: 'Autorisation de localisation refusÃ©e',
        en: 'Location permission denied',
        de: 'Standortberechtigung verweigert',
        it: 'Autorizzazione posizione negata',
        es: 'Permiso de ubicaciÃ³n denegado',
      );

  String get locationPermissionDeniedForever => _pick(
        fr: 'Autorisation de localisation refusÃ©e dÃ©finitivement. Ouvrez les rÃ©glages de lâ€™application pour la rÃ©activer.',
        en: 'Location permission permanently denied. Open the app settings to re-enable it.',
        de: 'Standortberechtigung dauerhaft verweigert. Ã–ffnen Sie die App-Einstellungen, um sie wieder zu aktivieren.',
        it: 'Autorizzazione posizione negata in modo permanente. Apri le impostazioni dellâ€™app per riattivarla.',
        es: 'Permiso de ubicaciÃ³n denegado permanentemente. Abre los ajustes de la aplicaciÃ³n para volver a activarlo.',
      );

  String get locationServicesDisabled => _pick(
        fr: 'Localisation dÃ©sactivÃ©e sur l\'appareil',
        en: 'Location services disabled on device',
        de: 'Standortdienste auf GerÃ¤t deaktiviert',
        it: 'Servizi di localizzazione disabilitati sul dispositivo',
        es: 'Servicios de ubicaciÃ³n desactivados en el dispositivo',
      );

  String get positionRetrievalFailed => _pick(
        fr: 'Impossible de rÃ©cupÃ©rer la position',
        en: 'Unable to retrieve position',
        de: 'Position kann nicht abgerufen werden',
        it: 'Impossibile recuperare la posizione',
        es: 'No se puede recuperar la posiciÃ³n',
      );

  String get fetchLocalPositionButton => _pick(
        fr: 'RÃ©cupÃ©rer la position locale',
        en: 'Fetch local position',
        de: 'Lokale Position abrufen',
        it: 'Recupera posizione locale',
        es: 'Obtener posiciÃ³n local',
      );

String get locationUsageExplanation => _pick(
  fr: 'Position utilisÃ©e uniquement Ã  votre demande pour renseigner la ville du stand et la mÃ©tÃ©o locale.',
  en: 'Location is only used on request to fill in the range city and local weather.',
  de: 'Standort wird nur auf Anfrage verwendet, um die Stadt des SchieÃŸstands und das lokale Wetter zu ergÃ¤nzen.',
  it: 'La posizione viene usata solo su richiesta per compilare la cittÃ  del poligono e il meteo locale.',
  es: 'La ubicaciÃ³n solo se usa a peticiÃ³n para completar la ciudad del campo de tiro y el clima local.',
);

String get reverseGeocodingExplanation => _pick(
  fr: 'Les coordonnÃ©es servent uniquement Ã  identifier la ville et Ã©viter une saisie manuelle.',
  en: 'Coordinates are only used to identify the city and avoid manual entry.',
  de: 'Die Koordinaten werden nur verwendet, um die Stadt zu bestimmen und eine manuelle Eingabe zu vermeiden.',
  it: 'Le coordinate servono solo a identificare la cittÃ  ed evitare lâ€™inserimento manuale.',
  es: 'Las coordenadas solo se usan para identificar la ciudad y evitar la introducciÃ³n manual.',
);

String get weatherUsageExplanation => _pick(
  fr: 'Le bouton mÃ©tÃ©o rÃ©cupÃ¨re la mÃ©tÃ©o locale utile Ã  la sÃ©ance, sans utilisation en arriÃ¨re-plan.',
  en: 'The weather button fetches local weather for the session, with no background use.',
  de: 'Die WetterschaltflÃ¤che ruft das lokale Wetter fÃ¼r die Sitzung ab, ohne Nutzung im Hintergrund.',
  it: 'Il pulsante meteo recupera il meteo locale per la sessione, senza uso in background.',
  es: 'El botÃ³n del clima obtiene el clima local para la sesiÃ³n, sin uso en segundo plano.',
);

  String get fetchLocalWeatherButton => _pick(
        fr:
            'RÃ©cupÃ©rer la mÃ©tÃ©o locale',
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
        fr: 'Autorisation de localisation refusÃ©e (mÃ©tÃ©o).',
        en: 'Location permission denied (weather).',
        de: 'Standortberechtigung verweigert (Wetter).',
        it: 'Autorizzazione posizione negata (meteo).',
        es: 'Permiso de ubicaciÃ³n denegado (clima).',
      );

  String get weatherLocationPermissionDeniedForever => _pick(
        fr: 'Autorisation de localisation refusÃ©e dÃ©finitivement pour la mÃ©tÃ©o. Ouvrez les rÃ©glages de lâ€™application pour la rÃ©activer.',
        en: 'Location permission permanently denied for weather. Open the app settings to re-enable it.',
        de: 'Standortberechtigung fÃ¼r Wetter dauerhaft verweigert. Ã–ffnen Sie die App-Einstellungen, um sie wieder zu aktivieren.',
        it: 'Autorizzazione posizione negata in modo permanente per il meteo. Apri le impostazioni dellâ€™app per riattivarla.',
        es: 'Permiso de ubicaciÃ³n denegado permanentemente para el clima. Abre los ajustes de la aplicaciÃ³n para volver a activarlo.',
      );

  String get weatherLocationServicesDisabled => _pick(
        fr: 'Localisation dÃ©sactivÃ©e sur l\'appareil (mÃ©tÃ©o).',
        en: 'Location services disabled on device (weather).',
        de: 'Standortdienste auf GerÃ¤t deaktiviert (Wetter).',
        it: 'Servizi di localizzazione disabilitati sul dispositivo (meteo).',
        es: 'Servicios de ubicaciÃ³n desactivados en el dispositivo (clima).',
      );

  String get weatherNetworkError => _pick(
        fr: 'Impossible de rÃ©cupÃ©rer la mÃ©tÃ©o (rÃ©seau).',
        en: 'Unable to fetch weather (network).',
        de: 'Wetter kann nicht abgerufen werden (Netzwerk).',
        it: 'Impossibile recuperare il meteo (rete).',
        es: 'No se puede obtener el clima (red).',
      );

  String get weatherInvalidResponse => _pick(
        fr: 'RÃ©ponse mÃ©tÃ©o invalide.',
        en: 'Invalid weather response.',
        de: 'UngÃ¼ltige Wetterantwort.',
        it: 'Risposta meteo non valida.',
        es: 'Respuesta de clima invÃ¡lida.',
      );

  String get weatherUnavailable => _pick(
        fr: 'MÃ©tÃ©o indisponible pour cet emplacement.',
        en: 'Weather unavailable for this location.',
        de: 'Wetter fÃ¼r diesen Standort nicht verfÃ¼gbar.',
        it: 'Meteo non disponibile per questa posizione.',
        es: 'Clima no disponible para esta ubicaciÃ³n.',
      );

  String get weatherRetrievalError => _pick(
        fr: 'Erreur lors de la rÃ©cupÃ©ration de la mÃ©tÃ©o.',
        en: 'Error retrieving weather.',
        de: 'Fehler beim Abrufen des Wetters.',
        it: 'Errore durante il recupero del meteo.',
        es: 'Error al obtener el clima.',
      );

  String get openAppSettingsLabel => _pick(
        fr: 'Ouvrir les rÃ©glages',
        en: 'Open settings',
        de: 'Einstellungen Ã¶ffnen',
        it: 'Apri impostazioni',
        es: 'Abrir ajustes',
      );

  String get freeVersionWeaponLimit => _pick(
        fr:
            'Version gratuite : seule la premiÃ¨re arme est utilisable. Passez Ã  Pro pour dÃ©bloquer tout le matÃ©riel.',
        en:
            'Free version: only the first weapon is usable. Upgrade to Pro to unlock all equipment.',
        de:
            'Kostenlose Version: nur die erste Waffe ist verwendbar. Upgrade auf Pro, um die gesamte AusrÃ¼stung freizuschalten.',
        it:
            'Versione gratuita: solo la prima arma Ã¨ utilizzabile. Passa a Pro per sbloccare tutta lâ€™attrezzatura.',
        es:
            'VersiÃ³n gratuita: solo la primera arma es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
      );

  String get freeVersionAmmoLimit => _pick(
        fr:
            'Version gratuite : seule la premiÃ¨re munition est utilisable. Passez Ã  Pro pour dÃ©bloquer tout le matÃ©riel.',
        en:
            'Free version: only the first ammo entry is usable. Upgrade to Pro to unlock all equipment.',
        de:
            'Kostenlose Version: nur die erste Munition ist verwendbar. Upgrade auf Pro, um die gesamte AusrÃ¼stung freizuschalten.',
        it:
            'Versione gratuita: solo la prima munizione Ã¨ utilizzabile. Passa a Pro per sbloccare tutta lâ€™attrezzatura.',
        es:
            'VersiÃ³n gratuita: solo la primera municiÃ³n es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
      );

  String get freeVersionAccessoryLimit => _pick(
        fr:
            'Version gratuite : seul le premier accessoire est utilisable. Passez Ã  Pro pour dÃ©bloquer tout le matÃ©riel.',
        en:
            'Free version: only the first accessory is usable. Upgrade to Pro to unlock all equipment.',
        de:
            'Kostenlose Version: nur das erste ZubehÃ¶r ist verwendbar. Upgrade auf Pro, um die gesamte AusrÃ¼stung freizuschalten.',
        it:
            'Versione gratuita: solo il primo accessorio Ã¨ utilizzabile. Passa a Pro per sbloccare tutta lâ€™attrezzatura.',
        es:
            'VersiÃ³n gratuita: solo el primer accesorio es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
      );

  String get sessionDuplicatedSnack => _pick(
        fr: 'SÃ©ance dupliquÃ©e',
        en: 'Session duplicated',
        de: 'Sitzung dupliziert',
        it: 'Sessione duplicata',
        es: 'SesiÃ³n duplicada',
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
        es: 'MuniciÃ³n',
      );

  String get inventoryTitle => _pick(
        fr: 'THOT',
        en: 'THOT',
        de: 'THOT',
        it: 'THOT',
        es: 'THOT',
      );

  String get inventorySubtitle => _pick(
        fr: 'MATÃ‰RIEL',
        en: 'EQUIPMENT',
        de: 'AUSRÃœSTUNG',
        it: 'ATTREZZATURA',
        es: 'EQUIPO',
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
        es: 'MuniciÃ³n',
      );

  String get accessoriesTab => _pick(
        fr: 'Accessoires',
        en: 'Accessories',
        de: 'ZubehÃ¶r',
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
        de: 'Waffe hinzufÃ¼gen',
        it: 'Aggiungi arma',
        es: 'Agregar arma',
      );

  String get addAmmo => _pick(
        fr: 'Ajouter une munition',
        en: 'Add ammunition',
        de: 'Munition hinzufÃ¼gen',
        it: 'Aggiungi munizione',
        es: 'Agregar municiÃ³n',
      );

  String get addAccessory => _pick(
        fr: 'Ajouter un accessoire',
        en: 'Add accessory',
        de: 'ZubehÃ¶r hinzufÃ¼gen',
        it: 'Aggiungi accessorio',
        es: 'Agregar accesorio',
      );

  String get addEquipment => _pick(
        fr: 'Ajouter du matÃ©riel',
        en: 'Add equipment',
        de: 'AusrÃ¼stung hinzufÃ¼gen',
        it: 'Aggiungi attrezzatura',
        es: 'Agregar equipo',
      );

  String get noWeaponFound => _pick(
        fr: 'Aucune arme trouvÃ©e',
        en: 'No weapon found',
        de: 'Keine Waffe gefunden',
        it: 'Nessuna arma trovata',
        es: 'No se encontrÃ³ arma',
      );

  String get noWeaponInStock => _pick(
        fr: "Vous n'avez pas d'arme en stock.",
        en: "You don't have any weapons in stock.",
        de: 'Du hast keine Waffen im Bestand.',
        it: 'Non hai armi in stock.',
        es: 'No tienes armas en stock.',
      );

  String get addFirstWeapon => _pick(
        fr: 'Ajoutez votre premiÃ¨re arme',
        en: 'Add your first weapon',
        de: 'FÃ¼ge deine erste Waffe hinzu',
        it: 'Aggiungi la tua prima arma',
        es: 'Agrega tu primera arma',
      );

  String get noAmmoFound => _pick(
        fr: 'Aucune munition trouvÃ©e',
        en: 'No ammunition found',
        de: 'Keine Munition gefunden',
        it: 'Nessuna munizione trovata',
        es: 'No se encontrÃ³ municiÃ³n',
      );

  String get noAmmoInStock => _pick(
        fr: "Vous n'avez pas de munition en stock.",
        en: "You don't have any ammunition in stock.",
        de: 'Du hast keine Munition im Bestand.',
        it: 'Non hai munizioni in stock.',
        es: 'No tienes municiÃ³n en stock.',
      );

  String get addFirstAmmo => _pick(
        fr: 'Ajoutez votre premiÃ¨re munition',
        en: 'Add your first ammunition',
        de: 'FÃ¼ge deine erste Munition hinzu',
        it: 'Aggiungi la tua prima munizione',
        es: 'Agrega tu primera municiÃ³n',
      );

  String get noAccessoryFound => _pick(
        fr: 'Aucun accessoire trouvÃ©',
        en: 'No accessory found',
        de: 'Kein ZubehÃ¶r gefunden',
        it: 'Nessun accessorio trovato',
        es: 'No se encontrÃ³ accesorio',
      );

  String get noAccessoryInStock => _pick(
        fr: "Vous n'avez pas d'accessoire en stock.",
        en: "You don't have any accessories in stock.",
        de: 'Du hast kein ZubehÃ¶r im Bestand.',
        it: 'Non hai accessori in stock.',
        es: 'No tienes accesorios en stock.',
      );

  String get addFirstAccessory => _pick(
        fr: 'Ajoutez votre premier accessoire',
        en: 'Add your first accessory',
        de: 'FÃ¼ge dein erstes ZubehÃ¶r hinzu',
        it: 'Aggiungi il tuo primo accessorio',
        es: 'Agrega tu primer accesorio',
      );

  String get shotsFired => _pick(
        fr: 'Coups tirÃ©s',
        en: 'Shots fired',
        de: 'SchÃ¼sse abgefeuert',
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
        fr: 'DerniÃ¨re sÃ©ance',
        en: 'Last session',
        de: 'Letzte Sitzung',
        it: 'Ultima sessione',
        es: 'Ãšltima sesiÃ³n',
      );

  String get yesterday => _pick(
        fr: 'Hier',
        en: 'Yesterday',
        de: 'Gestern',
        it: 'Ieri',
        es: 'Ayer',
      );

  String get edit => _pick(
        fr: 'Ã‰diter',
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
        de: 'LÃ¶schen',
        it: 'Elimina',
        es: 'Eliminar',
      );

  String get confirmDeletion => _pick(
        fr: 'Confirmer la suppression',
        en: 'Confirm deletion',
        de: 'LÃ¶schung bestÃ¤tigen',
        it: 'Conferma eliminazione',
        es: 'Confirmar eliminaciÃ³n',
      );

  String get deleteConfirmationMessage => _pick(
        fr: 'Voulez-vous vraiment supprimer "{name}" ?',
        en: 'Do you really want to delete "{name}"?',
        de: 'MÃ¶chten Sie "{name}" wirklich lÃ¶schen?',
        it: 'Vuoi davvero eliminare "{name}"?',
        es: 'Â¿Realmente quieres eliminar "{name}"?',
      );

  String get cancel => _pick(
        fr: 'Annuler',
        en: 'Cancel',
        de: 'Abbrechen',
        it: 'Annulla',
        es: 'Cancelar',
      );

  String get deletedSnack => _pick(
        fr: '"{name}" supprimÃ©',
        en: '"{name}" deleted',
        de: '"{name}" gelÃ¶scht',
        it: '"{name}" eliminato',
        es: '"{name}" eliminado',
      );

  String get validate => _pick(
        fr: 'VALIDER',
        en: 'CONFIRM',
        de: 'BESTÃ„TIGEN',
        it: 'CONFERMA',
        es: 'CONFIRMAR',
      );

  String get close => _pick(
        fr: 'Fermer',
        en: 'Close',
        de: 'SchlieÃŸen',
        it: 'Chiudi',
        es: 'Cerrar',
      );

  String get searchEllipsis => _pick(
        fr: 'Rechercherâ€¦',
        en: 'Searchâ€¦',
        de: 'Suchenâ€¦',
        it: 'Cercaâ€¦',
        es: 'Buscarâ€¦',
      );

  String get tapToChooseFromInventory => _pick(
        fr: 'Appuie pour choisir dans ton stock',
        en: 'Tap to choose from your inventory',
        de: 'Tippe, um aus deinem Bestand zu wÃ¤hlen',
        it: 'Tocca per scegliere dal tuo inventario',
        es: 'Toca para elegir de tu inventario',
      );

  String get equipmentsTitle => _pick(
        fr: 'Ã‰quipements',
        en: 'Equipment',
        de: 'AusrÃ¼stung',
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
        fr: 'Aucun rÃ©sultat',
        en: 'No results',
        de: 'Keine Ergebnisse',
        it: 'Nessun risultato',
        es: 'Sin resultados',
      );

  String get noEquipmentFound => _pick(
        fr: 'Aucun Ã©quipement trouvÃ©',
        en: 'No equipment found',
        de: 'Keine AusrÃ¼stung gefunden',
        it: 'Nessuna attrezzatura trovata',
        es: 'No se encontrÃ³ equipo',
      );

  String get searchEquipmentHint => _pick(
        fr: 'Rechercher (optique, protection, marqueâ€¦)',
        en: 'Search (optic, protection, brandâ€¦)',
        de: 'Suchen (Optik, Schutz, Markeâ€¦)',
        it: 'Cerca (ottica, protezione, marcaâ€¦)',
        es: 'Buscar (Ã³ptica, protecciÃ³n, marcaâ€¦)',
      );

  String get settingsDocumentTypeWeaponPermit => _pick(
        fr: "Autorisation de port d'arme",
        en: 'Weapon carry permit',
        de: 'Waffentragegenehmigung',
        it: "Autorizzazione al porto d'armi",
        es: 'Permiso de porte de armas',
      );

  String get settingsDocumentTypeMedicalCertificate => _pick(
        fr: 'Certificat mÃ©dical',
        en: 'Medical certificate',
        de: 'Ã„rztliches Attest',
        it: 'Certificato medico',
        es: 'Certificado mÃ©dico',
      );

  String get settingsDocumentTypeOther => _pick(
        fr: 'Autre',
        en: 'Other',
        de: 'Andere',
        it: 'Altro',
        es: 'Otro',
      );

  String get settingsDocumentAddedSuccess => _pick(
        fr: 'Document ajoutÃ© avec succÃ¨s',
        en: 'Document added successfully',
        de: 'Dokument erfolgreich hinzugefÃ¼gt',
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
        fr: 'Document mis Ã  jour',
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
        de: 'Ã–ffnen',
        it: 'Apri',
        es: 'Abrir',
      );

  String get settingsAdd => _pick(
        fr: 'Ajouter',
        en: 'Add',
        de: 'HinzufÃ¼gen',
        it: 'Aggiungi',
        es: 'AÃ±adir',
      );

  String get settingsPremiumTitle => _pick(
        fr: 'THOT Premium',
        en: 'THOT Premium',
        de: 'THOT Premium',
        it: 'THOT Premium',
        es: 'THOT Premium',
      );

  String get settingsPremiumUnlockText => _pick(
        fr: 'DÃ©bloquez toutes les fonctionnalitÃ©s premium :',
        en: 'Unlock all premium features:',
        de: 'Schalte alle Premium-Funktionen frei:',
        it: 'Sblocca tutte le funzionalitÃ  premium:',
        es: 'Desbloquea todas las funciones premium:',
      );

  String get settingsPremiumFeatureWeaponsDetailed => _pick(
        fr: 'âœ“ Armes illimitÃ©es (actuellement limitÃ© Ã  1)',
        en: 'âœ“ Unlimited weapons (currently limited to 1)',
        de: 'âœ“ Unbegrenzte Waffen (derzeit auf 1 begrenzt)',
        it: 'âœ“ Armi illimitate (attualmente limitate a 1)',
        es: 'âœ“ Armas ilimitadas (actualmente limitado a 1)',
      );

  String get settingsPremiumFeatureAmmosDetailed => _pick(
        fr: 'âœ“ Munitions illimitÃ©es (actuellement limitÃ© Ã  1)',
        en: 'âœ“ Unlimited ammo (currently limited to 1)',
        de: 'âœ“ Unbegrenzte Munition (derzeit auf 1 begrenzt)',
        it: 'âœ“ Munizioni illimitate (attualmente limitate a 1)',
        es: 'âœ“ MuniciÃ³n ilimitada (actualmente limitada a 1)',
      );

  String get settingsPremiumFeatureSessionsDetailed => _pick(
        fr: 'âœ“ SÃ©ances illimitÃ©es (actuellement limitÃ© Ã  5)',
        en: 'âœ“ Unlimited sessions (currently limited to 5)',
        de: 'âœ“ Unbegrenzte Sitzungen (derzeit auf 5 begrenzt)',
        it: 'âœ“ Sessioni illimitate (attualmente limitate a 5)',
        es: 'âœ“ Sesiones ilimitadas (actualmente limitadas a 5)',
      );

  String get settingsPremiumFeatureSecurityDetailed => _pick(
        fr: 'âœ“ Protection locale renforcÃ©e',
        en: 'âœ“ Enhanced local protection',
        de: 'âœ“ VerstÃ¤rkter lokaler Schutz',
        it: 'âœ“ Protezione locale avanzata',
        es: 'âœ“ ProtecciÃ³n local reforzada',
      );

  String get settingsPremiumFeatureBackupExport => _pick(
        fr: 'âœ“ Export de sauvegarde chiffrÃ©',
        en: 'âœ“ Encrypted backup export',
        de: 'âœ“ VerschlÃ¼sselter Backup-Export',
        it: 'âœ“ Esportazione backup crittografata',
        es: 'âœ“ ExportaciÃ³n de copia cifrada',
      );

  String get settingsPremiumFeatureBackupRestore => _pick(
        fr: 'âœ“ Restauration depuis fichier de sauvegarde',
        en: 'âœ“ Restore from backup file',
        de: 'âœ“ Wiederherstellung aus Sicherungsdatei',
        it: 'âœ“ Ripristino da file di backup',
        es: 'âœ“ RestauraciÃ³n desde archivo de copia',
      );

  String get settingsPremiumFeatureAdvancedExports => _pick(
        fr: 'âœ“ Exports avancÃ©s (PDF, CSV)',
        en: 'âœ“ Advanced exports (PDF, CSV)',
        de: 'âœ“ Erweiterte Exporte (PDF, CSV)',
        it: 'âœ“ Esportazioni avanzate (PDF, CSV)',
        es: 'âœ“ Exportaciones avanzadas (PDF, CSV)',
      );

  String get settingsPremiumPerMonthSuffix => _pick(
        fr: ' / mois',
        en: ' / month',
        de: ' / Monat',
        it: ' / mese',
        es: ' / mes',
      );

  String get settingsPremiumSecurePaymentPending => _pick(
        fr: "ðŸ”’ Paiement sÃ©curisÃ© (non connectÃ© pour l'instant)",
        en: 'ðŸ”’ Secure payment (not connected yet)',
        de: 'ðŸ”’ Sichere Zahlung (noch nicht verbunden)',
        it: 'ðŸ”’ Pagamento sicuro (non ancora collegato)',
        es: 'ðŸ”’ Pago seguro (aÃºn no conectado)',
      );

  String get settingsPremiumLater => _pick(
        fr: 'Plus tard',
        en: 'Later',
        de: 'SpÃ¤ter',
        it: 'PiÃ¹ tardi',
        es: 'MÃ¡s tarde',
      );

  String get settingsPremiumDemoActivated => _pick(
        fr: 'Paiement non encore connectÃ©. Version complÃ¨te activÃ©e pour dÃ©mo.',
        en: 'Payment not connected yet. Full version enabled for demo.',
        de: 'Zahlung noch nicht verbunden. Vollversion fÃ¼r Demo aktiviert.',
        it: 'Pagamento non ancora collegato. Versione completa attivata per demo.',
        es: 'Pago aÃºn no conectado. VersiÃ³n completa activada para demostraciÃ³n.',
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
        de: 'Dokument kann nicht geÃ¶ffnet werden',
        it: 'Impossibile aprire il documento',
        es: 'No se puede abrir el documento',
      );

  String get settingsDeleteDocumentTitle => _pick(
        fr: 'Supprimer le document',
        en: 'Delete document',
        de: 'Dokument lÃ¶schen',
        it: 'Elimina documento',
        es: 'Eliminar documento',
      );

  String settingsDeleteDocumentMessage(String name) => _pick(
        fr: 'Voulez-vous vraiment supprimer "$name" ?',
        en: 'Do you really want to delete "$name"?',
        de: 'MÃ¶chten Sie "$name" wirklich lÃ¶schen?',
        it: 'Vuoi davvero eliminare "$name"?',
        es: 'Â¿Realmente quieres eliminar "$name"?',
      );

  String get settingsDeleteAllDataLabel => _pick(
        fr: 'Supprimer toutes les donnÃ©es locales',
        en: 'Delete all local data',
        de: 'Alle lokalen Daten lÃ¶schen',
        it: 'Elimina tutti i dati locali',
        es: 'Eliminar todos los datos locales',
      );

  String get settingsDeleteAllDataSubtitle => _pick(
        fr: 'Efface profil, inventaire, sÃ©ances, diagnostiques et documents stockÃ©s sur cet appareil',
        en: 'Erase profile, inventory, sessions, diagnostics, and documents stored on this device',
        de: 'LÃ¶scht Profil, Inventar, Sitzungen, Diagnosen und auf diesem GerÃ¤t gespeicherte Dokumente',
        it: 'Cancella profilo, inventario, sessioni, diagnostica e documenti memorizzati su questo dispositivo',
        es: 'Borra el perfil, inventario, sesiones, diagnÃ³sticos y documentos almacenados en este dispositivo',
      );

  String get settingsDeleteAllDataTitle => _pick(
        fr: 'Supprimer toutes les donnÃ©es locales',
        en: 'Delete all local data',
        de: 'Alle lokalen Daten lÃ¶schen',
        it: 'Elimina tutti i dati locali',
        es: 'Eliminar todos los datos locales',
      );

  String get settingsDeleteAllDataMessage => _pick(
        fr: 'Cette action supprime de cet appareil votre profil, inventaire, sÃ©ances, diagnostiques et documents ajoutÃ©s dans lâ€™application. Cette action est irrÃ©versible.',
        en: 'This action removes from this device your profile, inventory, sessions, diagnostics, and documents added in the app. This action cannot be undone.',
        de: 'Diese Aktion entfernt von diesem GerÃ¤t Ihr Profil, Inventar, Sitzungen, Diagnosen und in der App hinzugefÃ¼gte Dokumente. Diese Aktion kann nicht rÃ¼ckgÃ¤ngig gemacht werden.',
        it: 'Questa azione rimuove da questo dispositivo il tuo profilo, inventario, sessioni, diagnostica e documenti aggiunti nellâ€™app. Questa azione non puÃ² essere annullata.',
        es: 'Esta acciÃ³n elimina de este dispositivo tu perfil, inventario, sesiones, diagnÃ³sticos y documentos aÃ±adidos en la aplicaciÃ³n. Esta acciÃ³n no se puede deshacer.',
      );

  String get settingsDeleteAllDataConfirm => _pick(
        fr: 'Tout supprimer',
        en: 'Delete everything',
        de: 'Alles lÃ¶schen',
        it: 'Elimina tutto',
        es: 'Eliminar todo',
      );

  String get settingsDeleteAllDataSuccess => _pick(
        fr: 'Toutes les donnÃ©es locales ont Ã©tÃ© supprimÃ©es',
        en: 'All local data has been deleted',
        de: 'Alle lokalen Daten wurden gelÃ¶scht',
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
        fr: 'Jour Mois AnnÃ©e',
        en: 'Day Month Year',
        de: 'Tag Monat Jahr',
        it: 'Giorno Mese Anno',
        es: 'DÃ­a Mes AÃ±o',
      );

  String get dateFormatMonthDayYear => _pick(
        fr: 'Mois Jour AnnÃ©e',
        en: 'Month Day Year',
        de: 'Monat Tag Jahr',
        it: 'Mese Giorno Anno',
        es: 'Mes DÃ­a AÃ±o',
      );

  String get settingsAnonymousUserUpper => _pick(
        fr: 'Utilisateur Anonyme',
        en: 'Anonymous User',
        de: 'Anonymer Benutzer',
        it: 'Utente anonimo',
        es: 'Usuario anÃ³nimo',
      );

  String get settingsAnonymousUser => _pick(
        fr: 'Utilisateur anonyme',
        en: 'Anonymous user',
        de: 'Anonymer Benutzer',
        it: 'Utente anonimo',
        es: 'Usuario anÃ³nimo',
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
        fr: 'Passer Ã  Pro',
        en: 'Upgrade to Pro',
        de: 'Zu Pro wechseln',
        it: 'Passa a Pro',
        es: 'Pasar a Pro',
      );

  String get settingsUpgradeToProSubtitle => _pick(
        fr: 'Tout dÃ©bloquÃ©',
        en: 'Everything unlocked',
        de: 'Alles freigeschaltet',
        it: 'Tutto sbloccato',
        es: 'Todo desbloqueado',
      );

  String get settingsLicenseNotProvided => _pick(
        fr: 'Licence non renseignÃ©e',
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
        fr: 'Ã‰quipement utilisÃ©',
        en: 'Equipment used',
        de: 'Verwendete AusrÃ¼stung',
        it: 'Attrezzatura usata',
        es: 'Equipo usado',
      );

  String get usedTargetLabel => _pick(
        fr: 'Cible utilisÃ©e',
        en: 'Target used',
        de: 'Verwendete Zielscheibe',
        it: 'Bersaglio utilizzato',
        es: 'Blanco utilizado',
      );

  String get noEquipmentSelected => _pick(
        fr: 'Aucun Ã©quipement sÃ©lectionnÃ©',
        en: 'No equipment selected',
        de: 'Keine AusrÃ¼stung ausgewÃ¤hlt',
        it: 'Nessuna attrezzatura selezionata',
        es: 'NingÃºn equipo seleccionado',
      );

  String selectedEquipmentCount(int count) => _pick(
        fr: '$count Ã©quipement(s) sÃ©lectionnÃ©(s)',
        en: '$count equipment item(s) selected',
        de: '$count AusrÃ¼stungsteil(e) ausgewÃ¤hlt',
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
        de: 'FÃ¼ge ein oder mehrere Fotos der Zielscheibe hinzu',
        it: 'Aggiungi una o piÃ¹ foto del bersaglio',
        es: 'Agrega una o mÃ¡s fotos del blanco',
      );

  String get photoNameLabel => _pick(
        fr: 'Nom de la photo',
        en: 'Photo name',
        de: 'Fotobezeichnung',
        it: 'Nome foto',
        es: 'Nombre de la foto',
      );

  String get sessionNotFoundTitle => _pick(
        fr: 'SÃ©ance introuvable',
        en: 'Session not found',
        de: 'Sitzung nicht gefunden',
        it: 'Sessione non trovata',
        es: 'SesiÃ³n no encontrada',
      );

  String get sessionNotFoundNoId => _pick(
        fr: 'Aucun identifiant de sÃ©ance fourni',
        en: 'No session ID provided',
        de: 'Keine Sitzungs-ID angegeben',
        it: 'Nessun ID sessione fornito',
        es: 'No se proporcionÃ³ ID de sesiÃ³n',
      );

  String sessionNotFoundId(String id) => _pick(
        fr: 'ID: $id',
        en: 'ID: $id',
        de: 'ID: $id',
        it: 'ID: $id',
        es: 'ID: $id',
      );

  String get sessionOpenFailedTitle => _pick(
        fr: "Impossible d'ouvrir cette sÃ©ance",
        en: 'Unable to open this session',
        de: 'Diese Sitzung kann nicht geÃ¶ffnet werden',
        it: 'Impossibile aprire questa sessione',
        es: 'No se puede abrir esta sesiÃ³n',
      );

  String get sessionOpenFailedSubtitle => _pick(
        fr: 'Revenez en arriÃ¨re et rÃ©essayez.',
        en: 'Go back and try again.',
        de: 'Gehe zurÃ¼ck und versuche es erneut.',
        it: 'Torna indietro e riprova.',
        es: 'Vuelve atrÃ¡s e intÃ©ntalo de nuevo.',
      );

  String get weatherTitleShort => _pick(
        fr: 'MÃ©tÃ©o',
        en: 'Weather',
        de: 'Wetter',
        it: 'Meteo',
        es: 'Clima',
      );

  String get noExerciseForSession => _pick(
        fr: 'Aucun exercice enregistrÃ© pour cette sÃ©ance',
        en: 'No exercise recorded for this session',
        de: 'Keine Ãœbung fÃ¼r diese Sitzung aufgezeichnet',
        it: 'Nessun esercizio registrato per questa sessione',
        es: 'No hay ejercicios registrados para esta sesiÃ³n',
      );

  String get observationsTitle => _pick(
        fr: 'Observations',
        en: 'Notes',
        de: 'Notizen',
        it: 'Osservazioni',
        es: 'Observaciones',
      );

  String get observationsExample => _pick(
        fr: 'Ex: LÃ©gÃ¨re tendance Ã  droite...',
        en: 'Ex: Slight tendency to the right...',
        de: 'Bsp.: Leichte Tendenz nach rechts...',
        it: 'Es: Leggera tendenza a destra...',
        es: 'Ej: Ligera tendencia a la derecha...',
      );

  String get progressionPrecisionTitle => _pick(
        fr: 'Progression (prÃ©cision)',
        en: 'Progress (precision)',
        de: 'Verlauf (PrÃ¤zision)',
        it: 'Progressi (precisione)',
        es: 'Progreso (precisiÃ³n)',
      );

  String get statsShotsLabelUpper => _pick(
        fr: 'COUPS',
        en: 'SHOTS',
        de: 'SCHÃœSSE',
        it: 'COLPI',
        es: 'DISPAROS',
      );

  String get statsAvgPrecisionLabelUpper => _pick(
        fr: 'PRÃ‰CISION MOY.',
        en: 'AVG PREC.',
        de: 'Ã˜ PRÃ„Z.',
        it: 'PREC. MED.',
        es: 'PREC. PROM.',
      );

  String get statsExercisesLabelUpper => _pick(
        fr: 'EXERCICES',
        en: 'EXERCISES',
        de: 'ÃœBUNGEN',
        it: 'ESERCIZI',
        es: 'EJERCICIOS',
      );

  String get noWeaponInStockSwitchBorrowed => _pick(
        fr: 'Aucune arme dans le stock. Passe en â€œPrÃªtÃ©eâ€.',
        en: 'No weapon in inventory. Switch to â€œBorrowedâ€.',
        de: 'Keine Waffe im Bestand. Wechsle zu â€žGeliehenâ€œ.',
        it: 'Nessuna arma in inventario. Passa a â€œPrestataâ€.',
        es: 'No hay ninguna arma en el inventario. Cambia a â€œPrestadaâ€.',
      );

  String get noAmmoInStockSwitchBorrowed => _pick(
        fr: 'Aucune munition dans le stock. Passe en â€œPrÃªtÃ©eâ€.',
        en: 'No ammo in inventory. Switch to â€œBorrowedâ€.',
        de: 'Keine Munition im Bestand. Wechsle zu â€žGeliehenâ€œ.',
        it: 'Nessuna munizione in inventario. Passa a â€œPrestataâ€.',
        es: 'No hay municiÃ³n en el inventario. Cambia a â€œPrestadaâ€.',
      );

  String get myInventory => _pick(
        fr: 'Mon stock',
        en: 'My inventory',
        de: 'Mein Bestand',
        it: 'Il mio inventario',
        es: 'Mi inventario',
      );

  String get borrowed => _pick(
        fr: 'PrÃªtÃ©e',
        en: 'Borrowed',
        de: 'Geliehen',
        it: 'Prestata',
        es: 'Prestada',
      );

  String get borrowedWeaponOptional => _pick(
        fr: 'Arme prÃªtÃ©e (dÃ©tail optionnel)',
        en: 'Borrowed weapon (optional details)',
        de: 'Geliehene Waffe (optional)',
        it: 'Arma prestata (dettagli opzionali)',
        es: 'Arma prestada (detalles opcionales)',
      );

  String get borrowedWeaponHint => _pick(
        fr: 'Ex: Glock 17, clubâ€¦',
        en: 'Ex: Glock 17, clubâ€¦',
        de: 'Bsp.: Glock 17, Vereinâ€¦',
        it: 'Es: Glock 17, clubâ€¦',
        es: 'Ej: Glock 17, clubâ€¦',
      );

  String get borrowedAmmoOptional => _pick(
        fr: 'Munition prÃªtÃ©e (dÃ©tail optionnel)',
        en: 'Borrowed ammo (optional details)',
        de: 'Geliehene Munition (optional)',
        it: 'Munizione prestata (dettagli opzionali)',
        es: 'MuniciÃ³n prestada (detalles opcionales)',
      );

  String get borrowedAmmoHint => _pick(
        fr: 'Ex: 9Ã—19 FMJ, rechargÃ©eâ€¦',
        en: 'Ex: 9Ã—19 FMJ, reloadedâ€¦',
        de: 'Bsp.: 9Ã—19 FMJ, wiedergeladenâ€¦',
        it: 'Es: 9Ã—19 FMJ, ricaricataâ€¦',
        es: 'Ej: 9Ã—19 FMJ, recargadaâ€¦',
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
        es: 'MuniciÃ³n',
      );

  String get chooseWeaponFromInventory => _pick(
        fr: 'Choisir une arme dans ton stock',
        en: 'Choose a weapon from your inventory',
        de: 'WÃ¤hle eine Waffe aus deinem Bestand',
        it: 'Scegli un\'arma dal tuo inventario',
        es: 'Elige un arma de tu inventario',
      );

  String get chooseAmmoFromInventory => _pick(
        fr: 'Choisir une munition dans ton stock',
        en: 'Choose ammo from your inventory',
        de: 'WÃ¤hle eine Munition aus deinem Bestand',
        it: 'Scegli una munizione dal tuo inventario',
        es: 'Elige municiÃ³n de tu inventario',
      );

  String get tapToChange => _pick(
        fr: 'Appuie pour changer',
        en: 'Tap to change',
        de: 'Tippe zum Ã„ndern',
        it: 'Tocca per cambiare',
        es: 'Toca para cambiar',
      );

  String get addExerciseTitle => _pick(
        fr: 'Ajouter un exercice',
        en: 'Add an exercise',
        de: 'Ãœbung hinzufÃ¼gen',
        it: 'Aggiungi un esercizio',
        es: 'Agregar un ejercicio',
      );

  String get measurePrecisionTitle => _pick(
        fr: 'Mesurer la prÃ©cision',
        en: 'Measure precision',
        de: 'PrÃ¤zision messen',
        it: 'Misura la precisione',
        es: 'Medir la precisiÃ³n',
      );

  String precisionValueLabel(String value) => _pick(
        fr: 'PrÃ©cision: $value',
        en: 'Precision: $value',
        de: 'PrÃ¤zision: $value',
        it: 'Precisione: $value',
        es: 'PrecisiÃ³n: $value',
      );

  String get saveAsTemplateButton => _pick(
    fr: 'Enregistrer comme modÃ¨le',
    en: 'Save as template',
    de: 'Als Vorlage speichern',
    it: 'Salva come modello',
    es: 'Guardar como plantilla',
  );

  String get templateNameDialogTitle => _pick(
    fr: 'Nom du modÃ¨le',
    en: 'Template name',
    de: 'Vorlagenname',
    it: 'Nome modello',
    es: 'Nombre de la plantilla',
  );

  String get templateNameHint => _pick(
    fr: 'Ex : Tir de prÃ©cision 25m',
    en: 'E.g. Precision drill 25m',
    de: 'Z.B. PrÃ¤zisionsÃ¼bung 25m',
    it: 'Es: Tiro di precisione 25m',
    es: 'Ej: Tiro de precisiÃ³n 25m',
  );

  String get templateSavedSnack => _pick(
    fr: 'ModÃ¨le enregistrÃ©',
    en: 'Template saved',
    de: 'Vorlage gespeichert',
    it: 'Modello salvato',
    es: 'Plantilla guardada',
  );

  String get createExerciseButton => _pick(
    fr: '+ CrÃ©er',
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
    fr: 'Importer un modÃ¨le',
    en: 'Import a template',
    de: 'Vorlage importieren',
    it: 'Importa un modello',
    es: 'Importar una plantilla',
  );

  String get noTemplatesAvailable => _pick(
    fr: 'Aucun modÃ¨le enregistrÃ©',
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
    fr: 'Supprimer ce modÃ¨le ?',
    en: 'Delete this template?',
    de: 'Diese Vorlage lÃ¶schen?',
    it: 'Eliminare questo modello?',
    es: 'Â¿Eliminar esta plantilla?',
  );

  String get offlineWeatherUnavailable => _pick(
    fr: 'Hors ligne â€” mÃ©tÃ©o indisponible.',
    en: 'Offline â€” weather unavailable.',
    de: 'Offline â€” Wetter nicht verfÃ¼gbar.',
    it: 'Offline â€” meteo non disponibile.',
    es: 'Sin conexiÃ³n â€” clima no disponible.',
  );

  String get offlineLocationUnavailable => _pick(
    fr: 'Hors ligne â€” gÃ©olocalisation indisponible.',
    en: 'Offline â€” geolocation unavailable.',
    de: 'Offline â€” Geolokalisierung nicht verfÃ¼gbar.',
    it: 'Offline â€” geolocalizzazione non disponibile.',
    es: 'Sin conexiÃ³n â€” geolocalizaciÃ³n no disponible.',
  );

  String get offlineBadgeLabel => _pick(
    fr: 'HORS LIGNE',
    en: 'OFFLINE',
    de: 'OFFLINE',
    it: 'OFFLINE',
    es: 'SIN CONEXIÃ“N',
  );

  String get saveExerciseButton => _pick(
        fr: "ENREGISTRER L'EXERCICE",
        en: 'SAVE EXERCISE',
        de: 'ÃœBUNG SPEICHERN',
        it: 'SALVA ESERCIZIO',
        es: 'GUARDAR EJERCICIO',
      );

  String get sessionLabelShots => _pick(
        fr: 'Coups',
        en: 'Shots',
        de: 'SchÃ¼sse',
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
        de: 'LÃ¶schen bestÃ¤tigen',
        it: 'Conferma eliminazione',
        es: 'Confirmar eliminaciÃ³n',
      );

  String confirmDeleteSessionMessage(String sessionName) => _pick(
        fr: 'Voulez-vous vraiment supprimer la sÃ©ance "$sessionName" ?',
        en: 'Do you really want to delete the session "$sessionName"?',
        de: 'MÃ¶chtest du die Sitzung "$sessionName" wirklich lÃ¶schen?',
        it: 'Vuoi davvero eliminare la sessione "$sessionName"?',
        es: 'Â¿Quieres eliminar la sesiÃ³n "$sessionName"?',
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
        fr: '"$sessionName" supprimÃ©e',
        en: '"$sessionName" deleted',
        de: '"$sessionName" gelÃ¶scht',
        it: '"$sessionName" eliminata',
        es: '"$sessionName" eliminada',
      );

  String get sessionShareSubjectPrefix => _pick(
        fr: 'SÃ©ance de tir - ',
        en: 'Shooting session - ',
        de: 'SchieÃŸsitzung - ',
        it: 'Sessione di tiro - ',
        es: 'SesiÃ³n de tiro - ',
      );

  String get exportSessionTitle => _pick(
        fr: 'Exporter la sÃ©ance',
        en: 'Export session',
        de: 'Sitzung exportieren',
        it: 'Esporta sessione',
        es: 'Exportar sesiÃ³n',
      );

  String get exportSessionSubtitle => _pick(
        fr: 'RÃ©sumÃ© texte prÃªt Ã  copier / enregistrer.',
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
        fr: 'RÃ©sumÃ© copiÃ©.',
        en: 'Summary copied.',
        de: 'Zusammenfassung kopiert.',
        it: 'Riepilogo copiato.',
        es: 'Resumen copiado.',
      );

  String get actionDownloadTxt => _pick(
        fr: 'TÃ©lÃ©charger .txt',
        en: 'Download .txt',
        de: '.txt herunterladen',
        it: 'Scarica .txt',
        es: 'Descargar .txt',
      );

  String get downloadFailedSnack => _pick(
        fr: 'Impossible de tÃ©lÃ©charger le fichier.',
        en: 'Unable to download the file.',
        de: 'Datei konnte nicht heruntergeladen werden.',
        it: 'Impossibile scaricare il file.',
        es: 'No se pudo descargar el archivo.',
      );

  String get shareUnavailableSnack => _pick(
        fr: 'Partage indisponible sur cet appareil.',
        en: 'Sharing is unavailable on this device.',
        de: 'Teilen ist auf diesem GerÃ¤t nicht verfÃ¼gbar.',
        it: 'Condivisione non disponibile su questo dispositivo.',
        es: 'Compartir no estÃ¡ disponible en este dispositivo.',
      );

  String get actionClose => _pick(
        fr: 'Fermer',
        en: 'Close',
        de: 'SchlieÃŸen',
        it: 'Chiudi',
        es: 'Cerrar',
      );

  // --- PIN Screen ---
  
  String get configurePinCode => _pick(
        fr: 'Configurer le code PIN',
        en: 'Configure PIN code',
        de: 'PIN-Code konfigurieren',
        it: 'Configura codice PIN',
        es: 'Configurar cÃ³digo PIN',
      );

  String get choosePin => _pick(
        fr: 'Choisissez un code PIN',
        en: 'Choose a PIN code',
        de: 'WÃ¤hlen Sie einen PIN-Code',
        it: 'Scegli un codice PIN',
        es: 'Elige un cÃ³digo PIN',
      );

  String get confirmPin => _pick(
        fr: 'Confirmez votre code PIN',
        en: 'Confirm your PIN code',
        de: 'BestÃ¤tigen Sie Ihren PIN-Code',
        it: 'Conferma il tuo codice PIN',
        es: 'Confirma tu cÃ³digo PIN',
      );

  String get pin6Digits => _pick(
        fr: 'Code Ã  6 chiffres',
        en: '6-digit code',
        de: '6-stelliger Code',
        it: 'Codice a 6 cifre',
        es: 'CÃ³digo de 6 dÃ­gitos',
      );

  String get pinsDoNotMatch => _pick(
        fr: 'Les codes ne correspondent pas',
        en: 'PINs do not match',
        de: 'PINs stimmen nicht Ã¼berein',
        it: 'I PIN non corrispondono',
        es: 'Los PIN no coinciden',
      );

  String get pinSetSuccess => _pick(
        fr: 'Code PIN configurÃ© avec succÃ¨s',
        en: 'PIN code configured successfully',
        de: 'PIN-Code erfolgreich konfiguriert',
        it: 'Codice PIN configurato con successo',
        es: 'CÃ³digo PIN configurado correctamente',
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
        fr: 'Limite atteinte ($current/$max). Passez Ã  Premium pour ajouter des $itemLabel illimitÃ©es.',
        en: 'Limit reached ($current/$max). Upgrade to Premium to add unlimited $itemLabel.',
        de: 'Limit erreicht ($current/$max). Upgrade auf Premium, um unbegrenzte $itemLabel hinzuzufÃ¼gen.',
        it: 'Limite raggiunto ($current/$max). Passa a Premium per aggiungere $itemLabel illimitati.',
        es: 'LÃ­mite alcanzado ($current/$max). Pasa a Premium para aÃ±adir $itemLabel ilimitados.',
      );

  String get restock => _pick(
        fr: 'RecomplÃ©ter le stock',
        en: 'Restock',
        de: 'Bestand auffÃ¼llen',
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
        fr: 'QuantitÃ© Ã  ajouter',
        en: 'Quantity to add',
        de: 'Menge hinzufÃ¼gen',
        it: 'QuantitÃ  da aggiungere',
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
        fr: 'Entre une quantitÃ© valide (> 0).',
        en: 'Enter a valid quantity (> 0).',
        de: 'GÃ¼ltige Menge eingeben (> 0).',
        it: 'Inserisci una quantitÃ  valida (> 0).',
        es: 'Ingresa una cantidad vÃ¡lida (> 0).',
      );

  String get stockUpdated => _pick(
        fr: 'Stock mis Ã  jour',
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
        es: 'DIAGNÃ“STICO',
      );

  String get diagnosticNew => _pick(
        fr: 'NOUVEAU DIAGNOSTIQUE',
        en: 'NEW DIAGNOSTIC',
        de: 'NEUE DIAGNOSE',
        it: 'NUOVA DIAGNOSI',
        es: 'NUEVO DIAGNÃ“STICO',
      );

  String get diagnosticEmptyTitle => _pick(
        fr: 'Aucun diagnostique enregistrÃ©',
        en: 'No diagnostic saved',
        de: 'Keine Diagnose gespeichert',
        it: 'Nessuna diagnosi salvata',
        es: 'No hay diagnÃ³sticos guardados',
      );

  String get diagnosticEmptySubtitle => _pick(
        fr: 'Commencez un nouveau diagnostique pour\nidentifier les problÃ¨mes de vos armes',
        en: 'Start a new diagnostic to\nidentify issues with your weapons',
        de: 'Starte eine neue Diagnose, um\nProbleme mit deinen Waffen zu erkennen',
        it: 'Avvia una nuova diagnosi per\nidentificare i problemi delle tue armi',
        es: 'Inicia un nuevo diagnÃ³stico para\nidentificar problemas con tus armas',
      );

  String get diagnosticDeleteTitle => _pick(
        fr: 'Supprimer le diagnostique',
        en: 'Delete diagnostic',
        de: 'Diagnose lÃ¶schen',
        it: 'Elimina diagnosi',
        es: 'Eliminar diagnÃ³stico',
      );

  String get diagnosticDeleteMessage => _pick(
        fr: 'ÃŠtes-vous sÃ»r de vouloir supprimer ce diagnostique ?',
        en: 'Are you sure you want to delete this diagnostic?',
        de: 'MÃ¶chtest du diese Diagnose wirklich lÃ¶schen?',
        it: 'Sei sicuro di voler eliminare questa diagnosi?',
        es: 'Â¿Seguro que quieres eliminar este diagnÃ³stico?',
      );

  String get diagnosticNoSpecificWeapon => _pick(
        fr: 'Diagnostique sans arme spÃ©cifique',
        en: 'Diagnostic without a specific weapon',
        de: 'Diagnose ohne bestimmte Waffe',
        it: 'Diagnosi senza arma specifica',
        es: 'DiagnÃ³stico sin arma especÃ­fica',
      );

  String get unknownWeapon => _pick(
        fr: 'Arme inconnue',
        en: 'Unknown weapon',
        de: 'Unbekannte Waffe',
        it: 'Arma sconosciuta',
        es: 'Arma desconocida',
      );

  String get decisionLabel => _pick(
        fr: 'DÃ‰CISION',
        en: 'DECISION',
        de: 'ENTSCHEIDUNG',
        it: 'DECISIONE',
        es: 'DECISIÃ“N',
      );

  String get summaryLabel => _pick(
        fr: 'RÃ‰SUMÃ‰',
        en: 'SUMMARY',
        de: 'ZUSAMMENFASSUNG',
        it: 'RIEPILOGO',
        es: 'RESUMEN',
      );

  String get previous => _pick(
        fr: 'PRÃ‰CÃ‰DENT',
        en: 'PREVIOUS',
        de: 'ZURÃœCK',
        it: 'PRECEDENTE',
        es: 'ANTERIOR',
      );

  String get yesUpper => _pick(
        fr: 'OUI',
        en: 'YES',
        de: 'JA',
        it: 'SÃŒ',
        es: 'SÃ',
      );

  String get noUpper => _pick(
        fr: 'NON',
        en: 'NO',
        de: 'NEIN',
        it: 'NO',
        es: 'NO',
      );

  String get diagnosticOrSelectWeapon => _pick(
        fr: 'OU SÃ‰LECTIONNEZ UNE ARME',
        en: 'OR SELECT A WEAPON',
        de: 'ODER EINE WAFFE AUSWÃ„HLEN',
        it: 'OPPURE SELEZIONA UN ARMA',
        es: 'O SELECCIONA UN ARMA',
      );

  String get diagnosticNoSpecificWeaponSubtitle => _pick(
        fr: 'Arbre complet - identification de la plateforme',
        en: 'Complete tree - platform identification',
        de: 'VollstÃ¤ndiger Ablauf - Plattformidentifikation',
        it: 'Albero completo - identificazione della piattaforma',
        es: 'Ãrbol completo - identificaciÃ³n de la plataforma',
      );

  String get diagnosticImmediateStopMessage => _pick(
        fr: "ARRÃŠT IMMÃ‰DIAT\n\nProcÃ©dure de sÃ©curisation immÃ©diate requise.\n\nMettez l'arme en direction sÃ»re, doigt hors dÃ©tente, et interrompez toute manipulation.",
        en: 'IMMEDIATE STOP\n\nImmediate safety procedure required.\n\nPoint the weapon in a safe direction, keep your finger off the trigger, and stop all handling.',
        de: 'SOFORT STOPP\n\nSofortige SicherheitsmaÃŸnahme erforderlich.\n\nWaffe in sichere Richtung halten, Finger weg vom Abzug und jede Handhabung stoppen.',
        it: "STOP IMMEDIATO\n\nÃˆ richiesta una procedura di sicurezza immediata.\n\nPunta l'arma in una direzione sicura, tieni il dito fuori dal grilletto e interrompi ogni manipolazione.",
        es: 'PARADA INMEDIATA\n\nSe requiere un procedimiento de seguridad inmediato.\n\nApunta el arma en una direcciÃ³n segura, mantÃ©n el dedo fuera del gatillo y detÃ©n cualquier manipulaciÃ³n.',
      );

  String get diagnosticUnknownStateMessage => _pick(
        fr: "ARRÃŠT - Ã‰TAT INCONNU\n\nConsidÃ©rez l'arme comme chargÃ©e et interrompez immÃ©diatement toute manipulation jusqu'Ã  identification claire de l'Ã©tat.",
        en: 'STOP - UNKNOWN STATE\n\nTreat the weapon as loaded and stop all handling immediately until its state is clearly identified.',
        de: 'STOPP - UNBEKANNTER ZUSTAND\n\nBehandle die Waffe als geladen und stoppe jede Handhabung sofort, bis der Zustand eindeutig festgestellt ist.',
        it: "STOP - STATO SCONOSCIUTO\n\nConsidera l'arma carica e interrompi immediatamente ogni manipolazione finchÃ© lo stato non Ã¨ chiaramente identificato.",
        es: 'PARADA - ESTADO DESCONOCIDO\n\nConsidera el arma cargada e interrumpe inmediatamente cualquier manipulaciÃ³n hasta identificar claramente su estado.',
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
        es: 'INMOVILIZACIÃ“N DEL ARMA',
      );

  String get immobilizeWeaponMessage => _pick(
        fr: "Risque Ã©levÃ©.\n\nImmobilisez l'arme et faites contrÃ´ler par un armurier qualifiÃ© avant toute rÃ©utilisation.",
        en: 'High risk.\n\nTake the weapon out of service and have it checked by a qualified gunsmith before any further use.',
        de: 'Hohes Risiko.\n\nWaffe stilllegen und vor weiterer Nutzung von einem qualifizierten BÃ¼chsenmacher prÃ¼fen lassen.',
        it: "Rischio elevato.\n\nImmobilizza l'arma e falla controllare da un armaiolo qualificato prima di riutilizzarla.",
        es: 'Riesgo elevado.\n\nInmoviliza el arma y hazla revisar por un armero cualificado antes de volver a usarla.',
      );

  String get saveDiagnosticUpper => _pick(
        fr: 'ENREGISTRER LE DIAGNOSTIQUE',
        en: 'SAVE DIAGNOSTIC',
        de: 'DIAGNOSE SPEICHERN',
        it: 'SALVA DIAGNOSI',
        es: 'GUARDAR DIAGNÃ“STICO',
      );

  String get diagnosticCompletedTitle => _pick(
        fr: 'DIAGNOSTIQUE TERMINÃ‰',
        en: 'DIAGNOSTIC COMPLETED',
        de: 'DIAGNOSE ABGESCHLOSSEN',
        it: 'DIAGNOSI COMPLETATA',
        es: 'DIAGNÃ“STICO COMPLETADO',
      );

  String get finalDecisionLabel => _pick(
        fr: 'DÃ‰CISION FINALE',
        en: 'FINAL DECISION',
        de: 'ENDGÃœLTIGE ENTSCHEIDUNG',
        it: 'DECISIONE FINALE',
        es: 'DECISIÃ“N FINAL',
      );

  String get probableCausesLabel => _pick(
        fr: 'CAUSES PROBABLES',
        en: 'PROBABLE CAUSES',
        de: 'WAHRSCHEINLICHE URSACHEN',
        it: 'CAUSE PROBABILI',
        es: 'CAUSAS PROBABLES',
      );

  String get recommendedActionLabel => _pick(
        fr: 'CONDUITE Ã€ TENIR',
        en: 'RECOMMENDED ACTION',
        de: 'EMPFOHLENES VORGEHEN',
        it: 'AZIONE CONSIGLIATA',
        es: 'CONDUCTA RECOMENDADA',
      );

  String get diagnosticWeaponSelectionTitle => _pick(
        fr: 'Voulez-vous diagnostiquer une arme spÃ©cifique de votre inventaire ?',
        en: 'Do you want to diagnose a specific weapon from your inventory?',
        de: 'MÃ¶chtest du eine bestimmte Waffe aus deinem Bestand diagnostizieren?',
        it: 'Vuoi diagnosticare unâ€™arma specifica del tuo inventario?',
        es: 'Â¿Quieres diagnosticar un arma especÃ­fica de tu inventario?',
      );

  String get diagnosticSafetyPhase => _pick(
        fr: 'PHASE DE SÃ‰CURISATION IMMÃ‰DIATE',
        en: 'IMMEDIATE SAFETY PHASE',
        de: 'SOFORTIGE SICHERHEITSPHASE',
        it: 'FASE DI SICUREZZA IMMEDIATA',
        es: 'FASE DE SEGURIDAD INMEDIATA',
      );

  String get diagnosticQuestion1 => _pick(
        fr: "L'arme est-elle immÃ©diatement mise en direction sÃ»re (safe direction) et doigt hors dÃ©tente ?",
        en: 'Is the weapon immediately pointed in a safe direction and the finger off the trigger?',
        de: 'Wird die Waffe sofort in sichere Richtung gehalten und der Finger vom Abzug genommen?',
        it: 'Lâ€™arma Ã¨ immediatamente puntata in una direzione sicura e il dito Ã¨ fuori dal grilletto?',
        es: 'Â¿Se apunta inmediatamente el arma en una direcciÃ³n segura y el dedo estÃ¡ fuera del gatillo?',
      );

  String get diagnosticQuestion2 => _pick(
        fr: "Le tir a-t-il Ã©tÃ© interrompu immÃ©diatement aprÃ¨s l'anomalie ?",
        en: 'Was firing stopped immediately after the anomaly?',
        de: 'Wurde das SchieÃŸen unmittelbar nach der StÃ¶rung unterbrochen?',
        it: 'Il tiro Ã¨ stato interrotto immediatamente dopo lâ€™anomalia?',
        es: 'Â¿Se interrumpiÃ³ el disparo inmediatamente despuÃ©s de la anomalÃ­a?',
      );

  String get diagnosticQuestion3 => _pick(
        fr: "L'Ã©tat de l'arme est-il clairement identifiÃ© ?",
        en: 'Is the state of the weapon clearly identified?',
        de: 'Ist der Zustand der Waffe eindeutig festgestellt?',
        it: 'Lo stato dellâ€™arma Ã¨ chiaramente identificato?',
        es: 'Â¿EstÃ¡ claramente identificado el estado del arma?',
      );

  String get diagnosticWeaponPossiblyLoaded => _pick(
        fr: 'Arme potentiellement chargÃ©e',
        en: 'Weapon potentially loaded',
        de: 'Waffe mÃ¶glicherweise geladen',
        it: 'Arma potenzialmente carica',
        es: 'Arma potencialmente cargada',
      );

  String get diagnosticWeaponOpenedSafe => _pick(
        fr: 'Arme ouverte / neutralisÃ©e',
        en: 'Weapon open / neutralized',
        de: 'Waffe geÃ¶ffnet / gesichert',
        it: 'Arma aperta / neutralizzata',
        es: 'Arma abierta / neutralizada',
      );

  String get diagnosticUnknownState => _pick(
        fr: 'Ã‰tat inconnu',
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
        es: 'CLASIFICACIÃ“N',
      );

  String get diagnosticQuestion4 => _pick(
        fr: 'Quel est le problÃ¨me principal observÃ© ?',
        en: 'What is the main observed problem?',
        de: 'Was ist das hauptsÃ¤chlich beobachtete Problem?',
        it: 'Qual Ã¨ il problema principale osservato?',
        es: 'Â¿CuÃ¡l es el principal problema observado?',
      );

  String get diagnosticIncidentNoFire => _pick(
        fr: 'Non-tir (clic / pas de dÃ©part)',
        en: 'Misfire (click / no shot)',
        de: 'FehlzÃ¼ndung (Klick / kein Schuss)',
        it: 'Mancato sparo (clic / nessun colpo)',
        es: 'Fallo de disparo (clic / no sale el tiro)',
      );

  String get diagnosticIncidentHangfire => _pick(
        fr: 'Long feu (dÃ©part retardÃ© / doute)',
        en: 'Hangfire (delayed shot / doubt)',
        de: 'Hangfire (verzÃ¶gerter Schuss / Zweifel)',
        it: 'Fuoco ritardato (colpo ritardato / dubbio)',
        es: 'Fuego retardado (disparo tardÃ­o / duda)',
      );

  String get diagnosticIncidentUnintendedDischarge => _pick(
        fr: 'DÃ©part intempestif',
        en: 'Unintended discharge',
        de: 'Unbeabsichtigte Schussabgabe',
        it: 'Partenza intempestiva',
        es: 'Disparo intempestivo',
      );

  String get diagnosticIncidentJam => _pick(
        fr: "Enrayage / incident d'alimentation",
        en: 'Jam / feeding incident',
        de: 'StÃ¶rung / ZufÃ¼hrungsproblem',
        it: 'Inceppamento / problema di alimentazione',
        es: 'Atasco / fallo de alimentaciÃ³n',
      );

  String get diagnosticIncidentAccuracyDrop => _pick(
        fr: 'Baisse de prÃ©cision',
        en: 'Accuracy drop',
        de: 'PrÃ¤zisionsverlust',
        it: 'Calo di precisione',
        es: 'Bajada de precisiÃ³n',
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
        fr: 'HypothÃ¨se',
        en: 'Hypothesis',
        de: 'Hypothese',
        it: 'Ipotesi',
        es: 'HipÃ³tesis',
      );

  String get exercisesLabel => _pick(
        fr: 'Exercices',
        en: 'Exercises',
        de: 'Ãœbungen',
        it: 'Esercizi',
        es: 'Ejercicios',
      );

  String get newAmmoTitle => _pick(
        fr: 'NOUVELLE MUNITION',
        en: 'NEW AMMO',
        de: 'NEUE MUNITION',
        it: 'NUOVE MUNIZIONI',
        es: 'NUEVA MUNICIÃ“N',
      );

  String get designationRegisterLabel => _pick(
fr: 'Nom personnalisÃ©',
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
        fr: 'QUANTITÃ‰ INITIALE',
        en: 'INITIAL QUANTITY',
        de: 'ANFANGSMENGE',
        it: 'QUANTITÃ€ INIZIALE',
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
        de: 'Tippen, um ein Foto hinzuzufÃ¼gen',
        it: 'Tocca per aggiungere una foto',
        es: 'Pulsa para aÃ±adir una foto',
      );

  String get clickToAddDocument => _pick(
        fr: 'Cliquer pour ajouter un document',
        en: 'Tap to add a document',
        de: 'Tippen, um ein Dokument hinzuzufÃ¼gen',
        it: 'Tocca per aggiungere un documento',
        es: 'Pulsa para aÃ±adir un documento',
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
        de: 'Aktiviere die Indikatoren, die du verfolgen mÃ¶chtest',
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
        fr: 'ENREGISTRER LE MATÃ‰RIEL',
        en: 'SAVE ITEM',
        de: 'AUSRÃœSTUNG SPEICHERN',
        it: 'SALVA MATERIALE',
        es: 'GUARDAR MATERIAL',
      );

  String get saveChangesButton => _pick(
        fr: 'ENREGISTRER LES MODIFICATIONS',
        en: 'SAVE CHANGES',
        de: 'Ã„NDERUNGEN SPEICHERN',
        it: 'SALVA MODIFICHE',
        es: 'GUARDAR CAMBIOS',
      );

  String get batteryChangeDateLabel => _pick(
        fr: 'Date de changement de pile',
        en: 'Battery change date',
        de: 'Datum des Batteriewechsels',
        it: 'Data di sostituzione batteria',
        es: 'Fecha de cambio de baterÃ­a',
      );

  String get batteryChangeDateSubtitle => _pick(
fr: 'Date du dernier remplacement',
en: 'Last replacement date',
de: 'Datum des letzten Austauschs',
it: 'Data dellâ€™ultima sostituzione',
es: 'Fecha del Ãºltimo reemplazo',
      );

  String get lastChangeLabel => _pick(
        fr: 'Dernier changement',
        en: 'Last change',
        de: 'Letzter Wechsel',
        it: 'Ultimo cambio',
        es: 'Ãšltimo cambio',
      );

  String get selectDateLabel => _pick(
        fr: 'SÃ©lectionner une date',
        en: 'Select a date',
        de: 'Datum auswÃ¤hlen',
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
        fr: 'Suivi d\'usure de l\'accessoire',
        en: 'Accessory wear tracking',
        de: 'ZubehÃ¶rverschleiÃŸ-Tracking',
        it: 'Monitoraggio usura accessorio',
        es: 'Seguimiento de desgaste del accesorio',
      );

  String get weaponWearTrackingLabel => _pick(
fr: 'Suivi de lâ€™usure de lâ€™arme',
en: 'Weapon wear monitoring',
de: 'WaffenverschleiÃŸ-Tracking',
it: 'Monitoraggio usura arma',
es: 'Monitoreo del desgaste del arma',
      );

  String get weaponWearTrackingSubtitle => _pick(
fr: 'Usure selon tirs',
en: 'Wear from shots',
de: 'VerschleiÃŸ durch SchÃ¼sse',
it: 'Usura dai colpi',
es: 'Desgaste por disparos',
      );

  String get accessoryWearTrackingSubtitle => _pick(
fr: 'CalculÃ© selon les coups tirÃ©s',
en: 'Calculated based on shots fired',
de: 'Berechnet anhand der abgegebenen SchÃ¼sse',
it: 'Calcolato in base ai colpi sparati',
es: 'Calculado segÃºn los disparos realizados',
      );

  String get accessoryCleaningTrackingLabel => _pick(
fr: 'Suivi de salissure de l\'arme',
en: 'Weapon fouling tracking',
de: 'Verfolgung der Verschmutzung der Waffe',
it: 'Monitoraggio dello sporco dell\'arma',
es: 'Seguimiento de la suciedad del arma',
      );

  String get weaponCleaningTrackingLabel => _pick(
fr: 'Suivi de lâ€™encrassement de lâ€™arme',
en: 'Weapon fouling monitoring',
de: 'Waffenverschmutzung-Tracking',
it: 'Monitoraggio dello sporco dell\'arma',
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
de: 'SchusszÃ¤hler-Tracking',
it: 'Monitoraggio contatore colpi',
es: 'Monitoreo del contador de disparos',
      );

  String get weaponRoundCounterSubtitle => _pick(
fr: 'Total des tirs',
en: 'Total shots',
de: 'Gesamtzahl der SchÃ¼sse',
it: 'Totale colpi',
es: 'Total de disparos',
      );

  String get initialRoundCounterLabel => _pick(
fr: 'Valeur de dÃ©part',
en: 'Starting value',
de: 'Startwert',
it: 'Valore iniziale',
es: 'Valor inicial',
      );

  String get wearThresholdLabel => _pick(
fr: 'Coups avant contrÃ´le',
en: 'Shots before check',
de: 'SchÃ¼sse vor Kontrolle',
it: 'Colpi prima controllo',
es: 'Disparos antes control',
      );

  String get accessoryCleaningTrackingSubtitle => _pick(
        fr: 'Rappel de nettoyage selon l\'utilisation',
        en: 'Cleaning reminder based on usage',
        de: 'Reinigungserinnerung je nach Nutzung',
        it: 'Promemoria pulizia in base allâ€™uso',
        es: 'Recordatorio de limpieza segÃºn el uso',
      );

  String get revisionThresholdShotsLabel => _pick(
        fr: 'Seuil avant rÃ©vision',
        en: 'Revision threshold',
        de: 'Schwelle vor Revision',
        it: 'Soglia prima revisione',
        es: 'Umbral antes de revisiÃ³n',
      );

  String get cleaningThresholdShotsLabel => _pick(
fr: 'Coups avant nettoyage',
en: 'Shots before cleaning',
de: 'SchÃ¼sse vor Reinigung',
it: 'Colpi prima pulizia',
es: 'Disparos antes limpieza',
      );

  String get customOtherLabel => _pick(
        fr: 'Autre (personnalisÃ©)',
        en: 'Other (custom)',
        de: 'Andere (benutzerdefiniert)',
        it: 'Altro (personalizzato)',
        es: 'Otro (personalizado)',
      );

  String get customTypeLabel => _pick(
        fr: 'TYPE (PERSONNALISÃ‰)',
        en: 'TYPE (CUSTOM)',
        de: 'TYP (BENUTZERDEFINIERT)',
        it: 'TIPO (PERSONALIZZATO)',
        es: 'TIPO (PERSONALIZADO)',
      );

  String get serialNumberLabel => _pick(
        fr: 'NÂ° SÃ‰RIE',
        en: 'SERIAL NUMBER',
        de: 'SERIENNUMMER',
        it: 'NUMERO DI SERIE',
        es: 'N.Âº DE SERIE',
      );

  String get weightGramsLabel => _pick(
        fr: 'POIDS (G)',
        en: 'WEIGHT (G)',
        de: 'GEWICHT (G)',
        it: 'PESO (G)',
        es: 'PESO (G)',
      );

  String get quantityRequiredError => _pick(
        fr: 'QuantitÃ© obligatoire',
        en: 'Quantity required',
        de: 'Menge erforderlich',
        it: 'QuantitÃ  obbligatoria',
        es: 'Cantidad obligatoria',
      );

  String get brandModelLabel => _pick(
        fr: 'MARQUE / MODÃˆLE',
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
        fr: 'Version gratuite : 1 document PDF maximum par fiche. Passez Ã  Pro pour illimitÃ©.',
        en: 'Free version: 1 PDF document maximum per item. Upgrade to Pro for unlimited documents.',
        de: 'Kostenlose Version: maximal 1 PDF-Dokument pro Eintrag. Upgrade auf Pro fÃ¼r unbegrenzte Dokumente.',
        it: 'Versione gratuita: massimo 1 documento PDF per scheda. Passa a Pro per documenti illimitati.',
        es: 'VersiÃ³n gratuita: mÃ¡ximo 1 documento PDF por ficha. Pasa a Pro para documentos ilimitados.',
      );

  String get itemFreePdfLimitReached => _pick(
        fr: 'Version gratuite : limite de documents atteinte pour cette fiche.',
        en: 'Free version: document limit reached for this item.',
        de: 'Kostenlose Version: Dokumentenlimit fÃ¼r diesen Eintrag erreicht.',
        it: 'Versione gratuita: limite di documenti raggiunto per questa scheda.',
        es: 'VersiÃ³n gratuita: lÃ­mite de documentos alcanzado para esta ficha.',
      );

  String itemPageTitle(String category, bool isEdit) {
    switch (category) {
      case 'ARME':
        return isEdit
            ? _pick(fr: 'Ã‰DITER ARME', en: 'EDIT WEAPON', de: 'WAFFE BEARBEITEN', it: 'MODIFICA ARMA', es: 'EDITAR ARMA')
            : _pick(fr: 'NOUVELLE ARME', en: 'NEW WEAPON', de: 'NEUE WAFFE', it: 'NUOVA ARMA', es: 'NUEVA ARMA');
      case 'MUNITION':
        return isEdit
            ? _pick(fr: 'Ã‰DITER MUNITION', en: 'EDIT AMMO', de: 'MUNITION BEARBEITEN', it: 'MODIFICA MUNIZIONE', es: 'EDITAR MUNICIÃ“N')
            : _pick(fr: 'NOUVELLE MUNITION', en: 'NEW AMMO', de: 'NEUE MUNITION', it: 'NUOVA MUNIZIONE', es: 'NUEVA MUNICIÃ“N');
      case 'ACCESSOIRE':
        return isEdit
            ? _pick(fr: 'Ã‰DITER ACCESSOIRE', en: 'EDIT ACCESSORY', de: 'ZUBEHÃ–R BEARBEITEN', it: 'MODIFICA ACCESSORIO', es: 'EDITAR ACCESORIO')
            : _pick(fr: 'NOUVEL ACCESSOIRE', en: 'NEW ACCESSORY', de: 'NEUES ZUBEHÃ–R', it: 'NUOVO ACCESSORIO', es: 'NUEVO ACCESORIO');
      default:
        return isEdit
            ? _pick(fr: 'Ã‰DITER MATÃ‰RIEL', en: 'EDIT EQUIPMENT', de: 'AUSRÃœSTUNG BEARBEITEN', it: 'MODIFICA MATERIALE', es: 'EDITAR MATERIAL')
            : _pick(fr: 'NOUVEAU MATÃ‰RIEL', en: 'NEW EQUIPMENT', de: 'NEUE AUSRÃœSTUNG', it: 'NUOVO MATERIALE', es: 'NUEVO MATERIAL');
    }
  }

  String itemPrimaryNameLabel(String category) {
    switch (category) {
      case 'ARME':
        return _pick(fr: 'Nom personnalisÃ©', en: 'Custom name', de: 'Benutzerdefinierter Name', it: 'Nome personalizzato', es: 'Nombre personalizado');
      case 'MUNITION':
        return designationRegisterLabel;
      case 'ACCESSOIRE':
        return _pick(fr: 'Nom personnalisÃ©', en: 'Custom name', de: 'Benutzerdefinierter Name', it: 'Nome personalizzato', es: 'Nombre personalizado');
      default:
        return _pick(fr: 'NOM', en: 'NAME', de: 'NAME', it: 'NOME', es: 'NOMBRE');
    }
  }

  String itemPrimaryNameHint(String category) {
    switch (category) {
      case 'ARME':
        return _pick(fr: 'ex: Glock 17 Gen 5', en: 'e.g. Glock 17 Gen 5', de: 'z. B. Glock 17 Gen 5', it: 'es: Glock 17 Gen 5', es: 'ej.: Glock 17 Gen 5');
      case 'MUNITION':
        return _pick(fr: 'ex: 9x19 FMJ 124gr (boÃ®te 50)', en: 'e.g. 9x19 FMJ 124gr (box of 50)', de: 'z. B. 9x19 FMJ 124gr (50er-Pack)', it: 'es: 9x19 FMJ 124gr (scatola da 50)', es: 'ej.: 9x19 FMJ 124gr (caja de 50)');
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
        fr: 'ex: Gold Dot, JHP, FTXâ€¦',
        en: 'e.g. Gold Dot, JHP, FTXâ€¦',
        de: 'z. B. Gold Dot, JHP, FTXâ€¦',
        it: 'es: Gold Dot, JHP, FTXâ€¦',
        es: 'ej.: Gold Dot, JHP, FTXâ€¦',
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
        fr: 'Modifications enregistrÃ©es',
        en: 'Changes saved',
        de: 'Ã„nderungen gespeichert',
        it: 'Modifiche salvate',
        es: 'Cambios guardados',
      );

  String get itemAddedSuccess => _pick(
        fr: 'MatÃ©riel ajoutÃ©',
        en: 'Equipment added',
        de: 'AusrÃ¼stung hinzugefÃ¼gt',
        it: 'Attrezzatura aggiunta',
        es: 'Equipo agregado',
      );

  String get itemCommentHint => _pick(
        fr: 'Ex: Note personnelle, lot, date dâ€™achat, particularitÃ©sâ€¦',
        en: 'Ex: Personal note, batch, purchase date, specificsâ€¦',
        de: 'z.B. PersÃ¶nliche Notiz, Los, Kaufdatum, Besonderheitenâ€¦',
        it: 'Es: Nota personale, lotto, data di acquisto, particolaritÃ â€¦',
        es: 'Ej: Nota personal, lote, fecha de compra, particularidadesâ€¦',
      );

  String itemDocumentTypeLabelForValue(String value) {
    switch (value) {
      case 'Facture':
        return _pick(fr: 'Facture', en: 'Invoice', de: 'Rechnung', it: 'Fattura', es: 'Factura');
      case 'RÃ©vision':
        return _pick(fr: 'RÃ©vision', en: 'Service', de: 'Inspektion', it: 'Revisione', es: 'RevisiÃ³n');
      case 'Entretien':
        return _pick(fr: 'Entretien', en: 'Maintenance', de: 'Wartung', it: 'Manutenzione', es: 'Mantenimiento');
      case 'Manuel':
        return _pick(fr: 'Manuel', en: 'Manual', de: 'Handbuch', it: 'Manuale', es: 'Manual');
      case 'Garantie':
        return _pick(fr: 'Garantie', en: 'Warranty', de: 'Garantie', it: 'Garanzia', es: 'GarantÃ­a');
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String itemAccessoryTypeLabel(String value) {
    switch (value) {
      case 'Optiques':
        return _pick(fr: 'Optiques', en: 'Optics', de: 'Optiken', it: 'Ottiche', es: 'Ã“pticas');
      case 'Lampes':
        return _pick(fr: 'Lampes', en: 'Lights', de: 'Lampen', it: 'Luci', es: 'Linternas');
      case 'Lasers':
        return _pick(fr: 'Lasers', en: 'Lasers', de: 'Laser', it: 'Laser', es: 'LÃ¡seres');
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
      case 'ModÃ©rateurs':
        return _pick(fr: 'ModÃ©rateurs', en: 'Suppressors', de: 'SchalldÃ¤mpfer', it: 'Soppressori', es: 'Supresores');
      case 'RÃ©ducteur de son':
        return _pick(fr: 'RÃ©ducteur de son', en: 'Sound moderator', de: 'SchalldÃ¤mpfer', it: 'Moderatore di suono', es: 'Moderador de sonido');
      case 'Compensateurs':
        return _pick(fr: 'Compensateurs', en: 'Compensators', de: 'Kompensatoren', it: 'Compensatori', es: 'Compensadores');
      case 'PoignÃ©es':
        return _pick(fr: 'PoignÃ©es', en: 'Grips', de: 'Griffe', it: 'Impugnature', es: 'EmpuÃ±aduras');
      case 'Bipieds':
        return _pick(fr: 'Bipieds', en: 'Bipods', de: 'Zweibeine', it: 'Bipiedi', es: 'BÃ­podes');
      case 'Montages':
        return _pick(fr: 'Montages', en: 'Mounts', de: 'Montagen', it: 'Attacchi', es: 'Montajes');
      case 'VisÃ©e mÃ©canique':
        return _pick(fr: 'VisÃ©e mÃ©canique', en: 'Iron sights', de: 'Mechanische Visierung', it: 'Mire meccaniche', es: 'Miras mecÃ¡nicas');
      case 'Crosses':
        return _pick(fr: 'Crosses', en: 'Stocks', de: 'SchÃ¤fte', it: 'Calci', es: 'Culatas');
      case 'DÃ©tentes':
        return _pick(fr: 'DÃ©tentes', en: 'Triggers', de: 'AbzÃ¼ge', it: 'Grilletti', es: 'Disparadores');
      case 'PiÃ¨ces internes':
        return _pick(fr: 'PiÃ¨ces internes', en: 'Internal parts', de: 'Innenteile', it: 'Componenti interni', es: 'Piezas internas');
      case 'Transport':
        return _pick(fr: 'Transport', en: 'Transport', de: 'Transport', it: 'Trasporto', es: 'Transporte');
      case 'SÃ©curitÃ©':
        return _pick(fr: 'SÃ©curitÃ©', en: 'Safety', de: 'Sicherheit', it: 'Sicurezza', es: 'Seguridad');
      case 'Protections':
        return _pick(fr: 'Protections', en: 'Protection gear', de: 'SchutzausrÃ¼stung', it: 'Protezioni', es: 'Protecciones');
      case 'Chronographes':
        return _pick(fr: 'Chronographes', en: 'Chronographs', de: 'Chronographen', it: 'Cronografi', es: 'CronÃ³grafos');
      case 'Timers':
        return _pick(fr: 'Timers', en: 'Timers', de: 'Timer', it: 'Timer', es: 'Temporizadores');
      case 'Cibles':
        return _pick(fr: 'Cibles', en: 'Targets', de: 'Ziele', it: 'Bersagli', es: 'Blancos');
      case 'Supports de tir':
        return _pick(fr: 'Supports de tir', en: 'Shooting rests', de: 'SchieÃŸauflagen', it: 'Supporti di tiro', es: 'Apoyos de tiro');
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
        return _pick(fr: 'Pistolet semi-auto', en: 'Semi-auto pistol', de: 'Selbstladepistole', it: 'Pistola semiautomatica', es: 'Pistola semiautomÃ¡tica');
      case 'RÃ©volver':
        return _pick(fr: 'RÃ©volver', en: 'Revolver', de: 'Revolver', it: 'Revolver', es: 'RevÃ³lver');
      case 'Pistolet mitrailleur':
        return _pick(fr: 'Pistolet mitrailleur', en: 'Submachine gun', de: 'Maschinenpistole', it: 'Pistola mitragliatrice', es: 'Subfusil');
      case "Fusil d'assaut":
        return _pick(fr: "Fusil d'assaut", en: 'Assault rifle', de: 'Sturmgewehr', it: "Fucile d'assalto", es: 'Fusil de asalto');
      case 'Fusil mitrailleur':
        return _pick(fr: 'Fusil mitrailleur', en: 'Machine rifle', de: 'Maschinengewehr', it: 'Fucile mitragliatore', es: 'Fusil ametrallador');
      case 'Carabine':
        return _pick(fr: 'Carabine', en: 'Carbine', de: 'Karabiner', it: 'Carabina', es: 'Carabina');
      case 'Fusil Ã  pompe':
        return _pick(fr: 'Fusil Ã  pompe', en: 'Pump shotgun', de: 'Pumpflinte', it: 'Fucile a pompa', es: 'Escopeta de bombeo');
      case 'Fusil de chasse':
        return _pick(fr: 'Fusil de chasse', en: 'Shotgun', de: 'Jagdflinte', it: 'Fucile da caccia', es: 'Escopeta de caza');
      case 'Fusil de prÃ©cision':
        return _pick(fr: 'Fusil de prÃ©cision', en: 'Precision rifle', de: 'PrÃ¤zisionsgewehr', it: 'Fucile di precisione', es: 'Rifle de precisiÃ³n');
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
        return _pick(fr: 'Subsonique', en: 'Subsonic', de: 'Unterschall', it: 'Subsonico', es: 'SubsÃ³nico');
      case 'TraÃ§ante':
        return _pick(fr: 'TraÃ§ante', en: 'Tracer', de: 'Leuchtspur', it: 'Tracciante', es: 'Trazadora');
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String get diagnosticDefaultFinal => _pick(
        fr: 'CAUSES MULTIFACTORIELLES â€” CONTRÃ”LE RECOMMANDÃ‰',
        en: 'MULTIFACTORIAL CAUSES â€” INSPECTION RECOMMENDED',
        de: 'MULTIFAKTORIELLE URSACHEN â€” KONTROLLE EMPFOHLEN',
        it: 'CAUSE MULTIFATTORIALI â€” CONTROLLO CONSIGLIATO',
        es: 'CAUSAS MULTIFACTORIALES â€” CONTROL RECOMENDADO',
      );

  String get diagnosticNoFireLabel => _pick(
        fr: 'NON-TIR',
        en: 'MISFIRE',
        de: 'FEHLZÃœNDUNG',
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
        fr: 'DÃ‰PART INTEMPESTIF',
        en: 'UNINTENDED DISCHARGE',
        de: 'UNBEABSICHTIGTE SCHUSSABGABE',
        it: 'PARTENZA INTEMPESTIVA',
        es: 'DISPARO INTEMPESTIVO',
      );

  String get diagnosticJamLabel => _pick(
        fr: 'ENRAYAGE',
        en: 'JAM',
        de: 'STÃ–RUNG',
        it: 'INCEPPAMENTO',
        es: 'ATASCO',
      );

  String get diagnosticAccuracyDropLabel => _pick(
        fr: 'BAISSE DE PRÃ‰CISION',
        en: 'ACCURACY DROP',
        de: 'PRÃ„ZISIONSVERLUST',
        it: 'CALO DI PRECISIONE',
        es: 'BAJADA DE PRECISIÃ“N',
      );

  String get diagnosticQuestion5 => _pick(
        fr: "Ã€ l'appui de dÃ©tente, entendez-vous la percussion (clic) ?",
        en: 'When pulling the trigger, do you hear the striker impact (click)?',
        de: 'HÃ¶rst du beim BetÃ¤tigen des Abzugs den Schlagbolzen (Klick)?',
        it: 'Premendo il grilletto, senti la percussione (clic)?',
        es: 'Al accionar el gatillo, Â¿oyes la percusiÃ³n (clic)?',
      );

  String get diagnosticQuestion6 => _pick(
        fr: "AprÃ¨s extraction, y a-t-il une empreinte de percussion sur l'amorce ?",
        en: 'After extraction, is there a firing pin mark on the primer?',
        de: 'Ist nach dem Auswerfen ein Schlagbolzenabdruck auf dem ZÃ¼ndhÃ¼tchen sichtbar?',
        it: "Dopo l'estrazione, c'Ã¨ un'impronta di percussione sull'innesco?",
        es: 'Tras la extracciÃ³n, Â¿hay una marca de percusiÃ³n en el pistÃ³n?',
      );

  String get diagnosticQuestion6Description => _pick(
        fr: "Si l'Ã©tat est douteux, considÃ©rez l'arme chargÃ©e et sÃ©curisez avant toute extraction.",
        en: 'If the state is uncertain, consider the weapon loaded and make it safe before any extraction.',
        de: 'Wenn der Zustand unklar ist, behandle die Waffe als geladen und sichere sie vor jedem Auswerfen.',
        it: "Se lo stato Ã¨ incerto, considera l'arma carica e mettila in sicurezza prima di qualsiasi estrazione.",
        es: 'Si el estado es dudoso, considera el arma cargada y asegÃºrala antes de cualquier extracciÃ³n.',
      );

  String get diagnosticQuestion7 => _pick(
        fr: "L'empreinte est-elle bien centrÃ©e et suffisamment marquÃ©e ?",
        en: 'Is the mark well centered and sufficiently pronounced?',
        de: 'Ist der Abdruck gut zentriert und deutlich genug?',
        it: 'Lâ€™impronta Ã¨ ben centrata e sufficientemente marcata?',
        es: 'Â¿La marca estÃ¡ bien centrada y suficientemente marcada?',
      );

  String get diagnosticQuestion7Description => _pick(
        fr: 'Une percussion dÃ©centrÃ©e/peu profonde peut indiquer: verrouillage incomplet, ressort de percuteur fatiguÃ©, canal percuteur encrassÃ©.',
        en: 'An off-center or shallow strike may indicate incomplete lockup, a tired firing pin spring, or a dirty firing pin channel.',
        de: 'Ein auÃŸermittiger oder flacher Abdruck kann auf unvollstÃ¤ndige Verriegelung, eine schwache Schlagbolzenfeder oder einen verschmutzten Schlagbolzenkanal hinweisen.',
        it: 'Una percussione decentrata o poco profonda puÃ² indicare chiusura incompleta, molla del percussore stanca o canale del percussore sporco.',
        es: 'Una percusiÃ³n descentrada o poco profunda puede indicar cierre incompleto, muelle del percutor fatigado o canal del percutor sucio.',
      );

  String get diagnosticQuestion8 => _pick(
        fr: "La cartouche Ã©tait-elle correctement chambrÃ©e / l'arme verrouillÃ©e ?",
        en: 'Was the cartridge properly chambered / the weapon locked?',
        de: 'War die Patrone korrekt im Patronenlager / die Waffe verriegelt?',
        it: 'La cartuccia era correttamente camerata / lâ€™arma era chiusa?',
        es: 'Â¿El cartucho estaba correctamente recamarado / el arma cerrada?',
      );

  String get diagnosticQuestion8Description => _pick(
        fr: "Sur certaines armes, une sÃ»retÃ© passive empÃªche la percussion si le verrou n'est pas totalement engagÃ©.",
        en: 'On some weapons, a passive safety prevents firing if the lock is not fully engaged.',
        de: 'Bei manchen Waffen verhindert eine passive Sicherung den Schlag, wenn die Verriegelung nicht vollstÃ¤ndig geschlossen ist.',
        it: 'Su alcune armi, una sicura passiva impedisce la percussione se la chiusura non Ã¨ completamente ingaggiata.',
        es: 'En algunas armas, un seguro pasivo impide la percusiÃ³n si el cierre no estÃ¡ completamente encajado.',
      );

  String get diagnosticQuestion9 => _pick(
        fr: 'Avez-vous essayÃ© une autre munition (autre lot / autre boÃ®te) ?',
        en: 'Have you tried another round (different lot / different box)?',
        de: 'Hast du eine andere Munition ausprobiert (anderes Los / andere Schachtel)?',
        it: 'Hai provato unâ€™altra munizione (altro lotto / altra scatola)?',
        es: 'Â¿Has probado otra municiÃ³n (otro lote / otra caja)?',
      );

  String get diagnosticQuestion10 => _pick(
        fr: 'Le coup est-il parti avec un dÃ©lai aprÃ¨s la percussion ?',
        en: 'Did the shot fire after a delay following the strike?',
        de: 'Hat sich der Schuss verzÃ¶gert nach dem Schlag gelÃ¶st?',
        it: 'Il colpo Ã¨ partito con ritardo dopo la percussione?',
        es: 'Â¿El disparo saliÃ³ con retraso tras la percusiÃ³n?',
      );

  String get diagnosticQuestion10Description => _pick(
        fr: "Si vous suspectez un long feu: maintenez l'arme Ã©paulÃ©e, canon dirigÃ© vers la cible, au moins 15 secondes avant d'ouvrir.",
        en: 'If you suspect a hangfire, keep the weapon shouldered and pointed at the target for at least 15 seconds before opening it.',
        de: 'Wenn du ein Hangfire vermutest, halte die Waffe mindestens 15 Sekunden lang angeschlagen und auf das Ziel gerichtet, bevor du sie Ã¶ffnest.',
        it: "Se sospetti un fuoco ritardato, mantieni l'arma in posizione di tiro e puntata verso il bersaglio per almeno 15 secondi prima di aprirla.",
        es: 'Si sospechas un fuego retardado, mantÃ©n el arma encarada y apuntando al blanco al menos 15 segundos antes de abrirla.',
      );

  String get diagnosticNoOrUnknown => _pick(
        fr: 'NON / JE NE SAIS PAS',
        en: 'NO / I DONâ€™T KNOW',
        de: 'NEIN / ICH WEISS NICHT',
        it: 'NO / NON LO SO',
        es: 'NO / NO LO SÃ‰',
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
        fr: "Avez-vous gardÃ© l'arme en direction sÃ»re au moins 15 secondes avant d'ouvrir ?",
        en: 'Did you keep the weapon pointed in a safe direction for at least 15 seconds before opening it?',
        de: 'Hast du die Waffe vor dem Ã–ffnen mindestens 15 Sekunden in sichere Richtung gehalten?',
        it: "Hai tenuto l'arma in direzione sicura per almeno 15 secondi prima di aprirla?",
        es: 'Â¿Mantuviste el arma en una direcciÃ³n segura al menos 15 segundos antes de abrirla?',
      );

  String get diagnosticQuestion12 => _pick(
        fr: "Cartouche Ã©jectÃ©e: essayez-vous d'Ã©viter de tirer / manipuler le reste du lot ?",
        en: 'Ejected round: are you avoiding firing / handling the rest of the batch?',
        de: 'Ausgeworfene Patrone: vermeidest du es, den Rest des Loses zu verschieÃŸen oder zu handhaben?',
        it: 'Cartuccia espulsa: stai evitando di sparare / manipolare il resto del lotto?',
        es: 'Cartucho expulsado: Â¿evitas disparar / manipular el resto del lote?',
      );

  String get diagnosticQuestion12Description => _pick(
        fr: 'Un long feu est typiquement liÃ© Ã  une munition dÃ©fectueuse (amorÃ§age / poudre).',
        en: 'A hangfire is typically linked to defective ammunition (primer / powder).',
        de: 'Ein Hangfire hÃ¤ngt typischerweise mit defekter Munition zusammen (ZÃ¼ndung / Pulver).',
        it: 'Un fuoco ritardato Ã¨ tipicamente legato a una munizione difettosa (innesco / polvere).',
        es: 'Un fuego retardado suele estar relacionado con municiÃ³n defectuosa (pistÃ³n / pÃ³lvora).',
      );

  String get diagnosticQuestion13 => _pick(
        fr: "ÃŠtes-vous certain de ne pas avoir involontairement pressÃ© la dÃ©tente ?",
        en: 'Are you certain you did not unintentionally press the trigger?',
        de: 'Bist du sicher, dass du den Abzug nicht unbeabsichtigt betÃ¤tigt hast?',
        it: 'Sei sicuro di non aver premuto involontariamente il grilletto?',
        es: 'Â¿EstÃ¡s seguro de no haber presionado involuntariamente el gatillo?',
      );

  String get diagnosticQuestion14 => _pick(
        fr: 'Le dÃ©part est-il survenu pendant une manipulation (fermeture, verrouillage, choc) ?',
        en: 'Did the discharge happen during handling (closing, locking, impact)?',
        de: 'Ist die Schussabgabe wÃ¤hrend einer Handhabung erfolgt (SchlieÃŸen, Verriegeln, StoÃŸ)?',
        it: 'La partenza Ã¨ avvenuta durante una manipolazione (chiusura, bloccaggio, urto)?',
        es: 'Â¿Se produjo el disparo durante una manipulaciÃ³n (cierre, bloqueo, golpe)?',
      );

  String get diagnosticQuestion15 => _pick(
        fr: 'La dÃ©tente/commande a-t-elle Ã©tÃ© modifiÃ©e ou rÃ©glÃ©e rÃ©cemment ?',
        en: 'Has the trigger/control been modified or adjusted recently?',
        de: 'Wurde der Abzug / die Steuerung kÃ¼rzlich verÃ¤ndert oder eingestellt?',
        it: 'Il grilletto/comando Ã¨ stato modificato o regolato di recente?',
        es: 'Â¿Se ha modificado o ajustado recientemente el disparador/control?',
      );

  String get diagnosticQuestion16 => _pick(
        fr: "Quel type d'enrayage observez-vous ?",
        en: 'What type of jam are you observing?',
        de: 'Welche Art von StÃ¶rung beobachtest du?',
        it: 'Che tipo di inceppamento osservi?',
        es: 'Â¿QuÃ© tipo de atasco observas?',
      );

  String get diagnosticJamFeeding => _pick(
        fr: 'Alimentation / chambrage',
        en: 'Feeding / chambering',
        de: 'ZufÃ¼hrung / Patronenlager',
        it: 'Alimentazione / cameratura',
        es: 'AlimentaciÃ³n / recÃ¡mara',
      );

  String get diagnosticJamReturnToBattery => _pick(
        fr: 'Retour en batterie incomplet',
        en: 'Incomplete return to battery',
        de: 'UnvollstÃ¤ndige Verriegelung',
        it: 'Ritorno in batteria incompleto',
        es: 'Retorno a baterÃ­a incompleto',
      );

  String get diagnosticJamExtractionEjection => _pick(
        fr: 'Extraction/Ã©jection',
        en: 'Extraction / ejection',
        de: 'Ausziehen / Auswerfen',
        it: 'Estrazione / espulsione',
        es: 'ExtracciÃ³n / expulsiÃ³n',
      );

  String get iDoNotKnow => _pick(
        fr: 'Je ne sais pas',
        en: 'I do not know',
        de: 'Ich weiÃŸ nicht',
        it: 'Non lo so',
        es: 'No lo sÃ©',
      );

  String get diagnosticQuestion17 => _pick(
        fr: 'Utilisez-vous un chargeur amovible ?',
        en: 'Are you using a detachable magazine?',
        de: 'Verwendest du ein herausnehmbares Magazin?',
        it: 'Stai usando un caricatore amovibile?',
        es: 'Â¿Usas un cargador extraÃ­ble?',
      );

  String get diagnosticQuestion18 => _pick(
        fr: 'Le problÃ¨me survient-il avec un chargeur en particulier ?',
        en: 'Does the problem occur with a particular magazine?',
        de: 'Tritt das Problem bei einem bestimmten Magazin auf?',
        it: 'Il problema si verifica con un caricatore in particolare?',
        es: 'Â¿El problema ocurre con un cargador en particular?',
      );

  String get diagnosticQuestion18Description => _pick(
        fr: 'Si un seul chargeur est concernÃ©: lÃ¨vres, ressort, saletÃ©s, prÃ©sentation de cartouche.',
        en: 'If only one magazine is affected: feed lips, spring, dirt, cartridge presentation.',
        de: 'Wenn nur ein Magazin betroffen ist: Lippen, Feder, Schmutz, PatronenzufÃ¼hrung.',
        it: 'Se Ã¨ coinvolto un solo caricatore: labbri, molla, sporco, presentazione della cartuccia.',
        es: 'Si solo afecta a un cargador: labios, muelle, suciedad, presentaciÃ³n del cartucho.',
      );

  String get diagnosticQuestion19 => _pick(
        fr: "L'arme est-elle propre (chambre, rampe, culasse) et lubrifiÃ©e correctement ?",
        en: 'Is the weapon clean (chamber, feed ramp, bolt) and correctly lubricated?',
        de: 'Ist die Waffe sauber (Patronenlager, ZufÃ¼hrrampe, Verschluss) und korrekt geschmiert?',
        it: "L'arma Ã¨ pulita (camera, rampa, otturatore) e correttamente lubrificata?",
        es: 'Â¿EstÃ¡ el arma limpia (recÃ¡mara, rampa, cierre) y correctamente lubricada?',
      );

  String get diagnosticQuestion23 => _pick(
        fr: 'ÃŠtes-vous sur un appui stable avec une tenue rÃ©guliÃ¨re ?',
        en: 'Are you on a stable rest with a consistent hold?',
        de: 'Hast du eine stabile Auflage und einen gleichmÃ¤ÃŸigen Anschlag?',
        it: 'Sei su un appoggio stabile con una tenuta regolare?',
        es: 'Â¿EstÃ¡s sobre un apoyo estable con una sujeciÃ³n regular?',
      );

  String get diagnosticQuestion23Description => _pick(
        fr: "Avant d'incriminer l'arme: position, dÃ©tente, lÃ¢cher, cadence, fatigue, visÃ©e.",
        en: 'Before blaming the weapon: position, trigger control, release, cadence, fatigue, sight picture.',
        de: 'Bevor du die Waffe beschuldigst: Position, Abzug, Schussabgabe, Rhythmus, MÃ¼digkeit, Zielbild.',
        it: "Prima di accusare l'arma: posizione, grilletto, sgancio, cadenza, fatica, mira.",
        es: 'Antes de culpar al arma: posiciÃ³n, gatillo, suelta, ritmo, fatiga, punterÃ­a.',
      );

  String get diagnosticQuestion24 => _pick(
        fr: 'Le problÃ¨me disparaÃ®t-il en changeant de munition (lot/type) ?',
        en: 'Does the problem disappear when changing ammunition (lot/type)?',
        de: 'Verschwindet das Problem mit anderer Munition (Los/Typ)?',
        it: 'Il problema scompare cambiando munizione (lotto/tipo)?',
        es: 'Â¿Desaparece el problema al cambiar de municiÃ³n (lote/tipo)?',
      );

  String get diagnosticQuestion25 => _pick(
        fr: "L'optique / montage est-il vÃ©rifiÃ© (serrage, colliers, rail) ?",
        en: 'Has the optic / mount been checked (torque, rings, rail)?',
        de: 'Wurden Optik / Montage geprÃ¼ft (Drehmoment, Ringe, Schiene)?',
        it: "L'ottica / montaggio Ã¨ stato verificato (serraggio, anelli, slitta)?",
        es: 'Â¿Se ha comprobado la Ã³ptica / montaje (apriete, anillas, rail)?',
      );

  String get diagnosticQuestion26 => _pick(
        fr: "Le canon/chambre est-il propre (pas d'encrassement notable) ?",
        en: 'Is the barrel/chamber clean (no notable fouling)?',
        de: 'Sind Lauf / Patronenlager sauber (keine nennenswerte Verschmutzung)?',
        it: 'La canna/camera Ã¨ pulita (senza incrostazioni rilevanti)?',
        es: 'Â¿EstÃ¡ limpio el caÃ±Ã³n/recÃ¡mara (sin suciedad notable)?',
      );

  String get addToStock => _pick(
        fr: 'AJOUTER AU STOCK',
        en: 'ADD TO STOCK',
        de: 'ZUM BESTAND HINZUFÃœGEN',
        it: 'AGGIUNGI ALLE SCORTE',
        es: 'AGREGAR AL STOCK',
      );

  String get itemNotFound => _pick(
        fr: 'Item non trouvÃ©',
        en: 'Item not found',
        de: 'Artikel nicht gefunden',
        it: 'Articolo non trovato',
        es: 'ArtÃ­culo no encontrado',
      );

  String get itemDoesNotExist => _pick(
        fr: "Cet item n'existe pas",
        en: 'This item does not exist',
        de: 'Dieser Artikel existiert nicht',
        it: 'Questo articolo non esiste',
        es: 'Este artÃ­culo no existe',
      );

  String get maintenanceStatus => _pick(
        fr: 'Ã‰TAT DE MAINTENANCE',
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
        fr: 'SPÃ‰CIFICATIONS',
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
        fr: 'Aucune donnÃ©e pour cette pÃ©riode',
        en: 'No data for this period',
        de: 'Keine Daten fÃ¼r diesen Zeitraum',
        it: 'Nessun dato per questo periodo',
        es: 'No hay datos para este perÃ­odo',
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
        fr: 'AnnÃ©e',
        en: 'Year',
        de: 'Jahr',
        it: 'Anno',
        es: 'AÃ±o',
      );

  String get modelLabel => _pick(
        fr: 'ModÃ¨le',
        en: 'Model',
        de: 'Modell',
        it: 'Modello',
        es: 'Modelo',
      );

  String get batteryChangedLabel => _pick(
        fr: 'Pile changÃ©e',
        en: 'Battery changed',
        de: 'Batterie gewechselt',
        it: 'Batteria cambiata',
        es: 'BaterÃ­a cambiada',
      );

  String get accessoryStatusTitle => _pick(
        fr: "Ã‰TAT DE L'ACCESSOIRE",
        en: 'ACCESSORY STATUS',
        de: 'ZUBEHÃ–RSTATUS',
        it: "STATO DELL'ACCESSORIO",
        es: 'ESTADO DEL ACCESORIO',
      );

  String get fullHistoryTitle => _pick(
        fr: 'HISTORIQUE COMPLET',
        en: 'FULL HISTORY',
        de: 'VOLLSTÃ„NDIGER VERLAUF',
        it: 'STORICO COMPLETO',
        es: 'HISTORIAL COMPLETO',
      );

  String get noMaintenanceHistoryRecorded => _pick(
        fr: "Aucun historique d'entretien/rÃ©vision enregistrÃ©",
        en: 'No maintenance/revision history recorded',
        de: 'Kein Wartungs-/Revisionsverlauf erfasst',
        it: 'Nessuno storico manutenzione/revisione registrato',
        es: 'No hay historial de mantenimiento/revisiÃ³n registrado',
      );

  String get emptyWeightLabel => _pick(
        fr: 'Poids (vide)',
        en: 'Weight (empty)',
        de: 'Gewicht (leer)',
        it: 'Peso (vuoto)',
        es: 'Peso (vacÃ­o)',
      );

  String get lastCleaningLabel => _pick(
        fr: 'Dernier nettoyage',
        en: 'Last cleaning',
        de: 'Letzte Reinigung',
        it: 'Ultima pulizia',
        es: 'Ãšltima limpieza',
      );

  String get lastRevisionLabel => _pick(
        fr: 'DerniÃ¨re rÃ©vision',
        en: 'Last revision',
        de: 'Letzte Revision',
        it: 'Ultima revisione',
        es: 'Ãšltima revisiÃ³n',
      );

  String get weaponConfirmRevisionMessage => _pick(
        fr: 'Voulez-vous vraiment enregistrer une rÃ©vision complÃ¨te pour cette arme ? Le compteur de rÃ©vision sera remis Ã  zÃ©ro.',
        en: 'Do you really want to record a complete revision for this weapon? The revision counter will be reset to zero.',
        de: 'MÃ¶chten Sie wirklich eine vollstÃ¤ndige Revision fÃ¼r diese Waffe erfassen? Der RevisionszÃ¤hler wird auf Null zurÃ¼ckgesetzt.',
        it: 'Vuoi davvero registrare una revisione completa per questa arma? Il contatore di revisione verrÃ  azzerato.',
        es: 'Â¿Realmente quieres registrar una revisiÃ³n completa para esta arma? El contador de revisiÃ³n se reiniciarÃ¡ a cero.',
      );

  String get accessoryConfirmCleaningMessage => _pick(
        fr: 'Voulez-vous vraiment enregistrer un nettoyage complet pour cet accessoire ? Le compteur d\'entretien sera remis Ã  zÃ©ro.',
        en: 'Do you really want to record a complete cleaning for this accessory? The maintenance counter will be reset to zero.',
        de: 'MÃ¶chten Sie wirklich eine vollstÃ¤ndige Reinigung fÃ¼r dieses ZubehÃ¶r erfassen? Der WartungszÃ¤hler wird auf Null zurÃ¼ckgesetzt.',
        it: 'Vuoi davvero registrare una pulizia completa per questo accessorio? Il contatore di manutenzione verrÃ  azzerato.',
        es: 'Â¿Realmente quieres registrar una limpieza completa para este accesorio? El contador de mantenimiento se reiniciarÃ¡ a cero.',
      );

  String get accessoryConfirmRevisionMessage => _pick(
        fr: 'Voulez-vous vraiment enregistrer une rÃ©vision complÃ¨te pour cet accessoire ? Le compteur de rÃ©vision sera remis Ã  zÃ©ro.',
        en: 'Do you really want to record a complete revision for this accessory? The revision counter will be reset to zero.',
        de: 'MÃ¶chten Sie wirklich eine vollstÃ¤ndige Revision fÃ¼r dieses ZubehÃ¶r erfassen? Der RevisionszÃ¤hler wird auf Null zurÃ¼ckgesetzt.',
        it: 'Vuoi davvero registrare una revisione completa per questo accessorio? Il contatore di revisione verrÃ  azzerato.',
        es: 'Â¿Realmente quieres registrar una revisiÃ³n completa para este accesorio? El contador de revisiÃ³n se reiniciarÃ¡ a cero.',
      );

  String get revisionRecordedSuccess => _pick(
        fr: 'RÃ©vision enregistrÃ©e avec succÃ¨s.',
        en: 'Revision recorded successfully.',
        de: 'Revision erfolgreich erfasst.',
        it: 'Revisione registrata con successo.',
        es: 'RevisiÃ³n registrada con Ã©xito.',
      );

  String get partChangeTitle => _pick(
        fr: 'Changement de piÃ¨ce',
        en: 'Part replacement',
        de: 'Teilewechsel',
        it: 'Sostituzione pezzo',
        es: 'Cambio de pieza',
      );

String get partNameLabel => _pick(
        fr: 'Nom de la piÃ¨ce',
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
        es: 'Ej.: caÃ±Ã³n',
      );

String get partChangeCommentLabel => _pick(
        fr: 'Commentaire',
        en: 'Comment',
        de: 'Kommentar',
        it: 'Commento',
        es: 'Comentario',
      );

  String get partChangeCommentHint => _pick(
        fr: 'Ex : remplacement prÃ©ventif aprÃ¨s 5 000 coups',
        en: 'E.g.: preventive replacement after 5,000 rounds',
        de: 'z. B.: vorbeugender Austausch nach 5.000 Schuss',
        it: 'Es.: sostituzione preventiva dopo 5.000 colpi',
        es: 'Ej.: sustituciÃ³n preventiva tras 5.000 disparos',
      );

  String get dateLabel => _pick(
        fr: 'Date',
        en: 'Date',
        de: 'Datum',
        it: 'Data',
        es: 'Fecha',
      );

  String get partChangeRecordedSuccess => _pick(
        fr: 'Changement de piÃ¨ce enregistrÃ©.',
        en: 'Part replacement recorded.',
        de: 'Teilewechsel erfasst.',
        it: 'Sostituzione pezzo registrata.',
        es: 'Cambio de pieza registrado.',
      );

  String get recordPartChange => _pick(
        fr: 'Enregistrer un changement de piÃ¨ce',
        en: 'Record part replacement',
        de: 'Teilewechsel erfassen',
        it: 'Registra sostituzione pezzo',
        es: 'Registrar cambio de pieza',
      );

  String shotsWithUnit(int count) => _pick(
        fr: '$count ${count > 1 ? 'coups' : 'coup'}',
        en: '$count ${count == 1 ? 'shot' : 'shots'}',
        de: '$count ${count == 1 ? 'Schuss' : 'SchÃ¼sse'}',
        it: '$count ${count == 1 ? 'colpo' : 'colpi'}',
        es: '$count ${count == 1 ? 'disparo' : 'disparos'}',
      );

  String get revision => _pick(
        fr: 'RÃ©vision',
        en: 'Revision',
        de: 'Revision',
        it: 'Revisione',
        es: 'RevisiÃ³n',
      );

  String get cleanliness => _pick(
        fr: 'PropretÃ©',
        en: 'Cleanliness',
        de: 'Sauberkeit',
        it: 'Pulizia',
        es: 'Limpieza',
      );

  String get totalShots => _pick(
        fr: 'TOTAL COUPS',
        en: 'TOTAL SHOTS',
        de: 'GESAMTSCHÃœSSE',
        it: 'COLPI TOTALI',
        es: 'TIROS TOTALES',
      );

  String get lastShot => _pick(
        fr: 'DERNIER TIR',
        en: 'LAST SHOT',
        de: 'LETZTER SCHUSS',
        it: 'ULTIMO COLPO',
        es: 'ÃšLTIMO TIRO',
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
        de: 'SchÃ¼sse',
        it: 'colpi',
        es: 'tiros',
      );

  String get confirmation => _pick(
        fr: 'Confirmation',
        en: 'Confirmation',
        de: 'BestÃ¤tigung',
        it: 'Conferma',
        es: 'ConfirmaciÃ³n',
      );

  String get confirmCleaningMessage => _pick(
        fr: 'Voulez-vous vraiment enregistrer un nettoyage complet pour cette arme ? Le compteur d\'entretien sera remis Ã  zÃ©ro.',
        en: 'Do you really want to record a complete cleaning for this weapon? The maintenance counter will be reset to zero.',
        de: 'MÃ¶chten Sie wirklich eine vollstÃ¤ndige Reinigung fÃ¼r diese Waffe aufzeichnen? Der WartungszÃ¤hler wird auf Null zurÃ¼ckgesetzt.',
        it: 'Vuoi davvero registrare una pulizia completa per questa arma? Il contatore di manutenzione verrÃ  azzerato.',
        es: 'Â¿Realmente quieres registrar una limpieza completa para esta arma? El contador de mantenimiento se reiniciarÃ¡ a cero.',
      );

  String get cleaningRecordedSuccess => _pick(
        fr: 'Entretien enregistrÃ© avec succÃ¨s.',
        en: 'Maintenance recorded successfully.',
        de: 'Wartung erfolgreich erfasst.',
        it: 'Manutenzione registrata con successo.',
        es: 'Mantenimiento registrado con Ã©xito.',
      );

  String diagnosticDecisionCauses(String decision) {
    switch (decision) {
      case 'PERCUTEUR / DÃ‰VERROUILLAGE':
        return _pick(
          fr: "Absence d'empreinte de percussion sur l'amorce. La percussion n'atteint pas la cartouche : verrouillage incomplet, sÃ»retÃ© passive, percuteur empÃªchÃ© (encrassement/casse), ressort de percuteur.",
          en: 'No firing pin mark on the primer. The firing system is not reaching the round: incomplete lockup, passive safety, obstructed/broken firing pin, or firing pin spring issue.',
          de: 'Kein Schlagbolzenabdruck auf dem ZÃ¼ndhÃ¼tchen. Das Schlagsystem erreicht die Patrone nicht: unvollstÃ¤ndige Verriegelung, passive Sicherung, blockierter/gebrochener Schlagbolzen oder Schlagbolzenfeder.',
          it: "Assenza di impronta di percussione sull'innesco. La percussione non raggiunge la cartuccia: chiusura incompleta, sicura passiva, percussore bloccato/rotto o molla del percussore.",
          es: 'Ausencia de marca de percusiÃ³n en el pistÃ³n. La percusiÃ³n no alcanza el cartucho: cierre incompleto, seguro pasivo, percutor bloqueado/roto o resorte del percutor.',
        );
      case 'PERCUSSION FAIBLE / HORS AXE':
        return _pick(
          fr: 'Percussion prÃ©sente mais faible/dÃ©centrÃ©e : verrouillage incomplet, accompagnement de culasse, ressort fatiguÃ©, canal percuteur encrassÃ©, piÃ¨ce usÃ©e.',
          en: 'The firing pin mark is present but weak/off-center: incomplete lockup, riding the slide, tired spring, dirty firing pin channel, or worn part.',
          de: 'Der Schlagbolzenabdruck ist vorhanden, aber schwach/auÃŸer Mitte: unvollstÃ¤ndige Verriegelung, Begleiten des Verschlusses, ermÃ¼dete Feder, verschmutzter Schlagbolzenkanal oder verschlissenes Teil.',
          it: 'Percussione presente ma debole/decentrata: chiusura incompleta, accompagnamento del carrello, molla affaticata, canale del percussore sporco o componente usurato.',
          es: 'La percusiÃ³n estÃ¡ presente pero es dÃ©bil/descentrada: cierre incompleto, acompaÃ±amiento de la corredera, muelle fatigado, canal del percutor sucio o pieza desgastada.',
        );
      case 'MUNITION / LOT DÃ‰FECTUEUX':
        return _pick(
          fr: 'Cartouche percutÃ©e correctement mais pas de dÃ©part : amorce/poudre dÃ©fectueuse, lot dÃ©faillant, stockage inadÃ©quat.',
          en: 'The round was struck correctly but did not fire: defective primer/powder, bad lot, or improper storage.',
          de: 'Die Patrone wurde korrekt getroffen, hat aber nicht gezÃ¼ndet: defektes ZÃ¼ndhÃ¼tchen/Pulver, fehlerhaftes Los oder unsachgemÃ¤ÃŸe Lagerung.',
          it: 'Cartuccia percossa correttamente ma non partita: innesco/polvere difettosi, lotto difettoso o conservazione inadeguata.',
          es: 'Cartucho percutido correctamente pero sin disparo: pistÃ³n/pÃ³lvora defectuosos, lote defectuoso o almacenamiento inadecuado.',
        );
      case 'DÃ‰FAUT DE CHAMBRAGE / ALIMENTATION':
        return _pick(
          fr: "Cartouche pas correctement prÃ©sentÃ©e/chambrÃ©e : problÃ¨me d'alimentation, magasin/chargeur, rampe, ressort, tenue de l'arme, saletÃ©s.",
          en: 'The round is not feeding/chambering correctly: feeding issue, magazine, feed ramp, spring, grip, or debris.',
          de: 'Die Patrone wird nicht korrekt zugefÃ¼hrt/ins Patronenlager gebracht: ZufÃ¼hrstÃ¶rung, Magazin, ZufÃ¼hrrampe, Feder, Waffenhaltung oder Verschmutzung.',
          it: "Cartuccia non presentata/camerata correttamente: problema di alimentazione, caricatore, rampa, molla, impugnatura o sporco.",
          es: 'El cartucho no se presenta/recÃ¡mara correctamente: problema de alimentaciÃ³n, cargador, rampa, muelle, sujeciÃ³n o suciedad.',
        );
      case 'LONG FEU (DANGER) â€” MUNITION DÃ‰FECTUEUSE':
        return _pick(
          fr: "Long feu : mise Ã  feu retardÃ©e. Cartouche dÃ©fectueuse (amorÃ§age/poudre). Risque d'accident grave si ouverture prÃ©maturÃ©e.",
          en: 'Hangfire: delayed ignition. Defective round (primer/powder). Serious injury risk if opened too early.',
          de: 'Hangfire: verzÃ¶gerte ZÃ¼ndung. Defekte Patrone (ZÃ¼ndsatz/Pulver). Ernstes Unfallrisiko bei zu frÃ¼hem Ã–ffnen.',
          it: 'Fuoco ritardato: accensione ritardata. Cartuccia difettosa (innesco/polvere). Grave rischio se aperta troppo presto.',
          es: 'Fuego retardado: igniciÃ³n tardÃ­a. Cartucho defectuoso (pistÃ³n/pÃ³lvora). Riesgo grave si se abre demasiado pronto.',
        );
      case 'INCIDENT MUNITION â€” PROCÃ‰DURE LONG FEU':
        return _pick(
          fr: 'Incident compatible munition (ratÃ©/irrÃ©gularitÃ©) avec risque de long feu non exclu.',
          en: 'Ammunition-related incident (misfire/irregularity) where hangfire cannot be ruled out.',
          de: 'Munitionsbedingte StÃ¶rung (FehlzÃ¼ndung/UnregelmÃ¤ÃŸigkeit), bei der ein Hangfire nicht ausgeschlossen werden kann.',
          it: 'Anomalia compatibile con la munizione (mancato sparo/irregolaritÃ ) con rischio di fuoco ritardato non escluso.',
          es: 'Incidente compatible con la municiÃ³n (fallo/irregularidad) con riesgo de fuego retardado no descartado.',
        );
      case 'FACTEUR HUMAIN (DOIGT / SÃ›RETÃ‰ / MANIPULATION)':
        return _pick(
          fr: 'Erreur de manipulation : doigt sur dÃ©tente, sÃ»retÃ© mal gÃ©rÃ©e, manipulation sous stress, accompagnement de culasse, approvisionnement.',
          en: 'Handling error: finger on trigger, poor safety management, stress manipulation, riding the slide, or loading issue.',
          de: 'Bedienfehler: Finger am Abzug, schlechte Sicherungshandhabung, Stressmanipulation, Begleiten des Verschlusses oder Ladefehler.',
          it: 'Errore di manipolazione: dito sul grilletto, gestione errata della sicura, manipolazione sotto stress, accompagnamento del carrello o errore di alimentazione.',
          es: 'Error de manipulaciÃ³n: dedo en el gatillo, mala gestiÃ³n del seguro, manipulaciÃ³n bajo estrÃ©s, acompaÃ±amiento de la corredera o error de carga.',
        );
      case 'ALIMENTATION / CHARGEUR':
        return _pick(
          fr: 'Enrayage liÃ© au chargeur/magasin : ressort, lÃ¨vres, saletÃ©s, prÃ©sentation des cartouches, remplissage.',
          en: 'Jam related to the magazine: spring, feed lips, dirt, cartridge presentation, or loading.',
          de: 'StÃ¶rung im Zusammenhang mit dem Magazin: Feder, Lippen, Schmutz, PatronenzufÃ¼hrung oder Ladevorgang.',
          it: 'Inceppamento legato al caricatore: molla, labbri, sporco, presentazione delle cartucce o riempimento.',
          es: 'Atasco relacionado con el cargador: muelle, labios, suciedad, presentaciÃ³n de cartuchos o carga.',
        );
      case 'EXTRACTION / Ã‰JECTION':
        return _pick(
          fr: 'ProblÃ¨me extracteur/Ã©jecteur, chambre encrassÃ©e, pression anormale, Ã©tui dÃ©formÃ©.',
          en: 'Extractor/ejector problem, dirty chamber, abnormal pressure, or deformed case.',
          de: 'Problem mit Auszieher/Auswerfer, verschmutztes Patronenlager, abnormaler Druck oder deformierte HÃ¼lse.',
          it: 'Problema di estrattore/espulsore, camera sporca, pressione anomala o bossolo deformato.',
          es: 'Problema de extractor/expulsor, recÃ¡mara sucia, presiÃ³n anormal o vaina deformada.',
        );
      case 'CHAMBRAGE / RETOUR EN BATTERIE':
        return _pick(
          fr: "Retour en batterie incomplet : saletÃ©s, lubrification inadaptÃ©e, ressort rÃ©cupÃ©rateur, cartouches hors cotes, tenue de l'arme.",
          en: 'Incomplete return to battery: debris, improper lubrication, recoil spring, out-of-spec rounds, or grip issue.',
          de: 'UnvollstÃ¤ndige Verriegelung: Schmutz, ungeeignete Schmierung, SchlieÃŸfeder, Patronen auÃŸerhalb der Toleranz oder Haltefehler.',
          it: 'Ritorno in batteria incompleto: sporco, lubrificazione inadeguata, molla di recupero, cartucce fuori tolleranza o impugnatura.',
          es: 'Retorno a baterÃ­a incompleto: suciedad, lubricaciÃ³n inadecuada, muelle recuperador, cartuchos fuera de tolerancia o problema de sujeciÃ³n.',
        );
      case 'FACTEUR HUMAIN / APPUI':
        return _pick(
          fr: "Baisse de prÃ©cision liÃ©e Ã  l'appui/tenue/lÃ¢cher/cadence/fatigue plutÃ´t qu'Ã  l'arme.",
          en: 'Accuracy loss is more likely due to rest/hold/trigger/cadence/fatigue than the weapon.',
          de: 'Der PrÃ¤zisionsverlust hÃ¤ngt eher mit Auflage/Anschlag/Abzug/Rhythmus/MÃ¼digkeit zusammen als mit der Waffe.',
          it: "Il calo di precisione Ã¨ piÃ¹ probabilmente dovuto ad appoggio/impugnatura/scatto/cadenza/fatica che all'arma.",
          es: 'La pÃ©rdida de precisiÃ³n probablemente se debe mÃ¡s al apoyo/sujeciÃ³n/disparo/cadencia/fatiga que al arma.',
        );
      case 'MUNITION (LOT / TYPE)':
        return _pick(
          fr: 'Baisse de prÃ©cision liÃ©e Ã  la munition : lot variable, projectile inadaptÃ©, poids/vitesse non optimale, stockage.',
          en: 'Accuracy loss linked to ammunition: inconsistent lot, unsuitable projectile, non-optimal weight/velocity, or storage.',
          de: 'PrÃ¤zisionsverlust durch die Munition: schwankendes Los, ungeeignetes Geschoss, nicht optimales Gewicht/Geschwindigkeit oder Lagerung.',
          it: 'Calo di precisione legato alla munizione: lotto variabile, proiettile inadatto, peso/velocitÃ  non ottimali o conservazione.',
          es: 'PÃ©rdida de precisiÃ³n ligada a la municiÃ³n: lote variable, proyectil inadecuado, peso/velocidad no Ã³ptimos o almacenamiento.',
        );
      case 'OPTique / MONTAGE DESSERRÃ‰':
        return _pick(
          fr: 'DÃ©rive ou dispersion due Ã  un montage/optique desserrÃ© ou mal montÃ©.',
          en: 'Shift or spread caused by a loose or improperly mounted optic/mount.',
          de: 'Treffpunktverlagerung oder Streuung durch eine lockere oder falsch montierte Optik/Montage.',
          it: 'Deriva o dispersione dovuta a ottica/montaggio allentati o montati male.',
          es: 'Deriva o dispersiÃ³n debida a una Ã³ptica/montaje flojo o mal instalado.',
        );
      case 'ENCRASSEMENT / ENTRETIEN':
        return _pick(
          fr: 'Encrassement canon/chambre, entretien insuffisant, lubrification inadaptÃ©e.',
          en: 'Fouling in barrel/chamber, insufficient maintenance, or improper lubrication.',
          de: 'Verschmutzung von Lauf/Patronenlager, unzureichende Wartung oder ungeeignete Schmierung.',
          it: 'Incrostazioni in canna/camera, manutenzione insufficiente o lubrificazione inadeguata.',
          es: 'Suciedad en caÃ±Ã³n/recÃ¡mara, mantenimiento insuficiente o lubricaciÃ³n inadecuada.',
        );
      default:
        return _pick(
          fr: 'Plusieurs causes possibles (munition, mÃ©canique, environnement, facteur humain).',
          en: 'Several causes are possible (ammunition, mechanics, environment, human factor).',
          de: 'Mehrere Ursachen sind mÃ¶glich (Munition, Mechanik, Umgebung, menschlicher Faktor).',
          it: 'Sono possibili diverse cause (munizione, meccanica, ambiente, fattore umano).',
          es: 'Son posibles varias causas (municiÃ³n, mecÃ¡nica, entorno, factor humano).',
        );
    }
  }

  String diagnosticDecisionActions(String decision) {
    switch (decision) {
      case 'PERCUTEUR / DÃ‰VERROUILLAGE':
        return _pick(
          fr: 'Canon dirigÃ© en zone sÃ»re. VÃ©rifier sÃ»retÃ© / verrouillage complet. ContrÃ´ler percuteur (propretÃ©, libre course) et ressort. Ne pas forcer. Armurier si doute ou rÃ©pÃ©tition.',
          en: 'Keep the muzzle in a safe direction. Check safety and full lockup. Inspect the firing pin (cleanliness, free movement) and spring. Do not force it. See a gunsmith if unsure or repeated.',
          de: 'MÃ¼ndung in sichere Richtung halten. Sicherung und vollstÃ¤ndige Verriegelung prÃ¼fen. Schlagbolzen (Sauberkeit, freie Bewegung) und Feder kontrollieren. Nichts erzwingen. Bei Zweifel oder Wiederholung zum BÃ¼chsenmacher.',
          it: 'Mantieni la volata in direzione sicura. Verifica sicura e completa chiusura. Controlla percussore (pulizia, corsa libera) e molla. Non forzare. Armaiolo in caso di dubbio o ripetizione.',
          es: 'MantÃ©n el caÃ±Ã³n en direcciÃ³n segura. Verifica seguro y cierre completo. Controla el percutor (limpieza, libre recorrido) y el muelle. No fuerces. Armero si hay dudas o se repite.',
        );
      case 'PERCUSSION FAIBLE / HORS AXE':
        return _pick(
          fr: 'VÃ©rifier fermeture/verrouillage sans accompagner. Nettoyer canal percuteur si autorisÃ©. Tester avec autre munition/lot. Armurier si persistant.',
          en: 'Check closure/lockup without riding the slide. Clean the firing pin channel if allowed. Test with different ammo/lot. See a gunsmith if it persists.',
          de: 'Verschluss/Verriegelung prÃ¼fen, ohne den Verschluss zu begleiten. Schlagbolzenkanal reinigen, falls zulÃ¤ssig. Mit anderer Munition/anderem Los testen. Bei Fortbestehen zum BÃ¼chsenmacher.',
          it: 'Verifica chiusura/bloccaggio senza accompagnare il carrello. Pulisci il canale del percussore se consentito. Prova con altra munizione/lotto. Armaiolo se persiste.',
          es: 'Verifica cierre/bloqueo sin acompaÃ±ar la corredera. Limpia el canal del percutor si estÃ¡ permitido. Prueba con otra municiÃ³n/lote. Armero si persiste.',
        );
      case 'MUNITION / LOT DÃ‰FECTUEUX':
        return _pick(
          fr: 'Mettre de cÃ´tÃ© le lot. Essayer une autre boÃ®te/lot/type. Ne pas manipuler inutilement les cartouches du mÃªme lot si incident rÃ©pÃ©tÃ©. Signaler au fabricant si possible.',
          en: 'Set the lot aside. Try another box/lot/type. Do not unnecessarily handle rounds from the same lot if the incident repeats. Report it to the manufacturer if possible.',
          de: 'Das Los beiseitelegen. Eine andere Schachtel/ein anderes Los/einen anderen Typ probieren. Patronen desselben Loses bei Wiederholung nicht unnÃ¶tig handhaben. Wenn mÃ¶glich dem Hersteller melden.',
          it: 'Metti da parte il lotto. Prova unâ€™altra scatola/lotto/tipo. Non maneggiare inutilmente le cartucce dello stesso lotto se il problema si ripete. Segnala al produttore se possibile.',
          es: 'Aparta el lote. Prueba otra caja/lote/tipo. No manipules innecesariamente los cartuchos del mismo lote si el incidente se repite. Notifica al fabricante si es posible.',
        );
      case 'DÃ‰FAUT DE CHAMBRAGE / ALIMENTATION':
        return _pick(
          fr: 'VÃ©rifier approvisionnement, chargeur, lÃ¨vres/ressort, propretÃ© (chambre/rampe). Tester autre chargeur et munition. Nettoyage + lubrification adaptÃ©e.',
          en: 'Check feeding, magazine, lips/spring, and cleanliness (chamber/feed ramp). Test another magazine and ammo. Clean and lubricate appropriately.',
          de: 'ZufÃ¼hrung, Magazin, Lippen/Feder und Sauberkeit (Patronenlager/ZufÃ¼hrrampe) prÃ¼fen. Ein anderes Magazin und andere Munition testen. Reinigen und passend schmieren.',
          it: 'Verifica alimentazione, caricatore, labbri/molla e pulizia (camera/rampa). Prova un altro caricatore e altra munizione. Pulisci e lubrifica correttamente.',
          es: 'Verifica alimentaciÃ³n, cargador, labios/muelle y limpieza (recÃ¡mara/rampa). Prueba otro cargador y otra municiÃ³n. Limpia y lubrica adecuadamente.',
        );
      case 'LONG FEU (DANGER) â€” MUNITION DÃ‰FECTUEUSE':
        return _pick(
          fr: 'Maintenir en joue en direction sÃ»re au moins 15 secondes. Ouvrir ensuite prudemment. Isoler la munition. Ne plus tirer les cartouches du mÃªme lot. Armurier si doute sur l\'arme.',
          en: 'Keep aimed in a safe direction for at least 15 seconds. Then open carefully. Isolate the round. Do not fire rounds from the same lot. See a gunsmith if unsure about the weapon.',
          de: 'Mindestens 15 Sekunden in sichere Richtung gerichtet halten. Danach vorsichtig Ã¶ffnen. Die Patrone isolieren. Keine Patronen desselben Loses mehr verschieÃŸen. Bei Zweifel an der Waffe zum BÃ¼chsenmacher.',
          it: 'Mantieni puntato in direzione sicura per almeno 15 secondi. Poi apri con cautela. Isola la cartuccia. Non sparare altre cartucce dello stesso lotto. Armaiolo se hai dubbi sullâ€™arma.',
          es: 'MantÃ©n apuntado en direcciÃ³n segura al menos 15 segundos. Luego abre con cuidado. AÃ­sla el cartucho. No dispares mÃ¡s cartuchos del mismo lote. Armero si dudas del arma.',
        );
      case 'INCIDENT MUNITION â€” PROCÃ‰DURE LONG FEU':
        return _pick(
          fr: 'Appliquer la procÃ©dure long feu par prÃ©caution. Changer de lot/type de munition. Stockage sec/constant. Armurier si rÃ©pÃ©titif.',
          en: 'Apply hangfire procedure as a precaution. Change ammo lot/type. Keep storage dry and stable. See a gunsmith if repeated.',
          de: 'Vorsorglich das Hangfire-Verfahren anwenden. Los/Typ der Munition wechseln. Trocken und konstant lagern. Bei Wiederholung zum BÃ¼chsenmacher.',
          it: 'Applica la procedura per fuoco ritardato per precauzione. Cambia lotto/tipo di munizione. Conservazione asciutta e stabile. Armaiolo se si ripete.',
          es: 'Aplica el procedimiento de fuego retardado por precauciÃ³n. Cambia lote/tipo de municiÃ³n. Almacenamiento seco y estable. Armero si se repite.',
        );
      case 'FACTEUR HUMAIN (DOIGT / SÃ›RETÃ‰ / MANIPULATION)':
        return _pick(
          fr: 'Revenir aux fondamentaux : doigt hors dÃ©tente, sÃ»retÃ©, procÃ©dures de chargement/dÃ©chargement. Faire contrÃ´ler la prise en main. Si dÃ©part intempestif avÃ©rÃ© : immobiliser et armurier.',
          en: 'Go back to the basics: finger off trigger, safety, loading/unloading procedures. Have your handling checked. If unintended discharge is confirmed: stop using it and see a gunsmith.',
          de: 'Zu den Grundlagen zurÃ¼ckkehren: Finger weg vom Abzug, Sicherung, Lade-/Entladeverfahren. Handhabung Ã¼berprÃ¼fen lassen. Bei bestÃ¤tigter ungewollter Schussabgabe: auÃŸer Betrieb nehmen und zum BÃ¼chsenmacher.',
          it: 'Torna alle basi: dito fuori dal grilletto, sicura, procedure di caricamento/scaricamento. Fatti controllare la presa. Se la partenza intempestiva Ã¨ confermata: immobilizza e armaiolo.',
          es: 'Vuelve a los fundamentos: dedo fuera del gatillo, seguro, procedimientos de carga/descarga. Haz revisar la manipulaciÃ³n. Si se confirma un disparo intempestivo: inmoviliza y armero.',
        );
      case 'ALIMENTATION / CHARGEUR':
        return _pick(
          fr: 'Tester un autre chargeur. Nettoyer chargeur/magasin. Inspecter lÃ¨vres/ressort. Ã‰viter munitions abÃ®mÃ©es. Armurier si dÃ©formation/usure.',
          en: 'Test another magazine. Clean the magazine. Inspect feed lips and spring. Avoid damaged ammo. See a gunsmith if deformed or worn.',
          de: 'Ein anderes Magazin testen. Magazin reinigen. Lippen und Feder prÃ¼fen. BeschÃ¤digte Munition vermeiden. Bei Verformung/VerschleiÃŸ zum BÃ¼chsenmacher.',
          it: 'Prova un altro caricatore. Pulisci il caricatore. Ispeziona labbri e molla. Evita munizioni danneggiate. Armaiolo in caso di deformazione/usura.',
          es: 'Prueba otro cargador. Limpia el cargador. Inspecciona labios y muelle. Evita municiÃ³n daÃ±ada. Armero si hay deformaciÃ³n/desgaste.',
        );
      case 'EXTRACTION / Ã‰JECTION':
        return _pick(
          fr: 'ArrÃªter si rÃ©pÃ©titif. Nettoyage chambre. ContrÃ´le extracteur/Ã©jecteur. Changer de munition. Armurier si blocage/Ã©tuis anormaux.',
          en: 'Stop if it repeats. Clean the chamber. Check extractor/ejector. Change ammunition. See a gunsmith for jams or abnormal cases.',
          de: 'Bei Wiederholung stoppen. Patronenlager reinigen. Auszieher/Auswerfer prÃ¼fen. Munition wechseln. Bei Blockaden oder abnormalen HÃ¼lsen zum BÃ¼chsenmacher.',
          it: 'Fermati se si ripete. Pulisci la camera. Controlla estrattore/espulsore. Cambia munizione. Armaiolo in caso di blocchi o bossoli anomali.',
          es: 'Detente si se repite. Limpia la recÃ¡mara. Revisa extractor/expulsor. Cambia municiÃ³n. Armero si hay bloqueos o vainas anormales.',
        );
      case 'CHAMBRAGE / RETOUR EN BATTERIE':
        return _pick(
          fr: 'Nettoyage + lubrification adaptÃ©e. Tester autre munition. VÃ©rifier ressort. Ne pas accompagner la fermeture. Armurier si persistant.',
          en: 'Clean and lubricate correctly. Test other ammunition. Check the spring. Do not ride the closing movement. See a gunsmith if it persists.',
          de: 'Reinigen und passend schmieren. Andere Munition testen. Feder prÃ¼fen. Den SchlieÃŸvorgang nicht begleiten. Bei Fortbestehen zum BÃ¼chsenmacher.',
          it: 'Pulisci e lubrifica correttamente. Prova altra munizione. Verifica la molla. Non accompagnare la chiusura. Armaiolo se persiste.',
          es: 'Limpia y lubrica correctamente. Prueba otra municiÃ³n. Revisa el muelle. No acompaÃ±es el cierre. Armero si persiste.',
        );
      case 'FACTEUR HUMAIN / APPUI':
        return _pick(
          fr: 'Stabiliser l\'appui, cadence rÃ©guliÃ¨re, contrÃ´le dÃ©tente/visÃ©e. Faire une sÃ©rie de rÃ©fÃ©rence. Ensuite seulement investiguer munition/optique/arme.',
          en: 'Stabilize the rest, keep a regular cadence, and control trigger/sight picture. Fire a reference group first. Only then investigate ammo/optic/weapon.',
          de: 'Auflage stabilisieren, gleichmÃ¤ÃŸigen Rhythmus halten und Abzug/Zielbild kontrollieren. Erst eine Referenzserie schieÃŸen. Dann erst Munition/Optik/Waffe prÃ¼fen.',
          it: 'Stabilizza lâ€™appoggio, mantieni una cadenza regolare e controlla scatto/mira. Fai prima una serie di riferimento. Solo dopo indaga munizione/ottica/arma.',
          es: 'Estabiliza el apoyo, mantÃ©n una cadencia regular y controla gatillo/miras. Haz primero una serie de referencia. Solo despuÃ©s investiga municiÃ³n/Ã³ptica/arma.',
        );
      case 'MUNITION (LOT / TYPE)':
        return _pick(
          fr: 'Changer de lot/type. Tester un poids CIP de rÃ©fÃ©rence si semi-auto. Ã‰carter cartouches endommagÃ©es/manipulÃ©es.',
          en: 'Change lot/type. Test a reference CIP bullet weight if semi-auto. Discard damaged or mishandled rounds.',
          de: 'Los/Typ wechseln. Bei Selbstladern ein CIP-Referenzgewicht testen. BeschÃ¤digte oder unsachgemÃ¤ÃŸ behandelte Patronen aussortieren.',
          it: 'Cambia lotto/tipo. Prova un peso CIP di riferimento se semiautomatica. Scarta cartucce danneggiate o maneggiate male.',
          es: 'Cambia lote/tipo. Prueba un peso CIP de referencia si es semiautomÃ¡tica. Descarta cartuchos daÃ±ados o manipulados.',
        );
      case 'OPTique / MONTAGE DESSERRÃ‰':
        return _pick(
          fr: 'VÃ©rifier couple de serrage, colliers/rail, frein filet si appropriÃ©. VÃ©rifier rÃ©glages. Faire un contrÃ´le aprÃ¨s quelques tirs.',
          en: 'Check torque, rings/rail, and thread locker if appropriate. Verify adjustments. Re-check after a few shots.',
          de: 'Anzugsmoment, Ringe/Schiene und ggf. Schraubensicherung prÃ¼fen. Einstellungen kontrollieren. Nach einigen SchÃ¼ssen erneut prÃ¼fen.',
          it: 'Verifica coppia di serraggio, anelli/slitta e frenafiletti se opportuno. Controlla le regolazioni. Ricontrolla dopo alcuni colpi.',
          es: 'Verifica par de apriete, anillas/carril y fijador de roscas si procede. Revisa los ajustes. Vuelve a comprobar tras algunos disparos.',
        );
      case 'ENCRASSEMENT / ENTRETIEN':
        return _pick(
          fr: 'Nettoyage en profondeur (chambre/canon/culasse) puis lubrification lÃ©gÃ¨re adaptÃ©e. Tester Ã  nouveau.',
          en: 'Deep clean the chamber/barrel/bolt, then apply proper light lubrication. Test again.',
          de: 'Patronenlager/Lauf/Verschluss grÃ¼ndlich reinigen und anschlieÃŸend passend leicht schmieren. Erneut testen.',
          it: 'Pulisci a fondo camera/canna/otturatore, poi applica una leggera lubrificazione adeguata. Prova di nuovo.',
          es: 'Limpia a fondo recÃ¡mara/caÃ±Ã³n/cierre y aplica una lubricaciÃ³n ligera adecuada. Prueba de nuevo.',
        );
      default:
        return _pick(
          fr: 'ProcÃ©der par Ã©limination : munition (autre lot) -> propretÃ©/lubrification -> chargeur -> contrÃ´le armurier si le problÃ¨me persiste.',
          en: 'Use elimination: ammunition (different lot) -> cleanliness/lubrication -> magazine -> gunsmith inspection if the problem persists.',
          de: 'Per Ausschluss vorgehen: Munition (anderes Los) -> Sauberkeit/Schmierung -> Magazin -> Kontrolle durch BÃ¼chsenmacher, wenn das Problem bleibt.',
          it: 'Procedi per esclusione: munizione (altro lotto) -> pulizia/lubrificazione -> caricatore -> controllo armaiolo se il problema persiste.',
          es: 'Procede por descarte: municiÃ³n (otro lote) -> limpieza/lubricaciÃ³n -> cargador -> revisiÃ³n por armero si el problema persiste.',
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

  // Milliradian tool (Formule du milliÃ¨me)
  String get milliemeToolTitle => _pick(
fr: 'FORMULE DU MILLIÃˆME',
en: 'MIL FORMULA',
de: 'MIL-FORMEL',
it: 'FORMULA DEL MIL',
es: 'FÃ“RMULA DEL MIL',
      );

  String get milliemeToolSubtitle => _pick(
fr: 'Calculez une distance facilement',
en: 'Calculate a distance easily',
de: 'Berechne eine Distanz einfach',
it: 'Calcola una distanza facilmente',
es: 'Calcula una distancia fÃ¡cilmente',
      );

  String get milliemeImperialWarning => _pick(
        fr: 'Attention : ce calcul reste exprimÃ© en systÃ¨me mÃ©trique (mÃ¨tres et milliÃ¨mes).',
        en: 'Warning: this calculation still uses metric units (meters and mils).',
        de: 'Achtung: Diese Berechnung verwendet weiterhin metrische Einheiten (Meter und Millirad).',
        it: 'Attenzione: questo calcolo usa comunque il sistema metrico (metri e mil).',
        es: 'AtenciÃ³n: este cÃ¡lculo sigue usando el sistema mÃ©trico (metros y mil).',
      );

  String get milliemeFrontLabel => _pick(
        fr: 'Front (taille rÃ©elle)',
        en: 'Front (real size)',
        de: 'Front (RealgrÃ¶ÃŸe)',
        it: 'Frontale (dimensione reale)',
        es: 'Frente (tamaÃ±o real)',
      );

  String get milliemeFrontField => _pick(
        fr: 'Front (m)',
        en: 'Front (m)',
        de: 'Front (m)',
        it: 'Frontale (m)',
        es: 'Frente (m)',
      );

  String get milliemeMilliemeLabel => _pick(
fr: 'L\'angle sous lequel je le vois',
en: 'Viewing angle',
de: 'Sichtwinkel',
it: 'Angolo di visione',
es: 'Ãngulo de visiÃ³n',
      );

  String get milliemeMilliemeField => _pick(
fr: 'MilliÃ¨mes (â‚¥)',
en: 'Milliradians (â‚¥)',
de: 'Milliradiant (â‚¥)',
it: 'Milliradianti (â‚¥)',
es: 'Milirradianes (â‚¥)',
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
        es: 'PREAJUSTES RÃPIDOS',
      );

  String get milliemeResetAll => _pick(
        fr: 'RÃ‰INITIALISER TOUT',
        en: 'RESET ALL',
        de: 'ALLES ZURÃœCKSETZEN',
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
        de: 'Feld lÃ¶schen',
        it: 'Pulisci campo',
        es: 'Borrar campo',
      );

  String get milliemeHelpFormula => _pick(
        fr: 'Rappel : F = m Ã— D (F en m, D en km, m en milliÃ¨mes). Distance calculÃ©e en mÃ¨tres.',
        en: 'Reminder: F = m Ã— D (F in m, D in km, m in mils). Distance shown in meters.',
        de: 'Erinnerung: F = m Ã— D (F in m, D in km, m in Millirad). Entfernung in Metern.',
        it: 'Promemoria: F = m Ã— D (F in m, D in km, m in mil). Distanza mostrata in metri.',
        es: 'Recordatorio: F = m Ã— D (F en m, D en km, m en mil). Distancia en metros.',
      );

  // Milliradian tool preset labels
  String get milliemePresetPylonHeight => _pick(
        fr: 'PylÃ´ne',
        en: 'Pylon',
        de: 'Mast',
        it: 'Palo',
        es: 'Pilona',
      );

  String get milliemePresetPylonWidth => _pick(
        fr: 'PylÃ´ne',
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
        es: 'CamiÃ³n',
      );

  String get milliemePresetTruckWidth => _pick(
        fr: 'Camion',
        en: 'Truck',
        de: 'Lkw',
        it: 'Camion',
        es: 'CamiÃ³n',
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
        fr: 'TÃªte',
        en: 'Head',
        de: 'Kopf',
        it: 'Testa',
        es: 'Cabeza',
      );

  String get milliemePresetHeadWidth => _pick(
        fr: 'TÃªte',
        en: 'Head',
        de: 'Kopf',
        it: 'Testa',
        es: 'Cabeza',
      );

  String get milliemePresetDoorHeight => _pick(
        fr: 'Porte',
        en: 'Door',
        de: 'TÃ¼r',
        it: 'Porta',
        es: 'Puerta',
      );

  String get milliemePresetDoorWidth => _pick(
        fr: 'Porte',
        en: 'Door',
        de: 'TÃ¼r',
        it: 'Porta',
        es: 'Puerta',
      );

  String get milliemePresetWindowHeight => _pick(
        fr: 'FenÃªtre',
        en: 'Window',
        de: 'Fenster',
        it: 'Finestra',
        es: 'Ventana',
      );

  String get milliemePresetWindowWidth => _pick(
        fr: 'FenÃªtre',
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
        es: 'Ãrbol',
      );

  String get milliemePresetTreeWidth => _pick(
        fr: 'Arbre',
        en: 'Tree',
        de: 'Baum',
        it: 'Albero',
        es: 'Ãrbol',
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
        fr: 'SÃ©ances',
        en: 'Sessions',
        de: 'Sitzungen',
        it: 'Sessioni',
        es: 'Sesiones',
      );

  String get navInventoryLabel => _pick(
        fr: 'MatÃ©riel',
        en: 'Equipment',
        de: 'AusrÃ¼stung',
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
        fr: 'RÃ©glages',
        en: 'Settings',
        de: 'Einstellungen',
        it: 'Impostazioni',
        es: 'Ajustes',
      );

  String get confirm => _pick(
            fr: 'CONFIRMER',
        en: 'CONFIRM',
        de: 'BESTÃ„TIGEN',
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
  String get colorPodTotalDuration => _pick(fr: 'Durée totale de l\\'exercice', en: 'Total exercise duration', de: 'Gesamtdauer der Übung', it: 'Durata totale dell\\'esercizio', es: 'Duración total del ejercicio');
  String get colorPodLaunch => _pick(fr: 'LANCER', en: 'START', de: 'STARTEN', it: 'AVVIA', es: 'INICIAR');
  String get colorPodPrepare => _pick(fr: 'Préparez-vous', en: 'Get ready', de: 'Mach dich bereit', it: 'Preparati', es: 'Prepárate');
  String get colorPodSecondsLeft => _pick(fr: 'secondes restantes', en: 'seconds left', de: 'Sekunden übrig', it: 'secondi rimanenti', es: 'segundos restantes');
  String get colorPodStop => _pick(fr: 'STOP', en: 'STOP', de: 'STOP', it: 'STOP', es: 'STOP');
  String get colorPodResults => _pick(fr: 'RÉSULTATS', en: 'RESULTS', de: 'ERGEBNISSE', it: 'RISULTATI', es: 'RESULTADOS');
  String colorPodTotal(int n) => _pick(fr: '\ apparitions au total', en: '\ total appearances', de: '\ Erscheinungen insgesamt', it: '\ apparizioni totali', es: '\ apariciones en total');
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
