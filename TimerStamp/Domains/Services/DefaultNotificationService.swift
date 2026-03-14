//
//  DefaultNotificationService.swift
//  TimerStamp
//

import UserNotifications

final class DefaultNotificationService: TimerNotificationService {
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func schedule(endDate: Date, durationMinutes: Int) {
        cancel()

        let content = UNMutableNotificationContent()
        content.title = "\(L10n.notificationTitleTimerDone) 🎉"
        content.body = "\(L10n.notificationBodyTimerDone(durationMinutes))"
        content.sound = .defaultRingtone

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: endDate.timeIntervalSinceNow,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.timerDone,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.timerDone]
        )
    }
}
