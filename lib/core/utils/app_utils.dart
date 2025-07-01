import 'dart:math';
import 'package:intl/intl.dart';

class AppUtils {
  // Number Formatting
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  static String formatTokenAmount(double amount, {String symbol = 'BLOCKVEST'}) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M $symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K $symbol';
    } else {
      return '${amount.toStringAsFixed(2)} $symbol';
    }
  }

  static String formatPercentage(double percentage, {int decimalPlaces = 2}) {
    return '${percentage.toStringAsFixed(decimalPlaces)}%';
  }

  static String formatCompactNumber(double number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toStringAsFixed(0);
    }
  }

  // Date Formatting
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  static String formatDuration(int days) {
    if (days >= 365) {
      final years = (days / 365).floor();
      final remainingDays = days % 365;
      if (remainingDays == 0) {
        return '$years year${years == 1 ? '' : 's'}';
      } else {
        return '$years year${years == 1 ? '' : 's'} ${remainingDays} day${remainingDays == 1 ? '' : 's'}';
      }
    } else if (days >= 30) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      if (remainingDays == 0) {
        return '$months month${months == 1 ? '' : 's'}';
      } else {
        return '$months month${months == 1 ? '' : 's'} ${remainingDays} day${remainingDays == 1 ? '' : 's'}';
      }
    } else {
      return '$days day${days == 1 ? '' : 's'}';
    }
  }

  // Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    // Nigerian phone number format
    return RegExp(r'^(\+234|0)[789][01]\d{8}$').hasMatch(phoneNumber);
  }

  // Random Data Generation for Mock Data
  static double generateRandomROI(String cropType) {
    final random = Random();
    final roiRange = {
      'Rice': {'min': 15.0, 'max': 25.0},
      'Maize': {'min': 18.0, 'max': 28.0},
      'Cassava': {'min': 12.0, 'max': 20.0},
      'Yam': {'min': 20.0, 'max': 35.0},
      'Cocoa': {'min': 25.0, 'max': 40.0},
      'Palm Oil': {'min': 30.0, 'max': 45.0},
      'Plantain': {'min': 16.0, 'max': 24.0},
      'Beans': {'min': 14.0, 'max': 22.0},
      'Millet': {'min': 13.0, 'max': 21.0},
      'Sorghum': {'min': 15.0, 'max': 23.0},
      'Groundnut': {'min': 17.0, 'max': 26.0},
      'Cotton': {'min': 22.0, 'max': 32.0},
    };

    final range = roiRange[cropType] ?? {'min': 15.0, 'max': 25.0};
    final min = range['min']!;
    final max = range['max']!;
    
    return min + random.nextDouble() * (max - min);
  }

  static String generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        12,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // GPS Coordinates for Nigerian States (approximate centers)
  static Map<String, Map<String, double>> getNigerianStateCoordinates() {
    return {
      'Lagos': {'lat': 6.5244, 'lng': 3.3792},
      'Kano': {'lat': 12.0022, 'lng': 8.5920},
      'Kaduna': {'lat': 10.5105, 'lng': 7.4165},
      'Oyo': {'lat': 8.0000, 'lng': 4.0000},
      'Rivers': {'lat': 4.8156, 'lng': 6.9778},
      'Bayelsa': {'lat': 4.6684, 'lng': 6.2316},
      'Akwa Ibom': {'lat': 5.0077, 'lng': 7.8536},
      'Imo': {'lat': 5.4951, 'lng': 7.0251},
      'Delta': {'lat': 5.8903, 'lng': 5.6803},
      'Edo': {'lat': 6.3350, 'lng': 5.6037},
      'Plateau': {'lat': 9.2182, 'lng': 9.5179},
      'Cross River': {'lat': 5.9631, 'lng': 8.3250},
      'Osun': {'lat': 7.5629, 'lng': 4.5200},
      'Ondo': {'lat': 7.2500, 'lng': 5.2500},
      'Ogun': {'lat': 7.1608, 'lng': 3.3476},
      'Kwara': {'lat': 8.9669, 'lng': 4.3828},
      'Benue': {'lat': 7.1906, 'lng': 8.1340},
      'Niger': {'lat': 10.4806, 'lng': 6.5056},
      'Kebbi': {'lat': 12.4539, 'lng': 4.1975},
      'Sokoto': {'lat': 13.0059, 'lng': 5.2476},
    };
  }

  // Color utilities
  static String getROIColor(double roi) {
    if (roi >= 30) return '#4CAF50'; // High ROI - Green
    if (roi >= 20) return '#8BC34A'; // Medium-High ROI - Light Green
    if (roi >= 15) return '#FFC107'; // Medium ROI - Amber
    return '#FF9800'; // Low ROI - Orange
  }

  static String getRiskLevel(double roi) {
    if (roi >= 35) return 'High Risk';
    if (roi >= 25) return 'Medium-High Risk';
    if (roi >= 20) return 'Medium Risk';
    if (roi >= 15) return 'Low-Medium Risk';
    return 'Low Risk';
  }
}
