package com.example.api.luan.repository;

import com.example.api.model.Bill;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BillAdminRepository extends JpaRepository<Bill, Integer> {
    @Query("SELECT b FROM Bill b WHERE b.fk_orderId = :orderId")
    List<Bill> findByFkOrderId(@Param("orderId") Integer orderId);

    @Modifying
    @Transactional
    @Query("UPDATE Bill b SET b.statusOrder = :statusOrder WHERE b.id = :billId")
    int updateBillStatus(@Param("billId") Integer billId, @Param("statusOrder") String statusOrder);
}
