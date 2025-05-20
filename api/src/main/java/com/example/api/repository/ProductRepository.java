package com.example.api.repository;

import com.example.api.dto.ProductDTO;
import com.example.api.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Integer> {

    List<Product> findByFkCategory(String fk_category);
    List<Product> findByFkBrand(String fk_brand);

    List<Product> findByNameContainingIgnoreCase(String name);



    List<Product> findTop20ByOrderByCreatedAtDesc();

    @Query(value = """
    SELECT p.* 
    FROM product p
    JOIN product_variant v ON p.id = v.fk_variant_product
    JOIN order_details d ON d.fk_product_id = v.id
    JOIN orders o ON o.id = d.fk_order_id
    WHERE o.process = 'hoantat'
    GROUP BY p.id, p.created_at, p.fk_brand, p.fk_category, p.name, p.short_description, p.has_color, p.main_image
    HAVING SUM(d.quantity) > 0
    ORDER BY SUM(d.quantity) DESC
    LIMIT 20
""", nativeQuery = true)
    List<Product> findTop20BestSeller();


    @Query(value = """
    SELECT 
        COALESCE(AVG(r.rating), 0)
    FROM 
        product p 
    LEFT JOIN 
        rating r ON p.id = r.id_fk_product 
    WHERE 
        p.id = :productId
    GROUP BY 
        p.id, p.created_at, p.fk_brand, p.fk_category, 
        p.name, p.short_description, p.has_color, p.main_image
    """, nativeQuery = true)
    Double findAvgRatingByProductId(@Param("productId") Integer productId);



}

