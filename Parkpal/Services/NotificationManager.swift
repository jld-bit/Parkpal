import Foundation
import UserNotifications

struct NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleReminder(for spot: ParkingSpot) async {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Parking reminder"
        content.body = "\(spot.nickname) expires soon. Head back before your time runs out."
        content.sound = .default

        let secondsUntilAlert = spot.expirationDate.timeIntervalSinceNow - spot.alertLeadTime
        guard secondsUntilAlert > 1 else { return }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsUntilAlert, repeats: false)
        let request = UNNotificationRequest(identifier: spot.id.uuidString, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func removeReminder(for spotID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [spotID.uuidString])
    }
}
