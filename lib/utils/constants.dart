import 'package:flutter/material.dart';

const List<String> kKategori = [
  'Sampah Rumah Tangga',
  'Sampah Plastik',
  'Sampah Elektronik',
  'Puing Bangunan',
  'Lainnya',
];

const String kMenunggu = 'menunggu';
const String kDiproses = 'diproses';
const String kSelesai = 'selesai';
const List<String> kStatus = [kMenunggu, kDiproses, kSelesai];

const int kPoinPerLaporan = 10;

Color statusColor(String s) {
  switch (s) {
    case kDiproses:
      return Colors.orange;
    case kSelesai:
      return Colors.green;
    default:
      return Colors.red;
  }
}

String statusLabel(String s) => s[0].toUpperCase() + s.substring(1);
