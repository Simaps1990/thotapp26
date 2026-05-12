part of 'app_strings.dart';

extension AppStringsColorPod on AppStrings {
  String get colorPodToolTitle => _pick(
    fr: 'STIMULIS VISUELS',
    en: 'VISUAL STIMULI',
    de: 'VISUELLE STIMULI',
    it: 'STIMOLI VISIVI',
    es: 'ESTÍMULOS VISUALES',
  );
  String get colorPodToolSubtitle => _pick(
    fr: 'Exercices de stimulation cognitive',
    en: 'Cognitive stimulation exercises',
    de: 'Übungen zur kognitiven Stimulation',
    it: 'Esercizi di stimolazione cognitiva',
    es: 'Ejercicios de estimulación cognitiva',
  );

  String get colorPodToolTooltip => _pick(
    fr: '''Générez aléatoirement des **couleurs**, **directions**, **formes**, **lettres** ou **chiffres** pour vos exercices de tir.
Exemples d'utilisation : une couleur pour une action, une direction entre cibles alignées, des formes sur une cible, des lettres/chiffres correspondant à des actions.''',
    en: '''Randomly generate **colors**, **directions**, **shapes**, **letters** or **numbers** for your shooting exercises.
Usage examples: a color for an action, a direction between aligned targets, shapes on a target, letters/numbers corresponding to actions.''',
    de: '''Generieren Sie zufällig **Farben**, **Richtungen**, **Formen**, **Buchstaben** oder **Zahlen** für Ihre Schießübungen.
Anwendungsbeispiele: eine Farbe für eine Aktion, eine Richtung zwischen ausgerichteten Zielen, Formen auf einem Ziel, Buchstaben/Zahlen für Aktionen.''',
    it: '''Genera casualmente **colori**, **direzioni**, **forme**, **lettere** o **numeri** per i tuoi esercizi di tiro.
Esempi d'uso: un colore per un'azione, una direzione tra bersagli allineati, forme su un bersaglio, lettere/numeri corrispondenti ad azioni.''',
    es: '''Genere aleatoriamente **colores**, **direcciones**, **formas**, **letras** o **números** para sus ejercicios de tiro.
Ejemplos de uso: un color para una acción, una dirección entre objetivos alineados, formas en un objetivo, letras/números correspondientes a acciones.''',
  );

