import 'package:kfc/api/san_pham_api.dart';
import 'package:kfc/models/san_pham.dart';
import 'package:kfc/models/danh_muc.dart';
import 'package:kfc/network/dio_client.dart';

class ProductService {
  static final SanPhamApi _api = SanPhamApi(DioClient.dio(withAuth: false));

  static List<DanhMuc>? _cachedDanhMuc;
  static List<SanPham>? _cachedSanPham;
  static DateTime? _lastCacheTime;
  static const Duration _cacheExpiry = Duration(minutes: 5);

  static bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiry;
  }

  // --- LẤY DANH MỤC ---
  static Future<List<DanhMuc>> layDanhSachDanhMuc({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _cachedDanhMuc != null) {
      return _cachedDanhMuc!;
    }

    try {
      final categories = await _api.getCategories();
      _cachedDanhMuc = categories;
      _lastCacheTime = DateTime.now();
      return categories;
    } catch (e) {
      print('❌ Lỗi khi lấy danh mục: $e');
      return _cachedDanhMuc ?? [];
    }
  }

  // --- LẤY TẤT CẢ SẢN PHẨM ---
  static Future<List<SanPham>> layDanhSachSanPham({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _cachedSanPham != null) {
      return _cachedSanPham!;
    }

    try {
      final products = await _api.getProducts();
      _cachedSanPham = products;
      _lastCacheTime = DateTime.now();
      return products;
    } catch (e) {
      print('❌ Lỗi khi lấy sản phẩm: $e');
      return _cachedSanPham ?? [];
    }
  }

  // --- LẤY THEO DANH MỤC ---
  static Future<List<SanPham>> layDanhSachSanPhamTheoDanhMuc(String danhMucId) async {
    try {
      // Ưu tiên lọc từ cache nếu có đủ dữ liệu
      if (_isCacheValid() && _cachedSanPham != null) {
        return _cachedSanPham!.where((sp) => sp.danhMucId == danhMucId).toList();
      }
      return await _api.getProductsByCategory(danhMucId);
    } catch (e) {
      print('❌ Lỗi: $e');
      return [];
    }
  }

  // --- LẤY SẢN PHẨM KHUYẾN MÃI ---
  static Future<List<SanPham>> layDanhSachSanPhamKhuyenMai() async {
    try {
      if (_isCacheValid() && _cachedSanPham != null) {
        return _cachedSanPham!.where((sp) => sp.coKhuyenMai).toList();
      }
      return await _api.getPromotionalProducts();
    } catch (e) {
      return [];
    }
  }

  // --- TÌM KIẾM ---
  static Future<List<SanPham>> timKiemSanPham(String tuKhoa) async {
    try {
      if (tuKhoa.isEmpty) return [];
      // Search từ server
      return await _api.searchProducts(tuKhoa);
    } catch (e) {
      // Fallback search local từ cache nếu server lỗi
      if (_cachedSanPham != null) {
        return _cachedSanPham!.where((sp) =>
            sp.ten.toLowerCase().contains(tuKhoa.toLowerCase())).toList();
      }
      return [];
    }
  }

  // --- LẤY THEO ID ---
  static Future<SanPham?> laySanPhamTheoId(String sanPhamId) async {
    try {
      // Kiểm tra trong cache trước
      if (_cachedSanPham != null) {
        final found = _cachedSanPham!.where((sp) => sp.id == sanPhamId);
        if (found.isNotEmpty) return found.first;
      }
      return await _api.getProductById(sanPhamId);
    } catch (e) {
      return null;
    }
  }

  // --- SẢN PHẨM LIÊN QUAN ---
  static Future<List<SanPham>> laySanPhamLienQuan(SanPham sanPham) async {
    try {
      return await _api.getRelatedProducts(sanPham.id);
    } catch (e) {
      // Fallback local
      if (_cachedSanPham != null) {
        return _cachedSanPham!
            .where((sp) => sp.danhMucId == sanPham.danhMucId && sp.id != sanPham.id)
            .take(3)
            .toList();
      }
      return [];
    }
  }

  // --- REALTIME (POLLING) ---
  // Vì REST không có stream như Firebase, ta giả lập bằng polling
  static Stream<List<SanPham>> streamSanPham() async* {
    while (true) {
      yield await layDanhSachSanPham(forceRefresh: true);
      await Future.delayed(const Duration(minutes: 5));
    }
  }

  static void xoaCache() {
    _cachedDanhMuc = null;
    _cachedSanPham = null;
    _lastCacheTime = null;
  }
}