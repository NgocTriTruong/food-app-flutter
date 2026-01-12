import 'package:kfc/api/don_hang_api.dart';
import 'package:kfc/models/don_hang.dart';
import 'package:kfc/network/dio_client.dart';

class DonHangService {
  // Sử dụng cấu hình Dio có Auth (vì đơn hàng thường yêu cầu Token)
  static final DonHangApi _donHangApi = DonHangApi(DioClient.dio(withAuth: true));

  // Tạo đơn hàng mới
  static Future<String> createDonHang(DonHang donHang) async {
    try {
      print('📤 [DonHangService] Gửi POST /orders với payload:');
      print('   - nguoiDungId: ${donHang.nguoiDungId}');
      print('   - tenNguoiNhan: ${donHang.tenNguoiNhan}');
      print('   - soDienThoai: ${donHang.soDienThoai}');
      print('   - diaChi: ${donHang.diaChi}');
      print('   - tongTien: ${donHang.tongTien}');
      print('   - phiGiaoHang: ${donHang.phiGiaoHang}');
      print('   - tongCong: ${donHang.tongCong}');
      print('   - phuongThucThanhToan: ${donHang.phuongThucThanhToan}');
      print('   - danhSachSanPham count: ${donHang.danhSachSanPham.length}');
      for (int i = 0; i < donHang.danhSachSanPham.length; i++) {
        final item = donHang.danhSachSanPham[i];
        print('      [$i] sanPham.id: ${item.sanPham.id}, soLuong: ${item.soLuong}');
      }
      print('   - Toàn bộ JSON: ${donHang.toJson()}');
      
      return await _donHangApi.createDonHang(donHang);
    } catch (e) {
      print('❌ Lỗi khi tạo đơn hàng: $e');
      rethrow;
    }
  }

  // Lấy danh sách đơn hàng của người dùng
  static Future<List<DonHang>> getDonHangByUser(String userId) async {
    try {
      return await _donHangApi.getDonHangByUser(userId);
    } catch (e) {
      print('Lỗi khi lấy danh sách đơn hàng: $e');
      return [];
    }
  }

  // Lấy chi tiết đơn hàng
  static Future<DonHang?> getDonHangById(String id) async {
    try {
      return await _donHangApi.getDonHangById(id);
    } catch (e) {
      print('Lỗi khi lấy chi tiết đơn hàng: $e');
      return null;
    }
  }

  // Cập nhật trạng thái đơn hàng
  static Future<void> updateTrangThaiDonHang(String id, TrangThaiDonHang trangThai) async {
    try {
      // Chuyển enum sang String tương ứng với Backend
      final trangThaiStr = trangThai.name;
      await _donHangApi.updateTrangThaiDonHang(id, trangThaiStr);
    } catch (e) {
      print('Lỗi khi cập nhật trạng thái đơn hàng: $e');
      rethrow;
    }
  }

  // Lấy tất cả đơn hàng (Admin)
  static Future<List<DonHang>> getAllDonHang() async {
    try {
      return await _donHangApi.getAllDonHang();
    } catch (e) {
      print('Lỗi khi lấy tất cả đơn hàng: $e');
      return [];
    }
  }

  // Lấy đơn hàng theo khoảng thời gian
  static Future<List<DonHang>> getDonHangByDateRange(DateTime start, DateTime end) async {
    try {
      return await _donHangApi.getDonHangByDateRange(
        start.toIso8601String(),
        end.toIso8601String(),
      );
    } catch (e) {
      print('Lỗi báo cáo: $e');
      return [];
    }
  }

  // LƯU Ý VỀ STREAM:
  // REST API (Retrofit) không hỗ trợ Stream tự nhiên như Firebase.
  // Để làm Real-time, bạn nên dùng WebSocket hoặc gọi lại API định kỳ (Polling).
  static Stream<List<DonHang>> streamDonHangByUser(String userId) async* {
    while (true) {
      yield await getDonHangByUser(userId);
      await Future.delayed(const Duration(seconds: 10)); // Polling mỗi 10s
    }
  }
}