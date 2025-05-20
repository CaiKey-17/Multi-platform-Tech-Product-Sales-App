

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";



DELIMITER $$


CREATE PROCEDURE `AddMoreToCart` (IN `p_OrderId` VARCHAR(50), IN `p_ProductId` INT)   BEGIN

    DECLARE v_PriceProduct DOUBLE;
    DECLARE v_Quantity INT;
    DECLARE v_Price_Total DOUBLE;


    SELECT price INTO v_PriceProduct FROM order_details WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId;
    
    UPDATE order_details
    SET quantity = quantity + 1, total = total + v_PriceProduct
    WHERE fk_order_Id = p_OrderId AND fk_product_Id = p_ProductId;


    SELECT sum(quantity) INTO v_Quantity from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;
    
    SELECT sum(total) INTO v_Price_Total from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;

    

    UPDATE orders
        SET quantity_total = v_Quantity,price_total = v_Price_Total
        WHERE id = p_OrderId;


END$$

CREATE PROCEDURE `AddPointToCart` (IN `p_OrderId` INT)   BEGIN
    DECLARE v_GetVoucher DOUBLE;
    DECLARE v_CustomerID INT;

    
    SELECT id_fk_customer INTO v_CustomerID FROM orders WHERE id = p_OrderId;
        
    SELECT points INTO v_GetVoucher FROM customer WHERE id = v_CustomerID;

    UPDATE orders
    SET point_total = v_GetVoucher,total = (price_total+ship+tax)-(v_GetVoucher+coupon_total) 
    WHERE id = p_OrderId;



END$$

CREATE PROCEDURE `AddToCart` (IN `p_CustomerID` INT, IN `p_ProductId` INT,IN `p_ColorId` INT, IN `p_Quantity` INT)   BEGIN
    DECLARE id_Real INT;
    DECLARE v_OrderId VARCHAR(50);
    DECLARE v_OrderIdTemp VARCHAR(50);
    DECLARE v_PriceProduct DOUBLE;
    DECLARE v_Quantity INT;
    DECLARE v_Total_donhang DOUBLE;
    DECLARE v_Total DOUBLE;

    DECLARE v_TempID VARCHAR(100);
    DECLARE v_Stt INT;




    IF p_CustomerID = -1 THEN
        IF(SELECT COUNT(*) FROM users WHERE temp_id LIKE 'T%') = 0 THEN
            SET v_TempID = 'T1';
        ELSE
            SELECT temp_id INTO v_TempID 
            FROM users 
            WHERE temp_id LIKE 'T%' 
            ORDER BY CAST(SUBSTRING_INDEX(temp_id, 'T', -1) AS UNSIGNED) DESC 
            LIMIT 1;

            SET v_Stt = CAST(SUBSTRING_INDEX(v_TempID, 'T', -1) AS UNSIGNED) + 1;
            SET v_TempID = CONCAT('T', v_Stt);
        END IF;
        
        INSERT INTO users(temp_id) VALUES(v_TempID);
        SELECT id INTO id_Real FROM users WHERE temp_id = v_TempID ;
        INSERT INTO customer(id,points) VALUES(id_Real,0);
        SELECT id_Real as id,v_TempID as temp_id;
    ELSE
        SELECT id INTO id_Real FROM users WHERE id = p_CustomerID LIMIT 1;
        SELECT id_Real as id,-1 as temp_id;

    END IF;


    IF p_ColorId<0 THEN
        SELECT price INTO v_PriceProduct FROM product_variant WHERE id = p_ProductId;
    ELSE
        SELECT color_price INTO v_PriceProduct FROM product_variant v,product_color c WHERE v.id = p_ProductId  and v.id = c.fk_variant_product and c.id = p_ColorId;
    END IF;

    SELECT v_PriceProduct as Price;



    SET v_Total = p_Quantity * v_PriceProduct;
    
    IF (SELECT COUNT(*) FROM orders WHERE id_fk_customer = id_Real AND process = 'giohang') = 0 THEN
        SELECT id INTO v_OrderIdTemp FROM orders ORDER BY id DESC LIMIT 1;
        IF v_OrderIdTemp IS NULL THEN
            SET v_OrderId = 1;
        ELSE
            SET v_OrderId = v_OrderIdTemp + 1;
        END IF;

        INSERT INTO orders(id, quantity_total, price_total,process,coupon_total,point_total,ship,tax,id_fk_customer)
        VALUES (v_OrderId,p_Quantity,v_Total,'giohang',0,0,0,0,id_Real);

        IF p_ColorId>0 THEN
            INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id,fk_color_Id)
            VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId,p_ColorId);
        ELSE
            INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id)
            VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId);
        END IF;

    ELSE
        SELECT id INTO v_OrderId FROM orders WHERE id_fk_customer = id_Real AND process = 'giohang' LIMIT 1;
        IF p_ColorId>0 THEN
            IF (SELECT COUNT(*) FROM order_details WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id = p_ColorId) > 0 THEN
                UPDATE order_details
                SET quantity = quantity + p_Quantity, total = total + v_Total
                WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id = p_ColorId;
            ELSE
                INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id,fk_color_Id)
                VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId,p_ColorId);
            END IF;
        ELSE
            IF (SELECT COUNT(*) FROM order_details WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId) > 0 THEN
                UPDATE order_details
                SET quantity = quantity + p_Quantity, total = total + v_Total
                WHERE fk_order_Id = v_OrderId AND fk_product_Id = p_ProductId;
            ELSE
                INSERT INTO order_details(price, quantity, total, fk_order_Id, fk_product_Id)
                VALUES (v_PriceProduct, p_Quantity, v_Total, v_OrderId, p_ProductId);
            END IF;
        END IF;
        
           

        SELECT SUM(quantity) INTO v_Quantity FROM order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id;

        SELECT SUM(total) INTO v_Total_donhang FROM order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id;

        UPDATE orders
        SET quantity_total = v_Quantity, price_total = v_Total_donhang
        WHERE id = v_OrderId;
    END IF;

    

END$$

CREATE PROCEDURE `AddVoucherToCart` (IN `p_OrderId` INT, IN `p_VoucherId` INT)   BEGIN
    DECLARE v_GetVoucher DOUBLE;
    DECLARE v_Quantity INT;
        
    SELECT  max_allowed_uses INTO v_Quantity FROM coupons WHERE id = p_VoucherId;

    IF v_Quantity > 0 THEN
        SELECT coupon_value INTO v_GetVoucher FROM coupons WHERE id = p_VoucherId;

        UPDATE orders
        SET coupon_total = v_GetVoucher,fk_coupon_Id = p_VoucherId,total = (price_total+ship+tax)-(v_GetVoucher+point_total) 
        WHERE id = p_OrderId;
    
    END IF;



END$$

