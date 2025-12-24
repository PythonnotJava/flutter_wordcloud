part of 'picture_album_rule.dart';

/// 仅Windows系统，不需要考虑那么多
/// 需要3幅图，一幅图是前x个期刊的柱状图，一个是全期刊的词云图，一个期刊饼状图
class DrawJournalWidget extends StatefulWidget {
  final List<String> records;
  const DrawJournalWidget({super.key, required this.records});

  @override
  State<StatefulWidget> createState() => DrawJournalWidgetState();
}

class DrawJournalWidgetState extends State<DrawJournalWidget>
    with AutomaticKeepAliveClientMixin {
  /// 排序好的期刊数据（从高到低），也是图数据来源，长这样：{"Energy" : 223, "Fuels" : 142, "JCLP" : 112, ...}
  late SliceableMap<String, int> sortJournalsData;

  /// 期刊数量
  late final int sortJournalsDataLength;

  /// 显示的前几个期刊数量
  late int topCount;

  /// 显示的前几个期刊
  late SliceableMap<String, int> sortJournalsDataTopX;

  /// 柱状图横纵，默认纵向
  late bool journalHorizontal;

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

  /// 整理好的 Top X 饼图数据列表 (PieData 内部使用 ChartData)
  late List<ChartData> pieChartData;

  /// 饼状图数据对应占比
  late Map<String, double> pieChartDataPercent;

  /// 饼状图块颜色映射
  late List<Color>? pieColorMap;

  /// 饼状图数据
  late SliceableMap<String, int> sortJournalDataTopXforPie;

  final WidgetsToImageController pieController = WidgetsToImageController();
  final WidgetsToImageController barController = WidgetsToImageController();
  final WidgetsToImageController wordCloudController =
      WidgetsToImageController();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    barController.dispose();
    pieController.dispose();
    wordCloudController.dispose();
    super.dispose();
  }

  void initData() {
    final List<String> journals = [];
    for (final entry in widget.records) {
      final e = matchSo(entry: entry);
      if (e != null) {
        journals.add(e);
      }
    }

    final journalsData = getCountSingle(target: journals);
    final journalsSliceDict = sortByValue(data: journalsData, reverse: true);

    /// 配置初始化
    sortJournalsData = SliceableMap(journalsSliceDict);
    sortJournalsDataLength = sortJournalsData.length;
    topCount = 20.clamp(0, sortJournalsDataLength);
    sortJournalsDataTopX = sortJournalsData.slice(null, topCount);
    sortJournalDataTopXforPie = SliceableMap(sortJournalsDataTopX);
    sortJournalDataTopXforPie['Other'] = sortJournalsData
        .slice(
          topCount,
        )
        .values
        .fold(0, (a, b) => a + b);

    journalHorizontal = true;
    xTitle = journalHorizontal ? '记录数量' : '期刊';
    yTitle = journalHorizontal ? '期刊' : '记录数量';
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
    chartDataTopX = sortJournalsDataTopX.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();

    pieColorMap = null;
    percentOfPieFontSize = 12;
    pieLegendFontSize = 18;
    pieLegendPos = LegendPosition.left;

    // 饼图数据 (Top X) - 将 key 改为 "name (count)" 格式
    pieChartData = sortJournalDataTopXforPie.entries
        .map((e) => ChartData('${e.key} (${e.value})', e.value))
        .toList();
    final pieChartDataSums = pieChartData.fold(0, (a, b) => a + b.y);
    pieChartDataPercent = {};
    sortJournalDataTopXforPie.forEach((k, v) {
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
        borderRadius: journalHorizontal
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
                      '期刊分析工具',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    Tooltip(
                      message:
                          '保存柱状图图表为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/期刊柱状图_flutter.png", false),
                        icon: const Icon(Icons.bar_chart),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Tooltip(
                      message:
                          '保存词云图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/期刊词云图_flutter.png", true),
                        icon: const Icon(Icons.cloud),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Tooltip(
                      message:
                          '保存饼状图为 PNG 文件 (DPI: ${canvasDpi.toStringAsFixed(1)})',
                      child: IconButton.filled(
                        onPressed: () async =>
                            exportPng("$outDir/期刊饼状图_flutter.png", null),
                        icon: const Icon(Icons.pie_chart),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 1. 前 X 期刊柱状图 ---
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
                          '期刊发文量 Top $topCount 分布 (总期刊数: $sortJournalsDataLength)',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    plotAreaBackgroundColor: canvasBgColor,
                    plotAreaBorderWidth: 0,
                    isTransposed: journalHorizontal, // 设置为横向柱状图

                    // X 轴配置 (期刊或数量)
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(
                        text: journalHorizontal ? yTitle : xTitle, // 横向时 X 轴是数量
                        textStyle: TextStyle(
                            fontSize: journalHorizontal
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

                    // Y 轴配置 (数量或期刊)
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: journalHorizontal ? xTitle : yTitle, // 横向时 Y 轴是期刊
                        textStyle: TextStyle(
                            fontSize: journalHorizontal
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

            // --- 2. 全期刊词云图 (占位容器) ---
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
                    cloud: WordCloudLogic(sortJournalsData,
                        width: canvasWidth,
                        height: canvasHeight,
                        backgroundGradient: GradientTheme.greenCyan,
                        coloMap: ColorMapTheme.turboColors,
                        minFontSize: 16,
                        maxFontSize: 42,
                        fontFamily: 'TimesNewRoman',
                        wordSpacing: Offset(10, 10))),
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
                      text: 'WOS 期刊期刊分布 - 饼状图 (前$topCount个期刊)',
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

  @override
  bool get wantKeepAlive => true;
}

// main.dart() async {
//   final path = r'C:\Users\25654\Desktop\WOSAnalysis\src\main.dart.txt';
//   final records = await load(path: path);
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: Scaffold(
//       body: DrawJournalWidget(records: records),
//     ),
//   ));
// }
