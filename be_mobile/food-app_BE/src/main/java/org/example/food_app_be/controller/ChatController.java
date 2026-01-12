package org.example.food_app_be.controller;

import org.example.food_app_be.model.ChatMessage;
import org.example.food_app_be.model.ChatRoom;
import org.example.food_app_be.repository.ChatMessageRepository;
import org.example.food_app_be.repository.ChatRoomRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/chat")
public class ChatController {
    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;

    public ChatController(ChatRoomRepository chatRoomRepository, ChatMessageRepository chatMessageRepository) {
        this.chatRoomRepository = chatRoomRepository;
        this.chatMessageRepository = chatMessageRepository;
    }

    // ===== CUSTOMER ENDPOINTS =====

    // Tạo hoặc lấy phòng chat cho khách hàng
    @PostMapping("/rooms/create")
    public ResponseEntity<ChatRoom> createOrGetChatRoom(@RequestBody Map<String, String> request) {
        String customerId = request.get("customerId");
        String customerName = request.get("customerName");

        Optional<ChatRoom> existingRoom = chatRoomRepository.findByCustomerIdAndIsActiveTrue(customerId);
        if (existingRoom.isPresent()) {
            return ResponseEntity.ok(existingRoom.get());
        }

        ChatRoom newRoom = new ChatRoom(customerId, customerName);
        ChatRoom saved = chatRoomRepository.save(newRoom);
        return ResponseEntity.ok(saved);
    }

