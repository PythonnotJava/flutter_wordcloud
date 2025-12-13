part of 'picture_album_rule.dart';

/// 仅Windows系统，不需要考虑那么多
/// 需要3幅图，一幅图是前x个学科的柱状图，一个是全学科的词云图，一个是饼状图
class DrawSubjectWidget extends StatefulWidget {
  final List<String> records;
  const DrawSubjectWidget({super.key, required this.records});

  @override
  State<StatefulWidget> createState() => DrawSubjectWidgetState();
}

class DrawSubjectWidgetState extends State<DrawSubjectWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// 排序好的学科数据（从高到低），也是图数据来源，长这样：{"Chemistry" : 223, "Computer Science" : 142, "Math" : 112, ...}
  late SliceableMap<String, int> sortSubjectsData;

  /// 学科数量
  late final int sortSubjectsDataLength;

  /// 显示的前几个学科数量，柱状图只显示这几个，饼状图中，显示这前topCount个，剩下的放到新的键值对{other: sum_other}中
  late int topCount;

  /// 显示的前几个学科
  late SliceableMap<String, int> sortSubjectsDataTopX;

  /// 饼状图的sortSubjectsDataTopX+other
  late SliceableMap<String, int> sortSubjectsDataTopXforPie;

  /// 柱状图横纵，默认纵向
  late bool subjectHorizontal;

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

  /// 是否展示折线图于柱状图
  late bool showPlot;

  /// 折现颜色
  late Color plotColor;

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

  final WidgetsToImageController barController = WidgetsToImageController();
  final WidgetsToImageController pieController = WidgetsToImageController();
  final WidgetsToImageController wordCloudController =
      WidgetsToImageController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    wordCloudController.dispose();
    pieController.dispose();
    barController.dispose();
    super.dispose();
  }

  /// 初始化和数据预处理
  void initData() {
    final List<List<String>> subjects = [];
    for (final entry in widget.records) {
      final List<String>? e = matchWc(entry: entry);
      if (e != null) {
        subjects.add(e);
      }
    }
    final SliceableMap<String, int> subjectsData = SliceableMap(
        sortByValue(data: getCountMult(target: subjects), reverse: true));

    /// 配置初始化
    sortSubjectsData = subjectsData;
    sortSubjectsDataLength = sortSubjectsData.length;
    topCount = 20.clamp(0, sortSubjectsDataLength);
    sortSubjectsDataTopX = sortSubjectsData.slice(null, topCount);
    sortSubjectsDataTopXforPie = SliceableMap(sortSubjectsDataTopX);
    sortSubjectsDataTopXforPie['Other'] = sortSubjectsData
        .slice(
          topCount,
        )
        .values
        .fold(0, (a, b) => a + b);

    barChartData = sortSubjectsDataTopX.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();
    subjectHorizontal = true;
    xTitle = subjectHorizontal ? '记录数量' : '学科';
    yTitle = subjectHorizontal ? '学科' : '记录数量';
    xTitleFontSize = 18.0;
    yTitleFontSize = 18.0;
    xAxisRotation = 0;
    yAxisRotation = 0;
    xAxisFontSize = 12.0;
    yAxisFontSize = 12.0;
    canvasBgColor = Colors.lightBlue[50];
    gridColor = Colors.lightBlue.withValues(alpha: 0.3);
    barWidth = 0.8;
    canvasWidth = 1600;
    canvasHeight = 1000;
    canvasDpi = 3.0;
    showPlot = false;
    plotColor = Colors.red;
    pieColorMap = null;
    percentOfPieFontSize = 12;
    pieLegendFontSize = 18;
    pieLegendPos = LegendPosition.left;

    // 饼图数据 (Top X) - 将 key 改为 "name (count)" 格式
    pieChartData = sortSubjectsDataTopXforPie.entries
        .map((e) => ChartData('${e.key} (${e.value})', e.value))
        .toList();
    final pieChartDataSums = pieChartData.fold(0, (a, b) => a + b.y);
    pieChartDataPercent = {};
    sortSubjectsDataTopXforPie.forEach((k, v) {
      pieChartDataPercent['$k ($v)'] = v / pieChartDataSums;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 柱状图系列
    final List<CartesianSeries> barSeriesList = [
      ColumnSeries<ChartData, String>(
        dataSource: barChartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: '记录数量',
        width: barWidth,
        spacing: (1 - barWidth) / 2,
        dataLabelSettings: const DataLabelSettings(isVisible: false),
        animationDuration: 1000,
        borderRadius: subjectHorizontal
            ? const BorderRadius.only(
                bottomRight: Radius.circular(15), topRight: Radius.circular(15))
            : const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        color: const Color(0xFF457B9D).withValues(alpha: 0.75),
      )
    ];

    // 添加折线图系列
    if (showPlot) {
      barSeriesList.add(LineSeries<ChartData, String>(
        dataSource: barChartData,
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
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '图表工具',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    // --- 保存柱状图按钮 ---
                    Tooltip(
                      message:
                          '保存柱状图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/学科柱状图_flutter.png", true),
                        icon: const Icon(Icons.bar_chart),
                      ),
                    ),
                    const SizedBox(width: 50),
                    // --- 保存饼状图按钮 ---
                    Tooltip(
                      message:
                          '保存饼状图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/学科饼状图_flutter.png", false),
                        icon: const Icon(Icons.pie_chart),
                      ),
                    ),
                    const SizedBox(width: 50),
                    // --- 保存饼状图按钮 ---
                    Tooltip(
                      message:
                          '保存词云图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/学科词云图_flutter.png", null),
                        icon: const Icon(Icons.cloud),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 柱状图区域 ---
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
                controller: barController,
                child: AspectRatio(
                  aspectRatio: canvasWidth / canvasHeight,
                  child: SfCartesianChart(
                    title: ChartTitle(
                      text:
                          'WOS 文献学科分布 - 前$topCount个学科 (总计: $sortSubjectsDataLength)',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    plotAreaBackgroundColor: canvasBgColor,
                    plotAreaBorderWidth: 0,
                    isTransposed: subjectHorizontal,

                    // --- X 轴配置 ---
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: subjectHorizontal ? yTitle : xTitle,
                        textStyle: TextStyle(
                            fontSize: subjectHorizontal
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

                    // --- Y 轴配置 ---
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: subjectHorizontal ? xTitle : yTitle,
                        textStyle: TextStyle(
                            fontSize: subjectHorizontal
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
                      isVisible: true,
                      position: LegendPosition.top,
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- 饼状图区域 ---
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
                      text: 'WOS 文献学科分布 - 饼状图 (前$topCount个学科)',
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
            const SizedBox(
              height: 50,
            ),
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
                    cloud: WordCloudLogic(sortSubjectsData,
                        width: canvasWidth,
                        height: canvasHeight,
                        backgroundGradient: GradientTheme.greenCyan,
                        coloMap: ColorMapTheme.scientificColors,
                        minFontSize: 16,
                        maxFontSize: 42,
                        wordSpacing: Offset(50, 10))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> exportPng(String output, bool? bar) async {
    final Uint8List? bytes = await (bar == null
            ? wordCloudController
            : bar
                ? barController
                : pieController)
        .capturePng(pixelRatio: canvasDpi);
    if (bytes == null) {
      return;
    }
    final file = File(output);
    await file.writeAsBytes(bytes);
    debugPrint(
        '保存成功: ${file.path}，图片尺寸：$canvasWidth x $canvasHeight，缩放：$canvasDpi');
  }
}

// main.dart() async {
//   final path = r'C:\Users\25654\Desktop\WOSAnalysis\src\main.dart.txt';
//   final records = await load(path: path);
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Scaffold(
//       body: DrawSubjectWidget(records: records),
//     ),
//   ));
// }
