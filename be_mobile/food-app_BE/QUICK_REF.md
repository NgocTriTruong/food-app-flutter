## 🎯 **QUICK REFERENCE - ADMIN ENDPOINTS**

### 🚀 **Start Backend**
```bash
cd d:\mobile\be_mobile\food-app_BE
./gradlew bootRun
```
Server chạy tại: `http://localhost:8080`

---

## **📦 PRODUCT - Sản Phẩm**

```bash
# Tạo mới
POST /api/products/admin/create
{ "ten": "...", "gia": 45000, "hinhAnh": "...", "moTa": "..." }

# Cập nhật
PUT /api/products/admin/{id}
{ "ten": "...", "gia": 50000 }

# Xóa
DELETE /api/products/admin/{id}
```

---

## **📋 ORDER - Đơn Hàng**

```bash
# Hủy đơn hàng
PUT /api/orders/{id}/cancel

# Cập nhật trạng thái (admin)
PUT /api/orders/admin/{id}/status?status=dangGiao
(dangXuLy, dangGiao, daGiao, daHuy)

# Cập nhật thông tin (admin)
PUT /api/orders/admin/{id}
{ "tenNguoiNhan": "...", "diaChi": "...", "trangThai": "dangGiao" }
```

---

## **👥 USER - Người Dùng**

```bash
# Cập nhật
PUT /api/users/admin/{id}
{ "ten": "...", "email": "...", "rule": "admin" }

# Xóa
DELETE /api/users/admin/{id}
```

---

## **🏷️ CATEGORY - Danh Mục**

```bash
# Tạo mới
POST /api/categories/admin/create
{ "ten": "Gà rán", "hinhAnh": "...", "moTa": "..." }

# Cập nhật
PUT /api/categories/admin/{id}
{ "ten": "...", "moTa": "..." }

# Xóa
DELETE /api/categories/admin/{id}
```

---

## **📊 Lấy Danh Sách**

```bash
GET /api/products              # Tất cả sản phẩm
GET /api/orders                # Tất cả đơn hàng
GET /api/orders/user/{userId}  # Đơn hàng của user
GET /api/users                 # Tất cả user
GET /api/categories            # Tất cả danh mục
```

---

## **🛠️ Troubleshooting**

| Lỗi | Nguyên nhân | Cách fix |
|-----|-----------|---------|
| 404 | ID không tồn tại | Kiểm tra danh sách với GET |
| 400 | Request sai | Check JSON format |
| 500 | Lỗi server | Xem backend logs |

---

## **📝 Notes**

✅ Tất cả endpoints có error handling
✅ Tất cả admin endpoints bắt đầu với `/admin/`
✅ Comments tiếng Việt trong code
✅ MongoDB ObjectId format: 24 hex characters

---

**🎉 Backend đã sẵn sàng!**
