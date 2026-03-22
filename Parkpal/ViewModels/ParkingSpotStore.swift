import CoreData
import CoreLocation
import Foundation

@MainActor
final class ParkingSpotStore: ObservableObject {
    @Published private(set) var savedSpots: [ParkingSpot] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchSpots()
    }

    func fetchSpots() {
        let request = ParkingSpotEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ParkingSpotEntity.savedAt, ascending: false)]

        do {
            savedSpots = try context.fetch(request).compactMap(Self.makeSpot)
        } catch {
            print("Failed to fetch spots: \(error.localizedDescription)")
        }
    }

    func saveSpot(from location: CLLocation, nickname: String, duration: TimeInterval, alertLeadTime: TimeInterval, allowMultiple: Bool) async -> ParkingSpot? {
        if !allowMultiple {
            deleteAllSpots()
        }

        let entity = ParkingSpotEntity(context: context)
        entity.id = UUID()
        entity.nickname = nickname
        entity.latitude = location.coordinate.latitude
        entity.longitude = location.coordinate.longitude
        entity.savedAt = Date()
        entity.expirationDate = Date().addingTimeInterval(duration)
        entity.alertLeadTime = alertLeadTime

        do {
            try context.save()
            fetchSpots()
            return savedSpots.first(where: { $0.id == entity.id })
        } catch {
            print("Failed to save spot: \(error.localizedDescription)")
            return nil
        }
    }

    func delete(_ spot: ParkingSpot) {
        let request = ParkingSpotEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", spot.id as CVarArg)

        if let entity = try? context.fetch(request).first {
            context.delete(entity)
            try? context.save()
            NotificationManager.shared.removeReminder(for: spot.id)
            fetchSpots()
        }
    }

    private func deleteAllSpots() {
        savedSpots.forEach { NotificationManager.shared.removeReminder(for: $0.id) }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ParkingSpotEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(deleteRequest)
        try? context.save()
    }

    private static func makeSpot(from entity: ParkingSpotEntity) -> ParkingSpot? {
        guard let id = entity.id,
              let nickname = entity.nickname,
              let savedAt = entity.savedAt,
              let expirationDate = entity.expirationDate else {
            return nil
        }

        return ParkingSpot(
            id: id,
            nickname: nickname,
            latitude: entity.latitude,
            longitude: entity.longitude,
            savedAt: savedAt,
            expirationDate: expirationDate,
            alertLeadTime: entity.alertLeadTime
        )
    }
}
