class UserModel {
  final int? id;
  final String nama;
  final String nim;
  final String email;
  final String password;

  UserModel({
    this.id,
    required this.nama,
    required this.nim,
    required this.email,
    required this.password,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama'],
      nim: map['nim'],
      email: map['email'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nama': nama,
      'nim': nim,
      'email': email,
      'password': password,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
