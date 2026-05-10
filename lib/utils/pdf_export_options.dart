/// Options de sélection pour l'export PDF THOT.
class PdfExportOptions {
  final bool includePlatforms;
  final bool includeAmmos;
  final bool includeAccessories;
  final bool includeSessions;
  final bool includeAuth;

  const PdfExportOptions({
    this.includePlatforms = true,
    this.includeAmmos = true,
    this.includeAccessories = true,
    this.includeSessions = true,
    this.includeAuth = true,
  });

  bool get isEmpty =>
      !includePlatforms && !includeAmmos && !includeAccessories && !includeSessions;
}