# 🏙️ City Life — Urban Companion App

> A comprehensive Flutter mobile application that enhances urban living by connecting residents with city services, community, events, jobs, and real-time information.

---

## 📱 Screenshots Overview

The app features a deep navy + electric teal design system with full dark/light mode support across all screens.

---

## 🚀 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x (StateNotifier + Provider) |
| Navigation | GoRouter 13.x (StatefulShellRoute) |
| Local Database | SQLite via sqflite |
| Authentication | Firebase Auth |
| Real-time Data | Firebase Firestore (scaffolded) |
| Maps | Google Maps Flutter |
| Location | Geolocator |
| Media | image_picker |
| HTTP | Dio + http |
| Fonts | Sora (display) + DM Sans (body) |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp + theme
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Full color palette (light + dark)
│   │   ├── app_typography.dart        # Sora + DM Sans type scale
│   │   └── app_spacing.dart           # 4pt grid spacing system
│   ├── theme/
│   │   ├── app_theme.dart             # Light + dark ThemeData
│   │   └── theme_provider.dart        # Riverpod theme state (persisted)
│   ├── navigation/
│   │   ├── app_router.dart            # GoRouter with StatefulShellRoute
│   │   └── app_routes.dart            # Route name constants
│   ├── database/
│   │   ├── database_helper.dart       # SQLite singleton + migrations
│   │   └── database_constants.dart    # Table/column name constants
│   └── utils/
│       └── scaffold_key.dart          # Global key for drawer access
│
├── features/
│   ├── onboarding/                    # ✅ Step 1
│   ├── auth/                          # ✅ Step 2
│   ├── home/                          # ✅ Step 3
│   ├── amenities/                     # ✅ Step 4
│   ├── events/                        # ✅ Step 5
│   ├── community/                     # ✅ Step 6
│   ├── jobs/                          # ✅ Step 7
│   ├── reporting/                     # ✅ Step 8
│   ├── profile/                       # ✅ Step 9
│   └── news/                          # ✅ Step 10
│
└── shared/
    ├── widgets/
    │   ├── cl_bottom_nav.dart         # Bottom nav + side drawer
    │   ├── cl_button.dart             # Reusable button (4 variants)
    │   └── cl_text_field.dart         # Reusable text input
    └── models/
        └── user_model.dart            # Base user model
```

---

## 🗃️ Database Schema (SQLite — v2)

| Table | Purpose |
|---|---|
| `users` | Auth profiles cached locally |
| `amenities` | City services (hospitals, schools, etc.) |
| `events` | City events with RSVP |
| `news` | City news articles |
| `posts` | Community social feed posts |
| `comments` | Post replies |
| `jobs` | Job listings |
| `reports` | City issue reports |
| `notifications` | App notifications |
| `bookmarks` | Saved items across all modules |
| `community_groups` | Community groups |
| `messages` | Direct messages |

---

## ✅ Features Built (Steps 1–10)

### Step 1 — Project Foundation
- Clean Architecture folder structure
- Design system: colors, typography (Sora + DM Sans), spacing constants
- Light and dark `ThemeData` with Riverpod-persisted theme toggle
- GoRouter with `StatefulShellRoute` for 5-tab bottom navigation
- SQLite database with full schema, migrations, and seed data
- 3-screen animated onboarding flow

### Step 2 — Authentication
- Email/Password registration and login via Firebase Auth
- Form validation on all fields
- Forgot password with email reset link
- Role-based accounts (Individual / Business)
- User profile cached to SQLite after login
- Auto-redirect for authenticated users

### Step 3 — Home Dashboard
- Time-based greeting (morning/afternoon/evening)
- Weather card (mock data, upgradeable to real API)
- Emergency SOS banner with confirmation dialog
- 8-item Quick Actions grid linking to all modules
- Featured events horizontal scroll
- City news preview (live from DB)
- Pull-to-refresh
- Avatar tap opens side drawer

### Step 4 — Amenities & Explore
- List/Map toggle view
- Real-time search across name, address, category
- 8-category filter chips
- 15 seeded real Nairobi amenities with coordinates
- Amenity cards with Open/Closed badge, star rating, Call + Directions + Save
- Google Maps view with marker tap → detail card
- My Location FAB

### Step 5 — Events Module
- Events listing with search + 9-category filter
- 8 seeded upcoming events (dates relative to today)
- Event cards with color-coded category banner, free/paid badge, RSVP button
- Event detail screen with hero gradient, capacity progress bar
- RSVP state persisted in Riverpod session

### Step 6 — Community (Twitter/Threads style)
- Feed, Groups, Messages tab layout
- For You / County / Constituency feed filter
- 20 Kenyan counties filter dropdown
- Post cards with like, repost, comment actions
- Post detail with threaded replies and reply input
- Create post bottom sheet with county tag
- 5 seeded community groups by county
- Messages tab with conversation list and unread badges

### Step 7 — Jobs Module
- Dual filter: category chips + job type pills
- Real-time search across title, company, skills
- 8 seeded jobs from real Kenyan companies
- Job cards with salary, deadline countdown, bookmark, Apply button
- Job detail screen with skills chips, quick-info cards, Apply FAB

### Step 8 — City Reporting
- 9-category grid picker with emoji icons
- Auto GPS location capture with full permission flow
- Actionable error messages + "Open Settings" for denied permissions
- Optional photo/video evidence (max 20s video)
- Camera, gallery, and video support via image_picker
- My Reports screen with status tracking (Pending/In Progress/Resolved/Rejected)
- Color-coded status bars and delete with confirmation

### Step 9 — Profile & Settings
- Gradient profile header with avatar, name, role badge, verified badge
- Stats row (Reports, Posts, Saved)
- Settings sections: Account, Preferences, Notifications, Activity, Support
- Dark mode toggle inline in settings
- Notification toggles (push, announcements, events)
- Edit Profile: display name, phone, bio — saved to Firebase + SQLite
- Sign out with confirmation dialog

### Step 10 — News Module
- News feed with search + 10-category filter
- 6 seeded full-length articles (real Nairobi topics)
- News cards with category color bars, author, view/like counts
- Full article reader with paragraph formatting, lead summary box, hashtags
- Share and bookmark actions
- Home dashboard news preview links to live articles

---

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio or VS Code
- Firebase project with Android app configured
- Google Maps API key (Maps SDK for Android enabled)

### 1. Clone and install

```bash
git clone <repo-url>
cd citylife
flutter pub get
```

### 2. Firebase setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app with package `com.citylife.citylife`
3. Download `google-services.json` → place in `android/app/`
4. Enable Email/Password in Authentication → Sign-in method
5. Add SHA-1 fingerprint from debug keystore

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

### 3. Google Maps setup

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Enable **Maps SDK for Android**
3. Create API Key → paste in `android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### 4. Run

