package com.example.api.controller.statistic;

import com.example.api.dto.*;
import com.example.api.repository.OrderRepository;
import com.example.api.service.OrderService;
import com.example.api.service.StatisticService;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/statistic")
public class StatisticController {

    @Autowired
    private UserService userService;

    @Autowired
    private StatisticService statisticService;

    @Autowired
    private OrderRepository orderRepository;

    @GetMapping("/user-stats")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUserStatistics() {
        Map<String, Long> statistics = userService.getUserStatistics();
        ApiResponse<Map<String, Long>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", statistics);
        return ResponseEntity.ok(response);
    }

    @Autowired
    private OrderService orderService;

    @GetMapping("/order-stats")
    public ResponseEntity<ApiResponse<OrderStatisticsDTO>> getOrderStatistics() {
        OrderStatisticsDTO statistics = orderService.getOrderStatistics();
        ApiResponse<OrderStatisticsDTO> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", statistics);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/top-selling-products")
    public ResponseEntity<ApiResponse<List<TopSellingProductDTO>>> getTopSellingProducts() {
        List<TopSellingProductDTO> topSellingProducts = orderService.getTopSellingProducts();
        ApiResponse<List<TopSellingProductDTO>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", topSellingProducts);
        return ResponseEntity.ok(response);
    }


