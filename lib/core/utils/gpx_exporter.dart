import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/stryde_database.dart';

class GpxExporter {
  GpxExporter._();

  static Future<File> exportToGpx({
    required Activity activity,
    required List<TrackPoint> trackPoints,
  }) async {
    final buffer = StringBuffer();
    final isoFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<gpx version="1.1" creator="Stryde Running Tracker - Offline First" '
      'xmlns="http://www.topografix.com/GPX/1/1" '
      'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
      'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">',
    );
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>${_escapeXml(activity.title)}</name>');
    buffer.writeln('    <time>${isoFormat.format(activity.startTime.toUtc())}</time>');
    buffer.writeln('  </metadata>');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${_escapeXml(activity.title)}</name>');
    buffer.writeln('    <type>running</type>');
    buffer.writeln('    <trkseg>');

    for (final point in trackPoints) {
      buffer.writeln(
        '      <trkpt lat="${point.latitude}" lon="${point.longitude}">',
      );
      buffer.writeln('        <ele>${point.altitude.toStringAsFixed(1)}</ele>');
      buffer.writeln('        <time>${isoFormat.format(point.timestamp.toUtc())}</time>');
      buffer.writeln('        <speed>${point.speed.toStringAsFixed(2)}</speed>');
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');

    final directory = await getTemporaryDirectory();
    final sanitizeTitle = activity.title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final fileName = 'Stryde_${sanitizeTitle}_${activity.id}.gpx';
    final file = File(p.join(directory.path, fileName));

    return await file.writeAsString(buffer.toString());
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

