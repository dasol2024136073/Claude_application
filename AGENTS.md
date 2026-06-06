# AGENTS.md

AI Agent가 이 프로젝트를 작업할 때 읽어야 하는 컨텍스트 파일입니다.

---

## 프로젝트 개요

취향 프로필 + 실시간 날씨를 Gemini AI에 전달해 개인화된 여행 경로를 생성·저장하는 Flutter 웹 앱.
1인 개발, 발표 데모 목적.

---

## 기술 스택 (실제 구현 기준)

| 영역 | 기술 | 비고 |
|------|------|------|
| 프레임워크 | Flutter 3.x + Dart 3.x | 웹 빌드 주력 (`flutter build web`) |
| 상태관리 | StatefulWidget | Riverpod는 pubspec에만 있고 실제 미사용 |
| 네비게이션 | GoRouter 14.x | 7개 경로 |
| AI 엔진 | Gemini 2.5 Flash | `gemini_service.dart`, thinkingBudget:0 |
| 날씨 | OpenWeatherMap API | `weather_service.dart` |
| 지도 | flutter_map + OpenStreetMap | API 키 불필요 |
| 저장 | SharedPreferences | Firebase 미연동, 로컬 JSON 직렬화 |
| 인증 | SharedPreferences 로컬 | 이메일/비밀번호 평문 (데모 전용) |
| HTTP | Dio 5.x | |

---

## 핵심 명령어

```bash
# 의존성 설치
flutter pub get

# 정적 분석 (작업 전후 반드시 실행)
flutter analyze

# 테스트 실행 (38개, 전부 통과 유지)
flutter test

# 웹 빌드 검증
flutter build web --no-pub

# 웹으로 실행
flutter run -d chrome
```

---

## 디렉토리 구조

```
lib/
├── core/
│   └── config.dart          # API 키 상수 (gitignore 적용 — 절대 커밋 금지)
├── domain/
│   └── models/
│       └── trip_plan.dart   # TripPlan / DayPlan / PlaceItem (toJson/fromJson)
├── data/
│   ├── mock/
│   │   └── mock_trip_data.dart          # 오사카·제주·도쿄·파리 더미 데이터
│   └── services/
│       ├── gemini_service.dart          # Gemini API 연동
│       ├── weather_service.dart         # OpenWeatherMap API
│       ├── weather_monitor_service.dart # Timer 기반 날씨 변화 감지
│       ├── trip_repository.dart         # 경로 저장·조회·삭제
│       └── auth_service.dart            # 로컬 이메일 인증
└── presentation/
    ├── screens/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── home_screen.dart
    │   ├── route_input_screen.dart
    │   ├── route_result_screen.dart
    │   └── map_screen.dart
    └── app.dart                         # GoRouter 라우팅

test/
├── ui_test.dart                         # LoginScreen 위젯 테스트 (4개)
├── debug_test.dart                      # 경계값·예외 케이스 (7개)
├── unit/unit_test.dart                  # 도메인 모델·MockData (13개)
└── integration/
    ├── scenario_test.dart               # 사용자 시나리오 (6개)
    └── integration_test.dart            # Data↔Domain 연동 (8개)
```

---

## 라우팅 (GoRouter)

| 경로 | 화면 |
|------|------|
| `/` | LoginScreen |
| `/signup` | SignupScreen |
| `/onboarding` | OnboardingScreen |
| `/home` | HomeScreen |
| `/route/input` | RouteInputScreen |
| `/route/result` | RouteResultScreen (extra: TripPlan) |
| `/route/map` | MapScreen (extra: TripPlan) |

---

## 아키텍처 원칙

- 4계층: Presentation → (Application 없음) → Domain → Data
- 화면은 서비스를 직접 호출한다 (Application 레이어 미구현)
- Domain 모델(`TripPlan`, `DayPlan`, `PlaceItem`)은 외부 의존 없음
- 각 Service는 static 메서드로 구성 (인스턴스 불필요)

---

## 코딩 규칙

1. **StatefulWidget 사용** — Riverpod Provider 생성 금지
2. **Gemini 모델**: `gemini-2.5-flash` 고정 (`gemini-2.5-pro` 사용 시 thinkingBudget 충돌)
3. **JSON 파싱**: `_extractJson()`을 반드시 거쳐서 파싱 (마크다운 블록 방어)
4. **날씨 변화 감지**: outdoor/indoor 카테고리 전환만 알림 (온도 변화는 무시)
5. **테스트**: 외부 API 호출 없이 `MockTripData`만 사용
6. **한국어 도시명**: `WeatherService._cityMap`을 통해 영문명으로 변환

---

## 보안 / 절대 금지 사항

- `lib/core/config.dart`는 `.gitignore` 적용 — **절대 커밋 금지**
- `config.dart` 파일에 접근할 때는 읽기만 하고 내용을 출력하거나 로그에 남기지 말 것
- `git add .` 또는 `git add -A` 사용 금지 — 폴더 단위로 명시적 add

---

## 작업 전 체크리스트

- [ ] `flutter analyze` 경고 없음
- [ ] `flutter test` 38개 전부 통과
- [ ] `config.dart`가 git 스테이징에 포함되지 않음

---

## 참조 문서

| 파일 | 내용 |
|------|------|
| `AUTHORING.임다솔.v0.3.0.md` | AI Agent 활용 방법론, Skills/Rules/Commands |
| `docs/architecture.md` | 4계층 아키텍처 + Mermaid 다이어그램 |
| `docs/setup.md` | 개발 환경 설정 |
| `docs/testing.md` | 테스트 전략 |
| `notes/week10~13-llm-wiki.md` | 프롬프트 패턴 14개, 실패 사례 |
| `.planning/` | 기획 문서 전체 (비전·요구사항·WBS·일정·위험) |
