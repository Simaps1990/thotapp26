import re

with open('lib/l10n/app_strings_tutorial.dart', 'r') as f:
    content = f.read()

# Replace descriptions with line breaks
def repl(m):
    # Only replace inside descriptions
    val = m.group(1)
    # We want to replace ". " with ".\n"
    # But only if it's followed by a capital letter or something
    # A simple string replace might be enough if we just match exactly.
    # Actually, the user says "des Retour à la ligne à chaque point"
    val = re.sub(r'\. ', '.\n', val)
    return m.group(0).replace(m.group(1), val)

# Update menu search texts first
content = re.sub(
    r"fr: 'Trois menus pour naviguer : Toutes vos sessions, uniquement les favoris, ou vos modèles prédéfinis.'",
    "fr: 'Trois menus pour filtrer : Toutes, Ce mois-ci, ou 7 derniers jours.\\nUtilisez la barre pour rechercher une session précise.'",
    content
)
content = re.sub(
    r"en: 'Three menus to navigate: All your sessions, favorites only, or your predefined templates.'",
    "en: 'Three menus to filter: All, This month, or Last 7 days.\\nUse the bar to search for a specific session.'",
    content
)
content = re.sub(
    r"de: 'Drei Menüs zum Navigieren: Alle Ihre Sitzungen, nur Favoriten oder Ihre vordefinierten Vorlagen.'",
    "de: 'Drei Menüs zum Filtern: Alle, Dieser Monat oder Letzte 7 Tage.\\nVerwenden Sie die Leiste, um nach einer bestimmten Sitzung zu suchen.'",
    content
)
content = re.sub(
    r"it: 'Tre menu per navigare: Tutte le sessioni, solo i preferiti, o i modelli predefiniti.'",
    "it: 'Tre menu per filtrare: Tutte, Questo mese, o Ultimi 7 giorni.\\nUsa la barra per cercare una sessione specifica.'",
    content
)
content = re.sub(
    r"es: 'Tres menús para navegar: Todas sus sesiones, solo favoritos, o sus plantillas predefinidas.'",
    "es: 'Tres menús para filtrar: Todas, Este mes, o Últimos 7 días.\\nUsa la barra para buscar una sesión específica.'",
    content
)

content = re.sub(
    r"fr: 'Trois menus pour naviguer : Toutes vos armes, uniquement les favoris, ou vos consommables.'",
    "fr: 'Trois onglets pour naviguer : Plateformes, Munitions ou Accessoires.\\nUtilisez la barre pour rechercher un équipement.'",
    content
)
content = re.sub(
    r"en: 'Three menus to navigate: All your weapons, favorites only, or your consumables.'",
    "en: 'Three tabs to navigate: Platforms, Ammunition or Accessories.\\nUse the bar to search for equipment.'",
    content
)
content = re.sub(
    r"de: 'Drei Menüs zum Navigieren: Alle Ihre Waffen, nur Favoriten oder Ihr Verbrauchsmaterial.'",
    "de: 'Drei Registerkarten zur Navigation: Plattformen, Munition oder Zubehör.\\nNutzen Sie die Leiste zur Suche nach Ausrüstung.'",
    content
)
content = re.sub(
    r"it: 'Tre menu per navigare: Tutte le armi, solo i preferiti, o i consumabili.'",
    "it: 'Tre schede per navigare: Piattaforme, Munizioni o Accessori.\\nUsa la barra per cercare un equipaggiamento.'",
    content
)
content = re.sub(
    r"es: 'Tres menús para navegar: Todas sus armas, solo favoritos, o sus consumibles.'",
    "es: 'Tres pestañas para navegar: Plataformas, Municiones o Accesorios.\\nUsa la barra para buscar equipo.'",
    content
)


# Now apply \n after each point inside description strings
def process_description(match):
    full_str = match.group(0)
    # We want to replace ". " with ".\n" inside the string
    # E.g. fr: '... . ...'
    # we need to be careful with \n already existing
    lines = full_str.split('\n')
    new_lines = []
    for line in lines:
        if re.match(r"\s*(fr|en|de|it|es):\s*'(.*)',?", line):
            m = re.match(r"(\s*(?:fr|en|de|it|es):\s*')(.*)('\,?)", line)
            prefix = m.group(1)
            text = m.group(2)
            suffix = m.group(3)
            # handle ". " -> ".\n"
            # Since the string will be multi-line, we need to handle formatting. 
            # Actually, Dart supports \n inside single quotes directly!
            # So replacing ". " with ".\n" literally works:
            text = text.replace('. ', '.\\n')
            new_lines.append(prefix + text + suffix)
        else:
            new_lines.append(line)
    return '\n'.join(new_lines)

content = re.sub(r'String get .*?Description => _pick\([\s\S]*?\);', process_description, content)
content = re.sub(r'String get onboardingDescription\d => _pick\([\s\S]*?\);', process_description, content)

with open('lib/l10n/app_strings_tutorial.dart', 'w') as f:
    f.write(content)

