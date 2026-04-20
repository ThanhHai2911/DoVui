import 'package:flutter/material.dart';

// ─── Field Label ──────────────────────────────────────────────────────────────

class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B)),
    );
  }
}

// ─── Text Field ───────────────────────────────────────────────────────────────

/// Generic styled text field with error state and animated shadow.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? errorText;
  final Widget? suffix;
  final void Function(String)? onChanged;
  /// Override prefix icon color (default: accent with 0.6 opacity)
  final Color? iconColor;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.errorText,
    this.suffix,
    this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final resolvedIconColor = iconColor ??
        (hasError ? const Color(0xFFFF6584) : const Color(0xFF6C63FF).withOpacity(0.6));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: hasError
                ? [BoxShadow(color: const Color(0xFFFF6584).withOpacity(0.15), blurRadius: 10, spreadRadius: 1)]
                : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: resolvedIconColor, size: 20),
              suffixIcon: suffix,
              filled: true,
              fillColor: hasError ? const Color(0xFFFF6584).withOpacity(0.04) : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: _border(hasError),
              enabledBorder: _border(hasError),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: hasError ? const Color(0xFFFF6584) : const Color(0xFF6C63FF),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (hasError) _ErrorHint(errorText!),
      ],
    );
  }

  OutlineInputBorder _border(bool hasError) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: hasError ? const Color(0xFFFF6584) : Colors.grey.shade200,
          width: hasError ? 1.5 : 1,
        ),
      );
}

/// Variant of [AuthTextField] with tri-state border: error / success / default.
/// Used in ForgotPassword where we need to show green on email found.
class AuthTextFieldTriState extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? errorText;
  final bool isSuccess;
  final Widget? suffix;
  final void Function(String)? onChanged;

  const AuthTextFieldTriState({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.errorText,
    this.isSuccess = false,
    this.suffix,
    this.onChanged,
  });

  static const _green = Color(0xFF43C6AC);
  static const _red = Color(0xFFFF6584);
  static const _purple = Color(0xFF6C63FF);

  Color get _borderColor {
    if (errorText != null) return _red;
    if (isSuccess) return _green;
    return Colors.grey.shade200;
  }

  Color get _iconColor {
    if (errorText != null) return _red;
    if (isSuccess) return _green;
    return _purple.withOpacity(0.6);
  }

  Color get _fillColor {
    if (errorText != null) return _red.withOpacity(0.04);
    if (isSuccess) return _green.withOpacity(0.04);
    return Colors.grey.shade50;
  }

  @override
  Widget build(BuildContext context) {
    final hasState = errorText != null || isSuccess;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: errorText != null
                ? [BoxShadow(color: _red.withOpacity(0.15), blurRadius: 10, spreadRadius: 1)]
                : isSuccess
                    ? [BoxShadow(color: _green.withOpacity(0.15), blurRadius: 10, spreadRadius: 1)]
                    : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFF1E1B4B), fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: _iconColor, size: 20),
              suffixIcon: suffix,
              filled: true,
              fillColor: _fillColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: _outlineBorder(),
              enabledBorder: _outlineBorder(),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: errorText != null ? _red : isSuccess ? _green : _purple, width: 1.5),
              ),
            ),
          ),
        ),
        if (errorText != null) _ErrorHint(errorText!),
      ],
    );
  }

  OutlineInputBorder _outlineBorder() => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _borderColor, width: errorText != null || isSuccess ? 1.5 : 1),
      );
}

// ─── Error Hint ───────────────────────────────────────────────────────────────

class _ErrorHint extends StatelessWidget {
  final String message;
  const _ErrorHint(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 13, color: Color(0xFFFF6584)),
          const SizedBox(width: 4),
          Text(message, style: const TextStyle(color: Color(0xFFFF6584), fontSize: 12)),
        ],
      ),
    );
  }
}

// ─── Eye (password toggle) button ────────────────────────────────────────────

class EyeToggleButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const EyeToggleButton({super.key, required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: Colors.grey.shade400,
      ),
      onPressed: onTap,
    );
  }
}

// ─── Auth Primary Button ──────────────────────────────────────────────────────

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.isLoading = false,
    this.disabled = false,
    this.onPressed,
    this.backgroundColor = const Color(0xFF6C63FF),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade200,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: (isLoading || disabled) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

// ─── Floating Emoji Icon ──────────────────────────────────────────────────────

class FloatingEmojiIcon extends StatelessWidget {
  final Animation<double> floatAnim;
  final String emoji;
  final Color bgColor;
  final Color borderColor;

  const FloatingEmojiIcon({
    super.key,
    required this.floatAnim,
    required this.emoji,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: floatAnim,
        builder: (_, child) => Transform.translate(offset: Offset(0, floatAnim.value), child: child),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderColor),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 44)),
        ),
      ),
    );
  }
}

// ─── Background Accent Blobs ──────────────────────────────────────────────────

class AuthBackgroundBlobs extends StatelessWidget {
  /// [topLeft] = true → blob dưới trái + trên phải (Register/ForgotPwd style)
  /// [topLeft] = false → blob trên trái + dưới phải (Login style)
  final bool topLeftVariant;

  const AuthBackgroundBlobs({super.key, this.topLeftVariant = false});

  @override
  Widget build(BuildContext context) {
    if (topLeftVariant) {
      return Stack(children: [
        _blob(top: -50, left: -50, color: const Color(0xFF43C6AC).withOpacity(0.08)),
        _blob(bottom: -40, right: -40, color: const Color(0xFF6C63FF).withOpacity(0.08)),
      ]);
    }
    return Stack(children: [
      _blob(top: -50, right: -50, color: const Color(0xFF6C63FF).withOpacity(0.07)),
      _blob(bottom: -40, left: -40, color: const Color(0xFF43C6AC).withOpacity(0.07)),
    ]);
  }

  Widget _blob({double? top, double? bottom, double? left, double? right, required Color color}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: top != null ? 160 : 140,
        height: top != null ? 160 : 140,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

// ─── Auth Link Row (đăng nhập / tạo tài khoản) ───────────────────────────────

class AuthLinkRow extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(prefixText, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          GestureDetector(
            onTap: onTap,
            child: Text(
              linkText,
              style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Success Dialog ───────────────────────────────────────────────────────────

class AuthSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onConfirm;
  final Color buttonColor;

  const AuthSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onConfirm,
    this.buttonColor = const Color(0xFF43C6AC),
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: buttonColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Text('✅', style: TextStyle(fontSize: 40)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1B4B))),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: onConfirm,
              child: Text(buttonLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}