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
    @State private var showPolyLine: Bool = true
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
                            let previousValue = locationManager.drawPolyline
                            locationManager.drawPolyline.toggle()
                            let newValue = locationManager.drawPolyline
                            if previousValue == true && newValue == false {
                                locationManager.savePolyLine = true
                            } else {
                                locationManager.savePolyLine = false
                            }
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
                        self.showPolyLine.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "road.lanes")
                                .foregroundStyle(.orange)
                            Text(showPolyLine ? "경로 가리기" : "경로 보기")
                                .lineLimit(1)
                                .fixedSize()
                                .foregroundStyle(colorScheme == .light ? .white : .black)
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

struct MapViewUIKit: UIViewRepresentable {
    @ObservedObject var locationManager: MapViewLocationManager
    @Binding var trackingMode: MKUserTrackingMode
    @Binding var showPolyLine: Bool
    @Binding var showDestinationDetail: Bool
    @Binding var goToCurrentUserLocation: Bool
    @Binding var distanceFromCurrentLocation: Double
    @Binding var estimatedTimeOfArrival: Int
    @Binding var estimatedStepCount: Int

    init(locationManager: MapViewLocationManager,
         trackingMode: Binding<MKUserTrackingMode>,
         showPolyLine: Binding<Bool>,
         showDestinationDetail: Binding<Bool>,
         goToCurrentUserLocation: Binding<Bool>,
         distanceFromCurrentLocation: Binding<Double>,
         estimatedTimeOfArrival: Binding<Int>,
         estimatedStepCount: Binding<Int>
    )
    {
        self.locationManager = locationManager
        self._trackingMode = trackingMode
        self._showPolyLine = showPolyLine
        self._showDestinationDetail = showDestinationDetail
        self._goToCurrentUserLocation = goToCurrentUserLocation
        self._distanceFromCurrentLocation = distanceFromCurrentLocation
        self._estimatedTimeOfArrival = estimatedTimeOfArrival
        self._estimatedStepCount = estimatedStepCount
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.register(PointSpotAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: PointSpotAnnotationView.ID)
        mapView.register(UserLocationAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: UserLocationAnnotationView.ID)
        mapView.register(ClusterAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: ClusterAnnotationView.ID)
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        context.coordinator.updateHeadingRotation()

        if locationManager.locationUpdateStatus == .startUpdating {
            view.userTrackingMode = trackingMode
            view.region = .init(center: locationManager.currentLocation.coordinate,
                                latitudinalMeters: 400,
                                longitudinalMeters: 400)
            view.addAnnotations(locationManager.pointSpotCoordinates)
            DispatchQueue.main.async {
                locationManager.locationUpdateStatus = .updating
            }
        }

        // show polyline
        if showPolyLine {
            for polyline in locationManager.polylines {
                let otherPolyline = MKPolyline(coordinates: polyline.map { $0.coordinate },
                                               count: polyline.count)
                view.addOverlay(otherPolyline)
            }
        }

        // remove all polyline
        if !showPolyLine {
            for overlay in view.overlays {
                view.removeOverlay(overlay)
            }
        }

        // go to current Location
        if goToCurrentUserLocation {
            view.region = .init(center: locationManager.currentLocation.coordinate,
                                latitudinalMeters: 400,
                                longitudinalMeters: 400)
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

    func addHeadingView(toAnnotationView annotationView: MKAnnotationView) {
        if headingView == nil {
            // 회전축
            let centerPoint: CGPoint = .init(x: annotationView.frame.width / 2,
                                             y: annotationView.frame.height / 2)
            // 크기 조절
            let multiple = 3.0
            let customHeadingView = GradientTriangleView(frame: .init(origin: .init(
                x: -multiple * (centerPoint.x),
                y: -multiple * (centerPoint.y)), size: .init(width: (annotationView.frame.width * (multiple + 1)), height: (annotationView.frame.height * (multiple + 1)))))

            headingView = customHeadingView
            annotationView.addSubview(headingView!)
            headingView?.layer.zPosition = -1
        }
    }

    func updateHeadingRotation() {
        if let heading = parent.locationManager.userHeading,
           let headingView {
            let rotation = CGFloat(heading * Double.pi / 180)
            UIView.animate(withDuration: 0.3) {
                headingView.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Custom UserLocationView
        if annotation is MKUserLocation {
            guard let userLocationAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: UserLocationAnnotationView.ID) as? UserLocationAnnotationView else { return nil }
            // HeadingView와의 Zindex 이슈로 밖에서 SubView넣어줌.
            userLocationAnnotationView.addSubview(UserView())
            addHeadingView(toAnnotationView: userLocationAnnotationView)
            return userLocationAnnotationView
        }

        // Custom PointSpotAnnotationView
        if let _ = annotation as? PointSpotAnnotation,
           let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: PointSpotAnnotationView.ID) as? PointSpotAnnotationView {
            annotationView.annotation = annotation
            annotationView.displayPriority = .required
            annotationView.canShowCallout = true
            return annotationView
        }

        // Custom ClusterAnnotationView
        if let _ = annotation as? MKClusterAnnotation,
           let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ClusterAnnotationView.ID) as? ClusterAnnotationView {
            annotationView.annotation = annotation
            return annotationView
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.parent.showDestinationDetail = true

        if let selectedCoordinate = view.annotation?.coordinate {
            parent.locationManager.getLocationName(location: .init(latitude: selectedCoordinate.latitude,
                                                                    longitude: selectedCoordinate.longitude))
        }

        if let coordinate = view.annotation?.coordinate {
            // caculate request
            let caculateRequest = MKDirections.Request()
            caculateRequest.source = .forCurrentLocation()
            caculateRequest.destination = .init(placemark: .init(coordinate: coordinate))
            caculateRequest.requestsAlternateRoutes = true // 모든 경로
            caculateRequest.transportType = .walking

            let direction = MKDirections(request: caculateRequest)

            direction.calculate { [weak self] response, _ in
                guard let response = response,
                      let self = self,
                      let shortestTravelTime = response.routes.map({ $0.expectedTravelTime }).min() else { return }
                if let shortestRoute = response.routes.first(where: { $0.expectedTravelTime == shortestTravelTime }) {

                    // 기존에 그려놨던 overlay 제거
                    for overlay in mapView.overlays {
                        mapView.removeOverlay(overlay)
                    }

                    // 최단 경로만 polyline
                    mapView.addOverlay(shortestRoute.polyline)

                    self.parent.showPolyLine = true

                    // 예상 시간, 걸음수, 거리
                    let eta = Int(shortestTravelTime / 60)
                    let distance = shortestRoute.distance
                    self.parent.distanceFromCurrentLocation = distance / 1000
                    self.parent.estimatedTimeOfArrival = eta
                    self.parent.estimatedStepCount = Int(distance / 0.7)
            }
        }
    }

        guard view is ClusterAnnotationView else { return }
        // if the user taps a cluster, zoom in
        let currentSpan = mapView.region.span
        let zoomSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / 2.0,
                                        longitudeDelta: currentSpan.longitudeDelta / 2.0)
        let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
        let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
        mapView.setRegion(zoomed, animated: true)
    }
}

extension CLLocationCoordinate2D {

