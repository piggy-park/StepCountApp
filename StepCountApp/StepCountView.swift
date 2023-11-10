//
//  ContentView.swift
//  HealthKitPractive
//
//  Created by 박진섭 on 2023/06/21.
//

import SwiftUI
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StepCountView().preferredColorScheme(.dark)
    }
}
