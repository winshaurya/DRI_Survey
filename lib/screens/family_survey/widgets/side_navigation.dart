import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/font_size_provider.dart';
import '../../../providers/locale_provider.dart';
import '../../../services/database_service.dart';
import '../../../services/supabase_service.dart';

class SideNavigation extends ConsumerWidget {
  const SideNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    User? user;
    try {
      user = SupabaseService.instance.currentUser;
    } catch (_) {
      // Supabase not initialized
      user = null;
    }

    final userEmail = user?.email ?? 'User';
    final isLoggedIn = user != null;

    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header - Compact and clean
              InkWell(
                onTap: isLoggedIn ? () => _navigateHome(context) : () => _showLoginPrompt(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green, Color(0xFF66BB6A)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: isLoggedIn
                            ? Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.green,
                                ),
                              )
                            : const Icon(
                                Icons.login,
                                color: Colors.green,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLoggedIn ? userEmail : 'Login Required',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isLoggedIn ? 'DRI Survey' : 'Tap to login',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Items - Simple and clean
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
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

                      _buildLanguageDropdown(context, l10n, ref),

                      _buildSettingsDropdown(context, l10n, ref),

                      const Divider(height: 1),

                      _buildHelpDropdown(context, l10n),

                      _buildMenuItem(
                        context,
                        icon: Icons.info,
                        title: l10n.about,
                        onTap: () => _showAboutDialog(context, l10n),
                      ),

                      const Divider(height: 1),

                      _buildMenuItem(
                        context,
                        icon: Icons.logout,
                        title: l10n.logout,
                        onTap: () => _showLogoutDialog(context, l10n),
                        color: Colors.red,
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
              ),
            ],
          ),
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

  void _navigateHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to access survey features. Please login to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to auth screen
              Navigator.pushNamed(context, '/auth');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AppLocalizations l10n) {
    final user = SupabaseService.instance.currentUser;
    final displayName = user?.email ?? 'User';
    final contactInfo = user?.email != null ? 'Email: ${user!.email}' : 'No email';

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
              displayName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              contactInfo,
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

  void _showClearDataDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all survey data. This action cannot be undone. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Note: Implement full data clearing in DatabaseService if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data clearing not implemented yet')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to clear data: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSurveyDialog(BuildContext context, AppLocalizations l10n, String sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content: Text('Delete survey for $sessionId? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseService().deleteSurveySession(sessionId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Survey deleted')),
                );
                // The list will refresh when dialog is reopened
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: $e')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Survey Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose export format:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export to CSV'),
              subtitle: const Text('Export all surveys to CSV file'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  // For now, show a message since export is complex
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              },
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

  void _showSurveyListDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Surveys'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
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
                return const Text('No survey data found.');
              }
              return ListView.builder(
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    child: ListTile(
                      title: Text(session['phone_number'] ?? 'Unknown Phone'),
                      subtitle: Text(
                        'Village: ${session['village_name'] ?? 'N/A'}\nDate: ${session['survey_date'] ?? 'N/A'}\nStatus: ${session['status'] ?? 'Unknown'}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'preview') {
                            Navigator.pop(context);
                            _navigateToSurveyPreview(context, session['phone_number']);
                          } else if (value == 'delete') {
                            _showDeleteSurveyDialog(context, l10n, session['phone_number']);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'preview',
                            child: Text('Preview'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
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

  void _showDataManagementDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.storage, color: Colors.teal),
            const SizedBox(width: 8),
            Text(l10n.dataManagement),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('View All Surveys'),
              subtitle: const Text('Browse and manage survey data'),
              onTap: () {
                Navigator.pop(context);
                _showSurveyListDialog(context, l10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Data'),
              subtitle: const Text('Export surveys to CSV file'),
              onTap: () {
                Navigator.pop(context);
                _showExportDialog(context, l10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Delete all survey data permanently'),
              onTap: () {
                Navigator.pop(context);
                _showClearDataDialog(context, l10n);
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
                                    backgroundColor: currentFontSize == 1.0 ? Colors.green : Colors.grey[300],
                                    foregroundColor: currentFontSize == 1.0 ? Colors.white : Colors.black,
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
                          leading: const Icon(Icons.storage, color: Colors.teal),
                          title: Text(
                            l10n.dataManagement,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text(
                            'Manage local survey data',
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () => _showDataManagementDialog(context, l10n),
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
                    title: Text(session['phone_number'] ?? 'Unknown Phone'),
                    subtitle: Text(
                      'Village: ${session['village_name'] ?? 'N/A'}\nDate: ${session['survey_date'] ?? 'N/A'}\nStatus: ${session['status'] ?? 'Unknown'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.download),
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to final page (preview) with this session data
                      _navigateToSurveyPreview(context, session['phone_number']);
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
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await SupabaseService.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/auth'); // Go to auth/login
              }
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

  Widget _buildLanguageDropdown(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final localeNotifier = ref.read(localeProvider.notifier);
    final currentLanguage = ref.watch(localeProvider).languageCode;

    return ExpansionTile(
      leading: const Icon(Icons.language, color: Colors.green),
      title: Text(l10n.selectLanguage),
      children: [
        ListTile(
          title: const Text('English'),
          leading: Radio<String>(
            value: 'en',
            groupValue: currentLanguage,
            onChanged: (value) async {
              if (value != null) {
                await localeNotifier.setLocale(Locale(value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.languageChangedToEnglish)),
                );
              }
            },
            activeColor: Colors.green,
          ),
        ),
        ListTile(
          title: const Text('हिंदी'),
          leading: Radio<String>(
            value: 'hi',
            groupValue: currentLanguage,
            onChanged: (value) async {
              if (value != null) {
                await localeNotifier.setLocale(Locale(value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.languageChangedToHindi)),
                );
              }
            },
            activeColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsDropdown(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    final fontSizeNotifier = ref.read(fontSizeProvider.notifier);
    final currentFontSize = ref.watch(fontSizeProvider);

    return ExpansionTile(
      leading: const Icon(Icons.settings, color: Colors.green),
      title: Text(l10n.settings),
      children: [
        // Font Size Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.fontSize,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Current: ${(currentFontSize * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: currentFontSize,
                min: 0.5,
                max: 1.5,
                divisions: 10,
                label: '${(currentFontSize * 100).round()}%',
                activeColor: Colors.green,
                onChanged: (value) {
                  fontSizeNotifier.setFontSize(value);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => fontSizeNotifier.setFontSize(0.7),
                      child: const Text('Small'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => fontSizeNotifier.resetToDefault(),
                      child: const Text('Default'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => fontSizeNotifier.setFontSize(1.3),
                      child: const Text('Large'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildHelpDropdown(BuildContext context, AppLocalizations l10n) {
    return ExpansionTile(
      leading: const Icon(Icons.help, color: Colors.green),
      title: Text(l10n.helpAndSupport),
      children: [
        ListTile(
          leading: const Icon(Icons.help),
          title: Text(l10n.userGuide),
          onTap: () => _showUserGuideDialog(context, l10n),
        ),
        ListTile(
          leading: const Icon(Icons.contact_support),
          title: Text(l10n.contactSupport),
          onTap: () => _showContactSupportDialog(context, l10n),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: Text(l10n.reportIssue),
          onTap: () => _showReportIssueDialog(context, l10n),
        ),
      ],
    );
  }

  void _showUserGuideDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.userGuide),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Family Survey User Guide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Starting a Survey:\n'
                '   - Enter the phone number of the head of the family\n'
                '   - Fill in village and location details\n'
                '   - Navigate through each page using the bottom navigation\n\n'
                '2. Family Information:\n'
                '   - Add details for each family member\n'
                '   - Include education, occupation, and health information\n\n'
                '3. Data Management:\n'
                '   - Use the sidebar to access settings and data management\n'
                '   - Export survey data for analysis\n'
                '   - Preview completed surveys\n\n'
                '4. Language Support:\n'
                '   - Switch between English and Hindi\n'
                '   - Adjust font size for better readability\n\n'
                '5. Troubleshooting:\n'
                '   - Check History for previous surveys\n'
                '   - Contact support if you encounter issues',
                style: TextStyle(fontSize: 14),
              ),
            ],
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

  void _showContactSupportDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactSupport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Email Support'),
              subtitle: Text('support@dri.org'),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone Support'),
              subtitle: Text('+91-1234567890'),
            ),
            const ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Address'),
              subtitle: Text('Deendayal Research Institute\nChitrakoot, India'),
            ),
            const SizedBox(height: 16),
            const Text(
              'For technical issues or questions about the survey process, please contact our support team.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
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

  void _showReportIssueDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reportIssue),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Issue Description',
                hintText: 'Describe the problem you encountered',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text(
              'Please provide details about the issue, including steps to reproduce it.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual issue reporting (email or API call)
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue report submitted')),
              );
            },
            child: const Text('Submit Report'),
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
