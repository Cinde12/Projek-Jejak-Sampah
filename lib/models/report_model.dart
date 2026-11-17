import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String uid;
  final String namaPelapor;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String fotoUrl;
  final double latitude;
  final double longitude;
  final String alamat;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.uid,
    required this.namaPelapor,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.fotoUrl,
    required this.latitude,
    required this.longitude,
    required this.alamat,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Report(
      id: doc.id,
      uid: d['uid'] ?? '',
      namaPelapor: d['namaPelapor'] ?? '-',
      judul: d['judul'] ?? '',
      deskripsi: d['deskripsi'] ?? '',
      kategori: d['kategori'] ?? 'Lainnya',
      fotoUrl: d['fotoUrl'] ?? '',
      latitude: (d['latitude'] ?? 0).toDouble(),
      longitude: (d['longitude'] ?? 0).toDouble(),
      alamat: d['alamat'] ?? '',
      status: d['status'] ?? 'menunggu',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
