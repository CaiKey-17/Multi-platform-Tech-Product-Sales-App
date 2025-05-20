package com.example.api.luan.repository;

import com.example.api.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderAdminRepository extends JpaRepository<Order, Integer> {
    @Query("SELECT o FROM Order o WHERE o.id_fk_customer = :customerId")
    List<Order> findByIdFkCustomer(@Param("customerId") Integer customerId);

    @Query("SELECT o FROM Order o WHERE o.fk_couponId = :couponId")
    List<Order> findByFkCouponId(@Param("couponId") Integer couponId);

    @Modifying
    @Query("UPDATE Order o SET o.process = :process WHERE o.id = :orderId")
    int updateOrderProcess(@Param("orderId") Integer orderId, @Param("process") String process);

    @Query("SELECT o FROM Order o WHERE o.process <> 'giohang'")
    List<Order> findAllExcludeGioHang();


    @Query("SELECT o FROM Order o WHERE o.id_fk_customer = :customerId AND o.process <> 'giohang'")
    List<Order> findByCustomerIdExcludeGioHang(@Param("customerId") Integer customerId);



}
