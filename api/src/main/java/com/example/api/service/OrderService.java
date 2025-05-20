package com.example.api.service;

import com.example.api.dto.OrderStatisticsDTO;
import com.example.api.dto.OrderSummaryDTO;
import com.example.api.model.Order;
import com.example.api.dto.TopSellingProductDTO;
import com.example.api.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    public Integer getOrderIdByCustomer(Integer customerId) {
        return orderRepository.findOrderIdByCustomerIdAndProcess(customerId).orElse(null);
    }

    public List<OrderSummaryDTO> findPendingOrdersByCustomerId(Integer customerId) {
        List<String> processList = List.of("dangdat");
        return orderRepository.findStatusOrdersByCustomerId(customerId,processList,"Chờ xác nhận");
    }

    public List<OrderSummaryDTO> findDeliveringOrdersByCustomerId(Integer customerId) {
        List<String> processList = List.of("danggiao");

        return orderRepository.findStatusOrdersByCustomerId(customerId,processList,"Đã xác nhận");
    }

    public List<OrderSummaryDTO> findDeliveredOrdersByCustomerId(Integer customerId) {
        List<String> processList = List.of("dahuy", "hoantat");
        return orderRepository.findStatusOrdersByCustomerId(customerId,processList,"Hoàn tất");
    }

    public List<Order> getOrdersByCustomerId(Integer customerId) {
        return orderRepository.findByIdFkCustomer(customerId);
    }
    public OrderStatisticsDTO getOrderStatistics() {
        long count = orderRepository.countOrdersNotInCart();
        Long totalRevenue = orderRepository.getTotalRevenue();
        long revenue = totalRevenue != null ? totalRevenue.longValue() : 0L;

        return new OrderStatisticsDTO(count, revenue);
    }

    public List<TopSellingProductDTO> getTopSellingProducts() {
        return orderRepository.findTopSellingProducts();
    }



}
