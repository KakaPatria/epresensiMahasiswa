import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../models/presensi_model.dart';
import '../database/database_helper.dart';
import '../services/location_service.dart';

class PresensiProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final LocationService _locationService = LocationService();

  List<PresensiModel> _riwayatPresensi = [];
  bool _isLoading = false;
  String _message = '';

  int _totalKeseluruhan = 0;
  int _totalHariIni = 0;
  int _totalTepatWaktu = 0;
  int _totalTerlambat = 0;

  List<PresensiModel> get riwayatPresensi => _riwayatPresensi;
  bool get isLoading => _isLoading;
  String get message => _message;
  int get totalKeseluruhan => _totalKeseluruhan;
  int get totalHariIni => _totalHariIni;
  int get totalTepatWaktu => _totalTepatWaktu;
  int get totalTerlambat => _totalTerlambat;

  Future<void> loadRiwayat(int userId) async {
    _setLoading(true);
    _riwayatPresensi = await _dbHelper.getPresensiByUser(userId);
    _calculateStatistics();
    _setLoading(false);
  }

  void _calculateStatistics() {
    _totalKeseluruhan = _riwayatPresensi.length;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _totalHariIni = _riwayatPresensi.where((p) => p.tanggal == today).length;
    _totalTepatWaktu = _riwayatPresensi.where((p) => p.status == 'Tepat Waktu').length;
    _totalTerlambat = _riwayatPresensi.where((p) => p.status == 'Terlambat').length;
  }

  List<Map<String, dynamic>> getAllSchedules() {
    DateTime now = DateTime.now();
    int totalMinutes = now.hour * 60 + now.minute;
    int weekday = now.weekday;

    List<Map<String, dynamic>> schedules = [];

    if (weekday == 1) { // Senin
      schedules = [
        {'id': 101, 'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00', 'startMinutes': 420, 'endMinutes': 720},
        {'id': 102, 'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00', 'startMinutes': 720, 'endMinutes': 900},
        {'id': 103, 'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00', 'startMinutes': 900, 'endMinutes': 1080},
        {'id': 1, 'nama': 'Teori Rekayasa Perangkat Lunak', 'jamMulai': '08:00', 'jamSelesai': '10:00', 'startMinutes': 480, 'endMinutes': 600},
      ];
    } else if (weekday == 2) { // Selasa
      schedules = [
        {'id': 201, 'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00', 'startMinutes': 420, 'endMinutes': 720},
        {'id': 202, 'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00', 'startMinutes': 720, 'endMinutes': 900},
        {'id': 203, 'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00', 'startMinutes': 900, 'endMinutes': 1080},
        {'id': 2, 'nama': 'Workshop Pemrograman Web', 'jamMulai': '08:00', 'jamSelesai': '12:00', 'startMinutes': 480, 'endMinutes': 720},
      ];
    } else if (weekday == 3) { // Rabu
      schedules = [
        {'id': 301, 'nama': 'Uji Kompetensi (Sesi 1)', 'jamMulai': '07:30', 'jamSelesai': '10:00', 'startMinutes': 450, 'endMinutes': 600},
        {'id': 302, 'nama': 'Uji Kompetensi (Sesi 2)', 'jamMulai': '07:30', 'jamSelesai': '10:00', 'startMinutes': 450, 'endMinutes': 600},
        {'id': 303, 'nama': 'Uji Kompetensi (Sesi 3)', 'jamMulai': '07:30', 'jamSelesai': '10:00', 'startMinutes': 450, 'endMinutes': 600},
        {'id': 304, 'nama': 'Uji Kompetensi (Sesi 4)', 'jamMulai': '07:30', 'jamSelesai': '10:00', 'startMinutes': 450, 'endMinutes': 600},
        {'id': 305, 'nama': 'Uji Kompetensi (Sesi 5)', 'jamMulai': '07:30', 'jamSelesai': '10:00', 'startMinutes': 450, 'endMinutes': 600},
        {'id': 3, 'nama': 'Teori Basis Data', 'jamMulai': '10:30', 'jamSelesai': '12:30', 'startMinutes': 630, 'endMinutes': 750},
      ];
    } else if (weekday == 4) { // Kamis
      schedules = [
        {'id': 401, 'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00', 'startMinutes': 420, 'endMinutes': 720},
        {'id': 402, 'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00', 'startMinutes': 720, 'endMinutes': 900},
        {'id': 403, 'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00', 'startMinutes': 900, 'endMinutes': 1080},
        {'id': 4, 'nama': 'Workshop Jaringan Komputer', 'jamMulai': '08:00', 'jamSelesai': '12:00', 'startMinutes': 480, 'endMinutes': 720},
      ];
    } else if (weekday == 5) { // Jumat
      schedules = [
        {'id': 501, 'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00', 'startMinutes': 420, 'endMinutes': 720},
        {'id': 502, 'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00', 'startMinutes': 720, 'endMinutes': 900},
        {'id': 503, 'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00', 'startMinutes': 900, 'endMinutes': 1080},
        {'id': 5, 'nama': 'Teori Etika Profesi', 'jamMulai': '08:00', 'jamSelesai': '10:00', 'startMinutes': 480, 'endMinutes': 600},
        {'id': 6, 'nama': 'Teori Sistem Operasi', 'jamMulai': '13:30', 'jamSelesai': '15:30', 'startMinutes': 810, 'endMinutes': 930},
      ];
    } else if (weekday == 6) { // Sabtu
       schedules = [
        {'id': 601, 'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00', 'startMinutes': 420, 'endMinutes': 720},
        {'id': 602, 'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00', 'startMinutes': 720, 'endMinutes': 900},
        {'id': 603, 'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00', 'startMinutes': 900, 'endMinutes': 1080},
       ];
    } else { // Minggu
       schedules = [];
    }

    String today = DateFormat('yyyy-MM-dd').format(now);

    return schedules.map((schedule) {
      int startMins = schedule['startMinutes'];
      int endMins = schedule['endMinutes'];
      
      schedule['isOpen'] = totalMinutes >= startMins && totalMinutes <= endMins;
      schedule['isPast'] = totalMinutes > endMins;
      
      bool sudahAbsen = _riwayatPresensi.any((p) => p.tanggal == today && p.mataKuliah == schedule['nama']);
      schedule['isAttended'] = sudahAbsen;

      return schedule;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> getWeeklySchedules() {
    return {
      'Senin': [
        {'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00'},
        {'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00'},
        {'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00'},
        {'nama': 'Teori Rekayasa Perangkat Lunak', 'jamMulai': '08:00', 'jamSelesai': '10:00'},
      ],
      'Selasa': [
        {'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00'},
        {'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00'},
        {'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00'},
        {'nama': 'Workshop Pemrograman Web', 'jamMulai': '08:00', 'jamSelesai': '12:00'},
      ],
      'Rabu': [
        {'nama': 'Uji Kompetensi (Sesi 1)', 'jamMulai': '07:30', 'jamSelesai': '10:00'},
        {'nama': 'Uji Kompetensi (Sesi 2)', 'jamMulai': '07:30', 'jamSelesai': '10:00'},
        {'nama': 'Uji Kompetensi (Sesi 3)', 'jamMulai': '07:30', 'jamSelesai': '10:00'},
        {'nama': 'Uji Kompetensi (Sesi 4)', 'jamMulai': '07:30', 'jamSelesai': '10:00'},
        {'nama': 'Uji Kompetensi (Sesi 5)', 'jamMulai': '07:30', 'jamSelesai': '10:00'},
        {'nama': 'Teori Basis Data', 'jamMulai': '10:30', 'jamSelesai': '12:30'},
      ],
      'Kamis': [
        {'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00'},
        {'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00'},
        {'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00'},
        {'nama': 'Workshop Jaringan Komputer', 'jamMulai': '08:00', 'jamSelesai': '12:00'},
      ],
      'Jumat': [
        {'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00'},
        {'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00'},
        {'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00'},
        {'nama': 'Teori Etika Profesi', 'jamMulai': '08:00', 'jamSelesai': '10:00'},
        {'nama': 'Teori Sistem Operasi', 'jamMulai': '13:30', 'jamSelesai': '15:30'},
      ],
      'Sabtu': [
        {'nama': 'Uji Coba Sistem (Pagi)', 'jamMulai': '07:00', 'jamSelesai': '12:00'},
        {'nama': 'Uji Coba Sistem (Siang)', 'jamMulai': '12:00', 'jamSelesai': '15:00'},
        {'nama': 'Uji Coba Sistem (Sore)', 'jamMulai': '15:00', 'jamSelesai': '18:00'},
      ],
    };
  }

  int getWeekdayNumber(String dayName) {
    switch (dayName) {
      case 'Senin': return 1;
      case 'Selasa': return 2;
      case 'Rabu': return 3;
      case 'Kamis': return 4;
      case 'Jumat': return 5;
      case 'Sabtu': return 6;
      case 'Minggu': return 7;
      default: return 1;
    }
  }

  List<PresensiModel> generateTimelineMatkul(String namaMatkul) {
    if (namaMatkul == 'Semua Mata Kuliah') {
      return _riwayatPresensi;
    }

    String scheduleDay = '';
    Map<String, dynamic>? targetSchedule;
    
    var weekly = getWeeklySchedules();
    for (var entry in weekly.entries) {
      for (var schedule in entry.value) {
        if (schedule['nama'] == namaMatkul) {
          scheduleDay = entry.key;
          targetSchedule = schedule;
          break;
        }
      }
      if (scheduleDay.isNotEmpty) break;
    }

    if (targetSchedule == null) return _riwayatPresensi.where((p) => p.mataKuliah == namaMatkul).toList();

    int targetWeekday = getWeekdayNumber(scheduleDay);
    List<PresensiModel> timeline = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < 1; i++) {
      int daysDifference = targetWeekday - now.weekday;
      DateTime targetDate = now.add(Duration(days: daysDifference - (i * 7)));
      
      if (targetDate.isAfter(now)) continue;
      
      bool isToday = targetDate.year == now.year && targetDate.month == now.month && targetDate.day == now.day;
      String dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      
      try {
        var record = _riwayatPresensi.firstWhere((p) => p.tanggal == dateStr && p.mataKuliah == namaMatkul);
        timeline.add(record);
      } catch (e) {
        bool isAlpa = false;
        if (!isToday) {
          isAlpa = true;
        } else {
          int currentMins = now.hour * 60 + now.minute;
          List<String> parts = targetSchedule['jamSelesai'].split(':');
          int endMins = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          if (currentMins > endMins) {
            isAlpa = true;
          }
        }

        if (isAlpa) {
          timeline.add(PresensiModel(
            userId: 0,
            mataKuliah: namaMatkul,
            tanggal: dateStr,
            jam: targetSchedule['jamMulai'],
            status: 'Alpa',
            latitude: 0.0,
            longitude: 0.0,
          ));
        }
      }
    }
    
    timeline.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return timeline;
  }

  Future<bool> doPresensi(int userId, Map<String, dynamic> schedule, {String? fotoSelfie}) async {
    _setLoading(true);
    _message = '';

    if (schedule['isPast'] == true) {
      _message = 'Jadwal perkuliahan ini sudah berakhir.';
      _setLoading(false);
      return false;
    }

    if (schedule['isAttended'] == true) {
      _message = 'Anda sudah melakukan presensi untuk mata kuliah ini hari ini.';
      _setLoading(false);
      return false;
    }

    if (schedule['isOpen'] == false) {
      _message = 'Presensi belum dibuka! Silakan absen tepat mulai jam ${schedule['jamMulai']}.';
      _setLoading(false);
      return false;
    }

    bool hasPermission = await _locationService.handleLocationPermission();
    if (!hasPermission) {
      _message = 'Izin lokasi tidak diberikan atau GPS mati.';
      _setLoading(false);
      return false;
    }

    Position? position = await _locationService.getCurrentPosition();
    if (position == null) {
      _message = 'Gagal mendapatkan lokasi.';
      _setLoading(false);
      return false;
    }

    bool isWithinRadius = _locationService.isWithinRadius(
      position.latitude,
      position.longitude,
    );

    if (!isWithinRadius) {
      _message = 'Posisi Anda berada di luar area kampus.';
      _setLoading(false);
      return false;
    }

    DateTime now = DateTime.now();
    String tanggal = DateFormat('yyyy-MM-dd').format(now);
    String jam = DateFormat('HH:mm:ss').format(now);

    int totalMinutes = now.hour * 60 + now.minute;
    int startMinutes = schedule['startMinutes'];

    String status = 'Tepat Waktu';
    // Telat jika absen melebihi 15 menit dari jam mulai
    if (totalMinutes > startMinutes + 15) {
      status = 'Terlambat';
    }

    PresensiModel newPresensi = PresensiModel(
      userId: userId,
      tanggal: tanggal,
      jam: jam,
      latitude: position.latitude,
      longitude: position.longitude,
      status: status,
      mataKuliah: schedule['nama'],
      fotoSelfie: fotoSelfie,
    );

    int id = await _dbHelper.insertPresensi(newPresensi);
    if (id > 0) {
      _message = 'Presensi berhasil dicatat. Selamat mengikuti perkuliahan!';
      await loadRiwayat(userId);
      _setLoading(false);
      return true;
    } else {
      _message = 'Gagal menyimpan presensi.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
