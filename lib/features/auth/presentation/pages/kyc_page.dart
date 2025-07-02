import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/face_scanning_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../shared/widgets/blockvest_button.dart';
import '../../../../shared/widgets/blockvest_input_field.dart';
import '../../../../core/theme/app_theme.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  String? _selectedIdType;
  String? _selectedState;

  // Services
  late final BiometricService _biometricService;
  late final FaceScanningService _faceScanningService;

  // State variables
  bool _isLoading = false;
  bool _biometricEnabled = false;
  bool _faceVerified = false;
  String? _biometricStatus;
  String? _faceVerificationStatus;

  final List<String> _idTypes = [
    'National ID',
    'Driver\'s License',
    'International Passport',
    'Voter\'s Card',
  ];

  @override
  void initState() {
    super.initState();
    _biometricService = di.sl<BiometricService>();
    _faceScanningService = di.sl<FaceScanningService>();
    _initializeBiometrics();
  }

  final List<String> _nigerianStates = [
    'Abia', 'Adamawa', 'Akwa Ibom', 'Anambra', 'Bauchi', 'Bayelsa', 'Benue',
    'Borno', 'Cross River', 'Delta', 'Ebonyi', 'Edo', 'Ekiti', 'Enugu',
    'FCT - Abuja', 'Gombe', 'Imo', 'Jigawa', 'Kaduna', 'Kano', 'Katsina',
    'Kebbi', 'Kogi', 'Kwara', 'Lagos', 'Nasarawa', 'Niger', 'Ogun', 'Ondo',
    'Osun', 'Oyo', 'Plateau', 'Rivers', 'Sokoto', 'Taraba', 'Yobe', 'Zamfara'
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _initializeBiometrics() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final biometrics = await _biometricService.getAvailableBiometrics();
      final isEnabled = await _biometricService.isBiometricEnabled();
      final isFaceVerified = await _faceScanningService.isKYCFaceVerified();

      setState(() {
        _biometricEnabled = isEnabled;
        _faceVerified = isFaceVerified;
        _biometricStatus = isAvailable
            ? _biometricService.getBiometricStatusMessage(biometrics)
            : 'Biometric authentication not available';
      });
    } catch (e) {
      setState(() {
        _biometricStatus = 'Error checking biometric availability';
      });
    }
  }

  Future<void> _enableBiometricAuth() async {
    setState(() => _isLoading = true);

    try {
      final success = await _biometricService.enableBiometricAuth();

      setState(() {
        _biometricEnabled = success;
        _isLoading = false;
      });

      if (success) {
        _showSuccessSnackBar('Biometric authentication enabled successfully');
      } else {
        _showErrorSnackBar('Failed to enable biometric authentication');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _performFaceVerification() async {
    setState(() => _isLoading = true);

    try {
      final result = await _faceScanningService.completeKYCFaceVerification();

      setState(() {
        _faceVerified = result.success;
        _faceVerificationStatus = result.message;
        _isLoading = false;
      });

      if (result.success) {
        _showSuccessSnackBar('Face verification completed successfully');
      } else {
        _showErrorSnackBar(result.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Face verification failed: ${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _submitKyc() {
    if (_formKey.currentState!.validate()) {
      // Check if biometric and face verification are completed
      if (!_biometricEnabled || !_faceVerified) {
        _showErrorSnackBar(
          'Please complete biometric authentication and face verification before submitting KYC'
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('KYC Submitted'),
          content: const Text(
            'Your KYC information has been submitted successfully with biometric verification. '
            'You will be notified once verification is complete.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(AppRouter.dashboard);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }

  void _skipKyc() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip KYC?'),
        content: const Text(
          'You can complete KYC verification later in your profile settings. '
          'Some features may be limited without verification.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRouter.dashboard);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        actions: [
          TextButton(
            onPressed: _skipKyc,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Verify Your Identity',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete KYC verification to unlock all features',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Phone Number field
                BlockVestInputField(
                  label: 'Phone Number',
                  hint: '+234 XXX XXX XXXX',
                  controller: _phoneController,
                  type: BlockVestInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  isRequired: true,
                ),
                const SizedBox(height: AppTheme.spacingM),

                // Address field
                BlockVestInputField(
                  label: 'Address',
                  hint: 'Enter your full address',
                  controller: _addressController,
                  type: BlockVestInputType.multiline,
                  prefixIcon: Icons.location_on_outlined,
                  isRequired: true,
                  maxLines: 2,
                ),
                const SizedBox(height: AppTheme.spacingM),

                // City field
                BlockVestInputField(
                  label: 'City',
                  controller: _cityController,
                  prefixIcon: Icons.location_city_outlined,
                  isRequired: true,
                ),
                const SizedBox(height: AppTheme.spacingM),
                
                // State dropdown
                DropdownButtonFormField<String>(
                  value: _selectedState,
                  decoration: const InputDecoration(
                    labelText: 'State',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: _nigerianStates.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your state';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // ID Type dropdown
                DropdownButtonFormField<String>(
                  value: _selectedIdType,
                  decoration: const InputDecoration(
                    labelText: 'ID Type',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: _idTypes.map((idType) {
                    return DropdownMenuItem(
                      value: idType,
                      child: Text(idType),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIdType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an ID type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Document upload section (placeholder for MVP)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload ID Document',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Take a clear photo of your selected ID',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // For MVP, just show a placeholder message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Document upload feature coming soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),

                // Biometric Authentication Section
                _buildBiometricSection(),
                const SizedBox(height: AppTheme.spacingL),

                // Face Verification Section
                _buildFaceVerificationSection(),
                const SizedBox(height: AppTheme.spacingXL),

                // Submit button
                BlockVestButton.primary(
                  text: 'Submit KYC',
                  onPressed: _submitKyc,
                  isFullWidth: true,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  color: _biometricEnabled ? AppTheme.successColor : AppTheme.textSecondary,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Biometric Authentication',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        _biometricStatus ?? 'Checking availability...',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_biometricEnabled)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (!_biometricEnabled) ...[
              Text(
                'Enable biometric authentication for enhanced security and quick access to your account.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              BlockVestButton.outline(
                text: 'Enable Biometric Auth',
                onPressed: _enableBiometricAuth,
                icon: Icons.fingerprint,
                isLoading: _isLoading,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        'Biometric authentication enabled successfully',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFaceVerificationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.face,
                  color: _faceVerified ? AppTheme.successColor : AppTheme.textSecondary,
                  size: 28,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Face Verification',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXS),
                      Text(
                        _faceVerificationStatus ?? 'Required for KYC compliance',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_faceVerified)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (!_faceVerified) ...[
              Text(
                'Complete face verification to ensure secure identity verification for KYC compliance.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              BlockVestButton.outline(
                text: 'Start Face Verification',
                onPressed: _performFaceVerification,
                icon: Icons.camera_alt,
                isLoading: _isLoading,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Expanded(
                      child: Text(
                        'Face verification completed successfully',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
