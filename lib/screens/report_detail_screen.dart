import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';
import '../widgets/report_card.dart';

class ReportDetailScreen extends StatelessWidget {
  final Report report;
  const ReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final me = AuthService().currentUser!;
    final point = LatLng(report.latitude, report.longitude);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: StreamBuilder<AppUser?>(
        stream: AuthService().userStream(me.uid),
        builder: (context, userSnap) {
          final isAdmin = userSnap.data?.isAdmin ?? false;
          final isOwner = report.uid == me.uid;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(report.fotoUrl,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(height: 240, child: Icon(Icons.broken_image))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(report.judul,
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold))),
                          StatusChip(report.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${report.kategori} • oleh ${report.namaPelapor}'),
                      Text(DateFormat('dd MMMM yyyy, HH:mm')
                          .format(report.createdAt)),
                      if (report.alamat.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Patokan: ${report.alamat}'),
                      ],
                      const Divider(height: 24),
                      Text(report.deskripsi),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            options:
                                MapOptions(initialCenter: point, initialZoom: 16),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.jejak_sampah',
                              ),
                              MarkerLayer(markers: [
                                Marker(
                                  point: point,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_on,
                                      color: Colors.red, size: 40),
                                ),
                              ]),
                            ],
                          ),
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 20),
                        const Text('Ubah status (admin)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: kStatus
                              .map((s) => ChoiceChip(
                                    label: Text(statusLabel(s)),
                                    selected: report.status == s,
                                    onSelected: (_) async {
                                      await ReportService()
                                          .updateStatus(report.id, s);
                                      if (context.mounted) Navigator.pop(context);
                                    },
                                  ))
                              .toList(),
                        ),
                      ],
                      if (isOwner || isAdmin) ...[
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          icon: const Icon(Icons.delete),
                          label: const Text('Hapus laporan'),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Hapus laporan?'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Batal')),
                                  TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Hapus')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await ReportService().deleteReport(report);
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
