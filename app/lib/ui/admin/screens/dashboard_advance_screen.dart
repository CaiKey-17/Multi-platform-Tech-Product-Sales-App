import 'package:app/models/category_sales.dart';
import 'package:app/models/total_product_by_year.dart';
import 'package:app/services/api_service.dart';
import 'package:app/ui/admin/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

final currentYear = DateTime.now().year;

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String token = "";

  String selectedPeriod = 'Năm';
  DateTimeRange? selectedRange;

  List<PerformanceDataDTO> performanceData = [];
  List<TotalProductByYear> toldResponse = [];
  List<CategorySalesProjection> typeResponse = [];

  List<ProductData> productData = [];

  final api = ApiService(Dio());

  List<int> availableYears = List.generate(6, (index) => currentYear - index);
  int? selectedYear;
  int? selectedQuarter;
  int? selectedMonth;
  int? selectedWeek;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "";
    });
  }

  String _getTotalOrders() {
    return performanceData
        .fold(0, (sum, item) => sum + item.tongSoDon)
        .toString();
  }

  double _getTotalRevenue() {
    return performanceData.fold(0.0, (sum, item) => sum + item.tongDoanhThu);
  }

  double _getTotalProfit() {
    return performanceData.fold(0.0, (sum, item) => sum + item.tongLoiNhuan);
  }

  String _formatCurrency(double value) {
    if (value >= 1e9) {
      return "${(value / 1e9).toStringAsFixed(1)} tỷ";
    } else if (value >= 1e6) {
      return "${(value / 1e6).toStringAsFixed(1)} triệu";
    } else if (value >= 1e3) {
      return "${(value / 1e3).toStringAsFixed(1)} nghìn";
    } else {
      final formatCurrency = NumberFormat.currency(
        locale: "vi_VN",
        symbol: "₫",
        decimalDigits: 0,
      );
      return formatCurrency.format(value);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    updateData();
  }

  void updateData({int? year, int? quarter, int? month, int? week}) async {
    try {
      final perfResponse =
          (year != null && month != null && week != null)
              ? await api.getPerformanceDataByYearWeek(year, month, week)
              : (year != null && quarter != null && month != null
                  ? await api.getPerformanceDataByYearMonth(year, month)
                  : (year != null && quarter != null
                      ? await api.getPerformanceDataByYearQuarter(year, quarter)
                      : (year != null && month != null
                          ? await api.getPerformanceDataByYearMonth(year, month)
                          : year != null
                          ? await api.getPerformanceDataByYear(year)
                          : await api.getPerformanceData(selectedPeriod))));

      if (perfResponse.data != null) {
        setState(() {
          performanceData = perfResponse.data!;
        });
      } else {
        print("Không có dữ liệu performance");
      }

      final response =
          (year != null && month != null && week != null)
              ? await api.getSoldProductsByYearMonthWeek(year, month, week)
              : (year != null && quarter != null && month != null
                  ? await api.getSoldProductsByYearMonthV2(year, month)
                  : (year != null && quarter != null
                      ? await api.getSoldProductsByYearQuarter(year, quarter)
                      : (year != null && month != null
                          ? await api.getSoldProductsByYearMonthV2(year, month)
                          : year != null
                          ? await api.getSoldProductsByYearMonth(year)
                          : await api.getSoldProductsByYear())));

      if (response.data != null) {
        setState(() {
          toldResponse = response.data!;
        });
      } else {
        print("Không có dữ liệu type");
      }

      final response1 =
          (year != null && month != null && week != null)
              ? await api.getSoldTypeProductsByYearMonthWeek(year, month, week)
              : (year != null && quarter != null && month != null
                  ? await api.getSoldTypeProductsByYearMonthV2(year, month)
                  : (year != null && quarter != null
                      ? await api.getSoldTypeProductsByYearQuarter(
                        year,
                        quarter,
                      )
                      : (year != null && month != null
                          ? await api.getSoldTypeProductsByYearMonthV2(
                            year,
                            month,
                          )
                          : year != null
                          ? await api.getSoldTypeProductsByYearMonth(year)
                          : await api.getSoldTypeProductsByYear())));

      if (response1.data != null) {
        setState(() {
          typeResponse = response1.data!;
        });
      } else {
        print("Không có dữ liệu performance");
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu: $e");
    }
  }

  void updateCustomData(DateTimeRange range) async {
    try {
      final start = DateFormat('yyyy-MM-dd').format(range.start);
      final end = DateFormat('yyyy-MM-dd').format(range.end);

      final perfResponse = await api.getCustomPerformanceData(start, end);
      if (perfResponse.data != null) {
        setState(() {
          performanceData = perfResponse.data!;
        });
      } else {
        print("Không có dữ liệu performance cho khoảng thời gian này");
      }

      final response = await api.getTotalProductByDayBetween(start, end);
      if (response.data != null) {
        setState(() {
          toldResponse = response.data!;
        });
      } else {
        print("Không có dữ liệu performance cho khoảng thời gian này");
      }

      final response1 = await api.getTotalTypeProductByDayBetween(start, end);
      if (response1.data != null) {
        setState(() {
          typeResponse = response1.data!;
        });
      } else {
        print("Không có dữ liệu performance cho khoảng thời gian này");
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu theo khoảng thời gian tùy chỉnh: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Dashboard nâng cao",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      drawer: SideBar(token: token),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Năm:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(width: 12),
                DropdownButton<int>(
                  dropdownColor: Colors.white,
                  value: selectedYear,
                  hint: Text("Chọn năm"),
                  items:
                      availableYears
                          .map(
                            (year) => DropdownMenuItem(
                              child: Text(year.toString()),
                              value: year,
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedYear = val;
                      selectedQuarter = null;
                      selectedMonth = null;
                      selectedWeek = null;
                    });
                    updateData(year: val);
                  },
                ),
                TextButton.icon(
                  icon: Icon(Icons.refresh, size: 18, color: Colors.blue),
                  label: Text("Đặt lại", style: TextStyle(color: Colors.blue)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedYear = null;
                      selectedQuarter = null;
                      selectedMonth = null;
                      selectedWeek = null;
                    });
                    updateData();
                  },
                ),
              ],
            ),

            /// LỰA CHỌN QUÝ
            if (selectedYear != null)
              Row(
                children: [
                  Text("Quý:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  DropdownButton<int>(
                    dropdownColor: Colors.white,

                    value: selectedQuarter,
                    hint: Text("Chọn quý"),
                    items:
                        [1, 2, 3, 4]
                            .map(
                              (q) => DropdownMenuItem<int>(
                                child: Text("Quý $q"),
                                value: q,
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedQuarter = val;
                        selectedMonth = null;
                        selectedWeek = null;
                      });
                      if (selectedYear != null && selectedQuarter != null) {
                        updateData(
                          year: selectedYear,
                          quarter: selectedQuarter,
                        );
                      }
                    },
                  ),
                ],
              ),

            if (selectedYear != null)
              Row(
                children: [
                  Text("Tháng:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  DropdownButton<int>(
                    dropdownColor: Colors.white,

                    value: selectedMonth,
                    hint: Text("Chọn tháng"),
                    items:
                        _getAvailableMonths().map((month) {
                          return DropdownMenuItem(
                            child: Text("Tháng $month"),
                            value: month,
                          );
                        }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedMonth = val;
                        selectedWeek = null;
                      });
                      if (selectedYear != null) {
                        updateData(year: selectedYear, month: selectedMonth);
                      }
                    },
                  ),
                ],
              ),

            if (selectedMonth != null)
              Row(
                children: [
                  Text("Tuần:", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(width: 12),
                  DropdownButton<int>(
                    dropdownColor: Colors.white,

                    value: selectedWeek,
                    hint: Text("Chọn tuần"),
                    items:
                        [1, 2, 3, 4]
                            .map(
                              (w) => DropdownMenuItem<int>(
                                child: Text("Tuần $w"),
                                value: w,
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedWeek = val;
                      });
                      if (selectedYear != null && selectedMonth != null) {
                        updateData(
                          year: selectedYear,
                          month: selectedMonth,
                          week: selectedWeek,
                        );
                      }
                    },
                  ),
                ],
              ),
            SizedBox(height: 12),
            Text(
              "Tùy chọn khoảng ngày:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                side: BorderSide(width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.white.withOpacity(0.3),
                elevation: 5, // Độ cao bóng đổ
              ),
              icon: Icon(Icons.date_range, color: Colors.black),
              label: Text(
                "Chọn khoảng thời gian",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  locale: const Locale('vi', 'VN'),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: selectedRange,
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData.light().copyWith(
                        primaryColor: Colors.blue, // Màu tiêu đề
                        hintColor: Colors.blue, // Màu chỉ dẫn
                        scaffoldBackgroundColor: Colors.white,
                        buttonTheme: ButtonThemeData(
                          textTheme: ButtonTextTheme.primary,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                          ),
                        ),
                        colorScheme: ColorScheme.light(primary: Colors.blue),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    selectedRange = picked;
                  });
                  updateCustomData(picked);
                }
              },
            ),

            SizedBox(height: 12),
            if (selectedRange != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Khoảng thời gian đã chọn:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "${DateFormat('dd/MM/yyyy').format(selectedRange!.start)} → ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      SizedBox(height: 8),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedRange = null;
                          });
                          updateData();
                        },
                      ),
                    ],
                  ),
                ],
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryCard("Đơn hàng", _getTotalOrders(), Colors.orange),
                _buildSummaryCard(
                  "Doanh thu",
                  _formatCurrency(_getTotalRevenue()),
                  Colors.green,
                ),
                _buildSummaryCard(
                  "Lợi nhuận",
                  _formatCurrency(_getTotalProfit()),
                  Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 16),

            _buildChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sales Performance",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            legend: Legend(isVisible: true),
            primaryXAxis: CategoryAxis(),
            series: <CartesianSeries<PerformanceDataDTO, String>>[
              LineSeries<PerformanceDataDTO, String>(
                name: 'Đơn hàng',
                dataSource: performanceData,
                xValueMapper: (data, _) => data.thoiGian,
                yValueMapper: (data, _) => data.tongSoDon,
              ),
              LineSeries<PerformanceDataDTO, String>(
                name: 'Doanh thu',
                dataSource: performanceData,
                xValueMapper: (data, _) => data.thoiGian,
                yValueMapper: (data, _) => data.tongDoanhThu,
              ),
              LineSeries<PerformanceDataDTO, String>(
                name: 'Lợi nhuận',
                dataSource: performanceData,
                xValueMapper: (data, _) => data.thoiGian,
                yValueMapper: (data, _) => data.tongLoiNhuan,
              ),
            ],
          ),
        ),

        SizedBox(height: 24),
        Text(
          "So sánh Doanh thu và Lợi nhuận",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<PerformanceDataDTO, String>(
                name: 'Doanh thu',
                dataSource: performanceData,
                xValueMapper: (PerformanceDataDTO data, _) => data.thoiGian,
                yValueMapper: (PerformanceDataDTO data, _) => data.tongDoanhThu,
                color: Colors.blue,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
              ColumnSeries<PerformanceDataDTO, String>(
                name: 'Lợi nhuận',
                dataSource: performanceData,
                xValueMapper: (PerformanceDataDTO data, _) => data.thoiGian,
                yValueMapper: (PerformanceDataDTO data, _) => data.tongLoiNhuan,
                color: Colors.green,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),
        Text(
          "Số lượng sản phẩm đã bán được",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries>[
              ColumnSeries<TotalProductByYear, String>(
                name: 'Sản phẩm',
                dataSource: toldResponse,
                xValueMapper: (TotalProductByYear data, _) => data.thoiGian,
                yValueMapper: (TotalProductByYear data, _) => data.tongSanPham,
                color: Colors.blue,
                dataLabelSettings: DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),
        Text(
          "Số lượng sản phẩm theo danh mục",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: _buildCategorySeries(),
          ),
        ),

        SizedBox(height: 24),
        Text(
          "Phân bố sản phẩm theo danh mục",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Container(
          height: 300,
          child: SfCircularChart(
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CircularSeries>[
              PieSeries<CategorySalesProjection, String>(
                dataSource: _aggregateCategoryData(),
                xValueMapper:
                    (CategorySalesProjection data, _) => data.tenLoaiSanPham,
                yValueMapper:
                    (CategorySalesProjection data, _) => data.tongSanPham,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                enableTooltip: true,
              ),
            ],
          ),
        ),

        // SizedBox(height: 24),
        // Text(
        //   "Product Comparison",
        //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        // ),
        // SizedBox(
        //   height: 300,
        //   child: SfCartesianChart(
        //     title: ChartTitle(text: 'Products Sold by Type'),
        //     primaryXAxis: CategoryAxis(),
        //     series: <CartesianSeries<ProductData, String>>[
        //       ColumnSeries<ProductData, String>(
        //         dataSource: productData,
        //         xValueMapper: (data, _) => data.category,
        //         yValueMapper: (data, _) => data.quantity,
        //         dataLabelSettings: DataLabelSettings(isVisible: true),
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(
        //   height: 200,
        //   child: SfCircularChart(
        //     legend: Legend(isVisible: true),
        //     series: <CircularSeries<ProductData, String>>[
        //       PieSeries<ProductData, String>(
        //         dataSource: productData,
        //         xValueMapper: (data, _) => data.category,
        //         yValueMapper: (data, _) => data.quantity,
        //         dataLabelSettings: DataLabelSettings(isVisible: true),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  List<CartesianSeries<CategorySalesProjection, String>>
  _buildCategorySeries() {
    // Get unique categories
    final categories =
        typeResponse.map((e) => e.tenLoaiSanPham).toSet().toList();

    // Create a series for each category
    return categories.map((category) {
      return ColumnSeries<CategorySalesProjection, String>(
        name: category,
        dataSource:
            typeResponse.where((e) => e.tenLoaiSanPham == category).toList(),
        xValueMapper: (CategorySalesProjection data, _) => data.thoiGian,
        yValueMapper: (CategorySalesProjection data, _) => data.tongSanPham,
        dataLabelSettings: DataLabelSettings(isVisible: true),
        // Assign a unique color for each category
        color: _getColorForCategory(category),
      );
    }).toList();
  }

  List<CategorySalesProjection> _aggregateCategoryData() {
    // Aggregate total products by category
    final Map<String, int> categoryTotals = {};
    for (var item in typeResponse) {
      categoryTotals.update(
        item.tenLoaiSanPham,
        (value) => value + item.tongSanPham,
        ifAbsent: () => item.tongSanPham,
      );
    }

    // Convert to CategorySalesProjection list
    return categoryTotals.entries.map((entry) {
      return CategorySalesProjection(
        thoiGian: 'Tổng', // Dummy value for pie chart
        tenLoaiSanPham: entry.key,
        tongSanPham: entry.value,
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.cyan,
      Colors.amber,
    ];
    final index = category.hashCode % colors.length;
    return colors[index];
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            SizedBox(height: 8),

            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _getAvailableMonths() {
    if (selectedQuarter != null) {
      return _monthsInQuarter(selectedQuarter!);
    }
    return List.generate(12, (i) => i + 1);
  }

  List<int> _monthsInQuarter(int quarter) {
    switch (quarter) {
      case 1:
        return [1, 2, 3];
      case 2:
        return [4, 5, 6];
      case 3:
        return [7, 8, 9];
      case 4:
        return [10, 11, 12];
      default:
        return [];
    }
  }
}
