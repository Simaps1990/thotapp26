part of 'app_strings.dart';

extension AppStringsTrainingTools on AppStrings {
  // --- Timer ---

  String get timerToolTitle => _pick(
    fr: 'TIMER',
    en: 'TIMER',
    de: 'TIMER',
    it: 'TIMER',
    es: 'TEMPORIZADOR',
  );

  String get timerToolSubtitle => _pick(
    fr: 'Gérez vos départs, par times et répétitions.',
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
    fr: 'Détection sonore',
    en: 'Sound detection',
    de: 'Geräuscherkennung',
    it: 'Rilevamento sonoro',
    es: 'Detección sonora',
  );

  String get timerModeSimple => _pick(
    fr: 'Décompte',
    en: 'Countdown',
    de: 'Countdown',
    it: 'Countdown',
    es: 'Cuenta regresiva',
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
    fr: 'Chronomètre',
    en: 'Chronometer',
    de: 'Stoppuhr',
    it: 'Cronometro',
    es: 'Cronómetro',
  );

  String get timerModeStartAndShots => _pick(
    fr: 'Multi hit',
    en: 'Multi-hit',
    de: 'Mehrfachtreffer',
    it: 'Colpi multipli',
    es: 'Impactos múltiples',
  );

  String get timerModeSimpleDescription => _pick(
    fr: 'Un bip après le délai choisi, idéal pour un départ en décompte.',
    en: 'One beep after the selected delay, ideal for a countdown start.',
    de: 'Ein Signalton nach der gewählten Verzögerung, ideal für einen Countdown-Start.',
    it: 'Un bip dopo il ritardo selezionato, ideale per una partenza in conto alla rovescia.',
    es: 'Un pitido tras el retraso seleccionado, ideal para una salida en cuenta regresiva.',
  );

  String get timerModeParTimeDescription => _pick(
    fr: 'Délai puis fenêtre d\'action (Par time) avant le bip final.',
    en: 'Delay then an action window (Par time) before the final beep.',
    de: 'Verzögerung, dann ein Aktionsfenster (Par-Zeit) vor dem letzten Signalton.',
    it: 'Ritardo poi finestra d\'azione (Par time) prima del bip finale.',
    es: 'Retraso y luego ventana de acción (Par time) antes del pitido final.',
  );

  String get timerModeRepeatDescription => _pick(
    fr: 'Plusieurs départs espacés du même délai, pour enchaîner les séries.',
    en: 'Multiple starts separated by the same delay, to chain training strings.',
    de: 'Mehrere Starts mit derselben Verzögerung, um Serien nacheinander auszuführen.',
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
    fr: 'Un bip de départ après le délai choisi, puis le chronomètre tourne jusqu\'au signal sonore détecté (ou arrêt manuel).',
    en: 'A start beep after the selected delay, then the chronometer runs until a loud sound is detected (or manual stop).',
    de: 'Ein Startsignalton nach der gewählten Verzögerung, dann läuft die Stoppuhr bis ein lautes Geräusch erkannt wird (oder manueller Stopp).',
    it: 'Un bip di partenza dopo il ritardo scelto, poi il cronometro continua fino al rilevamento di un suono forte (o stop manuale).',
    es: 'Un pitido de salida tras el retraso elegido, luego el cronómetro sigue hasta detectar un sonido fuerte (o parada manual).',
  );

  String get timerModeStartAndShotsDescription => _pick(
    fr: 'Un bip de départ après le délai choisi, puis le micro détecte chaque impact sonore et affiche les temps jusqu\'au stop.',
    en: 'A start beep after the selected delay, then the mic detects each loud sound and displays split times until you stop.',
    de: 'Ein Startsignalton nach der gewählten Verzögerung, dann erkennt das Mikro jedes laute Geräusch und zeigt die Zwischenzeiten bis zum Stopp.',
    it: 'Un bip di partenza dopo il ritardo scelto, poi il micro rileva ogni suono forte e mostra i tempi intermedi fino allo stop.',
    es: 'Un pitido de salida tras el retraso elegido, luego el mic detecta cada sonido fuerte y muestra los tiempos parciales hasta detener.',
  );

  String get timerModeSimpleExample => _pick(
    fr: 'Ex: En position, tu fixes un délai, au bip tu engages sur la cible.',
    en: 'Ex: In position, set a delay. On the beep, engage the target.',
    de: 'Bsp.: In Position, Verzögerung einstellen. Beim Signalton das Ziel angehen.',
    it: 'Es: In posizione, imposti un ritardo. Al bip ingaggi il bersaglio.',
    es: 'Ej: En posición, ajustas un retardo. Al pitido enganchas el blanco.',
  );

  String get timerModeParTimeExample => _pick(
    fr: 'Ex: Au bip tu as X secondes pour déclencher X cartouches avant le second bip.',
    en: 'Ex: On the beep, you have X seconds to shoot X rounds before the second beep.',
    de: 'Bsp.: Beim Signalton hast du X Sekunden, um X Schüsse abzugeben, bevor der zweite Signalton ertönt.',
    it: 'Es: Al bip hai X secondi per sparare X colpi prima del secondo bip.',
    es: 'Ej: Al pitido tienes X segundos para disparar X cartuchos antes del segundo pitido.',
  );

