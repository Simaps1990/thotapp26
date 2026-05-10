import 'package:flutter/widgets.dart';

class AppStringsDiagnostic {
  const AppStringsDiagnostic._();

  static String? _overrideLanguageCode;

  static void setLanguageCode(String code) {
    _overrideLanguageCode = code;
  }

  static String _resolvedLanguageCode() {
    return _overrideLanguageCode ??
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  }

  static String _pick({
    required String fr,
    required String en,
    required String de,
    required String it,
    required String es,
  }) {
    final code = _resolvedLanguageCode();
    if (code == 'en') return en;
    if (code == 'de') return de;
    if (code == 'it') return it;
    if (code == 'es') return es;
    return fr;
  }

  static String get diagnosticToolTitle => _pick(
fr: "DIAGNOSTIC D’INCIDENT",
en: 'INCIDENT DIAGNOSIS',
de: 'STÖRUNGSDIAGNOSE',
it: 'DIAGNOSI DELL’INCIDENTE',
es: 'DIAGNÓSTICO DE INCIDENTE',
      );

  static String get diagnosticToolSubtitle => _pick(
        fr: "Analyse guidée pour identifier un incident, estimer l’origine probable et adopter la bonne conduite.",
        en: 'Guided analysis to identify an incident, estimate the likely origin, and adopt the right course of action.',
        de: 'Geführte Analyse zur Identifikation eines Vorfalls, zur Einschätzung der wahrscheinlichen Ursache und zur Wahl des richtigen Vorgehens.',
        it: 'Analisi guidata per identificare un incidente, stimarne l’origine probabile e adottare la condotta corretta.',
        es: 'Análisis guiado para identificar un incidente, estimar el origen probable y adoptar la conducta adecuada.',
      );

  static String get diagnosticDisclaimerTitle => _pick(
        fr: 'Avertissement avant identification',
        en: 'Warning before assessment',
        de: 'Warnhinweis vor der Beurteilung',
        it: 'Avvertenza prima della valutazione',
        es: 'Aviso antes de la evaluación',
      );

  static String get diagnosticDisclaimerBody => _pick(
        fr: "Cet outil aide à identifier un incident, à estimer l’origine probable et à orienter la suite à donner. Il ne remplace ni une vérification physique ni le contrôle d’un professionnel qualifié. En cas de doute, d’incident répété ou de comportement anormal, interrompez l’utilisation et faites contrôler la plateforme.",
        en: 'This tool helps identify an incident, estimate the likely origin, and guide next steps. It does not replace a physical check or an inspection by a qualified professional. In case of doubt, repeated incidents, or abnormal behavior, stop use and have the platform inspected.',
        de: 'Dieses Werkzeug hilft bei der Identifikation eines Vorfalls, der Einschätzung der wahrscheinlichen Ursache und der Orientierung für die nächsten Schritte. Es ersetzt weder eine physische Prüfung noch die Kontrolle durch eine qualifizierte Fachkraft. Bei Unsicherheit, wiederholten Vorfällen oder auffälligem Verhalten Nutzung stoppen und die Plattform prüfen lassen.',
        it: 'Questo strumento aiuta a identificare un incidente, stimarne l’origine probabile e orientare i passaggi successivi. Non sostituisce una verifica fisica né il controllo da parte di un professionista qualificato. In caso di dubbio, incidenti ripetuti o comportamento anomalo, interrompere l’uso e far controllare la piattaforma.',
        es: 'Esta herramienta ayuda a identificar un incidente, estimar el origen probable y orientar los pasos siguientes. No sustituye una verificación física ni la revisión de un profesional cualificado. En caso de duda, incidentes repetidos o comportamiento anómalo, interrumpa el uso y haga revisar la plataforma.',
      );

  static String get diagnosticDisclaimerConfirm => _pick(
        fr: 'Je comprends',
        en: 'I understand',
        de: 'Ich verstehe',
        it: 'Ho capito',
        es: 'Entiendo',
      );

  static String get diagnosticNew => _pick(
        fr: 'NOUVEAU DIAGNOSTIC',
        en: 'NEW DIAGNOSTIC',
        de: 'NEUE DIAGNOSE',
        it: 'NUOVA DIAGNOSI',
        es: 'NUEVA EVALUACIÓN',
      );

  static String get diagnosticEmptyTitle => _pick(
        fr: 'Aucun diagnostic enregistré',
        en: 'No diagnosis recorded',
        de: 'Keine Diagnose gespeichert',
        it: 'Nessuna diagnosi registrata',
        es: 'No hay diagnósticos registrados',
      );

