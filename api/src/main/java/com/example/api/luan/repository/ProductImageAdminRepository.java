package com.example.api.luan.repository;

import com.example.api.model.Brand;
import com.example.api.model.Product_image;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductImageAdminRepository extends JpaRepository<Product_image, Integer> {
    @Query("SELECT pi FROM Product_image pi WHERE pi.fkImageProduct = :fkImageProduct")
    List<Product_image> findByFkImageProduct(@Param("fkImageProduct") Integer fkImageProduct);

    @Modifying
    @Query("DELETE FROM Product_image pi WHERE pi.fkImageProduct = :fkImageProduct")
    void deleteByFkImageProduct(@Param("fkImageProduct") Integer fkImageProduct);
}
