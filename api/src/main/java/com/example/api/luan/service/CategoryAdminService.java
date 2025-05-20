package com.example.api.luan.service;

import com.example.api.luan.repository.BrandAdminRepository;
import com.example.api.luan.repository.CategoryAdminRepository;
import com.example.api.model.Brand;
import com.example.api.model.Category;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CategoryAdminService {

    @Autowired
    private CategoryAdminRepository categoryRepository;

    public CategoryAdminService(CategoryAdminRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    public List<Category> getAll(){
        return categoryRepository.findAll();
    }

    public Category createCategory(String name, String image) {
        Category category = new Category();
        category.setName(name);
        category.setImages(image);
        return categoryRepository.save(category);
    }

    public Category updateCategory(String name, String image) {
        Optional<Category> optionalCategory = categoryRepository.findById(name);
        if (optionalCategory.isPresent()) {
            Category category = optionalCategory.get();
            category.setImages(image);
            return categoryRepository.save(category);
        }
        throw new RuntimeException("Brand not found");
    }

    public void deleteCategory(String name) {
        categoryRepository.deleteById(name);
    }

    public List<String> getAllCategoryNames() {
        return categoryRepository.findAllCategoryNames();
    }
}
