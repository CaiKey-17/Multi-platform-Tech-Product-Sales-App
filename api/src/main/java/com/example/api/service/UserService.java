package com.example.api.service;


import com.example.api.model.*;
import com.example.api.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class UserService {
    @Autowired
    RoleRepository roleRepository;

    @Autowired
    CustomerRepository customerRepository;

    @Autowired
    private UsersRepository userRepository;


    @Autowired
    private AddressService addressService;

    public void save(Users u){
        userRepository.save(u);
    }


    private PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public UserService(PasswordEncoder passwordEncoder) {
        this.passwordEncoder = passwordEncoder;
    }


    public boolean authenticateUser(String email, String password) {

        Optional<Users> user = userRepository.findByEmail(email);
        System.out.println(user.toString());
        return user.isPresent() && passwordEncoder.matches(password, user.get().getPassword());
    }


    public void updateUser(Users user) {
        userRepository.save(user);
    }

    public Users findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email không tồn tại: " + email));
    }


    public Users findById(int id) {
        return userRepository.findById(id).get();
    }

    public boolean validateResetToken(String token) {
        if (userRepository.findByResetToken(token) != null) {
            return true;
        }
        return false;
    }

    public boolean updatePassword(String token, String newPassword) {
        Users user = userRepository.findByResetToken(token);
        System.out.println(user.toString());
        if (user != null) {
            user.setPassword(passwordEncoder.encode(newPassword));
            user.setResetToken(null);
            userRepository.save(user);
            return true;



        }
        return false;
    }

    public void savePasswordResetToken(Users user, String token) {
        user.setResetToken(token);
        userRepository.save(user);
    }

    public UserService() {
    }

    public UserService(UsersRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    private final Map<String, String> otpStorage = new ConcurrentHashMap<>();

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public void saveOtp(String email, String otp) {
        otpStorage.put(email, otp);
    }

    public boolean verifyOtp(String email, String otp) {
        return otp.equals(otpStorage.get(email));
    }

    public Map<String, Long> getUserStatistics() {
        return userRepository.getTotalUsersAndNewUsers();
    }


    @Transactional
    public void registerUser(String email, String password, String address, String fullname,String codes) {
        Users newUser = new Users();
        newUser.setEmail(email);
        newUser.setPassword(passwordEncoder.encode(password));
        newUser.setFullName(fullname);
        newUser.setCreatedAt(new Date());
        Optional<Role> customerRoleOpt = Optional.ofNullable(roleRepository.findByRoleName("ROLE_CUSTOMER"));
        Role customerRole = customerRoleOpt.get();
        newUser.setRoles(Collections.singleton(customerRole));
        newUser = userRepository.save(newUser);
        int userId = newUser.getId();
        Address addresses = new Address(address, userId,codes);
        addressService.save(addresses);


        Customer customer = new Customer(userId, 0);
        customerRepository.save(customer);

        otpStorage.remove(email);
    }


    public String getUserRole(String username) {

        Optional<Users> user = userRepository.findByEmail(username);
        if (user.isPresent() && !user.get().getRoles().isEmpty()) {

            return user.get().getRoles().iterator().next().getRoleName();
        }
        return null;
    }


    public Users getUserById(int id) {
        return userRepository.findById(id).orElse(null);
    }

    public Integer getUserIdByEmail(String email) {
        return userRepository.findIdByEmail(email).orElse(null);
    }

}