  static String get diagnosticEmptySubtitle => _pick(
        fr: 'Commencez une nouvelle identification pour\nanalyser une situation',
        en: 'Start a new assessment to\nanalyze a situation',
        de: 'Starten Sie eine neue Beurteilung, um\neine Situation zu analysieren',
        it: 'Avvia una nuova valutazione per\nanalizzare una situazione',
        es: 'Inicie una nueva evaluación para\nanalizar una situación',
      );

  static String get diagnosticDeleteTitle => _pick(
        fr: 'Supprimer le diagnostic',
        en: 'Delete diagnosis',
        de: 'Diagnose löschen',
        it: 'Elimina diagnosi',
        es: 'Eliminar diagnóstico',
      );

  static String get diagnosticDeleteMessage => _pick(
        fr: 'Êtes-vous sûr de vouloir supprimer ce diagnostic ?',
        en: 'Are you sure you want to delete this diagnostic?',
        de: 'Möchten Sie diese Diagnose wirklich löschen?',
        it: 'Sei sicuro di voler eliminare questa diagnosi?',
        es: '¿Seguro que desea eliminar este diagnóstico?',
      );

  static String get diagnosticHistoryTitle => _pick(
        fr: 'PROBLÈME SUPPOSÉ',
        en: 'SUSPECTED ISSUE',
        de: 'VERMUTETES PROBLEM',
        it: 'PROBLEMA SOSPETTO',
        es: 'PROBLEMA SOSPECHADO',
      );

  static String diagnosticOfPlatform(String name) => _pick(
        fr: 'Diagnostic de $name',
        en: 'Diagnosis for $name',
        de: 'Diagnose für $name',
        it: 'Diagnosi per $name',
        es: 'Diagnóstico de $name',
      );

  static String get diagnosticOfUnknownPlatform => _pick(
        fr: 'Diagnostic sans plateforme spécifique',
        en: 'Diagnostic without specific platform',
        de: 'Diagnose ohne spezifische Plattform',
        it: 'Diagnosi senza piattaforma specifica',
        es: 'Diagnóstico sin plataforma específica',
      );

  static String get diagnosticNoSpecificPlatform => _pick(
        fr: 'Diagnostic sans plateforme spécifique',
        en: 'Diagnostic without specific platform',
        de: 'Diagnose ohne spezifische Plattform',
        it: 'Diagnosi senza piattaforma specifica',
        es: 'Diagnóstico sin plataforma específica',
      );

  static String get diagnosticOrSelectPlatform => _pick(
        fr: 'OU SÉLECTIONNEZ UNE PLATEFORME',
        en: 'OR SELECT A PLATFORM',
        de: 'ODER EINE PLATTFORM AUSWÄHLEN',
        it: 'OPPURE SELEZIONA UNA PIATTAFORMA',
        es: 'O SELECCIONE UNA PLATAFORMA',
      );

  static String get diagnosticNoSpecificPlatformSubtitle => _pick(
        fr: 'Arbre complet - identification de la situation',
        en: 'Full flow - situation identification',
        de: 'Vollständiger Ablauf - Situationsidentifikation',
        it: 'Flusso completo - identificazione della situazione',
        es: 'Flujo completo - identificación de la situación',
      );

  static String get diagnosticPlatformSelectionTitle => _pick(
        fr: 'SÉLECTION DE LA PLATEFORME',
        en: 'PLATFORM SELECTION',
        de: 'PLATTFORMAUSWAHL',
        it: 'SELEZIONE PIATTAFORMA',
        es: 'SELECCIÓN DE PLATAFORMA',
      );

  static String get diagnosticImmediateStopMessage => _pick(
        fr: 'ARRÊT IMMÉDIAT\n\nProcédure de sécurisation immédiate requise.\n\nPlacez la plateforme dans une direction sûre et interrompez toute manipulation.',
        en: 'IMMEDIATE STOP\n\nImmediate safety procedure required.\n\nPlace the platform in a safe direction and stop all handling.',
        de: 'SOFORT STOPP\n\nSofortige Sicherheitsmaßnahmen erforderlich.\n\nPlattform in eine sichere Richtung bringen und jede Handhabung stoppen.',
        it: 'STOP IMMEDIATO\n\nÈ richiesta una procedura di sicurezza immediata.\n\nPosiziona la piattaforma in una direzione sicura e interrompi ogni manipolazione.',
        es: 'DETENCIÓN INMEDIATA\n\nSe requiere un procedimiento de seguridad inmediato.\n\nColoque la plataforma en una dirección segura e interrumpa toda manipulación.',
      );

