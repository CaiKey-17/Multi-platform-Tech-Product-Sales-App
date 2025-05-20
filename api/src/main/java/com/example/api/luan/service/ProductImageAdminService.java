package com.example.api.luan.service;

import com.example.api.luan.repository.ProductImageAdminRepository;
import com.example.api.model.Product_image;
import com.example.api.model.Product_variant;
import com.example.api.repository.ProductImageRepository;
import com.example.api.repository.ProductVariantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductImageAdminService {

    @Autowired
    private ProductImageAdminRepository productImageRepository;

    public List<Product_image> getImagesByProduct(Integer fkImageProduct) {
        return productImageRepository.findByFkImageProduct(fkImageProduct);
    }

    public Optional<Product_image> getProductImageById(Integer id) {
        return productImageRepository.findById(id);
    }

    public Product_image saveProductImage(Product_image image) {
        return productImageRepository.save(image);
    }

    public void deleteProductImage(Integer id) {
        productImageRepository.deleteById(id);
    }

    public void deleteImagesByFkImageProduct(Integer fkImageProduct) {
        productImageRepository.deleteByFkImageProduct(fkImageProduct);
    }

}
