part of 'app_strings.dart';

extension AppStringsPdf on AppStrings {
  String pdfLabel(String key) {
    switch (key) {
      case 'Page': return _pick(fr: 'Page', en: 'Page', de: 'Seite', it: 'Pagina', es: 'Página');
      case 'PLATEFORMES': return _pick(fr: 'PLATEFORMES', en: 'PLATFORMS', de: 'PLATTFORMEN', it: 'PIATTAFORME', es: 'PLATAFORMAS');
      case 'CONSOMMABLES': return _pick(fr: 'CONSOMMABLES', en: 'CONSUMABLES', de: 'VERBRAUCHSMATERIAL', it: 'CONSUMABILI', es: 'CONSUMIBLES');
      case 'ACCESSOIRES': return _pick(fr: 'ACCESSOIRES', en: 'ACCESSORIES', de: 'ZUBEHÖR', it: 'ACCESSORI', es: 'ACCESORIOS');
      case 'STATISTIQUES': return _pick(fr: 'STATISTIQUES', en: 'STATISTICS', de: 'STATISTIKEN', it: 'STATISTICHE', es: 'ESTADÍSTICAS');
      case 'SESSIONS DE TIR': return _pick(fr: 'SESSIONS DE TIR', en: 'SHOOTING SESSIONS', de: 'SCHIESSSITZUNGEN', it: 'SESSIONI DI TIRO', es: 'SESIONES DE TIRO');
      case 'Export complet des données': return _pick(fr: 'Export complet des données', en: 'Complete data export', de: 'Vollständiger Datenexport', it: 'Esportazione dati completa', es: 'Exportación completa de datos');
      case 'SOMMAIRE': return _pick(fr: 'SOMMAIRE', en: 'SUMMARY', de: 'INHALTSVERZEICHNIS', it: 'SOMMARIO', es: 'RESUMEN');
      case 'Carnet de Tir Numérique': return _pick(fr: 'Carnet de Tir Numérique', en: 'Digital Shooting Logbook', de: 'Digitales Schießbuch', it: 'Registro di Tiro Digitale', es: 'Libro de Tiro Digital');
      case 'Marque': return _pick(fr: 'Marque', en: 'Brand', de: 'Marke', it: 'Marca', es: 'Marca');
      case 'Modèle': return _pick(fr: 'Modèle', en: 'Model', de: 'Modell', it: 'Modello', es: 'Modelo');
      case 'Calibre': return _pick(fr: 'Calibre', en: 'Caliber', de: 'Kaliber', it: 'Calibro', es: 'Calibre');
      case 'N° de série': return _pick(fr: 'N° de série', en: 'Serial Number', de: 'Seriennummer', it: 'N.º de serie', es: 'N.º de serie');
      case 'Type': return _pick(fr: 'Type', en: 'Type', de: 'Typ', it: 'Tipo', es: 'Tipo');
      case 'Poids': return _pick(fr: 'Poids', en: 'Weight', de: 'Gewicht', it: 'Peso', es: 'Peso');
      case 'Total coups': return _pick(fr: 'Total coups', en: 'Total shots', de: 'Gesamtschüsse', it: 'Totale colpi', es: 'Disparos totales');
      case 'Entretien': return _pick(fr: 'Entretien', en: 'Maintenance', de: 'Wartung', it: 'Manutenzione', es: 'Mantenimiento');
      case 'Révision': return _pick(fr: 'Révision', en: 'Revision', de: 'Revision', it: 'Revisione', es: 'Revisión');
      case 'Projectile': return _pick(fr: 'Projectile', en: 'Projectile', de: 'Geschoss', it: 'Proiettile', es: 'Proyectil');
      case 'Stock actuel': return _pick(fr: 'Stock actuel', en: 'Current stock', de: 'Aktueller Bestand', it: 'Scorte attuali', es: 'Stock actual');
      case 'Dernière utilisation': return _pick(fr: 'Dernière utilisation', en: 'Last used', de: 'Zuletzt verwendet', it: 'Ultimo utilizzo', es: 'Último uso');
      case 'Dernière pile': return _pick(fr: 'Dernière pile', en: 'Last battery change', de: 'Letzter Batteriewechsel', it: 'Ultimo cambio batteria', es: 'Último cambio de pila');
      case 'Lieu': return _pick(fr: 'Lieu', en: 'Location', de: 'Ort', it: 'Luogo', es: 'Lugar');
      case 'Coups tirés': return _pick(fr: 'Coups tirés', en: 'Shots fired', de: 'Abgegebene Schüsse', it: 'Colpi sparati', es: 'Disparos realizados');
      case 'Précision': return _pick(fr: 'Précision', en: 'Accuracy', de: 'Präzision', it: 'Precisione', es: 'Precisión');
      case 'Note': return _pick(fr: 'Note', en: 'Rating', de: 'Bewertung', it: 'Valutazione', es: 'Puntuación');
      case 'Température': return _pick(fr: 'Température', en: 'Temperature', de: 'Temperatur', it: 'Temperatura', es: 'Temperatura');
      case 'Humidité': return _pick(fr: 'Humidité', en: 'Humidity', de: 'Luftfeuchtigkeit', it: 'Umidità', es: 'Humedad');
      case 'Pression': return _pick(fr: 'Pression', en: 'Pressure', de: 'Luftdruck', it: 'Pressione', es: 'Presión');
      case 'Vent': return _pick(fr: 'Vent', en: 'Wind', de: 'Wind', it: 'Vento', es: 'Viento');
      case 'Exercices': return _pick(fr: 'Exercices', en: 'Exercises', de: 'Übungen', it: 'Esercizi', es: 'Ejercicios');
      case 'Distance': return _pick(fr: 'Distance', en: 'Distance', de: 'Entfernung', it: 'Distanza', es: 'Distancia');
      case 'Précision moy.': return _pick(fr: 'Précision moy.', en: 'Avg. accuracy', de: 'Durchschn. Präzision', it: 'Precisione media', es: 'Precisión media');
      case 'Licence': return _pick(fr: 'Licence', en: 'License', de: 'Lizenz', it: 'Licenza', es: 'Licencia');
      case 'Tireur': return _pick(fr: 'Tireur', en: 'Shooter', de: 'Schütze', it: 'Tiratore', es: 'Tirador');
      case 'Historique': return _pick(fr: 'Historique', en: 'History', de: 'Verlauf', it: 'Cronologia', es: 'Historial');
      case 'Pas de tir': return _pick(fr: 'Pas de tir', en: 'Shooting range', de: 'Schießstand', it: 'Poligono', es: 'Campo de tiro');
      case 'Observations': return _pick(fr: 'Observations', en: 'Observations', de: 'Beobachtungen', it: 'Osservazioni', es: 'Observaciones');
      case 'Sessions': return _pick(fr: 'Sessions', en: 'Sessions', de: 'Sitzungen', it: 'Sessioni', es: 'Sesiones');
      case 'SESSIONS': return _pick(fr: 'SESSIONS', en: 'SESSIONS', de: 'SITZUNGEN', it: 'SESSIONI', es: 'SESIONES');
      case 'Plateformes': return _pick(fr: 'Plateformes', en: 'Platforms', de: 'Plattformen', it: 'Piattaforme', es: 'Plataformas');
      case 'Plateforme': return _pick(fr: 'Plateforme', en: 'Platform', de: 'Plattform', it: 'Piattaforma', es: 'Plataforma');
      case 'plateforme': return _pick(fr: 'plateforme', en: 'platform', de: 'Plattform', it: 'piattaforma', es: 'plataforma');
      case 'plateformes': return _pick(fr: 'plateformes', en: 'platforms', de: 'Plattformen', it: 'piattaforme', es: 'plataformas');
      case 'Consommable': return _pick(fr: 'Consommable', en: 'Consumable', de: 'Verbrauchsmaterial', it: 'Consumabile', es: 'Consumible');
      case 'consommables': return _pick(fr: 'consommables', en: 'consumables', de: 'Verbrauchsmaterialien', it: 'consumabili', es: 'consumibles');
      case 'consommable': return _pick(fr: 'consommable', en: 'consumable', de: 'Verbrauchsmaterial', it: 'consumabile', es: 'consumible');
      case 'accessoires': return _pick(fr: 'accessoires', en: 'accessories', de: 'Zubehör', it: 'accessori', es: 'accesorios');
      case 'accessoire': return _pick(fr: 'accessoire', en: 'accessory', de: 'Zubehör', it: 'accessorio', es: 'accesorio');
      case 'sessions': return _pick(fr: 'sessions', en: 'sessions', de: 'Sitzungen', it: 'sessioni', es: 'sesiones');
      case 'session': return _pick(fr: 'session', en: 'session', de: 'Sitzung', it: 'sessione', es: 'sesión');
      case 'entrées': return _pick(fr: 'entrées', en: 'entries', de: 'Einträge', it: 'voci', es: 'entradas');
      case 'autres entrées': return _pick(fr: 'autres entrées', en: 'other entries', de: 'andere Einträge', it: 'altre voci', es: 'otras entradas');
      case 'coups au total': return _pick(fr: 'coups au total', en: 'total shots', de: 'Gesamtschüsse', it: 'colpi totali', es: 'disparos totales');
      case 'Jamais utilisé': return _pick(fr: 'Jamais utilisé', en: 'Never used', de: 'Nie verwendet', it: 'Mai usato', es: 'Nunca usado');
      case 'Cible': return _pick(fr: 'Cible', en: 'Target', de: 'Ziel', it: 'Bersaglio', es: 'Blanco');
      case 'de': return _pick(fr: 'de', en: 'of', de: 'von', it: 'di', es: 'de');
      case 'fr': return _pick(fr: 'fr', en: 'fr', de: 'fr', it: 'fr', es: 'fr');
      case 'en': return _pick(fr: 'en', en: 'en', de: 'en', it: 'en', es: 'en');
      case 'it': return _pick(fr: 'it', en: 'it', de: 'it', it: 'it', es: 'it');
      case 'es': return _pick(fr: 'es', en: 'es', de: 'es', it: 'es', es: 'es');
      default: return key;
    }
  }

  String pdfFooterLabel(String dateShort) {
    return _pick(
      fr: 'THOT - Document généré le $dateShort',
      en: 'THOT - Document generated on $dateShort',
      de: 'THOT - Dokument erstellt am $dateShort',
      it: 'THOT - Documento generato il $dateShort',
      es: 'THOT - Documento generado el $dateShort',
    );
  }
}
