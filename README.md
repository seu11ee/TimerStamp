# TimerStamp ⏰

> 집중 타이머와 인증 사진 공유 기능을 제공하는 SwiftUI 기반 생산성 앱

<img width="200" alt="screenshot-light" src="https://github.com/user-attachments/assets/4135783b-593b-4ca8-b7fb-dc070b14622e" />

<img width="200" alt="screenshot-dark" src="https://github.com/user-attachments/assets/abdce1bc-0b33-4bfe-98f1-1e379e1183d8" />

<img width="200" alt="screenshot-cert" src="https://github.com/user-attachments/assets/95b3911f-f5c8-454a-90dc-ea4dce737831" />

## 학습 목표

- **SwiftUI 심화**: Custom Shape, View, Animation을 활용한 복합 UI 구현
- **Modern Swift**: async/await, @Observable 매크로 활용
- **Interactive UI**: 드래그 제스처와 햅틱 피드백을 결합한 직관적 UX
- **Live Activity**: iOS 16+ Dynamic Island 및 Lock Screen 위젯
- **다국어 지원**: 20개 언어 현지화 (Localization)
- **테스트 주도 개발**: Unit Test, UI Test 작성

## 주요 기능

- **커스텀 타이머**: 드래그 제스처로 시간 설정, 햅틱 피드백 제공
- **집중 인증**: 타이머 완료 후 인증 사진 촬영 및 공유
- **Live Activity**: Dynamic Island와 Lock Screen에서 실시간 타이머 확인
- **다크모드**: 자동/수동 테마 전환 지원

## 아키텍처

```
TimerStamp/
├── Presentations/       # MVVM 기반 UI Layer
│   ├── Timer/          # 타이머 관련 View & Component
│   ├── Certification/  # 인증 기능 View & ViewModel
│   └── Screens/        # 메인 스크린들
├── Services/           # 비즈니스 로직 Layer
│   ├── Certification/  # 이미지 렌더링, 저장 서비스
│   └── Protocols.swift # 서비스 인터페이스 정의
├── Domains/           # Domain Layer
│   └── ViewModels/    # 상태 관리 (Observable)
├── LiveActivity/      # iOS 16+ Live Activity
└── Tests/            # Unit Tests & UI Tests
```

## 기술 스택

- **UI Framework**: SwiftUI, Custom Shapes & Views
- **State Management**: @Observable macro, MVVM pattern
- **Concurrency**: async/await, Task Group
- **iOS Features**: Live Activity, Dynamic Island, Core Haptics
- **Testing**: XCTest, UI Testing, Mock Objects
- **Localization**: 20개 언어 지원 (SwiftGen 활용)
- **Build Tools**: Xcode Schemes, SwiftGen, Custom Scripts

## 핵심 구현 포인트

### 1. Interactive Timer UI
- `PieSlice`, `RadiusStick` 등 Custom Shape 구현
- 드래그 제스처와 햅틱 피드백 동기화
- 실시간 애니메이션과 상태 업데이트

### 2. Certification System
- `CertificationImageRenderer`: SwiftUI View를 이미지로 변환
- `CertificationService`: 사진 촬영, 편집, 저장 통합 관리
- Template 기반 인증서 생성

### 3. Live Activity Integration
- `TimerAttributes`: ActivityKit 연동
- Dynamic Island에서 타이머 진행상황 실시간 표시
- Lock Screen 위젯 지원

### 4. Test Coverage
- `CertificationTests`: 인증 기능 Unit Test (90%+ 커버리지)
- `TimerViewModelTests`: 타이머 로직 테스트
- Mock 객체를 활용한 의존성 분리

## 설계 판단 근거

### 왜 SwiftUI + ObservableObject를 선택했는가
- Custom Shape(`PieSlice`, `RadiusStick`), 드래그 제스처, 애니메이션을 UIKit 없이 SwiftUI만으로 구현해 레이어 단순화
- `ObservableObject` + `@Published`로 ViewModel 상태 변화를 View에 자동 반영 — 별도 바인딩 코드 없음
- `ImageRenderer`, `ActivityKit` 등 최신 Apple 프레임워크가 SwiftUI 기반으로 설계되어 통합이 자연스러움

