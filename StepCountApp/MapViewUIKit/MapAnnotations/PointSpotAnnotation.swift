//
//  PointSpotAnnotation.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/12.
//

import UIKit
import MapKit

// 맵 위에 보여질 특정 포인트 관련 Custom View
final class PointSpotAnnotationView: MKAnnotationView {
    static let ID: String = "PointSpot"
    private let size: CGSize = .init(width: 30, height: 30)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
//        setupGestureRecognizers()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.backgroundColor = .systemPink
        self.frame = .init(origin: self.frame.origin, size: size)
        self.layer.cornerRadius = self.frame.height / 2
    }

    // MARK: -- handle Tap Gesture if want
//    private func setupGestureRecognizers() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        addGestureRecognizer(tapGesture)
//    }
//
//    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
//        self.frame.size = .init(width: size.width + 10, height: size.height + 10)
//    }

}

// 맵 위에 보여질 특정 포인트 관련 Custom View에 채워질 내용
final class PointSpotAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
}
