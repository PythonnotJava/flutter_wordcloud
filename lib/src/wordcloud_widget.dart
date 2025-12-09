import 'package:flutter/material.dart';

import 'wordcloud_logic.dart';

/// 最简洁高效的词云 Widget
/// 直接接收一个已经计算好的 WordCloudLogic 实例
class WordCloudView extends StatelessWidget {
  /// 已经完成布局的 WordCloudLogic 实例
  final WordCloudLogic cloud;

  /// 可选：是否自动根据 cloud.width / cloud.height 拉伸（默认 true）
  final bool fit;

  const WordCloudView({
    super.key,
    required this.cloud,
    this.fit = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = cloud.width.toDouble();
    final height = cloud.height.toDouble();

    final child = CustomPaint(
      painter: _WordCloudPainter(cloud),
      /// 保证画布大小和逻辑实例完全一致
      size: Size(width, height),
    );

    if (!fit) {
      /// 不拉伸，直接固定大小（常用于 ListView、GridView 中）
      return SizedBox(width: width, height: height, child: child);
    }

    /// 默认行为：自适应父容器（推荐）
    return AspectRatio(
      aspectRatio: width / height,
      child: child,
    );
  }
}

/// 真正的绘制器
class _WordCloudPainter extends CustomPainter {
  final WordCloudLogic cloud;

  const _WordCloudPainter(this.cloud);

  @override
  void paint(Canvas canvas, Size size) {
    /// 防止父容器给的 size 和 cloud 实际大小不一致（安全缩放）
    final scaleX = size.width / cloud.width;
    final scaleY = size.height / cloud.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    canvas.save();
    canvas.scale(scale, scale);
    cloud.draw(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WordCloudPainter old) => old.cloud != cloud;
}