# TimerStamp 기능 명세서

> 테스트 코드 작성을 위한 기능 명세. 실제 구현 기준으로 작성됨.

---

## 1. TimerViewModel

### 1-1. 상태 (TimerState)

| 상태 | 설명 |
|------|------|
| `idle` | 초기 상태. 타이머 시작 전, 시간 설정 가능 |
| `running` | 타이머 작동 중 |
| `paused` | 일시정지 상태. 남은 시간 보존 |
| `ended` | 타이머 완료. 인증사진 버튼 노출 |

### 1-2. 초기값

- `durationMinutes`: 25
- `remainingTime`: 25 * 60 = 1500초
- `state`: `.idle`
- `endDate`: nil

### 1-3. start()

**조건:** state가 `.idle` 또는 `.ended`일 때만 실행

**동작:**
- `endDate` = 현재시각 + durationMinutes * 60초
- `state` → `.running`
- 1초 간격 타이머 시작 (remainingTime 감소)
- 종료 예정 시각에 로컬 알림 예약
- LiveActivity 시작

**엣지 케이스:**
- `state == .running` 또는 `.paused`일 때 start() 호출 → 무시

### 1-4. pause()

**조건:** state가 `.running`일 때만 실행

**동작:**
- 내부 타이머 정지
- `remainingTime` = `endDate.timeIntervalSinceNow` (현재 남은 시간 캡처)
- `endDate` → nil
- `state` → `.paused`
- 로컬 알림 취소 (종료 시각이 무효화되므로)
- LiveActivity 일시정지 상태로 업데이트 (`isPaused: true`, `pausedRemainingTime` 전달)

### 1-5. resume()

**조건:** state가 `.paused`일 때만 실행

**동작:**
- `endDate` = 현재시각 + remainingTime
- `state` → `.running`
- 1초 간격 타이머 재시작
- 로컬 알림 재예약
- LiveActivity 재개 상태로 업데이트 (`isPaused: false`)

### 1-6. reset()

**조건:** 모든 상태에서 호출 가능

**동작:**
- 내부 타이머 정지, nil 처리
- `endDate` → nil
- `remainingTime` = durationMinutes * 60
- `state` → `.idle`
- LiveActivity 종료
- 로컬 알림 취소

### 1-7. 타이머 자동 완료 (내부 동작)

`remainingTime`이 0에 도달하면:
- 내부 타이머 정지, nil 처리
- `state` → `.ended`
- LiveActivity 종료
- 로컬 알림 취소
- (Pomodoro 모드일 경우) 다음 페이즈 자동 진행

### 1-8. progress (계산 프로퍼티)

```
progress = remainingTime / (durationMinutes * 60)
```

- 범위: 0.0 ~ 1.0
- idle 상태(remainingTime == total): 1.0
- 완료 상태(remainingTime == 0): 0.0
- total이 0이면 1.0 반환 (나누기 0 방지)

### 1-9. durationMinutes 변경

- `state != .running`일 때 변경 시 → `reset()` 자동 호출 (remainingTime 갱신)
- `state == .running`일 때 변경 → reset() 호출 안 함 (타이머 진행 유지)

### 1-10. restoreOnAppear()

뷰의 `onAppear`에서 호출. 앱 재실행 또는 백그라운드 복귀 시 상태 복원.

**분기:**
- `endDate == nil` + state가 `.idle` 또는 `.ended`
  → 알림 취소, LiveActivity 종료, remainingTime 초기화
- `endDate != nil` + 남은 시간 > 0
  → state → `.running`, 타이머 재개
- `endDate != nil` + 남은 시간 <= 0
  → `finish()` 호출 (종료 처리)

---

## 2. Pomodoro 모드

### 2-1. 페이즈 (PomodoroPhase)

| 페이즈 | 기본 시간 |
|--------|-----------|
| `focus` | 25분 |
| `shortBreak` | 5분 |
| `longBreak` | 15분 |

### 2-2. 라운드 진행 규칙

- `focus` 완료 → `pomodoroRound += 1`
  - round < maxRounds(4): `shortBreak`으로 전환
  - round >= maxRounds: `longBreak`으로 전환
- `shortBreak` 완료 → `focus`로 전환
- `longBreak` 완료 → `focus`로 전환, `pomodoroRound = 0` (초기화)

