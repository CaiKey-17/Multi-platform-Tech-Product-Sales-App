package com.example.api.repository;

import com.example.api.model.Product_color;
import com.example.api.model.Product_variant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProductColorRepository extends JpaRepository<Product_color, Integer> {
    List<Product_color> findByFkVariantProduct(Integer fkVariantProduct);

    @Query("SELECT p.quantity FROM Product_color p WHERE p.id = :id")
    Integer getQuantityById(Integer id);

}
