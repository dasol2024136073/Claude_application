# 아키텍처 — Tripia (AI 여행 경로 추천 앱)

## 1. 시스템 개요

취향 프로필 + 실시간 날씨를 Gemini API에 전달해 개인화된 여행 경로를 생성하고,
SharedPreferences에 로컬로 저장·조회하는 Flutter 웹 앱.

추가로 사용자의 저장된 취향을 기반으로 홈 화면에 AI 추천 여행지(Unsplash 사진 포함)를 보여주고,
현재 위치 기반 "지금 갈 수 있는 근교 코스"를 즉시 생성하며, 커뮤니티에서 경로/후기를 공유·탐색할 수 있다.

---

## 2. 레이어 구조

3계층 구조로, **Application(상태관리/유스케이스) 레이어는 별도로 두지 않고 화면(StatefulWidget)이 서비스를 직접 호출**한다.

```mermaid
graph TD
    A[Presentation Layer<br/>Screen · Widget · StatefulWidget] --> C[Domain Layer<br/>TripPlan/DayPlan/PlaceItem<br/>CommunityPost/Comment/Review<br/>DestinationRecommendation]
    A --> D[Data Layer<br/>Service · Repository]
    D --> C

    D --> E[(SharedPreferences<br/>로컬 저장)]
    D --> F[Gemini 2.5 Flash API]
    D --> G[OpenWeatherMap API]
    D --> U[Unsplash API<br/>추천 여행지 사진]
    A --> H[flutter_map<br/>+ OpenStreetMap]
```

| 레이어 | 책임 | 폴더 |
|--------|------|------|
| **Presentation** | 화면 렌더링, 사용자 입력 처리, 서비스 직접 호출 | `lib/presentation/` |
| **Domain** | 핵심 모델 정의 (TripPlan/DayPlan/PlaceItem, CommunityPost/Comment, Review, DestinationRecommendation), 외부 의존 없음, toJson/fromJson | `lib/domain/models/` |
| **Data** | API 연동(Gemini/OpenWeatherMap/Unsplash), 로컬 저장(SharedPreferences) | `lib/data/services/`, `lib/data/mock/` |
| **Core** | API 키 등 설정 상수 | `lib/core/` |

---

## 3. 디렉토리 구조

