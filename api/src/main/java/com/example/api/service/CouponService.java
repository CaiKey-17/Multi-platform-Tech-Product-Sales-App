package com.example.api.service;

import com.example.api.dto.CouponDTO;
import com.example.api.model.Category;
import com.example.api.model.Coupon;
import com.example.api.repository.CategoryRepository;
import com.example.api.repository.CouponRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CouponService {

    @Autowired
    private CouponRepository couponRepository;

    public CouponService(CouponRepository couponRepository) {
        this.couponRepository = couponRepository;
    }

    public CouponDTO findCouponByName(String name){
        Coupon coupon = couponRepository.findByName(name);
        CouponDTO couponDTO = new CouponDTO();
        couponDTO.setId(coupon.getId());
        couponDTO.setName(coupon.getName());
        couponDTO.setCouponValue(coupon.getCouponValue());
        return couponDTO;
    }
}
