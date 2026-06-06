import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  String? _gender;
  DateTime? _birthDate;

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final phone = _phoneController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('이름, 이메일, 비밀번호는 필수입니다');
      return;
    }
    if (password.length < 6) {
      _showError('비밀번호는 6자 이상이어야 합니다');
      return;
    }
    if (phone.isEmpty) {
      _showError('전화번호를 입력해주세요');
      return;
    }
    if (_birthDate == null) {
      _showError('생년월일을 선택해주세요');
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService.register(
      name, email, password,
      gender: _gender,
      phone: phone,
      birthDate: '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료됐습니다. 로그인해주세요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      context.go('/');
    } else {
      _showError(result.error ?? '회원가입 실패');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[700]),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: '생년월일 선택',
      locale: const Locale('ko'),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('환영합니다!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            Text('계정을 만들어 AI 여행 경로를 시작하세요',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 36),
            _buildField('이름 *', '홍길동', _nameController,
                type: TextInputType.name),
            const SizedBox(height: 16),
            _buildField('이메일 *', 'example@email.com', _emailController,
                type: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildGenderField(),
            const SizedBox(height: 16),
            _buildField('전화번호 *', '010-0000-0000', _phoneController,
                type: TextInputType.phone),
            const SizedBox(height: 16),
            _buildBirthDateField(),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _isLoading ? null : _signup,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('가입하기',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('이미 계정이 있으신가요?',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('로그인',
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90D9))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('비밀번호 *', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          decoration: InputDecoration(
            hintText: '6자 이상',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400]),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE8E8E8))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('성별', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        Row(
          children: [
            _genderChip('남성', '남성'),
            const SizedBox(width: 10),
            _genderChip('여성', '여성'),
            const SizedBox(width: 10),
            _genderChip('선택 안 함', '선택 안 함'),
          ],
        ),
      ],
    );
  }

  Widget _genderChip(String label, String value) {
    final selected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = selected ? null : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF4A90D9) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF4A90D9) : const Color(0xFFE8E8E8),
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF1A1A2E),
            )),
      ),
    );
  }

  Widget _buildBirthDateField() {
    final label = _birthDate == null
        ? '선택하기'
        : '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('생년월일 *', style: TextStyle(fontSize: 14,
            fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickBirthDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.grey[400]),
                const SizedBox(width: 10),
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      color: _birthDate == null ? Colors.grey[400] : const Color(0xFF1A1A2E),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