  static String get diagnosticUnknownStateMessage => _pick(
        fr: 'ÉTAT INCONNU\n\nProcédure de sécurisation immédiate requise.\n\nPlacez la plateforme dans une direction sûre et interrompez toute manipulation.',
        en: 'UNKNOWN STATE\n\nImmediate safety procedure required.\n\nPlace the platform in a safe direction and stop all handling.',
        de: 'UNBEKANNTER ZUSTAND\n\nSofortige Sicherheitsmaßnahmen erforderlich.\n\nPlattform in eine sichere Richtung bringen und jede Handhabung stoppen.',
        it: 'STATO SCONOSCIUTO\n\nÈ richiesta una procedura di sicurezza immediata.\n\nPosiziona la piattaforma in una direzione sicura e interrompi ogni manipolazione.',
        es: 'ESTADO DESCONOCIDO\n\nSe requiere un procedimiento de seguridad inmediato.\n\nColoque la plataforma en una dirección segura e interrumpa toda manipulación.',
      );

  static String get diagnosticProbabilitiesTitle => _pick(
        fr: 'PROBABILITÉS',
        en: 'PROBABILITIES',
        de: 'WAHRSCHEINLICHKEITEN',
        it: 'PROBABILITÀ',
        es: 'PROBABILIDADES',
      );

  static String get diagnosticRiskLevelTitle => _pick(
        fr: 'NIVEAU DE RISQUE',
        en: 'RISK LEVEL',
        de: 'RISIKOSTUFE',
        it: 'LIVELLO DI RISCHIO',
        es: 'NIVEL DE RIESGO',
      );

  static String get diagnosticSuspectedIssueTitle => _pick(
        fr: 'PROBLÈME SUPPOSÉ',
        en: 'SUSPECTED ISSUE',
        de: 'VERMUTETES PROBLEM',
        it: 'PROBLEMA SOSPETTO',
        es: 'PROBLEMA SOSPECHADO',
      );

  static String get diagnosticImmediateActionsTitle => _pick(
        fr: 'ACTIONS RECOMMANDÉES',
        en: 'RECOMMENDED ACTIONS',
        de: 'EMPFOHLENE MASSNAHMEN',
        it: 'AZIONI CONSIGLIATE',
        es: 'ACCIONES RECOMENDADAS',
      );

  static String get diagnosticAvoidTitle => _pick(
        fr: 'À ÉVITER',
        en: 'AVOID',
        de: 'ZU VERMEIDEN',
        it: 'DA EVITARE',
        es: 'EVITAR',
      );

  static String get diagnosticIdentifiedIncidentTitle => _pick(
        fr: 'INCIDENT IDENTIFIÉ',
        en: 'IDENTIFIED INCIDENT',
        de: 'IDENTIFIZIERTER VORFALL',
        it: 'INCIDENTE IDENTIFICATO',
        es: 'INCIDENTE IDENTIFICADO',
      );

  static String get issueComponentDamageHint => _pick(
        fr: 'Une usure ou une anomalie mécanique est possible. Un contrôle est recommandé.',
        en: 'Wear or a mechanical anomaly is possible. Inspection is recommended.',
        de: 'Verschleiß oder eine mechanische Auffälligkeit ist möglich. Eine Kontrolle wird empfohlen.',
        it: 'È possibile usura o anomalia meccanica. Si raccomanda un controllo.',
        es: 'Es posible desgaste o una anomalía mecánica. Se recomienda una revisión.',
      );

  static String get incidentNoFireLabel => _pick(
        fr: 'Non-départ',
        en: 'Failure to fire',
        de: 'Keine Schussauslösung',
        it: 'Mancato sparo',
        es: 'Fallo de disparo',
      );

  static String get incidentDelayedFireLabel => _pick(
        fr: 'Départ retardé',
        en: 'Delayed discharge',
        de: 'Verzögerte Schussauslösung',
        it: 'Sparo ritardato',
        es: 'Disparo con retardo',
      );

  static String get incidentCycleLabel => _pick(
        fr: 'Incident d’alimentation ou de cycle',
        en: 'Feeding or cycling issue',
        de: 'Zuführungs- oder Zyklusproblem',
        it: 'Problema di alimentazione o di ciclo',
        es: 'Incidente de alimentación o de ciclo',
      );

  static String get incidentAccuracyLabel => _pick(
        fr: 'Dégradation de précision',
        en: 'Accuracy degradation',
        de: 'Präzisionsabfall',
        it: 'Peggioramento della precisione',
        es: 'Pérdida de precisión',
      );

