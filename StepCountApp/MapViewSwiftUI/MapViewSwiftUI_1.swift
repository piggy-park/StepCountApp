//
//  MapViewSwiftUI.swift
//  HealthKitPractive
//
//  Created by 박진섭 on 2023/06/28.
//

import SwiftUI
import MapKit

struct MapViewSwiftUI_1: View {
    @Environment(\.colorScheme) private var colorScheme

    // 목표까지 예상 걸음 수 계산
    private let commonStepSize: Double = 0.0007 // 70cm
    private let commonStepSpeed: Double = 4 // 시속 4km

    @StateObject private var mapViewManager: MapViewManager = .init()
    @State private var position: MapCameraPosition = .automatic
    @State private var showPolyLine: Bool = false
    @State private var drawPolyLine: Bool = false
    @State private var selectedPoint: PointSpotAnnotation?
    @State private var distanceFromCurrentLocation: String?
    @State private var estimatedStepCount: Int?
    @State private var estimatedTimeOfArrival: Int?

    var body: some View {
        ZStack(alignment: .bottom) {
            StepCountMapView(mapViewManager: mapViewManager,
                             selectedPoint: $selectedPoint,
                             position: $position,
                             drawPolyLine: $drawPolyLine,
                             showPolyLine: $showPolyLine)
            buildButtons()
        }
        .onAppear {
            mapViewManager.startUpdatingLocation()
        }
        .onDisappear {
            mapViewManager.stopUpdatingLocation()
        }
        .onChange(of: mapViewManager.pointSpotCoordinates, { _, newValue in
            guard let initialPoint = newValue.first else { return }
            selectedPoint = initialPoint
        })
        .onChange(of: selectedPoint) { _, newValue in
            guard let newValue = newValue else { return }
            setDetailInfoToDestination(newValue.coordinate)
        }
    }

    @ViewBuilder
    private func buildButtons() -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing) {
                HStack(spacing: 16) {
                    Button {
                        drawPolyLine.toggle()
                    } label: {
                        HStack {
                            if drawPolyLine {
                                Image(systemName: "stop.circle.fill")
                                    .foregroundStyle(.orange)
                            } else {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.orange)
                            }
                            Text(drawPolyLine ? "기록 중지" : "기록 시작")
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
                            Text("경로 보기")
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
                        position = .userLocation(followsHeading: true, fallback: .automatic)
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.orange)
                            Text("내 위치")
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

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color.primary)
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            // TODO: 위치정보에 따라 바꿀것.
                            Text("그라운드 X에 가면")
                                .foregroundColor(.gray)
                            Spacer().frame(height: 8)
                            Text("20원 지급")
                                .foregroundStyle(Color.blue)
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 16)
                            Text("현재 위치에서 \(estimatedStepCount ?? 0)걸음 • \(estimatedTimeOfArrival ?? 0)분 예상")
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                                .fontWeight(.bold)
                            if let distanceFromCurrentLocation {
                                Text("거리: \(distanceFromCurrentLocation)KM")
                                    .foregroundStyle(colorScheme == .light ? .white : .black)
                            }
                        }
                        .padding(.top, 30)
                        .padding(.leading, 20)

                        Image(systemName: "figure.run.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(colorScheme == .light ? .white : .black)

                    }
                }
                .frame(height: 180)
                .padding([.leading, .trailing], 15)
                .padding(.bottom, 10)

            }
        }
    }


    // 특정 두 위치 기준 거리 가져오기.
    private func calculateDistance(from location1: CLLocationCoordinate2D, to location2: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371.0 // 지구 반지름 (단위: 킬로미터)

        let lat1Rad = degreesToRadians(degrees: location1.latitude)
        let lon1Rad = degreesToRadians(degrees: location1.longitude)
        let lat2Rad = degreesToRadians(degrees: location2.latitude)
        let lon2Rad = degreesToRadians(degrees: location2.longitude)

        let deltaLat = lat2Rad - lat1Rad
        let deltaLon = lon2Rad - lon1Rad

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
                cos(lat1Rad) * cos(lat2Rad) *
                sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        let distance = earthRadius * c

        return distance
    }

    // 목적지 까지의 설명값들(예상시간, 걸음수..)
    private func setDetailInfoToDestination(_ destination: CLLocationCoordinate2D) {
        let distance = calculateDistance(from: mapViewManager.currentLocation?.coordinate ?? .init(), to: destination)
        let estimatedStepCount = Int(round(distance / commonStepSize))
        let estimatedTimeOfArrival = Int(round(distance / commonStepSpeed * 60))
        self.distanceFromCurrentLocation = String(format: "%.2f", distance)
        self.estimatedStepCount = estimatedStepCount
        self.estimatedTimeOfArrival = estimatedTimeOfArrival
    }

    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.longitude == rhs.longitude && lhs.latitude == rhs.longitude
    }


    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    static let annotaion1: CLLocationCoordinate2D = .init(latitude: 37.507045, longitude: 127.063388)
    static let marker1: CLLocationCoordinate2D = .init(latitude: 37.506, longitude: 127)
    static let 판교경위도: CLLocationCoordinate2D = .init(latitude: 37.506, longitude: 127)
}

extension MKCoordinateRegion {
    static let 판교역Region = MKCoordinateRegion(
        center: .판교경위도,
        span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
}

//
//#Preview{
//    MapViewSwiftUI_1()
//}