```bash
flutter run
```

---

## 🔑 Key Dependencies

```yaml
flutter_riverpod: ^2.5.1       # State management
go_router: ^13.2.0              # Navigation
sqflite: ^2.3.3                 # Local database
firebase_core: ^3.3.0           # Firebase
firebase_auth: ^5.1.4           # Authentication
google_maps_flutter: ^2.7.0     # Maps
geolocator: ^12.0.0             # Location
image_picker: ^1.1.2            # Camera/gallery
url_launcher: ^6.3.0            # External links
shared_preferences: ^2.3.2      # Theme persistence
cached_network_image: ^3.3.1    # Image caching
dio: ^5.5.0+1                   # HTTP client
```

---

## 🗺️ Navigation Structure

```
/onboarding        → OnboardingScreen (3-page flow)
/login             → LoginScreen
/register          → RegisterScreen
/forgot-password   → ForgotPasswordScreen

Shell (bottom nav):
  /home            → HomeScreen
  /explore         → ExploreScreen (Amenities + Map)
  /community       → CommunityScreen (Feed/Groups/Messages)
  /services        → JobsScreen
  /nearby          → EventsScreen

Full-screen routes:
  /event/:id       → EventDetailScreen
  /post/:id        → PostDetailScreen
  /job/:id         → JobDetailScreen
  /news/:id        → NewsDetailScreen
  /news            → NewsScreen
  /report-issue    → ReportIssueScreen
  /my-reports      → MyReportsScreen
  /profile         → ProfileScreen
  /edit-profile    → EditProfileScreen
```

---

## 🎨 Design System

### Colors
| Token | Value | Usage |
|---|---|---|
| `primary` | `#0A2540` | Deep Navy — main brand |
| `accent` | `#00D4AA` | Electric Teal — CTAs |
| `amber` | `#FFB547` | Events, warnings |
| `coral` | `#FF6B6B` | Hospitals, alerts |
| `lavender` | `#8B7CF6` | Social, education |
| `sky` | `#38BDF8` | Maps, schools |

### Typography
- **Display/Headlines:** Sora — geometric, authoritative
- **Body/Labels:** DM Sans — clean, readable

### Spacing
4pt base grid: `xs(4)` → `sm(8)` → `md(12)` → `base(16)` → `lg(20)` → `xl(24)` → `xxl(32)`

---

## 🚧 Known Issues & TODO

- [ ] Google Maps not centering on user location (Geolocator permission flow needs device testing)
- [ ] Real-time features (Firestore sync for posts/news) — scaffolded, not yet connected
- [ ] Push notifications — scaffolded, needs FCM setup
- [ ] Image upload to Firebase Storage (currently saves local path)
- [ ] DM chat screen (UI scaffolded, real-time messaging pending)
- [ ] Payment integration for event booking
- [ ] AI recommendation engine for events/places
- [ ] Offline mode (local-first sync strategy)
- [ ] Government services portal
- [ ] Public transport real-time tracker

---

## 📋 Step Roadmap

| Step | Feature | Status |
|---|---|---|
| 1 | Project Setup, Design System, DB | ✅ Done |
| 2 | Authentication (Firebase) | ✅ Done |
| 3 | Home Dashboard | ✅ Done |
| 4 | Amenities & Maps | ✅ Done |
| 5 | Events Module | ✅ Done |
| 6 | Community (Social Feed) | ✅ Done |
| 7 | Jobs Module | ✅ Done |
| 8 | City Reporting | ✅ Done |
| 9 | Profile & Settings | ✅ Done |
| 10 | News Module | ✅ Done |
| — | Fix Maps/Location | 🔧 Pending |
| — | Real-time (Firestore) | 📋 Planned |
| — | Push Notifications | 📋 Planned |
| — | AI Recommendations | 📋 Planned |
| — | Payments | 📋 Planned |

---

## 👨‍💻 Development Notes

- Uninstall app before running when database schema changes: `adb uninstall com.citylife.citylife`
- Database version is currently `2` — bump `_version` in `database_helper.dart` for future migrations
- All seed data uses `ConflictAlgorithm.replace` to ensure fresh data on reinstall
- Community posts require seed users to exist first (FK constraint) — handled in `seedCommunity()`
- Theme preference persisted via `SharedPreferences` under key `theme_mode`

---

*Built with Flutter · Powered by Firebase · Designed for Nairobi, Kenya 🇰🇪*