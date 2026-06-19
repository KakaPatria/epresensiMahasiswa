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

  List<PresensiModel> get riwayatPresensi => _riwayatPresensi;
  bool get isLoading => _isLoading;
  String get message => _message;
  int get totalKeseluruhan => _totalKeseluruhan;
  int get totalHariIni => _totalHariIni;

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
  }

  Future<bool> doPresensi(int userId) async {
    _setLoading(true);
    _message = '';

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

    PresensiModel newPresensi = PresensiModel(
      userId: userId,
      tanggal: tanggal,
      jam: jam,
      latitude: position.latitude,
      longitude: position.longitude,
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