  String get timerModeRepeatExample => _pick(
    fr: 'Ex: Au bip tu as X secondes pour déclencher X cartouches au pistolet avant le second bip. Le cycle redémarre tu as X secondes pour déclencher X cartouches au fusil etc...',
    en: 'Ex: On the beep, you have X seconds to shoot X rounds with the handgun before the second beep. The cycle restarts: you have X seconds to shoot X rounds with the handgun, etc.',
    de: 'Bsp.: Beim Signalton hast du X Sekunden, um X Schüsse mit der Pistole abzugeben, bevor der zweite Signalton ertönt. Dann startet der Zyklus erneut: X Sekunden für X Schüsse mit dem Gewehr usw.',
    it: 'Es: Al bip hai X secondi per sparare X colpi con la pistola prima del secondo bip. Il ciclo riparte: hai X secondi per sparare X colpi con il fucile, ecc.',
    es: 'Ej: Al pitido tienes X segundos para disparar X cartuchos con la pistola antes del segundo pitido. El ciclo se reinicia: tienes X segundos para disparar X cartuchos con el fusil, etc.',
  );

  String get timerModeRandomDelayExample => _pick(
    fr: 'Ex: Le bip se déclenche aléatoirement, tu réagis et tu engages.',
    en: 'Ex: The beep triggers randomly. React and engage.',
    de: 'Bsp.: Der Signalton kommt zufällig. Reagieren und ausführen.',
    it: 'Es: Il bip scatta in modo casuale. Reagisci e ingaggia.',
    es: 'Ej: El pitido se activa aleatoriamente. Reaccionas y enganchas.',
  );

  String get timerModeStartAndMicExample => _pick(
    fr: 'Ex: Au bip, tu engages. Le téléphone détecte l\'impact sonore et affiche ton temps.',
    en: 'Ex: On the beep, engage. The phone detects the sound and displays your time.',
    de: 'Bsp.: Beim Signalton ausführen. Das Telefon erkennt das Geräusch und zeigt deine Zeit.',
    it: 'Es: Al bip ingaggi. Il telefono rileva il suono e mostra il tuo tempo.',
    es: 'Ej: Al pitido enganchas. El teléfono detecta el sonido y muestra tu tiempo.',
  );

  String get timerModeStartAndShotsExample => _pick(
    fr: 'Ex: Au bip, tu engages. Chaque impact sonore est détecté et affiché.',
    en: 'Ex: On the beep, engage. Each sound peak is detected and displayed.',
    de: 'Bsp.: Beim Signalton ausführen. Jeder Schallimpuls wird erkannt und angezeigt.',
    it: 'Es: Al bip ingaggi. Ogni picco sonoro viene rilevato e visualizzato.',
    es: 'Ej: Al pitido enganchas. Cada pico sonoro se detecta y se muestra.',
  );

  String get timerShotTimesTitle => _pick(
    fr: 'Temps enregistrés',
    en: 'Recorded times',
    de: 'Aufgezeichnete Zeiten',
    it: 'Tempi registrati',
    es: 'Tiempos registrados',
  );

  String get timerStatsTotalTime => _pick(
    fr: 'Temps total',
    en: 'Total time',
    de: 'Gesamtzeit',
    it: 'Tempo totale',
    es: 'Tiempo total',
  );

  String get timerStatsFirstShot => _pick(
    fr: 'Premier coup',
    en: 'First shot',
    de: 'Erster Schuss',
    it: 'Primo colpo',
    es: 'Primer disparo',
  );

  String get timerStatsSplitAverage => _pick(
    fr: 'Split moyen',
    en: 'Average split',
    de: 'Durchschnittlicher Split',
    it: 'Split medio',
    es: 'Split promedio',
  );

  String get timerStatsSplitMin => _pick(
    fr: 'Split min',
    en: 'Min split',
    de: 'Min Split',
    it: 'Split min',
    es: 'Split mín',
  );

  String get timerStatsSplitMax => _pick(
    fr: 'Split max',
    en: 'Max split',
    de: 'Max Split',
    it: 'Split max',
    es: 'Split máx',
  );

  String get timerStatsStdDev => _pick(
    fr: 'Régularité',
    en: 'Consistency',
    de: 'Konsistenz',
    it: 'Costanza',
    es: 'Consistencia',
  );

  String get hitFactorTitle => _pick(
    fr: 'Hit Factor IPSC',
    en: 'IPSC Hit Factor',
    de: 'IPSC Hit Factor',
    it: 'Hit Factor IPSC',
    es: 'Hit Factor IPSC',
  );

  String get hitFactorOpenButton => _pick(
    fr: 'Calculer le Hit Factor',
    en: 'Calculate Hit Factor',
    de: 'Hit Factor berechnen',
    it: 'Calcola Hit Factor',
    es: 'Calcular Hit Factor',
  );

  String get hitFactorZoneA => _pick(
    fr: 'Zone A',
    en: 'Zone A',
    de: 'Zone A',
    it: 'Zona A',
    es: 'Zona A',
  );

  String get hitFactorZoneC => _pick(
    fr: 'Zone C',
    en: 'Zone C',
    de: 'Zone C',
    it: 'Zona C',
    es: 'Zona C',
  );

  String get hitFactorZoneD => _pick(
    fr: 'Zone D',
    en: 'Zone D',
    de: 'Zone D',
    it: 'Zona D',
    es: 'Zona D',
  );

  String get hitFactorMike => _pick(
    fr: 'Ratés (M)',
    en: 'Misses (M)',
    de: 'Fehler (M)',
    it: 'Mancati (M)',
    es: 'Fallos (M)',
  );

  String get hitFactorNoShoot => _pick(
    fr: 'No-shoot (NS)',
    en: 'No-shoot (NS)',
    de: 'No-shoot (NS)',
    it: 'No-shoot (NS)',
    es: 'No-shoot (NS)',
  );

  String get hitFactorMajor =>
      _pick(fr: 'Major', en: 'Major', de: 'Major', it: 'Major', es: 'Major');

  String get hitFactorMinor =>
      _pick(fr: 'Minor', en: 'Minor', de: 'Minor', it: 'Minor', es: 'Minor');

