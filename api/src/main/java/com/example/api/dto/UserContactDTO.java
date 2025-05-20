package com.example.api.dto;

import java.util.Date;

public class UserContactDTO {
    private Integer userId;
    private String fullName;
    private String image;
    private String lastMessage;
    private Date lastMessageTime;

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public UserContactDTO(Integer userId, String fullName, String image, String lastMessage, Date lastMessageTime) {
        this.userId = userId;
        this.image = image;
        this.fullName = fullName;
        this.lastMessage = lastMessage;
        this.lastMessageTime = lastMessageTime;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getLastMessage() {
        return lastMessage;
    }

    public void setLastMessage(String lastMessage) {
        this.lastMessage = lastMessage;
    }

    public Date getLastMessageTime() {
        return lastMessageTime;
    }

    public void setLastMessageTime(Date lastMessageTime) {
        this.lastMessageTime = lastMessageTime;
    }

    // Getters và Setters
}
