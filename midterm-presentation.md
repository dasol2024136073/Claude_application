---
marp: true
theme: default
paginate: true
size: 16:9
style: |
  section {
    font-family: 'Noto Sans KR', sans-serif;
    background: #ffffff;
    color: #0f172a;
  }
  section.dark {
    background: #0f172a;
    color: #f8fafc;
  }
  section.vision {
    background: linear-gradient(135deg, #1e3a8a 0%, #4f46e5 100%);
    color: #ffffff;
  }
  h1 { font-size: 2em; font-weight: 800; }
  h2 { font-size: 1.5em; font-weight: 700; border-bottom: none; }
  blockquote {
    border-left: 4px solid #4f46e5;
    background: #f0f4ff;
    padding: 16px 20px;
    border-radius: 0 12px 12px 0;
    color: #1e3a8a;
    font-style: normal;
  }
---

<!-- _class: dark -->

# AI 여행 경로 추천 앱

### 세상에 단 하나뿐인 여행 동선을 AI가 설계합니다

<br>

**임다솔** · Flutter · 2026년 중간 발표

---

## 문제 정의

<svg viewBox="0 0 960 380" width="100%" role="img">
  <defs>
    <filter id="card-shadow">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-color="#0f172a" flood-opacity="0.10"/>
    </filter>
  </defs>

  <!-- Card 1 -->
  <rect x="30" y="40" width="270" height="300" rx="20" fill="#fef2f2" stroke="#fca5a5" stroke-width="2" filter="url(#card-shadow)"/>
  <text x="165" y="100" text-anchor="middle" font-size="44">😩</text>
  <text x="165" y="148" text-anchor="middle" font-size="22" font-weight="800" fill="#991b1b">계획 피로</text>
  <text x="165" y="182" text-anchor="middle" font-size="16" fill="#7f1d1d">여행지·식당·동선 검색에</text>
  <text x="165" y="206" text-anchor="middle" font-size="16" fill="#7f1d1d">평균 수십 개 탭 열기</text>
  <text x="165" y="244" text-anchor="middle" font-size="15" fill="#b91c1c">출발 전부터 지친다</text>

  <!-- Card 2 -->
  <rect x="345" y="40" width="270" height="300" rx="20" fill="#fffbeb" stroke="#fcd34d" stroke-width="2" filter="url(#card-shadow)"/>
  <text x="480" y="100" text-anchor="middle" font-size="44">🗺️</text>
  <text x="480" y="148" text-anchor="middle" font-size="22" font-weight="800" fill="#92400e">획일적 추천</text>
  <text x="480" y="182" text-anchor="middle" font-size="16" fill="#78350f">블로그·유튜브 추천은</text>
  <text x="480" y="206" text-anchor="middle" font-size="16" fill="#78350f">모두에게 같은 코스</text>
  <text x="480" y="244" text-anchor="middle" font-size="15" fill="#b45309">내 취향은 반영 안 된다</text>

  <!-- Card 3 -->
  <rect x="660" y="40" width="270" height="300" rx="20" fill="#f0fdf4" stroke="#86efac" stroke-width="2" filter="url(#card-shadow)"/>
  <text x="795" y="100" text-anchor="middle" font-size="44">🌧️</text>
  <text x="795" y="148" text-anchor="middle" font-size="22" font-weight="800" fill="#166534">상황 대응 불가</text>
  <text x="795" y="182" text-anchor="middle" font-size="16" fill="#14532d">갑자기 비가 와도</text>
  <text x="795" y="206" text-anchor="middle" font-size="16" fill="#14532d">처음부터 다시 검색</text>
  <text x="795" y="244" text-anchor="middle" font-size="15" fill="#15803d">실시간 대응이 없다</text>
</svg>

---

<!-- _class: vision -->

## 비전

<br>

<svg viewBox="0 0 960 200" width="88%" style="display:block;margin:0 auto">
  <rect x="20" y="20" width="920" height="160" rx="24" fill="rgba(255,255,255,0.12)" stroke="rgba(255,255,255,0.3)" stroke-width="2"/>
  <text x="480" y="90" text-anchor="middle" font-size="28" font-weight="800" fill="#ffffff">"당신이 좋아하는 것들로만 이어지는 길,</text>
  <text x="480" y="138" text-anchor="middle" font-size="28" font-weight="800" fill="#a5b4fc">AI가 설계하는 세상에 단 하나뿐인 동선."</text>
</svg>

<br>

> **계획에 드는 시간과 피로는 AI가 대신하고,**
> **여행자는 경험 자체에만 집중할 수 있게 한다.**

---

## 솔루션

<svg viewBox="0 0 960 310" width="100%" role="img">
  <defs>
    <linearGradient id="flow-grad" x1="0" x2="1">
      <stop offset="0" stop-color="#4f46e5"/>
      <stop offset="1" stop-color="#0ea5e9"/>
    </linearGradient>
    <marker id="sol-arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
      <path d="M0,0 L0,6 L9,3 z" fill="#94a3b8"/>
    </marker>
  </defs>

  <!-- Step 1 -->
  <rect x="30" y="60" width="200" height="190" rx="20" fill="#eff6ff" stroke="#3b82f6" stroke-width="2.5"/>
  <text x="130" y="115" text-anchor="middle" font-size="38">👤</text>
  <text x="130" y="158" text-anchor="middle" font-size="19" font-weight="800" fill="#1e3a8a">취향 프로필</text>
  <text x="130" y="185" text-anchor="middle" font-size="14" fill="#334155">여행 스타일</text>
  <text x="130" y="207" text-anchor="middle" font-size="14" fill="#334155">예산 · 동행 유형</text>

  <!-- Arrow -->
  <path d="M238 155 H282" stroke="#94a3b8" stroke-width="5" marker-end="url(#sol-arrow)"/>

  <!-- Step 2 -->
  <rect x="290" y="60" width="200" height="190" rx="20" fill="#f0fdf4" stroke="#22c55e" stroke-width="2.5"/>
  <text x="390" y="115" text-anchor="middle" font-size="38">🌤️</text>
  <text x="390" y="158" text-anchor="middle" font-size="19" font-weight="800" fill="#166534">실시간 상황</text>
  <text x="390" y="185" text-anchor="middle" font-size="14" fill="#334155">현재 날씨 · 위치</text>
  <text x="390" y="207" text-anchor="middle" font-size="14" fill="#334155">시간 · 시즌</text>

  <!-- Arrow -->
  <path d="M498 155 H542" stroke="#94a3b8" stroke-width="5" marker-end="url(#sol-arrow)"/>

  <!-- Step 3 (AI) -->
  <rect x="550" y="40" width="200" height="230" rx="20" fill="#1e1b4b" stroke="#818cf8" stroke-width="2.5"/>
  <text x="650" y="110" text-anchor="middle" font-size="38">🤖</text>
  <text x="650" y="155" text-anchor="middle" font-size="19" font-weight="800" fill="#a5b4fc">AI 경로 생성</text>
  <text x="650" y="182" text-anchor="middle" font-size="14" fill="#c7d2fe">Claude API</text>
  <text x="650" y="204" text-anchor="middle" font-size="14" fill="#c7d2fe">10초 이내 응답</text>
  <text x="650" y="248" text-anchor="middle" font-size="12" fill="#818cf8">핵심 엔진</text>

  <!-- Arrow -->
  <path d="M758 155 H802" stroke="#94a3b8" stroke-width="5" marker-end="url(#sol-arrow)"/>

  <!-- Step 4 -->
  <rect x="810" y="60" width="120" height="190" rx="20" fill="#fdf4ff" stroke="#c084fc" stroke-width="2.5"/>
  <text x="870" y="115" text-anchor="middle" font-size="38">🗺️</text>
  <text x="870" y="158" text-anchor="middle" font-size="17" font-weight="800" fill="#6b21a8">나만의</text>
  <text x="870" y="182" text-anchor="middle" font-size="17" font-weight="800" fill="#6b21a8">경로</text>
  <text x="870" y="210" text-anchor="middle" font-size="13" fill="#7e22ce">저장 · 공유</text>
</svg>

---

## 타겟 사용자

<svg viewBox="0 0 960 320" width="92%" style="display:block;margin:0 auto" role="img">
  <defs>
    <filter id="t-shadow">
      <feDropShadow dx="0" dy="4" stdDeviation="8" flood-color="#0f172a" flood-opacity="0.08"/>
    </filter>
  </defs>

  <!-- Main target -->
  <rect x="40" y="30" width="520" height="260" rx="24" fill="#eff6ff" stroke="#3b82f6" stroke-width="3" filter="url(#t-shadow)"/>
  <text x="60" y="76" font-size="16" font-weight="700" fill="#2563eb">주 타겟</text>
  <text x="300" y="120" text-anchor="middle" font-size="46">✈️</text>
  <text x="300" y="168" text-anchor="middle" font-size="22" font-weight="800" fill="#1e3a8a">20~30대 개인 여행자</text>
  <text x="300" y="200" text-anchor="middle" font-size="16" fill="#334155">여행 계획에 어려움을 느끼는 사람</text>
  <text x="300" y="224" text-anchor="middle" font-size="16" fill="#334155">나만의 취향대로 여행하고 싶은 사람</text>
  <text x="300" y="262" text-anchor="middle" font-size="14" fill="#64748b">→ "이번 여행은 좀 다르게 해보고 싶다"</text>

  <!-- Sub target -->
  <rect x="590" y="30" width="340" height="118" rx="20" fill="#f0fdf4" stroke="#22c55e" stroke-width="2" filter="url(#t-shadow)"/>
  <text x="610" y="68" font-size="15" font-weight="700" fill="#16a34a">부 타겟 ①</text>
  <text x="760" y="100" text-anchor="middle" font-size="16" font-weight="700" fill="#166534">당일치기 즐기는 직장인</text>
  <text x="760" y="124" text-anchor="middle" font-size="14" fill="#334155">위치·날씨 기반 즉흥 추천 필요</text>

  <rect x="590" y="172" width="340" height="118" rx="20" fill="#fff7ed" stroke="#f97316" stroke-width="2" filter="url(#t-shadow)"/>
  <text x="610" y="210" font-size="15" font-weight="700" fill="#ea580c">부 타겟 ②</text>
  <text x="760" y="242" text-anchor="middle" font-size="16" font-weight="700" fill="#9a3412">해외여행 초보자</text>
  <text x="760" y="266" text-anchor="middle" font-size="14" fill="#334155">검증된 경로로 안심하고 떠나고 싶음</text>
</svg>

---

## 사용자 시나리오

> **지수** (25세, 직장인) — "오사카 3박 4일, 맛집 위주로 계획해야 하는데…"

<svg viewBox="0 0 960 340" width="100%" role="img">
  <defs>
    <marker id="sc-arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#94a3b8"/>
    </marker>
  </defs>

  <!-- Step 1 -->
  <rect x="20" y="80" width="148" height="180" rx="16" fill="#eff6ff" stroke="#3b82f6" stroke-width="2"/>
  <text x="94" y="130" text-anchor="middle" font-size="32">📲</text>
  <text x="94" y="162" text-anchor="middle" font-size="13" font-weight="800" fill="#1e3a8a">Google 로그인</text>
  <text x="94" y="184" text-anchor="middle" font-size="11" fill="#475569">계정 한 번 탭으로</text>
  <text x="94" y="202" text-anchor="middle" font-size="11" fill="#475569">바로 시작</text>
  <text x="94" y="236" text-anchor="middle" font-size="22" fill="#3b82f6">①</text>

  <!-- Arrow -->
  <path d="M172 170 H200" stroke="#94a3b8" stroke-width="3" marker-end="url(#sc-arrow)"/>

  <!-- Step 2 -->
  <rect x="204" y="80" width="148" height="180" rx="16" fill="#f0fdf4" stroke="#22c55e" stroke-width="2"/>
  <text x="278" y="130" text-anchor="middle" font-size="32">✨</text>
  <text x="278" y="162" text-anchor="middle" font-size="13" font-weight="800" fill="#166534">취향 프로필</text>
  <text x="278" y="184" text-anchor="middle" font-size="11" fill="#475569">맛집·카페 선호,</text>
  <text x="278" y="202" text-anchor="middle" font-size="11" fill="#475569">혼자, 여유 예산</text>
  <text x="278" y="236" text-anchor="middle" font-size="22" fill="#22c55e">②</text>

  <!-- Arrow -->
  <path d="M356 170 H384" stroke="#94a3b8" stroke-width="3" marker-end="url(#sc-arrow)"/>

  <!-- Step 3 -->
  <rect x="388" y="60" width="148" height="220" rx="16" fill="#1e1b4b" stroke="#818cf8" stroke-width="2.5"/>
  <text x="462" y="120" text-anchor="middle" font-size="32">🤖</text>
  <text x="462" y="155" text-anchor="middle" font-size="13" font-weight="800" fill="#a5b4fc">AI 경로 생성</text>
  <text x="462" y="177" text-anchor="middle" font-size="11" fill="#c7d2fe">"오사카 3박 4일"</text>
  <text x="462" y="197" text-anchor="middle" font-size="11" fill="#c7d2fe">입력 → 10초 이내</text>
  <text x="462" y="220" text-anchor="middle" font-size="11" fill="#818cf8">Claude API</text>
  <text x="462" y="256" text-anchor="middle" font-size="22" fill="#818cf8">③</text>

  <!-- Arrow -->
  <path d="M540 170 H568" stroke="#94a3b8" stroke-width="3" marker-end="url(#sc-arrow)"/>

  <!-- Step 4 -->
  <rect x="572" y="80" width="148" height="180" rx="16" fill="#fdf4ff" stroke="#c084fc" stroke-width="2"/>
  <text x="646" y="130" text-anchor="middle" font-size="32">🗺️</text>
  <text x="646" y="162" text-anchor="middle" font-size="13" font-weight="800" fill="#6b21a8">일별 경로 확인</text>
  <text x="646" y="184" text-anchor="middle" font-size="11" fill="#475569">도톤보리→구로몬→</text>
  <text x="646" y="202" text-anchor="middle" font-size="11" fill="#475569">신사이바시 3박 4일</text>
  <text x="646" y="236" text-anchor="middle" font-size="22" fill="#c084fc">④</text>

  <!-- Arrow -->
  <path d="M724 170 H752" stroke="#94a3b8" stroke-width="3" marker-end="url(#sc-arrow)"/>

  <!-- Step 5 -->
  <rect x="756" y="80" width="184" height="180" rx="16" fill="#fff7ed" stroke="#f97316" stroke-width="2"/>
  <text x="848" y="130" text-anchor="middle" font-size="32">💾</text>
  <text x="848" y="162" text-anchor="middle" font-size="13" font-weight="800" fill="#9a3412">저장 & 출발</text>
  <text x="848" y="184" text-anchor="middle" font-size="11" fill="#475569">마음에 드는 장소</text>
  <text x="848" y="202" text-anchor="middle" font-size="11" fill="#475569">교체 후 최종 저장</text>
  <text x="848" y="236" text-anchor="middle" font-size="22" fill="#f97316">⑤</text>
</svg>

> **기대 결과**: 수십 개 탭 검색 없이, 10초 만에 취향 맞춤 오사카 동선 완성

---

## 기술 스택 — 왜 이걸 선택했나요?

<svg viewBox="0 0 960 380" width="100%" role="img">
  <defs>
    <filter id="ts-shadow">
      <feDropShadow dx="0" dy="3" stdDeviation="6" flood-color="#0f172a" flood-opacity="0.08"/>
    </filter>
  </defs>

  <!-- Flutter -->
  <rect x="20" y="20" width="280" height="160" rx="16" fill="#e0f2fe" stroke="#0284c7" stroke-width="1.5" filter="url(#ts-shadow)"/>
  <text x="36" y="56" font-size="13" font-weight="700" fill="#0369a1">📱 Flutter (ADR-0001)</text>
  <text x="36" y="82" font-size="12" fill="#0c4a6e">• iOS/Android 단일 코드베이스</text>
  <text x="36" y="102" font-size="12" fill="#0c4a6e">• Google Maps SDK 공식 지원</text>
  <text x="36" y="122" font-size="12" fill="#0c4a6e">• Widget 기반 자유로운 커스텀 UI</text>
  <text x="36" y="148" font-size="11" fill="#7dd3fc">↳ React Native·네이티브 검토 후 제외</text>
  <text x="36" y="166" font-size="11" fill="#7dd3fc">  (JS 미숙 / 코드 2배 부담)</text>

  <!-- Riverpod -->
  <rect x="320" y="20" width="280" height="160" rx="16" fill="#f0fdf4" stroke="#16a34a" stroke-width="1.5" filter="url(#ts-shadow)"/>
  <text x="336" y="56" font-size="13" font-weight="700" fill="#15803d">⚙️ Riverpod 2.x (ADR-0002)</text>
  <text x="336" y="82" font-size="12" fill="#14532d">• AsyncValue로 로딩·오류 타입 안전</text>
  <text x="336" y="102" font-size="12" fill="#14532d">• 화면 간 상태 공유 (인증·경로 결과)</text>
  <text x="336" y="122" font-size="12" fill="#14532d">• 컴파일 타임 오류 검출</text>
  <text x="336" y="148" font-size="11" fill="#86efac">↳ BLoC(보일러플레이트 과다)·GetX</text>
  <text x="336" y="166" font-size="11" fill="#86efac">  (테스트 어려움) 검토 후 제외</text>

  <!-- Firebase -->
  <rect x="620" y="20" width="320" height="160" rx="16" fill="#fff7ed" stroke="#ea580c" stroke-width="1.5" filter="url(#ts-shadow)"/>
  <text x="636" y="56" font-size="13" font-weight="700" fill="#c2410c">🔥 Firebase (ADR-0003)</text>
  <text x="636" y="82" font-size="12" fill="#7c2d12">• Auth: Google 로그인 기본 내장</text>
  <text x="636" y="102" font-size="12" fill="#7c2d12">• Firestore 실시간 스트림</text>
  <text x="636" y="122" font-size="12" fill="#7c2d12">• 무료 Spark 플랜으로 MVP 개발</text>
  <text x="636" y="148" font-size="11" fill="#fdba74">↳ Supabase(SDK 성숙도)·직접 구축</text>
  <text x="636" y="166" font-size="11" fill="#fdba74">  (배포 부담) 검토 후 제외</text>

  <!-- Claude API -->
  <rect x="20" y="200" width="280" height="160" rx="16" fill="#fdf4ff" stroke="#9333ea" stroke-width="1.5" filter="url(#ts-shadow)"/>
  <text x="36" y="236" font-size="13" font-weight="700" fill="#7e22ce">🤖 Claude API (Anthropic)</text>
  <text x="36" y="262" font-size="12" fill="#581c87">• 자연어 프롬프트로 구조화된</text>
  <text x="36" y="282" font-size="12" fill="#581c87">  JSON 일정 생성</text>
  <text x="36" y="302" font-size="12" fill="#581c87">• 취향 프로필 → 프롬프트 주입</text>
  <text x="36" y="342" font-size="11" fill="#d8b4fe">↳ GPT-4o도 검토, Claude 사용이</text>
  <text x="36" y="358" font-size="11" fill="#d8b4fe">  수업 취지에 부합</text>

  <!-- GoRouter -->
  <rect x="320" y="200" width="280" height="160" rx="16" fill="#f0f9ff" stroke="#0284c7" stroke-width="1.5" filter="url(#ts-shadow)"/>
  <text x="336" y="236" font-size="13" font-weight="700" fill="#0369a1">🧭 GoRouter</text>
  <text x="336" y="262" font-size="12" fill="#0c4a6e">• 선언형 URL 기반 라우팅</text>
  <text x="336" y="282" font-size="12" fill="#0c4a6e">• Deep link·웹 URL 지원</text>
  <text x="336" y="302" font-size="12" fill="#0c4a6e">• extra로 화면 간 데이터 전달</text>
  <text x="336" y="342" font-size="11" fill="#7dd3fc">↳ Navigator 2.0 직접 사용 대비</text>
  <text x="336" y="358" font-size="11" fill="#7dd3fc">  코드량 60% 감소</text>

  <!-- 외부 API -->
  <rect x="620" y="200" width="320" height="160" rx="16" fill="#f8fafc" stroke="#94a3b8" stroke-width="1.5" filter="url(#ts-shadow)"/>
  <text x="636" y="236" font-size="13" font-weight="700" fill="#475569">🌍 외부 API</text>
  <text x="636" y="262" font-size="12" fill="#334155">• Google Maps SDK — 경로 시각화</text>
  <text x="636" y="282" font-size="12" fill="#334155">• OpenWeatherMap — 실시간 날씨</text>
  <text x="636" y="302" font-size="12" fill="#334155">• Kakao Login SDK — 소셜 로그인</text>
  <text x="636" y="342" font-size="11" fill="#94a3b8">↳ 13주차 실제 연동 예정</text>
</svg>

---

## 아키텍처 — 레이어드 구조

<svg viewBox="0 0 960 300" width="100%" role="img">
  <defs>
    <filter id="arch-shadow">
      <feDropShadow dx="0" dy="2" stdDeviation="4" flood-color="#0f172a" flood-opacity="0.08"/>
    </filter>
  </defs>

  <!-- Presentation Layer -->
  <rect x="20" y="20" width="200" height="260" rx="14" fill="#eff6ff" stroke="#3b82f6" stroke-width="2" filter="url(#arch-shadow)"/>
  <text x="120" y="52" text-anchor="middle" font-size="13" font-weight="800" fill="#1e40af">Presentation</text>
  <text x="120" y="72" text-anchor="middle" font-size="11" fill="#3b82f6">Flutter Widgets</text>
  <rect x="36" y="88" width="168" height="26" rx="6" fill="#dbeafe"/>
  <text x="120" y="105" text-anchor="middle" font-size="11" fill="#1e3a8a">LoginScreen</text>
  <rect x="36" y="120" width="168" height="26" rx="6" fill="#dbeafe"/>
  <text x="120" y="137" text-anchor="middle" font-size="11" fill="#1e3a8a">OnboardingScreen</text>
  <rect x="36" y="152" width="168" height="26" rx="6" fill="#dbeafe"/>
  <text x="120" y="169" text-anchor="middle" font-size="11" fill="#1e3a8a">RouteInputScreen</text>
  <rect x="36" y="184" width="168" height="26" rx="6" fill="#dbeafe"/>
  <text x="120" y="201" text-anchor="middle" font-size="11" fill="#1e3a8a">RouteResultScreen</text>
  <text x="120" y="248" text-anchor="middle" font-size="10" fill="#93c5fd">GoRouter</text>
  <text x="120" y="266" text-anchor="middle" font-size="10" fill="#93c5fd">Riverpod Providers</text>

  <!-- Arrow -->
  <path d="M224 150 H258" stroke="#94a3b8" stroke-width="2.5" marker-end="url(#sc-arrow)"/>
  <path d="M258 150 H224" stroke="#94a3b8" stroke-width="2.5" marker-end="url(#sc-arrow)"/>

  <!-- Application Layer -->
  <rect x="262" y="20" width="200" height="260" rx="14" fill="#f0fdf4" stroke="#22c55e" stroke-width="2" filter="url(#arch-shadow)"/>
  <text x="362" y="52" text-anchor="middle" font-size="13" font-weight="800" fill="#15803d">Application</text>
  <text x="362" y="72" text-anchor="middle" font-size="11" fill="#22c55e">Use Cases</text>
  <rect x="278" y="88" width="168" height="26" rx="6" fill="#dcfce7"/>
  <text x="362" y="105" text-anchor="middle" font-size="11" fill="#14532d">GenerateRouteUseCase</text>
  <rect x="278" y="120" width="168" height="26" rx="6" fill="#dcfce7"/>
  <text x="362" y="137" text-anchor="middle" font-size="11" fill="#14532d">SaveRouteUseCase</text>
  <rect x="278" y="152" width="168" height="26" rx="6" fill="#dcfce7"/>
  <text x="362" y="169" text-anchor="middle" font-size="11" fill="#14532d">AuthUseCase</text>
  <text x="362" y="260" text-anchor="middle" font-size="10" fill="#86efac">(13주차 구현 예정)</text>

  <!-- Arrow -->
  <path d="M466 150 H500" stroke="#94a3b8" stroke-width="2.5" marker-end="url(#sc-arrow)"/>
  <path d="M500 150 H466" stroke="#94a3b8" stroke-width="2.5" marker-end="url(#sc-arrow)"/>

  <!-- Domain Layer -->
  <rect x="504" y="20" width="200" height="260" rx="14" fill="#fdf4ff" stroke="#9333ea" stroke-width="2" filter="url(#arch-shadow)"/>
  <text x="604" y="52" text-anchor="middle" font-size="13" font-weight="800" fill="#7e22ce">Domain</text>
  <text x="604" y="72" text-anchor="middle" font-size="11" fill="#9333ea">Models · Repositories</text>
  <rect x="520" y="88" width="168" height="26" rx="6" fill="#f3e8ff"/>
  <text x="604" y="105" text-anchor="middle" font-size="11" fill="#581c87">TripPlan</text>
  <rect x="520" y="120" width="168" height="26" rx="6" fill="#f3e8ff"/>
  <text x="604" y="137" text-anchor="middle" font-size="11" fill="#581c87">DayPlan · PlaceItem</text>
  <rect x="520" y="152" width="168" height="26" rx="6" fill="#f3e8ff"/>
  <text x="604" y="169" text-anchor="middle" font-size="11" fill="#581c87">IRouteRepository</text>
  <text x="604" y="260" text-anchor="middle" font-size="10" fill="#d8b4fe">외부 의존성 없음</text>

  <!-- Arrow -->
  <path d="M708 150 H742" stroke="#94a3b8" stroke-width="2.5" marker-end="url(#sc-arrow)"/>
  <path d="M742 150 H708" stroke="#94a3b8" stroke-width="2.5" marker-end="url(#sc-arrow)"/>

  <!-- Data Layer -->
  <rect x="746" y="20" width="194" height="260" rx="14" fill="#fff7ed" stroke="#ea580c" stroke-width="2" filter="url(#arch-shadow)"/>
  <text x="843" y="52" text-anchor="middle" font-size="13" font-weight="800" fill="#c2410c">Data</text>
  <text x="843" y="72" text-anchor="middle" font-size="11" fill="#ea580c">Repositories · API</text>
  <rect x="762" y="88" width="162" height="26" rx="6" fill="#ffedd5"/>
  <text x="843" y="105" text-anchor="middle" font-size="11" fill="#7c2d12">MockTripData ✅</text>
  <rect x="762" y="120" width="162" height="26" rx="6" fill="#ffedd5"/>
  <text x="843" y="137" text-anchor="middle" font-size="11" fill="#7c2d12">Firebase Firestore ⏳</text>
  <rect x="762" y="152" width="162" height="26" rx="6" fill="#ffedd5"/>
  <text x="843" y="169" text-anchor="middle" font-size="11" fill="#7c2d12">Claude API Client ⏳</text>
  <rect x="762" y="184" width="162" height="26" rx="6" fill="#ffedd5"/>
  <text x="843" y="201" text-anchor="middle" font-size="11" fill="#7c2d12">Google Maps SDK ⏳</text>
</svg>

---

## 현재 진행 상황

<svg viewBox="0 0 960 340" width="100%" role="img">
  <!-- 완료 영역 -->
  <rect x="20" y="20" width="440" height="300" rx="16" fill="#f0fdf4" stroke="#22c55e" stroke-width="2"/>
  <text x="40" y="54" font-size="15" font-weight="800" fill="#15803d">✅ 완료 (Must 기능 ~40%)</text>

  <rect x="36" y="66" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="84" font-size="12" fill="#14532d">✅ 기획 문서 — 비전·요구사항·WBS·일정·위험</text>

  <rect x="36" y="100" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="118" font-size="12" fill="#14532d">✅ ADR 3종 — 프레임워크·상태관리·백엔드</text>

  <rect x="36" y="134" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="152" font-size="12" fill="#14532d">✅ Flutter 4계층 프로젝트 구조 + 빌드 성공</text>

  <rect x="36" y="168" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="186" font-size="12" fill="#14532d">✅ LoginScreen — Google / Kakao 소셜 로그인 UI</text>

  <rect x="36" y="202" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="220" font-size="12" fill="#14532d">✅ OnboardingScreen — 여행 취향 프로필 설정</text>

  <rect x="36" y="236" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="254" font-size="12" fill="#14532d">✅ RouteInput → (2초 로딩) → RouteResult 흐름</text>

  <rect x="36" y="270" width="408" height="28" rx="8" fill="#dcfce7"/>
  <text x="52" y="288" font-size="12" fill="#14532d">✅ 도메인 모델 + Mock 데이터 레이어 분리</text>

  <!-- 예정 영역 -->
  <rect x="500" y="20" width="440" height="300" rx="16" fill="#fff7ed" stroke="#f97316" stroke-width="2"/>
  <text x="520" y="54" font-size="15" font-weight="800" fill="#c2410c">⏳ 진행 중 / 예정</text>

  <rect x="516" y="66" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="84" font-size="12" fill="#7c2d12">🚧 Claude API 실제 연동 (프롬프트·응답 파싱)</text>

  <rect x="516" y="100" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="118" font-size="12" fill="#7c2d12">🚧 Firebase Auth 실제 연동 (Google 로그인)</text>

  <rect x="516" y="134" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="152" font-size="12" fill="#7c2d12">🚧 Firestore — 생성 경로 저장·조회·삭제</text>

  <rect x="516" y="168" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="186" font-size="12" fill="#7c2d12">⏳ Google Maps SDK — 경로 핀·이동선 시각화</text>

  <rect x="516" y="202" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="220" font-size="12" fill="#7c2d12">⏳ 날씨 API — OpenWeatherMap 실시간 반영</text>

  <rect x="516" y="236" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="254" font-size="12" fill="#7c2d12">⏳ 커뮤니티 — 경로 공유·피드·좋아요</text>

  <rect x="516" y="270" width="408" height="28" rx="8" fill="#ffedd5"/>
  <text x="532" y="288" font-size="12" fill="#7c2d12">⏳ 단위 테스트 — 인증·AI 클라이언트</text>
</svg>

---

## 데모

> 지금 바로 보여드리겠습니다.

**데모 시나리오 — "오사카 3박 4일 맛집 코스"**

| 단계 | 화면 | 포인트 |
|---|---|---|
| ① | 로그인 화면 | Google 버튼 탭 → 즉시 다음 화면 |
| ② | 취향 프로필 | 맛집·카페 선택, 혼자, 여유 예산 |
| ③ | 홈 화면 | "새 여행 경로 만들기" CTA |
| ④ | 경로 입력 | "오사카" 입력, 3박 선택 → AI 경로 생성 |
| ⑤ | 로딩 | 스피너 + "AI가 경로를 설계하는 중…" |
| ⑥ | 경로 결과 | 일별 장소 목록, 저장 버튼 |

> 현재 AI 응답은 Mock 데이터 (13주차에 Claude API 실제 연동 예정)

---

## 남은 일정과 우선순위

<svg viewBox="0 0 960 280" width="100%" role="img">

  <!-- 13주차 -->
  <rect x="20" y="20" width="288" height="240" rx="16" fill="#eff6ff" stroke="#3b82f6" stroke-width="2"/>
  <text x="164" y="52" text-anchor="middle" font-size="15" font-weight="800" fill="#1e40af">13주차</text>
  <text x="164" y="74" text-anchor="middle" font-size="12" fill="#3b82f6">핵심 기능 2 + 테스트</text>

  <rect x="36" y="88" width="256" height="24" rx="6" fill="#dbeafe"/>
  <text x="44" y="104" font-size="11" fill="#1e3a8a">① Claude API 실제 연동</text>
  <rect x="36" y="118" width="256" height="24" rx="6" fill="#dbeafe"/>
  <text x="44" y="134" font-size="11" fill="#1e3a8a">② Firebase Auth + Firestore</text>
  <rect x="36" y="148" width="256" height="24" rx="6" fill="#dbeafe"/>
  <text x="44" y="164" font-size="11" fill="#1e3a8a">③ GPS + 날씨 API 연동</text>
  <rect x="36" y="178" width="256" height="24" rx="6" fill="#dbeafe"/>
  <text x="44" y="194" font-size="11" fill="#1e3a8a">④ 경로 편집·저장 기능</text>
  <rect x="36" y="208" width="256" height="24" rx="6" fill="#dbeafe"/>
  <text x="44" y="224" font-size="11" fill="#1e3a8a">⑤ 단위 테스트 스위트</text>

  <!-- 14주차 -->
  <rect x="336" y="20" width="288" height="240" rx="16" fill="#f0fdf4" stroke="#22c55e" stroke-width="2"/>
  <text x="480" y="52" text-anchor="middle" font-size="15" font-weight="800" fill="#15803d">14주차</text>
  <text x="480" y="74" text-anchor="middle" font-size="12" fill="#22c55e">마감 · 배포 · 문서</text>

  <rect x="352" y="88" width="256" height="24" rx="6" fill="#dcfce7"/>
  <text x="360" y="104" font-size="11" fill="#14532d">① 커뮤니티 피드 · 공유 기능</text>
  <rect x="352" y="118" width="256" height="24" rx="6" fill="#dcfce7"/>
  <text x="360" y="134" font-size="11" fill="#14532d">② Google Maps 경로 시각화</text>
  <rect x="352" y="148" width="256" height="24" rx="6" fill="#dcfce7"/>
  <text x="360" y="164" font-size="11" fill="#14532d">③ UAT (시나리오 3개 직접 수행)</text>
  <rect x="352" y="178" width="256" height="24" rx="6" fill="#dcfce7"/>
  <text x="360" y="194" font-size="11" fill="#14532d">④ Play Store / APK 빌드</text>
  <rect x="352" y="208" width="256" height="24" rx="6" fill="#dcfce7"/>
  <text x="360" y="224" font-size="11" fill="#14532d">⑤ README · 배포 문서 완성</text>

  <!-- 15주차 -->
  <rect x="652" y="20" width="288" height="240" rx="16" fill="#fff7ed" stroke="#f97316" stroke-width="2"/>
  <text x="796" y="52" text-anchor="middle" font-size="15" font-weight="800" fill="#c2410c">15주차</text>
  <text x="796" y="74" text-anchor="middle" font-size="12" fill="#f97316">최종 발표</text>

  <rect x="668" y="88" width="256" height="24" rx="6" fill="#ffedd5"/>
  <text x="676" y="104" font-size="11" fill="#7c2d12">① 최종 발표 슬라이드 완성</text>
  <rect x="668" y="118" width="256" height="24" rx="6" fill="#ffedd5"/>
  <text x="676" y="134" font-size="11" fill="#7c2d12">② 라이브 데모 (시나리오 1개)</text>
  <rect x="668" y="148" width="256" height="24" rx="6" fill="#ffedd5"/>
  <text x="676" y="164" font-size="11" fill="#7c2d12">③ KPT 회고 문서 작성</text>
  <rect x="668" y="178" width="256" height="24" rx="6" fill="#ffedd5"/>
  <text x="676" y="194" font-size="11" fill="#7c2d12">④ AUTHORING.md v0.3 최종화</text>
  <rect x="668" y="208" width="256" height="24" rx="6" fill="#ffedd5"/>
  <text x="676" y="224" font-size="11" fill="#7c2d12">⑤ 가산점 발표 어필</text>
</svg>

---

<!-- _class: dark -->

## Q&A 준비

> 아래 5가지 질문을 예상하고 답변을 준비했습니다.

---

**Q1. "왜 이 플랫폼을 선택했나요?"**

→ ADR-0001 참조. iOS/Android 단일 코드베이스, Google Maps·Firebase Flutter SDK 공식 지원, Widget 기반 커스텀 UI 자유도.
대안으로 React Native(JS 미숙)·네이티브(코드 2배)를 검토했지만 제외했습니다.

---

**Q2. "이 화면의 데이터는 어디서 오나요?"**

→ 현재는 `lib/data/mock/MockTripData` — 정적 더미 데이터입니다.
실제 흐름: RouteInputScreen → Claude API HTTP 호출 → JSON 파싱 → TripPlan 모델 → RouteResultScreen 렌더링.
Presentation 레이어는 Domain만 알고, Data 레이어를 직접 참조하지 않습니다.

---

**Q3. "지금 가장 큰 문제는?"**

→ R09 (가장 위험): AI가 생성한 코드를 본인이 완전히 이해하지 못하는 상황.
대응: 코드 생성 후 직접 주석 달기, 핵심 로직은 직접 타이핑 연습.
R05: 13주차가 시험·과제 폭주 주간과 겹쳐 일정 압박 존재.

---

**Q4. "어디서부터 어디까지 AI가 만들었나요?"**

→ **AI(Claude Code)가 생성**: 5개 화면 Flutter 코드, GoRouter 설정, 도메인 모델, MockTripData, ADR 문서 초안.
→ **제가 결정**: 기능 범위(Must/Should), ADR 선택 근거("왜 Flutter인가"), 프롬프트 방향 지시, 코드 리뷰·수정, 데이터 구조 기획.
AI 사용을 숨기지 않는 것이 이 수업의 원칙입니다.

---

**Q5. "본인이 직접 짠 부분은 어떤 거예요?"**

→ 요구사항 3개 시나리오 작성, ADR 세 가지 최종 결정, pubspec.yaml 패키지 선택·버전 관리,
더미 데이터 목적지·장소·설명 내용 기획, 발표 슬라이드 구성 방향.
코드 레벨에서는: AI 생성 후 `withValues(alpha:)` 마이그레이션, `(_, __)` → `(context, _)` 수정 등 직접 검토·수정했습니다.

---

<!-- _class: vision -->

# 감사합니다

<br>

> **임다솔** · AI 여행 경로 추천 앱 · 2026년 중간 발표

<br>

GitHub: `github.com/dasol2024136073/Claude_application`
