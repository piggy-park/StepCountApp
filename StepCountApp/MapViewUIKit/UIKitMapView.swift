//
//  UIKitMapView.swift
//  StepCountApp
//
//  Created by gx_piggy on 11/6/23.
//

import MapKit
import SwiftUI

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
