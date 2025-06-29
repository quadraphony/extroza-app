import 'package:extroza/features/settings/screens/privacy_policy_screen.dart';
import 'package:extroza/features/settings/screens/terms_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Extroza'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // App Logo
              Icon(
                Icons.chat_bubble_rounded,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              // App Name
              Text(
                'Extroza',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              // Links Section
              ListTile(
                title: const Text('Terms of Service'),
                leading: const Icon(Icons.description_outlined),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsScreen())),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                leading: const Icon(Icons.shield_outlined),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
              ),
              ListTile(
                title: const Text('Open Source Licenses'),
                leading: const Icon(Icons.code_rounded),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Extroza',
                  applicationVersion: _version,
                ),
              ),
              const Spacer(flex: 3),
              // Footer
              Text(
                '© $year Extroza',
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Version $_version',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
