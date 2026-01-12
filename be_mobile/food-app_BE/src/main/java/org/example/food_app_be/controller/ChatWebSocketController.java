package org.example.food_app_be.controller;

import org.example.food_app_be.model.ChatMessage;
import org.example.food_app_be.repository.ChatMessageRepository;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

import java.time.LocalDateTime;
import java.util.Map;

@Controller
public class ChatWebSocketController {
    private final ChatMessageRepository chatMessageRepository;

    public ChatWebSocketController(ChatMessageRepository chatMessageRepository) {
        this.chatMessageRepository = chatMessageRepository;
    }

    // WebSocket endpoint: /app/chat/{roomId}/send -> broadcast to /topic/chat/{roomId}
    @MessageMapping("/chat/{roomId}/send")
    @SendTo("/topic/chat/{roomId}")
    public ChatMessage handleMessage(@DestinationVariable String roomId, Map<String, String> payload) {
        String senderId = payload.get("senderId");
        String senderName = payload.get("senderName");
        String message = payload.get("message");

        ChatMessage chatMessage = new ChatMessage(roomId, senderId, senderName, message);
        chatMessage.setTimestamp(LocalDateTime.now());

        // Lưu vào database
        return chatMessageRepository.save(chatMessage);
    }
}
