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
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'THOT',
                subtitle: strings.aboutSubtitle,
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: Navigator.of(context).canPop()
                      ? () => Navigator.of(context).pop()
                      : null,
                ),
              ),
              const Gap(AppSpacing.lg),
              Text(
                strings.legalInfoTitle,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const Gap(8),
              Text(
                strings.legalInfoSubtitle,
                style: textTheme.bodyMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.7)),
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
            body: isFrench
                ? "THOT est un carnet de tir numérique destiné à organiser les informations liées au matériel, aux séances, aux statistiques, aux documents et au suivi personnel de l’utilisateur.\n\nLes données de l’application sont principalement stockées localement sur l’appareil.\n\nSite web : thotbook.fr\n"
                : "THOT is a digital shooting logbook designed to help you organize information related to your equipment, sessions, statistics, documents, and personal tracking.\n\nApp data is primarily stored locally on your device.\n\nWebsite: thotbook.fr\n",
          ),
          _LegalSection(
            title: strings.legalSupportTitle,
            body: isFrench
                ? "Pour toute assistance ou question :\n- Email : simapswebdesign@gmail.com\n"
                : "For assistance or questions:\n- Email: simapswebdesign@gmail.com\n",
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
            title: isFrench ? '1. Objet' : '1. Purpose',
            body: isFrench
                ? "Les présentes conditions générales d’utilisation encadrent l’accès au site thotbook.fr et à l’application THOT, ainsi que l’usage des fonctionnalités proposées. En utilisant le site ou l’application, vous acceptez ces conditions."
                : "These Terms of Use govern access to the thotbook.fr website and the THOT app, as well as the use of the provided features. By using the website or the app, you accept these terms.",
          ),
          _LegalSection(
            title: isFrench ? '2. Objet du service' : '2. Service description',
            body: isFrench
                ? "THOT est une application mobile de carnet de tir numérique destinée à organiser des informations liées au matériel, aux séances, aux statistiques, aux documents et au suivi personnel de l’utilisateur."
                : "THOT is a mobile digital shooting logbook intended to organize information related to equipment, sessions, statistics, documents, and personal tracking.",
          ),
          _LegalSection(
            title: isFrench ? '3. Nature de l’outil' : '3. Nature of the tool',
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
            title: isFrench ? '4. Accès et disponibilité' : '4. Access and availability',
            body: isFrench
                ? "Le site est accessible en ligne. L’application THOT est proposée via les boutiques de téléchargement compatibles. Certaines fonctions peuvent dépendre de l’appareil, du système d’exploitation, des autorisations accordées et des capacités techniques du terminal utilisé.\n\nL’éditeur peut faire évoluer, corriger, suspendre ou mettre à jour tout ou partie du service sans préavis, notamment pour des raisons techniques, de sécurité ou d’amélioration."
                : "The website is accessible online. The THOT app is distributed through compatible app stores. Some features may depend on the device, operating system, granted permissions, and technical capabilities.\n\nThe publisher may evolve, fix, suspend, or update all or part of the service without notice for technical, security, or improvement purposes.",
          ),
          _LegalSection(
            title: isFrench ? '5. Données et sécurité locale' : '5. Data and local security',
            body: isFrench
                ? "Les données de l’utilisateur sont principalement stockées localement sur son appareil. L’utilisateur conserve la maîtrise de ses informations et choisit lui-même, s’il le souhaite, d’utiliser les mécanismes de sauvegarde mis à disposition par son environnement ou son service cloud personnel.\n\nTHOT peut proposer une protection locale par code PIN et une authentification biométrique. Leur efficacité dépend également des réglages du terminal, du niveau de sécurité du système et des usages de l’utilisateur."
                : "User data is primarily stored locally on the device. You keep control of your information and may choose to use any backup mechanisms provided by your environment or your personal cloud services.\n\nTHOT may offer local protection via PIN code and biometric authentication. Their effectiveness also depends on device settings, system security level, and user practices.",
          ),
          _LegalSection(
            title: isFrench ? '6. Offre gratuite et abonnement Pro' : '6. Free plan and Pro subscription',
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
        title: isFrench ? 'Politique de confidentialité' : 'Privacy Policy',
        sections: [
          _LegalSection(
            title: isFrench ? '1. Principes' : '1. Principles',
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
                ? "Selon les fonctionnalités que vous activez, l’application peut accéder :\n\n- À votre localisation (uniquement lorsque vous appuyez sur un bouton de localisation/météo, afin de proposer un lieu et/ou récupérer la météo locale).\n- Au microphone (uniquement si vous activez la détection sonore dans le minuteur).\n- Au stockage local de l’appareil (pour enregistrer vos séances, votre inventaire, et les documents ajoutés)."
                : "Depending on the features you enable, the app may access:\n\n- Your location (only when you tap a location/weather button, to suggest a place and/or fetch local weather).\n- Your microphone (only if you enable sound detection in the shooting timer).\n- Local device storage (to store your sessions, inventory, and the documents you add).",
          ),
          _LegalSection(
            title: isFrench
                ? '5. Microphone (minuteur) : pourquoi, quand, et quelles données'
                : '5. Microphone (timer): why, when, and what data',
            body: isFrench
                ? "Pourquoi : le microphone est utilisé pour permettre la détection d’un départ sonore (ex : coup de feu) afin de déclencher/arrêter automatiquement le minuteur lorsque l’utilisateur active ce mode.\n\nQuand : le microphone est utilisé uniquement :\n- lorsque l’utilisateur sélectionne un mode de minuteur avec détection sonore ;\n- et pendant l’exécution du minuteur.\n\nDonnées audio : l’application ne stocke pas d’enregistrement audio, n’envoie pas d’audio sur Internet et ne partage pas de données audio avec des tiers. La détection repose sur des mesures instantanées du niveau sonore sur l’appareil."
                : "Why: the microphone is used to detect a sharp sound (e.g., a gunshot) in order to automatically start/stop the timer when you enable this mode.\n\nWhen: the microphone is used only when you select a sound-detection timer mode and while the timer is running.\n\nAudio data: the app does not store audio recordings, does not send audio over the Internet, and does not share audio data with third parties. Detection relies on instantaneous sound level measurements on the device.",
          ),
          _LegalSection(
            title: isFrench ? '6. Finalités du traitement' : '6. Purposes',
            body: isFrench
                ? "Les traitements de données peuvent notamment permettre de répondre aux demandes envoyées via le formulaire de contact, d’assurer la gestion des échanges avec les utilisateurs et prospects et d’améliorer la qualité des réponses ainsi que le suivi des demandes reçues."
                : "Data processing may be used to respond to requests submitted via the contact form, manage communications with users and prospects, and improve the quality of replies and the follow-up of received requests.",
          ),
          _LegalSection(
            title: isFrench ? '7. Base légale' : '7. Legal basis',
            body: isFrench
                ? "Le traitement des données issues du formulaire de contact repose sur l’intérêt légitime de l’éditeur à répondre aux messages reçus, ainsi que, le cas échéant, sur les démarches initiées par la personne concernée avant toute relation contractuelle."
                : "Processing of contact-form data is based on the publisher’s legitimate interest in responding to received messages and, where applicable, on steps initiated by the data subject prior to entering into any contractual relationship.",
          ),
          _LegalSection(
            title: isFrench
                ? '8. Stockage local dans l’application'
                : '8. Local storage in the app',
            body: isFrench
                ? "Les informations de suivi saisies dans l’application sont principalement stockées localement sur le terminal. L’utilisateur reste responsable de la sécurisation de son appareil et du recours éventuel aux services de sauvegarde de son choix, y compris un cloud personnel s’il décide d’en utiliser un.\n\nCertaines fonctionnalités, comme la biométrie, le code PIN, la géolocalisation optionnelle ou l’ajout de documents, dépendent des autorisations accordées et des capacités du terminal utilisé.\n\nLorsque l’utilisateur clique sur un bouton de localisation ou de météo dans la création d’une séance, l’application peut utiliser la position pour récupérer les données utiles aux deux automatismes : proposer automatiquement la ville du stand et obtenir les conditions météo locales. Les coordonnées peuvent aussi être transmises à un service de géocodage inverse afin d’obtenir un nom de ville lisible. Le switch météo ne contrôle que l’affichage de ces informations. Aucun appel de localisation n’est effectué en arrière-plan en dehors de cette action explicite."
                : "Tracking information entered in the app is primarily stored locally on your device. You remain responsible for securing your device and for using any backup mechanisms of your choice (including your own personal cloud services if you decide to use them).\n\nSome features (biometrics, PIN code, optional geolocation, document attachments) depend on the permissions you grant and on device capabilities.\n\nWhen you tap a location or weather button while creating a session, the app may use your location to suggest a shooting range city and fetch local weather conditions. Coordinates may also be sent to a reverse geocoding service to obtain a human-readable city name. No background location access is performed outside of this explicit action.",
          ),
          _LegalSection(
            title: isFrench
                ? '9. Suppression des données locales'
                : '9. Deleting local data',
            body: isFrench
                ? "L’application met à disposition une action permettant de supprimer l’ensemble des données locales stockées sur l’appareil concerné. Cette suppression vise notamment le profil, l’inventaire, les séances, les diagnostics, les documents ajoutés dans l’application, les préférences locales, les éléments de sécurité locaux (code PIN, biométrie, états de verrouillage), les clés de chiffrement locales ainsi que le cache local lié au statut premium. Les éventuelles sauvegardes ou synchronisations externes pilotées par l’utilisateur en dehors de l’application ne sont pas supprimées par cette action locale."
                : "The app provides an action to delete all local data stored on the device. This includes your profile, inventory, sessions, diagnostics, documents added in the app, local preferences, local security settings (PIN, biometrics, lock state), local encryption keys, and the local cache related to premium status. Any external backups or synchronizations controlled by you outside of the app are not deleted by this local action.",
          ),
          _LegalSection(
            title: isFrench ? '10. Retrait du consentement' : '10. Withdrawing consent',
            body: isFrench
                ? "Vous pouvez retirer votre consentement à tout moment :\n\n- Microphone : désactivez le mode de minuteur avec détection sonore et/ou retirez l’autorisation Micro dans les réglages du système (iOS/Android).\n- Localisation : retirez l’autorisation Localisation dans les réglages du système.\n\nVous pouvez également supprimer vos données en utilisant la fonctionnalité de suppression des données locales dans l’application, ou en désinstallant l’application."
                : "You can withdraw your consent at any time:\n\n- Microphone: disable the sound-detection timer mode and/or revoke the microphone permission in iOS/Android settings.\n- Location: revoke location permission in iOS/Android settings.\n\nYou can also delete your data using the in-app local data deletion feature, or by uninstalling the app.",
          ),
          _LegalSection(
            title: isFrench ? '11. Destinataires des données' : '11. Recipients',
            body: isFrench
                ? "Les données transmises via le formulaire de contact sont destinées à Thomas BOYER, éditeur de THOT, à l’adresse simapswebdesign@gmail.com. L’application peut également interroger des prestataires techniques strictement nécessaires à certaines fonctionnalités activées par l’utilisateur, par exemple un service météo, un service de géocodage inverse ou le service RevenueCat pour la gestion de l’abonnement Pro. Ces données ne sont pas destinées à une exploitation publicitaire ou à une revente par l’éditeur."
                : "Data sent via the contact form is received by Thomas BOYER, publisher of THOT, at simapswebdesign@gmail.com. The app may also interact with technical providers strictly necessary for user-enabled features (for example: a weather service, a reverse geocoding service, or RevenueCat for Pro subscription management). This data is not intended for advertising use or resale by the publisher.",
          ),
          _LegalSection(
            title: isFrench ? '12. Durée de conservation' : '12. Retention',
            body: isFrench
                ? "Les messages reçus peuvent être conservés pendant la durée nécessaire au traitement de la demande, au suivi de la relation et à la gestion des échanges, sauf obligation légale ou besoin légitime de conservation plus long. Les données de l’application conservées localement restent sur l’appareil jusqu’à leur suppression par l’utilisateur, la désinstallation de l’application ou les mécanismes de nettoyage du système."
                : "Received messages may be kept for the time necessary to handle the request, manage the relationship, and keep track of communications, unless legal obligations or legitimate needs require longer retention. App data stored locally remains on your device until you delete it, uninstall the app, or it is removed by system cleanup mechanisms.",
          ),
          _LegalSection(
            title: isFrench ? '13. Vos droits' : '13. Your rights',
            body: isFrench
                ? "Sous réserve de la réglementation applicable, vous pouvez demander l’accès, la rectification ou l’effacement de vos données, ainsi que la limitation de certains traitements ou formuler une opposition lorsque cela est possible."
                : "Subject to applicable law, you may request access to, rectification of, or deletion of your data, and you may request restriction of certain processing or object to processing where applicable.",
          ),
          _LegalSection(
            title: isFrench ? '14. Contact' : '14. Contact',
            body: isFrench
                ? "Pour exercer vos droits ou poser une question relative à la confidentialité, vous pouvez écrire à :\n- simapswebdesign@gmail.com"
                : "To exercise your rights or ask a privacy-related question, you can contact:\n- simapswebdesign@gmail.com",
          ),
        ],
      ),
      _LegalChapter(
        id: 'legal',
        title: isFrench ? 'Mentions légales' : 'Legal notice',
        sections: [
          _LegalSection(
            title: isFrench ? 'Éditeur' : 'Publisher',
            body: isFrench
                ? "Nom commercial : THOT\n\nÉditeur : Thomas BOYER\n\nAdresse : 11 allée du centre, 78000 Versailles, France\n\nEmail : simapswebdesign@gmail.com\n\nDirecteur de la publication : Thomas BOYER\n\nSite web : thotbook.fr"
                : "Trade name: THOT\n\nPublisher: Thomas BOYER\n\nAddress: 11 allée du centre, 78000 Versailles, France\n\nEmail: simapswebdesign@gmail.com\n\nPublication director: Thomas BOYER\n\nWebsite: thotbook.fr",
          ),
          _LegalSection(
            title: isFrench ? 'Hébergement' : 'Hosting',
            body: isFrench
                ? "Site web hébergé par : Netlify, Inc.\n\nSite web de l’hébergeur : https://www.netlify.com\n\nL’application THOT est distribuée via les stores Apple App Store et Google Play Store."
                : "Website hosting: Netlify, Inc.\n\nHost website: https://www.netlify.com\n\nThe THOT app is distributed through the Apple App Store and Google Play Store.",
          ),
          _LegalSection(
            title: isFrench ? 'Propriété intellectuelle' : 'Intellectual property',
            body: isFrench
                ? "Les éléments présents sur le site et dans l’application THOT, notamment les textes, la structure, l’interface, le design, le code, les éléments graphiques et les contenus associés, sont protégés par le droit de la propriété intellectuelle et demeurent la propriété de Thomas BOYER, sauf mention contraire.\n\nLa marque THOT n’est pas déposée à ce jour. Toute reproduction, représentation, adaptation, extraction, copie substantielle, réutilisation ou usage non autorisé du contenu, du code, du design, de la base d’informations ou du nom THOT est interdite sans autorisation préalable écrite."
                : "Elements available on the website and in the THOT app (including texts, structure, interface, design, code, graphics, and related content) are protected by intellectual property laws and remain the property of Thomas BOYER unless stated otherwise.\n\nThe THOT trademark is not registered at this time. Any reproduction, representation, adaptation, extraction, substantial copying, reuse, or unauthorized use of the content, code, design, data, or the name THOT is prohibited without prior written permission.",
          ),
          _LegalSection(
            title: isFrench ? 'Responsabilité' : 'Liability',
            body: isFrench
                ? "THOT est présenté comme un outil numérique d’organisation et de suivi personnel. Les informations publiées sur le site ont une vocation informative et peuvent être mises à jour à tout moment.\n\nL’éditeur s’efforce d’assurer l’exactitude des informations disponibles, sans garantir l’absence totale d’erreurs, d’omissions ou d’indisponibilités temporaires.\n\nL’application ne remplace aucune obligation réglementaire, administrative ou légale applicable à l’utilisateur. Celui-ci demeure seul responsable de l’usage de ses équipements, de ses données, de ses déclarations et du respect de la réglementation en vigueur dans son pays.\n\n${strings.diagnosticDisclaimerBody}"
                : "THOT is presented as a digital organization and personal tracking tool. Information published on the website is provided for informational purposes and may be updated at any time.\n\nThe publisher strives to ensure the accuracy of available information, without guaranteeing the total absence of errors, omissions, or temporary unavailability.\n\nThe app does not replace any regulatory, administrative, or legal obligation applicable to the user. You remain solely responsible for the use of your equipment, your data, your declarations, and compliance with applicable regulations in your country.\n\n${strings.diagnosticDisclaimerBody}",
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
  const _TocCard({
    required this.chapters,
    required this.initialChapterId,
  });

  final List<_LegalChapter> chapters;
  final String? initialChapterId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

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
            isFrench ? 'Chapitres' : 'Chapters',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
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
                    Icon(Icons.check_circle_rounded, color: colors.primary, size: 18)
                  else
                    Icon(Icons.menu_book_rounded, color: colors.secondary, size: 18),
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
  const _LegalSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
