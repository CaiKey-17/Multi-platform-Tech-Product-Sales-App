package com.example.api.repository;

import com.example.api.model.Address;
import com.example.api.model.Customer;
import com.example.api.model.Role;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;


public interface CustomerRepository extends JpaRepository<Customer, Integer> {

}