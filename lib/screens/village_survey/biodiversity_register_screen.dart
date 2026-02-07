import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'forest_map_screen.dart'; // Import the previous screen
import 'completion_screen.dart'; // Add this import
import '../../services/file_upload_service.dart';
import '../../services/database_service.dart';
import '../../database/database_helper.dart';
import '../../services/sync_service.dart';

class BiodiversityRegisterScreen extends StatefulWidget {
  const BiodiversityRegisterScreen({super.key});

  @override
  _BiodiversityRegisterScreenState createState() => _BiodiversityRegisterScreenState();
}

class _BiodiversityRegisterScreenState extends State<BiodiversityRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController componentsController = TextEditingController();
  final TextEditingController knowledgeController = TextEditingController();

  final FileUploadService _fileUploadService = FileUploadService.instance;
  final DatabaseService _databaseService = DatabaseService();

  String? _currentSessionId;
  String? _shineCode;
  String _uploadStatus = 'none';

  // Image upload
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSession();
    });
  }

  Future<void> _loadCurrentSession() async {
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      final sessionId = dbService.currentSessionId;
      
      if (sessionId != null) {
        // Fetch session details to get village_code (shineCode)
        final db = await DatabaseHelper().database;
        final sessions = await db.query(
          'village_survey_sessions',
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );

        if (sessions.isNotEmpty) {
          setState(() {
            _currentSessionId = sessionId;
            _shineCode = sessions.first['village_code'] as String?;
          });
          _loadExistingUploads();
        }
      }
    } catch (e) {
      debugPrint('Error loading current session: $e');
    }
  }

  Future<void> _loadExistingUploads() async {
    if (_shineCode == null) return;

    try {
      final pendingUploads = await _fileUploadService.getPendingUploadsForSession(
        _shineCode!,
        'pbr',
      );
      final uploadedFiles = await _fileUploadService.getUploadedFilesForSession(
        _shineCode!,
        'pbr',
      );

      setState(() {
        if (pendingUploads.isNotEmpty) {
          _uploadStatus = pendingUploads.first['status'];
        } else if (uploadedFiles.isNotEmpty) {
          _uploadStatus = 'uploaded';
        }
      });
    } catch (e) {
      debugPrint('Error loading existing uploads: $e');
    }
  }

  Future<void> _pickImage() async {
    if (_shineCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active village survey session found')),
      );
      return;
    }

    final XFile? image = await _fileUploadService.pickImage();

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _uploadStatus = 'pending';
      });

      try {
        await _fileUploadService.queueFileForUpload(
          image,
          _shineCode!,
          'pbr',
          'biodiversity_register',
          'image',
        );

        // Reload upload statuses
        await _loadExistingUploads();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image queued for upload')),
        );
      } catch (e) {
        setState(() => _uploadStatus = 'failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to queue image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (_shineCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active village survey session found')),
      );
      return;
    }

    final XFile? image = await _fileUploadService.captureImage();

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _uploadStatus = 'pending';
      });

      try {
        await _fileUploadService.queueFileForUpload(
          image,
          _shineCode!,
          'pbr',
          'biodiversity_register',
          'image',
        );

        // Reload upload statuses
        await _loadExistingUploads();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image queued for upload')),
        );
      } catch (e) {
        setState(() => _uploadStatus = 'failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to queue image: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _uploadStatus = 'none';
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

    final data = {
      'id': const Uuid().v4(),
      'session_id': _currentSessionId,
      'status': statusController.text,
      'details': detailsController.text,
      'components': componentsController.text,
      'knowledge': knowledgeController.text,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await DatabaseHelper().insert('village_biodiversity_register', data);

      await databaseService.markVillagePageCompleted(_currentSessionId!, 12);
      await syncService.syncVillagePageData(_currentSessionId!, 12, data);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompletionScreen()),
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
    // Navigate back to ForestMapScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ForestMapScreen()),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int lines = 1}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12), // Reduced from 15
      padding: EdgeInsets.all(10), // Reduced from 12
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Slightly smaller
        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, 
            style: TextStyle(
              fontSize: 14, // Reduced from default
              fontWeight: FontWeight.w600, 
              color: Color(0xFF800080)
            )
          ),
          SizedBox(height: 6), // Reduced from 8
          TextFormField(
            controller: controller,
            maxLines: lines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              hintText: 'Enter details... (optional)',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10, // Reduced from 12
                vertical: 10   // Reduced from 10
              ),
            ),
            style: TextStyle(fontSize: 13), // Smaller text
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header - Made more compact
            Container(
              height: 90, // Reduced from 100
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Government of India', 
                    style: TextStyle(
                      fontSize: 18, // Reduced from 22
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF003366)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text('Digital India', 
                        style: TextStyle(
                          fontSize: 14, // Reduced from 16
                          color: Color(0xFFFF9933), 
                          fontWeight: FontWeight.w600
                        )
                      ),
                      Text('Power To Empower', 
                        style: TextStyle(
                          fontSize: 13, // Reduced from 14
                          color: Color(0xFF138808), 
                          fontStyle: FontStyle.italic
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Container(
              padding: EdgeInsets.all(12), // Reduced from 16
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Card - Made more compact
                    Card(
                      elevation: 3, // Reduced from 4
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Reduced from 12
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(12), // Reduced from 16
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flag, color: Color(0xFF800080), size: 28), // Reduced from 32
                                SizedBox(width: 10), // Reduced from 12
                                Expanded(
                                  child: Text('Biodiversity Register', 
                                    style: TextStyle(
                                      fontSize: 18, // Reduced from 22
                                      fontWeight: FontWeight.w700, 
                                      color: Color(0xFF800080)
                                    )
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6), // Reduced from 8
                            Text('Step 14: People\'s Biodiversity Register (PBR) Documentation',
                              style: TextStyle(
                                color: Colors.grey.shade600, 
                                fontSize: 13 // Reduced from 15
                              )
                            ),
                            SizedBox(height: 4), // Reduced from 5
                            Container(
                              height: 3, // Reduced from 4
                              width: 100, // Reduced from 120
                              decoration: BoxDecoration(
                                color: Color(0xFF800080),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16), // Reduced from 20
                    
                    // Info Card - Made more compact
                    Card(
                      elevation: 2, // Reduced from 3
                      color: Colors.blue.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Reduced from default
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12), // Reduced from 16
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20), // Smaller
                                SizedBox(width: 8), // Reduced from 10
                                Expanded(
                                  child: Text(
                                    'About People\'s Biodiversity Register',
                                    style: TextStyle(
                                      fontSize: 14, // Reduced from 16
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8), // Reduced from 10
                            Text(
                              'PBR is a comprehensive record of local biological resources, their medicinal or any other use, or any other traditional knowledge associated with them.',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12, // Reduced from default
                              ),
                            ),
                            SizedBox(height: 6), // Reduced from 8
                            Text(
                              'Note: All fields on this screen are optional.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12, // Reduced from 14
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20), // Reduced from 25
                    
                    // Input Fields (All Optional) - Now using smaller version
                    _buildInputField('PBR Status (Available/Not Available) (optional)', statusController, lines: 1),
                    _buildInputField('Documentation Details (optional)', detailsController, lines: 3),
                    _buildInputField('Biodiversity Components Documented (optional)', componentsController, lines: 3),
                    _buildInputField('Traditional Knowledge Recorded (optional)', knowledgeController, lines: 3),
                    
                    SizedBox(height: 20), // Reduced from 25
                    
                    // Photo Upload Section - Made more compact
                    Container(
                      padding: EdgeInsets.all(12), // Reduced from 15
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10), // Reduced from 12
                        border: Border.all(color: Color(0xFF800080).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.camera_alt, color: Color(0xFF800080), size: 20), // Smaller
                              SizedBox(width: 8), // Reduced from 10
                              Expanded(
                                child: Text(
                                  'Upload Photo (Optional)',
                                  style: TextStyle(
                                    fontSize: 16, // Reduced from 18
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ),
                              _buildStatusIndicator(_uploadStatus),
                            ],
                          ),
                          SizedBox(height: 8), // Reduced from 10
                          
                          Text(
                            'Upload a photo of the Biodiversity Register if available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12, // Reduced from 14
                            ),
                          ),
                          SizedBox(height: 12), // Reduced from 15
                          
                          // Image Preview
                          if (_selectedImage != null)
                            Column(
                              children: [
                                Container(
                                  height: 180, // Reduced from 200
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6), // Reduced from 8
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6), // Reduced from 8
                                    child: Image.file(
                                        File(_selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8), // Reduced from 10
                                ElevatedButton.icon(
                                  onPressed: _removeImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade800,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12, 
                                      vertical: 10
                                    ),
                                  ),
                                  icon: Icon(Icons.delete, size: 18), // Smaller
                                  label: Text('Remove Photo',
                                    style: TextStyle(fontSize: 13) // Smaller
                                  ),
                                ),
                                SizedBox(height: 16), // Reduced from 20
                              ],
                            ),
                          
                          // Upload Buttons - Made more compact
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF800080),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12, // Reduced from 14
                                        horizontal: 8,
                                      ),
                                    ),
                                    icon: Icon(Icons.photo_library, size: 20), // Reduced from 22
                                    label: Text('Choose from Gallery',
                                      style: TextStyle(fontSize: 13) // Smaller
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8), // Reduced from 10
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _takePhoto,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade700,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12, // Reduced from 14
                                        horizontal: 8,
                                      ),
                                    ),
                                    icon: Icon(Icons.camera_alt, size: 20), // Reduced from 22
                                    label: Text('Take Photo',
                                      style: TextStyle(fontSize: 13) // Smaller
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 24), // Reduced from 30
                    
                    // Buttons - Previous and Final Submit - Made more compact
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _goToPreviousScreen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade600,
                                padding: EdgeInsets.symmetric(vertical: 14), // Reduced from 16
                              ),
                              icon: Icon(Icons.arrow_back, size: 18), // Reduced from 20
                              label: Text('Previous',
                                style: TextStyle(fontSize: 13) // Smaller
                              ),
                            ),
                          ),
                          SizedBox(width: 12), // Reduced from 16
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(vertical: 14), // Reduced from 16
                              ),
                              icon: Icon(Icons.done_all, size: 18), // Reduced from 20
                              label: Text('Submit Final Data',
                                style: TextStyle(fontSize: 13) // Smaller
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  void dispose() {
    statusController.dispose();
    detailsController.dispose();
    componentsController.dispose();
    knowledgeController.dispose();
    super.dispose();
  }
}