CREATE PROCEDURE `Cancel` (IN `p_OrderId` INT)   BEGIN

	DECLARE v_Process VARCHAR(255) ;
	DECLARE v_customerId int;
	DECLARE v_points int;
	DECLARE v_couponId int;

	SELECT process INTO v_Process FROM orders WHERE id = p_OrderId;

    IF v_Process = 'dangdat' THEN

        SELECT id_fk_customer INTO v_customerId FROM orders
        WHERE id = p_OrderId;

        SELECT fk_coupon_id INTO v_couponId FROM orders
        WHERE id = p_OrderId;

        SELECT point_total INTO v_points FROM orders
        WHERE id = p_OrderId;

        UPDATE coupons
        SET used_count = used_count - 1
        WHERE id = v_couponId;

       

        UPDATE customer
        SET points = points+ v_points/1000
        WHERE id = v_customerId;

        
       -- Tạo bảng tạm chứa số lượng cần cộng thêm theo product_variant.id
            UPDATE product_variant pv
            JOIN (
                SELECT od.fk_product_id AS id, SUM(od.quantity) AS quantity_to_add
                FROM order_details od
                WHERE od.fk_order_Id = p_OrderId AND od.fk_color_id IS NULL
                GROUP BY od.fk_product_id
            ) AS t ON pv.id = t.id
            SET pv.quantity = pv.quantity + t.quantity_to_add;

        
       UPDATE product_color pc
JOIN (
    SELECT od.fk_color_id AS id, SUM(od.quantity) AS quantity_to_add
    FROM order_details od
    WHERE od.fk_order_Id = p_OrderId AND od.fk_color_id IS NOT NULL
    GROUP BY od.fk_color_id
) AS t ON pc.id = t.id
SET pc.quantity = pc.quantity + t.quantity_to_add;

        
        

        UPDATE orders
        SET process  = 'dahuy'
        WHERE id = p_OrderId;



        SELECT v_points/1000 as points;

       
        

    
    END IF;
    
END$$

CREATE PROCEDURE `DeleteToCart` (IN `p_id` INT)   BEGIN
	DECLARE v_Quantity INT;
	DECLARE v_Total_Product DOUBLE;
    DECLARE v_OrderId INT;

    SELECT fk_order_Id INTO v_OrderId FROM order_details
    WHERE id = p_id;
   
   DELETE FROM order_details
   WHERE Id = p_id;
   
   
   	SELECT sum(quantity) INTO v_Quantity from order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id ;
  	SELECT sum(total) INTO v_Total_Product from order_details
        WHERE fk_order_Id = v_OrderId
        GROUP BY fk_order_Id ;

        

 	UPDATE orders
            SET quantity_total = v_Quantity,price_total = v_Total_Product
            WHERE id = v_OrderId;
    

END$$

CREATE PROCEDURE `MinusToCart` (IN `p_OrderId` VARCHAR(50), IN `p_ProductId` INT, IN `p_ColorId` INT)   BEGIN

    DECLARE v_PriceProduct DOUBLE;
    DECLARE v_Quantity INT;
    DECLARE v_Quantity_check INT;
    DECLARE v_Price_Total DOUBLE;




    IF p_ColorId != -1 THEN
        SELECT price INTO v_PriceProduct FROM order_details  WHERE fk_order_Id = p_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id = p_ColorId AND fk_color_Id IS NOT NULL;

       UPDATE order_details
        SET quantity = quantity - 1, total = total - v_PriceProduct
        WHERE fk_order_Id = p_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id = p_ColorId AND fk_color_Id IS NOT NULL;
    ELSE
        SELECT price INTO v_PriceProduct FROM order_details  WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId AND fk_color_Id IS NULL;



        UPDATE order_details
        SET quantity = quantity - 1, total = total - v_PriceProduct
        WHERE fk_order_Id = p_OrderId AND fk_product_Id = p_ProductId AND fk_color_Id IS NULL;

        SELECT quantity INTO v_Quantity_check FROM order_details WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId  AND fk_color_Id IS NULL;

    END IF;





    IF v_Quantity_check = 0 THEN
        DELETE FROM order_details WHERE fk_order_Id = p_OrderId and fk_product_Id = p_ProductId;
    END IF;



    SELECT sum(quantity) INTO v_Quantity from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;
    
    SELECT sum(total) INTO v_Price_Total from order_details
    WHERE fk_order_Id = p_OrderId
    GROUP BY fk_order_Id ;

    

    UPDATE orders
        SET quantity_total = v_Quantity,price_total = v_Price_Total
        WHERE id = p_OrderId;
END$$





    DELIMITER ;;
    CREATE PROCEDURE `Confirm`(
        IN p_OrderId INT,
        IN p_Address VARCHAR(255) CHARACTER Set utf8,
        IN p_CouponTotal DOUBLE,
        IN p_Email VARCHAR(255),
        IN p_FkCouponId INT,
        IN p_PointTotal DOUBLE,
        IN p_PriceTotal DOUBLE,
        IN p_Ship DOUBLE
    )
    BEGIN
        
        DECLARE v_Tax DOUBLE;    
        DECLARE v_Total DOUBLE;    
        DECLARE v_customerId INT;    
        SET v_Tax = p_PriceTotal* 0.02;
        SET v_Total = (p_PriceTotal+ v_Tax + p_Ship) - p_CouponTotal - p_PointTotal ;
        
        SELECT id_fk_customer INTO v_customerId FROM orders WHERE id = p_OrderId;

        
   UPDATE product_variant pv
JOIN (
    SELECT od.fk_product_id, SUM(od.quantity) AS total_quantity
    FROM order_details od
    WHERE od.fk_order_id = p_OrderId AND od.fk_color_id IS NULL
    GROUP BY od.fk_product_id
) AS sub ON pv.id = sub.fk_product_id
SET pv.quantity = pv.quantity - sub.total_quantity;

        
      UPDATE product_color pc
JOIN (
    SELECT od.fk_color_id, SUM(od.quantity) AS total_quantity
    FROM order_details od
    WHERE od.fk_order_id = p_OrderId AND od.fk_color_id IS NOT NULL
    GROUP BY od.fk_color_id
) AS sub ON pc.id = sub.fk_color_id
SET pc.quantity = pc.quantity - sub.total_quantity;

        
        IF p_FkCouponId != -1 THEN
            UPDATE coupons
            SET used_count = used_count +1
            WHERE id = p_FkCouponId;
        END IF;
        
        IF p_PointTotal != 0 THEN
            UPDATE customer
            SET points = 0
            WHERE id = v_customerId;
        END IF;
        
        
    
        UPDATE orders
        SET 
        total = v_Total,
        process = 'dangdat',
        created_at = NOW(),
        coupon_total = p_CouponTotal,
        address = p_Address,
        email = p_Email,
        fk_coupon_id = p_FkCouponId,
        point_total = p_PointTotal,
        ship = p_Ship,
        tax = v_Tax
        WHERE id = p_OrderId;
                
            INSERT INTO bills (created_at, fk_order_id, method_payment,status_order) VALUES (NOW(),p_OrderId, 'tienmat','chuathanhtoan');

        
    END ;;
    DELIMITER ;
    


ALTER TABLE product_variant
DROP COLUMN price;





ALTER TABLE product_variant
ADD COLUMN price Double AS (original_price - original_price * (discount_percent / 100.0)) STORED;





