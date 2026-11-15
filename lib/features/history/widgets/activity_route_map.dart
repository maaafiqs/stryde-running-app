import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/database/stryde_database.dart';
import '../../../core/theme/leaflet_map_style.dart';
import '../../../core/theme/stryde_colors.dart';

class ActivityRouteMap extends StatefulWidget {
  final Activity activity;
  final List<TrackPoint> trackPoints;
  final double height;

  const ActivityRouteMap({
    super.key,
    required this.activity,
    required this.trackPoints,
    this.height = 300,
  });

  @override
  State<ActivityRouteMap> createState() => _ActivityRouteMapState();
}

class _ActivityRouteMapState extends State<ActivityRouteMap> {
  final MapController _mapController = MapController();
  LeafletMapStyle _mapStyle = LeafletMapStyle.openStreetMap;
  bool _isMapReady = false;

  List<LatLng> get _latLngList =>
      widget.trackPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

  Color get _activityColor => widget.activity.activityType == 'walk'
      ? const Color(0xFF00E5FF)
      : StrydeColors.neonGreen;

  @override
  void didUpdateWidget(covariant ActivityRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackPoints != widget.trackPoints && _isMapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitRouteToBounds(animate: true);
      });
    }
  }

  void _fitRouteToBounds({bool animate = true}) {
    final points = _latLngList;
    if (!_isMapReady || points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.last, 17.5);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    final latSpan = (bounds.north - bounds.south).abs();
    final lonSpan = (bounds.east - bounds.west).abs();

    // If route is short (< 80 meters), center directly on the user's last position with close-up zoom
    if (latSpan < 0.0008 && lonSpan < 0.0008) {
      _mapController.move(points.last, 17.5);
    } else {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          maxZoom: 18.0,
          minZoom: 13.0,
        ),
      );
    }
  }

  void _focusLastLocation() {
    final points = _latLngList;
    if (!_isMapReady || points.isEmpty) return;

    _mapController.move(points.last, 18.0);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(LucideIcons.mapPin, size: 16, color: StrydeColors.neonRed),
            const SizedBox(width: 8),
            Text(
              'Lokasi Terakhir (${points.last.latitude.toStringAsFixed(4)}, ${points.last.longitude.toStringAsFixed(4)})',
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: StrydeColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleMapStyle() {
    setState(() {
      _mapStyle = _mapStyle == LeafletMapStyle.openStreetMap
          ? LeafletMapStyle.darkMatter
          : LeafletMapStyle.openStreetMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    final points = _latLngList;

    if (points.isEmpty) {
      return Container(
        height: 240,
        decoration: BoxDecoration(
          color: StrydeColors.surfaceCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: StrydeColors.border),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.mapPinOff, size: 40, color: StrydeColors.textMuted),
              SizedBox(height: 12),
              Text(
                'Data Jejak GPS Belum Tersedia',
                style: TextStyle(
                  color: StrydeColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Titik koordinat tidak terekam pada sesi ini.',
                style: TextStyle(color: StrydeColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final LatLng center = points.last;
    final LatLng firstPoint = points.first;
    final LatLng lastPoint = points.last;

    // Filter intermediate points for footprint trail dots
    final List<LatLng> stepTrailPoints = [];
    if (points.length >= 4) {
      final int stepInterval = points.length > 30 ? (points.length / 15).ceil() : 2;
      for (int i = stepInterval; i < points.length - 1; i += stepInterval) {
        stepTrailPoints.add(points[i]);
      }
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: StrydeColors.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: StrydeColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. FlutterMap
            FlutterMap(
              key: ValueKey('map_${widget.activity.id}_${points.length}'),
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 17.5,
                minZoom: 3.0,
                maxZoom: 19.0,
                onMapReady: () {
                  _isMapReady = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _fitRouteToBounds(animate: false);
                  });
                },
              ),
              children: [
                // Leaflet Map Tiles
                TileLayer(
                  urlTemplate: _mapStyle.urlTemplate,
                  subdomains: _mapStyle.subdomains,
                  userAgentPackageName: 'com.stryde.stryde',
                ),

                // Route Polylines (Glow + Solid Core)
                if (points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      // Outer glow
                      Polyline(
                        points: points,
                        strokeWidth: 8.0,
                        color: _activityColor.withValues(alpha: 0.35),
                      ),
                      // Core line
                      Polyline(
                        points: points,
                        strokeWidth: 4.5,
                        color: _activityColor,
                      ),
                    ],
                  ),

                // Markers (Start, Intermediate Steps, Last Location)
                MarkerLayer(
                  markers: [
                    // Intermediate footprint step dots
                    for (final stepPoint in stepTrailPoints)
                      Marker(
                        point: stepPoint,
                        width: 8,
                        height: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _activityColor.withValues(alpha: 0.8),
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                        ),
                      ),

                    // Start location marker
                    Marker(
                      point: firstPoint,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StrydeColors.neonGreen.withValues(alpha: 0.25),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: StrydeColors.neonGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.play,
                            size: 10,
                            color: StrydeColors.textOnNeon,
                          ),
                        ),
                      ),
                    ),

                    // Last recorded location marker (Lokasi Terakhir)
                    Marker(
                      point: lastPoint,
                      width: 130,
                      height: 68,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Floating badge label "📍 LOKASI TERAKHIR"
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F131C),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: StrydeColors.neonRed, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: StrydeColors.neonRed.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.mapPin, size: 10, color: StrydeColors.neonRed),
                                SizedBox(width: 4),
                                Text(
                                  'LOKASI TERAKHIR',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Target pin with animated glowing rings
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer ripple
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: StrydeColors.neonRed.withValues(alpha: 0.25),
                                ),
                              ),
                              // Middle ring
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: StrydeColors.neonRed.withValues(alpha: 0.5),
                                ),
                              ),
                              // Core pin
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: StrydeColors.neonRed,
                                  border: Border.all(color: Colors.white, width: 2.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. Info Pill (Top-Left)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F131C).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.footprints, size: 12, color: _activityColor),
                    const SizedBox(width: 5),
                    Text(
                      '${points.length} Titik GPS • ${widget.activity.distanceKm.toStringAsFixed(2)} KM',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Floating Map Controls (Top-Right)
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Map Style Switcher (Light / Dark)
                  _buildControlIconButton(
                    icon: LucideIcons.layers,
                    tooltip: 'Ganti Tampilan Peta',
                    onTap: _toggleMapStyle,
                  ),
                  const SizedBox(height: 8),

                  // Center on Last Location Button (Lokasi Terakhir)
                  _buildControlIconButton(
                    icon: LucideIcons.mapPin,
                    iconColor: StrydeColors.neonRed,
                    tooltip: 'Pusatkan ke Lokasi Terakhir',
                    onTap: _focusLastLocation,
                  ),
                  const SizedBox(height: 8),

                  // Fit Whole Route Bounds Button
                  _buildControlIconButton(
                    icon: LucideIcons.maximize2,
                    tooltip: 'Lihat Seluruh Rute',
                    onTap: () => _fitRouteToBounds(animate: true),
                  ),
                ],
              ),
            ),

            // 4. Attribution Badge (Bottom-Left)
            Positioned(
              bottom: 8,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  _mapStyle == LeafletMapStyle.openStreetMap
                      ? '🍃 Leaflet | © OpenStreetMap'
                      : '🍃 Leaflet | CartoDB Dark',
                  style: const TextStyle(fontSize: 9, color: Colors.white60),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0F131C).withValues(alpha: 0.88),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 6,
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}
