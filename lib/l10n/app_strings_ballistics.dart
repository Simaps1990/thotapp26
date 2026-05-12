part of 'app_strings.dart';

extension AppStringsBallistics on AppStrings {
  // --- Ballistic Calculations ---

  String get ballisticCalcTitle => _pick(
    fr: 'OUTILS DE CALCUL',
    en: 'CALCULATION TOOLS',
    de: 'BERECHNUNGSTOOLS',
    it: 'STRUMENTI DI CALCOLO',
    es: 'HERRAMIENTAS DE CÁLCULO',
  );

  String get ballisticCalcTooltip => _pick(
    fr: '''• **Millième** : Calcule la distance avec votre lunette et des références visuelles
• **Hit Factor** : Mesure la performance (points ÷ temps)
• **Power Factor** : Classe la munition (Major/Minor) selon sa puissance''',
    en: '''• **Milliradian**: Calculate distance with scope and visual references
• **Hit Factor**: Measure performance (points ÷ time)
• **Power Factor**: Classify ammunition (Major/Minor) by power''',
    de: '''• **Milliradien**: Entfernung mit Zielfernrohr und visuellen Referenzen berechnen
• **Hit Factor**: Leistung messen (Punkte ÷ Zeit)
• **Power Factor**: Munition klassifizieren (Major/Minor) nach Leistung''',
    it: '''• **Milliradiano**: Calcola la distanza con mirino e riferimenti visivi
• **Hit Factor**: Misura la performance (punti ÷ tempo)
• **Power Factor**: Classifica il munizionamento (Major/Minor) per potenza''',
    es: '''• **Milirradianes**: Calcular distancia con mira y referencias visuales
• **Hit Factor**: Medir rendimiento (puntos ÷ tiempo)
• **Power Factor**: Clasificar munición (Major/Minor) por potencia''',
  );

  String get ballisticCalcTabMillieme =>
      _pick(fr: 'Millième', en: 'Mil', de: 'Mil', it: 'Mil', es: 'Mil');

  String get ballisticCalcTabHitFactor => _pick(
    fr: 'Hit Factor',
    en: 'Hit Factor',
    de: 'Hit Factor',
    it: 'Hit Factor',
    es: 'Hit Factor',
  );

  String get ballisticCalcTabPowerFactor => _pick(
    fr: 'Power Factor',
    en: 'Power Factor',
    de: 'Power Factor',
    it: 'Power Factor',
    es: 'Power Factor',
  );

  String get powerFactorVelocityLabel => _pick(
    fr: 'Vitesse à la bouche',
    en: 'Muzzle velocity',
    de: 'Mündungsgeschwindigkeit',
    it: 'Velocità alla bocca',
    es: 'Velocidad en boca',
  );

  String get powerFactorWeightLabel => _pick(
    fr: 'Poids de la balle',
    en: 'Bullet weight',
    de: 'Geschossgewicht',
    it: 'Peso del proiettile',
    es: 'Peso de la bala',
  );

  String get powerFactorVelocityHint => _pick(
    fr: 'Ex: 380',
    en: 'E.g. 380',
    de: 'Z.B. 380',
    it: 'Es: 380',
    es: 'Ej: 380',
  );

  String get powerFactorWeightHint => _pick(
    fr: 'Ex: 124',
    en: 'E.g. 124',
    de: 'Z.B. 124',
    it: 'Es: 124',
    es: 'Ej: 124',
  );

  String get powerFactorResultLabel => _pick(
    fr: 'Power Factor',
    en: 'Power Factor',
    de: 'Power Factor',
    it: 'Power Factor',
    es: 'Power Factor',
  );

  String get powerFactorClassificationMajor =>
      _pick(fr: 'MAJOR', en: 'MAJOR', de: 'MAJOR', it: 'MAJOR', es: 'MAJOR');

  String get powerFactorClassificationMinor =>
      _pick(fr: 'MINOR', en: 'MINOR', de: 'MINOR', it: 'MINOR', es: 'MINOR');

  String get powerFactorClassificationSubMinor => _pick(
    fr: 'Sub-minor (non classifié)',
    en: 'Sub-minor (unclassified)',
    de: 'Sub-Minor (nicht klassifiziert)',
    it: 'Sub-minor (non classificato)',
    es: 'Sub-minor (sin clasificar)',
  );

  String get powerFactorFormulaNote => _pick(
    fr: 'Formule : (vitesse en fps × poids en grain) ÷ 1000',
    en: 'Formula: (velocity in fps × weight in grain) ÷ 1000',
    de: 'Formel: (Geschwindigkeit in fps × Gewicht in grain) ÷ 1000',
    it: 'Formula: (velocità in fps × peso in grain) ÷ 1000',
    es: 'Fórmula: (velocidad en fps × peso en grain) ÷ 1000',
  );

  String get powerFactorThresholdsNote => _pick(
    fr: 'Les seuils dépendent de la division. Vérifiez les règlements officiels.',
    en: 'Thresholds depend on the division. Check official rulebooks.',
    de: 'Die Schwellenwerte hängen von der Division ab. Prüfen Sie die offiziellen Regelwerke.',
    it: 'Le soglie dipendono dalla divisione. Verifica i regolamenti ufficiali.',
    es: 'Los umbrales dependen de la división. Consulta los reglamentos oficiales.',
  );

  String get hitFactorTimeLabel => _pick(
    fr: 'Temps total (s)',
    en: 'Total time (s)',
    de: 'Gesamtzeit (s)',
    it: 'Tempo totale (s)',
    es: 'Tiempo total (s)',
  );

  String get hitFactorReset => _pick(
    fr: 'Réinitialiser',
    en: 'Reset',
    de: 'Zurücksetzen',
    it: 'Reimposta',
    es: 'Reiniciar',
  );

  String get hitFactorCoefficientsLegend => _pick(
    fr: 'Coefficients utilisés',
    en: 'Coefficients used',
    de: 'Verwendete Koeffizienten',
    it: 'Coefficienti utilizzati',
    es: 'Coeficientes utilizados',
  );
}
