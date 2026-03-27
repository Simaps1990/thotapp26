/// Options de sélection pour l'export PDF THOT.
class PdfExportOptions {
  final bool includeWeapons;
  final bool includeAmmos;
  final bool includeAccessories;
  final bool includeSessions;

  const PdfExportOptions({
    this.includeWeapons = true,
    this.includeAmmos = true,
    this.includeAccessories = true,
    this.includeSessions = true,
  });

  bool get isEmpty =>
      !includeWeapons && !includeAmmos && !includeAccessories && !includeSessions;
}