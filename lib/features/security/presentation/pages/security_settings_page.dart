import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/kyc_service.dart';
import '../../../../core/services/mfa_service.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../widgets/biometric_settings_card.dart';
import '../widgets/kyc_status_card.dart';
import '../widgets/mfa_settings_card.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  late final BiometricService _biometricService;
  late final KYCService _kycService;
  late final MFAService _mfaService;
  
  bool _isLoading = true;
  Map<String, dynamic> _securityStatus = {};

  @override
  void initState() {
    super.initState();
    _biometricService = di.sl<BiometricService>();
    _kycService = di.sl<KYCService>();
    _mfaService = di.sl<MFAService>();
    _loadSecurityStatus();
  }

  Future<void> _loadSecurityStatus() async {
    try {
      setState(() => _isLoading = true);
      
      final biometricStatus = await _biometricService.getBiometricStatus();
      final kycSummary = await _kycService.getKYCSummary();
      final mfaStatus = await _mfaService.getMFAStatus();
      
      setState(() {
        _securityStatus = {
          'biometric': biometricStatus,
          'kyc': kycSummary,
          'mfa': mfaStatus,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load security status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSecurityStatus,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSecurityStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Overview
                    _buildSecurityOverview(),
                    const SizedBox(height: 24),
                    
                    // KYC Status Card
                    KYCStatusCard(
                      kycSummary: _securityStatus['kyc'] ?? {},
                      onRefresh: _loadSecurityStatus,
                    ),
                    const SizedBox(height: 16),
                    
                    // Biometric Settings Card
                    BiometricSettingsCard(
                      biometricStatus: _securityStatus['biometric'] ?? {},
                      onRefresh: _loadSecurityStatus,
                    ),
                    const SizedBox(height: 16),
                    
                    // MFA Settings Card
                    MFASettingsCard(
                      mfaStatus: _securityStatus['mfa'] ?? {},
                      onRefresh: _loadSecurityStatus,
                    ),
                    const SizedBox(height: 16),
                    
                    // Security Tips
                    _buildSecurityTips(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSecurityOverview() {
    final biometricStatus = _securityStatus['biometric'] ?? {};
    final kycStatus = _securityStatus['kyc'] ?? {};
    final mfaStatus = _securityStatus['mfa'] ?? {};
    
    final securityScore = _calculateSecurityScore(
      biometricStatus,
      kycStatus,
      mfaStatus,
    );
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: _getSecurityScoreColor(securityScore),
                ),
                const SizedBox(width: 8),
                Text(
                  'Security Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSecurityScoreColor(securityScore).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${securityScore.toInt()}%',
                    style: TextStyle(
                      color: _getSecurityScoreColor(securityScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: securityScore / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getSecurityScoreColor(securityScore),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getSecurityScoreDescription(securityScore),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTips() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Security Tips',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._getSecurityTips().map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  double _calculateSecurityScore(
    Map<String, dynamic> biometric,
    Map<String, dynamic> kyc,
    Map<String, dynamic> mfa,
  ) {
    double score = 0;
    
    // KYC verification (40% of score)
    final kycStatus = kyc['status'] ?? 'notStarted';
    if (kycStatus == 'approved') {
      score += 40;
    } else if (kycStatus == 'pendingReview') {
      score += 30;
    } else if (kycStatus == 'inProgress') {
      score += 20;
    }
    
    // Biometric authentication (30% of score)
    final biometricAvailable = biometric['isAvailable'] ?? false;
    final enabledLevels = biometric['enabledLevels'] ?? {};
    if (biometricAvailable && enabledLevels.isNotEmpty) {
      score += 30;
    }
    
    // MFA (30% of score)
    final mfaEnabled = mfa['isEnabled'] ?? false;
    final enabledMethods = mfa['enabledMethods'] ?? [];
    if (mfaEnabled && enabledMethods.isNotEmpty) {
      score += 30;
    }
    
    return score;
  }

  Color _getSecurityScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getSecurityScoreDescription(double score) {
    if (score >= 80) {
      return 'Excellent security! Your account is well protected.';
    } else if (score >= 60) {
      return 'Good security, but there\'s room for improvement.';
    } else if (score >= 40) {
      return 'Basic security. Consider enabling more security features.';
    } else {
      return 'Low security. Please complete your security setup.';
    }
  }

  List<String> _getSecurityTips() {
    return [
      'Complete KYC verification to unlock all features',
      'Enable biometric authentication for quick and secure access',
      'Set up multi-factor authentication for sensitive operations',
      'Keep your recovery phrases in a safe place',
      'Never share your private keys or passwords',
      'Regularly review your security settings',
      'Use strong, unique passwords for your accounts',
    ];
  }
}
