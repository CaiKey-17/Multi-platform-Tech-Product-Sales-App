package com.example.api.service;

import com.example.api.model.Customer;
import com.example.api.model.Users;
import com.example.api.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CustomerService {

    @Autowired
    CustomerRepository customerRepository;

    public Customer getCustomerById(int id){
        return  customerRepository.findById(id).orElse(null);
    }

    public void save(Customer c){
        customerRepository.save(c);
    }
}
