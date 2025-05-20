package com.example.api.luan.repository;

import com.example.api.model.Brand;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface BrandAdminRepository extends JpaRepository<Brand, String> {
    @Query("SELECT b.name FROM Brand b")
    List<String> findAllBrandNames();
}
