import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/presensi_provider.dart';
import '../providers/auth_provider.dart';
import '../models/presensi_model.dart';
import '../services/location_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedMatkul = 'Semua Mata Kuliah';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      await Provider.of<PresensiProvider>(
        context,
        listen: false,
      ).loadRiwayat(user.id!);
    }
  }

  void _showDetail(PresensiModel presensi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Detail Kehadiran',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Selfie View is hidden as requested

                      // Map View
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                presensi.latitude,
                                presensi.longitude,
                              ),
                              initialZoom: 16.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.epresensi',
                              ),
                              CircleLayer(
                                circles: [
                                  CircleMarker(
                                    point: const LatLng(LocationService.targetLatitude, LocationService.targetLongitude),
                                    color: Colors.blue.withValues(alpha: 0.2),
                                    borderColor: Colors.blueAccent,
                                    borderStrokeWidth: 2,
                                    useRadiusInMeter: true,
                                    radius: LocationService.maxRadius,
                                  ),
                                ],
                              ),
                              MarkerLayer(
                                markers: [
                                  // Campus Center Pin
                                  Marker(
                                    point: const LatLng(LocationService.targetLatitude, LocationService.targetLongitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.business_rounded,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  // User Attend Pin
                                  Marker(
                                    point: LatLng(
                                      presensi.latitude,
                                      presensi.longitude,
                                    ),
                                    width: 60,
                                    height: 60,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildDetailRow(
                        Icons.calendar_today_rounded,
                        'Tanggal',
                        presensi.tanggal,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.access_time_rounded,
                        'Waktu Absen',
                        presensi.jam,
                      ),
                      const Divider(height: 20),

                      // FutureBuilder for Reverse Geocoding
                      FutureBuilder<String>(
                        future: LocationService().getAddressFromLatLng(
                          presensi.latitude,
                          presensi.longitude,
                        ),
                        builder: (context, snapshot) {
                          String address = 'Sedang mencari lokasi...';
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            address = snapshot.data ?? 'Alamat tidak ditemukan';
                          }
                          return _buildDetailRow(
                            Icons.my_location_rounded,
                            'Lokasi GPS',
                            address,
                          );
                        },
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.school_rounded,
                        'Mata Kuliah',
                        presensi.mataKuliah,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        Icons.info_outline_rounded,
                        'Status Kehadiran',
                        presensi.status,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2980B9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup Detail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2980B9).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2980B9), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final presensiProvider = Provider.of<PresensiProvider>(context);
    final riwayat = presensiProvider.riwayatPresensi;

    List<String> allSubjects = [];
    for (var list in presensiProvider.getWeeklySchedules().values) {
      for (var schedule in list) {
        allSubjects.add(schedule['nama']);
      }
    }
    List<String> uniqueSubjects = allSubjects.toSet().toList();
    uniqueSubjects.sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Presensi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2980B9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: presensiProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter Dropdown
                if (riwayat.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list_rounded, color: Color(0xFF2980B9)),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedMatkul,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF2980B9)),
                              style: const TextStyle(
                                color: Color(0xFF2C3E50),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              items: ['Semua Mata Kuliah', ...uniqueSubjects]
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedMatkul = newValue!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // List View
                Expanded(
                  child: riwayat.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          child: Builder(
                            builder: (context) {
                              final filteredRiwayat = _selectedMatkul == 'Semua Mata Kuliah'
                                  ? riwayat
                                  : presensiProvider.generateTimelineMatkul(_selectedMatkul);

                              if (filteredRiwayat.isEmpty) {
                                return const Center(
                                  child: Text(
                                    'Tidak ada riwayat untuk mata kuliah ini.',
                                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                );
                              }

                              return ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16.0),
                                itemCount: filteredRiwayat.length,
                                itemBuilder: (context, index) {
                                  final presensi = filteredRiwayat[index];
                                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueGrey.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: presensi.status == 'Alpa' 
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Detail absen tidak tersedia karena Anda Alpa.')),
                              );
                            }
                          : () => _showDetail(presensi),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Ikon / Badge Tanggal di Kiri
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: presensi.status == 'Alpa'
                                        ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
                                        : [const Color(0xFF2980B9), const Color(0xFF6DD5FA)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      presensi.status == 'Alpa' ? Icons.event_busy_rounded : Icons.event_available_rounded, 
                                      color: Colors.white, 
                                      size: 28
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Info Presensi di Tengah
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      presensi.tanggal,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      presensi.jam,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2C3E50),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      presensi.mataKuliah,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF2980B9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Status Badge di Kanan
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: presensi.status == 'Tepat Waktu' ? Colors.green.withValues(alpha: 0.15) 
                                           : presensi.status == 'Alpa' ? Colors.red.withValues(alpha: 0.15)
                                           : Colors.orange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          presensi.status == 'Tepat Waktu' ? Icons.check_circle 
                                          : presensi.status == 'Alpa' ? Icons.cancel_rounded
                                          : Icons.warning_rounded, 
                                          color: presensi.status == 'Tepat Waktu' ? Colors.green 
                                          : presensi.status == 'Alpa' ? Colors.red
                                          : Colors.orange, 
                                          size: 14
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          presensi.status,
                                          style: TextStyle(
                                            color: presensi.status == 'Tepat Waktu' ? Colors.green 
                                                 : presensi.status == 'Alpa' ? Colors.red
                                                 : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (presensi.status != 'Alpa')
                                    const Text(
                                      'Lihat Detail ➔',
                                      style: TextStyle(
                                        color: Color(0xFF2980B9),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_toggle_off_rounded,
              size: 100,
              color: Color(0xFFBDC3C7),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Belum Ada Riwayat Presensi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Anda belum memiliki riwayat presensi.\nSilakan lakukan presensi pada menu utama.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: _loadHistory,
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2980B9)),
            label: const Text(
              'Muat Ulang',
              style: TextStyle(
                color: Color(0xFF2980B9),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Color(0xFF2980B9), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
