# Module 3: Dashboard & Home Experience

This module implements the core dashboard page and navigation system for **MindSync AI**.

## Directory Structure

```
lib/features/dashboard/
├── data/
│   ├── datasources/
│   │   ├── dashboard_local_datasource.dart    # Hive cache implementation for offline support
│   │   └── dashboard_remote_datasource.dart   # OpenWeather API and IT-focused mockup data
│   ├── models/
│   │   ├── weather_model.dart                 # Weather data mapping
│   │   └── dashboard_data_model.dart          # Aggregated dashboard payload models
│   └── repositories/
│       └── dashboard_repository_impl.dart     # Repository wiring offline cache & network fallbacks
├── domain/
│   ├── entities/
│   │   ├── activity_summary.dart              # Daily steps, sleep, water, and exercise counts
│   │   ├── dashboard_data.dart                # Aggregated dashboard state object
│   │   └── weather_info.dart                  # Weather info properties
│   └── repositories/
│       └── dashboard_repository.dart          # Domain repository contract
└── presentation/
    ├── pages/
    │   ├── dashboard_page.dart                # Dashboard layout with slivers & pull-to-refresh
    │   └── main_layout_page.dart              # Shell navigation with bottom bar and side rail
    ├── providers/
    │   └── dashboard_providers.dart           # Riverpod state managers (weather, activity, dashboard)
    └── widgets/
        ├── activity_summary_card.dart         # Circular gauge grids for daily trackers
        ├── burnout_risk_card.dart             # ML-ready risk bar with diagnostic details sheet
        ├── mood_summary_card.dart             # Mood status, trend lines, and shortcut arrow
        ├── motivational_quote_card.dart       # Beautiful custom daily quotes card
        ├── quick_actions_grid.dart            # Standard M3 grid shortcut list (Log Mood, Chat, Reports, Tips)
        ├── recommendations_card.dart          # AI wellness category tags and breathing exercises
        ├── weather_widget.dart                # OpenWeather display & location-based suggestions
        ├── welcome_header.dart                # Time-based greetings, profile avatar, and shortcut options
        ├── wellness_score_card.dart           # Animated progress gauge with score contributions
        └── weekly_wellness_charts.dart        # fl_chart lines and bar plots for weekly trends
```

## Architectural Decisions & Design Patterns

### 1. State Preservation in Tabs
The navigation shell uses GoRouter's `StatefulShellRoute.indexedStack` inside `app_router.dart` and the `MainLayoutPage` layout wrapper. This allows the app to retain the scroll position and active views of all major branches (Dashboard, Mood Journal, AI Chat, Reports, Profile) as the user switches between tabs.

### 2. Geolocation & Weather Graceful Degradation
The `weatherStateProvider` uses `geolocator` to query GPS coordinates.
- If geolocation permission is denied, it degrades to default coordinates (Colombo).
- If the OpenWeather API returns network failures or is configured with a dummy key (`mock_weather_key_for_testing`), the `DashboardRemoteDataSource` intercepts the request and serves structured local mock data, avoiding crash logs.
- If completely offline, the system attempts to return cached data from the `DashboardLocalDataSource` before emitting errors.

### 3. Responsive Adaptations
- **Tablet / Large Screens**: Switches the bottom navigation bar into a vertical `NavigationRail` and updates the dashboard layout to arrange cards (Weather, Wellness Score, Mood, Burnout) in 2-column or 4-column side-by-side rows.
- **Mobile Phones**: Places the standard `NavigationBar` at the bottom and cascades cards in a scrollable column structure.

### 4. Accessibility
- All interactive cards and buttons are wrapped in explicit `Semantics` tags to provide rich labels for screen readers.
- Touch target sizes are kept above $48 \times 48\text{ dp}$ for high touch accessibility.
- Animations utilize curve damping (`Curves.easeOutBack`) to prevent visual strain.

## Tests

Run the unit and widget tests using:
```bash
flutter test test/features/dashboard
```
Tests check the following properties:
- Emitting correct loading, data, and error values for our Riverpod providers.
- Displaying widget labels, rendering numbers, and triggering dialogue popups.
