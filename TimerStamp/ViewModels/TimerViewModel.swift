//
//  TimerViewModel.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/2/25.
//

import Foundation
import UserNotifications
import Combine

final class TimerViewModel: ObservableObject {
    // MARK: - Public Properties
    @Published var state: TimerState = .idle
    @Published var durationMinutes: Int = 25 {
        didSet {
            if state != .running {
                reset()
            }
        }
    }
    @Published var remainingSeconds: Int = 25 * 60
    var progress: Double {
        let total = Double(durationMinutes * 60)
        return total > 0 ? Double(remainingSeconds) / total : 1.0
    }
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var endDate: Date?

    // MARK: - Init
    init() {
        requestNotificationPermission()
    }
    init(durationMinutes: Int = 25) {
        self.durationMinutes = durationMinutes
        self.remainingSeconds = durationMinutes * 60
        requestNotificationPermission()
    }
 
    // MARK: - Timer Control
    func start() {
        guard state != .running && state != .ended else { return }

        state = .running
        remainingSeconds = durationMinutes * 60
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))

        startTicking()
        scheduleNotification()
        LiveActivityManager.start(durationMinutes: durationMinutes)
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        LiveActivityManager.end()
        remainingSeconds = durationMinutes * 60
        endDate = nil
        state = .idle
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.timerDone])
    }

    private func startTicking() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateRemainingTime()
        }
    }

    private func updateRemainingTime() {
        guard let end = endDate else { return }

        let seconds = max(Int(end.timeIntervalSinceNow), 0)
        remainingSeconds = seconds
        LiveActivityManager.update(remainingSeconds: seconds)
        if seconds == 0 {
            finish()
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        state = .ended
        LiveActivityManager.end()
    }

    // MARK: - App State Handling
    func restoreTimerIfNeeded() {
        guard let end = endDate else {
            remainingSeconds = durationMinutes * 60
            return
        }

        let seconds = max(Int(end.timeIntervalSinceNow), 0)
        remainingSeconds = seconds

        if seconds > 0 {
            state = .running
            startTicking()
        } else {
            finish()
        }
    }

    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func scheduleNotification() {
        guard let end = endDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "타이머 완료 🎉"
        content.body = "\(durationMinutes)분 집중이 끝났어요!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: end.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationIdentifier.timerDone, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
