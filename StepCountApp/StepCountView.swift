//
//  ContentView.swift
//  HealthKitPractive
//
//  Created by 박진섭 on 2023/06/21.
//

import SwiftUI
import CoreMotion
import Combine
import Charts

struct StepCountView: View {
    @State private var showMap: Bool = false
    @StateObject private var stepsManager = StepsMananger()
    private let calendar = Calendar.current
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("오늘 걸음 수")
                    .foregroundColor(.gray)
                HStack {
                    Text("\(stepsManager.steps ?? 0) 걸음")
                        .bold()
                        .fontWeight(.bold)
                }
            }

            HStack(spacing: 16) {
                Text("방문해서 포인트 받기")
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue)
                    .overlay {
                        Text("내 주변 보기")
                            .foregroundStyle(.white)
                    }
                    .frame(width: 100, height: 32)

            }
            .onTapGesture {
                self.showMap = true
            }

            Spacer().frame(height: 50)

            Text("일주일 기록")
                .foregroundColor(.gray)

            Chart {
                ForEach(stepsManager.stepsForWeek) { stepsPerDay in

                    BarMark(x: .value("날짜", "\(WeekDay.init(rawValue: stepsPerDay.countOfDayAgo)!)"),
                            y: .value("걸음수", stepsPerDay.stepCount) )
                }
            }
            .frame(width: 300, height: 300)
        }

        .onAppear {
            stepsManager.getSteps()    // get current step count
            stepsManager.updateSteps() // update when data change
        }
        .fullScreenCover(isPresented: $showMap) {
            MapView()
        }

    }
}


final class StepsMananger: ObservableObject {
    private let pedometer: CMPedometer = .init()
    private var isPedometerIsAvailable: Bool {
        return CMPedometer.isStepCountingAvailable()
    }

    @Published var stepsForWeek: [StepPerDay] = []
    @Published var steps: Int?

    func getSteps() {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        var cachedStepsForWeek: [StepPerDay] = []
        if isPedometerIsAvailable {
            pedometer.queryPedometerData(from: startDate, to: Date()) { [weak self] data, error in
                guard let data = data,
                      let self = self,
                      error == nil else { return }

                DispatchQueue.main.async {
                    self.steps = data.numberOfSteps.intValue
                    print("Current Step Counts", data.numberOfSteps.intValue)
                }
            }

            for n in 1...7 {
                let nDayAgo = calendar.date(byAdding: .day, value: -n, to: startDate)!
                pedometer.queryPedometerData(from: nDayAgo, to: startDate) { data, error in
                    guard let data = data,
                          error == nil else { return }
                    if cachedStepsForWeek.isEmpty {
                        let week = calendar.dateComponents([.weekday], from: nDayAgo)
                        cachedStepsForWeek.append(.init(countOfDayAgo: week.weekday!, stepCount: data.numberOfSteps.intValue))
                    }
                    else {
                        let totalStepCount = data.numberOfSteps.intValue
                        let stepCountNDayAgo = cachedStepsForWeek.map { $0.stepCount }.reduce(0) { $0 + $1 }
                        let stepPerDay = totalStepCount - stepCountNDayAgo
                        let week = calendar.dateComponents([.weekday], from: nDayAgo)
                        cachedStepsForWeek.append(.init(countOfDayAgo: week.weekday!, stepCount: stepPerDay))


                    }
                }
                DispatchQueue.main.async {
                    self.stepsForWeek = cachedStepsForWeek.reversed()
                }
            }
        }
    }

    func updateSteps() {
        if isPedometerIsAvailable {
            pedometer.startUpdates(from: Date()) { [weak self] data, error in
                guard let self = self,
                      data != nil,
                      error == nil else { return }
                self.getSteps()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StepCountView().preferredColorScheme(.dark)
    }
}

extension Date {
    public var removeTimeStamp : Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return nil
        }
        return date
    }

    func dateWithoutTime() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        guard let dateWithoutTime = calendar.date(from: dateComponents) else { return Date() }
        return dateWithoutTime
    }

}

struct StepPerDay: Identifiable {
    let id = UUID()
    let countOfDayAgo: Int
    let stepCount: Int
}

enum WeekDay: Int {
    case 일요일 = 1
    case 월요일 = 2
    case 화요일 = 3
    case 수요일 = 4
    case 목요일 = 5
    case 금요일 = 6
    case 토요일 = 7
}
