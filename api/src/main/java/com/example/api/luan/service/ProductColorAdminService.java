package com.example.api.luan.service;

import com.example.api.model.Product_color;
import com.example.api.model.Product_variant;
import com.example.api.repository.ProductColorRepository;
import com.example.api.repository.ProductVariantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductColorAdminService {

    @Autowired
    private ProductColorRepository productColorRepository;

    public List<Product_color> getByFkVariantProduct(Integer fkVariantProduct) {
        return productColorRepository.findByFkVariantProduct(fkVariantProduct);
    }

    public Optional<Product_color> getProductColorById(Integer id) {
        return productColorRepository.findById(id);
    }

    public Product_color saveProductColor(Product_color color) {
        if (color.getId() != null && color.getId() == 0) {
            color.setId(null);
        }
        return productColorRepository.save(color);
    }

    public void deleteProductColor(Integer id) {
        productColorRepository.deleteById(id);
    }
}
