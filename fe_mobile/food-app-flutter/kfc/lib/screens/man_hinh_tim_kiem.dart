import 'package:flutter/material.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:kfc/models/san_pham.dart';
import 'package:kfc/widgets/san_pham_card.dart';
import 'package:kfc/screens/man_hinh_chi_tiet_san_pham.dart';
import 'package:provider/provider.dart';
import 'package:kfc/providers/tim_kiem_provider.dart';
import 'package:kfc/data/du_lieu_mau.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


class ManHinhTimKiem extends StatefulWidget {
  const ManHinhTimKiem({Key? key}) : super(key: key);

  @override
  State<ManHinhTimKiem> createState() => _ManHinhTimKiemState();
}

class _ManHinhTimKiemState extends State<ManHinhTimKiem>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilterOptions = false;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  final FocusNode _searchFocusNode = FocusNode();

  late stt.SpeechToText _speech;
  bool _dangNghe = false;

  @override
  void initState() {
    super.initState();
    
    // Animation controller cho filter
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    // Lấy từ khóa hiện tại từ provider
    final timKiemProvider = Provider.of<TimKiemProvider>(
      context,
      listen: false,
    );
    _searchController.text = timKiemProvider.tuKhoa;

    _speech = stt.SpeechToText();

  }
  Future<void> _batDauNgheGiongNoi() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
      },
      onError: (error) {
        debugPrint('Speech error: $error');
      },
    );

    if (!available) return;

    setState(() => _dangNghe = true);
    print("dang nghe");
    await _speech.listen(
      localeId: 'vi_VN', // ✅ locale đặt ở đây
      onResult: (result) {
        print(result);
        final text = result.recognizedWords;

        _searchController.text = text;
        _searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: text.length),
        );

        Provider.of<TimKiemProvider>(
          context,
          listen: false,
        ).datTuKhoa(text);
      },
    );
  }

  void _dungNgheGiongNoi() {
    _speech.stop();
    setState(() => _dangNghe = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() {
      _showFilterOptions = !_showFilterOptions;
      if (_showFilterOptions) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      body: SafeArea(
        child: Column(
          children: [
            // Header với search bar
            _buildHeader(),
            
            // Filter options
            _buildFilterSection(),
            
            // Kết quả tìm kiếm
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar với title và filter button
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tìm kiếm món ăn',
                  style: TextStyle(
                    color: MauSac.trang,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: _showFilterOptions ? MauSac.kfcRed : MauSac.denNen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    color: _showFilterOptions ? MauSac.trang : MauSac.xam,
                  ),
                  onPressed: _toggleFilter,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: MauSac.denNen,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _searchFocusNode.hasFocus
                    ? MauSac.kfcRed
                    : MauSac.xam.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: MauSac.trang, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm món ăn yêu thích...',
                hintStyle: TextStyle(
                  color: MauSac.xam.withOpacity(0.7),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search,
                    color: MauSac.xam.withOpacity(0.7),
                    size: 24,
                  ),
                ),

                /// 🔴 SUFFIX ICON (CLEAR + MICRO)
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ❌ Clear text
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: MauSac.xam.withOpacity(0.7),
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<TimKiemProvider>(
                            context,
                            listen: false,
                          ).datTuKhoa('');
                          setState(() {});
                        },
                      ),

                    // 🎤 Voice search
                    IconButton(
                      icon: Icon(
                        _dangNghe ? Icons.mic : Icons.mic_none,
                        color: _dangNghe
                            ? MauSac.kfcRed
                            : MauSac.xam.withOpacity(0.7),
                      ),
                      onPressed: () {
                        if (_dangNghe) {
                          _dungNgheGiongNoi();
                        } else {
                          _batDauNgheGiongNoi();
                        }
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (value) {
                Provider.of<TimKiemProvider>(
                  context,
                  listen: false,
                ).datTuKhoa(value);
                setState(() {});
              },
              onSubmitted: (value) {
                Provider.of<TimKiemProvider>(
                  context,
                  listen: false,
                ).datTuKhoa(value);
                _searchFocusNode.unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return Container(
          height: _filterAnimation.value * 200,
          decoration: BoxDecoration(
            color: MauSac.denNhat,
            border: Border(
              bottom: BorderSide(
                color: MauSac.xam.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<TimKiemProvider>(
                builder: (context, timKiemProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header filter
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.filter_alt, color: MauSac.kfcRed, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Bộ lọc tìm kiếm',
                                style: TextStyle(
                                  color: MauSac.trang,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {
                              timKiemProvider.xoaBoLoc();
                            },
                            icon: const Icon(Icons.refresh, size: 16, color: MauSac.kfcRed),
                            label: const Text(
                              'Đặt lại',
                              style: TextStyle(color: MauSac.kfcRed, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Danh mục
                      const Text(
                        'Danh mục',
                        style: TextStyle(
                          color: MauSac.trang,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: DuLieuMau.danhSachDanhMuc.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return _buildFilterChip(
                                'Tất cả',
                                timKiemProvider.danhMucId.isEmpty,
                                () => timKiemProvider.datDanhMuc(''),
                                Icons.apps,
                              );
                            }
                            final danhMuc = DuLieuMau.danhSachDanhMuc[index - 1];
                            return _buildFilterChip(
                              danhMuc.ten,
                              timKiemProvider.danhMucId == danhMuc.id,
                              () => timKiemProvider.datDanhMuc(danhMuc.id),
                              Icons.fastfood,
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Sắp xếp
                      const Text(
                        'Sắp xếp theo',
                        style: TextStyle(
                          color: MauSac.trang,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildSortChip(
                            'Mặc định',
                            timKiemProvider.sapXepTheo == 'mac_dinh',
                            () => timKiemProvider.datSapXep('mac_dinh'),
                            Icons.sort,
                          ),
                          _buildSortChip(
                            'Giá tăng',
                            timKiemProvider.sapXepTheo == 'gia_tang',
                            () => timKiemProvider.datSapXep('gia_tang'),
                            Icons.trending_up,
                          ),
                          _buildSortChip(
                            'Giá giảm',
                            timKiemProvider.sapXepTheo == 'gia_giam',
                            () => timKiemProvider.datSapXep('gia_giam'),
                            Icons.trending_down,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MauSac.kfcRed : MauSac.denNen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? MauSac.kfcRed : MauSac.xam.withOpacity(0.3),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: MauSac.kfcRed.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? MauSac.trang : MauSac.xam,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? MauSac.trang : MauSac.xam,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, bool isSelected, VoidCallback onTap, IconData icon) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? MauSac.kfcRed : MauSac.denNen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? MauSac.kfcRed : MauSac.xam.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? MauSac.trang : MauSac.xam,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? MauSac.trang : MauSac.xam,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Consumer<TimKiemProvider>(
      builder: (context, timKiemProvider, child) {
        final ketQuaTimKiem = timKiemProvider.ketQuaTimKiem;

        if (timKiemProvider.tuKhoa.isEmpty && !_showFilterOptions) {
          return _buildEmptySearchState();
        }

        if (ketQuaTimKiem.isEmpty) {
          return _buildNoResultsState();
        }

        return Column(
          children: [
            // Results header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tìm thấy ${ketQuaTimKiem.length} kết quả',
                    style: const TextStyle(
                      color: MauSac.trang,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (ketQuaTimKiem.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MauSac.kfcRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${ketQuaTimKiem.length}',
                        style: const TextStyle(
                          color: MauSac.kfcRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Results grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: ketQuaTimKiem.length,
                itemBuilder: (context, index) {
                  return SanPhamCard(
                    sanPham: ketQuaTimKiem[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManHinhChiTietSanPham(
                            sanPhamId: ketQuaTimKiem[index].id,
                            sanPhamBanDau: ketQuaTimKiem[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptySearchState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: MauSac.denNhat,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: MauSac.kfcRed.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.search,
                size: 50,
                color: MauSac.kfcRed,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tìm kiếm món ăn yêu thích',
              style: TextStyle(
                color: MauSac.trang,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập tên món ăn hoặc sử dụng bộ lọc\nđể tìm kiếm chính xác hơn',
              style: TextStyle(
                color: MauSac.xam.withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MauSac.kfcRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: MauSac.kfcRed.withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: MauSac.kfcRed, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Thử tìm: "gà rán", "burger", "khoai tây"',
                    style: TextStyle(
                      color: MauSac.kfcRed,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: MauSac.denNhat,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: MauSac.xam.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.search_off,
                size: 50,
                color: MauSac.xam.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                color: MauSac.trang,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử thay đổi từ khóa tìm kiếm\nhoặc điều chỉnh bộ lọc',
              style: TextStyle(
                color: MauSac.xam.withOpacity(0.8),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<TimKiemProvider>(context, listen: false).xoaBoLoc();
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Đặt lại tìm kiếm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: MauSac.kfcRed,
                foregroundColor: MauSac.trang,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