  String get hitFactorCompute => _pick(
    fr: 'Calculer',
    en: 'Compute',
    de: 'Berechnen',
    it: 'Calcola',
    es: 'Calcular',
  );

  String get hitFactorScoreLabel => _pick(
    fr: 'Score',
    en: 'Score',
    de: 'Punktzahl',
    it: 'Punteggio',
    es: 'Puntuación',
  );

  String get hitFactorResultLabel => _pick(
    fr: 'Hit Factor',
    en: 'Hit Factor',
    de: 'Hit Factor',
    it: 'Hit Factor',
    es: 'Hit Factor',
  );

  String get timerMicrophonePermissionDenied => _pick(
    fr: 'Permission micro refusée. Activez le micro pour utiliser la détection acoustique.',
    en: 'Microphone permission denied. Enable the microphone to use acoustic detection.',
    de: 'Mikrofonberechtigung verweigert. Aktivieren Sie das Mikrofon, um die akustische Erkennung zu verwenden.',
    it: 'Autorizzazione microfono negata. Attiva il microfono per usare il rilevamento acustico.',
    es: 'Permiso de micrófono denegado. Active el micrófono para usar la detección acústica.',
  );

  String get timerMicrophoneError => _pick(
    fr: 'Erreur micro. Impossible d\'écouter le son pour le moment.',
    en: 'Microphone error. Sound detection is currently unavailable.',
    de: 'Mikrofonfehler. Die Geräuscherkennung ist derzeit nicht verfügbar.',
    it: 'Errore microfono. Il rilevamento audio non è al momento disponibile.',
    es: 'Error de micrófono. La detección de sonido no está disponible en este momento.',
  );

  String get visualStimulusToolTitle => _pick(
    fr: 'STIMULIS VISUELS',
    en: 'VISUAL STIMULI',
    de: 'VISUELLE STIMULI',
    it: 'STIMOLI VISIVI',
    es: 'ESTÍMULOS VISUALES',
  );

  String get visualStimulusToolSubtitle => _pick(
    fr: 'Dynamisez vos séances avec cet outil de génération de stimuli.',
    en: 'Energize your sessions with this stimulus generation tool.',
    de: 'Gestalten Sie Ihre Einheiten dynamischer mit diesem Tool zur Stimulus-Erzeugung.',
    it: 'Rendi più dinamiche le tue sessioni con questo strumento di generazione di stimoli.',
    es: 'Dinamiza tus sesiones con esta herramienta de generación de estímulos.',
  );

  String get cognitiveDrillsToolTitle => _pick(
    fr: 'STIMULIS COGNITIFS',
    en: 'COGNITIVE STIMULI',
    de: 'KOGNITIVE STIMULI',
    it: 'STIMOLI COGNITIVI',
    es: 'ESTÍMULOS COGNITIVOS',
  );

  String get cognitiveDrillsToolSubtitle => _pick(
    fr: 'Décision sous stress et inhibition',
    en: 'Decision-making under stress and inhibition',
    de: 'Entscheidung unter Stress und Hemmung',
    it: 'Decisione sotto stress e inibizione',
    es: 'Decisión bajo estrés e inhibición',
  );

  String get reflexesToolTitle => _pick(
    fr: 'EXERCICES',
    en: 'EXERCISES',
    de: 'ÜBUNGEN',
    it: 'ESERCIZI',
    es: 'EJERCICIOS',
  );

  String get reflexesToolSubtitle => _pick(
    fr: 'Exercices cognitifs pour travailler réflexes, attention, mémoire et décision.',
    en: 'Cognitive exercises to train reflexes, attention, memory, and decision-making.',
    de: 'Kognitive Übungen für Reflexe, Aufmerksamkeit, Gedächtnis und Entscheidungen.',
    it: 'Esercizi cognitivi per allenare riflessi, attenzione, memoria e decisione.',
    es: 'Ejercicios cognitivos para entrenar reflejos, atención, memoria y decisión.',
  );

  String get calculationsToolTitle => _pick(
    fr: 'OUTILS DE CALCUL',
    en: 'CALCULATION TOOLS',
    de: 'BERECHNUNGSTOOLS',
    it: 'STRUMENTI DI CALCOLO',
    es: 'HERRAMIENTAS DE CÁLCULO',
  );

  String get calculationsToolSubtitle => _pick(
    fr: 'Millième, Hit Factor, Power Factor.',
    en: 'Mil, Hit Factor, Power Factor.',
    de: 'Mil, Hit Factor, Power Factor.',
    it: 'Mil, Hit Factor, Power Factor.',
    es: 'Mil, Hit Factor, Power Factor.',
  );

  String get toolsTrainingSectionTitle => _pick(
    fr: 'Entraînement',
    en: 'Training',
    de: 'Training',
    it: 'Allenamento',
    es: 'Entrenamiento',
  );

  String get toolsCalculationSectionTitle => _pick(
    fr: 'Calcul',
    en: 'Calculation',
    de: 'Berechnung',
    it: 'Calcolo',
    es: 'Cálculo',
  );

  String get toolsMaintenanceSectionTitle => _pick(
    fr: 'Maintenance',
    en: 'Maintenance',
    de: 'Wartung',
    it: 'Manutenzione',
    es: 'Mantenimiento',
  );

  String get toolComingSoon => _pick(
    fr: 'Bientôt disponible',
    en: 'Coming soon',
    de: 'Bald verfügbar',
    it: 'Disponibile a breve',
    es: 'Próximamente',
  );

  String get cognitiveDrillsTitle => _pick(
    fr: 'STIMULIS COGNITIFS',
    en: 'COGNITIVE STIMULI',
    de: 'KOGNITIVE STIMULI',
    it: 'STIMOLI COGNITIVI',
    es: 'ESTÍMULOS COGNITIVOS',
  );