### 2-3. 페이즈 전환 동작

- `durationMinutes`가 해당 페이즈 시간으로 변경됨
- `reset()` → `start()` 자동 호출

---

## 3. LiveActivityManager

### 3-1. start(startDate:endDate:totalDuration:)

- 기기에서 LiveActivity가 비활성화된 경우 → 무시
- `TimerAttributes` + `ContentState(endDate:)` 로 Activity 생성

### 3-2. update(endDate:isPaused:pausedRemainingTime:)

| 상황 | endDate | isPaused | pausedRemainingTime |
|------|---------|----------|----------------------|
| 실행 중 | 종료 예정 시각 | false | 0 |
| 일시정지 | nil | true | 현재 남은 초 |
| 재개 | 새 종료 예정 시각 | false | 0 |

### 3-3. end()

- 모든 활성 Activity를 즉시(`.immediate`) 종료

---

## 4. TimerAttributes.ContentState

### 4-1. remainingTime (계산 프로퍼티)

```
endDate가 있으면: max(0, endDate.timeIntervalSinceNow)
endDate가 없으면: pausedRemainingTime
```

**중요:** `remainingTime == 0`일 때 LiveActivity 뷰는 정적 "00:00"을 표시해야 함.
(0을 기준으로 `.timer` 스타일을 사용하면 경과 시간으로 카운트업됨 — 버그)

---

## 5. 드래그 다이얼 (MinuteDial)

### 5-1. 각도-분 변환

```
1분 = 6도
분 = 각도 / 6
```

- 설정 가능 범위: 1 ~ 59분
- 0분(360도) 및 음수 각도 설정 불가
- `state == .running`일 때 드래그 제스처 비활성화

### 5-2. 드래그 동작

- 드래그 중: `durationMinutes` 실시간 업데이트
- 드래그 중: 분 경계 통과 시 햅틱 피드백 (`.soft`)
- 드래그 종료: 각도를 6도 단위로 snap
- 타이머 실행 중: 제스처 nil → 입력 무시

### 5-3. remainingTime 연동

- 타이머 진행 중 `remainingTime` 변경 시 다이얼 각도 자동 갱신
  ```
  rotation = remainingTime / 10.0
  ```
- 드래그 중에는 갱신 무시 (`isDragging == true`)

---

## 6. PieSlice (원형 진행 표시)

### 6-1. 각도 계산

```
totalDegrees = minutes * 6
startAngle = -90도 + totalDegrees * progress
endAngle = -90도 (12시 방향)
```

- `progress = 1.0`: 전체 부채꼴 표시
- `progress = 0.0`: 부채꼴 없음 (endAngle == startAngle)
- 시계 방향으로 채워짐

### 6-2. 애니메이션

- `animatableData = progress` → progress 변화 시 부드러운 애니메이션

---

## 7. 알림 (UNUserNotificationCenter)

### 7-1. 권한 요청

- 앱 최초 실행 시 `requestAuthorization(options: [.alert, .sound])` 호출

### 7-2. 예약

- 식별자: `"timerDone"`
- 트리거: `endDate.timeIntervalSinceNow` 후 1회 발송
- 내용: 제목(완료 메시지) + 본문(설정 분 포함) + 기본 알림음

### 7-3. 취소

- `reset()`, `pause()`, 타이머 자동 완료 시 `"timerDone"` 식별자로 pending 알림 제거

---

## 8. UI 상태별 표시

| 상태 | 안내 텍스트 | 타이머 레이블 | 인증사진 버튼 | 플레이 버튼 |
|------|-------------|--------------|--------------|------------|
| idle | "돌려서 시간을 설정하세요" (표시) | 표시 | 숨김 | play.fill (활성) |
| running | 투명 처리 | 표시 | 숨김 | pause.fill (활성) |
| paused | 투명 처리 | 표시 | 숨김 | play.fill (활성) |
| ended | "집중 완료" 메시지 | 숨김 | 표시 | play.fill (비활성) |

---

## 9. 화면 잠금 방지

- `TimerScreen` 등장 시: `UIApplication.shared.isIdleTimerDisabled = true`
- `TimerScreen` 사라질 시: `UIApplication.shared.isIdleTimerDisabled = false`
- 첫 실행 시에는 온보딩 표시 (잠금 방지 미적용)
