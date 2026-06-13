# LLM Wiki — 14주차 암묵지 정리

> 날짜: 2026-06-13
> 도구: Claude Code (claude-sonnet-4-6)
> 작업: 홈 화면 AI 개인화 추천(Unsplash 연동), "지금 갈 수 있는 근교 코스" 추천,
> 실내/실외 선호 필터, N박(N+1)일 일정 생성 버그 수정, 커뮤니티(게시글·댓글·후기) 기능,
> 기획/아키텍처 문서 동기화

---

## 1. 효과적이었던 프롬프트 패턴

### 패턴 21: 캐싱이 필요한 AI 추천 — Repository + 타임스탬프 키 패턴

Gemini로 "취향 기반 추천 여행지"를 매번 새로 생성하면 홈 화면 진입마다 API 호출이 발생해
속도도 느리고 추천 결과도 매번 바뀜. 결과를 SharedPreferences에 캐싱하고
별도의 타임스탬프 키로 만료(24시간)를 관리하는 패턴을 적용함.

```dart
class RecommendationRepository {
  static const _key = 'destination_recommendations';
  static const _timeKey = 'destination_recommendations_time';

  static Future<List<DestinationRecommendation>> getOrFetch(
    Future<List<DestinationRecommendation>> Function() fetch,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final timeRaw = prefs.getString(_timeKey);
    if (timeRaw != null &&
        DateTime.now().difference(DateTime.parse(timeRaw)) < const Duration(hours: 24)) {
      // 캐시된 값 반환
    }
    final fresh = await fetch();
    await prefs.setString(_key, jsonEncode(fresh.map((r) => r.toJson()).toList()));
    await prefs.setString(_timeKey, DateTime.now().toIso8601String());
    return fresh;
  }
}
```

**핵심 키워드**: "값 키 + 타임스탬프 키 분리", "만료 시간 비교 후 캐시 히트/미스 분기".
**교훈**: AI 추천처럼 비용·지연이 있는 호출은 Repository 레이어에서 캐싱 책임을 갖게 하면
화면(Presentation)은 "캐시든 새 데이터든 받아서 그리기만" 하면 됨.

---

### 패턴 22: 외부 사진 API + Graceful Fallback UI

Unsplash에서 추천 여행지 사진을 가져오되, API 실패·키 미설정·검색 결과 없음 등
어떤 경우에도 화면이 깨지지 않도록 "사진 없으면 그라데이션+이모지" fallback을 항상 준비함.

```dart
// PhotoService.search()가 null을 반환할 수 있음을 전제로 위젯을 작성
photoUrl != null
    ? Image.network(photoUrl, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _FallbackGradient(emoji: emoji))
    : _FallbackGradient(emoji: emoji)
```

**왜 씀**: 데모 환경에서 Unsplash API 키가 없거나 rate limit에 걸려도 카드 UI 자체는
항상 동일한 레이아웃으로 보여야 발표가 매끄러움.
**교훈**: "외부 리소스가 있으면 좋은 것"은 반드시 없는 경우의 디자인을 먼저 정하고 구현 요청.

---

### 패턴 23: 저장된 값을 기본값으로 쓰되, "이번만 변경"은 저장하지 않는 UI

온보딩에서 저장한 취향(여행 스타일/예산/동행/지역/강도/실내·실외)을 경로 검색 시
기본 필터로 자동 적용하면서도, 사용자가 그 화면에서 일시적으로 다른 값을 선택할 수 있게 하되
그 선택은 영구 저장되지 않아야 한다는 요구사항을 다음과 같이 구현함.

```dart
// 1) initState에서 저장된 취향으로 Set/필드를 채움 (= 기본값)
// 2) 사용자가 칩을 누르면 로컬 State만 바뀜 (Set<int> / int?)
// 3) "경로 생성" 시 이 State 값을 그대로 Gemini 프롬프트에 전달
// 4) AuthService.updatePreferences()는 호출하지 않음 → 영구 저장 안 됨
```

