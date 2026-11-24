import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/models/split_pace.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';

class SplitPaceTable extends StatefulWidget {
  final List<SplitPace> splits;
  final String activityType;
  final double avgPaceSecondsPerKm;

  const SplitPaceTable({
    super.key,
    required this.splits,
    this.activityType = 'run',
    this.avgPaceSecondsPerKm = 0.0,
  });

  @override
  State<SplitPaceTable> createState() => _SplitPaceTableState();
}

class _SplitPaceTableState extends State<SplitPaceTable> {
  bool _showSpeed = false; // toggle between Pace (min/km) and Speed (km/h)

  bool get _isWalking => widget.activityType == 'walk';
  Color get _themeColor =>
      _isWalking ? const Color(0xFF00E5FF) : StrydeColors.neonGreen;

  @override
  Widget build(BuildContext context) {
    if (widget.splits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: StrydeColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: StrydeColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.timer, size: 28, color: StrydeColors.textMuted),
              SizedBox(height: 8),
              Text(
                'Data split pace belum cukup.',
                style: TextStyle(
                  color: StrydeColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Determine fastest and slowest split for highlighting
    double minPace = double.infinity;
    double maxPace = 0.0;
    SplitPace? fastestSplit;
    SplitPace? slowestSplit;

    for (final s in widget.splits) {
      if (s.paceSeconds > 0) {
        if (s.paceSeconds < minPace) {
          minPace = s.paceSeconds;
          fastestSplit = s;
        }
        if (s.paceSeconds > maxPace) {
          maxPace = s.paceSeconds;
          slowestSplit = s;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StrydeColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Mode Switcher (Pace vs Speed)
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.listOrdered, size: 16, color: _themeColor),
                  const SizedBox(width: 8),
                  const Text('SPLIT PACE', style: StrydeTypography.metricLabel),
                ],
              ),
              const Spacer(),

              // Pace vs Speed Toggle Pills
              Container(
                decoration: BoxDecoration(
                  color: StrydeColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: StrydeColors.border),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(
                      label: 'PACE',
                      isSelected: !_showSpeed,
                      onTap: () => setState(() => _showSpeed = false),
                    ),
                    _buildModeButton(
                      label: 'SPEED',
                      isSelected: _showSpeed,
                      onTap: () => setState(() => _showSpeed = true),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fastest KM callout banner if more than 1 split
          if (fastestSplit != null && widget.splits.length > 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _themeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.zap, size: 14, color: _themeColor),
                  const SizedBox(width: 6),
                  Text(
                    'Fastest KM: ${fastestSplit.displayLabel} • ${_showSpeed ? fastestSplit.formattedSpeed : "${fastestSplit.formattedPace} /km"}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _themeColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.splits.length} SPLITS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: StrydeColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 8),

          // Column headers
          Row(
            children: [
              const SizedBox(
                width: 54,
                child: Text('KM', style: StrydeTypography.caption),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  _showSpeed ? 'SPEED (KM/H)' : 'PACE (/KM)',
                  style: StrydeTypography.caption,
                ),
              ),
              const Expanded(
                flex: 2,
                child: Text(
                  'ELEV',
                  textAlign: TextAlign.end,
                  style: StrydeTypography.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Split Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.splits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final split = widget.splits[index];
              final isFastest =
                  split == fastestSplit && widget.splits.length > 1;
              final isSlowest =
                  split == slowestSplit && widget.splits.length > 2;

              // Relative bar ratio (inverted: lower seconds = wider bar)
              final double ratio = maxPace > minPace
                  ? (1.0 -
                        ((split.paceSeconds - minPace) / (maxPace - minPace)))
                  : 1.0;
              final double clampedRatio = ratio.clamp(0.25, 1.0);

              // Pace diff vs average
              final double avgPace = widget.avgPaceSecondsPerKm;
              final double paceDiff = split.paceSeconds - avgPace;

              return Row(
                children: [
                  // KM index / label
                  SizedBox(
                    width: 54,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            split.displayLabel,
                            style: StrydeTypography.metricSmall.copyWith(
                              fontSize: split.isPartial ? 11 : 13,
                              color: isFastest
                                  ? _themeColor
                                  : StrydeColors.textPrimary,
                              fontWeight: isFastest
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                          if (isFastest) ...[
                            const SizedBox(width: 2),
                            Icon(LucideIcons.zap, size: 10, color: _themeColor),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Pace / Speed bar & value
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 58,
                          child: Text(
                            _showSpeed
                                ? split.formattedSpeed
                                : split.formattedPace,
                            style: StrydeTypography.metricSmall.copyWith(
                              fontSize: 13,
                              color: isFastest
                                  ? _themeColor
                                  : isSlowest
                                  ? StrydeColors.textSecondary
                                  : StrydeColors.textPrimary,
                              fontWeight: isFastest
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Progress Bar
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: clampedRatio,
                              minHeight: 7,
                              backgroundColor: StrydeColors.surfaceElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFastest
                                    ? _themeColor
                                    : _themeColor.withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        ),

                        // Diff badge vs average
                        if (avgPace > 0 && !split.isPartial) ...[
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 36,
                            child: Text(
                              paceDiff <= -1
                                  ? '-${(-paceDiff).round()}s'
                                  : paceDiff >= 1
                                  ? '+${paceDiff.round()}s'
                                  : '0s',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: paceDiff < 0
                                    ? _themeColor
                                    : StrydeColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Elevation delta
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${split.elevationDelta >= 0 ? '+' : ''}${split.elevationDelta.toStringAsFixed(0)} m',
                      textAlign: TextAlign.end,
                      style: StrydeTypography.caption.copyWith(
                        fontSize: 11,
                        color: split.elevationDelta >= 0
                            ? StrydeColors.textSecondary
                            : StrydeColors.neonMint,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _themeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isSelected
                ? StrydeColors.textOnNeon
                : StrydeColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
