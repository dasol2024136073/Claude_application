import 'package:flutter/foundation.dart';

/// 커뮤니티 게시글/댓글 데이터가 변경될 때마다 값을 증가시켜
/// 목록 화면이 다시 불러오도록 알리는 이벤트 버스.
class CommunityEvents {
  static final ValueNotifier<int> changed = ValueNotifier(0);

  static void notify() => changed.value++;
}
