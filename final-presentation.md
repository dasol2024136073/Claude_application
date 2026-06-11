---
marp: true
theme: default
paginate: true
size: 16:9
transition: fade
style: |
  section {
    font-family: 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif;
    background: #ffffff;
    color: #0f172a;
    padding: 48px 68px;
    font-size: 19px;
  }
  h1 { font-size: 2.3em; font-weight: 800; color: #0f172a; margin-bottom: 10px; }
  h2 { font-size: 1.45em; font-weight: 700; color: #1e3a8a;
       border-bottom: 3px solid #3b82f6; padding-bottom: 8px; margin-bottom: 22px; }
  h3 { font-size: 1.05em; font-weight: 600; color: #334155; margin-bottom: 6px; }
  p  { line-height: 1.6; }
  ul { padding-left: 1.2em; }
  li { margin-bottom: 5px; line-height: 1.5; }
  table { width: 100%; border-collapse: collapse; font-size: 0.8em; }
  th { background: #1e3a8a; color: #ffffff; padding: 8px 14px; text-align: left; }
  td { padding: 7px 14px; border-bottom: 1px solid #e2e8f0; color: #1e3a8a; }
  tr:nth-child(even) td { background: #f8fafc; }
  blockquote {
    border-left: 4px solid #3b82f6;
    background: #eff6ff;
    color: #1e3a8a;
    padding: 12px 20px;
    border-radius: 0 8px 8px 0;
    margin: 16px 0;
    font-style: normal;
  }
  strong { color: #1e3a8a; }

  /* === 표지 / 마무리 === */
  section.cover { background: #0f172a; color: #ffffff; justify-content: center; }
  section.cover h1 { color: #ffffff; font-size: 2.8em; }
  section.cover p  { color: #94a3b8; font-size: 1.1em; margin-top: 8px; }
  section.cover .sub { color: #60a5fa; font-size: 1.05em; }
  section.end { background: #0f172a; color: #ffffff; justify-content: center; text-align: center; }
  section.end h2 { border: none; color: #60a5fa; }
  section.qa { background: #1e3a8a; color: #ffffff; }
  section.qa h2 { color: #ffffff; border-color: #60a5fa; }
  section.qa li, section.qa p { color: #e2e8f0; }
  section.qa strong { color: #93c5fd; }

  /* === 뱃지 (기술 스택, 가산점) === */
  .badges { display: flex; flex-wrap: wrap; gap: 10px; margin: 14px 0; }
  .badge {
    display: inline-block; padding: 8px 18px; border-radius: 999px;
    background: #eff6ff; border: 2px solid #3b82f6; color: #1e3a8a;
    font-weight: 700; font-size: 0.95em;
  }
  .badge.alt { background: #ecfdf5; border-color: #10b981; color: #065f46; }
  .badge.warn { background: #fff7ed; border-color: #f97316; color: #9a3412; }

  /* === 표 안의 작은 기술 태그 (WBS) === */
  .tag {
    display: inline-block; padding: 2px 10px; border-radius: 999px;
    background: #eff6ff; border: 1px solid #3b82f6; color: #1e3a8a;
    font-weight: 700; font-size: 0.85em; margin: 1px 3px 1px 0;
  }
  .tag.alt { background: #ecfdf5; border-color: #10b981; color: #065f46; }
  .tag.warn { background: #fff7ed; border-color: #f97316; color: #9a3412; }

  /* === 카드 그리드 (문제정의, 핵심기능) === */
  .cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 16px; }
  .card {
    border: 2px solid #e2e8f0; border-radius: 14px; padding: 16px 18px;
    background: #f8fafc;
  }
  .card .icon { font-size: 2em; margin-bottom: 6px; }
  .card h3 { color: #1e3a8a; margin-bottom: 6px; }
  .card.bad { border-color: #fecaca; background: #fef2f2; }
  .card.good { border-color: #bbf7d0; background: #f0fdf4; }

  /* === 타임라인 (진행과정) === */
  .timeline { display: flex; justify-content: space-between; margin: 28px 0 8px; position: relative; }
  .timeline::before {
    content: ''; position: absolute; top: 14px; left: 4%; right: 4%;
    height: 4px; background: #bfdbfe; z-index: 0;
  }
  .tl-item { flex: 1; text-align: center; position: relative; z-index: 1; }
  .tl-dot {
    width: 30px; height: 30px; border-radius: 50%; background: #3b82f6; color: #fff;
    display: flex; align-items: center; justify-content: center; margin: 0 auto 8px;
    font-weight: 800; font-size: 0.85em; border: 4px solid #ffffff; box-shadow: 0 0 0 2px #3b82f6;
  }
  .tl-item.done .tl-dot { background: #10b981; box-shadow: 0 0 0 2px #10b981; }
  .tl-label { font-size: 0.85em; font-weight: 700; color: #1e3a8a; }
  .tl-sub { font-size: 0.75em; color: #64748b; margin-top: 2px; }

  /* === 레이어 다이어그램 (아키텍처) === */
  .layers { display: flex; flex-direction: column; gap: 10px; margin-top: 16px; }
  .layer {
    border-radius: 12px; padding: 14px 20px; color: #fff; font-weight: 700;
    display: flex; justify-content: space-between; align-items: center;
  }
  .layer .desc { font-weight: 400; font-size: 0.85em; opacity: 0.9; }
  .layer.l1 { background: #1e3a8a; }
  .layer.l2 { background: #2563eb; }
  .layer.l3 { background: #3b82f6; }
  .layer-arrow { text-align: center; color: #94a3b8; font-size: 1.2em; margin: -4px 0; }

  /* === 아키텍처 슬라이드: 2단 구성 (다이어그램 + 실제 흐름 예시) === */
  .arch-grid { display: flex; gap: 28px; margin-top: 14px; align-items: flex-start; }
  .arch-grid > div { flex: 1; }
  .arch-grid h3 { margin-bottom: 10px; }
  .flow-item { display: flex; gap: 10px; align-items: flex-start; margin-bottom: 10px; }
  .flow-num {
    flex-shrink: 0; width: 26px; height: 26px; border-radius: 50%; color: #fff;
    font-weight: 700; display: flex; align-items: center; justify-content: center; font-size: 0.85em;
  }
  .flow-num.l1 { background: #1e3a8a; }
  .flow-num.l2 { background: #2563eb; }
  .flow-num.l3 { background: #3b82f6; }
  .flow-text { font-size: 0.92em; line-height: 1.5; padding-top: 3px; }
  .flow-text code { background: #eff6ff; padding: 1px 6px; border-radius: 4px; color: #1e3a8a; }

  /* === 체크리스트 === */
  .check-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 24px; margin-top: 12px; }
  .check-item { display: flex; align-items: center; gap: 8px; font-weight: 600; }
  .check-item .mark { color: #10b981; font-size: 1.2em; }

  /* === 데모 강조 === */
  section.demo { background: linear-gradient(135deg, #1e3a8a, #3b82f6); color: #fff; justify-content: center; }
  section.demo h1, section.demo h2 { color: #fff; border: none; }
  section.demo p { color: #dbeafe; }
---

<!-- _class: cover -->
<!-- transition: fade -->

# Tripia
## AI 여행 경로 추천 앱

<br>

**"당신의 발걸음을 AI가 별자리처럼 이어,**
**이 세상 어디에도 없던 하나뿐인 여행을 그려드립니다."**

<br>

<span class="sub">취향 프로필 + 실시간 날씨를 Gemini AI가 분석해 10초 만에 나만의 여행 동선을 설계합니다</span>

<br><br>

**임다솔** · Flutter Web · 2026 기말 발표 (5분)

<!--
[비전 / 0:00~0:15]
안녕하세요, "Tripia"를 만든 임다솔입니다.
저희 앱의 비전은 "당신의 발걸음을 AI가 별자리처럼 이어, 이 세상 어디에도 없던 하나뿐인 여행을 그려드립니다" 입니다.
취향 프로필과 실시간 날씨를 Gemini AI에 전달해서, 10초 만에 나만의 여행 동선을 만들어주는 앱입니다.
-->

---

## 문제 정의 — 여행 계획, 왜 이렇게 피곤할까?

<div class="cards">
<div class="card bad">
<div class="icon">😩</div>
<h3>계획 피로</h3>
여행지·맛집·동선을 검색하느라 수십 개의 탭을 열어야 한다
</div>
<div class="card bad">
<div class="icon">📋</div>
<h3>획일적 추천</h3>
블로그·유튜브는 모두에게 같은 코스를 추천한다
</div>
<div class="card bad">
<div class="icon">🌧️</div>
<h3>상황 대응 불가</h3>
갑자기 비가 오면 처음부터 다시 검색해야 한다
</div>
</div>

<br>

> 누구나 한 번쯤, 여행 가기도 전에 계획 짜다가 지쳐본 경험 있으시죠?
> **Tripia는 이 세 가지 문제를 "AI + 실시간 데이터"로 해결합니다.**

<!--
[문제정의 / 0:15~0:35]
여행 계획, 왜 이렇게 피곤할까요? 세 가지 문제가 있습니다.
첫째, 계획 피로 — 여행지, 맛집, 동선을 찾느라 수십 개 탭을 열게 됩니다.
둘째, 획일적 추천 — 블로그나 유튜브는 모두에게 똑같은 코스를 추천합니다.
셋째, 상황 대응 불가 — 갑자기 비가 오면 처음부터 다시 짜야 합니다.
저도 여행 가기 전에 계획 짜다가 지친 경험이 있는데요, Tripia는 이 세 가지를 AI와 실시간 데이터로 해결합니다.
-->

---

## 프로젝트 계획 — WBS & 기술 스택

<div class="badges">
<span class="badge">Flutter Web</span>
<span class="badge">Dart 3.x</span>
<span class="badge">GoRouter 14</span>
<span class="badge">Gemini 2.5 Flash</span>
<span class="badge">OpenWeatherMap</span>
<span class="badge">flutter_map + OSM</span>
<span class="badge">SharedPreferences</span>
</div>

| 모듈 (WBS) | 산출물 | 사용 기술 | 상태 |
|---|---|---|---|
| 1. 인증 모듈 | 로그인/회원가입/마이페이지 | <span class="tag">SharedPreferences</span><span class="tag">GoRouter</span> | ✅ 완료 |
| 2. AI 경로 추천 모듈 | 입력 → Gemini 생성 → 결과 화면 | <span class="tag alt">Gemini 2.5 Flash</span><span class="tag">Dio</span> | ✅ 완료 |
| 3. 실시간 상황 반영 | 날씨 연동 + 변화 감지 알림 | <span class="tag warn">OpenWeatherMap</span><span class="tag">Timer</span> | ✅ 완료 |
| 4. 지도 모듈 | flutter_map 경로 시각화 | <span class="tag">flutter_map</span><span class="tag">OSM</span> | ✅ 완료 |
| 5. 마이페이지 모듈 | 경로 저장/조회/삭제, 프로필 | <span class="tag">SharedPreferences</span><span class="tag">GoRouter</span> | ✅ 완료 |
| 6. 문서·QA | 38개 테스트, ADR 4개, docs 5종 | <span class="tag">flutter_test</span><span class="tag alt">Marp CI</span> | ✅ 완료 |

<!--
[프로젝트계획 / 0:35~1:00]
기술 스택은 Flutter Web, Dart, GoRouter, Gemini 2.5 Flash, OpenWeatherMap, flutter_map, SharedPreferences입니다.
WBS 기준으로 인증, AI 경로 추천, 실시간 상황 반영, 지도, 마이페이지, 문서·QA까지 총 6개 모듈을 모두 완료했고, 각 모듈에 사용한 핵심 기술을 표에 함께 정리했습니다.
원래 36개 산출물 중 7주 일정에 맞게 핵심 기능 위주로 재설계해서 진행했습니다.
-->

---

## 프로젝트 진행 과정 (9주차 ~ 15주차)

<div class="timeline">
<div class="tl-item done"><div class="tl-dot">9</div><div class="tl-label">기획</div><div class="tl-sub">비전·요구사항·WBS·ADR</div></div>
<div class="tl-item done"><div class="tl-dot">11</div><div class="tl-label">설계</div><div class="tl-sub">아키텍처·중간발표</div></div>
<div class="tl-item done"><div class="tl-dot">12</div><div class="tl-label">핵심구현</div><div class="tl-sub">화면 7개·라우팅</div></div>
<div class="tl-item done"><div class="tl-dot">13</div><div class="tl-label">AI연동</div><div class="tl-sub">Gemini·인증·테스트</div></div>
<div class="tl-item done"><div class="tl-dot">14</div><div class="tl-label">실시간기능</div><div class="tl-sub">날씨·지도·저장</div></div>
<div class="tl-item done"><div class="tl-dot">15</div><div class="tl-label">마감</div><div class="tl-sub">문서화·배포·발표</div></div>
</div>

<div class="check-grid" style="margin-top: 28px;">
<div class="check-item"><span class="mark">✅</span> Must + Should 기능 전체 동작</div>
<div class="check-item"><span class="mark">✅</span> 단위·통합 테스트 38개 전부 통과</div>
<div class="check-item"><span class="mark">✅</span> ADR 4개 + docs 5종 작성</div>
<div class="check-item"><span class="mark">✅</span> Flutter Web 빌드/배포 파이프라인</div>
</div>

<!--
[진행과정 / 1:00~1:20]
9주차 기획부터 15주차 마감까지, Must와 Should 기능을 모두 동작 상태로 완성했습니다.
9주차에 비전·요구사항·WBS·ADR을 작성했고, 12~14주차에 핵심 화면과 Gemini 연동, 날씨·지도 기능을 구현했습니다.
현재 단위·통합 테스트 38개 전부 통과, ADR 4개와 문서 5종을 모두 갖춘 상태입니다.
-->

---

## 구현 방법 — 아키텍처 & 앱 구조

<div class="arch-grid">

<div>

<div class="layers">
<div class="layer l1">Presentation <span class="desc">9개 화면 · StatefulWidget</span></div>
<div class="layer-arrow">↓ 직접 호출</div>
<div class="layer l3">Data <span class="desc">Service 4종 · static 메서드</span></div>
<div class="layer-arrow">↓ 모델로 변환</div>
<div class="layer l2">Domain <span class="desc">TripPlan · DayPlan · PlaceItem</span></div>
</div>

<div class="badges" style="margin-top: 14px;">
<span class="badge alt">Application 레이어 없음</span>
</div>

</div>

<div>

### 예시: "제주 2박3일" 검색 흐름

<div class="flow-item"><div class="flow-num l1">1</div><div class="flow-text"><code>RouteInputScreen</code>에서 목적지·기간 입력</div></div>
<div class="flow-item"><div class="flow-num l3">2</div><div class="flow-text"><code>GeminiService.generateTrip()</code> 호출 → JSON 응답 수신</div></div>
<div class="flow-item"><div class="flow-num l2">3</div><div class="flow-text">응답을 <code>TripPlan/DayPlan/PlaceItem</code>으로 파싱</div></div>
<div class="flow-item"><div class="flow-num l1">4</div><div class="flow-text"><code>RouteResultScreen</code>이 TripPlan을 받아 일정 렌더링</div></div>
<div class="flow-item"><div class="flow-num l3">5</div><div class="flow-text"><code>TripRepository</code>로 SharedPreferences에 저장</div></div>

</div>

</div>

<br>

GoRouter 8개 경로로 화면 전환 (`/`, `/home`, `/route/input`, `/route/result`, `/route/map`, `/weather`, `/mypage` ...)

<!--
[구현방법-아키텍처 / 1:20~1:45]
아키텍처는 3계층입니다. Presentation은 9개 화면, Data는 4개 Service(static 메서드), Domain은 TripPlan/DayPlan/PlaceItem 모델입니다.
원래 계획에는 Application 레이어가 있었지만, 화면이 서비스를 직접 호출하는 구조로 단순화했습니다.
오른쪽 예시처럼, 사용자가 "제주 2박3일"을 입력하면 RouteInputScreen이 GeminiService를 호출하고,
응답을 TripPlan 모델로 파싱한 뒤 RouteResultScreen에서 보여주고 TripRepository로 저장하는 흐름입니다.
GoRouter로 8개 경로를 관리합니다.
-->

---

## 구현 방법 — 핵심 기능 3가지

<div class="cards">
<div class="card good">
<div class="icon">🤖</div>
<h3>AI 경로 생성</h3>
취향+날씨 컨텍스트를 Gemini 2.5 Flash에 전달, <code>_extractJson()</code>으로 마크다운 방어 파싱
</div>
<div class="card good">
<div class="icon">🌦️</div>
<h3>실시간 날씨 반영</h3>
OpenWeatherMap → 60+ 도시 매핑 → outdoor/indoor 카테고리 변화 시 재추천 알림
</div>
<div class="card good">
<div class="icon">🗺️</div>
<h3>지도 시각화</h3>
flutter_map + OpenStreetMap, 번호 마커 + 폴리라인으로 동선 표시 (API 키 불필요)
</div>
</div>

<br>

> 세 기능 모두 **API 키 1개(Gemini, OpenWeatherMap)** 만으로 동작 — 발표 데모 환경 이식성 확보

<!--
[구현방법-핵심기능 / 1:45~2:10]
핵심 기능은 세 가지입니다.
첫째, AI 경로 생성 — 취향과 날씨 정보를 Gemini 2.5 Flash에 전달하고, 응답에 마크다운이 섞여도 안전하게 파싱하는 _extractJson 함수를 만들었습니다.
둘째, 실시간 날씨 반영 — OpenWeatherMap에서 60개 이상 도시를 매핑하고, 실내외 카테고리가 바뀌면 재추천 알림을 보냅니다.
셋째, 지도 시각화 — flutter_map과 OpenStreetMap으로 API 키 없이 번호 마커와 폴리라인으로 동선을 보여줍니다.
이 세 기능 모두 API 키 1개씩만 있으면 동작해서, 데모 환경을 옮기기 쉽습니다.
-->

---

## 개발 환경 설정 & 빌드/배포

```bash
# 1. 클론 & 의존성
git clone https://github.com/dasol2024136073/Claude_application.git
cd Claude_application && flutter pub get

# 2. API 키 설정 (lib/core/config.dart 직접 생성, gitignore 처리됨)
const geminiApiKey = '...';
const openWeatherApiKey = '...';

# 3. 실행 (디버그)
flutter run -d chrome

# 4. 릴리스 빌드
flutter build web --release
```

<div class="badges">
<span class="badge alt">버전: SemVer (1.0.0+1)</span>
<span class="badge alt">롤백: git revert + 재배포</span>
<span class="badge warn">자세한 내용: docs/deploy.md</span>
</div>

<!--
[개발환경/빌드배포 / 2:10~2:30]
개발 환경은 docs/setup.md 기준으로, 클론 후 flutter pub get, 그리고 lib/core/config.dart에 API 키 2개만 넣으면 바로 실행됩니다.
빌드는 flutter build web --release로 release 빌드를 만들고,
버전은 SemVer(1.0.0+1) 규칙을 따르며, 문제 발생 시 git revert로 롤백합니다.
자세한 내용은 docs/deploy.md에 정리해뒀습니다.
-->

---

## 구현 시행착오 — "강릉 검색이 안 돼요" 디버깅

<div class="cards" style="grid-template-columns: 1fr 1fr;">
<div class="card bad">
<h3>1차 시도 (실패)</h3>
"강릉 검색하면 안 돼, 고쳐줘" → AI가 Geocoding API로 추측성 교체 → <strong>여전히 실패</strong>
</div>
<div class="card good">
<h3>2차 시도 (성공)</h3>
브라우저 F12 콘솔 로그 추가 → <code>Geocoding result: 0 items</code>, <code>404</code> 확인 → AI에게 증거와 함께 재요청
</div>
</div>

<br>

**원인**: OpenWeatherMap은 영문 도시명 기준 — "서울"은 국제적으로 알려져 되지만 "강릉(Gangneung)"은 매핑이 없어 404
**해결**: `_cityMap`에 국내 30+ 도시 영문명 추가 → AGENTS.md 규칙 R-09로 정착 ("증상이 아닌 로그/증거로 디버깅 요청")

<!--
[구현시행착오 / 2:30~2:55]
구현 시행착오 사례를 하나 소개하면, "강릉 검색이 안 돼요" 버그입니다.
처음에는 "안 된다, 고쳐줘"라고만 요청했더니 AI가 Geocoding API로 추측성 수정을 했는데도 안 됐습니다.
그래서 브라우저 개발자도구 콘솔에 로그를 추가해서, Geocoding 결과 0개, 404 에러를 직접 확인했습니다.
원인은 OpenWeatherMap이 영문 도시명 기준이라 "서울"은 되지만 "강릉"은 매핑이 없어서였습니다.
국내 30개 이상 도시의 영문명을 매핑 테이블에 추가해서 해결했고, 이 경험을 "증거 기반 디버깅 요청" 규칙으로 AGENTS.md에 정착시켰습니다.
-->

---

## 코드 품질 · 테스트 · 성능 최적화

<div class="badges">
<span class="badge alt">flutter analyze 경고 0개</span>
<span class="badge alt">테스트 38개 전부 통과</span>
<span class="badge">thinkingBudget: 0</span>
<span class="badge">5초 후 즉시 날씨 체크</span>
</div>

| 테스트 종류 | 개수 | 내용 |
|---|---|---|
| Widget (UI) | 4 | LoginScreen 렌더링 |
| Unit | 13 | 도메인 모델·MockTripData |
| Debug (경계값) | 7 | 예외 케이스 |
| Scenario (통합) | 6 | 사용자 시나리오 |
| Integration | 8 | Data ↔ Domain 연동 |

- **성능**: Gemini `thinkingBudget: 0` 설정으로 응답 속도 최적화 (모델은 `gemini-2.5-pro`→`flash`로 변경, ADR 사례)
- **성능**: 날씨 변화 감지는 30분 주기지만, 데모를 위해 "5초 후 즉시 1회 체크" 추가

<!--
[코드품질/테스트/성능 / 2:55~3:15]
코드 품질은 flutter analyze 경고 0개를 유지하고, 테스트는 위젯 4개, 단위 13개, 경계값 7개, 시나리오 6개, 통합 8개로 총 38개 전부 통과합니다.
성능 최적화로는 Gemini 모델을 pro에서 flash로 바꾸고 thinkingBudget을 0으로 설정해서 응답 속도를 높였고,
날씨 변화 감지는 원래 30분 주기지만 데모에서는 5초 후 즉시 한 번 체크하도록 추가했습니다.
-->

---

## ADR 요약 (질의응답 대비, 4개)

| ADR | 결정 | 핵심 이유 |
|---|---|---|
| **ADR-0001** | 모바일 프레임워크 → **Flutter** | 단일 코드베이스로 iOS/Android/Web 동시 지원 |
| **ADR-0002** | 상태관리 → Riverpod (계획) | 비동기 상태 多, 타입 안전성 |
| **ADR-0003** | 백엔드 → Firebase (계획) | MVP 기간 내 인프라 구축 최소화 |
| **ADR-0004** | **피벗**: Riverpod/Firebase → **StatefulWidget/SharedPreferences** | 1인·7주 일정 재평가, 화면 7~9개 규모엔 과한 설정 비용 |

<br>

> **핵심 메시지**: 계획(ADR-0002/3)을 그대로 밀어붙이지 않고, 일정·규모를 재평가해 **ADR-0004로 의도적으로 피벗**했습니다.
> 저장 구조는 Firestore 호환 형태로 설계해 향후 마이그레이션이 가능합니다.

<!--
[ADR요약 / 3:15~3:35]
질의응답 대비 ADR은 총 4개입니다.
ADR-0001은 Flutter 선택, ADR-0002는 계획 단계의 Riverpod, ADR-0003은 계획 단계의 Firebase였습니다.
그런데 12주차 구현 시작 시점에 1인 개발과 7주 일정을 재평가해서, ADR-0004로 StatefulWidget과 SharedPreferences로 피벗했습니다.
중요한 건 계획을 무작정 따르지 않고, 일정과 규모에 맞게 의도적으로 피벗한 결정이라는 점이고, 저장 구조는 Firestore와 호환되게 설계했습니다.
-->

---

## 활용 방안 & 기대 효과 + GitHub 가이드

**활용 시나리오**: 주말 당일치기 직장인이 "수원 1박 2일" 입력 → 10초 내 일정 생성 → 비 예보 시 실내 코스로 자동 재추천

| 목표 지표 (비전 문서 기준) | 의미 |
|---|---|
| 추천 경로 저장률 ≥ 60% | 추천 품질에 대한 신뢰 |
| 첫 추천 제공 시간 ≤ 10초 | Gemini Flash + 단순 아키텍처로 달성 |

<div class="badges">
<span class="badge">README.md — 5분 안에 이해</span>
<span class="badge">docs/setup.md — 실행 가이드</span>
<span class="badge">AGENTS.md — AI Agent 컨텍스트</span>
</div>

GitHub: `github.com/dasol2024136073/Claude_application` — README → setup → architecture → deploy → testing 순서로 확인 가능

<!--
[활용방안/GitHub가이드 / 3:35~3:55]
활용 시나리오는, 주말에 당일치기를 가는 직장인이 "수원 1박 2일"을 입력하면 10초 안에 일정을 받고,
비 예보가 있으면 실내 코스로 자동 재추천 받는 식입니다.
비전 문서의 목표 지표인 추천 경로 저장률 60% 이상, 첫 추천 10초 이내도 Gemini Flash와 단순한 아키텍처로 달성 가능한 구조입니다.
GitHub 저장소에는 README, setup, architecture, deploy, testing 문서가 순서대로 정리되어 있어서 누구나 5분 안에 설치하고 실행할 수 있습니다.
-->

---

## 가산점 어필 — AI Agent 활용 방법론

<div class="badges">
<span class="badge">+1 AI Agent 적극 활용</span>
<span class="badge alt">+2 AUTHORING.md (본인만의 기법)</span>
<span class="badge warn">+1 LLM Wiki 암묵지</span>
</div>

- **AUTHORING.임다솔.v0.4.0.md**: Skills(`/plan`, `/debug-log`, `/simplify-terms`) + Rules(R-01~R-10) + Commands를 1개 md로 통합 운영
- 핵심 규칙 예: "AI 출력은 반드시 읽고 commit", "증상이 아닌 로그/증거로 버그 수정 요청"
- **notes/week10~13-llm-wiki.md**: 프롬프트 패턴 20개, 실패 사례 누적 기록

<!--
[가산점어필 / 3:55~4:10]
가산점 항목도 간단히 말씀드리면, AI Agent를 기획부터 코드, 문서까지 전 과정에 활용했고,
AUTHORING.임다솔.v0.4.0.md 한 파일에 Skills, Rules, Commands를 통합해서 운영했습니다.
"AI 출력은 반드시 읽고 commit한다", "증상이 아니라 로그와 증거로 버그 수정을 요청한다" 같은 규칙들이 실제로 강릉 버그 해결에 적용됐습니다.
또 notes 폴더에 LLM Wiki로 프롬프트 패턴 20개와 실패 사례를 누적 기록했습니다.
-->

---

<!-- _class: demo -->
<!-- transition: wipe-left -->

# 🎬 시연 데모 (30초)

### 사용자 시나리오: "제주 2박 3일, 비 오면 실내로"

1. 로그인 → 홈 (현재 위치 날씨 카드)
2. "제주 / 2박 3일" 입력 → **Gemini가 10초 내 일정 생성**
3. 결과 화면 → 지도에서 동선 확인
4. 날씨 변화 알림 → 실내 코스 재추천

<!--
[시연데모 / 4:10~4:40]
지금부터 30초간 실제 데모를 보여드리겠습니다.
시나리오는 "제주 2박 3일, 비 오면 실내로"입니다.
로그인 후 홈 화면에서 현재 위치 날씨를 보여주고, 제주 2박 3일을 입력하면 Gemini가 10초 안에 일정을 만들어줍니다.
결과 화면에서 지도로 동선을 확인하고, 날씨가 바뀌면 실내 코스로 재추천하는 알림까지 보여드리겠습니다.
-->

---

<!-- _class: end -->

# 마무리 & 향후 발전 방향

<div class="badges" style="justify-content: center;">
<span class="badge">Firebase Auth 전환</span>
<span class="badge alt">커뮤니티 공유 기능</span>
<span class="badge warn">다국어 지원</span>
</div>

<br>

**Tripia**는 7주 동안 1인 개발로 Must+Should 기능을 모두 완성했습니다.
다음 단계는 ADR-0004에서 의도적으로 미룬 **Firebase Auth 전환**, 그리고 **커뮤니티 경로 공유** 기능입니다.

<br>

### 감사합니다 — Q&A

<!--
[마무리 / 4:40~5:00]
정리하면, Tripia는 7주 동안 1인 개발로 Must와 Should 기능을 모두 완성했습니다.
다음 단계는 ADR-0004에서 의도적으로 미뤄둔 Firebase Auth 전환, 그리고 커뮤니티 경로 공유 기능입니다.
여기까지 발표 마치겠습니다. 감사합니다.
-->
