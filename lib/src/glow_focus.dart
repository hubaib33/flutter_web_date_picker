import 'package:flutter/material.dart';

/// Paints a focus halo around [child] whenever focus lands anywhere inside it.
///
/// It never takes focus itself (`canRequestFocus: false`, `skipTraversal: true`)
/// so it adds no extra Tab stop.
class GlowFocus extends StatefulWidget {
  const GlowFocus({
    super.key,
    required this.child,
    this.radius = 6,
    this.accent = const Color(0xFF312E81),
  });

  final Widget child;

  /// Corner radius of the ring. Match the wrapped control so the outline hugs
  /// it (6 = text fields / dropdowns, 8 = tabs, 14+ = round icon buttons).
  final double radius;

  /// Ring color; the soft halo behind it is the same color at ~25% alpha.
  final Color accent;

  @override
  State<GlowFocus> createState() => _GlowFocusState();
}

class _GlowFocusState extends State<GlowFocus> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (hasFocus != _focused) setState(() => _focused = hasFocus);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          // Painted in list order, so the soft halo goes down first and the
          // crisp ring lands on top of it.
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: widget.accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: widget.accent,
                    blurRadius: 0,
                    spreadRadius: 2,
                  ),
                ]
              : const [],
        ),
        child: widget.child,
      ),
    );
  }
}
