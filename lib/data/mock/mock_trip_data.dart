import '../../domain/models/trip_plan.dart';

class MockTripData {
  static TripPlan generate(String destination, int days) {
    final key = destination.toLowerCase();

    if (key.contains('오사카') || key.contains('osaka')) return _osaka(days);
    if (key.contains('제주') || key.contains('jeju')) return _jeju(days);
    if (key.contains('도쿄') || key.contains('tokyo')) return _tokyo(days);
    if (key.contains('파리') || key.contains('paris')) return _paris(days);
    return _generic(destination, days);
  }

  static TripPlan _osaka(int days) => TripPlan(
        destination: '오사카',
        days: days,
        dayPlans: [
          const DayPlan(day: 1, places: [
            PlaceItem(time: '12:00', name: '도톤보리', category: '맛집·관광', description: '오사카의 심장, 화려한 네온사인과 다코야키·타코스의 거리', latitude: 34.6687, longitude: 135.5019),
            PlaceItem(time: '15:00', name: '구로몬 시장', category: '시장', description: '150년 역사의 전통 시장, 신선한 해산물과 현지 먹거리', latitude: 34.6672, longitude: 135.5070),
            PlaceItem(time: '18:00', name: '신사이바시 쇼핑', category: '쇼핑', description: '브랜드 쇼핑과 드럭스토어가 줄지어선 오사카 대표 상권', latitude: 34.6726, longitude: 135.5000),
            PlaceItem(time: '20:00', name: '난바 야식', category: '맛집', description: '이자카야에서 오코노미야키와 현지 맥주로 마무리', latitude: 34.6635, longitude: 135.5018),
          ]),
          const DayPlan(day: 2, places: [
            PlaceItem(time: '09:00', name: '오사카성', category: '역사·문화', description: '도요토미 히데요시가 세운 400년 역사의 성, 주변 공원 산책 포함', latitude: 34.6873, longitude: 135.5259),
            PlaceItem(time: '13:00', name: '우메다 런치', category: '맛집', description: '우메다 지하 푸드코트에서 오사카식 라멘 한 그릇', latitude: 34.7024, longitude: 135.4959),
            PlaceItem(time: '15:00', name: '우메다 스카이 빌딩', category: '전망대', description: '공중 정원 전망대에서 오사카 360° 파노라마 뷰', latitude: 34.7057, longitude: 135.4904),
            PlaceItem(time: '18:00', name: '덴포잔 하버빌리지', category: '관광', description: '해 질 녘 항구 풍경과 관람차, 대형 수족관', latitude: 34.6528, longitude: 135.4317),
          ]),
          const DayPlan(day: 3, places: [
            PlaceItem(time: '09:00', name: '아라시야마 대나무 숲', category: '자연', description: '교토 근교 1시간 거리, 이른 아침 대나무 바람 소리가 압권', latitude: 35.0094, longitude: 135.6780),
            PlaceItem(time: '12:00', name: '텐류지 정원', category: '역사·문화', description: '세계문화유산 선원, 연못 정원과 함께하는 도시락 피크닉', latitude: 35.0149, longitude: 135.6729),
            PlaceItem(time: '14:30', name: '금각사', category: '역사·문화', description: '황금빛 사리전이 연못에 반사되는 교토 최대 명소', latitude: 35.0394, longitude: 135.7292),
            PlaceItem(time: '17:00', name: '기요미즈데라', category: '역사·문화', description: '목재 무대에서 내려다보는 교토 시내, 석양 감상 명소', latitude: 34.9948, longitude: 135.7850),
          ]),
          const DayPlan(day: 4, places: [
            PlaceItem(time: '09:00', name: '유니버설 스튜디오 재팬', category: '테마파크', description: '해리포터, 슈퍼닌텐도 월드 — 반일 코스 추천', latitude: 34.6654, longitude: 135.4323),
            PlaceItem(time: '16:00', name: '린쿠 프리미엄 아웃렛', category: '쇼핑', description: '공항 근처 아웃렛, 출국 전 마지막 쇼핑 기회', latitude: 34.4378, longitude: 135.3157),
          ]),
        ].take(days + 1).toList(),
      );