  String get cognitiveDrillsInfo => _pick(
    fr: 'Exercices pour stimuler l\'esprit pendant les phases de travail et identifier votre cible',
    en: 'Exercises to stimulate the mind during work phases and identify your target',
    de: 'Übungen zur Stimulation des Geistes während Arbeitsphasen und Identifikation Ihres Ziels',
    it: 'Esercizi per stimolare la mente durante le fasi di lavoro e identificare il tuo bersaglio',
    es: 'Ejercicios para estimular la mente durante las fases de trabajo e identificar su objetivo',
  );

  String get cognitiveDrillModeDirection => _pick(
    fr: 'Direction',
    en: 'Direction',
    de: 'Richtung',
    it: 'Direzione',
    es: 'Dirección',
  );

  String get cognitiveDrillModeStroop => _pick(
    fr: 'Test de Stroop',
    en: 'Stroop test',
    de: 'Stroop-Test',
    it: 'Test di Stroop',
    es: 'Test de Stroop',
  );

  String get cognitiveDrillModeStroopHeader => _pick(
    fr: 'TEST DE STROOP',
    en: 'STROOP TEST',
    de: 'STROOP-TEST',
    it: 'TEST DI STROOP',
    es: 'TEST DE STROOP',
  );


  String get cognitiveDrillStroopSubmodeSimple => _pick(
    fr: 'Réaction simple',
    en: 'Simple reaction',
    de: 'Einfache Reaktion',
    it: 'Reazione semplice',
    es: 'Reacción simple',
  );

  String get cognitiveDrillStroopSubmodeTargetColor => _pick(
    fr: 'Couleur cible',
    en: 'Target color',
    de: 'Zielfarbe',
    it: 'Colore bersaglio',
    es: 'Color objetivo',
  );

  String get cognitiveDrillDifficultyEasy =>
      _pick(fr: 'Facile', en: 'Easy', de: 'Leicht', it: 'Facile', es: 'Fácil');

  String get cognitiveDrillDifficultyMedium =>
      _pick(fr: 'Moyen', en: 'Medium', de: 'Mittel', it: 'Medio', es: 'Medio');

  String get cognitiveDrillDifficultyHard => _pick(
    fr: 'Difficile',
    en: 'Hard',
    de: 'Schwer',
    it: 'Difficile',
    es: 'Difícil',
  );

  String get cognitiveDrillSettingsTitle => _pick(
    fr: 'Paramètres',
    en: 'Settings',
    de: 'Einstellungen',
    it: 'Impostazioni',
    es: 'Configuración',
  );

  String get cognitiveDrillDifficultyLabel => _pick(
    fr: 'Difficulté',
    en: 'Difficulty',
    de: 'Schwierigkeit',
    it: 'Difficoltà',
    es: 'Dificultad',
  );

  String get cognitiveDrillModeDirectionDescription => _pick(
    fr: 'Installez des cibles en ligne, colonne ou en croix, THOT désigne aléatoirement laquelle engager.',
    en: 'Place targets in a row, column, or cross; THOT randomly picks which one to engage.',
    de: 'Ziele in Reihe, Spalte oder Kreuz platzieren; THOT wählt zufällig das nächste Ziel.',
    it: 'Posiziona bersagli in fila, colonna o croce; THOT sceglie a caso quale ingaggiare.',
    es: 'Coloca objetivos en fila, columna o cruz; THOT elige al azar cuál enfrentar.',
  );

  String get cognitiveDrillModeStroopCardDescription => _pick(
    fr: 'Gérez le conflit cognitif entre un mot et sa couleur.',
    en: 'Manage the cognitive conflict between a word and its color.',
    de: 'Bewältigen Sie den kognitiven Konflikt zwischen einem Wort und seiner Farbe.',
    it: 'Gestisci il conflitto cognitivo tra una parola e il suo colore.',
    es: 'Gestiona el conflicto cognitivo entre una palabra y su color.',
  );

  String get cognitiveDrillModeStroopDescription => _pick(
    fr: 'Un mot de couleur va apparaître au centre de l’écran (**ROUGE, VERT, BLEU** ou **JAUNE**).\nLe mot peut être écrit dans une **encre différente** de son sens.\nTapez sur le bouton correspondant à la **couleur de l’encre**, pas au mot lu.\nExemple : le mot "**ROUGE**" écrit en bleu → tapez le bouton bleu.\nSoyez **rapide** et **précis**.',
    en: 'A color word will appear in the center of the screen (**RED, GREEN, BLUE**, or **YELLOW**).\nThe word may be written in an **ink color that differs** from its meaning.\nTap the button that matches the **ink color**, not the word you read.\nExample: the word "**RED**" written in blue → tap the blue button.\nBe **fast** and **accurate**.',
    de: 'Ein Farbwort erscheint in der Mitte des Bildschirms (**ROT, GRÜN, BLAU** oder **GELB**).\nDas Wort kann in einer **Schriftfarbe** angezeigt werden, die nicht seiner Bedeutung entspricht.\nTippen Sie auf die Schaltfläche, die der **Schriftfarbe** entspricht, nicht auf das gelesene Wort.\nBeispiel: das Wort "**ROT**" in Blau geschrieben → tippen Sie auf die blaue Schaltfläche.\nSeien Sie **schnell** und **präzise**.',
    it: 'Una parola che indica un colore apparirà al centro dello schermo (**ROSSO, VERDE, BLU** o **GIALLO**).\nLa parola può essere scritta con un **colore dell’inchiostro diverso** dal suo significato.\nTocca il pulsante corrispondente al **colore dell’inchiostro**, non alla parola letta.\nEsempio: la parola "**ROSSO**" scritta in blu → tocca il pulsante blu.\nSii **rapido** e **preciso**.',
    es: 'Aparecerá una palabra de color en el centro de la pantalla (**ROJO, VERDE, AZUL** o **AMARILLO**).\nLa palabra puede estar escrita con un **color de tinta diferente** de su significado.\nToca el botón que corresponda al **color de la tinta**, no a la palabra leída.\nEjemplo: la palabra "**ROJO**" escrita en azul → toca el botón azul.\nSé **rápido** y **preciso**.',
  );

