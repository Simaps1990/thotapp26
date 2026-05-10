# THOT - Carnet de Tir Numérique / Digital Shooting Logbook

## Présentation Générale

THOT est une application mobile conçue comme le carnet de tir numérique incontournable pour les utilisateurs de plateformes d'armes à feu. L'application fonctionne 100% hors-ligne avec des données protégées localement sur l'appareil, sécurisées par code PIN ou biométrie selon la configuration choisie. Aucun serveur, aucun compte, aucune fuite de données possible.

## Public Cible

- Tireurs sportifs (IPSC, PPC, tir de précision)
- Propriétaires d'armes à feu
- Entraîneurs et moniteurs de tir
- Professionnels des forces de l'ordre et militaires
- Passionnés de tir qui souhaitent suivre leur progression et leur matériel

## Langues Disponibles

- Français (FR)
- Anglais (EN)
- Allemand (DE)
- Italien (IT)
- Espagnol (ES)

## Fonctionnalités Principales

### 1. Gestion de l'Inventaire

#### Plateformes (Armes)
- **Informations détaillées**: Nom, modèle, type (PA, FA, FM, FP...), calibre, numéro de série, poids
- **Suivi de l'usure**: Compteur de coups tirés, seuil de révision configurable, indicateur de progression d'usure
- **Suivi de l'entretien**: Date du dernier nettoyage, seuil de nettoyage configurable, indicateur de progression de salissure
- **Historique**: Enregistrement des événements de tir, entretien, et révision
- **Documents**: Ajout de factures, manuels, garanties avec dates d'expiration et notifications
- **Photos**: Photo de l'arme avec affichage dans la fiche détaillée
- **Liaison d'accessoires**: Association d'accessoires à chaque plateforme
- **Types de plateformes**: Pistols semi-automatiques, fusils, carabines, etc.

#### Consommables (Munitions)
- **Informations**: Nom, marque, calibre, type de projectile (FMJ, pointe creuse, Gold Dot, etc.)
- **Gestion du stock**: Quantité actuelle, stock initial, seuil d'alerte de stock bas
- **Historique**: Suivi des recharges et des consommations
- **Documents**: Factures, fiches techniques
- **Photos**: Photo des munitions
- **Alertes**: Notification lorsque le stock atteint le seuil critique

#### Accessoires
- **Informations**: Marque, modèle, type (optique, holster, protection, etc.)
- **Suivi d'utilisation**: Compteur de coups tirés avec l'accessoire
- **Maintenance**: Suivi de l'entretien et de la révision (comme les plateformes)
- **Suivi de batterie**: Date du dernier changement de batterie
- **Liaison aux plateformes**: Association à plusieurs plateformes
- **Documents**: Factures, manuels, garanties
- **Photos**: Photo de l'accessoire

### 2. Sessions de Tir

#### Création de Sessions
- **Informations générales**: Nom, date, lieu, type de session (Personnel, Professionnel, Compétition)
- **Météo**: Température, vent, humidité, pression (optionnel)
- **Localisation**: Coordonnées GPS et distance de tir
- **Exercices multiples**: Une session peut contenir plusieurs exercices

#### Exercices Détaillés
- **Mode simple**: Distance, nombre de coups tirés, précision, observations
- **Mode détaillé par étapes**: 
  - Déplacements (mouvements tactiques)
  - Mises en joue (positions, cibles, distances)
  - Tirs (nombre de coups par plateforme)
  - Rechargements (type de rechargement)
  - Transitions (changement de plateforme)
  - Attentes (durées, déclencheurs)
  - Sécurité (phrase de sécurité)
  - Autres (étapes personnalisées)
- **Assignation de matériel**: 
  - Plateformes (inventaire ou personnalisées)
  - Consommables (inventaire, prêtés, ou personnalisés)
  - Accessoires (sélectionnés automatiquement ou manuellement)
- **Cibles**: Nom de la cible, photos multiples avec légendes
- **Précision**: Pourcentage de réussite (optionnel par exercice)
- **Observations**: Notes libres sur chaque exercice

#### Modèles d'Exercices
- **Création de modèles**: Enregistrer des exercices types pour les réutiliser
- **Import rapide**: Ajouter un exercice depuis un modèle existant
- **Mode simple ou détaillé**: Les modèles supportent les deux modes

### 3. Statistiques et Analyses

