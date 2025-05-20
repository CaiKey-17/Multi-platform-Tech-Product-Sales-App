package com.example.api.luan.controller;

import com.example.api.luan.dto.UserInfoDTO;
import com.example.api.model.Users;
import com.example.api.luan.service.UserAdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/users")
public class UserAdminController {

    @Autowired
    private UserAdminService userAdminService;

    @GetMapping
    public ResponseEntity<List<?>> getAllUsers() {
        List<UserInfoDTO> users = userAdminService.getAllUsers();
        return ResponseEntity.ok(users);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserInfoDTO> getUserById(@PathVariable Integer id) {
        return userAdminService.getUserById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/{id}/toggle-active")
    public ResponseEntity<String> toggleUserActive(@PathVariable Integer id) {
        boolean success = userAdminService.toggleActiveStatus(id);
        if (success) {
            return ResponseEntity.ok("Trạng thái active đã được cập nhật.");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Integer id) {
        boolean deleted = userAdminService.deleteUserById(id);
        if (deleted) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/{id}/full-name")
    public ResponseEntity<?> updateFullName(
            @PathVariable Integer id,
            @RequestParam String fullName) {
        boolean updated = userAdminService.updateFullName(id, fullName);
        if (updated) {
            return ResponseEntity.ok("Cập nhật tên thành công.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Không tìm thấy người dùng với ID: " + id);
        }
    }

}
