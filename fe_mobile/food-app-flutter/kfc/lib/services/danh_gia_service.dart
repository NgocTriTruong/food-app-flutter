import 'package:dio/dio.dart';
import 'package:kfc/network/dio_client.dart';
import '../models/danh_gia.dart';

class DanhGiaService {
  static final Dio _dio = DioClient.dio();

  // Thêm đánh giá mới
  static Future<bool> themDanhGia(DanhGia danhGia) async {
    try {
      print('🔄 Đang thêm đánh giá cho sản phẩm: ${danhGia.sanPhamId}');
      print('📝 Thông tin đánh giá: ${danhGia.toJson()}');
      
      final response = await _dio.post('/reviews', data: danhGia.toJson());
      print('✅ Thêm đánh giá thành công: ${response.data}');
      
      return response.data == true;
    } catch (e) {
      print('❌ Lỗi khi thêm đánh giá: $e');
      return false;
    }
  }

  // Lấy danh sách đánh giá theo sản phẩm
  static Future<List<DanhGia>> layDanhGiaTheoSanPham(String sanPhamId) async {
    try {
      print('🔄 Đang lấy đánh giá cho sản phẩm: $sanPhamId');
      
      final response = await _dio.get('/reviews/product/$sanPhamId');
      
      List<DanhGia> danhSachDanhGia = [];
      for (var data in response.data) {
        try {
          print('📄 Raw data từ backend: $data');
          
          final danhGia = DanhGia.fromJson(data);
          print('✅ Parsed đánh giá: ${danhGia.tenNguoiDung}, ${danhGia.soSao} sao, ${danhGia.binhLuan}');
          
          danhSachDanhGia.add(danhGia);
        } catch (e) {
          print('⚠️ Lỗi parse đánh giá: $e');
        }
      }

      print('✅ Lấy thành công ${danhSachDanhGia.length} đánh giá');
      return danhSachDanhGia;
    } catch (e) {
      print('❌ Lỗi khi lấy đánh giá: $e');
      return [];
    }
  }

  // Lấy thống kê đánh giá theo sản phẩm
  static Future<ThongKeDanhGia> layThongKeDanhGia(String sanPhamId) async {
    try {
      final response = await _dio.get('/reviews/product/$sanPhamId/stats');
      final data = response.data;
      
      return ThongKeDanhGia(
        diemTrungBinh: (data['diemTrungBinh'] ?? 0.0).toDouble(),
        tongSoDanhGia: data['tongSoDanhGia'] ?? 0,
        phanBoSao: {
          1: data['phanBoSao']?['1'] ?? 0,
          2: data['phanBoSao']?['2'] ?? 0,
          3: data['phanBoSao']?['3'] ?? 0,
          4: data['phanBoSao']?['4'] ?? 0,
          5: data['phanBoSao']?['5'] ?? 0,
        },
      );
    } catch (e) {
      print('❌ Lỗi khi lấy thống kê đánh giá: $e');
      return ThongKeDanhGia(
        diemTrungBinh: 0.0,
        tongSoDanhGia: 0,
        phanBoSao: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      );
    }
  }

  // Kiểm tra người dùng đã đánh giá sản phẩm chưa
  static Future<bool> kiemTraDaDanhGia(String sanPhamId, String nguoiDungId) async {
    try {
      final response = await _dio.get('/reviews/check', 
        queryParameters: {'productId': sanPhamId, 'userId': nguoiDungId});
      
      return response.data == true;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra đánh giá: $e');
      return false;
    }
  }

  // Cập nhật đánh giá
  static Future<bool> capNhatDanhGia(String danhGiaId, int soSao, String binhLuan) async {
    try {
      final response = await _dio.patch('/reviews/$danhGiaId', data: {
        'soSao': soSao,
        'binhLuan': binhLuan,
      });
      
      print('✅ Cập nhật đánh giá thành công');
      return response.data == true;
    } catch (e) {
      print('❌ Lỗi khi cập nhật đánh giá: $e');
      return false;
    }
  }

  // Xóa đánh giá
  static Future<bool> xoaDanhGia(String danhGiaId) async {
    try {
      final response = await _dio.delete('/reviews/$danhGiaId');
      
      print('✅ Xóa đánh giá thành công');
      return response.data == true;
    } catch (e) {
      print('❌ Lỗi khi xóa đánh giá: $e');
      return false;
    }
  }

  // Lấy đánh giá của người dùng cho sản phẩm
  static Future<DanhGia?> layDanhGiaCuaNguoiDung(String sanPhamId, String nguoiDungId) async {
    try {
      final response = await _dio.get('/reviews/user-product',
        queryParameters: {'productId': sanPhamId, 'userId': nguoiDungId});
      
      if (response.data != null && response.data is Map) {
        return DanhGia.fromJson(response.data);
      }
      
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy đánh giá của người dùng: $e');
      return null;
    }
  }
}
