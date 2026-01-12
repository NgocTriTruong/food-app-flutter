## 🔧 DEBUG - HỦY ĐƠN HÀNG (Lỗi 404)

### 🐛 **Vấn đề gốc:**
Lỗi `404 Not Found` khi gọi API hủy đơn hàng hoặc update đơn hàng

```
DioException [DioExceptionType.unknown]: 
DioException [bad response]: 
This exception was thrown because the response status code 404 and 
RequestOptions.validateStatus was configured to throw for this status code
```

### 🔍 **Nguyên nhân:**

1. **Path Routing Conflict**: Đường dẫn `/api/orders/{id}` bị xung đột giữa:
   - `GET /api/orders/{id}` (lấy order)
   - `PUT /api/orders/{id}/cancel` (hủy order)

2. **Thứ tự Mapping sai**: Trong Spring, cần đặt path cụ thể trước path chung
   - ❌ SAI: `GET /{id}` rồi `GET /user/{userId}`
   - ✅ ĐÚNG: `GET /user/{userId}` rồi `GET /{id}`

3. **Order ID không tồn tại**: MongoDB tạo ObjectId (dạng `507f1f77bcf86cd799439011`), nhưng frontend có thể gửi String khác

### ✅ **Các Endpoint Hủy/Cập Nhật Đơn Hàng:**

#### 1. **Hủy đơn hàng (User hoặc Admin)**
```
PUT /api/orders/{id}/cancel
```
- **ID cần thiết**: Order ID (từ MongoDB)
- **Response**: Trả về Order object nếu thành công
- **Điều kiện**: Chỉ được hủy nếu đơn hàng đang ở trạng thái `dangXuLy`

**Ví dụ Postman:**
```
PUT http://localhost:8080/api/orders/6935003/cancel
```

---

#### 2. **Cập nhật trạng thái đơn hàng (ADMIN ONLY)**
```
PUT /api/orders/admin/{id}/status?status=...
```
- **ID cần thiết**: Order ID
- **Query Parameter**: `status` = `dangXuLy` | `dangGiao` | `daGiao` | `daHuy`
- **Response**: Trả về Order object

**Ví dụ Postman:**
```
PUT http://localhost:8080/api/orders/admin/6935003/status?status=dangGiao
```

---

#### 3. **Cập nhật thông tin đơn hàng (ADMIN ONLY)**
```
PUT /api/orders/admin/{id}
Content-Type: application/json

{
  "tenNguoiNhan": "Nguyễn Văn A",
  "soDienThoai": "0912345678",
  "diaChi": "123 Đường ABC, HN",
  "ghiChu": "Giao lúc 19h",
  "phuongThucThanhToan": "COD",
  "trangThai": "dangGiao"
}
```

**Ví dụ Postman:**
```
PUT http://localhost:8080/api/orders/admin/6935003
Content-Type: application/json

{
  "tenNguoiNhan": "Nguyễn Văn B",
  "trangThai": "daGiao"
}
```

---

### 📋 **Tất cả Endpoints Order:**

| Chức năng | Method | Path | Yêu cầu ID | Ghi chú |
|-----------|--------|------|-----------|---------|
| Lấy tất cả | GET | `/api/orders` | ❌ | - |
| Lấy theo ID | GET | `/api/orders/{id}` | ✅ | Order ID |
| Lấy của user | GET | `/api/orders/user/{userId}` | ✅ | User ID |
| Tạo mới | POST | `/api/orders` | ❌ | Body: Order data |
| **Hủy** | **PUT** | **`/api/orders/{id}/cancel`** | **✅** | **Order ID** |
| **Status admin** | **PUT** | **`/api/orders/admin/{id}/status?status=...`** | **✅** | **Order ID** |
| **Update admin** | **PUT** | **`/api/orders/admin/{id}`** | **✅** | **Order ID** |

---

### 🆘 **Cách Fix 404 Error:**

#### 1. **Kiểm tra Order ID có tồn tại không**
```
GET http://localhost:8080/api/orders
```
- Xem danh sách tất cả order
- Copy ID từ response

#### 2. **Kiểm tra format ID**
MongoDB ObjectId format:
```
507f1f77bcf86cd799439011  ✅ Đúng (24 ký tự hex)
6935003                    ❌ Sai (quá ngắn)
```

#### 3. **Test với Postman**
```
1. GET http://localhost:8080/api/orders
   → Xem danh sách, copy _id
   
2. PUT http://localhost:8080/api/orders/{id}/cancel
   → Hủy đơn hàng
   
3. PUT http://localhost:8080/api/orders/admin/{id}/status?status=dangGiao
   → Update trạng thái admin
```

---

### 🚀 **Cách Test trên Flutter:**

```dart
// 1. Hủy đơn hàng
Future<void> cancelOrder(String orderId) async {
  final response = await dio.put(
    '/api/orders/$orderId/cancel',
  );
  print('Order cancelled: ${response.data}');
}

// 2. Update trạng thái (Admin)
Future<void> updateOrderStatus(String orderId, String status) async {
  final response = await dio.put(
    '/api/orders/admin/$orderId/status',
    queryParameters: {'status': status},
  );
  print('Status updated: ${response.data}');
}

// 3. Update thông tin (Admin)
Future<void> updateOrderInfo(String orderId, Map<String, dynamic> data) async {
  final response = await dio.put(
    '/api/orders/admin/$orderId',
    data: data,
  );
  print('Order updated: ${response.data}');
}
```

---

### ✨ **Đã Fix:**
- ✅ Sắp xếp lại path routing (user endpoint trước id endpoint)
- ✅ Thêm try-catch để handle exception
- ✅ Thêm comment ví dụ cho mỗi endpoint
- ✅ Return 404 rõ ràng khi order không tìm thấy

**Hãy rebuild backend và test lại!**
