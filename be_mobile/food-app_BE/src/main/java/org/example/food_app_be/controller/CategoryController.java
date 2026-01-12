package org.example.food_app_be.controller;

import org.example.food_app_be.model.Category;
import org.example.food_app_be.service.CategoryService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    private CategoryService categoryService;
    
    public CategoryController(CategoryService categoryService){
        this.categoryService=categoryService;
    }

    // Lấy tất cả danh mục sản phẩm
    @GetMapping
    public List<Category> getAllCategories(){
        return categoryService.getAllCategories();
    }
    
    // Lấy danh mục theo ID
    @GetMapping("/{id}")
    public ResponseEntity<Category> getCategoryById(@PathVariable String id) {
        return categoryService.getCategoryById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    // ===== ADMIN ENDPOINTS =====
    
    // Tạo danh mục mới (dành cho admin)
    @PostMapping("/admin/create")
    public ResponseEntity<Category> createCategory(@RequestBody Category category) {
        try {
            Category created = categoryService.createCategory(category);
            return ResponseEntity.ok(created);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Cập nhật danh mục (dành cho admin)
    @PutMapping("/admin/{id}")
    public ResponseEntity<Category> updateCategory(
            @PathVariable String id,
            @RequestBody Category category) {
        try {
            Category updated = categoryService.updateCategory(id, category);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Xóa danh mục (dành cho admin)
    @DeleteMapping("/admin/{id}")
    public ResponseEntity<String> deleteCategory(@PathVariable String id) {
        try {
            categoryService.deleteCategory(id);
            return ResponseEntity.ok("Category deleted successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}

