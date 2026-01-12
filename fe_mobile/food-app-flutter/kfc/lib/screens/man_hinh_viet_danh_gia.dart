import 'package:flutter/material.dart';
import 'package:kfc/models/san_pham.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/models/danh_gia.dart';
import 'package:kfc/services_fix/danh_gia_service.dart';
import 'package:kfc/providers/nguoi_dung_provider.dart';
import 'package:provider/provider.dart';

class ManHinhVietDanhGia extends StatefulWidget {
  final SanPham sanPham;
  final DanhGia? danhGiaCu;

  const ManHinhVietDanhGia({
    Key? key,
    required this.sanPham,
    this.danhGiaCu,
  }) : super(key: key);

  @override
  State<ManHinhVietDanhGia> createState() => _ManHinhVietDanhGiaState();
}

class _ManHinhVietDanhGiaState extends State<ManHinhVietDanhGia>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _binhLuanController = TextEditingController();
  
  int _soSao = 5;
  bool _dangGui = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    if (widget.danhGiaCu != null) {
      _soSao = widget.danhGiaCu!.soSao;
      _binhLuanController.text = widget.danhGiaCu!.binhLuan;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _binhLuanController.dispose();
    super.dispose();
  }

  String _getImagePath(String hinhAnh) {
    if (hinhAnh.isEmpty) return '';
    if (hinhAnh.startsWith('assets/')) return hinhAnh;
    return 'assets/images/$hinhAnh';
  }

  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MauSac.kfcRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              child: _getImagePath(widget.sanPham.hinhAnh).isNotEmpty
                  ? Image.asset(
                      _getImagePath(widget.sanPham.hinhAnh),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: MauSac.kfcRed.withOpacity(0.8),
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.white,
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: MauSac.kfcRed.withOpacity(0.8),
                      child: const Icon(
                        Icons.fastfood,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sanPham.ten,
                  style: const TextStyle(
                    color: MauSac.trang,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.sanPham.gia.round()} ₫',
                  style: const TextStyle(
                    color: MauSac.kfcRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MauSac.kfcRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star, color: MauSac.vang, size: 24),
              SizedBox(width: 8),
              Text(
                'Đánh giá của bạn',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _soSao = index + 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      index < _soSao ? Icons.star : Icons.star_border,
                      color: MauSac.vang,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Text(
              _getRatingDescription(_soSao),
              style: TextStyle(
                color: _getRatingColor(_soSao),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Rất không hài lòng';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
        return 'Rất hài lòng';
      default:
        return 'Chọn đánh giá';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return MauSac.kfcRed;
      case 3:
        return MauSac.cam;
      case 4:
      case 5:
        return MauSac.xanhLa;
      default:
        return MauSac.xam;
    }
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MauSac.kfcRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.comment, color: MauSac.kfcRed, size: 24),
              SizedBox(width: 8),
              Text(
                'Chia sẻ trải nghiệm',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _binhLuanController,
            maxLines: 5,
            maxLength: 500,
            style: const TextStyle(color: MauSac.trang),
            decoration: InputDecoration(
              hintText: 'Chia sẻ cảm nhận của bạn về món ăn này...',
              hintStyle: TextStyle(color: MauSac.xam.withOpacity(0.6)),
              filled: true,
              fillColor: MauSac.denNen,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: MauSac.xam.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: MauSac.xam.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: MauSac.kfcRed),
              ),
              counterStyle: TextStyle(color: MauSac.xam.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _dangGui ? null : _guiDanhGia,
        style: ElevatedButton.styleFrom(
          backgroundColor: MauSac.kfcRed,
          foregroundColor: MauSac.trang,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
        ),
        child: _dangGui
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: MauSac.trang,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Đang gửi...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                  'Gửi đánh giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _guiDanhGia() async {
    final user = context.read<NguoiDungProvider>().nguoiDung;
    if (user == null) {
      _showErrorSnackBar('Vui lòng đăng nhập để đánh giá');
      return;
    }

    if (_binhLuanController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập bình luận');
      return;
    }

    setState(() {
      _dangGui = true;
    });

    try {
      final isEdit = widget.danhGiaCu != null;

      bool ok = false;
      if (isEdit) {
        ok = await DanhGiaService.capNhatDanhGia(
          widget.danhGiaCu!.id,
          _soSao,
          _binhLuanController.text.trim(),
        );
      } else {
        final danhGia = DanhGia(
          id: '',
          sanPhamId: widget.sanPham.id,
          nguoiDungId: user.id,
          tenNguoiDung: user.ten.isNotEmpty ? user.ten : 'Người dùng',
          soSao: _soSao,
          binhLuan: _binhLuanController.text.trim(),
          ngayTao: DateTime.now().toIso8601String(),
          hinhAnh: null,
        );

        ok = await DanhGiaService.themDanhGia(danhGia);
      }
      if (!ok) {
        throw Exception('Không gửi được đánh giá');
      }

      _showSuccessSnackBar(isEdit ? 'Cập nhật đánh giá thành công!' : 'Gửi đánh giá thành công!');
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }

    } catch (e) {
      print('Lỗi khi gửi đánh giá: $e');
      _showErrorSnackBar('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _dangGui = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: MauSac.xanhLa,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: MauSac.kfcRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.danhGiaCu != null;
    return Scaffold(
      backgroundColor: MauSac.denNen,
      appBar: AppBar(
        backgroundColor: MauSac.denNen,
        foregroundColor: MauSac.trang,
        title: Text(
          isEdit ? 'Chỉnh sửa đánh giá' : 'Viết đánh giá',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductInfo(),
                const SizedBox(height: 20),
                _buildRatingSection(),
                const SizedBox(height: 20),
                _buildCommentSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}