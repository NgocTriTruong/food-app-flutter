import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/danh_gia.dart';

part 'danh_gia_api.g.dart';

@RestApi()
abstract class DanhGiaApi {
  factory DanhGiaApi(Dio dio, {String baseUrl}) = _DanhGiaApi;

  @POST("/reviews")
  Future<bool> themDanhGia(@Body() DanhGia danhGia);

  @GET("/reviews/product/{productId}")
  Future<List<DanhGia>> layDanhGiaTheoSanPham(@Path("productId") String sanPhamId);

  @GET("/reviews/product/{productId}/stats")
  Future<ThongKeDanhGia> layThongKeDanhGia(@Path("productId") String sanPhamId);

  @GET("/reviews/check")
  Future<bool> kiemTraDaDanhGia(
      @Query("productId") String sanPhamId,
      @Query("userId") String nguoiDungId
      );

  @PATCH("/reviews/{id}")
  Future<bool> capNhatDanhGia(
      @Path("id") String id,
      @Body() Map<String, dynamic> updateData
      );

  @DELETE("/reviews/{id}")
  Future<bool> xoaDanhGia(@Path("id") String id);

  @GET("/reviews/user-product")
  Future<DanhGia?> layDanhGiaCuaNguoiDung(
      @Query("productId") String sanPhamId,
      @Query("userId") String nguoiDungId
      );
}