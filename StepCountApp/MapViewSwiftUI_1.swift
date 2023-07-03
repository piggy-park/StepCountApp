//
//  MapViewSwiftUI.swift
//  HealthKitPractive
//
//  Created by 박진섭 on 2023/06/28.
//

import SwiftUI
import MapKit

struct MapViewSwiftUI_1: View {
    // 70cm
    private let commonStepSize: Double = 0.0007
    // 시속 4km
    private let commonStepSpeed: Double = 4
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .light)

    // 권한 설정
    @StateObject private var mapViewManager: MapViewManager = .init()
    // camera 포지션 설정가능
    // MapCamera 이니셜라이저를 적용하면 3D구조의 카메라도 구현가능하다.
    @State private var position: MapCameraPosition = .automatic
    // MapItem을 선택하면 풍선 애니메이션이 생긴다.
    // 이를 구현하지 않으면 클릭 이벤트 발생 하지 않음.
    @State private var selectedResult: MKMapItem?
    @State private var selectedPoint: PointSpotAnnotation?
    @State private var route: MKRoute?
    @State private var showPointDetail: Bool = true
    @State private var pointTitle: String?
    @State private var distanceFromCurrentLocation: String?
    @State private var estimatedStepCount: Int?
    @State private var estimatedTimeOfArrival: Int?

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position, selection: $selectedResult) {
                UserAnnotation(anchor: .bottom) {
                    ZStack {
                        Circle()
                            .foregroundStyle(.orange)
                        Circle()
                            .foregroundStyle(.white)
                            .padding(5)
                    }
                }

                ForEach(mapViewManager.pointSpotCoordinates, id: \.self) { point in
                    Annotation(point.title ?? "", coordinate: point.coordinate) {
                        if point == selectedPoint {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.white)
                                Circle()
                                    .foregroundStyle(.blue)
                                    .padding(5)
                            }
                                .frame(width: 30, height: 30)
                                .onTapGesture(perform: {
                                    self.selectedPoint = nil
                                })
                        } else {
                            
                            Text("20")
                                .fixedSize()
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(.blue, in: Circle())
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    self.selectedPoint = point
                                }
                        }
                    }
                }
                .annotationTitles(.hidden)
            }

            ZStack(alignment: .topLeading) {
                VStack(alignment: .trailing) {
                    Button {
                        guard let currentUserCoordinate = mapViewManager.currentLocation?.coordinate else { return }
                        self.position = .region(.init(center: .init(latitude: currentUserCoordinate.latitude, longitude: currentUserCoordinate.longitude),
                                                      latitudinalMeters: 700,
                                                      longitudinalMeters: 700))
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.orange)
                            Text("내 위치")
                                .foregroundStyle(.white)
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.primary)
                        }
                    }
                    .padding(.trailing, 15)

                    if showPointDetail {
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
                                        .foregroundStyle(Color.white)
                                        .fontWeight(.bold)
                                    if let distanceFromCurrentLocation {
                                        Text("거리: \(distanceFromCurrentLocation)KM")
                                            .foregroundStyle(Color.white)
                                    }
                                }
                                .padding(.top, 30)
                                .padding(.leading, 20)

                                Image(systemName: "figure.run.circle")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(.white)

                            }
                        }
                        .frame(height: 180)
                        .padding([.leading, .trailing], 15)
                        .padding(.bottom, 25)
                    }
                }
            }
        }
        .ignoresSafeArea()
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
            hapticGenerator.impactOccurred()
            let pointCoordinate = newValue.coordinate
            let distance = calculateDistance(from: mapViewManager.currentLocation?.coordinate ?? .init(), to: pointCoordinate)
            let estimatedStepCount = Int(round(distance / commonStepSize))
            let estimatedTimeOfArrival = Int(round(distance / commonStepSpeed * 60))
            self.distanceFromCurrentLocation = String(format: "%.2f", distance)
            self.estimatedStepCount = estimatedStepCount
            self.estimatedTimeOfArrival = estimatedTimeOfArrival
        }
    }

    // 특정 두 위치 기준 거리 가져오기.
    func calculateDistance(from location1: CLLocationCoordinate2D, to location2: CLLocationCoordinate2D) -> Double {
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

    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }


}

#Preview{
    MapViewSwiftUI_1()
}
