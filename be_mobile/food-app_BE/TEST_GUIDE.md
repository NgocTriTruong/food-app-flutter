## 📝 HƯỚNG DẪN TEST TẤT CẢ ADMIN FEATURES

### 🎯 Các tính năng Admin cần Test

1. **Quản lý Sản phẩm** (Product Management)
2. **Quản lý Người dùng** (User Management)
3. **Quản lý Đơn hàng** (Order Management)
4. **Quản lý Danh mục** (Category Management)

---

## 1️⃣ **QUẢN LÝ SẢN PHẨM**

### Lấy danh sách sản phẩm
```bash
GET http://localhost:8080/api/products
```

### Tạo sản phẩm mới
```bash
POST http://localhost:8080/api/products/admin/create
Content-Type: application/json

{
  "ten": "Gà rán KFC",
  "gia": 45000,
  "hinhAnh": "https://example.com/image.jpg",
  "moTa": "Gà rán giòn, ngon",
  "danhMucId": "507f1f77bcf86cd799439011",
  "khuyenMai": true,
  "giamGia": 20
}
```
**Response**: Trả về sản phẩm mới (có ID)

### Cập nhật sản phẩm
```bash
PUT http://localhost:8080/api/products/admin/{id}
Content-Type: application/json

{
  "ten": "Gà rán KFC - Updated",
  "gia": 50000,
  "giamGia": 25
}
```

### Xóa sản phẩm
```bash
DELETE http://localhost:8080/api/products/admin/{id}
```

---

## 2️⃣ **QUẢN LÝ NGƯỜI DÙNG**

### Lấy danh sách người dùng
```bash
GET http://localhost:8080/api/users
```

### Lấy thông tin một người dùng
```bash
GET http://localhost:8080/api/users/{userId}
```

### Cập nhật người dùng
```bash
PUT http://localhost:8080/api/users/admin/{userId}
Content-Type: application/json

{
  "ten": "Nguyễn Văn A",
  "email": "nguyenvana@example.com",
  "soDienThoai": "0912345678",
  "rule": "admin",
  "trangThaiHoatDong": true,
  "vaiTro": ["superAdmin", "quanLyDonHang"]
}
```

### Xóa người dùng
```bash
DELETE http://localhost:8080/api/users/admin/{userId}
```

---

## 3️⃣ **QUẢN LÝ ĐƠN HÀNG** ⭐ (Tìm lỗi 404)

### Lấy danh sách đơn hàng
```bash
GET http://localhost:8080/api/orders
```
✅ **Lưu ID từ response**

### Lấy đơn hàng của user
```bash
GET http://localhost:8080/api/orders/user/{userId}
```

### Lấy chi tiết một đơn hàng
```bash
GET http://localhost:8080/api/orders/{orderId}
```

### ❌ HỦY ĐƠN HÀNG (Có lỗi 404)
```bash
PUT http://localhost:8080/api/orders/{orderId}/cancel
```
✅ **FIX**: Kiểm tra Order ID có tồn tại không

### Cập nhật trạng thái (ADMIN)
```bash
PUT http://localhost:8080/api/orders/admin/{orderId}/status?status=dangGiao
```
**Các giá trị status:**
- `dangXuLy` - Đang xử lý
- `dangGiao` - Đang giao
- `daGiao` - Đã giao
- `daHuy` - Đã hủy

### Cập nhật thông tin đơn hàng (ADMIN)
```bash
PUT http://localhost:8080/api/orders/admin/{orderId}
Content-Type: application/json

{
  "tenNguoiNhan": "Nguyễn Văn B",
  "soDienThoai": "0987654321",
  "diaChi": "456 Đường XYZ, HN",
  "ghiChu": "Giao lúc 18h",
  "phuongThucThanhToan": "COD",
  "trangThai": "dangGiao"
}
```

---

## 4️⃣ **QUẢN LÝ DANH MỤC**

### Lấy danh sách danh mục
```bash
GET http://localhost:8080/api/categories
```

### Lấy danh mục theo ID
```bash
GET http://localhost:8080/api/categories/{categoryId}
```

