import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kfc/services_fix/voice_assistant_service.dart';
import 'package:kfc/providers/san_pham_provider.dart';
import 'package:kfc/providers/gio_hang_provider.dart';
import 'package:kfc/providers/nguoi_dung_provider.dart';
import 'package:kfc/models/san_pham_gio_hang.dart';
import 'package:kfc/screens/man_hinh_don_hang.dart';
import 'package:kfc/services_fix/don_hang_service.dart';
import 'package:kfc/models/don_hang.dart';
import 'package:kfc/models/san_pham.dart';
import 'package:kfc/services_fix/auth_service.dart';

class FloatingVoiceButton extends StatefulWidget {
  const FloatingVoiceButton({Key? key}) : super(key: key);

  @override
  State<FloatingVoiceButton> createState() => _FloatingVoiceButtonState();
}

class _FloatingVoiceButtonState extends State<FloatingVoiceButton> {
  final VoiceAssistantService _assistant = VoiceAssistantService();
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _assistant.init();
  }

  void _onResult(String text) async {
    setState(() => _listening = false);
    final lower = text.toLowerCase();

    final sanPhamProvider = Provider.of<SanPhamProvider>(context, listen: false);
    final gioHang = Provider.of<GioHangProvider>(context, listen: false);
    final nguoiDungProv = Provider.of<NguoiDungProvider>(context, listen: false);

    // Intent: open cart
    if (lower.contains('giỏ') || lower.contains('giỏ hàng') || lower.contains('mở giỏ')) {
      Navigator.pushNamed(context, '/cart');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mở giỏ hàng')));
      return;
    }

    // Intent: view orders/history
    if (lower.contains('lịch sử') || lower.contains('đơn hàng') || lower.contains('xem lịch sử')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ManHinhDonHang()));
      return;
    }

    // Intent: add product to cart
    if (lower.contains('thêm') || lower.contains('mua')) {
      // try to extract product name after keywords
      String name = '';
      final parts = lower.split(RegExp(r'thêm|mua|vào giỏ|vào giỏ hàng'));
      if (parts.length > 1) name = parts.last.trim();
      // fallback: remove keyword 'cho tôi' etc
      name = name.replaceAll(RegExp(r'cho tôi|một|mua'), '').trim();

      if (name.isNotEmpty) {
        // find product by name contains
        final all = sanPhamProvider.danhSachSanPham;
        SanPham? found;
        for (var p in all) {
          if (p.ten.toLowerCase().contains(name)) {
            found = p;
            break;
          }
        }
        if (found != null) {
          gioHang.themSanPham(SanPhamGioHang(sanPham: found, soLuong: 1));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${found.ten} vào giỏ hàng')));
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không tìm thấy sản phẩm: $name')));
          return;
        }
      }
    }

    // Intent: checkout / place order
    if (lower.contains('thanh toán') || lower.contains('đặt hàng') || lower.contains('thanh toan')) {
      // require confirmation via dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('Bạn muốn đặt đơn hàng tự động bằng giọng nói? (Phương thức: Nhận hàng trả tiền)'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xác nhận')),
          ],
        ),
      );
      if (confirm != true) return;

      // build DonHang from cart
      final uid = await AuthService.getStoredUid();
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập trước khi đặt hàng')));
        return;
      }
      final cartItems = gioHang.danhSachSanPham;
      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng trống')));
        return;
      }

      final tongTien = gioHang.tongTien;
      final phiGiao = 0.0;
      final tongCong = tongTien + phiGiao;

      final donHang = DonHang(
        id: '',
        nguoiDungId: uid,
        tenNguoiNhan: nguoiDungProv.nguoiDung?.ten ?? 'Khách',
        soDienThoai: nguoiDungProv.nguoiDung?.soDienThoai ?? '',
        diaChi: '',
        danhSachSanPham: cartItems,
        tongTien: tongTien,
        phiGiaoHang: phiGiao,
        tongCong: tongCong,
        trangThai: TrangThaiDonHang.dangXuLy,
        thoiGianDat: DateTime.now(),
      );

      try {
        final orderId = await DonHangService.createDonHang(donHang);
        gioHang.xoaGioHang();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã đặt hàng (ID: $orderId)')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đặt hàng thất bại: $e')));
      }
      return;
    }

    // Default: show recognized text
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nghe: "$text"')));
  }

  void _toggleListen() {
    if (_listening) {
      _assistant.stop();
      setState(() => _listening = false);
    } else {
      setState(() => _listening = true);
      _assistant.listen(_onResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 18,
      bottom: 80,
      child: FloatingActionButton(
        backgroundColor: _listening ? Colors.red : Theme.of(context).primaryColor,
        onPressed: _toggleListen,
        child: Icon(_listening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