  static String get incidentAbnormalDepartureLabel => _pick(
        fr: 'Départ involontaire ou anormal',
        en: 'Involuntary or abnormal discharge',
        de: 'Unbeabsichtigte oder auffällige Schussauslösung',
        it: 'Sparo involontario o anomalo',
        es: 'Disparo involuntario o anómalo',
      );

  static String incidentLabel(String key) {
    switch (key) {
      case 'incident_no_fire':
        return incidentNoFireLabel;
      case 'incident_delayed_fire':
        return incidentDelayedFireLabel;
      case 'incident_cycle':
        return incidentCycleLabel;
      case 'incident_accuracy':
        return incidentAccuracyLabel;
      case 'incident_abnormal_departure':
        return incidentAbnormalDepartureLabel;
      default:
        return _pick(
          fr: 'Incident non spécifié',
          en: 'Unspecified incident',
          de: 'Nicht spezifizierter Vorfall',
          it: 'Incidente non specificato',
          es: 'Incidente no especificado',
        );
    }
  }

  static String issueLabel(String key) {
    switch (key) {
      case 'ammo_defective':
        return _pick(
          fr: 'Consommable potentiellement défectueux',
          en: 'Potentially defective ammunition',
          de: 'Möglicherweise fehlerhafte Munition',
          it: 'Munizione potenzialmente difettosa',
          es: 'Munición potencialmente defectuosa',
        );
      case 'fouling_dirty':
        return _pick(
          fr: 'Encrassement ou entretien insuffisant',
          en: 'Fouling or insufficient maintenance',
          de: 'Verschmutzung oder unzureichende Wartung',
          it: 'Sporco o manutenzione insufficiente',
          es: 'Suciedad o mantenimiento insuficiente',
        );
      case 'configuration_issue':
        return _pick(
          fr: 'Équipement ou plateforme à vérifier',
          en: 'Equipment or platform to check',
          de: 'Ausrüstung oder Plattform prüfen',
          it: 'Attrezzatura o piattaforma da verificare',
          es: 'Equipo o plataforma a verificar',
        );
      case 'component_damage':
        return _pick(
          fr: 'Composant interne possiblement endommagé',
          en: 'Internal component possibly damaged',
          de: 'Internes Bauteil möglicherweise beschädigt',
          it: 'Componente interno possibilmente danneggiato',
          es: 'Componente interno posiblemente dañado',
        );
      case 'optic_or_mount':
        return _pick(
          fr: 'Optique ou montage à vérifier',
          en: 'Optic or mount to check',
          de: 'Optik oder Montage prüfen',
          it: 'Ottica o montaggio da verificare',
          es: 'Óptica o montaje a verificar',
        );
      case 'human_factor':
        return _pick(
          fr: 'Facteur d’usage / appui',
          en: 'Handling or support factor',
          de: 'Handhabungs- oder Auflagefaktor',
          it: 'Fattore d’uso / appoggio',
          es: 'Factor de manejo o apoyo',
        );
      case 'multiple_possible':
      default:
        return _pick(
          fr: 'Plusieurs causes possibles',
          en: 'Multiple possible causes',
          de: 'Mehrere mögliche Ursachen',
          it: 'Possibili cause multiple',
          es: 'Varias causas posibles',
        );
    }
  }

  static String riskLabel(String key) {
    switch (key) {
      case 'low':
        return _pick(
          fr: 'Faible',
          en: 'Low',
          de: 'Niedrig',
          it: 'Basso',
          es: 'Bajo',
        );
      case 'high':
        return _pick(
          fr: 'Élevé',
          en: 'High',
          de: 'Hoch',
          it: 'Alto',
          es: 'Alto',
        );
      case 'medium':
      default:
        return _pick(
          fr: 'À surveiller',
          en: 'Monitor closely',
          de: 'Genau beobachten',
          it: 'Da monitorare',
          es: 'Vigilar de cerca',
        );
    }
  }

