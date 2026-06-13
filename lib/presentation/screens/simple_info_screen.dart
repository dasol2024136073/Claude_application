import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SimpleInfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const SimpleInfoScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), height: 1.7),
          ),
        ),
      ),
    );
  }
}

class AppInfoContents {
  static const notice = '''공지사항

[2026.06.13] Tripia 서비스가 시작되었습니다.
AI가 여행 일정을 자동으로 설계해주는 서비스를 만나보세요.

[업데이트 안내]
- 여행 날짜/입국·출국 시간/숙소 위치를 반영한 맞춤 일정 생성 기능이 추가되었습니다.
- 내 경로 저장 및 후기 작성 기능을 이용해보세요.

앞으로도 더 나은 서비스를 위해 노력하겠습니다. 감사합니다.''';

  static const terms = '''이용약관

제1조 (목적)
이 약관은 Tripia(이하 "서비스")가 제공하는 여행 일정 추천 서비스의 이용 조건 및 절차, 이용자와 서비스 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (서비스의 제공)
서비스는 AI를 활용한 여행 일정 추천, 경로 저장, 후기 작성, 커뮤니티 게시판 등의 기능을 제공합니다.

제3조 (이용자의 의무)
이용자는 서비스 이용 시 관계 법령, 본 약관의 규정, 이용안내 및 서비스와 관련하여 공지한 주의사항을 준수하여야 합니다.

제4조 (게시물의 관리)
이용자가 작성한 게시물의 저작권은 작성자에게 있으며, 서비스 운영 정책에 위반되는 게시물은 사전 통지 없이 삭제될 수 있습니다.

제5조 (책임의 한계)
AI가 생성한 여행 일정은 참고용 정보이며, 실제 운영시간, 휴무일 등은 방문 전 별도로 확인하시기 바랍니다.''';

  static const privacy = '''개인정보처리방침

Tripia는 이용자의 개인정보를 중요하게 생각하며, 다음과 같은 정책을 운영합니다.

1. 수집하는 개인정보 항목
회원가입 시 이름, 이메일, 비밀번호, 성별, 전화번호, 생년월일 등을 수집할 수 있습니다.

2. 개인정보의 이용 목적
- 회원 식별 및 서비스 이용
- 맞춤형 여행 일정 추천
- 고객 문의 대응

3. 개인정보의 보관 및 파기
이용자가 회원 탈퇴를 요청하는 경우, 관련 법령에 따른 보관 의무가 없는 한 지체 없이 해당 정보를 파기합니다.

4. 개인정보의 제3자 제공
서비스는 법령에 근거하거나 이용자의 동의가 있는 경우를 제외하고 개인정보를 외부에 제공하지 않습니다.

5. 이용자의 권리
이용자는 언제든지 자신의 개인정보를 조회, 수정, 삭제할 수 있으며, 회원 탈퇴를 통해 개인정보 처리의 정지를 요구할 수 있습니다.''';
}
