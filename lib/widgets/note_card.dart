import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NoteCard — kartu catatan pribadi di DetailScreen
// Mode baca: tampilkan catatan + tombol Edit
// Mode edit: TextField multiline + Simpan + Batal
// ─────────────────────────────────────────────────────────────────────────────

class NoteCard extends StatefulWidget {
  final String? initialNote;
  /// Dipanggil saat user menekan Simpan; terima String note baru
  final Future<void> Function(String note) onSave;

  const NoteCard({
    super.key,
    this.initialNote,
    required this.onSave,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late final TextEditingController _ctrl;
  bool _editing = false;
  bool _saving = false;
  bool _justSaved = false; // tampilkan indikator "Tersimpan ✓"

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(_ctrl.text.trim());
    if (mounted) {
      setState(() {
        _saving = false;
        _editing = false;
        _justSaved = true;
      });
      // Reset indikator setelah 2 detik
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justSaved = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasNote =
        widget.initialNote != null && widget.initialNote!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _editing ? _buildEditMode() : _buildReadMode(hasNote),
        ),
      ),
    );
  }

  // ── Mode Baca ─────────────────────────────────────────────────────────────
  Widget _buildReadMode(bool hasNote) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Catatan teks
        if (hasNote) ...[
          Text(
            _ctrl.text.isEmpty ? (widget.initialNote ?? '') : _ctrl.text,
            style: AppTextStyles.bodyMd(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
        ] else ...[
          Text(
            'Belum ada catatan. Ketuk Edit untuk menambahkan.',
            style: AppTextStyles.bodyMd(color: AppColors.textHint)
                .copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Indikator "Tersimpan ✓"
            AnimatedOpacity(
              opacity: _justSaved ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Tersimpan',
                      style: AppTextStyles.captionSm(
                          color: AppColors.success)),
                ],
              ),
            ),
            // Tombol edit
            TextButton.icon(
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_note_rounded, size: 16),
              label: Text(hasNote ? 'Edit' : 'Tambah Catatan'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: AppTextStyles.label(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Mode Edit ─────────────────────────────────────────────────────────────
  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _ctrl,
          maxLines: 4,
          autofocus: true,
          style: AppTextStyles.bodyMd(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText:
                'Contoh: Kurangi garam, tambah sedikit cabai rawit…',
            hintStyle: AppTextStyles.bodyMd(color: AppColors.textHint)
                .copyWith(fontStyle: FontStyle.italic),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Batal
            TextButton(
              onPressed: () {
                _ctrl.text = widget.initialNote ?? '';
                setState(() => _editing = false);
              },
              child: Text(
                'Batal',
                style: AppTextStyles.label(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 8),
            // Simpan
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 16),
              label: const Text('Simpan'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                textStyle: AppTextStyles.button(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
