part of 'app_strings.dart';

extension AppStringsNewSession on AppStrings {
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
    en: 'Rounds',
    de: 'Schüsse',
    it: 'Colpi sparati',
    es: 'Disparos',
  );

  String get shotsCountLabel => _pick(
    fr: 'NB DE COUPS',
    en: 'NO. OF ROUNDS',
    de: 'ANZ. SCHÜSSE',
    it: 'N. COLPI',
    es: 'N.º DISPAROS',
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
    fr: 'Type de session',
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

  /// Returns the localized display name for a stored session type key.
  String sessionTypeDisplayName(String typeKey) {
    switch (typeKey) {
      case 'Professionnel':
        return sessionTypeProfessional;
      case 'Compétition':
        return sessionTypeCompetition;
      case 'Personnel':
      default:
        return sessionTypePersonal;
    }
  }

  String get sessionSummaryTitle => _pick(
    fr: 'Résumé session',
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
    fr: 'Détails plateforme & équipement',
    en: 'Platform & gear details',
    de: 'Plattform- & Ausrüstungsdetails',
    it: 'Dettagli piattaforma e attrezzatura',
    es: 'Detalles de plataforma y equipo',
  );

  String get shootingResultsTitle => _pick(
    fr: 'Résultats du tir',
    en: 'Shooting results',
    de: 'Trainingsergebnisse',
    it: 'Risultati di tiro',
    es: 'Resultados del tiro',
  );

  String get borrowedPlatformFallback => _pick(
    fr: 'Plateforme prêtée',
    en: 'Borrowed platform',
    de: 'Geliehene Plattform',
    it: 'Piattaforma prestata',
    es: 'Plataforma prestada',
  );

  String get borrowedAmmoFallback => _pick(
    fr: 'Consommable prêté',
    en: 'Borrowed ammo',
    de: 'Geliehenes Verbrauchsmaterial',
    it: 'Consumabile prestato',
    es: 'Consumible prestado',
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
    fr: 'Impact sur les consommables',
    en: 'Ammo impact',
    de: 'Auswirkung auf Verbrauchsmaterial',
    it: 'Impatto sui consumabili',
    es: 'Impacto en consumibles',
  );

  String get sessionSummaryPlatformsImpactTitle => _pick(
    fr: 'Impact sur les plateformes',
    en: 'Platform impact',
    de: 'Auswirkung auf Plattformen',
    it: 'Impatto sulle piattaforme',
    es: 'Impacto en plataformas',
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

  String sessionSummaryAmmoImpactLineWithCost(
    String name,
    int shots,
    int remaining,
    String cost,
    String currency,
  ) => _pick(
    fr: '• $name : $shots coups tirés ($cost $currency), $remaining restantes',
    en: '• $name: $shots shots fired ($currency$cost), $remaining remaining',
    de: '• $name: $shots Schüsse ($cost $currency), $remaining verbleibend',
    it: '• $name: $shots colpi sparati ($currency $cost), $remaining rimanenti',
    es: '• $name: $shots disparos ($currency$cost), $remaining restantes',
  );

  String sessionSummaryPlatformImpactLine(String name, int shots) => _pick(
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
    fr: 'ENREGISTRER LA SESSION',
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

  String get windLabel =>
      _pick(fr: 'Vent', en: 'Wind', de: 'Wind', it: 'Vento', es: 'Viento');

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
    fr: 'Météo indisponible. Veuillez saisir une ville.',
    en: 'Weather unavailable. Please enter a city.',
    de: 'Wetter nicht verfügbar. Bitte Stadt eingeben.',
    it: 'Meteo non disponibile. Inserisci una città.',
    es: 'Clima no disponible. Por favor ingrese una ciudad.',
  );

  String get locationPermissionDeniedForever => _pick(
    fr: 'Météo indisponible. Veuillez saisir une ville valide.',
    en: 'Weather unavailable. Please enter a valid city.',
    de: 'Wetter nicht verfügbar. Bitte gültige Stadt eingeben.',
    it: 'Meteo non disponibile. Inserisci una città valida.',
    es: 'Clima no disponible. Por favor ingrese una ciudad válida.',
  );

  String get locationUsageExplanation => _pick(
    fr: 'Ville saisie manuellement pour la météo locale. Pas d\'accès automatique à la position.',
    en: 'Manually entered city for local weather. No automatic position access.',
    de: 'Manuell eingegebene Stadt für das lokale Wetter. Kein automatischer Positionszugriff.',
    it: 'Città inserita manualmente per il meteo locale. Nessun accesso automatico alla posizione.',
    es: 'Ciudad ingresada manualmente para el clima local. Sin acceso automático a la posición.',
  );

  String get weatherUsageExplanation => _pick(
    fr: 'Le bouton météo récupère la météo locale utile à la session, sans utilisation en arrière-plan.',
    en: 'The weather button fetches local weather for the session, with no background use.',
    de: 'Die Wetterschaltfläche ruft das lokale Wetter für die Sitzung ab, ohne Nutzung im Hintergrund.',
    it: 'Il pulsante meteo recupera il meteo locale per la sessione, senza uso in background.',
    es: 'El botón del clima obtiene el clima local para la sesión, sin uso en segundo plano.',
  );

  String get fetchLocalWeatherButton => _pick(
    fr: 'Récupérer la météo locale',
    en: 'Fetch local weather',
    de: 'Lokales Wetter abrufen',
    it: 'Recupera meteo locale',
    es: 'Obtener clima local',
  );

  String get weatherLocationPermissionDenied => _pick(
    fr: 'Météo indisponible. Veuillez saisir une ville.',
    en: 'Weather unavailable. Please enter a city.',
    de: 'Wetter nicht verfügbar. Bitte Stadt eingeben.',
    it: 'Meteo non disponibile. Inserire una città.',
    es: 'Clima no disponible. Por favor ingrese una ciudad.',
  );

  String get weatherLocationPermissionDeniedForever => _pick(
    fr: 'Météo indisponible. Veuillez saisir une ville valide.',
    en: 'Weather unavailable. Please enter a valid city.',
    de: 'Wetter nicht verfügbar. Bitte gültige Stadt eingeben.',
    it: 'Meteo non disponibile. Inserire una città valida.',
    es: 'Clima no disponible. Por favor ingrese una ciudad válida.',
  );

  String get weatherLocationServicesDisabled => _pick(
    fr: 'Météo indisponible. Veuillez vérifier votre connexion.',
    en: 'Weather unavailable. Please check your connection.',
    de: 'Wetter nicht verfügbar. Bitte Verbindung prüfen.',
    it: 'Meteo non disponibile. Verificare la connessione.',
    es: 'Clima no disponible. Verifique su conexión.',
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
    fr: 'Météo indisponible pour cette ville.',
    en: 'Weather unavailable for this city.',
    de: 'Wetter für diese Stadt nicht verfügbar.',
    it: 'Meteo non disponibile per questa città.',
    es: 'Clima no disponible para esta ciudad.',
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

  String get freeVersionPlatformLimit => _pick(
    fr: 'Version gratuite : seule la première plateforme est utilisable. Passez à Pro pour débloquer tout le matériel.',
    en: 'Free version: only the first platform is usable. Upgrade to Pro to unlock all equipment.',
    de: 'Kostenlose Version: nur die erste Plattform ist verwendbar. Upgrade auf Pro, um die gesamte Ausrüstung freizuschalten.',
    it: 'Versione gratuita: solo la prima piattaforma è utilizzabile. Passa a Pro per sbloccare tutta l\'attrezzatura.',
    es: 'Versión gratuita: solo la primera plataforma es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
  );

  String get freeVersionAmmoLimit => _pick(
    fr: 'Version gratuite : seule le premier consommable est utilisable. Passez à Pro pour débloquer tout le matériel.',
    en: 'Free version: only the first 5 consumable entries are usable. Upgrade to Pro to unlock all equipment.',
    de: 'Kostenlose Version: nur die ersten 5 Verbrauchsmaterial sind verwendbar. Upgrade auf Pro, um die gesamte Ausrüstung freizuschalten.',
    it: 'Versione gratuita: solo i primi 5 consumabili sono utilizzabili. Passa a Pro per sbloccare tutta l\'attrezzatura.',
    es: 'Versión gratuita: solo los primeros 5 consumibles son utilizables. Actualiza a Pro para desbloquear todo el equipo.',
  );

  String get freeVersionAccessoryLimit => _pick(
    fr: 'Version gratuite : seul le premier accessoire est utilisable. Passez à Pro pour débloquer tout le matériel.',
    en: 'Free version: only the first accessory is usable. Upgrade to Pro to unlock all equipment.',
    de: 'Kostenlose Version: nur das erste Zubehör ist verwendbar. Upgrade auf Pro, um die gesamte Ausrüstung freizuschalten.',
    it: 'Versione gratuita: solo il primo accessorio è utilizzabile. Passa a Pro per sbloccare tutta l’attrezzatura.',
    es: 'Versión gratuita: solo el primer accesorio es utilizable. Actualiza a Pro para desbloquear todo el equipo.',
  );

  String get sessionDuplicatedSnack => _pick(
    fr: 'Session dupliquée',
    en: 'Session duplicated',
    de: 'Sitzung dupliziert',
    it: 'Sessione duplicata',
    es: 'Sesión duplicada',
  );

  String get sessionLabelPlatform => _pick(
    fr: 'Plateforme',
    en: 'Platform',
    de: 'Plattform',
    it: 'Piattaforma',
    es: 'Plataforma',
  );

  String get sessionLabelAmmo => _pick(
    fr: 'Consommable',
    en: 'Ammo',
    de: 'Verbrauchsmaterial',
    it: 'Consumabile',
    es: 'Consumible',
  );

  String get inventoryTitle =>
      _pick(fr: 'THOT', en: 'THOT', de: 'THOT', it: 'THOT', es: 'THOT');

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

  String get platformsTab => _pick(
    fr: 'Plateformes',
    en: 'Platforms',
    de: 'Plattformen',
    it: 'Piattaforme',
    es: 'Plataformas',
  );

  String get ammosTab => _pick(
    fr: 'Consommables',
    en: 'Consumables',
    de: 'Verbrauchsmaterial',
    it: 'Consumabili',
    es: 'Consumibles',
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

  String get addPlatform => _pick(
    fr: 'Ajouter une plateforme',
    en: 'Add platform',
    de: 'Plattform hinzufügen',
    it: 'Aggiungi piattaforma',
    es: 'Agregar plataforma',
  );

  String get addAmmo => _pick(
    fr: 'Ajouter une boîte',
    en: 'Add a box',
    de: 'Eine Box hinzufügen',
    it: 'Aggiungi una scatola',
    es: 'Agregar una caja',
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

  String get noPlatformFound => _pick(
    fr: 'Aucune plateforme trouvée',
    en: 'No platform found',
    de: 'Keine Plattform gefunden',
    it: 'Nessuna piattaforma trovata',
    es: 'No se encontró plataforma',
  );

  String get noPlatformInStock => _pick(
    fr: "Vous n'avez pas de plateforme en stock.",
    en: "You don't have any platforms in stock.",
    de: 'Du hast keine Plattformen im Bestand.',
    it: 'Non hai piattaforme in stock.',
    es: 'No tienes plataformas en stock.',
  );

  String get addFirstPlatform => _pick(
    fr: 'Ajoutez votre première plateforme',
    en: 'Add your first platform',
    de: 'Füge deine erste Plattform hinzu',
    it: 'Aggiungi la tua prima piattaforma',
    es: 'Agrega tu primera plataforma',
  );

  String get noAmmoFound => _pick(
    fr: 'Aucun consommable trouvé',
    en: 'No consumable found',
    de: 'Kein Verbrauchsmaterial gefunden',
    it: 'Nessun consumabile trovato',
    es: 'No se encontró consumible',
  );

  String get noAmmoInStock => _pick(
    fr: "Vous n'avez pas de consommable en stock.",
    en: "You don't have any consumable in stock.",
    de: 'Du hast kein Verbrauchsmaterial im Bestand.',
    it: 'Non hai consumabili in stock.',
    es: 'No tienes consumibles en stock.',
  );

  String get addFirstAmmo => _pick(
    fr: 'Ajoutez votre première boîte',
    en: 'Add your first box',
    de: 'Füge deine erste Box hinzu',
    it: 'Aggiungi la tua prima scatola',
    es: 'Agrega tu primera caja',
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
    fr: 'Dernière session',
    en: 'Last session',
    de: 'Letzte Sitzung',
    it: 'Ultima sessione',
    es: 'Última sesión',
  );

  String get yesterday =>
      _pick(fr: 'Hier', en: 'Yesterday', de: 'Gestern', it: 'Ieri', es: 'Ayer');

  String get edit => _pick(
    fr: 'Éditer',
    en: 'Edit',
    de: 'Bearbeiten',
    it: 'Modifica',
    es: 'Editar',
  );

  String get add => _pick(
    fr: 'Ajouter',
    en: 'Add',
    de: 'Hinzufügen',
    it: 'Aggiungi',
    es: 'Añadir',
  );

  String get notes =>
      _pick(fr: 'Notes', en: 'Notes', de: 'Notizen', it: 'Note', es: 'Notas');

  String get noteOptional => _pick(
    fr: 'Note (optionnelle)',
    en: 'Note (optional)',
    de: 'Notiz (optional)',
    it: 'Nota (opzionale)',
    es: 'Nota (opcional)',
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

  String get settingsOpenDocument =>
      _pick(fr: 'Ouvrir', en: 'Open', de: 'Öffnen', it: 'Apri', es: 'Abrir');

  String get settingsAdd => _pick(
    fr: 'Ajouter',
    en: 'Add',
    de: 'Hinzufügen',
    it: 'Aggiungi',
    es: 'Añadir',
  );

  String get linkToAccessory => _pick(
    fr: 'Lier à un accessoire',
    en: 'Link to accessory',
    de: 'Mit Zubehör verknüpfen',
    it: 'Collega a un accessorio',
    es: 'Vincular a un accesorio',
  );

  String get linkToPlatform => _pick(
    fr: 'Lier à une plateforme',
    en: 'Link to platform',
    de: 'Mit Plattform verknüpfen',
    it: 'Collega a una piattaforma',
    es: 'Vincular a una plataforma',
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

  String get settingsPremiumFeaturePlatformsDetailed => _pick(
    fr: '✓ Plateformes illimitées (actuellement limité à 1)',
    en: '✓ Unlimited platforms (currently limited to 1)',
    de: '✓ Unbegrenzte Plattformen (derzeit auf 1 begrenzt)',
    it: '✓ Piattaforme illimitate (attualmente limitate a 1)',
    es: '✓ Plataformas ilimitadas (actualmente limitado a 1)',
  );

  String get settingsPremiumFeatureAmmosDetailed => _pick(
    fr: '✓ Consommables illimités (actuellement limité à 1)',
    en: '✓ Unlimited consumables (currently limited to 1)',
    de: '✓ Unbegrenzte Verbrauchsmaterialien (derzeit auf 1 begrenzt)',
    it: '✓ Consumabili illimitati (attualmente limitati a 1)',
    es: '✓ Consumibles ilimitados (actualmente limitados a 1)',
  );

  String get settingsPremiumFeatureSessionsDetailed => _pick(
    fr: '✓ Sessions illimitées (actuellement limité à 5)',
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

  String get proBadge =>
      _pick(fr: 'PRO', en: 'PRO', de: 'PRO', it: 'PRO', es: 'PRO');

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
    fr: 'Efface profil, inventaire, sessions, diagnostics et documents stockés sur cet appareil',
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
    fr: 'Cette action supprime de cet appareil votre profil, inventaire, sessions, diagnostics et documents ajoutés dans l\'application. Cette action est irréversible.',
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

  String get dateFormatYearMonthDay => _pick(
    fr: 'Année Mois Jour',
    en: 'Year Month Day',
    de: 'Jahr Monat Tag',
    it: 'Anno Mese Giorno',
    es: 'Año Mes Día',
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
    fr: 'Session introuvable',
    en: 'Session not found',
    de: 'Sitzung nicht gefunden',
    it: 'Sessione non trovata',
    es: 'Sesión no encontrada',
  );

  String get sessionNotFoundNoId => _pick(
    fr: 'Aucun identifiant de session fourni',
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
    fr: "Impossible d'ouvrir cette session",
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

  String get weatherTitleShort =>
      _pick(fr: 'Météo', en: 'Weather', de: 'Wetter', it: 'Meteo', es: 'Clima');

  String get noExerciseForSession => _pick(
    fr: 'Aucun exercice enregistré pour cette session',
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

  String get noPlatformInStockSwitchBorrowed => _pick(
    fr: 'Aucune plateforme dans le stock. Passe en “Prêtée”.',
    en: 'No platform in inventory. Switch to “Borrowed”.',
    de: 'Keine Plattform im Bestand. Wechsle zu “Geliehen”.',
    it: 'Nessuna piattaforma in stock. Passa a “Prestito”.',
    es: 'No hay plataforma en inventario. Cambia a “Prestada”.',
  );

  String get noAmmoInStockSwitchBorrowed => _pick(
    fr: 'Aucun consommable dans le stock. Passe en "Prêtée".',
    en: 'No ammo in inventory. Switch to “Borrowed”.',
    de: 'Kein Verbrauchsmaterial im Bestand. Wechsle zu "Geliehen".',
    it: 'Nessun consumabile in inventario. Passa a "Prestata".',
    es: 'No hay consumible en el inventario. Cambia a "Prestada".',
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

  String get borrowedPlatformOptional => _pick(
    fr: 'Plateforme prêtée (détail optionnel)',
    en: 'Borrowed platform (optional details)',
    de: 'Geliehene Plattform (optionale Details)',
    it: 'Piattaforma prestata (dettagli opzionali)',
    es: 'Plataforma prestada (detalles opcionales)',
  );

  String get borrowedPlatformHint => _pick(
    fr: 'Ex: Glock 17, club…',
    en: 'Ex: Glock 17, club…',
    de: 'Bsp.: Glock 17, Verein…',
    it: 'Es: Glock 17, club…',
    es: 'Ej: Glock 17, club…',
  );

  String get borrowedAmmoOptional => _pick(
    fr: 'Consommable prêté (détail optionnel)',
    en: 'Borrowed ammo (optional details)',
    de: 'Geliehenes Verbrauchsmaterial (optional)',
    it: 'Consumabile prestato (dettagli opzionali)',
    es: 'Consumible prestado (detalles opcionales)',
  );

  String get borrowedAmmoHint => _pick(
    fr: 'Ex: 9×19 FMJ, rechargée…',
    en: 'Ex: 9×19 FMJ, reloaded…',
    de: 'Bsp.: 9×19 FMJ, wiedergeladen…',
    it: 'Es: 9×19 FMJ, ricaricata…',
    es: 'Ej: 9×19 FMJ, recargada…',
  );

  String get platformTitle => _pick(
    fr: 'Plateforme',
    en: 'Platform',
    de: 'Plattform',
    it: 'Piattaforma',
    es: 'Plataforma',
  );

  String get ammoTitle => _pick(
    fr: 'Consommable',
    en: 'Ammo',
    de: 'Verbrauchsmaterial',
    it: 'Consumabile',
    es: 'Consumible',
  );

  String get choosePlatformFromInventory => _pick(
    fr: 'Choisir une plateforme dans ton stock',
    en: 'Choose a platform from your inventory',
    de: 'Wähle eine Plattform aus deinem Bestand',
    it: 'Scegli una piattaforma dal tuo inventario',
    es: 'Elige una plataforma de tu inventario',
  );

  String get chooseAmmoFromInventory => _pick(
    fr: 'Choisir un consommable dans ton stock',
    en: 'Choose ammo from your inventory',
    de: 'Wähle ein Verbrauchsmaterial aus deinem Bestand',
    it: 'Scegli un consumabile dal tuo inventario',
    es: 'Elige un consumible de tu inventario',
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

  String get createTemplateButton => _pick(
    fr: 'Créer un modèle',
    en: 'Create a template',
    de: 'Vorlage erstellen',
    it: 'Crea un modello',
    es: 'Crear una plantilla',
  );

  String get createExerciseTemplateTitle => _pick(
    fr: 'CRÉER UN MODÈLE',
    en: 'CREATE A TEMPLATE',
    de: 'VORLAGE ERSTELLEN',
    it: 'CREA UN MODELLO',
    es: 'CREAR UNA PLANTILLA',
  );

  String get createTemplateTooltip => _pick(
    fr: "Créez un modèle d'exercice pour le réutiliser plus tard.",
    en: 'Create an exercise template to reuse it later.',
    de: 'Erstellen Sie eine Übungsvorlage, um sie später wiederzuverwenden.',
    it: 'Crea un modello di esercizio per riutilizzarlo più tardi.',
    es: 'Cree una plantilla de ejercicio para reutilizarla más tarde.',
  );

  String get editTemplateTooltip => _pick(
    fr: "Modifiez un modèle d'exercice existant.",
    en: 'Modify an existing exercise template.',
    de: 'Ändern Sie eine vorhandene Übungsvorlage.',
    it: 'Modifica un modello di esercizio esistente.',
    es: 'Modifique una plantilla de ejercicio existente.',
  );

  String get exerciseTemplatesStandardSection => _pick(
    fr: 'Drills standards THOT',
    en: 'THOT standard drills',
    de: 'THOT Standard-Drills',
    it: 'Drill standard THOT',
    es: 'Drills estándar THOT',
  );

  String get exerciseTemplatesMyTemplatesSection => _pick(
    fr: 'Mes modèles',
    en: 'My templates',
    de: 'Meine Vorlagen',
    it: 'I miei modelli',
    es: 'Mis plantillas',
  );

  String get exerciseTemplatesStandardBadge =>
      _pick(fr: 'STD', en: 'STD', de: 'STD', it: 'STD', es: 'STD');

  String get exerciseTemplatesDuplicateAction => _pick(
    fr: 'Dupliquer pour modifier',
    en: 'Duplicate to edit',
    de: 'Zum Bearbeiten duplizieren',
    it: 'Duplica per modificare',
    es: 'Duplicar para editar',
  );

  String get exerciseTemplatesUseInSession => _pick(
    fr: 'Utiliser dans une session',
    en: 'Use in a session',
    de: 'In Sitzung verwenden',
    it: 'Usa in una sessione',
    es: 'Usar en una sesión',
  );

  String get sessionLabelShots =>
      _pick(fr: 'Cps', en: 'Rds', de: 'Sch.', it: 'Col.', es: 'Disp.');

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
    fr: 'Voulez-vous vraiment supprimer la session "$sessionName" ?',
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
    fr: 'Session de tir - ',
    en: 'Shooting session - ',
    de: 'Schießsitzung - ',
    it: 'Sessione di tiro - ',
    es: 'Sesión de tiro - ',
  );

  String get exportSessionTitle => _pick(
    fr: 'Exporter la session',
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

  String get offlineWeatherUnavailable => _pick(
    fr: 'Hors ligne — météo indisponible.',
    en: 'Offline — weather unavailable.',
    de: 'Offline — Wetter nicht verfügbar.',
    it: 'Offline — meteo non disponibile.',
    es: 'Sin conexión — clima no disponible.',
  );

  String get offlineLocationUnavailable => _pick(
    fr: 'Hors ligne — météo indisponible.',
    en: 'Offline — weather unavailable.',
    de: 'Offline — Wetter nicht verfügbar.',
    it: 'Offline — meteo non disponibile.',
    es: 'Sin conexión — clima no disponible.',
  );

  String get offlineBadgeLabel => _pick(
    fr: 'HORS LIGNE',
    en: 'OFFLINE',
    de: 'OFFLINE',
    it: 'OFFLINE',
    es: 'SIN CONEXIÓN',
  );
}
