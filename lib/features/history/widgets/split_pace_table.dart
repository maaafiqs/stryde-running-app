import 'package:flutter/material.dart';
import '../../../core/models/split_pace.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';

class SplitPaceTable extends StatelessWidget {
  final List<SplitPace> splits;

  const SplitPaceTable({super.key, required this.splits});

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: StrydeColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: StrydeColors.border),
        ),
        child: const Center(
          child: Text(
            'Complete at least 1.0 km to view split breakdown.',
            style: TextStyle(color: StrydeColors.textSecondary, fontSize: 13),
          ),
        ),
      );
    }

    // Determine fastest split for relative bar visualization
    double minPace = double.infinity;
    double maxPace = 0.0;
    for (final s in splits) {
      if (s.paceSeconds > 0) {
        if (s.paceSeconds < minPace) minPace = s.paceSeconds;
        if (s.paceSeconds > maxPace) maxPace = s.paceSeconds;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StrydeColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '1 KM SPLITS',
                style: StrydeTypography.metricLabel,
              ),
              const Spacer(),
              Text(
                '${splits.length} SPLITS',
                style: StrydeTypography.caption.copyWith(color: StrydeColors.neonGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Header row
          const Row(
            children: [
              SizedBox(
                width: 36,
                child: Text('KM', style: StrydeTypography.caption),
              ),
              Expanded(
                flex: 4,
                child: Text('PACE', style: StrydeTypography.caption),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'ELEV',
                  textAlign: TextAlign.end,
                  style: StrydeTypography.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: splits.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final split = splits[index];
              final isFastest = split.paceSeconds == minPace && splits.length > 1;

              // Relative bar ratio (inverted: lower seconds = wider bar)
              final double ratio = maxPace > minPace
                  ? (1.0 - ((split.paceSeconds - minPace) / (maxPace - minPace)))
                  : 1.0;
              final double clampedRatio = ratio.clamp(0.2, 1.0);

              return Row(
                children: [
                  // Km index
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${split.km}',
                      style: StrydeTypography.metricSmall.copyWith(
                        color: isFastest ? StrydeColors.neonGreen : StrydeColors.textPrimary,
                      ),
                    ),
                  ),

                  // Pace bar & text
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        Text(
                          split.formattedPace,
                          style: StrydeTypography.metricSmall.copyWith(
                            color: isFastest ? StrydeColors.neonGreen : StrydeColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: clampedRatio,
                              minHeight: 6,
                              backgroundColor: StrydeColors.surfaceElevated,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFastest
                                    ? StrydeColors.neonGreen
                                    : StrydeColors.textSecondary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
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
}
