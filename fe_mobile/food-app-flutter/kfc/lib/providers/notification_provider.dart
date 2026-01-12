import 'package:flutter/material.dart';
import '../models/thong_bao.dart';
import '../services/notification_service.dart';
import 'dart:async';

class NotificationProvider extends ChangeNotifier {
  List<ThongBao> _danhSachThongBao = [];
  bool _dangTai = false;
  String? _loi;
  bool _isFirebaseConnected = false;
  bool _collectionExists = false;
  StreamSubscription<List<ThongBao>>? _notificationSubscription;

  List<ThongBao> get danhSachThongBao => _danhSachThongBao;
  bool get dangTai => _dangTai;
  String? get loi => _loi;
  bool get isFirebaseConnected => _isFirebaseConnected;
  bool get collectionExists => _collectionExists;

  // Lấy số lượng thông báo chưa đọc
  int get soThongBaoChuaDoc {
    return _danhSachThongBao.where((tb) => !tb.daDoc).length;
  }

  // Lấy thông báo mới nhất chưa đọc
  List<ThongBao> get thongBaoChuaDoc {
    return _danhSachThongBao.where((tb) => !tb.daDoc).toList();
  }

  // Khởi tạo và kiểm tra Firebase
  void initialize() {
    // Tạm thời không dùng Firebase – giữ trạng thái rỗng
    _isFirebaseConnected = false;
    _collectionExists = false;
    _danhSachThongBao = [];
    _dangTai = false;
    _loi = null;
    notifyListeners();
  }

  // Các hàm liên quan Firebase tạm thời bỏ trống
  void _initializeFirebaseConnection() {}
  Future<void> _checkCollectionAndListen() async {}
  void _listenToNotifications() {}

  // Tải danh sách thông báo
  Future<void> taiDanhSachThongBao() async {
    _dangTai = false;
    _loi = null;
    _danhSachThongBao = [];
    _collectionExists = false;
    _isFirebaseConnected = false;
    notifyListeners();
  }

  // Đánh dấu thông báo đã đọc
  Future<void> danhDauDaDoc(String notificationId) async {
    if (!_collectionExists) return;
    
    try {
      await NotificationService.markAsRead(notificationId);
      
      // Cập nhật local state
      final index = _danhSachThongBao.indexWhere((tb) => tb.id == notificationId);
      if (index != -1) {
        _danhSachThongBao[index] = _danhSachThongBao[index].copyWith(daDoc: true);
        notifyListeners();
      }
    } catch (e) {
      print('Lỗi khi đánh dấu đã đọc: $e');
    }
  }

  // Đánh dấu tất cả đã đọc
  Future<void> danhDauTatCaDaDoc() async {
    if (!_collectionExists) return;
    
    try {
      final chuaDoc = thongBaoChuaDoc;
      for (final thongBao in chuaDoc) {
        await NotificationService.markAsRead(thongBao.id);
      }
      
      // Cập nhật local state
      _danhSachThongBao = _danhSachThongBao.map((tb) => 
          tb.copyWith(daDoc: true)).toList();
      notifyListeners();
    } catch (e) {
      print('Lỗi khi đánh dấu tất cả đã đọc: $e');
    }
  }

  // Xóa thông báo
  Future<void> xoaThongBao(String notificationId) async {
    if (!_collectionExists) return;
    
    try {
      await NotificationService.deleteNotification(notificationId);
      
      // Cập nhật local state
      _danhSachThongBao.removeWhere((tb) => tb.id == notificationId);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi xóa thông báo: $e');
    }
  }

  // Lọc thông báo theo loại
  List<ThongBao> layThongBaoTheoLoai(String loai) {
    return _danhSachThongBao.where((tb) => tb.loai == loai).toList();
  }

  // Reset provider
  void reset() {
    _danhSachThongBao = [];
    _dangTai = false;
    _loi = null;
    _collectionExists = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }
}
