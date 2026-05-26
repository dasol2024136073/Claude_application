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