```
lib/
├── main.dart                              # 진입점
├── app.dart                               # GoRouter 라우팅 (StatefulShellRoute 기반 GNB)
├── core/
│   ├── config.dart                        # API 키 상수 (gitignore, 절대 커밋 금지)
│   └── config.example.dart                # API 키 설정 예시
├── domain/
│   └── models/
│       ├── trip_plan.dart                 # TripPlan / DayPlan / PlaceItem
│       ├── community_post.dart            # CommunityPost (게시글, 카테고리: 경로공유/질문/자유, 좋아요)
│       ├── community_comment.dart         # CommunityComment (댓글)
│       ├── review.dart                    # Review (경로 후기)
│       └── destination_recommendation.dart # DestinationRecommendation (AI 추천 여행지)
├── data/
│   ├── mock/
│   │   └── mock_trip_data.dart            # 오사카·제주·도쿄·파리 더미 데이터 (N박 N+1일)
│   └── services/
│       ├── gemini_service.dart            # Gemini 2.5 Flash 연동, JSON 추출, 경로 생성/추천
│       ├── weather_service.dart           # OpenWeatherMap, 60+ 도시 매핑
│       ├── weather_monitor_service.dart   # 5초 후 즉시 + 30분 주기 날씨 변화 감지
│       ├── photo_service.dart             # Unsplash 사진 검색
│       ├── recommendation_repository.dart # 추천 여행지 캐싱 (24시간)
│       ├── trip_repository.dart           # 경로 저장·조회·삭제
│       ├── trip_events.dart               # 경로/후기 변경 알림 이벤트 버스
│       ├── community_repository.dart      # 커뮤니티 게시글 저장·조회·좋아요
│       ├── community_comment_repository.dart # 커뮤니티 댓글 저장·조회·삭제
│       ├── community_events.dart          # 커뮤니티 변경 알림 이벤트 버스
│       ├── review_repository.dart         # 경로 후기 저장·조회·삭제
│       └── auth_service.dart              # 이메일 로그인·회원가입·비밀번호 변경·취향 프로필
└── presentation/
    ├── theme/
    │   └── app_theme.dart                 # 전역 테마 (AppBar 타이틀 18px 등)
    ├── widgets/
    │   ├── main_shell.dart                # GNB 바텀 네비게이션 (홈/내경로/커뮤니티/마이페이지)
    │   └── post_list_items.dart           # 커뮤니티 게시글 리스트 아이템 위젯
    └── screens/
        ├── login_screen.dart
        ├── signup_screen.dart
        ├── welcome_screen.dart
        ├── onboarding_screen.dart         # 취향 프로필 5종 + 실내/실외 선호 설정
        ├── home_screen.dart               # AI 추천 카드 + 지금 갈 수 있는 근교 코스 + 날씨 알림
        ├── my_routes_screen.dart          # 저장된 경로 목록 (GNB "내 경로")
        ├── community_screen.dart          # 커뮤니티 게시글 목록 (GNB "커뮤니티")
        ├── post_editor_screen.dart        # 커뮤니티 글 작성/수정
        ├── post_detail_screen.dart        # 커뮤니티 글 상세 + 댓글
        ├── review_editor_screen.dart      # 경로 후기 작성/수정
        ├── review_view_screen.dart        # 경로 후기 보기
        ├── route_input_screen.dart        # 여행지·기간·취향 필터(실내/실외 포함) 입력
        ├── route_result_screen.dart       # 일별 경로 결과 + 날씨 배지
        ├── map_screen.dart                # flutter_map 경로 시각화
        ├── weather_screen.dart            # 시간별·5일 날씨 예보
        ├── mypage_screen.dart             # 마이페이지 (GNB "마이페이지")
        ├── profile_edit_screen.dart       # 프로필 수정
        ├── personal_info_screen.dart      # 개인정보 수정
        ├── my_posts_screen.dart           # 내가 쓴 글
        ├── liked_posts_screen.dart        # 좋아요한 글
        ├── notification_settings_screen.dart # 알림 설정
        ├── app_settings_screen.dart       # 앱 설정
        └── simple_info_screen.dart        # 공지사항/이용약관/개인정보처리방침
```

---

## 4. 화면 흐름도

```mermaid
flowchart TD
    A([앱 시작]) --> B{로그인 여부}
    B -->|비로그인| C[로그인 화면<br/>이메일/비밀번호]
    B -->|로그인| GNB
    C -->|회원가입| S[회원가입<br/>성별·전화번호·생년월일]
    S --> E[온보딩<br/>취향 프로필 5종 + 실내/실외 선호]
    E --> GNB
    C --> GNB

    subgraph GNB[GNB 탭 — StatefulShellRoute]
        D[홈<br/>현재 위치 날씨 + AI 추천 카드]
        MR[내 경로<br/>저장된 경로 목록]
        CM[커뮤니티<br/>게시글 목록]
        M[마이페이지]
    end

    D --> F[여행지·기간·취향 필터 입력<br/>실내/실외 선호 포함]
    D -->|추천 카드 탭| F
    D -->|지금 갈 수 있는 근교 코스| G
    F --> G[Gemini API 경로 생성]
    G --> H[경로 결과 화면<br/>일별 장소 + 날씨 배지]
    H --> I[지도 화면<br/>flutter_map 폴리라인]
    H --> K[경로 저장]
    K --> MR
    MR --> RV[후기 작성/보기]
    D --> W[날씨 검색 화면<br/>시간별·5일 예보]
    D -. 30분 주기 .-> WM[저장된 경로 날씨 변화 감지]
    WM -. 알림 .-> MR

    CM --> PD[게시글 상세 + 댓글]
    CM --> PE[글 작성/수정]
    M --> PR[프로필/개인정보 수정]
    M --> MP[내가 쓴 글 / 좋아요한 글]
```

