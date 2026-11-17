import 'package:flutter/material.dart';
import 'create_report_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'report_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [ReportListScreen(), MapScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jejak Sampah'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateReportScreen())),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Lapor'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Peta'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
