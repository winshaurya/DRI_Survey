import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'signboards_screen.dart';
import 'survey_details_screen.dart';
import '../../services/file_upload_service.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';

class SocialMapScreen extends StatefulWidget {
  const SocialMapScreen({super.key});

  @override
  _SocialMapScreenState createState() => _SocialMapScreenState();
}

class _SocialMapScreenState extends State<SocialMapScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _remarksController = TextEditingController();
  final FileUploadService _fileUploadService = FileUploadService.instance;

  String? _currentSessionId;
  String? _shineCode;

  final Map<String, XFile?> _mapImages = {
    'Topography & Hydrology': null,
    'Enterprise Map': null,
    'Village': null,
    'Venn Diagram': null,
    'Transect Map': null,
    'Cadastral Map': null,
  };

  final Map<String, String> _uploadStatuses = {
    'Topography & Hydrology': 'none',
    'Enterprise Map': 'none',
    'Village': 'none',
    'Venn Diagram': 'none',
    'Transect Map': 'none',
    'Cadastral Map': 'none',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSession();
    });
  }

  Future<void> _loadCurrentSession() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final sessionId = databaseService.currentSessionId;
    
    if (sessionId != null) {
      setState(() {
        _currentSessionId = sessionId;
      });
      
      // Fetch session details to get shine code
      final session = await databaseService.getVillageSurveySession(sessionId);
      if (session != null && session['shine_code'] != null) {
        setState(() {
          _shineCode = session['shine_code'];
        });
        _loadExistingUploads();
      }
    }
  }

  Future<void> _loadExistingUploads() async {
    if (_shineCode == null) return;

    try {
      final pendingUploads = await _fileUploadService.getPendingUploadsForSession(
        _shineCode!,
        'social_map',
      );
      final databaseService = Provider.of<DatabaseService>(context, listen: false);
      final socialMaps = _currentSessionId == null
          ? <Map<String, dynamic>>[]
          : await databaseService.getVillageData('village_social_maps', _currentSessionId!);
      final socialMap = socialMaps.isNotEmpty ? socialMaps.first : <String, dynamic>{};

      setState(() {
        for (final upload in pendingUploads) {
          final component = upload['component'];
          if (component != null && _uploadStatuses.containsKey(component)) {
            _uploadStatuses[component] = upload['status'] ?? 'pending';
          }
        }

        void markIfLink(String component, String column) {
          final link = socialMap[column];
          if (link is String && link.trim().isNotEmpty) {
            _uploadStatuses[component] = 'uploaded';
          }
        }

        markIfLink('Topography & Hydrology', 'topography_file_link');
        markIfLink('Enterprise Map', 'enterprise_file_link');
        markIfLink('Village', 'village_file_link');
        markIfLink('Venn Diagram', 'venn_file_link');
        markIfLink('Transect Map', 'transect_file_link');
        markIfLink('Cadastral Map', 'cadastral_file_link');
      });
    } catch (e) {
      debugPrint('Error loading existing uploads: $e');
    }
  }

  Future<void> _pickFile(String component) async {
    if (_shineCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active village survey session found')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery (Image)'),
                onTap: () async {
                  Navigator.of(context).pop();
                  // Use pickImage() which is implemented, instead of pickFile()
                  final file = await _fileUploadService.pickImage();
                  if (file != null) _handleFileSelection(file, component, 'image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await _fileUploadService.captureImage();
                  if (file != null) _handleFileSelection(file, component, 'image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Document (PDF)'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await _fileUploadService.pickFile(['pdf']);
                  if (file != null) _handleFileSelection(file, component, 'pdf');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleFileSelection(XFile file, String component, String type) async {
    setState(() {
      _mapImages[component] = file;
      _uploadStatuses[component] = 'pending';
    });

    try {
      await _fileUploadService.queueFileForUpload(
        file,
        _shineCode!,
        'social_map',
        component,
        type,
      );

      // Reload upload statuses
      await _loadExistingUploads();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File queued for upload')),
      );
    } catch (e) {
      setState(() => _uploadStatuses[component] = 'failed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to queue file: $e')),
      );
    }
  }

  // Deprecated: used _pickFile instead
  Future<void> _pickImage(String component) async {
      await _pickFile(component);
  }

  void _removeImage(String component) {
    setState(() {
      _mapImages[component] = null;
      _uploadStatuses[component] = 'none';
    });
  }

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final syncService = SyncService.instance;

    if (_currentSessionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active village survey session found')),
      );
      return;
    }

    // Check authentication before syncing
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    final currentUser = supabaseService.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not authenticated. Please login again.')),
        );
      }
      return;
    }

    final existing = await databaseService.getVillageData('village_social_maps', _currentSessionId!);
    final existingRow = existing.isNotEmpty ? existing.first : <String, dynamic>{};

    String? _existingLink(String column) {
      final value = existingRow[column];
      if (value is String && value.trim().isNotEmpty) return value;
      return null;
    }

    final data = {
      'id': const Uuid().v4(),
      'session_id': _currentSessionId,
      'remarks': _remarksController.text,
      'topography_file_link': _existingLink('topography_file_link'),
      'enterprise_file_link': _existingLink('enterprise_file_link'),
      'village_file_link': _existingLink('village_file_link'),
      'venn_file_link': _existingLink('venn_file_link'),
      'transect_file_link': _existingLink('transect_file_link'),
      'cadastral_file_link': _existingLink('cadastral_file_link'),
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      await databaseService.insertOrUpdate('village_social_maps', data, _currentSessionId!);

      await databaseService.markVillagePageCompleted(_currentSessionId!, 8);
      unawaited(syncService.syncVillagePageData(_currentSessionId!, 8, data));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SurveyDetailsScreen()),
        );
      }
    } catch (e) {
      print('Error saving data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  void _goToPreviousScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignboardsScreen()),
    );
  }

  Widget _buildImageUploader(String title, String component) {
    XFile? image = _mapImages[component];
    String status = _uploadStatuses[component] ?? 'none';

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF800080),
                ),
              ),
              _buildStatusIndicator(status),
            ],
          ),
          SizedBox(height: 6),

          if (image == null)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: InkWell(
                onTap: () => _pickFile(component),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 32,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Upload File',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade200,
                    image: image.path.toLowerCase().endsWith('.pdf') 
                        ? null 
                        : DecorationImage(
                            image: FileImage(File(image.path)),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: image.path.toLowerCase().endsWith('.pdf')
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                              SizedBox(height: 8),
                              Text(
                                image.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeImage(component),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
                if (status == 'pending' || status == 'uploading')
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status == 'pending' ? 'Pending' : 'Uploading...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (status == 'uploaded')
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Uploaded',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (status == 'failed')
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Failed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status) {
    switch (status) {
      case 'pending':
        return Icon(Icons.schedule, color: Colors.orange, size: 16);
      case 'uploading':
        return SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        );
      case 'uploaded':
        return Icon(Icons.check_circle, color: Colors.green, size: 16);
      case 'failed':
        return Icon(Icons.error, color: Colors.red, size: 16);
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  // Form Header
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.map, color: Color(0xFF800080)),
                              SizedBox(width: 8),
                              Text(
                                'Social Map',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF800080),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('Step 8: Upload map images'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // Image Uploaders
                  ..._mapImages.keys
                      .map(
                        (component) =>
                            _buildImageUploader(component, component),
                      )
                      .toList(),

                  SizedBox(height: 20),

                  // Remarks Input Box
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remarks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF800080),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _remarksController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Enter any remarks or comments here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF800080), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Buttons - Previous and Continue
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _goToPreviousScreen,
                          icon: Icon(Icons.arrow_back, size: 16),
                          label: Text('Previous'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Color(0xFF800080)),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: Icon(Icons.arrow_forward, size: 16),
                          label: Text('Save & Continue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF800080),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20), // Extra padding at bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