### Tạo danh mục mới
```bash
POST http://localhost:8080/api/categories/admin/create
Content-Type: application/json

{
  "ten": "Gà rán",
  "hinhAnh": "https://example.com/ga-ran.jpg",
  "moTa": "Những món gà rán ngon"
}
```

### Cập nhật danh mục
```bash
PUT http://localhost:8080/api/categories/admin/{categoryId}
Content-Type: application/json

{
  "ten": "Gà rán - Updated",
  "moTa": "Gà rán chất lượng"
}
```

### Xóa danh mục
```bash
DELETE http://localhost:8080/api/categories/admin/{categoryId}
```

---

## 🧪 **TEST FLOW (Quy trình Test)**

### 1. **Start Backend**
```bash
cd d:\mobile\be_mobile\food-app_BE
./gradlew bootRun
```
✅ Đợi đến khi thấy: `Started FoodAppBeApplication`

### 2. **Test Danh mục**
```
1. GET /api/categories → Lấy danh sách
2. POST /api/categories/admin/create → Tạo danh mục mới
   (Lưu ID từ response)
3. PUT /api/categories/admin/{id} → Cập nhật
4. DELETE /api/categories/admin/{id} → Xóa
```

### 3. **Test Sản phẩm**
```
1. POST /api/products/admin/create → Tạo sản phẩm
   (Dùng categoryId từ bước 2)
2. GET /api/products → Xem danh sách
3. PUT /api/products/admin/{id} → Cập nhật
4. DELETE /api/products/admin/{id} → Xóa
```

### 4. **Test Người dùng**
```
1. GET /api/users → Xem danh sách (lưu ID)
2. PUT /api/users/admin/{id} → Cập nhật
3. DELETE /api/users/admin/{id} → Xóa
```

### 5. **Test Đơn hàng** ⭐
```
1. GET /api/orders → Xem danh sách (lưu orderId)
2. PUT /api/orders/{orderId}/cancel → HỦY
3. PUT /api/orders/admin/{orderId}/status?status=dangGiao → Update status
4. PUT /api/orders/admin/{orderId} → Update thông tin
```

---

## ⚠️ **Lỗi Thường Gặp và Cách Fix**

### ❌ **404 Not Found**
**Nguyên nhân**: Resource ID không tồn tại hoặc path sai
**Fix**: 
1. Kiểm tra ID có tồn tại: `GET /api/orders` (xem danh sách)
2. Kiểm tra path routing (đã fix ở OrderController)

### ❌ **400 Bad Request**
**Nguyên nhân**: Request body sai format
**Fix**: Kiểm tra JSON format, data types

### ❌ **500 Internal Server Error**
**Nguyên nhân**: Lỗi database hoặc logic
**Fix**: Kiểm tra logs backend

---

## 📊 **Kiểm Tra Logs Backend**

Khi test, hãy xem console backend:
```
2026-01-10 19:47:55 - Starting HTTP request
2026-01-10 19:47:55 - Mapping requests...
2026-01-10 19:47:55 - Response status 200
```

✅ Status 200 = Thành công
❌ Status 404 = Không tìm thấy
❌ Status 400 = Request sai
❌ Status 500 = Lỗi server

---

## ✅ **Checklist Hoàn Thành**

- [ ] Backend chạy bình thường (no errors)
- [ ] Test GET endpoints (lấy danh sách)
- [ ] Test POST endpoints (tạo mới)
- [ ] Test PUT endpoints (cập nhật)
- [ ] Test DELETE endpoints (xóa)
- [ ] Test hủy đơn hàng (404 fix)
- [ ] Test cập nhật trạng thái đơn hàng
- [ ] Test cập nhật thông tin đơn hàng

---

## 💡 **Tips**

1. **Dùng Postman hoặc Insomnia** để test API
2. **Lưu lại ID** từ các response để dùng cho request tiếp theo
3. **Check MongoDB Atlas** để verify dữ liệu
4. **Restart backend** nếu có thay đổi code
5. **Kiểm tra Console logs** để debug

---

**Status: ✅ Tất cả admin endpoints đã ready, có xử lý error tốt**
