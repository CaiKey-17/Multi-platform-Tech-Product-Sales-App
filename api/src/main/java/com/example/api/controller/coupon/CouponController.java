package com.example.api.controller.coupon;

import com.example.api.dto.CouponDTO;
import com.example.api.model.Brand;
import com.example.api.model.Coupon;
import com.example.api.repository.CouponRepository;
import com.example.api.service.BrandService;
import com.example.api.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/coupon")
public class CouponController {

    @Autowired
    private CouponService couponService;

    @Autowired
    private CouponRepository couponRepository;

    public CouponController(CouponService couponService) {
        this.couponService = couponService;
    }

    @GetMapping("/find")
    public ResponseEntity<?> findCoupon(@RequestParam String name,@RequestParam double price) {
        Coupon coupon = couponRepository.findByName(name);

        if (coupon == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 404,
                    "message", "Mã giảm giá không tồn tại"
            ));
        }

        if(price<= coupon.getMinOrderValue()){
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 400,
                    "message", "Đơn hàng chưa đủ điều kiện áp dụng"
            ));


        }

        if (coupon.getMaxAllowedUses() == coupon.getUsedCount()) {
            return ResponseEntity.badRequest().body(Map.of(
                    "code", 400,
                    "message", "Mã này đã hết lượt dùng"
            ));
        }

        CouponDTO couponDTO = couponService.findCouponByName(name);
        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "Áp dụng mã thành công",
                "data", couponDTO
        ));
    }

    @GetMapping()
    public ResponseEntity<?> listCoupon() {
        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "Áp dụng mã thành công",
                "data", couponRepository.findAll()
        ));
    }

    @PostMapping()
    public ResponseEntity<?> addCoupon(@RequestParam int couponValue,
                                       @RequestParam int  maxAllowedUses,
                                       @RequestParam int minOrderValue) {


        Coupon coupon = new Coupon();

        coupon.setName(generateRandomName());
        coupon.setUsedCount(0);
        coupon.setCouponValue(couponValue);
        coupon.setMaxAllowedUses(maxAllowedUses);
        coupon.setMinOrderValue(minOrderValue);
        coupon.setCreatedAt(Timestamp.valueOf(LocalDateTime.now()));

        couponRepository.save(coupon);

        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "Tạo mã thành công",
                "data", coupon
        ));
    }

    @PostMapping("/delete")
    public ResponseEntity<?> deleteCoupon(
                                       @RequestParam int id) {



        couponRepository.deleteById(id);

        return ResponseEntity.ok(Map.of(
                "code", 200,
                "message", "Xóa mã thành công"
        ));
    }

    private String generateRandomName() {
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder randomName = new StringBuilder();

        for (int i = 0; i < 5; i++) {
            int index = random.nextInt(characters.length());
            randomName.append(characters.charAt(index));
        }

        while (couponRepository.existsByName(randomName.toString())) {
            randomName = new StringBuilder();
            for (int i = 0; i < 5; i++) {
                int index = random.nextInt(characters.length());
                randomName.append(characters.charAt(index));
            }
        }

        return randomName.toString();
    }


}
