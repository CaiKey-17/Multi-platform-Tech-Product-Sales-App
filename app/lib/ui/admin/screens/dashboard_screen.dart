import 'package:app/globals/convert_money.dart';
import 'package:app/models/order_statistics.dart';
import 'package:app/models/top_selling_product.dart';
import 'package:app/models/user_statistics.dart';
import 'package:app/services/api_service.dart';
import 'package:app/ui/admin/widgets/sidebar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SalesData {
  final DateTime date;
  final double revenue;
  final double profit;
  final int orders;
  final String topProduct;

  SalesData(this.date, this.revenue, this.profit, this.orders, this.topProduct);
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late ApiService apiService;
  bool isLoading = true;
  String token = "";
  int? totalUser;
  int? newUser;
  String selectedFilter = "Năm";
  List<SalesData> salesData = [];
  UserStatistics? userStatistics;
  OrderStatisticsDTO? orderStatisticsDTO;
  List<TopSellingProductDTO> listTopSelling = [];
  @override
  void initState() {
    super.initState();
    apiService = ApiService(Dio());

    // _fetchData();
    _loadUserData();
    getUserStatistics();
    getOrderStatistics();
    getProductStatistics();
  }

  Future<void> getProductStatistics() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await apiService.getTopSellingProducts();

      if (response.code == 200 && response.data != null) {
        final data = response.data!;
        setState(() {
          listTopSelling =
              data.map((json) => TopSellingProductDTO.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch top selling products');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> getOrderStatistics() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getOrderStatistics();
      if (response.code == 200) {
        final data = response.data!;
        setState(() {
          orderStatisticsDTO = OrderStatisticsDTO.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch order statistics');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> getUserStatistics() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await apiService.getUserStatistics();
      if (response.code == 200) {
        final data = response.data;
        setState(() {
          userStatistics = UserStatistics.fromJson(data!);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user statistics');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      rethrow;
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  Future<List<SalesData>> fetchSalesData(
    String filter, {
    DateTime? start,
    DateTime? end,
  }) async {
    List<SalesData> allData = [
      SalesData(DateTime(2025, 1, 1), 10000000, 2500000, 50, "SP001"),
      SalesData(DateTime(2025, 2, 1), 15000000, 3750000, 75, "SP002"),
      SalesData(DateTime(2025, 3, 1), 20000000, 5000000, 100, "SP003"),
      SalesData(DateTime(2025, 4, 1), 12000000, 3000000, 60, "SP004"),
      SalesData(DateTime(2025, 5, 1), 18000000, 4500000, 90, "SP005"),
      SalesData(DateTime(2025, 6, 1), 22000000, 5500000, 110, "SP006"),
      SalesData(DateTime(2025, 7, 1), 13000000, 3250000, 65, "SP007"),
      SalesData(DateTime(2025, 8, 1), 17000000, 4250000, 85, "SP008"),
      SalesData(DateTime(2025, 9, 1), 19000000, 4750000, 95, "SP009"),
      SalesData(DateTime(2025, 10, 1), 14000000, 3500000, 70, "SP010"),
      SalesData(DateTime(2025, 11, 1), 16000000, 4000000, 80, "SP011"),
      SalesData(DateTime(2025, 12, 1), 21000000, 5250000, 105, "SP012"),
    ];

    DateTime now = DateTime.now();
    if (start != null && end != null) {
      return allData
          .where(
            (data) =>
                data.date.isAfter(start.subtract(Duration(days: 1))) &&
                data.date.isBefore(end.add(Duration(days: 1))),
          )
          .toList();
    }

    switch (filter) {
      case "Tuần":
        DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
        return allData
            .where(
              (data) =>
                  data.date.isAfter(weekStart.subtract(Duration(days: 1))),
            )
            .toList();
      case "Tháng":
        return allData
            .where(
              (data) =>
                  data.date.month == now.month && data.date.year == now.year,
            )
            .toList();
      case "Quý":
        int quarter = (now.month - 1) ~/ 3 + 1;
        int startMonth = (quarter - 1) * 3 + 1;
        int endMonth = quarter * 3;
        return allData
            .where(
              (data) =>
                  data.date.year == now.year &&
                  data.date.month >= startMonth &&
                  data.date.month <= endMonth,
            )
            .toList();
      case "Năm":
      default:
        return allData.where((data) => data.date.year == now.year).toList();
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subValue,
    Color color,
  ) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(subValue, style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLegend({bool includeOrders = true}) {
    List<Widget> items = [
      _buildLegendItem(Colors.blue, "Doanh thu (triệu VNĐ)"),
      SizedBox(width: 16),
      _buildLegendItem(Colors.green, "Lợi nhuận (triệu VNĐ)"),
    ];
    if (includeOrders) {
      items.addAll([
        SizedBox(width: 16),
        _buildLegendItem(Colors.orange, "Số đơn hàng"),
      ]);
    }
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: items);
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLineChart(List<SalesData> data) {
    return Container(
      height: 350,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Doanh thu và lợi nhuận theo thời gian",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, horizontalInterval: 5000000),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Transform.rotate(
                            angle: -45 * 3.14159 / 180,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                "${data[index].date.month}/${data[index].date.year}",
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }
                        return Text("");
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots:
                        data
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(e.key.toDouble(), e.value.revenue),
                            )
                            .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots:
                        data
                            .asMap()
                            .entries
                            .map(
                              (e) => FlSpot(e.key.toDouble(), e.value.profit),
                            )
                            .toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildLegend(includeOrders: false),
        ],
      ),
    );
  }

  Widget _buildRevenueProfitChart(List<SalesData> data) {
    double totalRevenue = data.fold(0.0, (sum, e) => sum + e.revenue) / 1000000;
    double totalProfit = data.fold(0.0, (sum, e) => sum + e.profit) / 1000000;

    return Container(
      height: 350,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Tổng doanh thu và lợi nhuận",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalRevenue,
                        color: Colors.blue,
                        width: 20,
                        borderRadius: BorderRadius.zero,
                      ),
                      BarChartRodData(
                        toY: totalProfit,
                        color: Colors.green,
                        width: 20,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text("Tổng"),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          SizedBox(height: 8),
          _buildLegend(includeOrders: false),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(List<SalesData> data) {
    int totalOrders = data.fold(0, (sum, e) => sum + e.orders);

    return Container(
      height: 350,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Tổng số đơn hàng",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalOrders.toDouble(),
                        color: Colors.orange,
                        width: 20,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text("Tổng"),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                ),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_buildLegendItem(Colors.orange, "Số đơn hàng")],
          ),
        ],
      ),
    );
  }

  Widget _buildUserChartCard(String totalU, String newU) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Biểu đồ người dùng",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Tổng');
                          case 1:
                            return const Text('Mới');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                maxY:
                    double.parse(totalU) > double.parse(newU)
                        ? double.parse(totalU) + 2
                        : double.parse(newU) + 2,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: double.parse(totalU),
                        color: Colors.blue,
                        width: 25,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: double.parse(newU),
                        color: Colors.green,
                        width: 25,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tổng người dùng: ${totalU}",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          Text(
            "Người dùng mới:  ${newU}",
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget buildOrderRevenueChartCard(String countO, String revenueO) {
    double count = double.parse(countO);
    double revenue = double.parse(revenueO) / 1000000;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Biểu đồ Đơn hàng & Doanh thu",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, _) {
                        return Text(
                          '${(value * 1000000).toStringAsFixed(0)}tr',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Đơn hàng');
                          case 1:
                            return const Text('Doanh thu');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                maxY: revenue > count ? revenue + 2 : count + 2,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: count,
                        color: Colors.blue,
                        width: 30,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: revenue,
                        color: Colors.green,
                        width: 30,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Tổng: ${countO} đơn",
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
          Text(
            "Tổng doanh thu: " +
                "${ConvertMoney.currencyFormatter.format(double.parse(revenueO))} ₫",

            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget buildTopSellingProductsChartCard(List<TopSellingProductDTO> list) {
    final top3 = list.take(3).toList();

    final List<Color> barColors = [Colors.blue, Colors.green, Colors.orange];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Biểu đồ Top 3 Sản phẩm bán chạy",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        if (value.toInt() < top3.length) {
                          return Text(
                            top3[value.toInt()].productName,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),

                barGroups: List.generate(top3.length, (index) {
                  final product = top3[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: product.totalSold.toDouble(),
                        color: barColors[index],
                        width: 30,
                        borderRadius: BorderRadius.zero,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(top3.length, (index) {
            final product = top3[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                'Top ${index + 1}: ${product.productName} (${product.totalSold})',
                style: TextStyle(
                  fontSize: 12,
                  color: barColors[index],
                  fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: SideBar(token: token),
      body:
          isDashboardDataReady
              ? SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard(
                          "Tổng người dùng",
                          userStatistics!.totalUsers.toString(),
                          "+ ${userStatistics!.newUsers} người dùng mới",
                          Colors.blue,
                        ),
                        _buildStatCard(
                          "Tổng đơn hàng",
                          orderStatisticsDTO!.countOrder.toString(),
                          "+ ${ConvertMoney.currencyFormatter.format(orderStatisticsDTO!.totalRevenue)} ₫",
                          Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildUserChartCard(
                      userStatistics!.totalUsers.toString(),
                      userStatistics!.newUsers.toString(),
                    ),
                    SizedBox(height: 24),
                    buildOrderRevenueChartCard(
                      orderStatisticsDTO!.countOrder.toString(),
                      orderStatisticsDTO!.totalRevenue.toString(),
                    ),
                    SizedBox(height: 24),
                    buildTopSellingProductsChartCard(listTopSelling),
                  ],
                ),
              )
              : Center(child: CircularProgressIndicator(color: Colors.blue)),
    );
  }

  bool get isDashboardDataReady {
    return userStatistics != null &&
        orderStatisticsDTO != null &&
        listTopSelling.isNotEmpty;
  }
}
