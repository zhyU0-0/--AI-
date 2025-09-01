import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../Presenter/chart_presenter.dart';

var logger = Logger();

class ChartPage extends StatefulWidget {

  ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  ChartPresenter chartPresenter = new ChartPresenter();
  Map<String,double> summary = {};
  Timer? _timer;
  List<PieData> pieData = [];
  List<Map<String, dynamic>> barData = [];
  List<Map<String, dynamic>> lineData = [];
  List<Widget> land=[
    PieChartSample2(pieData: [],),
    BarChartSample(productSales: [],),
    LineChartSample(monthlySales: [],)
  ];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer?.cancel();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Summery".tr),
        backgroundColor: Color(0xFFE8E6E0),
      ),
      body: Container(
          decoration: BoxDecoration(
              color: Color(0xFFE8E6E0),
          ),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          height: double.infinity,
          child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Expanded(child: ListView(
                  children: [
                    ListTile(
                      title:Column(
                        children:land ,
                      ),
                    )
                  ],
                )
                )
              ]
          )
      ),
    );
  }
  init()async{
    Timer(Duration(milliseconds: 500),() async {
      pieData = await chartPresenter.getPieData();
      barData = await chartPresenter.getBarData();
      lineData = await chartPresenter.getLineData();
      setState(() {
        land=[
          PieChartSample2(pieData: pieData,),
          BarChartSample(productSales: barData,),
          LineChartSample(monthlySales: lineData,)
        ];
      });
    });

  }


}

//饼图
class PieData {
  final String label;
  final double value;
  final Color color;

  PieData(this.label, this.value, this.color);
}

class PieChartSample2 extends StatefulWidget {
  List<PieData> pieData = [
    PieData('A', 25, Colors.blue),
    PieData('B', 25, Colors.red),
    PieData('C', 25, Colors.green),
    PieData('D', 25, Colors.amber),
  ];
  PieChartSample2({super.key,required this.pieData});
  @override
  State<StatefulWidget> createState() => PieChartSample2State();
}

