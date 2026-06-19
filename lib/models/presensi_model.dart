class PresensiModel {
  final int? id;
  final int userId;
  final String tanggal;
  final String jam;
  final double latitude;
  final double longitude;

  PresensiModel({
    this.id,
    required this.userId,
    required this.tanggal,
    required this.jam,
    required this.latitude,
    required this.longitude,
  });

  factory PresensiModel.fromMap(Map<String, dynamic> map) {
    return PresensiModel(
      id: map['id'],
      userId: map['user_id'],
      tanggal: map['tanggal'],
      jam: map['jam'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal,
      'jam': jam,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
