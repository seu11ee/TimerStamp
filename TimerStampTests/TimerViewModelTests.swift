//
//  TimerViewModelTests.swift
//  TimerStamp
//
//  Created by 이예슬 on 5/3/25.
//

import XCTest
@testable import TimerStamp

final class TimerViewModelTests: XCTestCase {

    func testStart_setsIsRunningAndRemainingSeconds() {
        let vm = TimerViewModel()
        vm.durationMinutes = 1
        vm.start()
        
        XCTAssertTrue(vm.isRunning)
        XCTAssertEqual(vm.remainingTime, 60)
    }

    func testReset_stopsTimerAndResetsState() {
        let vm = TimerViewModel()
        vm.durationMinutes = 1
        vm.start()
        vm.reset()
        
        XCTAssertFalse(vm.isRunning)
        XCTAssertFalse(vm.isFinished)
        XCTAssertEqual(vm.remainingTime, 60)
    }
}
