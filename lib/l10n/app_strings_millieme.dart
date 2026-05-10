part of 'app_strings.dart';

extension AppStringsMillieme on AppStrings {
  // --- Milliradian Tool (Formule du millième) ---

  String get milliemeToolTitle => _pick(
        fr: 'FORMULE DU MILLIÈME',
        en: 'MIL FORMULA',
        de: 'MIL-FORMEL',
        it: 'FORMULA DEL MIL',
        es: 'FÓRMULA DEL MIL',
      );

  String get milliemeToolSubtitle => _pick(
fr: 'Calculez une distance ou un écart angulaire',
en: 'Calculate a distance or an angular offset',
de: 'Berechne eine Distanz oder eine Winkelabweichung',
it: 'Calcola una distanza o uno scarto angolare',
es: 'Calcula una distancia o una desviación angular',
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

  String get milliemeFieldDisabledHint => _pick(
        fr: 'Cliquez sur Calculer pour obtenir le résultat',
        en: 'Click Calculate to get the result',
        de: 'Klicken Sie auf Berechnen, um das Ergebnis zu erhalten',
        it: 'Clicca su Calcola per ottenere il risultato',
        es: 'Haga clic en Calcular para obtener el resultado',
      );

  String get milliemeIntro => _pick(
        fr: 'La formule du millième permet de calculer une distance en utilisant votre lunette et des références visuelles connues du terrain.\nDes gabarits types avec leurs mesures ont été ajoutés pour gagner du temps.',
        en: 'The milliradian formula allows calculating a distance using your scope and known visual references from the field.\nStandard templates with measurements have been added to save time.',
        de: 'Die Milliradienformel ermöglicht die Berechnung einer Entfernung mit Ihrem Zielfernrohr und bekannten visuellen Referenzen aus dem Feld.\nStandardvorlagen mit Messungen wurden hinzugefügt, um Zeit zu sparen.',
        it: 'La formula dei milliradi permette di calcolare una distanza utilizzando il tuo cannocchiale e riferimenti visivi noti del campo.\nSono stati aggiunti modelli standard con misure per risparmiare tempo.',
        es: 'La fórmula de miliradianes permite calcular una distancia usando su mira y referencias visuales conocidas del campo.\nSe han añadido plantillas estándar con medidas para ahorrar tiempo.',
      );
}