#### Résumé Global
- **Sessions totales**: Nombre de sessions enregistrées
- **Coups tirés**: Total de cartouches tirées
- **Plateformes**: Nombre de plateformes en inventaire
- **Précision moyenne**: Moyenne des précisions mesurées
- **Sessions à 100%**: Nombre de sessions parfaites
- **Meilleure session**: Session avec la meilleure précision

#### Précision
- **Graphique d'évolution**: Courbe de précision dans le temps
- **Filtres temporels**: 1 jour, 1 semaine, 1 mois, 1 année, total
- **Indicateurs**: Moyenne, maximum
- **Sessions parfaites**: Pourcentage de sessions à 100%

#### Rythme d'Entraînement
- **Graphique en barres**: Nombre de sessions par période (semaine/mois)
- **Sessions cette semaine**: Compteur de la semaine en cours
- **Sessions ce mois**: Compteur du mois en cours

#### Analyse par Plateforme
- **Plateforme la plus utilisée**: Celle avec le plus de coups tirés
- **Top plateformes**: Classement des 4 plateformes les plus utilisées
- **Graphique d'utilisation**: Répartition des coups par plateforme

#### Analyse par Consommable
- **Consommable le plus critique**: Celui avec le ratio quantité/seuil le plus bas
- **Alerte de stock**: Indicateur visuel de criticité

#### Fiche Détaillée
- **Historique d'utilisation**: Graphique d'utilisation dans le temps
- **Documents**: Liste des documents attachés
- **Statistiques**: Résumé des performances avec cet item

### 4. Outils de Tir

#### Timer de Tir (Shot Timer)
- **Modes disponibles**:
  - **Simple**: Un bip après le délai choisi
  - **Par time**: Délai puis fenêtre d'action avant le bip final
  - **Répétitions**: Plusieurs départs espacés pour enchaîner les séries
  - **Bip aléatoire**: Délai de départ aléatoire (50% à 100% du délai choisi)
  - **Réaction au bip**: Le timer tourne jusqu'à détection sonore (ou stop manuel)
  - **Multi hit**: Détection de chaque impact sonore avec temps intermédiaires
- **Paramètres**: Délai de départ, par time, durée de cycle, nombre de répétitions, sensibilité du micro
- **Feedback sonore et vibration**: Activation/désactivation
- **Détection sonore**: Utilisation du microphone pour détecter les impacts (aucun audio enregistré, traité localement uniquement)
- **Temps enregistrés**: Affichage des temps intermédiaires pour chaque tir

#### Tables de Tir (Shooting Adjustment Tables)
- **Tables de réglage**: Création de tables de zérotage pour chaque plateforme
- **Distances multiples**: Entrées pour différentes distances (mètres ou yards)
- **Offsets**: Corrections horizontales et verticales (centimètres ou pouces)
- **Contexte**: Association avec plateforme, consommable, et accessoires
- **Visualisation**: Affichage des impacts sur cible C50 avec possibilité de zoomer
- **Conversion automatique**: Support métrique et impérial

#### Outil Millième (Millieme Tool)
- **Calculateur millième**: Conversion entre millième, distance, et taille d'objet
- **Presets rapides**: 
  - Pylône (hauteur/largeur)
  - Camion (hauteur/largeur)
  - Voiture (hauteur/largeur)
  - Humain (hauteur/tête)
  - Cible IPSC
- **Calcul inverse**: Estimation de la distance à partir d'un objet de taille connue
- **Calcul direct**: Estimation de la taille d'un objet à une distance connue

#### Diagnostic de Tir
- **Outil de dépannage**: Système interactif pour identifier les incidents de tir
- **Types d'incidents**:
  - Pas de tir
  - Tir retardé
  - Cycle
  - Problème de précision
  - Départ anormal
- **Questionnaire guidé**: Séries de questions pour affiner le diagnostic
- **Analyse probabiliste**: Calcul des causes probables avec pourcentages
- **Niveaux de risque**: Évaluation du niveau de risque (faible, moyen, élevé)
- **Recommandations**: Solutions suggérées selon le problème identifié
- **Historique**: Sauvegarde des diagnostics avec dates et résultats

### 5. Gestion de la Maintenance

#### Indicateurs Critiques (Alertes)
- **Alertes d'usure**: Notification lorsque le seuil de révision est atteint
- **Alertes de salissure**: Notification lorsque le seuil de nettoyage est atteint
- **Alertes de stock**: Notification lorsque le stock de munitions est bas
- **Alertes de documents**: Notification avant expiration des documents (1 semaine, 1 mois, 3 mois)
- **Centre de notifications**: Panneau de notification centralisé avec marquage comme lu

