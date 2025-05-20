package com.example.api.repository;

import com.example.api.dto.*;
import com.example.api.model.Address;
import com.example.api.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Integer> {
    @Query("SELECT o.id FROM Order o WHERE o.id_fk_customer = :customerId AND o.process = 'giohang'")
    Optional<Integer> findOrderIdByCustomerIdAndProcess(@Param("customerId") Integer customerId);


    @Query(value = """
         SELECT
           o.id AS orderId,
           o.created_at AS createdAt,
           o.total AS total,
           COUNT(d.id) AS totalItems,
           (
             SELECT p.main_image
             FROM order_details d2
             JOIN product_variant v2 ON d2.fk_product_id = v2.id
             JOIN product p ON v2.fk_variant_product = p.id
             WHERE d2.fk_order_id = o.id
             ORDER BY d2.id ASC
             LIMIT 1
           ) AS firstProductImage,
           (
             SELECT p.name
             FROM order_details d2
             JOIN product_variant v2 ON d2.fk_product_id = v2.id
             JOIN product p ON v2.fk_variant_product = p.id
             WHERE d2.fk_order_id = o.id
             ORDER BY d2.id ASC
             LIMIT 1
           ) AS firstProductName,
           CASE
             WHEN 'dahuy' IN (:processList) AND o.process = 'dahuy' THEN 'Đã hủy'
              WHEN 'danggiao' IN (:processList) AND o.process = 'danggiao' THEN 'Đã xác nhận'
             WHEN 'hoantat' IN (:processList) AND o.process = 'hoantat' THEN 'Hoàn tất'
             ELSE 'Chờ xác nhận'
           END AS status
         FROM orders o
         JOIN order_details d ON o.id = d.fk_order_id
         JOIN product_variant v ON d.fk_product_id = v.id
         JOIN product p ON v.fk_variant_product = p.id
         WHERE o.id_fk_customer = :customerId AND o.process IN (:processList)
         GROUP BY o.id, o.created_at, o.total
         ORDER BY o.created_at DESC;
        """, nativeQuery = true)
    List<OrderSummaryDTO> findStatusOrdersByCustomerId(@Param("customerId") Integer customerId,@Param("processList") List<String> processList,@Param("status") String status );

    @Query("SELECT o FROM Order o WHERE o.id_fk_customer = :idFkCustomer")
    List<Order> findByIdFkCustomer(@Param("idFkCustomer") Integer idFkCustomer);
    @Query("SELECT COUNT(o) FROM Order o WHERE o.process != 'giohang'")
    long countOrdersNotInCart();

    @Query("SELECT SUM(o.total) FROM Order o WHERE o.process = 'hoantat'")
    Long getTotalRevenue();

    @Query(value = """
        SELECT p.id AS productId,
               p.name AS productName,
               SUM(d.quantity) AS totalSold
        FROM product p
        JOIN product_variant v ON p.id = v.fk_variant_product
        JOIN order_details d ON d.fk_product_id = v.id
        JOIN orders o ON o.id = d.fk_order_id
        WHERE o.process = 'hoantat'
        GROUP BY p.id, p.name
        HAVING SUM(d.quantity) > 0
        ORDER BY SUM(d.quantity) DESC
        LIMIT 3
    """, nativeQuery = true)
    List<TopSellingProductDTO> findTopSellingProducts();


    @Query(value = """
        SELECT 
            CONCAT('Tháng ', MONTH(o.created_at)) AS thoiGian,
            SUM(od.total) AS tongDoanhThu,
            SUM((od.price - pv.import_price) * od.quantity) AS tongLoiNhuan,
            COUNT(DISTINCT o.id) AS tongSoDon
        FROM orders o
        JOIN order_details od ON o.id = od.fk_order_id
        JOIN product_variant pv ON od.fk_product_id = pv.id
        WHERE o.process = 'hoantat'
        GROUP BY thoiGian
        ORDER BY thoiGian
        """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByMonth();

//    @Query(value = """
//        SELECT
//            CONCAT('Năm ', YEAR(o.created_at)) AS thoiGian,
//            SUM(od.total) AS tongDoanhThu,
//            SUM((od.price - pv.import_price) * od.quantity) AS tongLoiNhuan,
//            COUNT(DISTINCT o.id) AS tongSoDon
//        FROM orders o
//        JOIN order_details od ON o.id = od.fk_order_id
//        JOIN product_variant pv ON o.id_fk_product_variant = pv.id
//        WHERE o.process = 'hoantat'
//        GROUP BY thoiGian
//        ORDER BY thoiGian
//        """, nativeQuery = true)
//    List<PerformanceDataProjection> getStatisticByYear();

    @Query(value = """
        SELECT 
            CONCAT('Quý ', QUARTER(o.created_at)) AS thoiGian,
            SUM(od.total) AS tongDoanhThu,
            SUM((od.price - pv.import_price) * od.quantity) AS tongLoiNhuan,
            COUNT(DISTINCT o.id) AS tongSoDon
        FROM orders o
        JOIN order_details od ON o.id = od.fk_order_id
        JOIN product_variant pv ON od.fk_product_id = pv.id
        WHERE o.process = 'hoantat'
        GROUP BY thoiGian
        ORDER BY thoiGian
        """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByQuarter();

    @Query(value = """
        SELECT 
            WEEK(o.created_at) AS thoiGian,
            SUM(od.total) AS tongDoanhThu,
            SUM((od.price - pv.import_price) * od.quantity) AS tongLoiNhuan,
            COUNT(DISTINCT o.id) AS tongDonHang
        FROM orders o
        JOIN order_details od ON o.id = od.fk_order_id
        JOIN product_variant pv ON od.fk_product_id = pv.id
        WHERE o.process = 'hoantat'
        AND YEAR(o.created_at) = YEAR(CURRENT_DATE)  -- Điều kiện để lấy tuần trong năm này
        GROUP BY WEEK(o.created_at)
        ORDER BY thoiGian
    """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByWeek();


    //


    @Query(value = """
    SELECT 
        CONCAT('Năm ', y.nam) AS thoiGian,
        COALESCE(SUM(od.total), 0) AS tongDoanhThu,
        COALESCE(SUM((od.price - pv.import_price) * od.quantity), 0) AS tongLoiNhuan,
        COALESCE(COUNT(DISTINCT o.id), 0) AS tongSoDon
    FROM 
        (SELECT YEAR(CURDATE()) - 4 AS nam UNION ALL
         SELECT YEAR(CURDATE()) - 3 UNION ALL
         SELECT YEAR(CURDATE()) - 2 UNION ALL
         SELECT YEAR(CURDATE()) - 1 UNION ALL
         SELECT YEAR(CURDATE())) y
    LEFT JOIN orders o ON YEAR(o.created_at) = y.nam AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON od.fk_product_id = pv.id
    GROUP BY y.nam
    ORDER BY y.nam
    """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByYear();

    @Query(value = """
    SELECT 
        CONCAT('Tháng ', m.thang) AS thoiGian,
        COALESCE(SUM(od.total), 0) AS tongDoanhThu,
        COALESCE(SUM((od.price - pv.import_price) * od.quantity), 0) AS tongLoiNhuan,
        COALESCE(COUNT(DISTINCT o.id), 0) AS tongSoDon
    FROM 
        (SELECT 1 AS thang UNION ALL 
         SELECT 2 UNION ALL 
         SELECT 3 UNION ALL 
         SELECT 4 UNION ALL 
         SELECT 5 UNION ALL 
         SELECT 6 UNION ALL 
         SELECT 7 UNION ALL 
         SELECT 8 UNION ALL 
         SELECT 9 UNION ALL 
         SELECT 10 UNION ALL 
         SELECT 11 UNION ALL 
         SELECT 12) m
    LEFT JOIN orders o ON MONTH(o.created_at) = m.thang 
        AND YEAR(o.created_at) = :year AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON od.fk_product_id = pv.id
    GROUP BY m.thang
    ORDER BY m.thang
    """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByMonth(@Param("year") int year);


    @Query(value = """
        SELECT 
            CONCAT('Tháng ', m.thang) AS thoiGian,
            COALESCE(SUM(od.total), 0) AS tongDoanhThu,
            COALESCE(SUM((od.price - pv.import_price) * od.quantity), 0) AS tongLoiNhuan,
            COALESCE(COUNT(DISTINCT o.id), 0) AS tongSoDon
        FROM 
            (SELECT 1 AS thang UNION ALL
             SELECT 2 UNION ALL
             SELECT 3 UNION ALL
             SELECT 4 UNION ALL
             SELECT 5 UNION ALL
             SELECT 6 UNION ALL
             SELECT 7 UNION ALL
             SELECT 8 UNION ALL
             SELECT 9 UNION ALL
             SELECT 10 UNION ALL
             SELECT 11 UNION ALL
             SELECT 12) m
        LEFT JOIN orders o ON MONTH(o.created_at) = m.thang 
            AND YEAR(o.created_at) = :year AND o.process = 'hoantat'
        LEFT JOIN order_details od ON o.id = od.fk_order_id
        LEFT JOIN product_variant pv ON od.fk_product_id = pv.id
        WHERE 
            (m.thang BETWEEN 
                CASE 
                    WHEN :quarter = 1 THEN 1
                    WHEN :quarter = 2 THEN 4
                    WHEN :quarter = 3 THEN 7
                    WHEN :quarter = 4 THEN 10
                END
            AND 
                CASE 
                    WHEN :quarter = 1 THEN 3
                    WHEN :quarter = 2 THEN 6
                    WHEN :quarter = 3 THEN 9
                    WHEN :quarter = 4 THEN 12
                END)
        GROUP BY m.thang
        ORDER BY m.thang
    """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByMonthAndQuarter(int year, int quarter);

    @Query(value = """
        WITH RECURSIVE DateRange AS (
            SELECT DATE(CONCAT(:year, '-', :month, '-01')) AS date_value
            UNION ALL
            SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
            FROM DateRange
            WHERE date_value < LAST_DAY(DATE(CONCAT(:year, '-', :month, '-01')))
        )
        SELECT 
            CONCAT(DAY(d.date_value), '/', :month) AS thoiGian,
            COALESCE(SUM(od.total), 0) AS tongDoanhThu,
            COALESCE(SUM((od.price - pv.import_price) * od.quantity), 0) AS tongLoiNhuan,
            COALESCE(COUNT(DISTINCT o.id), 0) AS tongSoDon
        FROM 
            DateRange d
        LEFT JOIN orders o ON DAY(o.created_at) = DAY(d.date_value) 
            AND YEAR(o.created_at) = :year
            AND MONTH(o.created_at) = :month
            AND o.process = 'hoantat'
        LEFT JOIN order_details od ON o.id = od.fk_order_id
        LEFT JOIN product_variant pv ON od.fk_product_id = pv.id
        GROUP BY d.date_value
        ORDER BY d.date_value
    """, nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByDay(@Param("year") int year, @Param("month") int month);


    @Query(value = """
    WITH RECURSIVE DateRange AS (
        -- Tính ngày đầu tiên của tháng được truyền vào
        SELECT DATE(CONCAT(:year, '-', :month, '-01')) AS date_value
        UNION ALL
        -- Tăng ngày thêm một bước mỗi lần
        SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
        FROM DateRange
        WHERE date_value < LAST_DAY(DATE(CONCAT(:year, '-', :month, '-01'))) -- Kết thúc khi hết ngày của tháng
    )
    SELECT 
        CONCAT(DAY(d.date_value), '/', :month) AS thoiGian,        
        COALESCE(SUM(od.total), 0) AS tongDoanhThu,
        COALESCE(SUM((od.price - pv.import_price) * od.quantity), 0) AS tongLoiNhuan,
        COALESCE(COUNT(DISTINCT o.id), 0) AS tongSoDon
    FROM 
        DateRange d
    LEFT JOIN orders o ON DAY(o.created_at) = DAY(d.date_value) 
        AND YEAR(o.created_at) = :year
        AND MONTH(o.created_at) = :month
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON od.fk_product_id = pv.id
    WHERE 
        (
            (DAY(d.date_value) BETWEEN 1 AND 7 AND :week = 1) OR
            (DAY(d.date_value) BETWEEN 8 AND 14 AND :week = 2) OR
            (DAY(d.date_value) BETWEEN 15 AND 21 AND :week = 3) OR
            (DAY(d.date_value) BETWEEN 22 AND 28 AND :week = 4)
        )
    GROUP BY d.date_value
    ORDER BY d.date_value
""", nativeQuery = true)
    List<PerformanceDataProjection> getStatisticByWeek(@Param("year") int year, @Param("month") int month, @Param("week") int week);

    @Query(value = """
WITH RECURSIVE DateRange AS (
    SELECT DATE(:startDate) AS date_value
    UNION ALL
    SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
    FROM DateRange
    WHERE date_value < DATE(:endDate)
)
SELECT 
    DATE_FORMAT(d.date_value, '%d-%m-%Y') AS thoiGian,
    COALESCE(SUM(od.total), 0) AS tongDoanhThu,
    COALESCE(SUM((od.price - pv.import_price) * od.quantity), 0) AS tongLoiNhuan,
    COALESCE(COUNT(DISTINCT o.id), 0) AS tongSoDon
FROM DateRange d
LEFT JOIN orders o ON DATE(o.created_at) = d.date_value AND o.process = 'hoantat'
LEFT JOIN order_details od ON o.id = od.fk_order_id
LEFT JOIN product_variant pv ON od.fk_product_id = pv.id
GROUP BY d.date_value
ORDER BY d.date_value
""", nativeQuery = true)
    List<PerformanceDataProjection> getRevenueByDayBetween(@Param("startDate") String startDate, @Param("endDate") String endDate);



    @Query(value = """
    SELECT 
        CONCAT('Năm ', y.nam) AS thoiGian,
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        (SELECT YEAR(CURDATE()) - 4 AS nam UNION ALL
         SELECT YEAR(CURDATE()) - 3 UNION ALL
         SELECT YEAR(CURDATE()) - 2 UNION ALL
         SELECT YEAR(CURDATE()) - 1 UNION ALL
         SELECT YEAR(CURDATE())) y
    LEFT JOIN orders o ON YEAR(o.created_at) = y.nam AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    GROUP BY y.nam
    ORDER BY y.nam
""", nativeQuery = true)
    List<TotalProductByYearProjection> getTotalProductByYear();


    @Query(value = """
    SELECT 
        CONCAT('Tháng ', m.thang) AS thoiGian,
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        (SELECT 1 AS thang UNION ALL 
         SELECT 2 UNION ALL 
         SELECT 3 UNION ALL 
         SELECT 4 UNION ALL 
         SELECT 5 UNION ALL 
         SELECT 6 UNION ALL 
         SELECT 7 UNION ALL 
         SELECT 8 UNION ALL 
         SELECT 9 UNION ALL 
         SELECT 10 UNION ALL 
         SELECT 11 UNION ALL 
         SELECT 12) m
    LEFT JOIN orders o ON MONTH(o.created_at) = m.thang 
        AND YEAR(o.created_at) = :year 
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    GROUP BY m.thang
    ORDER BY m.thang
""", nativeQuery = true)
    List<TotalProductByYearProjection> getTotalProductByYearMonth(@Param("year") int year);

    @Query(value = """
    WITH RECURSIVE DateRange AS (
        SELECT DATE(CONCAT(:year, '-', :month, '-01')) AS date_value
        UNION ALL
        SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
        FROM DateRange
        WHERE date_value < LAST_DAY(DATE(CONCAT(:year, '-', :month, '-01')))
    )
    SELECT 
        CONCAT(DAY(d.date_value), ' / ', :month) AS thoiGian,            
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        DateRange d
    LEFT JOIN orders o ON DATE(o.created_at) = d.date_value 
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    GROUP BY d.date_value
    ORDER BY d.date_value
""", nativeQuery = true)
    List<TotalProductByYearProjection> getTotalProductByYearMonth(@Param("year") int year, @Param("month") int month);


    @Query(value = """
    SELECT 
        CONCAT('Tháng ', m.thang) AS thoiGian,
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        (SELECT 1 AS thang UNION ALL
         SELECT 2 UNION ALL
         SELECT 3 UNION ALL
         SELECT 4 UNION ALL
         SELECT 5 UNION ALL
         SELECT 6 UNION ALL
         SELECT 7 UNION ALL
         SELECT 8 UNION ALL
         SELECT 9 UNION ALL
         SELECT 10 UNION ALL
         SELECT 11 UNION ALL
         SELECT 12) m
    LEFT JOIN orders o ON MONTH(o.created_at) = m.thang 
        AND YEAR(o.created_at) = :year 
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    WHERE 
        m.thang BETWEEN 
            CASE WHEN :quarter = 1 THEN 1
                 WHEN :quarter = 2 THEN 4
                 WHEN :quarter = 3 THEN 7
                 WHEN :quarter = 4 THEN 10
            END
        AND 
            CASE WHEN :quarter = 1 THEN 3
                 WHEN :quarter = 2 THEN 6
                 WHEN :quarter = 3 THEN 9
                 WHEN :quarter = 4 THEN 12
            END
    GROUP BY m.thang
    ORDER BY m.thang
""", nativeQuery = true)
    List<TotalProductByYearProjection> getTotalProductByYearQuarter(
            @Param("year") int year,
            @Param("quarter") int quarter
    );


    @Query(value = """
    WITH RECURSIVE DateRange AS (
        -- Tính ngày đầu tiên của tháng được truyền vào
        SELECT DATE(CONCAT(:year, '-', :month, '-01')) AS date_value
        UNION ALL
        -- Tăng ngày thêm một bước mỗi lần
        SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
        FROM DateRange
        WHERE date_value < LAST_DAY(DATE(CONCAT(:year, '-', :month, '-01'))) -- Kết thúc khi hết ngày của tháng
    )
    SELECT 
        CONCAT(DAY(d.date_value), '/', :month) AS thoiGian,                    
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        DateRange d
    LEFT JOIN orders o ON DAY(o.created_at) = DAY(d.date_value) 
        AND YEAR(o.created_at) = :year
        AND MONTH(o.created_at) = :month
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    WHERE 
        (
            (DAY(d.date_value) BETWEEN 1 AND 7 AND :week = 1) OR
            (DAY(d.date_value) BETWEEN 8 AND 14 AND :week = 2) OR
            (DAY(d.date_value) BETWEEN 15 AND 21 AND :week = 3) OR
            (DAY(d.date_value) BETWEEN 22 AND 28 AND :week = 4)
        )
    GROUP BY d.date_value
    ORDER BY d.date_value
""", nativeQuery = true)
    List<TotalProductByYearProjection> getTotalProductByYearMonthWeek(
            @Param("year") int year,
            @Param("month") int month,
            @Param("week") int week
    );


    @Query(value = """
WITH RECURSIVE DateRange AS (
    SELECT DATE(:startDate) AS date_value
    UNION ALL
    SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
    FROM DateRange
    WHERE date_value < DATE(:endDate)
)
SELECT 
    DATE_FORMAT(d.date_value, '%d-%m-%Y') AS thoiGian,
    COALESCE(SUM(od.quantity), 0) AS tongSanPham
FROM DateRange d
LEFT JOIN orders o ON DATE(o.created_at) = d.date_value AND o.process = 'hoantat'
LEFT JOIN order_details od ON o.id = od.fk_order_id
GROUP BY d.date_value
ORDER BY d.date_value
""", nativeQuery = true)
    List<TotalProductByYearProjection> getTotalProductByDayBetween(
            @Param("startDate") String startDate,
            @Param("endDate") String endDate
    );



/// /
///

    @Query(value = """
SELECT 
    CONCAT('Năm ', y.nam) AS thoiGian,
    COALESCE(c.name, '') AS tenLoaiSanPham,            
    COALESCE(SUM(od.quantity), 0) AS tongSanPham
FROM 
    (SELECT YEAR(CURDATE()) - 4 AS nam UNION ALL
     SELECT YEAR(CURDATE()) - 3 UNION ALL
     SELECT YEAR(CURDATE()) - 2 UNION ALL
     SELECT YEAR(CURDATE()) - 1 UNION ALL
     SELECT YEAR(CURDATE())) y
LEFT JOIN orders o ON YEAR(o.created_at) = y.nam AND o.process = 'hoantat'
LEFT JOIN order_details od ON o.id = od.fk_order_id
LEFT JOIN product_variant pv ON pv.id = od.fk_product_id
LEFT JOIN product p ON p.id = pv.fk_variant_product
LEFT JOIN category c ON c.name = p.fk_category
GROUP BY y.nam, c.name
ORDER BY y.nam, c.name
""", nativeQuery = true)
    List<CategorySalesProjection> getTypeProduct();

    @Query(value = """
    SELECT 
        CONCAT('Tháng ', m.thang) AS thoiGian,
        COALESCE(c.name, '') AS tenLoaiSanPham,            
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        (SELECT 1 AS thang UNION ALL 
         SELECT 2 UNION ALL 
         SELECT 3 UNION ALL 
         SELECT 4 UNION ALL 
         SELECT 5 UNION ALL 
         SELECT 6 UNION ALL 
         SELECT 7 UNION ALL 
         SELECT 8 UNION ALL 
         SELECT 9 UNION ALL 
         SELECT 10 UNION ALL 
         SELECT 11 UNION ALL 
         SELECT 12) m
    LEFT JOIN orders o ON MONTH(o.created_at) = m.thang 
        AND YEAR(o.created_at) = :year AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON pv.id = od.fk_product_id
    LEFT JOIN product p ON p.id = pv.fk_variant_product
    LEFT JOIN category c ON c.name = p.fk_category
    GROUP BY m.thang, c.name
    ORDER BY m.thang, c.name
    """, nativeQuery = true)
    List<CategorySalesProjection> getTypeProductByYear(@Param("year") int year);

    @Query(value = """
    SELECT 
        CONCAT('Tháng ', m.thang) AS thoiGian,
        COALESCE(c.name, '') AS tenLoaiSanPham,
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        (SELECT 1 AS thang UNION ALL
         SELECT 2 UNION ALL
         SELECT 3 UNION ALL
         SELECT 4 UNION ALL
         SELECT 5 UNION ALL
         SELECT 6 UNION ALL
         SELECT 7 UNION ALL
         SELECT 8 UNION ALL
         SELECT 9 UNION ALL
         SELECT 10 UNION ALL
         SELECT 11 UNION ALL
         SELECT 12) m
    LEFT JOIN orders o ON MONTH(o.created_at) = m.thang 
        AND YEAR(o.created_at) = :year AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON pv.id = od.fk_product_id
    LEFT JOIN product p ON p.id = pv.fk_variant_product
    LEFT JOIN category c ON c.name = p.fk_category
    WHERE 
        (m.thang BETWEEN 
            CASE 
                WHEN :quarter = 1 THEN 1
                WHEN :quarter = 2 THEN 4
                WHEN :quarter = 3 THEN 7
                WHEN :quarter = 4 THEN 10
            END
        AND 
            CASE 
                WHEN :quarter = 1 THEN 3
                WHEN :quarter = 2 THEN 6
                WHEN :quarter = 3 THEN 9
                WHEN :quarter = 4 THEN 12
            END)
    GROUP BY m.thang, c.name
    ORDER BY m.thang, c.name
    """, nativeQuery = true)
    List<CategorySalesProjection> getTypeProductByYearQuarter(@Param("year") int year, @Param("quarter") int quarter);


    @Query(value = """
    WITH RECURSIVE DateRange AS (
        SELECT DATE(CONCAT(:year, '-', :month, '-01')) AS date_value
        UNION ALL
        SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
        FROM DateRange
        WHERE date_value < LAST_DAY(DATE(CONCAT(:year, '-', :month, '-01')))
    )
    SELECT 
        CONCAT(DAY(d.date_value), '/', :month) AS thoiGian,
        COALESCE(c.name, '') AS tenLoaiSanPham,
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        DateRange d
    LEFT JOIN orders o ON DAY(o.created_at) = DAY(d.date_value) 
        AND YEAR(o.created_at) = :year
        AND MONTH(o.created_at) = :month
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON pv.id = od.fk_product_id
    LEFT JOIN product p ON p.id = pv.fk_variant_product
    LEFT JOIN category c ON c.name = p.fk_category
    GROUP BY d.date_value, c.name
    ORDER BY d.date_value, c.name
    """, nativeQuery = true)
    List<CategorySalesProjection> getTypeProductByYearMonth(@Param("year") int year, @Param("month") int month);

    @Query(value = """
    WITH RECURSIVE DateRange AS (
        SELECT DATE(CONCAT(:year, '-', :month, '-01')) AS date_value
        UNION ALL
        SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
        FROM DateRange
        WHERE date_value < LAST_DAY(DATE(CONCAT(:year, '-', :month, '-01')))
    )
    SELECT 
        CONCAT(DAY(d.date_value), '/', :month) AS thoiGian,
        COALESCE(c.name, '') AS tenLoaiSanPham,
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        DateRange d
    LEFT JOIN orders o ON DAY(o.created_at) = DAY(d.date_value) 
        AND YEAR(o.created_at) = :year
        AND MONTH(o.created_at) = :month
        AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON pv.id = od.fk_product_id
    LEFT JOIN product p ON p.id = pv.fk_variant_product
    LEFT JOIN category c ON c.name = p.fk_category
    WHERE 
        (
            (DAY(d.date_value) BETWEEN 1 AND 7 AND :week = 1) OR
            (DAY(d.date_value) BETWEEN 8 AND 14 AND :week = 2) OR
            (DAY(d.date_value) BETWEEN 15 AND 21 AND :week = 3) OR
            (DAY(d.date_value) BETWEEN 22 AND 28 AND :week = 4)
        )
    GROUP BY d.date_value, c.name
    ORDER BY d.date_value, c.name
    """, nativeQuery = true)
    List<CategorySalesProjection> getTypeProductByYearWeek(@Param("year") int year, @Param("month") int month, @Param("week") int week);


    @Query(value = """
    WITH RECURSIVE DateRange AS (
        SELECT DATE(:startDate) AS date_value
        UNION ALL
        SELECT DATE_ADD(date_value, INTERVAL 1 DAY)
        FROM DateRange
        WHERE date_value < DATE(:endDate)
    )
    SELECT 
        DATE_FORMAT(d.date_value, '%d-%m-%Y') AS thoiGian,
        COALESCE(c.name, '') AS tenLoaiSanPham,        
        COALESCE(SUM(od.quantity), 0) AS tongSanPham
    FROM 
        DateRange d
    LEFT JOIN orders o ON DATE(o.created_at) = d.date_value AND o.process = 'hoantat'
    LEFT JOIN order_details od ON o.id = od.fk_order_id
    LEFT JOIN product_variant pv ON pv.id = od.fk_product_id
    LEFT JOIN product p ON p.id = pv.fk_variant_product
    LEFT JOIN category c ON c.name = p.fk_category
    GROUP BY d.date_value, c.name
    ORDER BY d.date_value, c.name
    """, nativeQuery = true)
    List<CategorySalesProjection> getTypeProductByDayBetween(@Param("startDate") String startDate, @Param("endDate") String endDate);
}
