import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:crypto/crypto.dart';

enum KYCStatus {
  notStarted,
  inProgress,
  pendingReview,
  approved,
  rejected,
  expired,
}

enum DocumentType {
  nationalId,
  passport,
  driversLicense,
  votersCard,
  nin, // Nigerian National Identification Number
}

enum VerificationStep {
  personalInfo,
  documentUpload,
  faceVerification,
  addressVerification,
  completed,
}

class KYCService {
  static const String _kycStatusKey = 'kyc_status';
  static const String _kycDataKey = 'kyc_data';
  static const String _faceDataKey = 'face_verification_data';
  static const String _documentsKey = 'kyc_documents';
  static const String _verificationStepKey = 'verification_step';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();

  /// Get current KYC status
  Future<KYCStatus> getKYCStatus() async {
    try {
      final statusStr = await _secureStorage.read(key: _kycStatusKey);
      if (statusStr != null) {
        return KYCStatus.values.firstWhere(
          (status) => status.name == statusStr,
          orElse: () => KYCStatus.notStarted,
        );
      }
      return KYCStatus.notStarted;
    } catch (e) {
      return KYCStatus.notStarted;
    }
  }

  /// Update KYC status
  Future<void> updateKYCStatus(KYCStatus status) async {
    try {
      await _secureStorage.write(key: _kycStatusKey, value: status.name);
    } catch (e) {
      throw Exception('Failed to update KYC status: ${e.toString()}');
    }
  }

  /// Get current verification step
  Future<VerificationStep> getCurrentStep() async {
    try {
      final stepStr = await _secureStorage.read(key: _verificationStepKey);
      if (stepStr != null) {
        return VerificationStep.values.firstWhere(
          (step) => step.name == stepStr,
          orElse: () => VerificationStep.personalInfo,
        );
      }
      return VerificationStep.personalInfo;
    } catch (e) {
      return VerificationStep.personalInfo;
    }
  }

  /// Update verification step
  Future<void> updateVerificationStep(VerificationStep step) async {
    try {
      await _secureStorage.write(key: _verificationStepKey, value: step.name);
    } catch (e) {
      throw Exception('Failed to update verification step: ${e.toString()}');
    }
  }

  /// Submit personal information
  Future<void> submitPersonalInfo({
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String phoneNumber,
    required String email,
    required String address,
    required String city,
    required String state,
    required String country,
    String? nin, // Nigerian National Identification Number
  }) async {
    try {
      final personalInfo = {
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'nin': nin,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      await _secureStorage.write(
        key: _kycDataKey,
        value: json.encode(personalInfo),
      );

      await updateVerificationStep(VerificationStep.documentUpload);
      await updateKYCStatus(KYCStatus.inProgress);
    } catch (e) {
      throw Exception('Failed to submit personal info: ${e.toString()}');
    }
  }

  /// Upload document for verification
  Future<void> uploadDocument({
    required DocumentType documentType,
    required String imagePath,
    String? documentNumber,
  }) async {
    try {
      // Read image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      
      // Generate hash for integrity
      final imageHash = sha256.convert(imageBytes).toString();
      
      // Store document data
      final documentData = {
        'type': documentType.name,
        'imagePath': imagePath,
        'imageHash': imageHash,
        'documentNumber': documentNumber,
        'uploadedAt': DateTime.now().toIso8601String(),
      };

      // Get existing documents
      final existingDocuments = await _getStoredDocuments();
      existingDocuments[documentType.name] = documentData;

      await _secureStorage.write(
        key: _documentsKey,
        value: json.encode(existingDocuments),
      );

      // Check if we have at least one document to proceed
      if (existingDocuments.isNotEmpty) {
        await updateVerificationStep(VerificationStep.faceVerification);
      }
    } catch (e) {
      throw Exception('Failed to upload document: ${e.toString()}');
    }
  }

  /// Capture face for verification
  Future<void> captureFaceVerification() async {
    try {
      // Capture image using camera
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image == null) {
        throw Exception('No image captured');
      }

      // Read image bytes
      final imageBytes = await image.readAsBytes();
      
      // Generate hash
      final imageHash = sha256.convert(imageBytes).toString();
      
      // Simulate face detection and analysis
      final faceAnalysis = await _analyzeFace(imageBytes);
      
      // Store face verification data
      final faceData = {
        'imagePath': image.path,
        'imageHash': imageHash,
        'analysis': faceAnalysis,
        'capturedAt': DateTime.now().toIso8601String(),
      };

      await _secureStorage.write(
        key: _faceDataKey,
        value: json.encode(faceData),
      );

      await updateVerificationStep(VerificationStep.addressVerification);
    } catch (e) {
      throw Exception('Failed to capture face verification: ${e.toString()}');
    }
  }

