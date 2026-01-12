import 'package:flutter/foundation.dart';
import 'package:kfc/models/thong_bao.dart';

class ThongBaoProvider with ChangeNotifier {
  List<ThongBao> _danhSachThongBao = [];
  bool _isLoading = false;

  List<ThongBao> get danhSachThongBao => _danhSachThongBao;
  bool get isLoading => _isLoading;

  int get soThongBaoChuaDoc => _danhSachThongBao.where((tb) => !tb.daDoc).length;

  List<ThongBao> get thongBaoChuaDoc => _danhSachThongBao.where((tb) => !tb.daDoc).toList();

  // Khởi tạo dữ liệu mẫu
  void khoiTaoDuLieuMau() {
    _danhSachThongBao = [
      ThongBao(
        id: '1',
        tieuDe: 'Chào mừng bạn đến với KFC!',
        noiDung: 'Cảm ơn bạn đã tải ứng dụng. Hãy khám phá các món ăn ngon và ưu đãi hấp dẫn!',
        thoiGian: DateTime.now().subtract(const Duration(hours: 1)),
        loai: 'hethong',
      ),
      ThongBao(
        id: '2',
        tieuDe: 'Giảm giá 20% cho đơn hàng đầu tiên',
        noiDung: 'Nhập mã KFCFIRST để được giảm 20% cho đơn hàng đầu tiên của bạn!',
        thoiGian: DateTime.now().subtract(const Duration(hours: 3)),
        loai: 'khuyenmai',
        daDoc: true,
      ),
      ThongBao(
        id: '3',
        tieuDe: 'Đơn hàng của bạn đã được xác nhận',
        noiDung: 'Đơn hàng #12345678 đã được xác nhận và đang được chuẩn bị.',
        thoiGian: DateTime.now().subtract(const Duration(days: 1)),
        loai: 'donhang',
        daDoc: true,
      ),
    ];
    notifyListeners();
  }

  Future<void> taiThongBao(String? nguoiDungId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Gọi API để lấy thông báo từ server
      // final response = await ThongBaoService.getThongBao(nguoiDungId);
      // _danhSachThongBao = response;
      
      // Tạm thời dùng dữ liệu mẫu
      await Future.delayed(const Duration(milliseconds: 500));
      khoiTaoDuLieuMau();
    } catch (e) {
      print('Lỗi khi tải thông báo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void themThongBao(ThongBao thongBao) {
    _danhSachThongBao.insert(0, thongBao);
    notifyListeners();
  }

  Future<void> danhDauDaDoc(String thongBaoId) async {
    final index = _danhSachThongBao.indexWhere((tb) => tb.id == thongBaoId);
    if (index != -1) {
      _danhSachThongBao[index] = _danhSachThongBao[index].copyWith(daDoc: true);
      notifyListeners();
      
      // TODO: Gọi API để update trạng thái đã đọc
      // await ThongBaoService.danhDauDaDoc(thongBaoId);
    }
  }

  Future<void> danhDauTatCaDaDoc() async {
    _danhSachThongBao = _danhSachThongBao
        .map((tb) => tb.copyWith(daDoc: true))
        .toList();
    notifyListeners();
    
    // TODO: Gọi API để update tất cả
    // await ThongBaoService.danhDauTatCaDaDoc();
  }

  Future<void> xoaThongBao(String thongBaoId) async {
    _danhSachThongBao.removeWhere((tb) => tb.id == thongBaoId);
    notifyListeners();
    
    // TODO: Gọi API để xóa thông báo
    // await ThongBaoService.xoaThongBao(thongBaoId);
  }

  void xoaTatCa() {
    _danhSachThongBao.clear();
    notifyListeners();
  }

  // Lọc thông báo chưa đọc
  List<ThongBao> layThongBaoChuaDoc() {
    return _danhSachThongBao.where((tb) => !tb.daDoc).toList();
  }

  // Lọc thông báo theo loại
  List<ThongBao> layThongBaoTheoLoai(String loai) {
    return _danhSachThongBao.where((tb) => tb.loai == loai).toList();
  }
}
