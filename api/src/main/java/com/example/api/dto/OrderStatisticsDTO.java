package com.example.api.dto;


public class OrderStatisticsDTO {
    private long countOrder;
    private long totalRevenue;

    // Constructor
    public OrderStatisticsDTO(long countOrder, long totalRevenue) {
        this.countOrder = countOrder;
        this.totalRevenue = totalRevenue;
    }

    // Getters và Setters
    public long getCountOrder() {
        return countOrder;
    }

    public void setCountOrder(long countOrder) {
        this.countOrder = countOrder;
    }

    public long getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(long totalRevenue) {
        this.totalRevenue = totalRevenue;
    }
}
