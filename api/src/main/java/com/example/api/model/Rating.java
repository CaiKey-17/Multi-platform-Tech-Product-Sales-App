package com.example.api.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "rating")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Rating {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Integer rating;
    private String name;


    private String content;
    private Integer sentiment;
    @Column(name = "id_fk_customer",  nullable = true)
    private Integer id_fk_customer;

    @Column(name = "id_fk_product",  nullable = true)
    private Integer id_fk_product;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Integer getSentiment() {
        return sentiment;
    }

    public void setSentiment(Integer sentiment) {
        this.sentiment = sentiment;
    }

    public Integer getId_fk_customer() {
        return id_fk_customer;
    }

    public void setId_fk_customer(Integer id_fk_customer) {
        this.id_fk_customer = id_fk_customer;
    }

    public Integer getId_fk_product() {
        return id_fk_product;
    }

    public void setId_fk_product(Integer id_fk_product) {
        this.id_fk_product = id_fk_product;
    }
}
