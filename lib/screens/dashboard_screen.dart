import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/presensi_provider.dart';
import '../services/location_service.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import 'schedule_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  StreamSubscription<Position>? _positionStream;
  double? _currentDistance;
  final LocationService _locationService = LocationService();
  String? _base64Image;
  bool _isFakeGps = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _startLocationStream();
      _loadProfileImage();
    });
  }

  Future<void> _loadProfileImage() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _base64Image = prefs.getString('avatar_${user.id}');
      });
    }
  }

  void _startLocationStream() async {
    bool hasPermission = await _locationService.handleLocationPermission();
    if (hasPermission) {
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 2,
            ),
          ).listen((Position position) {
            if (mounted) {
              setState(() {
                _isFakeGps = position.isMocked;
                _currentDistance = _locationService.calculateDistance(
                  position.latitude,
                  position.longitude,
                );
              });
            }
          });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser != null) {
      await Provider.of<PresensiProvider>(
        context,
        listen: false,
      ).loadRiwayat(authProvider.currentUser!.id!);
    }
  }

  void _doPresensi(Map<String, dynamic> schedule) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final presensiProvider = Provider.of<PresensiProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      if (_isFakeGps) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Aplikasi Fake GPS Terdeteksi! Presensi Ditolak.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      // Buka kamera untuk selfie
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 50,
      );

      if (image == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Absen dibatalkan: Foto selfie wajib!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      final String base64Image = base64Encode(bytes);

      await presensiProvider.doPresensi(
        authProvider.currentUser!.id!, 
        schedule,
        fotoSelfie: base64Image,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(presensiProvider.message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: presensiProvider.message.contains('berhasil')
              ? Colors.green
              : Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;
    final presensiProvider = Provider.of<PresensiProvider>(context);

    int sisaKelas = presensiProvider.getAllSchedules().where((s) => s['isPast'] == false && s['isAttended'] == false).length;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F7FA,
      ), // Latar belakang abu-abu sangat muda
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header Gradient Modern
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 40,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2980B9),
                      Color(0xFF2C3E50),
                    ], // Gradien Biru ke Dark Navy
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat datang,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.nama,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.nim,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                        // Muat ulang gambar profil setelah kembali dari layar profil
                        if (mounted) {
                          _loadProfileImage();
                        }
                      },
                      child: Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFF2980B9),
                            backgroundImage: _base64Image != null
                                ? MemoryImage(base64Decode(_base64Image!))
                                : null,
                            child: _base64Image == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 35,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Memberikan efek floating overlap ke Header
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildModernStatCard(
                          title: 'Matkul Hari Ini',
                          value: presensiProvider.getAllSchedules().length.toString(),
                          icon: Icons.menu_book_rounded,
                          color: const Color(0xFF8E44AD),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernStatCard(
                          title: 'Sisa Kelas',
                          value: sisaKelas.toString(),
                          icon: Icons.pending_actions_rounded,
                          color: const Color(0xFFE67E22), // Warna Orange
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Daftar Jadwal Kuliah
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Jadwal Kuliah Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...presensiProvider.getAllSchedules().map((schedule) {
                      bool isPast = schedule['isPast'];
                      bool isOpen = schedule['isOpen'];
                      bool isActive = isOpen || (!isPast && !isOpen); // Either open now, or upcoming

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isActive 
                              ? const LinearGradient(colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)])
                              : (isPast && !(schedule['isAttended'] ?? false)
                                  ? const LinearGradient(colors: [Color(0xFFE74C3C), Color(0xFFE67E22)]) // Red-Orange for Alpa
                                  : isPast && (schedule['isAttended'] ?? false)
                                      ? const LinearGradient(colors: [Color(0xFF27AE60), Color(0xFF2ECC71)]) // Green for Hadir
                                      : const LinearGradient(colors: [Color(0xFFBDC3C7), Color(0xFF95A5A6)])), // Grey for Akan Datang
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isActive 
                                  ? const Color(0xFF2980B9).withValues(alpha: 0.3)
                                  : (isPast && !(schedule['isAttended'] ?? false)
                                      ? const Color(0xFFE74C3C).withValues(alpha: 0.3)
                                      : isPast && (schedule['isAttended'] ?? false)
                                          ? const Color(0xFF27AE60).withValues(alpha: 0.3)
                                          : Colors.grey.withValues(alpha: 0.3)),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isPast 
                                        ? ((schedule['isAttended'] ?? false) ? Icons.check_circle_rounded : Icons.person_off_rounded) 
                                        : Icons.school_rounded, 
                                    color: Colors.white, 
                                    size: 30
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPast 
                                            ? ((schedule['isAttended'] ?? false) ? 'Selesai (Hadir)' : 'Selesai (Tidak Hadir / Alpa)') 
                                            : (isOpen ? 'Sedang Berlangsung' : 'Akan Datang'),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        schedule['nama'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${schedule['jamMulai']} - ${schedule['jamSelesai']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (!isPast) ...[
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white24, height: 1),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: Builder(
                                  builder: (context) {
                                    bool isAttended = schedule['isAttended'] ?? false;
                                    bool isOutOfRange = _currentDistance != null && _currentDistance! > LocationService.maxRadius;
                                    bool canTap = isOpen && !_isFakeGps && !isOutOfRange && !presensiProvider.isLoading && !isAttended;
                                    
                                    String buttonText = 'ABSEN SEKARANG';
                                    if (isAttended) {
                                      buttonText = 'SUDAH ABSEN';
                                    } else if (!isOpen) {
                                      buttonText = 'BELUM DIBUKA';
                                    } else if (_isFakeGps) {
                                      buttonText = 'FAKE GPS TERDETEKSI';
                                    } else if (isOutOfRange) {
                                      buttonText = 'DI LUAR AREA KAMPUS';
                                    }

                                    return ElevatedButton.icon(
                                      onPressed: canTap ? () => _doPresensi(schedule) : null,
                                      icon: presensiProvider.isLoading && isOpen && !isAttended
                                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.blueGrey, strokeWidth: 2))
                                          : Icon(
                                              isAttended ? Icons.check_circle_rounded :
                                              (!isOpen) ? Icons.lock_clock_rounded :
                                              (_isFakeGps || isOutOfRange) ? Icons.location_off_rounded : 
                                              Icons.touch_app_rounded, 
                                              size: 24
                                            ),
                                      label: Text(
                                        buttonText,
                                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: isAttended ? Colors.green : ((_isFakeGps || isOutOfRange) ? Colors.redAccent : const Color(0xFF2980B9)),
                                      backgroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                                      disabledForegroundColor: Colors.black54,
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                  );
                                }
                              ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Spasi untuk floating button
            ],
          ),
        ),
      ),

      // Tombol Riwayat dan Kalender di tengah bawah (mengambang)
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'history_btn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
            elevation: 8,
            backgroundColor: const Color(0xFF2C3E50),
            icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
            label: const Text(
              'RIWAYAT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'schedule_btn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScheduleScreen()),
              );
            },
            elevation: 8,
            backgroundColor: const Color(0xFF2980B9),
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            label: const Text(
              'KALENDER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
