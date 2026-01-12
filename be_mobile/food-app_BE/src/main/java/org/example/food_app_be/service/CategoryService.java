package org.example.food_app_be.service;

import org.example.food_app_be.model.Category;
import org.example.food_app_be.repository.CategoryRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CategoryService {
    private final CategoryRepository categoryRepository;
    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }
    // Lấy tất cả danh mục sản phẩm
    public List<Category> getAllCategories(){
        return categoryRepository.findAll();
    }
    
    // Lấy danh mục theo ID
    public Optional<Category> getCategoryById(String id) {
        return categoryRepository.findById(id);
    }
    
    // ===== ADMIN - CHỨC NĂNG QUẢN LÝ =====
    
    // Tạo danh mục mới (dành cho admin)
    public Category createCategory(Category category) {
        category.setId(null); // Để MongoDB tự sinh ID
        return categoryRepository.save(category);
    }
    
    // Cập nhật danh mục (dành cho admin)
    public Category updateCategory(String id, Category categoryData) {
        Optional<Category> existing = categoryRepository.findById(id);
        if (existing.isPresent()) {
            Category category = existing.get();
            if (categoryData.getTen() != null) category.setTen(categoryData.getTen());
            if (categoryData.getHinhAnh() != null) category.setHinhAnh(categoryData.getHinhAnh());
            if (categoryData.getMoTa() != null) category.setMoTa(categoryData.getMoTa());
            return categoryRepository.save(category);
        }
        throw new RuntimeException("Category not found");
    }
    
    // Xóa danh mục (dành cho admin)
    public void deleteCategory(String id) {
        if (categoryRepository.existsById(id)) {
            categoryRepository.deleteById(id);
        } else {
            throw new RuntimeException("Category not found");
        }
    }
}

