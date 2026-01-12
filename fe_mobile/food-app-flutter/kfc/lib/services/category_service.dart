import 'package:dio/dio.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:kfc/models/danh_muc.dart';

class CategoryService {
  static final Dio _dio = DioClient.dio();

  // Lấy tất cả danh mục
  static Future<List<DanhMuc>> getAll() async {
    try {
      print('Đang lấy danh mục từ backend...');
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Lấy danh mục thành công: ${data.length} danh mục');
        
        return data
            .map((item) => DanhMuc(
              id: item['id'] ?? item['_id'] ?? '',
              ten: item['ten'] ?? '',
              hinhAnh: item['hinhAnh'] ?? '',
              moTa: item['moTa'] ?? '',
            ))
            .toList();
      } else {
        throw Exception('Lỗi lấy danh mục: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi lấy danh mục: $e');
      rethrow;
    }
  }

  // Lấy danh mục theo ID
  static Future<DanhMuc?> getById(String id) async {
    try {
      print('Đang lấy danh mục: $id');
      final response = await _dio.get('/categories/$id');

      if (response.statusCode == 200) {
        final data = response.data;
        print('Lấy danh mục thành công: ${data['ten']}');
        
        return DanhMuc(
          id: data['id'] ?? data['_id'] ?? '',
          ten: data['ten'] ?? '',
          hinhAnh: data['hinhAnh'] ?? '',
          moTa: data['moTa'] ?? '',
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Lỗi khi lấy danh mục: $e');
      return null;
    }
  }

  // Tạo danh mục mới (Admin)
  static Future<DanhMuc?> create(String ten, String hinhAnh, String moTa) async {
    try {
      print('Đang tạo danh mục: $ten');
      final response = await _dio.post('/categories/admin/create', data: {
        'ten': ten,
        'hinhAnh': hinhAnh,
        'moTa': moTa,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        print('Tạo danh mục thành công: ${data['ten']}');
        
        return DanhMuc(
          id: data['id'] ?? data['_id'] ?? '',
          ten: data['ten'] ?? '',
          hinhAnh: data['hinhAnh'] ?? '',
          moTa: data['moTa'] ?? '',
        );
      } else {
        throw Exception('Lỗi tạo danh mục: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi tạo danh mục: $e');
      rethrow;
    }
  }

  // Cập nhật danh mục (Admin)
  static Future<DanhMuc?> update(String id, String ten, String hinhAnh, String moTa) async {
    try {
      print('Đang cập nhật danh mục: $id');
      final response = await _dio.put('/categories/admin/$id', data: {
        'ten': ten,
        'hinhAnh': hinhAnh,
        'moTa': moTa,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        print('Cập nhật danh mục thành công: ${data['ten']}');
        
        return DanhMuc(
          id: data['id'] ?? data['_id'] ?? '',
          ten: data['ten'] ?? '',
          hinhAnh: data['hinhAnh'] ?? '',
          moTa: data['moTa'] ?? '',
        );
      } else {
        throw Exception('Lỗi cập nhật danh mục: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi cập nhật danh mục: $e');
      rethrow;
    }
  }

  // Xóa danh mục (Admin)
  static Future<void> delete(String id) async {
    try {
      print('Đang xóa danh mục: $id');
      final response = await _dio.delete('/categories/admin/$id');

      if (response.statusCode == 200) {
        print('Xóa danh mục thành công: $id');
      } else {
        throw Exception('Lỗi xóa danh mục: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi xóa danh mục: $e');
      rethrow;
    }
  }
}
