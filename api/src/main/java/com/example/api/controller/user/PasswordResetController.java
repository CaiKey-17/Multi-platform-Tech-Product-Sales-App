package com.example.api.controller.user;

import com.example.api.model.Users;
import com.example.api.service.UserService;
import com.example.api.service.EmailService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import java.util.UUID;

import static com.example.api.domain.IP.IP_network;

@RestController
@RequestMapping("/api/auth")
public class PasswordResetController {

    private final UserService userService;
    private final EmailService emailService;

    public PasswordResetController(UserService userService, EmailService emailService) {
        this.userService = userService;
        this.emailService = emailService;
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestParam String email) {
        Users user = userService.findByEmail(email);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Email không tồn tại trong hệ thống");
        }

        String token = UUID.randomUUID().toString();
        userService.savePasswordResetToken(user, token);

        String resetLink = "http://"+IP_network+":8080/api/auth/reset-password?token=" + token;

        emailService.sendEmail(email, "Đặt lại mật khẩu", "Nhấp vào liên kết sau để đặt lại mật khẩu: " + resetLink);

        return ResponseEntity.ok("Email đặt lại mật khẩu đã được gửi");
    }

    @GetMapping("/reset-password")
    public ModelAndView showResetPasswordPage(@RequestParam String token) {
        ModelAndView modelAndView = new ModelAndView("reset_password");
        boolean isValid = userService.validateResetToken(token);

        if (!isValid) {
            modelAndView.setViewName("error");
            modelAndView.addObject("message", "Token không hợp lệ hoặc đã hết hạn.");
            return modelAndView;
        }

        modelAndView.addObject("token", token);
        return modelAndView;
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> processResetPassword(@RequestParam String token, @RequestParam String newPassword) {
        boolean isUpdated = userService.updatePassword(token, newPassword);

        if (!isUpdated) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Token không hợp lệ hoặc đã hết hạn.");
        }

        return ResponseEntity.ok("Mật khẩu đã được cập nhật thành công.");
    }
}
