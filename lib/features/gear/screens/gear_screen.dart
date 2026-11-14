import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/database/stryde_database.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import '../../tracker/providers/tracker_notifier.dart';

class GearScreen extends ConsumerWidget {
  const GearScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoesAsync = ref.watch(shoesStreamProvider);
    final db = ref.watch(databaseProvider);
    final trackerNotifier = ref.read(trackerProvider.notifier);

    return Scaffold(
      backgroundColor: StrydeColors.background,
      appBar: AppBar(
        title: const Text('RUNNING GEAR'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, color: StrydeColors.neonGreen),
            onPressed: () => _openAddShoeDialog(context, db),
          ),
        ],
      ),
      body: shoesAsync.when(
        data: (shoes) {
          if (shoes.isEmpty) {
            return _buildEmptyState(context, db);
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: shoes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final shoe = shoes[index];
              return _buildShoeCard(context, db, trackerNotifier, shoe);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: StrydeColors.neonGreen),
        ),
        error: (err, _) => Center(
          child: Text('Error loading gear: $err', style: const TextStyle(color: StrydeColors.dangerRed)),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, StrydeDatabase db) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: StrydeColors.surfaceCard,
                shape: BoxShape.circle,
                border: Border.all(color: StrydeColors.border),
              ),
              child: const Icon(
                LucideIcons.archive,
                size: 48,
                color: StrydeColors.neonGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NO GEAR ADDED',
              style: StrydeTypography.title,
            ),
            const SizedBox(height: 8),
            const Text(
              'Track the lifespan of your running shoes to know when it is time for a fresh pair (default limit: 700 km).',
              textAlign: TextAlign.center,
              style: StrydeTypography.bodySecondary,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openAddShoeDialog(context, db),
              icon: const Icon(LucideIcons.plus),
              label: const Text('ADD FIRST SHOE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoeCard(
    BuildContext context,
    StrydeDatabase db,
    TrackerNotifier trackerNotifier,
    Shoe shoe,
  ) {
    final double maxDist = shoe.maxDistanceKm > 0 ? shoe.maxDistanceKm : 700.0;
    final double progress = (shoe.totalDistanceKm / maxDist).clamp(0.0, 1.0);
    final int percentage = (progress * 100).round();

    Color statusColor = StrydeColors.neonGreen;
    if (percentage >= 85 || shoe.isRetired) {
      statusColor = StrydeColors.dangerRed;
    } else if (percentage >= 65) {
      statusColor = StrydeColors.pausedAmber;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: shoe.isDefault ? StrydeColors.neonGreen.withValues(alpha: 0.6) : StrydeColors.border,
          width: shoe.isDefault ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${shoe.brand} ${shoe.model}',
                      style: StrydeTypography.metricSmall.copyWith(fontSize: 18),
                    ),
                    if (shoe.nickname != null && shoe.nickname!.isNotEmpty)
                      Text(
                        '"${shoe.nickname}"',
                        style: StrydeTypography.caption.copyWith(color: StrydeColors.neonMint),
                      ),
                  ],
                ),
              ),
              if (shoe.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: StrydeColors.neonGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: StrydeColors.neonGreen),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: StrydeColors.neonGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical, size: 20, color: StrydeColors.textSecondary),
                color: StrydeColors.surfaceElevated,
                onSelected: (value) async {
                  if (value == 'default') {
                    await db.setDefaultShoe(shoe.id);
                    trackerNotifier.setShoe(shoe.id);
                  } else if (value == 'retire') {
                    await db.updateShoe(shoe.copyWith(isRetired: !shoe.isRetired));
                  } else if (value == 'delete') {
                    await db.deleteShoe(shoe.id);
                  }
                },
                itemBuilder: (context) => [
                  if (!shoe.isDefault && !shoe.isRetired)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Set as Default'),
                    ),
                  PopupMenuItem(
                    value: 'retire',
                    child: Text(shoe.isRetired ? 'Unretire Shoe' : 'Retire Shoe'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: StrydeColors.dangerRed)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: StrydeColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 10),

          // Mileage text
          Row(
            children: [
              Text(
                '${shoe.totalDistanceKm.toStringAsFixed(1)} / ${maxDist.toStringAsFixed(0)} KM',
                style: StrydeTypography.metricSmall.copyWith(
                  fontSize: 14,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Text(
                '$percentage% LIFESPAN',
                style: StrydeTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openAddShoeDialog(BuildContext context, StrydeDatabase db) {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final nicknameController = TextEditingController();
    final initialDistController = TextEditingController(text: '0.0');
    final maxDistController = TextEditingController(text: '700.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: StrydeColors.surfaceSubtle,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('ADD RUNNING SHOE', style: StrydeTypography.title),
                  const SizedBox(height: 16),
                  TextField(
                    controller: brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand (e.g. Nike, Asics, Saucony)',
                      filled: true,
                      fillColor: StrydeColors.surfaceCard,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: modelController,
                    decoration: const InputDecoration(
                      labelText: 'Model (e.g. Vaporfly 3, Novablast 4)',
                      filled: true,
                      fillColor: StrydeColors.surfaceCard,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Nickname (Optional, e.g. Race Day Magic)',
                      filled: true,
                      fillColor: StrydeColors.surfaceCard,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: initialDistController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Initial KM',
                            filled: true,
                            fillColor: StrydeColors.surfaceCard,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxDistController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Max KM (Default 700)',
                            filled: true,
                            fillColor: StrydeColors.surfaceCard,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (brandController.text.trim().isEmpty ||
                          modelController.text.trim().isEmpty) {
                        return;
                      }

                      final initialDist = double.tryParse(initialDistController.text) ?? 0.0;
                      final maxDist = double.tryParse(maxDistController.text) ?? 700.0;

                      final shoeCompanion = ShoesCompanion.insert(
                        brand: brandController.text.trim(),
                        model: modelController.text.trim(),
                        nickname: drift.Value(nicknameController.text.trim().isEmpty ? null : nicknameController.text.trim()),
                        totalDistanceKm: drift.Value(initialDist),
                        maxDistanceKm: drift.Value(maxDist),
                        isDefault: const drift.Value(true),
                      );

                      await db.insertShoe(shoeCompanion);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: const Text('SAVE SHOE'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