    // Lấy phòng chat của khách hàng
    @GetMapping("/rooms/customer/{customerId}")
    public ResponseEntity<ChatRoom> getCustomerChatRoom(@PathVariable String customerId) {
        Optional<ChatRoom> room = chatRoomRepository.findByCustomerIdAndIsActiveTrue(customerId);
        return room.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Lấy thông tin phòng chat bằng roomId
    @GetMapping("/rooms/{roomId}")
    public ResponseEntity<ChatRoom> getChatRoom(@PathVariable String roomId) {
        Optional<ChatRoom> room = chatRoomRepository.findById(roomId);
        return room.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Gửi tin nhắn (old endpoint - deprecated)
    @PostMapping("/messages/send")
    public ResponseEntity<ChatMessage> sendMessage(@RequestBody Map<String, String> request) {
        String chatRoomId = request.get("chatRoomId");
        String senderId = request.get("senderId");
        String senderName = request.get("senderName");
        String message = request.get("message");

        ChatMessage newMessage = new ChatMessage(chatRoomId, senderId, senderName, message);
        ChatMessage saved = chatMessageRepository.save(newMessage);

        // Cập nhật thông tin phòng chat
        Optional<ChatRoom> room = chatRoomRepository.findById(chatRoomId);
        if (room.isPresent()) {
            ChatRoom chatRoom = room.get();
            chatRoom.setLastMessage(message);
            chatRoom.setLastMessageTime(newMessage.getTimestamp());
            
            // Cập nhật unreadCount (chỉ nếu user gửi, admin gửi thì unread = 0)
            if (chatRoom.getStaffId() == null || chatRoom.getStaffId().isEmpty()) {
                // Room chưa assign → tin nhắn từ user → cộng unreadCount
                long totalMessages = chatMessageRepository.countByChatRoomId(chatRoomId);
                chatRoom.setUnreadCount((int) totalMessages);
            } else {
                // Room đã assign → tin nhắn từ admin → set unreadCount = 0
                chatRoom.setUnreadCount(0);
            }
            
            chatRoomRepository.save(chatRoom);
        }

        return ResponseEntity.ok(saved);
    }

    // Gửi tin nhắn - New endpoint matching Flutter API
    @PostMapping("/rooms/{roomId}/messages")
    public ResponseEntity<ChatMessage> sendMessageToRoom(
            @PathVariable String roomId,
            @RequestBody Map<String, Object> request) {
        try {
            String message = (String) request.getOrDefault("message", "");
            String imageUrl = (String) request.getOrDefault("imageUrl", null);
            String senderId = (String) request.getOrDefault("senderId", null);
            
            System.out.println("📩 Tin nhắn mới - senderId: " + senderId);
            
            if (message.isEmpty()) {
                return ResponseEntity.badRequest().build();
            }

            // Lấy phòng chat
            Optional<ChatRoom> roomOpt = chatRoomRepository.findById(roomId);
            if (roomOpt.isEmpty()) {
                return ResponseEntity.notFound().build();
            }

            ChatRoom chatRoom = roomOpt.get();
            
            System.out.println("🔑 Room staffId: " + chatRoom.getStaffId());
            System.out.println("💬 Sender ID: " + senderId);
            
            // Xác định ai đang gửi: so sánh senderId với staffId
            // Nếu room đã assign (staffId != null) và senderId = staffId → admin
            // Nếu room chưa assign hoặc senderId != staffId → user
            boolean isFromAdmin = (chatRoom.getStaffId() != null && 
                                   senderId != null && 
                                   senderId.equals(chatRoom.getStaffId()));
            
            System.out.println("👤 isFromAdmin: " + isFromAdmin);
            
            // Tạo tin nhắn mới
            ChatMessage newMessage = new ChatMessage(
                roomId,
                chatRoom.getCustomerId(),
                chatRoom.getCustomerName(),
                message
            );
            
            ChatMessage saved = chatMessageRepository.save(newMessage);

            // Cập nhật last message của phòng chat
            chatRoom.setLastMessage(message);
            chatRoom.setLastMessageTime(newMessage.getTimestamp());
            
            // Cập nhật unreadCount DỰA VÀO AI ĐANG GỬI
            if (isFromAdmin) {
                // Admin gửi → admin đã đọc → unreadCount = 0
                System.out.println("✅ Admin gửi → unreadCount = 0");
                chatRoom.setUnreadCount(0);
            } else {
                // User gửi → admin chưa đọc → cộng unreadCount
                System.out.println("📈 User gửi → unreadCount++");
                int currentUnread = chatRoom.getUnreadCount();
                chatRoom.setUnreadCount(currentUnread + 1);
            }
            
            chatRoomRepository.save(chatRoom);

            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            System.err.println("❌ Lỗi gửi tin nhắn: " + e.getMessage());
            return ResponseEntity.status(500).build();
        }
    }

    // Lấy tin nhắn của phòng chat
    @GetMapping("/messages/{chatRoomId}")
    public ResponseEntity<List<ChatMessage>> getMessages(@PathVariable String chatRoomId) {
        List<ChatMessage> messages = chatMessageRepository.findByChatRoomIdOrderByTimestampAsc(chatRoomId);
        return ResponseEntity.ok(messages);
    }

    // Đóng phòng chat
    @PostMapping("/rooms/{roomId}/close")
    public ResponseEntity<ChatRoom> closeRoom(@PathVariable String roomId) {
        Optional<ChatRoom> room = chatRoomRepository.findById(roomId);
        if (room.isPresent()) {
            ChatRoom chatRoom = room.get();
            chatRoom.setActive(false);
            ChatRoom updated = chatRoomRepository.save(chatRoom);
            return ResponseEntity.ok(updated);
        }
        return ResponseEntity.notFound().build();
    }

    // ===== STAFF ENDPOINTS =====

    // Lấy danh sách phòng chat chưa có nhân viên
    @GetMapping("/rooms/staff/unassigned")
    public ResponseEntity<List<ChatRoom>> getUnassignedRooms() {
        List<ChatRoom> rooms = chatRoomRepository.findByIsActiveTrueAndHasStaffAssignedFalseOrderByCreatedAtAsc();
        return ResponseEntity.ok(rooms);
    }

    // Nhân viên nhận phòng chat
    @PostMapping("/rooms/{roomId}/assign")
    public ResponseEntity<ChatRoom> assignRoom(@PathVariable String roomId, @RequestBody Map<String, String> request) {
        String staffId = request.get("staffId");
        String staffName = request.get("staffName");

        Optional<ChatRoom> room = chatRoomRepository.findById(roomId);
        if (room.isPresent()) {
            ChatRoom chatRoom = room.get();
            chatRoom.setStaffId(staffId);
            chatRoom.setStaffName(staffName);
            chatRoom.setHasStaffAssigned(true);
            ChatRoom updated = chatRoomRepository.save(chatRoom);
            return ResponseEntity.ok(updated);
        }
        return ResponseEntity.notFound().build();
    }

    // Đánh dấu room chat đã đọc (reset unreadCount)
    @PatchMapping("/rooms/{roomId}/mark-read")
    public ResponseEntity<ChatRoom> markRoomAsRead(@PathVariable String roomId) {
        Optional<ChatRoom> room = chatRoomRepository.findById(roomId);
        if (room.isPresent()) {
            ChatRoom chatRoom = room.get();
            chatRoom.setUnreadCount(0);
            ChatRoom updated = chatRoomRepository.save(chatRoom);
            return ResponseEntity.ok(updated);
        }
        return ResponseEntity.notFound().build();
    }

    // Lấy danh sách phòng chat assigned cho nhân viên cụ thể
    @GetMapping("/rooms/staff/{staffId}")
    public ResponseEntity<List<ChatRoom>> getStaffRooms(@PathVariable String staffId) {
        // Chỉ lấy rooms ASSIGNED cho staffId này
        List<ChatRoom> assignedRooms = chatRoomRepository.findByIsActiveTrueAndStaffIdOrderByLastMessageTimeDesc(staffId);
        
        // Trả về rooms với unreadCount từ DB (không ghi đè)
        return ResponseEntity.ok(assignedRooms);
    }
}
