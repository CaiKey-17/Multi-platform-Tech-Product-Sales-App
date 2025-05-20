package com.example.api;

import com.example.api.model.Role;
import com.example.api.repository.RoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataLoader {

    @Autowired
    private RoleRepository roleRepository;

    @Bean
    public CommandLineRunner loadData() {
        return args -> {
            if (roleRepository.findByRoleName("ROLE_ADMIN") == null) {
                roleRepository.save(new Role("ROLE_ADMIN"));
            }

            if (roleRepository.findByRoleName("ROLE_CUSTOMER") == null) {
                roleRepository.save(new Role("ROLE_CUSTOMER"));
            }


        };
    }


}