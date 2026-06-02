import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/data/mock/mock_trip_data.dart';

// 시나리오: 사용자가 여행지와 기간을 입력하면 일정이 생성된다
void main() {
  group('시나리오: 오사카 2박3일 여행 경로 생성', () {
    test('should_generate_complete_2day_plan_when_user_requests_osaka', () {
      const destination = '오사카';
      const days = 2;

      final plan = MockTripData.generate(destination, days);

      // 목적지가 맞는지
      expect(plan.destination, '오사카');
      // 요청한 일수만큼 일정이 있는지
      expect(plan.dayPlans.length, days);
      // 각 일정에 장소가 하나 이상 있는지
      for (final dayPlan in plan.dayPlans) {
        expect(dayPlan.places, isNotEmpty,
            reason: '${dayPlan.day}일차에 장소가 없습니다');
      }
      // 1일차에 도톤보리가 포함되는지
      final day1Names = plan.dayPlans.first.places.map((p) => p.name).toList();
      expect(day1Names, contains('도톤보리'));
      // 3일차는 포함되지 않는지 (2박3일이므로)
      expect(plan.dayPlans.length, lessThanOrEqualTo(2));
    });
  });
}