  String get cognitiveDrillStroopRunInstruction => _pick(
    fr: 'Sélectionne la couleur de l’encre du mot',
    en: 'Select the ink color of the word',
    de: 'Wähle die Schriftfarbe des Wortes',
    it: 'Seleziona il colore dell’inchiostro della parola',
    es: 'Selecciona el color de la tinta de la palabra',
  );

  String get cognitiveDrillModeStroopInfoTooltip => _pick(
    fr: '**Test** développé par **John Ridley Stroop** en 1935 (Journal of Experimental Psychology).\nUtilisé en **neuropsychologie clinique** (batteries D-KEFS, Golden Stroop) et en **recherche** sur la prise de décision en contexte policier shoot/don\'t-shoot.\nCet exercice ne constitue pas un dispositif médical et ne remplace aucune évaluation clinique.',
    en: '**Test** developed by **John Ridley Stroop** in 1935 (Journal of Experimental Psychology).\nUsed in **clinical neuropsychology** (D-KEFS batteries, Golden Stroop) and in **research** on decision-making in police shoot/don\'t-shoot contexts.\nThis exercise is not a medical device and does not replace any clinical evaluation.',
    de: '**Test** entwickelt von **John Ridley Stroop** im Jahr 1935 (Journal of Experimental Psychology).\nVerwendet in der **klinischen Neuropsychologie** (D-KEFS-Batterien, Golden Stroop) und in der **Forschung** zur Entscheidungsfindung in polizeilichen Shoot-/Don\'t-Shoot-Situationen.\nDiese Übung ist kein Medizinprodukt und ersetzt keine klinische Beurteilung.',
    it: '**Test** sviluppato da **John Ridley Stroop** nel 1935 (Journal of Experimental Psychology).\nUtilizzato in **neuropsicologia clinica** (batterie D-KEFS, Golden Stroop) e nella **ricerca** sul processo decisionale in contesti di polizia shoot/don\'t-shoot.\nQuesto esercizio non è un dispositivo medico e non sostituisce alcuna valutazione clinica.',
    es: '**Test** desarrollado por **John Ridley Stroop** en 1935 (Journal of Experimental Psychology).\nUtilizado en **neuropsicología clínica** (baterías D-KEFS, Golden Stroop) y en **investigación** sobre la toma de decisiones en contextos policiales shoot/don\'t-shoot.\nEste ejercicio no constituye un producto sanitario ni sustituye ninguna evaluación clínica.',
  );

  String get reflexesModeMot => _pick(
    fr: 'Test M.O.T',
    en: 'M.O.T Test',
    de: 'M.O.T-Test',
    it: 'Test M.O.T',
    es: 'Test M.O.T',
  );

  String get reflexesModeMotHeader =>
      _pick(fr: 'M.O.T', en: 'M.O.T', de: 'M.O.T', it: 'M.O.T', es: 'M.O.T');

  String get reflexesModeMotCardDescription => _pick(
    fr: 'Suivez plusieurs cibles en mouvement simultané.',
    en: 'Track multiple targets moving simultaneously.',
    de: 'Verfolgen Sie mehrere gleichzeitig bewegte Ziele.',
    it: 'Segui più target in movimento contemporaneamente.',
    es: 'Sigue múltiples objetivos en movimiento simultáneo.',
  );

  String get reflexesModeMotDescription => _pick(
    fr: 'Plusieurs cercles identiques sont disposés à l\'écran. Au début, **certains cercles clignotent en orange** : ce sont vos cibles à mémoriser. Le nombre de cibles varie selon la difficulté (1 à 5). Tous les cercles redeviennent ensuite identiques et se déplacent en même temps. Suivez mentalement les cibles d\'origine. Quand le mouvement s\'arrête, tapez les cercles que vous pensez être les cibles.',
    en: 'Multiple identical circles are arranged on screen. At the start, **some circles flash orange** : these are your targets to memorize. The number of targets varies by difficulty (1 to 5). All circles then become identical and move simultaneously. Mentally track the original targets. When movement stops, tap the circles you believe are the targets.',
    de: 'Mehrere identische Kreise sind auf dem Bildschirm angeordnet. Zu Beginn blinken **einige Kreise orange** : dies sind Ihre Ziele, die Sie sich merken müssen. Die Anzahl der Ziele variiert je nach Schwierigkeit (1 bis 5). Alle Kreise werden dann identisch und bewegen sich gleichzeitig. Verfolgen Sie mental die ursprünglichen Ziele. Wenn die Bewegung stoppt, tippen Sie auf die Kreise, die Ihrer Meinung nach die Ziele sind.',
    it: 'Più cerchi identici sono disposti sullo schermo. All\'inizio, **alcuni cerchi lampeggiano in arancione** : questi sono i target da memorizzare. Il numero di target varia in base alla difficoltà (da 1 a 5). Tutti i cerchi diventano poi identici e si muovono contemporaneamente. Segui mentalmente i target originali. Quando il movimento si ferma, tocca i cerchi che pensi siano i target.',
    es: 'Varios círculos idénticos están dispuestos en pantalla. Al principio, **algunos círculos parpadean en naranja** : estos son tus objetivos a memorizar. El número de objetivos varía según la dificultad (de 1 a 5). Todos los círculos se vuelven luego idénticos y se mueven simultáneamente. Sigue mentalmente los objetivos originales. Cuando el movimiento se detiene, toca los círculos que crees que son los objetivos.',
  );

