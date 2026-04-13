# Canteen Ordering App 🍔

A robust, beautifully designed campus food delivery and ordering application built with Flutter. Inspired by the UI and UX flows of Swiggy and Zomato, this app streamlines the student ordering process by allowing them to discover menu items, handle cart management intuitively, and choose distinct time slots for pickup.

## 🚀 Features
- **Smart Menu & Filtering**: Browse through Categories (Snacks, Meals, Beverages, Desserts) seamlessly with mutually exclusive Dietary Badges (Veg, Non-Veg, Egg) and adaptive Sorting options.
- **Dynamic Slot Booking**: Reserve exact pickup times. The system prevents selections on fully booked slots and dynamically calculates an ETA countdown if your slot begins within the hour.
- **Cart Management**: Add, decrement, and organize items with a fixed real-time summary attached directly to a floating action banner.
- **Modern User Experience**: Features Shimmer loading states, dynamic hero gradients, beautiful micro-interactions, and adaptive `BottomSheet` selectors.
- **Dark Mode Support**: A fully responsive dark/light theme toggle mapped elegantly using Flutter's Material 3 theme integrations and persistent providers.

## 🏗️ Architecture
The project strictly adheres to a **Layer-First Clean Architecture**, deeply separating concerns for maximum scalability.

```text
lib/
├── core/
│   ├── constants/    # String keys
│   ├── theme/        # Global overarching AppTheme data
│   └── utils/        # Global utilities and Mock Data
├── data/
│   ├── models/       # Application models (User, Orders, CartItems)
│   └── services/     # External API and Auth Services abstractions
└── presentation/
    ├── providers/    # ViewModels managing state (ChangeNotifier)
    ├── screens/      # Complex widget pages and routable screens
    └── widgets/      # Isolated, reusable presentation components
```

*Note: The entire codebase utilizes strict, absolute package imports (`import 'package:student_app/...;`) to guarantee perfectly re-locatable components without relative path breakage.*

## 🛠️ Tech Stack
- **Framework**: `Flutter`
- **State Management**: `Provider`
- **Typography & UI**: `google_fonts`, `shimmer`, `flutter_animate`, `cached_network_image`
- **Data Persistence**: `shared_preferences`
- **Backend & Realtime**: `Supabase`

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