#### Historique de Maintenance
- **Types d'événements**: Tir, entretien, révision
- **Informations**: Date, type, label, détails
- **Suivi automatique**: Mise à jour automatique des compteurs lors des sessions

### 6. Système de Récompenses (Trophées)

#### Catégories d'Achievements
- **Sessions**: Première session, 5 sessions, 10 sessions, 25 sessions, 50 sessions, 100 sessions, 200 sessions, 1000 sessions
- **Plateformes**: Première plateforme, 3 plateformes, 5 plateformes, 10 plateformes
- **Consommables**: Première boîte, 3 références, 10 références
- **Accessoires**: Premier accessoire, 3 accessoires, 10 accessoires
- **Précision**: Première précision mesurée, 10 sessions avec précision, 50 sessions avec précision
- **Sessions parfaites**: Sans faute (100%), Zéro défaut (3x100%), Maître de précision (10x100%)
- **Entretien**: Premier entretien, 5 entretiens, 10 entretiens, 50 entretiens
- **Révision**: Première révision, 5 révisions, 10 révisions
- **Coups tirés**: 100 coups, 1 000 coups, 5 000 coups, 10 000 coups
- **Historique**: Carnet vivant (10 entrées), Historique riche (50 entrées), Mémoire d'atelier (100 entrées)
- **Écosystème**: Perfectionniste (20 sessions modifiées), Architecte de données (20 items), Écosystème complet (40 items)

#### Niveaux de Trophées
- **Bronze**: Objectifs d'initiation
- **Argent**: Objectifs intermédiaires
- **Or**: Objectifs avancés

#### Suivi des Trophées
- **Date de déblocage**: Chaque trophée est daté
- **Tri**: Par date (récent/ancien) ou par niveau
- **Progression**: Indicateur de progression pour chaque objectif

### 7. Gestion des Documents

#### Documents d'Équipement
- **Types**: Facture, Révision, Entretien, Manuel, Garantie, Autre
- **Stockage**: PDF, JPG, JPEG, PNG
- **Expiration**: Date d'expiration optionnelle
- **Notifications**: Alerte avant expiration (7 jours, 1 mois, 3 mois)
- **Actions**: Ouvrir, modifier, supprimer
- **Limites**: Version gratuite limitée à 1 document par item

#### Documents Personnels
- **Types**: Permis de chasse, Licence FFT, Carte d'identité, etc.
- **Stockage**: PDF, JPG, JPEG, PNG
- **Expiration**: Date d'expiration optionnelle
- **Notifications**: Alerte avant expiration

### 8. Export et Partage

#### Export PDF de Sessions
- **Options d'export**: Sélection des champs à inclure
- **Formatage**: Mise en page professionnelle
- **Partage**: Export et partage via l'application de partage du système

#### Export Texte de Sessions
- **Format texte**: Export en format texte simple
- **Narratif**: Génération de récit des exercices

### 9. Sécurité et Confidentialité

#### Chiffrement
- **Protection locale**: Données conservées et protégées uniquement sur l'appareil
- **Stockage sécurisé**: Utilisation de FlutterSecureStorage
- **Aucun serveur**: Toutes les données restent sur l'appareil

#### Authentification
- **Code PIN**: Code à 4 chiffres personnalisable
- **Biométrie**: Support de Face ID / Touch ID / empreinte digitale
- **Verrouillage automatique**: Verrouillage après inactivité
- **Tentatives limitées**: Blocage temporaire après trop de tentatives échouées

#### Permissions
- **Microphone**: Uniquement pour les modes de timer avec détection sonore (optionnel)
- **Stockage**: Pour sauvegarder les photos et documents
- **Biométrie**: Pour l'authentification

### 10. Personnalisation

#### Thème
- **Mode clair/sombre**: Toggle entre thème clair et sombre
- **Thème premium**: Design moderne et soigné

#### Unités
- **Métrique/Impérial**: Choix entre mètres/centimètres et yards/pouces
- **Conversion automatique**: Conversion intelligente selon le choix

#### Langue
- **5 langues**: Français, Anglais, Allemand, Italien, Espagnol
- **Changement dynamique**: Changement de langue à la volée

### 11. Fonctionnalités Premium

