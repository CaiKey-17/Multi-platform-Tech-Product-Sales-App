package com.example.api.dto;


public class PerformanceDataDTO {

    private String thoiGian;
    private int tongSoDon;
    private double tongDoanhThu;
    private double tongLoiNhuan;

    // Constructor, Getter và Setter
    public PerformanceDataDTO(String thoiGian, int tongSoDon, double tongDoanhThu, double tongLoiNhuan) {
        this.thoiGian = thoiGian;
        this.tongSoDon = tongSoDon;
        this.tongDoanhThu = tongDoanhThu;
        this.tongLoiNhuan = tongLoiNhuan;
    }

    public String getThoiGian() {
        return thoiGian;
    }

    public void setThoiGian(String thoiGian) {
        this.thoiGian = thoiGian;
    }

    public int getTongSoDon() {
        return tongSoDon;
    }

    public void setTongSoDon(int tongSoDon) {
        this.tongSoDon = tongSoDon;
    }

    public double getTongDoanhThu() {
        return tongDoanhThu;
    }

    public void setTongDoanhThu(double tongDoanhThu) {
        this.tongDoanhThu = tongDoanhThu;
    }

    public double getTongLoiNhuan() {
        return tongLoiNhuan;
    }

    public void setTongLoiNhuan(double tongLoiNhuan) {
        this.tongLoiNhuan = tongLoiNhuan;
    }
}
