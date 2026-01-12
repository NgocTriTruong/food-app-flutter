import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:kfc/models/don_hang.dart';

part 'don_hang_api.g.dart';

@RestApi()
abstract class DonHangApi {
  factory DonHangApi(Dio dio, {String baseUrl}) = _DonHangApi;

  @POST("/orders")
  Future<String> createDonHang(@Body() DonHang donHang);

  @GET("/orders/user/{userId}")
  Future<List<DonHang>> getDonHangByUser(@Path("userId") String userId);

  @GET("/orders/{id}")
  Future<DonHang> getDonHangById(@Path("id") String id);

  @PATCH("/orders/{id}/status")
  Future<void> updateTrangThaiDonHang(
      @Path("id") String id,
      @Query("status") String trangThai
      );

  @GET("/orders")
  Future<List<DonHang>> getAllDonHang();

  @GET("/orders/status/{status}")
  Future<List<DonHang>> getDonHangByTrangThai(@Path("status") String trangThai);

  @GET("/orders/report")
  Future<List<DonHang>> getDonHangByDateRange(
      @Query("startDate") String startDate,
      @Query("endDate") String endDate
      );
}