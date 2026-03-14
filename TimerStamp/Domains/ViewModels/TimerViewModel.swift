//
//  TimerViewModel.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/2/25.
//

import Foundation
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
    @Published var remainingTime: TimeInterval = 25 * 60
    @Published var endDate: Date?

    var progress: Double {
        let total = Double(durationMinutes * 60)
        return total > 0 ? Double(remainingTime) / total : 1.0
    }

    // MARK: - Private Properties
    private var timer: Timer?
    private let liveActivity: TimerLiveActivityService
    private let notification: TimerNotificationService

    // MARK: - Init
    init(
        durationMinutes: Int = 25,
        liveActivity: TimerLiveActivityService = DefaultLiveActivityService(),
        notification: TimerNotificationService = DefaultNotificationService()
    ) {
        self.durationMinutes = durationMinutes
        self.remainingTime = TimeInterval(durationMinutes * 60)
        self.liveActivity = liveActivity
        self.notification = notification
        notification.requestPermission()
    }

    // MARK: - Timer Control
    func start() {
        guard state == .idle || state == .ended else { return }

        self.endDate = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
        self.state = .running

        startTicking()
        notification.schedule(endDate: endDate!, durationMinutes: durationMinutes)
        liveActivity.start(startDate: Date(), endDate: endDate!, totalDuration: TimeInterval(remainingTime))
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        endDate = nil
        self.remainingTime = TimeInterval(durationMinutes * 60)
        state = .idle

        liveActivity.end()
        notification.cancel()
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

        notification.cancel()
        liveActivity.update(endDate: nil, isPaused: true, pausedRemainingTime: remainingTime)
    }

    func resume() {
        guard state == .paused else { return }

        self.endDate = Date().addingTimeInterval(TimeInterval(remainingTime))
        self.state = .running

        startTicking()
        notification.schedule(endDate: endDate!, durationMinutes: durationMinutes)
        liveActivity.update(endDate: endDate, isPaused: false, pausedRemainingTime: 0)
    }

    /// 뷰의 onAppear에서 호출. 백그라운드 복귀 또는 앱 재실행 시 타이머 상태를 복원하고
    /// 이미 종료된 경우 알림/LiveActivity를 정리합니다.
    func restoreOnAppear() {
        guard let end = endDate else {
            if state == .idle || state == .ended {
                notification.cancel()
                liveActivity.end()
            }
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

    // MARK: - Private
    private func startTicking() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let endDate = self.endDate else { return }

            let remaining = max(0, endDate.timeIntervalSinceNow)
            self.remainingTime = remaining

            if remaining <= 0 {
                self.finish()
            }
        }
    }

    private func finish() {
        timer?.invalidate()
        timer = nil
        state = .ended
        liveActivity.end()
        notification.cancel()
    }
}
