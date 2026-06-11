# 빌드 / 배포 가이드

> "배포는 어떻게 하나요?" 질문에 이 문서 하나로 답할 수 있어야 합니다.

---

## 1. 빌드 종류

| 빌드 타입 | 용도 | 명령어 |
|---|---|---|
| **debug** | 로컬 개발, 핫리로드 | `flutter run -d chrome` |
| **release** | 실제 배포용 최적화 빌드 | `flutter build web --release` |
| **profile** | 성능 프로파일링 | `flutter build web --profile` |

본 프로젝트는 **Flutter Web** 우선 개발이며, Android/iOS도 동일 코드베이스로 빌드 가능합니다.

```bash
# 디버그 (Chrome에서 즉시 실행)
flutter run -d chrome

# 릴리스 웹 빌드 (build/web/ 에 산출물 생성)
flutter build web --release

# Android 릴리스 APK (apk/ipa 산출 옵션)
flutter build apk --release --split-per-abi

# iOS 릴리스
flutter build ios --release
```

---

## 2. 서명 / 인증서 관리

- **Android**: 현재 데모 단계는 Flutter 기본 **debug 서명**으로 빌드합니다.
  - 정식 release APK 배포 시 `android/key.properties` + keystore(`*.jks`)를 생성해야 하며, 둘 다 `.gitignore`에 포함되어 커밋되지 않습니다 (기존 `.gitignore` 규칙 적용됨).
  - keystore 생성 명령:
    ```bash
    keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias travel_ai
    ```
- **iOS**: Xcode의 Apple Developer 인증서/프로비저닝 프로파일 필요 (본 프로젝트 범위 외, TestFlight 진행 시 적용).
- **Web**: 별도 서명 불필요. HTTPS는 GitHub Pages가 기본 제공.

---

## 3. 환경별 설정

API 키는 `.env` 대신 **`lib/core/config.dart`** 파일로 관리합니다 (Flutter Web에서 `dotenv` 로딩 이슈를 피하기 위한 선택).

```dart
// lib/core/config.dart (gitignore 처리됨, 절대 커밋 금지)
const geminiApiKey = '...';
const openWeatherApiKey = '...';
```

| 항목 | 내용 |
|---|---|
| 커밋되는 파일 | 없음 — `lib/core/config.dart`는 `.gitignore`에 등록됨 |
| 신규 환경 설정 | 위 템플릿대로 `lib/core/config.dart`를 직접 생성 (값은 팀 내부 공유) |
| 키 종류 | Gemini API 키, OpenWeatherMap API 키 |
| dev/prod 구분 | 현재 단일 환경(config.dart 1개)으로 운영. 추후 `.env.dev` / `.env.prod` 분리 시 `flutter_dotenv` 패키지 도입 예정 |

---

## 4. 배포 채널 / 명령

### 4-1. 발표 슬라이드 (Marp → GitHub Pages, 자동)
`.github/workflows/deploy-slides.yml`이 `main` 브랜치 push 시 자동 동작:
```bash
marp midterm-presentation.md --html --output dist/index.html
```
→ GitHub Pages로 자동 배포.

### 4-2. Flutter Web 앱 (수동)
```bash
flutter build web --release
# build/web/ 폴더 전체를 정적 호스팅(GitHub Pages, Firebase Hosting 등)에 업로드
```

### 4-3. 모바일 산출물 (apk/ipa)
```bash
flutter build apk --release --split-per-abi
# 산출물: build/app/outputs/flutter-apk/*.apk
```
최소 요건: apk 1개 산출 + 1인 이상 설치 확인.

---

## 5. 버전 관리 규칙 (SemVer)

`pubspec.yaml`의 `version: MAJOR.MINOR.PATCH+BUILD` 형식을 따릅니다.

| 구분 | 의미 | 예시 |
|---|---|---|
| MAJOR | 호환 깨지는 변경 | 1.x.x → 2.0.0 |
| MINOR | 기능 추가 | 1.0.x → 1.1.0 |
| PATCH | 버그 수정 | 1.0.0 → 1.0.1 |
| BUILD | 빌드 번호 (`+1`, `+2`...) | `1.0.0+1` → `1.0.0+2` |

현재 버전: `pubspec.yaml`, `version.json` 기준 **1.0.0+1**.
배포 빌드 시 `--build-name`/`--build-number` 옵션으로 덮어쓰기 가능:
```bash
flutter build web --release --build-name=1.1.0 --build-number=2
```

---

## 6. 롤백 방법

1. **코드 롤백**: `git revert <commit>` 또는 이전 태그/커밋으로 `git checkout` 후 재빌드.
2. **GitHub Pages 롤백**: `main` 브랜치를 문제 이전 커밋으로 되돌리고 push → `deploy-slides.yml`이 자동 재배포.
3. **APK 롤백**: 이전 버전 APK(`build/app/outputs/flutter-apk/` 백업본)를 재배포 — 빌드 시마다 산출물을 버전 태그와 함께 보관 권장.

---

## 7. 보안 체크리스트

- [x] API 키(`lib/core/config.dart`)가 코드 저장소에 커밋되지 않음 — `.gitignore` 등록 확인
- [x] `.gitignore`에 `*.jks`, `android/key.properties` 포함
- [x] 사용자 입력은 `TripRepository`/`AuthService`에서 형식 검증 후 SharedPreferences에 저장
- [x] OpenWeatherMap, Gemini API 통신은 HTTPS
- [ ] 로컬 저장 데이터(SharedPreferences)는 평문 저장 — 민감정보(비밀번호 등) 암호화는 향후 개선 항목
- [x] 로그에 비밀번호/API 키 출력 없음
- [x] 위치 권한은 현재 위치 기반 날씨 조회 목적으로만 사용 (앱 내 안내 문구 포함)
