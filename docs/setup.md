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

## 3단계 — 환경 변수 설정

Firebase와 API 키는 `.env` 파일로 관리합니다. (현재 Hello World 단계는 불필요)

```bash
# .env.example을 복사해서 .env 생성
cp .env.example .env
```

`.env` 파일에 아래 값을 채워넣으세요.

```
# Firebase (12주차 설정 후 추가)
FIREBASE_PROJECT_ID=

# API Keys (12주차 이후 추가)
GOOGLE_MAPS_API_KEY=
OPENWEATHER_API_KEY=
CLAUDE_API_KEY=
```

> `.env` 파일은 `.gitignore`에 포함되어 있어 절대 커밋되지 않습니다.

---

## 4단계 — 에뮬레이터 실행 확인

```bash
flutter devices
```

사용 가능한 디바이스 목록이 나와야 합니다. 없으면 Android Studio에서 에뮬레이터를 먼저 시작하세요.

---

## 5단계 — 앱 실행

```bash
flutter run
```

"AI 여행 경로 추천" 타이틀과 시작하기 버튼이 보이면 성공입니다.

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