  String get reflexesModeMotInfoTooltip => _pick(
    fr: 'Paradigme du **Multiple Object Tracking** introduit par Pylyshyn et Storm en 1988 (Spatial Vision). Système commercial **NeuroTracker** développé par le neuroscientifique Jocelyn Faubert à l\'Université de Montréal. Utilisé par **US Special Operations Command**, Manchester United, Atlanta Falcons, IMG Academy et les **Forces Spéciales canadiennes** (Vartanian et al., Military Psychology, 2016).\n\nCet exercice s\'inspire de protocoles de recherche en neurosciences cognitives. Il ne constitue pas un dispositif médical et ne remplace aucune évaluation clinique.',
    en: 'Multiple Object Tracking paradigm introduced by Pylyshyn and Storm in 1988 (Spatial Vision). Commercial **NeuroTracker** system developed by neuroscientist Jocelyn Faubert at the University of Montreal. Used by **US Special Operations Command**, Manchester United, Atlanta Falcons, IMG Academy and **Canadian Special Forces** (Vartanian et al., Military Psychology, 2016).\n\nThis exercise is inspired by cognitive neuroscience research protocols. It is not a medical device and does not replace any clinical evaluation.',
    de: 'Multiple-Object-Tracking-Paradigma eingeführt von Pylyshyn und Storm 1988 (Spatial Vision). Kommerzielles **NeuroTracker**-System entwickelt von Neurowissenschaftler Jocelyn Faubert an der Universität Montreal. Verwendet vom **US Special Operations Command**, Manchester United, Atlanta Falcons, IMG Academy und den **kanadischen Spezialeinheiten** (Vartanian et al., Military Psychology, 2016).\n\nDiese Übung ist inspiriert von Forschungsprotokollen der kognitiven Neurowissenschaften. Sie ist kein Medizinprodukt und ersetzt keine klinische Beurteilung.',
    it: 'Paradigma del Multiple Object Tracking introdotto da Pylyshyn e Storm nel 1988 (Spatial Vision). Sistema commerciale **NeuroTracker** sviluppato dal neuroscienziato Jocelyn Faubert all\'Università di Montreal. Utilizzato da **US Special Operations Command**, Manchester United, Atlanta Falcons, IMG Academy e **Forze Speciali canadesi** (Vartanian et al., Military Psychology, 2016).\n\nQuesto esercizio è ispirato da protocolli di ricerca in neuroscienze cognitive. Non è un dispositivo medico e non sostituisce alcuna valutazione clinica.',
    es: 'Paradigma del Multiple Object Tracking introducido por Pylyshyn y Storm en 1988 (Spatial Vision). Sistema comercial **NeuroTracker** desarrollado por el neurocientífico Jocelyn Faubert en la Universidad de Montreal. Utilizado por **US Special Operations Command**, Manchester United, Atlanta Falcons, IMG Academy y las **Fuerzas Especiales canadienses** (Vartanian et al., Military Psychology, 2016).\n\nEste ejercicio está inspirado en protocolos de investigación en neurociencias cognitivas. No constituye un dispositivo médico ni sustituye ninguna evaluación clínica.',
  );

  String get reflexesMotTrialLabel => _pick(
    fr: 'Essai',
    en: 'Trial',
    de: 'Durchgang',
    it: 'Prova',
    es: 'Ensayo',
  );

  String get reflexesMotTargetsFound => _pick(
    fr: 'Cibles trouvées',
    en: 'Targets found',
    de: 'Ziele gefunden',
    it: 'Target trovati',
    es: 'Objetivos encontrados',
  );

  String get reflexesMotAvgScore => _pick(
    fr: 'Score moyen',
    en: 'Average score',
    de: 'Durchschnittswert',
    it: 'Punteggio medio',
    es: 'Puntuación media',
  );

  String get reflexesMotSuccessRate => _pick(
    fr: 'Taux de réussite',
    en: 'Success rate',
    de: 'Erfolgsquote',
    it: 'Tasso di successo',
    es: 'Tasa de éxito',
  );

  String get reflexesMotPhaseMemorize => _pick(
    fr: 'Mémorisez les cibles',
    en: 'Memorize targets',
    de: 'Ziele merken',
    it: 'Memorizza i target',
    es: 'Memoriza los objetivos',
  );

  String get reflexesMotPhaseTrack => _pick(
    fr: 'Suivez les cibles',
    en: 'Track targets',
    de: 'Ziele verfolgen',
    it: 'Segui i target',
    es: 'Sigue los objetivos',
  );

  String get reflexesMotPhaseIdentify => _pick(
    fr: 'Identifiez les 3 cibles',
    en: 'Identify the 3 targets',
    de: 'Identifizieren Sie die 3 Ziele',
    it: 'Identifica i 3 target',
    es: 'Identifica los 3 objetivos',
  );

  String get reflexesMotPhaseFeedback => _pick(
    fr: 'Résultat',
    en: 'Result',
    de: 'Ergebnis',
    it: 'Risultato',
    es: 'Resultado',
  );

  String get cognitiveDrillStroopSubmodeAlternating => _pick(
    fr: 'Congruent / conflit alternés',
    en: 'Congruent / conflict mixed',
    de: 'Kongruent / Konflikt gemischt',
    it: 'Congruente / conflitto alternati',
    es: 'Congruente / conflicto alternados',
  );

  String get cognitiveDrillResultsTitle => _pick(
    fr: 'Résultats',
    en: 'Results',
    de: 'Ergebnisse',
    it: 'Risultati',
    es: 'Resultados',
  );

  String get cognitiveDrillResultTitle => _pick(
    fr: 'RESULTAT',
    en: 'RESULT',
    de: 'ERGEBNIS',
    it: 'RISULTATO',
    es: 'RESULTADO',
  );