  static String diagnosticRecommendedActions(String riskKey) {
    switch (riskKey) {
      case 'high':
        return _pick(
          fr: 'Interrompez immédiatement l’utilisation. Immobilisez la plateforme. Ne forcez aucune manipulation. Faites contrôler par un professionnel qualifié avant toute réutilisation.',
          en: 'Stop use immediately. Keep the platform out of service. Do not force any manipulation. Have it inspected by a qualified professional before any reuse.',
          de: 'Nutzung sofort stoppen. Plattform außer Betrieb lassen. Keine Handhabung erzwingen. Vor jeder weiteren Nutzung durch eine qualifizierte Fachkraft prüfen lassen.',
          it: 'Interrompere immediatamente l’uso. Tenere la piattaforma fuori servizio. Non forzare alcuna manipolazione. Far controllare da un professionista qualificato prima di ogni riutilizzo.',
          es: 'Interrumpa el uso de inmediato. Mantenga la plataforma fuera de servicio. No fuerce ninguna manipulación. Haga revisar por un profesional cualificado antes de cualquier reutilización.',
        );
      case 'low':
        return _pick(
          fr: 'Vérifiez l’environnement, l’appui, le rythme d’utilisation et la régularité. Contrôlez aussi l’état général et le montage des accessoires.',
          en: 'Check the environment, support, usage pace, and consistency. Also verify overall condition and accessory mounting.',
          de: 'Umgebung, Auflage, Nutzungsrhythmus und Konstanz prüfen. Außerdem Gesamtzustand und Zubehörmontage kontrollieren.',
          it: 'Verificare ambiente, appoggio, ritmo d’uso e regolarità. Controllare anche stato generale e montaggio degli accessori.',
          es: 'Verifique el entorno, el apoyo, el ritmo de uso y la regularidad. Controle también el estado general y el montaje de accesorios.',
        );
      case 'medium':
      default:
        return _pick(
          fr: 'Interrompez l’utilisation. Vérifiez visuellement l’état général. Essayez un autre consommable ou un autre élément d’alimentation si cela est pertinent. Effectuez un entretien si nécessaire. Si le problème persiste, faites contrôler.',
          en: 'Stop use. Perform a visual check of the general condition. Try different ammunition or a different feeding component if relevant. Perform maintenance if needed. If the issue persists, have it inspected.',
          de: 'Nutzung stoppen. Allgemeinzustand visuell prüfen. Falls sinnvoll andere Munition oder ein anderes Zuführelement verwenden. Bei Bedarf warten. Wenn das Problem anhält, prüfen lassen.',
          it: 'Interrompere l’uso. Eseguire un controllo visivo dello stato generale. Se pertinente, provare altra munizione o un diverso elemento di alimentazione. Effettuare manutenzione se necessario. Se il problema persiste, far controllare.',
          es: 'Interrumpa el uso. Realice una verificación visual del estado general. Pruebe otra munición u otro elemento de alimentación si es pertinente. Realice mantenimiento si es necesario. Si el problema persiste, haga revisar.',
        );
    }
  }

  static String diagnosticAvoidActions() => _pick(
        fr: 'Ne pas forcer. Ne pas poursuivre en cas de comportement anormal répété. Ne pas conclure sans vérification visuelle. Ne pas réutiliser en cas de doute.',
        en: 'Do not force anything. Do not continue after repeated abnormal behavior. Do not conclude without visual verification. Do not reuse if in doubt.',
        de: 'Nichts erzwingen. Bei wiederholt auffälligem Verhalten nicht fortsetzen. Keine Schlussfolgerung ohne Sichtprüfung. Bei Zweifel nicht weiterverwenden.',
        it: 'Non forzare nulla. Non proseguire in caso di comportamento anomalo ripetuto. Non concludere senza verifica visiva. Non riutilizzare in caso di dubbio.',
        es: 'No fuerce nada. No continúe ante comportamiento anómalo repetido. No saque conclusiones sin verificación visual. No reutilice en caso de duda.',
      );

  static String get questionIncidentTitle => _pick(
        fr: 'Quel type d’incident est observé ?',
        en: 'Which type of incident is observed?',
        de: 'Welche Art von Vorfall wird beobachtet?',
        it: 'Quale tipo di incidente viene osservato?',
        es: '¿Qué tipo de incidente se observa?',
      );

  static String get q5MarkOnPrimer => _pick(
        fr: 'Une trace d’impact est-elle visible sur l’amorce ?',
        en: 'Is an impact mark visible on the primer?',
        de: 'Ist eine Schlagspur auf dem Zündhütchen sichtbar?',
        it: 'È visibile un segno d’impatto sull’innesco?',
        es: '¿Se observa una marca de impacto en el fulminante?',
      );

  static String get q6RepeatsOtherAmmo => _pick(
        fr: 'Le problème se répète-t-il avec d’autres munitions ?',
        en: 'Does the issue repeat with other ammunition?',
        de: 'Tritt das Problem auch mit anderer Munition auf?',
        it: 'Il problema si ripete con altre munizioni?',
        es: '¿El problema se repite con otra munición?',
      );

