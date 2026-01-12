# Hướng dẫn kiểm tra tính năng Quên mật khẩu

## Tính năng đã hoàn thành

✅ **Backend (Spring Boot)**
- POST `/api/auth/forgot-password` - Kiểm tra email có tồn tại
- POST `/api/auth/reset-password` - Cập nhật mật khẩu mới

✅ **Frontend (Flutter)**
- Màn hình `ManHinhQuenMatKhau` - Nhập email
- Màn hình `ManHinhDatLaiMatKhau` - Nhập mật khẩu mới
- Link "Quên mật khẩu?" trên màn hình đăng nhập

## Cách kiểm tra

### Bước 1: Mở ứng dụng
- Mở app trên emulator
- Vào màn hình Tài khoản

### Bước 2: Thử nghiệm Quên mật khẩu
1. **Nhấn vào "Quên mật khẩu?"** (link màu cam bên dưới nút Đăng nhập)

2. **Màn hình Khôi phục tài khoản**
   - Nhập email đã đăng ký (ví dụ: `test@email.com`)
   - Nhấn "Gửi yêu cầu"
   - Nếu email tồn tại → Chuyển sang màn hình Đặt lại mật khẩu
   - Nếu email không tồn tại → Hiển thị thông báo "Không tìm thấy tài khoản với email này"

3. **Màn hình Đặt lại mật khẩu**
   - Nhập mật khẩu mới (tối thiểu 6 ký tự)
   - Nhập lại mật khẩu để xác nhận
   - Nhấn "Đặt lại mật khẩu"
   - Nếu thành công → Quay về màn hình đăng nhập với thông báo "Đặt lại mật khẩu thành công!"
   - Nếu lỗi → Hiển thị thông báo lỗi

4. **Đăng nhập với mật khẩu mới**
   - Nhập email và mật khẩu mới vừa đặt
   - Đăng nhập thành công

## Các trường hợp kiểm tra

### Test case 1: Email tồn tại
- Email: Sử dụng email đã đăng ký trong database
- Kết quả mong đợi: Cho phép đặt lại mật khẩu

### Test case 2: Email không tồn tại
- Email: `khongtontai@test.com`
- Kết quả mong đợi: Hiển thị "Không tìm thấy tài khoản với email này"

### Test case 3: Email không hợp lệ
- Email: `email-sai-format`
- Kết quả mong đợi: Hiển thị "Vui lòng nhập email hợp lệ"

### Test case 4: Mật khẩu không khớp
- Mật khẩu mới: `123456`
- Xác nhận: `654321`
- Kết quả mong đợi: Hiển thị "Mật khẩu xác nhận không khớp"

### Test case 5: Mật khẩu quá ngắn
- Mật khẩu: `12345` (5 ký tự)
- Kết quả mong đợi: Hiển thị "Mật khẩu phải có ít nhất 6 ký tự"

## API Endpoints

### 1. Quên mật khẩu (Kiểm tra email)
```
POST http://10.0.2.2:8080/api/auth/forgot-password
Content-Type: application/json

{
  "email": "test@email.com"
}

Response 200: { "message": "Verification code sent to your email" }
Response 404: Email không tồn tại
```

### 2. Đặt lại mật khẩu
```
POST http://10.0.2.2:8080/api/auth/reset-password
Content-Type: application/json

{
  "email": "test@email.com",
  "newPassword": "matkhaumoi123"
}

Response 200: { "message": "Password reset successful" }
Response 404: Email không tồn tại
```

## Ghi chú kỹ thuật

⚠️ **Lưu ý quan trọng:**
- Hiện tại mật khẩu lưu dạng plain text (chưa mã hóa)
- Backend có comment TODO về việc cần thêm password hashing
- Không gửi email thực (tính năng demo)
- Không có verification code/OTP (để đơn giản)

🔐 **Cải tiến cho production:**
1. Thêm password hashing (BCrypt hoặc Argon2)
2. Gửi email verification code
3. Thêm expiry time cho reset token
4. Rate limiting để tránh spam
5. CAPTCHA để tránh bot

## Cấu trúc code

### Backend
- `ForgotPasswordRequest.java` - DTO nhận email
- `ResetPasswordRequest.java` - DTO nhận email + password mới
- `UserService.resetPassword()` - Logic reset password
- `AuthController` - Endpoints `/auth/forgot-password` và `/auth/reset-password`

### Frontend
- `man_hinh_quen_mat_khau.dart` - UI nhập email
- `man_hinh_dat_lai_mat_khau.dart` - UI nhập password mới
- `auth_api.dart` - Retrofit API definitions
- `auth_service.dart` - Service layer với error handling
- `man_hinh_tai_khoan.dart` - Thêm link "Quên mật khẩu?"

## Trạng thái hiện tại
✅ Backend hoàn chỉnh
✅ Frontend hoàn chỉnh
✅ Retrofit code đã generate
✅ App build thành công
✅ Sẵn sàng kiểm tra

---
**Ngày tạo:** 2024
**Phiên bản:** 1.0
