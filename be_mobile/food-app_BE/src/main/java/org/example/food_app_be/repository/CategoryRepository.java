package org.example.food_app_be.repository;

import org.example.food_app_be.model.Category;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface CategoryRepository extends MongoRepository<Category,String> {

}
