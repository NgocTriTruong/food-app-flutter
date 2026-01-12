package org.example.food_app_be.repository;

import org.bson.types.ObjectId;
import org.example.food_app_be.model.Product;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;


public interface ProductRepository extends MongoRepository<Product,String> {
    Optional<Product> findById(String s);
    List<Product> findByKhuyenMaiTrue();

    List<Product> findByTenContainingIgnoreCase(String query);
    List<Product> findByDanhMucId(ObjectId danhMucId);

}