INSERT INTO `users` (`id`, `active`, `email`, `full_name`, `password`, `temp_id`, `created_at`, `reset_token`, `image`) VALUES
(131, 1, 'ncaoky69@gmail.com', 'CaiKey-1724', '$2a$10$yROnPfnDl6A7neAQbCjX0e/ypSLYq8iEbk2t3u2gWvPWceRxramnq', NULL, '2025-04-01 16:06:09.295000', NULL, 'https://yt3.googleusercontent.com/c-Z7mIlntSpG6VyQ5ZqaPggqkZRhaySr-H5ZEazFN2iR1pP4eD1UGekwu0y--c4CSVhJJ1A4QT8=s900-c-k-c0x00ffffff-no-rj'),
(139, 1, 'caoky.sonhaa@gmail.com', 'T1p8mczf', '$2a$10$9zyU/97fcyZiAITVCK0QAeX87UOm1mN5qyzzH7LRSMl1A3o7VxMC6', NULL, '2025-04-02 16:41:23.845000', NULL, 'https://media-cdn-v2.laodong.vn/storage/newsportal/2024/8/18/1381365/G-Dragon-Instagram-1-01.jpg'),
(140, 0, NULL, NULL, NULL, 'T1', NULL, NULL, NULL),
(141, 1, 'ck@gmail.com', 'rLHRcSzi', '$2a$10$9TB8WwfFLalXVtrTAUCTp.plEd8OA2PSlqJV9ZReH4jIbPiXtQnle', NULL, '2025-05-01 16:16:54.653000', NULL, NULL),
(142, NULL, NULL, NULL, NULL, 'T2', NULL, NULL, NULL),
(143, 1, 'caoky.sonha@gmail.com', 'Mai Văn Mạnh', '$2a$10$vuYXmOiH21ImmikE0eueduKO.6lD6YSFExe8ckbb2nPYG3mWJXR8a', NULL, '2025-05-01 16:17:02.561000', NULL, 'https://standboothvietnam.com/wp-content/uploads/2023/08/dt1-1.jpg'),
(144, 1, 'aca@gmail.com', 'Iy4NjGOK', '$2a$10$9zyU/97fcyZiAITVCK0QAeX87UOm1mN5qyzzH7LRSMl1A3o7VxMC6', NULL, '2025-05-04 11:41:10.162000', NULL, 'https://images2.thanhnien.vn/zoom/686_429/528068263637045248/2025/1/20/jack-1737333866175616770624-0-0-1600-2560-crop-1737334264735386598332.jpeg'),
(145, NULL, NULL, NULL, NULL, 'T3', NULL, NULL, NULL),
(146, NULL, NULL, NULL, NULL, 'T4', NULL, NULL, NULL),
(147, NULL, NULL, NULL, NULL, 'T5', NULL, NULL, NULL),
(148, 0, 'ca@gmail.com', 'jEhlxKy4', '$2a$10$9zyU/97fcyZiAITVCK0QAeX87UOm1mN5qyzzH7LRSMl1A3o7VxMC6', NULL, '2025-05-11 23:42:19.765000', NULL, NULL),
(149, NULL, NULL, NULL, NULL, 'T6', NULL, NULL, NULL);

INSERT INTO `user_roles` (`user_id`, `role_id`) VALUES
(143, 1),
(131, 2),
(139, 2),
(141, 2),
(144, 2),
(148, 2);


INSERT INTO `customer` (`id`, `points`) VALUES
(131, 24121),
(139, 0),
(140, 0),
(141, 0),
(142, 0),
(144, 0),
(145, 0),
(146, 0),
(147, 0),
(148, 253),
(149, 0);



INSERT INTO `address` (`id`, `address`, `user_id`, `codes`, `status`) VALUES
(98, 'bac, Xã Phan Sào Nam, Huyện Phù Cừ, Hưng Yên', 138, '220709,2194,268', 1),
(99, 'asda, Xã Khánh Tiến, Huyện U Minh, Cà Mau', 139, '610307,2042,252', 0),
(100, 'asd, Xã Tiên Nha, Huyện Lục Nam, Bắc Giang', 139, '180522,1965,248', 1),
(101, 'a, Xã Ngối Cáy, Huyện Mường Ảng, Điện Biên', 141, '620909,2170,265', 1),
(102, 'asd, Xã Pha Long, Huyện Mường Khương, Lào Cai', 131, '80911,2171,269', 1),
(103, 'b, Xã Vạn Mai, Huyện Mai Châu, Hòa Bình', 131, '230323,2163,267', 0),
(104, ', Xã Nậm Sài, Thị xã Sa Pa, Lào Cai', 143, '80508,2005,269', 0),
(105, 'aca, Xã Suối Giàng, Huyện Văn Chấn, Yên Bái', 144, '130625,2044,263', 0),
(106, 'aaca, Xã Viễn Sơn, Huyện Văn Yên, Yên Bái', 144, '130321,2047,263', 1),
(107, 'abc, Phường Tam Bình, Quận Thủ Đức, Hồ Chí Minh', 131, '21810,1463,202', 0),
(108, 'bbb, Xã Nặm Lịch, Huyện Mường Ảng, Điện Biên', 148, '620908,2170,265', 0),
(109, 'a, Xã Tà Si Láng, Huyện Trạm Tấu, Yên Bái', 148, '130809,2248,263', 1);



INSERT INTO `brand` (`name`, `images`) VALUES
('Acer', 'https://res.cloudinary.com/dwskd7iqr/image/upload/v1746407395/ylwr2iwvi44t1ntuijx2.jpg'),
('Apple', 'https://cdn-icons-png.flaticon.com/512/882/882704.png'),
('Asus', 'https://cdn-icons-png.flaticon.com/512/5969/5969002.png'),
('Dell', 'https://cdn-icons-png.flaticon.com/512/882/882828.png'),
('Lenovo', 'https://cdn-icons-png.flaticon.com/512/16183/16183609.png'),
('LG', 'https://cdn-icons-png.flaticon.com/512/882/882722.png'),
('MSI', 'https://cdn-icons-png.flaticon.com/512/5969/5969287.png'),
('Nokia', 'https://res.cloudinary.com/dwskd7iqr/image/upload/v1746871675/ftzenmqxeppgesftn7gr.jpg'),
('Samsung', 'https://cdn-icons-png.flaticon.com/128/882/882747.png'),
('Sony', 'https://cdn-icons-png.flaticon.com/512/5969/5969287.png'),
('Xiaomi', 'https://cdn-icons-png.flaticon.com/128/882/882720.png');


INSERT INTO `category` (`name`, `images`) VALUES
('Bàn phím', 'https://media1.giphy.com/media/l378gaCswFD95pfO0/200.webp?cid=ecf05e47694p0ojipbw2ev3xuba6jpsfdglzba818ikwi8tx&ep=v1_gifs_related&rid=200.webp&ct=g'),
('Bộ nguồn', 'https://i.giphy.com/3e5kkipMoPVMAhKxmC.webp'),
('Card đồ họa', 'https://i.giphy.com/IpPMIk2IGJDuaB4sL9.webp'),
('Chuột', 'https://media4.giphy.com/media/hJix08Z6fEagxUveWw/200.webp?cid=ecf05e47n8erd8y2vfvzu2fqoswoq2axt2yjokqyzps12im7&ep=v1_gifs_related&rid=200.webp&ct=g'),
('Điện thoại', 'https://i.giphy.com/gnBzgeEwVlbwI.webp'),
('Laptop', 'https://media1.giphy.com/media/VDLOcxG69cLBBXH6nw/200.webp?cid=ecf05e47gza74v76k8ztl4jqgmkrccwe1bfc868gblu0elb3&ep=v1_gifs_related&rid=200.webp&ct=g'),
('Linh kiện máy tính', 'https://media2.giphy.com/media/H41U6NbkdhwEPuQLpj/200.webp?cid=ecf05e47694p0ojipbw2ev3xuba6jpsfdglzba818ikwi8tx&ep=v1_gifs_related&rid=200.webp&ct=g'),
('Màn hình', 'https://media0.giphy.com/media/oNXO7sbPQivmrBgPKq/200.webp?cid=ecf05e47694p0ojipbw2ev3xuba6jpsfdglzba818ikwi8tx&ep=v1_gifs_related&rid=200.webp&ct=g'),
('Ổ cứng', 'https://i.giphy.com/VkyLajGO9Kfo4dlHZs.webp'),
('PC - Máy tính bàn', 'https://i.giphy.com/18LKVvlCoDsvmK5pXv.webp'),
('Tai nghe', 'https://i.giphy.com/5XEN23wvm20XGkiXP9.webp');