    // 특정 두 위치 기준 거리 가져오기.
    func calculateDistance(to location2: CLLocationCoordinate2D) -> Double {
        let earthRadius = 6371.0 // 지구 반지름 (단위: 킬로미터)

        let lat1Rad = degreesToRadians(degrees: self.latitude)
        let lon1Rad = degreesToRadians(degrees: self.longitude)
        let lat2Rad = degreesToRadians(degrees: self.latitude)
        let lon2Rad = degreesToRadians(degrees: self.longitude)

        let deltaLat = lat2Rad - lat1Rad
        let deltaLon = lon2Rad - lon1Rad

        let a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))

        let distance = earthRadius * c

        return distance
    }

    // 특정 경위도 기준 반경 N미터 떨어져있는 경위도
    func getCoordinateWithDistanceAndBearing(distance: CLLocationDistance, bearing: Double) -> CLLocationCoordinate2D {
        let earthRadius: CLLocationDistance = 6371000 // 지구 반지름 (미터 단위)
        let angularDistance = distance / earthRadius
        let bearingRadians = bearing * .pi / 180

        let centerLatitudeRadians = self.latitude * .pi / 180
        let centerLongitudeRadians = self.longitude * .pi / 180

        let newLatitudeRadians = asin(sin(centerLatitudeRadians) * cos(angularDistance) + cos(centerLatitudeRadians) * sin(angularDistance) * cos(bearingRadians))
        let newLongitudeRadians = centerLongitudeRadians + atan2(sin(bearingRadians) * sin(angularDistance) * cos(centerLatitudeRadians), cos(angularDistance) - sin(centerLatitudeRadians) * sin(newLatitudeRadians))

        let newLatitude = newLatitudeRadians * 180 / .pi
        let newLongitude = newLongitudeRadians * 180 / .pi

        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }



    private func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
}