  /// Simulate face analysis (in production, this would use ML/AI services)
  Future<Map<String, dynamic>> _analyzeFace(Uint8List imageBytes) async {
    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock face analysis results
      return {
        'faceDetected': true,
        'confidence': 0.95,
        'quality': 'high',
        'landmarks': {
          'eyes': 2,
          'nose': 1,
          'mouth': 1,
        },
        'liveness': {
          'score': 0.92,
          'passed': true,
        },
        'processedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'faceDetected': false,
        'confidence': 0.0,
        'quality': 'low',
        'error': e.toString(),
      };
    }
  }

  /// Submit address verification
  Future<void> submitAddressVerification({
    required String proofType, // utility bill, bank statement, etc.
    required String imagePath,
  }) async {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final imageHash = sha256.convert(imageBytes).toString();

      final addressProof = {
        'proofType': proofType,
        'imagePath': imagePath,
        'imageHash': imageHash,
        'submittedAt': DateTime.now().toIso8601String(),
      };

      // Get existing KYC data and add address proof
      final kycDataStr = await _secureStorage.read(key: _kycDataKey);
      final kycData = kycDataStr != null 
          ? Map<String, dynamic>.from(json.decode(kycDataStr))
          : <String, dynamic>{};
      
      kycData['addressProof'] = addressProof;

      await _secureStorage.write(
        key: _kycDataKey,
        value: json.encode(kycData),
      );

      await updateVerificationStep(VerificationStep.completed);
      await updateKYCStatus(KYCStatus.pendingReview);
    } catch (e) {
      throw Exception('Failed to submit address verification: ${e.toString()}');
    }
  }

  /// Get stored documents
  Future<Map<String, dynamic>> _getStoredDocuments() async {
    try {
      final documentsStr = await _secureStorage.read(key: _documentsKey);
      if (documentsStr != null) {
        return Map<String, dynamic>.from(json.decode(documentsStr));
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Get KYC completion percentage
  Future<double> getCompletionPercentage() async {
    try {
      final currentStep = await getCurrentStep();
      final stepIndex = VerificationStep.values.indexOf(currentStep);
      return (stepIndex + 1) / VerificationStep.values.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get KYC summary
  Future<Map<String, dynamic>> getKYCSummary() async {
    try {
      final status = await getKYCStatus();
      final currentStep = await getCurrentStep();
      final completionPercentage = await getCompletionPercentage();
      
      // Get personal info
      final kycDataStr = await _secureStorage.read(key: _kycDataKey);
      final personalInfo = kycDataStr != null 
          ? Map<String, dynamic>.from(json.decode(kycDataStr))
          : null;
      
      // Get documents
      final documents = await _getStoredDocuments();
      
      // Get face verification
      final faceDataStr = await _secureStorage.read(key: _faceDataKey);
      final faceData = faceDataStr != null 
          ? Map<String, dynamic>.from(json.decode(faceDataStr))
          : null;

      return {
        'status': status.name,
        'currentStep': currentStep.name,
        'completionPercentage': completionPercentage,
        'hasPersonalInfo': personalInfo != null,
        'documentsCount': documents.length,
        'hasFaceVerification': faceData != null,
        'submittedAt': personalInfo?['submittedAt'],
        'nextSteps': _getNextSteps(currentStep, status),
      };
    } catch (e) {
      return {
        'status': KYCStatus.notStarted.name,
        'currentStep': VerificationStep.personalInfo.name,
        'completionPercentage': 0.0,
        'hasPersonalInfo': false,
        'documentsCount': 0,
        'hasFaceVerification': false,
        'submittedAt': null,
        'nextSteps': ['Complete personal information'],
      };
    }
  }

  /// Get next steps based on current progress
  List<String> _getNextSteps(VerificationStep currentStep, KYCStatus status) {
    if (status == KYCStatus.approved) {
      return ['KYC verification completed'];
    }
    
    if (status == KYCStatus.rejected) {
      return ['Review rejection reasons and resubmit'];
    }

    switch (currentStep) {
      case VerificationStep.personalInfo:
        return ['Complete personal information form'];
      case VerificationStep.documentUpload:
        return ['Upload valid government-issued ID'];
      case VerificationStep.faceVerification:
        return ['Complete face verification selfie'];
      case VerificationStep.addressVerification:
        return ['Upload proof of address document'];
      case VerificationStep.completed:
        return ['Wait for review (1-3 business days)'];
    }
  }

  /// Verify face match (simulate ML comparison)
  Future<bool> verifyFaceMatch(String newImagePath) async {
    try {
      // Get stored face data
      final faceDataStr = await _secureStorage.read(key: _faceDataKey);
      if (faceDataStr == null) {
        throw Exception('No face verification data found');
      }

      // Simulate face matching process
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock matching result (in production, use ML/AI services)
      final matchScore = 0.85 + (0.1 * (DateTime.now().millisecond % 10) / 10);
      return matchScore > 0.8;
    } catch (e) {
      throw Exception('Face verification failed: ${e.toString()}');
    }
  }

  /// Clear all KYC data
  Future<void> clearKYCData() async {
    try {
      await _secureStorage.delete(key: _kycStatusKey);
      await _secureStorage.delete(key: _kycDataKey);
      await _secureStorage.delete(key: _faceDataKey);
      await _secureStorage.delete(key: _documentsKey);
      await _secureStorage.delete(key: _verificationStepKey);
    } catch (e) {
      throw Exception('Failed to clear KYC data: ${e.toString()}');
    }
  }

  /// Check if KYC is required for operation
  bool isKYCRequiredForOperation(String operation) {
    // Define operations that require KYC
    const kycRequiredOperations = [
      'large_investment', // > $10,000
      'withdrawal',
      'governance_voting',
      'staking',
    ];
    
    return kycRequiredOperations.contains(operation);
  }

  /// Get KYC requirements for Nigerian users
  Map<String, dynamic> getNigerianKYCRequirements() {
    return {
      'requiredDocuments': [
        'National ID Card',
        'Nigerian International Passport',
        'Driver\'s License',
        'Voter\'s Card',
        'NIN (National Identification Number)',
      ],
      'addressProofOptions': [
        'Utility Bill (NEPA/PHCN)',
        'Bank Statement',
        'Tenancy Agreement',
        'Local Government Certificate',
      ],
      'minimumAge': 18,
      'additionalRequirements': [
        'Valid phone number',
        'Email address',
        'BVN (Bank Verification Number) - Optional',
      ],
    };
  }
}
