package com.example.api.luan.repository;

import com.example.api.model.Product_variant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductVariantAdminRepository extends JpaRepository<Product_variant, Integer> {
    @Query("SELECT pv FROM Product_variant pv WHERE pv.fkVariantProduct = :fkVariantProduct")
    List<Product_variant> findByFkVariantProduct(@Param("fkVariantProduct") Integer fkVariantProduct);
}
