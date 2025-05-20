package com.example.api.luan.controller;

import com.example.api.luan.repository.OrderAdminRepository;
import com.example.api.luan.service.BrandAdminService;
import com.example.api.luan.service.OrderAdminService;
import com.example.api.model.Brand;
import com.example.api.model.Order;
import com.example.api.service.OrderService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/orders")
public class OrderAdminController {

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderAdminService orderAdminService;

    @GetMapping("/customer/{customerId}")
    public List<Order> getOrdersByCustomer(@PathVariable Integer customerId) {
        return orderAdminService.getOrdersByCustomerId(customerId);
    }

    @GetMapping("/coupon/{couponId}")
    public ResponseEntity<List<Order>> getOrdersByCoupon(@PathVariable Integer couponId) {
        List<Order> orders = orderAdminService.getOrdersByCouponId(couponId);
        return ResponseEntity.ok(orders);
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<Order> getOrderById(@PathVariable Integer orderId) {
        Optional<Order> order = orderAdminService.getOrderById(orderId);
        return order.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Order>> getAllOrders() {
        List<Order> orders = orderAdminService.getAllOrders();
        return ResponseEntity.ok(orders);
    }

    @PutMapping("/{orderId}/process")
    public ResponseEntity<String> updateOrderProcess(
            @PathVariable Integer orderId,
            @RequestParam String process) {
        boolean updated = orderAdminService.updateOrderProcess(orderId, process);
        if (updated) {
            return ResponseEntity.ok("Cập nhật trạng thái đơn hàng thành công");
        } else {
            return ResponseEntity.badRequest().body("Cập nhật trạng thái đơn hàng thất bại. Trạng thái không hợp lệ hoặc đơn hàng không tồn tại");
        }
    }
}

