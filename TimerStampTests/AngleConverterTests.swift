//
//  AngleConverterTests.swift
//  TimerStamp
//
//  [이슈 #7] MinuteDial 각도 변환 공식 불일치 해결을 위한 테스트.
//  AngleConverter 타입이 존재하지 않으면 컴파일 실패 (TDD red 상태).
//

import XCTest
@testable import TimerStamp

final class AngleConverterTests: XCTestCase {

    // MARK: - minutesToDegrees

    func test_minutesToDegrees_1minute_returns6() {
        XCTAssertEqual(AngleConverter.minutesToDegrees(1), 6.0)
    }

    func test_minutesToDegrees_25minutes_returns150() {
        XCTAssertEqual(AngleConverter.minutesToDegrees(25), 150.0)
    }

    func test_minutesToDegrees_60minutes_returns360() {
        XCTAssertEqual(AngleConverter.minutesToDegrees(60), 360.0)
    }

    func test_minutesToDegrees_0minutes_returns0() {
        XCTAssertEqual(AngleConverter.minutesToDegrees(0), 0.0)
    }

    // MARK: - secondsToDegrees

    func test_secondsToDegrees_60seconds_returns6() {
        XCTAssertEqual(AngleConverter.secondsToDegrees(60), 6.0)
    }

    func test_secondsToDegrees_1500seconds_returns150() {
        XCTAssertEqual(AngleConverter.secondsToDegrees(1500), 150.0)
    }

    func test_secondsToDegrees_0seconds_returns0() {
        XCTAssertEqual(AngleConverter.secondsToDegrees(0), 0.0)
    }

    // MARK: - 일관성 검증 (두 함수가 동일한 결과를 반환해야 함)

    func test_consistency_minutesAndSeconds_produceSameDegrees() {
        for minutes in 1...59 {
            let fromMinutes = AngleConverter.minutesToDegrees(minutes)
            let fromSeconds = AngleConverter.secondsToDegrees(TimeInterval(minutes * 60))
            XCTAssertEqual(fromMinutes, fromSeconds, accuracy: 0.001,
                           "minutes=\(minutes): minutesToDegrees(\(fromMinutes)) != secondsToDegrees(\(fromSeconds))")
        }
    }
}
