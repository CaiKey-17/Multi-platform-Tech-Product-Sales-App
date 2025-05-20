package com.example.api.dto;

import java.math.BigDecimal;

public interface OrderDetailProjection {
    Integer getOrderId();
    Integer getProductId();
    Integer getOrderDetailId();
    Integer getFkColorId();
    Integer getFkProductId();
    BigDecimal getPrice();
    BigDecimal getOriginalPrice();

    Integer getQuantity();
    BigDecimal getTotal();
    String getImage();
    String getColorName();
    String getNameVariant();

}
