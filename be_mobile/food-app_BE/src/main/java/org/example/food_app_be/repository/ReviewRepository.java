package org.example.food_app_be.repository;

import org.example.food_app_be.model.Review;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface ReviewRepository extends MongoRepository<Review, String> {
    List<Review> findBySanPhamIdOrderByNgayTaoDesc(String sanPhamId);
    Optional<Review> findBySanPhamIdAndNguoiDungId(String sanPhamId, String nguoiDungId);
    long countBySanPhamIdAndNguoiDungId(String sanPhamId, String nguoiDungId);
}
