package com.example.api.model;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "product")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(length = 255, nullable = true)
    private String name;

    @Column(name = "shortDescription", length = 1000, nullable = true)
    private String shortDescription;

    @Column(name = "detail", length = 1000, nullable = true)
    private String detail;

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }

    @Column(name = "created_at", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP", updatable = false, insertable = false)
    private Timestamp createdAt;

    @Column(length = 255, nullable = true)
    private String mainImage;

    @Column(nullable = false, columnDefinition = "BOOLEAN DEFAULT TRUE")
    private Boolean hasColor = true;

    @Column(name = "fk_brand", length = 100, nullable = true)
    private String fkBrand;

    @Column(name = "fk_category", length = 100, nullable = true)
    private String fkCategory;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getShortDescription() {
        return shortDescription;
    }

    public void setShortDescription(String shortDescription) {
        this.shortDescription = shortDescription;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getMainImage() {
        return mainImage;
    }

    public void setMainImage(String mainImage) {
        this.mainImage = mainImage;
    }

    public Boolean getHasColor() {
        return hasColor;
    }

    public void setHasColor(Boolean hasColor) {
        this.hasColor = hasColor;
    }

    public String getFkBrand() {
        return fkBrand;
    }

    public void setFkBrand(String fkBrand) {
        this.fkBrand = fkBrand;
    }

    public String getFkCategory() {
        return fkCategory;
    }

    public void setFkCategory(String fkCategory) {
        this.fkCategory = fkCategory;
    }
}