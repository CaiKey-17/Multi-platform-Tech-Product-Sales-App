package com.example.api.service;

import com.example.api.dto.OrderDetailProjection;
import com.example.api.repository.OrderDetailRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OrderDetailService {

    @Autowired
    private OrderDetailRepository orderDetailRepository;

    public Integer getQuantity(Integer orderId, Integer productId, Integer colorId) {
        return orderDetailRepository.getQuantityByOrderProductColor(orderId, productId, colorId);
    }

    public Integer getQuantity(Integer orderId, Integer productId) {
        return orderDetailRepository.getQuantityByOrderAndProduct(orderId, productId);
    }

    public List<OrderDetailProjection> getOrderDetailsByCustomerId(Integer customerId,String process) {
        return orderDetailRepository.findOrderDetailsByCustomerId(customerId,process);
    }

    public List<OrderDetailProjection> getOrderDetailsByCustomerIdDetail(Integer orderId) {
        return orderDetailRepository.findOrderDetailsByCustomerIdDetail(orderId);
    }

    public List<OrderDetailProjection> getOrderDetailsByCustomerIdAndOrderId(Integer customerId,String process,int orderId) {
        return orderDetailRepository.findOrderDetailsByCustomerIdAndOrderId(customerId,process,orderId);
    }
}
