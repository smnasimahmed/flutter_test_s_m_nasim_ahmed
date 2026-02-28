# Daraz-Style Product Listing — Flutter Hiring Task 2026

## Run Instructions

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected device / emulator
flutter run
```

Tested with Flutter 3.19+ / Dart 3.3+.  
API: [https://fakestoreapi.com](https://fakestoreapi.com)  
Demo credentials → **username:** `johnd` | **password:** `m38rmF$`

---

## Architecture Decisions

### 1. How Horizontal Swipe Was Implemented

A `PageView` drives horizontal navigation between tabs.  
It is placed inside a `SliverToBoxAdapter` with a computed fixed height so the outer `CustomScrollView` can still scroll vertically past it.

Two-way sync between `TabBar` and `PageView`:

- **Tab tap** → `tabController.addListener` detects `indexIsChanging` → calls `pageController.animateToPage(index)`
- **Page swipe** → `PageView.onPageChanged(index)` → calls `tabController.animateTo(index)`

Boolean guards (`_syncingFromTab`, `_syncingFromPage`) prevent feedback loops between the two listeners.

The `PageView` uses `PageScrollPhysics` which only intercepts **horizontal** gestures.  
Flutter's gesture arena automatically routes vertical drags to the outer `CustomScrollView`.

---

### 2. Who Owns the Vertical Scroll and Why

**One `CustomScrollView` owns all vertical scrolling.**

The per-tab `GridView`s inside each `PageView` page are configured with:
```dart
physics: const NeverScrollableScrollPhysics(),
shrinkWrap: true,
```

This makes them passive layout boxes that expose their full content height upward, rather than creating a second scroll context. The outer `CustomScrollView` expands to fit the tallest tab content and scrolls it.

Consequences:
| Requirement | How it's satisfied |
|---|---|
| Exactly ONE vertical scrollable |  Only the `CustomScrollView` scrolls vertically |
| Pull-to-refresh from any tab |  `RefreshIndicator` wraps the outer scroll; works regardless of tab |
| Tab switch doesn't reset scroll |  Switching tabs only swaps the `PageView` page; `scrollController` is untouched |
| No scroll jitter / conflict |  `NeverScrollableScrollPhysics` eliminates the second scroll context |
| Tab bar stays visible once pinned |  `SliverPersistentHeader(pinned: true)` |

---

### 3. Trade-offs / Limitations

| Decision | Trade-off |
|---|---|
| `shrinkWrap: true` on grids | O(n) layout cost. Acceptable for FakeStore's ≤20 items/tab. For 100s of items, use `NestedScrollView` + independent `SliverList` bodies instead. |
| Fixed `pageViewH` computed from `MediaQuery` | Accurate at build time; re-computes when the widget rebuilds. Not fully responsive to dynamic inset changes mid-session, but sufficient for this use case. |
| `PageView` inside `SliverToBoxAdapter` | The entire page content (all tab grids) is laid out at once. A `NestedScrollView` approach would lazy-build only the visible tab but requires more complex scroll coordination. |
| Single `TabController` rebuilt on category fetch | The controller is replaced after categories load. This is safe with `GetxController` lifecycle management but means there's a brief moment with a length-1 tab bar. |

---

## Project Structure

```
lib/
├── constant/
│   ├── api/api_end_point.dart       # FakeStore API endpoints
│   └── color/const_colour.dart      # Color palette
├── models/
│   ├── product_model.dart           # Product + Rating models
│   └── user_model.dart              # User + Name + Address models
├── services/
│   ├── api/
│   │   ├── api_service.dart         # Dio HTTP client
│   │   └── api_response_model.dart  # Unified response wrapper
│   ├── log/
│   │   ├── app_log.dart             # Debug logging
│   │   ├── error_log.dart           # Error logging
│   │   └── api_log.dart             # PrettyDioLogger
│   └── storage/
│       ├── storage_keys.dart        # GetStorage key constants
│       └── storage_service.dart     # Local persistence (GetStorage)
├── routes/
│   ├── app_routes.dart              # Route name constants + initial route logic
│   ├── app_routes_file.dart         # GetPage definitions
│   └── bindings/
│       ├── auth_bindings.dart
│       └── home_bindings.dart
├── splash_screen/
│   ├── login_page.dart              # Login UI
│   └── controller/login_controller.dart
├── home_screen/
│   ├── home_page.dart               # ★ Main screen (scroll architecture lives here)
│   ├── controller/home_page_controller.dart  # Data + tab + scroll state
│   └── widgets/
│       ├── banner_widget.dart       # Collapsible header content
│       ├── product_card.dart        # Individual product card
│       └── product_grid_for_tab.dart # NeverScrollable grid per tab
└── profile_screen/
    └── profile_page.dart            # User profile view
```