    @GetMapping("/performance")
    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getPerformanceData(@RequestParam("period") String period) {
        List<PerformanceDataProjection> performanceData = statisticService.getPerformanceData(period);
        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/performance-year")
    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getPerformanceDataYear(@RequestParam("year") int year) {
        List<PerformanceDataProjection> performanceData = orderRepository.getStatisticByMonth(year);
        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/performance-year-quarter")
    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getPerformanceDataYearQuarter(@RequestParam("year") int year,@RequestParam("quarter") int quarter) {
        List<PerformanceDataProjection> performanceData = orderRepository.getStatisticByMonthAndQuarter(year,quarter);
        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/performance-year-month")
    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getPerformanceDataYearMonth(@RequestParam("year") int year,@RequestParam("month") int month) {
        List<PerformanceDataProjection> performanceData = orderRepository.getStatisticByDay(year,month);
        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }
    @GetMapping("/performance-year-week")
    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getPerformanceDataYearWeek(@RequestParam("year") int year,@RequestParam("month") int month,@RequestParam("week") int week) {
        List<PerformanceDataProjection> performanceData = orderRepository.getStatisticByWeek(year,month,week);
        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }




    @GetMapping("/product-stats")
    public ResponseEntity<ApiResponse<List<ProductDataDTO>>> getProductData(@RequestParam("period") String period) {
        List<ProductDataDTO> productData = statisticService.getProductData(period);
        ApiResponse<List<ProductDataDTO>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/performance/custom")
    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getCustomPerformanceData(@RequestParam("start") String start, @RequestParam("end") String end) {
        List<PerformanceDataProjection> performanceData = orderRepository.getRevenueByDayBetween(start, end);
        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/product-stats/custom")
    public ResponseEntity<ApiResponse<List<ProductDataDTO>>> getCustomProductData(@RequestParam("start") String start, @RequestParam("end") String end) {
        List<ProductDataDTO> productData = statisticService.getCustomProductData(start, end);
        ApiResponse<List<ProductDataDTO>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    //
//    @GetMapping("/performance-test")
//    public ResponseEntity<ApiResponse<List<PerformanceDataProjection>>> getPerformanceDataTest(@RequestParam("currentYear") int currentYear) {
//        List<PerformanceDataProjection> performanceData = orderRepository.getStatisticByYear(currentYear);
//        ApiResponse<List<PerformanceDataProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
//        return ResponseEntity.ok(response);
//    }


    @GetMapping("/sold-products-by-year")
    public ResponseEntity<ApiResponse<List<TotalProductByYearProjection>>> getSoldProductsByYear() {
        List<TotalProductByYearProjection> productData = orderRepository.getTotalProductByYear();
        ApiResponse<List<TotalProductByYearProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-products-by-year-month")
    public ResponseEntity<ApiResponse<List<TotalProductByYearProjection>>> getSoldProductsByYearMonth(@RequestParam("year") int year) {
        List<TotalProductByYearProjection> productData = orderRepository.getTotalProductByYearMonth(year);
        ApiResponse<List<TotalProductByYearProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-products-by-year-month-v2")
    public ResponseEntity<ApiResponse<List<TotalProductByYearProjection>>> getSoldProductsByYearMonthV2(@RequestParam("year") int year,@RequestParam("month") int month) {
        List<TotalProductByYearProjection> productData = orderRepository.getTotalProductByYearMonth(year,month);
        ApiResponse<List<TotalProductByYearProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-products-by-year-quarter")
    public ResponseEntity<ApiResponse<List<TotalProductByYearProjection>>> getSoldProductsByYearQuarter(@RequestParam("year") int year,@RequestParam("quarter") int quarter) {
        List<TotalProductByYearProjection> productData = orderRepository.getTotalProductByYearQuarter(year,quarter);
        ApiResponse<List<TotalProductByYearProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-products-by-year-month-week")
    public ResponseEntity<ApiResponse<List<TotalProductByYearProjection>>> getSoldProductsByYearMonthWeek(@RequestParam("year") int year,@RequestParam("month") int month,@RequestParam("week") int week) {
        List<TotalProductByYearProjection> performanceData = orderRepository.getTotalProductByYearMonthWeek(year,month,week);
        ApiResponse<List<TotalProductByYearProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-products/custom")
    public ResponseEntity<ApiResponse<List<TotalProductByYearProjection>>> getTotalProductByDayBetween(@RequestParam("start") String start, @RequestParam("end") String end) {
        List<TotalProductByYearProjection> productData = orderRepository.getTotalProductByDayBetween(start, end);
        ApiResponse<List<TotalProductByYearProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

//ádasdasdas
@GetMapping("/sold-type-products-by-year")
public ResponseEntity<ApiResponse<List<CategorySalesProjection>>> getSoldTypeProductsByYear() {
    List<CategorySalesProjection> productData = orderRepository.getTypeProduct();
    ApiResponse<List<CategorySalesProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
    return ResponseEntity.ok(response);
}

    @GetMapping("/sold-type-products-by-year-month")
    public ResponseEntity<ApiResponse<List<CategorySalesProjection>>> getSoldTypeProductsByYearMonth(@RequestParam("year") int year) {
        List<CategorySalesProjection> productData = orderRepository.getTypeProductByYear(year);
        ApiResponse<List<CategorySalesProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-type-products-by-year-month-v2")
    public ResponseEntity<ApiResponse<List<CategorySalesProjection>>> getSoldTypeProductsByYearMonthV2(@RequestParam("year") int year,@RequestParam("month") int month) {
        List<CategorySalesProjection> productData = orderRepository.getTypeProductByYearMonth(year,month);
        ApiResponse<List<CategorySalesProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-type-products-by-year-quarter")
    public ResponseEntity<ApiResponse<List<CategorySalesProjection>>> getSoldTypeProductsByYearQuarter(@RequestParam("year") int year,@RequestParam("quarter") int quarter) {
        List<CategorySalesProjection> productData = orderRepository.getTypeProductByYearQuarter(year,quarter);
        ApiResponse<List<CategorySalesProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-type-products-by-year-month-week")
    public ResponseEntity<ApiResponse<List<CategorySalesProjection>>> getSoldTypeProductsByYearMonthWeek(@RequestParam("year") int year,@RequestParam("month") int month,@RequestParam("week") int week) {
        List<CategorySalesProjection> performanceData = orderRepository.getTypeProductByYearWeek(year,month,week);
        ApiResponse<List<CategorySalesProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", performanceData);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/sold-type-products/custom")
    public ResponseEntity<ApiResponse<List<CategorySalesProjection>>> getTotalTypeProductByDayBetween(@RequestParam("start") String start, @RequestParam("end") String end) {
        List<CategorySalesProjection> productData = orderRepository.getTypeProductByDayBetween(start, end);
        ApiResponse<List<CategorySalesProjection>> response = new ApiResponse<>(200, "Dữ liệu được tải về thành công", productData);
        return ResponseEntity.ok(response);
    }







}
