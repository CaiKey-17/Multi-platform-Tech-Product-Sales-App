package com.example.api.repository;

import com.example.api.model.Address;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface AddressRepository extends JpaRepository<Address, Integer> {
    List<Address> findByUserId(Integer userId);

    List<Address> findByUserIdOrderByStatusDesc(Integer userId);


    @Modifying
    @Transactional
    @Query("UPDATE Address a SET a.status = 0 WHERE a.userId = :userId")
    void resetStatusByUserId(Integer userId);

    @Modifying
    @Transactional
    @Query("UPDATE Address a SET a.status = 1 WHERE a.id = :addressId")
    void setDefaultAddress(Integer addressId);


}
