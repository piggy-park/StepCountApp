//
//  ContentView.swift
//  HealthKitPractive
//
//  Created by 박진섭 on 2023/06/21.
//

import SwiftUI
import CoreMotion
import Combine

struct StepCountView: View {
    @State private var showMap: Bool = false
    @StateObject private var stepsManager = StepsMananger()

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("현재 걸음 수")
                        .foregroundColor(.gray)
                    HStack {
                        Text("\(stepsManager.steps ?? 0) 걸음")
                            .bold()
                            .fontWeight(.bold)
                    }
                    
                }
                
                Spacer().frame(height: 30)
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
            }
        }
        .onAppear {
            stepsManager.getSteps() // get current step count
            stepsManager.updateSteps() // update when data change
        }
        .fullScreenCover(isPresented: $showMap) {
            MapViewSwiftUI_1()
        }

    }
}

struct MapViewWithSteps: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button("dismiss") {
            dismiss()
        }
    }
}


final class StepsMananger: ObservableObject {
    private let pedometer: CMPedometer = .init()
    private var isPedometerIsAvailable: Bool {
        return CMPedometer.isStepCountingAvailable()
    }

    @Published var steps: Int?

    func getSteps() {
        let startDate = Calendar.current.startOfDay(for: Date())
        pedometer.queryPedometerData(from: startDate, to: Date()) { [weak self] data, error in
            guard let data = data,
                  let self = self,
                  error == nil else { return }
            DispatchQueue.main.async {
                self.steps = data.numberOfSteps.intValue
                print("Current Step Counts", data.numberOfSteps.intValue)
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
