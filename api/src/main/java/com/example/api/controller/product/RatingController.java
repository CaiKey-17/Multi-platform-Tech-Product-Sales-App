package com.example.api.controller.product;


import com.example.api.model.Brand;
import com.example.api.model.Rating;
import com.example.api.service.BrandService;
import com.example.api.service.RatingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/rating")
public class RatingController {

    @Autowired
    private RatingService ratingService;
    @Autowired

    private SimpMessagingTemplate messagingTemplate;

    public RatingController(RatingService ratingService) {
        this.ratingService = ratingService;
    }

    @GetMapping("/product")
    public ResponseEntity<List<Rating>> getRatingsByProductId(@RequestParam Integer productId) {
        List<Rating> ratings = ratingService.getRatingsByProductId(productId);
        if (ratings.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(ratings);
    }
//    @PostMapping("/product/{productId}")
//    public ResponseEntity<Rating> createRating(
//            @PathVariable Integer productId,
//            @RequestBody Rating rating
//    ) {
//        rating.setId_fk_product(productId);
//        Rating savedRating = ratingService.saveRating(rating);
//        return ResponseEntity.ok(savedRating);
//    }

    @PostMapping("/product/{productId}")
    public ResponseEntity<Rating> createRating(
            @PathVariable Integer productId,
            @RequestBody Rating rating
    ) {
        rating.setId_fk_product(productId);
        Rating savedRating = ratingService.saveRating(rating);

        messagingTemplate.convertAndSend("/topic/ratings/" + productId, savedRating);

        return ResponseEntity.ok(savedRating);
    }


}