  String get cognitiveDrillStroopAvgCongruent => _pick(
    fr: 'TR moyen congruent',
    en: 'Avg RT congruent',
    de: 'Mittlere RT kongruent',
    it: 'TR medio congruente',
    es: 'TR medio congruente',
  );

  String get cognitiveDrillStroopAvgConflict => _pick(
    fr: 'TR moyen conflictuel',
    en: 'Avg RT conflict',
    de: 'Mittlere RT Konflikt',
    it: 'TR medio conflittuale',
    es: 'TR medio conflicto',
  );

  String get cognitiveDrillStroopInkColors => _pick(
    fr: 'Couleurs d\'encre',
    en: 'Ink colors',
    de: 'Tintenfarben',
    it: 'Colori dell\'inchiostro',
    es: 'Colores de tinta',
  );

  String get cognitiveDrillStroopWords => _pick(
    fr: 'Mots',
    en: 'Words',
    de: 'W\u00f6rter',
    it: 'Parole',
    es: 'Palabras',
  );

  String get cognitiveDrillStimulusDurationLabel => _pick(
    fr: 'Durée du stimulus',
    en: 'Stimulus duration',
    de: 'Stimulusdauer',
    it: 'Durata dello stimolo',
    es: 'Duración del estímulo',
  );

  String get cognitiveDrillTargetColorLabel => _pick(
    fr: 'Couleur cible',
    en: 'Target color',
    de: 'Zielfarbe',
    it: 'Colore bersaglio',
    es: 'Color objetivo',
  );

  String get cognitiveDrillResultsStimuliCount => _pick(
    fr: 'Stimuli',
    en: 'Stimuli',
    de: 'Stimuli',
    it: 'Stimoli',
    es: 'Estímulos',
  );

  // Direction arrows breakdown
  String get directionArrowsUp => _pick(
    fr: 'Flèches haut',
    en: 'Up arrows',
    de: 'Pfeile nach oben',
    it: 'Frecce su',
    es: 'Flechas arriba',
  );

  String get directionArrowsDown => _pick(
    fr: 'Flèches bas',
    en: 'Down arrows',
    de: 'Pfeile nach unten',
    it: 'Frecce giù',
    es: 'Flechas abajo',
  );

  String get directionArrowsLeft => _pick(
    fr: 'Flèches gauche',
    en: 'Left arrows',
    de: 'Pfeile nach links',
    it: 'Frecce sinistra',
    es: 'Flechas izquierda',
  );

  String get directionArrowsRight => _pick(
    fr: 'Flèches droite',
    en: 'Right arrows',
    de: 'Pfeile nach rechts',
    it: 'Frecce destra',
    es: 'Flechas derecha',
  );

  // Stroop word breakdown
  String get stroopWordsRed => _pick(
    fr: 'Mot rouge',
    en: 'Red word',
    de: 'Wort rot',
    it: 'Parola rosso',
    es: 'Palabra rojo',
  );

  String get stroopWordsBlue => _pick(
    fr: 'Mot bleu',
    en: 'Blue word',
    de: 'Wort blau',
    it: 'Parola blu',
    es: 'Palabra azul',
  );

  String get stroopWordsGreen => _pick(
    fr: 'Mot vert',
    en: 'Green word',
    de: 'Wort grün',
    it: 'Parola verde',
    es: 'Palabra verde',
  );

  String get stroopWordsYellow => _pick(
    fr: 'Mot jaune',
    en: 'Yellow word',
    de: 'Wort gelb',
    it: 'Parola giallo',
    es: 'Palabra amarillo',
  );

  String get stroopInkRed => _pick(
    fr: 'Encre rouge',
    en: 'Red ink',
    de: 'Tinte rot',
    it: 'Inchiostro rosso',
    es: 'Tinta roja',
  );

  String get stroopInkBlue => _pick(
    fr: 'Encre bleu',
    en: 'Blue ink',
    de: 'Tinte blau',
    it: 'Inchiostro blu',
    es: 'Tinta azul',
  );

  String get stroopInkGreen => _pick(
    fr: 'Encre vert',
    en: 'Green ink',
    de: 'Tinte grün',
    it: 'Inchiostro verde',
    es: 'Tinta verde',
  );

  String get stroopInkYellow => _pick(
    fr: 'Encre jaune',
    en: 'Yellow ink',
    de: 'Tinte gelb',
    it: 'Inchiostro giallo',
    es: 'Tinta amarillo',
  );

  String get cognitiveDrillResultsStimulusDuration => _pick(
    fr: 'Durée par stimulus',
    en: 'Duration per stimulus',
    de: 'Dauer pro Stimulus',
    it: 'Durata per stimolo',
    es: 'Duración por estímulo',
  );

  String get cognitiveDrillResultsTotalDuration => _pick(
    fr: 'Durée totale',
    en: 'Total duration',
    de: 'Gesamtdauer',
    it: 'Durata totale',
    es: 'Duración total',
  );

  String get cognitiveDrillResultsResponses => _pick(
    fr: 'Réponses détectées',
    en: 'Recorded responses',
    de: 'Erfasste Antworten',
    it: 'Risposte registrate',
    es: 'Respuestas registradas',
  );

  // --- Difficulty Criteria ---

  String get cognitiveDrillStroopEasyCriteria => _pick(
    fr: '15 stimuli • 1.8 s',
    en: '15 stimuli • 1.8 s',
    de: '15 Stimuli • 1.8 s',
    it: '15 stimoli • 1.8 s',
    es: '15 estímulos • 1.8 s',
  );

