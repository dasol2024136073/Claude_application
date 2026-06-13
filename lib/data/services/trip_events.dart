import 'package:flutter/foundation.dart';

/// 경로/후기 데이터가 변경될 때마다 값을 증가시켜
/// 다른 탭(화면)이 목록을 다시 불러오도록 알리는 이벤트 버스.
class TripEvents {
  static final ValueNotifier<int> changed = ValueNotifier(0);

  static void notify() => changed.value++;
}
