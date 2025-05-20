package com.example.api.luan.service;

import com.example.api.model.Product_variant;
import com.example.api.repository.ProductVariantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductVariantAdminService {

    @Autowired
    private ProductVariantRepository productVariantRepository;

    public List<Product_variant> getByFkVariantProduct(Integer fkVariantProduct) {
        return productVariantRepository.findByFkVariantProduct(fkVariantProduct);
    }

    public Optional<Product_variant> getProductVariantById(Integer id) {
        return productVariantRepository.findById(id);
    }

    public Product_variant saveProductVariant(Product_variant productVariant) {
        if (productVariant.getId() != null && productVariant.getId() == 0) {
            productVariant.setId(null);
        }
        return productVariantRepository.save(productVariant);
    }

    public void deleteProductVariant(Integer id) {
        productVariantRepository.deleteById(id);
    }

}
