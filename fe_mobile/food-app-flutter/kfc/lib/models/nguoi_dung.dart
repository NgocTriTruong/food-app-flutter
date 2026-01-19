class NguoiDung {
  final String id;
  final String ten;
  final String email;
  final String soDienThoai;
  final String rule;

  // 🔥 Thêm mới
  final String provider;        // LOCAL | GOOGLE
  final List<String> vaiTro;    // superAdmin, quanLyDonHang...
  final String? avatar;

  NguoiDung({
    required this.id,
    required this.ten,
    required this.email,
    required this.soDienThoai,
    this.rule = 'user',
    this.provider = 'LOCAL',
    this.vaiTro = const ['user'],
    this.avatar,
  });

  // ================= fromMap / fromJson =================

  factory NguoiDung.fromMap(Map<String, dynamic> map) {
    return NguoiDung(
      id: map['id'] ??
          map['_id'] ??
          map['_id']?['\$oid'] ??
          '',
      ten: map['ten'] ?? '',
      email: map['email'] ?? '',
      soDienThoai: map['soDienThoai'] ?? '',
      rule: map['rule'] ?? 'user',
      provider: map['provider'] ?? 'LOCAL',
      vaiTro: List<String>.from(map['vaiTro'] ?? ['user']),
      avatar: map['avatar'],
    );
  }

  factory NguoiDung.fromJson(Map<String, dynamic> json) =>
      NguoiDung.fromMap(json);

  // ================= toMap / toJson =================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ten': ten,
      'email': email,
      'soDienThoai': soDienThoai,
      'rule': rule,
      'provider': provider,
      'vaiTro': vaiTro,
      'avatar': avatar,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  // ================= Helpers =================

  bool get isAdmin => rule == 'admin';
  bool get isUser => rule == 'user';

  bool get isGoogleAccount => provider == 'GOOGLE';
}
