package org.example.food_app_be.controller;

import org.example.food_app_be.model.Order;
import org.example.food_app_be.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    // Lấy tất cả đơn hàng
    @GetMapping
    public List<Order> getAll() {
        return orderService.getAll();
    }

    // Lấy đơn hàng của user - PHẢI ĐẶT TRƯỚC /{id}
    @GetMapping("/user/{userId}")
    public List<Order> getByUser(@PathVariable String userId) {
        return orderService.getByUser(userId);
    }

    // Lấy đơn hàng theo ID
    @GetMapping("/{id}")
    public ResponseEntity<Order> getById(@PathVariable String id) {
        return orderService.getById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // Tạo đơn hàng mới
    @PostMapping
    public ResponseEntity<String> create(@RequestBody Order order) {
        Order saved = orderService.create(order);
        return ResponseEntity.ok(saved.getId());
    }

    // Hủy đơn hàng
    @PutMapping("/{id}/cancel")
    public ResponseEntity<Order> cancel(@PathVariable String id) {
        return orderService.cancelOrder(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    // ===== ADMIN ENDPOINTS =====
    
    // Cập nhật trạng thái đơn hàng (dành cho admin)
    // Ví dụ: PUT/PATCH /api/orders/admin/6935003/status?status=dangGiao
    @RequestMapping(value = "/admin/{id}/status", method = {RequestMethod.PUT, RequestMethod.PATCH})
    public ResponseEntity<Order> updateOrderStatus(
            @PathVariable String id,
            @RequestParam String status) {
        try {
            Order.TrangThaiDonHang trangThai = Order.TrangThaiDonHang.valueOf(status);
            Order updated = orderService.updateOrderStatus(id, trangThai);
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(null);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Fallback cho client cũ gọi nhầm không có /admin
    // Ví dụ: PATCH /api/orders/6935003/status?status=daHuy
    @RequestMapping(value = "/{id}/status", method = {RequestMethod.PUT, RequestMethod.PATCH})
    public ResponseEntity<Order> updateOrderStatusFallback(
            @PathVariable String id,
            @RequestParam String status) {
        return updateOrderStatus(id, status);
    }
    
    // Cập nhật thông tin đơn hàng (dành cho admin)
    // PUT /api/orders/admin/6935003
    @PutMapping("/admin/{id}")
    public ResponseEntity<Order> updateOrder(
            @PathVariable String id,
            @RequestBody Order order) {
        try {
            Order updated = orderService.updateOrder(id, order);
            return ResponseEntity.ok(updated);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }
}
