import 'package:flutter/material.dart';
import '../../../../core/services/kyc_service.dart';
import '../../../../core/di/injection_container.dart' as di;

class KYCStatusCard extends StatefulWidget {
  final Map<String, dynamic> kycSummary;
  final VoidCallback onRefresh;

  const KYCStatusCard({
    super.key,
    required this.kycSummary,
    required this.onRefresh,
  });

  @override
  State<KYCStatusCard> createState() => _KYCStatusCardState();
}

class _KYCStatusCardState extends State<KYCStatusCard> {
  late final KYCService _kycService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _kycService = di.sl<KYCService>();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.kycSummary['status'] ?? 'notStarted';
    final currentStep = widget.kycSummary['currentStep'] ?? 'personalInfo';
    final completionPercentage = (widget.kycSummary['completionPercentage'] ?? 0.0) as double;
    final hasPersonalInfo = widget.kycSummary['hasPersonalInfo'] ?? false;
    final documentsCount = widget.kycSummary['documentsCount'] ?? 0;
    final hasFaceVerification = widget.kycSummary['hasFaceVerification'] ?? false;
    final nextSteps = List<String>.from(widget.kycSummary['nextSteps'] ?? []);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Text(
                  'KYC Verification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDisplayName(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: completionPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getStatusColor(status),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(completionPercentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Current step
            Text(
              'Current Step: ${_getStepDisplayName(currentStep)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            
            // Progress checklist
            _buildProgressItem(
              'Personal Information',
              hasPersonalInfo,
              Icons.person,
            ),
            _buildProgressItem(
              'Document Upload',
              documentsCount > 0,
              Icons.upload_file,
              subtitle: documentsCount > 0 ? '$documentsCount document(s) uploaded' : null,
            ),
            _buildProgressItem(
              'Face Verification',
              hasFaceVerification,
              Icons.face,
            ),
            _buildProgressItem(
              'Address Verification',
              status == 'pendingReview' || status == 'approved',
              Icons.location_on,
            ),
            
            const SizedBox(height: 16),
            
            // Next steps
            if (nextSteps.isNotEmpty) ...[
              Text(
                'Next Steps:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...nextSteps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            
            // Action buttons
            if (status == 'notStarted' || status == 'inProgress') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _startKYCProcess,
                  icon: const Icon(Icons.start),
                  label: Text(
                    status == 'notStarted' ? 'Start KYC Process' : 'Continue KYC',
                  ),
                ),
              ),
            ] else if (status == 'rejected') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _restartKYCProcess,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart KYC Process'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ),
            ],
            
            if (_isLoading) ...[
              const SizedBox(height: 8),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String title,
    bool isCompleted,
    IconData icon, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCompleted ? Colors.black : Colors.grey[600],
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startKYCProcess() async {
    try {
      setState(() => _isLoading = true);
      
      // Navigate to KYC flow (would be implemented)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC process would start here'),
            backgroundColor: Colors.blue,
          ),
        );
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

  Future<void> _restartKYCProcess() async {
    try {
      setState(() => _isLoading = true);
      
      await _kycService.clearKYCData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC data cleared. You can start the process again.'),
            backgroundColor: Colors.green,
          ),
        );
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.verified;
      case 'pendingReview':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.error;
      case 'inProgress':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pendingReview':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'inProgress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'notStarted':
        return 'Not Started';
      case 'inProgress':
        return 'In Progress';
      case 'pendingReview':
        return 'Pending Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      default:
        return status;
    }
  }

  String _getStepDisplayName(String step) {
    switch (step) {
      case 'personalInfo':
        return 'Personal Information';
      case 'documentUpload':
        return 'Document Upload';
      case 'faceVerification':
        return 'Face Verification';
      case 'addressVerification':
        return 'Address Verification';
      case 'completed':
        return 'Completed';
      default:
        return step;
    }
  }
}
