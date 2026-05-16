part of 'app_strings.dart';

extension AppStringsTimer on AppStrings {
  // --- Timer & Microphone Settings ---

  String get timerMicDisclaimerShort => _pick(
    fr: 'Le micro est utilisé uniquement pendant ce mode pour détecter un signal sonore fort. Aucun son n\'est enregistré ni envoyé.',
    en: 'The microphone is used only in this mode to detect a loud sound. No audio is recorded or sent.',
    de: 'Das Mikrofon wird nur in diesem Modus verwendet, um ein lautes Geräusch zu erkennen. Es wird kein Audio aufgezeichnet oder übertragen.',
    it: 'Il microfono viene usato solo in questa modalità per rilevare un suono forte. Nessun audio viene registrato o inviato.',
    es: 'El micrófono se usa solo en este modo para detectar un sonido fuerte. No se graba ni se envía audio.',
  );

  String get timerMicConfirmationTitle => _pick(
    fr: 'Activation du microphone',
    en: 'Microphone activation',
    de: 'Mikrofonaktivierung',
    it: 'Attivazione del microfono',
    es: 'Activación del micrófono',
  );

  String get timerMicConfirmationMessage => _pick(
    fr: 'Ce mode utilise le microphone du téléphone pour détecter un signal sonore pour le timer.\n\nAucun audio n\'est enregistré, stocké ou transmis.\n\nVoulez-vous continuer ?',
    en: 'This mode uses the phone microphone to detect a sound signal for the timer.\n\nNo audio is recorded, stored, or transmitted.\n\nDo you want to continue?',
    de: 'Dieser Modus verwendet das Telefonmikrofon, um ein Tonsignal für den Timer zu erkennen.\n\nKein Audio wird aufgenommen, gespeichert oder übertragen.\n\nMöchten Sie fortfahren?',
    it: 'Questa modalità utilizza il microfono del telefono per rilevare un segnale sonoro per il timer.\n\nNessun audio viene registrato, memorizzato o trasmesso.\n\nVuoi continuare?',
    es: 'Este modo usa el micrófono del teléfono para detectar una señal sonora para el temporizador.\n\nNo se graba, almacena ni transmite ningún audio.\n\n¿Desea continuar?',
  );

  String get timerMicConfirmationContinue => _pick(
    fr: 'Continuer',
    en: 'Continue',
    de: 'Fortfahren',
    it: 'Continua',
    es: 'Continuar',
  );

  String get timerMicConfirmationCancel => _pick(
    fr: 'Annuler',
    en: 'Cancel',
    de: 'Abbrechen',
    it: 'Annulla',
    es: 'Cancelar',
  );

  String get timerStartDelayLabel => _pick(
    fr: 'Délai avant départ (s)',
    en: 'Start delay (s)',
    de: 'Startverzögerung (s)',
    it: 'Ritardo di avvio (s)',
    es: 'Retardo de inicio (s)',
  );

