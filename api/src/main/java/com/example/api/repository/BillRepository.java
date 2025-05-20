package com.example.api.repository;

import com.example.api.model.Bill;
import com.example.api.model.Brand;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface BillRepository extends JpaRepository<Bill,Integer> {

    @Query("SELECT b FROM Bill b WHERE b.fk_orderId = :orderId")
    Bill findByFkOrderId(@Param("orderId") Integer orderId);

}
