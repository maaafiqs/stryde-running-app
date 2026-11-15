import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/services/location_permission_service.dart';
import '../../../core/services/run_metrics_calculator.dart';
import '../../../core/theme/stryde_colors.dart';
import '../../../core/theme/stryde_typography.dart';
import '../../history/screens/activity_detail_screen.dart';
import '../models/tracking_state.dart';
import '../providers/tracker_notifier.dart';
import '../widgets/slide_to_finish_button.dart';

enum LeafletMapStyle {
  openStreetMap(
    name: 'Leaflet OpenStreetMap',
    description: 'Peta Leaflet Klasik Terang',
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c'],
  ),
  darkMatter(
    name: 'Leaflet Dark Matter',
    description: 'Peta Leaflet Gelap Kontras Tinggi',
    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
    subdomains: ['a', 'b', 'c', 'd'],
  );

  final String name;
  final String description;
  final String urlTemplate;
  final List<String> subdomains;

  const LeafletMapStyle({
    required this.name,
    required this.description,
    required this.urlTemplate,
    required this.subdomains,
  });
}

class LiveRunScreen extends ConsumerStatefulWidget {
  const LiveRunScreen({super.key});

  @override
  ConsumerState<LiveRunScreen> createState() => _LiveRunScreenState();
}

class _LiveRunScreenState extends ConsumerState<LiveRunScreen> {
  final MapController _mapController = MapController();
  bool _followRunner = true;
  bool _isLocating = false;
  LeafletMapStyle _mapStyle = LeafletMapStyle.openStreetMap;
  LocationPermissionStatus _permissionStatus = LocationPermissionStatus.granted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndPermission();
    });
  }

  Future<void> _initLocationAndPermission() async {
    final status = await LocationPermissionService.checkPermissionOnly();
    if (!mounted) return;
    setState(() {
      _permissionStatus = status;
    });

    if (status == LocationPermissionStatus.granted) {
      ref.read(trackerProvider.notifier).startStandbyLocation();
      final pos = await ref.read(trackerProvider.notifier).refreshCurrentLocation();
      if (pos != null && mounted) {
        _mapController.move(pos, 16.5);
      }
    } else if (status == LocationPermissionStatus.denied) {
      // Prompt user to grant permission when entering the screen
      _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLocating = true;
    });
    try {
      final status = await LocationPermissionService.checkAndRequestPermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus = status;
      });

      if (status == LocationPermissionStatus.granted) {
        ref.read(trackerProvider.notifier).startStandbyLocation();
        final pos = await ref.read(trackerProvider.notifier).refreshCurrentLocation();
        if (pos != null && mounted) {
          _mapController.move(pos, 16.5);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Izin lokasi aktif! Posisi GPS ditemukan.'),
              backgroundColor: StrydeColors.surfaceElevated,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _showPermissionSnackbar(status);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _showPermissionSnackbar(LocationPermissionStatus status) {
    String message = 'Izin lokasi dibutuhkan untuk menampilkan posisi di peta Leaflet.';
    String actionLabel = 'Izinkan';
    VoidCallback onAction = _requestPermission;

    if (status == LocationPermissionStatus.serviceDisabled) {
      message = 'GPS di HP Anda sedang nonaktif.';
      actionLabel = 'Nyalakan GPS';
      onAction = () => LocationPermissionService.openLocationSettings();
    } else if (status == LocationPermissionStatus.deniedForever) {
      message = 'Izin lokasi ditolak permanen. Buka pengaturan aplikasi.';
      actionLabel = 'Pengaturan';
      onAction = () => LocationPermissionService.openAppSettings();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: actionLabel,
          textColor: StrydeColors.neonGreen,
          onPressed: onAction,
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: StrydeColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _recenterLocation() async {
    setState(() {
      _followRunner = true;
      _isLocating = true;
    });

    try {
      final status = await LocationPermissionService.checkAndRequestPermission();
      if (!mounted) return;
      setState(() {
        _permissionStatus = status;
      });

      if (status != LocationPermissionStatus.granted) {
        _showPermissionSnackbar(status);
        return;
      }

      final pos = await ref.read(trackerProvider.notifier).refreshCurrentLocation();
      if (pos != null && mounted) {
        _mapController.move(pos, 16.5);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lokasi GPS terkunci (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: StrydeColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  void _toggleMapStyle() {
    setState(() {
      _mapStyle = _mapStyle == LeafletMapStyle.openStreetMap
          ? LeafletMapStyle.darkMatter
          : LeafletMapStyle.openStreetMap;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.map, size: 16, color: StrydeColors.neonGreen),
            const SizedBox(width: 8),
            Text('Gaya Peta: ${_mapStyle.name}'),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: StrydeColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackerProvider);
    final trackerNotifier = ref.read(trackerProvider.notifier);
    final shoesAsync = ref.watch(shoesStreamProvider);

    // Keep map centered on user when active
    if (_followRunner && trackingState.currentPosition != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(trackingState.currentPosition!, _mapController.camera.zoom);
      });
    }

    return Scaffold(
      backgroundColor: StrydeColors.background,
      body: Stack(
        children: [
          // 1. Leaflet Map (OpenStreetMap / CartoDB Dark)
          _buildMap(trackingState),

          // 2. Map Overlay Gradient for top bar readability
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    StrydeColors.background.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Top Status Bar & Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Stryde Logo Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: StrydeColors.surfaceCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: StrydeColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: trackingState.isRunning
                                ? StrydeColors.neonGreen
                                : trackingState.isAutoPaused
                                    ? StrydeColors.pausedAmber
                                    : StrydeColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'STRYDE',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: StrydeColors.neonGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // GPS / Permission Status Pill
                  GestureDetector(
                    onTap: _permissionStatus != LocationPermissionStatus.granted
                        ? _requestPermission
                        : _recenterLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _permissionStatus == LocationPermissionStatus.granted
                            ? StrydeColors.surfaceCard.withValues(alpha: 0.9)
                            : StrydeColors.pausedAmber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _permissionStatus == LocationPermissionStatus.granted
                              ? StrydeColors.border
                              : StrydeColors.pausedAmber,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _permissionStatus == LocationPermissionStatus.granted
                                ? LucideIcons.mapPin
                                : LucideIcons.alertCircle,
                            size: 13,
                            color: _permissionStatus == LocationPermissionStatus.granted
                                ? StrydeColors.neonGreen
                                : StrydeColors.pausedAmber,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _permissionStatus == LocationPermissionStatus.granted
                                ? 'GPS AKTIF'
                                : 'IZIN GPS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _permissionStatus == LocationPermissionStatus.granted
                                  ? StrydeColors.textSecondary
                                  : StrydeColors.pausedAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Auto-Pause Pill Toggle
                  GestureDetector(
                    onTap: () => trackerNotifier.toggleAutoPause(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: trackingState.autoPauseEnabled
                            ? StrydeColors.neonMint.withValues(alpha: 0.15)
                            : StrydeColors.surfaceCard.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: trackingState.autoPauseEnabled
                              ? StrydeColors.neonMint
                              : StrydeColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.pauseCircle,
                            size: 13,
                            color: trackingState.autoPauseEnabled
                                ? StrydeColors.neonMint
                                : StrydeColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            trackingState.autoPauseEnabled ? 'AUTO-PAUSE' : 'MANUAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: trackingState.autoPauseEnabled
                                  ? StrydeColors.neonMint
                                  : StrydeColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Permission Banner if Location Disabled / Denied
          if (_permissionStatus != LocationPermissionStatus.granted)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: _buildPermissionBanner(),
            ),

          // 5. Floating Leaflet Map Actions (Right Side)
          Positioned(
            right: 16,
            top: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Layer Style Switcher
                _buildFloatingButton(
                  icon: LucideIcons.layers,
                  tooltip: 'Ganti Gaya Peta Leaflet',
                  onTap: _toggleMapStyle,
                ),
                const SizedBox(height: 10),

                // Recenter / Locate Me Button
                _buildFloatingButton(
                  icon: _isLocating ? LucideIcons.loader : LucideIcons.crosshair,
                  tooltip: 'Pusatkan Lokasi GPS',
                  iconColor: _followRunner ? StrydeColors.neonGreen : StrydeColors.textPrimary,
                  isLoading: _isLocating,
                  onTap: _recenterLocation,
                ),
                const SizedBox(height: 10),

                // Zoom In Button
                _buildFloatingButton(
                  icon: LucideIcons.plus,
                  tooltip: 'Perbesar Peta',
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    if (zoom < 19.0) {
                      _mapController.move(_mapController.camera.center, zoom + 1.0);
                    }
                  },
                ),
                const SizedBox(height: 6),

                // Zoom Out Button
                _buildFloatingButton(
                  icon: LucideIcons.minus,
                  tooltip: 'Perkecil Peta',
                  onTap: () {
                    final zoom = _mapController.camera.zoom;
                    if (zoom > 3.0) {
                      _mapController.move(_mapController.camera.center, zoom - 1.0);
                    }
                  },
                ),
              ],
            ),
          ),

          // 6. Leaflet Attribution Badge
          Positioned(
            bottom: trackingState.isActive ? 275 : 215,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🍃 Leaflet | ',
                    style: TextStyle(
                      fontSize: 10,
                      color: StrydeColors.neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _mapStyle == LeafletMapStyle.openStreetMap
                        ? '© OpenStreetMap'
                        : 'CartoDB Dark',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. Auto-Pause Notification Banner
          if (trackingState.isAutoPaused)
            Positioned(
              top: 110,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: StrydeColors.pausedAmber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StrydeColors.pausedAmber),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.pause, size: 16, color: StrydeColors.pausedAmber),
                    SizedBox(width: 8),
                    Text(
                      'AUTO-PAUSED • RESUMES UPON RUNNING',
                      style: TextStyle(
                        color: StrydeColors.pausedAmber,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 8. Bottom Heads-Up Display (Metrics + Controls)
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildHudPanel(context, trackingState, trackerNotifier, shoesAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(TrackingState trackingState) {
    // Default to user's real GPS or fallback
    final center = trackingState.currentPosition ?? const LatLng(-6.2088, 106.8456);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16.0,
        minZoom: 3.0,
        maxZoom: 19.0,
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && _followRunner) {
            setState(() {
              _followRunner = false;
            });
          }
        },
      ),
      children: [
        // Leaflet Tile Layer (OpenStreetMap / CartoDB Dark)
        TileLayer(
          urlTemplate: _mapStyle.urlTemplate,
          subdomains: _mapStyle.subdomains,
          userAgentPackageName: 'com.stryde.stryde',
        ),

        // Route Polyline (Electric Neon Green for Run, Cyan for Walk)
        if (trackingState.coordinates.isNotEmpty)
          PolylineLayer(
            polylines: [
              // Outer glow line
              Polyline(
                points: trackingState.coordinates,
                strokeWidth: 8.0,
                color: (trackingState.isWalking
                        ? const Color(0xFF00E5FF)
                        : StrydeColors.neonGreen)
                    .withValues(alpha: 0.35),
              ),
              // Inner solid line
              Polyline(
                points: trackingState.coordinates,
                strokeWidth: 4.5,
                color: trackingState.isWalking
                    ? const Color(0xFF00E5FF)
                    : StrydeColors.neonGreen,
              ),
            ],
          ),

        // Runner Current Position Marker (Leaflet Pulsing Marker)
        if (trackingState.currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: trackingState.currentPosition!,
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_mapStyle == LeafletMapStyle.openStreetMap
                                ? const Color(0xFF1E88E5)
                                : StrydeColors.neonGreen)
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (_mapStyle == LeafletMapStyle.openStreetMap
                                ? const Color(0xFF1E88E5)
                                : StrydeColors.neonGreen)
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    // Inner core dot
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _mapStyle == LeafletMapStyle.openStreetMap
                            ? const Color(0xFF0D47A1)
                            : StrydeColors.neonGreen,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = StrydeColors.textPrimary,
    bool isLoading = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: StrydeColors.surfaceCard.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: StrydeColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StrydeColors.neonGreen,
                    ),
                  )
                : Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionBanner() {
    final isServiceDisabled = _permissionStatus == LocationPermissionStatus.serviceDisabled;
    final isPermanentlyDenied = _permissionStatus == LocationPermissionStatus.deniedForever;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StrydeColors.pausedAmber),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: StrydeColors.pausedAmber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.mapPin,
              color: StrydeColors.pausedAmber,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isServiceDisabled
                      ? 'GPS Perangkat Nonaktif'
                      : isPermanentlyDenied
                          ? 'Izin Lokasi Ditolak'
                          : 'Izin Lokasi Diperlukan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isServiceDisabled
                      ? 'Nyalakan GPS HP untuk mengambil lokasi Anda di peta Leaflet.'
                      : 'Izinkan akses lokasi untuk mendeteksi posisi lari Anda.',
                  style: const TextStyle(
                    color: StrydeColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (isServiceDisabled) {
                LocationPermissionService.openLocationSettings();
              } else if (isPermanentlyDenied) {
                LocationPermissionService.openAppSettings();
              } else {
                _requestPermission();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: StrydeColors.neonGreen,
              foregroundColor: StrydeColors.textOnNeon,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isServiceDisabled
                  ? 'Nyalakan'
                  : isPermanentlyDenied
                      ? 'Pengaturan'
                      : 'Izinkan',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudPanel(
    BuildContext context,
    TrackingState state,
    TrackerNotifier notifier,
    AsyncValue<List<dynamic>> shoesAsync,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: StrydeColors.background.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(
          top: BorderSide(color: StrydeColors.border, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag indicator
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: StrydeColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Activity Mode Selector (Lari vs Jalan Santai)
          if (state.status == TrackingStatus.idle) ...[
            _buildActivitySelector(state, notifier),
            const SizedBox(height: 14),
          ],

          // Primary Huge Metric (DISTANCE)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.distanceKm.toStringAsFixed(2),
                style: StrydeTypography.metricHuge,
              ),
              const SizedBox(width: 8),
              Text(
                'KM',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: state.isWalking ? const Color(0xFF00E5FF) : StrydeColors.neonGreen,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Secondary Metrics Grid (Pace / Steps / Duration / Speed)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: StrydeColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StrydeColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: state.isWalking
                  ? [
                      _buildMetricItem(
                        label: 'EST. STEPS',
                        value: '${state.estimatedSteps}',
                        unit: 'langkah',
                      ),
                      _buildDivider(),
                      _buildMetricItem(
                        label: 'TIME',
                        value: RunMetricsCalculator.formatDuration(state.movingTimeSeconds),
                        unit: 'elapsed',
                      ),
                      _buildDivider(),
                      _buildMetricItem(
                        label: 'SPEED',
                        value: state.currentSpeedKmh.toStringAsFixed(1),
                        unit: 'km/h',
                      ),
                    ]
                  : [
                      _buildMetricItem(
                        label: 'CURRENT PACE',
                        value: RunMetricsCalculator.formatPace(state.currentPaceSeconds),
                        unit: '/km',
                      ),
                      _buildDivider(),
                      _buildMetricItem(
                        label: 'TIME',
                        value: RunMetricsCalculator.formatDuration(state.movingTimeSeconds),
                        unit: 'elapsed',
                      ),
                      _buildDivider(),
                      _buildMetricItem(
                        label: 'AVG PACE',
                        value: RunMetricsCalculator.formatPace(state.averagePaceSeconds),
                        unit: '/km',
                      ),
                    ],
            ),
          ),
          const SizedBox(height: 14),

          // Elevation and Calories info pill
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.mountain, size: 14, color: StrydeColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '+${state.elevationGain.toStringAsFixed(0)} m elevation',
                style: StrydeTypography.caption.copyWith(color: StrydeColors.textSecondary),
              ),
              const SizedBox(width: 16),
              const Icon(LucideIcons.flame, size: 14, color: StrydeColors.neonOrange),
              const SizedBox(width: 6),
              Text(
                '${state.calories.toStringAsFixed(0)} kcal',
                style: StrydeTypography.caption.copyWith(color: StrydeColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tracking Action Controls
          if (state.status == TrackingStatus.idle)
            _buildStartButton(state, notifier)
          else
            _buildActiveControls(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildActivitySelector(TrackingState state, TrackerNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: StrydeColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StrydeColors.border),
      ),
      child: Row(
        children: [
          // 1. RUN OPTION
          Expanded(
            child: GestureDetector(
              onTap: () => notifier.setActivityType(StrydeActivityType.run),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !state.isWalking
                      ? StrydeColors.neonGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.footprints,
                      size: 16,
                      color: !state.isWalking
                          ? StrydeColors.textOnNeon
                          : StrydeColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LARI (RUN)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: !state.isWalking
                            ? StrydeColors.textOnNeon
                            : StrydeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 2. WALK OPTION
          Expanded(
            child: GestureDetector(
              onTap: () => notifier.setActivityType(StrydeActivityType.walk),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: state.isWalking
                      ? const Color(0xFF00E5FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.personStanding,
                      size: 16,
                      color: state.isWalking
                          ? Colors.black
                          : StrydeColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'JALAN SANTAI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: state.isWalking
                            ? Colors.black
                            : StrydeColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: StrydeTypography.metricMedium,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: StrydeTypography.metricLabel.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: StrydeColors.border,
    );
  }

  Widget _buildStartButton(TrackingState state, TrackerNotifier notifier) {
    final isWalk = state.isWalking;
    final primaryColor = isWalk ? const Color(0xFF00E5FF) : StrydeColors.neonGreen;
    final textColor = isWalk ? Colors.black : StrydeColors.textOnNeon;

    return ElevatedButton(
      onPressed: () async {
        final success = await notifier.startTracking();
        if (!success && mounted) {
          _requestPermission();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isWalk ? LucideIcons.personStanding : LucideIcons.play,
            size: 24,
            color: textColor,
          ),
          const SizedBox(width: 12),
          Text(
            isWalk ? 'MULAI JALAN SANTAI' : 'START STRYDE (LARI)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveControls(
    BuildContext context,
    TrackingState state,
    TrackerNotifier notifier,
  ) {
    return Column(
      children: [
        Row(
          children: [
            // Pause / Resume Toggle Button
            Expanded(
              flex: 1,
              child: ElevatedButton(
                onPressed: () {
                  if (state.status == TrackingStatus.running) {
                    notifier.pauseTracking();
                  } else {
                    notifier.resumeTracking();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: state.status == TrackingStatus.running
                      ? StrydeColors.surfaceElevated
                      : StrydeColors.neonGreen,
                  foregroundColor: state.status == TrackingStatus.running
                      ? StrydeColors.textPrimary
                      : StrydeColors.textOnNeon,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: state.status == TrackingStatus.running
                          ? StrydeColors.border
                          : StrydeColors.neonGreen,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.status == TrackingStatus.running
                          ? LucideIcons.pause
                          : LucideIcons.play,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.status == TrackingStatus.running ? 'PAUSE' : 'RESUME',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Slide to Finish Component (prevents accidental stop)
        SlideToFinishButton(
          onConfirmed: () async {
            final int? activityId = await notifier.finishTracking();
            if (activityId != null && context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ActivityDetailScreen(activityId: activityId),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