  static String get q7CycleAbnormal => _pick(
        fr: 'Le cycle ou la fermeture paraissent-ils anormaux ?',
        en: 'Does cycling or lockup seem abnormal?',
        de: 'Wirken Zyklus oder Verriegelung auffällig?',
        it: 'Il ciclo o la chiusura sembrano anomali?',
        es: '¿El ciclo o el cierre parecen anómalos?',
      );

  static String get q8RecentCleaning => _pick(
        fr: 'La plateforme a-t-elle été nettoyée récemment ?',
        en: 'Has the platform been cleaned recently?',
        de: 'Wurde die Plattform kürzlich gereinigt?',
        it: 'La piattaforma è stata pulita di recente?',
        es: '¿Se ha limpiado la plataforma recientemente?',
      );

  static String get q9RealDelay => _pick(
        fr: 'Y a-t-il eu un délai net entre l’impact sur l’amorce et le départ ?',
        en: 'Was there a clear delay between primer impact and discharge?',
        de: 'Gab es eine klare Verzögerung zwischen Schlag auf das Zündhütchen und Schussauslösung?',
        it: 'C’è stato un ritardo netto tra l’impatto sull’innesco e lo sparo?',
        es: '¿Hubo un retraso claro entre el impacto en el fulminante y el disparo?',
      );

  static String get q10SingleRound => _pick(
        fr: 'Le phénomène concerne-t-il une seule munition ?',
        en: 'Does this affect only one round?',
        de: 'Betrifft das Phänomen nur eine einzelne Patrone?',
        it: 'Il fenomeno riguarda una sola munizione?',
        es: '¿El fenómeno afecta solo a una munición?',
      );

  static String get q11AlreadySeen => _pick(
        fr: 'Le phénomène s’est-il déjà produit auparavant ?',
        en: 'Has this happened before?',
        de: 'Ist dieses Phänomen bereits früher aufgetreten?',
        it: 'Il fenomeno si è già verificato in passato?',
        es: '¿Este fenómeno ya se presentó anteriormente?',
      );

  static String get q12RepeatedCycleIssue => _pick(
        fr: 'L’incident se produit-il souvent ?',
        en: 'Does the incident occur frequently?',
        de: 'Tritt der Vorfall häufig auf?',
        it: 'L’incidente si verifica spesso?',
        es: '¿El incidente ocurre con frecuencia?',
      );

  static String get q13ChangesWithOtherAmmo => _pick(
        fr: 'Le comportement change-t-il avec une autre munition ?',
        en: 'Does behavior change with different ammunition?',
        de: 'Verändert sich das Verhalten mit anderer Munition?',
        it: 'Il comportamento cambia con una munizione diversa?',
        es: '¿El comportamiento cambia con otra munición?',
      );

  static String get q14ChangesWithOtherMag => _pick(
        fr: 'Le comportement change-t-il avec un autre chargeur ou un autre élément d’alimentation ?',
        en: 'Does behavior change with another magazine or another feeding component?',
        de: 'Verändert sich das Verhalten mit einem anderen Magazin oder einem anderen Zuführelement?',
        it: 'Il comportamento cambia con un altro caricatore o un altro elemento di alimentazione?',
        es: '¿El comportamiento cambia con otro cargador u otro elemento de alimentación?',
      );

  static String get q15DirtyOrDry => _pick(
        fr: 'La plateforme semble-t-elle encrassée, peu lubrifiée ou anormalement dure en fonctionnement ?',
        en: 'Does the platform seem fouled, poorly lubricated, or abnormally stiff in operation?',
        de: 'Wirkt die Plattform verschmutzt, unzureichend geschmiert oder im Betrieb ungewöhnlich schwergängig?',
        it: 'La piattaforma sembra sporca, poco lubrificata o anormalmente dura nel funzionamento?',
        es: '¿La plataforma parece sucia, poco lubricada o anormalmente dura en funcionamiento?',
      );

  static String get q16SuddenAccuracyDrop => _pick(
        fr: 'La dégradation est-elle apparue brutalement ?',
        en: 'Did the accuracy drop appear suddenly?',
        de: 'Ist der Präzisionsabfall plötzlich aufgetreten?',
        it: 'Il peggioramento della precisione è comparso bruscamente?',
        es: '¿La pérdida de precisión apareció de forma brusca?',
      );

  static String get q17RecentChange => _pick(
        fr: 'Une munition, une optique ou un accessoire a-t-il changé récemment ?',
        en: 'Have ammunition, optic, or accessories changed recently?',
        de: 'Wurden Munition, Optik oder Zubehör kürzlich geändert?',
        it: 'Munizione, ottica o accessori sono cambiati di recente?',
        es: '¿Han cambiado recientemente la munición, la óptica o los accesorios?',
      );