**핵심 키워드**: "기본값 = 저장된 상태로 초기화", "이번 세션의 변경은 별도 저장 호출 없이 휘발".
**교훈**: "기본값 자동 적용"과 "영구 저장"은 별개의 요구사항이다. AI에게 이 둘을 분리해서
명시하지 않으면 칩을 누르는 즉시 `updatePreferences()`를 호출하는 코드를 만들기 쉽다.

---

### 패턴 24: "박"과 "일"이 섞인 조건은 프롬프트에 직접 환산된 숫자로 적기

"N박 M일" 여행에서 `dayPlans` 배열 길이는 `M = N+1`이어야 하는데,
프롬프트 조건에 `days`(박)를 그대로 써서 LLM이 `days`개만 생성하는 버그가 있었음.

```dart
// 나쁜 조건문 (버그):
"조건: ${days}박 일정이므로 dayPlans 배열 길이는 ${days}"

// 좋은 조건문:
"조건: ${days}박 ${days + 1}일 일정이므로 dayPlans 배열 길이는 반드시 ${days + 1}
(day 1부터 day ${days + 1}까지 모두 포함)"
```

**교훈**: 사람은 "1박 2일"을 자연스럽게 이해하지만, 프롬프트에 변수를 그대로 넣으면
"박"과 "일"의 +1 차이가 묻힌다. 조건문에는 항상 **최종적으로 필요한 숫자(`days+1`)를
미리 계산해서** 박아 넣는다.

---

### 패턴 25: 플래그 기반 프롬프트 분기 (nearbyNow)

"지금 갈 수 있는 근교 코스"처럼 기존 흐름과 비슷하지만 제약 조건이 다른 요청은
새 함수를 만들지 않고, 기존 `generateTripPlan()`에 `bool` 플래그를 추가해
`extraConditions`에 조건을 추가하는 방식으로 구현함.

```dart
static Future<TripPlan> generateTripPlan(
  String destination, int days, {
  ... 기존 파라미터 ...
  bool nearbyNow = false,
}) async {
  if (nearbyNow) {
    extraConditions.writeln('- 지금 당장 출발하는 당일 근교 코스야. 장소는 $destination 근교(30분 이내)');
    extraConditions.writeln('- 장소 2~4개만 추천해줘. (장소 4개 조건보다 이 조건을 우선해)');
  }
}
```

**교훈**: 기존 함수의 시그니처를 깨지 않는 선택적 파라미터(`bool ... = false`)로
변형 요청을 처리하면, 호출부(홈 화면 vs 경로 입력 화면)는 각자 필요한 옵션만 켜면 됨.
조건 간 우선순위가 충돌할 수 있는 경우(장소 개수 등)는 "이 조건을 우선해"처럼
명시적으로 우선순위를 적어줘야 LLM이 일관되게 따름.

---

### 패턴 26: 로컬 게시판 — Repository + ValueNotifier 이벤트 버스

Firebase 없이 SharedPreferences로 커뮤니티 게시글/댓글(대댓글 포함)/좋아요 기능을 구현할 때,
"글 작성 화면에서 저장 → 목록 화면이 자동으로 갱신"되어야 하는 문제를
전역 `ValueNotifier<int>` 이벤트 버스로 해결함.

```dart
class CommunityEvents {
  static final ValueNotifier<int> changed = ValueNotifier(0);
  static void notify() => changed.value++;
}

// 저장 후
await CommunityRepository.save(post);
CommunityEvents.notify();

// 목록 화면
@override
void initState() {
  super.initState();
  CommunityEvents.changed.addListener(_load);
}
```

**교훈**: Riverpod/Provider 같은 상태관리 없이도, "데이터가 바뀌었다"는 신호만 전달하면
충분한 경우(목록 새로고침)는 `ValueNotifier` 1줄짜리 이벤트 버스로 충분하다.
ADR-0004(StatefulWidget/SharedPreferences 피벗)와 일관된 경량 패턴.

---

## 2. 실수 & 학습

### 실수: 문서에 실제로 없는 "북마크" 기능을 있다고 서술

- **상황**: `docs/architecture.md`를 업데이트하면서 커뮤니티 게시글에 "좋아요·북마크" 기능이
  있다고 적었음.
