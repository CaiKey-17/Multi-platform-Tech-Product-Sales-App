package com.example.api.repository;

import com.example.api.dto.CouponDTO;
import com.example.api.model.Category;
import com.example.api.model.Coupon;
import com.example.api.model.Product_variant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CouponRepository extends JpaRepository<Coupon,Integer> {

    Coupon findByName(String name);

    boolean existsByName(String name);

}
