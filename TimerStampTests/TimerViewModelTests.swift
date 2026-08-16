//
//  TimerViewModelTests.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/3/25.
//

import XCTest
@testable import TimerStamp

// MARK: - Mocks

final class MockLiveActivityService: TimerLiveActivityService {
    var startCallCount = 0
    var updateCallCount = 0
    var endCallCount = 0

    var lastUpdateIsPaused: Bool?
    var lastUpdateEndDate: Date??

    func start(startDate: Date, endDate: Date, totalDuration: TimeInterval) {
        startCallCount += 1
    }

    func update(endDate: Date?, isPaused: Bool, pausedRemainingTime: TimeInterval) {
        updateCallCount += 1
        lastUpdateIsPaused = isPaused
        lastUpdateEndDate = endDate
    }

    func end() {
        endCallCount += 1
    }
}

final class MockNotificationService: TimerNotificationService {
    var requestPermissionCallCount = 0
    var scheduleCallCount = 0
    var cancelCallCount = 0

    func requestPermission() {
        requestPermissionCallCount += 1
    }

    func schedule(endDate: Date, durationMinutes: Int) {
        scheduleCallCount += 1
    }

    func cancel() {
        cancelCallCount += 1
    }
}

// MARK: - Tests

final class TimerViewModelTests: XCTestCase {

    private var liveActivity: MockLiveActivityService!
    private var notification: MockNotificationService!
    private var vm: TimerViewModel!

    override func setUp() {
        super.setUp()
        liveActivity = MockLiveActivityService()
        notification = MockNotificationService()
        vm = TimerViewModel(durationMinutes: 1, liveActivity: liveActivity, notification: notification)
    }

    // MARK: - State Transition Tests

    func testStart_setsRunningStateAndEndDate() {
        vm.start()

        XCTAssertEqual(vm.state, .running)
        XCTAssertNotNil(vm.endDate)
        XCTAssertEqual(vm.endDate!.timeIntervalSinceNow, 60, accuracy: 1)
    }

    func testReset_returnsToIdleAndClearsEndDate() {
        vm.start()
        vm.reset()

        XCTAssertEqual(vm.state, .idle)
        XCTAssertNil(vm.endDate)
    }

    func testPause_setsPausedState() {
        vm.start()
        vm.pause()

        XCTAssertEqual(vm.state, .paused)
        XCTAssertNil(vm.endDate)
    }

    func testResume_setsRunningStateAfterPause() {
        vm.start()
        vm.pause()
        vm.resume()

        XCTAssertEqual(vm.state, .running)
        XCTAssertNotNil(vm.endDate)
    }

    // MARK: - Guard Condition Tests

    func testStart_whileRunning_isIgnored() {
        vm.start()
        vm.start()

        XCTAssertEqual(liveActivity.startCallCount, 1)
    }

    func testPause_whileIdle_isIgnored() {
        vm.pause()

        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(liveActivity.updateCallCount, 0)
    }

    func testResume_whileIdle_isIgnored() {
        vm.resume()

        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(liveActivity.updateCallCount, 0)
    }

    func testStart_afterEnded_startsRunning() {
        vm.endDate = Date().addingTimeInterval(-1)
        vm.restoreOnAppear()  // expired endDate → finish() → state = .ended
        XCTAssertEqual(vm.state, .ended)

        vm.start()

        XCTAssertEqual(vm.state, .running)
        XCTAssertEqual(liveActivity.startCallCount, 1)
    }

    // MARK: - Progress Tests

    func testProgress_isOneWhenDurationIsZero() {
        let vm = TimerViewModel(durationMinutes: 0, liveActivity: liveActivity, notification: notification)
        XCTAssertEqual(vm.progress, 1.0, accuracy: 0.01)
    }

    // MARK: - LiveActivity Service Tests

    func testStart_callsLiveActivityStart() {
        vm.start()

        XCTAssertEqual(liveActivity.startCallCount, 1)
    }

