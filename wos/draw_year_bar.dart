part of 'picture_album_rule.dart';

/// 仅Windows系统，不需要考虑那么多
class DrawYearBar extends StatefulWidget {
  final List<String> records;
  const DrawYearBar({super.key, required this.records});

  @override
  State<DrawYearBar> createState() => DrawYearBarState();
}

class DrawYearBarState extends State<DrawYearBar>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 统计的合法年份量
  late int counterYearFound;

  /// 排序好的年份数据，也是柱状图来源，长这样：{2014 : 23, 2015 : 42, ...}
  late Map<String, int> sortYearsData;

  /// 排序方式，默认是从早到晚
  late bool yearReverse;

  /// 柱状图横纵，默认纵向
  late bool yearHorizontal;

  /// x轴标题
  late String xTitle;

  /// y轴标题
  late String yTitle;

  /// x轴标题字体大小
  late double xTitleFontSize; // 确保类型是 double

  /// y轴标题字体大小
  late double yTitleFontSize; // 确保类型是 double

  /// x轴标签旋转角度（度）
  late double xAxisRotation;

  /// y轴标签旋转角度（度）
  late double yAxisRotation;

  /// x轴标签字体大小
  late double xAxisFontSize;

  /// y轴标签字体大小
  late double yAxisFontSize;

  /// 画布背景颜色，null表示透明
  late Color? canvasBgColor;

  /// 网格颜色，null表示不显示网格
  late Color? gridColor;

  /// 柱子宽度参数
  late double barWidth;

  /// 画布宽
  late double canvasWidth;

  /// 画布高
  late double canvasHeight;

  /// 画布dpi（用于导出图片时的分辨率倍数）
  late double canvasDpi;

  /// 整理好的图表数据列表
  late List<ChartData> chartData;

  /// 是否展示折线图
  late bool showPlot;

  /// 折现颜色
  late Color plotColor;

  final WidgetsToImageController controller = WidgetsToImageController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initData() {
    /// 配置初始化
    counterYearFound = 0;
    yearReverse = false;
    yearHorizontal = true;
    xTitle = yearHorizontal ? '记录数量' : '年份';
    yTitle = yearHorizontal ? '年份' : '记录数量';
    xTitleFontSize = 18.0;
    yTitleFontSize = 18.0;
    xAxisRotation = 0;
    yAxisRotation = 0;
    xAxisFontSize = 12.0;
    yAxisFontSize = 12.0;
    canvasBgColor = null;
    gridColor = Colors.lightBlue.withValues(alpha: 0.3);
    barWidth = 0.8;
    canvasWidth = 1600;
    canvasHeight = 1000;
    canvasDpi = 3.0;
    showPlot = true;
    plotColor = Colors.red;

    List<String> years = [];

    for (final entry in widget.records) {
      final rt = matchPy(entry: entry);
      if (rt != null) {
        years.add(rt);
        counterYearFound++;
      }
    }

    final Map<String, int> yearsData = getCountSingle(target: years);

    final sortedEntries = yearsData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    sortYearsData = Map.fromEntries(sortedEntries);
    chartData =
        sortYearsData.entries.map((e) => ChartData(e.key, e.value)).toList();

    if (yearReverse) {
      chartData = chartData.reversed.toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ... (系列列表构建保持不变)
    final List<CartesianSeries> seriesList = [
      // 1. 柱状图系列
      ColumnSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: '记录数量',
        width: barWidth,
        spacing: (1 - barWidth) / 2,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
        animationDuration: 1000,
        borderRadius: yearHorizontal
            ? const BorderRadius.only(
                bottomRight: Radius.circular(15), topRight: Radius.circular(15))
            : const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        color: const Color(0xFF457B9D).withValues(alpha: 0.75),
      )
    ];

    // 2. 添加折线图系列
    if (showPlot) {
      seriesList.add(LineSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: '趋势',
        color: const Color(0xFFE63946),
        width: 3,
        markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            height: 10,
            width: 10),
        animationDuration: 1000,
      ));
    }

    // --- 布局美化 ---
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0), // 添加整体内边距
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 工具栏靠左
          children: [
            // --- 工具栏美化 ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 适应内容宽度
                  children: [
                    const Text(
                      '图表工具',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    // --- 保存按钮 ---
                    Tooltip(
                      message:
                          '保存图表为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: exportPng,
                        icon: const Icon(Icons.save),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 图表区域 ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // 给图表区域一个背景，使其更清晰
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: canvasWidth, // <- 应用 canvasWidth
              // height: canvasHeight, // 取消固定高度，让图表自己根据内容调整
              child: WidgetsToImage(
                controller: controller,
                child: AspectRatio(
                  // 使用 AspectRatio 来控制图表尺寸比例
                  aspectRatio: canvasWidth / canvasHeight, // 根据设定的宽高比例
                  child: SfCartesianChart(
                    title: ChartTitle(
                      text: 'WOS 文献年份分布 (总数: $counterYearFound)',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    plotAreaBackgroundColor:
                        canvasBgColor, // <- 应用 canvasBgColor
                    plotAreaBorderWidth: 0, // 移除边框，更美观
                    isTransposed: yearHorizontal,

                    // --- X 轴配置 (CategoryAxis: 年份) ---
                    primaryXAxis: CategoryAxis(
                      // ... (X 轴配置保持不变)
                      title: AxisTitle(
                        text: yearHorizontal ? yTitle : xTitle,
                        textStyle: TextStyle(
                            fontSize: yearHorizontal
                                ? yTitleFontSize
                                : xTitleFontSize), // <- 应用 xTitleFontSize/yTitleFontSize
                      ),
                      labelStyle: TextStyle(
                          fontSize: xAxisFontSize), // <- 应用 xAxisFontSize
                      labelRotation:
                          xAxisRotation.toInt(), // <- 应用 xAxisRotation
                      majorGridLines: gridColor != null
                          ? MajorGridLines(color: gridColor!)
                          : const MajorGridLines(width: 0), // <- 应用 gridColor
                      axisLine: const AxisLine(width: 0),
                    ),

                    // --- Y 轴配置 (NumericAxis: 数量) ---
                    primaryYAxis: NumericAxis(
                      // ... (Y 轴配置保持不变)
                      title: AxisTitle(
                        text: yearHorizontal ? xTitle : yTitle,
                        textStyle: TextStyle(
                            fontSize: yearHorizontal
                                ? xTitleFontSize
                                : yTitleFontSize), // <- 应用 yTitleFontSize/xTitleFontSize
                      ),
                      labelStyle: TextStyle(
                          fontSize: yAxisFontSize), // <- 应用 yAxisFontSize
                      labelRotation:
                          yAxisRotation.toInt(), // <- 应用 yAxisRotation
                      majorGridLines: gridColor != null
                          ? MajorGridLines(color: gridColor!)
                          : const MajorGridLines(width: 0), // <- 应用 gridColor
                      axisLine: const AxisLine(width: 0),
                      decimalPlaces: 0,
                    ),

                    // 系列（数据）
                    series: seriesList,

                    // 悬停/工具提示
                    tooltipBehavior:
                        TooltipBehavior(enable: true, shared: true),

                    // 图例
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.top,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> exportPng([String output = '$outDir/年份_flutter.png']) async {
    final Uint8List? bytes = await controller.capturePng(pixelRatio: canvasDpi);
    if (bytes == null) {
      return;
    }
    final file = File(output);
    await file.writeAsBytes(bytes);
    debugPrint('保存成功: ${file.path}，图片尺寸：${(
      canvasWidth,
      canvasHeight
    )}，缩放：$canvasDpi}');
  }
}

// main.dart() async {
//   final path = r'C:\Users\25654\Desktop\WOSAnalysis\src\main.dart.txt';
//   final records = await load(path: path);
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Scaffold(
//       body: DrawYearBar(records: records),
//     ),
//   ));
// }
