package com.example.api.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.Formula;

@Entity
@Table(name = "product_variant")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product_variant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column( length = 255)
    private String nameVariant;

    private Double importPrice;

    @Column(name = "quantity", nullable = true)
    private Integer quantity=0;

    private Double originalPrice;

    private Integer discountPercent;
    @Column(name = "price", nullable = true, insertable = false, updatable = false)
    private Double price;



    @Column(name = "fk_variant_product", nullable = true)
    private Integer fkVariantProduct;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNameVariant() {
        return nameVariant;
    }

    public void setNameVariant(String nameVariant) {
        this.nameVariant = nameVariant;
    }

    public Double getImportPrice() {
        return importPrice;
    }

    public void setImportPrice(Double importPrice) {
        this.importPrice = importPrice;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getOriginalPrice() {
        return originalPrice;
    }

    public void setOriginalPrice(Double originalPrice) {
        this.originalPrice = originalPrice;
    }

    public Integer getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(Integer discountPercent) {
        this.discountPercent = discountPercent;
    }

    public Double getPrice() {
        return price;
    }

    @JsonIgnore
    public void setPrice(Double price) {
        this.price = price;
    }

    public Integer getFkVariantProduct() {
        return fkVariantProduct;
    }

    public void setFkVariantProduct(Integer fkVariantProduct) {
        this.fkVariantProduct = fkVariantProduct;
    }
}
