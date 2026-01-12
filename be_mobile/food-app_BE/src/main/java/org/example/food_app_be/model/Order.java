package org.example.food_app_be.model;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.Instant;
import java.util.List;

@Document(collection = "orders")
@JsonIgnoreProperties(ignoreUnknown = true)
public class Order {
    public enum TrangThaiDonHang {
        dangXuLy,
        dangGiao,
        daGiao,
        daHuy
    }
    @Id
    @JsonProperty("_id")
    private String id;
    private String nguoiDungId;
    private String tenNguoiNhan;
    private String soDienThoai;
    private String diaChi;
    private List<OrderItem> danhSachSanPham;
    private double tongTien;
    private double phiGiaoHang;
    private double tongCong;
    private TrangThaiDonHang trangThai;
    private Instant thoiGianDat;
    private String ghiChu;
    private String phuongThucThanhToan;

    public Order() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getNguoiDungId() {
        return nguoiDungId;
    }

    public void setNguoiDungId(String nguoiDungId) {
        this.nguoiDungId = nguoiDungId;
    }

    public String getTenNguoiNhan() {
        return tenNguoiNhan;
    }

    public void setTenNguoiNhan(String tenNguoiNhan) {
        this.tenNguoiNhan = tenNguoiNhan;
    }

    public String getSoDienThoai() {
        return soDienThoai;
    }

    public void setSoDienThoai(String soDienThoai) {
        this.soDienThoai = soDienThoai;
    }

    public String getDiaChi() {
        return diaChi;
    }

    public void setDiaChi(String diaChi) {
        this.diaChi = diaChi;
    }

    public List<OrderItem> getDanhSachSanPham() {
        return danhSachSanPham;
    }

    public void setDanhSachSanPham(List<OrderItem> danhSachSanPham) {
        this.danhSachSanPham = danhSachSanPham;
    }

    public double getTongTien() {
        return tongTien;
    }

    public void setTongTien(double tongTien) {
        this.tongTien = tongTien;
    }

    public double getPhiGiaoHang() {
        return phiGiaoHang;
    }

    public void setPhiGiaoHang(double phiGiaoHang) {
        this.phiGiaoHang = phiGiaoHang;
    }

    public double getTongCong() {
        return tongCong;
    }

    public void setTongCong(double tongCong) {
        this.tongCong = tongCong;
    }

    public TrangThaiDonHang getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(TrangThaiDonHang trangThai) {
        this.trangThai = trangThai;
    }

    public Instant getThoiGianDat() {
        return thoiGianDat;
    }

    public void setThoiGianDat(Instant thoiGianDat) {
        this.thoiGianDat = thoiGianDat;
    }

    public String getGhiChu() {
        return ghiChu;
    }

    public void setGhiChu(String ghiChu) {
        this.ghiChu = ghiChu;
    }

    public String getPhuongThucThanhToan() {
        return phuongThucThanhToan;
    }

    public void setPhuongThucThanhToan(String phuongThucThanhToan) {
        this.phuongThucThanhToan = phuongThucThanhToan;
    }
}