  String get cognitiveDrillStroopMediumCriteria => _pick(
    fr: '20 stimuli • 1.4 s',
    en: '20 stimuli • 1.4 s',
    de: '20 Stimuli • 1.4 s',
    it: '20 stimoli • 1.4 s',
    es: '20 estímulos • 1.4 s',
  );

  String get cognitiveDrillStroopHardCriteria => _pick(
    fr: '25 stimuli • 1.0 s',
    en: '25 stimuli • 1.0 s',
    de: '25 Stimuli • 1.0 s',
    it: '25 stimoli • 1.0 s',
    es: '25 estímulos • 1.0 s',
  );

  // --- Score History ---

  String get cognitiveDrillScoreHistoryTitle => _pick(
    fr: 'Historique des scores',
    en: 'Score history',
    de: 'Ergebnisverlauf',
    it: 'Cronologia punteggi',
    es: 'Historial de puntuaciones',
  );

  String get cognitiveDrillNoScores => _pick(
    fr: 'Aucun score enregistré',
    en: 'No scores recorded',
    de: 'Keine Ergebnisse aufgezeichnet',
    it: 'Nessun punteggio registrato',
    es: 'Sin puntuaciones registradas',
  );

  // --- Reflexes Difficulty Criteria ---

  String get reflexesReactionEasyCriteria => _pick(
    fr: '10 stimuli • 2-4 s',
    en: '10 stimuli • 2-4 s',
    de: '10 Stimuli • 2-4 s',
    it: '10 stimoli • 2-4 s',
    es: '10 estímulos • 2-4 s',
  );

  String get reflexesReactionMediumCriteria => _pick(
    fr: '15 stimuli • 1.5-5 s',
    en: '15 stimuli • 1.5-5 s',
    de: '15 Stimuli • 1.5-5 s',
    it: '15 stimoli • 1.5-5 s',
    es: '15 estímulos • 1.5-5 s',
  );

  String get reflexesReactionHardCriteria => _pick(
    fr: '20 stimuli • 1-6 s',
    en: '20 stimuli • 1-6 s',
    de: '20 Stimuli • 1-6 s',
    it: '20 stimoli • 1-6 s',
    es: '20 estímulos • 1-6 s',
  );

  String get reflexesMathEasyCriteria => _pick(
    fr: 'Additions et soustractions jusqu\'à 50, sans résultat négatif',
    en: 'Addition and subtraction up to 50, no negative results',
    de: 'Addition und Subtraktion bis 50, keine negativen Ergebnisse',
    it: 'Addizione e sottrazione fino a 50, senza risultati negativi',
    es: 'Suma y resta hasta 50, sin resultados negativos',
  );

  String get reflexesMathMediumCriteria => _pick(
    fr: '+, −, × — nombres jusqu\'à 99, tables jusqu\'à 12',
    en: '+, −, × — numbers up to 99, tables up to 12',
    de: '+, −, × — Zahlen bis 99, Tabellen bis 12',
    it: '+, −, × — numeri fino a 99, tabelle fino a 12',
    es: '+, −, × — números hasta 99, tablas hasta 12',
  );

  String get reflexesMathHardCriteria => _pick(
    fr: '+, −, ×, ÷ — nombres jusqu\'à 99, tables jusqu\'à 12, divisions exactes',
    en: '+, −, ×, ÷ — numbers up to 99, tables up to 12, exact divisions',
    de: '+, −, ×, ÷ — Zahlen bis 99, Tabellen bis 12, exakte Divisionen',
    it: '+, −, ×, ÷ — numeri fino a 99, tabelle fino a 12, divisioni esatte',
    es: '+, −, ×, ÷ — números hasta 99, tablas hasta 12, divisiones exactas',
  );

  String get reflexesMemoryEasyCriteria => _pick(
    fr: '4 chiffres • 3 s',
    en: '4 digits • 3 s',
    de: '4 Ziffern • 3 s',
    it: '4 cifre • 3 s',
    es: '4 dígitos • 3 s',
  );

  String get reflexesMemoryMediumCriteria => _pick(
    fr: '6 chiffres • 2.5 s',
    en: '6 digits • 2.5 s',
    de: '6 Ziffern • 2.5 s',
    it: '6 cifre • 2.5 s',
    es: '6 dígitos • 2.5 s',
  );

  String get reflexesMemoryHardCriteria => _pick(
    fr: '8 chiffres • 2 s',
    en: '8 digits • 2 s',
    de: '8 Ziffern • 2 s',
    it: '8 cifre • 2 s',
    es: '8 dígitos • 2 s',
  );

  String get reflexesMotEasyCriteria => _pick(
    fr: '10 cercles • 1 cible • 7 s • 100 px/s',
    en: '10 circles • 1 target • 7 s • 100 px/s',
    de: '10 Kreise • 1 Ziel • 7 s • 100 px/s',
    it: '10 cerchi • 1 bersaglio • 7 s • 100 px/s',
    es: '10 círculos • 1 objetivo • 7 s • 100 px/s',
  );

  String get reflexesMotMediumCriteria => _pick(
    fr: '10 cercles • 3 cibles • 8 s • 140 px/s',
    en: '10 circles • 3 targets • 8 s • 140 px/s',
    de: '10 Kreise • 3 Ziele • 8 s • 140 px/s',
    it: '10 cerchi • 3 bersagli • 8 s • 140 px/s',
    es: '10 círculos • 3 objetivos • 8 s • 140 px/s',
  );

  String get reflexesMotHardCriteria => _pick(
    fr: '10 cercles • 5 cibles • 10 s • 180 px/s',
    en: '10 circles • 5 targets • 10 s • 180 px/s',
    de: '10 Kreise • 5 Ziele • 10 s • 180 px/s',
    it: '10 cerchi • 5 bersagli • 10 s • 180 px/s',
    es: '10 círculos • 5 objetivos • 10 s • 180 px/s',
  );
}
