package com.example.api.repository;

import com.example.api.model.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;
public interface RoleRepository extends JpaRepository<Role, Integer> {
    Role findByRoleName(String roleName);
}