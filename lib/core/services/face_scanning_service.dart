import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_face_api/face_api.dart' as face_api;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FaceScanningService {
  static const String _faceTemplateKey = 'face_template';
  static const String _kycStatusKey = 'kyc_face_verified';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isInitialized = false;

  /// Initialize the face scanning service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Face API
      await face_api.FaceSDK.init();
      _isInitialized = true;
    } catch (e) {
      throw FaceScanningException('Failed to initialize face scanning: $e');
    }
  }

  /// Capture face image from camera
  Future<File?> captureFaceImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw FaceScanningException('Failed to capture face image: $e');
    }
  }

  /// Extract face template from image
  Future<String?> extractFaceTemplate(File imageFile) async {
    try {
      await initialize();
      
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Detect faces in the image
      final face_api.DetectFacesResponse detectResponse = 
          await face_api.FaceSDK.detectFaces(
        face_api.DetectFacesRequest(
          tag: 'kyc_face_detection',
          scenario: face_api.FaceCaptureScenario.CROP_CENTRAL_FACE,
          image: base64Encode(imageBytes),
        ),
      );

      if (detectResponse.faces.isEmpty) {
        throw FaceScanningException('No face detected in the image');
      }

      if (detectResponse.faces.length > 1) {
        throw FaceScanningException('Multiple faces detected. Please ensure only one face is visible');
      }

      final face_api.DetectFace detectedFace = detectResponse.faces.first;
      
      // Check face quality
      if (detectedFace.attributes != null) {
        final quality = detectedFace.attributes!.quality;
        if (quality != null && quality.score < 0.7) {
          throw FaceScanningException('Face quality too low. Please take a clearer photo');
        }
      }

      // Create face template
      final face_api.CreatePersonResponse createPersonResponse = 
          await face_api.FaceSDK.createPerson(
        face_api.CreatePersonRequest(
          images: [
            face_api.ImageUpload(
              imageData: face_api.ImageData(
                image: base64Encode(imageBytes),
              ),
            ),
          ],
          groupIds: ['kyc_group'],
        ),
      );

      return createPersonResponse.person.id;
    } catch (e) {
      if (e is FaceScanningException) rethrow;
      throw FaceScanningException('Failed to extract face template: $e');
    }
  }

  /// Store face template for KYC
  Future<void> storeFaceTemplate(String template) async {
    await _secureStorage.write(key: _faceTemplateKey, value: template);
  }

  /// Get stored face template
  Future<String?> getStoredFaceTemplate() async {
    return await _secureStorage.read(key: _faceTemplateKey);
  }

  /// Verify face against stored template
  Future<bool> verifyFace(File imageFile) async {
    try {
      await initialize();
      
      final String? storedTemplate = await getStoredFaceTemplate();
      if (storedTemplate == null) {
        throw FaceScanningException('No stored face template found');
      }

      final String? newTemplate = await extractFaceTemplate(imageFile);
      if (newTemplate == null) {
        return false;
      }

      // Compare faces using Face API
      final face_api.MatchFacesResponse matchResponse = 
          await face_api.FaceSDK.matchFaces(
        face_api.MatchFacesRequest(
          images: [
            face_api.MatchFacesImage(
              type: face_api.ImageType.PRINTED,
              imageData: face_api.ImageData(
                image: await _getImageFromTemplate(storedTemplate),
              ),
            ),
            face_api.MatchFacesImage(
              type: face_api.ImageType.LIVE,
              imageData: face_api.ImageData(
                image: await _getImageFromTemplate(newTemplate),
              ),
            ),
          ],
        ),
      );

      if (matchResponse.results.isNotEmpty) {
        final double similarity = matchResponse.results.first.similarity;
        return similarity > 0.75; // 75% similarity threshold
      }

      return false;
    } catch (e) {
      if (e is FaceScanningException) rethrow;
      throw FaceScanningException('Face verification failed: $e');
    }
  }

  /// Perform liveness detection
  Future<bool> performLivenessDetection(File imageFile) async {
    try {
      await initialize();
      
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Perform liveness detection
      final face_api.LivenessResponse livenessResponse = 
          await face_api.FaceSDK.liveness(
        face_api.LivenessRequest(
          tag: 'kyc_liveness',
          image: base64Encode(imageBytes),
        ),
      );

      return livenessResponse.liveness == face_api.LivenessStatus.PASSED;
    } catch (e) {
      throw FaceScanningException('Liveness detection failed: $e');
    }
  }

  /// Complete KYC face verification process
  Future<KYCFaceResult> completeKYCFaceVerification() async {
    try {
      // Step 1: Capture face image
      final File? faceImage = await captureFaceImage();
      if (faceImage == null) {
        return KYCFaceResult(
          success: false,
          message: 'Face capture cancelled',
        );
      }

      // Step 2: Perform liveness detection
      final bool isLive = await performLivenessDetection(faceImage);
      if (!isLive) {
        return KYCFaceResult(
          success: false,
          message: 'Liveness detection failed. Please ensure you are taking a live photo',
        );
      }

      // Step 3: Extract face template
      final String? template = await extractFaceTemplate(faceImage);
      if (template == null) {
        return KYCFaceResult(
          success: false,
          message: 'Failed to process face image',
        );
      }

      // Step 4: Store template
      await storeFaceTemplate(template);
      await _secureStorage.write(key: _kycStatusKey, value: 'verified');

      return KYCFaceResult(
        success: true,
        message: 'Face verification completed successfully',
        faceTemplate: template,
      );
    } catch (e) {
      return KYCFaceResult(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Check if KYC face verification is completed
  Future<bool> isKYCFaceVerified() async {
    final String? status = await _secureStorage.read(key: _kycStatusKey);
    return status == 'verified';
  }

  /// Clear stored face data
  Future<void> clearFaceData() async {
    await _secureStorage.delete(key: _faceTemplateKey);
    await _secureStorage.delete(key: _kycStatusKey);
  }

  /// Helper method to get image from template (mock implementation)
  Future<String> _getImageFromTemplate(String template) async {
    // In a real implementation, this would retrieve the actual image data
    // For now, return the template as base64 (mock)
    return template;
  }

  /// Dispose resources
  void dispose() {
    // Clean up resources if needed
  }
}

/// Result class for KYC face verification
class KYCFaceResult {
  final bool success;
  final String message;
  final String? faceTemplate;

  KYCFaceResult({
    required this.success,
    required this.message,
    this.faceTemplate,
  });
}

/// Custom exception for face scanning errors
class FaceScanningException implements Exception {
  final String message;
  
  FaceScanningException(this.message);
  
  @override
  String toString() => 'FaceScanningException: $message';
}
