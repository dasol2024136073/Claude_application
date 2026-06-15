# 테스트 전략

## 실행 방법

```bash
# 전체 테스트
flutter test

# 단위 테스트만
flutter test test/unit/

# 통합 테스트만
flutter test test/integration/

# 위젯(UI) 테스트만
flutter test test/ui_test.dart

# 특정 파일만
flutter test test/debug_test.dart
```

## 테스트 구조

```
test/
├── unit/
│   └── unit_test.dart            # TripPlan/DayPlan/PlaceItem 모델 + MockTripData.generate() 분기
├── integration/
│   ├── integration_test.dart     # Data→Domain 레이어 연동 (반환 타입·구조 일관성)
│   └── scenario_test.dart        # 사용자 시나리오 통합 (오사카 2박3일, 뉴욕 3박4일)
├── debug_test.dart                # 경계값·예외 케이스 (days=0, 미등록 목적지 등)
└── ui_test.dart                   # LoginScreen 위젯 렌더링
```

## 테스트 계층

| 계층 | 파일 | 테스트 수 | 도구 |
|---|---|---|---|
| 단위 (Unit) | `unit/unit_test.dart` | 13 | `flutter_test` |
| 통합 (Integration) | `integration/integration_test.dart` | 5 | `flutter_test` |
| 시나리오 (Scenario) | `integration/scenario_test.dart` | 6 | `flutter_test` |
| 디버깅/경계값 | `debug_test.dart` | 7 | `flutter_test` |
| 위젯 (UI) | `ui_test.dart` | 4 | `flutter_test` |

**`flutter test` 실행 시 총 38개, 전부 통과**

## 테스트 네이밍 규칙

`{대상}이/가 {조건}에서 {기대 결과}` 형식의 한글 서술형 사용

예: `요청한 박수+1일치 dayPlans를 반환한다 (2박3일)`

## 핵심 도메인 규칙: N박 M일

`MockTripData.generate(destination, days)`의 `days`는 **숙박 일수(박)**를 의미하며, 반환되는 `dayPlans`는 `days + 1`개(= M일)입니다. (`route_input_screen.dart`의 `'$_days박 ${_days + 1}일'` 표기와 동일한 규칙, `lib/data/mock/mock_trip_data.dart`의 `.take(days + 1)` / `List.generate(days + 1, ...)`로 구현)

## 커버리지 범위

- `TripPlan` / `DayPlan` / `PlaceItem` 모델 생성 및 필드 저장
- `MockTripData.generate()` — 목적지 키워드 매칭(오사카/제주/도쿄/파리, 영문·대문자·복합 문자열 포함) 및 미등록 목적지의 generic 플랜 처리
- N박 M일 규칙: `days=0`(당일치기 → 1일치), `days=1`(1박2일 → 2일치), `days=2`(2박3일 → 3일치)
- 경계값: 보유한 dayPlans 수를 초과 요청해도 최대 보유분까지만 반환
- 시나리오: 오사카 2박3일 → 3일치 일정 + 1일차 도톤보리 포함, 뉴욕 3박4일(미등록 도시) → generic 4일치 일정
- Data→Domain 레이어 연동: `MockTripData.generate()` 반환 타입 및 4개 목적지 구조 일관성
- 위젯: 로그인 화면 타이틀·이메일/비밀번호 입력란·로그인/회원가입 버튼 렌더링
