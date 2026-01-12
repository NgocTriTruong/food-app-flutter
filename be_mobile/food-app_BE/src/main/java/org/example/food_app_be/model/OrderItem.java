package org.example.food_app_be.model;

import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "order_items")
public class OrderItem {
    private int soLuong;
    private Product sanPham;

    // Needed by Spring/Jackson for request body deserialization
    public OrderItem() {
    }

    public OrderItem(int soLuong, Product sanPham){
        this.soLuong = soLuong;
        this.sanPham = sanPham;
    }
    public int getSoLuong() {
        return soLuong;
    }

    public void setSoLuong(int soLuong) {
        this.soLuong = soLuong;
    }

    public Product getSanPham() {
        return sanPham;
    }

    public void setSanPham(Product sanPham) {
        this.sanPham = sanPham;
    }
}
