//
//  FeatureMapViewUIKit.swift
//  KlipApp
//
//  Created by 박진섭 on 2022/10/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(\.colorScheme) private var colorScheme
    // 목표까지 예상 걸음 수 계산
    private let commonStepSize: Double = 0.0007 // 70cm
    private let commonStepSpeed: Double = 4 // 시속 4km

    @StateObject private var locationManager: MapViewLocationManager = .init()
    @State private var trackingMode: MKUserTrackingMode = .follow
    @State private var showPolyLine: Bool = false
    @State private var goToCurrentUserLocation: Bool = false
    @State private var showDestinationDetail: Bool = false

    @State private var distanceFromCurrentLocation: Double = .zero
    @State private var estimatedTimeOfArrival: Int = .zero
    @State private var estimatedStepCount: Int = .zero

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            MapViewUIKit(
                locationManager: locationManager,
                trackingMode: $trackingMode,
                showPolyLine: $showPolyLine,
                showDestinationDetail: $showDestinationDetail,
                goToCurrentUserLocation: $goToCurrentUserLocation,
                distanceFromCurrentLocation: $distanceFromCurrentLocation,
                estimatedTimeOfArrival: $estimatedTimeOfArrival,
                estimatedStepCount: $estimatedStepCount
            )
            .edgesIgnoringSafeArea(.all)

            buildButtons()

        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onChange(of: showDestinationDetail) { _ in
            self.showDestinationDetail = true
        }
    }


    @ViewBuilder
    private func buildButtons() -> some View {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .trailing) {
                    HStack(spacing: 16) {
                        Button {
                            let previousValue = locationManager.startRecord
                            locationManager.startRecord.toggle()
                            let newValue = locationManager.startRecord
                            if previousValue == true && newValue == false {
                                locationManager.savePolyLine = true
                            } else {
                                locationManager.savePolyLine = false
                            }
                        } label: {
                            HStack {
                                if locationManager.startRecord {
                                    Image(systemName: "stop.circle.fill")
                                        .foregroundStyle(.orange)
                                } else {
                                    Image(systemName: "record.circle")
                                        .foregroundStyle(.orange)
                                }
                                Text(locationManager.startRecord ? "기록 중지" : "기록 시작")
                                    .fixedSize()
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                            }
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.primary)
                            }
                        }

                        Button {
                            self.showPolyLine.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "road.lanes")
                                    .foregroundStyle(.orange)
                                Text(showPolyLine ? "경로 숨기기" : "경로 보기")
                                    .lineLimit(1)
                                    .fixedSize()
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                            }
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.primary)
                        }

                        Button {
                            goToCurrentUserLocation.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(.orange)
                                Text("내 위치")
                                    .fixedSize()
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                            }
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundStyle(Color.primary)
                            }
                        }
                    }
                    .padding([.leading, .trailing], 15)

                    if showDestinationDetail {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 25)
                                .foregroundStyle(Color.primary)
                            HStack {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("\(locationManager.locationName ?? "")로 가면")
                                        .minimumScaleFactor(0.4)
                                        .foregroundColor(.gray)

                                    Spacer().frame(height: 8)

                                    Text("20원 지급")
                                        .foregroundStyle(Color.blue)
                                        .font(.title)
                                        .fontWeight(.bold)

                                    Spacer().frame(height: 16)

                                    Text("\(estimatedStepCount)걸음 • \(estimatedTimeOfArrival)분 예상")
                                        .foregroundStyle(colorScheme == .light ? .white : .black)
                                        .minimumScaleFactor(0.4)
                                        .fontWeight(.bold)

                                    Spacer().frame(height: 8)

                                    Text("거리: \(distanceFromCurrentLocation ,specifier: "%.2f")KM")
                                        .minimumScaleFactor(0.4)
                                        .foregroundStyle(colorScheme == .light ? .white : .black)

                                }
                                .padding(.top, 20)
                                .padding(.leading, 20)

                                Spacer()

                                Image(systemName: "figure.run.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(colorScheme == .light ? .white : .black)

                                Spacer().frame(width: 16)
                            }
                        }
                        .frame(height: 180)
                        .padding([.leading, .trailing], 15)
                    }
            }
        }
    }
}
