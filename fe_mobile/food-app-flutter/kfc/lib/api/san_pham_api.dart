import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/san_pham.dart';
import '../models/danh_muc.dart';

part 'san_pham_api.g.dart';

@RestApi()
abstract class SanPhamApi {
  factory SanPhamApi(Dio dio, {String baseUrl}) = _SanPhamApi;

  @GET("/categories")
  Future<List<DanhMuc>> getCategories();

  @GET("/products")
  Future<List<SanPham>> getProducts();

  @GET("/products/category/{categoryId}")
  Future<List<SanPham>> getProductsByCategory(@Path("categoryId") String categoryId);

  @GET("/products/promotions")
  Future<List<SanPham>> getPromotionalProducts();

  @GET("/products/featured")
  Future<List<SanPham>> getFeaturedProducts();

  @GET("/products/search")
  Future<List<SanPham>> searchProducts(@Query("query") String query);

  @GET("/products/{id}")
  Future<SanPham> getProductById(@Path("id") String id);

  @GET("/products/{id}/related")
  Future<List<SanPham>> getRelatedProducts(@Path("id") String id);
}