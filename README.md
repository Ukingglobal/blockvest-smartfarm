# BlockVest SmartFarm 🌾

**Blockchain-powered agricultural real estate investment platform**

BlockVest is a revolutionary Flutter mobile application that democratizes agricultural investment through blockchain technology, enabling users to invest in agricultural projects with transparency, security, and real-time tracking.

## 🚀 Features

### ✅ Completed (MVP Phase)
- **🔐 Authentication System**: Secure login/register with Supabase
- **📱 Clean Architecture**: BLoC pattern with dependency injection
- **🏪 Marketplace**: Browse agricultural investment projects
- **🔍 Search & Filter**: Advanced project filtering and sorting
- **📊 Project Details**: Comprehensive project information and metrics
- **👤 User Profiles**: KYC verification and user management
- **🎨 Modern UI**: Material Design 3 with agricultural theme
- **🌐 Multi-language**: English, Spanish, French support
- **📱 Responsive Design**: Works on mobile, tablet, and web

### 🚧 In Development
- **💰 Investment Flow**: Blockchain-based investment transactions
- **🔗 Web3 Integration**: Supra blockchain connectivity
- **📈 Portfolio Tracking**: Real-time investment monitoring
- **🏛️ DAO Governance**: Decentralized decision making
- **🌱 Sustainability Metrics**: Environmental impact tracking

## 🏗️ Architecture

```
lib/
├── core/                    # Core functionality
│   ├── constants/          # App constants and configuration
│   ├── di/                 # Dependency injection
│   ├── router/             # Navigation routing
│   └── theme/              # App theming
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── dashboard/          # Main dashboard
│   ├── marketplace/        # Project marketplace
│   ├── wallet/             # Crypto wallet
│   ├── governance/         # DAO governance
│   └── settings/           # User settings
└── main.dart              # App entry point
```

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.24.5
- **State Management**: BLoC Pattern
- **Backend**: Supabase (Auth, Database, Storage)
- **Blockchain**: Supra Network
- **Navigation**: GoRouter
- **DI**: GetIt + Injectable
- **UI**: Material Design 3
- **Localization**: Flutter Intl

## 📱 Screenshots

### Marketplace
- Browse agricultural investment projects
- Advanced search and filtering
- Project cards with funding progress
- Category-based organization

### Project Details
- Comprehensive project information
- Financial projections and metrics
- Farmer profiles and verification
- Investment tracking and documentation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.5 or higher
- Dart SDK 3.5.4 or higher
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Ukingglobal/blockvest-smartfarm.git
   cd blockvest-smartfarm
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a Supabase project at [supabase.com](https://supabase.com)
   - Update `lib/core/constants/app_constants.dart` with your credentials

4. **Run the app**
   ```bash
   # For web
   flutter run -d chrome

   # For mobile
   flutter run
   ```

## 🌱 Project Categories

- **🌾 Crops**: Rice, wheat, corn, and other grain farming
- **🐄 Livestock**: Cattle, poultry, and animal husbandry
- **🐟 Aquaculture**: Fish farming and marine agriculture
- **🌳 Forestry**: Sustainable forestry and timber projects
- **🔬 AgriTech**: Technology-driven farming solutions
- **🏭 Processing**: Food processing and value addition

## 💰 Investment Features

- **Minimum Investment**: Starting from ₦50,000
- **Expected Returns**: 15-30% annual returns
- **Risk Assessment**: Low, Medium, High risk categorization
- **Transparency**: Real-time project updates and financials
- **Verification**: KYC-compliant farmer and project verification

## 🔐 Security

- **Blockchain Security**: Immutable transaction records
- **KYC Verification**: Identity verification for all users
- **Smart Contracts**: Automated investment and payout logic
- **Secure Storage**: Encrypted local storage for sensitive data

## 🌍 Sustainability

BlockVest promotes sustainable agriculture through:
- Environmental impact tracking
- Sustainable farming practice incentives
- Carbon footprint monitoring
- Biodiversity conservation projects

## 📈 Roadmap

### Phase 1: MVP (Current)
- ✅ Core app architecture
- ✅ Authentication system
- ✅ Marketplace functionality
- ✅ Project browsing and details

### Phase 2: Blockchain Integration
- 🚧 Web3 wallet integration
- 🚧 Smart contract deployment
- 🚧 Investment transactions
- 🚧 Portfolio tracking

### Phase 3: Advanced Features
- 📅 DAO governance system
- 📅 AI-powered project recommendations
- 📅 IoT integration for real-time monitoring
- 📅 DeFi yield farming features

### Phase 4: Scale & Expansion
- 📅 Multi-country expansion
- 📅 Advanced analytics dashboard
- 📅 Mobile app optimization
- 📅 Enterprise partnerships

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Team

- **Lead Developer**: King ([@Ukingglobal](https://github.com/Ukingglobal))
- **Architecture**: Clean Architecture with BLoC pattern
- **Design**: Material Design 3 with agricultural theme

## 📞 Contact

- **GitHub**: [@Ukingglobal](https://github.com/Ukingglobal)
- **Project Link**: [https://github.com/Ukingglobal/blockvest-smartfarm](https://github.com/Ukingglobal/blockvest-smartfarm)

---

**Made with ❤️ for sustainable agriculture and financial inclusion**
