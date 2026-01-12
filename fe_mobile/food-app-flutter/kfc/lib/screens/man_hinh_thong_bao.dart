import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/thong_bao_provider.dart';
import '../models/thong_bao.dart';
import '../theme/mau_sac.dart';

class ManHinhThongBao extends StatefulWidget {
  const ManHinhThongBao({Key? key}) : super(key: key);

  @override
  State<ManHinhThongBao> createState() => _ManHinhThongBaoState();
}

class _ManHinhThongBaoState extends State<ManHinhThongBao> {
  String _loaiHienTai = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThongBaoProvider>(context, listen: false).khoiTaoDuLieuMau();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        centerTitle: true,
        backgroundColor: MauSac.kfcRed,
        foregroundColor: Colors.white,
        actions: [
          Consumer<ThongBaoProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: () {
                  for (var thongBao in provider.danhSachThongBao) {
                    if (!thongBao.daDoc) {
                      provider.danhDauDaDoc(thongBao.id);
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đọc tất cả thông báo')),
                  );
                },
                child: const Text(
                  'Đọc tất cả',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tất cả', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Chưa đọc', 'unread'),
            const SizedBox(width: 8),
            _buildFilterChip('Đơn hàng', 'donHang'),
            const SizedBox(width: 8),
            _buildFilterChip('Khuyến mãi', 'khuyenMai'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _loaiHienTai == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _loaiHienTai = value;
        });
      },
      backgroundColor: Colors.grey[200],
      selectedColor: MauSac.kfcRed.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? MauSac.kfcRed : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ThongBaoProvider>(
      builder: (context, provider, child) {
        List<ThongBao> danhSach;
        
        if (_loaiHienTai == 'all') {
          danhSach = provider.danhSachThongBao;
        } else if (_loaiHienTai == 'unread') {
          danhSach = provider.layThongBaoChuaDoc();
        } else {
          danhSach = provider.layThongBaoTheoLoai(_loaiHienTai);
        }

        if (danhSach.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Không có thông báo',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: danhSach.length,
          itemBuilder: (context, index) {
            final thongBao = danhSach[index];
            return Dismissible(
              key: Key(thongBao.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) {
                provider.xoaThongBao(thongBao.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa: ${thongBao.tieuDe}')),
                );
              },
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: thongBao.daDoc ? 0 : 2,
                color: thongBao.daDoc ? Colors.white : MauSac.kfcRed.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: thongBao.daDoc 
                        ? Colors.grey[300] 
                        : MauSac.kfcRed.withOpacity(0.2),
                    child: Icon(
                      _getIconTheoLoai(thongBao.loai),
                      color: thongBao.daDoc ? Colors.grey[600] : MauSac.kfcRed,
                    ),
                  ),
                  title: Text(
                    thongBao.tieuDe,
                    style: TextStyle(
                      fontWeight: thongBao.daDoc ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        thongBao.noiDung,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(thongBao.thoiGian),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  trailing: !thongBao.daDoc
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: MauSac.kfcRed,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                  onTap: () {
                    if (!thongBao.daDoc) {
                      provider.danhDauDaDoc(thongBao.id);
                    }
                    _showThongBaoDetail(context, thongBao);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconTheoLoai(String loai) {
    switch (loai) {
      case 'donHang':
        return Icons.shopping_bag;
      case 'khuyenMai':
        return Icons.local_offer;
      case 'thongBao':
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showThongBaoDetail(BuildContext context, ThongBao thongBao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(thongBao.tieuDe),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(thongBao.noiDung),
            const SizedBox(height: 16),
            Text(
              _formatTime(thongBao.thoiGian),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
