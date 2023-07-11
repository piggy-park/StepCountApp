////
////  MapViewSwiftUI.swift
////  HealthKitPractive
////
////  Created by 박진섭 on 2023/06/28.
////
//
//import SwiftUI
//import MapKit
//
//struct MapViewSwiftUI: View {
//    // 권한 설정
//    private let locationManager: CLLocationManager = .init()
//    // 장소 검색 결과 담김
//    @State private var searchResult: [MKMapItem] = []
//    // camera 포지션 설정가능
//    // MapCamera 이니셜라이저를 적용하면 3D구조의 카메라도 구현가능하다.
//    @State private var position: MapCameraPosition = .automatic
//    // 현재 카메라 위치에 따라 검색 결과 보여주기 위함.
//    @State private var visibleRegion: MKCoordinateRegion?
//    // MapItem을 선택하면 풍선 애니메이션이 생긴다.
//    // 이를 구현하지 않으면 클릭 이벤트 발생 하지 않음.
//    @State private var selectedResult: MKMapItem?
//    @State private var selectedTag: Int?
//
//    @State private var route: MKRoute?
//
//    var body: some View {
//        Map(position: $position, selection: $selectedResult) {
//            // custom 가능!
//            UserAnnotation(anchor: .bottom) {
//                ZStack {
//                    Circle()
//                        .foregroundStyle(.orange)
//                    Circle()
//                        .foregroundStyle(.white)
//                        .padding(5)
//                }
//            }
//
//
////
////            ForEach(searchResult, id: \.self) { result in
////                Annotation("hi", coordinate: result.bookmark.coordinate) {
////                    ZStack {
////                        Image(systemName: "person")
////                    }
////                    .onTapGesture {
////                        print("HI!")
////                    }
////                }
////            }
//
////                Annotation("hi", coordinate: result.bookmark.coordinate) {
////                    Circle()
////                        .onTapGesture {
////                            print("HI!")
////                        }
////                }
////                Marker(item: result)
////                    .tint(Color.blue)
////            }
////            .annotationTitles(.hidden)
//
////            ForEach(Array(zip(searchResult.indices, searchResult)), id: \.0) { index, result in
////                Marker("123", monogram: selectedTag == index ? "" : "20", coordinate: result.placemark.coordinate)
////                    .tint(Color.blue)
////                    .tag(index)
////            }
////            .annotationTitles(.hidden)
//
//            if let route {
//                MapPolyline(route)
//                    .stroke(.blue, lineWidth: 5)
//            }
//        }
//        .mapControls{
//            MapUserLocationButton()
//        }
//        .safeAreaInset(edge: .bottom, content: {
//            HStack {
//                Spacer()
//                VStack(spacing: 0) {
//                    if let selectedResult {
//                        ItemInfoView(selectedResult: selectedResult, route: route)
//                            .frame(height: 400)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .padding([.top, .horizontal])
//                    }
//                    SearchButton(position: $position,
//                                 searchResults: $searchResult,
//                                 visibleRegion: $visibleRegion)
//                    .padding(.top)
//                }
//                Spacer()
//            }
//            .background(.thinMaterial)
//        })
//        .onChange(of: searchResult) {
//            position = .automatic
//        }
//        // 현재 카메라의 Context를 가져올 수 있음.
//        .onMapCameraChange { context in
//            visibleRegion = context.region
//            // 확대 축소시에 선택된 marker 초기화.
//            selectedResult = nil
//        }
//        .onAppear {
//            checkAuthorization(locationManager)
//        }
//        .onChange(of: selectedResult) {
//            getDirections()
//        }
//        .onChange(of: selectedTag) { oldValue, newValue in
//            print(oldValue ?? 0)
//            print(newValue ?? 0)
//        }
//    }
//
//
//    // 앱 권한별 상태 설정
//    private func checkAuthorization(_ manager: CLLocationManager) {
//        switch manager.authorizationStatus {
//        case .notDetermined:
//            manager.requestWhenInUseAuthorization()
//        case .restricted, .denied:
//            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
//        case .authorizedWhenInUse, .authorizedAlways:
//            manager.startUpdatingLocation()
//            manager.startUpdatingHeading()
//        @unknown default:
//            break
//        }
//    }
//
//    func getDirections() {
//        route = nil
//        guard let selectedResult else { return }
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .판교경위도))
//
//        Task {
//            let directions = MKDirections(request: request)
//            let response = try? await directions.calculate()
//            route = response?.routes.first
//        }
//    }
//
//}
////
////#Preview {
////    MapViewSwiftUI()
////}
//
//struct SearchButton: View {
//
//    @Binding var position: MapCameraPosition
//    @Binding var searchResults: [MKMapItem]
//    @Binding var visibleRegion: MKCoordinateRegion?
//
//    var body: some View {
//        HStack {
//            Button {
//                search(for: "playground")
//            } label: {
//                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
//            }
//            .buttonStyle(.borderedProminent)
//
//            Button {
//                search(for: "beach")
//            } label: {
//                Label("Beaches", systemImage: "beach.umbrella")
//            }
//            .buttonStyle(.borderedProminent)
//
//            Button {
//                position = .region(.판교역Region)
//            } label: {
//                Label("Beaches", systemImage: "train.side.rear.car")
//            }
//            .buttonStyle(.borderedProminent)
//
//            Button {
//                position = .userLocation(followsHeading: true, fallback: .automatic)
//            } label: {
//                Label("people", systemImage: "person.fill")
//            }
//            .buttonStyle(.bordered)
//
//
//        }
//        .labelStyle(.iconOnly)
//    }
//
//
//    func search(for query: String) {
//        let request = MKLocalSearch.Request()
//        request.naturalLanguageQuery = query
//        request.resultTypes = .pointOfInterest
//        request.region = visibleRegion ?? MKCoordinateRegion (
//            center: .annotaion1,
//            span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1)
//        )
//
//        Task {
//            let search = MKLocalSearch(request: request)
//            let response = try? await search.start()
//            searchResults = response?.mapItems ?? []
//        }
//    }
//
//}
//
//struct ItemInfoView: View {
//    @State private var lookAroundScene: MKLookAroundScene? = nil
//    let selectedResult: MKMapItem
//    let route: MKRoute?
//
//    init(lookAroundScene: MKLookAroundScene? = nil, selectedResult: MKMapItem, route: MKRoute?) {
//        self.lookAroundScene = lookAroundScene
//        self.selectedResult = selectedResult
//        self.route = route
//    }
//
//    private var travelTime: String? {
//        guard let route else { return nil }
//        let formatter = DateComponentsFormatter()
//        formatter.unitsStyle = .abbreviated
//        formatter.allowedUnits = [.hour, .minute]
//        return formatter.string(from: route.expectedTravelTime)
//    }
//
//    var body: some View {
//        LookAroundPreview(initialScene: lookAroundScene)
//            .overlay(alignment: .bottomTrailing) {
//                HStack {
//                    Text("\(selectedResult.name ?? "")")
//                    if let travelTime {
//                        Text(travelTime)
//                    }
//                }
//            .font(.caption)
//            .foregroundStyle(.white)
//            .padding(10)
//            }
//            .onAppear {
//                getLookAroundScene()
//            }
//            .onChange(of: selectedResult) {
//                getLookAroundScene()
//            }
//    }
//
//    func getLookAroundScene() {
//        lookAroundScene = nil
//        Task {
//            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
//            lookAroundScene = try? await request.scene
//        }
//    }
//}
