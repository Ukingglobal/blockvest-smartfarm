import 'package:equatable/equatable.dart';

enum ProjectStatus {
  upcoming,
  active,
  funded,
  completed,
  cancelled,
}

enum ProjectCategory {
  crops,
  livestock,
  aquaculture,
  forestry,
  agritech,
  processing,
}

enum RiskLevel {
  low,
  medium,
  high,
}

class Project extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final List<String> imageUrls;
  final ProjectCategory category;
  final ProjectStatus status;
  final RiskLevel riskLevel;
  final double targetAmount;
  final double raisedAmount;
  final double minimumInvestment;
  final double expectedReturn;
  final int durationMonths;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String farmerId;
  final String farmerName;
  final String farmerAvatar;
  final int investorCount;
  final List<String> highlights;
  final Map<String, dynamic> financials;
  final Map<String, dynamic> documentation;
  final bool isVerified;
  final double rating;
  final int reviewCount;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.imageUrls,
    required this.category,
    required this.status,
    required this.riskLevel,
    required this.targetAmount,
    required this.raisedAmount,
    required this.minimumInvestment,
    required this.expectedReturn,
    required this.durationMonths,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.farmerId,
    required this.farmerName,
    required this.farmerAvatar,
    required this.investorCount,
    required this.highlights,
    required this.financials,
    required this.documentation,
    required this.isVerified,
    required this.rating,
    required this.reviewCount,
  });

  double get fundingProgress => raisedAmount / targetAmount;
  
  bool get isFullyFunded => raisedAmount >= targetAmount;
  
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  String get categoryDisplayName {
    switch (category) {
      case ProjectCategory.crops:
        return 'Crops';
      case ProjectCategory.livestock:
        return 'Livestock';
      case ProjectCategory.aquaculture:
        return 'Aquaculture';
      case ProjectCategory.forestry:
        return 'Forestry';
      case ProjectCategory.agritech:
        return 'AgriTech';
      case ProjectCategory.processing:
        return 'Processing';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ProjectStatus.upcoming:
        return 'Upcoming';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.funded:
        return 'Funded';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get riskLevelDisplayName {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? imageUrl,
    List<String>? imageUrls,
    ProjectCategory? category,
    ProjectStatus? status,
    RiskLevel? riskLevel,
    double? targetAmount,
    double? raisedAmount,
    double? minimumInvestment,
    double? expectedReturn,
    int? durationMonths,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    String? farmerId,
    String? farmerName,
    String? farmerAvatar,
    int? investorCount,
    List<String>? highlights,
    Map<String, dynamic>? financials,
    Map<String, dynamic>? documentation,
    bool? isVerified,
    double? rating,
    int? reviewCount,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      status: status ?? this.status,
      riskLevel: riskLevel ?? this.riskLevel,
      targetAmount: targetAmount ?? this.targetAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      minimumInvestment: minimumInvestment ?? this.minimumInvestment,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      durationMonths: durationMonths ?? this.durationMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerAvatar: farmerAvatar ?? this.farmerAvatar,
      investorCount: investorCount ?? this.investorCount,
      highlights: highlights ?? this.highlights,
      financials: financials ?? this.financials,
      documentation: documentation ?? this.documentation,
      isVerified: isVerified ?? this.isVerified,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        imageUrl,
        imageUrls,
        category,
        status,
        riskLevel,
        targetAmount,
        raisedAmount,
        minimumInvestment,
        expectedReturn,
        durationMonths,
        startDate,
        endDate,
        createdAt,
        farmerId,
        farmerName,
        farmerAvatar,
        investorCount,
        highlights,
        financials,
        documentation,
        isVerified,
        rating,
        reviewCount,
      ];
}
