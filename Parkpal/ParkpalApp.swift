import SwiftUI

@main
struct ParkpalApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var spotStore = ParkingSpotStore()
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(spotStore)
                .environmentObject(purchaseManager)
                .task {
                    await purchaseManager.loadProducts()
                    await purchaseManager.updatePurchasedState()
                }
        }
    }
}