  static String get q18VisibleMovement => _pick(
        fr: 'Un jeu, un desserrage ou un mouvement anormal est-il visible ?',
        en: 'Is visible play, loosening, or abnormal movement present?',
        de: 'Ist sichtbares Spiel, Lockerung oder eine auffällige Bewegung erkennbar?',
        it: 'È visibile gioco, allentamento o movimento anomalo?',
        es: '¿Se observa holgura, aflojamiento o movimiento anómalo?',
      );

  static String get q19HighRoundsSinceCleaning => _pick(
        fr: 'La plateforme a-t-elle beaucoup servi depuis le dernier entretien ?',
        en: 'Has the platform seen heavy use since the last maintenance?',
        de: 'Wurde die Plattform seit der letzten Wartung stark genutzt?',
        it: 'La piattaforma è stata usata molto dall’ultima manutenzione?',
        es: '¿La plataforma ha tenido mucho uso desde el último mantenimiento?',
      );

  static String get q20DependsOnSupport => _pick(
        fr: 'Le résultat varie-t-il surtout selon la position, l’appui ou le rythme ?',
        en: 'Does the result vary mainly with position, support, or pace?',
        de: 'Variiert das Ergebnis hauptsächlich je nach Position, Auflage oder Rhythmus?',
        it: 'Il risultato varia soprattutto in base a posizione, appoggio o ritmo?',
        es: '¿El resultado varía sobre todo según la posición, el apoyo o el ritmo?',
      );

  static String get q21ConfirmedOrSuspected => _pick(
        fr: 'Le départ involontaire ou anormal est-il confirmé ou seulement suspecté ?',
        en: 'Is the involuntary or abnormal discharge confirmed or only suspected?',
        de: 'Ist die unbeabsichtigte oder abnorme Schussauslösung bestätigt oder nur vermutet?',
        it: 'Lo sparo involontario o anomalo è confermato o solo sospetto?',
        es: '¿El disparo involuntario o anómalo está confirmado o solo sospechado?',
      );

  static String get diagnosticDefaultFinal => issueLabel('multiple_possible');
  static String get diagnosticSafetyPhase => _pick(
        fr: 'PHASE DE SÉCURITÉ',
        en: 'SAFETY PHASE',
        de: 'SICHERHEITSPHASE',
        it: 'FASE DI SICUREZZA',
        es: 'FASE DE SEGURIDAD',
      );
  static String get diagnosticClassification => _pick(
        fr: 'CLASSIFICATION',
        en: 'CLASSIFICATION',
        de: 'KLASSIFIZIERUNG',
        it: 'CLASSIFICAZIONE',
        es: 'CLASIFICACIÓN',
      );

  static String get diagnosticQuestion1 => _pick(
        fr: 'La plateforme est-elle orientée dans une direction sûre ?',
        en: 'Is the platform oriented in a safe direction?',
        de: 'Ist die Plattform in eine sichere Richtung ausgerichtet?',
        it: 'La piattaforma è orientata in una direzione sicura?',
        es: '¿La plataforma está orientada en una dirección segura?',
      );
  static String get diagnosticQuestion2 => _pick(
fr: 'Le doigt est-il hors de la détente ?',
en: 'Is the finger off the trigger?',
de: 'Ist der Finger vom Abzug weg?',
it: 'Il dito è fuori dal grilletto?',
es: '¿Está el dedo fuera del gatillo?',
      );
  static String get diagnosticQuestion3 => _pick(
        fr: 'Quel est l’état de la plateforme ?',
        en: 'What is the platform state?',
        de: 'Wie ist der Zustand der Plattform?',
        it: 'Qual è lo stato della piattaforma?',
        es: '¿Cuál es el estado de la plataforma?',
      );
  static String get diagnosticQuestion4 => questionIncidentTitle;
  static String get diagnosticQuestion5 => q5MarkOnPrimer;
  static String get diagnosticQuestion6 => q6RepeatsOtherAmmo;
  static String get diagnosticQuestion7 => q7CycleAbnormal;
  static String get diagnosticQuestion8 => q8RecentCleaning;
  static String get diagnosticQuestion9 => q9RealDelay;
  static String get diagnosticQuestion10 => q10SingleRound;
  static String get diagnosticQuestion11 => q11AlreadySeen;
  static String get diagnosticQuestion12 => q12RepeatedCycleIssue;
  static String get diagnosticQuestion13 => q13ChangesWithOtherAmmo;
  static String get diagnosticQuestion14 => q14ChangesWithOtherMag;
  static String get diagnosticQuestion15 => q15DirtyOrDry;
  static String get diagnosticQuestion16 => q16SuddenAccuracyDrop;
  static String get diagnosticQuestion17 => q17RecentChange;
  static String get diagnosticQuestion18 => q18VisibleMovement;
  static String get diagnosticQuestion19 => q19HighRoundsSinceCleaning;
  static String get diagnosticQuestion23 => q20DependsOnSupport;
  static String get diagnosticQuestion24 => q21ConfirmedOrSuspected;
  static String get diagnosticQuestion25 => q21ConfirmedOrSuspected;
  static String get diagnosticQuestion26 => q21ConfirmedOrSuspected;

