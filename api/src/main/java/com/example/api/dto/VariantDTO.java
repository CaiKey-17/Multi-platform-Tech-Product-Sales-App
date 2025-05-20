package com.example.api.dto;

import lombok.Data;

import java.util.List;

@Data
public class VariantDTO {
    private int id;
    private String name;
    private int discountPercent;
    private double oldPrice;
    private double price;
    private List<ColorDTO> colors;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(int discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getOldPrice() {
        return oldPrice;
    }

    public void setOldPrice(double oldPrice) {
        this.oldPrice = oldPrice;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public List<ColorDTO> getColors() {
        return colors;
    }

    public void setColors(List<ColorDTO> colors) {
        this.colors = colors;
    }
}
