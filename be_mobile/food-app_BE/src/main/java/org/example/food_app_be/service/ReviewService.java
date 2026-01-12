package org.example.food_app_be.service;

import org.example.food_app_be.dto.ReviewSummary;
import org.example.food_app_be.model.Review;
import org.example.food_app_be.repository.ReviewRepository;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class ReviewService {
    private final ReviewRepository reviewRepository;

    public ReviewService(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    public Review create(Review review) {
        Date now = new Date();
        review.setNgayTao(now);
        review.setUpdatedAt(now);
        return reviewRepository.save(review);
    }

    public List<Review> getByProduct(String productId) {
        return reviewRepository.findBySanPhamIdOrderByNgayTaoDesc(productId);
    }

    public Optional<Review> getUserReview(String productId, String userId) {
        return reviewRepository.findBySanPhamIdAndNguoiDungId(productId, userId);
    }

    public boolean hasUserReview(String productId, String userId) {
        return reviewRepository.countBySanPhamIdAndNguoiDungId(productId, userId) > 0;
    }

    public boolean update(String id, Integer soSao, String binhLuan) {
        Optional<Review> existingOpt = reviewRepository.findById(id);
        if (existingOpt.isEmpty()) {
            return false;
        }
        Review review = existingOpt.get();
        if (soSao != null) {
            review.setSoSao(soSao);
        }
        if (binhLuan != null) {
            review.setBinhLuan(binhLuan);
        }
        review.setUpdatedAt(new Date());
        reviewRepository.save(review);
        return true;
    }

    public boolean delete(String id) {
        if (!reviewRepository.existsById(id)) {
            return false;
        }
        reviewRepository.deleteById(id);
        return true;
    }

    public ReviewSummary getSummary(String productId) {
        List<Review> reviews = getByProduct(productId);
        ReviewSummary summary = new ReviewSummary();
        if (reviews.isEmpty()) {
            summary.setDiemTrungBinh(0);
            summary.setTongSoDanhGia(0);
            summary.setPhanBoSao(defaultDistribution());
            return summary;
        }

        long total = reviews.size();
        int sum = reviews.stream().mapToInt(Review::getSoSao).sum();
        summary.setTongSoDanhGia(total);
        summary.setDiemTrungBinh((double) sum / total);

        Map<Integer, Long> distribution = defaultDistribution();
        reviews.forEach(r -> distribution.put(r.getSoSao(), distribution.getOrDefault(r.getSoSao(), 0L) + 1));
        summary.setPhanBoSao(distribution);
        return summary;
    }

    private Map<Integer, Long> defaultDistribution() {
        Map<Integer, Long> map = new HashMap<>();
        for (int i = 1; i <= 5; i++) {
            map.put(i, 0L);
        }
        return map;
    }
}
