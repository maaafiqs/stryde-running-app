import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';

class SlideToFinishButton extends StatefulWidget {
  final Future<void> Function() onConfirmed;
  final String label;

  const SlideToFinishButton({
    super.key,
    required this.onConfirmed,
    this.label = 'SLIDE TO FINISH',
  });

  @override
  State<SlideToFinishButton> createState() => _SlideToFinishButtonState();
}

class _SlideToFinishButtonState extends State<SlideToFinishButton> {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;
  static const double _handleSize = 56.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxDrag = constraints.maxWidth - _handleSize - 8.0;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            color: StrydeColors.surfaceElevated,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _isConfirmed
                  ? StrydeColors.neonRed
                  : StrydeColors.border.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Progress fill behind handle
              Container(
                width: _dragPosition + _handleSize + 4,
                decoration: BoxDecoration(
                  color: StrydeColors.neonRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),

              // Centered prompt text
              Center(
                child: Text(
                  _isConfirmed ? 'FINISHING RUN...' : widget.label,
                  style: StrydeTypography.metricLabel.copyWith(
                    color: _isConfirmed
                        ? StrydeColors.neonRed
                        : StrydeColors.textSecondary,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // Draggable handle
              Positioned(
                left: _dragPosition + 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isConfirmed) return;
                    setState(() {
                      _dragPosition = (_dragPosition + details.delta.dx)
                          .clamp(0.0, maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) async {
                    if (_isConfirmed) return;
                    if (_dragPosition >= maxDrag * 0.85) {
                      setState(() {
                        _dragPosition = maxDrag;
                        _isConfirmed = true;
                      });
                      await widget.onConfirmed();
                    } else {
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: _handleSize,
                    height: _handleSize,
                    decoration: BoxDecoration(
                      color: StrydeColors.neonRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: StrydeColors.neonRed.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.flag,
                      color: StrydeColors.textPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
