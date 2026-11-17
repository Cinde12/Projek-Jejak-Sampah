import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});
  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _deskripsi = TextEditingController();
  final _alamat = TextEditingController();
  String _kategori = kKategori.first;
  File? _foto;
  Position? _pos;
  bool _loadingGps = false;
  bool _submitting = false;

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  void initState() {
    super.initState();
    _ambilLokasi();
  }

  Future<void> _ambilFoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (x != null) setState(() => _foto = File(x.path));
  }

  Future<void> _ambilLokasi() async {
    setState(() => _loadingGps = true);
    try {
      final p = await LocationService().getCurrentPosition();
      if (mounted) setState(() => _pos = p);
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loadingGps = false);
    }
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;
    if (_foto == null) return _msg('Ambil foto terlebih dahulu');
    if (_pos == null) return _msg('Lokasi belum tersedia');

    setState(() => _submitting = true);
    try {
      final user = AuthService().currentUser!;
      await ReportService().createReport(
        uid: user.uid,
        namaPelapor: user.displayName ?? 'Warga',
        judul: _judul.text.trim(),
        deskripsi: _deskripsi.text.trim(),
        kategori: _kategori,
        alamat: _alamat.text.trim(),
        latitude: _pos!.latitude,
        longitude: _pos!.longitude,
        foto: _foto!,
      );
      if (!mounted) return;
      _msg('Laporan terkirim! +$kPoinPerLaporan poin');
      Navigator.pop(context);
    } catch (e) {
      _msg('Gagal mengirim: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _ambilFoto,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _foto == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 48),
                            Text('Ketuk untuk mengambil foto'),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_foto!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(_loadingGps
                      ? 'Mencari lokasi...'
                      : _pos == null
                          ? 'Lokasi belum tersedia'
                          : '${_pos!.latitude.toStringAsFixed(5)}, '
                              '${_pos!.longitude.toStringAsFixed(5)}'),
                  trailing: IconButton(
                      icon: const Icon(Icons.refresh), onPressed: _ambilLokasi),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _judul,
                decoration: const InputDecoration(
                    labelText: 'Judul laporan', border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _kategori,
                decoration: const InputDecoration(
                    labelText: 'Kategori', border: OutlineInputBorder()),
                items: kKategori
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alamat,
                decoration: const InputDecoration(
                    labelText: 'Patokan alamat (opsional)',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deskripsi,
                maxLines: 4,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder()),
                validator: (v) =>
                    (v == null || v.trim().length < 10) ? 'Minimal 10 karakter' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _kirim,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: Text(_submitting ? 'Mengirim...' : 'Kirim Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
