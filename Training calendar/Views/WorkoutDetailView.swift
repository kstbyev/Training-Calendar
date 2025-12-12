import SwiftUI
import MapKit

struct WorkoutDetailView: View {
    var coordinator: AppCoordinator
    let workoutKey: String
    @Binding var path: NavigationPath

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var metadata: WorkoutMetadata?
    @State private var diagramData: [DiagramDataPoint] = []
    @State private var isLoading = true

    private let apiService = MockAPIService.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if isLoading {
                    ProgressView("Загрузка данных тренировки...")
                        .padding()
                } else if let metadata = metadata {
                    workoutHeader(metadata: metadata)

                    workoutStats(metadata: metadata)

                    if !diagramData.isEmpty {
                        heartRateChartSection

                        speedChartSection

                        mapSection
                    }

                    if let comment = metadata.comment, !comment.isEmpty {
                        commentSection(comment: comment)
                    }
                } else {
                    errorView
                }
            }
            .padding()
        }
        .navigationTitle("Детали тренировки")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            loadWorkoutData()
        }
    }

    private func workoutHeader(metadata: WorkoutMetadata) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(metadata.workoutActivityType.color))
                    .frame(width: 64, height: 64)

                Image(systemName: metadata.workoutActivityType.iconName)
                    .foregroundColor(.white)
                    .font(.system(size: 28))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(metadata.workoutActivityType.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(metadata.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private func workoutStats(metadata: WorkoutMetadata) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Дистанция",
                    value: metadata.formattedDistance,
                    icon: "figure.walk"
                )

                StatCard(
                    title: "Длительность",
                    value: metadata.formattedDuration,
                    icon: "clock"
                )
            }

            HStack(spacing: 16) {
                StatCard(
                    title: "Температура",
                    value: metadata.formattedAvgTemp,
                    icon: "thermometer"
                )

                StatCard(
                    title: "Влажность",
                    value: metadata.formattedAvgHumidity,
                    icon: "drop"
                )
            }
        }
    }

    private var heartRateChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("График пульса")
                .font(.title3)
                .fontWeight(.semibold)

            HeartRateChart(dataPoints: diagramData)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }

    private func commentSection(comment: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Комментарий")
                .font(.title3)
                .fontWeight(.semibold)

            Text(comment)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
    }

    private var speedChartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("График скорости")
                .font(.title3)
                .fontWeight(.semibold)
            
            SpeedChart(dataPoints: diagramData)
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }

    private var mapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Маршрут")
                .font(.title3)
                .fontWeight(.semibold)
            
            if let firstCoordinate = diagramData.first(where: { $0.latitude != 0 && $0.longitude != 0 }) {
                WorkoutMapView(dataPoints: diagramData)
                    .frame(height: 250)
                    .cornerRadius(12)
                    .padding(.horizontal)
            } else {
                Text("Нет данных GPS для отображения маршрута.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text("Ошибка загрузки данных")
                .font(.title3)

            Text("Не удалось загрузить информацию о тренировке")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private func loadWorkoutData() {
        isLoading = true

        // Load metadata
        metadata = apiService.getWorkoutMetadata(workoutId: workoutKey, email: "test@gmail.com")

        // Load diagram data
        diagramData = apiService.getDiagramData(workoutId: workoutKey, email: "test@gmail.com") ?? []

        isLoading = false
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        VStack(spacing: horizontalSizeClass == .compact ? 6 : 8) {
            Image(systemName: icon)
                .font(.system(size: horizontalSizeClass == .compact ? 20 : 24))
                .foregroundColor(.accentColor)

            Text(value)
                .font(horizontalSizeClass == .compact ? .headline : .title3)
                .fontWeight(.semibold)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.9)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, horizontalSizeClass == .compact ? 12 : 16)
        .padding(.horizontal, horizontalSizeClass == .compact ? 8 : 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

struct HeartRateChart: View {
    let dataPoints: [DiagramDataPoint]

    private var heartRateValues: [Double] {
        dataPoints.map { Double($0.heartRate) }
    }

    private var maxHeartRate: Double {
        heartRateValues.max() ?? 200
    }

    private var minHeartRate: Double {
        heartRateValues.min() ?? 60
    }

    private var timeLabels: [String] {
        dataPoints.enumerated().compactMap { index, point in
            if index % 5 == 0 { // Show every 5th point
                return point.formattedTime
            }
            return nil
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // Chart area
                ZStack {
                    // Grid lines
                    Path { path in
                        let yStep = geometry.size.height / 5
                        for i in 0...5 {
                            let y = geometry.size.height - CGFloat(i) * yStep
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)

                    // Heart rate line
                    Path { path in
                        guard !dataPoints.isEmpty else { return }

                        let points = dataPoints.enumerated().map { index, point -> CGPoint in
                            let x = geometry.size.width * CGFloat(index) / CGFloat(max(1, dataPoints.count - 1))
                            let normalizedHeartRate = (Double(point.heartRate) - minHeartRate) / (maxHeartRate - minHeartRate)
                            let y = geometry.size.height * (1 - CGFloat(normalizedHeartRate))
                            return CGPoint(x: x, y: y)
                        }

                        if let firstPoint = points.first {
                            path.move(to: firstPoint)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color.red, lineWidth: 2)

                    // Data points
                    ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, point in
                        let x = geometry.size.width * CGFloat(index) / CGFloat(max(1, dataPoints.count - 1))
                        let normalizedHeartRate = (Double(point.heartRate) - minHeartRate) / (maxHeartRate - minHeartRate)
                        let y = geometry.size.height * (1 - CGFloat(normalizedHeartRate))

                        Circle()
                            .fill(Color.red)
                            .frame(width: 4, height: 4)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: geometry.size.height - 40)

                // Time labels
                HStack {
                    ForEach(timeLabels, id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .frame(height: 20)
            }
        }
    }
}

struct SpeedChart: View {
    let dataPoints: [DiagramDataPoint]

    private var speedValues: [Double] {
        dataPoints.map { $0.speedKmh }
    }

    private var maxSpeed: Double {
        speedValues.max() ?? 20
    }

    private var minSpeed: Double {
        speedValues.min() ?? 0
    }

    private var timeLabels: [String] {
        dataPoints.enumerated().compactMap { index, point in
            if index % 5 == 0 { // Show every 5th point
                return point.formattedTime
            }
            return nil
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // Chart area
                ZStack {
                    // Grid lines
                    Path { path in
                        let yStep = geometry.size.height / 5
                        for i in 0...5 {
                            let y = geometry.size.height - CGFloat(i) * yStep
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)

                    // Speed line
                    Path { path in
                        guard !dataPoints.isEmpty else { return }

                        let points = dataPoints.enumerated().map { index, point -> CGPoint in
                            let x = geometry.size.width * CGFloat(index) / CGFloat(max(1, dataPoints.count - 1))
                            let normalizedSpeed = (point.speedKmh - minSpeed) / (maxSpeed - minSpeed)
                            let y = geometry.size.height * (1 - CGFloat(normalizedSpeed))
                            return CGPoint(x: x, y: y)
                        }

                        if let firstPoint = points.first {
                            path.move(to: firstPoint)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2) // Синий цвет для скорости

                    // Data points
                    ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, point in
                        let x = geometry.size.width * CGFloat(index) / CGFloat(max(1, dataPoints.count - 1))
                        let normalizedSpeed = (point.speedKmh - minSpeed) / (maxSpeed - minSpeed)
                        let y = geometry.size.height * (1 - CGFloat(normalizedSpeed))

                        Circle()
                            .fill(Color.blue)
                            .frame(width: 4, height: 4)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: geometry.size.height - 40)

                // Time labels
                HStack {
                    ForEach(timeLabels, id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .frame(height: 20)
            }
        }
    }
}

// MARK: - Map Polyline Support

struct WorkoutMapView: View {
    let dataPoints: [DiagramDataPoint]

    @State private var region: MKCoordinateRegion

    init(dataPoints: [DiagramDataPoint]) {
        self.dataPoints = dataPoints
        _region = State(initialValue: Self.initialRegion(for: dataPoints))
    }

    private static func initialRegion(for dataPoints: [DiagramDataPoint]) -> MKCoordinateRegion {
        guard let firstPoint = dataPoints.first(where: { $0.latitude != 0 && $0.longitude != 0 }) else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173), // Default Moscow center
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: firstPoint.latitude, longitude: firstPoint.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    private var coordinates: [CLLocationCoordinate2D] {
        dataPoints
            .filter { $0.latitude != 0 && $0.longitude != 0 }
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    var body: some View {
        if !coordinates.isEmpty {
            MapViewRepresentable(region: $region,  polylineCoordinates: coordinates)
                .onAppear(perform: adjustMapRegion)
        } else {
            Map(coordinateRegion: $region)
        }
    }

    private func adjustMapRegion() {
        guard !coordinates.isEmpty else { return }

        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }

        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max() else { return }

        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2

        let spanLat = max((maxLat - minLat) * 1.5, 0.005)
        let spanLon = max((maxLon - minLon) * 1.5, 0.005)

        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }
}

// MARK: - UIKit MapKit Polyline Representable

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var polylineCoordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region, animated: true)

        // Remove existing overlays
        uiView.removeOverlays(uiView.overlays)

        // Add polyline
        if !polylineCoordinates.isEmpty {
            let polyline = MKPolyline(coordinates: polylineCoordinates, count: polylineCoordinates.count)
            uiView.addOverlay(polyline)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor.systemBlue
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(coordinator: AppCoordinator(), workoutKey: "7823456789012345", path: .constant(NavigationPath()))
    }
}

