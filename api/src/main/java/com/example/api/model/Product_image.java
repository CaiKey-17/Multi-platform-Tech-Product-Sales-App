package com.example.api.model;
import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "product_image")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product_image {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(length = 255, nullable = true)
    private String image;

    @Column(length = 255, nullable = true)
    private Integer fkImageProduct;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Integer getFkImageProduct() {
        return fkImageProduct;
    }

    public void setFkImageProduct(Integer fkImageProduct) {
        this.fkImageProduct = fkImageProduct;
    }
}