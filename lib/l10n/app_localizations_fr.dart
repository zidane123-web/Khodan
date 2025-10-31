// Generated localization file. Do not modify by hand.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Khodan';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navAnimals => 'Éleveurs';

  @override
  String get navEvents => 'Portées & cages';

  @override
  String get navReports => 'Rapports';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navPlanning => 'Planning';

  @override
  String get navPlanningDescription =>
      'Planifie les tâches d\'élevage et visualise le calendrier.';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navNotificationsDescription =>
      'Suis les alertes critiques et rappels importants.';

  @override
  String get navHelpCenter => 'Centre d\'aide';

  @override
  String get navHelpCenterDescription =>
      'Accède aux guides et articles de support.';

  @override
  String get navMore => 'Plus';

  @override
  String get placeholderPlanningTitle => 'Planning en préparation';

  @override
  String get placeholderPlanningMessage =>
      'Le module Planning sera bientôt disponible. Vous y retrouverez l\'agenda des tâches et rappels.';

  @override
  String get placeholderNotificationsTitle => 'Notifications en préparation';

  @override
  String get placeholderNotificationsMessage =>
      'Les alertes et rappels seront affichées ici dès l\'activation du module.';

  @override
  String get placeholderFabLabel => 'Action rapide';

  @override
  String get placeholderFabMessage =>
      'Cette action sera disponible dès que la fonctionnalité sera prête.';

  @override
  String get settingsSupportSection => 'Support et diagnostics';

  @override
  String get settingsKnowledgeBase => 'Base de connaissances';

  @override
  String get settingsContactSupport => 'Contacter le support';

  @override
  String get settingsLogs => 'Journaux et diagnostics';

  @override
  String get settingsOfflineSection => 'Mode hors connexion';

  @override
  String get settingsOfflineToggle => 'Activer le mode hors connexion';

  @override
  String get settingsSupportDescription =>
      'Retrouvez nos guides, contactez l\'équipe et exportez les journaux.';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String settingsOfflineSummaryPending(int count) {
    return 'Synchronisation en attente : $count action(s).';
  }

  @override
  String get settingsOfflineSummaryReady =>
      'Synchronise automatiquement dès le retour du réseau.';

  @override
  String get settingsOfflineQueueTitle => 'Actions en file d\'attente';

  @override
  String get settingsOfflineQueueSubtitle =>
      'Vos modifications seront envoyées dès que la connexion sera disponible.';

  @override
  String get settingsOfflineQueueButton => 'Synchroniser';

  @override
  String get settingsOfflineStatusOffline => 'Mode hors-ligne actif';

  @override
  String get settingsOfflineStatusOnline => 'Mode en ligne';

  @override
  String get settingsOfflineStatusOfflineDetails =>
      'Les actions sont enregistrées en local jusqu\'à la reconnexion.';

  @override
  String get settingsOfflineStatusOnlineDetails =>
      'Les données sont synchronisées en temps réel.';

  @override
  String get settingsProfileTitle => 'Profil de l\'élevage';

  @override
  String get settingsProfileSubtitle =>
      'Mettre à jour les coordonnées et préférences légales.';

  @override
  String get settingsSpeciesTitle => 'Gestion des espèces';

  @override
  String get settingsSpeciesSubtitle =>
      'Configurer les durées de gestation et sevrage.';

  @override
  String get settingsAboutTitle => 'À propos';

  @override
  String get settingsAboutSubtitle => 'Version, licences et mentions légales.';

  @override
  String get settingsSignOut => 'Déconnexion';

  @override
  String get knowledgeBaseTitle => 'Base de connaissances';

  @override
  String get knowledgeBaseRefresh => 'Rafraîchir';

  @override
  String get knowledgeBaseSearchHint =>
      'Rechercher dans les guides, FAQ, mots-clés…';

  @override
  String get knowledgeBaseOfflineBanner =>
      'Mode hors-ligne actif : les articles affichés proviennent du cache local.';

  @override
  String knowledgeBaseLastUpdate(Object date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String knowledgeBaseUpdatedAt(Object date) {
    return 'Mis à jour $date';
  }

  @override
  String get knowledgeBaseEmpty =>
      'Aucun article ne correspond à votre recherche.';

  @override
  String get knowledgeBaseRetry => 'Réessayer';

  @override
  String knowledgeBaseLastSync(Object date) {
    return 'Dernière synchronisation : $date';
  }

  @override
  String get knowledgeBaseEmptyHelp =>
      'Nous n’avons trouvé aucun article pour votre recherche.\nEssayez avec d’autres mots-clés ou contactez le support.';

  @override
  String knowledgeBaseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article trouvé',
    );
    return '$_temp0';
  }

  @override
  String get commonClear => 'Effacer';

  @override
  String get logsTitle => 'Journaux et diagnostics';

  @override
  String get logsRefresh => 'Actualiser le diagnostic';

  @override
  String get logsOfflineToggle => 'Journalisation détaillée';

  @override
  String get logsExport => 'Exporter';

  @override
  String get logsShare => 'Partager';

  @override
  String get logsClear => 'Vider l\'historique';

  @override
  String logsShareError(Object error) {
    return 'Partage impossible : $error';
  }

  @override
  String get logsShareUnavailable =>
      'Le partage de fichier n\'est pas disponible sur le web.';

  @override
  String get logsFileGenerated => 'Fichier de logs généré.';

  @override
  String get logsHistoryEmpty => 'Aucun journal à afficher.';

  @override
  String get logsHistoryDescription =>
      'Les actions de synchronisation et erreurs seront listées ici.';

  @override
  String get logsLoadingTitle => 'Collecte des informations système…';

  @override
  String get logsLoadingSubtitle => 'Veuillez patienter quelques secondes.';

  @override
  String get logsDeviceInfoTitle => 'Appareil et environnement';

  @override
  String get logsDevicePlatform => 'Plateforme';

  @override
  String get logsDeviceVersion => 'Version app';

  @override
  String get logsDeviceLanguage => 'Langue';

  @override
  String get logsDeviceOffline => 'Mode hors-ligne';

  @override
  String get logsDeviceOfflineActive => 'Activé';

  @override
  String get logsDeviceOfflineInactive => 'Désactivé';

  @override
  String get logsDevicePendingActions => 'Actions en attente';

  @override
  String logsDeviceRefreshedAt(Object date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get logsOfflineToggleHint =>
      'Collecte les logs détaillés (peut inclure des données sensibles).';

  @override
  String logsHistoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Historique ($count)',
      one: 'Historique (1)',
      zero: 'Historique',
    );
    return '$_temp0';
  }

  @override
  String logsEntryMetadata(Object source, Object timestamp) {
    return '$source – $timestamp';
  }

  @override
  String get logsShareSubject => 'Journaux Khodan';

  @override
  String logsShareText(Object date) {
    return 'Logs de diagnostic Khodan générés le $date.';
  }

  @override
  String get contactSupportTitle => 'Contacter le support';

  @override
  String get contactSupportSubmit => 'Envoyer au support';

  @override
  String get contactSupportSubjectLabel => 'Sujet';

  @override
  String get contactSupportMessageLabel => 'Message';

  @override
  String get contactSupportPriorityLabel => 'Priorité';

  @override
  String get contactSupportOfflineNotice => 'Mode hors connexion';

  @override
  String get contactSupportOfflineDetails =>
      'Votre demande sera envoyée dès que la connexion sera rétablie.';

  @override
  String get contactSupportMissingSession =>
      'Vous devez être connecté pour contacter le support.';

  @override
  String get contactSupportSubjectValidation => 'Veuillez préciser le sujet.';

  @override
  String get contactSupportPriorityNormal => 'Normale';

  @override
  String get contactSupportPriorityUrgent => 'Urgente';

  @override
  String get contactSupportMessageHint =>
      'Décrivez votre question ou le problème rencontré en fournissant le plus de détails possible.';

  @override
  String get contactSupportMessageValidation =>
      'Merci de détailler votre demande (au moins 10 caractères).';

  @override
  String get contactSupportSubmitting => 'Envoi en cours…';

  @override
  String get contactSupportRecentTitle => 'Derniers tickets';

  @override
  String get planningTitle => 'Planning';

  @override
  String get planningSearchHint => 'Rechercher taches, animaux, notes...';

  @override
  String get planningTabList => 'Liste';

  @override
  String get planningTabCalendar => 'Calendrier';

  @override
  String get planningTabChain => 'Chaine';

  @override
  String get planningFilterStatus => 'Statut';

  @override
  String get planningFilterPeriod => 'Periode';

  @override
  String get planningFilterType => 'Type';

  @override
  String get planningFilterReset => 'Reinitialiser';

  @override
  String get planningStatusPlanned => 'A faire';

  @override
  String get planningStatusCompleted => 'Terminees';

  @override
  String get planningStatusOverdue => 'En retard';

  @override
  String get planningStatusSkipped => 'Ignorees';

  @override
  String get planningPeriodAll => 'Toutes';

  @override
  String get planningPeriodToday => 'Aujourd\'hui';

  @override
  String get planningPeriodWeek => '7 jours';

  @override
  String get planningPeriodMonth => '30 jours';

  @override
  String get planningEmpty => 'Aucune tache ne correspond aux filtres.';

  @override
  String planningOfflinePending(int count) {
    return '$count action(s) hors ligne en attente';
  }

  @override
  String get planningOfflineViewQueue => 'Voir la file';

  @override
  String get planningMarkDone => 'Marquer fait';

  @override
  String get planningReschedule => 'Reprogrammer';

  @override
  String get planningDelete => 'Supprimer';

  @override
  String get planningExportCsv => 'Exporter CSV';

  @override
  String get planningExportIcalDisabled => 'Export iCal (bientot)';

  @override
  String get planningCalendarMonth => 'Mois';

  @override
  String get planningCalendarWeek => 'Semaine';

  @override
  String get planningChainSection => 'Chaines de reproduction';

  @override
  String get planningChainEmpty => 'Aucune chaine de reproduction a afficher.';

  @override
  String planningSelectionCount(int count) {
    return '$count selectionnee(s)';
  }

  @override
  String get planningBulkComplete => 'Terminer la selection';

  @override
  String get planningBulkExport => 'Exporter la selection';

  @override
  String get planningCsvExported => 'CSV genere';
}
