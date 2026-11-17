import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';
import '../widgets/report_card.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});
  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  String _filter = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: ['Semua', ...kKategori]
                .map((k) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(k),
                        selected: _filter == k,
                        onSelected: (_) => setState(() => _filter = k),
                      ),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Report>>(
            stream: ReportService().allReports(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data!
                  .where((r) => _filter == 'Semua' || r.kategori == _filter)
                  .toList();
              if (list.isEmpty) {
                return const Center(child: Text('Belum ada laporan'));
              }
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: list.length,
                itemBuilder: (_, i) => ReportCard(
                  report: list[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(report: list[i])),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
