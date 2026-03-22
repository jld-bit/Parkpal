import MapKit
import SwiftUI

struct ParkingMapCard: View {
    let spot: ParkingSpot

    @State private var cameraPosition: MapCameraPosition

    init(spot: ParkingSpot) {
        self.spot = spot
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: spot.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Saved Map", systemImage: "parkingsign.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
                Text(spot.nickname)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Map(position: $cameraPosition) {
                Marker(spot.nickname, coordinate: spot.coordinate)
                    .tint(.yellow)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 16, y: 8)
    }
}
