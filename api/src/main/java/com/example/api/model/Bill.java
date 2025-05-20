package com.example.api.model;

import jakarta.persistence.*;
import lombok.*;

import java.sql.Timestamp;

@Entity
@Table(name = "bills")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Bill {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "created_at", nullable = true)
    private Timestamp createdAt;

    @Column(name = "created_receive", nullable = true)
    private Timestamp createdReceive;

    @Column(name = "status_order", length = 255, nullable = true)
    private String statusOrder;

    @Column(name = "method_payment", length = 50, nullable = true)
    private String methodPayment;

    @Column(nullable = true)
    private Integer fk_orderId;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getCreatedReceive() {
        return createdReceive;
    }

    public void setCreatedReceive(Timestamp createdReceive) {
        this.createdReceive = createdReceive;
    }

    public String getStatusOrder() {
        return statusOrder;
    }

    public void setStatusOrder(String statusOrder) {
        this.statusOrder = statusOrder;
    }

    public String getMethodPayment() {
        return methodPayment;
    }

    public void setMethodPayment(String methodPayment) {
        this.methodPayment = methodPayment;
    }

    public Integer getFk_orderId() {
        return fk_orderId;
    }

    public void setFk_orderId(Integer fk_orderId) {
        this.fk_orderId = fk_orderId;
    }
}
