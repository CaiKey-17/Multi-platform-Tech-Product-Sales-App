package com.example.api.luan.service;

import com.example.api.luan.repository.BillAdminRepository;
import com.example.api.luan.repository.OrderAdminRepository;
import com.example.api.model.Bill;
import com.example.api.model.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BillAdminService {

    @Autowired
    private BillAdminRepository billRepository;

    public List<Bill> getBillsByOrderId(Integer orderId) {
        return billRepository.findByFkOrderId(orderId);
    }

    public Optional<Bill> getBillById(Integer billId) {
        return billRepository.findById(billId);
    }

    public List<Bill> getAllBills() {
        return billRepository.findAll();
    }

    public boolean updateBillStatus(Integer billId, String statusOrder) {
        if (!isValidStatus(statusOrder)) {
            return false;
        }
        int updated = billRepository.updateBillStatus(billId, statusOrder);
        return updated > 0;
    }

    private boolean isValidStatus(String statusOrder) {
        return statusOrder != null &&
                (statusOrder.equals("dathanhtoan") ||
                        statusOrder.equals("chuathanhtoan"));
    }

}
