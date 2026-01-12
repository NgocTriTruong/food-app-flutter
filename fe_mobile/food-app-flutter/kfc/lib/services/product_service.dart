import 'package:dio/dio.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:kfc/models/san_pham.dart';

class ProductService {
  static final Dio _dio = DioClient.dio();

  // Lấy tất cả sản phẩm
  static Future<List<SanPham>> getAll() async {
    try {
      final response = await _dio.get('/products');
      final List<dynamic> data = response.data;
      return data.map((json) => SanPham.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi lấy danh sách sản phẩm: $e');
      rethrow;
    }
  }

  // Tạo sản phẩm mới (admin)
  static Future<SanPham> create(Map<String, dynamic> productData) async {
    try {
      final response = await _dio.post('/products/admin/create', data: productData);
      return SanPham.fromJson(response.data);
    } catch (e) {
      print('Lỗi khi tạo sản phẩm: $e');
      rethrow;
    }
  }

  // Cập nhật sản phẩm (admin)
  static Future<SanPham> update(String id, Map<String, dynamic> productData) async {
    try {
      final response = await _dio.put('/products/admin/$id', data: productData);
      return SanPham.fromJson(response.data);
    } catch (e) {
      print('Lỗi khi cập nhật sản phẩm: $e');
      rethrow;
    }
  }

  // Xóa sản phẩm (admin)
  static Future<void> delete(String id) async {
    try {
      await _dio.delete('/products/admin/$id');
    } catch (e) {
      print('Lỗi khi xóa sản phẩm: $e');
      rethrow;
    }
  }

  // Lấy chi tiết sản phẩm theo ID
  static Future<SanPham> getById(String id) async {
    try {
      final response = await _dio.get('/products/$id');
      return SanPham.fromJson(response.data);
    } catch (e) {
      print('Lỗi khi lấy sản phẩm: $e');
      rethrow;
    }
  }

  // Tìm kiếm sản phẩm
  static Future<List<SanPham>> search(String query) async {
    try {
      final response = await _dio.get('/products/search', queryParameters: {'query': query});
      final List<dynamic> data = response.data;
      return data.map((json) => SanPham.fromJson(json)).toList();
    } catch (e) {
      print('Lỗi khi tìm kiếm sản phẩm: $e');
      rethrow;
    }
  }
}
