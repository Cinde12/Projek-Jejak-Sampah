import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/report_model.dart';
import '../utils/config.dart';
import '../utils/constants.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;

  /// Upload foto ke Cloudinary (unsigned) dan kembalikan URL-nya.
  Future<String> _uploadFoto(File foto) async {
    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$kCloudinaryCloudName/image/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = kCloudinaryPreset
      ..files.add(await http.MultipartFile.fromPath('file', foto.path));
    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode != 200) {
      throw Exception('Upload foto gagal (${res.statusCode}): ${res.body}');
    }
    return jsonDecode(res.body)['secure_url'] as String;
  }

  Future<void> createReport({
    required String uid,
    required String namaPelapor,
    required String judul,
    required String deskripsi,
    required String kategori,
    required String alamat,
    required double latitude,
    required double longitude,
    required File foto,
  }) async {
    // 1. Upload foto ke Cloudinary
    final fotoUrl = await _uploadFoto(foto);

    // 2. Simpan data laporan ke Firestore
    await _db.collection('reports').add({
      'uid': uid,
      'namaPelapor': namaPelapor,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'fotoUrl': fotoUrl,
      'status': kMenunggu,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. Tambah poin pelapor
    await _db.collection('users').doc(uid).update({
      'poin': FieldValue.increment(kPoinPerLaporan),
    });
  }

  Stream<List<Report>> allReports() => _db
      .collection('reports')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Report.fromDoc).toList());

  Stream<List<Report>> myReports(String uid) => _db
      .collection('reports')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((s) {
        final list = s.docs.map(Report.fromDoc).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  Future<void> updateStatus(String id, String status) =>
      _db.collection('reports').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  // Foto di Cloudinary tidak dihapus dari aplikasi (unsigned upload tidak
  // mengizinkan hapus); cukup hapus data laporannya.
  Future<void> deleteReport(Report r) =>
      _db.collection('reports').doc(r.id).delete();
}
