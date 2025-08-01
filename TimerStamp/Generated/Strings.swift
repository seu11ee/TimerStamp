// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// 인증 사진 만들기
  public static let authPhoto = L10n.tr("Localizable", "auth_photo", fallback: "인증 사진 만들기")
  /// 취소
  public static let cancel = L10n.tr("Localizable", "cancel", fallback: "취소")
  /// 닫기
  public static let certClose = L10n.tr("Localizable", "cert_close", fallback: "닫기")
  /// 이미지를 렌더링 중입니다...
  public static let certRendering = L10n.tr("Localizable", "cert_rendering", fallback: "이미지를 렌더링 중입니다...")
  /// 이미지 저장
  public static let certSaveImage = L10n.tr("Localizable", "cert_save_image", fallback: "이미지 저장")
  /// 공유하기
  public static let certShare = L10n.tr("Localizable", "cert_share", fallback: "공유하기")
  /// 인증 사진
  public static let certTitle = L10n.tr("Localizable", "cert_title", fallback: "인증 사진")
  /// 완료
  public static let done = L10n.tr("Localizable", "done", fallback: "완료")
  /// %d분 집중 완료!
  public static func focusComplete(_ p1: Int) -> String {
    return L10n.tr("Localizable", "focus_complete", p1, fallback: "%d분 집중 완료!")
  }
  /// 확인
  public static let ok = L10n.tr("Localizable", "ok", fallback: "확인")
  /// 집중을 마친 후 인증 사진을 저장하거나 공유할 수 있어요.
  public static let onboardingCertDesc = L10n.tr("Localizable", "onboarding_cert_desc", fallback: "집중을 마친 후 인증 사진을 저장하거나 공유할 수 있어요.")
  /// 집중한 후 인증 사진 만들기
  public static let onboardingCertTitle = L10n.tr("Localizable", "onboarding_cert_title", fallback: "집중한 후 인증 사진 만들기")
  /// 시작하기
  public static let onboardingStart = L10n.tr("Localizable", "onboarding_start", fallback: "시작하기")
  /// 원하는 시간만큼 다이얼을 돌려 집중을 시작하세요.
  public static let onboardingTimerDesc = L10n.tr("Localizable", "onboarding_timer_desc", fallback: "원하는 시간만큼 다이얼을 돌려 집중을 시작하세요.")
  /// 다이얼을 돌리고 타이머 시작
  public static let onboardingTimerTitle = L10n.tr("Localizable", "onboarding_timer_title", fallback: "다이얼을 돌리고 타이머 시작")
  /// 타이머와 인증을 통해 집중력 올리기
  public static let onboardingTitle = L10n.tr("Localizable", "onboarding_title", fallback: "타이머와 인증을 통해 집중력 올리기")
  /// 보관함에서 선택
  public static let photoChooseLibrary = L10n.tr("Localizable", "photo_choose_library", fallback: "보관함에서 선택")
  /// 이미지가 저장되었습니다!
  public static let photoSaveSuccess = L10n.tr("Localizable", "photo_save_success", fallback: "이미지가 저장되었습니다!")
  /// 사진을 어떻게 가져올까요?
  public static let photoSourceTitle = L10n.tr("Localizable", "photo_source_title", fallback: "사진을 어떻게 가져올까요?")
  /// 사진 찍기
  public static let photoTakeNew = L10n.tr("Localizable", "photo_take_new", fallback: "사진 찍기")
  /// 저장
  public static let save = L10n.tr("Localizable", "save", fallback: "저장")
  /// 일시정지
  public static let timerPause = L10n.tr("Localizable", "timer_pause", fallback: "일시정지")
  /// 초기화
  public static let timerReset = L10n.tr("Localizable", "timer_reset", fallback: "초기화")
  /// 분침을 돌려 시간을 설정하세요
  public static let timerRotateInstruction = L10n.tr("Localizable", "timer_rotate_instruction", fallback: "분침을 돌려 시간을 설정하세요")
  /// 시작
  public static let timerStart = L10n.tr("Localizable", "timer_start", fallback: "시작")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