### 왜 MVVM 구조로 설계했는가
- 타이머 상태(idle / running / paused / ended) 전이를 `TimerViewModel` 한 곳에서만 제어 → View가 직접 상태를 바꾸는 패턴을 CLAUDE.md 금지 규칙으로 명문화
- `TimerLiveActivityService`, `TimerNotificationService`를 생성자 주입으로 교체 가능하게 설계 → Mock 주입으로 40개 테스트 가능
- 상태 복원(`restoreOnAppear`)·일시정지·재개 같은 복잡한 흐름이 ViewModel 안에 캡슐화되어 View 코드가 단순하게 유지됨

### 서비스 레이어 분리 기준
- **외부 프레임워크 경계** = 분리 기준: `ActivityKit`, `UserNotifications`, `UIImageWriteToSavedPhotosAlbum` 호출은 각각 서비스로 격리
- 분리하면 Mock으로 교체 가능 → 테스트 가능성이 분리의 실질적 동기
- `Presentations → Domains → LiveActivity` 단방향 의존성을 지키기 위해 View가 `LiveActivity`를 직접 참조하는 것을 구조적으로 차단

## AI 활용 워크플로우

이 프로젝트는 **Claude Code CLI**를 활용해 리팩토링, 테스트, 배포를 진행했습니다.

- **도구**: Claude Code CLI (claude-sonnet-4-6), Fastlane, GitHub Actions
- **워크플로우**:
  1. Human이 이슈 정의 → AI가 TDD 기반으로 테스트 먼저 작성 후 구현
  2. AI가 PR 초안 생성 → Human이 코드 리뷰 후 머지 여부 결정
  3. Human이 `/deploy` 명령 트리거 → AI가 Fastlane 빌드·서명·TestFlight 업로드 실행
- **Human이 직접 판단한 것**: 아키텍처 방향, 리팩토링 범위 결정, PR 최종 승인, 배포 타이밍
- **AI가 실행한 것**: 코드 구현, 테스트 작성, PR 초안, 커밋 메시지, Fastlane 파이프라인 실행
- **효과**: 반복 작업(테스트 작성, PR 초안, 배포 자동화) 시간 단축 / 코드 리뷰를 AI와 사전 검토 후 머지해 버그 유입 감소
- **한계**: LiveActivity 실기기 동작 확인, UI 골든패스 검증은 Human 필수 / AI가 작성한 코드도 Human 리뷰 없이 머지하지 않음

## 트러블슈팅

| 문제 | 원인 | 해결 |
|------|------|------|
| LiveActivity 종료 후 시간이 카운트업 | `Text(.., style: .timer)`가 앵커 날짜를 지나면 자동으로 카운트업으로 전환 | `Text(timerInterval: Date()...endDate, countsDown: true)`로 교체 + `end()` 시 `endDate: nil` 명시 |
| MinuteDial 드래그 중 0/360° 경계에서 점프 | 단순 각도 차 계산 시 359° → 1° 이동을 -358° 역방향으로 해석 | `shortestDelta()`: delta를 [-180, 180] 범위로 클램핑해 최단 경로만 허용 |
| 분 기반·초 기반 각도 변환 결과 불일치 | 각도 계산 공식이 파일마다 다르게 정의됨 | `AngleConverter` 유틸 추출 후 TDD로 59가지 시나리오 일관성 검증 |

## 한계 및 개선 방향

- **HistoryView 미구현**: 완료 세션 히스토리(날짜별 그리드, 인증사진 썸네일)는 설계만 완료, 구현 예정
- **LiveActivity 책임 분산**: `Domains/Services/TimerLiveActivityService`와 `LiveActivity/DefaultLiveActivityService`에 책임이 나뉘어 있어 단일 책임으로 정리 필요
- **UI 테스트 없음**: UI 골든패스(타이머 시작→종료→인증사진 흐름)는 수동 검증에 의존
- **Eval 루프 구축 중**: AI가 작성한 코드를 정량적으로 평가하는 파이프라인(테스트 커버리지 추적, PR별 리뷰 이슈 수 기록) 추가 예정

