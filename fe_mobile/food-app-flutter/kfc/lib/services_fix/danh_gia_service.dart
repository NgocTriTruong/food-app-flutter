import 'package:kfc/api/danh_gia_api.dart';
import 'package:kfc/models/danh_gia.dart';
import 'package:kfc/network/dio_client.dart';

class DanhGiaService {
  // Sử dụng Dio có Auth (thường đánh giá cần login)
  static final DanhGiaApi _api = DanhGiaApi(DioClient.dio(withAuth: true));

  // Thêm đánh giá mới
  static Future<bool> themDanhGia(DanhGia danhGia) async {
    try {
      print('🔄 Đang thêm đánh giá cho sản phẩm: ${danhGia.sanPhamId}');
      return await _api.themDanhGia(danhGia);
    } catch (e) {
      print('❌ Lỗi khi thêm đánh giá: $e');
      return false;
    }
  }

  // Lấy danh sách đánh giá theo sản phẩm
  static Future<List<DanhGia>> layDanhGiaTheoSanPham(String sanPhamId) async {
    try {
      print('🔄 Đang lấy đánh giá cho sản phẩm: $sanPhamId');
      List<DanhGia> danhSach = await _api.layDanhGiaTheoSanPham(sanPhamId);

      // Sắp xếp theo thời gian (Backend nên làm việc này, nhưng giữ lại code của bạn cho chắc chắn)
      danhSach.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.ngayTao);
          final dateB = DateTime.parse(b.ngayTao);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      return danhSach;
    } catch (e) {
      print('❌ Lỗi khi lấy đánh giá: $e');
      return [];
    }
  }

  // Lấy thống kê đánh giá
  static Future<ThongKeDanhGia> layThongKeDanhGia(String sanPhamId) async {
    try {
      return await _api.layThongKeDanhGia(sanPhamId);
    } catch (e) {
      print('❌ Lỗi khi lấy thống kê: $e');
      return ThongKeDanhGia(
        diemTrungBinh: 0.0,
        tongSoDanhGia: 0,
        phanBoSao: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }
  }

  // Kiểm tra người dùng đã đánh giá chưa
  static Future<bool> kiemTraDaDanhGia(String sanPhamId, String nguoiDungId) async {
    try {
      return await _api.kiemTraDaDanhGia(sanPhamId, nguoiDungId);
    } catch (e) {
      return false;
    }
  }

  // Cập nhật đánh giá
  static Future<bool> capNhatDanhGia(String danhGiaId, int soSao, String binhLuan) async {
    try {
      final updateData = {
        'soSao': soSao,
        'binhLuan': binhLuan,
        'ngayCapNhat': DateTime.now().toIso8601String(),
      };
      return await _api.capNhatDanhGia(danhGiaId, updateData);
    } catch (e) {
      print('❌ Lỗi khi cập nhật: $e');
      return false;
    }
  }

  // Xóa đánh giá
  static Future<bool> xoaDanhGia(String danhGiaId) async {
    try {
      return await _api.xoaDanhGia(danhGiaId);
    } catch (e) {
      print('❌ Lỗi khi xóa: $e');
      return false;
    }
  }

  // Stream đánh giá (Polling)
  static Stream<List<DanhGia>> streamDanhGiaTheoSanPham(String sanPhamId) async* {
    while (true) {
      yield await layDanhGiaTheoSanPham(sanPhamId);
      await Future.delayed(const Duration(seconds: 15)); // Cập nhật mỗi 15 giây
    }
  }

  // Lấy đánh giá cụ thể của user
  static Future<DanhGia?> layDanhGiaCuaNguoiDung(String sanPhamId, String nguoiDungId) async {
    try {
      return await _api.layDanhGiaCuaNguoiDung(sanPhamId, nguoiDungId);
    } catch (e) {
      return null;
    }
  }
}