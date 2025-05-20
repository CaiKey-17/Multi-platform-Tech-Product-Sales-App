package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "product_color")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product_color {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "color_name", length = 50, nullable = false)
    private String colorName;

    @Column(name = "color_price", nullable = false)
    private Double colorPrice;

    private Integer quantity=0;
    private String image;

    private Integer fkVariantProduct;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getColorName() {
        return colorName;
    }

    public void setColorName(String colorName) {
        this.colorName = colorName;
    }

    public Double getColorPrice() {
        return colorPrice;
    }

    public void setColorPrice(Double colorPrice) {
        this.colorPrice = colorPrice;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Integer getFkVariantProduct() {
        return fkVariantProduct;
    }

    public void setFkVariantProduct(Integer fkVariantProduct) {
        this.fkVariantProduct = fkVariantProduct;
    }
}
