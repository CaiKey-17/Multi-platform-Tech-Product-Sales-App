package com.example.api.luan.repository;

import com.example.api.model.Product_color;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductColorAdminRepository extends JpaRepository<Product_color, Integer> {
    @Query("SELECT pc FROM Product_color pc WHERE pc.fkVariantProduct = :fkVariantProduct")
    List<Product_color> findByFkVariantProduct(@Param("fkVariantProduct") Integer fkVariantProduct);
}
