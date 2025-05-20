package com.example.api.controller.user;

import com.example.api.model.Address;
import com.example.api.model.Customer;
import com.example.api.model.Users;
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
@RequestMapping("/api/address")
public class AddressController {

    @Autowired
    private UserService userService;

    @Autowired
    private AddressService addressService;

    @Autowired
    private CustomerService customerService;

    @GetMapping()
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


            return ResponseEntity.ok(addresses);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }

    @PostMapping("/add")
    public ResponseEntity<?> getUserInfo(@RequestBody Address address) {
        try {
            addressService.save(address);
            return ResponseEntity.ok(Map.of("data", address, "message", "Thêm địa chỉ mới thành công"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }

    @PostMapping("/default")
    public ResponseEntity<?> chooseAddressDefault(@RequestHeader("Authorization") String token, @RequestParam int addressId) {
        try {
            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
            Users user = userService.getUserById(userId);
            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                        "code", 404,
                        "message", "Không tìm thấy người dùng"
                ));
            } else {
                Address a = addressService.findAddressById(addressId).orElse(null);
                if (a != null) {
                    addressService.setDefaultAddress(userId, a.getId());
                }
                return ResponseEntity.ok(HttpStatus.OK);

            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi lấy thông tin người dùng"
            ));
        }
    }


}
