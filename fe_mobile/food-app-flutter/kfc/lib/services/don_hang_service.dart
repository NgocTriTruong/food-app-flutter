// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kfc/models/don_hang.dart';
import 'package:kfc/models/san_pham_gio_hang.dart';
import 'package:dio/dio.dart';

class DonHangService {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator localhost
  final Dio _dio = Dio();

  // Hủy đơn hàng
  Future<void> cancelDonHang(String id) async {
    try {
      print('🔴 Hủy đơn hàng ID: $id');
      final response = await _dio.put(
        '$baseUrl/orders/$id/cancel',
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      
      if (response.statusCode == 200) {
        print('✅ Hủy đơn hàng thành công: $id');
      } else {
        throw Exception('Lỗi hủy đơn: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi khi hủy đơn hàng: $e');
      throw e;
    }
  }
}