    func testReset_callsLiveActivityEnd() {
        vm.start()
        vm.reset()

        XCTAssertEqual(liveActivity.endCallCount, 1)
    }

    func testPause_callsLiveActivityUpdateWithPaused() {
        vm.start()
        vm.pause()

        XCTAssertEqual(liveActivity.updateCallCount, 1)
        XCTAssertEqual(liveActivity.lastUpdateIsPaused, true)
    }

    func testResume_callsLiveActivityUpdateWithResumed() {
        vm.start()
        vm.pause()
        let countAfterPause = liveActivity.updateCallCount

        vm.resume()

        XCTAssertEqual(liveActivity.updateCallCount, countAfterPause + 1)
        XCTAssertEqual(liveActivity.lastUpdateIsPaused, false)
    }

    // MARK: - Notification Service Tests

    func testInit_requestsNotificationPermission() {
        XCTAssertEqual(notification.requestPermissionCallCount, 1)
    }

    func testStart_schedulesNotification() {
        vm.start()

        XCTAssertEqual(notification.scheduleCallCount, 1)
    }

    func testReset_cancelsNotification() {
        vm.start()
        vm.reset()

        XCTAssertEqual(notification.cancelCallCount, 1)
    }

    func testPause_cancelsNotification() {
        vm.start()
        vm.pause()

        XCTAssertEqual(notification.cancelCallCount, 1)
    }

    func testResume_schedulesNotificationAgain() {
        vm.start()
        vm.pause()
        let countAfterStart = notification.scheduleCallCount

        vm.resume()

        XCTAssertEqual(notification.scheduleCallCount, countAfterStart + 1)
    }

    // MARK: - dialViewState Tests

    // dialAngle: idle → durationMinutes * 6°
    func testDialViewState_idle_angleMatchesDurationMinutes() {
        let vm = TimerViewModel(durationMinutes: 25, liveActivity: liveActivity, notification: notification)

        XCTAssertEqual(vm.dialViewState.dialAngle, 150.0, accuracy: 0.001)
    }

    // dialAngle: running → remainingTime / 10°
    func testDialViewState_running_angleMatchesRemainingTime() {
        vm.start()
        vm.remainingTime = 300  // 5분 남음

        XCTAssertEqual(vm.dialViewState.dialAngle, 30.0, accuracy: 0.001)
    }

    // dialAngle: paused → 멈춘 시점의 remainingTime / 10°
    // pause()가 내부에서 endDate 기준으로 remainingTime을 덮어쓰므로 pause() 이후에 설정
    func testDialViewState_paused_angleMatchesRemainingTime() {
        vm.start()
        vm.pause()
        vm.remainingTime = 30

        XCTAssertEqual(vm.dialViewState.dialAngle, 3.0, accuracy: 0.001)
    }

    // dialAngle: ended → 0°
    func testDialViewState_ended_angleIsZero() {
        vm.endDate = Date().addingTimeInterval(-1)
        vm.restoreOnAppear()
        XCTAssertEqual(vm.state, .ended)

        XCTAssertEqual(vm.dialViewState.dialAngle, 0.0, accuracy: 0.001)
    }

    // reset 후 idle 복귀 시 dialAngle이 이전 durationMinutes 기준으로 복원되는지
    func testDialViewState_idle_afterReset_angleRestoresToPreviousDuration() {
        vm.setDurationMinutes(10)   // 10분 설정
        vm.start()
        vm.reset()

        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(vm.dialViewState.dialAngle, 60.0, accuracy: 0.001)  // 10분 × 6° = 60°
    }

    // pause 후 reset 해도 durationMinutes가 유지되는지
    func testDialViewState_idle_afterResetFromPaused_angleRestoresToPreviousDuration() {
        vm.setDurationMinutes(10)
        vm.start()
        vm.pause()
        vm.reset()

        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(vm.dialViewState.dialAngle, 60.0, accuracy: 0.001)
    }

