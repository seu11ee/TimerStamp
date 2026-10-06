//
//  MinuteDialTests.swift
//  TimerStamp
//
//  [이슈 #10] MinuteDial 각도 기반 분리 테스트.
//

import XCTest
@testable import TimerStamp

final class MinuteDialTests: XCTestCase {

    private let radius: CGFloat = 100

    private func makeDial(
        angle: Double = 0,
        snapStep: Double = 6.0,
        allowedRange: ClosedRange<Double> = 0...360
    ) -> MinuteDial {
        MinuteDial(
            angle: .constant(angle),
            snapStep: snapStep,
            allowedRange: allowedRange,
            radius: radius,
            isRunning: false
        )
    }

    // MARK: - pointToAngle
    // 중심: (radius, radius) = (100, 100)

    func test_pointToAngle_rightOfCenter_returns0() {
        let dial = makeDial()
        XCTAssertEqual(dial.pointToAngle(CGPoint(x: 200, y: 100)), 0.0, accuracy: 0.001)
    }

    func test_pointToAngle_belowCenter_returns90() {
        let dial = makeDial()
        XCTAssertEqual(dial.pointToAngle(CGPoint(x: 100, y: 200)), 90.0, accuracy: 0.001)
    }

    func test_pointToAngle_leftOfCenter_returns180() {
        let dial = makeDial()
        XCTAssertEqual(dial.pointToAngle(CGPoint(x: 0, y: 100)), 180.0, accuracy: 0.001)
    }

    func test_pointToAngle_aboveCenter_returns270() {
        let dial = makeDial()
        // 12시 방향: (100, 0) → vector (0, -100) → atan2(-100, 0) = -90° → 270°
        XCTAssertEqual(dial.pointToAngle(CGPoint(x: 100, y: 0)), 270.0, accuracy: 0.001)
    }

    func test_pointToAngle_result_alwaysNonNegative() {
        let dial = makeDial()
        for x in stride(from: 0, through: 200, by: 20) {
            for y in stride(from: 0, through: 200, by: 20) {
                let angle = dial.pointToAngle(CGPoint(x: x, y: y))
                XCTAssertGreaterThanOrEqual(angle, 0, "angle should be >= 0 for point (\(x), \(y))")
                XCTAssertLessThan(angle, 360, "angle should be < 360 for point (\(x), \(y))")
            }
        }
    }

    // MARK: - snapToStep (default 6°)

    func test_snapToStep_exactMultiple_unchanged() {
        let dial = makeDial()
        XCTAssertEqual(dial.snapToStep(150.0), 150.0, accuracy: 0.001)
        XCTAssertEqual(dial.snapToStep(6.0), 6.0, accuracy: 0.001)
    }

    func test_snapToStep_roundsDown() {
        let dial = makeDial()
        XCTAssertEqual(dial.snapToStep(151.0), 150.0, accuracy: 0.001)
        XCTAssertEqual(dial.snapToStep(155.9), 150.0, accuracy: 0.001)
    }

    func test_snapToStep_zero_returnsZero() {
        let dial = makeDial()
        XCTAssertEqual(dial.snapToStep(0.0), 0.0, accuracy: 0.001)
    }

    // MARK: - snapToStep (custom snapStep)

    func test_snapToStep_customStep_snapsCorrectly() {
        // snapStep = 10° — 타이머 외 다른 용도 (e.g. 10단위 다이얼)
        let dial = makeDial(snapStep: 10.0)
        XCTAssertEqual(dial.snapToStep(15.0), 10.0, accuracy: 0.001)
        XCTAssertEqual(dial.snapToStep(20.0), 20.0, accuracy: 0.001)
        XCTAssertEqual(dial.snapToStep(29.9), 20.0, accuracy: 0.001)
    }

    func test_snapToStep_1degree_snapsToEveryDegree() {
        let dial = makeDial(snapStep: 1.0)
        XCTAssertEqual(dial.snapToStep(5.7), 5.0, accuracy: 0.001)
        XCTAssertEqual(dial.snapToStep(5.0), 5.0, accuracy: 0.001)
    }

    // MARK: - clampAngle (DIAL-2)

    // 타이머 범위(6°~360°) — 하한 밖은 하한으로
    func test_DIAL2_2_clampAngle_belowRange_returnsLowerBound() {
        let dial = makeDial(allowedRange: 6...360)
        XCTAssertEqual(dial.clampAngle(0), 6, accuracy: 0.001)
        XCTAssertEqual(dial.clampAngle(-30), 6, accuracy: 0.001)
    }

    // 상한 밖은 상한으로
    func test_DIAL2_2_clampAngle_aboveRange_returnsUpperBound() {
        let dial = makeDial(allowedRange: 6...360)
        XCTAssertEqual(dial.clampAngle(400), 360, accuracy: 0.001)
    }

    // 범위 안 값은 그대로 (경계값 포함)
    func test_DIAL2_2_clampAngle_insideRange_unchanged() {
        let dial = makeDial(allowedRange: 6...360)
        XCTAssertEqual(dial.clampAngle(6), 6, accuracy: 0.001)
        XCTAssertEqual(dial.clampAngle(150.5), 150.5, accuracy: 0.001)
        XCTAssertEqual(dial.clampAngle(360), 360, accuracy: 0.001)
    }

    // 범위를 넘기지 않으면 기존처럼 한 바퀴(0°~360°) 전체 허용 — 재사용 컴포넌트 기본 동작 유지
    func test_clampAngle_defaultRange_allowsFullCircle() {
        let dial = makeDial()
        XCTAssertEqual(dial.clampAngle(0), 0, accuracy: 0.001)
        XCTAssertEqual(dial.clampAngle(-1), 0, accuracy: 0.001)
        XCTAssertEqual(dial.clampAngle(361), 360, accuracy: 0.001)
    }
}
