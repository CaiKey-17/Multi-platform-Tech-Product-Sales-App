package com.example.api.luan.service;

import com.example.api.luan.dto.UserInfoDTO;
import com.example.api.model.Users;
import com.example.api.repository.UsersRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class UserAdminService {
    @Autowired
    private UsersRepository usersRepository;

    public List<UserInfoDTO> getAllUsers() {
        List<Users> users = usersRepository.findAllUsersWithRoleId2();

        List<UserInfoDTO> dtoList = new ArrayList<>();
        for (Users user : users) {
            String roleName = user.getRoles().isEmpty() ? "" : user.getRoles().getClass().getName();

            UserInfoDTO dto = new UserInfoDTO();
            dto.setId(user.getId());
            dto.setEmail(user.getEmail());
            dto.setFullName(user.getFullName());
            dto.setRole(roleName);
            dto.setAddresses(Collections.emptyList());
            dto.setActive(user.getActive() != null ? user.getActive() : 0);
            dto.setTempId(user.getTempId());
            dto.setCreatedAt("");
            dto.setPoints(0);
            dto.setCodes(Collections.emptyList());
            dto.setImage(user.getImage());

            dtoList.add(dto);
        }

        return dtoList;
    }


    public Optional<UserInfoDTO> getUserById(Integer id) {
        Optional<Users> optionalUser = usersRepository.findById(id);

        if (optionalUser.isEmpty()) {
            return Optional.empty();
        }

        Users user = optionalUser.get();

        String roleName = user.getRoles().isEmpty() ? "" : user.getRoles().getClass().getName();

        UserInfoDTO dto = new UserInfoDTO();
        dto.setId(user.getId());
        dto.setEmail(user.getEmail());
        dto.setFullName(user.getFullName());
        dto.setRole(roleName);
        dto.setAddresses(Collections.emptyList());
        dto.setActive(user.getActive() != null ? user.getActive() : 0);
        dto.setTempId(user.getTempId());
        dto.setCreatedAt(user.getCreatedAt() != null ? user.getCreatedAt().toString() : "");
        dto.setPoints(0); // nếu có points thì xử lý thêm
        dto.setCodes(Collections.emptyList());
        dto.setImage(user.getImage());

        return Optional.of(dto);
    }


    public boolean toggleActiveStatus(Integer id) {
        Optional<Users> optionalUser = usersRepository.findById(id);
        if (optionalUser.isPresent()) {
            Users user = optionalUser.get();
            Integer currentStatus = user.getActive();
            Integer newStatus = (currentStatus != null && currentStatus == 1) ? 0 : 1;

            usersRepository.updateUserActiveById(id, newStatus);
            return true;
        } else {
            return false;
        }
    }

    public boolean deleteUserById(Integer id) {
        if (usersRepository.existsById(id)) {
            usersRepository.deleteById(id);
            return true;
        }
        return false;
    }

    @Transactional
    public boolean updateFullName(Integer id, String fullName) {
        Optional<Users> optionalUser = usersRepository.findById(id);
        if (optionalUser.isPresent()) {
            usersRepository.updateFullNameById(id, fullName);
            return true;
        }
        return false;
    }


}