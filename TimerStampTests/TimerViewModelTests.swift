//
//  TimerViewModelTests.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/3/25.
//

import XCTest
@testable import TimerStamp

final class TimerViewModelTests: XCTestCase {

    func testStart_setsRunningStateAndRemainingTime() {
        let vm = TimerViewModel()
        vm.durationMinutes = 1
        vm.start()

        XCTAssertEqual(vm.state, .running)
        XCTAssertEqual(vm.remainingTime, 60, accuracy: 1)
    }

    func testReset_returnsToIdleAndResetsRemainingTime() {
        let vm = TimerViewModel()
        vm.durationMinutes = 1
        vm.start()
        vm.reset()

        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(vm.remainingTime, 60, accuracy: 1)
    }

    func testPause_setsPausedState() {
        let vm = TimerViewModel()
        vm.durationMinutes = 1
        vm.start()
        vm.pause()

        XCTAssertEqual(vm.state, .paused)
        XCTAssertNil(vm.endDate)
    }

    func testResume_setsRunningStateAfterPause() {
        let vm = TimerViewModel()
        vm.durationMinutes = 1
        vm.start()
        vm.pause()
        vm.resume()

        XCTAssertEqual(vm.state, .running)
        XCTAssertNotNil(vm.endDate)
    }

    func testProgress_returnsOneWhenIdle() {
        let vm = TimerViewModel(durationMinutes: 25)

        XCTAssertEqual(vm.progress, 1.0, accuracy: 0.01)
    }
}
