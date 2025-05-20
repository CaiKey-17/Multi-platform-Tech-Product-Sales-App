package com.example.api.repository;

import com.example.api.model.Product_variant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ProductVariantRepository extends JpaRepository<Product_variant, Integer> {
    List<Product_variant> findByFkVariantProduct(Integer fkVariantProduct);
    @Query("SELECT p.quantity FROM Product_variant p WHERE p.id = :id")
    Integer getQuantityById(Integer id);

}
