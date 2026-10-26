# Pbee Collate

A Flutter application for managing student registrations, course details, payment tracking, and announcements. The application uses Supabase for authentication, database storage, and file storage, providing separate interfaces for administrators and students.

## Features

### Authentication and Access Control
- User registration and login using email and password.
- Role-based routing that directs users to either the Admin Dashboard or the Student Dashboard based on their account role (`admin` or `user`).

### Admin Dashboard
- **User Management**: View registered students, inspect individual profile details, edit student information, and archive or restore student records.
- **Payment Tracking**: Record and monitor amounts paid by students against course costs.
- **Course Management**: Add, update, and remove courses along with pricing information.
- **Notifications**: Broadcast notifications to registered users.
- **Analytics**: View statistics on user registrations and payment collections.

### User Dashboard
- **Profile Overview**: View personal registration details, course enrollment, and payment status.
- **Notifications**: Read announcements sent by administrators.

---

## Installation Guide

### Prerequisites
- **Flutter SDK**: Version 3.24.0 or later (Dart SDK `^3.9.2`).
- **Development Environment**: VS Code, Android Studio, or any preferred editor with Flutter and Dart extensions.
- **Platform Toolchain**:
  - Android SDK for Android devices or emulators.
  - Visual Studio with C++ tools for Windows desktop.
  - Chrome or Edge for web.
- **Supabase Account**: A Supabase project with authentication, database, and storage configured.

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/<your-username>/pbee_collate.git
cd pbee_collate
```

---

### Step 2: Install Dependencies
Fetch the project's required packages:
```bash
flutter pub get
```

---

### Step 3: Configure Supabase

1. Open `lib/main.dart`.
2. Locate the `Supabase.initialize` call:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_PROJECT_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```
3. Replace the placeholder values with your project's URL and public anonymous key found in your Supabase project dashboard under **Project Settings > API**.

---

### Step 4: Supabase Database Setup

Ensure the following tables and storage buckets are configured in your Supabase project:

#### Tables
- **`profiles`**
  - `id`: UUID (Primary Key)
  - `user_id`: UUID (Foreign Key to `auth.users`)
  - `first_name`: text
  - `last_name`: text
  - `email`: text
  - `address`: text
  - `phone`: text
  - `course`: text
  - `notes`: text
  - `role`: text (e.g. `'admin'` or `'user'`)
  - `avatar_url`: text (nullable)
  - `amount_paid`: numeric / float8 (default: `0.0`)
  - `created_at`: timestamptz (default: `now()`)

- **`courses`**
  - `id`: UUID or bigint (Primary Key, auto-generated)
  - `title`: text
  - `price`: numeric / float8

- **`notifications`**
  - `id`: UUID or bigint (Primary Key, auto-generated)
  - `title`: text
  - `message`: text
  - `created_at`: timestamptz (default: `now()`)

- **`archived_profiles`**
  - Stores archived student profile records with the same structure as `profiles`.

#### Storage
- Create a storage bucket named `avatars` with public read access if user profile images will be uploaded.

---

### Step 5: Run the Application

Start the app on an active device or emulator:
```bash
flutter run
```

To target a specific platform:
```bash
# Android
flutter run -d android
```

---

### Step 6: Build for Release (Optional)

Generate build artifacts for your target platform:
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```
