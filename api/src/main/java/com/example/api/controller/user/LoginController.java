package com.example.api.controller.user;

import com.example.api.dto.LoginRequest;
import com.example.api.model.Users;
import com.example.api.security.JwtTokenUtil;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import com.example.api.service.UserService;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class LoginController {
    @Autowired
    private UserService userService;

    private PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();



    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request,
            HttpServletResponse response) {

        Users user = userService.findByEmail(request.getUsername());

        if (user == null || !userService.authenticateUser(request.getUsername(), request.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "code", 401,
                    "message", "Sai tài khoản hoặc mật khẩu"
            ));
        }

        if (user.getActive() == 0) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of(
                    "code", 403,
                    "message", "Người dùng đã bị cấm"
            ));
        }

        try {
            String role = userService.getUserRole(request.getUsername());
            int id = user.getId();
            String token = JwtTokenUtil.createToken(id, role);

            Cookie tokenCookie = new Cookie("token", token);
            tokenCookie.setHttpOnly(true);
            tokenCookie.setPath("/");
            tokenCookie.setMaxAge(60 * 60 * 24);
            tokenCookie.setAttribute("SameSite", "Strict");
            response.addCookie(tokenCookie);

            return ResponseEntity.ok(Map.of(
                    "code", 200,
                    "message", "Đăng nhập thành công",
                    "token", token,
                    "role", role
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi tạo token"
            ));
        }
    }

    @PostMapping("/changePassword")
    public ResponseEntity<?> changePassword(
            @RequestHeader("Authorization") String token,
            @RequestParam String oldPassword,
            @RequestParam String newPassword) {
        try {
            int userId = JwtTokenUtil.getIdFromToken(token.replace("Bearer ", ""));
            Users user = userService.getUserById(userId);

            if (user == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of(
                        "code", 404,
                        "message", "Không tìm thấy người dùng"
                ));
            }

            if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(
                        "code", 400,
                        "message", "Mật khẩu cũ không đúng"
                ));
            }

            user.setPassword(passwordEncoder.encode(newPassword));
            userService.save(user);

            return ResponseEntity.ok(Map.of(
                    "code", 200,
                    "message", "Đổi mật khẩu thành công"
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "code", 500,
                    "message", "Lỗi khi đổi mật khẩu"
            ));
        }
    }



}
