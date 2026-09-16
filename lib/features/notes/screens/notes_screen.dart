import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/notes_service.dart';
import 'note_detail_screen.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _notesService = NotesService();
  List<Note> _notes = [];
  bool _loading = true;
  String? _selectedClass;
  String? _selectedSubject;

  static const _classes = ['3', '4', '5', '6', '7', '8'];
  static const _subjects = ['Math', 'Science', 'English', 'Bengali', 'Social Science', 'Physics', 'Chemistry', 'Biology'];

  @override
  void initState() {
    super.initState();
    // Auto-select user's class from profile
    final user = ref.read(authProvider).user;
    if (user != null && user.studentClass.isNotEmpty && _classes.contains(user.studentClass)) {
      _selectedClass = user.studentClass;
    }
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    try {
      final storage = SecureStorageService();
      final token = await storage.readToken();
      final notes = await _notesService.getNotes(
        token: token,
        classLevel: _selectedClass,
        subject: _selectedSubject,
      );
      if (mounted) setState(() { _notes = notes; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceFor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('নোটস', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              children: [
                _buildFilterChip('All Classes', _selectedClass == null, () {
                  setState(() => _selectedClass = null);
                  _loadNotes();
                }),
                const SizedBox(width: 8),
                ..._classes.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip('Class $c', _selectedClass == c, () {
                    setState(() => _selectedClass = c);
                    _loadNotes();
                  }),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              children: [
                _buildFilterChip('All Subjects', _selectedSubject == null, () {
                  setState(() => _selectedSubject = null);
                  _loadNotes();
                }),
                const SizedBox(width: 8),
                ..._subjects.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(s, _selectedSubject == s, () {
                    setState(() => _selectedSubject = s);
                    _loadNotes();
                  }),
                )),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Notes list
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadNotes,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                          itemCount: _notes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) => _buildNoteCard(_notes[index]),
                        ),
                      ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderFor(context)),
        ),
        child: Text(
          label,
          style: AppTextStyles.label(context).copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text('No Notes Found', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text('Check back soon for new notes!', style: AppTextStyles.bodySmall(context)),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    final typeIcon = note.type == 'notes'
        ? Icons.note_alt_rounded
        : note.type == 'guide'
            ? Icons.menu_book_rounded
            : Icons.article_rounded;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NoteDetailScreen(noteId: note.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: Icon(typeIcon, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('${note.subject} · Class ${note.classLevel}', style: AppTextStyles.bodySmall(context)),
                  if (note.chapter.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(note.chapter, style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
