# 테스트 전략

## 실행 방법

```bash
# 단위 + 시나리오 테스트 전체
flutter test test/unit/ test/scenario/

# 단위 테스트만
flutter test test/unit/

# 특정 파일만
flutter test test/unit/mock_trip_data_test.dart
```

## 테스트 구조

```
test/
├── unit/
│   ├── trip_plan_test.dart       # TripPlan / DayPlan / PlaceItem 모델
│   └── mock_trip_data_test.dart  # MockTripData.generate() 로직
├── scenario/
│   └── trip_generation_scenario_test.dart  # 여행 경로 생성 E2E 시나리오
└── widget_test.dart              # 앱 smoke test
```

## 테스트 계층

| 계층 | 파일 수 | 테스트 수 | 도구 |
|---|---|---|---|
| 단위 (Unit) | 2 | 13 | `flutter_test` |
| 시나리오 (Integration) | 1 | 1 | `flutter_test` |

## 테스트 네이밍 규칙

`should_{기대 결과}_when_{조건}` 형식 사용

예: `should_return_osaka_plan_when_keyword_is_오사카`

## 커버리지 범위

- `TripPlan` / `DayPlan` / `PlaceItem` 모델 생성 및 필드 저장
- `MockTripData.generate()` — 키워드 매칭 (오사카, 제주, 도쿄, 파리, 알 수 없는 목적지)
- 경계값: 0일 입력 시 빈 일정 반환
- 시나리오: 오사카 2박3일 요청 → 2개 일정 + 1일차 도톤보리 포함 검증