---

## 5. 핵심 기능별 흐름

| 기능 | Presentation | Domain | Data |
|------|-------------|--------|------|
| 취향 기반 개인화 추천 | `HomeScreen` (가로 스크롤 카드) → `RouteInputScreen` | `DestinationRecommendation` | `GeminiService.recommendDestinations()` + `RecommendationRepository`(24시간 캐싱) + `PhotoService`(Unsplash 사진) |
| AI 경로 생성 (취향 필터 자동 적용) | `RouteInputScreen` → `RouteResultScreen` | `TripPlan`/`DayPlan`/`PlaceItem` | `GeminiService.generateTripPlan()` + `AuthService`(저장된 취향 불러오기) |
| 실내·실외 선호 필터 | `RouteInputScreen` 상세설정 | - | `GeminiService` 프롬프트에 `indoorOutdoor` 조건 반영 |
| 지금 갈 수 있는 근교 코스 | `HomeScreen` (현재 위치/날씨/시각 기반) | `TripPlan` (0박 1일) | `GeminiService.generateTripPlan(nearbyNow: true)` |
| 경로 저장/조회/삭제 | `RouteResultScreen`, `MyRoutesScreen` | `TripPlan` | `TripRepository` (SharedPreferences) + `TripEvents` |
| 경로 후기 작성/조회 | `ReviewEditorScreen`, `ReviewViewScreen`, `MyRoutesScreen` | `Review` | `ReviewRepository` (SharedPreferences) |
| 지도 시각화 | `MapScreen` | `PlaceItem` (lat/lng) | flutter_map + OpenStreetMap |
| 실시간 날씨 반영 추천 | `HomeScreen`, `RouteResultScreen` | - | `WeatherService` → Gemini 프롬프트 조정 |
| 날씨 변화 감지 재추천 (저장된 경로) | (백그라운드) | - | `WeatherMonitorService` (Timer, 30분 주기 + 5초 데모 체크) |
| 날씨 검색 | `WeatherScreen` | - | `WeatherService` |
| 커뮤니티 게시글/댓글(대댓글)/좋아요 | `CommunityScreen`, `PostDetailScreen`, `PostEditorScreen`, `MyPostsScreen`, `LikedPostsScreen` | `CommunityPost`(카테고리: 경로공유/질문/자유), `CommunityComment` | `CommunityRepository`, `CommunityCommentRepository` (SharedPreferences) + `CommunityEvents` |
| 로그인/회원가입/마이페이지/취향 프로필 | `LoginScreen`, `SignupScreen`, `OnboardingScreen`, `MyPageScreen`, `ProfileEditScreen`, `PersonalInfoScreen` | - | `AuthService` (SharedPreferences) |

---

## 6. 라우팅 (GoRouter)

홈/내 경로/커뮤니티/마이페이지 4개 탭은 `StatefulShellRoute.indexedStack` + `MainShell`로 구성된 GNB(바텀 네비게이션) 영역이며,
나머지는 일반 `GoRoute`로 GNB 위에 푸시되는 화면이다.

