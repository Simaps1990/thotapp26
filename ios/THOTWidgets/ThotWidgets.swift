import WidgetKit
import SwiftUI

private let appGroupId = "group.fr.thotbook.app"

struct ThotEntry: TimelineEntry {
    let date: Date
    let values: [String: Any]
}

private func widgetValues() -> [String: Any] {
    let defaults = UserDefaults(suiteName: appGroupId)
    return defaults?.dictionaryRepresentation() ?? [:]
}

private func int(_ dict: [String: Any], _ key: String, _ fallback: Int = 0) -> Int {
    return dict[key] as? Int ?? fallback
}

private func double(_ dict: [String: Any], _ key: String, _ fallback: Double = 0) -> Double {
    if let value = dict[key] as? Double { return value }
    if let value = dict[key] as? Float { return Double(value) }
    if let value = dict[key] as? NSNumber { return value.doubleValue }
    return fallback
}

private struct BaseWidgetView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.sRGB, red: 0.07, green: 0.07, blue: 0.07, opacity: 1))
            content
                .padding(14)
                .foregroundColor(.white)
        }
    }
}

struct StatsProvider: TimelineProvider {
    func placeholder(in context: Context) -> ThotEntry {
        ThotEntry(date: Date(), values: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (ThotEntry) -> Void) {
        completion(ThotEntry(date: Date(), values: widgetValues()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ThotEntry>) -> Void) {
        let entry = ThotEntry(date: Date(), values: widgetValues())
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct StatsWidgetView: View {
    var entry: StatsProvider.Entry

    var body: some View {
        let shotsToday = int(entry.values, "widget_shots_today")
        let sessionsWeek = int(entry.values, "widget_sessions_this_week")
        let precision = Int(double(entry.values, "widget_avg_precision").rounded())

        BaseWidgetView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Stats du jour").font(.caption).bold().foregroundStyle(.white.opacity(0.9))
                Text("\(shotsToday) tirs").font(.system(size: 24, weight: .bold))
                Text("\(sessionsWeek) sessions / 7j").font(.caption)
                Text("Précision moy. \(precision)%").font(.caption2).foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ThotStatsWidget: Widget {
    let kind: String = "ThotStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            StatsWidgetView(entry: entry)
        }
        .configurationDisplayName("THOT • Stats")
        .description("Stats non sensibles du jour")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MaintenanceWidgetView: View {
    var entry: StatsProvider.Entry

    var body: some View {
        let wear = Int((double(entry.values, "widget_wear_avg") * 100.0).rounded())
        let foul = Int((double(entry.values, "widget_fouling_avg") * 100.0).rounded())
        let stock = Int((double(entry.values, "widget_stock_avg") * 100.0).rounded())

        BaseWidgetView {
            VStack(alignment: .leading, spacing: 7) {
                Text("Maintenance").font(.caption).bold().foregroundStyle(.white.opacity(0.9))
                Text("Usure \(wear)%").font(.caption)
                Text("Encrass. \(foul)%").font(.caption)
                Text("Stock \(stock)%").font(.caption)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ThotMaintenanceWidget: Widget {
    let kind: String = "ThotMaintenanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            MaintenanceWidgetView(entry: entry)
        }
        .configurationDisplayName("THOT • Maintenance")
        .description("Vue globale maintenance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct DocumentsWidgetView: View {
    var entry: StatsProvider.Entry

    var body: some View {
        let dueCount = int(entry.values, "widget_due_documents_count")
        let nextDays = int(entry.values, "widget_next_doc_due_days", 9999)

        let subtitle: String = {
            if dueCount <= 0 { return "Aucun rappel urgent" }
            if nextDays == 9999 { return "Échéance à vérifier" }
            if nextDays < 0 { return "Au moins un document expiré" }
            if nextDays == 0 { return "Échéance aujourd'hui" }
            return "Prochaine échéance: \(nextDays) jour(s)"
        }()

        BaseWidgetView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Rappels documents").font(.caption).bold().foregroundStyle(.white.opacity(0.9))
                Text("\(dueCount) à vérifier").font(.system(size: 24, weight: .bold))
                Text(subtitle).font(.caption2).foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ThotDocumentsWidget: Widget {
    let kind: String = "ThotDocumentsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            DocumentsWidgetView(entry: entry)
        }
        .configurationDisplayName("THOT • Documents")
        .description("Rappels documents non sensibles")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ActivityWidgetView: View {
    var entry: StatsProvider.Entry

    var body: some View {
        let days = int(entry.values, "widget_last_activity_days", -1)
        let sessions = int(entry.values, "widget_total_sessions")

        let activity: String = {
            if days < 0 { return "Aucune session" }
            if days == 0 { return "Aujourd'hui" }
            if days == 1 { return "Hier" }
            return "Il y a \(days) jours"
        }()

        BaseWidgetView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dernière activité").font(.caption).bold().foregroundStyle(.white.opacity(0.9))
                Text(activity).font(.system(size: 20, weight: .bold))
                Text("\(sessions) sessions totales").font(.caption2).foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

struct ThotActivityWidget: Widget {
    let kind: String = "ThotActivityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatsProvider()) { entry in
            ActivityWidgetView(entry: entry)
        }
        .configurationDisplayName("THOT • Activité")
        .description("Dernière activité non sensible")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct ThotWidgetsBundle: WidgetBundle {
    var body: some Widget {
        ThotStatsWidget()
        ThotMaintenanceWidget()
        ThotDocumentsWidget()
        ThotActivityWidget()
    }
}
