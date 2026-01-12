package org.example.food_app_be.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "chat_rooms")
public class ChatRoom {
    @Id
    private String id;
    private String customerId;
    private String customerName;
    private String staffId; // ID của nhân viên support
    private String staffName;
    private LocalDateTime createdAt;
    private LocalDateTime closedAt;
    private LocalDateTime lastMessageTime;
    private String lastMessage;
    private boolean isActive;
    private boolean hasStaffAssigned;
    private int unreadCount; // Số tin nhắn chưa đọc

    // Constructor
    public ChatRoom() {
    }

    public ChatRoom(String customerId, String customerName) {
        this.customerId = customerId;
        this.customerName = customerName;
        this.createdAt = LocalDateTime.now();
        this.lastMessageTime = LocalDateTime.now();
        this.isActive = true;
        this.hasStaffAssigned = false;
        this.unreadCount = 0;
    }

    // Getters and Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getStaffId() {
        return staffId;
    }

    public void setStaffId(String staffId) {
        this.staffId = staffId;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getClosedAt() {
        return closedAt;
    }

    public void setClosedAt(LocalDateTime closedAt) {
        this.closedAt = closedAt;
    }

    public LocalDateTime getLastMessageTime() {
        return lastMessageTime;
    }

    public void setLastMessageTime(LocalDateTime lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public boolean isHasStaffAssigned() {
        return hasStaffAssigned;
    }

    public void setHasStaffAssigned(boolean hasStaffAssigned) {
        this.hasStaffAssigned = hasStaffAssigned;
    }

    public int getUnreadCount() {
        return unreadCount;
    }

    public void setUnreadCount(int unreadCount) {
        this.unreadCount = unreadCount;
    }
}
