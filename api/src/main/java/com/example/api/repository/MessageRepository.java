package com.example.api.repository;

import com.example.api.dto.UserContactDTO;
import com.example.api.model.Message;
import com.example.api.model.Order_detail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Integer> {

    @Query("SELECT m FROM Message m WHERE (m.sender_id = :userId AND m.receiver_id = :otherUserId) OR (m.sender_id = :otherUserId AND m.receiver_id = :userId) ORDER BY m.sentAt ASC")
    List<Message> findMessagesByUserIds(@Param("userId") Integer userId, @Param("otherUserId") Integer otherUserId);

    @Query(value = """
    SELECT 
        u.id AS userId,
        u.full_name AS fullName,
        u.image AS image,
        m2.content AS lastMessage,
        m2.sent_at AS lastMessageTime
    FROM users u
    JOIN (
        SELECT 
            CASE 
                WHEN sender_id = :userId THEN receiver_id
                ELSE sender_id
            END AS contact_id,
            MAX(sent_at) AS latest_time
        FROM messages
        WHERE sender_id = :userId OR receiver_id = :userId
        GROUP BY contact_id
    ) AS latest_msg ON u.id = latest_msg.contact_id
    JOIN messages m2 ON (
        ((m2.sender_id = :userId AND m2.receiver_id = u.id) OR 
         (m2.receiver_id = :userId AND m2.sender_id = u.id))
        AND m2.sent_at = latest_msg.latest_time
    )
    ORDER BY latest_msg.latest_time DESC
    """, nativeQuery = true)
    List<Object[]> findDistinctContacts(@Param("userId") Integer userId);


}
