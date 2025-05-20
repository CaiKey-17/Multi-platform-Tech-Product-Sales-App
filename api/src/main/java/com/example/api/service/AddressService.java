package com.example.api.service;

import com.example.api.model.Address;
import com.example.api.repository.AddressRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AddressService {

    @Autowired
    AddressRepository addressRepository;

    public void save(Address address){
        addressRepository.save(address);
    }
    public List<Address> getAddressesByUserId(Integer userId) {
        return addressRepository.findByUserIdOrderByStatusDesc(userId);
    }


    public Optional<Address> findAddressById(Integer id) {
        return addressRepository.findById(id);
    }

    public void setDefaultAddress(int userId, int addressId) {
        addressRepository.resetStatusByUserId(userId);

        addressRepository.setDefaultAddress(addressId);
    }

}