  static TripPlan _jeju(int days) => TripPlan(
        destination: '제주도',
        days: days,
        dayPlans: [
          const DayPlan(day: 1, places: [
            PlaceItem(time: '11:00', name: '성산일출봉', category: '자연', description: '유네스코 자연유산, 분화구 트레킹 1시간 30분', latitude: 33.4587, longitude: 126.9425),
            PlaceItem(time: '14:00', name: '섭지코지', category: '자연', description: '유채꽃과 현무암이 어우러진 제주 동쪽 해안 산책로', latitude: 33.4307, longitude: 126.9267),
            PlaceItem(time: '17:00', name: '우도 전망', category: '자연', description: '해 질 녘 우도 뷰 감상 후 숙소로', latitude: 33.5022, longitude: 126.9531),
            PlaceItem(time: '19:00', name: '서귀포 해산물 저녁', category: '맛집', description: '갈치조림과 고등어회, 제주 최고의 해산물 식당가', latitude: 33.2503, longitude: 126.5600),
          ]),
          const DayPlan(day: 2, places: [
            PlaceItem(time: '07:00', name: '우도 페리 탑승', category: '관광', description: '성산항에서 15분, 자전거 대여 후 우도 1주', latitude: 33.5022, longitude: 126.9531),
            PlaceItem(time: '11:00', name: '우도 땅콩 아이스크림', category: '맛집', description: '우도 특산 땅콩으로 만든 아이스크림', latitude: 33.5100, longitude: 126.9600),
            PlaceItem(time: '14:00', name: '함덕 해수욕장', category: '자연', description: '에메랄드빛 얕은 바다, 스노클링 최적 포인트', latitude: 33.5437, longitude: 126.6693),
            PlaceItem(time: '18:00', name: '제주시 동문 재래시장', category: '시장·맛집', description: '흑돼지 구이와 오메기떡, 현지인이 추천하는 야시장', latitude: 33.5108, longitude: 126.5241),
          ]),
          const DayPlan(day: 3, places: [
            PlaceItem(time: '09:00', name: '한라산 영실 코스', category: '자연', description: '왕복 5.8km 3시간, 병풍바위와 구상나무 군락지', latitude: 33.3617, longitude: 126.5097),
            PlaceItem(time: '14:00', name: '천지연 폭포', category: '자연', description: '22m 높이 폭포, 밤에 조명이 아름다운 명소', latitude: 33.2508, longitude: 126.5595),
            PlaceItem(time: '16:30', name: '애월 해안도로 드라이브', category: '자연', description: '제주 서쪽 카페 로드, 한담해변 석양이 압권', latitude: 33.4632, longitude: 126.3162),
          ]),
        ].take(days + 1).toList(),
      );

  static TripPlan _tokyo(int days) => TripPlan(
        destination: '도쿄',
        days: days,
        dayPlans: [
          const DayPlan(day: 1, places: [
            PlaceItem(time: '10:00', name: '아사쿠사·센소지', category: '역사·문화', description: '도쿄 최고 사원, 나카미세 쇼핑 거리와 인력거 체험', latitude: 35.7148, longitude: 139.7967),
            PlaceItem(time: '13:00', name: '스카이트리 전망대', category: '전망대', description: '634m 세계 최고 전파탑에서 도쿄 전경 감상', latitude: 35.7101, longitude: 139.8107),
            PlaceItem(time: '16:00', name: '아키하바라', category: '쇼핑', description: '전자·애니메이션·피규어의 성지, 요도바시카메라', latitude: 35.7023, longitude: 139.7745),
            PlaceItem(time: '20:00', name: '우에노 이자카야', category: '맛집', description: '야키토리와 사와를 곁들인 도쿄 현지 저녁', latitude: 35.7133, longitude: 139.7777),
          ]),
          const DayPlan(day: 2, places: [
            PlaceItem(time: '09:00', name: '시부야 스크램블 교차로', category: '관광', description: '세계에서 가장 바쁜 교차로, 이른 아침이 사진 명소', latitude: 35.6595, longitude: 139.7005),
            PlaceItem(time: '11:00', name: '하라주쿠·다케시타 거리', category: '쇼핑', description: '크레페와 팝컬처, 일본 10대 패션의 중심지', latitude: 35.6702, longitude: 139.7028),
            PlaceItem(time: '14:00', name: '메이지 신궁', category: '자연·문화', description: '도심 속 70만 평 숲, 쇼와 천황 부부를 기리는 신사', latitude: 35.6763, longitude: 139.6993),
            PlaceItem(time: '17:00', name: '오모테산도 카페 거리', category: '카페·쇼핑', description: '일본 최고급 부티크와 애프터눈 티 카페', latitude: 35.6650, longitude: 139.7128),
          ]),
          const DayPlan(day: 3, places: [
            PlaceItem(time: '10:00', name: '신주쿠 교엔', category: '자연', description: '58.3ha 국립 정원, 계절 꽃과 피크닉', latitude: 35.6851, longitude: 139.7100),
            PlaceItem(time: '13:00', name: '신주쿠 가부키초', category: '맛집·쇼핑', description: '도쿄 최대 번화가에서 라멘 맛집 탐방', latitude: 35.6940, longitude: 139.7038),
            PlaceItem(time: '16:00', name: '도쿄 도청 전망대', category: '전망대', description: '무료 전망대에서 날씨 좋으면 후지산도 보임', latitude: 35.6896, longitude: 139.6921),
            PlaceItem(time: '19:00', name: '오오쿠보 코리아타운', category: '맛집', description: '삼겹살과 치즈 닭갈비, 한국 음식이 그리울 때', latitude: 35.7017, longitude: 139.6993),
          ]),
        ].take(days + 1).toList(),
      );

