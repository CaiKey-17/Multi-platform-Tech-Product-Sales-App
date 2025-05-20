package com.example.api.controller.cart;

import com.example.api.dto.CartItemProjection;
import com.example.api.dto.OrderDetailProjection;
import com.example.api.repository.OrderDetailRepository;
import com.example.api.security.JwtTokenUtil;
import com.example.api.service.*;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    @Autowired
    private CartService cartService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private OrderDetailService orderDetailService;


    @Autowired
    private OrderDetailRepository orderDetailRepository;

    @Autowired
    private ProductColorService productColorService;

    @Autowired
    private ProductVariantService productVariantService;


    @PostMapping("/add")
    public ResponseEntity<?> addToCart(
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestParam int productId,
            @RequestParam int colorId,
            @RequestParam int quantity,
            @RequestParam(value = "id", required = false) Integer existingId,
            HttpServletResponse response,
            HttpSession session) {
        Integer id = (existingId != null) ? existingId : -1;
        if (id == -1 && token != null && !token.isBlank()) {
            try {
                Integer extractedId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
                if (extractedId != null) {
                    id = extractedId;
                }


            } catch (Exception e) {
                System.out.println("Token không hợp lệ: " + token);
            }
        }
        Integer orderId = (orderService.getOrderIdByCustomer(id) != null) ? orderService.getOrderIdByCustomer(id) : -1;
        Integer quantityInDetails = 0;
        Integer quantityInStockColor = 0;
        Integer quantityInStockVariant = 0;
        if (colorId > 0 && orderId > -1 && orderDetailService.getQuantity(orderId, productId, colorId) != null) {
            quantityInDetails = orderDetailService.getQuantity(orderId, productId, colorId);
            quantityInStockColor = productColorService.getQuantityById(colorId);
            if (quantityInDetails >= quantityInStockColor) {
                return ResponseEntity.status(400).body(Map.of(
                        "error", "Số lượng vượt quá tồn kho",
                        "available_stock", quantityInStockColor,
                        "requested_quantity", quantityInDetails + quantity
                ));
            }
        }
        if (colorId < 0 && orderId > -1 && orderDetailService.getQuantity(orderId, productId) != null) {
            quantityInDetails = orderDetailService.getQuantity(orderId, productId);
            quantityInStockVariant = productVariantService.getQuantityById(productId);
            if (quantityInDetails >= quantityInStockVariant) {
                return ResponseEntity.status(400).body(Map.of(
                        "error", "Số lượng vượt quá tồn kho",
                        "available_stock", quantityInStockVariant,
                        "requested_quantity", quantityInDetails + quantity
                ));
            }
        }


        Map<String, Object> result = cartService.addToCart(id, productId, colorId, quantity);

        if (result == null) {
            return ResponseEntity.status(500).body(Map.of("error", "Lỗi hệ thống: Không thể thêm vào giỏ hàng"));
        }

        if (id == -1) {
            id = (Integer) result.getOrDefault("id", -1);
        }

        String tempID = result.getOrDefault("temp_id", "-1").toString();

        if (!tempID.equals("-1")) {
            session.setAttribute("id", id.toString());
            Cookie userCookie = new Cookie("id", id.toString());
            userCookie.setPath("/");
            response.addCookie(userCookie);
        }

        return ResponseEntity.ok(Map.of("message", "Thêm vào giỏ hàng", "id", id, "temp_id", tempID));
    }

    @PostMapping("/minus")
    public ResponseEntity<?> minusToCart(
            @RequestParam int productId,
            @RequestParam int orderId,
            @RequestParam int colorId
            ) {

        cartService.minusToCart(productId, orderId,colorId);
        return ResponseEntity.ok(Map.of("message", "Đã trừ trong giỏ hàng"));
    }

    @PostMapping("/delete")
    public ResponseEntity<?> deleteToCart(
            @RequestParam int orderDetailId) {

        cartService.deleteToCart(orderDetailId);
        return ResponseEntity.ok(Map.of("message", "Đã xoá sản phẩm trong giỏ hàng"));
    }

    @GetMapping("/list")
    public ResponseEntity<List<OrderDetailProjection>> listItemCarts(
            @RequestHeader(value = "Authorization", required = false) String token,
            @RequestParam(value = "id", required = false) Integer existingId,
            HttpServletResponse response,
            HttpSession session) {
        System.out.println(token);
        Integer id = (existingId != null) ? existingId : -1;
        System.out.println(id);
        if (id == -1 && token != null && !token.isBlank()) {
            try {
                Integer extractedId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
                if (extractedId != null) {
                    id = extractedId;
                }

            } catch (Exception e) {
                System.out.println("Token không hợp lệ: " + token);
            }
        }

        List<OrderDetailProjection> list = orderDetailService.getOrderDetailsByCustomerId(id,"giohang");

        return ResponseEntity.ok(list);
    }

    @GetMapping("/list-detail")
    public ResponseEntity<List<OrderDetailProjection>> listItemCartsDetail(
            @RequestParam(value = "orderId") Integer orderId,
            HttpServletResponse response,
            HttpSession session) {

        List<OrderDetailProjection> list = orderDetailService.getOrderDetailsByCustomerIdDetail(orderId);

        return ResponseEntity.ok(list);
    }




    @GetMapping("/quantity")
    public ResponseEntity<Map<Integer, Integer>> getCartQuantities(@RequestParam("userId") Integer userId) {
        List<CartItemProjection> items = orderDetailRepository.findCartItemsByCustomerId(userId);

        Map<Integer, Integer> result = new HashMap<>();
        for (CartItemProjection item : items) {
            result.put(item.getId(), item.getQuantity());
        }

        return ResponseEntity.ok(result);
    }

}
