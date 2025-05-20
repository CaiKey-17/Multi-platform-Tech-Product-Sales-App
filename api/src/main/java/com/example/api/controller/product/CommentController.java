package com.example.api.controller.product;

import com.example.api.dto.CommentDTO;
import com.example.api.model.Comment;
import com.example.api.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/comments")
public class CommentController {
    @Autowired
    private  CommentService commentService;
    @Autowired
    private  SimpMessagingTemplate messagingTemplate;




    @GetMapping()
    public ResponseEntity<List<CommentDTO>> getComments(@RequestParam int id) {
        List<CommentDTO> comments = commentService.getCommentsByProductId(id);
        return ResponseEntity.ok(comments);
    }

    @PostMapping
    public ResponseEntity<CommentDTO> addComment(@RequestBody Comment comment) {
        CommentDTO savedComment = commentService.addComment(comment);

        messagingTemplate.convertAndSend("/topic/comments/" + comment.getProductId(), savedComment);

        return ResponseEntity.status(HttpStatus.CREATED).body(savedComment);
    }

    @PostMapping("/{commentId}/reply")
    public ResponseEntity<CommentDTO> replyToComment(@PathVariable Integer commentId, @RequestBody Comment reply) {
        CommentDTO savedReply = commentService.addReply(commentId, reply);

        messagingTemplate.convertAndSend("/topic/replies/" + commentId, savedReply);

        return ResponseEntity.status(HttpStatus.CREATED).body(savedReply);
    }

}
