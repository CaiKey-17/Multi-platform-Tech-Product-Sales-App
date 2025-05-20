package com.example.api.luan.service;

import com.example.api.luan.repository.BrandAdminRepository;
import com.example.api.luan.repository.OrderAdminRepository;
import com.example.api.model.Brand;
import com.example.api.model.Order;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class OrderAdminService {

    @Autowired
    private OrderAdminRepository orderRepository;

    public List<Order> getOrdersByCustomerId(Integer customerId) {
        return orderRepository.findByCustomerIdExcludeGioHang(customerId);
    }

    public List<Order> getOrdersByCouponId(Integer couponId) {
        return orderRepository.findByFkCouponId(couponId);
    }

    public Optional<Order> getOrderById(Integer orderId) {
        return orderRepository.findById(orderId);
    }

    public List<Order> getAllOrders() {
        return orderRepository.findAllExcludeGioHang();
    }

    @Transactional
    public boolean updateOrderProcess(Integer orderId, String process) {
        if (!isValidProcess(process)) {
            return false;
        }
        int updated = orderRepository.updateOrderProcess(orderId, process);
        return updated > 0;
    }

    private boolean isValidProcess(String process) {
        return process != null &&
                (process.equals("dahuy") ||
                        process.equals("danggiao") ||
                        process.equals("hoantat") ||
                        process.equals("dangdat"));
    }



}
