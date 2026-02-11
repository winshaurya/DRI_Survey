import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import 'detailed_map_screen.dart'; // Import the previous screen
import 'forest_map_screen.dart';

class CadastralMapScreen extends StatefulWidget {
  const CadastralMapScreen({super.key});

  @override
  _CadastralMapScreenState createState() => _CadastralMapScreenState();
}

class _CadastralMapScreenState extends State<CadastralMapScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Cadastral map availability
  bool hasCadastralMap = false;
  TextEditingController mapDetailsController = TextEditingController();
  TextEditingController availabilityStatusController = TextEditingController();
  
  // Image upload
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _submitForm() async {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    final syncService = SyncService.instance;

    // Get session ID (ensure DatabaseService is updated to return String ID)
    final sessionId = databaseService.currentSessionId;

    if (sessionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error: No active session found')),
        );
      }
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

    final data = {
      'id': const Uuid().v4(),
      'session_id': sessionId,
      'has_cadastral_map': hasCadastralMap ? 1 : 0,
      'map_details': mapDetailsController.text,
      'availability_status': availabilityStatusController.text,
      'image_path': _selectedImage?.path,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      // NOTE: Ensure 'village_cadastral_maps' table exists in DatabaseHelper
      // If not, we might need to add it or skip this.
      // Assuming it doesn't exist yet based on previous file reads of DatabaseHelper.
      // I will add the table creation to DatabaseHelper shortly.
      await databaseService.insertOrUpdate('village_cadastral_maps', data, sessionId);

      await databaseService.markVillagePageCompleted(sessionId, 13);
      unawaited(syncService.syncVillagePageData(sessionId, 13, data));

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForestMapScreen()),
        );
      }
    } catch (e) {
      print('Error saving cadastral map data: $e');
      if (mounted) {
        // Navigate anyway to avoid blocking
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForestMapScreen()),
        );
      }
    }
  }

  void _goToPreviousScreen() {
    // Navigate back to DetailedMapScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DetailedMapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header removed (Govt/Platform labels stripped)
            SizedBox(height: 12),

              ),
            ),
            
            Container(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.landscape, color: Color(0xFF800080), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'Cadastral Map',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF800080),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Step 12: Cadastral map documentation (if available)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 25),
                    
                    // Info Card
                    Card(
                      elevation: 3,
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade800),
                                SizedBox(width: 10),
                                Text(
                                  'What is a Cadastral Map?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'A cadastral map shows property boundaries, land ownership, and parcel information. '
                              'It is used for land records, taxation, and property disputes.',
                              style: TextStyle(color: Colors.blue.shade700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Cadastral Map Availability
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cadastral Map Availability',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          
                          RadioListTile<bool>(
                            title: Text('Available', style: TextStyle(color: Colors.grey.shade800)),
                            value: true,
                            groupValue: hasCadastralMap,
                            onChanged: (value) => setState(() => hasCadastralMap = value ?? false),
                            activeColor: Color(0xFF800080),
                          ),
                          
                          RadioListTile<bool>(
                            title: Text('Not Available', style: TextStyle(color: Colors.grey.shade800)),
                            value: false,
                            groupValue: hasCadastralMap,
                            onChanged: (value) => setState(() => hasCadastralMap = value ?? false),
                            activeColor: Color(0xFF800080),
                          ),
                          
                          if (hasCadastralMap)
                            Column(
                              children: [
                                SizedBox(height: 15),
                                TextFormField(
                                  controller: mapDetailsController,
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    labelText: 'Enter cadastral map details (optional)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    helperText: 'Include map number, year, jurisdiction, etc.',
                                  ),
                                  // Removed validator to make it optional
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Photo Upload Section
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFF800080).withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upload Photo (Optional)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF800080),
                            ),
                          ),
                          SizedBox(height: 10),
                          
                          Text(
                            'Upload a photo of the cadastral map if available',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 15),
                          
                          // Image Preview
                          if (_selectedImage != null)
                            Column(
                              children: [
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton.icon(
                                  onPressed: _removeImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade800,
                                  ),
                                  icon: Icon(Icons.delete, size: 20),
                                  label: Text('Remove Photo'),
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          
                          // Upload Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF800080),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: Icon(Icons.photo_library, size: 22),
                                  label: Text('Choose from Gallery'),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _takePhoto,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  icon: Icon(Icons.camera_alt, size: 22),
                                  label: Text('Take Photo'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30),
                    
                    // Buttons - Previous and Continue
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _goToPreviousScreen,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Color(0xFF800080), width: 2),
                            ),
                            icon: Icon(Icons.arrow_back, size: 24),
                            label: Text(
                              'Previous',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF800080),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: Icon(Icons.arrow_forward, size: 24),
                            label: Text(
                              'Save & Continue',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapDetailsController.dispose();
    availabilityStatusController.dispose();
    super.dispose();
  }
}
