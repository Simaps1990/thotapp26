part of 'app_strings.dart';

extension AppStringsPin on AppStrings {
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

  String premiumLimitMessage(
    String current,
    String max,
    String itemLabel,
  ) => _pick(
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

  String get unknownPlatform => _pick(
    fr: 'Plateforme inconnue',
    en: 'Unknown platform',
    de: 'Unbekannte Plattform',
    it: 'Piattaforma sconosciuta',
    es: 'Plataforma desconocida',
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

  String get yesUpper =>
      _pick(fr: 'OUI', en: 'YES', de: 'JA', it: 'SÌ', es: 'SÍ');

  String get noUpper =>
      _pick(fr: 'NON', en: 'NO', de: 'NEIN', it: 'NO', es: 'NO');

  String get closeUpper => _pick(
    fr: 'FERMER',
    en: 'CLOSE',
    de: 'SCHLIESSEN',
    it: 'CHIUDI',
    es: 'CERRAR',
  );

  String get immobilizePlatformTitle => _pick(
    fr: "IMMOBILISATION DE LA PLATEFORME",
    en: 'PLATFORM IMMOBILIZATION',
    de: 'PLATTFORM STILLLEGEN',
    it: "IMMOBILIZZAZIONE DELLA PIATTAFORMA",
    es: 'INMOVILIZACIÓN DE LA PLATAFORMA',
  );

  String get immobilizePlatformMessage => _pick(
    fr: "Risque élevé.\n\nImmobilisez la plateforme et faites contrôler par un professionnel qualifié avant toute réutilisation.",
    en: 'High risk.\n\nTake the platform out of service and have it checked by a qualified technician before any further use.',
    de: 'Hohes Risiko.\n\nPlattform stilllegen und vor weiterer Nutzung von einem qualifizierten Techniker prüfen lassen.',
    it: "Rischio elevato.\n\nImmobilizza la piattaforma e falla controllare da un tecnico qualificato prima di riutilizzarla.",
    es: 'Riesgo elevado.\n\nInmoviliza la plataforma y hazla revisar por un técnico cualificado antes de volver a usarla.',
  );

  String get saveDiagnosticUpper => _pick(
    fr: 'ENREGISTRER LE DIAGNOSTIC',
    en: 'SAVE DIAGNOSTIC',
    de: 'DIAGNOSE SPEICHERN',
    it: 'SALVA DIAGNOSI',
    es: 'GUARDAR DIAGNÓSTICO',
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

  String get platformLabel => _pick(
    fr: 'Plateforme',
    en: 'Platform',
    de: 'Plattform',
    it: 'Piattaforma',
    es: 'Plataforma',
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
    fr: 'NOUVEAU CONSOMMABLE',
    en: 'NEW AMMO',
    de: 'NEUES VERBRAUCHSMATERIAL',
    it: 'NUOVI CONSUMABILI',
    es: 'NUEVO CONSUMIBLE',
  );

  String get designationRegisterLabel => _pick(
    fr: 'Nom personnalisé',
    en: 'Custom name',
    de: 'Benutzerdefinierter Name',
    it: 'Nome personalizzato',
    es: 'Nombre personalizado',
  );

  String get brandLabel =>
      _pick(fr: 'Marque', en: 'Brand', de: 'Marke', it: 'Marca', es: 'Marca');

  String get typeLabel =>
      _pick(fr: 'Type', en: 'Type', de: 'Typ', it: 'Tipo', es: 'Tipo');

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

  String get itemPhotoLabel =>
      _pick(fr: 'Photo', en: 'Photo', de: 'Foto', it: 'Foto', es: 'Foto');

  String get itemDocumentsLabel => _pick(
    fr: 'DOCUMENTS',
    en: 'DOCUMENTS',
    de: 'DOKUMENTE',
    it: 'DOCUMENTI',
    es: 'DOCUMENTOS',
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
    fr: 'ENREGISTRER',
    en: 'SAVE',
    de: 'SPEICHERN',
    it: 'SALVA',
    es: 'GUARDAR',
  );

  String get saveChangesButton => _pick(
    fr: 'ENREGISTRER',
    en: 'SAVE',
    de: 'SPEICHERN',
    it: 'SALVA',
    es: 'GUARDAR',
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

  String get batteryChangedLabel => _pick(
    fr: 'Pile changée le:',
    en: 'Battery changed on:',
    de: 'Batterie gewechselt am:',
    it: 'Batteria cambiata il:',
    es: 'Batería cambiada el:',
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

  String get platformWearTrackingLabel => _pick(
    fr: 'Suivi de l’usure',
    en: 'Wear tracking',
    de: 'Verschleißverfolgung',
    it: 'Monitoraggio dell’usura',
    es: 'Seguimiento del desgaste',
  );

  String get platformWearTrackingSubtitle => _pick(
    fr: 'Programmez vos révisions',
    en: 'Schedule your inspections',
    de: 'Plane deine Überprüfungen',
    it: 'Pianifica le revisioni',
    es: 'Programa tus revisiones',
  );

  String get accessoryWearTrackingSubtitle => _pick(
    fr: 'Calculé selon les coups tirés',
    en: 'Calculated from recorded use',
    de: 'Anhand der erfassten Nutzung berechnet',
    it: "Calcolato in base all'uso registrato",
    es: 'Calculado según el uso registrado',
  );

  String get accessoryCleaningTrackingLabel => _pick(
    fr: "Suivi de salissure de la plateforme",
    en: 'Platform fouling tracking',
    de: 'Verfolgung der Plattformverschmutzung',
    it: "Monitoraggio dello sporco della piattaforma",
    es: 'Seguimiento de la suciedad de la plataforma',
  );

  String get platformCleaningTrackingLabel => _pick(
    fr: 'Suivi de l’encrassement',
    en: 'Fouling tracking',
    de: 'Verschmutzungsverfolgung',
    it: "Monitoraggio dell'incrostazione",
    es: 'Seguimiento del ensuciamiento',
  );

  String get platformCleaningTrackingSubtitle => _pick(
    fr: 'Programmez vos entretiens',
    en: 'Schedule your cleanings',
    de: 'Plane deine Reinigungen',
    it: 'Pianifica le pulizie',
    es: 'Programa tus limpiezas',
  );

  String get platformRoundCounterLabel => _pick(
    fr: 'Suivi du compteur de coups',
    en: 'Usage counter monitoring',
    de: 'Nutzungszähler-Tracking',
    it: 'Monitoraggio contatore usi',
    es: 'Monitoreo del contador de uso',
  );

  String get platformRoundCounterSubtitle => _pick(
    fr: 'Gardez le compte',
    en: 'Keep count',
    de: 'Zählen Sie mit',
    it: 'Tieni il conto',
    es: 'Lleva la cuenta',
  );

  String get initialRoundCounterLabel => _pick(
    fr: 'Historique des coups tirés',
    en: 'Shot history',
    de: 'Schussverlauf',
    it: 'Cronologia dei colpi',
    es: 'Historial de disparos',
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
      case 'PLATEFORME':
        return isEdit
            ? _pick(
                fr: 'ÉDITER PLATEFORME',
                en: 'EDIT PLATFORM',
                de: 'PLATTFORM BEARBEITEN',
                it: 'MODIFICA CONFIGURAZIONE',
                es: 'EDITAR CONFIGURACIÓN',
              )
            : _pick(
                fr: 'NOUVELLE PLATEFORME',
                en: 'NEW PLATFORM',
                de: 'NEUE PLATTFORM',
                it: 'NUOVA CONFIGURAZIONE',
                es: 'NUEVA CONFIGURACIÓN',
              );
      case 'CONSOMMABLE':
        return isEdit
            ? _pick(
                fr: 'ÉDITER CONSOMMABLE',
                en: 'EDIT AMMO',
                de: 'VERBRAUCHSMATERIAL BEARBEITEN',
                it: 'MODIFICA CONSUMABILE',
                es: 'EDITAR CONSUMIBLE',
              )
            : _pick(
                fr: 'NOUVEAU CONSOMMABLE',
                en: 'NEW AMMO',
                de: 'NEUES VERBRAUCHSMATERIAL',
                it: 'NUOVO CONSUMABILE',
                es: 'NUEVO CONSUMIBLE',
              );
      case 'ACCESSOIRE':
        return isEdit
            ? _pick(
                fr: 'ÉDITER ACCESSOIRE',
                en: 'EDIT ACCESSORY',
                de: 'ZUBEHÖR BEARBEITEN',
                it: 'MODIFICA ACCESSORIO',
                es: 'EDITAR ACCESSORIO',
              )
            : _pick(
                fr: 'NOUVEL ACCESSOIRE',
                en: 'NEW ACCESSORY',
                de: 'NEUES ZUBEHÖR',
                it: 'NUOVO ACCESSORIO',
                es: 'NUEVO ACCESSORIO',
              );
      default:
        return isEdit
            ? _pick(
                fr: 'ÉDITER MATÉRIEL',
                en: 'EDIT EQUIPMENT',
                de: 'AUSRÜSTUNG BEARBEITEN',
                it: 'MODIFICA MATERIALE',
                es: 'EDITAR MATERIAL',
              )
            : _pick(
                fr: 'NOUVEAU MATÉRIEL',
                en: 'NEW EQUIPMENT',
                de: 'NEUE AUSRÜSTUNG',
                it: 'NUOVO MATERIALE',
                es: 'NUEVO MATERIAL',
              );
    }
  }

  String itemPrimaryNameLabel(String category) {
    switch (category) {
      case 'PLATEFORME':
        return _pick(
          fr: 'Nom personnalisé',
          en: 'Custom name',
          de: 'Benutzerdefinierter Name',
          it: 'Nome personalizzato',
          es: 'Nombre personalizado',
        );
      case 'CONSOMMABLE':
        return designationRegisterLabel;
      case 'ACCESSOIRE':
        return _pick(
          fr: 'Nom personnalisé',
          en: 'Custom name',
          de: 'Benutzerdefinierter Name',
          it: 'Nome personalizzato',
          es: 'Nombre personnalisé',
        );
      default:
        return _pick(
          fr: 'NOM',
          en: 'NAME',
          de: 'NAME',
          it: 'NOME',
          es: 'NOMBRE',
        );
    }
  }

  String itemPrimaryNameHint(String category) {
    switch (category) {
      case 'PLATEFORME':
        return _pick(
          fr: 'ex: Glock 17 Gen 5',
          en: 'e.g. Glock 17 Gen 5',
          de: 'z. B. Glock 17 Gen 5',
          it: 'es: Glock 17 Gen 5',
          es: 'ej.: Glock 17 Gen 5',
        );
      case 'CONSOMMABLE':
        return _pick(
          fr: 'ex: 9x19 FMJ 124gr (boîte 50)',
          en: 'e.g. 9x19 FMJ 124gr (box of 50)',
          de: 'z. B. 9x19 FMJ 124gr (50er-Pack)',
          it: 'es: 9x19 FMJ 124gr (scatola da 50)',
          es: 'ej.: 9x19 FMJ 124gr (caja de 50)',
        );
      case 'ACCESSOIRE':
        return _pick(
          fr: 'ex: HS507C / Kydex / Peltor SportTac...',
          en: 'e.g. HS507C / Kydex / Peltor SportTac...',
          de: 'z. B. HS507C / Kydex / Peltor SportTac...',
          it: 'es: HS507C / Kydex / Peltor SportTac...',
          es: 'ej.: HS507C / Kydex / Peltor SportTac...',
        );
      default:
        return _pick(
          fr: 'Nom',
          en: 'Name',
          de: 'Name',
          it: 'Nome',
          es: 'Nombre',
        );
    }
  }

  String get itemPlatformBrandHint => _pick(
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
        return _pick(
          fr: 'Facture',
          en: 'Invoice',
          de: 'Rechnung',
          it: 'Fattura',
          es: 'Factura',
        );
      case 'Révision':
        return _pick(
          fr: 'Révision',
          en: 'Service',
          de: 'Inspektion',
          it: 'Revisione',
          es: 'Revisión',
        );
      case 'Entretien':
        return _pick(
          fr: 'Entretien',
          en: 'Maintenance',
          de: 'Wartung',
          it: 'Manutenzione',
          es: 'Mantenimiento',
        );
      case 'Manuel':
        return _pick(
          fr: 'Manuel',
          en: 'Manual',
          de: 'Handbuch',
          it: 'Manuale',
          es: 'Manual',
        );
      case 'Garantie':
        return _pick(
          fr: 'Garantie',
          en: 'Warranty',
          de: 'Garantie',
          it: 'Garanzia',
          es: 'Garantía',
        );
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String itemAccessoryTypeLabel(String value) {
    switch (value) {
      case 'Optiques':
        return _pick(
          fr: 'Optiques',
          en: 'Optics',
          de: 'Optiken',
          it: 'Ottiche',
          es: 'Ópticas',
        );
      case 'Lampes':
        return _pick(
          fr: 'Lampes',
          en: 'Lights',
          de: 'Lampen',
          it: 'Luci',
          es: 'Linternas',
        );
      case 'Lasers':
        return _pick(
          fr: 'Lasers',
          en: 'Lasers',
          de: 'Laser',
          it: 'Laser',
          es: 'Láseres',
        );
      case 'Holsters':
        return _pick(
          fr: 'Holsters',
          en: 'Holsters',
          de: 'Holster',
          it: 'Fondine',
          es: 'Fundas',
        );
      case 'Sangles':
        return _pick(
          fr: 'Sangles',
          en: 'Slings',
          de: 'Trageriemen',
          it: 'Cinghie',
          es: 'Correas',
        );
      case 'Chargeurs':
        return _pick(
          fr: 'Chargeurs',
          en: 'Magazines',
          de: 'Magazine',
          it: 'Caricatori',
          es: 'Cargadores',
        );
      case 'Porte-chargeurs':
        return _pick(
          fr: 'Porte-chargeurs',
          en: 'Mag pouches',
          de: 'Magazintaschen',
          it: 'Portacaricatori',
          es: 'Portacargadores',
        );
      case 'Nettoyage':
        return _pick(
          fr: 'Nettoyage',
          en: 'Cleaning',
          de: 'Reinigung',
          it: 'Pulizia',
          es: 'Limpieza',
        );
      case 'SUPP':
        return _pick(fr: 'RDS', en: 'SUPP', de: 'SD', it: 'SIL', es: 'SIL');
      case 'Compensateurs':
        return _pick(
          fr: 'Compensateurs',
          en: 'Compensators',
          de: 'Kompensatoren',
          it: 'Compensatori',
          es: 'Compensadores',
        );
      case 'Poignées':
        return _pick(
          fr: 'Poignées',
          en: 'Grips',
          de: 'Griffe',
          it: 'Impugnature',
          es: 'Empuñaduras',
        );
      case 'Bipieds':
        return _pick(
          fr: 'Bipieds',
          en: 'Bipods',
          de: 'Zweibeine',
          it: 'Bipiedi',
          es: 'Bípodes',
        );
      case 'Montages':
        return _pick(
          fr: 'Montages',
          en: 'Mounts',
          de: 'Montagen',
          it: 'Attacchi',
          es: 'Montajes',
        );
      case 'Visée mécanique':
        return _pick(
          fr: 'Visée mécanique',
          en: 'Iron sights',
          de: 'Mechanische Visierung',
          it: 'Mire meccaniche',
          es: 'Miras mecánicas',
        );
      case 'Crosses':
        return _pick(
          fr: 'Crosses',
          en: 'Stocks',
          de: 'Schäfte',
          it: 'Calci',
          es: 'Culatas',
        );
      case 'Détentes':
        return _pick(
          fr: 'Détentes',
          en: 'Triggers',
          de: 'Abzüge',
          it: 'Grilletti',
          es: 'Disparadores',
        );
      case 'Pièces internes':
        return _pick(
          fr: 'Pièces internes',
          en: 'Internal parts',
          de: 'Innenteile',
          it: 'Componenti interni',
          es: 'Piezas internas',
        );
      case 'Transport':
        return _pick(
          fr: 'Transport',
          en: 'Transport',
          de: 'Transport',
          it: 'Trasporto',
          es: 'Transporte',
        );
      case 'Sécurité':
        return _pick(
          fr: 'Sécurité',
          en: 'Safety',
          de: 'Sicherheit',
          it: 'Sicurezza',
          es: 'Seguridad',
        );
      case 'Protections':
        return _pick(
          fr: 'Protections',
          en: 'Protection gear',
          de: 'Schutzausrüstung',
          it: 'Protezioni',
          es: 'Protecciones',
        );
      case 'Chronographes':
        return _pick(
          fr: 'Chronographes',
          en: 'Chronographs',
          de: 'Chronographen',
          it: 'Cronografi',
          es: 'Cronógrafos',
        );
      case 'Timers':
        return _pick(
          fr: 'Timers',
          en: 'Timers',
          de: 'Timer',
          it: 'Timer',
          es: 'Temporizadores',
        );
      case 'Cibles':
        return _pick(
          fr: 'Cibles',
          en: 'Targets',
          de: 'Ziele',
          it: 'Bersagli',
          es: 'Blancos',
        );
      case 'Supports de tir':
        return _pick(
          fr: "Supports d'appui",
          en: 'Support rests',
          de: 'Auflagen',
          it: "Supporti d'appoggio",
          es: 'Apoyos de soporte',
        );
      case 'Outils':
        return _pick(
          fr: 'Outils',
          en: 'Tools',
          de: 'Werkzeuge',
          it: 'Strumenti',
          es: 'Herramientas',
        );
      case 'Divers':
        return _pick(
          fr: 'Divers',
          en: 'Miscellaneous',
          de: 'Verschiedenes',
          it: 'Vari',
          es: 'Varios',
        );
      default:
        return value;
    }
  }

  String itemPlatformTypeLabel(String value) {
    switch (value) {
      case 'PA':
        return _pick(
          fr: 'PA',
          en: 'Pistol',
          de: 'Pistole',
          it: 'Pistola',
          es: 'Pistola',
        );
      case 'Révolver':
        return _pick(
          fr: 'Révolver',
          en: 'Revolver',
          de: 'Revolver',
          it: 'Revolver',
          es: 'Revólver',
        );
      case 'PM':
        return _pick(fr: 'PM', en: 'SMG', de: 'MP', it: 'PM', es: 'Subfusil');
      case 'FA':
        return _pick(fr: 'FA', en: 'AR', de: 'StGw', it: 'FA', es: 'FA');
      case 'FM':
        return _pick(fr: 'FM', en: 'LMG', de: 'MG', it: 'FM', es: 'FA auto');
      case 'Carabine':
        return _pick(
          fr: 'Carabine',
          en: 'Carbine',
          de: 'Karabiner',
          it: 'Carabina',
          es: 'Carabina',
        );
      case 'FAP':
        return _pick(
          fr: 'FAP',
          en: 'Pump-action',
          de: 'Pump',
          it: 'Pompa',
          es: 'Corredera',
        );
      case 'Fusil de chasse':
        return _pick(
          fr: 'Fusil de chasse',
          en: 'Shotgun',
          de: 'Flinte',
          it: 'Fucile caccia',
          es: 'Escopeta',
        );
      case 'FP':
        return _pick(fr: 'FP', en: 'PR', de: 'PzGw', it: 'FP', es: 'FP');
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
        return _pick(
          fr: 'Pointe creuse (JHP)',
          en: 'Hollow point (JHP)',
          de: 'Hohlspitze (JHP)',
          it: 'Punta cava (JHP)',
          es: 'Punta hueca (JHP)',
        );
      case 'Gold Dot':
        return 'Gold Dot';
      case 'Soft Point':
        return 'Soft Point';
      case 'Plomb':
        return _pick(
          fr: 'Plomb',
          en: 'Lead',
          de: 'Blei',
          it: 'Piombo',
          es: 'Plomo',
        );
      case 'Subsonique':
        return _pick(
          fr: 'Subsonique',
          en: 'Subsonic',
          de: 'Unterschall',
          it: 'Subsonico',
          es: 'Subsónico',
        );
      case 'Traçante':
        return _pick(
          fr: 'Traçante',
          en: 'Tracer',
          de: 'Leuchtspur',
          it: 'Tracciante',
          es: 'Trazadora',
        );
      case 'Autre':
        return customOtherLabel;
      default:
        return value;
    }
  }

  String get iDoNotKnow => _pick(
    fr: 'Je ne sais pas',
    en: 'I do not know',
    de: 'Ich weiß nicht',
    it: 'Non lo so',
    es: 'No lo sé',
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
    fr: "SUIVI D'UTILISATION",
    en: 'USAGE HISTORY',
    de: 'NUTZUNGSVERLAUF',
    it: "STORICO DI UTILIZZO",
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

  String get monthLabel =>
      _pick(fr: 'Mois', en: 'Month', de: 'Monat', it: 'Mese', es: 'Mes');

  String get yearLabel =>
      _pick(fr: 'Année', en: 'Year', de: 'Jahr', it: 'Anno', es: 'Año');

  String get modelLabel => _pick(
    fr: 'Modèle',
    en: 'Model',
    de: 'Modell',
    it: 'Modello',
    es: 'Modelo',
  );

  String get accessoryStatusTitle => _pick(
    fr: "ÉTAT DE L'ACCESSOIRE",
    en: 'ACCESSORY STATUS',
    de: 'ZUBEHÖRSTATUS',
    it: "STATO DELL'ACCESSORIO",
    es: 'ESTADO DEL ACCESORIO',
  );

  String get fullHistoryTitle => _pick(
    fr: 'HISTORIQUE',
    en: 'HISTORY',
    de: 'VERLAUF',
    it: 'STORICO',
    es: 'HISTORIAL',
  );

  String get noMaintenanceHistoryRecorded => _pick(
    fr: "Aucun historique d'entretien/révision enregistré",
    en: 'No maintenance/revision history recorded',
    de: 'Kein Wartungs-/Revisionsverlauf erfasst',
    it: 'Nessuno storico manutenzione/revisione registrato',
    es: 'No hay historial de mantenimiento/revisión registrado',
  );

  String get noRestockHistoryYet => _pick(
    fr: 'Aucun réapprovisionnement enregistré',
    en: 'No restock recorded yet',
    de: 'Noch keine Nachbestellung erfasst',
    it: 'Nessun rifornimento registrato',
    es: 'No hay reposición registrada aún',
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

  String get platformConfirmRevisionMessage => _pick(
    fr: 'Voulez-vous vraiment enregistrer une révision complète pour cette plateforme ? Le compteur de révision sera remis à zéro.',
    en: 'Do you really want to record a complete revision for this platform? The revision counter will be reset to zero.',
    de: 'Möchten Sie wirklich eine vollständige Revision für diese Plattform erfassen? Der Revisionszähler wird auf Null zurückgesetzt.',
    it: 'Vuoi davvero registrare una revisione completa per questa piattaforma? Il contatore di revisione verrà azzerato.',
    es: '¿Realmente quieres registrar una revisión completa para esta plataforma? El contador de revisión se reiniciará a cero.',
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

  String get dateLabel =>
      _pick(fr: 'Date', en: 'Date', de: 'Datum', it: 'Data', es: 'Fecha');

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

  String get replacedPartsLabel => _pick(
    fr: 'Pièces remplacées',
    en: 'Replaced parts',
    de: 'Ersetzte Teile',
    it: 'Pezzi sostituiti',
    es: 'Piezas reemplazadas',
  );

  String get partChangedOnLabel => _pick(
    fr: 'Remplacée le',
    en: 'Replaced on',
    de: 'Ersetzt am',
    it: 'Sostituito il',
    es: 'Reemplazada el',
  );

  String get partRoundsSinceChangeLabel => _pick(
    fr: 'Depuis remplacement',
    en: 'Since replacement',
    de: 'Seit Austausch',
    it: 'Da sostituzione',
    es: 'Desde reemplazo',
  );

  String get partStartingRoundsLabel => _pick(
    fr: 'Compteur initial de la pièce',
    en: 'Part initial counter',
    de: 'Startzähler des Teils',
    it: 'Contatore iniziale del pezzo',
    es: 'Contador inicial de la pieza',
  );

  String get partStartingRoundsInvalid => _pick(
    fr: 'Le compteur initial de la pièce doit être renseigné.',
    en: 'The part initial counter is required.',
    de: 'Der Startzähler des Teils muss angegeben werden.',
    it: 'Il contatore iniziale del pezzo è obbligatorio.',
    es: 'El contador inicial de la pieza es obligatorio.',
  );

  String get editPartReplacement => _pick(
    fr: 'Modifier la pièce',
    en: 'Edit part',
    de: 'Teil bearbeiten',
    it: 'Modifica pezzo',
    es: 'Modificar pieza',
  );

  String get deletePartReplacement => _pick(
    fr: 'Supprimer la pièce',
    en: 'Delete part',
    de: 'Teil löschen',
    it: 'Elimina pezzo',
    es: 'Eliminar pieza',
  );

  String get confirmDeletePartReplacement => _pick(
    fr: 'Supprimer cette pièce remplacée ?',
    en: 'Delete this replaced part?',
    de: 'Dieses ersetzte Teil löschen?',
    it: 'Eliminare questo pezzo sostituito?',
    es: '¿Eliminar esta pieza reemplazada?',
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

  String get shotsLower =>
      _pick(fr: 'coups', en: 'shots', de: 'Schüsse', it: 'colpi', es: 'tiros');

  String get confirmation => _pick(
    fr: 'Confirmation',
    en: 'Confirmation',
    de: 'Bestätigung',
    it: 'Conferma',
    es: 'Confirmación',
  );

  String get confirmPlatformCleaningMessage => _pick(
    fr: "Voulez-vous vraiment enregistrer un nettoyage complet pour cette plateforme ? Le compteur d'entretien sera remis à zéro.",
    en: 'Do you really want to record a complete cleaning for this platform? The maintenance counter will be reset to zero.',
    de: 'Möchten Sie wirklich eine vollständige Reinigung für diese Plattform aufzeichnen? Der Wartungszähler wird auf Null zurückgesetzt.',
    it: 'Vuoi davvero registrare una pulizia completa per questa piattaforma? Il contatore di manutenzione verrà azzerato.',
    es: '¿Realmente quieres registrar una limpieza completa para esta plataforma? El contador de mantenimiento se reiniciará a cero.',
  );

  String get cleaningRecordedSuccess => _pick(
    fr: 'Entretien enregistré avec succès.',
    en: 'Maintenance recorded successfully.',
    de: 'Wartung erfolgreich erfasst.',
    it: 'Manutenzione registrata con successo.',
    es: 'Mantenimiento registrado con éxito.',
  );

  String get clean => _pick(
    fr: 'Nettoyer',
    en: 'Clean',
    de: 'Reinigen',
    it: 'Pulisci',
    es: 'Limpiar',
  );

  String get hitFactorIntro => _pick(
    fr: 'Le Hit Factor mesure votre performance en divisant vos points par le temps.\nUn score plus élevé indique une meilleure performance.',
    en: 'Hit Factor measures your performance by dividing your points by time.\nA higher score indicates better performance.',
    de: 'Hit Factor misst Ihre Leistung, indem es Ihre Punkte durch die Zeit teilt.\nEine höhere Punktzahl deutet auf eine bessere Leistung hin.',
    it: 'Hit Factor misura la tua prestazione dividendo i punti per il tempo.\nUn punteggio più alto indica una prestazione migliore.',
    es: 'Hit Factor mide su rendimiento dividiendo sus puntos por el tiempo.\nUna puntuación más alta indica un mejor rendimiento.',
  );

  String get powerFactorIntro => _pick(
    fr: 'Le Power Factor détermine la classification de votre munition (Major/Minor) selon sa puissance.\nLes seuils varient selon les règles de compétition.',
    en: 'Power Factor determines the classification of your ammunition (Major/Minor) based on its power.\nThresholds vary by competition rules.',
    de: 'Power Factor bestimmt die Klassifizierung Ihrer Munition (Major/Minor) basierend auf ihrer Leistung.\nDie Schwellenwerte variieren je nach Wettkampfregeln.',
    it: 'Power Factor determina la classificazione del tuo munizionamento (Major/Minor) in base alla sua potenza.\nLe soglie variano in base alle regole di competizione.',
    es: 'Power Factor determina la clasificación de su munición (Major/Minor) según su potencia.\nLos umbrales varían según las reglas de competición.',
  );

  String get dopeMarkAsDope => _pick(
    fr: 'Marquer comme DOPE',
    en: 'Mark as DOPE',
    de: 'Als DOPE markieren',
    it: 'Segna come DOPE',
    es: 'Marcar como DOPE',
  );

  String get dopeExplanation => _pick(
    fr: 'Activer si la mesure est prise sur le terrain et non théorique',
    en: 'Enable if measured in the field, not theoretical',
    de: 'Aktivieren, wenn im Feld gemessen, nicht theoretisch',
    it: 'Attiva se misurato sul campo, non teorico',
    es: 'Activar si se mide en el campo, no teórico',
  );

  String get dopeBadge =>
      _pick(fr: 'DOPE', en: 'DOPE', de: 'DOPE', it: 'DOPE', es: 'DOPE');

  String get dopeFilterAll =>
      _pick(fr: 'Toutes', en: 'All', de: 'Alle', it: 'Tutte', es: 'Todas');

  String get dopeFilterDopeOnly => _pick(
    fr: 'DOPE seulement',
    en: 'DOPE only',
    de: 'Nur DOPE',
    it: 'Solo DOPE',
    es: 'Solo DOPE',
  );

  String get dopePocketCardMode => _pick(
    fr: 'Mode carte',
    en: 'Card mode',
    de: 'Kartenmodus',
    it: 'Modalità carta',
    es: 'Modo tarjeta',
  );

  String get dopeExportPdfCard => _pick(
    fr: 'Exporter en carte de poche',
    en: 'Export as pocket card',
    de: 'Als Taschenkarte exportieren',
    it: 'Esporta come carta tascabile',
    es: 'Exportar como tarjeta de bolsillo',
  );

  String get noAccessoryLinked => _pick(
    fr: 'Aucun accessoire lié.',
    en: 'No accessory linked.',
    de: 'Kein Zubehör verknüpft.',
    it: 'Nessun accessorio collegato.',
    es: 'Sin accesorio vinculado.',
  );

  String get noPlatformLinked => _pick(
    fr: 'Aucune plateforme liée.',
    en: 'No platform linked.',
    de: 'Keine Plattform verknüpft.',
    it: 'Nessuna piattaforma collegata.',
    es: 'Sin plataforma vinculada.',
  );

  String get maintenanceRecordedSuccess => _pick(
    fr: 'Entretien enregistré avec succès.',
    en: 'Maintenance recorded successfully.',
    de: 'Wartung erfolgreich erfasst.',
    it: 'Manutenzione registrata con successo.',
    es: 'Mantenimiento registrado con éxito.',
  );

  String get reviseLabel => _pick(
    fr: 'Réviser',
    en: 'Revise',
    de: 'Revidieren',
    it: 'Revisionare',
    es: 'Revisar',
  );

  String get cannotOpenDocument => _pick(
    fr: 'Impossible d\'ouvrir le document',
    en: 'Cannot open document',
    de: 'Dokument kann nicht geöffnet werden',
    it: 'Impossibile aprire il documento',
    es: 'No se puede abrir el documento',
  );

  String get platformsUsedLabel => _pick(
    fr: 'Plateformes utilisées',
    en: 'Platforms used',
    de: 'Verwendete Plattformen',
    it: 'Piattaforme utilizzate',
    es: 'Plataformas utilizadas',
  );

  String get consumablesUsedLabel => _pick(
    fr: 'Consommables utilisés',
    en: 'Consumables used',
    de: 'Verbrauchsmaterial verwendet',
    it: 'Consumabili utilizzati',
    es: 'Consumibles utilizados',
  );

  String get unlinkAccessoryForSessionMessage => _pick(
    fr: 'Retirer cet accessoire lié pour cette session uniquement ?',
    en: 'Remove this linked accessory for this session only?',
    de: 'Dieses verknüpfte Zubehör nur für diese Sitzung entfernen?',
    it: 'Rimuovere questo accessorio collegato solo per questa sessione?',
    es: '¿Eliminar este accesorio vinculado solo para esta sesión?',
  );

  String diagnosticOf(String platformName) => _pick(
    fr: 'Diagnostic de $platformName',
    en: 'Diagnostic of $platformName',
    de: 'Diagnose von $platformName',
    it: 'Diagnostico di $platformName',
    es: 'Diagnóstico de $platformName',
  );

  String get presumedProblemLabel => _pick(
    fr: 'Problème supposé :',
    en: 'Presumed problem:',
    de: 'Vermutetes Problem:',
    it: 'Problema presunto:',
    es: 'Problema presunto:',
  );

  String get riskLabel => _pick(
    fr: 'Risque :',
    en: 'Risk:',
    de: 'Risiko:',
    it: 'Rischio:',
    es: 'Riesgo:',
  );

  String get platformNotSpecified => _pick(
    fr: 'plateforme non spécifiée',
    en: 'platform not specified',
    de: 'Plattform nicht angegeben',
    it: 'piattaforma non specificata',
    es: 'plataforma no especificada',
  );

  String get simpleFilterLabel => _pick(
    fr: 'Simples',
    en: 'Simple',
    de: 'Einfach',
    it: 'Semplice',
    es: 'Simple',
  );

  String get detailedFilterLabel => _pick(
    fr: 'Détaillés',
    en: 'Detailed',
    de: 'Detailliert',
    it: 'Dettagliato',
    es: 'Detallado',
  );

  String get allFilterLabel =>
      _pick(fr: 'Tous', en: 'All', de: 'Alle', it: 'Tutti', es: 'Todos');

  String stepsCount(int steps) => _pick(
    fr: '$steps étapes',
    en: '$steps steps',
    de: '$steps Schritte',
    it: '$steps passi',
    es: '$steps pasos',
  );

  String get newTableLabel => _pick(
    fr: 'NOUVELLE TABLE',
    en: 'NEW TABLE',
    de: 'NEUE TABELLE',
    it: 'NUOVA TABELLA',
    es: 'NUEVA TABLA',
  );

  String get noPlatform => _pick(
    fr: 'Aucune plateforme',
    en: 'No platform',
    de: 'Keine Plattform',
    it: 'Nessuna piattaforma',
    es: 'Sin plataforma',
  );

  String get borrowedPlatform => _pick(
    fr: 'Plateforme prêtée',
    en: 'Borrowed platform',
    de: 'Geliehene Plattform',
    it: 'Piattaforma prestata',
    es: 'Plataforma prestada',
  );

  String get noConsumable => _pick(
    fr: 'Aucun consommable',
    en: 'No consumable',
    de: 'Kein Verbrauchsmaterial',
    it: 'Nessun consumabile',
    es: 'Sin consumible',
  );

  String get borrowedConsumable => _pick(
    fr: 'Consommable prêté',
    en: 'Borrowed consumable',
    de: 'Geliehenes Verbrauchsmaterial',
    it: 'Consumabile prestato',
    es: 'Consumible prestado',
  );

  String get unknownConsumable => _pick(
    fr: 'Consommable inconnu',
    en: 'Unknown consumable',
    de: 'Unbekanntes Verbrauchsmaterial',
    it: 'Consumabile sconosciuto',
    es: 'Consumible desconocido',
  );

  String get confirm => _pick(
    fr: 'CONFIRMER',
    en: 'CONFIRM',
    de: 'BESTÄTIGEN',
    it: 'CONFERMA',
    es: 'CONFIRMAR',
  );

  String get updateAvailableTitle => _pick(
    fr: 'Mise à jour disponible',
    en: 'Update available',
    de: 'Update verfügbar',
    it: 'Aggiornamento disponibile',
    es: 'Actualización disponible',
  );
  String updateAvailableBody(String latestVersion) => _pick(
    fr: 'Une nouvelle version ($latestVersion) est disponible.',
    en: 'A new version ($latestVersion) is available.',
    de: 'Eine neue Version ($latestVersion) ist verfügbar.',
    it: 'È disponibile una nuova versione ($latestVersion).',
    es: 'Hay una nueva versión disponible ($latestVersion).',
  );
  String get updateAvailableOpenStore => _pick(
    fr: 'Ouvrir le store',
    en: 'Open store',
    de: 'Store öffnen',
    it: 'Apri store',
    es: 'Abrir tienda',
  );
  String get remindLater => _pick(
    fr: 'Plus tard',
    en: 'Later',
    de: 'Später',
    it: 'Più tardi',
    es: 'Más tarde',
  );
}