#### Limites de la Version Gratuite
- **Plateformes**: Maximum 1
- **Consommables**: Maximum 1
- **Accessoires**: Maximum 1
- **Sessions**: Maximum 5
- **Documents par item**: Maximum 1

#### Avantages Premium
- **Illimité**: Nombre illimité de plateformes, consommables, accessoires, sessions
- **Documents**: Documents illimités par item
- **Diagnostic**: Accès à l'outil de diagnostic complet
- **Tables de tir**: Création illimitée de tables de réglage
- **Support**: Support prioritaire

#### Abonnements
- **Mensuel**: Paiement mensuel
- **Annuel**: Paiement annuel avec économie
- **Restauration**: Restauration des achats

### 12. Interface Utilisateur

#### Design
- **Moderne et premium**: Interface soignée avec attention aux détails
- **Graph-first**: Visualisation des données avec graphiques
- **Intuitive**: Navigation simple et logique
- **Responsive**: Adaptée à tous les tailles d'écran

#### Navigation
- **Barre de navigation**: Navigation en bas avec icônes SVG
- **Accès rapide**: Raccourcis vers les fonctionnalités les plus utilisées
- **Recherche**: Recherche dans les sessions et l'inventaire
- **Filtres**: Filtres temporels et thématiques

#### Composants
- **Cartes KPI**: Affichage clair des indicateurs clés
- **Graphiques**: Graphiques interactifs avec fl_chart
- **Modals**: Bottom sheets pour les actions secondaires
- **Alertes**: Notifications contextuelles

### 13. Synchronisation et Sauvegarde

#### Sauvegarde Locale
- **Automatique**: Sauvegarde automatique après chaque modification
- **Chiffrée**: Toutes les données chiffrées
- **Restauration**: Restauration automatique au démarrage

#### Export/Import
- **Export JSON**: Export complet des données pour sauvegarde externe
- **Import JSON**: Restauration depuis un fichier de sauvegarde

### 14. Performance et Fiabilité

#### Performance
- **Rapide**: Démarrage rapide et navigation fluide
- **Optimisé**: Optimisation pour les grandes quantités de données
- **Mémoire**: Gestion efficace de la mémoire

#### Fiabilité
- **Testé**: Testé sur iOS, Android, et Web
- **Stable**: Gestion robuste des erreurs
- **Récupération**: Récupération automatique en cas de crash

## Cas d'Utilisation

### Pour le Tireur Sportif
- Suivre sa progression en précision
- Analyser ses performances par plateforme et par consommable
- Planifier ses entraînements avec le timer
- Créer des tables de réglage pour chaque combinaison

### Pour le Propriétaire d'Armes
- Gérer son inventaire d'armes et de munitions
- Suivre l'entretien de ses plateformes
- Être alerté des stocks bas de munitions
- Conserver tous les documents importants

### Pour l'Entraîneur
- Suivre la progression de ses élèves
- Créer des modèles d'exercices types
- Analyser les statistiques de groupe
- Partager les sessions via export PDF

### Pour le Professionnel
- Documentation complète de l'utilisation du matériel
- Suivi de l'usure pour la maintenance préventive
- Rapports d'activité détaillés
- Gestion des documents réglementaires

## Technologies Utilisées

### Framework
- **Flutter**: Framework multiplateforme
- **Dart**: Langage de programmation

### Dépendances Principales
- **provider**: Gestion d'état
- **go_router**: Navigation
- **fl_chart**: Graphiques
- **flutter_secure_storage**: Stockage sécurisé
- **local_auth**: Authentification biométrique
- **shared_preferences**: Préférences
- **file_picker**: Sélection de fichiers
- **share_plus**: Partage
- **noise_meter**: Détection sonore pour le timer
- **vibration**: Feedback haptique
- **flutter_svg**: Support des SVG
- **gap**: Espacement
- **purchases_ui_flutter**: Interface d'abonnement

### Sécurité
- **Protection locale**: Données 100% hors ligne, protégées sur l'appareil
- **FlutterSecureStorage**: Stockage sécurisé du PIN
- **LocalAuthentication**: Authentification biométrique

## Conclusion

THOT est une application complète et professionnelle pour la gestion du tir sportif et de l'entretien des armes à feu. Elle combine fonctionnalités de gestion d'inventaire, suivi d'entraînement, outils de tir, et statistiques avancées dans une interface moderne et sécurisée. Son fonctionnement 100% hors-ligne et sa protection locale avec code PIN/biométrie garantissent une confidentialité totale des données de l'utilisateur.
