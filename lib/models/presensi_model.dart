class PresensiModel {
  final int? id;
  final int userId;
  final String tanggal;
  final String jam;
  final double latitude;
  final double longitude;
  final String status;
  final String mataKuliah;
  final String? fotoSelfie;

  PresensiModel({
    this.id,
    required this.userId,
    required this.tanggal,
    required this.jam,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.mataKuliah,
    this.fotoSelfie,
  });

  factory PresensiModel.fromMap(Map<String, dynamic> map) {
    return PresensiModel(
      id: map['id'],
      userId: map['user_id'],
      tanggal: map['tanggal'],
      jam: map['jam'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      status: map['status'] ?? 'Tepat Waktu',
      mataKuliah: map['mata_kuliah'] ?? 'Kelas Umum',
      fotoSelfie: map['foto_selfie'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_id': userId,
      'tanggal': tanggal,
      'jam': jam,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'mata_kuliah': mataKuliah,
      'foto_selfie': fotoSelfie,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
