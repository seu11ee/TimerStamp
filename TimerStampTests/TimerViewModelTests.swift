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
