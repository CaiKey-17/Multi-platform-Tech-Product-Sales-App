package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;
import java.sql.Timestamp;

@Entity
@Table(name = "coupons")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Coupon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "name", length = 5, nullable = true)
    private String name;

    @Column(name = "coupon_value", nullable = false)
    private Integer couponValue;

    @Column(name = "max_allowed_uses", nullable = false)
    private Integer maxAllowedUses;

    @Column(name = "used_count", nullable = false)
    private Integer usedCount = 0;

    @Column(name = "min_order_value", nullable = false)
    private Integer minOrderValue;


    @Column(name = "created_at", columnDefinition = "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    private Timestamp createdAt;

    public Integer getUsedCount() {
        return usedCount;
    }

    public Integer getMinOrderValue() {
        return minOrderValue;
    }

    public void setMinOrderValue(Integer minOrderValue) {
        this.minOrderValue = minOrderValue;
    }

    public void setUsedCount(Integer usedCount) {
        this.usedCount = usedCount;
    }

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

    public Integer getCouponValue() {
        return couponValue;
    }

    public void setCouponValue(Integer couponValue) {
        this.couponValue = couponValue;
    }

    public Integer getMaxAllowedUses() {
        return maxAllowedUses;
    }

    public void setMaxAllowedUses(Integer maxAllowedUses) {
        this.maxAllowedUses = maxAllowedUses;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}
