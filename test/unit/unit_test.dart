// 기능 단위 테스트: 도메인 모델과 MockTripData의 핵심 기능 검증
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/domain/models/trip_plan.dart';
import 'package:travel_ai/data/mock/mock_trip_data.dart';

void main() {
  group('TripPlan — 모델 필드 저장', () {
    test('destination을 정확히 저장한다', () {
      const plan = TripPlan(destination: '도쿄', days: 3, dayPlans: []);
      expect(plan.destination, '도쿄');
    });

    test('days를 정확히 저장한다', () {
      const plan = TripPlan(destination: '파리', days: 5, dayPlans: []);
      expect(plan.days, 5);
    });

    test('빈 dayPlans를 허용한다', () {
      const plan = TripPlan(destination: '서울', days: 0, dayPlans: []);
      expect(plan.dayPlans, isEmpty);
    });
  });

  group('DayPlan — 일차 구성', () {
    test('day 번호를 정확히 저장한다', () {
      const day = DayPlan(day: 2, places: []);
      expect(day.day, 2);
    });

    test('places 리스트를 정확히 저장한다', () {
      const place = PlaceItem(time: '09:00', name: '에펠탑', category: '관광', description: '파리의 상징');
      const day = DayPlan(day: 1, places: [place]);
      expect(day.places.length, 1);
    });
  });

  group('PlaceItem — 장소 필드', () {
    test('모든 필드를 정확히 저장한다', () {
      const place = PlaceItem(
        time: '10:00', name: '도톤보리', category: '맛집·관광', description: '오사카의 심장',
      );
      expect(place.time, '10:00');
      expect(place.name, '도톤보리');
      expect(place.category, '맛집·관광');
      expect(place.description, '오사카의 심장');
    });
  });

  group('MockTripData.generate — 목적지별 분기', () {
    test('오사카 키워드로 오사카 플랜을 반환한다', () {
      final plan = MockTripData.generate('오사카', 2);
      expect(plan.destination, '오사카');
    });

    test('영문 osaka로도 오사카 플랜을 반환한다', () {
      final plan = MockTripData.generate('osaka', 1);
      expect(plan.destination, '오사카');
    });

    test('제주 키워드로 제주도 플랜을 반환한다', () {
      final plan = MockTripData.generate('제주', 2);
      expect(plan.destination, '제주도');
    });

    test('도쿄 키워드로 도쿄 플랜을 반환한다', () {
      final plan = MockTripData.generate('도쿄', 1);
      expect(plan.destination, '도쿄');
    });

    test('파리 키워드로 파리 플랜을 반환한다', () {
      final plan = MockTripData.generate('파리', 1);
      expect(plan.destination, '파리');
    });

    test('요청한 일수만큼만 dayPlans를 반환한다', () {
      final plan = MockTripData.generate('도쿄', 2);
      expect(plan.dayPlans.length, 2);
    });

    test('오사카 1일차에 장소가 4개다', () {
      final plan = MockTripData.generate('오사카', 1);
      expect(plan.dayPlans.first.places.length, 4);
    });
  });
}
