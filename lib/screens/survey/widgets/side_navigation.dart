import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/font_size_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../services/database_service.dart';

class SideNavigation extends ConsumerWidget {
  const SideNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green, Color(0xFF66BB6A)],
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.familySurvey,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    l10n.deendayalResearchInstitute,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: l10n.profile,
                    onTap: () => _showProfileDialog(context, l10n),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.history,
                    title: 'History',
                    onTap: () => _showHistoryDialog(context, l10n),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.language,
                    title: l10n.selectLanguage,
                    onTap: () => _showLanguageDialog(context, l10n, ref),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.settings,
                    title: l10n.settings,
                    onTap: () => _showSettingsDialog(context, l10n, ref),
                  ),

                  const Divider(),

                  _buildMenuItem(
                    context,
                    icon: Icons.help,
                    title: l10n.helpAndSupport,
                    onTap: () => _showHelpDialog(context, l10n),
                  ),

                  _buildMenuItem(
                    context,
                    icon: Icons.info,
                    title: l10n.about,
                    onTap: () => _showAboutDialog(context, l10n),
                  ),

                  const Divider(),

                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: l10n.logout,
                    onTap: () => _showLogoutDialog(context, l10n),
                    color: Colors.red,
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.version,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Colors.green,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.surveyUser,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.phoneNumberDisplay,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileManagementMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    String? selectedLanguage = ref.watch(localeProvider).languageCode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: 'en',
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() => selectedLanguage = value);
                    },
                    activeColor: Colors.green,
                  ),
                  const Text('English'),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'hi',
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() => selectedLanguage = value);
                    },
                    activeColor: Colors.green,
                  ),
                  const Text('हिंदी'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                if (selectedLanguage != null) {
                  await localeNotifier.setLocale(Locale(selectedLanguage!));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(selectedLanguage == 'en' ? l10n.languageChangedToEnglish : l10n.languageChangedToHindi)),
                  );
                }
              },
              child: Text(l10n.apply),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final fontSizeNotifier = ref.read(fontSizeProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final currentFontSize = ref.watch(fontSizeProvider);
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.settings, color: Colors.green),
                const SizedBox(width: 8),
                Text(l10n.settings),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Font Size Section - Reorganized for APK interface
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.text_fields, color: Colors.blue, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                l10n.fontSize,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Current size display
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Current: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(currentFontSize * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Slider with better touch targets for APK
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                              ),
                              child: Slider(
                                value: currentFontSize,
                                min: 0.5,
                                max: 1.5,
                                divisions: 10,
                                label: '${(currentFontSize * 100).round()}%',
                                activeColor: Colors.blue,
                                inactiveColor: Colors.blue[200],
                                onChanged: (value) {
                                  fontSizeNotifier.setFontSize(value);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Preset buttons - larger for APK touch interface
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    fontSizeNotifier.setFontSize(0.7); // Small
                                  },
                                  icon: const Icon(Icons.text_decrease, size: 20),
                                  label: const Text(
                                    'Small',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentFontSize == 0.7 ? Colors.blue : Colors.grey[300],
                                    foregroundColor: currentFontSize == 0.7 ? Colors.white : Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    fontSizeNotifier.resetToDefault();
                                  },
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text(
                                    'Default',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentFontSize == 0.7 ? Colors.green : Colors.grey[300],
                                    foregroundColor: currentFontSize == 0.7 ? Colors.white : Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    fontSizeNotifier.setFontSize(1.0); // Large
                                  },
                                  icon: const Icon(Icons.text_increase, size: 20),
                                  label: const Text(
                                    'Large',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentFontSize == 1.0 ? Colors.blue : Colors.grey[300],
                                    foregroundColor: currentFontSize == 1.0 ? Colors.white : Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Extra large option
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                fontSizeNotifier.setFontSize(1.3); // Extra Large
                              },
                              icon: const Icon(Icons.text_increase, size: 20),
                              label: const Text(
                                'Extra Large',
                                style: TextStyle(fontSize: 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentFontSize == 1.3 ? Colors.blue : Colors.grey[300],
                                foregroundColor: currentFontSize == 1.3 ? Colors.white : Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Other Settings - Simplified for APK
                  Card(
                    elevation: 2,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.orange),
                          title: Text(
                            l10n.notifications,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          trailing: Switch(
                            value: true,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              // TODO: Implement notification settings
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.dark_mode, color: Colors.purple),
                          title: Text(
                            l10n.darkMode,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          trailing: Switch(
                            value: false,
                            activeColor: Colors.green,
                            onChanged: (value) {
                              // TODO: Implement dark mode
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.storage, color: Colors.teal),
                          title: Text(
                            l10n.dataManagement,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text(
                            'Manage local survey data',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () {
                            // TODO: Implement data management
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.close,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.helpAndSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(l10n.userGuide),
              onTap: () {
                // TODO: Open user guide
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_support),
              title: Text(l10n.contactSupport),
              onTap: () {
                // TODO: Contact support
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n.reportIssue),
              onTap: () {
                // TODO: Report issue
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: Icon(
                Icons.family_restroom,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.familySurveyApp,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.version,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.appDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.developedBy,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Survey History'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService().getAllSurveySessions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final sessions = snapshot.data ?? [];
              if (sessions.isEmpty) {
                return const Text('No survey history found.');
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return ListTile(
                    title: Text(session['village_name'] ?? 'Unknown Village'),
                    subtitle: Text(
                      'Date: ${session['survey_date'] ?? 'N/A'}\nStatus: ${session['status'] ?? 'Unknown'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to final page (preview) with this session data
                      _navigateToSurveyPreview(context, session['session_id']);
                    },
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirm),
        content: Text(l10n.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushReplacementNamed(context, '/'); // Go to landing
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  void _navigateToSurveyPreview(BuildContext context, String sessionId) {
    // Navigate to survey screen and load the specific session for preview
    Navigator.pushNamed(
      context,
      '/survey',
      arguments: {'previewSessionId': sessionId},
    );
  }
}
