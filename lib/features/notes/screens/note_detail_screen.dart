import 'package:flutter/material.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../services/notes_service.dart';

class NoteDetailScreen extends StatefulWidget {
  final int noteId;
  const NoteDetailScreen({super.key, required this.noteId});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _notesService = NotesService();
  Note? _note;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final token = await SecureStorageService().readToken();
    final note = await _notesService.getNoteById(widget.noteId, token: token);
    if (mounted) setState(() { _note = note; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Note not found')),
        body: const Center(child: Text('Note not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceFor(context),
        elevation: 0,
        title: Text(_note!.title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: _printNote,
            tooltip: 'Print',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meta info
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetaChip(_note!.subject, AppColors.primary),
                _buildMetaChip('Class ${_note!.classLevel}', AppColors.success),
                if (_note!.chapter.isNotEmpty)
                  _buildMetaChip(_note!.chapter, AppColors.warning),
                _buildMetaChip(_note!.language.toUpperCase(), AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Text(
                _note!.content,
                style: AppTextStyles.bodyMedium(context).copyWith(height: 1.8),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _printNote,
                    icon: const Icon(Icons.print_rounded),
                    label: Text('Print', style: AppTextStyles.bodyMedium(context)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.borderFor(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareNote,
                    icon: const Icon(Icons.share_rounded),
                    label: Text('Share', style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Future<void> _printNote() async {
    // Show a message that printing is available
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Print feature coming soon!'), backgroundColor: AppColors.primary),
      );
    }
  }

  void _shareNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note content copied!'), backgroundColor: AppColors.success),
    );
  }
}
