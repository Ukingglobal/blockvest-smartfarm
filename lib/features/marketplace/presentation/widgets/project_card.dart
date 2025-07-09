import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 0,
    );

import '../../../../core/theme/app_theme.dart'; // Import AppTheme

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_NG', // Consider making this locale dynamic based on settings
      symbol: '₦',
      decimalDigits: 0,
    );

    return Card(
      // Card styling from AppTheme.mainTheme.cardTheme will apply (bg color, shape, elevation)
      clipBehavior: Clip.antiAlias, // Ensures content respects card's border radius
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                project.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.secondaryCardsModules.withOpacity(0.5),
                    child: const Icon(
                      Icons.agriculture_outlined,
                      size: 48,
                      color: AppTheme.textIconColor,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.0,
                      color: AppTheme.accentCTA,
                    ),
                  );
                },
              ),
            ),

            // Scrim for text legibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0), // More transparent at the top
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8), // Darker at the bottom for text
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // Information Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important for Stack positioning
                  children: [
                    Text(
                      project.title, // Farm Name
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.textIconColor, // Ensure text is light on dark scrim
                            fontWeight: FontWeight.bold,
                            shadows: [ // Optional: subtle shadow for better legibility
                              Shadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.5))
                            ]
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${project.expectedReturn.toStringAsFixed(1)}% ROI', // ROI Percentage
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.accentCTA, // Use accent for ROI
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(blurRadius: 1.0, color: Colors.black.withOpacity(0.5))]
                              ),
                        ),
                        Text(
                          // Funding Goal (simplified for this card)
                          // More detailed progress on ProjectDetailsPage
                          'Goal: ${currencyFormatter.format(project.targetAmount)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textIconColor.withOpacity(0.85),
                                shadows: [Shadow(blurRadius: 1.0, color: Colors.black.withOpacity(0.5))]
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    // Simplified progress bar
                    LinearProgressIndicator(
                      value: project.fundingProgress,
                      backgroundColor: AppTheme.textIconColor.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCTA),
                      minHeight: 6, // Make it a bit thicker
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

  // _buildMetricItem, _getStatusColor, _getRiskColor are removed as they are
  // not part of the new simplified card design based on the mockup.
  // This information would be on the project details page.

  // Widget _buildMetricItem( // Old code, remove
  // Color _getStatusColor(ProjectStatus status) { // Old code, remove
  // Color _getRiskColor(RiskLevel riskLevel) { // Old code, remove
}
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.upcoming:
        return Colors.blue;
      case ProjectStatus.active:
        return Colors.green;
      case ProjectStatus.funded:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.purple;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }
}