- **원인**: `route_result_screen.dart`/`my_routes_screen.dart`의 "경로 저장(bookmark 아이콘)"과
  "커뮤니티 게시글 좋아요(`likedBy`)"를 혼동함. `CommunityPost` 모델에는 북마크 필드가 없음.
- **해결**: `grep -rn "bookmark" lib/`로 실제 사용 위치를 확인 → 커뮤니티 글에는 좋아요만 있음을
  확인하고 문서에서 "북마크" 표현 삭제, 게시글 카테고리(경로공유/질문/자유) 표기로 대체.
- **교훈**: AI가 작성한 문서에 "있을 법한 기능"이 자연스럽게 끼어들 수 있다.
  특정 기능의 존재 여부를 문서화할 때는 모델 필드/서비스 메서드 이름을 grep으로 직접 확인한다.

---

### 실수: N박(N+1)일 일정에서 마지막 날 일정 누락 (재확인)

- **상황**: "1박 2일"을 입력하면 day 1만 생성되고 day 2(출국 전 일정)가 누락됨.
- **원인**: 프롬프트의 dayPlans 길이 조건이 `days`(=1, 박 기준)로 적혀 있어
  LLM이 정확히 1개짜리 배열만 생성함.
- **해결**: 패턴 24 적용 — 조건문에 `${days + 1}`을 직접 계산해서 명시.
- **교훈**: "증상"(마지막 날이 없다)이 아니라 "원인이 되는 데이터 구조"(dayPlans 길이 식)를
  먼저 코드에서 찾아 AI에게 전달하면 한 번에 수정됨. R-09("증상이 아닌 증거")의
  적용 대상이 로그뿐 아니라 **프롬프트/데이터 구조 자체**일 수도 있음을 확인.

---

## 3. 아키텍처 결정 — GNB(하단 탭) 도입

### 결정: 일반 GoRoute push 방식 → `StatefulShellRoute.indexedStack` 기반 GNB

홈/내 경로/커뮤니티/마이페이지가 늘어나면서 화면마다 상단으로 돌아가는 방식보다
하단 탭(바텀 네비게이션)으로 전환할 필요가 생김.

| 기준 | 기존 (GoRoute push) | StatefulShellRoute (GNB) |
|---|---|---|
| 탭 전환 시 상태 유지 | ❌ (재생성) | ✅ (IndexedStack으로 각 탭 상태 보존) |
| 뒤로가기 동작 | 스택 전체 pop | 탭별 독립 스택 |
| 구현 복잡도 | 낮음 | 중간 (MainShell 위젯 1개 추가) |

**결론**: `MainShell` 위젯 하나로 4개 탭(홈/내 경로/커뮤니티/마이페이지)을 감싸고,
나머지 화면(경로 입력/결과/지도/글쓰기 등)은 기존처럼 GoRoute push로 유지.
GNB 진입 시 AppBar 타이틀 폰트도 22px → 18px로 줄여 탭 전환이 잦은 화면에 맞춤.

---

## 4. 누적 패턴 현황 (14주차 기준)

| 주차 | 패턴 번호 | 주제 |
|------|-----------|------|
| 10주차 | 1~3 | 조건 정의, 선택형 질문, 문서 참조 |
| 11주차 | 4~7 | md 파일 분석, 현황 파악, 빌드 검증, git add 범위 |
| 12주차 | 8~10 | 메모리 기반 재개, 도메인 모델 분리, 빌드 검증 포함 |
| 13주차 | 11~14 | JSON 강제, 방어적 파싱, thinkingBudget, 로컬 인증 |
| 15주차 | 15~20 | AGENTS.md, base-href, 빌드 보안, 도시명 변환 맵, 전문용어 정제, Web API 디버깅 |
| 14주차(본 문서) | 21~26 | 추천 캐싱, 외부 사진 fallback, 임시 필터 오버라이드, 박/일 환산, 플래그 기반 프롬프트 분기, 로컬 게시판 이벤트 버스 |

총 **26개 패턴** 누적 (LLM Wiki 가산점 기준 10개 초과)
