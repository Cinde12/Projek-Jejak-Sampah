import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';
import 'report_detail_screen.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Report>>(
      stream: ReportService().allReports(),
      builder: (context, snap) {
        final reports = snap.data ?? [];
        // Pusat awal: laporan terbaru, atau Yogyakarta jika kosong
        final center = reports.isNotEmpty
            ? LatLng(reports.first.latitude, reports.first.longitude)
            : const LatLng(-7.7956, 110.3695);

        return FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 13),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.jejak_sampah',
            ),
            MarkerLayer(
              markers: reports
                  .map((r) => Marker(
                        point: LatLng(r.latitude, r.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ReportDetailScreen(report: r)),
                          ),
                          child: Icon(Icons.location_on,
                              size: 44, color: statusColor(r.status)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
