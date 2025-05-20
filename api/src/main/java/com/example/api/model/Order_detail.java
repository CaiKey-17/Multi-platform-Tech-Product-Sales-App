package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "order_details")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Order_detail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "price", nullable = true)
    private Double price;

    @Column(name = "quantity", nullable = true)
    private Integer quantity;

    @Column(name = "total", nullable = true)
    private Double total;

    @Column( nullable = true)
    private Integer fk_orderId;

    @Column( nullable = true)
    private Integer fk_productId;

    @Column( nullable = true)
    private Integer fk_colorId;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Double getTotal() {
        return total;
    }

    public void setTotal(Double total) {
        this.total = total;
    }

    public Integer getFk_orderId() {
        return fk_orderId;
    }

    public void setFk_orderId(Integer fk_orderId) {
        this.fk_orderId = fk_orderId;
    }

    public Integer getFk_productId() {
        return fk_productId;
    }

    public void setFk_productId(Integer fk_productId) {
        this.fk_productId = fk_productId;
    }

    public Integer getFk_colorId() {
        return fk_colorId;
    }

    public void setFk_colorId(Integer fk_colorId) {
        this.fk_colorId = fk_colorId;
    }
}
