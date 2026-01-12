package org.example.food_app_be.service;

import org.bson.types.ObjectId;
import org.example.food_app_be.model.Product;
import org.example.food_app_be.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductService {
    private final ProductRepository productRepository;
    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }
    // Lấy tất cả sản phẩm
    public List<Product> getAll(){
        return productRepository.findAll();
    }
    
    // Lưu sản phẩm
    public Product save(Product product){
        return productRepository.save(product);
    }

    // Tìm sản phẩm theo ID
    public Optional<Product> findById(String id){
        return productRepository.findById(id);
    }
    
    // Lấy sản phẩm đang khuyến mãi
    public List<Product> getPromotionalProducts() {
        return productRepository.findByKhuyenMaiTrue();
    }
    
    // Lấy sản phẩm theo ID (ném lỗi nếu không tìm thấy)
    public Product getProductById(String id){
        return productRepository.findById(id).orElseThrow(() -> new RuntimeException("product not found"));
    }

    // Tìm kiếm sản phẩm theo tên
    public List<Product> searchProducts(String query) {
        return productRepository.findByTenContainingIgnoreCase(query);
    }
    
    // Lấy sản phẩm theo danh mục
    public List<Product> findByDanhMucId(String danhMucId) {
        return productRepository.findByDanhMucId(new ObjectId(danhMucId));
    }
    
    // ===== ADMIN - CHỨC NĂNG QUẢN LÝ =====
    
    // Tạo sản phẩm mới (dành cho admin)
    public Product createProduct(Product product) {
        product.setId(null); // Để MongoDB tự sinh ID
        return productRepository.save(product);
    }
    
    // Cập nhật sản phẩm (dành cho admin)
    // Cập nhật sản phẩm (dành cho admin)
    public Product updateProduct(String id, Product productData) {
        Optional<Product> existing = productRepository.findById(id);
        if (existing.isPresent()) {
            Product product = existing.get();
            if (productData.getTen() != null) product.setTen(productData.getTen());
            if (productData.getGia() > 0) product.setGia(productData.getGia());
            if (productData.getHinhAnh() != null) product.setHinhAnh(productData.getHinhAnh());
            if (productData.getMoTa() != null) product.setMoTa(productData.getMoTa());
            if (productData.getDanhMucId() != null) product.setDanhMucId(productData.getDanhMucId());
            product.setKhuyenMai(productData.isKhuyenMai());
            if (productData.getGiamGia() >= 0) product.setGiamGia(productData.getGiamGia());
            return productRepository.save(product);
        }
        throw new RuntimeException("Product not found");
    }
    
    // Xóa sản phẩm (dành cho admin)
    public void deleteProduct(String id) {
        if (productRepository.existsById(id)) {
            productRepository.deleteById(id);
        } else {
            throw new RuntimeException("Product not found");
        }
    }
}
