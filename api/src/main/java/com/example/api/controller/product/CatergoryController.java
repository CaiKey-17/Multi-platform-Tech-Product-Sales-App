package com.example.api.controller.product;


import com.example.api.model.Address;
import com.example.api.model.Category;
import com.example.api.model.Customer;
import com.example.api.model.Users;
import com.example.api.security.JwtTokenUtil;
import com.example.api.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/category")
public class CatergoryController {

    @Autowired
    private CategoryService categoryService;

    public CatergoryController(CategoryService categoryService) {
        this.categoryService = categoryService;
    }

    @GetMapping("/list")
    public ResponseEntity<List<Category>> getAllCategory() {
        List<Category> categories = categoryService.getAll();
        return ResponseEntity.ok(categories);
    }
}
