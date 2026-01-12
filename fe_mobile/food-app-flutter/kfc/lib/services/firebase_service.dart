import '../models/danh_muc.dart';
import '../models/san_pham.dart';
import '../services_fix/san_pham_service.dart';

/// Adapter giữ nguyên API cũ nhưng chuyển toàn bộ dữ liệu
/// từ Firebase sang Spring Boot + MongoDB Atlas (REST).
class FirebaseService {
  // --- DANH MỤC ---
  static Future<List<DanhMuc>> layDanhSachDanhMuc({bool forceRefresh = false}) {
    return ProductService.layDanhSachDanhMuc(forceRefresh: forceRefresh);
  }

  // --- SẢN PHẨM ---
  static Future<List<SanPham>> layDanhSachSanPham({bool forceRefresh = false}) {
    return ProductService.layDanhSachSanPham(forceRefresh: forceRefresh);
  }

  static Future<List<SanPham>> layDanhSachSanPhamTheoDanhMuc(String danhMucId) {
    return ProductService.layDanhSachSanPhamTheoDanhMuc(danhMucId);
  }

  static Future<List<SanPham>> layDanhSachSanPhamKhuyenMai() {
    return ProductService.layDanhSachSanPhamKhuyenMai();
  }

  static Future<List<SanPham>> layDanhSachSanPhamNoiBat() async {
    // Tạm coi sản phẩm nổi bật là sản phẩm khuyến mãi hoặc giá cao
    final sanPham = await ProductService.layDanhSachSanPham();
    final noiBat = sanPham
        .where((sp) => sp.coKhuyenMai || sp.gia >= 50000)
        .take(10)
        .toList();

    if (noiBat.isNotEmpty) return noiBat;
    return ProductService.layDanhSachSanPhamKhuyenMai();
  }

  static Future<List<SanPham>> timKiemSanPham(String tuKhoa) {
    return ProductService.timKiemSanPham(tuKhoa);
  }

  static Future<List<SanPham>> laySanPhamLienQuan(SanPham sanPham) {
    return ProductService.laySanPhamLienQuan(sanPham);
  }

  static Future<SanPham?> laySanPhamTheoId(String sanPhamId) {
    return ProductService.laySanPhamTheoId(sanPhamId);
  }

  // --- STREAMS ---
  static Stream<List<SanPham>> streamSanPham() {
    return ProductService.streamSanPham();
  }

  // Đơn giản dùng polling danh mục mỗi 5 phút (tạm đủ)
  static Stream<List<DanhMuc>> streamDanhMuc() async* {
    while (true) {
      yield await ProductService.layDanhSachDanhMuc(forceRefresh: true);
      await Future.delayed(const Duration(minutes: 5));
    }
  }

  // --- CACHE ---
  static void xoaCache() {
    ProductService.xoaCache();
  }
}