INSERT INTO `coupons` (`id`, `coupon_value`, `created_at`, `max_allowed_uses`, `name`, `used_count`, `min_order_value`) VALUES
(1, 10000, '2025-02-26 10:05:36', 10, 'A1B2C', 9, 16000),
(2, 20000, '2025-02-26 10:05:36', 10, 'D3E4F', 0, 80000),
(3, 50000, '2025-02-26 10:05:36', 10, 'G5H6I', 0, 300000),
(4, 100000, '2025-02-26 10:05:36', 10, 'J7K8L', 0, 750000),
(5, 10000, '2025-02-26 10:05:36', 10, 'M9N0O', 0, 70000),
(9, 50000, '2025-05-07 14:53:19', 1, 'NFjKU', 0, 2131231),
(10, 50000, '2025-05-07 14:53:40', 1, 'As7p8', 0, 231231231),
(11, 20000, '2025-05-07 14:55:32', 2, 'KaKAZ', 0, 212121),
(12, 20000, '2025-05-07 14:58:00', 2, '1Igks', 0, 1111111),
(14, 20000, '2025-05-11 23:53:36', 9, 'ZbgmZ', 0, 200000);


INSERT INTO `product` (`id`, `created_at`, `fk_brand`, `fk_category`, `name`, `short_description`, `has_color`, `main_image`, `detail`) VALUES
(30, '2025-05-12 13:42:32', 'Apple', 'Điện thoại', 'iPhone 16 Pro Max', 'iPhone 16 Pro Max 512GB là điện thoại cao cấp nhất của 2024 với cấu hình vượt trội. Đặc biệt với dung lượng bộ nhớ mở rộng tối ưu cho khả năng lưu trữ.', 1, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max_1.png', NULL),
(32, '2025-05-12 13:44:41', 'Apple', 'Laptop', 'MacBook Pro 14 M4', 'MacBook Pro 14 inch M4 16GB 512GB mang nguồn sức mạnh ấn tượng với con chip M4 10 lõi, GPU 10 lõi Neural Engine 16 lõi khai phá tiềm năng AI kinh ngạc, nâng cấp hiệu năng vượt trội. MacBook sở hữu RAM 16GB mạnh mẽ với tốc độ băng thông 120GB/s cho mọi thao tác trơn tru và được xử lý tốc độ. Bộ nhớ 512GB với loại ổ cứng SSD đem đến không gian lưu trữ lớn cùng khả năng truy xuất dữ liệu tốc độ cao đồng thời bảo vệ dữ liệu an toàn.', 1, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_1__6_135.png', NULL),
(33, '2025-05-12 13:46:23', 'Asus', 'Laptop', 'Laptop ASUS TUF Gaming A15 FA506NCR-HN047W', 'Laptop Asus TUF Gaming A15 FA506NCR HN047W sử dụng bộ xử lý AMD Ryzen 7 7435HS Mobile Processor 3.1GHz kết hợp card đồ họa NVIDIA GeForce RTX 3050 mạnh mẽ. ', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_d_i_5_9.png', NULL),
(34, '2025-05-12 13:47:43', 'Apple', 'Tai nghe', 'Tai nghe Bluetooth Apple AirPods', 'Apple AirPods 4 là tai nghe không dây với chip H2 cùng EQ thích ứng và âm thanh không gian cá nhân hóa mang lại trải nghiệm âm thanh ấn tượng. Tai nghe được trang bị Micrô kép với cảm biến quang học cùng micro hướng vào trong giúp thu âm tốt hơn. ', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/a/i/airpods-4-2.png', NULL),
(35, '2025-05-12 13:49:00', 'Xiaomi', 'Điện thoại', 'Xiaomi 14T', 'Xiaomi 14T 5G là phiên bản điện thoại cận cao cấp được Xiaomi trang bị chip Dimensity 8300 Ultra cùng 12GB RAM để mang tới hiệu suất ấn tượng. ', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_14t_2_.png', NULL),
(36, '2025-05-12 13:50:22', 'Sony', 'Màn hình', 'Google Tivi Sony 4K', 'Google Tivi Sony K-43S30 4K 43 inch sở hữu màn hình LED 43 inch độ phân giải 4K, tích hợp công nghệ Triluminos Pro, X-Reality PRO, Motionflow XR 200. ', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/o/google-tivi-sony-k-43s30-4k-43-inch_5_.png', NULL),
(37, '2025-05-12 13:51:31', 'Samsung', 'Màn hình', 'Smart Tivi Samsung QLED 4K', 'Smart Tivi Samsung QLED 55Q60D 4K 55 inch 2024 sử dụng công nghệ hình ảnh Quantum Dot hiển thị 100% dải màu, kết hợp QuantumProcessor Lite 4K. Cộng thêm chế độ ALLM cải thiện độ trễ đầu vào đáng kể.', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/m/smart_tivi_qned_lg_4k_65_inch_65qned86sra_36_.png', NULL),
(38, '2025-05-12 13:53:22', 'Samsung', 'Bàn phím', 'Bàn phím cơ E-DRA không dây EK368L Alpha', 'Bàn phím cơ không dây E-DRA EK368L Alpha sở hữu kích thước 311 x 101 x 42 mm, trọng lượng khoảng 557g, layout 68 phím với bộ Switch Huano cho độ bền cao. ', 1, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-phim-co-khong-day-e-dra-ek368l-alpha_1_.png', NULL),
(39, '2025-05-12 13:54:13', 'Xiaomi', 'Bàn phím', 'Bàn phím cơ không dây AULA', 'Bàn phím cơ không dây Aula F75 Đen có 80 phím với chất liệu keycap nhựa PBT, dùng loại switch Grey Wood V3 Switch cho độ bền tới 60 triệu lần bấm.', 1, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/a/gaming_8_1__1.png', NULL),
(40, '2025-05-12 13:55:24', 'Asus', 'PC - Máy tính bàn', 'PC CPS X ASUS Gaming', 'PC CPS ASUS Gaming Intel i3 Gen 12 được trang bị vi xử lý Intel Core i3-12100F, đi kèm là Mainboard ASUS PRIME H610M-K D4, giúp máy hoạt động ổn định.', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/r/group_786.png', NULL),
(41, '2025-05-12 13:56:15', 'Samsung', 'PC - Máy tính bàn', 'PC CPS văn phòng', 'Máy tính PC CPS văn phòng Intel I3 Gen 14 là lựa chọn lý tưởng cho công việc văn phòng và học tập với cấu hình mạnh mẽ Intel I3-14100, RAM 8GB và SSD 256GB. Với màn hình Dahua 22 inch 100Hz đi kèm', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/p/c/pc-cps-van-phong-s4-spa_2.png', NULL),
(42, '2025-05-12 13:58:08', 'MSI', 'Chuột', 'Chuột không dây Logitech MX Master', 'aLogitech MX Master 2S là một trong những thương hiệu chuột không dây nổi tiếng được nhiều người dùng lựa chọn tin dùng với đẩy đủ các tính năng được trang bị giúp độ nhạy ', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/c/h/chuot-khong-day-logitech-mx-master-2s_3_.png', NULL),
(43, '2025-05-12 13:58:57', 'Apple', 'Chuột', 'Bàn di chuột Apple Magic Trackpad', 'Với thiết kế tinh tế và công nghệ đột phá, bàn di chuột Apple Magic Trackpad 2024 không chỉ là một phụ kiện mà còn là biểu tượng của sự hiện đại và đẳng cấp.', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-di-chuot-apple-magic-trackpad-2024_2__3.png', NULL),
(44, '2025-05-12 14:00:48', 'Lenovo', 'Ổ cứng', 'Ổ cứng di động SSD ADATA SC750 USB 3.2 Gen 2', 'Ổ cứng di động SSD ADATA SC750 USB 3.2 Gen 2 1050MB/s 1TB có tốc độ truyền tải dữ liệu siêu tốc lên đến 1050MB/s. Cùng với dung lượng 1TB thoải mái lưu trữ mọi ', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/r/group_301_1__1_3.png', NULL),
(45, '2025-05-12 14:01:28', 'Asus', 'Ổ cứng', 'Ổ cứng di động Sandisk E61 Extreme V2 SSD', 'Ổ cứng di động Sandisk E61 Extreme V2 SSD 1TB USB 3.2 inch có được tốc độ truyền dữ liệu rất nhanh, và lưu trữ các tập tin khá an toàn. Đặc biệt mẫu ổ cứng di động này còn đạt tiêu chuẩn chống nước IP55, đem lại sự yên tâm trong quá trình sử dụng.', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/e/x/extreme-usb-3-2-ssd-front.png.wd_1.png', NULL),
(46, '2025-05-12 14:02:43', 'Lenovo', 'Linh kiện máy tính', 'Phụ kiện gắn máy quay GoPro Folding Fingers', 'Phụ kiện chốt gắn cho phép bạn gắn chiếc Gopro của mình vào giá đỡ, dễ dàng hoán đổi giá đỡ nếu muốn. Thiết bị có thiết kế đơn giản, chắc chắn, độ chính xác chi tiết cao ăn khít với Gopro.', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/p/h/phu-kien-gan-may-quay-gopro-folding-fingers.jpeg', NULL),
(47, '2025-05-12 14:03:26', 'Samsung', 'Linh kiện máy tính', 'Ốp lưng linh hoạt Samsung Galaxy Z Fold5 chính hãng', 'Ốp lưng Samsung Galaxy Z Fold 5 linh hoạt có thiết kế và tính năng ấn tượng, bạn có thể sử dụng để bảo vệ điện thoại tốt hơn, hạn chế bị hỏng khi bị va đập ngoài ý muốn.', 0, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/h/thumb-op-lung_4__1.png', NULL);


INSERT INTO `product_color` (`id`, `color_name`, `color_price`, `fk_variant_product`, `quantity`, `image`) VALUES
(12, 'Titan sa mạc', 31741500, 21, 99, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-sa-mac.png'),
(13, 'Titan trắng', 31940500, 21, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-trang.png'),
(14, 'Titan trắng', 32396000, 22, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-trang.png'),
(15, 'Titan đen', 32396000, 22, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/i/p/iphone-16-pro-max-titan-den.png'),
(16, 'Bạc', 38353900, 24, 95, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/t/e/text_ng_n_8__4_172.png'),
(17, 'Đen', 38353900, 24, 99, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/t/e/text_ng_n_9__4_183.png'),
(18, 'Đen', 40255000, 25, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/t/e/text_ng_n_9__4_183.png'),
(19, 'Bạc', 40255000, 25, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/t/e/text_ng_n_8__4_172.png'),
(20, 'Blue Switch', 582000, 39, 100, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:358:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-phim-co-e-dra-khong-day-ek368l-bk-blue-switch_1_.png'),
(21, 'Brown Switch', 550000, 38, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/b/a/ban-phim-co-e-dra-khong-day-ek368l-alpha-brown-switch_2__1.png'),
(22, 'Grey Wood', 1045000, 40, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/b/a/ban-phim-co-khong-day-aula-f75-r.png'),
(23, 'Reaper Switch', 1045000, 40, 100, 'https://cdn2.cellphones.com.vn/358x/media/catalog/product/b/a/ban-phim-co-khong-day-aula-f75-reaper-switch_1.png');


INSERT INTO `product_image` (`id`, `fk_image_product`, `image`) VALUES
(28, 30, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max-3.png'),
(29, 30, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max-4.png'),
(30, 30, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max-6.png'),
(31, 30, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max-7.png'),
(32, 30, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max-8.png'),
(33, 30, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/i/p/iphone-16-pro-max-10.png'),
(34, 32, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_pro_14_inch_m4_chip_silver_pdp_image_position_2_vn_vi.jpg'),
(35, 32, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_pro_14_inch_m4_chip_silver_pdp_image_position_4_vn_vi.jpg'),
(36, 32, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/m/a/macbook_pro_14_inch_m4_chip_silver_pdp_image_position_7_vn_vi.jpg'),
(37, 33, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_97__1_5.png'),
(38, 33, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_96__1_7.png'),
(39, 33, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_100__2_5.png'),
(40, 33, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_35__3_25.png'),
(41, 33, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_34__3_28.png'),
(42, 34, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/a/i/airpods-4-1.png'),
(43, 34, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/a/i/airpods-4-3-3.png'),
(44, 35, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_14t_12gb_512gb_-_3.png'),
(45, 35, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_14t_12gb_512gb_-_2.png'),
(46, 35, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_14t_12gb_512gb_-_5.png'),
(47, 35, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_14t_16_.png'),
(48, 35, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/x/i/xiaomi_14t_9_.png'),
(49, 36, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/o/google-tivi-sony-k-43s30-4k-43-inch.1.png'),
(50, 36, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/o/google-tivi-sony-k-43s30-4k-43-inch_1_.png'),
(51, 36, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/o/google-tivi-sony-k-43s30-4k-43-inch_3_.png'),
(52, 36, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/g/o/google-tivi-sony-k-43s30-4k-43-inch_4_.png'),
(53, 37, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/m/smart_tivi_samsung_qled_4k_55_inch_2024_55q60d_-_1.png'),
(54, 37, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/m/smart_tivi_samsung_qled_4k_55_inch_2024_55q60d_-_2.png'),
(55, 37, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/m/smart-tivi-samsung-qled-85q80d-4k-85-inch-2024_13__1_1.png'),
(56, 37, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/s/m/smart-tivi-samsung-qled-85q80d-4k-85-inch-2024_15__1_1.png'),
(57, 38, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-phim-co-khong-day-e-dra-ek368l-alpha_4_.png'),
(58, 38, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-phim-co-khong-day-e-dra-ek368l-alpha_3_.png'),
(59, 39, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/f/r/frame_379_1_.png'),
(60, 39, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/f/r/frame_379_3_.png'),
(61, 39, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/f/r/frame_379_4_.png'),
(62, 39, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/f/r/frame_379_5_.png'),
(63, 39, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/f/r/frame_379_11_.png'),
(64, 40, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/1/6/16_2_118.png'),
(65, 40, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_11__5_44_1.png'),
(66, 41, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_13__7_7.png'),
(67, 41, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_8__4_87_1_2.png'),
(68, 41, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_9__4_90_1_2.png'),
(69, 42, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/c/h/chuot-khong-day-logitech-mx-master-2s_1__1.png'),
(70, 42, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/c/h/chuot-khong-day-logitech-mx-master-2s_1_.png'),
(71, 42, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/c/h/chuot-khong-day-logitech-mx-master-2s_2_.png'),
(72, 42, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/c/h/chuot-khong-day-logitech-mx-master-2s_7_.png'),
(73, 43, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-di-chuot-apple-magic-trackpad-2024_6__2.png'),
(74, 43, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/b/a/ban-di-chuot-apple-magic-trackpad-2024_5__2.png'),
(75, 44, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_1__6_106.png'),
(76, 44, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_2__6_117.png'),
(77, 44, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_3__5_109.png'),
(78, 44, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/t/e/text_ng_n_6__2_140.png'),
(79, 45, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/e/x/extreme-usb-3-2-ssd-front-angle_1.png'),
(80, 45, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/e/x/extreme-usb-3-2-ssd-front-flat.p_2__1.png'),
(81, 45, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/e/x/extreme-usb-3-2-ssd-kolsch-6.jpg_1.png'),
(82, 46, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/p/h/phu-kien-gan-camera-mu-bao-hiem-gopro-3.jpeg'),
(83, 46, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/p/h/phu-kien-gan-camera-mu-bao-hiem-gopro-2.jpeg'),
(84, 47, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/o/p/op-lung-linh-hoat-galaxy-z-fold-5-1.png'),
(85, 47, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/o/p/op-lung-linh-hoat-galaxy-z-fold-5-2.png'),
(86, 47, 'https://cdn2.cellphones.com.vn/insecure/rs:fill:0:358/q:90/plain/https://cellphones.com.vn/media/catalog/product/o/p/op-lung-linh-hoat-galaxy-z-fold-5-7.png');


INSERT INTO `product_variant` (`id`, `fk_variant_product`, `name_variant`, `quantity`, `discount_percent`, `import_price`, `original_price`) VALUES
(21, 30, 'iPhone 16 Pro Max 256GB', 100, 15, 27000000, 34990000),
(22, 30, 'iPhone 16 Pro Max 512GB', 100, 15, 29000000, 37290000),
(23, 30, 'iPhone 16 Pro Max 1TB', 100, 10, 31000000, 43500000),
(24, 32, 'MacBook Pro 14 M4 10GPU 16GB 512GB', 100, 3, 31000000, 39540000),
(25, 32, 'MacBook Pro 14 M4 10GPU 24GB 512GB', 100, 3, 32500000, 41500000),
(26, 33, 'Laptop ASUS TUF Gaming A15 R7-7435HS/16GB/512GB PCIE/VGA 4GB RTX3050', 100, 10, 13000000, 17490000),
(27, 33, 'Laptop ASUS TUF Gaming A15 R7-7435HS/16GB/512GB PCIE/VGA 4GB RTX2050', 100, 10, 12500000, 16450000),
(28, 34, 'AirPods 4', 100, 0, 2100000, 3050000),
(29, 34, 'AirPods 2', 100, 0, 2000000, 2990000),
(30, 34, 'AirPods 3 MagSafe', 100, 0, 2050000, 2820000),
(31, 35, 'Xiaomi 14T 12GB 512GB', 100, 20, 8500000, 14900000),
(32, 35, 'Xiaomi 14T Pro 12GB 512GB', 99, 17, 9200000, 18900000),
(33, 36, 'Google Tivi Sony 4K 43 inch (K-43S30)', 100, 10, 8000000, 13500000),
(34, 36, 'Google Tivi Sony 4K 75 inch (K-75S30)', 100, 10, 17000000, 26200000),
(35, 37, 'Smart Tivi Samsung QLED 4K 55 inch 2024 (55Q60D)', 100, 5, 7750000, 13450000),
(36, 37, 'Smart Tivi Samsung QLED 4K 50 inch 2024 (50Q60D)\n', 100, 5, 6200000, 12450000),
(37, 37, 'Smart Tivi Samsung QLED 4K 75 inch 2024 (75Q60D)', 100, 10, 15000000, 26220000),
(38, 38, 'Bàn phím cơ E-DRA không dây EK368L Alpha Trắng Xám', 100, 0, 250000, 550000),
(39, 38, 'Bàn phím cơ E-DRA không dây EK368L Alpha Đen Trắng', 100, 0, 240000, 572000),
(40, 39, 'Bàn phím cơ không dây AULA Ice Green', 100, 5, 550000, 1100000),
(41, 39, 'Bàn phím cơ không dây AULA Glacier Blue', 100, 5, 550000, 1200000),
(42, 40, 'PC CPS X ASUS Gaming Intel i3', 98, 17, 7500000, 17500000),
(43, 40, 'PC CPS X ASUS Gaming Intel i7', 100, 17, 8000000, 20500000),
(44, 41, 'PC CPS văn phòng AMD R3 3200G', 100, 15, 4450000, 8500000),
(45, 41, 'PC CPS văn phòng AMD R7 3200G', 100, 15, 4720000, 9500000),
(46, 42, 'Chuột không dây Logitech MX Master Master 2S', 100, 5, 650000, 1200000),
(47, 42, 'Chuột không dây Logitech MX Master Master 3S', 100, 5, 700000, 1350000),
(48, 43, 'Trackpad 2024', 100, 10, 1590000, 3150000),
(49, 43, 'Trackpad 2022', 100, 10, 1050000, 2750000),
(50, 44, 'Ổ cứng di động SSD ADATA SC750 USB 3.2 Gen 2 1050MB/s 500GB', 99, 5, 850000, 1540000),
(51, 44, 'Ổ cứng di động SSD ADATA SC750 USB 3.2 Gen 2 1050MB/s 2TB', 100, 5, 3020000, 4150000),
(52, 45, 'Ổ cứng di động Sandisk E61 Extreme V2 SSD 1TB USB 3.2', 99, 5, 2230000, 2990000),
(53, 45, 'Ổ cứng di động Sandisk E61 Extreme V2 SSD 2TB USB 3.2', 100, 5, 2530000, 3150000),
(54, 46, 'Phụ kiện gắn máy quay GoPro Folding Fingers - Chống rung', 99, 0, 150000, 550000),
(55, 46, 'Phụ kiện gắn máy quay GoPro Folding Fingers - Cảm biến', 100, 0, 152000, 560000),
(56, 47, 'Ốp lưng linh hoạt Samsung Galaxy Z Fold5 chính hãng - Cứng nhựa', 99, 0, 20000, 75000),
(57, 47, 'Ốp lưng linh hoạt Samsung Galaxy Z Fold5 chính hãng - Dẻo mềm', 100, 0, 15000, 50000);




INSERT INTO `orders` (`id`, `address`, `coupon_total`, `created_at`, `email`, `fk_coupon_id`, `id_fk_customer`, `point_total`, `price_total`, `process`, `quantity_total`, `ship`, `tax`, `total`, `id_fk_product_variant`) VALUES
(1, 'abc, Phường Tam Bình, Quận Thủ Đức, Hồ Chí Minh', 0, '2025-05-02 15:49:29.000000', 'ncaoky69@gmail.com', -1, 131, 0, 31741500, 'hoantat', 1, 0, 634830, 32376330, 21),
(2, 'abc, Phường Tam Bình, Quận Thủ Đức, Hồ Chí Minh', 0, '2025-05-07 15:49:48.000000', 'ncaoky69@gmail.com', -1, 131, 0, 15687000, 'hoantat', 1, 0, 313740, 16000740, 32),
(3, 'abc, Phường Tam Bình, Quận Thủ Đức, Hồ Chí Minh', 0, '2025-04-17 15:52:59.000000', 'ncaoky69@gmail.com', -1, 131, 0, 29675000, 'hoantat', 4, 0, 593500, 30268500, 42),
(4, 'abc, Phường Tam Bình, Quận Thủ Đức, Hồ Chí Minh', 0, '2025-01-08 15:53:28.000000', 'ncaoky69@gmail.com', -1, 131, 0, 4303500, 'hoantat', 2, 0, 86070, 4389570, 52),
(5, 'asd, Xã Pha Long, Huyện Mường Khương, Lào Cai', 0, '2025-02-03 15:53:49.000000', 'ncaoky69@gmail.com', -1, 131, 0, 2835000, 'dahuy', 1, 20500, 56700, 2912200, 48),
(6, 'asd, Xã Pha Long, Huyện Mường Khương, Lào Cai', 0, '2024-09-12 15:54:10.000000', 'ncaoky69@gmail.com', -1, 131, 5054000, 191769500, 'hoantat', 5, 20500, 3835390, 190571390, 24),
(7, NULL, 0, NULL, NULL, NULL, 131, 0, 14525000, 'giohang', 1, 0, 0, 0, 42);



INSERT INTO `order_details` (`id`, `fk_color_id`, `fk_order_id`, `fk_product_id`, `price`, `quantity`, `total`) VALUES
(744, 12, 1, 21, 31741500, 1, 31741500),
(745, NULL, 2, 32, 15687000, 1, 15687000),
(746, NULL, 3, 42, 14525000, 2, 29050000),
(747, NULL, 3, 56, 75000, 1, 75000),
(748, NULL, 3, 54, 550000, 1, 550000),
(749, NULL, 4, 52, 2840500, 1, 2840500),
(750, NULL, 4, 50, 1463000, 1, 1463000),
(751, NULL, 5, 48, 2835000, 1, 2835000),
(752, 16, 6, 24, 38353900, 5, 191769500),
(753, NULL, 7, 42, 14525000, 1, 14525000);


INSERT INTO `bills` (`id`, `created_at`, `created_receive`, `fk_order_id`, `method_payment`, `status_order`) VALUES
(126, '2025-05-12 22:51:43.485000', NULL, 1, 'tienmat', 'dathanhtoan'),
(127, '2025-05-12 22:55:21.885000', NULL, 2, 'tienmat', 'dathanhtoan'),
(128, '2025-05-12 22:55:20.636000', NULL, 3, 'tienmat', 'dathanhtoan'),
(129, '2025-05-12 22:55:19.291000', NULL, 4, 'tienmat', 'dathanhtoan'),
(130, '2025-05-12 15:53:49.000000', NULL, 5, 'tienmat', 'chuathanhtoan'),
(131, '2025-05-12 22:55:17.809000', NULL, 6, 'tienmat', 'dathanhtoan');



INSERT INTO `messages` (`id`, `content`, `receiver_id`, `sender_id`, `sent_at`, `image`) VALUES
(15, 'hello cac ban', 139, 131, '2025-04-28 17:03:24.334000', NULL),
(16, 'sao v', 131, 139, '2025-04-28 17:04:38.302000', NULL),
(17, 'k sao', 139, 131, '2025-04-28 17:04:46.231000', NULL),
(18, 'qqq', 131, 139, '2025-04-28 17:08:03.894000', NULL),
(19, 'hehehe', 139, 131, '2025-04-28 17:08:11.204000', NULL),
(20, 'dang lam gi do', 131, 139, '2025-04-28 17:08:16.786000', NULL),
(21, 'ranh k', 131, 139, '2025-04-28 17:08:23.400000', NULL),
(22, 'k', 139, 131, '2025-04-28 17:08:43.118000', NULL),
(23, 'k', 139, 131, '2025-04-28 17:08:47.383000', NULL),
(24, 'sa', 139, 131, '2025-04-28 17:08:53.998000', NULL),
(25, 'sao ba', 139, 131, '2025-04-28 17:09:07.961000', NULL),
(26, 'bam nham a', 139, 131, '2025-04-28 17:10:19.640000', NULL),
(27, 'het hon', 131, 139, '2025-04-28 17:10:25.219000', NULL),
(28, 'umhum =))', 139, 131, '2025-04-28 17:10:30.776000', NULL),
(29, 'ha', 131, 139, '2025-04-28 17:12:56.390000', NULL),
(30, 'hws', 139, 131, '2025-04-28 17:13:02.558000', NULL),
(31, 'dasd', 139, 131, '2025-04-28 17:13:05.543000', NULL),
(32, 'dasd', 139, 131, '2025-04-28 17:13:07.698000', NULL),
(33, 'asd', 139, 131, '2025-04-28 17:13:08.558000', NULL),
(34, 'hehe', 131, 139, '2025-04-28 17:13:11.252000', NULL),
(35, 'Hello', 131, 139, '2025-05-01 16:10:08.146000', NULL),
(36, 'Ranh k a', 131, 139, '2025-05-01 16:10:12.180000', NULL),
(37, 'k nhe:))', 139, 131, '2025-05-01 16:10:20.829000', NULL),
(38, 'a', 131, 143, '2025-05-01 21:35:52.445000', NULL),
(39, 'as', 131, 143, '2025-05-05 08:35:53.965000', NULL),
(40, 'sao v', 143, 131, '2025-05-05 08:35:59.189000', NULL),
(41, 'on k', 143, 131, '2025-05-05 08:36:06.778000', NULL),
(42, 'k :))', 131, 143, '2025-05-05 08:36:12.442000', NULL),
(43, 'M', 143, 131, '2025-05-05 08:36:40.479000', NULL),
(44, 'a', 131, 143, '2025-05-05 08:37:03.420000', NULL),
(45, 'aa', 131, 143, '2025-05-05 09:19:05.070000', NULL),
(46, '?', 143, 131, '2025-05-05 09:19:09.943000', NULL),
(47, 'Cao Ky', 143, 131, '2025-05-05 09:19:49.000000', NULL),
(48, 'z', 143, 131, '2025-05-05 09:22:46.224000', NULL),
(62, 'Hi', 143, 144, '2025-05-05 09:42:42.002000', NULL),
(63, 'sao v', 143, 144, '2025-05-05 09:45:16.075000', NULL),
(64, 'rep toi di', 143, 144, '2025-05-05 09:45:27.277000', NULL),
(65, 'sao v a', 144, 143, '2025-05-05 09:45:33.618000', NULL),
(66, 'heee', 143, 144, '2025-05-05 09:49:53.705000', NULL),
(67, 'aa', 143, 144, '2025-05-05 09:50:00.844000', NULL),
(68, '?', 144, 143, '2025-05-05 09:50:05.815000', NULL),
(69, 'a', 143, 144, '2025-05-05 09:50:11.120000', NULL),
(70, 'asd', 143, 144, '2025-05-05 09:54:08.480000', NULL),
(71, 'dasda', 143, 144, '2025-05-05 09:54:15.620000', NULL),
(72, 'aasda', 143, 131, '2025-05-05 10:12:29.536000', NULL),
(73, 'hi', 131, 143, '2025-05-05 10:30:47.748000', NULL),
(74, 'Alooo', 143, 144, '2025-05-06 17:15:37.617000', NULL),
(75, '', 143, 131, '2025-05-07 20:02:58.423000', NULL),
(76, '', 143, 131, '2025-05-07 20:04:17.303000', NULL),
(77, 'ha', 131, 143, '2025-05-07 20:08:07.096000', NULL),
(78, 'gif v', 131, 143, '2025-05-07 20:08:17.613000', NULL),
(79, 'HBU', 143, 131, '2025-05-07 20:09:04.342000', NULL),
(80, 'z', 131, 143, '2025-05-07 20:09:15.128000', NULL),
(81, 'a', 143, 131, '2025-05-07 20:09:22.791000', NULL),
(82, 'asd', 143, 131, '2025-05-07 20:09:29.936000', NULL),
(83, 'asd', 131, 143, '2025-05-07 20:09:33.080000', NULL),
(84, '?', 131, 143, '2025-05-07 20:11:47.295000', NULL),
(85, 'sao', 131, 143, '2025-05-07 20:12:29.155000', NULL),
(86, 'a', 131, 143, '2025-05-07 20:14:05.759000', NULL),
(87, 'hhii', 131, 143, '2025-05-07 20:14:31.480000', NULL),
(88, 'sao', 143, 131, '2025-05-07 20:14:35.811000', NULL),
(89, 'as', 143, 131, '2025-05-07 20:14:54.045000', NULL),
(90, 'a', 131, 143, '2025-05-07 20:14:59.142000', NULL),
(91, 'a', 143, 131, '2025-05-07 20:15:02.265000', NULL),
(92, 'hu', 143, 131, '2025-05-07 20:15:28.940000', NULL),
(93, 'hee', 143, 131, '2025-05-07 20:15:50.621000', NULL),
(94, 'sa', 131, 143, '2025-05-07 20:15:56.526000', NULL),
(95, '??', 143, 131, '2025-05-07 20:15:59.760000', NULL),
(96, 'sao v', 131, 143, '2025-05-07 20:17:16.238000', NULL),
(97, 'sao la sao', 143, 131, '2025-05-07 20:17:21.382000', NULL),
(98, 'aa', 143, 131, '2025-05-07 20:19:29.571000', NULL),
(99, 'asda', 143, 131, '2025-05-07 20:19:36.147000', NULL),
(100, '??', 143, 131, '2025-05-07 20:19:50.813000', NULL),
(101, 'aa', 143, 131, '2025-05-07 20:20:22.563000', NULL),
(102, 'a', 131, 143, '2025-05-07 20:26:49.369000', NULL),
(103, 'b', 143, 131, '2025-05-07 20:26:52.487000', NULL),
(104, 'acac', 131, 143, '2025-05-07 20:27:07.810000', NULL),
(105, 'z', 143, 131, '2025-05-07 20:27:15.122000', NULL),
(106, 'a', 131, 143, '2025-05-07 20:27:22.115000', NULL),
(107, 'acasc', 143, 131, '2025-05-07 20:27:51.354000', NULL),
(108, 'a', 131, 143, '2025-05-07 20:28:20.459000', NULL),
(109, 'casc', 143, 131, '2025-05-07 20:28:23.282000', NULL),
(110, 'a', 131, 143, '2025-05-07 20:44:43.021000', NULL),
(111, 'hmm', 143, 131, '2025-05-07 20:44:46.364000', NULL),
(112, 'HIhi', 131, 143, '2025-05-07 20:44:51.270000', NULL),
(113, 'hihiaa', 143, 131, '2025-05-07 20:45:00.127000', NULL),
(114, '', 131, 143, '2025-05-07 20:49:47.469000', 'https://res.cloudinary.com/dwskd7iqr/image/upload/v1746625786/nlejlbdgajsvezrtbyfm.jpg'),
(115, 'hmnm??', 143, 131, '2025-05-07 20:49:57.462000', 'https://res.cloudinary.com/dwskd7iqr/image/upload/v1746625796/unopq7usppjulzesqyte.jpg'),
(116, 'bi loi', 143, 131, '2025-05-07 20:50:10.669000', ''),
(117, 'loi gi', 131, 143, '2025-05-07 20:50:15.610000', ''),
(118, 'k biet', 143, 131, '2025-05-07 20:50:22.706000', ''),
(119, 'a', 144, 143, '2025-05-07 20:54:55.888000', ''),
(120, 'thua', 131, 143, '2025-05-07 20:55:26.054000', ''),
(121, 'alo', 143, 131, '2025-05-08 11:33:55.587000', ''),
(122, 'sao v', 131, 143, '2025-05-08 11:34:03.085000', ''),
(123, 'kcj', 143, 131, '2025-05-08 11:34:12.635000', 'https://res.cloudinary.com/dwskd7iqr/image/upload/v1746678850/bjjl72qo7zvsjdupk4h0.jpg'),
(124, 'ranh', 131, 143, '2025-05-08 11:34:17.690000', ''),
(125, 'a', 143, -1, '2025-05-09 10:59:46.166000', ''),
(126, 'aa', 143, -1, '2025-05-10 10:45:53.227000', ''),
(127, '??', 131, 143, '2025-05-10 10:46:23.662000', ''),
(128, 'as', 143, 131, '2025-05-10 10:46:39.015000', ''),
(129, 'Cuu', 143, 148, '2025-05-12 15:37:54.815000', ''),
(130, 'aloo', 143, 148, '2025-05-12 15:38:08.700000', ''),
(131, '??', 143, 148, '2025-05-12 15:38:15.359000', ''),
(132, 'gi v', 148, 143, '2025-05-12 15:38:21.671000', ''),
(133, '', 148, 143, '2025-05-12 15:38:30.219000', 'https://res.cloudinary.com/dwskd7iqr/image/upload/v1747039109/sptzishc1p7vmw1ktghj.jpg'),
(134, 'pok', 143, 148, '2025-05-12 15:38:37.706000', ''),
(135, 'Hii shop', 143, 139, '2025-05-12 23:15:27.103000', '');





INSERT INTO `rating` (`id`, `id_fk_customer`, `id_fk_product`, `rating`, `sentiment`, `content`, `name`) VALUES
(63, 131, 30, 4, 1, 'I want to buy more', 'CaiKey-1722'),
(64, 131, 35, 2, 1, 'Urgly', 'CaiKey-1722'),
(65, 131, 41, 5, 1, 'Hayy', 'CaiKey-1722'),
(66, 131, 33, 3, 1, 'a', 'CaiKey-1722');
