import SwiftUI

struct ContentView: View {
    var body: some View {
        ParkingDashboardView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ParkingSpotStore())
        .environmentObject(PurchaseManager())
}
