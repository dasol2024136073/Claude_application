---
marp: true
theme: default
paginate: true
size: 16:9
transition: fade
style: |
  section {
    font-family: 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif;
    background:
      linear-gradient(#d3e8da, #d3e8da) top left / 100% 16px no-repeat,
      linear-gradient(#d3e8da, #d3e8da) bottom left / 100% 16px no-repeat,
      #ffffff;
    color: #0f172a;
    padding: 48px 68px;
    font-size: 23px;
  }
  h1 { font-size: 2.3em; font-weight: 800; color: #0f172a; margin-bottom: 10px; }
  h2 { font-size: 1.45em; font-weight: 700; color: #4a6b52;
       border-bottom: 3px solid #7eab8f; padding-bottom: 8px; margin-bottom: 22px; }
  h3 { font-size: 1.05em; font-weight: 600; color: #334155; margin-bottom: 6px; }
  p  { line-height: 1.6; }
  ul { padding-left: 1.2em; }
  li { margin-bottom: 5px; line-height: 1.5; }
  table { width: 100%; border-collapse: collapse; font-size: 0.8em; }
  th { background: #4a6b52; color: #ffffff; padding: 8px 14px; text-align: left; }
  td { padding: 7px 14px; border-bottom: 1px solid #e2e8f0; color: #4a6b52; }
  tr:nth-child(even) td { background: #f8fafc; }
  blockquote {
    border-left: 4px solid #7eab8f;
    background: #f2f7f4;
    color: #4a6b52;
    padding: 12px 20px;
    border-radius: 0 8px 8px 0;
    margin: 16px 0;
    font-style: normal;
  }
  strong { color: #4a6b52; }

  /* === 알약 배지 (전체 톤) === */
  .kicker {
    display: inline-block; background: #0f172a; color: #fff;
    font-weight: 800; letter-spacing: 0.12em; font-size: 0.75em;
    text-transform: uppercase; padding: 8px 24px; border-radius: 999px;
    margin-bottom: 14px;
  }

  /* === 표지 / 마무리 === */
  section.cover { color: #0f172a; justify-content: center; }
  section.cover h1 { color: #0f172a; font-size: 3.4em; font-weight: 900; }
  section.cover h2 { border: none; color: #4a6b52; font-size: 1.3em; margin-bottom: 14px; font-weight: 700; }
  section.cover p  { color: #475569; font-size: 1.1em; margin-top: 8px; }
  section.cover .sub { color: #4a6b52; font-size: 1.05em; font-weight: 700; }
  .author-tag { display: inline-flex; align-items: center; gap: 10px; font-weight: 700; font-size: 0.95em; color: #0f172a; }
  .author-tag .dot {
    width: 34px; height: 34px; border-radius: 50%; background: #4a6b52; color: #fff;
    display: flex; align-items: center; justify-content: center; font-size: 1.1em; flex-shrink: 0;
  }
  .title-icon {
    display: inline-flex; align-items: center; justify-content: center;
    width: 0.85em; height: 0.85em; border-radius: 50%; background: #4a6b52; color: #fff;
    font-size: 0.55em; vertical-align: middle; margin-left: 14px;
  }
  section.end { color: #0f172a; justify-content: center; text-align: center; }
  section.end h2 { border: none; color: #4a6b52; font-size: 2em; }
  section.qa { background: #4a6b52; color: #ffffff; }
  section.qa h2 { color: #ffffff; border-color: #a3c9b2; }
  section.qa li, section.qa p { color: #e2e8f0; }
  section.qa strong { color: #c2ddcb; }

  /* === 큰 챕터 번호 (제목 앞 강조) === */
  .chnum { font-size: 1.3em; font-weight: 900; color: #0f172a; margin-right: 14px; }

  /* === 세로 구분선 컬럼 === */
  .col-grid { display: flex; gap: 0; margin-top: 24px; width: 100%; box-sizing: border-box; }
  .col-grid > div { flex: 1; padding: 4px 28px; text-align: center; }
  .col-grid > div:not(:first-child) { border-left: 1px solid #cbd5e1; }
  .col-grid .icon { font-size: 2.4em; margin-bottom: 10px; }
  .col-grid h3 { font-size: 1.1em; margin-bottom: 8px; text-align: center; }
  .col-grid p { font-size: 0.88em; color: #475569; line-height: 1.5; margin: 0; }

  /* === 뱃지 (기술 스택, 가산점) === */
  .badges { display: flex; flex-wrap: wrap; gap: 10px; margin: 14px 0; }
  .badges.center { justify-content: center; width: 100%; box-sizing: border-box; align-self: stretch; }
  .badge {
    display: inline-block; padding: 8px 18px; border-radius: 999px;
    background: #f2f7f4; border: 2px solid #7eab8f; color: #4a6b52;
    font-weight: 700; font-size: 0.95em;
  }
  .badge.alt { background: #ecfdf5; border-color: #10b981; color: #065f46; }
  .badge.warn { background: #fff7ed; border-color: #f97316; color: #9a3412; }

  /* === 표 안의 작은 기술 태그 (WBS) === */
  .tag {
    display: inline-block; padding: 2px 10px; border-radius: 999px;
    background: #f2f7f4; border: 1px solid #7eab8f; color: #4a6b52;
    font-weight: 700; font-size: 0.85em; margin: 1px 3px 1px 0;
  }
  .tag.alt { background: #ecfdf5; border-color: #10b981; color: #065f46; }
  .tag.warn { background: #fff7ed; border-color: #f97316; color: #9a3412; }

  /* === 카드 그리드 (문제정의, 핵심기능) === */
  .cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 16px; width: 100%; box-sizing: border-box; }
  .card {
    border: 2px solid #e2e8f0; border-radius: 14px; padding: 16px 18px;
    background: #f8fafc;
  }
  .card .icon { font-size: 2em; margin-bottom: 6px; }
  .card h3 { color: #4a6b52; margin-bottom: 6px; }
  .card.bad { border-color: #fecaca; background: #fef2f2; }
  .card.good { border-color: #d3e8da; background: #f2f7f4; }
  .cards.compact { margin: 8px 0 14px; }
  .cards.compact .card { padding: 6px 18px; }
  .cards.compact ~ table th,
  .cards.compact ~ table td { padding: 4px 14px; }

  /* === 타임라인 (진행과정) === */
  .timeline { display: flex; justify-content: space-between; margin: 28px 0 8px; position: relative; }
  .timeline::before {
    content: ''; position: absolute; top: 14px; left: 4%; right: 4%;
    height: 4px; background: #d3e8da; z-index: 0;
  }
  .tl-item { flex: 1; text-align: center; position: relative; z-index: 1; }
  .tl-dot {
    width: 30px; height: 30px; border-radius: 50%; background: #7eab8f; color: #fff;
    display: flex; align-items: center; justify-content: center; margin: 0 auto 8px;
    font-weight: 800; font-size: 0.85em; border: 4px solid #ffffff; box-shadow: 0 0 0 2px #7eab8f;
  }
  .tl-item.done .tl-dot { background: #10b981; box-shadow: 0 0 0 2px #10b981; }
  .tl-label { font-size: 0.85em; font-weight: 700; color: #4a6b52; }
  .tl-sub { font-size: 0.75em; color: #64748b; margin-top: 2px; }

  /* === 레이어 다이어그램 (아키텍처) === */
  .layers { display: flex; flex-direction: column; gap: 10px; margin-top: 16px; }
  .layer {
    border-radius: 12px; padding: 14px 20px; color: #fff; font-weight: 700;
    display: flex; justify-content: space-between; align-items: center;
  }
  .layer .desc { font-weight: 400; font-size: 0.85em; opacity: 0.9; }
  .layer.l1 { background: #4a6b52; }
  .layer.l2 { background: #5f8a6f; }
  .layer.l3 { background: #7eab8f; }
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
  .flow-num.l1 { background: #4a6b52; }
  .flow-num.l2 { background: #5f8a6f; }
  .flow-num.l3 { background: #7eab8f; }
  .flow-text { font-size: 0.92em; line-height: 1.5; padding-top: 3px; }
  .flow-text code { background: #f2f7f4; padding: 1px 6px; border-radius: 4px; color: #4a6b52; }

  /* === 테스트 구성 막대 + 범례 (코드품질 슬라이드) === */
  .test-bar { display: table; width: 100%; table-layout: fixed; border-spacing: 0; height: 34px; border-radius: 8px; overflow: hidden; margin: 14px 0 12px; }
  .test-bar .seg { display: table-cell; text-align: center; vertical-align: middle; color: #fff; font-weight: 700; font-size: 0.85em; }
  .test-bar .seg.t1 { background: #4a6b52; }
  .test-bar .seg.t2 { background: #5f8a6f; }
  .test-bar .seg.t3 { background: #7eab8f; }
  .test-bar .seg.t4 { background: #a3c9b2; }
  .test-bar .seg.t5 { background: #c2ddcb; color: #4a6b52; }
  .legend-item { display: flex; align-items: center; gap: 8px; font-size: 0.85em; margin-bottom: 6px; }
  .legend-dot { width: 14px; height: 14px; border-radius: 4px; flex-shrink: 0; }
  .legend-dot.t1 { background: #4a6b52; }
  .legend-dot.t2 { background: #5f8a6f; }
  .legend-dot.t3 { background: #7eab8f; }
  .legend-dot.t4 { background: #a3c9b2; }
  .legend-dot.t5 { background: #c2ddcb; }

  /* === 체크리스트 === */
  .check-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 24px; margin-top: 12px; }
  .check-item { display: flex; align-items: center; gap: 8px; font-weight: 600; }
  .check-item .mark { color: #10b981; font-size: 1.2em; }

  /* === 데모 강조 === */
  section.demo { background: linear-gradient(135deg, #e6f1ea, #d3e8da); color: #33503c; justify-content: center; }
  section.demo h1, section.demo h2 { color: #33503c; border: none; }
  section.demo p { color: #4a6b52; }

  /* === 본문 글씨 검은색 (제목/표 헤더 제외) === */
  section.mono-text td,
  section.mono-text strong,
  section.mono-text blockquote,
  section.mono-text .badge,
  section.mono-text .badge.alt,
  section.mono-text .badge.warn,
  section.mono-text .tag,
  section.mono-text .tag.alt,
  section.mono-text .tag.warn,
  section.mono-text .card h3,
  section.mono-text.demo p,
  section.mono-text.demo li,
  section.mono-text.demo h3,
  section.mono-text.demo strong { color: #0f172a; }
---

<!-- _class: cover -->
<!-- transition: fade -->

<span class="kicker">AI Travel Planner</span>

# Tripia <span class="title-icon">✈️</span>
## AI 여행 경로 추천 앱

<br>

**"당신의 발걸음을 AI가 별자리처럼 이어,**
**이 세상 어디에도 없던 하나뿐인 여행을 그려드립니다."**

<br>

<span class="sub">취향 프로필 + 실시간 날씨를 Gemini AI가 분석해 10초 만에 나만의 여행 동선을 설계합니다</span>

<div style="margin-top: 40px;">
<div class="author-tag"><div class="dot">📘</div>임다솔 · Flutter Web · 2026 기말 발표 (5분)</div>
</div>

<!--
[비전 / 0:00~0:15]
안녕하세요, "Tripia"를 만든 임다솔입니다.
저희 앱의 비전은 "당신의 발걸음을 AI가 별자리처럼 이어, 이 세상 어디에도 없던 하나뿐인 여행을 그려드립니다" 입니다.
취향 프로필과 실시간 날씨를 Gemini AI에 전달해서, 10초 만에 나만의 여행 동선을 만들어주는 앱입니다.
-->

---

## <span class="chnum">01</span> 문제 정의 — 여행 계획, 왜 이렇게 피곤할까?

<div class="col-grid">
<div>
<div class="icon">😩</div>
<h3>계획 피로</h3>
<p>여행지·맛집·동선을 검색하느라 수십 개의 탭을 열어야 한다</p>
</div>
<div>
<div class="icon">📋</div>
<h3>획일적 추천</h3>
<p>블로그·유튜브는 모두에게 같은 코스를 추천한다</p>
</div>
<div>
<div class="icon">🌧️</div>
<h3>상황 대응 불가</h3>
<p>갑자기 비가 오면 처음부터 다시 검색해야 한다</p>
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

<!-- _class: mono-text -->

## 프로젝트 계획 — WBS & 기술 스택

<div class="badges">
<span class="badge">Flutter Web</span>
<span class="badge">Dart 3.x</span>
<span class="badge">GoRouter 14</span>
<span class="badge">Gemini 2.5 Flash</span>
<span class="badge">OpenWeatherMap</span>
<span class="badge">Unsplash API</span>
<span class="badge">flutter_map + OSM</span>
<span class="badge">SharedPreferences</span>
</div>

| 모듈 (WBS) | 산출물 | 사용 기술 | 상태 |
|---|---|---|---|
| 1. 인증 모듈 | 로그인/회원가입/마이페이지 | <span class="tag">SharedPreferences</span><span class="tag">GoRouter</span> | ✅ 완료 |
| 2. AI 경로 추천 모듈 | 입력 → Gemini 생성 → 결과 화면 + 취향 기반 개인화 추천(캐싱) | <span class="tag alt">Gemini 2.5 Flash</span><span class="tag">Dio</span><span class="tag alt">Unsplash</span> | ✅ 완료 |
| 3. 실시간 상황 반영 | 날씨 연동 + "다시 확인" 시 재추천 | <span class="tag warn">OpenWeatherMap</span> | ✅ 완료 |
| 4. 지도 모듈 | flutter_map 경로 시각화 | <span class="tag">flutter_map</span><span class="tag">OSM</span> | ✅ 완료 |
| 5. 마이페이지 모듈 | 경로 저장/조회/삭제, 프로필 | <span class="tag">SharedPreferences</span><span class="tag">GoRouter</span> | ✅ 완료 |
| 6. 커뮤니티 모듈 | 게시글/댓글/좋아요/북마크 | <span class="tag">SharedPreferences</span><span class="tag">GoRouter</span> | ✅ 완료 |
| 7. 문서·QA | 38개 테스트, ADR 4개, docs 5종 | <span class="tag">flutter_test</span><span class="tag alt">Marp CI</span> | ✅ 완료 |

<!--
[프로젝트계획 / 0:35~1:00]
기술 스택은 Flutter Web, Dart, GoRouter, Gemini 2.5 Flash, OpenWeatherMap, flutter_map, SharedPreferences입니다.
WBS 기준으로 인증, AI 경로 추천, 실시간 상황 반영, 지도, 마이페이지, 커뮤니티, 문서·QA까지 총 7개 모듈을 모두 완료했고, 각 모듈에 사용한 핵심 기술을 표에 함께 정리했습니다.
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

## <span class="chnum">02</span> 구현 방법 — 핵심 기능 5가지

<div class="cards compact" style="grid-template-columns: repeat(3, 1fr);">
<div class="card good">
<div class="icon" style="font-size: 1.4em; margin-bottom: 2px;">🎯</div>
<h3 style="margin-bottom: 2px;">취향 기반 개인화 추천</h3>
<p style="font-size: 0.85em; line-height: 1.35;">온보딩 취향 5종 → 홈 추천 카드 생성, 경로 검색 시 기본 필터로 자동 적용</p>
</div>
<div class="card good">
<div class="icon" style="font-size: 1.4em; margin-bottom: 2px;">🤖</div>
<h3 style="margin-bottom: 2px;">AI 경로 생성</h3>
<p style="font-size: 0.85em; line-height: 1.35;">취향+날씨를 Gemini 2.5 Flash에 전달, <code>_extractJson()</code>으로 마크다운 방어 파싱</p>
</div>
<div class="card good">
<div class="icon" style="font-size: 1.4em; margin-bottom: 2px;">🌦️</div>
<h3 style="margin-bottom: 2px;">실시간 날씨 반영</h3>
<p style="font-size: 0.85em; line-height: 1.35;">60+ 도시 매핑, "날씨 다시 확인" 클릭 시 저장 경로 재추천(실내·실외)</p>
</div>
<div class="card good">
<div class="icon" style="font-size: 1.4em; margin-bottom: 2px;">🗺️</div>
<h3 style="margin-bottom: 2px;">지도 시각화</h3>
<p style="font-size: 0.85em; line-height: 1.35;">flutter_map + OpenStreetMap, 번호 마커+폴리라인 (API 키 불필요)</p>
</div>
<div class="card good">
<div class="icon" style="font-size: 1.4em; margin-bottom: 2px;">👥</div>
<h3 style="margin-bottom: 2px;">커뮤니티</h3>
<p style="font-size: 0.85em; line-height: 1.35;">경로공유·질문·자유 게시판 + 댓글·좋아요·북마크로 다른 사용자 경로 참고</p>
</div>
</div>

> 다섯 기능 모두 **API 키 2개(Gemini, OpenWeatherMap)** + Unsplash(선택) 만으로 동작 — 발표 데모 환경 이식성 확보

<!--
[구현방법-핵심기능 / 1:45~2:10]
핵심 기능은 다섯 가지입니다.
첫째, 취향 기반 개인화 추천 — 온보딩에서 고른 취향 5종을 바탕으로 홈 화면에 Gemini가 나라별 추천 카드를 만들어주고, 경로 검색 시 저장된 취향이 기본 필터로 자동 적용됩니다.
둘째, AI 경로 생성 — 취향과 날씨 정보를 Gemini 2.5 Flash에 전달하고, 응답에 마크다운이 섞여도 안전하게 파싱하는 _extractJson 함수를 만들었습니다.
셋째, 실시간 날씨 반영 — OpenWeatherMap에서 60개 이상 도시를 매핑하고, 홈 화면 "날씨 다시 확인" 버튼으로 저장된 경로의 날씨를 재확인해 실내·실외 재추천을 받을 수 있습니다.
넷째, 지도 시각화 — flutter_map과 OpenStreetMap으로 API 키 없이 번호 마커와 폴리라인으로 동선을 보여줍니다.
다섯째, 커뮤니티 — 경로 공유·질문·자유 게시판에 댓글과 좋아요·북마크 기능으로 다른 사용자의 여행 경로를 참고할 수 있습니다.
이 다섯 기능 모두 API 키 1~2개만 있으면 동작해서, 데모 환경을 옮기기 쉽습니다.
-->

---

## 개발 환경 설정 & 빌드/배포

<div class="arch-grid">

<div>

### 로컬 실행 — 4단계

<div class="flow-item"><div class="flow-num l1">1</div><div class="flow-text">저장소 클론 + <code>flutter pub get</code></div></div>
<div class="flow-item"><div class="flow-num l1">2</div><div class="flow-text"><code>lib/core/config.dart</code> 생성, API 키 2개 입력 (gitignore 처리)</div></div>
<div class="flow-item"><div class="flow-num l1">3</div><div class="flow-text"><code>flutter run -d chrome</code>로 디버그 실행</div></div>
<div class="flow-item"><div class="flow-num l1">4</div><div class="flow-text"><code>flutter build web --release</code>로 배포용 빌드</div></div>

</div>

<div>

### 빌드 → 배포 파이프라인

<div class="layers">
<div class="layer l1">코드 push (main) <span class="desc">git push origin main</span></div>
<div class="layer-arrow">↓</div>
<div class="layer l2">발표 슬라이드 <span class="desc">Marp CI 자동 빌드 → GitHub Pages</span></div>
<div class="layer-arrow">↓</div>
<div class="layer l3">Flutter 앱 <span class="desc">flutter build web --release → 정적 호스팅 (수동)</span></div>
</div>

</div>

</div>

<div class="badges" style="margin-top: 14px;">
<span class="badge alt">버전: SemVer (1.0.0+1)</span>
<span class="badge alt">롤백: git revert + 재배포</span>
<span class="badge warn">자세한 내용: docs/deploy.md</span>
</div>

<!--
[개발환경/빌드배포 / 2:10~2:30]
왼쪽은 로컬 실행 4단계입니다. 클론 후 flutter pub get, lib/core/config.dart에 API 키 2개만 넣으면 flutter run -d chrome으로 바로 실행됩니다.
오른쪽은 빌드~배포 파이프라인인데, main에 push하면 발표 슬라이드는 Marp CI가 자동으로 GitHub Pages에 배포하고,
Flutter 앱은 flutter build web --release로 빌드한 산출물을 정적 호스팅에 수동으로 올리는 구조입니다.
버전은 SemVer(1.0.0+1) 규칙을 따르며, 문제 발생 시 git revert로 롤백합니다. 자세한 내용은 docs/deploy.md에 정리해뒀습니다.
-->

---

## 구현 시행착오 — 사례 2가지

<div class="cards" style="grid-template-columns: 1fr 1fr;">
<div class="card bad">
<h3>사례 1. "강릉 검색이 안 돼요"</h3>
1차: "안 돼, 고쳐줘" → AI가 추측성 교체 → 여전히 실패<br>
2차: F12 콘솔에 <code>Geocoding result: 0 items</code>, <code>404</code> 확인 → 증거와 함께 재요청 → 해결
</div>
<div class="card bad">
<h3>사례 2. "1박2일인데 1일차만 생성됨"</h3>
프롬프트가 <code>days</code>(박) 기준으로 dayPlans 개수를 요청해 마지막 날 일정이 누락 → <code>days+1</code>(일) 기준으로 수정해 N박(N+1)일 모두 생성
</div>
</div>

<br>

**원인 1**: OpenWeatherMap은 영문 도시명 기준 — "서울"은 되지만 "강릉(Gangneung)"은 매핑이 없어 404 → `_cityMap`에 국내 30+ 도시 영문명 추가
**원인 2**: "박"과 "일" 단위를 혼용한 프롬프트 조건 → 데이터 구조(`dayPlans` 길이 = days+1)를 직접 분석해 수정
**정착**: AGENTS.md 규칙 R-09 보강 — "증상이 아닌 로그/증거 + 정확한 데이터 구조 분석으로 디버깅 요청"

<!--
[구현시행착오 / 2:30~2:55]
구현 시행착오 사례 두 가지를 소개하면, 첫째는 "강릉 검색이 안 돼요" 버그입니다.
처음에는 "안 된다, 고쳐줘"라고만 요청했더니 AI가 추측성 수정을 했는데도 안 됐는데, 브라우저 콘솔에서 Geocoding 결과 0개, 404 에러를 직접 확인하고 증거와 함께 재요청해 해결했습니다. 원인은 OpenWeatherMap이 영문 도시명 기준이라 "강릉"은 매핑이 없었던 것이었고, 국내 30개 이상 도시의 영문명을 매핑 테이블에 추가했습니다.
둘째는 "1박2일인데 1일차 일정만 생성되는" 버그입니다. 프롬프트가 박 기준으로 dayPlans 개수를 요청해서 마지막 날이 빠졌는데, days+1(일) 기준으로 데이터 구조를 정확히 분석해 수정했습니다.
이 두 경험을 "증상이 아닌 로그·증거와 정확한 데이터 구조 분석으로 디버깅을 요청한다"는 AGENTS.md 규칙 R-09로 정착시켰습니다.
-->

---

## <span class="chnum">03</span> 코드 품질 · 테스트

<div class="badges">
<span class="badge alt">flutter analyze 경고 0개</span>
<span class="badge alt">테스트 38개 전부 통과</span>
</div>

### 테스트 38개 구성

<div class="test-bar">
<div class="seg t1" style="width: 10.53%">4</div>
<div class="seg t2" style="width: 34.21%">13</div>
<div class="seg t3" style="width: 18.42%">7</div>
<div class="seg t4" style="width: 15.79%">6</div>
<div class="seg t5" style="width: 21.05%">8</div>
</div>

<div class="check-grid">
<div class="legend-item"><div class="legend-dot t1"></div>Widget 4 — LoginScreen 렌더링</div>
<div class="legend-item"><div class="legend-dot t2"></div>Unit 13 — 도메인 모델·MockTripData</div>
<div class="legend-item"><div class="legend-dot t3"></div>Debug 7 — 경계값·예외 케이스</div>
<div class="legend-item"><div class="legend-dot t4"></div>Scenario 6 — 사용자 시나리오</div>
<div class="legend-item"><div class="legend-dot t5"></div>Integration 8 — Data ↔ Domain 연동</div>
</div>

<!--
[코드품질/테스트 / 2:55~3:07]
코드 품질은 flutter analyze 경고 0개를 유지하고, 테스트는 위젯 4, 단위 13, 경계값 7, 시나리오 6, 통합 8개로 총 38개 전부 통과합니다.
-->

---

## 성능 최적화

<div class="cards" style="grid-template-columns: 1fr 1fr;">
<div class="card good">
<div class="icon">⚡</div>
<h3>Gemini 응답 속도</h3>
모델 <code>gemini-2.5-pro</code> → <code>flash</code> 전환 + <code>thinkingBudget: 0</code> 설정으로 응답 지연 단축 (ADR 사례)
</div>
<div class="card good">
<div class="icon">📦</div>
<h3>추천 카드 캐싱</h3>
홈 화면 개인화 추천은 <code>RecommendationRepository</code>가 <strong>24시간 캐싱</strong> — 매번 Gemini를 호출하지 않고 캐시된 결과 재사용
</div>
</div>

<!--
[성능최적화 / 3:07~3:15]
성능 최적화는 두 가지인데, 첫째 Gemini 모델을 pro에서 flash로 바꾸고 thinkingBudget을 0으로 설정해서 응답 속도를 높였고,
둘째 홈 화면의 개인화 추천 카드는 RecommendationRepository가 24시간 동안 캐싱해서, 매번 Gemini를 호출하지 않고 캐시된 결과를 재사용하도록 했습니다.
-->

---

<!-- _class: mono-text -->

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

<!-- _class: mono-text -->

## 활용 방안 & 기대 효과

> **활용 시나리오**: 주말 당일치기 직장인이 "수원 1박 2일" 입력 → 10초 내 일정 생성 → 비 예보 시 "날씨 다시 확인"으로 실내 코스 재추천

<div class="cards compact" style="grid-template-columns: 1fr 1fr;">
<div class="card bad">
<div class="icon">😩</div>
<h3>기존 여행 계획</h3>
블로그·커뮤니티를 뒤져 평균 30분~1시간 소요, 막상 가보면 날씨 변화엔 대응 못함
</div>
<div class="card good">
<div class="icon">✨</div>
<h3>Tripia 사용</h3>
취향+실시간 날씨를 반영해 10초 내 일정 생성, 날씨가 바뀌면 버튼 한 번으로 실내 코스 재추천
</div>
</div>

| 비전 목표 (00-vision.md) | 지표 | 현재 상태 |
|---|---|---|
| 빠른 경로 생성 | 첫 추천 제공 ≤ 10초 | ✅ Gemini Flash로 달성 |
| 개인화 추천 정확도 | 추천 경로 저장률 ≥ 60% | 저장 기능 구현 완료, 지표 측정은 향후 |
| 높은 재사용률 | 월간 재방문 ≥ 40% | 마이페이지 저장 경로로 재방문 유도 구조 |
| 활성 커뮤니티 형성 | 월간 공유 ≥ 1,000건 | ✅ 커뮤니티 공유·좋아요·북마크 구현 완료, 활성화 지표는 향후 측정 |

<!--
[활용방안/기대효과 / 3:35~3:48]
활용 시나리오는, 주말에 당일치기를 가는 직장인이 "수원 1박 2일"을 입력하면 10초 안에 일정을 받고,
비 예보가 있으면 홈 화면의 "날씨 다시 확인" 버튼 한 번으로 실내 코스 재추천을 받는 식입니다.
기존에는 블로그·커뮤니티를 뒤지며 30분~1시간이 걸리고 날씨 변화에 대응할 수 없었지만, Tripia는 이 두 문제를 해결합니다.
비전 문서의 4개 목표 지표 중, 첫 추천 10초 이내는 Gemini Flash로 이미 달성했고,
저장률·재방문율은 저장/마이페이지 구조로 유도 가능하며, 커뮤니티 공유·좋아요·북마크 기능도 이미 구현을 완료했고 활성화 지표는 앞으로 측정할 계획입니다.
-->

---

## GitHub 가이드

<div class="badges">
<span class="badge">README.md — 5분 안에 이해</span>
<span class="badge">docs/setup.md — 실행 가이드</span>
<span class="badge">AGENTS.md — AI Agent 컨텍스트</span>
</div>

`github.com/dasol2024136073/Claude_application`

<div class="flow-item"><div class="flow-num l1">1</div><div class="flow-text"><code>README.md</code> — 프로젝트 개요·기능·실행 방법 5분 요약</div></div>
<div class="flow-item"><div class="flow-num l1">2</div><div class="flow-text"><code>docs/setup.md</code> — 클론부터 실행까지 환경 설정 가이드</div></div>
<div class="flow-item"><div class="flow-num l1">3</div><div class="flow-text"><code>docs/architecture.md</code> — 3계층 구조·화면 흐름·라우팅</div></div>
<div class="flow-item"><div class="flow-num l1">4</div><div class="flow-text"><code>docs/deploy.md</code> — 빌드/배포/버전관리/롤백</div></div>
<div class="flow-item"><div class="flow-num l1">5</div><div class="flow-text"><code>docs/testing.md</code> — 테스트 38개 구성과 실행 방법</div></div>

<!--
[GitHub가이드 / 3:48~3:55]
GitHub 저장소에는 README, setup, architecture, deploy, testing 문서가 순서대로 정리되어 있어서,
누구나 이 순서대로 읽으면 5분 안에 프로젝트 전체 구조와 실행 방법을 파악할 수 있습니다.
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

<!-- _class: demo mono-text -->
<!-- transition: wipe-left -->

# 🎬 시연 데모

### 사용자 시나리오: "제주 2박 3일, 비 오면 실내로, 커뮤니티 공유"

1. 로그인 → 홈 (현재 위치 날씨 카드)
2. "제주 / 2박 3일" 입력 → **Gemini가 10초 내 일정 생성**
3. 결과 화면 → 지도에서 동선 확인
4. "날씨 다시 확인" 클릭 → 실내 코스 재추천
5. 재추천 받은 경로를 **커뮤니티에 공유**

<!--
[시연데모]
지금부터 데모를 보여드리겠습니다.
시나리오는 "제주 2박3일, 비 오면 실내로, 커뮤니티 공유"입니다.
로그인 후 "제주 2박3일"을 입력하면 10초 안에 일정이 생성됩니다.
지도로 동선을 확인하고, 날씨 재확인으로 실내 코스를 받은 뒤 커뮤니티에 공유하는 것까지 보여드리겠습니다.
-->

---

<!-- _class: end -->

<span class="kicker">Thank You</span>

# 마무리 & 향후 발전 방향

<div class="badges center">
<span class="badge">Firebase Auth 전환</span>
<span class="badge alt">추천 정확도 피드백 루프</span>
<span class="badge warn">다국어 지원</span>
</div>

<br>

**Tripia**는 7주 동안 1인 개발로 Must+Should 기능을 모두 완성했습니다.
다음 단계는 ADR-0004에서 의도적으로 미룬 **Firebase Auth 전환**, 그리고 추천 결과에 대한 좋아요/저장 데이터를 학습해 **개인화 추천 정확도를 높이는 피드백 루프**입니다.

<br>

### 감사합니다 — Q&A

<!--
[마무리 / 4:40~5:00]
정리하면, Tripia는 7주 동안 1인 개발로 Must와 Should 기능을 모두 완성했습니다.
다음 단계는 ADR-0004에서 의도적으로 미뤄둔 Firebase Auth 전환, 그리고 추천 경로에 대한 좋아요·저장 데이터를 학습해서 개인화 추천 정확도를 높이는 피드백 루프입니다.
여기까지 발표 마치겠습니다. 감사합니다.
-->
