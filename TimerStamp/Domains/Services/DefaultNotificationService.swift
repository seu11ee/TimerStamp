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

        // 0 이하 간격은 UNTimeIntervalNotificationTrigger가 받지 않으므로 예약하지 않는다 (NTF-1.5)
        guard let interval = Self.triggerInterval(endDate: endDate) else { return }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.timerDone,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    /// 알림을 예약할 간격. 종료 시각이 지금이거나 이미 지났으면 nil.
    static func triggerInterval(endDate: Date, now: Date = Date()) -> TimeInterval? {
        let interval = endDate.timeIntervalSince(now)
        return interval > 0 ? interval : nil
    }

    func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.timerDone]
        )
    }
}
