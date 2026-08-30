# Splitsies

Splitsies automatically handles your money splits and generates the payment QRs for your conviniece

*An app for when you wanna make them pay*

---

## Features

**Core Features**
- expense splitting with equal split calculation
- Split tracking and balance management
- QR code generation direct UPI payments
- Activity log to track all transactions
- Local storage persistence
- Input validation for expense entries

**Technical Highlights**
- Frag shaders instead of painters in the background for fast rendering
- state management with RxDart BehaviorSubjects as theyre easier and less annoying than providers
- Dependency injection with GetIt service locator pattern

---

## Tech Stack

### Frontend Framework
- **Flutter**

### State Management & DI
- **RxDart**
- **GetIt** 

### Core Packages
- **QR Flutter** 
- **Mobile Scanner** 
- **Shared Preferences** 
- **URL Launcher**
- **Intl**


---

## How to Run

### Prerequisites
- **Flutter SDK** 3.12 or higher
- **Dart SDK** 3.12 or higher
- **Xcode** (for iOS) or **Android Studio** (for Android)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd splitsies
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Build shaders** (if needed)
   ```bash
   flutter clean
   flutter pub get
   ```

### Run the App

**For iOS:**
Beware I did NOT test on a mac 
```bash
flutter run -d ios
# Or specify a device
flutter run -d "iPhone 14"
```

**For Android:**
```bash
flutter run -d android
# Or specify a device
flutter run -d <device-id>
```

**On any platform (auto-selects connected device):**
```bash
flutter run
```

### Build for Release

**iOS:**
Beware I did NOT test on a mac 
```bash
flutter build ios --release
# Or create an IPA for distribution
flutter build ipa
```

**Android:**
```bash
flutter build apk --release
# Or build as App Bundle
flutter build appbundle --release
```

---

## Usage Guide

### Adding an Expense
1. Add Expense button on homescreen
2. Enter amount and description
3. Add participants involved
4. Save

### Viewing Balances
- On the homescreen the amount of money everyone has contributed to the group is shown

### Making Payments via QR
1. When an activity is pressed, the QR for each participant is shown and they can pay by scanning it

### Activity Log
- View all transactions chronologically
- See payment history and settlements
- Tap any entry for full details

---

## Architecture Decisions

### Why RxDart + GetIt?
- Because the provider architecture is quite cumbersome and im familiar with this

### Why Custom Shaders?
- Normal painters lagged since their taget was the whole bg

---

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## Support

For issues and questions, please open an issue on the repository.
