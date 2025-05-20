package com.example.api.dto;

import lombok.Data;

import java.util.List;

@Data
public class CouponDTO {
    private int id;
    private String name;
    private int couponValue;

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

    public int getCouponValue() {
        return couponValue;
    }

    public void setCouponValue(int couponValue) {
        this.couponValue = couponValue;
    }
}
