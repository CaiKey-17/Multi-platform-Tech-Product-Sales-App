package com.example.api.controller.product;

import com.example.api.dto.ProductDTO;
import com.example.api.dto.ProductDetailDTO;
import com.example.api.model.Address;
import com.example.api.model.Customer;
import com.example.api.model.Users;
import com.example.api.security.JwtTokenUtil;
import com.example.api.service.CustomerService;
import com.example.api.service.ProductService;
import com.example.api.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/products")
public class ProductController {

    @Autowired
    private ProductService productService;



    @Autowired
    private UserService userService;
    @Autowired
    private CustomerService customerService;

    @GetMapping("/promotion")
    public ResponseEntity<List<ProductDTO>> getProductsPromotion() {
        List<ProductDTO> products = productService.getAllProductsPromotion();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/new")
    public ResponseEntity<List<ProductDTO>> getProductsNew() {
        List<ProductDTO> products = productService.getAllProductsNew();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }
    @GetMapping("/best-seller")
    public ResponseEntity<List<ProductDTO>> getProductsBestSeller() {
        List<ProductDTO> products = productService.getAllProductsBestSeller();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/laptop")
    public ResponseEntity<List<ProductDTO>> getProductsLaptop() {
        List<ProductDTO> products = productService.getAllProductsLaptop();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/monitor")
    public ResponseEntity<List<ProductDTO>> getProductsMonitor() {
        List<ProductDTO> products = productService.getAllProductsMonitor();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/keyboard")
    public ResponseEntity<List<ProductDTO>> getProductsKeyboard() {
        List<ProductDTO> products = productService.getAllProductsKeyboard();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }


    @GetMapping("/phone")
    public ResponseEntity<List<ProductDTO>> getProductsPhone() {
        List<ProductDTO> products = productService.getAllProductsPhone();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/pc")
    public ResponseEntity<List<ProductDTO>> getProductsPc() {
        List<ProductDTO> products = productService.getAllProductsPc();
        return new ResponseEntity<>(products, HttpStatus.OK);
    }



    @GetMapping("/category")
    public ResponseEntity<List<ProductDTO>> getProductsByCategory(@RequestParam String fk_category) {
        List<ProductDTO> products = productService.getAllProductsByCategory(fk_category);
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/brand")
    public ResponseEntity<List<ProductDTO>> getProductsByBrand(@RequestParam String fk_brand) {
        List<ProductDTO> products = productService.getAllProductsByBrand(fk_brand);
        return new ResponseEntity<>(products, HttpStatus.OK);
    }

    @GetMapping("/detail")
    public ResponseEntity<ProductDetailDTO> getProductsDetail(@RequestParam int id) {
        ProductDetailDTO product = productService.getDetailProduct(id);
        return new ResponseEntity<>(product, HttpStatus.OK);
    }

    @GetMapping("/search")
    public ResponseEntity<List<ProductDTO>> getProductsSearch(@RequestParam String name) {
        List<ProductDTO> products = productService.getAllProductsBySearch(name);
        return new ResponseEntity<>(products, HttpStatus.OK);
    }



    @GetMapping("/search-advance")
    public ResponseEntity<List<ProductDTO>> getProductsSearchAdvance(
            @RequestParam String name,
            @RequestParam(required = false) String brand,
            @RequestParam(required = false) Double minPrice,
            @RequestParam(required = false) Double maxPrice,
            @RequestParam(required = false) Double rating) {

        List<ProductDTO> products = productService.getAllProductsBySearchAdvance(name, brand, minPrice, maxPrice, rating);
        return new ResponseEntity<>(products, HttpStatus.OK);
    }



//    @GetMapping("/cart")
//    public ResponseEntity<?> getProductsInCart(@RequestHeader("Authorization") String token) {
//        try {
//            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
//            Users user = userService.getUserById(userId);
//            Customer customer = customerService.getCustomerById(userId);
//            if (user == null) {
//                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
//                        "code", 404,
//                        "message", "Không tìm thấy người dùng"
//                ));
//            }
//
//            Map<String, Object> userInfo = new HashMap<>();
//            userInfo.put("id", user.getId());
//            userInfo.put("tempId", user.getTempId());
//            userInfo.put("email", user.getEmail());
//            userInfo.put("fullName", user.getFullName());
//            userInfo.put("active", user.getActive());
//            userInfo.put("createdAt", user.getCreatedAt());
//            userInfo.put("role", userService.getUserRole(user.getEmail()));
//            userInfo.put("addresses", addressList);
//            userInfo.put("points", customer.getPoints());
//
//            return ResponseEntity.ok(userInfo);
//        } catch (Exception e) {
//            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
//                    "code", 500,
//                    "message", "Lỗi khi lấy thông tin người dùng"
//            ));
//        }
//    }



}
