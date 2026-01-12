package org.example.food_app_be.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.List;

@Document(collection = "users")
public class User {
    @Id
    private String id;  // MongoDB _id sẽ tự động sinh nếu null

    private String ten;
    private String email;
    private String password;
    private String soDienThoai;
    private String rule; // user / admin
    private Boolean trangThaiHoatDong;
    private Date ngayTao;
    private List<String> vaiTro; // array như superAdmin, quanLyDonHang
    private String otp; // Mã OTP để reset password
    private Date otpExpiry; // Thời gian hết hạn của OTP

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getRule() {
        return rule;
    }

    public void setRule(String rule) {
        this.rule = rule;
    }

    public Boolean getTrangThaiHoatDong() {
        return trangThaiHoatDong;
    }

    public void setTrangThaiHoatDong(Boolean trangThaiHoatDong) {
        this.trangThaiHoatDong = trangThaiHoatDong;
    }

    public Date getNgayTao() {
        return ngayTao;
    }

    public void setNgayTao(Date ngayTao) {
        this.ngayTao = ngayTao;
    }

    public List<String> getVaiTro() {
        return vaiTro;
    }

    public void setVaiTro(List<String> vaiTro) {
        this.vaiTro = vaiTro;
    }

    public String getOtp() {
        return otp;
    }

    public void setOtp(String otp) {
        this.otp = otp;
    }

    public Date getOtpExpiry() {
        return otpExpiry;
    }

    public void setOtpExpiry(Date otpExpiry) {
        this.otpExpiry = otpExpiry;
    }

    @Override
    public String toString() {
        return "User{" +
                "id='" + id + '\'' +
                ", ten='" + ten + '\'' +
                ", email='" + email + '\'' +
                ", soDienThoai='" + soDienThoai + '\'' +
                ", rule='" + rule + '\'' +
                ", trangThaiHoatDong=" + trangThaiHoatDong +
                ", ngayTao=" + ngayTao +
                ", vaiTro=" + vaiTro +
                '}';
    }
}
