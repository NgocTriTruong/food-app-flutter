## API ENDPOINTS - ADMIN QUẢN LÝ (TIẾNG VIỆT)

### Backend được xây dựng với: Spring Boot + MongoDB Atlas

---

## 1. 📦 SẢN PHẨM (Product)

### Endpoint công khai (User xem):
- **GET** `/api/products` - Lấy tất cả sản phẩm
- **GET** `/api/products/{id}` - Lấy sản phẩm theo ID
- **GET** `/api/products/search?query=...` - Tìm kiếm sản phẩm
- **GET** `/api/products/promotions` - Lấy sản phẩm khuyến mãi
- **GET** `/api/products/category/{categoryId}` - Lấy sản phẩm theo danh mục

### Endpoint ADMIN (Quản lý):
- **POST** `/api/products/admin/create` - Tạo sản phẩm mới
  - Request body: `{ ten, gia, hinhAnh, moTa, danhMucId, khuyenMai, giamGia }`
  
- **PUT** `/api/products/admin/{id}` - Cập nhật sản phẩm
  - Request body: `{ ten, gia, hinhAnh, moTa, danhMucId, khuyenMai, giamGia }`
  
- **DELETE** `/api/products/admin/{id}` - Xóa sản phẩm

---

## 2. 👥 NGƯỜI DÙNG (User)

### Endpoint công khai:
- **GET** `/api/users` - Lấy tất cả người dùng
- **GET** `/api/users/{uid}` - Lấy thông tin người dùng theo ID
- **GET** `/api/users/test` - Endpoint test

### Endpoint ADMIN (Quản lý):
- **PUT** `/api/users/admin/{id}` - Cập nhật người dùng
  - Request body: `{ ten, email, soDienThoai, trangThaiHoatDong, rule, vaiTro }`
  - rule: "user" hoặc "admin"
  - vaiTro: ["superAdmin", "quanLyDonHang", ...]
  
- **DELETE** `/api/users/admin/{id}` - Xóa người dùng

---

## 3. 📋 ĐƠN HÀNG (Order)

### Endpoint công khai:
- **GET** `/api/orders` - Lấy tất cả đơn hàng
- **GET** `/api/orders/{id}` - Lấy đơn hàng theo ID
- **GET** `/api/orders/user/{userId}` - Lấy đơn hàng của user
- **POST** `/api/orders` - Tạo đơn hàng mới
- **PUT** `/api/orders/{id}/cancel` - Hủy đơn hàng

### Endpoint ADMIN (Quản lý):
- **PUT** `/api/orders/admin/{id}/status?status=...` - Cập nhật trạng thái đơn hàng
  - Trạng thái: `dangXuLy`, `dangGiao`, `daGiao`, `daHuy`
  - Ví dụ: `/api/orders/admin/123/status?status=dangGiao`
  
- **PUT** `/api/orders/admin/{id}` - Cập nhật thông tin đơn hàng
  - Request body: `{ tenNguoiNhan, soDienThoai, diaChi, trangThai, ghiChu, phuongThucThanhToan }`

---

## 4. 🏷️ DANH MỤC (Category)

### Endpoint công khai:
- **GET** `/api/categories` - Lấy tất cả danh mục
- **GET** `/api/categories/{id}` - Lấy danh mục theo ID

### Endpoint ADMIN (Quản lý):
- **POST** `/api/categories/admin/create` - Tạo danh mục mới
  - Request body: `{ ten, hinhAnh, moTa }`
  
- **PUT** `/api/categories/admin/{id}` - Cập nhật danh mục
  - Request body: `{ ten, hinhAnh, moTa }`
  
- **DELETE** `/api/categories/admin/{id}` - Xóa danh mục

---

## 📝 GHI CHÚ QUAN TRỌNG

1. **MongoDB Atlas**: Tất cả dữ liệu được lưu trên MongoDB Atlas (NoSQL)
2. **Java/Spring Boot**: Backend được xây dựng với Spring Boot 3.x
3. **Token**: Hiện tại sử dụng token giả (ey_dummy_token_...), nên thêm JWT trong tương lai
4. **Comment tiếng Việt**: Tất cả code đã được thêm comment tiếng Việt
5. **Lỗi xử lý**: Nếu resource không tìm thấy sẽ trả về lỗi 404

---

## 🔧 CẤU TRÚC FOLDER BACKEND

```
src/main/java/org/example/food_app_be/
├── controller/     (Các endpoint API)
│   ├── ProductController.java
│   ├── OrderController.java
│   ├── UserController.java
│   └── CategoryController.java
├── service/        (Logic xử lý dữ liệu)
│   ├── ProductService.java
│   ├── OrderService.java
│   ├── UserService.java
│   └── CategoryService.java
├── model/          (Định nghĩa dữ liệu)
│   ├── Product.java
│   ├── Order.java
│   ├── User.java
│   └── Category.java
├── repository/     (Giao tiếp với MongoDB)
│   ├── ProductRepository.java
│   ├── OrderRepository.java
│   ├── UserRepository.java
│   └── CategoryRepository.java
└── FoodAppBeApplication.java (Chương trình chính)
```

---

## 🚀 HƯỚNG DẪN CHẠY BACKEND

1. **Cấu hình MongoDB Atlas**:
   - Mở `application.properties`
   - Thêm cấu hình kết nối MongoDB Atlas

2. **Build và chạy**:
   ```bash
   cd d:\mobile\be_mobile\food-app_BE
   ./gradlew bootRun
   ```

3. **Kiểm tra API**:
   - Backend sẽ chạy tại `http://localhost:8080`
   - Dùng Postman để test các endpoint

---

## ✅ CHỈ TIÊU HOÀN THÀNH

- ✅ Tạo API endpoints cho tất cả tính năng admin
- ✅ Thêm các hàm create, update, delete cho Product, Order, User, Category
- ✅ Thêm comment tiếng Việt cho tất cả code
- ✅ Tách admin endpoints (`/admin/...`) riêng biệt
- ⏳ Cần cập nhật Frontend để gọi API thay vì Firebase

