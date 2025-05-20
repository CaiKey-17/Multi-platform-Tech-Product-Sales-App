package com.example.api.service;

import com.example.api.repository.ProductColorRepository;
import com.example.api.repository.ProductVariantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProductVariantService {

    @Autowired
    private ProductVariantRepository productVariantRepository;

    public Integer getQuantityById(Integer id) {
        return productVariantRepository.getQuantityById(id);
    }
}
