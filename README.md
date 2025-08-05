# Pranay Funds Bank

<p align="center">
  <img src="lib/images/logo.svg" alt="Pranay Funds Logo" width="150"/>
</p>

<p align="center">
  <strong>A sleek, modern, and secure Flutter application for managing personal funds, investments, and transactions. Built with Material 3, expressive design, and a custom backend.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen.svg" alt="Platform">
</p>

---

## ✨ Key Features

* **🔐 Secure Authentication**: Robust login flow with username persistence, MPIN, and biometric (fingerprint) authentication.
* **📊 Dynamic Dashboard**: A beautiful and interactive home screen that displays the real-time account balance and a summary of recent activity.
* **💸 Manual Transactions**: An intuitive, multi-step process for users to submit manual "Add Funds" and "Withdrawal" requests with transaction references.
* **📄 Detailed Statements**: A comprehensive statement screen with powerful filtering options, including by month, year, and custom date range.
* 🎨 **Expressive Material 3 UI**: Crafted with the latest Material You design principles, featuring dynamic color, smooth animations, and a clean, user-friendly interface.
* **🔄 Pending Approvals**: Intelligent UI that shows users the status of their pending deposits and withdrawals, ensuring transparency.

---

## 📱 Screenshots

<p align="center">
  <img src="https://i.imgur.com/your-login-screenshot-id.png" alt="Login Screen" width="200"/>
  <img src="https://i.imgur.com/your-home-screenshot-id.png" alt="Home Screen" width="200"/>
  <img src="https://i.imgur.com/your-statement-screenshot-id.png" alt="Statement Screen" width="200"/>
  <img src="https://i.imgur.com/your-addfunds-screenshot-id.png" alt="Add Funds Screen" width="200"/>
</p>

---

## 🚀 Technologies & Packages

This project is a showcase of modern Flutter development.

* **Framework**: Flutter
* **Language**: Dart
* **State Management**: `StatefulWidget` & `FutureBuilder`
* **UI Design**: Material 3 (Material You)
* **API Communication**: `http` package
* **Local Storage**: `shared_preferences` for session persistence
* **Authentication**: `local_auth` for biometric login
* **Styling**: `google_fonts` for beautiful typography
* **Vector Graphics**: `flutter_svg` for crisp, scalable assets

---

## ⚙️ Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* **Flutter SDK**: Ensure you have Flutter installed. [Installation Guide](https://flutter.dev/docs/get-started/install)
* **Code Editor**: VS Code or Android Studio with the Flutter plugin.
* **Backend API**: This project requires the custom Pranay Funds API to be running and accessible.

### Installation

1.  **Clone the repo**
    ```sh
    git clone [https://github.com/weberq/Pranay-Funds](https://github.com/weberq/Pranay-Funds)
    ```
2.  **Navigate to the project directory**
    ```sh
    cd pranay-funds
    ```
3.  **Install packages**
    ```sh
    flutter pub get
    ```
4.  **Configure the API**
    * Open `lib/configs/app_config.dart`.
    * Update the `baseUrl` and `apiKey` with your API details.
5.  **Run the app**
    ```sh
    flutter run
    ```

---

## 🏛️ API Backend

This Flutter application is powered by a custom PHP/MySQL backend that handles all business logic, including user authentication, account management, and transaction processing. All endpoints require an `X-API-KEY` for secure communication.

---

## 🗺️ Roadmap

* [ ] Implement real-time push notifications for transaction approvals.
* [ ] Add a dedicated "Withdraw Funds" screen.
* [ ] Introduce data visualization with charts for financial insights.
* [ ] Add light and dark theme toggles.
* [ ] Implement unit and widget tests.

---

## 🤝 Contact & Acknowledgments

This app was lovingly crafted and designed.

**WeberQ Global Pvt Ltd**

* GitHub: [@weberq](https://github.com/weberq)
* LinkedIn: [company/weberq](https://www.linkedin.com/company/weberq)

A big thank you to the Flutter community and the creators of the open-source packages that made this project possible.