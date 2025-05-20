package com.example.api.service;

import com.example.api.dto.CommentDTO;
import com.example.api.model.Comment;
import com.example.api.repository.CommentRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class CommentService {
    private final CommentRepository commentRepository;

    public CommentService(CommentRepository commentRepository) {
        this.commentRepository = commentRepository;
    }

    public List<CommentDTO> getCommentsByProductId(Integer productId) {
        List<Comment> topLevelComments = commentRepository.findByProductId(productId);
        return topLevelComments.stream().map(this::convertToDTO).collect(Collectors.toList());
    }

    public CommentDTO addComment(Comment comment) {
        comment.setCreatedAt(new Date());
        return convertToDTO(commentRepository.save(comment));
    }
    public CommentDTO addReply(Integer commentId, Comment reply) {
        Comment parentComment = commentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("Comment not found"));

        reply.setParentComment(parentComment);
        reply.setCreatedAt(new Date());

        Comment savedReply = commentRepository.save(reply);

        return convertToDTO(savedReply);
    }
    private CommentDTO convertToDTO(Comment comment) {
        List<CommentDTO> replyDTOs = (comment.getReplies() != null) ?
                comment.getReplies().stream().map(this::convertToDTO).collect(Collectors.toList()) : new ArrayList<>();

        return new CommentDTO(
                comment.getId(),
                comment.getProductId(),
                comment.getUsername(),
                comment.getContent(),
                comment.getCreatedAt(),
                comment.getParentComment() != null ? comment.getParentComment().getId() : null,
                replyDTOs,
                comment.getRole()
        );
    }


}
