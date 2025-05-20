package com.example.api.luan.controller;


import com.example.api.luan.service.ProductAdminService;
import com.example.api.luan.service.ProductColorAdminService;
import com.example.api.luan.service.ProductVariantAdminService;
import com.example.api.luan.service.ProductImageAdminService;
import com.example.api.model.Product;
import com.example.api.model.Product_color;
import com.example.api.model.Product_image;
import com.example.api.model.Product_variant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/products")
public class ProductAdminController {
    @Autowired
    private ProductAdminService productAdminService;

    @Autowired
    private ProductVariantAdminService productVariantAdminService;

    @Autowired
    private ProductColorAdminService productColorAdminService;

    @Autowired
    private ProductImageAdminService productImageAdminService;

    @GetMapping
    public ResponseEntity<List<?>> getAllProducts() {
        List<Product> products = productAdminService.getAllProducts();
        return ResponseEntity.ok(products);
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getProductById(@PathVariable Integer id) {
        return productAdminService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        Product savedProduct = productAdminService.saveProduct(product);
        return ResponseEntity.ok(savedProduct);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Integer id, @RequestBody Product product) {
        if (!productAdminService.getProductById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        product.setId(id);
        Product updatedProduct = productAdminService.saveProduct(product);
        return ResponseEntity.ok(updatedProduct);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Integer id) {
        if (!productAdminService.getProductById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        productAdminService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/product_variant/{fkVariantProduct}")
    public ResponseEntity<List<?>> getByVariantProduct(@PathVariable Integer fkVariantProduct) {
        List<Product_variant> result = productVariantAdminService.getByFkVariantProduct(fkVariantProduct);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/product_variant")
    public ResponseEntity<Product_variant> createProductVariant(@RequestBody Product_variant variant) {
        Product_variant savedVariant = productVariantAdminService.saveProductVariant(variant);
        return ResponseEntity.ok(savedVariant);
    }

    @PutMapping("/product_variant/{id}")
    public ResponseEntity<Product_variant> updateProductVariant(@PathVariable Integer id, @RequestBody Product_variant variant) {
        if (!productVariantAdminService.getProductVariantById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        variant.setId(id);
        Product_variant updatedVariant = productVariantAdminService.saveProductVariant(variant);
        return ResponseEntity.ok(updatedVariant);
    }

    @DeleteMapping("/product_variant/{id}")
    public ResponseEntity<Void> deleteProductVariant(@PathVariable Integer id) {
        if (!productVariantAdminService.getProductVariantById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        productVariantAdminService.deleteProductVariant(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/product_color/{fkVariantProduct}")
    public ResponseEntity<List<?>> getByColorProduct(@PathVariable Integer fkVariantProduct) {
        List<Product_color> result = productColorAdminService.getByFkVariantProduct(fkVariantProduct);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/product_color")
    public ResponseEntity<Product_color> createProductColor(@RequestBody Product_color color) {
        Product_color savedColor = productColorAdminService.saveProductColor(color);
        return ResponseEntity.ok(savedColor);
    }

    @PutMapping("/product_color/{id}")
    public ResponseEntity<Product_color> updateProductColor(@PathVariable Integer id, @RequestBody Product_color color) {
        if (!productColorAdminService.getProductColorById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        color.setId(id);
        Product_color updatedColor = productColorAdminService.saveProductColor(color);
        return ResponseEntity.ok(updatedColor);
    }

    @DeleteMapping("/product_color/{id}")
    public ResponseEntity<Void> deleteProductColor(@PathVariable Integer id) {
        if (!productColorAdminService.getProductColorById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        productColorAdminService.deleteProductColor(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/product_images/{fkImageProduct}")
    public ResponseEntity<List<Product_image>> getImagesByProduct(@PathVariable Integer fkImageProduct) {
        List<Product_image> images = productImageAdminService.getImagesByProduct(fkImageProduct);
        if (images.isEmpty()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(images);
    }

    @PostMapping("/product_images")
    public ResponseEntity<Product_image> createProductImage(@RequestBody Product_image image) {
        Product_image savedImage = productImageAdminService.saveProductImage(image);
        return ResponseEntity.ok(savedImage);
    }

    @DeleteMapping("/product_images/{id}")
    public ResponseEntity<Void> deleteProductImage(@PathVariable Integer id) {
        if (!productImageAdminService.getProductImageById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        productImageAdminService.deleteProductImage(id);
        return ResponseEntity.noContent().build();
    }

}
