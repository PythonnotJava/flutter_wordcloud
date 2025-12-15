part of 'picture_album_rule.dart';

class DrawWorldMapPage extends StatefulWidget {
  const DrawWorldMapPage({super.key});

  @override
  State<DrawWorldMapPage> createState() => DrawWorldMapPageState();
}

class DrawWorldMapPageState extends State<DrawWorldMapPage>
    with AutomaticKeepAliveClientMixin {
  late Future<MapData> _mapDataFuture;

  // 尺寸和缩放参数
  final int canvasWidth = 1600;
  final int canvasHeight = 1000;
  final double canvasDpi = 3;
  late bool showBar;

  @override
  void initState() {
    super.initState();
    _mapDataFuture = _loadMapData();
    showBar = true;
  }

  @override
  bool get wantKeepAlive => true;

  // 异步加载地图数据 - 使用 compute 在隔离线程中处理
  Future<MapData> _loadMapData() async {
    try {
      // 在独立的 isolate 中读取 Excel，避免阻塞主线程
      final Map<String, int> loadedDatas = await compute(
        _readExcelInIsolate,
        r'C:\Users\25654\Desktop\农业机械化与农业碳排放\src\savedrecs.xlsx',
      );

      if (loadedDatas.isEmpty) {
        throw Exception('数据为空');
      }

      final turboColors = ColorMapTheme.scientificColors;
      final maxWeight = loadedDatas.values.reduce((a, b) => a > b ? a : b);
      final minWeight = 0;

      final countryData = _getCountryData(loadedDatas);
      final colorMappers = _generateColorMappers(turboColors, maxWeight);

      final dataSource = MapShapeSource.asset(
        'assets/maps.json',
        shapeDataField: 'name',
        dataCount: countryData.length,
        primaryValueMapper: (int index) => countryData[index].country,
        shapeColorValueMapper: (int index) => countryData[index].value,
        shapeColorMappers: colorMappers,
      );

      return MapData(
        dataSource: dataSource,
        countryData: countryData,
        maxWeight: maxWeight,
        minWeight: minWeight,
        colorMaps: turboColors,
      );
    } catch (e) {
      throw Exception('加载数据失败: $e');
    }
  }

  // 静态方法，用于在 isolate 中执行
  static Future<Map<String, int>> _readExcelInIsolate(String path) async {
    return await readExcel(path: path);
  }

  // 动态生成颜色映射器
  List<MapColorMapper> _generateColorMappers(List<Color> colors, int maxValue) {
    final adjustedMax = maxValue < colors.length
        ? colors.length.toDouble()
        : maxValue.toDouble();

    final interval = adjustedMax / colors.length;
    List<MapColorMapper> mappers = [];

    for (int i = 0; i < colors.length; i++) {
      final from = i * interval;
      final to = (i + 1) * interval;

      mappers.add(MapColorMapper(
        from: from,
        to: to,
        color: colors[i],
      ));
    }

    return mappers;
  }

  String _mapCountryName(String country) {
    const mapping = {
      'USA': 'United States',
      'England': 'United Kingdom',
      'Scotland': 'United Kingdom',
      'Wales': 'United Kingdom',
      'South Korea': 'Republic of Korea',
      'Dominican Rep': 'Dominican Republic',
      'Turkey': 'Turkey',
      'Czech Republic': 'Czech Republic',
      'Taiwan': 'Taiwan',
    };
    return mapping[country] ?? country;
  }

  List<CountryData> _getCountryData(Map<String, int> datasMap) {
    return datasMap.entries.map((e) {
      String mappedName = _mapCountryName(e.key);
      return CountryData(mappedName, e.value.toDouble());
    }).toList();
  }

  // 计算合适的刻度值
  List<int> _calculateTicks(int maxWeight) {
    if (maxWeight == 0) return [0];

    int step;
    if (maxWeight <= 50) {
      step = 10;
    } else if (maxWeight <= 100) {
      step = 20;
    } else if (maxWeight <= 500) {
      step = 50;
    } else if (maxWeight <= 1000) {
      step = 100;
    } else if (maxWeight <= 5000) {
      step = 500;
    } else {
      step = 1000;
    }

    final roundedMax = ((maxWeight / step).ceil() * step);

    List<int> ticks = [];
    for (int i = 0; i <= roundedMax; i += step) {
      ticks.add(i);
    }

    if (ticks.length < 2) {
      ticks = [0, maxWeight];
    }

    return ticks;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('全球国家数据分布热力图'),
        actions: [
          IconButton(
            onPressed: () async => exportPng(),
            icon: const Icon(Icons.map),
          ),
          const SizedBox(width: 300),
        ],
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<MapData>(
        future: _mapDataFuture,
        builder: (context, snapshot) {
          // 加载中
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    '正在加载数据...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          // 加载失败
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _mapDataFuture = _loadMapData();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新加载'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // 加载成功
          if (!snapshot.hasData) {
            return const Center(
              child: Text('没有数据'),
            );
          }

          final mapData = snapshot.data!;

          return Column(
            children: [
              const SizedBox(height: 20),
              // 显示数据范围信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '数据范围: ${mapData.minWeight} - ${mapData.maxWeight}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '国家数量: ${mapData.countryData.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: WidgetsToImage(
                        controller: controller,
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 地图部分
                              SizedBox(
                                width: canvasWidth.toDouble(),
                                height: canvasHeight.toDouble(),
                                child: SfMaps(
                                  layers: [
                                    MapShapeLayer(
                                      source: mapData.dataSource,
                                      showDataLabels: false,
                                      shapeTooltipBuilder:
                                          (BuildContext context, int index) {
                                        if (index < 0 ||
                                            index >=
                                                mapData.countryData.length) {
                                          return const SizedBox.shrink();
                                        }
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            '${mapData.countryData[index].country}\n数值: ${mapData.countryData[index].value.toInt()}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                      tooltipSettings: const MapTooltipSettings(
                                        color: Colors.transparent,
                                      ),
                                      color: Colors.grey[300],
                                      strokeColor: Colors.white,
                                      strokeWidth: 0.5,
                                    ),
                                  ],
                                ),
                              ),
                              // 色标部分
                              if (showBar)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    top: 50,
                                    bottom: 50,
                                    right: 20,
                                  ),
                                  child: CustomPaint(
                                    painter: ColorBarPainter(
                                      colors: mapData.colorMaps,
                                      ticks: _calculateTicks(mapData.maxWeight),
                                    ),
                                    size: const Size(80, 900),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Future<void> exportPng([String output = '$outDir/国家发文_flutter.png']) async {
    final Uint8List? bytes = await controller.capturePng(pixelRatio: canvasDpi);
    if (bytes == null) {
      return;
    }
    final file = File(output);
    await file.writeAsBytes(bytes);
    debugPrint(
        '保存成功: ${file.path},图片尺寸:${(canvasWidth, canvasHeight)},缩放:$canvasDpi');
  }

  final WidgetsToImageController controller = WidgetsToImageController();
}

// 地图数据模型
class MapData {
  final MapShapeSource dataSource;
  final List<CountryData> countryData;
  final int maxWeight;
  final int minWeight;
  final List<Color> colorMaps;

  MapData({
    required this.dataSource,
    required this.countryData,
    required this.maxWeight,
    required this.minWeight,
    required this.colorMaps,
  });
}

class CountryData {
  CountryData(this.country, this.value);
  final String country;
  final double value;
}

// 自定义绘制颜色条的 Painter
class ColorBarPainter extends CustomPainter {
  final List<Color> colors;
  final List<int> ticks;

  ColorBarPainter({required this.colors, required this.ticks});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 25.0;
    final barHeight = size.height - 40;
    final barLeft = 0.0;
    final barTop = 20.0;

    // 绘制颜色条
    final rect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);

    final gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: colors,
      stops: List.generate(colors.length, (i) => i / (colors.length - 1)),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // 绘制圆角矩形
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rrect, paint);

    // 绘制边框
    final borderPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    // 绘制刻度和标签
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );

    final maxValue = ticks.last;
    if (maxValue == 0) return;

    for (int i = 0; i < ticks.length; i++) {
      final value = ticks[i];
      final ratio = value / maxValue;
      final y = barTop + barHeight * (1 - ratio);

      // 绘制刻度线
      final tickPaint = Paint()
        ..color = Colors.black54
        ..strokeWidth = 1.5;
      canvas.drawLine(
        Offset(barLeft + barWidth, y),
        Offset(barLeft + barWidth + 5, y),
        tickPaint,
      );

      // 绘制刻度标签
      textPainter.text = TextSpan(
        text: value.toString(),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(barLeft + barWidth + 10, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(ColorBarPainter oldDelegate) {
    return oldDelegate.colors != colors || oldDelegate.ticks != ticks;
  }
}
