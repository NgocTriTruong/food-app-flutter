package org.example.food_app_be.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import org.example.food_app_be.model.AuthProvider;
import org.example.food_app_be.model.User;
import org.example.food_app_be.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final EmailService emailService;
    private final BCryptPasswordEncoder passwordEncoder;
    private final GoogleIdTokenVerifier googleIdTokenVerifier;

    public UserService(UserRepository userRepository, EmailService emailService,GoogleIdTokenVerifier googleIdTokenVerifier
    ) {
        this.userRepository = userRepository;
        this.googleIdTokenVerifier = googleIdTokenVerifier;
        this.emailService = emailService;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }
    // Lấy tất cả người dùng
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
    
    // Lấy người dùng theo ID
    public Optional<User> getUserById(String id){
        return userRepository.findById(id);
    }
    
    // Lấy người dùng theo email
    public Optional<User> getUserByEmail(String email){
        return userRepository.findByEmailIgnoreCase(email);
    }
    
    // Đăng ký người dùng mới
    public User registerUser(String ten, String email, String password, String soDienThoai) {
        // Kiểm tra email đã tồn tại
        if (getUserByEmail(email).isPresent()) {
            throw new RuntimeException("Email đã được sử dụng");
        }
        
        User newUser = new User();
        newUser.setTen(ten);
        newUser.setEmail(email);
        newUser.setPassword(passwordEncoder.encode(password)); // Mã hóa password với BCrypt
        newUser.setSoDienThoai(soDienThoai);
        newUser.setRule("user");
        newUser.setTrangThaiHoatDong(true);
        newUser.setNgayTao(new Date());
        
        return userRepository.save(newUser);
    }
    
    // Kiểm tra email đã tồn tại không
    public boolean verifyEmailExists(String email) {
        return getUserByEmail(email).isPresent();
    }
    
    // Tạo và lưu OTP (mã xác nhận) cho việc đặt lại mật khẩu
    public String generateAndSaveOtp(String email) {
        Optional<User> userOptional = getUserByEmail(email);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            
            // Tạo OTP 6 chữ số
            String otp = String.format("%06d", (int)(Math.random() * 1000000));
            
            // Thời gian hết hạn: 5 phút
            Date expiry = new Date(System.currentTimeMillis() + 5 * 60 * 1000);
            
            user.setOtp(otp);
            user.setOtpExpiry(expiry);
            userRepository.save(user);
            
            // Gửi OTP qua email
            emailService.sendOtpEmail(email, otp);
            
            System.out.println("OTP cho " + email + ": " + otp);
            return otp;
        }
        return null;
    }
    public User loginWithGoogle(String idToken) {
        try {
            GoogleIdToken googleToken = googleIdTokenVerifier.verify(idToken);

            if (googleToken == null) {
                throw new RuntimeException("Google token không hợp lệ");
            }

            GoogleIdToken.Payload payload = googleToken.getPayload();

            String email = payload.getEmail();
            String name = (String) payload.get("name");
            String googleId = payload.getSubject();
            String avatar = (String) payload.get("picture");

            return userRepository.findByEmailIgnoreCase(email)
                    .orElseGet(() -> {
                        User u = new User();
                        u.setEmail(email);
                        u.setTen(name);
                        u.setGoogleId(googleId);
                        u.setAvatar(avatar);
                        u.setProvider(AuthProvider.GOOGLE);
                        u.setRule("user");
                        u.setTrangThaiHoatDong(true);
                        u.setNgayTao(new Date());
                        return userRepository.save(u);
                    });

        } catch (Exception e) {
            throw new RuntimeException("Xác thực Google thất bại", e);
        }
    }
    public boolean verifyOtp(String email, String otp) {
        Optional<User> userOptional = getUserByEmail(email);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            
            // Kiểm tra OTP hợp lệ và chưa hết hạn
            if (user.getOtp() != null && 
                user.getOtp().equals(otp) && 
                user.getOtpExpiry() != null && 
                user.getOtpExpiry().after(new Date())) {
                return true;
            }
        }
        return false;
    }
    
    // Đặt lại mật khẩu (xác thực OTP trước)
    public boolean resetPassword(String email, String newPassword, String otp) {
        // Xác thực OTP trước
        if (!verifyOtp(email, otp)) {
            return false;
        }
        
        Optional<User> userOptional = getUserByEmail(email);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            user.setPassword(newPassword); // TODO: Nên hash password
            
            // Xóa OTP sau khi sử dụng
            user.setOtp(null);
            user.setOtpExpiry(null);
            
            userRepository.save(user);
            return true;
        }
        return false;
    }
    
    // ===== ADMIN - CHỨC NĂNG QUẢN LÝ =====
    
    // Cập nhật thông tin người dùng (dành cho admin)
    public User updateUser(String id, User userData) {
        Optional<User> existing = userRepository.findById(id);
        if (existing.isPresent()) {
            User user = existing.get();
            if (userData.getTen() != null) user.setTen(userData.getTen());
            if (userData.getEmail() != null) user.setEmail(userData.getEmail());
            if (userData.getSoDienThoai() != null) user.setSoDienThoai(userData.getSoDienThoai());
            if (userData.getTrangThaiHoatDong() != null) user.setTrangThaiHoatDong(userData.getTrangThaiHoatDong());
            if (userData.getRule() != null) user.setRule(userData.getRule());
            if (userData.getVaiTro() != null) user.setVaiTro(userData.getVaiTro());
            return userRepository.save(user);
        }
        throw new RuntimeException("User not found");
    }
    
    // Xóa người dùng (dành cho admin)
    public void deleteUser(String id) {
        if (userRepository.existsById(id)) {
            userRepository.deleteById(id);
        } else {
            throw new RuntimeException("User not found");
        }
    }
}

