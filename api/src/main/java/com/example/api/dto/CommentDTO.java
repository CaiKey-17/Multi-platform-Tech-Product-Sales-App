package com.example.api.dto;

import com.example.api.model.Comment;

import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class CommentDTO {
    private Integer id;
    private String username;
    private String role;
    private String content;
    private Date createdAt;
    private List<CommentDTO> replies;
    private Integer productId;

    private Integer parentCommentId;

    public CommentDTO(Integer id, Integer productId, String username, String content, Date createdAt, List<CommentDTO> replies) {
        this.id = id;
        this.productId = productId;
        this.username = username;
        this.content = content;
        this.createdAt = createdAt;
        this.replies = replies;
    }

    public CommentDTO(Integer id, Integer productId, String username, String content,
                      Date createdAt, Integer parentCommentId, List<CommentDTO> replies,String role) {
        this.id = id;
        this.productId = productId;
        this.username = username;
        this.content = content;
        this.createdAt = createdAt;
        this.parentCommentId = parentCommentId;
        this.replies = replies;
        this.role = role;
    }



    public long getDaysAgo() {
        long diffMillis = new Date().getTime() - createdAt.getTime();
        return TimeUnit.MILLISECONDS.toDays(diffMillis);
    }

    // Getters and Setters


    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Integer getParentCommentId() {
        return parentCommentId;
    }

    public void setParentCommentId(Integer parentCommentId) {
        this.parentCommentId = parentCommentId;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public List<CommentDTO> getReplies() {
        return replies;
    }

    public void setReplies(List<CommentDTO> replies) {
        this.replies = replies;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }
}
