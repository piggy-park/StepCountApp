//
//  StepCountMapView.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/04.
//

import SwiftUI
import MapKit

struct StepCountMapView: View {
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    @ObservedObject var mapViewManager: MapViewManager
    @State private var polyLines: [[CLLocationCoordinate2D]] = []
    @State private var currentPolyLine: [CLLocationCoordinate2D] = []
    @State private var userHeading: Double?
    @Binding var selectedPoint: PointSpotAnnotation?
    @Binding var position: MapCameraPosition
    @Binding var drawPolyLine: Bool
    @Binding var showPolyLine: Bool
    @State private var degree = 10.0
    @ViewBuilder
    private func buildCustomUserView() -> some View {
        // TODO: 정사각형
        GeometryReader { reader in
            ZStack {
                InvertedTriangle()
                    .fill(Gradient(colors: [.clear, .orange]))
                    .opacity(0.5)
                    .frame(height: 60)

                Circle()
                    .foregroundStyle(.orange)
                Circle()
                    .foregroundStyle(.white)
                    .padding(5)
            }
        }
    }

    var body: some View {
        ZStack {
            Map(position: $position) {
                UserAnnotation { location in
                    buildCustomUserView()
                        .onChange(of: location) { oldValue, newValue in
                            if let currentLocation = oldValue.location?.coordinate {
                                if drawPolyLine {
                                    currentPolyLine.append(currentLocation)
                                    addPolyLine(currentPolyLine)
                                } else {
                                    currentPolyLine = []
                                }
                            }
                        }
                        .onChange(of: degree) { oldValue, newValue in
                            print("change!2")
                        }
                        .rotationEffect(.init(degrees: degree))
                }

                ForEach(mapViewManager.pointSpotCoordinates, id: \.self) { point in
                    Annotation(point.title ?? "", coordinate: point.coordinate) {
                        if point == selectedPoint {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.white)
                                Circle()
                                    .foregroundStyle(.blue)
                                    .padding(5)
                            }
                            .frame(width: 30, height: 30)
                            .onTapGesture(perform: {
                                self.selectedPoint = nil
                            })
                        } else {
                            Text("20")
                                .fixedSize()
                                .foregroundStyle(.white)
                                .padding(5)
                                .background(.blue, in: Circle())
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    self.selectedPoint = point
                                    hapticGenerator.impactOccurred()
                                }
                        }
                    }
                }
                .annotationTitles(.hidden)
                
                if showPolyLine {
                    ForEach(polyLines, id: \.self) {
                        MapPolyline(coordinates: $0)
                            .stroke(.red, lineWidth: 8.0)
                            .mapOverlayLevel(level: .aboveRoads)
                    }
                }
            }
            Button("taptap") {
                self.degree += 10
                self.position = .automatic
            }
            .padding()
            .background(.red)
        }
        .onChange(of: drawPolyLine) { oldValue, newValue in
            // 기록 중지시 현재까지 기록된 polyline polyline배열에 추가
            if oldValue == true && newValue == false {
                self.polyLines.append(self.currentPolyLine)
            }
        }
    }

    // 그려져야할 polyLine의 배열에 마지막으로 현재 polyline 저장
    private func addPolyLine(_ polyLine: [CLLocationCoordinate2D]) {
        if !polyLines.isEmpty {
            polyLines[polyLines.count - 1] = polyLine
        } else {
            polyLines.append([.init()])
        }
    }
}

extension UserLocation: Equatable {
    public static func == (lhs: UserLocation, rhs: UserLocation) -> Bool {
        lhs.location?.coordinate == lhs.location?.coordinate
    }
}

struct InvertedTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}
