// Generated localization file. Do not modify by hand.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Khodan'**
  String get appTitle;

  /// No description provided for @navDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get navDashboard;

  /// No description provided for @navAnimals.
  ///
  /// In fr, this message translates to:
  /// **'Éleveurs'**
  String get navAnimals;

  /// No description provided for @navEvents.
  ///
  /// In fr, this message translates to:
  /// **'Portées & cages'**
  String get navEvents;

  /// No description provided for @navReports.
  ///
  /// In fr, this message translates to:
  /// **'Rapports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navPlanning.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get navPlanning;

  /// No description provided for @navPlanningDescription.
  ///
  /// In fr, this message translates to:
  /// **'Planifie les tâches d\'élevage et visualise le calendrier.'**
  String get navPlanningDescription;

  /// No description provided for @navNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navNotificationsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Suis les alertes critiques et rappels importants.'**
  String get navNotificationsDescription;

  /// No description provided for @navHelpCenter.
  ///
  /// In fr, this message translates to:
  /// **'Centre d\'aide'**
  String get navHelpCenter;

  /// No description provided for @navHelpCenterDescription.
  ///
  /// In fr, this message translates to:
  /// **'Accède aux guides et articles de support.'**
  String get navHelpCenterDescription;

  /// No description provided for @navMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get navMore;

  /// No description provided for @placeholderPlanningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning en préparation'**
  String get placeholderPlanningTitle;

  /// No description provided for @placeholderPlanningMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le module Planning sera bientôt disponible. Vous y retrouverez l\'agenda des tâches et rappels.'**
  String get placeholderPlanningMessage;

  /// No description provided for @placeholderNotificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications en préparation'**
  String get placeholderNotificationsTitle;

  /// No description provided for @placeholderNotificationsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les alertes et rappels seront affichées ici dès l\'activation du module.'**
  String get placeholderNotificationsMessage;

  /// No description provided for @placeholderFabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Action rapide'**
  String get placeholderFabLabel;

  /// No description provided for @placeholderFabMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action sera disponible dès que la fonctionnalité sera prête.'**
  String get placeholderFabMessage;

  /// No description provided for @settingsSupportSection.
  ///
  /// In fr, this message translates to:
  /// **'Support et diagnostics'**
  String get settingsSupportSection;

  /// No description provided for @settingsKnowledgeBase.
  ///
  /// In fr, this message translates to:
  /// **'Base de connaissances'**
  String get settingsKnowledgeBase;

  /// No description provided for @settingsContactSupport.
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support'**
  String get settingsContactSupport;

  /// No description provided for @settingsLogs.
  ///
  /// In fr, this message translates to:
  /// **'Journaux et diagnostics'**
  String get settingsLogs;

  /// No description provided for @settingsOfflineSection.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors connexion'**
  String get settingsOfflineSection;

  /// No description provided for @settingsOfflineToggle.
  ///
  /// In fr, this message translates to:
  /// **'Activer le mode hors connexion'**
  String get settingsOfflineToggle;

  /// No description provided for @settingsSupportDescription.
  ///
  /// In fr, this message translates to:
  /// **'Retrouvez nos guides, contactez l\'équipe et exportez les journaux.'**
  String get settingsSupportDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsOfflineSummaryPending.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en attente : {count} action(s).'**
  String settingsOfflineSummaryPending(int count);

  /// No description provided for @settingsOfflineSummaryReady.
  ///
  /// In fr, this message translates to:
  /// **'Synchronise automatiquement dès le retour du réseau.'**
  String get settingsOfflineSummaryReady;

  /// No description provided for @settingsOfflineQueueTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions en file d\'attente'**
  String get settingsOfflineQueueTitle;

  /// No description provided for @settingsOfflineQueueSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos modifications seront envoyées dès que la connexion sera disponible.'**
  String get settingsOfflineQueueSubtitle;

  /// No description provided for @settingsOfflineQueueButton.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser'**
  String get settingsOfflineQueueButton;

  /// No description provided for @settingsOfflineStatusOffline.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors-ligne actif'**
  String get settingsOfflineStatusOffline;

  /// No description provided for @settingsOfflineStatusOnline.
  ///
  /// In fr, this message translates to:
  /// **'Mode en ligne'**
  String get settingsOfflineStatusOnline;

  /// No description provided for @settingsOfflineStatusOfflineDetails.
  ///
  /// In fr, this message translates to:
  /// **'Les actions sont enregistrées en local jusqu\'à la reconnexion.'**
  String get settingsOfflineStatusOfflineDetails;

  /// No description provided for @settingsOfflineStatusOnlineDetails.
  ///
  /// In fr, this message translates to:
  /// **'Les données sont synchronisées en temps réel.'**
  String get settingsOfflineStatusOnlineDetails;

  /// No description provided for @settingsProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil de l\'élevage'**
  String get settingsProfileTitle;

  /// No description provided for @settingsProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour les coordonnées et préférences légales.'**
  String get settingsProfileSubtitle;

  /// No description provided for @settingsSpeciesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des espèces'**
  String get settingsSpeciesTitle;

  /// No description provided for @settingsSpeciesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Configurer les durées de gestation et sevrage.'**
  String get settingsSpeciesSubtitle;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Version, licences et mentions légales.'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get settingsSignOut;

  /// No description provided for @knowledgeBaseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Base de connaissances'**
  String get knowledgeBaseTitle;

  /// No description provided for @knowledgeBaseRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Rafraîchir'**
  String get knowledgeBaseRefresh;

  /// No description provided for @knowledgeBaseSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher dans les guides, FAQ, mots-clés…'**
  String get knowledgeBaseSearchHint;

  /// No description provided for @knowledgeBaseOfflineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors-ligne actif : les articles affichés proviennent du cache local.'**
  String get knowledgeBaseOfflineBanner;

  /// No description provided for @knowledgeBaseLastUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : {date}'**
  String knowledgeBaseLastUpdate(Object date);

  /// No description provided for @knowledgeBaseUpdatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Mis à jour {date}'**
  String knowledgeBaseUpdatedAt(Object date);

  /// No description provided for @knowledgeBaseEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun article ne correspond à votre recherche.'**
  String get knowledgeBaseEmpty;

  /// No description provided for @knowledgeBaseRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get knowledgeBaseRetry;

  /// No description provided for @knowledgeBaseLastSync.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation : {date}'**
  String knowledgeBaseLastSync(Object date);

  /// No description provided for @knowledgeBaseEmptyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Nous n’avons trouvé aucun article pour votre recherche.\nEssayez avec d’autres mots-clés ou contactez le support.'**
  String get knowledgeBaseEmptyHelp;

  /// No description provided for @knowledgeBaseCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {Aucun article trouvé} one {1 article} other {{count} articles}}'**
  String knowledgeBaseCount(int count);

  /// No description provided for @commonClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get commonClear;

  /// No description provided for @logsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journaux et diagnostics'**
  String get logsTitle;

  /// No description provided for @logsRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser le diagnostic'**
  String get logsRefresh;

  /// No description provided for @logsOfflineToggle.
  ///
  /// In fr, this message translates to:
  /// **'Journalisation détaillée'**
  String get logsOfflineToggle;

  /// No description provided for @logsExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter'**
  String get logsExport;

  /// No description provided for @logsShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get logsShare;

  /// No description provided for @logsClear.
  ///
  /// In fr, this message translates to:
  /// **'Vider l\'historique'**
  String get logsClear;

  /// No description provided for @logsShareError.
  ///
  /// In fr, this message translates to:
  /// **'Partage impossible : {error}'**
  String logsShareError(Object error);

  /// No description provided for @logsShareUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Le partage de fichier n\'est pas disponible sur le web.'**
  String get logsShareUnavailable;

  /// No description provided for @logsFileGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Fichier de logs généré.'**
  String get logsFileGenerated;

  /// No description provided for @logsHistoryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun journal à afficher.'**
  String get logsHistoryEmpty;

  /// No description provided for @logsHistoryDescription.
  ///
  /// In fr, this message translates to:
  /// **'Les actions de synchronisation et erreurs seront listées ici.'**
  String get logsHistoryDescription;

  /// No description provided for @logsLoadingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Collecte des informations système…'**
  String get logsLoadingTitle;

  /// No description provided for @logsLoadingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter quelques secondes.'**
  String get logsLoadingSubtitle;

  /// No description provided for @logsDeviceInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appareil et environnement'**
  String get logsDeviceInfoTitle;

  /// No description provided for @logsDevicePlatform.
  ///
  /// In fr, this message translates to:
  /// **'Plateforme'**
  String get logsDevicePlatform;

  /// No description provided for @logsDeviceVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version app'**
  String get logsDeviceVersion;

  /// No description provided for @logsDeviceLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get logsDeviceLanguage;

  /// No description provided for @logsDeviceOffline.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors-ligne'**
  String get logsDeviceOffline;

  /// No description provided for @logsDeviceOfflineActive.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get logsDeviceOfflineActive;

  /// No description provided for @logsDeviceOfflineInactive.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get logsDeviceOfflineInactive;

  /// No description provided for @logsDevicePendingActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions en attente'**
  String get logsDevicePendingActions;

  /// No description provided for @logsDeviceRefreshedAt.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mise à jour : {date}'**
  String logsDeviceRefreshedAt(Object date);

  /// No description provided for @logsOfflineToggleHint.
  ///
  /// In fr, this message translates to:
  /// **'Collecte les logs détaillés (peut inclure des données sensibles).'**
  String get logsOfflineToggleHint;

  /// No description provided for @logsHistoryCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0 {Historique} one {Historique (1)} other {Historique ({count})}}'**
  String logsHistoryCount(int count);

  /// No description provided for @logsEntryMetadata.
  ///
  /// In fr, this message translates to:
  /// **'{source} – {timestamp}'**
  String logsEntryMetadata(Object source, Object timestamp);

  /// No description provided for @logsShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Journaux Khodan'**
  String get logsShareSubject;

  /// No description provided for @logsShareText.
  ///
  /// In fr, this message translates to:
  /// **'Logs de diagnostic Khodan générés le {date}.'**
  String logsShareText(Object date);

  /// No description provided for @contactSupportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacter le support'**
  String get contactSupportTitle;

  /// No description provided for @contactSupportSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer au support'**
  String get contactSupportSubmit;

  /// No description provided for @contactSupportSubjectLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sujet'**
  String get contactSupportSubjectLabel;

  /// No description provided for @contactSupportMessageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get contactSupportMessageLabel;

  /// No description provided for @contactSupportPriorityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Priorité'**
  String get contactSupportPriorityLabel;

  /// No description provided for @contactSupportOfflineNotice.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors connexion'**
  String get contactSupportOfflineNotice;

  /// No description provided for @contactSupportOfflineDetails.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande sera envoyée dès que la connexion sera rétablie.'**
  String get contactSupportOfflineDetails;

  /// No description provided for @contactSupportMissingSession.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez être connecté pour contacter le support.'**
  String get contactSupportMissingSession;

  /// No description provided for @contactSupportSubjectValidation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez préciser le sujet.'**
  String get contactSupportSubjectValidation;

  /// No description provided for @contactSupportPriorityNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normale'**
  String get contactSupportPriorityNormal;

  /// No description provided for @contactSupportPriorityUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgente'**
  String get contactSupportPriorityUrgent;

  /// No description provided for @contactSupportMessageHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre question ou le problème rencontré en fournissant le plus de détails possible.'**
  String get contactSupportMessageHint;

  /// No description provided for @contactSupportMessageValidation.
  ///
  /// In fr, this message translates to:
  /// **'Merci de détailler votre demande (au moins 10 caractères).'**
  String get contactSupportMessageValidation;

  /// No description provided for @contactSupportSubmitting.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get contactSupportSubmitting;

  /// No description provided for @contactSupportRecentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Derniers tickets'**
  String get contactSupportRecentTitle;

  /// No description provided for @planningTitle.
  ///
  /// In fr, this message translates to:
  /// **'Planning'**
  String get planningTitle;

  /// No description provided for @planningSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher taches, animaux, notes...'**
  String get planningSearchHint;

  /// No description provided for @planningTabList.
  ///
  /// In fr, this message translates to:
  /// **'Liste'**
  String get planningTabList;

  /// No description provided for @planningTabCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get planningTabCalendar;

  /// No description provided for @planningTabChain.
  ///
  /// In fr, this message translates to:
  /// **'Chaine'**
  String get planningTabChain;

  /// No description provided for @planningFilterStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get planningFilterStatus;

  /// No description provided for @planningFilterPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Periode'**
  String get planningFilterPeriod;

  /// No description provided for @planningFilterType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get planningFilterType;

  /// No description provided for @planningFilterReset.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser'**
  String get planningFilterReset;

  /// No description provided for @planningStatusPlanned.
  ///
  /// In fr, this message translates to:
  /// **'A faire'**
  String get planningStatusPlanned;

  /// No description provided for @planningStatusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminees'**
  String get planningStatusCompleted;

  /// No description provided for @planningStatusOverdue.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get planningStatusOverdue;

  /// No description provided for @planningStatusSkipped.
  ///
  /// In fr, this message translates to:
  /// **'Ignorees'**
  String get planningStatusSkipped;

  /// No description provided for @planningPeriodAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get planningPeriodAll;

  /// No description provided for @planningPeriodToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get planningPeriodToday;

  /// No description provided for @planningPeriodWeek.
  ///
  /// In fr, this message translates to:
  /// **'7 jours'**
  String get planningPeriodWeek;

  /// No description provided for @planningPeriodMonth.
  ///
  /// In fr, this message translates to:
  /// **'30 jours'**
  String get planningPeriodMonth;

  /// No description provided for @planningEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tache ne correspond aux filtres.'**
  String get planningEmpty;

  /// No description provided for @planningOfflinePending.
  ///
  /// In fr, this message translates to:
  /// **'{count} action(s) hors ligne en attente'**
  String planningOfflinePending(int count);

  /// No description provided for @planningOfflineViewQueue.
  ///
  /// In fr, this message translates to:
  /// **'Voir la file'**
  String get planningOfflineViewQueue;

  /// No description provided for @planningMarkDone.
  ///
  /// In fr, this message translates to:
  /// **'Marquer fait'**
  String get planningMarkDone;

  /// No description provided for @planningReschedule.
  ///
  /// In fr, this message translates to:
  /// **'Reprogrammer'**
  String get planningReschedule;

  /// No description provided for @planningDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get planningDelete;

  /// No description provided for @planningExportCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter CSV'**
  String get planningExportCsv;

  /// No description provided for @planningExportIcalDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Export iCal (bientot)'**
  String get planningExportIcalDisabled;

  /// No description provided for @planningCalendarMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get planningCalendarMonth;

  /// No description provided for @planningCalendarWeek.
  ///
  /// In fr, this message translates to:
  /// **'Semaine'**
  String get planningCalendarWeek;

  /// No description provided for @planningChainSection.
  ///
  /// In fr, this message translates to:
  /// **'Chaines de reproduction'**
  String get planningChainSection;

  /// No description provided for @planningChainEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune chaine de reproduction a afficher.'**
  String get planningChainEmpty;

  /// No description provided for @planningSelectionCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} selectionnee(s)'**
  String planningSelectionCount(int count);

  /// No description provided for @planningBulkComplete.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la selection'**
  String get planningBulkComplete;

  /// No description provided for @planningBulkExport.
  ///
  /// In fr, this message translates to:
  /// **'Exporter la selection'**
  String get planningBulkExport;

  /// No description provided for @planningCsvExported.
  ///
  /// In fr, this message translates to:
  /// **'CSV genere'**
  String get planningCsvExported;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
