import 'package:flutter/material.dart';
import 'package:kfc/theme/mau_sac.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kfc/network/dio_client.dart';
import 'package:dio/dio.dart';

class ManHinhDashboard extends StatefulWidget {
  const ManHinhDashboard({Key? key}) : super(key: key);

  @override
  State<ManHinhDashboard> createState() => _ManHinhDashboardState();
}

class _ManHinhDashboardState extends State<ManHinhDashboard> {
  bool _isLoading = true;
  final Dio _dio = DioClient.dio();
  
  // Data variables
  double _totalRevenue = 0.0;
  double _todayRevenue = 0.0;
  int _totalOrders = 0;
  int _todayOrders = 0;
  int _totalCustomers = 0;
  int _pendingOrders = 0;
  double _averageOrderValue = 0.0;
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _dailyRevenueData = [];
  Map<String, int> _orderStatusDistribution = {
    'completed': 0,
    'processing': 0,
    'pending': 0,
    'cancelled': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadStats(),
        _loadDailyRevenue(),
        _loadOrderStatusDistribution(),
        _loadRecentOrders(),
      ]);
    } catch (e) {
      print('Error loading dashboard: $e');
      _resetData();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resetData() {
    setState(() {
      _totalRevenue = 0.0;
      _todayRevenue = 0.0;
      _totalOrders = 0;
      _todayOrders = 0;
      _totalCustomers = 0;
      _pendingOrders = 0;
      _averageOrderValue = 0.0;
      _recentOrders = [];
      _dailyRevenueData = [];
      _orderStatusDistribution = {
        'completed': 0,
        'processing': 0,
        'pending': 0,
        'cancelled': 0,
      };
    });
  }

  Future<void> _loadStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');
      if (mounted) {
        setState(() {
          _totalRevenue = (response.data['totalRevenue'] ?? 0).toDouble();
          _todayRevenue = (response.data['todayRevenue'] ?? 0).toDouble();
          _totalOrders = response.data['totalOrders'] ?? 0;
          _todayOrders = response.data['todayOrders'] ?? 0;
          _totalCustomers = response.data['totalCustomers'] ?? 0;
          _pendingOrders = response.data['pendingOrders'] ?? 0;
          _averageOrderValue = (response.data['averageOrderValue'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  Future<void> _loadDailyRevenue() async {
    try {
      final response = await _dio.get('/dashboard/daily-revenue');
      if (mounted) {
        setState(() {
          _dailyRevenueData = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print('Error loading daily revenue: $e');
    }
  }

  Future<void> _loadOrderStatusDistribution() async {
    try {
      final response = await _dio.get('/dashboard/order-status-distribution');
      if (mounted) {
        setState(() {
          _orderStatusDistribution = Map<String, int>.from(response.data);
        });
      }
    } catch (e) {
      print('Error loading order status: $e');
    }
  }

  Future<void> _loadRecentOrders() async {
    try {
      final response = await _dio.get('/dashboard/recent-orders?limit=5');
      if (mounted) {
        setState(() {
          _recentOrders = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print('Error loading recent orders: $e');
    }
  }
  

  

  

  

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;

    try {
      if (value is double) return value.isFinite ? value : 0.0;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value) ?? 0.0;
        return parsed.isFinite ? parsed : 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MauSac.denNen,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: MauSac.kfcRed,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    _buildRevenueLineChart(),
                    const SizedBox(height: 20),
                    _buildOrderStatusBarChart(),
                    const SizedBox(height: 20),
                    _buildRecentOrdersSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: MauSac.denNhat,
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Dashboard Quản Lý',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: MauSac.kfcRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _loadDashboardData,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: MauSac.trang,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const Icon(
                            Icons.refresh,
                            color: MauSac.trang,
                            size: 18,
                          ),
                        const SizedBox(width: 8),
                        const Text(
                          'Làm mới',
                          style: TextStyle(
                            color: MauSac.trang,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {
        'title': 'Tổng Doanh Thu',
        'value': _formatCurrency(_totalRevenue),
        'subtitle': 'Tất cả thời gian',
        'icon': Icons.attach_money,
        'color': MauSac.xanhLa,
      },
      {
        'title': 'Doanh Thu Hôm Nay',
        'value': _formatCurrency(_todayRevenue),
        'subtitle': '$_todayOrders đơn hàng',
        'icon': Icons.today,
        'color': MauSac.cam,
      },
      {
        'title': 'Tổng Đơn Hàng',
        'value': _totalOrders.toString(),
        'subtitle': 'Đã hoàn thành',
        'icon': Icons.shopping_cart,
        'color': MauSac.kfcRed,
      },
      {
        'title': 'Đang Xử Lý',
        'value': _pendingOrders.toString(),
        'subtitle': 'Đơn hàng chờ',
        'icon': Icons.pending,
        'color': MauSac.vang,
      },
      {
        'title': 'Khách Hàng',
        'value': _totalCustomers.toString(),
        'subtitle': 'Đã đăng ký',
        'icon': Icons.people,
        'color': MauSac.xanhLa,
      },
      {
        'title': 'Trung Bình/Đơn',
        'value': _formatCurrency(_averageOrderValue),
        'subtitle': 'Giá trị đơn hàng',
        'icon': Icons.trending_up,
        'color': MauSac.cam,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(stat);
      },
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (stat['color'] as Color).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (stat['color'] as Color).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: stat['color'] as Color,
                  size: 16,
                ),
              ),
              const Spacer(),
              if (_isLoading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    color: stat['color'] as Color,
                    strokeWidth: 2,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['title'] as String,
                style: TextStyle(
                  color: MauSac.xam,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                stat['value'] as String,
                style: TextStyle(
                  color: stat['color'] as Color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stat['subtitle'] as String,
                style: TextStyle(
                  color: MauSac.xam,
                  fontSize: 8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueLineChart() {
    if (_dailyRevenueData.isEmpty || _isLoading) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MauSac.denNhat,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MauSac.xamDam.withOpacity(0.3)),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(color: MauSac.kfcRed)
              : Text(
                  'Chưa có dữ liệu doanh thu',
                  style: TextStyle(color: MauSac.xam),
                ),
        ),
      );
    }

    final maxRevenue = _dailyRevenueData
        .map((e) => e['revenue'] as double)
        .reduce((a, b) => a > b ? a : b);
    final spots = _dailyRevenueData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value['revenue']))
        .toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MauSac.xamDam.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: MauSac.xanhLa, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Doanh Thu 7 Ngày Gần Nhất',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatShortCurrency(value),
                          style: TextStyle(color: MauSac.xam, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _dailyRevenueData.length) {
                          final dateVal = _dailyRevenueData[index]['date'];
                          DateTime? dt;
                          if (dateVal is DateTime) {
                            dt = dateVal;
                          } else if (dateVal is String) {
                            dt = DateTime.tryParse(dateVal);
                          }
                          if (dt == null) return const Text('');
                          return Text(
                            DateFormat('dd/MM').format(dt),
                            style: TextStyle(color: MauSac.xam, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: MauSac.xanhLa,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: MauSac.xanhLa.withOpacity(0.2),
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxRevenue * 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusBarChart() {
    final totalOrders = _orderStatusDistribution.values.reduce((a, b) => a + b,);
    if (totalOrders == 0 || _isLoading) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MauSac.denNhat,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MauSac.xamDam.withOpacity(0.3)),
        ),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator(color: MauSac.kfcRed)
              : Text(
                  'Chưa có dữ liệu đơn hàng',
                  style: TextStyle(color: MauSac.xam),
                ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MauSac.xamDam.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: MauSac.cam, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Phân Bố Trạng Thái Đơn Hàng',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: _orderStatusDistribution['completed']?.toDouble() ?? 0,
                        color: MauSac.xanhLa,
                        width: 20,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: _orderStatusDistribution['processing']?.toDouble() ?? 0,
                        color: MauSac.cam,
                        width: 20,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _orderStatusDistribution['cancelled']?.toDouble() ?? 0,
                        color: MauSac.kfcRed,
                        width: 20,
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(color: MauSac.xam, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return Text('Hoàn thành', style: TextStyle(color: MauSac.xam, fontSize: 10));
                          case 1:
                            return Text('Đang xử lý', style: TextStyle(color: MauSac.xam, fontSize: 10));
                          case 2:
                            return Text('Đã hủy', style: TextStyle(color: MauSac.xam, fontSize: 10));
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MauSac.denNhat,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MauSac.xamDam.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long, color: MauSac.cam, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Đơn Hàng Gần Đây',
                style: TextStyle(
                  color: MauSac.trang,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: MauSac.kfcRed),
              ),
            )
          else if (_recentOrders.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.inbox, color: MauSac.xam, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có đơn hàng nào',
                      style: TextStyle(color: MauSac.xam),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _recentOrders.map((order) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: MauSac.denNen,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: MauSac.xamDam.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(order['trangThai']),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(
                              builder: (context) {
                                final rawId = order['id'] ?? order['_id'] ?? '';
                                final idStr = rawId?.toString() ?? '';
                                final shortId = idStr.isNotEmpty
                                    ? idStr.substring(0, idStr.length >= 8 ? 8 : idStr.length)
                                    : '—';
                                return Text(
                                  '#$shortId',
                                  style: const TextStyle(
                                    color: MauSac.trang,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                            Builder(
                              builder: (context) {
                                final tg = order['thoiGian'];
                                DateTime? dt;
                                if (tg is DateTime) {
                                  dt = tg;
                                } else if (tg is String) {
                                  dt = DateTime.tryParse(tg);
                                }
                                if (dt == null) return const SizedBox.shrink();
                                return Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(dt),
                                  style: TextStyle(
                                    color: MauSac.xam,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatShortCurrency(order['tongTien']),
                            style: TextStyle(
                              color: MauSac.xanhLa,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _getStatusText(order['trangThai']),
                            style: TextStyle(
                              color: _getStatusColor(order['trangThai']),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dagiao':
      case 'hoan_thanh':
      case 'completed':
        return MauSac.xanhLa;
      case 'dangxuly':
      case 'processing':
        return MauSac.cam;
      case 'dahuy':
      case 'cancelled':
        return MauSac.kfcRed;
      default:
        return MauSac.xam;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'dagiao':
        return 'Đã giao';
      case 'hoan_thanh':
        return 'Hoàn thành';
      case 'dangxuly':
        return 'Đang xử lý';
      case 'dahuy':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K đ';
    } else {
      return '${amount.toStringAsFixed(0)} đ';
    }
  }

  String _formatShortCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}