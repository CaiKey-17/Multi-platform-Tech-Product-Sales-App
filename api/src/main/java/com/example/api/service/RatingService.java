package com.example.api.service;

import com.example.api.model.Address;
import com.example.api.model.Rating;
import com.example.api.repository.AddressRepository;
import com.example.api.repository.RatingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RatingService {


    @Autowired
    private RatingRepository ratingRepository;

    public List<Rating> getRatingsByProductId(Integer productId) {
        return ratingRepository.findByProductId(productId);
    }

    public Rating saveRating(Rating rating) {
        return ratingRepository.save(rating);
    }



}
