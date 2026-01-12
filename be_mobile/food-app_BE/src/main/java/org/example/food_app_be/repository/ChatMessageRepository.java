package org.example.food_app_be.repository;

import org.example.food_app_be.model.ChatMessage;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends MongoRepository<ChatMessage, String> {
    List<ChatMessage> findByChatRoomId(String chatRoomId);
    List<ChatMessage> findByChatRoomIdOrderByTimestampAsc(String chatRoomId);
    long countByChatRoomId(String chatRoomId);
}
