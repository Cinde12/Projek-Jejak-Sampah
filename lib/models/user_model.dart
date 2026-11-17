class AppUser {
  final String uid;
  final String nama;
  final String email;
  final int poin;
  final String role;

  AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.poin,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String uid, Map<String, dynamic> d) => AppUser(
        uid: uid,
        nama: d['nama'] ?? '-',
        email: d['email'] ?? '',
        poin: (d['poin'] ?? 0) as int,
        role: d['role'] ?? 'warga',
      );
}
