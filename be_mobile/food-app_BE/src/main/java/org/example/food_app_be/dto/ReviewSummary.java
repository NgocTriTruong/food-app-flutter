package org.example.food_app_be.dto;

import java.util.HashMap;
import java.util.Map;

public class ReviewSummary {
    private double diemTrungBinh;
    private long tongSoDanhGia;
    private Map<Integer, Long> phanBoSao;

    public ReviewSummary() {
        this.phanBoSao = new HashMap<>();
    }

    public double getDiemTrungBinh() {
        return diemTrungBinh;
    }

    public void setDiemTrungBinh(double diemTrungBinh) {
        this.diemTrungBinh = diemTrungBinh;
    }

    public long getTongSoDanhGia() {
        return tongSoDanhGia;
    }

    public void setTongSoDanhGia(long tongSoDanhGia) {
        this.tongSoDanhGia = tongSoDanhGia;
    }

    public Map<Integer, Long> getPhanBoSao() {
        return phanBoSao;
    }

    public void setPhanBoSao(Map<Integer, Long> phanBoSao) {
        this.phanBoSao = phanBoSao;
    }
}
