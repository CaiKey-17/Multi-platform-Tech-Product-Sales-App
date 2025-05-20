package com.example.api.luan.dto;

import lombok.Data;

@Data
public class ProductVariantDTO {
    private Integer id;
    private String nameVariant;
    private Double importPrice;
    private Integer quantity;
    private Double originalPrice;
    private Integer discountPercent;
    private Integer fkVariantProduct;
}