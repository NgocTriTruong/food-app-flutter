import 'package:flutter/material.dart';
import 'package:kfc/models/don_hang.dart';
import 'package:kfc/models/san_pham_gio_hang.dart';
import 'package:kfc/providers/don_hang_provider.dart';
import 'package:kfc/providers/nguoi_dung_provider.dart';
import 'package:kfc/services/don_hang_service.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:provider/provider.dart';

class ManHinhDonHang extends StatefulWidget {
  const ManHinhDonHang({Key? key}) : super(key: key);

  @override
  State<ManHinhDonHang> createState() => _ManHinhDonHangState();
}

class _ManHinhDonHangState extends State<ManHinhDonHang> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = true;
  final donHangService = DonHangService();
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDonHang();
    });
    
    _animationController.forward();
  }

  Future<void> _loadDonHang() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final nguoiDungProvider = Provider.of<NguoiDungProvider>(context, listen: false);
      final donHangProvider = Provider.of<DonHangProvider>(context, listen: false);

      if (nguoiDungProvider.currentUser != null) {
        await donHangProvider.fetchDonHangByUser(nguoiDungProvider.currentUser!.id);
      }
    } catch (e) {
      print('Error loading orders: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading ? _buildLoading() : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MauSac.denNhat,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: MauSac.kfcRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: MauSac.kfcRed,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đơn hàng của tôi',
                    style: TextStyle(
                      color: MauSac.trang,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Theo dõi trạng thái đơn hàng của bạn',
                    style: TextStyle(
                      color: MauSac.xam.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Container(
              decoration: BoxDecoration(
                color: MauSac.kfcRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: MauSac.kfcRed,
                  size: 20,
                ),
                onPressed: _loadDonHang,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: MauSac.kfcRed,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Đang tải đơn hàng...',
            style: TextStyle(
              color: MauSac.xam.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Selector<DonHangProvider, Map<String, dynamic>>(
        selector: (context, provider) => {
          'donHangList': provider.donHangList,
          'error': provider.error,
          'isLoading': provider.isLoading,
        },
        builder: (context, data, child) {
          final donHangList = data['donHangList'] as List<DonHang>;
          final error = data['error'] as String?;
          final isLoading = data['isLoading'] as bool;

          if (error != null) {
            return _buildError(error);
          }

          if (isLoading) {
            return _buildLoading();
          }

          return _buildDonHangList(donHangList);
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: MauSac.kfcRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                color: MauSac.kfcRed,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                color: MauSac.trang,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                color: MauSac.xam.withOpacity(0.8),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadDonHang,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.kfcRed,
                foregroundColor: MauSac.trang,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonHangList(List<DonHang> danhSachDonHang) {
    if (danhSachDonHang.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDonHang,
      color: MauSac.kfcRed,
      backgroundColor: MauSac.denNhat,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: danhSachDonHang.length,
        itemBuilder: (context, index) {
          final donHang = danhSachDonHang[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildDonHangItem(donHang),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          MauSac.kfcRed.withOpacity(0.1),
                          MauSac.kfcRed.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: MauSac.kfcRed.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.receipt_long,
                      size: 60,
                      color: MauSac.kfcRed.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Chưa có đơn hàng nào',
              style: TextStyle(
                color: MauSac.trang,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hãy đặt món ăn yêu thích của bạn\nngay bây giờ',
              style: TextStyle(
                color: MauSac.xam.withOpacity(0.8),
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.fastfood),
              label: const Text('Đặt hàng ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.kfcRed,
                foregroundColor: MauSac.trang,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonHangItem(DonHang donHang) {
    Color statusColor;
    IconData statusIcon;
    
    switch (donHang.trangThai) {
      case TrangThaiDonHang.dangXuLy:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
        break;
      case TrangThaiDonHang.dangGiao:
        statusColor = Colors.blue;
        statusIcon = Icons.delivery_dining;
        break;
      case TrangThaiDonHang.daGiao:
        statusColor = MauSac.xanhLa;
        statusIcon = Icons.check_circle;
        break;
      case TrangThaiDonHang.daHuy:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDonHangDetail(donHang),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusIcon,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #${donHang.id.length > 8 ? donHang.id.substring(0, 8) : donHang.id}',
                            style: const TextStyle(
                              color: MauSac.trang,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${donHang.ngayDatHang} - ${donHang.gioDatHang}',
                            style: TextStyle(
                              color: MauSac.xam.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          donHang.trangThaiText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        MauSac.xam.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: MauSac.kfcRed,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        donHang.phuongThucThanhToan ?? 'Chưa xác định',
                        style: TextStyle(
                          color: MauSac.xam.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.fastfood,
                                color: MauSac.kfcRed,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${donHang.danhSachSanPham.length} món',
                                style: const TextStyle(
                                  color: MauSac.trang,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _buildProductSummary(donHang),
                            style: TextStyle(
                              color: MauSac.xam.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tổng cộng',
                          style: TextStyle(
                            color: MauSac.xam.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${donHang.tongCong.toStringAsFixed(0)} ₫',
                          style: const TextStyle(
                            color: MauSac.kfcRed,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (donHang.trangThai == TrangThaiDonHang.dangXuLy)
                      TextButton.icon(
                        onPressed: () => _showCancelDialog(donHang),
                        icon: const Icon(
                          Icons.cancel_outlined,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Hủy đơn',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDonHangDetail(donHang),
                      icon: const Icon(
                        Icons.visibility,
                        size: 16,
                        color: MauSac.kfcRed,
                      ),
                      label: const Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: MauSac.kfcRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildProductSummary(DonHang donHang) {
    if (donHang.danhSachSanPham.isEmpty) {
      return 'Không có sản phẩm';
    }

    final firstProduct = donHang.danhSachSanPham.first.sanPham.ten;
    if (donHang.danhSachSanPham.length == 1) {
      return firstProduct;
    }

    return '$firstProduct và ${donHang.danhSachSanPham.length - 1} món khác';
  }

  void _showDonHangDetail(DonHang donHang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DonHangDetailSheet(
        donHang: donHang,
        onCancel: () {
          Navigator.pop(context); // Đóng bottom sheet
          _showCancelDialog(donHang);
        },
      ),
    );
  }

  void _showCancelDialog(DonHang donHang) {
    print('🔍 Dialog hủy đơn - ID: "${donHang.id}", Status: ${donHang.trangThai}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await donHangService.cancelDonHang(donHang.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đơn hàng đã được hủy'),
                    backgroundColor: Colors.red,
                  ),
                );
                // Reload danh sách
                if (mounted) {
                  setState(() {});
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Hủy đơn',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonHangDetailSheet extends StatelessWidget {
  final DonHang donHang;
  final VoidCallback? onCancel;

  const _DonHangDetailSheet({
    Key? key,
    required this.donHang,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    
    switch (donHang.trangThai) {
      case TrangThaiDonHang.dangXuLy:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
        break;
      case TrangThaiDonHang.dangGiao:
        statusColor = Colors.blue;
        statusIcon = Icons.delivery_dining;
        break;
      case TrangThaiDonHang.daGiao:
        statusColor = MauSac.xanhLa;
        statusIcon = Icons.check_circle;
        break;
      case TrangThaiDonHang.daHuy:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: MauSac.denNen,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MauSac.denNhat,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.close, color: MauSac.trang),
                ),
              ),
              if (donHang.trangThai == TrangThaiDonHang.dangXuLy)
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Hủy đơn',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: MauSac.xam.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MauSac.denNhat,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đơn hàng #${donHang.id.length > 8 ? donHang.id.substring(0, 8) : donHang.id}',
                        style: const TextStyle(
                          color: MauSac.trang,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${donHang.ngayDatHang} - ${donHang.gioDatHang}',
                        style: TextStyle(
                          color: MauSac.xam.withOpacity(0.8),
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      donHang.trangThaiText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Thông tin giao hàng',
                    icon: Icons.location_on,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Người nhận', donHang.tenNguoiNhan),
                        const SizedBox(height: 12),
                        _buildInfoRow('Số điện thoại', donHang.soDienThoai),
                        const SizedBox(height: 12),
                        _buildInfoRow('Địa chỉ', donHang.diaChi),
                        _buildPaymentRow('Phương thức', donHang.phuongThucThanhToan ?? 'Chưa xác định'),
                        const SizedBox(height: 12),
                        if (donHang.ghiChu != null && donHang.ghiChu!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow('Ghi chú', donHang.ghiChu!),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'Danh sách sản phẩm',
                    icon: Icons.fastfood,
                    child: Column(
                      children: [
                        ...donHang.danhSachSanPham.map((item) => _buildProductItem(item)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    title: 'Thông tin thanh toán',
                    icon: Icons.payment,
                    child: Column(
                      children: [
                        _buildPaymentRow('Tạm tính', '${donHang.tongTien.toStringAsFixed(0)} ₫'),
                        const SizedBox(height: 12),
                        _buildPaymentRow('Phí giao hàng', '${donHang.phiGiaoHang.toStringAsFixed(0)} ₫'),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                MauSac.xam.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentRow(
                          'Tổng cộng', 
                          '${donHang.tongCong.toStringAsFixed(0)} ₫',
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: MauSac.denNhat,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MauSac.kfcRed,
                    foregroundColor: MauSac.trang,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MauSac.kfcRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: MauSac.kfcRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: MauSac.trang,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: MauSac.xam.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: MauSac.trang,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(SanPhamGioHang item) {
    final sanPham = item.sanPham;
    final soLuong = item.soLuong;
    final giaGoc = sanPham.gia;
    final giaSauGiam = sanPham.coKhuyenMai ? sanPham.giaGiam : giaGoc;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MauSac.denNen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MauSac.xam.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: MauSac.kfcRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$soLuong',
                style: const TextStyle(
                  color: MauSac.kfcRed,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: MauSac.xam.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: sanPham.hinhAnh != null && sanPham.hinhAnh!.isNotEmpty
                  ? Image.asset(
                      sanPham.hinhAnh!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading asset image: $error');
                        return const Icon(
                          Icons.fastfood,
                          color: MauSac.kfcRed,
                          size: 30,
                        );
                      },
                    )
                  : const Icon(
                      Icons.fastfood,
                      color: MauSac.kfcRed,
                      size: 30,
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sanPham.ten,
                  style: const TextStyle(
                    color: MauSac.trang,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (sanPham.coKhuyenMai) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: MauSac.kfcRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: MauSac.kfcRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '-${sanPham.phanTramGiamGia}%',
                          style: const TextStyle(
                            color: MauSac.kfcRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          '${giaGoc.toString()} ₫',
                          style: TextStyle(
                            color: MauSac.xam.withOpacity(0.7),
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          Text(
            '${giaSauGiam.toStringAsFixed(0)} ₫',
            style: const TextStyle(
              color: MauSac.trang,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? MauSac.trang : MauSac.xam.withOpacity(0.8),
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? MauSac.kfcRed : MauSac.trang,
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}