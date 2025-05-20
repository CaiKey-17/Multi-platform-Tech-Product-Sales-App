package com.example.api.service;

import com.example.api.repository.ProductColorRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ProductColorService {

    @Autowired
    private ProductColorRepository productColorRepository;

    public Integer getQuantityById(Integer id) {
        return productColorRepository.getQuantityById(id);
    }
}
