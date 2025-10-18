import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/core/constants.dart';

const String _gitCommit =
    String.fromEnvironment('GIT_COMMIT', defaultValue: 'non défini');
const String _buildEnvironment =
    String.fromEnvironment('APP_ENV', defaultValue: 'local');

class SettingsAboutScreen extends StatefulWidget {
  const SettingsAboutScreen({super.key});

  @override
  State<SettingsAboutScreen> createState() => _SettingsAboutScreenState();
}

class _SettingsAboutScreenState extends State<SettingsAboutScreen> {
  String _version = 'Chargement...';
  String _packageName = '—';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) {
      return;
    }
    setState(() {
      _version = '${info.version}+${info.buildNumber}';
      _packageName = info.packageName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version $_version',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text('Package : $_packageName'),
                  const SizedBox(height: 4),
                  Text('Commit Git : ${_gitCommit.substring(0, _gitCommit.length > 8 ? 8 : _gitCommit.length)}'),
                  const SizedBox(height: 4),
                  Text('Environnement : $_buildEnvironment'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: const Text('Conditions générales d’utilisation'),
                  subtitle: const Text('khodan.app/cgu'),
                  trailing: const Icon(Icons.open_in_new_outlined),
                  onTap: () => _launch(
                    Uri.parse('https://khodan.app/cgu'),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.shield_moon_outlined),
                  title: const Text('Politique de confidentialité'),
                  subtitle: const Text('khodan.app/confidentialite'),
                  trailing: const Icon(Icons.open_in_new_outlined),
                  onTap: () => _launch(
                    Uri.parse('https://khodan.app/confidentialite'),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Licences Open Source'),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: AppConstants.appName,
                      applicationVersion: _version,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contact'),
                  subtitle: Text(AppConstants.supportEmail),
                  trailing: const Icon(Icons.open_in_new_outlined),
                  onTap: () => _launch(
                    Uri.parse('mailto:${AppConstants.supportEmail}'),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.public_outlined),
                  title: const Text('Site web'),
                  subtitle: const Text('khodan.app'),
                  trailing: const Icon(Icons.open_in_new_outlined),
                  onTap: () => _launch(Uri.parse('https://khodan.app')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’ouvrir ${uri.toString()}'),
        ),
      );
    }
  }
}
