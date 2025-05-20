package com.example.api.luan.controller;

import com.example.api.luan.service.BillAdminService;
import com.example.api.model.Bill;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/bills")
public class BillAdminController {

    @Autowired
    private BillAdminService billAdminService;

    @GetMapping("/order/{orderId}")
    public ResponseEntity<List<Bill>> getBillsByOrder(@PathVariable Integer orderId) {
        List<Bill> bills = billAdminService.getBillsByOrderId(orderId);
        return ResponseEntity.ok(bills);
    }

    @GetMapping("/{billId}")
    public ResponseEntity<Bill> getBillById(@PathVariable Integer billId) {
        Optional<Bill> bill = billAdminService.getBillById(billId);
        return bill.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Bill>> getAllBills() {
        List<Bill> bills = billAdminService.getAllBills();
        return ResponseEntity.ok(bills);
    }

    @PutMapping("/{billId}/status")
    public ResponseEntity<String> updateBillStatus(
            @PathVariable Integer billId,
            @RequestParam String statusOrder) {
        try {
            boolean updated = billAdminService.updateBillStatus(billId, statusOrder);
            if (updated) {
                return ResponseEntity.ok("Cập nhật trạng thái hóa đơn thành công");
            } else {
                return ResponseEntity.badRequest().body("Cập nhật trạng thái hóa đơn thất bại. Trạng thái không hợp lệ hoặc hóa đơn không tồn tại");
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Lỗi server: " + e.getMessage());
        }
    }
}