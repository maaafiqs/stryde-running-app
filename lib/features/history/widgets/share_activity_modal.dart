import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:screenshot/screenshot.dart';

import '../../../core/database/stryde_database.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import 'shareable_activity_card.dart';

class ShareActivityModal extends StatefulWidget {
  final Activity activity;
  final List<TrackPoint> trackPoints;

  const ShareActivityModal({
    super.key,
    required this.activity,
    required this.trackPoints,
  });

  static Future<void> show({
    required BuildContext context,
    required Activity activity,
    required List<TrackPoint> trackPoints,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareActivityModal(
        activity: activity,
        trackPoints: trackPoints,
      ),
    );
  }

  @override
  State<ShareActivityModal> createState() => _ShareActivityModalState();
}

class _ShareActivityModalState extends State<ShareActivityModal> {
  final ScreenshotController _screenshotController = ScreenshotController();

  ShareBackgroundStyle _backgroundStyle = ShareBackgroundStyle.carbonDark;
  bool _showRoute = true;
  ShareCardFormat _format = ShareCardFormat.card;
  bool _isProcessing = false;

  bool get _isWalking => widget.activity.activityType == 'walk';
  Color get _themeColor => _isWalking ? const Color(0xFF00E5FF) : StrydeColors.neonGreen;

  @override
  void initState() {
    super.initState();
    // Default showRoute to true only if there are recorded points
    _showRoute = widget.trackPoints.length >= 2;
  }

  Future<void> _shareImage() async {
    setState(() => _isProcessing = true);
    try {
      await ShareableActivityCard.captureAndShare(
        context: context,
        screenshotController: _screenshotController,
        title: widget.activity.title,
        subtitle: '${widget.activity.distanceKm.toStringAsFixed(2)} KM',
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveImage() async {
    setState(() => _isProcessing = true);
    try {
      final savedPath = await ShareableActivityCard.captureAndSaveImage(
        context: context,
        screenshotController: _screenshotController,
        title: widget.activity.title,
      );

      if (savedPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: StrydeColors.neonGreen, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Gambar berhasil disimpan ke penyimpanan perangkat.'),
                ),
              ],
            ),
            backgroundColor: StrydeColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double maxModalHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxModalHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF0D111A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Colors.white12, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Modal Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(LucideIcons.share2, size: 18, color: _themeColor),
                const SizedBox(width: 8),
                const Text(
                  'BAGIKAN HASIL AKTIVITAS',
                  style: StrydeTypography.title,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: StrydeColors.textSecondary, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Live Preview Area
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _backgroundStyle == ShareBackgroundStyle.transparent
                            ? const Color(0xFF161B26)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_backgroundStyle == ShareBackgroundStyle.transparent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.sparkles, size: 12, color: _themeColor),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Preview Mode Transparan (Stiker PNG)',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: StrydeColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Screenshot(
                            controller: _screenshotController,
                            child: ShareableActivityCard(
                              activity: widget.activity,
                              trackPoints: widget.trackPoints,
                              backgroundStyle: _backgroundStyle,
                              showRoute: _showRoute,
                              format: _format,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Customization Options Header
                  const Text(
                    'KUSTOMISASI TAMPILAN',
                    style: StrydeTypography.metricLabel,
                  ),
                  const SizedBox(height: 12),

                  // 2A. Toggle Route ON / OFF (Bentuk Lokasi Lari/Jalan)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: StrydeColors.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: StrydeColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showRoute ? LucideIcons.mapPin : LucideIcons.mapPinOff,
                          size: 18,
                          color: _showRoute ? _themeColor : StrydeColors.textMuted,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bentuk Rute / Lokasi GPS',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: StrydeColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _showRoute
                                    ? 'Menampilkan jejak garis rute GPS'
                                    : 'Hanya statistik (Jarak, Pace, Waktu, Kalori)',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: StrydeColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _showRoute,
                          activeThumbColor: _themeColor,
                          activeTrackColor: _themeColor.withValues(alpha: 0.5),
                          onChanged: widget.trackPoints.length < 2
                              ? null
                              : (val) {
                                  setState(() => _showRoute = val);
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2B. Background Style Selector (Transparan, Dark Carbon, Midnight, Light)
                  const Text(
                    'GAYA BACKGROUND',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: StrydeColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ShareBackgroundStyle.values.map((style) {
                      final isSelected = _backgroundStyle == style;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (style == ShareBackgroundStyle.transparent) ...[
                              Icon(
                                LucideIcons.sparkles,
                                size: 12,
                                color: isSelected ? StrydeColors.textOnNeon : _themeColor,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(style.label),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: _themeColor,
                        backgroundColor: StrydeColors.surfaceCard,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? StrydeColors.textOnNeon
                              : StrydeColors.textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected ? _themeColor : StrydeColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _backgroundStyle = style);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // 2C. Card Format Selector (Story 9:16, Square 1:1, Card)
                  const Text(
                    'UKURAN / FORMAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: StrydeColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: ShareCardFormat.values.map((fmt) {
                      final isSelected = _format == fmt;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _format = fmt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _themeColor.withValues(alpha: 0.15)
                                    : StrydeColors.surfaceCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? _themeColor : StrydeColors.border,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                fmt.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? _themeColor : StrydeColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 3. Action Buttons (Share and Save)
                  Row(
                    children: [
                      // Save Image Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isProcessing ? null : _saveImage,
                          icon: const Icon(LucideIcons.download, size: 18),
                          label: const Text('SIMPAN'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Share Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _shareImage,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: StrydeColors.textOnNeon,
                                  ),
                                )
                              : const Icon(LucideIcons.share2, size: 18),
                          label: Text(
                            _isProcessing ? 'MEMPROSES...' : 'BAGIKAN GAMBAR',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _themeColor,
                            foregroundColor: StrydeColors.textOnNeon,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
