# THOT WidgetKit setup (iOS)

`ThotWidgets.swift` is ready, but WidgetKit still needs a native Xcode target.

## Steps

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Add a new target: **Widget Extension** named `THOTWidgets`.
3. Replace generated Swift file content with `ios/THOTWidgets/ThotWidgets.swift`.
4. Enable **App Groups** capability on both targets:
   - `Runner`
   - `THOTWidgets`
5. Add the same group ID on both targets:
   - `group.fr.thotbook.app`
6. Ensure iOS deployment target of the widget target is compatible with your app target.
7. Build and run on a real iOS device/simulator, then add THOT widgets from the Home Screen.

## Data contract

The Flutter app writes these keys through `DashboardWidgetService`:

- `widget_shots_today`
- `widget_sessions_this_week`
- `widget_avg_precision`
- `widget_wear_avg`
- `widget_fouling_avg`
- `widget_stock_avg`
- `widget_due_documents_count`
- `widget_next_doc_due_days`
- `widget_last_activity_days`
- `widget_total_sessions`
