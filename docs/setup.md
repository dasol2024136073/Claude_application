# 개발 환경 설정 가이드

> 이 문서만 보고 5분 안에 앱을 실행할 수 있어야 합니다.

---

## 필요한 도구

| 도구 | 버전 | 설치 확인 명령 |
|------|------|----------------|
| Flutter SDK | 3.x 이상 | `flutter --version` |
| Dart SDK | 3.x 이상 | `dart --version` |
| Android Studio / VS Code | 최신 | — |
| Android SDK | 36.x 이상 | `flutter doctor` |
| Git | 2.x 이상 | `git --version` |

---

## 1단계 — 클론

```bash
git clone https://github.com/dasol2024136073/Claude_application.git
cd Claude_application
```

---

## 2단계 — 의존성 설치

```bash
flutter pub get
```

---

## 3단계 — API 키 설정

API 키는 `.env` 대신 **`lib/core/config.dart`** 파일로 관리합니다 (Flutter Web에서 `dotenv` 로딩 이슈를 피하기 위한 선택).

```bash
# 템플릿을 복사해서 config.dart 생성
cp lib/core/config.example.dart lib/core/config.dart
```

`lib/core/config.dart` 파일에 아래 값을 채워넣으세요.

```dart
const geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
const openWeatherApiKey = 'YOUR_OPENWEATHER_API_KEY_HERE';
```

| 키 | 용도 | 발급처 |
|---|---|---|
| `geminiApiKey` | AI 여행 경로 생성 (Gemini 2.5 Flash) | Google AI Studio |
| `openWeatherApiKey` | 실시간 날씨/예보 조회 | OpenWeatherMap |

> `lib/core/config.dart`는 `.gitignore`에 포함되어 있어 절대 커밋되지 않습니다. 템플릿인 `config.example.dart`만 저장소에 포함됩니다.

---

## 4단계 — 실행 디바이스 확인

```bash
flutter devices
```

본 프로젝트는 **Flutter Web(Chrome) 우선 개발**이므로 Chrome이 목록에 있으면 충분합니다. Android 에뮬레이터로 실행하려면 Android Studio에서 AVD를 먼저 시작하세요.

---

## 5단계 — 앱 실행

```bash
flutter run -d chrome
```

이메일/비밀번호 로그인 화면(Tripia)이 보이면 성공입니다. 계정이 없다면 회원가입 화면에서 새 계정을 만들 수 있습니다.

### 특정 디바이스 지정

```bash
# 연결된 디바이스 목록 확인
flutter devices

# 특정 디바이스로 실행
flutter run -d <device-id>

# Chrome(웹)으로 실행
flutter run -d chrome
```

---

## 플랫폼별 주의사항

### Windows
- Android 에뮬레이터는 Android Studio에서 AVD Manager로 생성
- `flutter doctor`로 모든 항목 체크 확인

### macOS
- iOS 빌드: Xcode 설치 필요 (`xcode-select --install`)
- iOS 시뮬레이터: `open -a Simulator`

### Linux
- Android 에뮬레이터 또는 실기기 연결 필요
- `sudo apt install default-jdk` (JDK 필요 시)

---

## FAQ

**Q1. `flutter pub get` 실패할 때**
```bash
flutter clean
flutter pub get
```

**Q2. 에뮬레이터가 목록에 안 보일 때**
Android Studio → Device Manager → 에뮬레이터 시작 후 다시 `flutter devices`

**Q3. Gradle 빌드 실패 시**
```bash
cd android
./gradlew clean
cd ..
flutter run
```

**Q4. `flutter doctor`에 빨간 항목이 있을 때**
표시된 명령을 그대로 실행하면 대부분 해결됩니다. (예: `flutter doctor --android-licenses`)

**Q5. 패키지 버전 충돌 시**
```bash
flutter pub upgrade
```

**Q6. `Target of URI doesn't exist: '../../core/config.dart'` 에러가 날 때**
`lib/core/config.dart` 파일이 없는 상태입니다. 3단계대로 `config.example.dart`를 복사해 `config.dart`를 생성하고 API 키를 채워주세요.
