package com.example.api.repository;

import com.example.api.model.Product_image;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<Product_image, Integer> {
    List<Product_image> findByFkImageProduct(Integer fkImageProduct);
}
