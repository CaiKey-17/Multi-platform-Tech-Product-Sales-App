package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "quantity_total", nullable = true)
    private Integer quantityTotal;

    @Column(name = "price_total", nullable = true)
    private Double priceTotal;

    @Column(name = "coupon_total", nullable = true, columnDefinition = "DOUBLE DEFAULT 0")
    private Double couponTotal;

    @Column(name = "point_total", nullable = true, columnDefinition = "DOUBLE DEFAULT 0")
    private Double pointTotal;

    @Column(name = "ship", nullable = true)
    private Double ship;

    @Column(name = "tax", nullable = true)
    private Double tax;

    @Column(name = "created_at", nullable = true)
    private Timestamp createdAt;

    @Column(name = "address", length = 255)
    private String address;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "total", nullable = true, columnDefinition = "DOUBLE DEFAULT 0")
    private Double total;

    @Column(name = "process", length = 100)
    private String process;

    @Column(name = "id_fk_customer",  nullable = true)
    private Integer id_fk_customer;


    @Column(name = "id_fk_product_variant", nullable = true)
    private Integer id_fk_product_variant;

    @Column( nullable = true)
    private Integer fk_couponId;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getQuantityTotal() {
        return quantityTotal;
    }

    public void setQuantityTotal(Integer quantityTotal) {
        this.quantityTotal = quantityTotal;
    }

    public Double getPriceTotal() {
        return priceTotal;
    }

    public void setPriceTotal(Double priceTotal) {
        this.priceTotal = priceTotal;
    }

    public Double getCouponTotal() {
        return couponTotal;
    }

    public void setCouponTotal(Double couponTotal) {
        this.couponTotal = couponTotal;
    }

    public Double getPointTotal() {
        return pointTotal;
    }

    public void setPointTotal(Double pointTotal) {
        this.pointTotal = pointTotal;
    }

    public Double getShip() {
        return ship;
    }

    public void setShip(Double ship) {
        this.ship = ship;
    }

    public Double getTax() {
        return tax;
    }

    public void setTax(Double tax) {
        this.tax = tax;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Double getTotal() {
        return total;
    }

    public void setTotal(Double total) {
        this.total = total;
    }

    public String getProcess() {
        return process;
    }

    public void setProcess(String process) {
        this.process = process;
    }

    public Integer getId_fk_customer() {
        return id_fk_customer;
    }

    public void setId_fk_customer(Integer id_fk_customer) {
        this.id_fk_customer = id_fk_customer;
    }

    public Integer getId_fk_product_variant() {
        return id_fk_product_variant;
    }

    public void setId_fk_product_variant(Integer id_fk_product_variant) {
        this.id_fk_product_variant = id_fk_product_variant;
    }

    public Integer getFk_couponId() {
        return fk_couponId;
    }

    public void setFk_couponId(Integer fk_couponId) {
        this.fk_couponId = fk_couponId;
    }
}