    // isInteractive: idle만 true
    func testDialViewState_isInteractive_trueOnlyInIdle() {
        XCTAssertTrue(vm.dialViewState.isInteractive, "idle")

        vm.start()
        XCTAssertFalse(vm.dialViewState.isInteractive, "running")

        vm.pause()
        XCTAssertFalse(vm.dialViewState.isInteractive, "paused")

        vm.endDate = Date().addingTimeInterval(-1)
        vm.restoreOnAppear()
        XCTAssertFalse(vm.dialViewState.isInteractive, "ended")
    }

    // progress: 시작 직후 ≈ 1.0
    func testDialViewState_progress_fullAtStart() {
        vm.start()

        XCTAssertEqual(vm.dialViewState.progress, 1.0, accuracy: 0.01)
    }

    // progress: remainingTime = 0이면 0.0
    func testDialViewState_progress_zeroWhenRemainingIsZero() {
        vm.start()
        vm.remainingTime = 0

        XCTAssertEqual(vm.dialViewState.progress, 0.0, accuracy: 0.001)
    }

    // progress: 절반 남았을 때 ≈ 0.5
    func testDialViewState_progress_halfWhenHalfRemaining() {
        vm.start()
        vm.remainingTime = 30  // durationMinutes=1 → total=60초, 절반=30초

        XCTAssertEqual(vm.dialViewState.progress, 0.5, accuracy: 0.01)
    }

    // MARK: - setDurationMinutes Tests

    // idle 상태에서 분 변경 → 반영됨
    func testSetDurationMinutes_inIdle_updatesValue() {
        vm.setDurationMinutes(10)

        XCTAssertEqual(vm.durationMinutes, 10)
    }

    // idle 상태에서 분 변경 → remainingTime도 같이 갱신됨
    func testSetDurationMinutes_inIdle_updatesRemainingTime() {
        vm.setDurationMinutes(10)

        XCTAssertEqual(vm.remainingTime, 600, accuracy: 0.001)
    }

    // running 중에는 무시됨
    func testSetDurationMinutes_inRunning_isIgnored() {
        vm.start()
        vm.setDurationMinutes(10)

        XCTAssertEqual(vm.durationMinutes, 1)  // setUp에서 1분으로 초기화
    }

    // paused 상태에서는 무시됨
    func testSetDurationMinutes_inPaused_isIgnored() {
        vm.start()
        vm.pause()
        vm.setDurationMinutes(10)

        XCTAssertEqual(vm.durationMinutes, 1)
    }

    // ended 상태에서는 무시됨
    func testSetDurationMinutes_inEnded_isIgnored() {
        vm.endDate = Date().addingTimeInterval(-1)
        vm.restoreOnAppear()
        vm.setDurationMinutes(10)

        XCTAssertEqual(vm.durationMinutes, 1)
    }

    // 같은 값 전달하면 아무것도 안 함
    func testSetDurationMinutes_sameValue_noChange() {
        let before = vm.remainingTime
        vm.setDurationMinutes(1)  // 이미 1분

        XCTAssertEqual(vm.remainingTime, before)
    }

    // MARK: - restoreOnAppear Tests

    func testRestoreOnAppear_whenIdleWithNoEndDate_cleansUpServices() {
        vm.restoreOnAppear()

        XCTAssertEqual(notification.cancelCallCount, 1)
        XCTAssertEqual(liveActivity.endCallCount, 1)
    }

    func testRestoreOnAppear_withFutureEndDate_resumesTimer() {
        vm.endDate = Date().addingTimeInterval(30)
        vm.restoreOnAppear()

        XCTAssertEqual(vm.state, .running)
    }

    func testRestoreOnAppear_withExpiredEndDate_finishesTimer() {
        vm.endDate = Date().addingTimeInterval(-1)
        vm.restoreOnAppear()

        XCTAssertEqual(vm.state, .ended)
        XCTAssertEqual(liveActivity.endCallCount, 1)
        XCTAssertEqual(notification.cancelCallCount, 1)
    }
}
