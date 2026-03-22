import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        for index in 0..<2 {
            let spot = ParkingSpotEntity(context: viewContext)
            spot.id = UUID()
            spot.nickname = "Spot \(index + 1)"
            spot.latitude = 37.3349 + Double(index) * 0.001
            spot.longitude = -122.0090 + Double(index) * 0.001
            spot.savedAt = Date()
            spot.expirationDate = Date().addingTimeInterval(3600)
            spot.alertLeadTime = 900
        }

        try? viewContext.save()
        return controller
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Parkpal")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Unresolved Core Data error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
