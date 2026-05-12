part of 'app_strings.dart';

extension AppStringsTemplates on AppStrings {
  // --- Exercise Templates ---

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
    fr: 'Créer',
    en: 'Create',
    de: 'Erstellen',
    it: 'Crea',
    es: 'Crear',
  );

  String get importExerciseButton => _pick(
    fr: 'Importer',
    en: 'Import',
    de: 'Importieren',
    it: 'Importa',
    es: 'Importar',
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

  String get saveExerciseButton => _pick(
    fr: "ENREGISTRER L'EXERCICE",
    en: 'SAVE EXERCISE',
    de: 'ÜBUNG SPEICHERN',
    it: 'SALVA ESERCIZIO',
    es: 'GUARDAR EJERCICIO',
  );
}
