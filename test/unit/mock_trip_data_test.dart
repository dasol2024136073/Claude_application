import 'package:flutter_test/flutter_test.dart';
import 'package:travel_ai/data/mock/mock_trip_data.dart';

void main() {
  group('MockTripData.generate', () {
    test('should_return_osaka_plan_when_keyword_is_오사카', () {
      final plan = MockTripData.generate('오사카', 2);
      expect(plan.destination, '오사카');
    });

    test('should_return_osaka_plan_when_keyword_is_osaka_english', () {
      final plan = MockTripData.generate('osaka', 1);
      expect(plan.destination, '오사카');
    });

    test('should_return_jeju_plan_when_keyword_is_제주', () {
      final plan = MockTripData.generate('제주', 2);
      expect(plan.destination, '제주도');
    });

    test('should_limit_dayplans_to_requested_days', () {
      final plan = MockTripData.generate('도쿄', 2);
      expect(plan.dayPlans.length, 2);
    });

    test('should_return_generic_plan_when_unknown_destination', () {
      final plan = MockTripData.generate('뉴욕', 3);
      expect(plan.destination, '뉴욕');
      expect(plan.dayPlans.length, 3);
    });

    test('should_return_empty_dayplans_when_zero_days', () {
      final plan = MockTripData.generate('파리', 0);
      expect(plan.dayPlans, isEmpty);
    });

    test('should_have_4_places_on_day1_for_osaka', () {
      final plan = MockTripData.generate('오사카', 1);
      expect(plan.dayPlans.first.places.length, 4);
    });
  });
}
