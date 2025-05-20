package com.example.api.service;

import com.example.api.controller.statistic.TimeGroupType;
import com.example.api.dto.PerformanceDataDTO;
import com.example.api.dto.PerformanceDataProjection;
import com.example.api.dto.ProductDataDTO;
import com.example.api.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StatisticService {

    @Autowired
    private OrderRepository orderRepository;

    public List<PerformanceDataProjection> getPerformanceData(String periodLabel) {
        TimeGroupType period;
        try {
            period = TimeGroupType.fromLabel(periodLabel);
        } catch (IllegalArgumentException e) {
            return List.of();
        }

        return switch (period) {
            case YEAR -> orderRepository.getStatisticByYear();
            case QUARTER -> orderRepository.getStatisticByQuarter();
            case MONTH -> orderRepository.getStatisticByMonth();
            case WEEK -> orderRepository.getStatisticByWeek();
        };
    }




    public List<ProductDataDTO> getProductData(String period) {
        return List.of(
                new ProductDataDTO("Electronics", 320),
                new ProductDataDTO("Clothing", 210),
                new ProductDataDTO("Home Appliances", 180),
                new ProductDataDTO("Books", 90)
        );
    }

    public List<PerformanceDataDTO> getCustomPerformanceData(String start, String end) {
        return List.of(
                new PerformanceDataDTO("2024-01-01", 50, 7000.0, 2000.0),
                new PerformanceDataDTO("2024-01-15", 80, 10000.0, 3500.0),
                new PerformanceDataDTO("2024-02-01", 90, 12000.0, 4000.0)
        );
    }

    public List<ProductDataDTO> getCustomProductData(String start, String end) {
        return List.of(
                new ProductDataDTO("Electronics", 130),
                new ProductDataDTO("Clothing", 95),
                new ProductDataDTO("Books", 40)
        );
    }
}
