//
//  Extensions.swift
//  StepCountApp
//
//  Created by gx_piggy on 11/6/23.
//

import CoreLocation

extension Date {
    public var removeTimeStamp : Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return nil
        }
        return date
    }

    func dateWithoutTime() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        guard let dateWithoutTime = calendar.date(from: dateComponents) else { return Date() }
        return dateWithoutTime
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
