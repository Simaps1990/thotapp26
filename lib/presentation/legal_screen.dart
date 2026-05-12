import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';
import 'package:thot/widgets/app_page_header.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key, this.initialChapterId});

  final String? initialChapterId;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final chapters = _buildChapters();

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: Navigator.of(context).canPop()
                        ? () => Navigator.of(context).pop()
                        : null,
                  ),
                  Expanded(
                    child: AppPageHeader(
                      title: 'THOT',
                      subtitle: strings.aboutSubtitle,
                    ),
                  ),
                ],
              ),
              const Gap(AppSpacing.lg),
              Text(
                strings.legalInfoTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(8),
              Text(
                strings.legalInfoSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Gap(AppSpacing.lg),
              _TocCard(
                chapters: chapters,
                initialChapterId: widget.initialChapterId,
              ),
              const Gap(AppSpacing.lg),
              ...chapters.map(
                (c) => _ChapterCard(
                  key: ValueKey('chapter-${c.id}'),
                  chapter: c,
                  initiallyExpanded: widget.initialChapterId == null
                      ? false
                      : widget.initialChapterId == c.id,
                ),
              ),
              const Gap(AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  List<_LegalChapter> _buildChapters() {
    final strings = AppStrings.of(context);
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    return [
      _LegalChapter(
        id: 'about',
        title: strings.legalAboutTitle,
        sections: [
          _LegalSection(
            title: strings.legalPresentationTitle,
            body: strings.legalPresentationBody,
          ),
          _LegalSection(
            title: strings.legalSupportTitle,
            body: strings.legalSupportBody,
          ),
          _LegalSection(
            title: strings.legalMicTimerDisclaimerSectionTitle,
            body: strings.legalMicTimerDisclaimerBody,
          ),
          _LegalSection(
            title: strings.legalDiagnosticDisclaimerSectionTitle,
            body: strings.diagnosticDisclaimerBody,
          ),
        ],
      ),
      _LegalChapter(
        id: 'cgu',
        title: strings.legalCguTitle,
        sections: [
          _LegalSection(
            title: strings.legalTermsPurposeTitle,
            body: isFrench
                ? "Les présentes conditions générales d’utilisation encadrent l’accès au site thotbook.fr et à l’application THOT, ainsi que l’usage des fonctionnalités proposées. En utilisant le site ou l’application, vous acceptez ces conditions."
                : "These Terms of Use govern access to the thotbook.fr website and the THOT app, as well as the use of the provided features. By using the website or the app, you accept these terms.",
          ),
          _LegalSection(
            title: strings.legalTermsServiceTitle,
            body: isFrench
                ? "THOT est une application mobile de carnet de tir numérique destinée à organiser des informations liées au matériel, aux sessions, aux statistiques, aux documents, aux consommables et au suivi personnel de l'utilisateur."
                : "THOT is a mobile digital shooting logbook intended to organize information related to equipment, sessions, statistics, documents, and personal tracking.",
          ),
          _LegalSection(
            title: strings.legalTermsToolNatureTitle,
            body: isFrench
                ? "THOT constitue un outil personnel d’organisation, de suivi et d’archivage. L’application ne remplace pas une obligation réglementaire, un registre officiel, un conseil juridique, ni une vérification de conformité.\n\nL’utilisateur demeure seul responsable des informations qu’il saisit, de leur exactitude, de leur conservation, de leur sauvegarde éventuelle et du respect des lois applicables à son activité."
                : "THOT is a personal organization, tracking, and archiving tool. The app does not replace any legal/regulatory obligation, official register, legal advice, or compliance check.\n\nYou remain solely responsible for the information you enter, its accuracy, its preservation, any backup you may perform, and your compliance with applicable laws.",
          ),
          _LegalSection(
            title: strings.legalMicTimerDisclaimerSectionTitle,
            body: strings.legalMicTimerDisclaimerBody,
          ),
          _LegalSection(
            title: strings.legalDiagnosticDisclaimerSectionTitle,
            body: strings.diagnosticDisclaimerBody,
          ),
          _LegalSection(
            title: strings.legalTermsAccessTitle,
            body: isFrench
                ? "Le site est accessible en ligne. L’application THOT est proposée via les boutiques de téléchargement compatibles. Certaines fonctions peuvent dépendre de l’appareil, du système d’exploitation, des autorisations accordées et des capacités techniques du terminal utilisé.\n\nL’éditeur peut faire évoluer, corriger, suspendre ou mettre à jour tout ou partie du service sans préavis, notamment pour des raisons techniques, de sécurité ou d’amélioration."
                : "The website is accessible online. The THOT app is distributed through compatible app stores. Some features may depend on the device, operating system, granted permissions, and technical capabilities.\n\nThe publisher may evolve, fix, suspend, or update all or part of the service without notice for technical, security, or improvement purposes.",
          ),
          _LegalSection(
            title: strings.legalDataStorageTitle,
            body: isFrench
                ? "Vos données ne quittent jamais votre appareil. THOT ne dispose d'aucun serveur propre, d'aucune base de données centrale, d'aucun compte utilisateur. Toutes vos données (plateformes, consommables, sessions, documents) restent stockées localement, uniquement sur votre appareil, avec une protection renforcée.\n\nAucune fuite via un serveur central n'est possible : il n'en existe pas.\n\nLes seuls échanges réseau optionnels sont la météo et le lieu d'une session (uniquement si vous appuyez sur le bouton dédié), et la validation de l'abonnement Pro via RevenueCat (identifiant de transaction anonyme, aucune donnée personnelle).\n\nL'application fonctionne entièrement hors ligne. THOT peut proposer une protection locale par code PIN et une authentification biométrique (Face ID / Touch ID)."
                : "Your data never leaves your device. THOT has no server, no central database, and no user account. All your data (platforms, ammo, sessions, documents) stays stored locally on your device only, with strong local protection.\n\nNo data leak through a central server is possible: there is none.\n\nThe only optional network calls are weather and location for a session (only when you tap the dedicated button), and Pro subscription validation via RevenueCat (anonymous transaction ID, no personal data).\n\nThe app works fully offline. THOT may offer local protection via PIN code and biometric authentication (Face ID / Touch ID).",
          ),
          _LegalSection(
            title: strings.legalPurchaseTitle,
            body: isFrench
                ? "Une version gratuite permet de découvrir THOT avec des limitations d’usage. Une version Pro est proposée au prix affiché dans l’application.\n\nLes abonnements, résiliations, modalités de facturation et remboursements relèvent des règles et conditions des plateformes de distribution concernées, notamment l’App Store et Google Play."
                : "A free version lets you discover THOT with usage limitations. A Pro version is available at the price shown in the app.\n\nSubscriptions, cancellations, billing terms, and refunds are governed by the rules and conditions of the distribution platforms, including the App Store and Google Play.",
          ),
          _LegalSection(
            title: isFrench ? '7. Usage acceptable' : '7. Acceptable use',
            body: isFrench
                ? "L’utilisateur s’engage à utiliser THOT de manière licite, loyale et conforme à la réglementation applicable. Il s’interdit notamment tout usage frauduleux, toute tentative de perturbation technique, d’extraction non autorisée de données ou d’atteinte aux droits de l’éditeur.\n\nToute utilisation contraire aux présentes conditions peut justifier des mesures techniques, juridiques ou organisationnelles appropriées."
                : "You agree to use THOT lawfully, fairly, and in compliance with applicable regulations. In particular, you must not use the service fraudulently, attempt to disrupt it, extract data without authorization, or infringe the publisher’s rights.\n\nAny use contrary to these terms may justify appropriate technical, legal, or organizational measures.",
          ),
          _LegalSection(
            title: isFrench ? '8. Contact' : '8. Contact',
            body: isFrench
                ? "Pour toute question relative aux présentes CGU, vous pouvez contacter l’éditeur à l’adresse suivante :\n- simapswebdesign@gmail.com"
                : "For any question regarding these Terms of Use, you can contact the publisher at:\n- simapswebdesign@gmail.com",
          ),
        ],
      ),
      _LegalChapter(
        id: 'privacy',
        title: strings.legalPrivacyTitle,
        sections: [
          _LegalSection(
            title: strings.legalPrivacyPrinciplesTitle,
            body: isFrench
                ? "Cette politique de confidentialité explique quelles informations peuvent être traitées dans le cadre du site et de l’application THOT, pour quelles finalités et selon quelles modalités.\n\nTHOT a été conçu avec une logique de confidentialité locale. Les données liées à l’usage de l’application sont principalement stockées sur l’appareil de l’utilisateur. L’éditeur ne met pas en place de compte utilisateur obligatoire et ne déclare pas de collecte analytics sur le site à ce jour."
                : "This Privacy Policy explains what information may be processed when using the THOT website and mobile application, for what purposes, and under which conditions.\n\nTHOT is designed with a local-first privacy approach. Most app data is stored on the user's device. The publisher does not require a mandatory user account and, at the time of writing, does not run analytics tracking on the website.",
          ),
          _LegalSection(
            title: isFrench
                ? '2. URL publique (Google Play)'
                : '2. Public URL (Google Play)',
            body: isFrench
                ? "Une version publique de cette politique de confidentialité est disponible à l’adresse suivante :\n\nhttps://thotbook.fr/privacy\n\n(à renseigner également dans le champ dédié de la Play Console)."
                : "A public version of this Privacy Policy is available at:\n\nhttps://thotbook.fr/privacy\n\n(This URL must also be provided in the dedicated field in Google Play Console.)",
          ),
          _LegalSection(
            title: isFrench
                ? '3. Données traitées via le site'
                : '3. Data processed via the website',
            body: isFrench
                ? "Lorsque vous utilisez le formulaire de contact, les données d’identité et de contact que vous renseignez, ainsi que le contenu de votre message, peuvent être transmis à l’éditeur par email afin de traiter votre demande.\n\nLes données concernées peuvent inclure notamment votre nom, votre adresse email et le contenu de votre message."
                : "When you use the contact form, the identity and contact details you provide, as well as the content of your message, may be sent to the publisher by email in order to handle your request.\n\nThis may include your name, your email address, and the content of your message.",
          ),
          _LegalSection(
            title: isFrench
                ? '4. Données accessibles dans l’application'
                : '4. Data accessed by the app',
            body: isFrench
                ? "Selon les fonctionnalités que vous activez, l'application peut accéder :\n\n- Une ville saisie manuellement (uniquement lorsque vous saisissez une ville pour la météo, sans accès à votre position GPS).\n- Au microphone (uniquement si vous activez la détection sonore dans le timer).\n- Aux notifications (uniquement si vous activez les rappels de péremption de documents).\n- Au stockage local de l'appareil (pour enregistrer vos sessions, votre inventaire, et les documents ajoutés sur l’appareil).\n\n- À votre appareil photo (uniquement si vous choisissez \"Prendre une photo\" dans le sélecteur de fichiers).\n- À votre galerie de photos (uniquement si vous choisissez la sélection de photos dans le sélecteur de fichiers)."
                : "Depending on the features you enable, the app may access:\n\n- A manually entered city (only when you enter a city for weather, with no GPS position access).\n- Your microphone (only if you enable sound detection in the timer).\n- Notifications (only if you enable document expiry reminders).\n- Local device storage (to store your sessions, inventory, and the documents you add on the device).\n\n- Your camera (only if you choose \"Take Photo\" in the file picker).\n- Your photo gallery (only if you choose photo selection in the file picker).",
          ),
          _LegalSection(
            title: isFrench
                ? strings.legalMicrophoneTimerTitle
                : strings.legalMicrophoneTimerTitle,
            body: isFrench
                ? "Pourquoi : le microphone est utilisé pour permettre la détection d’un départ sonore (ex : tir) afin de déclencher/arrêter automatiquement le minuteur lorsque l’utilisateur active ce mode.\n\nQuand : le microphone est utilisé uniquement :\n- lorsque l’utilisateur sélectionne un mode de minuteur avec détection sonore ;\n- et pendant l’exécution du minuteur.\n\nDonnées audio : l’application ne stocke pas d’enregistrement audio, n’envoie pas d’audio sur Internet et ne partage pas de données audio avec des tiers. La détection repose sur des mesures instantanées du niveau sonore sur l’appareil."
                : "Why: the microphone is used to detect a sharp sound (e.g., a gunshot) in order to automatically start/stop the timer when you enable this mode.\n\nWhen: the microphone is used only when you select a sound-detection timer mode and while the timer is running.\n\nAudio data: the app does not store audio recordings, does not send audio over the Internet, and does not share audio data with third parties. Detection relies on instantaneous sound level measurements on the device.",
          ),
          _LegalSection(
            title: strings.legalRevenueCatTitle,
            body: isFrench
                ? "Pourquoi : RevenueCat est utilisé pour gérer les abonnements Premium (achat, restauration, validation).\n\nQuand : uniquement si vous accédez aux fonctionnalités Premium ou restaurez un achat.\n\nDonnées : identifiants d’abonnement et de transaction nécessaires à la gestion. RevenueCat ne reçoit pas vos données personnelles ni vos contenus (sessions, documents, images).\n\nSécurité : communications sécurisées; RevenueCat est certifié ISO 27001."
                : "Why: RevenueCat is used to manage Premium subscriptions (purchase, restore, validation).\n\nWhen: only if you access Premium features or restore a purchase.\n\nData: subscription and transaction identifiers required for management. RevenueCat does not receive your personal data or your content (sessions, documents, images).\n\nSecurity: secure communications; RevenueCat is ISO 27001 certified.",
          ),
          _LegalSection(
            title: strings.legalBackupTitle,
            body: isFrench
                ? "THOT peut transférer des données hors de l\'appareil uniquement dans les cas suivants :\n\n- Météo : nom de ville vers API Open-Meteo.com pour récupérer données météo publiques.\n- Abonnements : identifiants de transaction vers RevenueCat pour gestion des abonnements.\n- Sauvegarde système : les données applicatives (inventaire, sessions, diagnostics, préférences) sont incluses dans la sauvegarde automatique du système d\'exploitation (iCloud Backup sur iOS, Google Auto Backup sur Android), comme pour la majorité des applications. Cette sauvegarde permet la restauration de l\'application sur un nouvel appareil. Elle est gérée par Apple ou Google selon les paramètres de votre compte et de votre appareil. THOT ne reçoit aucune copie de cette sauvegarde.\n\nTHOT n\'envoie aucun de vos contenus personnels (sessions, documents, images) vers ses propres serveurs."
                : "THOT may transfer data off-device only in the following cases:\n\n- Weather: city name to Open-Meteo.com API to fetch public weather data.\n- Subscriptions: transaction identifiers to RevenueCat for subscription management.\n- System backup: app data (inventory, sessions, diagnostics, preferences) is included in the operating system's automatic backup (iCloud Backup on iOS, Google Auto Backup on Android), as for most apps. This backup enables app restoration on a new device. It is managed by Apple or Google according to your account and device settings. THOT does not receive any copy of this backup.\n\nTHOT does not send any of your personal content (sessions, documents, images) to its own servers.",
          ),
          _LegalSection(
            title: isFrench ? '8. Chiffrement' : '8. Encryption',
            body: isFrench
                ? "Les données de l'application sont protégées par le sandbox applicatif du système d'exploitation (iOS Data Protection, Android SELinux/sandbox). THOT ne met pas en œuvre de couche de chiffrement applicatif supplémentaire indépendante du système. La sécurité repose sur les mécanismes natifs fournis par Apple et Google.\n\nCertaines pièces jointes et images peuvent également rester stockées localement via les mécanismes natifs du sélecteur de fichiers."
                : "App data is protected by the operating system's applicative sandbox (iOS Data Protection, Android SELinux/sandbox). THOT does not implement an additional independent application-level encryption layer beyond the system. Security relies on the native mechanisms provided by Apple and Google.\n\nSome attachments and images may also remain stored locally via native file picker mechanisms.",
          ),
          _LegalSection(
            title: isFrench ? '9. Finalités du traitement' : '9. Purposes',
            body: isFrench
                ? "Les traitements de données peuvent notamment permettre de répondre aux demandes envoyées via le formulaire de contact, d’assurer la gestion des échanges avec les utilisateurs et prospects et d’améliorer la qualité des réponses ainsi que le suivi des demandes reçues."
                : "Data processing may be used to respond to requests submitted via the contact form, manage communications with users and prospects, and improve the quality of replies and the follow-up of received requests.",
          ),
          _LegalSection(
            title: isFrench ? '10. Base légale' : '10. Legal basis',
            body: isFrench
                ? "Le traitement des données issues du formulaire de contact repose sur l’intérêt légitime de l’éditeur à répondre aux messages reçus, ainsi que, le cas échéant, sur les démarches initiées par la personne concernée avant toute relation contractuelle."
                : "Processing of contact-form data is based on the publisher’s legitimate interest in responding to received messages and, where applicable, on steps initiated by the data subject prior to entering into any contractual relationship.",
          ),
          _LegalSection(
            title: isFrench
                ? strings.legalLocalStorageTitle
                : strings.legalLocalStorageTitle,
            body: isFrench
                ? "Les informations de suivi saisies dans l'application sont stockées localement sur le terminal et incluses dans la sauvegarde automatique du système d'exploitation (iCloud Backup sur iOS, Google Auto Backup sur Android). Cette sauvegarde système permet à l'utilisateur de restaurer ses données sur un nouvel appareil sans intervention manuelle. THOT ne crée pas de sauvegarde sur ses propres serveurs.\n\nL'utilisateur peut désactiver cette sauvegarde système dans les paramètres de son compte Apple iCloud ou Google selon sa préférence.\n\nCertaines fonctionnalités, comme la biométrie, le code PIN ou l'ajout de documents, dépendent des autorisations accordées et des capacités du terminal utilisé.\n\nLorsque l'utilisateur saisit manuellement une ville dans la création d'une session et active la météo, l'application utilise uniquement le nom de la ville pour récupérer les conditions météo locales. Aucun accès au GPS ou à la position de l'appareil n'est effectué. Le switch météo ne contrôle que l'affichage de ces informations."
                : "Tracking information entered in the app is stored locally on your device and is included in the operating system's automatic backup (iCloud Backup on iOS, Google Auto Backup on Android). This system backup enables you to restore your data on a new device without manual action. THOT does not create any backup on its own servers.\n\nYou can disable this system backup in your Apple iCloud or Google account settings.\n\nSome features (biometrics, PIN code, document attachments) depend on the permissions you grant and on device capabilities.\n\nWhen you manually enter a city while creating a session and enable weather, the app uses only the city name to fetch local weather conditions. No GPS or device position access is performed. The weather switch only controls the display of this information.",
          ),
          _LegalSection(
            title: isFrench
                ? '12. Suppression des données locales'
                : '12. Deleting local data',
            body: isFrench
                ? "L'application met à disposition une action permettant de supprimer l'ensemble des données locales stockées sur l'appareil concerné. Cette suppression vise notamment le profil, l'inventaire, les sessions, les diagnostics, les documents ajoutés dans l'application, les préférences locales, les éléments de sécurité locaux (code PIN, biométrie, états de verrouillage) ainsi que le cache local lié au statut premium. Les sauvegardes système (iCloud, Google Auto Backup) précédemment effectuées par le système d'exploitation ne sont pas supprimées par cette action locale ; pour les supprimer, l'utilisateur doit utiliser les paramètres de son compte Apple iCloud ou Google."
                : "The app provides an action to delete all local data stored on the device. This includes your profile, inventory, sessions, diagnostics, documents added in the app, local preferences, local security settings (PIN, biometrics, lock state), and the local cache related to premium status. System backups (iCloud, Google Auto Backup) previously made by the operating system are not deleted by this local action; to delete them, you must use your Apple iCloud or Google account settings.",
          ),
          _LegalSection(
            title: isFrench
                ? '13. Retrait du consentement'
                : '13. Withdrawing consent',
            body: isFrench
                ? "Vous pouvez retirer votre consentement à tout moment :\n\n- Microphone : désactivez le mode de minuteur avec détection sonore et/ou retirez l’autorisation Micro dans les réglages du système (iOS/Android).\n- Notifications : désactivez les rappels de péremption dans les paramètres THOT et/ou retirez l’autorisation Notifications dans les réglages du système (iOS/Android).\n- Météo : cessez de saisir des villes dans vos sessions ou désactivez la fonction météo.\n\nVous pouvez également supprimer vos données en utilisant la fonctionnalité de suppression des données locales dans l’application, ou en désinstallant l’application."
                : "You can withdraw your consent at any time:\n\n- Microphone: disable the sound-detection timer mode and/or revoke the microphone permission in iOS/Android settings.\n- Notifications: disable document expiry reminders in THOT settings and/or revoke notification permission in iOS/Android settings.\n- Weather: stop entering cities in your sessions or disable the weather function.\n\nYou can also delete your data using the in-app local data deletion feature, or by uninstalling the app.",
          ),
          _LegalSection(
            title: isFrench
                ? '14. Destinataires des données'
                : '14. Recipients',
            body: isFrench
                ? "Les données transmises via le formulaire de contact sont destinées à Paola PAVIOT, éditeur de THOT, à l'adresse simapswebdesign@gmail.com. L'application peut également interroger des prestataires techniques strictement nécessaires à certaines fonctionnalités activées par l'utilisateur, par exemple un service météo, un service de géocodage inverse ou le service RevenueCat pour la gestion de l'abonnement Pro. Ces données ne sont pas destinées à une exploitation publicitaire ou à une revente par l'éditeur."
                : "Data sent via the contact form is received by Paola PAVIOT, publisher of THOT, at simapswebdesign@gmail.com. The app may also interact with technical providers strictly necessary for user-enabled features (for example: a weather service, a reverse geocoding service, or RevenueCat for Pro subscription management). This data is not intended for advertising use or resale by the publisher.",
          ),
          _LegalSection(
            title: isFrench ? '15. Durée de conservation' : '15. Retention',
            body: isFrench
                ? "Les messages reçus peuvent être conservés pendant la durée nécessaire au traitement de la demande, au suivi de la relation et à la gestion des échanges, sauf obligation légale ou besoin légitime de conservation plus long. Les données de l’application conservées localement restent sur l’appareil jusqu’à leur suppression par l’utilisateur, la désinstallation de l’application ou les mécanismes de nettoyage du système."
                : "Received messages may be kept for the time necessary to handle the request, manage the relationship, and keep track of communications, unless legal obligations or legitimate needs require longer retention. App data stored locally remains on your device until you delete it, uninstall the app, or it is removed by system cleanup mechanisms.",
          ),
          _LegalSection(
            title: isFrench ? '16. Vos droits' : '16. Your rights',
            body: isFrench
                ? "Sous réserve de la réglementation applicable, vous pouvez demander l’accès, la rectification ou l’effacement de vos données, ainsi que la limitation de certains traitements ou formuler une opposition lorsque cela est possible."
                : "Subject to applicable law, you may request access to, rectification of, or deletion of your data, and you may request restriction of certain processing or object to processing where applicable.",
          ),
          _LegalSection(
            title: isFrench ? '17. Contact' : '17. Contact',
            body: isFrench
                ? "Pour exercer vos droits ou poser une question relative à la confidentialité, vous pouvez écrire à :\n- simapswebdesign@gmail.com"
                : "To exercise your rights or ask a privacy-related question, you can contact:\n- simapswebdesign@gmail.com",
          ),
        ],
      ),
      _LegalChapter(
        id: 'legal',
        title: strings.legalMentionsTitle,
        sections: [
          _LegalSection(
            title: strings.legalPublisherTitle,
            body: isFrench
                ? "Nom commercial : THOT\n\nÉditeur : Paola PAVIOT\n\nAdresse : 11 allée du centre, 78000 Versailles, France\n\nEmail : simapswebdesign@gmail.com\n\nDirecteur de la publication : Paola PAVIOT\n\nSite web : thotbook.fr"
                : "Trade name: THOT\n\nPublisher: Paola PAVIOT\n\nAddress: 11 allée du centre, 78000 Versailles, France\n\nEmail: simapswebdesign@gmail.com\n\nPublication director: Paola PAVIOT\n\nWebsite: thotbook.fr",
          ),
          _LegalSection(
            title: strings.legalHostingTitle,
            body: isFrench
                ? "Site web hébergé par : Netlify, Inc.\n\nSite web de l’hébergeur : https://www.netlify.com\n\nL’application THOT est distribuée via les stores Apple App Store et Google Play Store."
                : "Website hosting: Netlify, Inc.\n\nHost website: https://www.netlify.com\n\nThe THOT app is distributed through the Apple App Store and Google Play Store.",
          ),
          _LegalSection(
            title: isFrench
                ? 'Propriété intellectuelle'
                : 'Intellectual property',
            body: isFrench
                ? "Les éléments présents sur le site et dans l’application THOT, notamment les textes, la structure, l’interface, le design, le code, les éléments graphiques et les contenus associés, sont protégés par le droit de la propriété intellectuelle et demeurent la propriété de Paola PAVIOT, sauf mention contraire.\n\nLa marque THOT n’est pas déposée à ce jour. Toute reproduction, représentation, adaptation, extraction, copie substantielle, réutilisation ou usage non autorisé du contenu, du code, du design, de la base d’informations ou du nom THOT est interdite sans autorisation préalable écrite."
                : "Elements available on the website and in the THOT app (including texts, structure, interface, design, code, graphics, and related content) are protected by intellectual property laws and remain the property of Paola PAVIOT unless stated otherwise.\n\nThe THOT trademark is not registered at this time. Any reproduction, representation, adaptation, extraction, substantial copying, reuse, or unauthorized use of the content, code, design, data, or the name THOT is prohibited without prior written permission.",
          ),
          _LegalSection(
            title: strings.legalLiabilityTitle,
            body: isFrench
                ? "THOT est présenté comme un outil numérique d’organisation et de suivi personnel. Les informations publiées sur le site ont une vocation informative et peuvent être mises à jour à tout moment.\n\nL’éditeur s’efforce d’assurer l’exactitude des informations disponibles, sans garantir l’absence totale d’erreurs, d’omissions ou d’indisponibilités temporaires.\n\nL’application ne remplace aucune obligation réglementaire, administrative ou légale applicable à l’utilisateur. Celui-ci demeure seul responsable de l’usage de ses équipements, de ses données, de ses déclarations et du respect de la réglementation en vigueur dans son pays.\n\n${strings.diagnosticDisclaimerBody}"
                : "THOT is presented as a digital organization and personal tracking tool. Information published on the website is provided for informational purposes and may be updated at any time.\n\nThe publisher strives to ensure the accuracy of available information, without guaranteeing the total absence of errors, omissions, or temporary unavailability.\n\nThe app does not replace any regulatory, administrative, or legal obligation applicable to the user. You remain solely responsible for the use of your equipment, your data, your declarations, and compliance with applicable regulations in your country.\n\n${strings.diagnosticDisclaimerBody}",
          ),
          _LegalSection(
            title: isFrench
                ? 'Exploitation des exercices (Stroop, MOT, mémoire, calcul mental, réaction, etc.)'
                : 'Use of exercises (Stroop, MOT, memory, mental math, reaction, etc.)',
            body: isFrench
                ? "Les exercices intégrés à THOT sont proposés à des fins d’entraînement personnel, de progression individuelle et d’aide pédagogique. Ils ne constituent pas un dispositif médical, un outil d’évaluation clinique, ni une certification de performance.\n\nPour chaque exercice, les résultats sont strictement indicatifs, non opposables, et ne doivent pas être utilisés comme preuve, validation officielle ou base unique de décision opérationnelle/professionnelle :\n- Stroop (inhibition/attention) ;\n- MOT (suivi d’objets multiples) ;\n- Mémoire ;\n- Calcul mental ;\n- Réaction visuelle ;\n- Réaction auditive.\n\nL’utilisateur reconnaît que l’exploitation des résultats (scores, vitesses, taux de réussite, historiques) relève de sa seule responsabilité. Ces résultats peuvent varier selon le contexte d’usage, l’appareil, la fatigue, l’environnement ou les réglages.\n\nL’éditeur ne saurait être tenu responsable des décisions, interprétations, usages opérationnels, professionnels ou réglementaires fondés sur ces exercices ou leurs résultats."
                : "Exercises available in THOT are provided for personal training, individual progress, and educational support purposes. They do not constitute a medical device, a clinical assessment tool, or a performance certification.\n\nFor each exercise, results are strictly indicative, non-binding, and must not be used as proof, official validation, or as the sole basis for operational/professional decisions:\n- Stroop (inhibition/attention);\n- MOT (multiple object tracking);\n- Memory;\n- Mental math;\n- Visual reaction;\n- Auditory reaction.\n\nYou acknowledge that any use of results (scores, speed, success rates, history) is under your sole responsibility. Such results may vary depending on usage context, device, fatigue, environment, or settings.\n\nThe publisher cannot be held liable for decisions, interpretations, operational/professional uses, or regulatory uses based on these exercises or their results.",
          ),
          _LegalSection(
            title: isFrench ? 'Contact' : 'Contact',
            body: isFrench
                ? "Pour toute question juridique, demande d’information ou signalement relatif au site thotbook.fr, vous pouvez écrire à l’adresse suivante :\n- simapswebdesign@gmail.com"
                : "For any legal question, request for information, or report related to thotbook.fr, you can write to:\n- simapswebdesign@gmail.com",
          ),
        ],
      ),
    ];
  }
}

class _TocCard extends StatelessWidget {
  const _TocCard({required this.chapters, required this.initialChapterId});

  final List<_LegalChapter> chapters;
  final String? initialChapterId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.legalChaptersLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(12),
          ...chapters.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      c.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (initialChapterId == c.id)
                    Icon(
                      Icons.check_circle_rounded,
                      color: colors.primary,
                      size: 18,
                    )
                  else
                    Icon(
                      Icons.menu_book_rounded,
                      color: colors.secondary,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  const _ChapterCard({
    super.key,
    required this.chapter,
    required this.initiallyExpanded,
  });

  final _LegalChapter chapter;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        title: Text(
          chapter.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...chapter.sections.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                        const Gap(6),
                        SelectableText(
                          s.body,
                          style: textTheme.bodyMedium?.copyWith(
                            height: 1.35,
                            color: colors.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalChapter {
  const _LegalChapter({
    required this.id,
    required this.title,
    required this.sections,
  });

  final String id;
  final String title;
  final List<_LegalSection> sections;
}

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}
