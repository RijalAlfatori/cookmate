import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CookSearchBar — search bar dengan debounce 500ms dan tombol clear
// ─────────────────────────────────────────────────────────────────────────────

class CookSearchBar extends StatefulWidget {
  final String hintText;
  /// Dipanggil setelah debounce 500ms saat teks berubah
  final ValueChanged<String>? onChanged;
  /// Dipanggil saat user menekan Enter/tombol search
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onCleared;
  final TextEditingController? controller;

  const CookSearchBar({
    super.key,
    this.hintText = 'Cari resep...',
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
    this.controller,
  });

  @override
  State<CookSearchBar> createState() => _CookSearchBarState();
}

class _CookSearchBarState extends State<CookSearchBar> {
  late final TextEditingController _ctrl;
  Timer? _debounce;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(_onTextChanged);
    _hasText = _ctrl.text.isNotEmpty;
  }

  void _onTextChanged() {
    final hasText = _ctrl.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);

    // Debounce 500ms
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged?.call(_ctrl.text);
    });
  }

  void _clear() {
    _ctrl.clear();
    widget.onCleared?.call();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _ctrl,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.body(color: AppColors.textHint),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          suffixIcon: _hasText
              ? IconButton(
                  tooltip: 'Hapus pencarian',
                  onPressed: _clear,
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
