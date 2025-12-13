part of 'picture_album_rule.dart';

/// 仅Windows系统，不需要考虑那么多
/// 需要3幅图，一幅图是前x个研究领域的柱状图，一个是全研究领域的词云图，还有个饼状图
class DrawResearchWidget extends StatefulWidget {
  final List<String> records;
  const DrawResearchWidget({super.key, required this.records});

  @override
  State<StatefulWidget> createState() => DrawResearchWidgetState();
}

class DrawResearchWidgetState extends State<DrawResearchWidget>
    with AutomaticKeepAliveClientMixin {
  /// 排序好的研究领域数据（从高到低），也是图数据来源，长这样：{"Material" : 1321, "Science" : 233 ...}
  late SliceableMap<String, int> sortResearchData;

  /// 研究领域类别数量
  late final int sortResearchDataLength;

  /// 显示的前几个研究领域数量
  late int topCount;

  /// 显示的前几个研究领域
  late SliceableMap<String, int> sortResearchDataTopX;

  /// 柱状图横纵，默认纵向
  late bool researchHorizontal;

  /// x轴标题
  late String xTitle;

  /// y轴标题
  late String yTitle;

  /// x轴标题字体大小
  late double xTitleFontSize;

  /// y轴标题字体大小
  late double yTitleFontSize;

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

  /// 是否展示折线图
  late bool showPlot;

  /// 折现颜色
  late Color plotColor;

  /// 整理好的图表数据列表 (用于柱状图)
  late List<ChartData> chartDataTopX;

  /// 饼状图百分比字体大小
  late double percentOfPieFontSize;

  /// 饼状图图例字体大小
  late double pieLegendFontSize;

  /// 饼状图图例位置（相对于饼上下左右）或者使用Flutter内置方向枚举
  late LegendPosition pieLegendPos;

  /// 整理好的 Top X 柱状图数据列表
  late List<ChartData> barChartData;

  /// 整理好的 Top X 饼图数据列表 (PieData 内部使用 ChartData)
  late List<ChartData> pieChartData;

  /// 饼状图数据对应占比
  late Map<String, double> pieChartDataPercent;

  /// 饼状图块颜色映射
  late List<Color>? pieColorMap;

  /// 饼状图的sortSubjectsDataTopX+other
  late SliceableMap<String, int> sortResearchDataTopXforPie;

  final WidgetsToImageController barController = WidgetsToImageController();
  final WidgetsToImageController wordCloudController =
      WidgetsToImageController();
  final WidgetsToImageController pieController = WidgetsToImageController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    barController.dispose();
    wordCloudController.dispose();
    pieController.dispose();
    super.dispose();
  }

  void initData() {
    final List<List<String>> journals = [];
    for (final entry in widget.records) {
      final List<String>? e = matchSc(entry: entry);
      if (e != null) {
        journals.add(e);
      }
    }

    final journalsData = getCountMult(target: journals);
    final journalsSliceDict = sortByValue(data: journalsData, reverse: true);

    /// 配置初始化
    sortResearchData = SliceableMap(journalsSliceDict);
    sortResearchDataLength = sortResearchData.length;
    topCount = 20.clamp(0, sortResearchDataLength);
    sortResearchDataTopX = sortResearchData.slice(null, topCount);
    sortResearchDataTopXforPie = SliceableMap(sortResearchDataTopX);
    sortResearchDataTopXforPie['Other'] = sortResearchData
        .slice(
          topCount,
        )
        .values
        .fold(0, (a, b) => a + b);
    barChartData = sortResearchDataTopX.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();
    researchHorizontal = true;
    xTitle = researchHorizontal ? '记录数量' : '研究领域';
    yTitle = researchHorizontal ? '研究领域' : '记录数量';
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
    showPlot = false;
    plotColor = Colors.red;
    chartDataTopX = sortResearchDataTopX.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();
    pieColorMap = null;
    percentOfPieFontSize = 12;
    pieLegendFontSize = 18;
    pieLegendPos = LegendPosition.left;
    // 饼图数据 (Top X) - 将 key 改为 "name (count)" 格式
    pieChartData = sortResearchDataTopXforPie.entries
        .map((e) => ChartData('${e.key} (${e.value})', e.value))
        .toList();
    final pieChartDataSums = pieChartData.fold(0, (a, b) => a + b.y);
    pieChartDataPercent = {};
    sortResearchDataTopXforPie.forEach((k, v) {
      pieChartDataPercent['$k ($v)'] = v / pieChartDataSums;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final List<CartesianSeries> barSeriesList = [
      ColumnSeries<ChartData, String>(
        dataSource: chartDataTopX,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: '记录数量',
        width: barWidth,
        spacing: (1 - barWidth) / 2,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
        animationDuration: 1000,
        borderRadius: researchHorizontal
            ? const BorderRadius.only(
                topRight: Radius.circular(15), bottomRight: Radius.circular(15))
            : const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        color: const Color(0xFF457B9D).withValues(alpha: 0.75),
      )
    ];

    // --- 添加折线图系列 (如果开启) ---
    if (showPlot) {
      barSeriesList.add(LineSeries<ChartData, String>(
        dataSource: chartDataTopX,
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

    // --- 整体布局 ---
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 居中显示图表和容器
          children: [
            // --- 工具栏 (占位，可自行添加控件) ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '研究领域分析工具',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    Tooltip(
                      message:
                          '保存柱状图图表为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/研究领域柱状图_flutter.png", false),
                        icon: const Icon(Icons.bar_chart),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Tooltip(
                      message:
                          '保存词云图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/研究领域词云图_flutter.png", true),
                        icon: const Icon(Icons.cloud),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Tooltip(
                      message:
                          '保存饼状图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/研究领域饼状图_flutter.png", null),
                        icon: const Icon(Icons.pie_chart),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 1. 前 X 研究领域柱状图 ---
            Container(
              margin: const EdgeInsets.only(bottom: 40), // 与下方词云图分隔
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: canvasWidth,
              child: WidgetsToImage(
                controller: barController, // 用于保存图片
                child: AspectRatio(
                  aspectRatio: canvasWidth / canvasHeight,
                  child: SfCartesianChart(
                    title: ChartTitle(
                      text:
                          '研究领域 Top $topCount 分布 (总研究领域数: $sortResearchDataLength)',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    plotAreaBackgroundColor: canvasBgColor,
                    plotAreaBorderWidth: 0,
                    isTransposed: researchHorizontal, // 设置为横向柱状图

                    // X 轴配置 (研究领域或数量)
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text:
                            researchHorizontal ? yTitle : xTitle, // 横向时 X 轴是数量
                        textStyle: TextStyle(
                            fontSize: researchHorizontal
                                ? yTitleFontSize
                                : xTitleFontSize),
                      ),
                      labelStyle: TextStyle(fontSize: xAxisFontSize),
                      labelRotation: xAxisRotation.toInt(),
                      majorGridLines: gridColor != null
                          ? MajorGridLines(color: gridColor!)
                          : const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                    ),

                    // Y 轴配置 (数量或研究领域)
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: researchHorizontal
                            ? xTitle
                            : yTitle, // 横向时 Y 轴是研究领域
                        textStyle: TextStyle(
                            fontSize: researchHorizontal
                                ? xTitleFontSize
                                : yTitleFontSize),
                      ),
                      labelStyle: TextStyle(fontSize: yAxisFontSize),
                      labelRotation: yAxisRotation.toInt(),
                      majorGridLines: gridColor != null
                          ? MajorGridLines(color: gridColor!)
                          : const MajorGridLines(width: 0),
                      axisLine: const AxisLine(width: 0),
                      decimalPlaces: 0,
                    ),

                    series: barSeriesList,

                    tooltipBehavior:
                        TooltipBehavior(enable: true, shared: true),

                    legend: Legend(
                      isVisible: showPlot, // 如果有折线图才显示图例
                      position: LegendPosition.top,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),

            // --- 2. 全研究领域词云图 (占位容器) ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: canvasWidth,
              child: WidgetsToImage(
                controller: wordCloudController,
                child: WordCloudView(
                    cloud: WordCloudLogic(sortResearchData,
                        width: canvasWidth,
                        height: canvasHeight,
                        backgroundGradient: GradientTheme.greenCyan,
                        coloMap: ColorMapTheme.scientificColors,
                        minFontSize: 16)),
              ),
            ),
            const SizedBox(height: 50),
            // -- 3. 饼状图 --
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              width: canvasWidth,
              child: WidgetsToImage(
                controller: pieController,
                child: AspectRatio(
                  aspectRatio: canvasWidth / canvasHeight,
                  child: SfCircularChart(
                    title: ChartTitle(
                      text: 'WOS 文献研究领域分布 - 饼状图 (前$topCount个研究领域)',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: canvasBgColor,
                    series: <CircularSeries>[
                      PieSeries<ChartData, String>(
                        pointColorMapper: pieColorMap != null
                            ? (_, i) => pieColorMap![i]
                            : null,
                        dataSource: pieChartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        name: '记录数量',
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          textStyle: TextStyle(
                              fontSize: percentOfPieFontSize,
                              fontWeight: FontWeight.bold),
                          useSeriesColor: true,
                        ),
                        dataLabelMapper: (ChartData data, _) {
                          final percent = pieChartDataPercent[data.x] ?? 0;
                          return '${(percent * 100).toStringAsFixed(1)}%';
                        },
                        animationDuration: 1000,
                      )
                    ],
                    legend: Legend(
                      isVisible: true,
                      position: pieLegendPos,
                      textStyle: TextStyle(fontSize: pieLegendFontSize),
                    ),
                    tooltipBehavior:
                        TooltipBehavior(enable: true, shared: true),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportPng(String output, bool? cloud) async {
    final Uint8List? bytes = await (cloud == null
            ? pieController
            : cloud
                ? wordCloudController
                : barController)
        .capturePng(pixelRatio: canvasDpi);
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
//       body: DrawResearchWidget(records: records),
//     ),
//   ));
// }
