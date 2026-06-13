import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/community_repository.dart';
import '../../data/services/trip_repository.dart';
import '../../domain/models/community_post.dart';
import '../theme/app_theme.dart';

class PostEditorScreen extends StatefulWidget {
  final PostCategory category;
  final CommunityPost? existingPost;

  const PostEditorScreen({super.key, required this.category, this.existingPost});

  @override
  State<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends State<PostEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late List<String> _photos;
  late bool _isAnonymous;
  String? _tripDestination;
  int? _tripDays;
  int _rating = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingPost;
    _titleController = TextEditingController(text: p?.title ?? '');
    _contentController = TextEditingController(text: p?.content ?? '');
    _photos = List.of(p?.photos ?? []);
    _isAnonymous = p?.isAnonymous ?? false;
    _tripDestination = p?.tripDestination;
    _tripDays = p?.tripDays;
    _rating = p?.rating ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 70);
    if (files.isEmpty) return;
    final encoded = <String>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final mime = file.mimeType ?? 'image/jpeg';
      encoded.add('data:$mime;base64,${base64Encode(bytes)}');
    }
    setState(() => _photos.addAll(encoded));
  }

  Future<void> _pickTrip() async {
    final trips = (await TripRepository.getAll()).where((t) => t.visited).toList();
    if (!mounted) return;

    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('다녀온 경로가 없습니다. 내 경로에서 먼저 다녀온 경로로 표시해주세요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('공유할 경로 선택', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView(
                shrinkWrap: true,
                children: trips.map((t) => ListTile(
                      leading: Icon(Icons.flight_takeoff_rounded, color: AppTheme.primary),
                      title: Text(t.plan.destination, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${t.plan.days}박 ${t.plan.days + 1}일'),
                      onTap: () {
                        setState(() {
                          _tripDestination = t.plan.destination;
                          _tripDays = t.plan.days;
                        });
                        Navigator.of(context).pop();
                      },
                    )).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _saving = true);
    final user = await AuthService.getCurrentUser();

    final post = CommunityPost(
      id: widget.existingPost?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      category: widget.category,
      isAnonymous: _isAnonymous,
      authorName: widget.existingPost?.authorName ?? (user?['name'] ?? '여행자'),
      authorEmail: widget.existingPost?.authorEmail ?? (user?['email'] ?? 'guest'),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      photos: _photos,
      tripDestination: _tripDestination,
      tripDays: _tripDays,
      rating: widget.category == PostCategory.routeShare && _rating > 0 ? _rating : null,
      likedBy: widget.existingPost?.likedBy ?? const [],
      commentCount: widget.existingPost?.commentCount ?? 0,
      createdAt: widget.existingPost?.createdAt ?? DateTime.now(),
    );

    await CommunityRepository.save(post);

    if (!mounted) return;
    setState(() => _saving = false);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingPost != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isEdit ? '${widget.category.label} 수정' : '${widget.category.label} 작성', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.category == PostCategory.routeShare) ...[
              const Text('경로 연결 (선택)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              if (_tripDestination != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flight_takeoff_rounded, color: AppTheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('$_tripDestination · $_tripDays박 ${(_tripDays ?? 0) + 1}일',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _tripDestination = null;
                          _tripDays = null;
                        }),
                        child: Icon(Icons.close, size: 18, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickTrip,
                  icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                  label: const Text('다녀온 경로 불러오기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              const SizedBox(height: 16),

              const Text('별점 (선택)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return IconButton(
                    onPressed: () => setState(() => _rating = (_rating == i + 1) ? 0 : i + 1),
                    icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded,
                        color: const Color(0xFFFFC107), size: 32),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40),
                  );
                }),
              ),
              const SizedBox(height: 16),
            ],

            const Text('제목', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목을 입력해주세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),

            const Text('내용', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '내용을 입력해주세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 20),

            const Text('사진 (선택)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._photos.asMap().entries.map((e) => _MediaThumb(
                      child: Image.memory(
                        base64Decode(e.value.split(',').last),
                        width: 88, height: 88, fit: BoxFit.cover,
                      ),
                      onRemove: () => setState(() => _photos.removeAt(e.key)),
                    )),
                _AddPhotoButton(onTap: _pickPhotos),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
                activeThumbColor: AppTheme.primary,
                title: const Text('익명으로 작성', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                subtitle: Text('작성자 이름이 "익명"으로 표시됩니다', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(isEdit ? '수정 완료' : '게시하기',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _MediaThumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: child),
        Positioned(
          top: 4, right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPhotoButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88, height: 88,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[400], size: 28),
      ),
    );
  }
}