  static TripPlan _paris(int days) => TripPlan(
        destination: '파리',
        days: days,
        dayPlans: [
          const DayPlan(day: 1, places: [
            PlaceItem(time: '10:00', name: '에펠탑', category: '관광', description: '파리의 상징, 2층 전망대 권장 — 정상은 바람이 강함', latitude: 48.8584, longitude: 2.2945),
            PlaceItem(time: '13:00', name: '레 두 마고 카페', category: '카페', description: '생제르맹데프레의 역사적 카페, 헤밍웨이가 사랑했던 곳', latitude: 48.8540, longitude: 2.3330),
            PlaceItem(time: '15:00', name: '루브르 박물관', category: '문화', description: '모나리자·비너스 중심으로 3시간 집중 관람 코스', latitude: 48.8606, longitude: 2.3376),
            PlaceItem(time: '20:00', name: '몽마르트 야경', category: '관광', description: '사크레쾨르 성당 계단에서 파리 야경 감상', latitude: 48.8867, longitude: 2.3431),
          ]),
          const DayPlan(day: 2, places: [
            PlaceItem(time: '09:00', name: '베르사유 궁전', category: '역사·문화', description: '루이 14세의 거울의 방과 18km² 정원 — 반일 코스', latitude: 48.8049, longitude: 2.1204),
            PlaceItem(time: '15:00', name: '마레 지구 산책', category: '쇼핑', description: '피카소 미술관, 빈티지샵, 팔라펠 맛집이 밀집', latitude: 48.8566, longitude: 2.3590),
            PlaceItem(time: '19:00', name: '센 강 유람선 석식', category: '관광·맛집', description: '바토무슈 2시간 크루즈, 일몰과 야경을 동시에', latitude: 48.8600, longitude: 2.3050),
          ]),
        ].take(days + 1).toList(),
      );

  static TripPlan _generic(String destination, int days) {
    final List<DayPlan> plans = List.generate(days + 1, (i) {
      return DayPlan(day: i + 1, places: [
        PlaceItem(time: '09:30', name: '$destination 대표 명소', category: '관광', description: 'AI가 취향 프로필을 분석해 선택한 핵심 스팟'),
        PlaceItem(time: '12:30', name: '현지 맛집 점심', category: '맛집', description: '구글 리뷰 4.5 이상, 현지인이 즐겨 찾는 숨은 맛집'),
        PlaceItem(time: '15:00', name: '문화·쇼핑 거리', category: '문화·쇼핑', description: '당일 날씨와 선호도를 반영한 실시간 추천 장소'),
        PlaceItem(time: '19:00', name: '저녁 식사 & 야경', description: '해 질 녘 뷰가 좋은 레스토랑에서 하루 마무리', category: '맛집'),
      ]);
    });
    return TripPlan(destination: destination, days: days, dayPlans: plans);
  }
}
