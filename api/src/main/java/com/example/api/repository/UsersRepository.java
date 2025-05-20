package com.example.api.repository;

import com.example.api.model.Users;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public interface UsersRepository extends JpaRepository<Users, Integer> {
    Optional<Users> findByEmail(String email);

    @Query("SELECT u.id FROM Users u WHERE u.email = :email")
    Optional<Integer> findIdByEmail(@Param("email") String email);

    boolean existsByEmail(String email);

    Users findByResetToken(String resetToken);

    Optional<Users> findByTempId(String tempId);

    @Modifying
    @Transactional
    @Query("UPDATE Users u SET u.active = :active WHERE u.id = :id")
    void updateUserActiveById(@Param("id") Integer id, @Param("active") Integer active);

    @Modifying
    @Query("UPDATE Users u SET u.fullName = :fullName WHERE u.id = :id")
    void updateFullNameById(@Param("id") Integer id, @Param("fullName") String fullName);
    Optional<Users> findById(Integer id);


    @Query("SELECT " +
            "COUNT(u) AS total_users, " +
            "SUM(CASE " +
            "WHEN FUNCTION('MONTH', u.createdAt) = FUNCTION('MONTH', CURRENT_DATE) " +
            "AND FUNCTION('YEAR', u.createdAt) = FUNCTION('YEAR', CURRENT_DATE) THEN 1 " +
            "ELSE 0 " +
            "END) AS new_users " +
            "FROM Users u " +
            "JOIN u.roles r " +
            "WHERE r.id = 2")
    Map<String, Long> getTotalUsersAndNewUsers();

    @Query("SELECT u FROM Users u JOIN u.roles r WHERE r.id = 2")
    List<Users> findAllUsersWithRoleId2();

}

