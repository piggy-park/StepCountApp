//
//  StepsManager.swift
//  StepCountApp
//
//  Created by gx_piggy on 11/6/23.
//

import Foundation
import CoreMotion

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
