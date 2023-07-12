//
//  GradientTriangleView.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/12.
//

import UIKit

final class GradientTriangleView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: rect.midX, y: rect.midY))
        trianglePath.addLine(to: CGPoint(x: rect.maxX * 0.2, y: rect.minY))
        trianglePath.addLine(to: CGPoint(x: rect.maxX * 0.8, y: rect.minY))
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
            let endPoint = CGPoint(x: rect.midX, y: rect.minY)

            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }

        context.restoreGState()
    }
}