  String get colorPodColors => _pick(
    fr: 'COULEURS',
    en: 'COLORS',
    de: 'FARBEN',
    it: 'COLORI',
    es: 'COLORES',
  );
  String get colorPodActivateAll => _pick(
    fr: 'Tout activer',
    en: 'Enable all',
    de: 'Alle aktivieren',
    it: 'Attiva tutto',
    es: 'Activar todo',
  );
  String get colorPodDeactivateAll => _pick(
    fr: 'Tout désactiver',
    en: 'Disable all',
    de: 'Alle deaktivieren',
    it: 'Disattiva tutto',
    es: 'Desactivar todo',
  );
  String get colorPodColorDuration => _pick(
    fr: 'Durée d\'affichage de la couleur',
    en: 'Color display duration',
    de: 'Anzeigedauer der Farbe',
    it: 'Durata di visualizzazione del colore',
    es: 'Duración de visualización del color',
  );
  String get colorPodDelay => _pick(
    fr: 'Délai entre les couleurs (écran noir)',
    en: 'Delay between colors (black screen)',
    de: 'Pause zwischen den Farben (schwarzer Bildschirm)',
    it: 'Pausa tra i colori (schermo nero)',
    es: 'Pausa entre colores (pantalla negra)',
  );
  String get colorPodTotalDuration => _pick(
    fr: "Durée totale de l'exercice",
    en: 'Total exercise duration',
    de: 'Gesamtdauer der Übung',
    it: "Durata totale dell'esercizio",
    es: 'Duración total del ejercicio',
  );
  String get colorPodLaunch => _pick(
    fr: 'LANCER',
    en: 'START',
    de: 'STARTEN',
    it: 'AVVIA',
    es: 'INICIAR',
  );
  String get colorPodPrepare => _pick(
    fr: 'Préparez-vous',
    en: 'Get ready',
    de: 'Mach dich bereit',
    it: 'Preparati',
    es: 'Prepárate',
  );
  String get colorPodSecondsLeft => _pick(
    fr: 'secondes restantes',
    en: 'seconds left',
    de: 'Sekunden übrig',
    it: 'secondi rimanenti',
    es: 'segundos restantes',
  );
  String get colorPodStop =>
      _pick(fr: 'STOP', en: 'STOP', de: 'STOP', it: 'STOP', es: 'STOP');
  String get colorPodNext => _pick(
    fr: 'SUIVANT',
    en: 'NEXT',
    de: 'WEITER',
    it: 'SUCCESSIVO',
    es: 'SIGUIENTE',
  );
  String get colorPodResults => _pick(
    fr: 'RÉSULTATS',
    en: 'RESULTS',
    de: 'ERGEBNISSE',
    it: 'RISULTATI',
    es: 'RESULTADOS',
  );
  String colorPodTotal(int n) => _pick(
    fr: '$n apparitions au total',
    en: '$n total appearances',
    de: '$n Erscheinungen insgesamt',
    it: '$n apparizioni totali',
    es: '$n apariciones en total',
  );
  String get colorPodMenu =>
      _pick(fr: 'MENU', en: 'MENU', de: 'MENÜ', it: 'MENU', es: 'MENÚ');
  String get colorPodConfig => _pick(
    fr: 'MODIFIER',
    en: 'EDIT',
    de: 'BEARBEITEN',
    it: 'MODIFICA',
    es: 'EDITAR',
  );
  String get colorPodRestart => _pick(
    fr: 'RELANCER',
    en: 'RETRY',
    de: 'NOCHMAL',
    it: 'RIFAI',
    es: 'REINTENTAR',
  );
  String get colorPodRed =>
      _pick(fr: 'Rouge', en: 'Red', de: 'Rot', it: 'Rosso', es: 'Rojo');
  String get colorPodBlue =>
      _pick(fr: 'Bleu', en: 'Blue', de: 'Blau', it: 'Blu', es: 'Azul');
  String get colorPodGreen =>
      _pick(fr: 'Vert', en: 'Green', de: 'Grün', it: 'Verde', es: 'Verde');
  String get colorPodYellow => _pick(
    fr: 'Jaune',
    en: 'Yellow',
    de: 'Gelb',
    it: 'Giallo',
    es: 'Amarillo',
  );
  String get colorPodOrange => _pick(
    fr: 'Orange',
    en: 'Orange',
    de: 'Orange',
    it: 'Arancione',
    es: 'Naranja',
  );
  String get colorPodPurple =>
      _pick(fr: 'Violet', en: 'Purple', de: 'Lila', it: 'Viola', es: 'Morado');
  String get colorPodPink =>
      _pick(fr: 'Rose', en: 'Pink', de: 'Rosa', it: 'Rosa', es: 'Rosa');
  String get colorPodMediumGray => _pick(
    fr: 'Gris médian',
    en: 'Medium gray',
    de: 'Mittelgrau',
    it: 'Grigio medio',
    es: 'Gris medio',
  );
  String get colorPodWhite =>
      _pick(fr: 'Blanc', en: 'White', de: 'Weiß', it: 'Bianco', es: 'Blanco');
  String get colorPodBlack =>
      _pick(fr: 'Noir', en: 'Black', de: 'Schwarz', it: 'Nero', es: 'Negro');
  String get colorPodShapes => _pick(
    fr: 'FORMES',
    en: 'SHAPES',
    de: 'FORMEN',
    it: 'FORME',
    es: 'FORMAS',
  );
  String get colorPodDirections => _pick(
    fr: 'DIRECTION',
    en: 'DIRECTION',
    de: 'RICHTUNG',
    it: 'DIREZIONE',
    es: 'DIRECCIÓN',
  );
  String get colorPodDirectionLeft => _pick(
    fr: 'Gauche',
    en: 'Left',
    de: 'Links',
    it: 'Sinistra',
    es: 'Izquierda',
  );
  String get colorPodDirectionRight => _pick(
    fr: 'Droite',
    en: 'Right',
    de: 'Rechts',
    it: 'Destra',
    es: 'Derecha',
  );
  String get colorPodDirectionUp =>
      _pick(fr: 'Haut', en: 'Up', de: 'Oben', it: 'Su', es: 'Arriba');
  String get colorPodDirectionDown =>
      _pick(fr: 'Bas', en: 'Down', de: 'Unten', it: 'Giù', es: 'Abajo');
  String get colorPodDirectionCenter => _pick(
    fr: 'Centre',
    en: 'Center',
    de: 'Mitte',
    it: 'Centro',
    es: 'Centro',
  );
  String get colorPodLetters => _pick(
    fr: 'LETTRES',
    en: 'LETTERS',
    de: 'BUCHSTABEN',
    it: 'LETTERE',
    es: 'LETRAS',
  );
  String get colorPodDigits => _pick(
    fr: 'CHIFFRES',
    en: 'DIGITS',
    de: 'ZIFFERN',
    it: 'CIFRE',
    es: 'DÍGITOS',
  );
  String get colorPodShapeCircle => _pick(
    fr: 'Cercle',
    en: 'Circle',
    de: 'Kreis',
    it: 'Cerchio',
    es: 'Círculo',
  );
  String get colorPodShapeSquare => _pick(
    fr: 'Carré',
    en: 'Square',
    de: 'Quadrat',
    it: 'Quadrato',
    es: 'Cuadrado',
  );
  String get colorPodShapeHeart =>
      _pick(fr: 'Cœur', en: 'Heart', de: 'Herz', it: 'Cuore', es: 'Corazón');
  String get colorPodShapeTriangle => _pick(
    fr: 'Triangle',
    en: 'Triangle',
    de: 'Dreieck',
    it: 'Triangolo',
    es: 'Triángulo',
  );
  String get colorPodShapeStar => _pick(
    fr: 'Étoile',
    en: 'Star',
    de: 'Stern',
    it: 'Stella',
    es: 'Estrella',
  );
  String get colorPodShapeDiamond => _pick(
    fr: 'Diamant',
    en: 'Diamond',
    de: 'Diamant',
    it: 'Diamante',
    es: 'Diamante',
  );
}
