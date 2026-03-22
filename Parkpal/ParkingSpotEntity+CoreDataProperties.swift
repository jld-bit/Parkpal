import CoreData
import Foundation

extension ParkingSpotEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ParkingSpotEntity> {
        NSFetchRequest<ParkingSpotEntity>(entityName: "ParkingSpotEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var nickname: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var savedAt: Date?
    @NSManaged public var expirationDate: Date?
    @NSManaged public var alertLeadTime: Double
}
