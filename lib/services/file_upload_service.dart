import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class FileUploadService {
  static final FileUploadService _instance = FileUploadService._internal();
  static FileUploadService get instance => _instance;

  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _uploadTimer;
  bool _isOnline = false;

  // Drive API credentials (to be loaded from env)
  String? _serviceAccountEmail;
  String? _privateKey;
  String? _driveFolderId;

  // Root DRI folder ID
  static const String ROOT_FOLDER_ID = '1vSI4mzbITbsAdJRhYR8rraR_8y1ie7QF';

  FileUploadService._internal() {
    _initializeConnectivityMonitoring();
    _loadCredentials();
  }

  void _initializeConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        if (!wasOnline && _isOnline) {
          // Network came back online, start uploading
          _startPeriodicUpload();
          processPendingUploads();
        } else if (wasOnline && !_isOnline) {
          // Network went offline, stop periodic upload
          _stopPeriodicUpload();
        }
      },
    );

    // Check initial connectivity
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      if (_isOnline) {
        _startPeriodicUpload();
      }
    });
  }

  void _startPeriodicUpload() {
    _uploadTimer?.cancel();
    _uploadTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      processPendingUploads();
    });
  }

  void _stopPeriodicUpload() {
    _uploadTimer?.cancel();
    _uploadTimer = null;
  }

  Future<void> _loadCredentials() async {
    // Load credentials from Android environment variables or dotenv
    String? email = const String.fromEnvironment('GOOGLE_SERVICE_ACCOUNT_EMAIL');
    String? key = const String.fromEnvironment('GOOGLE_PRIVATE_KEY');
    
    if (email.isEmpty) {
      email = dotenv.env['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
    }
    
    if (key.isEmpty) {
      key = dotenv.env['GOOGLE_PRIVATE_KEY'];
    }

    _serviceAccountEmail = email;
    _privateKey = key?.replaceAll(r'\n', '\n');
    _driveFolderId = ROOT_FOLDER_ID;

    // Also load GOOGLE_FORM if available (for alternative upload method)
    String googleFormUrl = const String.fromEnvironment('GOOGLE_FORM');
    if (googleFormUrl.isEmpty) {
      googleFormUrl = dotenv.env['GOOGLE_FORM'] ?? '';
    }

    if (_serviceAccountEmail == null || _privateKey == null) {
      if (googleFormUrl.isNotEmpty) {
        debugPrint('Using GOOGLE_FORM for uploads: $googleFormUrl');
        // TODO: Implement Google Form upload method as fallback
      } else {
        debugPrint('Warning: Neither Drive credentials nor GOOGLE_FORM configured. File uploads will fail.');
        debugPrint('Please set GOOGLE_SERVICE_ACCOUNT_EMAIL, GOOGLE_PRIVATE_KEY, or GOOGLE_FORM environment variables.');
      }
    }
  }

  Future<auth.AuthClient> _getAuthenticatedClient() async {
    if (_serviceAccountEmail == null || _privateKey == null) {
      throw Exception('Drive credentials not configured');
    }

    final credentials = auth.ServiceAccountCredentials(
      _serviceAccountEmail!,
      auth.ClientId('dummy', 'dummy'), // Not needed for service account
      _privateKey!,
    );

    return auth.clientViaServiceAccount(credentials, [drive.DriveApi.driveScope]);
  }

  Future<String?> _getOrCreateVillageFolder(String shineCode, drive.DriveApi driveApi) async {
    try {
      // Search for existing folder using SHINE code directly
      final query = "name = '$shineCode' and mimeType = 'application/vnd.google-apps.folder' and '$ROOT_FOLDER_ID' in parents and trashed = false";
      final searchResult = await driveApi.files.list(
        q: query,
        spaces: 'drive',
      );

      if (searchResult.files != null && searchResult.files!.isNotEmpty) {
        return searchResult.files!.first.id;
      }

      // Create new folder using SHINE code
      final folderMetadata = drive.File()
        ..name = shineCode
        ..mimeType = 'application/vnd.google-apps.folder'
        ..parents = [ROOT_FOLDER_ID];

      final createdFolder = await driveApi.files.create(folderMetadata);
      return createdFolder.id;
    } catch (e) {
      debugPrint('Error creating/getting village folder: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _uploadFileToDrive(
    String localPath,
    String fileName,
    String shineCode,
    String pageType,
  ) async {
    final client = await _getAuthenticatedClient();
    final driveApi = drive.DriveApi(client);

    try {
      // Get or create village folder
      final villageFolderId = await _getOrCreateVillageFolder(shineCode, driveApi);
      if (villageFolderId == null) {
        throw Exception('Could not create/access village folder');
      }

      // Create file metadata
      final fileMetadata = drive.File()
        ..name = fileName
        ..parents = [villageFolderId];

      // Upload file
      final media = drive.Media(
        File(localPath).openRead(),
        await File(localPath).length(),
      );

      final uploadedFile = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      // Make file publicly accessible
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        uploadedFile.id!,
      );

      // Get shareable link
      final shareableLink = 'https://drive.google.com/file/d/${uploadedFile.id}/view?usp=sharing';

      return {
        'fileId': uploadedFile.id,
        'shareLink': shareableLink,
      };
    } catch (e) {
      debugPrint('Error uploading to Drive: $e');
      return null;
    } finally {
      client.close();
    }
  }

  Future<void> _syncFileMetadataToSupabase(
    String shineCode,
    String pageType,
    String component,
    String fileName,
    String fileType,
    String driveFileId,
    String driveShareLink,
    String? phoneNumber,
  ) async {
    try {
      await _supabaseService.client.from('uploaded_files').insert({
        'village_smile_code': shineCode,
        'page_type': pageType,
        'component': component,
        'file_name': fileName,
        'file_type': fileType,
        'drive_file_id': driveFileId,
        'drive_share_link': driveShareLink,
        'phone_number': phoneNumber,
        'uploaded_by': _supabaseService.currentUser?.email,
      });
    } catch (e) {
      debugPrint('Error syncing file metadata to Supabase: $e');
      // Don't throw - upload succeeded, just metadata sync failed
    }
  }

  Future<void> processPendingUploads() async {
    debugPrint('Processing pending uploads... Online: $_isOnline');
    if (!_isOnline) return;

    // Check credentials existence to fail fast
    if (_serviceAccountEmail == null && _privateKey == null) {
        // Try loading again just in case
        await _loadCredentials();
        if (_serviceAccountEmail == null) {
           debugPrint('Cannot process uploads: Credentials missing');
           return;
        }
    }

    final pendingUploads = await _getPendingUploads();
    debugPrint('Found ${pendingUploads.length} pending uploads');
    for (final upload in pendingUploads) {
      await _processSingleUpload(upload);
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingUploads() async {
    final db = await _databaseService.database;
    return await db.query(
      'pending_uploads',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> _processSingleUpload(Map<String, dynamic> upload) async {
    final uploadId = upload['id'];
    final localPath = upload['local_file_path'];
    final fileName = upload['file_name'];
    final shineCode = upload['village_smile_code'];
    final pageType = upload['page_type'];
    final component = upload['component'];
    final fileType = upload['file_type'];

    // Update status to uploading
    await _updateUploadStatus(uploadId, 'uploading');

    try {
      // Check if file still exists
      if (!File(localPath).existsSync()) {
        await _updateUploadStatus(uploadId, 'failed', errorMessage: 'File not found locally');
        return;
      }

      // Upload to Drive
      final driveResult = await _uploadFileToDrive(
        localPath,
        fileName,
        shineCode,
        pageType,
      );

      if (driveResult == null) {
        throw Exception('Drive upload failed');
      }

      // Sync metadata to Supabase
      await _syncFileMetadataToSupabase(
        shineCode,
        pageType,
        component ?? '',
        fileName,
        fileType,
        driveResult['fileId'],
        driveResult['shareLink'],
        shineCode, // Use shineCode as proxy for phone number if not available in context
      );

      // Update status to uploaded
      await _updateUploadStatus(uploadId, 'uploaded');
      debugPrint('File upload successful: $fileName');

      // Optionally delete local file after successful upload
      // File(localPath).deleteSync();

    } catch (e) {
      debugPrint('File upload failed: $e');
      final attempts = upload['upload_attempts'] + 1;
      final errorMessage = e.toString();

      // If credentials error, fail immediately (don't retry endlessly)
      if (errorMessage.contains('credentials not configured')) {
         await _updateUploadStatus(uploadId, 'failed', errorMessage: errorMessage);
         return;
      }

      if (attempts >= 3) {
        await _updateUploadStatus(uploadId, 'failed', errorMessage: errorMessage);
      } else {
        await _updateUploadStatus(uploadId, 'pending', attempts: attempts, errorMessage: errorMessage);
      }
    }
  }

  Future<void> _updateUploadStatus(
    int uploadId,
    String status, {
    int? attempts,
    String? errorMessage,
  }) async {
    final db = await _databaseService.database;
    final updateData = {
      'status': status,
      'last_attempt_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (attempts != null) {
      updateData['upload_attempts'] = attempts.toString();
    }
    if (errorMessage != null) {
      updateData['error_message'] = errorMessage;
    }

    await db.update(
      'pending_uploads',
      updateData,
      where: 'id = ?',
      whereArgs: [uploadId],
    );
  }

  Future<String> _saveFileLocally(XFile file, String shineCode, String pageType) async {
    final directory = await getApplicationDocumentsDirectory();
    final uploadDir = Directory(path.join(directory.path, 'uploads', shineCode, pageType));

    if (!uploadDir.existsSync()) {
      uploadDir.createSync(recursive: true);
    }

    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final localPath = path.join(uploadDir.path, fileName);

    await file.saveTo(localPath);
    return localPath;
  }

  Future<void> queueFileForUpload(
    XFile file,
    String shineCode,
    String pageType,
    String component,
    String fileType,
  ) async {
    try {
      // Save file locally
      final localPath = await _saveFileLocally(file, shineCode, pageType);
      
      // Construct filename: shineCode_component.ext
      String extension = path.extension(file.path);
      // Sanitize component name (replace spaces and special chars with underscores)
      String sanitizedComponent = component.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      String targetFileName = '${shineCode}_$sanitizedComponent$extension';

      // Add to pending uploads queue
      final db = await _databaseService.database;
      await db.insert('pending_uploads', {
        'local_file_path': localPath,
        'file_name': targetFileName,
        'file_type': fileType,
        'village_smile_code': shineCode,
        'page_type': pageType,
        'component': component,
        'status': 'pending',
        'upload_attempts': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Try to upload immediately if online
      if (_isOnline) {
        processPendingUploads();
      }
    } catch (e) {
      debugPrint('Error queuing file for upload: $e');
      throw e;
    }
  }

  Future<XFile?> pickImage() async {
    try {
      // Check for permissions
      if (Platform.isAndroid) {
        // Android 13+ use photos/media permission, older use storage
        // However, image_picker mostly handles this. 
        // We will try to request to be safe if user's device is tricky.
        var status = await Permission.photos.status;
        if (status.isDenied) {
           // On old Android, photos permission might map to storage or be permanently denied if assumed
           // Actually, let's check storage too for older devices
           var storageStatus = await Permission.storage.status;
           if (storageStatus.isDenied) {
              // Try requesting storage first as a catch-all for older devices including 12 and below
              // On 13, this might not do anything useful but harmless
              await Permission.storage.request();
           }
           // Try requesting photos for newer devices
           await Permission.photos.request();
        }
      }

      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      return pickedFile;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<XFile?> captureImage() async {
    try {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        await Permission.camera.request();
      }
      
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      return pickedFile;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<XFile?> pickFile(List<String> allowedExtensions) async {
    try {
      // Storage permission check for older Androids
      if (Platform.isAndroid) {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
             await Permission.storage.request();
          }
      }
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        return XFile(result.files.single.path!);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  Future<XFile?> pickDocument() async {
     return pickFile(['pdf', 'doc', 'docx']);
  }

  Future<List<Map<String, dynamic>>> getPendingUploadsForSession(
    String shineCode,
    String pageType,
  ) async {
    final db = await _databaseService.database;
    return await db.query(
      'pending_uploads',
      where: 'village_smile_code = ? AND page_type = ?',
      whereArgs: [shineCode, pageType],
    );
  }

  Future<List<Map<String, dynamic>>> getUploadedFilesForSession(
    String shineCode,
    String pageType,
  ) async {
    try {
      final response = await _supabaseService.client
          .from('uploaded_files')
          .select('*')
          .eq('village_smile_code', shineCode)
          .eq('page_type', pageType)
          .eq('is_deleted', false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting uploaded files: $e');
      return [];
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _uploadTimer?.cancel();
  }
}