  static String get diagnosticQuestion6Description => '';
  static String get diagnosticQuestion7Description => '';
  static String get diagnosticQuestion8Description => '';
  static String get diagnosticQuestion10Description => '';
  static String get diagnosticQuestion12Description => '';
  static String get diagnosticQuestion18Description => '';
  static String get diagnosticQuestion23Description => '';

  static String get diagnosticPlatformPossiblyLoaded => _pick(
        fr: 'Possiblement chargée',
        en: 'Possibly loaded',
        de: 'Möglicherweise geladen',
        it: 'Possibilmente carica',
        es: 'Posiblemente cargada',
      );
  static String get diagnosticPlatformOpenedSafe => _pick(
        fr: 'Ouverte et sécurisée',
        en: 'Open and safe',
        de: 'Geöffnet und gesichert',
        it: 'Aperta e in sicurezza',
        es: 'Abierta y en condición segura',
      );
  static String get diagnosticUnknownState => _pick(
        fr: 'État inconnu',
        en: 'Unknown state',
        de: 'Unbekannter Zustand',
        it: 'Stato sconosciuto',
        es: 'Estado desconocido',
      );

  static String get diagnosticIncidentNoFire => incidentNoFireLabel;
  static String get diagnosticIncidentHangfire => incidentDelayedFireLabel;
  static String get diagnosticIncidentUnintendedDischarge =>
      incidentAbnormalDepartureLabel;
  static String get diagnosticIncidentJam => incidentCycleLabel;
  static String get diagnosticIncidentAccuracyDrop => incidentAccuracyLabel;

  static String get diagnosticNoFireLabel => incidentNoFireLabel;
  static String get diagnosticHangfireLabel => incidentDelayedFireLabel;
  static String get diagnosticUnintendedDischargeLabel =>
      incidentAbnormalDepartureLabel;
  static String get diagnosticJamLabel => incidentCycleLabel;
  static String get diagnosticAccuracyDropLabel => incidentAccuracyLabel;

  static String get diagnosticNoOrUnknown => _pick(
        fr: 'NON / INCONNU',
        en: 'NO / UNKNOWN',
        de: 'NEIN / UNBEKANNT',
        it: 'NO / SCONOSCIUTO',
        es: 'NO / DESCONOCIDO',
      );
  static String get diagnosticNoOrDoubt => _pick(
        fr: 'NON / DOUTE',
        en: 'NO / DOUBT',
        de: 'NEIN / ZWEIFEL',
        it: 'NO / DUBBIO',
        es: 'NO / DUDA',
      );
  static String get diagnosticNoOrSeveral => _pick(
        fr: 'NON / PLUSIEURS',
        en: 'NO / MULTIPLE',
        de: 'NEIN / MEHRERE',
        it: 'NO / MULTIPLE',
        es: 'NO / VARIOS',
      );

  static String get diagnosticJamFeeding => _pick(
        fr: 'Alimentation',
        en: 'Feeding',
        de: 'Zuführung',
        it: 'Alimentazione',
        es: 'Alimentación',
      );
  static String get diagnosticJamReturnToBattery => _pick(
        fr: 'Retour en batterie',
        en: 'Return to battery',
        de: 'Verriegelungsrücklauf',
        it: 'Ritorno in chiusura',
        es: 'Retorno a cierre',
      );
  static String get diagnosticJamExtractionEjection => _pick(
        fr: 'Extraction / éjection',
        en: 'Extraction / ejection',
        de: 'Ausziehen / Auswerfen',
        it: 'Estrazione / espulsione',
        es: 'Extracción / expulsión',
      );

  static String get answerConfirmed => _pick(
        fr: 'Confirmé',
        en: 'Confirmed',
        de: 'Bestätigt',
        it: 'Confermato',
        es: 'Confirmado',
      );

  static String get answerSuspected => _pick(
        fr: 'Suspecté',
        en: 'Suspected',
        de: 'Vermutet',
        it: 'Sospettato',
        es: 'Solo sospechado',
      );
}
