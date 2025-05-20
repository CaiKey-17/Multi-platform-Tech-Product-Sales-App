package com.example.api.controller.user;

import com.example.api.model.Customer;
import com.example.api.model.Users;
import com.example.api.model.Address;
import com.example.api.security.JwtTokenUtil;
import com.example.api.service.AddressService;
import com.example.api.service.CustomerService;
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
@RequestMapping("/api/auth")
public class UserController {

    @Autowired
    private UserService userService;
    @Autowired
    private AddressService addressService;

    @Autowired
    private CustomerService customerService;

    @GetMapping("/user-info")
    public ResponseEntity<?> getUserInfo(@RequestHeader("Authorization") String token) {
        try {
            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
            Users user = userService.getUserById(userId);
            Customer customer = customerService.getCustomerById(userId);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                        "code", 404,
                        "message", "Không tìm thấy người dùng"
                ));
            }

            List<Address> addresses = addressService.getAddressesByUserId(userId);
            List<String> addressList = addresses.stream()
                    .map(Address::getAddress)
                    .collect(Collectors.toList());
            List<String> addressCode = addresses.stream()
                    .map(Address::getCodes)
                    .collect(Collectors.toList());
            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", user.getId());
            userInfo.put("tempId", user.getTempId());
            userInfo.put("email", user.getEmail());
            userInfo.put("fullName", user.getFullName());
            userInfo.put("active", user.getActive());
            userInfo.put("createdAt", user.getCreatedAt());
            userInfo.put("role", userService.getUserRole(user.getEmail()));
            userInfo.put("addresses", addressList);
            userInfo.put("codes", addressCode);
            userInfo.put("points", customer.getPoints());
            if (user.getImage() != null) {
                userInfo.put("image", user.getImage());
            } else {
                userInfo.put("image", "");

            }
            return ResponseEntity.ok(userInfo);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }

    @GetMapping("/admin-info")
    public ResponseEntity<?> getAdminInfo(@RequestHeader("Authorization") String token) {
        try {
            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
            Users user = userService.getUserById(userId);

            Map<String, Object> userInfo = new HashMap<>();
            userInfo.put("id", user.getId());
            userInfo.put("email", user.getEmail());
            userInfo.put("fullName", user.getFullName());
            userInfo.put("active", user.getActive());
            userInfo.put("role", userService.getUserRole(user.getEmail()));
            if (user.getImage() != null) {
                userInfo.put("image", user.getImage());
            } else {
                userInfo.put("image", "");

            }

            return ResponseEntity.ok(userInfo);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }


    @PostMapping("/user-info/change")
    public ResponseEntity<?> changeImage(@RequestHeader("Authorization") String token, @RequestParam String image) {
        try {
            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
            Users user = userService.getUserById(userId);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                        "code", 404,
                        "message", "Không tìm thấy người dùng"
                ));
            }
            user.setImage(image);
            userService.updateUser(user);

            System.out.println("📸 Ảnh nhận được: " + image);


            return ResponseEntity.ok(Map.of(
                    "code", 200,
                    "message", "Lưu ảnh người dùng thành công!"

            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }

    @PostMapping("/user-info/update-name")
    public ResponseEntity<?> changeName(@RequestHeader("Authorization") String token, @RequestParam String name) {
        try {
            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
            Users user = userService.getUserById(userId);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                        "code", 404,
                        "message", "Không tìm thấy người dùng"
                ));
            }
            user.setFullName(name);
            userService.updateUser(user);


            return ResponseEntity.ok(Map.of(
                    "code", 200,
                    "message", "Đổi tên người dùng thành công!"
            ));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }


}
