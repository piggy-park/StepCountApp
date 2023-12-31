////
////  MapViewModel.swift
////  HealthKitPractive
////
////  Created by 박진섭 on 2023/06/22.
////
//
//import Foundation
//import CoreData
//import MapKit
//
//final class MapViewModelSwiftUI: NSObject, ObservableObject {
//    var currentLocation: CLLocation?
//    @Published var userHeading: Double?
//    @Published var pointSpotCoordinates: [PointSpotAnnotation] = []
//
//    private let locationManager: CLLocationManager = CLLocationManager()
//
//    override init() {
//        super.init()
//        configureLocationManager()
//    }
//
//    func startUpdatingLocation() {
//        checkAuthorization(self.locationManager)
//    }
//
//    func stopUpdatingLocation() {
//        self.locationManager.stopUpdatingHeading()
//        self.locationManager.stopUpdatingLocation()
//    }
//
//    // configure Location Manager
//    private func configureLocationManager(_ accuracy: CLLocationAccuracy = kCLLocationAccuracyBest) {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = accuracy
//        locationManager.distanceFilter = 10
//        locationManager.headingFilter = 0.1
//    }
//
//    // 앱 권한별 상태 설정
//    private func checkAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .notDetermined:
//            manager.requestWhenInUseAuthorization()
//        case .restricted, .denied:
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//        case .authorizedWhenInUse, .authorizedAlways:
//            manager.startUpdatingLocation()
//            manager.startUpdatingHeading()
//        @unknown default:
//            break
//        }
//    }
//
//    private func locationServicesEnabled() async -> Bool {
//        return CLLocationManager.locationServicesEnabled()
//    }
//
//    private func roundNumber(_ with: Double = 100, number: Double) -> Double {
//        return round(number * with) / with
//    }
//}
//
//extension MapViewModelSwiftUI: CLLocationManagerDelegate {
//    // 권한이 바뀌었을 때
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        Task {
//            if await locationServicesEnabled() {
//                checkAuthorization(manager)
//            }
//        }
//    }
//
//    // 각도
//    func locationManager(_ manager: CLLocationManager,
//                         didUpdateHeading newHeading: CLHeading) {
//        if newHeading.headingAccuracy < 0 { return }
//
//        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
//        if let userHeading {
//            if abs(userHeading - heading) > 5 {
//                self.userHeading = heading
//            }
//        } else {
//            self.userHeading = heading
//        }
//    }
//
//    // 위치 정보 업데이트
//    func locationManager(_ manager: CLLocationManager,
//                         didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//
//        // 현재 정보 저장
//        self.currentLocation = location
//
//        if pointSpotCoordinates.isEmpty {
//            setPointSpotCoordinates()
//        }
//    }
//
//    // TODO: 위치를 가지고 오지 못할 때 에러 처리
//    func locationManager(_ manager: CLLocationManager,
//                         didFailWithError error: Error) {
//        print("Get Location Error: \(error)")
//    }
//
//    func getNewPoint() {
//        self.pointSpotCoordinates = []
//        setPointSpotCoordinates()
//    }
//
//    private func setPointSpotCoordinates() {
//        if let currentLocation = currentLocation?.coordinate {
//            if pointSpotCoordinates.isEmpty {
//                let location1 = getCoordinateWithDistanceAndBearing(from: currentLocation, distance: 100, bearing: 0)
//                let location2 = getCoordinateWithDistanceAndBearing(from: currentLocation, distance: 100, bearing: 90)
//                let location3 = getCoordinateWithDistanceAndBearing(from: currentLocation, distance: 100, bearing: 180)
//                let location4 = getCoordinateWithDistanceAndBearing(from: currentLocation, distance: 100, bearing: 270)
//
//
//                pointSpotCoordinates.append(contentsOf: [PointSpotAnnotation(coordinate: location1, title: "spot1", subtitle: ""),
//                                                         PointSpotAnnotation(coordinate: location2, title: "spot2", subtitle: ""),
//                                                         PointSpotAnnotation(coordinate: location3, title: "spot3", subtitle: ""),
//                                                         PointSpotAnnotation(coordinate: location4, title: "spot4", subtitle: "")]
//                )
//            }
//        }
//    }
//
//    // 특정 경위도 기준 반경 N미터 떨어져있는 경위도
//    private func getCoordinateWithDistanceAndBearing(from centerCoordinate: CLLocationCoordinate2D, distance: CLLocationDistance, bearing: Double) -> CLLocationCoordinate2D {
//        let earthRadius: CLLocationDistance = 6371000 // 지구 반지름 (미터 단위)
//        let angularDistance = distance / earthRadius
//        let bearingRadians = bearing * .pi / 180
//
//        let centerLatitudeRadians = centerCoordinate.latitude * .pi / 180
//        let centerLongitudeRadians = centerCoordinate.longitude * .pi / 180
//
//        let newLatitudeRadians = asin(sin(centerLatitudeRadians) * cos(angularDistance) + cos(centerLatitudeRadians) * sin(angularDistance) * cos(bearingRadians))
//        let newLongitudeRadians = centerLongitudeRadians + atan2(sin(bearingRadians) * sin(angularDistance) * cos(centerLatitudeRadians), cos(angularDistance) - sin(centerLatitudeRadians) * sin(newLatitudeRadians))
//
//        let newLatitude = newLatitudeRadians * 180 / .pi
//        let newLongitude = newLongitudeRadians * 180 / .pi
//
//        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
//    }
//}
//
//final class PointSpotAnnotation: NSObject, MKAnnotation {
//    var coordinate: CLLocationCoordinate2D
//    var title: String?
//    var subtitle: String?
//
//    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
//        self.coordinate = coordinate
//        self.title = title
//        self.subtitle = subtitle
//    }
//}
