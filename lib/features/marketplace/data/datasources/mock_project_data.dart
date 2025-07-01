import '../../domain/entities/project.dart';

class MockProjectData {
  static List<Project> get projects => [
    Project(
      id: '1',
      title: 'Organic Rice Farming Initiative',
      description: 'Sustainable organic rice cultivation project in Lagos State using modern irrigation techniques and eco-friendly practices. This project aims to produce premium quality organic rice for both local and export markets.',
      location: 'Lagos State, Nigeria',
      imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=800',
      imageUrls: [
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=800',
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800',
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=800',
      ],
      category: ProjectCategory.crops,
      status: ProjectStatus.active,
      riskLevel: RiskLevel.low,
      targetAmount: 5000000.0, // ₦5M
      raisedAmount: 3200000.0, // ₦3.2M
      minimumInvestment: 50000.0, // ₦50K
      expectedReturn: 18.5, // 18.5% annual return
      durationMonths: 12,
      startDate: DateTime(2024, 1, 15),
      endDate: DateTime(2024, 12, 31),
      createdAt: DateTime(2023, 12, 1),
      farmerId: 'farmer_001',
      farmerName: 'Adebayo Ogundimu',
      farmerAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      investorCount: 127,
      highlights: [
        'Certified organic farming practices',
        'Modern irrigation system',
        'Export market contracts secured',
        '15+ years farming experience',
      ],
      financials: {
        'revenue_projection': 7500000.0,
        'operating_costs': 4200000.0,
        'net_profit': 3300000.0,
        'roi': 18.5,
      },
      documentation: {
        'business_plan': 'available',
        'land_certificate': 'verified',
        'environmental_permit': 'approved',
        'insurance': 'comprehensive',
      },
      isVerified: true,
      rating: 4.8,
      reviewCount: 89,
    ),
    
    Project(
      id: '2',
      title: 'Smart Poultry Farm Expansion',
      description: 'Expansion of automated poultry farm with IoT monitoring systems, climate control, and sustainable feed production. Focus on free-range chicken and organic egg production.',
      location: 'Ogun State, Nigeria',
      imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=800',
      imageUrls: [
        'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=800',
        'https://images.unsplash.com/photo-1551218808-94e220e084d2?w=800',
        'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=800',
      ],
      category: ProjectCategory.livestock,
      status: ProjectStatus.active,
      riskLevel: RiskLevel.medium,
      targetAmount: 8500000.0, // ₦8.5M
      raisedAmount: 6100000.0, // ₦6.1M
      minimumInvestment: 100000.0, // ₦100K
      expectedReturn: 22.0, // 22% annual return
      durationMonths: 18,
      startDate: DateTime(2024, 2, 1),
      endDate: DateTime(2025, 7, 31),
      createdAt: DateTime(2023, 11, 15),
      farmerId: 'farmer_002',
      farmerName: 'Fatima Abdullahi',
      farmerAvatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      investorCount: 203,
      highlights: [
        'IoT-enabled smart monitoring',
        'Automated feeding systems',
        'Free-range organic certification',
        'Established supply chain',
      ],
      financials: {
        'revenue_projection': 12500000.0,
        'operating_costs': 7800000.0,
        'net_profit': 4700000.0,
        'roi': 22.0,
      },
      documentation: {
        'business_plan': 'available',
        'veterinary_permits': 'approved',
        'biosecurity_plan': 'certified',
        'insurance': 'comprehensive',
      },
      isVerified: true,
      rating: 4.6,
      reviewCount: 156,
    ),

    Project(
      id: '3',
      title: 'Catfish Aquaculture Project',
      description: 'Modern catfish farming facility with recirculating aquaculture systems (RAS) technology. Sustainable fish production with minimal environmental impact.',
      location: 'Delta State, Nigeria',
      imageUrl: 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
      imageUrls: [
        'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
        'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800',
        'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      ],
      category: ProjectCategory.aquaculture,
      status: ProjectStatus.upcoming,
      riskLevel: RiskLevel.medium,
      targetAmount: 6200000.0, // ₦6.2M
      raisedAmount: 1800000.0, // ₦1.8M
      minimumInvestment: 75000.0, // ₦75K
      expectedReturn: 25.0, // 25% annual return
      durationMonths: 15,
      startDate: DateTime(2024, 4, 1),
      endDate: DateTime(2025, 6, 30),
      createdAt: DateTime(2024, 1, 10),
      farmerId: 'farmer_003',
      farmerName: 'Emeka Okafor',
      farmerAvatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      investorCount: 67,
      highlights: [
        'RAS technology implementation',
        'Water recycling system',
        'High-density production',
        'Local market demand secured',
      ],
      financials: {
        'revenue_projection': 9500000.0,
        'operating_costs': 5800000.0,
        'net_profit': 3700000.0,
        'roi': 25.0,
      },
      documentation: {
        'business_plan': 'available',
        'water_permit': 'approved',
        'environmental_assessment': 'completed',
        'insurance': 'basic',
      },
      isVerified: true,
      rating: 4.4,
      reviewCount: 43,
    ),

    Project(
      id: '4',
      title: 'Cassava Processing Plant',
      description: 'Modern cassava processing facility for producing high-quality cassava flour, starch, and ethanol. Serving local farmers and export markets.',
      location: 'Oyo State, Nigeria',
      imageUrl: 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=800',
      imageUrls: [
        'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=800',
        'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=800',
        'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=800',
      ],
      category: ProjectCategory.processing,
      status: ProjectStatus.funded,
      riskLevel: RiskLevel.low,
      targetAmount: 12000000.0, // ₦12M
      raisedAmount: 12000000.0, // ₦12M (fully funded)
      minimumInvestment: 200000.0, // ₦200K
      expectedReturn: 20.0, // 20% annual return
      durationMonths: 24,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2025, 12, 31),
      createdAt: DateTime(2023, 10, 1),
      farmerId: 'farmer_004',
      farmerName: 'Kemi Adebisi',
      farmerAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      investorCount: 340,
      highlights: [
        'Modern processing equipment',
        'Multiple product lines',
        'Export contracts secured',
        'Local farmer partnerships',
      ],
      financials: {
        'revenue_projection': 18000000.0,
        'operating_costs': 11500000.0,
        'net_profit': 6500000.0,
        'roi': 20.0,
      },
      documentation: {
        'business_plan': 'available',
        'factory_permit': 'approved',
        'export_license': 'obtained',
        'insurance': 'comprehensive',
      },
      isVerified: true,
      rating: 4.9,
      reviewCount: 267,
    ),

    Project(
      id: '5',
      title: 'Vertical Farming Innovation',
      description: 'Indoor vertical farming system using hydroponics and LED technology for year-round vegetable production. Focus on leafy greens and herbs.',
      location: 'Abuja, FCT',
      imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
      imageUrls: [
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
        'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?w=800',
        'https://images.unsplash.com/photo-1592419044706-39796d40f98c?w=800',
      ],
      category: ProjectCategory.agritech,
      status: ProjectStatus.active,
      riskLevel: RiskLevel.high,
      targetAmount: 15000000.0, // ₦15M
      raisedAmount: 4500000.0, // ₦4.5M
      minimumInvestment: 250000.0, // ₦250K
      expectedReturn: 30.0, // 30% annual return
      durationMonths: 36,
      startDate: DateTime(2024, 3, 1),
      endDate: DateTime(2027, 2, 28),
      createdAt: DateTime(2024, 1, 5),
      farmerId: 'farmer_005',
      farmerName: 'David Okonkwo',
      farmerAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      investorCount: 89,
      highlights: [
        'Cutting-edge technology',
        '90% water savings',
        'Year-round production',
        'Premium market positioning',
      ],
      financials: {
        'revenue_projection': 25000000.0,
        'operating_costs': 16000000.0,
        'net_profit': 9000000.0,
        'roi': 30.0,
      },
      documentation: {
        'business_plan': 'available',
        'technology_patent': 'pending',
        'facility_permit': 'approved',
        'insurance': 'comprehensive',
      },
      isVerified: true,
      rating: 4.2,
      reviewCount: 34,
    ),
  ];

  static List<Project> getProjectsByCategory(ProjectCategory category) {
    return projects.where((project) => project.category == category).toList();
  }

  static List<Project> getProjectsByStatus(ProjectStatus status) {
    return projects.where((project) => project.status == status).toList();
  }

  static List<Project> getActiveProjects() {
    return projects.where((project) => project.status == ProjectStatus.active).toList();
  }

  static Project? getProjectById(String id) {
    try {
      return projects.firstWhere((project) => project.id == id);
    } catch (e) {
      return null;
    }
  }
}
