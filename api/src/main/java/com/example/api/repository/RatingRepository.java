package com.example.api.repository;

import com.example.api.model.Address;
import com.example.api.model.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Integer> {
    @Query("SELECT r FROM Rating r WHERE r.id_fk_product = :id_fk_product")
    List<Rating> findByProductId(@Param("id_fk_product") Integer id_fk_product);
}
