import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../widgets/report_card.dart';
import 'report_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final uid = auth.currentUser!.uid;

    return StreamBuilder<AppUser?>(
      stream: auth.userStream(uid),
      builder: (context, snap) {
        final u = snap.data;
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.green.shade50,
              child: Column(
                children: [
                  const CircleAvatar(
                      radius: 36, child: Icon(Icons.person, size: 40)),
                  const SizedBox(height: 8),
                  Text(u?.nama ?? '...',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(u?.email ?? ''),
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.star, color: Colors.amber),
                    label: Text('${u?.poin ?? 0} poin'),
                  ),
                  TextButton.icon(
                    onPressed: auth.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Laporan saya',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Report>>(
                stream: ReportService().myReports(uid),
                builder: (context, s) {
                  if (!s.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (s.data!.isEmpty) {
                    return const Center(child: Text('Belum ada laporan'));
                  }
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 90),
                    children: s.data!
                        .map((r) => ReportCard(
                              report: r,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ReportDetailScreen(report: r))),
                            ))
                        .toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
