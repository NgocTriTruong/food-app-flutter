package org.example.food_app_be.controller;

import org.example.food_app_be.model.User;
import org.example.food_app_be.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService){
        this.userService = userService;
    }

    // Lấy tất cả người dùng
    @GetMapping
    public List<User> getAllUsers(){
        System.out.println(userService.getAllUsers());
        return userService.getAllUsers();
    }
    
    // Lấy người dùng theo ID
    @GetMapping("/{uid}")
    public Optional<User> getUser(@PathVariable String uid){
        return userService.getUserById(uid);
    }
    
    // Endpoint test
    @GetMapping("/test")
    public String test(){
        return "OK";
    }
    
    // ===== ADMIN ENDPOINTS =====
    
    // Cập nhật người dùng (dành cho admin)
    @PutMapping("/admin/{id}")
    public ResponseEntity<User> updateUser(
            @PathVariable String id,
            @RequestBody User user) {
        User updated = userService.updateUser(id, user);
        return ResponseEntity.ok(updated);
    }
    
    // Xóa người dùng (dành cho admin)
    @DeleteMapping("/admin/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return ResponseEntity.ok("User deleted successfully");
    }
}

