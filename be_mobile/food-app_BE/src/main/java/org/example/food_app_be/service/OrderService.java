package org.example.food_app_be.service;

import org.example.food_app_be.model.Order;
import org.example.food_app_be.repository.OrderRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Service
public class OrderService {
    private final OrderRepository orderRepository;

    public OrderService(OrderRepository orderRepository) {
        this.orderRepository = orderRepository;
    }

    // Tạo đơn hàng mới
    public Order create(Order order) {
        if (order.getThoiGianDat() == null) {
            order.setThoiGianDat(Instant.now());
        }
        if (order.getTrangThai() == null) {
            order.setTrangThai(Order.TrangThaiDonHang.dangXuLy);
        }
        order.setId(null);
        return orderRepository.save(order);
    }

    // Lấy đơn hàng theo ID
    public Optional<Order> getById(String id) {
        return orderRepository.findById(id);
    }

    // Lấy đơn hàng của user (sắp xếp giảm dần theo thời gian đặt)
    public List<Order> getByUser(String userId) {
        return orderRepository.findByNguoiDungIdOrderByThoiGianDatDesc(userId);
    }

    // Lấy tất cả đơn hàng
    public List<Order> getAll() {
        return orderRepository.findAll();
    }

    // Hủy đơn hàng (chỉ được hủy nếu đang xử lý)
    public Optional<Order> cancelOrder(String id) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            Order o = order.get();
            if (o.getTrangThai() == Order.TrangThaiDonHang.dangXuLy) {
                o.setTrangThai(Order.TrangThaiDonHang.daHuy);
                return Optional.of(orderRepository.save(o));
            }
        }
        return order;
    }
    
    // ===== ADMIN - CHỨC NĂNG QUẢN LÝ =====
    
    // Cập nhật trạng thái đơn hàng (dành cho admin)
    // Cập nhật trạng thái đơn hàng (dành cho admin)
    public Order updateOrderStatus(String id, Order.TrangThaiDonHang newStatus) {
        Optional<Order> order = orderRepository.findById(id);
        if (order.isPresent()) {
            Order o = order.get();
            o.setTrangThai(newStatus);
            return orderRepository.save(o);
        }
        throw new RuntimeException("Order not found");
    }
    
    // Cập nhật thông tin đơn hàng (dành cho admin)
    public Order updateOrder(String id, Order orderData) {
        Optional<Order> existing = orderRepository.findById(id);
        if (existing.isPresent()) {
            Order order = existing.get();
            if (orderData.getTenNguoiNhan() != null) order.setTenNguoiNhan(orderData.getTenNguoiNhan());
            if (orderData.getSoDienThoai() != null) order.setSoDienThoai(orderData.getSoDienThoai());
            if (orderData.getDiaChi() != null) order.setDiaChi(orderData.getDiaChi());
            if (orderData.getTrangThai() != null) order.setTrangThai(orderData.getTrangThai());
            if (orderData.getGhiChu() != null) order.setGhiChu(orderData.getGhiChu());
            if (orderData.getPhuongThucThanhToan() != null) order.setPhuongThucThanhToan(orderData.getPhuongThucThanhToan());
            return orderRepository.save(order);
        }
        throw new RuntimeException("Order not found");
    }
}
