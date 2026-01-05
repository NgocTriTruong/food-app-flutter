class SanPham {
  final String id;
  final String ten;
  final int gia;
  final String hinhAnh;
  final String moTa;
  final String danhMucId; // ✅ LUÔN LÀ STRING
  final bool? khuyenMai;
  final int? giamGia;

  SanPham({
    required this.id,
    required this.ten,
    required this.gia,
    required this.hinhAnh,
    required this.moTa,
    required this.danhMucId,
    this.khuyenMai,
    this.giamGia,
  });

  factory SanPham.fromJson(Map<String, dynamic> json) {
    return SanPham(
      id: json['id']?.toString() ?? '',
      ten: json['ten']?.toString() ?? '',
      gia: _parseToInt(json['gia']),
      hinhAnh: json['hinhAnh']?.toString() ?? '',
      moTa: json['moTa']?.toString() ?? '',
      danhMucId: _parseObjectId(json['danhMucId']),
      khuyenMai: _parseToBool(json['khuyenMai']),
      giamGia: _parseToIntNullable(json['giamGia']),
    );
  }

  // ================== HELPERS ==================

  /// 🔥 Parse ObjectId từ MongoDB
  static String _parseObjectId(dynamic value) {
    if (value == null) return '';

    // Backend trả string
    if (value is String) return value;

    // Backend trả { "$oid": "..." }
    if (value is Map && value.containsKey('\$oid')) {
      return value['\$oid'].toString();
    }

    return value.toString();
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseToIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _parseToBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is int) return value == 1;
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'ten': ten,
      'gia': gia,
      'hinhAnh': hinhAnh,
      'moTa': moTa,
      'danhMucId': danhMucId, // ✅ GỬI STRING LÊN BACKEND
      'khuyenMai': khuyenMai,
      'giamGia': giamGia,
    };
  }

  // ================== COMPUTED ==================

  bool get coKhuyenMai => khuyenMai == true;
  int get phanTramGiamGia => giamGia ?? 0;
  int get giaGiam =>
      coKhuyenMai ? (gia * (100 - phanTramGiamGia) / 100).round() : gia;

  @override
  String toString() => 'SanPham(id: $id, ten: $ten, danhMucId: $danhMucId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SanPham && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
