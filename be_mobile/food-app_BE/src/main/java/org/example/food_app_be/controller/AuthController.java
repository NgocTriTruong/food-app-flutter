package org.example.food_app_be.controller;


import org.example.food_app_be.dto.GoogleLoginRequest;
import org.example.food_app_be.dto.LoginRequest;
import org.example.food_app_be.dto.LoginResponse;
import org.example.food_app_be.dto.RegisterRequest;
import org.example.food_app_be.model.User;
import org.example.food_app_be.service.UserService;
import org.example.food_app_be.util.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.security.auth.login.LoginContext;
import java.util.Map;
import java.util.Optional;

@Controller
@RequestMapping("/api/auth")
public class AuthController {
    private UserService userService;
    private JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();
    
    AuthController(UserService userService, JwtUtil jwtUtil){
        this.userService=userService;
        this.jwtUtil=jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest){
        Optional<User> userOptional = userService.getUserByEmail(loginRequest.email);

        if(userOptional.isPresent()){
            User user = userOptional.get();

            // So sánh password được mã hóa BCrypt
            if(passwordEncoder.matches(loginRequest.password, user.getPassword())){
                // Tạo JWT token thật
                String token = jwtUtil.generateToken(user.getId(), user.getEmail());

                return ResponseEntity.ok(new LoginResponse(token, user));
            }
        }
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Sai email hoặc mật khẩu");
    }
    @PostMapping("/google")
    public ResponseEntity<?> loginWithGoogle(
            @RequestBody GoogleLoginRequest request) {
        System.out.println(1);
        User user = userService.loginWithGoogle(request.getIdToken());
        String token = jwtUtil.generateToken(user.getId(), user.getEmail());

        return ResponseEntity.ok(
                Map.of(
                        "token", token,
                        "user", user
                )
        );
    }
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest registerRequest) {
        try {
            User newUser = userService.registerUser(
                registerRequest.ten,
                registerRequest.email,
                registerRequest.password,
                registerRequest.soDienThoai
            );
            
            // Tạo JWT token thật
            String token = jwtUtil.generateToken(newUser.getId(), newUser.getEmail());
            
            return ResponseEntity.status(HttpStatus.CREATED)
                .body(new LoginResponse(token, newUser));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(e.getMessage());
        }
    }
    
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody java.util.Map<String, String> request) {
        String email = request.get("email");
        
        if (email == null || email.trim().isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Email không được để trống");
        }
        
        try {
            // Tạo và gửi OTP qua email
            String otp = userService.generateAndSaveOtp(email.trim());
            
            if (otp != null) {
                return ResponseEntity.ok()
                    .body(java.util.Map.of(
                        "message", "Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra hộp thư."
                    ));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Không tìm thấy tài khoản với email này.");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Lỗi khi gửi email: " + e.getMessage());
        }
    }
    
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody java.util.Map<String, String> request) {
        String email = request.get("email");
        String newPassword = request.get("newPassword");
        String otp = request.get("otp");
        
        if (email == null || email.trim().isEmpty() || newPassword == null || newPassword.isEmpty() || otp == null || otp.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Email, mật khẩu mới và mã OTP không được để trống");
        }
        
        boolean success = userService.resetPassword(email.trim(), newPassword, otp);
        
        if (success) {
            return ResponseEntity.ok()
                .body(java.util.Map.of("message", "Đặt lại mật khẩu thành công"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body("Mã OTP không hợp lệ hoặc đã hết hạn.");
        }
    }
    
    @GetMapping("/user/{id}")
    public ResponseEntity<?> getUserById(@PathVariable String id) {
        Optional<User> userOptional = userService.getUserById(id);
        
        if (userOptional.isPresent()) {
            return ResponseEntity.ok(userOptional.get());
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body("Không tìm thấy người dùng");
        }
    }
}
