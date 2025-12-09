# flutter_wordcloud

## 💡极简的Flutter云图

> 下载: https://pub.dev/packages/flutter_wordcloud

只需要传入一个值表示权重的字典，即可一键生成云图。支持高清。

## example

```dart
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_wordcloud/flutter_wordcloud.dart';

int counter = 0;

Future<File> saveUint8ListToDesktop(
    Uint8List data) async {
  final String? desktopPath = await getDownloadsDirectory()
      .then((dir) => dir?.parent.path)
      .then((parent) => '$parent/Desktop');

  final String desktop = desktopPath ??
      r'C:\Users\' + Platform.environment['USERNAME']! + r'\Desktop';

  final Directory desktopDir = Directory(desktop);
  if (!await desktopDir.exists()) {
    await desktopDir.create(recursive: true);
  }

  final String fullPath = "$desktop/${counter++}.png";
  final File file = File(fullPath);
  await file.writeAsBytes(data);

  debugPrint('已保存到桌面：$fullPath');
  return file;
}

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("WordCloud 形状演示")),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildExample(
                  "矩形 (Rectangle)",
                  WordCloudShape.rectangle,
                  _gradientBlue(),
                  _colorMapPink(),
                ),
                _buildExample(
                  "矩形 (Rectangle)",
                  WordCloudShape.rectangle,
                  GradientTheme.fire,
                  ColorMapTheme.mono,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> savePng(WordCloudLogic wc) async {
    final data = await wc.exportToPngBytes(ratio: 3);
    await saveUint8ListToDesktop(data);
  }

  Widget _buildExample(
      String title,
      WordCloudShape shape,
      Gradient gradient,
      List<Color> colorMap, {
        Offset? wordSpacing,
      }) {
    final wc = WordCloudLogic(
      generateRandomMap(100),
      width: 1600,
      height: 1000,
      minFontSize: 10,
      shape: shape,
      backgroundGradient: gradient,
      colorList: colorMap,
      wordSpacing: wordSpacing,
    );

    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            IconButton(onPressed: () async => savePng(wc), icon: const Icon(Icons.save))
          ],
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: WordCloudView(cloud: wc),
        ),
      ],
    );
  }

  Gradient _gradientBlue() => const LinearGradient(
    colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  List<Color> _colorMapPink() => const [
    Color(0xFF000fff),
    Color(0xFF000000),
    Color(0xFF123456),
    Color(0xFF00ff00),
  ];

  /// key是a~z任意5~10个组成，value是randint（1， 51）
  Map<String, double> generateRandomMap(int count) {
    final rand = Random();
    final Map<String, double> result = {};

    String randomString(int length, Random rand) {
      const letters = 'abcdefghijklmnopqrstuvwxyz';
      return List.generate(length, (_) {
        return letters[rand.nextInt(letters.length)];
      }).join();
    }

    while (result.length < count) {
      final int len = 5 + rand.nextInt(6); // 5~10
      final String key = randomString(len, rand);
      final int value = 1 + rand.nextInt(51); // 1~51

      result[key] = value.toDouble();
    }

    return result;
  }
}
```

<table style="width:100%; table-layout:fixed;">
  <tr>
    <td style="width:33%; padding:0;">
      <img src="example/img/0.png" style="width:100%; display:block;"  alt=""/>
    </td>
    <td style="width:33%; padding:0;">
      <img src="example/img/1.png" style="width:100%; display:block;"  alt=""/>
    </td>
    <td style="width:33%; padding:0;">
      <img src="example/img/2.png" style="width:100%; display:block;"  alt=""/>
    </td>
  </tr>
</table>