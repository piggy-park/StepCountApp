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

    @StateObject private var locationManager: MapViewLocationMananger = .init()
    @State private var trackingMode: MKUserTrackingMode = .followWithHeading
    @State private var showPolyLine: Bool = false
    @State private var goToCurrentUserLocation: Bool = false

    @State private var distanceFromCurrentLocation: Double = .zero
    @State private var estimatedStepCount: Int = .zero
    @State private var estimatedTimeOfArrival: Int = .zero

    var body: some View {
        ZStack(alignment: .bottom) {
            // Map
            MapViewUIKit(
                locationManager: locationManager,
                trackingMode: $trackingMode,
                showPolyLine: $showPolyLine,
                goToCurrentUserLocation: $goToCurrentUserLocation
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
    }



    @ViewBuilder
    private func buildButtons() -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing) {
                HStack(spacing: 16) {
                    Button {
                        locationManager.drawPolyline.toggle()
                    } label: {
                        HStack {
                            if locationManager.drawPolyline {
                                Image(systemName: "stop.circle.fill")
                                    .foregroundStyle(.orange)
                            } else {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.orange)
                            }
                            Text(locationManager.drawPolyline ? "기록 중지" : "기록 시작")
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

                            Text("현재 위치에서 \(estimatedStepCount)걸음 • \(estimatedTimeOfArrival)분 예상")
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                                .fontWeight(.bold)
                            Text("거리: \(distanceFromCurrentLocation)KM")
                                .foregroundStyle(colorScheme == .light ? .white : .black)

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
        let distance = calculateDistance(from: locationManager.currentLocation.coordinate,
                                         to: destination)
        let estimatedStepCount = Int(round(distance / commonStepSize))
        let estimatedTimeOfArrival = Int(round(distance / commonStepSpeed * 60))
        self.distanceFromCurrentLocation = round(distance * 100) / 100
        self.estimatedStepCount = estimatedStepCount
        self.estimatedTimeOfArrival = estimatedTimeOfArrival
    }

    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
}

struct MapViewUIKit: UIViewRepresentable {

    @ObservedObject var locationManager: MapViewLocationMananger
    @Binding var trackingMode: MKUserTrackingMode
    @Binding var showPolyLine: Bool
    @Binding var goToCurrentUserLocation: Bool

    init(locationManager: MapViewLocationMananger,
         trackingMode: Binding<MKUserTrackingMode>,
         showPolyLine: Binding<Bool>,
         goToCurrentUserLocation: Binding<Bool>)
    {
        self.locationManager = locationManager
        self._trackingMode = trackingMode
        self._showPolyLine = showPolyLine
        self._goToCurrentUserLocation = goToCurrentUserLocation
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.userTrackingMode = trackingMode
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        context.coordinator.updateHeadingRotation()
        // draw & show polyline
        if locationManager.drawPolyline && showPolyLine {
            for polyline in locationManager.polylines {
                let otherPolyline = MKPolyline(coordinates: polyline.map { $0.coordinate },
                                               count: polyline.count)
                view.addOverlay(otherPolyline)
            }
        }

        // overlay로 추가했던 polyline을 모두 지움.
        if !showPolyLine {
            for overlay in view.overlays {
                view.removeOverlay(overlay)
            }
        }

        // go to current Location
        if goToCurrentUserLocation {
            view.region = .init(center: locationManager.currentLocation.coordinate,
                                latitudinalMeters: 1000,
                                longitudinalMeters: 1000)
            DispatchQueue.main.async {
                goToCurrentUserLocation = false
            }
        }
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(self)
    }

}

final class MapCoordinator: NSObject, MKMapViewDelegate {
    var parent: MapViewUIKit
    var headingView: UIView?

    init(_ parent: MapViewUIKit) {
        self.parent = parent
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        let userAnnotation = views.first { $0.annotation is MKUserLocation }
        if let userAnnotation {
            addHeadingView(toAnnotationView: userAnnotation)
        }
    }

    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        if headingView == nil {
            // 회전축
            let centerPoint: CGPoint = .init(x: annotationView.frame.width / 2,
                                             y: annotationView.frame.height / 2)
            // 크기 조절
            let multiple = 4.0
            let customHeadingView = GradientTriangleView(frame: .init(origin: .init(
                x: -multiple * (centerPoint.x),
                y: -multiple * (centerPoint.y)), size:
                    .init(width: (annotationView.frame.width * (multiple + 1)),
                          height: (annotationView.frame.height * (multiple + 1)))))

            headingView = customHeadingView
            headingView?.layer.zPosition = -1
            annotationView.addSubview(headingView!)
        }
    }

    func updateHeadingRotation() {
        if let heading = parent.locationManager.userHeading,
           let headingView {
            let rotation = CGFloat(heading / 180 * Double.pi)
            headingView.transform = CGAffineTransform(rotationAngle: rotation)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let customUserAnnotationView: MKAnnotationView = .init(annotation: annotation, reuseIdentifier: "UserAnnotation")
            // TODO: add Custom Image
            customUserAnnotationView.image = UIImage(systemName: "circle.fill")
            return customUserAnnotationView
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.systemRed
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}

extension Date {
    var koreaStringDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd a hh시 mm분"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
}

final class GradientTriangleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: rect.midX, y: rect.midY))
        trianglePath.addLine(to: CGPoint(x: rect.maxX * 0.2, y: rect.maxY))
        trianglePath.addLine(to: CGPoint(x: rect.maxX * 0.8, y: rect.maxY))
        trianglePath.close()

        context.saveGState()
        trianglePath.addClip()

        let colors = [
            UIColor.blue.withAlphaComponent(1.0).cgColor,
            UIColor.orange.withAlphaComponent(0.75).cgColor,
            UIColor.orange.withAlphaComponent(0.5).cgColor,
            UIColor.orange.withAlphaComponent(0.25).cgColor,
            UIColor.clear.cgColor
        ]

        let locations: [CGFloat] = [0.0, 0.25, 0.5, 0.75, 1.0]

        if let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: locations) {
            let startPoint = CGPoint(x: rect.midX, y: rect.midY)
            let endPoint = CGPoint(x: rect.midX, y: rect.maxY)

            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }

        context.restoreGState()
    }
}
