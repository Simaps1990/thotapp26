part of 'app_strings.dart';

extension AppStringsSessions on AppStrings {
  // --- Sessions ---

  String get sessionsSubtitle => _pick(
    fr: 'SESSIONS',
    en: 'SESSIONS',
    de: 'SITZUNGEN',
    it: 'SESSIONI',
    es: 'SESIONES',
  );

  String get newSessionCta => _pick(
    fr: 'Nouvelle session',
    en: 'New session',
    de: 'Neue Sitzung',
    it: 'Nuova sessione',
    es: 'Nueva sesión',
  );

  String get sessionsFilterAll =>
      _pick(fr: 'Toutes', en: 'All', de: 'Alle', it: 'Tutte', es: 'Todas');

  String get sessionsFilterMonth => _pick(
    fr: 'Ce mois',
    en: 'This month',
    de: 'Dieser Monat',
    it: 'Questo mese',
    es: 'Este mes',
  );

  String get sessionsFilter7Days => _pick(
    fr: '7 jours',
    en: '7 days',
    de: '7 Tage',
    it: '7 giorni',
    es: '7 días',
  );

  String get sessionsSortDate =>
      _pick(fr: 'Date', en: 'Date', de: 'Datum', it: 'Data', es: 'Fecha');

  String get sessionsSortName =>
      _pick(fr: 'Nom', en: 'Name', de: 'Name', it: 'Nome', es: 'Nombre');

  String get searchSessionsHint => _pick(
    fr: 'Rechercher une séance...',
    en: 'Search sessions...',
    de: 'Sitzungen suchen...',
    it: 'Cerca sessioni...',
    es: 'Buscar sesiones...',
  );

  String sessionExerciseDefaultTitle(int index) => _pick(
    fr: 'Exercice $index',
    en: 'Exercise $index',
    de: 'Übung $index',
    it: 'Esercizio $index',
    es: 'Ejercicio $index',
  );

  String get sessionPlatformAndEquipmentDetailsTitle => _pick(
    fr: 'Matériel utilisé',
    en: 'Equipment used',
    de: 'Verwendete Ausrüstung',
    it: 'Attrezzatura utilizzata',
    es: 'Equipo utilizado',
  );

  String get sessionShootingResultsTitle => _pick(
    fr: "Déroulé de l'exercice",
    en: 'Exercise log',
    de: 'Trainingsablauf',
    it: "Dettagli dell'esercizio",
    es: 'Desarrollo del ejercicio',
  );

  String get deleteHistoryEntryTitle => _pick(
    fr: "Supprimer l'entrée",
    en: 'Delete entry',
    de: 'Eintrag löschen',
    it: "Elimina l'iscrizione",
    es: 'Eliminar entrada',
  );

  String get deleteButton => _pick(
    fr: 'Supprimer',
    en: 'Delete',
    de: 'Löschen',
    it: 'Elimina',
    es: 'Eliminar',
  );

  String get moveUp => _pick(
    fr: 'Monter',
    en: 'Move up',
    de: 'Nach oben',
    it: 'Sposta su',
    es: 'Mover arriba',
  );

  String get moveDown => _pick(
    fr: 'Descendre',
    en: 'Move down',
    de: 'Nach unten',
    it: 'Sposta giù',
    es: 'Mover abajo',
  );

  String get cancelButton => _pick(
    fr: 'Annuler',
    en: 'Cancel',
    de: 'Abbrechen',
    it: 'Annulla',
    es: 'Cancelar',
  );

  String get deleteHistoryEntryConfirm => _pick(
    fr: 'Êtes-vous sûr de vouloir supprimer cette opération ? Le stock sera ajusté en conséquence.',
    en: 'Are you sure you want to delete this operation? The stock will be adjusted accordingly.',
    de: 'Sind Sie sicher, dass Sie diesen Vorgang löschen möchten? Der Lagerbestand wird entsprechend angepasst.',
    it: 'Sei sicuro di voler eliminare questa operazione? Lo stock verrà adeguato di conseguenza.',
    es: '¿Está seguro de que desea eliminar esta operación? El stock se ajustará en consecuencia.',
  );

  String get sessionsEmptySearchTitle => _pick(
    fr: 'Aucune session trouvée',
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
    fr: 'Aucune session pour cette période',
    en: 'No session for this period',
    de: 'Keine Sitzung in diesem Zeitraum',
    it: 'Nessuna sessione per questo periodo',
    es: 'No hay sesiones para este período',
  );

  String get sessionsEmptyPeriodSubtitle => _pick(
    fr: 'Créez votre première session',
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
    fr: 'NOUVELLE SESSION',
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
    fr: 'Nom de la session *',
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
    fr: 'Date et heure de la session',
    en: 'Session date and time',
    de: 'Sitzungsdatum und -uhrzeit',
    it: 'Data e ora della sessione',
    es: 'Fecha y hora de la sesión',
  );

  String get locationLabel =>
      _pick(fr: 'Ville', en: 'City', de: 'Stadt', it: 'Città', es: 'Ciudad');

  String get locationHint => _pick(
    fr: 'Ex. : Club de tir de la ville',
    en: 'E.g. City range club',
    de: 'Z. B. Schützenverein der Stadt',
    it: 'Es.: club di tiro della città',
    es: 'Ej.: club de tiro de la ciudad',
  );

  String get shootingDistanceLabel => _pick(
    fr: 'Quel stand de tir?',
    en: 'Which training lane?',
    de: 'Welche Trainingsbahn?',
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
}
