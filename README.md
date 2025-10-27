# TimerStamp ⏰

> 집중 타이머와 인증 사진 공유 기능을 제공하는 SwiftUI 기반 생산성 앱

<img width="200" alt="screenshot-light" src="https://github.com/user-attachments/assets/4135783b-593b-4ca8-b7fb-dc070b14622e" />

<img width="200" alt="screenshot-dark" src="https://github.com/user-attachments/assets/abdce1bc-0b33-4bfe-98f1-1e379e1183d8" />

<img width="200" alt="screenshot-cert" src="https://github.com/user-attachments/assets/95b3911f-f5c8-454a-90dc-ea4dce737831" />

## 🎯 학습 목표

- **SwiftUI 심화**: Custom Shape, View, Animation을 활용한 복합 UI 구현
- **Modern Swift**: async/await, @Observable 매크로 활용
- **Interactive UI**: 드래그 제스처와 햅틱 피드백을 결합한 직관적 UX
- **Live Activity**: iOS 16+ Dynamic Island 및 Lock Screen 위젯
- **다국어 지원**: 20개 언어 현지화 (Localization)
- **테스트 주도 개발**: Unit Test, UI Test 작성

## 📱 주요 기능

- **커스텀 타이머**: 드래그 제스처로 시간 설정, 햅틱 피드백 제공
- **집중 인증**: 타이머 완료 후 인증 사진 촬영 및 공유
- **Live Activity**: Dynamic Island와 Lock Screen에서 실시간 타이머 확인
- **다크모드**: 자동/수동 테마 전환 지원

## 🏗️ 아키텍처

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

## 🛠️ 기술 스택

- **UI Framework**: SwiftUI, Custom Shapes & Views
- **State Management**: @Observable macro, MVVM pattern
- **Concurrency**: async/await, Task Group
- **iOS Features**: Live Activity, Dynamic Island, Core Haptics
- **Testing**: XCTest, UI Testing, Mock Objects
- **Localization**: 20개 언어 지원 (SwiftGen 활용)
- **Build Tools**: Xcode Schemes, SwiftGen, Custom Scripts

## 🎨 핵심 구현 포인트

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

