# Canteen Ordering App 🍔

A robust, beautifully designed campus food delivery and ordering application built with Flutter. Inspired by the UI and UX flows of Swiggy and Zomato, this app streamlines the student ordering process by allowing them to discover menu items, handle cart management intuitively, and choose distinct time slots for pickup.

## 🚀 Features
- **Campus-Wide Discovery**: Browse through multiple canteens and shops, each with live "Open/Closed" status indicators and unique catalogs.
- **Smart Menu & Filtering**: Seamlessly navigate through categories (Snacks, Meals, Beverages, Desserts) with dietary badges (Veg, Non-Veg) and real-time availability.
- **Live Queue tracking**: A dedicated tab to monitor your active orders in real-time, complete with live status updates (Pending → Preparing → Ready).
- **Cart & Dynamic Slot Booking**: Reserve exact pickup times. The system dynamically validates slot capacity and prevents overbooking.
- **Instant Notifications**: Receive real-time alerts as your order status changes, ensuring you pick up your food while it's fresh.
- **Modern User Experience**: Features Shimmer transition states, dynamic hero gradients, and adaptive Material 3 components.

## 🏗️ Architecture
The project strictly adheres to a **Layer-First Clean Architecture**, ensuring deep separation of concerns.

```text
lib/
├── core/
│   ├── constants/    # String keys and branding
│   ├── router/       # GoRouter definitions and logic
│   ├── theme/        # Centralized AppTheme data
│   └── utils/        # Generic helpers and Mock Data
├── data/
│   ├── models/       # Entities (CartItem, MenuItem, Order, Shop, User)
│   └── services/     # API clients, Supabase auth, and Sockets
└── presentation/
    ├── providers/    # Riverpod state management and business logic
    ├── screens/      # Feature-based pages and navigation shells
    └── widgets/      # Fragmented, reusable UI components
```

*Note: The entire codebase utilizes strict, absolute package imports (`import 'package:student_app/...;`) to guarantee perfectly re-locatable components without relative path breakage.*

## 🛠️ Tech Stack
- **Framework**: `Flutter` (Material 3)
- **State Management**: `Riverpod` (`flutter_riverpod`)
- **Navigation**: `GoRouter`
- **Typography & UI**: `google_fonts`, `shimmer`, `flutter_animate`, `cached_network_image`
- **Data Persistence**: `shared_preferences`
- **Backend**: `Supabase` (Auth, Database, Real-time)

## ⚙️ How to Run
1. Ensure you have the Flutter SDK installed and an emulator (or physical device) connected.
2. Clone or download the repository.
3. Install the dependencies:
   ```bash
   flutter pub get
   ```
4. Create a `.env` file in the root of the project with your Supabase keys:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
5. Run the application:
   ```bash
   flutter run
   ```
