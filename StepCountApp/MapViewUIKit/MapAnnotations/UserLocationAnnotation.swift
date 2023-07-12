//
//  UserLocationAnnotationView.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/12.
//

import UIKit
import MapKit

final class UserLocationAnnotationView: MKAnnotationView {
    static let ID: String = "UserLocation"
    private let size: CGSize = .init(width: 20, height: 20)

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // TODO: ADD Custom Image or configure custom uiView
    private func configure() {
        self.frame = .init(origin: self.frame.origin, size: size)
        self.backgroundColor = .clear
    }
}


final class UserView: UIView {
    private let size: CGSize = .init(width: 20, height: 20)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let outerCircleRadius = min(bounds.width, bounds.height) / 2
        let outerCircleCenter = CGPoint(x: bounds.midX, y: bounds.midY)

        let innerCircleRadius = outerCircleRadius / 2
        let innerCircleCenter = outerCircleCenter

        let outerCirclePath = UIBezierPath(arcCenter: outerCircleCenter, radius: outerCircleRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        UIColor.orange.setFill()
        outerCirclePath.fill()

        let innerCirclePath = UIBezierPath(arcCenter: innerCircleCenter, radius: innerCircleRadius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        UIColor.white.setFill()
        innerCirclePath.fill()
    }

    private func configure() {
        self.frame = .init(origin: self.frame.origin, size: size)
        self.backgroundColor = .clear
    }
}
