package com.example.api.luan.service;

import com.example.api.model.Brand;
import com.example.api.luan.repository.BrandAdminRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BrandAdminService {

    @Autowired
    private BrandAdminRepository brandRepository;

    public BrandAdminService(BrandAdminRepository brandRepository) {
        this.brandRepository = brandRepository;
    }

    public List<Brand> getAll(){
        return brandRepository.findAll();
    }

    public Brand createBrand(String name, String image) {
        Brand brand = new Brand();
        brand.setName(name);
        brand.setImages(image);
        return brandRepository.save(brand);
    }

    public Brand updateBrand(String name, String image) {
        Optional<Brand> optionalBrand = brandRepository.findById(name);
        if (optionalBrand.isPresent()) {
            Brand brand = optionalBrand.get();
            brand.setImages(image);
            return brandRepository.save(brand);
        }
        throw new RuntimeException("Brand not found");
    }

    public void deleteBrand(String name) {
        brandRepository.deleteById(name);
    }

    public List<String> getAllBrandNames() {
        return brandRepository.findAllBrandNames();
    }
}
