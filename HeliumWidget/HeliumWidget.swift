//
//  HeliumWidget.swift
//  HeliumWidget
//
//  Boot-time launcher widget for Helium HUD
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), isHUDRunning: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), isHUDRunning: checkHUDStatus())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // This is called when the widget refreshes, including after device unlock
        let currentDate = Date()
        
        // Check if HUD should be auto-started
        let shouldAutoStart = UserDefaults(suiteName: "group.com.leemin.helium")?.bool(forKey: "AutoStartOnBoot") ?? true
        
        if shouldAutoStart {
            // Trigger HUD start via URL scheme
            if let url = URL(string: "helium://auto-start-from-widget") {
                // Send notification to wake up the app
                CFNotificationCenterPostNotification(
                    CFNotificationCenterGetDarwinNotifyCenter(),
                    CFNotificationName("com.leemin.helium.widget.wakeup" as CFString),
                    nil, nil, true
                )
            }
        }
        
        // Create entry
        let entry = SimpleEntry(date: currentDate, isHUDRunning: checkHUDStatus())
        
        // Update timeline - refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func checkHUDStatus() -> Bool {
        // Check via shared UserDefaults
        return UserDefaults(suiteName: "group.com.leemin.helium")?.bool(forKey: "HUDIsRunning") ?? false
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let isHUDRunning: Bool
}

struct HeliumWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15)
            
            VStack(spacing: 8) {
                Image(systemName: entry.isHUDRunning ? "circle.fill" : "circle")
                    .font(.system(size: family == .systemSmall ? 32 : 24))
                    .foregroundColor(entry.isHUDRunning ? .green : .gray)
                
                Text("氦气")
                    .font(.system(size: family == .systemSmall ? 16 : 14, weight: .medium))
                    .foregroundColor(.white)
                
                if family != .systemSmall {
                    Text(entry.isHUDRunning ? "运行中" : "已停止")
                        .font(.system(size: 12))
                        .foregroundColor(entry.isHUDRunning ? .green : .gray)
                }
            }
            .padding()
        }
    }
}

@main
struct HeliumWidget: Widget {
    let kind: String = "HeliumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HeliumWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("氦气 HUD")
        .description("重启后自动启动 HUD(需添加到桌面)")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HeliumWidget_Previews: PreviewProvider {
    static var previews: some View {
        HeliumWidgetEntryView(entry: SimpleEntry(date: Date(), isHUDRunning: true))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
