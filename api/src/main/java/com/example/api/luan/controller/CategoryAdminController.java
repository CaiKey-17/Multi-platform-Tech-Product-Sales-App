package com.example.api.luan.controller;

import com.example.api.luan.service.CategoryAdminService;
import com.example.api.model.Brand;
import com.example.api.model.Category;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/category")
public class CategoryAdminController {

    @Autowired
    private CategoryAdminService categoryService;

    private static final Logger logger = LoggerFactory.getLogger(CategoryAdminController.class);

    public CategoryAdminController(CategoryAdminService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping("/list")
    public ResponseEntity<List<?>> getAllCategories() {
        List<Category> categories = categoryService.getAll();
        return ResponseEntity.ok(categories);
    }

    @PostMapping("/add")
    public ResponseEntity<?> createCategory(@RequestParam String name,
                                             @RequestParam String image) {
        Category category = categoryService.createCategory(name, image);
        return ResponseEntity.ok(category);
    }

    @PostMapping("/{name}")
    public ResponseEntity<?> updateCategory(@PathVariable String name,
                                         @RequestParam String image) {
        logger.info("Nhận được yêu cầu cập nhật loại sản phẩm: name = {}, image = {}", name, image);
        try {
            Category category = categoryService.updateCategory(name, image);
            logger.info("Cập nhật thành công, loại sản phẩm trả về: {}", category);
            return ResponseEntity.ok(category);
        } catch (Exception e) {
            logger.error("Lỗi khi cập nhật loại sản phẩm: {}", e.getMessage(), e);
            return ResponseEntity.status(500).body("Lỗi: " + e.getMessage());
        }
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<Void> deleteCategory(@PathVariable String name) {
        categoryService.deleteCategory(name);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/names")
    public List<String> getAllCategoryNames() {
        return categoryService.getAllCategoryNames();
    }
}
