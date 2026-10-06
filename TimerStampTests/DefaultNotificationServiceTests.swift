//
//  DefaultNotificationServiceTests.swift
//  TimerStamp
//
//  알림 예약 시간 판단(NTF-1.5). 실제 UNUserNotificationCenter는 건드리지 않는다.
//

import XCTest
@testable import TimerStamp

final class DefaultNotificationServiceTests: XCTestCase {

    private let now = Date(timeIntervalSince1970: 1_000_000)

    // 종료 시각이 미래면 남은 시간을 그대로 반환
    func test_NTF1_5_triggerInterval_futureEndDate_returnsInterval() {
        let interval = DefaultNotificationService.triggerInterval(endDate: now.addingTimeInterval(60), now: now)
        XCTAssertEqual(interval ?? -1, 60, accuracy: 0.001)
    }

    // 종료 시각이 지금이면(0분 타이머) 예약하지 않음
    func test_NTF1_5_triggerInterval_endDateIsNow_returnsNil() {
        XCTAssertNil(DefaultNotificationService.triggerInterval(endDate: now, now: now))
    }

    // 종료 시각이 이미 지났으면 예약하지 않음
    func test_NTF1_5_triggerInterval_pastEndDate_returnsNil() {
        XCTAssertNil(DefaultNotificationService.triggerInterval(endDate: now.addingTimeInterval(-5), now: now))
    }
}
