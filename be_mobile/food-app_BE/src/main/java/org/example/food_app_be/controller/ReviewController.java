package org.example.food_app_be.controller;

import org.example.food_app_be.dto.ReviewSummary;
import org.example.food_app_be.model.Review;
import org.example.food_app_be.service.ReviewService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @PostMapping
    public ResponseEntity<Boolean> create(@RequestBody Review review) {
        Review saved = reviewService.create(review);
        return ResponseEntity.ok(saved.getId() != null);
    }

    @GetMapping("/product/{productId}")
    public List<Review> getByProduct(@PathVariable String productId) {
        return reviewService.getByProduct(productId);
    }

    @GetMapping("/product/{productId}/stats")
    public ReviewSummary getSummary(@PathVariable String productId) {
        return reviewService.getSummary(productId);
    }

    @GetMapping("/check")
    public boolean hasUserReviewed(@RequestParam String productId, @RequestParam String userId) {
        return reviewService.hasUserReview(productId, userId);
    }

    @GetMapping("/user-product")
    public ResponseEntity<Review> getUserReview(@RequestParam String productId, @RequestParam String userId) {
        Optional<Review> review = reviewService.getUserReview(productId, userId);
        return review.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.ok().build());
    }

    @PatchMapping("/{id}")
    public ResponseEntity<Boolean> update(@PathVariable String id, @RequestBody Map<String, Object> updateData) {
        Integer soSao = null;
        if (updateData.containsKey("soSao")) {
            Object raw = updateData.get("soSao");
            if (raw instanceof Number) {
                soSao = ((Number) raw).intValue();
            }
        }
        String binhLuan = updateData.containsKey("binhLuan") ? (String) updateData.get("binhLuan") : null;
        boolean updated = reviewService.update(id, soSao, binhLuan);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> delete(@PathVariable String id) {
        boolean deleted = reviewService.delete(id);
        return ResponseEntity.ok(deleted);
    }
}
