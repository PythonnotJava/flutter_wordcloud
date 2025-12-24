import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'theme.dart';

/// 形状枚举
enum WordCloudShape {
  /// 矩形（默认）
  rectangle,
}

/// 画图逻辑
class WordCloudLogic {
  /// 画布尺寸
  final double width;
  final double height;

  /// 背景颜色
  Color backgroundColor = Colors.white;

  /// 背景渐变，如果有则优先高于背景颜色
  Gradient? backgroundGradient;

  /// 词云映射颜色
  /// rename from colorList
  List<Color>? coloMap;

  /// 最小字体
  double minFontSize = 12;

  /// 最大号字体，如果未指定，则根据minWeight / minFontSize = maxWeight / maxFontSize赋值
  late double maxFontSize;

  /// 词频表
  final Map<String, num> _freq = {};
  final List<PlacedWord> _placed = [];

  /// 文字旋转角度（弧度），0 表示不旋转
  double rotateStep = 0.0;

  /// 词云颜色
  WordCloudShape shape = WordCloudShape.rectangle;

  /// 词间距
  Offset? wordSpacing;

  late num _maxWeight;
  late num _minWeight;

  String? fontFamily;

  WordCloudLogic(
      Map<String, num> datas, {
        this.width = 800,
        this.height = 600,
        Color? backgroundColor,
        this.backgroundGradient,
        this.coloMap,
        this.minFontSize = 12,
        double? maxFontSize,
        this.rotateStep = 0.0,
        this.fontFamily,
        this.shape = WordCloudShape.rectangle,
        this.wordSpacing,
      }) : assert(datas.isNotEmpty) {
    if (backgroundColor != null) this.backgroundColor = backgroundColor;

    _freq.addAll(datas);
    _maxWeight = datas.values.map((e) => e.toDouble()).reduce(max);
    _minWeight = datas.values.map((e) => e.toDouble()).reduce(min);

    this.maxFontSize = maxFontSize ??
        (minFontSize * 8)
            .clamp(minFontSize, min(width, height) * 0.3)
            .toDouble();
    _layout();
  }

  /// 重新从已有的词频字典生成
  void generateFromFrequency(Map<String, double> frequency) {
    assert(frequency.isNotEmpty);
    _freq
      ..clear()
      ..addAll(frequency);
    if (_freq.isNotEmpty) {
      _maxWeight = _freq.values.reduce(max);
      _minWeight = _freq.values.reduce(min);
    }
    _layout();
  }

  void _layout() {
    _placed.clear();

    if (_freq.isEmpty) return;

    // 按频率倒序
    final sorted = _freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sorted) {
      final fontSize = _mapFontSize(entry.value.toDouble());
      final placed = _tryPlaceWord(entry.key, fontSize);
      if (placed != null) {
        _placed.add(placed);
      }
    }
  }

  double _mapFontSize(double weight) {
    if (_maxWeight == _minWeight) return maxFontSize;
    final ratio = (weight - _minWeight) / (_maxWeight - _minWeight);
    return minFontSize + ratio * (maxFontSize - minFontSize);
  }

  PlacedWord? _tryPlaceWord(String text, double fontSize) {
    final measure = _measureText(text, fontSize);
    final spacing = wordSpacing ?? Offset(8, 8);

    return _placeWithDynamicGrid(text, fontSize, measure, spacing);
  }

  /// 动态网格放置算法 - 自适应调整，优先保证大词能放进去
  PlacedWord? _placeWithDynamicGrid(
      String text,
      double fontSize,
      _TextSize size,
      Offset spacing,
      ) {
    final random = Random();
    final padding = 5.0;
    final availableWidth = width - padding * 2;
    final availableHeight = height - padding * 2;

    final wordWidth = size.width + spacing.dx;
    final wordHeight = size.height + spacing.dy;

    final importance = fontSize / maxFontSize;
    final maxAttempts = (500 * (1 + importance * 2)).toInt();

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      Offset pos;

      if (attempt < maxAttempts * 0.3) {
        final centerX = width / 2;
        final centerY = height / 2;
        final spread = min(availableWidth, availableHeight) * 0.3 * (1 - importance * 0.5);

        pos = Offset(
          centerX + (random.nextDouble() - 0.5) * spread * 2,
          centerY + (random.nextDouble() - 0.5) * spread * 2,
        );
      } else {
        pos = Offset(
          padding + random.nextDouble() * availableWidth,
          padding + random.nextDouble() * availableHeight,
        );
      }

      if (pos.dx - wordWidth / 2 < padding ||
          pos.dx + wordWidth / 2 > width - padding ||
          pos.dy - wordHeight / 2 < padding ||
          pos.dy + wordHeight / 2 > height - padding) {
        continue;
      }

      final rect = Rect.fromCenter(
        center: pos,
        width: wordWidth,
        height: wordHeight,
      );

      if (!_hasCollision(rect)) {
        return PlacedWord(text, pos, fontSize, rect);
      }
    }
    return null;
  }

  _TextSize _measureText(String text, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return _TextSize(tp.width, tp.height);
  }

  bool _hasCollision(Rect candidate) {
    for (final word in _placed) {
      if (word.rect.overlaps(candidate)) return true;
    }
    return false;
  }

  Color _getColorForWord(int index) {
    final colors = coloMap ??
        (_freq.length >= 50 ? ColorMapTheme.classic : ColorMapTheme.sunset);
    return colors[index % colors.length];
  }

  /// 绘制到 Canvas（供自定义使用）
  void draw(Canvas canvas) {
    _drawBackground(canvas);
    for (int i = 0; i < _placed.length; i++) {
      final w = _placed[i];
      final tp = TextPainter(
        text: TextSpan(
          text: w.text,
          style: TextStyle(
            fontSize: w.fontSize,
            color: _getColorForWord(i),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(w.center.dx, w.center.dy);
      if (rotateStep != 0) canvas.rotate(rotateStep);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _drawBackground(Canvas canvas) {
    final rect = Offset.zero & Size(width.toDouble(), height.toDouble());
    final paint = Paint();

    if (backgroundGradient != null) {
      paint.shader = backgroundGradient!.createShader(rect);
    } else {
      paint.color = backgroundColor;
    }
    canvas.drawRect(rect, paint);
  }

  /// 导出为 PNG 字节
  Future<Uint8List> exportToPngBytes({double ratio = 1.0}) async {
    final pw = (width * ratio).ceil();
    final ph = (height * ratio).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.scale(ratio, ratio);
    draw(canvas);

    final picture = recorder.endRecording();
    final img = await picture.toImage(pw, ph);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  List<PlacedWord> get placedWords => List.unmodifiable(_placed);
}

class PlacedWord {
  final String text;
  final Offset center;
  final double fontSize;
  final Rect rect;

  const PlacedWord(this.text, this.center, this.fontSize, this.rect);
}

class _TextSize {
  final double width;
  final double height;
  const _TextSize(this.width, this.height);
}