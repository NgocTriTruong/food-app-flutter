package org.example.food_app_be.repository;

import org.example.food_app_be.model.ChatRoom;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepository extends MongoRepository<ChatRoom, String> {
    Optional<ChatRoom> findByCustomerIdAndIsActiveTrue(String customerId);
    List<ChatRoom> findByIsActiveTrueAndHasStaffAssignedFalseOrderByCreatedAtAsc();
    List<ChatRoom> findByIsActiveTrueAndStaffIdOrderByLastMessageTimeDesc(String staffId);
    List<ChatRoom> findByIsActiveTrueOrderByLastMessageTimeDesc();
}
