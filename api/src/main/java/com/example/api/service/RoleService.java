package com.example.api.service;


import com.example.api.model.Role;
import com.example.api.repository.RoleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class RoleService {
    @Autowired
    private RoleRepository roleRepository;

    public Role createRole(String roleName) {
        Role role = new Role(roleName);
        return roleRepository.save(role);
    }
    public RoleService(RoleRepository roleRepository) {
        this.roleRepository = roleRepository;
    }
    public Role findByName(String roleName) {
        return roleRepository.findByRoleName(roleName);
    }
}
