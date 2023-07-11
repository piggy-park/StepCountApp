//
//  DestinationDetailView.swift
//  StepCountApp
//
//  Created by 박진섭 on 2023/07/07.
//

import SwiftUI
import MapKit

struct DestinationDetailView: View {
    @Environment(\.colorScheme) private var colorScheme

    @Binding var drawPolyLine: Bool
    @Binding var estimatedStepCount: Int
    @Binding var estimatedTimeOfArrival: Int
    @Binding var distanceFromCurrentLocation: Double
    @Binding var showPolyLine: Bool
    @Binding var trackingMode: MKUserTrackingMode

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }

    @ViewBuilder
    private func buildButtons() -> some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .trailing) {
                HStack(spacing: 16) {
                    Button {
                        drawPolyLine.toggle()
                    } label: {
                        HStack {
                            if drawPolyLine {
                                Image(systemName: "stop.circle.fill")
                                    .foregroundStyle(.orange)
                            } else {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.orange)
                            }
                            Text(drawPolyLine ? "기록 중지" : "기록 시작")
                                .foregroundColor(colorScheme == .light ? .white : .black)
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.primary)
                        }
                    }

                    Button {
                        self.showPolyLine.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "road.lanes")
                                .foregroundStyle(.orange)
                            Text("경로 보기")
                                .lineLimit(1)
                                .fixedSize()
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                        }
                    }
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color.primary)
                    }

                    Button {
                        trackingMode = .followWithHeading
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.orange)
                            Text("내 위치")
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                        }
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
                .padding([.leading, .trailing], 15)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(Color.primary)
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            // TODO: 위치정보에 따라 바꿀것.
                            Text("그라운드 X에 가면")
                                .foregroundColor(.gray)
                            Spacer().frame(height: 8)
                            Text("20원 지급")
                                .foregroundStyle(Color.blue)
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer().frame(height: 16)
                            Text("현재 위치에서 \(estimatedStepCount)걸음 • \(estimatedTimeOfArrival)분 예상")
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                                .fontWeight(.bold)
                            Text("거리: \(distanceFromCurrentLocation)KM")
                                .foregroundStyle(colorScheme == .light ? .white : .black)
                        }
                        .padding(.top, 30)
                        .padding(.leading, 20)

                        Image(systemName: "figure.run.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(colorScheme == .light ? .white : .black)

                    }
                }
                .frame(height: 180)
                .padding([.leading, .trailing], 15)
                .padding(.bottom, 10)

            }
        }
    }
}
