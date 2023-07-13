//
//  ClusterAnnotationView.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/13.
//

import Foundation
import MapKit

final class ClusterAnnotationView: MKAnnotationView {
    static let ID = "ClusterAnnotationView"
    override var annotation: MKAnnotation? {
        didSet {
            guard let cluster = annotation as? MKClusterAnnotation else { return }
            displayPriority = .defaultHigh

            let rect = CGRect(x: 0, y: 0, width: 40, height: 40)
            image = UIGraphicsImageRenderer.image(for: cluster.memberAnnotations, in: rect)
        }
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


// https://medium.com/@worthbak/clustering-with-mapkit-on-ios-11-part-2-2418a865543b
extension UIGraphicsImageRenderer {
    static func image(for annotations: [MKAnnotation], in rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: rect.size)

        let totalCount = annotations.count
        // 이미 방문한 장소가 Cluster에 얼만큼 되어있는지 표현 가능.
        let alReadyGoCount = 0
        let countText = "\(totalCount)"

        return renderer.image { _ in
            // total count 색상
            UIColor(red: 245 / 255.0, green: 166 / 255.0, blue: 35 / 255.0, alpha: 1.0).setFill()
            UIBezierPath(ovalIn: rect).fill()
            // alReady go count 색상
            UIColor(red: 245 / 255.0, green: 166 / 255.0, blue: 35 / 255.0, alpha: 1.0).setFill()
            let piePath = UIBezierPath()
            piePath.addArc(withCenter: CGPoint(x: 20, y: 20), radius: 20,
                           startAngle: 0,
                           endAngle: (CGFloat.pi * 2.0 * CGFloat(alReadyGoCount)) / CGFloat(totalCount),
                           clockwise: true)
            piePath.addLine(to: CGPoint(x: 20, y: 20))
            piePath.close()
            piePath.fill()

            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 24, height: 24)).fill()

            countText.drawForCluster(in: rect)
        }
    }
}

extension String {
    func drawForCluster(in rect: CGRect) {
        let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                           NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]
        let textSize = self.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width / 2) - (textSize.width / 2),
                              y: (rect.height / 2) - (textSize.height / 2),
                              width: textSize.width,
                              height: textSize.height)

        self.draw(in: textRect, withAttributes: attributes)
    }
}
