# LLM Wiki — 12주차 암묵지 정리

> 날짜: 2026-05-26
> 도구: Claude Code (claude-sonnet-4-6)
> 작업: 핵심 화면 구현 (LoginScreen, OnboardingScreen, HomeScreen, RouteInputScreen, RouteResultScreen)

---

## 1. 효과적이었던 프롬프트 패턴

### 패턴 8: "이어서 할게" — 메모리 기반 세션 재개

새 대화를 시작할 때 매번 배경 설명 없이 "이어서 할게" 한 마디로 재개할 수 있었음.
Agent가 자동으로 `MEMORY.md` → `project_flutter_travel_app.md` 를 읽어 현황을 파악하고,
이전 슬라이드 파일(`week-12.md`)까지 분석해서 이번 주 할 일을 제시함.

```
사용자: "이어서 할게"
→ Agent: memory 확인 → 프로젝트 디렉토리 탐색 → week-12.md 분석
→ 12주차 목표(Must 50% + 중간 발표) 자동 도출 → 작업 제안
```

**핵심 조건**: memory 파일에 프로젝트 위치, GitHub URL, 다음 할 일이 명확히 기록되어 있어야 함.
기록이 없으면 Agent도 문맥을 잃음.

---

### 패턴 9: 데이터 레이어 분리 요청 — "도메인 모델도 만들어줘"

화면(UI)만 만들어달라고 하면 더미 데이터가 화면 안에 인라인 됨.
"도메인 모델 + mock 데이터 레이어 분리"를 명시하면
`lib/domain/models/` 와 `lib/data/mock/` 에 각각 파일이 생성됨.

```
// 나쁜 프롬프트:
"오사카 일정 화면 만들어줘"

// 좋은 프롬프트:
"TripPlan / DayPlan / PlaceItem 도메인 모델 만들고,
 MockTripData 클래스로 오사카·제주·도쿄 더미 데이터 분리해줘"
```

**왜 중요한가**: 나중에 실제 API로 교체할 때 화면 코드를 건드리지 않고 data 레이어만 바꾸면 됨.
아키텍처 문서(ADR, layered)와 코드 구조가 일치하게 됨.

---

### 패턴 10: 빌드 검증을 프롬프트에 포함

"화면 만들어줘" 다음에 자동으로 `flutter analyze` 와 `flutter build web --debug` 를 실행하도록
세션 초반에 요청해두면 실수가 줄어듦.

```
"만든 후에 flutter analyze 먼저 실행하고, 이슈 없으면 빌드까지 확인해줘"
```

**이번에 발견한 것**: `(_, __)` 형식의 unnamed parameter가 flutter 3.x에서
`unnecessary_underscores` info를 발생시킴 → `(context, _)` 로 수정.

---

## 2. 실수 & 학습

### 실수: GoRouter route 빌더에서 `__` (double underscore) 사용

go_router의 GoRoute builder에서 사용하지 않는 파라미터에 `(_, __)` 를 쓰면
flutter analyze가 `unnecessary_underscores` info를 발생시킴.

```dart
// 수정 전 (info 발생)
GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),

// 수정 후 (clean)
GoRoute(path: '/home', builder: (context, _) => const HomeScreen()),
```

→ 파라미터가 2개일 때는 두 번째만 `_` 로 처리하면 됨.

---

### 학습: `withOpacity()` → `withValues(alpha: ...)` 마이그레이션

Flutter 3.27 이상에서 `Color.withOpacity()`가 deprecated.
`withValues(alpha: 0.12)` 형태로 바꿔야 경고가 없어짐.

```dart
// 이전 방식
color.withOpacity(0.12)

// 새 방식
color.withValues(alpha: 0.12)
```

---

## 3. 아키텍처 결정 — 더미 데이터 설계

### 결정: 목적지 키워드로 분기하는 MockTripData

실제 API 없이 오사카/제주/도쿄/파리 네 가지 경우를 준비하고,
없는 목적지는 generic 템플릿으로 처리.

```dart
static TripPlan generate(String destination, int days) {
  final key = destination.toLowerCase();
  if (key.contains('오사카') || key.contains('osaka')) return _osaka(days);
  if (key.contains('제주') || key.contains('jeju'))   return _jeju(days);
  // ...
  return _generic(destination, days);
}
```

**장점**: 데모 때 자연스럽게 "오사카 3박 4일" 입력 → 실제처럼 보이는 결과.
**한계**: 실제 AI 호출이 아니라 발표 때 솔직하게 "현재 mock 데이터, 다음 주에 Claude API 연동 예정"이라고 말할 것.

---

## 4. 데모 전 체크리스트 (회고)

| 항목 | 결과 |
|---|---|
| `flutter analyze` clean | ✅ No issues |
| `flutter build web --debug` 성공 | ✅ Built build/web |
| GitHub push 완료 | ✅ main d6f8119 |
| LoginScreen → OnboardingScreen 네비게이션 | ✅ |
| RouteInputScreen 로딩 애니메이션 | ✅ 2초 딜레이 |
| RouteResultScreen 저장 버튼 | ✅ SnackBar 피드백 |
