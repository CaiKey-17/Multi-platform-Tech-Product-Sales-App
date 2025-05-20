package com.example.api.dto;

import java.time.LocalDateTime;

public interface OrderSummaryDTO {
    Integer getOrderId();
    LocalDateTime getCreatedAt();
    Double getTotal();
    Integer getTotalItems();
    String getFirstProductImage();
    String getFirstProductName();
    String getStatus();
}
