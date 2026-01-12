package org.example.food_app_be.controller;

import org.example.food_app_be.model.Product;
import org.example.food_app_be.repository.ProductRepository;
import org.example.food_app_be.service.ProductService;
import org.springframework.data.mongodb.repository.Query;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService productService;
    
    public ProductController(ProductService productService){
        this.productService = productService;
    }

    // Lấy tất cả sản phẩm
    @GetMapping
    public List<Product> getAll(){
        return this.productService.getAll();
    }

    // Tìm kiếm sản phẩm - TRƯỚC /{id}
    @GetMapping("/search")
    public List<Product> searchProducts(@RequestParam("query") String query){
        return this.productService.searchProducts(query);
    }
    
    // Lấy sản phẩm đang khuyến mãi - TRƯỚC /{id}
    @GetMapping("/promotions")
    public List<Product> getPromotionalProducts() {
        return productService.getPromotionalProducts();
    }
    
    // Lấy sản phẩm theo danh mục - TRƯỚC /{id}
    @GetMapping("/category/{categoryId}")
    public List<Product> getProductsByCategoryId(@PathVariable String categoryId) {
        return productService.findByDanhMucId(categoryId);
    }

    // Lấy sản phẩm theo ID - SAU các static paths
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable String id){
        try {
            Product product = productService.getProductById(id);
            return ResponseEntity.ok(product);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // ===== ADMIN ENDPOINTS =====
    
    // Tạo sản phẩm mới (dành cho admin)
    @PostMapping("/admin/create")
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        try {
            Product created = productService.createProduct(product);
            return ResponseEntity.ok(created);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    // Cập nhật sản phẩm (dành cho admin)
    @PutMapping("/admin/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable String id, @RequestBody Product product) {
        try {
            Product updated = productService.updateProduct(id, product);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    // Xóa sản phẩm (dành cho admin)
    @DeleteMapping("/admin/{id}")
    public ResponseEntity<String> deleteProduct(@PathVariable String id) {
        try {
            productService.deleteProduct(id);
            return ResponseEntity.ok("Product deleted successfully");
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
