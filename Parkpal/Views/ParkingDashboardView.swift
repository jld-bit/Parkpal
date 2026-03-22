import MapKit
import SwiftUI

struct ParkingDashboardView: View {
    @EnvironmentObject private var store: ParkingSpotStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @StateObject private var locationManager = LocationManager()

    @State private var selectedDuration: TimeInterval = 7200
    @State private var selectedAlertLeadTime: TimeInterval = 900
    @State private var nickname = "Sunny Spot"
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let durations: [TimeInterval] = [1800, 3600, 7200, 14400]
    private let alertOptions: [TimeInterval] = [300, 900, 1800]

    private var activeSpot: ParkingSpot? {
        store.savedSpots.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    heroCard
                    configurationCard

                    if let spot = activeSpot {
                        CircularCountdownView(progress: spot.progress, timeRemaining: spot.expirationDate.timeIntervalSince(now))
                        ParkingMapCard(spot: spot)
                        actionRow(for: spot)
                    } else {
                        emptyState
                    }

                    upgradeCard
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.18), Color.blue.opacity(0.14), Color.green.opacity(0.14)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Parkpal")
            .task {
                await NotificationManager.shared.requestAuthorization()
                locationManager.requestAccess()
            }
            .onReceive(timer) { value in
                now = value
            }
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Keep your parking spot colorful, visible, and on time.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Save your current location, watch the countdown ring, and jump back with Apple Maps navigation.")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.92))

            Button {
                saveCurrentSpot()
            } label: {
                Label("Save Spot", systemImage: "location.fill")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.yellow)
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            }
            .shadow(color: .yellow.opacity(0.25), radius: 16, y: 8)
        }
        .padding(24)
        .background(
            LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: .blue.opacity(0.24), radius: 20, y: 10)
    }

    private var configurationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Parking setup")
                .font(.title3.bold())

            TextField("Spot nickname", text: $nickname)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading) {
                Text("Expiration")
                    .font(.headline)
                Picker("Expiration", selection: $selectedDuration) {
                    ForEach(durations, id: \.self) { duration in
                        Text(durationLabel(for: duration)).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading) {
                Text("Reminder")
                    .font(.headline)
                Picker("Reminder", selection: $selectedAlertLeadTime) {
                    ForEach(alertOptions, id: \.self) { option in
                        Text(reminderLabel(for: option)).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 12, height: 12)
                Text(purchaseManager.unlockedProFeatures ? "Pro unlocked: save multiple spots and custom alerts." : "Free mode: one active spot at a time.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 8)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "car.fill")
                .font(.system(size: 44))
                .foregroundStyle(.blue)
            Text("No saved parking spot yet")
                .font(.title3.bold())
            Text("Tap the big Save Spot button after parking to capture your current location and start the timer.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func actionRow(for spot: ParkingSpot) -> some View {
        VStack(spacing: 12) {
            Button {
                spot.mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } label: {
                Label("Navigate to Spot", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }

            Button(role: .destructive) {
                store.delete(spot)
            } label: {
                Label("Clear Saved Spot", systemImage: "trash.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
        }
    }

    private var upgradeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Parkpal Pro", systemImage: "sparkles")
                .font(.title3.bold())
                .foregroundStyle(.green)
            Text("Unlock multiple saved spots and richer parking alerts with Apple’s native in-app purchases.")
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await purchaseManager.purchasePro()
                }
            } label: {
                Text(purchaseManager.unlockedProFeatures ? "Pro Unlocked" : "Unlock Pro")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(purchaseManager.unlockedProFeatures ? Color.green : Color.yellow)
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .disabled(purchaseManager.unlockedProFeatures)
        }
        .padding(20)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func saveCurrentSpot() {
        guard let location = locationManager.currentLocation else {
            locationManager.refreshLocation()
            return
        }

        Task {
            if let saved = await store.saveSpot(
                from: location,
                nickname: nickname.isEmpty ? "Bright Spot" : nickname,
                duration: selectedDuration,
                alertLeadTime: selectedAlertLeadTime,
                allowMultiple: purchaseManager.unlockedProFeatures
            ) {
                await NotificationManager.shared.scheduleReminder(for: saved)
            }
        }
    }

    private func durationLabel(for duration: TimeInterval) -> String {
        switch Int(duration) {
        case 1800: return "30m"
        case 3600: return "1h"
        case 7200: return "2h"
        case 14400: return "4h"
        default: return "Custom"
        }
    }

    private func reminderLabel(for duration: TimeInterval) -> String {
        switch Int(duration) {
        case 300: return "5m"
        case 900: return "15m"
        case 1800: return "30m"
        default: return "Alert"
        }
    }
}

#Preview {
    ParkingDashboardView()
        .environmentObject(ParkingSpotStore(context: PersistenceController.preview.container.viewContext))
        .environmentObject(PurchaseManager())
}
