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
    enum TimerMode {
        case normal
        case pomodoro
    }
    
    enum PomodoroPhase {
        case focus
        case shortBreak
        case longBreak
    }
    
    // MARK: - Public Properties
    @Published var state: TimerState = .idle
    @Published var durationMinutes: Int = 25 {
        didSet {
            if state != .running {
                reset()
            }
        }
    }
    @Published var remainingTime: TimeInterval = 25 * 60
    @Published var endDate: Date?
    var progress: Double {
        let total = Double(durationMinutes * 60)
        return total > 0 ? Double(remainingTime) / total : 1.0
    }
    
    @Published var mode: TimerMode = .normal
    @Published var pomodoroPhase: PomodoroPhase = .focus
    @Published var pomodoroRound: Int = 0
    
    var focusMinutes: Int = 25
    var breakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var maxRounds: Int = 4
    
    // MARK: - Private Properties
    private var timer: Timer?
    
    // MARK: - Init
    init(mode: TimerMode = .normal, durationMinutes: Int = 25) {
        self.mode = mode
        self.durationMinutes = durationMinutes
        self.remainingTime = TimeInterval(durationMinutes * 60)
        requestNotificationPermission()
    }
    
    // MARK: - Timer Control
    func start() {
        guard state == .idle || state == .ended else { return }

        self.endDate = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.state = .running
        
        startTicking()
        scheduleNotification()
        
        LiveActivityManager.start(startDate: Date(), endDate: endDate!, totalDuration: TimeInterval(remainingTime))
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        self.remainingTime = TimeInterval(durationMinutes * 60)
        state = .idle
        
        LiveActivityManager.end()
        cancelNotification()
    }
    
    func pause() {
        guard state == .running else { return }
        timer?.invalidate()
        timer = nil
        
        if let endDate = endDate {
            remainingTime = max(0, endDate.timeIntervalSinceNow)
        }
        endDate = nil
        
        self.state = .paused
        
        scheduleNotification()
        
        LiveActivityManager.update(endDate: endDate, isPaused: true, pausedRemainingTime: remainingTime)
    }
    func resume() {
        guard state == .paused else { return }
        
        self.endDate = Date().addingTimeInterval(TimeInterval(remainingTime))
        self.state = .running
        
        startTicking()
        scheduleNotification()
        
        LiveActivityManager.update(endDate: endDate, isPaused: false)
    }
    private func startTicking() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let endDate = self.endDate else { return }
            
            let remaining = max(0, endDate.timeIntervalSinceNow)
            self.remainingTime = remaining
            
            if remaining <= 0 {
                self.timer?.invalidate()
                self.state = .ended
                LiveActivityManager.end()
                self.cancelNotification()
                if self.mode == .pomodoro {
                    self.advanceToNextPomodoroPhase()
                }
            }
        }
    }
    
    private func updateRemainingTime() {
        guard let end = endDate else { return }
        
        remainingTime = max(end.timeIntervalSinceNow, 0)
        if remainingTime == 0 {
            finish()
        }
    }
    
    private func finish() {
        timer?.invalidate()
        timer = nil
        state = .ended
        LiveActivityManager.end()
        cancelNotification()
        if mode == .pomodoro {
            advanceToNextPomodoroPhase()
        }
    }
    
    private func advanceToNextPomodoroPhase() {
        switch pomodoroPhase {
        case .focus:
            pomodoroRound += 1
            if pomodoroRound < maxRounds {
                pomodoroPhase = .shortBreak
                durationMinutes = breakMinutes
            } else {
                pomodoroPhase = .longBreak
                durationMinutes = longBreakMinutes
            }
        case .shortBreak:
            pomodoroPhase = .focus
            durationMinutes = focusMinutes
        case .longBreak:
            pomodoroPhase = .focus
            pomodoroRound = 0
            durationMinutes = focusMinutes
        }
        reset()
        start()
    }
    
    // MARK: - App State Handling
    func restoreTimerIfNeeded() {
        guard let end = endDate else {
            remainingTime = TimeInterval(durationMinutes * 60)
            return
        }
        
        let seconds = max(end.timeIntervalSinceNow, 0)
        remainingTime = seconds
        
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
        cancelNotification()
        guard let end = endDate else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "\(L10n.notificationTitleTimerDone) 🎉"
        content.body = "\(L10n.notificationBodyTimerDone(durationMinutes))"
        content.sound = .defaultRingtone
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: end.timeIntervalSinceNow, repeats: false)
        let request = UNNotificationRequest(identifier: NotificationIdentifier.timerDone, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.timerDone])
    }
}
