package org.example.food_app_be.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;
import java.util.List;

@Document(collection = "users")
public class User {

    @Id
    private String id; // MongoDB _id

    // ===== Thông tin cơ bản =====
    private String ten;
    private String email;
    private String password; // null nếu login Google
    private String soDienThoai;

    // ===== Phân quyền =====
    private String rule;              // user / admin
    private List<String> vaiTro;       // superAdmin, quanLyDonHang...

    // ===== Auth provider =====
    private AuthProvider provider;     // LOCAL | GOOGLE
    private String googleId;           // chỉ có nếu GOOGLE
    private String avatar;             // ảnh đại diện (Google)

    // ===== Trạng thái =====
    private Boolean trangThaiHoatDong;
    private Date ngayTao;

    // ===== OTP reset password =====
    private String otp;
    private Date otpExpiry;

    // ================== Constructors ==================

    public User() {
        this.ngayTao = new Date();
        this.trangThaiHoatDong = true;
        this.provider = AuthProvider.LOCAL;
        this.rule = "user";
    }

    // ================== Getters & Setters ==================

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

    // password = null nếu Google
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

    public List<String> getVaiTro() {
        return vaiTro;
    }

    public void setVaiTro(List<String> vaiTro) {
        this.vaiTro = vaiTro;
    }

    public AuthProvider getProvider() {
        return provider;
    }

    public void setProvider(AuthProvider provider) {
        this.provider = provider;
    }

    public String getGoogleId() {
        return googleId;
    }

    public void setGoogleId(String googleId) {
        this.googleId = googleId;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
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

    // ================== Helper methods ==================

    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(this.rule);
    }

    public boolean isGoogleUser() {
        return AuthProvider.GOOGLE.equals(this.provider);
    }

    public boolean isLocalUser() {
        return AuthProvider.LOCAL.equals(this.provider);
    }

    @Override
    public String toString() {
        return "User{" +
                "id='" + id + '\'' +
                ", ten='" + ten + '\'' +
                ", email='" + email + '\'' +
                ", rule='" + rule + '\'' +
                ", provider=" + provider +
                ", vaiTro=" + vaiTro +
                ", trangThaiHoatDong=" + trangThaiHoatDong +
                ", ngayTao=" + ngayTao +
                '}';
    }
}
