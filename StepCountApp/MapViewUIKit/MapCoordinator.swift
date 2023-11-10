//
//  MapCoordinator.swift
//  StepCountApp
//
//  Created by gx_piggy on 11/6/23.
//

import Foundation
import MapKit

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
