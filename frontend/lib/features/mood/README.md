# Module 4: Mood Journal & Wellness Tracking

This module implements the primary data collection and wellness tracking logs (mood, stress, energy, sleep hours, water intake, exercise minutes, daily notes) for **MindSync AI**.

## Directory Structure

```
lib/features/mood/
├── data/
│   ├── datasources/
│   │   ├── mood_local_datasource.dart       # Local caching (drafts, entries, offline sync queue)
│   │   └── mood_remote_datasource.dart      # Firestore network CRUD operations
│   ├── models/
│   │   └── mood_log_model.dart              # Model with Firestore Timestamp conversions
│   └── repositories/
│       └── mood_repository_impl.dart        # Synchronizes cache list, handles offline queues
├── domain/
│   ├── entities/
│   │   └── mood_log.dart                    # Domain entity representing a wellness check-in log
│   └── repositories/
│       └── mood_repository.dart             # Repository interfaces
└── presentation/
    ├── pages/
    │   ├── mood_journal_page.dart           # Segmented view: History list, Calendar heatmap, Charts
    │   └── mood_logging_page.dart           # Create/Edit log form layout
    ├── providers/
    │   └── mood_providers.dart              # Riverpod states (History, drafts, filters)
    └── widgets/
        ├── journal_draft_field.dart         # Autosaving notes text area
        ├── mood_calendar_view.dart          # Custom heat-grid calendar calendar
        ├── mood_log_list_item.dart          # Journal card with modal detail and delete checks
        ├── mood_selector_grid.dart          # High-contrast interactive mood buttons list
        ├── mood_stats_charts.dart           # fl_chart analytics dashboard
        ├── stress_energy_sliders.dart       # Level 1-10 sliders
        └── tracker_input_fields.dart        # Water, sleep, and exercise increment fields
```

## Architectural & UX Decisions

### 1. Offline Sync Queue
If a write action (create, update, delete) is triggered while the device is offline or Firestore throws network errors:
- The local list cache is updated immediately to keep the UI snappy.
- The action is appended to the Hive `mood_sync_queue` box.
- Next time the user opens the tab online, the repository detects items in the queue and syncs them to Firestore sequentially.

### 2. GDPR Hard Deletion
Because mental health journals represent highly personal private data:
- Tapping **Delete** opens a double-check confirmation dialog.
- On approval, the log is completely and immediately erased from local Hive files and Firestore documents, fulfilling data erasure privacy guidelines.

### 3. Local Draft Autosave
The notes text area listens to changes. If the user exits the logging screen without saving, the text is persisted in Hive. Tapping **Log Mood** next time will fully pre-populate the text field, preventing data loss.

### 4. Interactive Averages & backdating
- The analytics tab dynamically calculates weekly and monthly averages directly from the user's historical log lists.
- Selecting a day in the calendar displays that day's entry. If empty, the user can backdate logs for that specific calendar date.

## Run Tests

Run the unit, provider, and widget tests:
```bash
flutter test test/features/mood
```
