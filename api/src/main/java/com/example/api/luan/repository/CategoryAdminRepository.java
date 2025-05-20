package com.example.api.luan.repository;

import com.example.api.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CategoryAdminRepository extends JpaRepository<Category, String> {
    @Query("SELECT b.name FROM Category b")
    List<String> findAllCategoryNames();
}