  String get timerParTimeLabel => _pick(
    fr: 'Par time (s)',
    en: 'Par time (s)',
    de: 'Par-Zeit (s)',
    it: 'Par time (s)',
    es: 'Par time (s)',
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
    fr: 'Activer la détection sonore',
    en: 'Enable sound detection',
    de: 'Geräuscherkennung aktivieren',
    it: 'Attiva rilevamento sonoro',
    es: 'Activar detección sonora',
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

  String get timerSensitivityFine =>
      _pick(fr: 'Fine', en: 'Fine', de: 'Fein', it: 'Fine', es: 'Fina');

  String get timerSensitivityHint => _pick(
    fr: 'Plus la sensibilité est fine, plus la détection peut réagir aux bruits ambiants.',
    en: 'The finer the sensitivity, the more it may react to ambient noise.',
    de: 'Je feiner die Empfindlichkeit, desto eher kann die Erkennung auf Umgebungsgeräusche reagieren.',
    it: 'Più la sensibilità è fine, più il rilevamento può reagire ai rumori ambientali.',
    es: 'Cuanto más fina la sensibilidad, más puede reaccionar al ruido ambiental.',
  );

  String get timerSensitivityLess => _pick(
    fr: '– sensible',
    en: '– sensitive',
    de: '– empfindlich',
    it: '– sensibile',
    es: '– sensible',
  );

  String get timerSensitivityMore => _pick(
    fr: '+ sensible',
    en: '+ sensitive',
    de: '+ empfindlich',
    it: '+ sensibile',
    es: '+ sensible',
  );

  String get timerSensitivityAuto => _pick(
    fr: 'Automatique',
    en: 'Auto',
    de: 'Automatisch',
    it: 'Automatico',
    es: 'Automático',
  );

  String get timerSensitivityAutoTooltip => _pick(
    fr: 'Mesure le bruit ambiant pour régler le seuil automatiquement.',
    en: 'Measures ambient noise to set the threshold automatically.',
    de: 'Misst das Umgebungsgeräusch, um den Schwellenwert automatisch einzustellen.',
    it: 'Misura il rumore ambientale per impostare automaticamente la soglia.',
    es: 'Mide el ruido ambiente para ajustar el umbral automáticamente.',
  );

  String get timerSensitivityCalibrateTitle => _pick(
    fr: 'Calibration automatique',
    en: 'Auto calibration',
    de: 'Automatische Kalibrierung',
    it: 'Calibrazione automatica',
    es: 'Calibración automática',
  );

  String get timerSensitivityCalibrateMessage => _pick(
    fr: 'Restez immobile et silencieux pendant 3 secondes. L\'app écoute le bruit ambiant pour positionner le seuil juste au-dessus.',
    en: 'Stay still and silent for 3 seconds. The app listens to ambient noise to set the threshold just above it.',
    de: 'Bleiben Sie 3 Sekunden still. Die App hört das Umgebungsgeräusch ab, um den Schwellenwert knapp darüber zu setzen.',
    it: 'Rimani fermo e silenzioso per 3 secondi. L\'app ascolta il rumore ambientale per impostare la soglia appena sopra.',
    es: 'Permanezca quieto y en silencio durante 3 segundos. La app escucha el ruido ambiente para ajustar el umbral justo por encima.',
  );

  String get timerSensitivityCalibrateStart => _pick(
    fr: 'Démarrer',
    en: 'Start',
    de: 'Starten',
    it: 'Avvia',
    es: 'Iniciar',
  );

  String get timerSensitivityCalibrating => _pick(
    fr: 'Mesure du bruit ambiant… ne faites aucun bruit.',
    en: 'Measuring ambient noise… stay silent.',
    de: 'Umgebungsgeräusch wird gemessen … bleiben Sie still.',
    it: 'Misurazione del rumore ambientale… non fare rumore.',
    es: 'Midiendo el ruido ambiente… no haga ruido.',
  );

  String timerSensitivityCalibrationDone(int db) => _pick(
    fr: 'Calibration terminée. Seuil réglé à $db dB.',
    en: 'Calibration done. Threshold set to $db dB.',
    de: 'Kalibrierung abgeschlossen. Schwellenwert auf $db dB gesetzt.',
    it: 'Calibrazione completata. Soglia impostata a $db dB.',
    es: 'Calibración completada. Umbral ajustado a $db dB.',
  );

  String get timerSensitivityCalibrationFailed => _pick(
    fr: 'La calibration a échoué. Vérifiez l\'autorisation micro.',
    en: 'Calibration failed. Check microphone permission.',
    de: 'Kalibrierung fehlgeschlagen. Mikrofon-Berechtigung prüfen.',
    it: 'Calibrazione fallita. Verifica i permessi del microfono.',
    es: 'Calibración fallida. Verifique el permiso del micrófono.',
  );

  String get timerMicDisclaimer => _pick(
    fr: 'Le micro est utilisé uniquement sur l\'appareil pour détecter les pics sonores. Aucun son n\'est envoyé à l\'extérieur. Les performances de détection peuvent varier selon le stand et la plateforme utilisée.',
    en: 'The microphone is used only on-device to detect sound peaks. No audio is sent outside the app. Detection performance may vary depending on stand and platform.',
    de: 'Das Mikrofon wird nur auf dem Gerät verwendet, um Schalldruckspitzen zu erkennen. Es wird kein Audio nach außen gesendet. Die Erkennung kann je nach Stand und Plattform variieren.',
    it: 'Il microfono è utilizzato solo sul dispositivo per rilevare i picchi sonori. Nessun audio viene inviato all\'esterno. Le prestazioni di rilevamento possono variare a seconda dello stand e della piattaforma.',
    es: 'El micrófono se usa solo en el dispositivo para detectar picos de sonido. No se envía audio fuera de la aplicación. El rendimiento de detección puede variar según el stand y la plataforma.',
  );

  String get timerMicPermissionDenied => _pick(
    fr: 'La détection sonore nécessite l\'autorisation micro.',
    en: 'Timer requires microphone permission.',
    de: 'Die Timer-Funktion erfordert die Mikrofonberechtigung.',
    it: 'Il timer richiede l\'autorizzazione al microfono.',
    es: 'El temporizador requiere permiso de micrófono.',
  );

  String get timerStatusReady =>
      _pick(fr: 'Prêt', en: 'Ready', de: 'Bereit', it: 'Pronto', es: 'Listo');

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

  String get timerGoButton =>
      _pick(fr: 'GO', en: 'GO', de: 'GO', it: 'VAI', es: 'YA');

  String get timerPauseButton =>
      _pick(fr: 'PAUSE', en: 'PAUSE', de: 'PAUSE', it: 'PAUSE', es: 'PAUSE');

  String get timerResumeButton => _pick(
    fr: 'REPRENDRE',
    en: 'RESUME',
    de: 'FORTSETZEN',
    it: 'RIPRENDI',
    es: 'REANUDAR',
  );

  String get timerStopButton =>
      _pick(fr: 'Arrêter', en: 'Stop', de: 'Stopp', it: 'Stop', es: 'Detener');

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

  String get increaseValue => _pick(
    fr: 'Augmenter',
    en: 'Increase',
    de: 'Erhöhen',
    it: 'Aumenta',
    es: 'Aumentar',
  );

  String get decreaseValue => _pick(
    fr: 'Diminuer',
    en: 'Decrease',
    de: 'Verringern',
    it: 'Diminuisci',
    es: 'Disminuir',
  );
}
