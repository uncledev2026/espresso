# espresso

espresso는 macOS 메뉴 막대에서 동작하는 작은 샌드박스 유틸리티 앱입니다. 켜짐 상태에서는 IOKit 전원 assertion을 만들어 디스플레이가 유휴 상태로 어두워지거나 꺼지지 않게 하고, 그 결과 Mac이 유휴 절전 상태로 들어가지 않게 합니다. 꺼짐 상태에서는 assertion을 해제하므로 macOS가 사용자의 기존 전원 설정을 따릅니다.

## 요구 사항

- macOS 13 이상
- Xcode Command Line Tools
- Swift 6 호환 도구 체인

## 빌드

```sh
Scripts/build_app.sh
```

스크립트는 아래 앱 번들을 생성합니다.

```text
build/espresso.app
```

Xcode 프로젝트도 바로 열 수 있습니다.

```sh
open espresso.xcodeproj
```

CLI에서 Xcode 프로젝트를 빌드할 때는 macOS destination을 명시하면 Xcode가 대상 아키텍처를 자동 선택하며 출력하는 destination 경고를 피할 수 있습니다.

```sh
xcodebuild -project espresso.xcodeproj -scheme espresso -configuration Release -destination 'platform=macOS,arch=arm64' -derivedDataPath build/XcodeDerivedData build
```

로컬 테스트용 앱은 App Sandbox entitlement를 포함해 ad-hoc 서명됩니다. Mac App Store 제출 전에는 `Resources/Info.plist`의 `com.example.espresso`를 실제 등록한 번들 식별자로 바꾸고, Apple 배포 인증서와 프로비저닝 프로파일로 서명 및 아카이브해야 합니다.

## 로컬 서명 설정

Git에 올라가는 기본 서명 설정은 `Configs/Signing.xcconfig`에 있습니다. 개인 또는 팀별 값은 Git에서 무시되는 `Configs/Signing.local.xcconfig`에 작성해 덮어씁니다.

예시는 `Configs/Signing.local.xcconfig.example`에서 확인할 수 있습니다.

```xcconfig
PRODUCT_BUNDLE_IDENTIFIER = com.example.espresso
DEVELOPMENT_TEAM =
```

## 동작

- Dock 아이콘 없이 메뉴 막대 아이콘만 표시합니다.
- `켜기` 또는 `Enable`을 누르면 `kIOPMAssertionTypePreventUserIdleDisplaySleep` assertion을 만들어 Mac이 유휴 상태로 잠들지 않게 합니다.
- `끄기` 또는 `Disable`을 누르면 assertion을 해제하고 macOS 전원 설정으로 제어를 돌려줍니다.
- `로그인 시 실행` 또는 `Launch at Login`은 macOS 13 이상의 `SMAppService.mainApp`을 사용합니다.
- 켜짐/꺼짐 상태는 `UserDefaults`에 저장되므로 앱을 다시 실행할 때 이전 상태를 복원합니다.
- 주 언어가 `ko`로 시작하는 경우에만 한국어 UI 문자열을 사용하고, 그 외 모든 언어에서는 영어 UI 문자열을 사용합니다.

이 앱은 켜짐 상태에서 유휴 디스플레이 절전과 유휴 시스템 절전을 막습니다. 사용자가 직접 잠자기를 선택하는 경우, 노트북 덮개를 닫는 경우, 강제 종료, 배터리 또는 열 보호 상황까지 막지는 않습니다.

## 출처

- Apple 공식 문서, `IOPMAssertionCreateWithName`: https://developer.apple.com/documentation/iokit/1557134-iopmassertioncreatewithname
- Apple 공식 문서, `kIOPMAssertionTypePreventUserIdleDisplaySleep`: https://developer.apple.com/documentation/iokit/kiopmassertiontypepreventuseridledisplaysleep
- Apple 공식 문서, `NSStatusItem`: https://developer.apple.com/documentation/appkit/nsstatusitem
- Apple 공식 문서, `SMAppService.mainApp`: https://developer.apple.com/documentation/servicemanagement/smappservice/mainapp
- Apple 공식 문서, App Sandbox 배포 요구 사항: https://developer.apple.com/documentation/xcode/preparing-your-app-for-distribution
