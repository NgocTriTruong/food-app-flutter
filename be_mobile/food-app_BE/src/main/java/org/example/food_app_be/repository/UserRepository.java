package org.example.food_app_be.repository;

import org.example.food_app_be.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface UserRepository extends MongoRepository<User,String> {
    Optional<User> findById(String id);
    Optional<User> findByEmailIgnoreCase(String email);

}