| 경로 | 화면 | 비고 |
|------|------|------|
| `/` | LoginScreen | |
| `/signup` | SignupScreen | |
| `/welcome` | WelcomeScreen | |
| `/onboarding` | OnboardingScreen | extra: 기존 사용자 정보(Map, 선택) |
| **GNB** `/home` | HomeScreen | AI 추천 + 근교 코스 |
| **GNB** `/my-routes` | MyRoutesScreen | 저장된 경로 목록 |
| **GNB** `/community` | CommunityScreen | 게시글 목록 |
| **GNB** `/mypage` | MyPageScreen | |
| `/route/input` | RouteInputScreen | extra: 목적지/기간(선택) |
| `/route/result` | RouteResultScreen | extra: TripPlan, weather, tripId(선택) |
| `/route/map` | MapScreen | extra: TripPlan |
| `/review/edit` | ReviewEditorScreen | extra: trip, 기존 review(선택) |
| `/review/view` | ReviewViewScreen | extra: trip, review |
| `/community/write` | PostEditorScreen | extra: category, 기존 post(선택) |
| `/community/post` | PostDetailScreen | extra: postId |
| `/mypage/profile-edit` | ProfileEditScreen | extra: user |
| `/mypage/personal-info` | PersonalInfoScreen | extra: user |
| `/mypage/my-posts` | MyPostsScreen | extra: 내 이메일 |
| `/mypage/liked-posts` | LikedPostsScreen | extra: 내 이메일 |
| `/mypage/notifications` | NotificationSettingsScreen | |
| `/mypage/app-settings` | AppSettingsScreen | |
| `/mypage/notice` `/mypage/terms` `/mypage/privacy` | SimpleInfoScreen | 공지/약관/개인정보처리방침 |
| `/weather` | WeatherScreen | extra: lat/lon/city(선택) |

---

## 7. 기술 스택 및 ADR

| 영역 | 기술 | ADR |
|------|------|-----|
| 프레임워크 | Flutter 3.x + Dart 3.x (Web 우선) | [ADR-0001](../.planning/decisions/ADR-0001-mobile-framework.md) |
| 상태관리 | StatefulWidget (계획 단계엔 Riverpod) | [ADR-0002](../.planning/decisions/ADR-0002-state-management.md) → [ADR-0004](../.planning/decisions/ADR-0004-state-storage-pivot.md)로 피벗 |
| 백엔드/저장 | SharedPreferences (계획 단계엔 Firebase) | [ADR-0003](../.planning/decisions/ADR-0003-backend-choice.md) → [ADR-0004](../.planning/decisions/ADR-0004-state-storage-pivot.md)로 피벗 |
| AI 추천 / 경로 생성 | Gemini 2.5 Flash | `gemini_service.dart` |
| 날씨 | OpenWeatherMap API | `weather_service.dart` |
| 추천 여행지 사진 | Unsplash API | `photo_service.dart` |
| 지도 | flutter_map + OpenStreetMap | API 키 불필요 |
| 네비게이션 | GoRouter 14.x | StatefulShellRoute 기반 GNB + 일반 라우트 |

---

## 8. 로컬 저장 구조 (SharedPreferences)

Firebase Firestore 대신 SharedPreferences에 JSON으로 직렬화하여 저장한다 (구조는 추후 Firestore 마이그레이션을 고려해 동일하게 설계).

```
key: "users"                       → [ { name, email, password, gender, phone, birthDate, preferences: {...}, ... }, ... ]
key: "currentUser"                 → { name, email }
key: "saved_trips"                 → [ TripPlan.toJson() + { id, ... }, ... ]
key: "trip_reviews"                → [ Review.toJson(), ... ]
key: "community_posts"             → [ CommunityPost.toJson() (카테고리: 경로공유/질문/자유, 좋아요 포함), ... ]
key: "community_comments"          → [ CommunityComment.toJson(), ... ]
key: "destination_recommendations" → [ DestinationRecommendation.toJson(), ... ]  (+ 캐싱 시각 별도 키)
```

- `TripPlan`: `{ destination, days, dayPlans: [DayPlan] }` — `dayPlans` 길이는 항상 `days + 1` (N박 N+1일)
- `DayPlan`: `{ day, places: [PlaceItem] }`
- `PlaceItem`: `{ time, name, category, description, latitude, longitude }`
- `CommunityPost`: `{ id, category, title, content, author, likes, bookmarks, ... }`
- `CommunityComment`: `{ id, postId, author, content, ... }`
- `Review`: `{ tripId, rating, content, ... }`
- `DestinationRecommendation`: `{ destination, country, reason, days, emoji, photoUrl }`
- 사용자 취향 프로필(`preferences`): 여행 스타일/예산/동행 유형/선호 지역/여행 강도 + 실내·실외 선호(단일 선택)
