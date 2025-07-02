import 'package:flutter/material.dart';
import '../../../../core/services/mfa_service.dart';
import '../../../../core/di/injection_container.dart' as di;

class MFASettingsCard extends StatefulWidget {
  final Map<String, dynamic> mfaStatus;
  final VoidCallback onRefresh;

  const MFASettingsCard({
    super.key,
    required this.mfaStatus,
    required this.onRefresh,
  });

  @override
  State<MFASettingsCard> createState() => _MFASettingsCardState();
}

class _MFASettingsCardState extends State<MFASettingsCard> {
  late final MFAService _mfaService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mfaService = di.sl<MFAService>();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.mfaStatus['isEnabled'] ?? false;
    final enabledMethods = List<String>.from(
      widget.mfaStatus['enabledMethods'] ?? [],
    );
    final backupCodesCount = widget.mfaStatus['backupCodesCount'] ?? 0;
    final recommendedMethods = List<String>.from(
      widget.mfaStatus['recommendedMethods'] ?? [],
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
                  color: isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-Factor Authentication',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isEnabled,
                  onChanged: _isLoading ? null : _toggleMFA,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (!isEnabled) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Enable MFA to add an extra layer of security to your account',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Enabled methods
              if (enabledMethods.isNotEmpty) ...[
                Text(
                  'Enabled Methods:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...enabledMethods.map((method) => _buildMethodTile(method, true)),
                const SizedBox(height: 16),
              ],
              
              // Available methods to enable
              Text(
                'Available Methods:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildMethodOption(
                'SMS Verification',
                MFAMethod.sms,
                enabledMethods.contains('sms'),
                'Receive codes via text message',
                Icons.sms,
              ),
              _buildMethodOption(
                'Email Verification',
                MFAMethod.email,
                enabledMethods.contains('email'),
                'Receive codes via email',
                Icons.email,
              ),
              _buildMethodOption(
                'Biometric',
                MFAMethod.biometric,
                enabledMethods.contains('biometric'),
                'Use fingerprint or face recognition',
                Icons.fingerprint,
              ),
              _buildMethodOption(
                'Authenticator App',
                MFAMethod.authenticatorApp,
                enabledMethods.contains('authenticatorApp'),
                'Use Google Authenticator or similar',
                Icons.smartphone,
              ),
              
              const SizedBox(height: 16),
              
              // Backup codes section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.backup, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Backup Codes',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$backupCodesCount remaining',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: backupCodesCount > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Backup codes can be used when other MFA methods are unavailable',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _generateBackupCodes,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Generate New'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        if (backupCodesCount > 0) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _viewBackupCodes,
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('View Codes'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
            
            // Recommendations
            if (recommendedMethods.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendedMethods.map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
            ],
            
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(String method, bool isEnabled) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        _getMethodIcon(method),
        color: isEnabled ? Colors.green : Colors.grey,
      ),
      title: Text(_getMethodDisplayName(method)),
      subtitle: Text(_getMethodDescription(method)),
      trailing: isEnabled
          ? IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: _isLoading ? null : () => _toggleMethod(method, false),
            )
          : null,
    );
  }

  Widget _buildMethodOption(
    String title,
    MFAMethod method,
    bool isEnabled,
    String description,
    IconData icon,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isEnabled ? Colors.green : Colors.grey),
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: isEnabled,
        onChanged: _isLoading ? null : (value) => _toggleMethod(method.name, value),
      ),
    );
  }

  Future<void> _toggleMFA(bool enable) async {
    try {
      setState(() => _isLoading = true);
      
      if (enable) {
        // Enable at least one method
        await _mfaService.enableMFAMethod(MFAMethod.sms);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MFA enabled with SMS verification'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Disable all methods
        final enabledMethods = await _mfaService.getEnabledMethods();
        for (final method in enabledMethods) {
          await _mfaService.disableMFAMethod(method);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('MFA disabled'),
            ),
          );
        }
      }
      
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleMethod(String methodName, bool enable) async {
    try {
      setState(() => _isLoading = true);
      
      final method = MFAMethod.values.firstWhere((m) => m.name == methodName);
      
      if (enable) {
        await _mfaService.enableMFAMethod(method);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getMethodDisplayName(methodName)} enabled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await _mfaService.disableMFAMethod(method);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getMethodDisplayName(methodName)} disabled'),
            ),
          );
        }
      }
      
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _generateBackupCodes() async {
    try {
      setState(() => _isLoading = true);
      
      final codes = await _mfaService.generateBackupCodes();
      
      if (mounted) {
        _showBackupCodesDialog(codes);
      }
      
      widget.onRefresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _viewBackupCodes() async {
    // In a real app, this would show existing backup codes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup codes viewing would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showBackupCodesDialog(List<String> codes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Backup Codes Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save these backup codes in a secure location. Each code can only be used once.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: codes.map((code) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I\'ve Saved These Codes'),
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(String method) {
    switch (method) {
      case 'sms':
        return Icons.sms;
      case 'email':
        return Icons.email;
      case 'biometric':
        return Icons.fingerprint;
      case 'authenticatorApp':
        return Icons.smartphone;
      case 'backupCodes':
        return Icons.backup;
      default:
        return Icons.security;
    }
  }

  String _getMethodDisplayName(String method) {
    switch (method) {
      case 'sms':
        return 'SMS Verification';
      case 'email':
        return 'Email Verification';
      case 'biometric':
        return 'Biometric';
      case 'authenticatorApp':
        return 'Authenticator App';
      case 'backupCodes':
        return 'Backup Codes';
      default:
        return method;
    }
  }

  String _getMethodDescription(String method) {
    switch (method) {
      case 'sms':
        return 'Receive verification codes via SMS';
      case 'email':
        return 'Receive verification codes via email';
      case 'biometric':
        return 'Use fingerprint or face recognition';
      case 'authenticatorApp':
        return 'Use Google Authenticator or similar app';
      case 'backupCodes':
        return 'One-time use codes for emergency access';
      default:
        return '';
    }
  }
}
