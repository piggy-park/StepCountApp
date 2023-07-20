//
//  StepCountWidget.swift
//  StepCountWidget
//
//  Created by 박진섭 on 2023/07/16.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {

    //데이터를 불러오기 전에 보여줄 PlaceHolder
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    // 추가하기전에 보이는 View
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // 현 시간부터 5시간동안 1시간씩 업데이트됨.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 보여질 View에 들어갈 데이터
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

// 보여질 View
struct StepCountWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.date, style: .time)
    }
}

// MARK: -- IntentConfiguration

struct StepCountWidget: Widget {
    let kind: String = "StepCountWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self,
                            provider: Provider()) { entry in
            StepCountWidgetEntryView(entry: entry)
        }
        // 위젯 설명
        .configurationDisplayName("StepCount Widget")
        .description("위젯 샘플입니다.")
    }
}

struct StepCountWidget_Previews: PreviewProvider {
    static var previews: some View {
        StepCountWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
