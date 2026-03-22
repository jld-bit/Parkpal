import CoreLocation
import Foundation
import MapKit

struct ParkingSpot: Identifiable, Equatable {
    let id: UUID
    let nickname: String
    let latitude: Double
    let longitude: Double
    let savedAt: Date
    let expirationDate: Date
    let alertLeadTime: TimeInterval

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: coordinate)
        let item = MKMapItem(placemark: placemark)
        item.name = nickname
        return item
    }

    var timeRemaining: TimeInterval {
        max(expirationDate.timeIntervalSinceNow, 0)
    }

    var totalDuration: TimeInterval {
        max(expirationDate.timeIntervalSince(savedAt), 1)
    }

    var progress: Double {
        let remaining = timeRemaining
        let total = totalDuration
        return min(max(remaining / total, 0), 1)
    }
}
