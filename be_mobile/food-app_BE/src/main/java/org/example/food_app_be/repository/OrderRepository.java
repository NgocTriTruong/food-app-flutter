package org.example.food_app_be.repository;

import org.example.food_app_be.model.Order;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends MongoRepository<Order, String> {
    Optional<Order> findById(String id);
    List<Order> findByNguoiDungIdOrderByThoiGianDatDesc(String nguoiDungId);
}
