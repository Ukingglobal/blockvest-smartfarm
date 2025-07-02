import 'package:flutter/material.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/di/injection_container.dart' as di;

class BiometricSettingsCard extends StatefulWidget {
  final Map<String, dynamic> biometricStatus;
  final VoidCallback onRefresh;

  const BiometricSettingsCard({
    super.key,
    required this.biometricStatus,
    required this.onRefresh,
  });

  @override
  State<BiometricSettingsCard> createState() => _BiometricSettingsCardState();
}

class _BiometricSettingsCardState extends State<BiometricSettingsCard> {
  late final BiometricService _biometricService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _biometricService = di.sl<BiometricService>();
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.biometricStatus['isAvailable'] ?? false;
    final availableTypes = List<String>.from(
      widget.biometricStatus['availableTypes'] ?? [],
    );
    final enabledLevels = Map<String, bool>.from(
      widget.biometricStatus['enabledLevels'] ?? {},
    );
    final failedAttempts = widget.biometricStatus['failedAttempts'] ?? 0;
    final isLocked = widget.biometricStatus['isLocked'] ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fingerprint,
                  color: isAvailable ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Biometric Authentication',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (!isAvailable) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Biometric authentication is not available on this device',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Available biometric types
              if (availableTypes.isNotEmpty) ...[
                Text(
                  'Available Methods:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: availableTypes.map((type) => Chip(
                    label: Text(_getBiometricTypeDisplayName(type)),
                    avatar: Icon(
                      _getBiometricTypeIcon(type),
                      size: 16,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],
              
              // Security levels
              Text(
                'Authentication Levels:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildAuthLevelTile(
                'Low (App Access)',
                AuthenticationLevel.low,
                enabledLevels['low'] ?? false,
                'Quick app unlock and basic features',
              ),
              _buildAuthLevelTile(
                'Medium (Wallet Operations)',
                AuthenticationLevel.medium,
                enabledLevels['medium'] ?? false,
                'Investment transactions and wallet access',
              ),
              _buildAuthLevelTile(
                'High (Critical Operations)',
                AuthenticationLevel.high,
                enabledLevels['high'] ?? false,
                'Large transactions and sensitive settings',
              ),
              
              if (isLocked) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Biometric authentication is temporarily locked due to $failedAttempts failed attempts',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testBiometric,
                  icon: const Icon(Icons.touch_app),
                  label: const Text('Test Biometric'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAuthLevelTile(
    String title,
    AuthenticationLevel level,
    bool isEnabled,
    String description,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(description),
      trailing: Switch(
        value: isEnabled,
        onChanged: _isLoading ? null : (value) => _toggleAuthLevel(level, value),
      ),
    );
  }

  Future<void> _toggleAuthLevel(AuthenticationLevel level, bool enable) async {
    try {
      setState(() => _isLoading = true);
      
      if (enable) {
        // Test biometric first
        final canAuthenticate = await _biometricService.authenticateWithBiometrics(
          reason: 'Enable biometric authentication for ${level.name} level',
          level: level,
        );
        
        if (canAuthenticate) {
          await _biometricService.enableBiometricForLevel(level);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Biometric authentication enabled for ${level.name} level'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        await _biometricService.disableBiometricForLevel(level);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Biometric authentication disabled for ${level.name} level'),
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

  Future<void> _testBiometric() async {
    try {
      setState(() => _isLoading = true);
      
      final success = await _biometricService.authenticateWithBiometrics(
        reason: 'Test biometric authentication',
        level: AuthenticationLevel.medium,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Biometric authentication successful!' 
                  : 'Biometric authentication failed',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
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

  String _getBiometricTypeDisplayName(String type) {
    switch (type) {
      case 'fingerprint':
        return 'Fingerprint';
      case 'face':
        return 'Face ID';
      case 'iris':
        return 'Iris';
      default:
        return type;
    }
  }

  IconData _getBiometricTypeIcon(String type) {
    switch (type) {
      case 'fingerprint':
        return Icons.fingerprint;
      case 'face':
        return Icons.face;
      case 'iris':
        return Icons.visibility;
      default:
        return Icons.security;
    }
  }
}
