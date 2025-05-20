package com.example.api.luan.controller;

import com.example.api.luan.service.BrandAdminService;
import com.example.api.model.Brand;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/brand")
public class BrandAdminController {

    @Autowired
    private BrandAdminService brandService;

    private static final Logger logger = LoggerFactory.getLogger(BrandAdminController.class);

    public BrandAdminController(BrandAdminService brandService) {
        this.brandService = brandService;
    }

    @GetMapping("/list")
    public ResponseEntity<List<?>> getAllBrands() {
        List<Brand> brands = brandService.getAll();
        return ResponseEntity.ok(brands);
    }

    @PostMapping("/add")
    public ResponseEntity<?> createBrand(@RequestParam String name,
                                             @RequestParam String image) {
        Brand brand = brandService.createBrand(name, image);
        return ResponseEntity.ok(brand);
    }

    @PostMapping("/{name}")
    public ResponseEntity<?> updateBrand(@PathVariable String name,
                                         @RequestParam String image) {
        logger.info("Nhận được yêu cầu cập nhật thương hiệu: name = {}, image = {}", name, image);
        try {
            Brand brand = brandService.updateBrand(name, image);
            logger.info("Cập nhật thành công, brand trả về: {}", brand);
            return ResponseEntity.ok(brand);
        } catch (Exception e) {
            logger.error("Lỗi khi cập nhật thương hiệu: {}", e.getMessage(), e);
            return ResponseEntity.status(500).body("Lỗi: " + e.getMessage());
        }
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<Void> deleteBrand(@PathVariable String name) {
        brandService.deleteBrand(name);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/names")
    public List<String> getAllBrandNames() {
        return brandService.getAllBrandNames();
    }
}
