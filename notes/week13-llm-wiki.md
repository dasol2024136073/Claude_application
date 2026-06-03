# LLM Wiki — 13주차 암묵지 정리

> 날짜: 2026-06-03
> 도구: Claude Code (claude-sonnet-4-6)
> 작업: Gemini API 연동, 로컬 인증(SharedPreferences), 단위 테스트 13개

---

## 1. 효과적이었던 프롬프트 패턴

### 패턴 11: LLM에게 구조화된 JSON 출력 강제하기

Gemini API에서 여행 경로를 JSON으로 받을 때, 단순히 "JSON으로 줘"라고 하면
마크다운 코드 블록(```` ```json ````…```` ``` ````)이나 설명 텍스트가 섞여 파싱에 실패함.

```
// 나쁜 프롬프트:
"여행 경로를 JSON 형식으로 알려줘"

// 좋은 프롬프트:
"반드시 아래 JSON 형식으로만 응답해. 마크다운, 설명 텍스트 없이 JSON만:
{ ... 스키마 예시 ... }
조건: category는 [관광/맛집/...] 중 하나, description은 한국어 50자 이내"
```

**핵심 키워드**: "형식으로만", "설명 텍스트 없이", 스키마 예시를 직접 삽입.

---

### 패턴 12: 방어적 JSON 파싱 — `_extractJson` 메서드

아무리 프롬프트를 잘 써도 LLM이 마크다운 블록을 포함하는 경우가 있음.
파싱 로직에서 방어적으로 처리하는 게 안전함.

```dart
static String _extractJson(String text) {
  final clean = text
      .replaceAll(RegExp(r'```json\s*'), '')
      .replaceAll('```', '')
      .trim();
  final start = clean.indexOf('{');
  final end = clean.lastIndexOf('}');
  if (start == -1 || end == -1) throw Exception('JSON 파싱 실패: $clean');
  return clean.substring(start, end + 1);
}
```

**교훈**: 프롬프트로 출력 형식을 통제하면서, 코드에서도 방어적으로 처리하는 이중 방어 전략.

---

### 패턴 13: thinkingBudget 비활성화 — Gemini 2.5 Flash 최적화

Gemini 2.5 시리즈는 기본적으로 thinking(내부 추론) 과정을 거침.
여행 경로 같은 단순 JSON 생성에는 thinking이 불필요하고 응답이 느려짐.

```dart
'generationConfig': {
  'temperature': 0.7,
  'maxOutputTokens': 2048,
  'thinkingConfig': {'thinkingBudget': 0},  // thinking 비활성화
},
```

**왜**: thinkingBudget: 0으로 설정하면 불필요한 추론 생략 → 응답 속도 2~3배 향상.
단, 복잡한 논리 추론이 필요한 작업에서는 끄지 말 것.

---

### 패턴 14: Firebase 없이 로컬 인증 — SharedPreferences 패턴

Firebase Auth 연동에는 google-services.json 설정, SHA-1 등록, 웹 플랫폼 추가 설정이 필요.
데모·발표 목적에서는 SharedPreferences 기반 로컬 인증이 훨씬 빠르게 작동함.

```dart
// 회원 목록: SharedPreferences에 JSON 배열로 저장
static Future<({bool success, String? error})> register(...) async {
  final prefs = await SharedPreferences.getInstance();
  final users = _loadUsers(prefs);  // JSON → List<Map>
  if (users.any((u) => u['email'] == email)) {
    return (success: false, error: '이미 사용 중인 이메일입니다');
  }
  users.add({'name': name, 'email': email, 'password': password});
  await prefs.setString(_usersKey, jsonEncode(users));
  ...
}
```

**장점**: 외부 서비스 의존 없이 즉시 동작. 웹/앱 모두 작동.
**한계**: 비밀번호가 평문으로 저장되므로 실제 출시 앱에는 사용 금지.
발표 데모 환경에서만 허용되는 패턴임.

---

## 2. 실수 & 학습

### 실수: Gemini 2.5-pro → thinkingConfig 충돌로 응답 실패

- **상황**: `gemini-2.5-pro` 모델로 `thinkingConfig: {thinkingBudget: 0}` 설정 → API 400 오류.
- **원인**: 2.5-pro는 thinking을 완전히 끄는 것을 지원하지 않음 (최솟값이 0보다 큼).
- **해결**: `gemini-2.5-flash`로 모델 변경 → thinkingBudget: 0 정상 작동.
- **교훈**: 모델별 generationConfig 지원 범위가 다름. Flash 계열이 파라미터 유연성이 더 높음.

---

### 실수: 단위 테스트에서 실제 API 호출 시도

- **상황**: `GeminiService.generateTripPlan()`을 단위 테스트에서 직접 호출 → API 키 누락으로 실패.
- **원인**: `config.dart`의 API 키가 테스트 환경에서 빈 문자열.
- **해결**: `MockTripData.generate()`를 이용한 단위 테스트로 전환.
  GeminiService 자체는 통합 테스트(실기기·에뮬레이터)로 검증.
- **교훈**: 단위 테스트는 외부 API를 호출하면 안 됨. mock 레이어와 실제 서비스 레이어를 분리한 이유가 여기에 있음.

---

## 3. 아키텍처 결정 — 인증 방식 선택

### 결정: Firebase Auth 대신 SharedPreferences 로컬 인증 (데모 전용)

| 기준 | Firebase Auth | SharedPreferences |
|---|---|---|
| 설정 복잡도 | 높음 (google-services, SHA-1) | 없음 |
| 실제 출시 가능 | ✅ | ❌ (평문 비밀번호) |
| 발표 데모 | 설정 오류 위험 | 즉시 동작 |
| 웹 지원 | 추가 설정 필요 | 기본 지원 |

**결론**: 기말 발표까지는 SharedPreferences 로컬 인증 유지.
추후 Firestore 연동 시 Auth도 Firebase로 마이그레이션할 것.

---

## 4. 누적 패턴 현황 (13주차 기준)

| 주차 | 패턴 번호 | 주제 |
|------|-----------|------|
| 10주차 | 1~3 | 조건 정의, 선택형 질문, 문서 참조 |
| 11주차 | 4~7 | md 파일 분석, 현황 파악, 빌드 검증, git add 범위 |
| 12주차 | 8~10 | 메모리 기반 재개, 도메인 모델 분리, 빌드 검증 포함 |
| 13주차 | 11~14 | JSON 강제, 방어적 파싱, thinkingBudget, 로컬 인증 |

총 **14개 패턴** 누적 (LLM Wiki 가산점 기준 10개 초과)