class PieChartSample2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  List<PieData> pieData = [
    PieData('A', 25, Colors.blue),
    PieData('B', 25, Colors.red),
    PieData('C', 25, Colors.green),
    PieData('D', 25, Colors.amber),
  ];
  @override
  void didUpdateWidget(covariant PieChartSample2 oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if(widget.pieData != oldWidget.pieData && mounted){
      setState(() {
        logger.d("2222");
        pieData = widget.pieData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: showingSections(pieData),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(List<PieData> pieData) {
    return List.generate(pieData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 16.0;
      final radius = isTouched ? 70.0 : 50.0;
      final title = isTouched ? pieData[i].value.toString()+"%":pieData[i].label;

      return PieChartSectionData(
        color: pieData[i].color,
        value: pieData[i].value,
        title: '${title}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }
}

//折线图
class LineChartSample extends StatefulWidget {
  List<Map<String, dynamic>> monthlySales = [];
  LineChartSample({super.key,required this.monthlySales});

  @override
  State<LineChartSample> createState() => _LineChartSampleState();
}

class _LineChartSampleState extends State<LineChartSample> {
  List<Map<String, dynamic>> monthlySales = [
    {'类型': '1', 'sales': 0.0},
    {'类型': '2', 'sales': 0.0},
    {'类型': '3', 'sales': 0.0},
    {'类型': '4', 'sales': 0.0},
  ];
  double max_Y = 100;
  @override
  void didUpdateWidget(covariant LineChartSample oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    double sum = 0;
    if(widget.monthlySales!=oldWidget.monthlySales && mounted){

      for(var a in widget.monthlySales){
        logger.d(a["sales"]);
        sum += a["sales"];
      }
      setState(() {
        monthlySales = widget.monthlySales;
        max_Y = sum;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.7, // 图表宽高比
        child: LineChart(
          LineChartData(
            // ---- 网格线配置 ----
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              ),
            ),

            // ---- 坐标轴标题配置 ----
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(  // 替换 SideTitles
                sideTitles: SideTitles(  // 现在 SideTitles 是 AxisTitles 的子属性
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {  // 替换 getTextStyles 和 getTitles
                    return Text(
                      monthlySales[value.toInt()]['类型'],
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles( // 如果需要左侧也显示标签
                sideTitles: SideTitles(showTitles: false), // 默认隐藏
              ),
              topTitles: AxisTitles( // 如果需要左侧也显示标签
                sideTitles: SideTitles(showTitles: false), // 默认隐藏
              ),
              leftTitles: AxisTitles(  // 替换 SideTitles
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  },
                  reservedSize: 28,
                ),
              ),
            ),

            // ---- 边框配置 ----
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.blueGrey.withOpacity(0.3),
                width: 1,
              ),
            ),

            // ---- 折线数据 ----
            lineBarsData: [
              LineChartBarData(
                spots: monthlySales.asMap().entries.map((entry) {
                  // 将数据转换为FlSpot(x,y)
                  return FlSpot(
                    entry.key.toDouble(), // x轴位置（索引）
                    entry.value['sales'].toDouble(), // y轴值
                  );
                }).toList(),
                isCurved: false, // 是否使用曲线
                color: Colors.blueAccent,
                barWidth: 4, // 线宽
                isStrokeCapRound: true, // 线头圆角
                dotData: FlDotData(
                  show: true, // 显示数据点
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: Colors.blueAccent,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true, // 显示区域填充
                  color: Colors.blueAccent.withOpacity(0.3),
                ),
              ),
            ],

            // ---- 其他配置 ----
            minX: 0,
            maxX: monthlySales.length.toDouble() - 1,
            minY: 0,
            maxY: max_Y, // y轴最大值
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => Colors.blueGrey, // 替代 tooltipBgColor
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem('',
                      const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: '${spot.y.toInt()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}



//条形图
class BarChartSample extends StatefulWidget {
  List<Map<String, dynamic>> productSales = [];
  BarChartSample({super.key,required this.productSales});

  @override
  State<BarChartSample> createState() => _BarChartSampleState();
}

class _BarChartSampleState extends State<BarChartSample> {
  List<Map<String, dynamic>> productSales = [
    {'类型': '衣', 'sales': 0.0},
    {'类型': '食', 'sales': 0.0},
    {'类型': '住', 'sales': 0.0},
    {'类型': '行', 'sales': 0.0},
  ];
  double max_Y = 100;
  @override
  void didUpdateWidget(covariant BarChartSample oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    double sum = 0;
    if(widget.productSales!=oldWidget.productSales && mounted){
      for(var a in widget.productSales){
        logger.d(a["sales"]);
        sum += a["sales"];
      }
      setState(() {
        productSales = widget.productSales;
        max_Y = sum;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.7,
        child: BarChart(
            BarChartData(
              // ---- 对齐方式 ----
              alignment: BarChartAlignment.spaceAround,

              // ---- 网格线配置 ----
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false, // 只显示水平网格线
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1.0,
                ),
              ),

              // ---- 坐标轴标题配置 ----
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(  // 替换 SideTitles
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        productSales[value.toInt()]['类型'],
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles( // 如果需要左侧也显示标签
                  sideTitles: SideTitles(showTitles: false), // 默认隐藏
                ),
                topTitles: AxisTitles( // 如果需要左侧也显示标签
                  sideTitles: SideTitles(showTitles: false), // 默认隐藏
                ),
                leftTitles: AxisTitles(  // 替换 SideTitles
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 28,
                  ),
                ),
              ),

              // ---- 边框配置 ----
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.blueGrey.withOpacity(0.3),
                  width: 1,
                ),
              ),

              // ---- 条形数据 ----
              barGroups: productSales.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key, // x轴位置
                  barRods: [
                    BarChartRodData(
                      // 条形高度
                      color: Colors.blueAccent, // 条形颜色
                      width: 20, // 条形宽度
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true, // 显示背景条// 背景条高度（最大可能值）
                        color: Colors.grey.withOpacity(0.15),
                      ), toY: entry.value["sales"],
                    ),
                  ],
                );
              }).toList(),

              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  //tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    // 获取当前数据
                    final item = productSales[group.x.toInt()];
                    return BarTooltipItem(
                      '${item['类型']}\n', // 第一行显示类型
                      TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toInt()}', // 第二行显示数值
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    );
                  },
                  // 其他提示框样式配置
                  tooltipPadding: EdgeInsets.all(8),
                  tooltipMargin: 10,
                  fitInsideHorizontally: true, // 避免提示框超出屏幕
                ),
              ),
              maxY: max_Y,
            )
        ),
      ),
    );
  }
}
