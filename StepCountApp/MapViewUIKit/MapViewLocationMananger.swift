//
//  MapViewModel.swift
//  KlipApp
//
//  Created by 박진섭 on 2022/10/18.
//

import Foundation
import CoreData
import MapKit

final class MapViewLocationMananger: NSObject, ObservableObject {
    private let locationManager: CLLocationManager = CLLocationManager()
    private var currentPolyline: [CLLocation] = []
    @Published var drawPolyline: Bool = false
    @Published var polylines: [[CLLocation]] = []
    @Published var userHeading: Double?

    var currentLocation: CLLocation = .init()

    override init() {
        super.init()
        setManager()
    }

    func startUpdatingLocation() {
        checkAuthorization(self.locationManager)
    }

    func stopUpdatingLocation() {
        self.locationManager.stopUpdatingHeading()
        self.locationManager.stopUpdatingLocation()
    }

    // Location Manager Setting
    private func setManager(_ accuracy: CLLocationAccuracy = kCLLocationAccuracyBest) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = 10
        locationManager.headingFilter = 0.1
    }

    // 앱 권한별 상태 설정
    private func checkAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            manager.startUpdatingHeading()
        @unknown default:
            break
        }
    }

    private func locationServicesEnabled() async -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    private func roundNumber(_ with: Double = 100, number: Double) -> Double {
        return round(number * with) / with
    }
}

extension MapViewLocationMananger: CLLocationManagerDelegate {
    // 권한이 바뀌었을 때
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task {
            if await locationServicesEnabled() {
                checkAuthorization(manager)
            }
        }
    }

    // 각도
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
         if newHeading.headingAccuracy < 0 { return }

         let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
         userHeading = heading
        }

//    func locationManager(_ manager: CLLocationManager,
//                         didUpdateHeading newHeading: CLHeading) {
//        let newCurrentUserHeading = newHeading.trueHeading
//
//        if let userHeading {
//            if abs(userHeading - newCurrentUserHeading) > 5 {
//                self.userHeading = newCurrentUserHeading
//            }
//        } else {
//            userHeading = newCurrentUserHeading
//        }
//    }

    // 위치 정보 업데이트
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location

        // For mulit polyline
        if drawPolyline {
            self.currentPolyline.append(location)
            if !polylines.isEmpty {
                self.polylines[polylines.count - 1] = currentPolyline
            } else {
                self.polylines.append([])
            }
        } else {
            currentPolyline = []
        }
    }

    // TODO: 위치를 가지고 오지 못할 때 에러 처리
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Core Location Error : \(error)")
    }
}
