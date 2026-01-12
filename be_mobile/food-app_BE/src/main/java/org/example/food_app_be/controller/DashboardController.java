package org.example.food_app_be.controller;

import org.example.food_app_be.model.Order;
import org.example.food_app_be.repository.OrderRepository;
import org.example.food_app_be.repository.UserRepository;
import org.example.food_app_be.repository.ChatRoomRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {
    
    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final ChatRoomRepository chatRoomRepository;

    public DashboardController(OrderRepository orderRepository, UserRepository userRepository, ChatRoomRepository chatRoomRepository) {
        this.orderRepository = orderRepository;
        this.userRepository = userRepository;
        this.chatRoomRepository = chatRoomRepository;
    }

    // Lấy thống kê tổng quan
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        try {
            Map<String, Object> stats = new HashMap<>();

            // Tổng doanh thu
            List<Order> allOrders = orderRepository.findAll();
            double totalRevenue = allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.daGiao.equals(o.getTrangThai()))
                    .mapToDouble(Order::getTongTien)
                    .sum();

            // Doanh thu hôm nay
            LocalDate today = LocalDate.now();
            double todayRevenue = allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.daGiao.equals(o.getTrangThai()) &&
                            o.getThoiGianDat() != null &&
                            LocalDateTime.ofInstant(o.getThoiGianDat(), java.time.ZoneId.systemDefault()).toLocalDate().equals(today))
                    .mapToDouble(Order::getTongTien)
                    .sum();

            // Tổng đơn hàng
            int totalOrders = allOrders.size();

            // Đơn hàng hôm nay
            int todayOrders = (int) allOrders.stream()
                    .filter(o -> o.getThoiGianDat() != null && 
                            LocalDateTime.ofInstant(o.getThoiGianDat(), java.time.ZoneId.systemDefault()).toLocalDate().equals(today))
                    .count();

            // Tổng khách hàng
            int totalCustomers = (int) userRepository.findAll().stream()
                    .filter(u -> "user".equals(u.getVaiTro()))
                    .count();

            // Đơn hàng đang chờ
            int pendingOrders = (int) allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.dangXuLy.equals(o.getTrangThai()))
                    .count();

            // Giá trị đơn hàng trung bình
            double averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

            stats.put("totalRevenue", totalRevenue);
            stats.put("todayRevenue", todayRevenue);
            stats.put("totalOrders", totalOrders);
            stats.put("todayOrders", todayOrders);
            stats.put("totalCustomers", totalCustomers);
            stats.put("pendingOrders", pendingOrders);
            stats.put("averageOrderValue", averageOrderValue);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Collections.singletonMap("error", e.getMessage()));
        }
    }

    // Lấy doanh thu theo ngày (7 ngày gần nhất)
    @GetMapping("/daily-revenue")
    public ResponseEntity<List<Map<String, Object>>> getDailyRevenue() {
        try {
            List<Order> allOrders = orderRepository.findAll();
            List<Map<String, Object>> dailyRevenue = new ArrayList<>();

            // Lấy 7 ngày gần nhất
            LocalDate today = LocalDate.now();
            for (int i = 6; i >= 0; i--) {
                LocalDate date = today.minusDays(i);
                double revenue = allOrders.stream()
                        .filter(o -> Order.TrangThaiDonHang.daGiao.equals(o.getTrangThai()) &&
                                o.getThoiGianDat() != null &&
                                LocalDateTime.ofInstant(o.getThoiGianDat(), java.time.ZoneId.systemDefault()).toLocalDate().equals(date))
                        .mapToDouble(Order::getTongTien)
                        .sum();

                Map<String, Object> dayData = new HashMap<>();
                dayData.put("date", date.toString());
                dayData.put("revenue", revenue);
                dailyRevenue.add(dayData);
            }

            return ResponseEntity.ok(dailyRevenue);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Collections.emptyList());
        }
    }

    // Lấy phân bố trạng thái đơn hàng
    @GetMapping("/order-status-distribution")
    public ResponseEntity<Map<String, Integer>> getOrderStatusDistribution() {
        try {
            List<Order> allOrders = orderRepository.findAll();
            
            Map<String, Integer> distribution = new HashMap<>();
            distribution.put("completed", (int) allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.daGiao.equals(o.getTrangThai()))
                    .count());
            distribution.put("processing", (int) allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.dangGiao.equals(o.getTrangThai()))
                    .count());
            distribution.put("pending", (int) allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.dangXuLy.equals(o.getTrangThai()))
                    .count());
            distribution.put("cancelled", (int) allOrders.stream()
                    .filter(o -> Order.TrangThaiDonHang.daHuy.equals(o.getTrangThai()))
                    .count());

            return ResponseEntity.ok(distribution);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(new HashMap<>());
        }
    }

    // Lấy danh sách đơn hàng gần đây
    @GetMapping("/recent-orders")
    public ResponseEntity<List<Order>> getRecentOrders(@RequestParam(defaultValue = "10") int limit) {
        try {
            List<Order> recentOrders = orderRepository.findAll().stream()
                    .sorted((o1, o2) -> {
                        if (o1.getThoiGianDat() == null || o2.getThoiGianDat() == null) return 0;
                        return o2.getThoiGianDat().compareTo(o1.getThoiGianDat());
                    })
                    .limit(limit)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(recentOrders);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Collections.emptyList());
        }
    }

    // Lấy thống kê chat (staff dashboard)
    @GetMapping("/chat-stats")
    public ResponseEntity<Map<String, Integer>> getChatStats() {
        try {
            Map<String, Integer> stats = new HashMap<>();

            // Phòng chat đang chờ (chưa gán staff)
            int pendingChats = (int) chatRoomRepository.findByIsActiveTrueAndHasStaffAssignedFalseOrderByCreatedAtAsc()
                    .size();

            // Phòng chat đang hoạt động (đã gán staff)
            int activeChats = (int) chatRoomRepository.findAll().stream()
                    .filter(r -> r.isActive() && r.isHasStaffAssigned())
                    .count();

            stats.put("pendingChats", pendingChats);
            stats.put("activeChats", activeChats);

            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(new HashMap<>());
        }
    }
}
