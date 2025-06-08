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
    private var startDate: Date?
    
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
    func start(durationMinutes: Int) {
        guard state == .idle || state == .ended else { return }
        
        self.durationMinutes = durationMinutes
        self.remainingSeconds = durationMinutes * 60
        self.startDate = Date()
        self.endDate = startDate?.addingTimeInterval(TimeInterval(remainingSeconds))
        self.state = .running
        
        startTicking()
        scheduleNotification()
        
        LiveActivityManager.start(startDate: startDate!, endDate: endDate!, totalDuration: TimeInterval(remainingSeconds))
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        remainingSeconds = durationMinutes * 60
        state = .idle
        print("durationMinutes", durationMinutes)
        
        LiveActivityManager.end()
        cancelNotification()
    }
    
    func pause() {
        guard state == .running else { return }
        timer?.invalidate()
        timer = nil
        
        if let endDate = endDate {
            remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow))
        }
        
        self.state = .paused
        
        let newEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        LiveActivityManager.update(endDate: newEndDate, isPaused: true)
    }
    func resume() {
        guard state == .paused else { return }
        
        self.endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        self.state = .running
        
        startTicking()
        scheduleNotification()
        
        LiveActivityManager.update(endDate: endDate!, isPaused: false)
    }
    private func startTicking() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let endDate = self.endDate else { return }
            
            let remaining = max(0, Int(endDate.timeIntervalSinceNow))
            self.remainingSeconds = remaining
            
            if remaining <= 0 {
                self.timer?.invalidate()
                self.state = .ended
                LiveActivityManager.end()
                self.cancelNotification()
            }
        }
    }
    
    private func updateRemainingTime() {
        guard let end = endDate else { return }
        
        let seconds = max(Int(end.timeIntervalSinceNow), 0)
        remainingSeconds = seconds
        //LiveActivityManager.update(remainingSeconds: seconds)
        if seconds == 0 {
            finish()
        }
    }
    
    private func finish() {
        timer?.invalidate()
        timer = nil
        state = .ended
        LiveActivityManager.end()
        cancelNotification()
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
    
    func resetStatus() {
        if state == .idle || state == .ended {
            cancelNotification()
            LiveActivityManager.end()
        }
    }
    // MARK: - Notifications
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }
    
    private func scheduleNotification() {
        guard let end = endDate else { return }
        
        cancelNotification() // 기존 알림 제거 후 등록
        
        let content = UNMutableNotificationContent()
        content.title = "타이머 완료 🎉"
        content.body = "\(durationMinutes)분 집중이 끝났어요!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: end.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationIdentifier.timerDone, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.timerDone])
    }
}
