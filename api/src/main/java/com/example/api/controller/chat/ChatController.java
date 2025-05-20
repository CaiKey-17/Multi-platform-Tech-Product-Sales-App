package com.example.api.controller.chat;

import com.example.api.dto.UserContactDTO;
import com.example.api.model.Message;
import com.example.api.repository.MessageRepository;
import com.example.api.repository.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
@Controller
@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private final MessageRepository  messageRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public ChatController(MessageRepository messageRepository) {
        this.messageRepository = messageRepository;
    }


    @MessageMapping("/sendMessage")
    public void sendMessage(@Payload Message message) {
        message.setSentAt(new Date());
        messageRepository.save(message);

        messagingTemplate.convertAndSend("/topic/chat", message);
    }
    @GetMapping("/messages/{userId}/{otherUserId}")
    public List<Message> getChatHistory(
            @PathVariable Integer userId,
            @PathVariable Integer otherUserId) {
        return messageRepository.findMessagesByUserIds(userId, otherUserId);
    }


    @GetMapping("/contacts/{userId}")
    public ResponseEntity<List<UserContactDTO>> getUserContacts(@PathVariable Integer userId) {
        List<Object[]> results = messageRepository.findDistinctContacts(userId);

        List<UserContactDTO> contacts = results.stream()
                .map(row -> new UserContactDTO(
                        ((Number) row[0]).intValue(),
                        (String) row[1],
                        row[2] != null ? (String) row[2] : "",
                        (String) row[3],
                        (Date) row[4]
                ))
                .toList();

        return ResponseEntity.ok(contacts);
    }

}