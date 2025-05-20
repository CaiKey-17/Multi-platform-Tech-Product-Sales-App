package com.example.api.dto;


public class ProductDataDTO {

    private String category;
    private int quantity;

    // Constructor, Getter và Setter
    public ProductDataDTO(String category, int quantity) {
        this.category = category;
        this.quantity = quantity;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
