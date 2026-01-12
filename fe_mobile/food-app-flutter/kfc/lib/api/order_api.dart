import 'package:dio/dio.dart';
import 'package:kfc/models/don_hang.dart';
import 'package:retrofit/retrofit.dart';

part 'order_api.g.dart';

@RestApi()
abstract class OrderApi {
  factory OrderApi(Dio dio, {String baseUrl}) = _OrderApi;

  @GET('/orders')
  Future<List<DonHang>> getAllOrders();

  @GET('/orders/{id}')
  Future<DonHang> getOrderById(@Path('id') String id);

  @GET('/orders/user/{userId}')
  Future<List<DonHang>> getOrdersByUser(@Path('userId') String userId);

  @POST('/orders')
  Future<DonHang> createOrder(@Body() DonHang order);
}
