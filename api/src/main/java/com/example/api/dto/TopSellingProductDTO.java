package com.example.api.dto;

import java.math.BigDecimal;

public class TopSellingProductDTO {
    private Integer productId;
    private String productName;
    private BigDecimal totalSold;

    // Constructor
    public TopSellingProductDTO(Integer productId, String productName, BigDecimal totalSold) {
        this.productId = productId;
        this.productName = productName;
        this.totalSold = totalSold;
    }

    // Getters và Setters
    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public BigDecimal getTotalSold() {
        return totalSold;
    }

    public void setTotalSold(BigDecimal totalSold) {
        this.totalSold = totalSold;
    }
}
