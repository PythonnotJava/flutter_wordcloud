import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:widgets_to_image/widgets_to_image.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

// 这里定义了 load, matchPy, getCountSingle等
import 'util.dart';
import 'sliceable_dict.dart';
import 'package:flutter_wordcloud/flutter_wordcloud.dart';

part 'draw_journal.dart';
part 'draw_world_map.dart';
part 'draw_publish.dart';
part 'draw_research.dart';
part 'draw_subject.dart';
part 'draw_year_bar.dart';

/// 用于图表数据模型的类
class ChartData {
  const ChartData(this.x, this.y);
  final String x;
  final int y;
}

/// 保存文件夹
const outDir = r"C:\Users\25654\Desktop\农业碳排放\out_final";

// 为了更高度自定义，暂时放弃这个interface
// mixin DrawRule<T extends StatefulWidget> on State<T> {
//   late final xxx;
//   @mustCallSuper
//   void initData();
// }

class TabDemoPage extends StatefulWidget {
  const TabDemoPage({super.key, required this.records});
  final List<String> records;

  @override
  State<StatefulWidget> createState() => TabDemoPageState();
}

class TabDemoPageState extends State<TabDemoPage> {
  late List<Widget> pages;
  @override
  void initState() {
    pages = [
      DrawYearBar(records: widget.records),
      DrawJournalWidget(records: widget.records),
      DrawResearchWidget(records: widget.records),
      DrawPublishWidget(records: widget.records),
      DrawSubjectWidget(records: widget.records),
      const DrawWorldMapPage()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "年份", icon: Icon(Icons.date_range)),
              Tab(text: "期刊", icon: Icon(Icons.search)),
              Tab(text: "研究领域", icon: Icon(Icons.star)),
              Tab(text: "出版社", icon: Icon(Icons.shop)),
              Tab(text: "学科", icon: Icon(Icons.subject)),
              Tab(text: "国家发文地图", icon: Icon(Icons.map),)
            ],
          ),
        ),

        /// Tab 内容区域
        body: TabBarView(children: pages),
      ),
    );
  }
}

void main() async {
  final path = r'C:\Users\25654\Desktop\农业碳排放\src\savedrecs.txt';
  final records = await load(path: path);
  runApp(MaterialApp(
    title: 'WOSAnalysis For Flutter',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      fontFamily: 'TimesNewRoman', // 全局字体
    ),
    home: TabDemoPage(
      records: records,
    ),
  ));
}
