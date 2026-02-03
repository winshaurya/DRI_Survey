import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/database_service.dart';
import '../../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _typeTabController;
  String _searchQuery = '';
  List<Map<String, dynamic>> _allSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _typeTabController = TabController(length: 2, vsync: this);
    _typeTabController.addListener(() {
      if (_typeTabController.indexIsChanging) setState(() {});
    });
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    try {
      final familySessions = await DatabaseService().getAllSurveySessions();
      final villageSessions = await DatabaseService().getAllVillageSurveySessions();
      
      final processedFamily = familySessions.map((s) => {...s, 'type': 'family'}).toList();
      final processedVillage = villageSessions.map((s) => {...s, 'type': 'village'}).toList();

      if (mounted) {
        setState(() {
          _allSessions = [...processedFamily, ...processedVillage];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _typeTabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterSessions(String statusFilter) {
    final currentType = _typeTabController.index == 0 ? 'family' : 'village';
    
    return _allSessions.where((session) {
      final type = session['type'];
      if (type != currentType) return false;

      final status = session['status'] ?? 'in_progress';
      final isCompleted = status == 'completed';
      final matchesStatus = statusFilter == 'all' || 
                            (statusFilter == 'completed' && isCompleted) ||
                            (statusFilter == 'in_progress' && !isCompleted);
      
      final villageName = (session['village_name'] ?? '').toString().toLowerCase();
      final phoneNumber = (session['phone_number'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      final matchesSearch = villageName.contains(query) || phoneNumber.contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey History', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
               TabBar(
                controller: _typeTabController,
                indicatorColor: Colors.white,
                indicatorWeight: 4,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: 'Families', icon: Icon(Icons.family_restroom)),
                  Tab(text: 'Villages', icon: Icon(Icons.location_city)),
                ],
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white70,
                indicatorWeight: 2,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'In Progress'),
                  Tab(text: 'Completed'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Village or Phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSessionList('all'),
                _buildSessionList('in_progress'),
                _buildSessionList('completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(String filter) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final sessions = _filterSessions(filter);

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _typeTabController.index == 0 ? Icons.family_restroom : Icons.location_city, 
              size: 64, color: Colors.grey.shade300
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_typeTabController.index == 0 ? 'family' : 'village'} surveys found',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSessions,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          final session = sessions[index];
          return _buildHistoryCard(session);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> session) {
    final type = session['type'];
    final phoneNumber = session['phone_number'] ?? 'Unknown Phone';
    final villageName = session['village_name'] ?? 'Unknown Village';
    final sessionId = session['session_id'] ?? phoneNumber; // Village uses session_id
    
    final rawDate = session['survey_date'] ?? session['created_at'];
    String formattedDate = 'N/A';
    if (rawDate != null) {
      try {
        final date = DateTime.parse(rawDate);
        formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
      } catch (_) {}
    }
    
    final status = session['status'] ?? 'in_progress';
    final isCompleted = status == 'completed';
    final isSynced = session['last_synced_at'] != null;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isCompleted && isSynced) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Completed & Synced';
    } else if (isCompleted && !isSynced) {
      statusColor = Colors.blue;
      statusIcon = Icons.cloud_upload;
      statusText = 'Completed (Pending Sync)';
    } else {
      statusColor = Colors.orange;
      statusIcon = Icons.edit_note;
      statusText = 'In Progress';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (type == 'family') {
            if (isCompleted) {
              _navigateToSurveyPreview(phoneNumber);
            } else {
              _navigateToContinueSurvey(phoneNumber);
            }
          } else {
             // Village survey navigation
             if (isCompleted) {
               // View village survey details (Not implemented fully yet, maybe just go to flow?)
               // For now just continue/edit which allows viewing
               _navigateToContinueVillageSurvey(sessionId);
             } else {
               _navigateToContinueVillageSurvey(sessionId);
             }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          villageName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (type == 'family')
                          Text(
                            phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              fontFamily: 'RobotoMono' // Monospace for phone numbers looks good
                            ),
                          ),
                        if (type == 'village')
                          Text(
                            'Session: ${sessionId.substring(0, 8)}...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isCompleted)
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: Colors.orange.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.orange.withOpacity(0.3))
                       ),
                       child: const Text('Resume', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                     )
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSurveyPreview(String sessionId) {
    Navigator.pushNamed(
      context,
      '/survey',
      arguments: {'previewSessionId': sessionId},
    ).then((_) => _loadSessions()); // Reload on return
  }

  void _navigateToContinueSurvey(String sessionId) {
    Navigator.pushNamed(
      context,
      '/survey',
      arguments: {'continueSessionId': sessionId},
    ).then((_) => _loadSessions()); // Reload on return
  }

  void _navigateToContinueVillageSurvey(String sessionId) {
     // Set current session ID in DatabaseService
     DatabaseService().currentSessionId = sessionId;
     
     // Navigate to Village Form (start of flow) or maybe determine where they left off?
     // For now start at the form
     Navigator.pushNamed(
       context,
       '/village-form',
       // arguments: {'sessionId': sessionId} // VillageFormScreen might need update to read args if we want to be explicit, but it uses provider/singleton usually
     ).then((_) => _loadSessions());
  }
}
