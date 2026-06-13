import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/community_repository.dart';
import '../../data/services/review_repository.dart';
import '../../data/services/trip_repository.dart';
import '../../domain/models/community_post.dart';
import '../../domain/models/review.dart';
import '../theme/app_theme.dart';

class ReviewEditorScreen extends StatefulWidget {
  final SavedTrip trip;
  final Review? existingReview;

  const ReviewEditorScreen({super.key, required this.trip, this.existingReview});

  @override
  State<ReviewEditorScreen> createState() => _ReviewEditorScreenState();
}

class _ReviewEditorScreenState extends State<ReviewEditorScreen> {
  late int _rating;
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late List<String> _photos;
  late List<String> _videos;
  late ReviewVisibility _visibility;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReview;
    _rating = r?.rating ?? 0;
    _titleController = TextEditingController(text: r?.title ?? '');
    _textController = TextEditingController(text: r?.text ?? '');
    _photos = List.of(r?.photos ?? []);
    _videos = List.of(r?.videos ?? []);
    _visibility = r?.visibility ?? ReviewVisibility.private;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
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

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime = file.mimeType ?? 'video/mp4';
    setState(() => _videos.add('data:$mime;base64,${base64Encode(bytes)}'));
  }

  Future<void> _save() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점을 선택해주세요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _saving = true);
    final user = await AuthService.getCurrentUser();

    final review = Review(
      id: widget.existingReview?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      tripId: widget.trip.id,
      destination: widget.trip.plan.destination,
      days: widget.trip.plan.days,
      rating: _rating,
      title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
      text: _textController.text.trim().isEmpty ? null : _textController.text.trim(),
      photos: _photos,
      videos: _videos,
      visibility: _visibility,
      createdAt: widget.existingReview?.createdAt ?? DateTime.now(),
      authorName: user?['name'] ?? '여행자',
    );

    await ReviewRepository.save(review);
    if (!widget.trip.visited) {
      await TripRepository.setVisited(widget.trip.id, true);
    }

    final communityPostId = 'review_${widget.trip.id}';
    if (_visibility == ReviewVisibility.public) {
      final existing = await CommunityRepository.getById(communityPostId);
      final content = _textController.text.trim();
      final titleText = _titleController.text.trim();
      await CommunityRepository.save(CommunityPost(
        id: communityPostId,
        category: PostCategory.routeShare,
        authorName: review.authorName,
        authorEmail: user?['email'] ?? 'guest',
        title: titleText.isNotEmpty ? titleText : '${widget.trip.plan.destination} 여행 후기',
        content: content.isEmpty ? '${widget.trip.plan.destination} 여행에 대한 별점 후기를 공유했습니다.' : content,
        photos: _photos,
        tripDestination: widget.trip.plan.destination,
        tripDays: widget.trip.plan.days,
        rating: _rating,
        likedBy: existing?.likedBy ?? const [],
        commentCount: existing?.commentCount ?? 0,
        createdAt: existing?.createdAt ?? DateTime.now(),
      ));
    } else {
      await CommunityRepository.delete(communityPostId);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReview != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isEdit ? '후기 수정' : '후기 작성', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.trip.plan.destination,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text('${widget.trip.plan.days}박 ${widget.trip.plan.days + 1}일',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const SizedBox(height: 24),

            const Text('제목 (선택)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '후기 제목을 입력해주세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            const Text('별점', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final filled = i < _rating;
                return IconButton(
                  onPressed: () => setState(() => _rating = i + 1),
                  icon: Icon(filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFFFC107), size: 36),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 44),
                );
              }),
            ),
            const SizedBox(height: 24),

            const Text('후기 (선택)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '여행은 어떠셨나요? 다른 사람들과 공유할 이야기를 적어보세요',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

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
                _AddMediaButton(icon: Icons.add_photo_alternate_outlined, onTap: _pickPhotos),
              ],
            ),
            const SizedBox(height: 24),

            const Text('동영상 (선택)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._videos.asMap().entries.map((e) => _MediaThumb(
                      child: Container(
                        width: 88, height: 88,
                        color: Colors.black87,
                        child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 32),
                      ),
                      onRemove: () => setState(() => _videos.removeAt(e.key)),
                    )),
                if (_videos.isEmpty)
                  _AddMediaButton(icon: Icons.video_call_outlined, onTap: _pickVideo),
              ],
            ),
            const SizedBox(height: 28),

            const Text('공개 설정', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            _VisibilityOption(
              icon: Icons.public,
              title: '커뮤니티에 공개',
              subtitle: '다른 사용자와 게시물로 공유합니다',
              selected: _visibility == ReviewVisibility.public,
              onTap: () => setState(() => _visibility = ReviewVisibility.public),
            ),
            const SizedBox(height: 10),
            _VisibilityOption(
              icon: Icons.lock_outline,
              title: '나만 보기',
              subtitle: '내 경로에서만 확인할 수 있습니다',
              selected: _visibility == ReviewVisibility.private,
              onTap: () => setState(() => _visibility = ReviewVisibility.private),
            ),
            const SizedBox(height: 32),

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
                    : Text(isEdit ? '수정 완료' : '후기 등록',
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

class _AddMediaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AddMediaButton({required this.icon, required this.onTap});

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
        child: Icon(icon, color: Colors.grey[400], size: 28),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : const Color(0xFFE8E8E8), width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppTheme.primary : Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                      color: selected ? AppTheme.primary : const Color(0xFF1A1A2E))),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppTheme.primary : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
