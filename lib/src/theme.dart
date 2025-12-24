import 'package:flutter/painting.dart';

/// 背景渐变
final class GradientTheme {
  /// 线性渐变“构造函数” —— 传入首尾颜色
  static LinearGradient linear({
    required Color start,
    required Color end,
    Alignment begin = Alignment.centerLeft,
    Alignment endAlign = Alignment.centerRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: endAlign,
      colors: [start, end],
    );
  }

  /// 线性渐变“构造函数” —— 传入颜色数组
  static LinearGradient linearMulti({
    required List<Color> colors,
    Alignment begin = Alignment.topLeft,
    Alignment endAlign = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: endAlign,
      colors: colors,
    );
  }

  /// 蓝 → 青（科技感）
  static const LinearGradient blueCyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2193B0),
      Color(0xFF6DD5ED),
    ],
  );

  /// 紫 → 蓝（梦幻感）
  static const LinearGradient purpleBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7F00FF),
      Color(0xFFE100FF),
    ],
  );

  /// 橙 → 粉（活力感）
  static const LinearGradient orangePink = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF512F),
      Color(0xFFDD2476),
    ],
  );

  /// 绿 → 青（清新感）
  static const LinearGradient greenCyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF11998E),
      Color(0xFF38EF7D),
    ],
  );

  /// 红 → 橙（热情感）
  static const LinearGradient redOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF00000),
      Color(0xFFDC281E),
    ],
  );

  /// 日落渐变
  static const LinearGradient sunset = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF512F),
      Color(0xFFDD2476),
      Color(0xFF753A88),
    ],
  );

  /// 极光渐变
  static const LinearGradient aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C9FF),
      Color(0xFF92FE9D),
      Color(0xFF00F2FE),
    ],
  );

  /// 蓝紫梦境
  static const LinearGradient dreamBluePurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4776E6),
      Color(0xFF8E54E9),
      Color(0xFFE94057),
    ],
  );

  /// 烈焰渐变
  static const LinearGradient fire = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF12711),
      Color(0xFFF5AF19),
      Color(0xFFF12711),
    ],
  );

  /// 深蓝商务风
  static const LinearGradient deepBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F2027),
      Color(0xFF203A43),
      Color(0xFF2C5364),
    ],
  );

  /// 暗紫氛围
  static const LinearGradient darkPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF232526),
      Color(0xFF414345),
    ],
  );

  /// 冷灰过渡
  static const LinearGradient coolGray = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFBDC3C7),
      Color(0xFF2C3E50),
    ],
  );
}

/// 词云颜色映射
final class ColorMapTheme {
  const ColorMapTheme._();

  /// 传入首尾的颜色以及分段个数实现渐变版本颜色映射
  static List<Color> linearMap({
    required Color from,
    required Color to,
    required int step,
  }) {
    assert(step >= 2);

    List<Color> colors = [];

    for (int i = 0; i < step; i++) {
      double t = i / (step - 1);
      int a = ((from.a * 255.0 + (to.a * 255.0 - from.a * 255.0) * t).round() &
          0xff);
      int r = ((from.r * 255.0 + (to.r * 255.0 - from.r * 255.0) * t).round() &
          0xff);
      int g = ((from.g * 255.0 + (to.g * 255.0 - from.g * 255.0) * t).round() &
          0xff);
      int b = ((from.b * 255.0 + (to.b * 255.0 - from.b * 255.0) * t).round() &
          0xff);

      colors.add(Color.fromARGB(a, r, g, b));
    }

    return colors;
  }

  /// 经典高饱和配色（适合词云），适合样本非常多
  static const List<Color> classic = [
    Color(0xFFF44336), // red
    Color(0xFFE91E63), // pink
    Color(0xFF9C27B0), // purple
    Color(0xFF673AB7), // deep purple
    Color(0xFF3F51B5), // indigo
    Color(0xFF2196F3), // blue
    Color(0xFF03A9F4), // light blue
    Color(0xFF00BCD4), // cyan
    Color(0xFF009688), // teal
    Color(0xFF4CAF50), // green
    Color(0xFF8BC34A), // light green
    Color(0xFFFFC107), // amber
    Color(0xFFFF9800), // orange
    Color(0xFFFF5722), // deep orange
  ];

  /// 等价于 Flutter 的 Colors.primaries（不含 grey），适合样本非常多
  static const List<Color> primaries = [
    Color(0xFFF44336), // red
    Color(0xFFE91E63), // pink
    Color(0xFF9C27B0), // purple
    Color(0xFF673AB7), // deepPurple
    Color(0xFF3F51B5), // indigo
    Color(0xFF2196F3), // blue
    Color(0xFF03A9F4), // lightBlue
    Color(0xFF00BCD4), // cyan
    Color(0xFF009688), // teal
    Color(0xFF4CAF50), // green
    Color(0xFF8BC34A), // lightGreen
    Color(0xFFCDDC39), // lime
    Color(0xFFFFEB3B), // yellow
    Color(0xFFFFC107), // amber
    Color(0xFFFF9800), // orange
    Color(0xFFFF5722), // deepOrange
    Color(0xFF795548), // brown
    Color(0xFF607D8B), // blueGrey
  ];

  /// 柔和莫兰迪色系（高级感）
  static const List<Color> morandi = [
    Color(0xFFBFA5A0),
    Color(0xFFA3A9AA),
    Color(0xFF8E9BAE),
    Color(0xFF9C89B8),
    Color(0xFFF0A6CA),
    Color(0xFFEFC3E6),
    Color(0xFFB8BEDD),
    Color(0xFF89C2D9),
  ];

  /// 商务蓝灰系（图表适合）
  static const List<Color> business = [
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF1976D2),
    Color(0xFF1E88E5),
    Color(0xFF42A5F5),
    Color(0xFF90CAF9),
    Color(0xFFB0BEC5),
    Color(0xFF78909C),
  ];

  /// 深色系霓虹风
  static const List<Color> neonDark = [
    Color(0xFFFF1744),
    Color(0xFFF50057),
    Color(0xFFD500F9),
    Color(0xFF651FFF),
    Color(0xFF3D5AFE),
    Color(0xFF2979FF),
    Color(0xFF00E5FF),
    Color(0xFF1DE9B6),
  ];

  /// 温暖日落系，适合样本少
  static const List<Color> sunset = [
    Color(0xFFFF5F6D),
    Color(0xFFFFC371),
    Color(0xFFFFA17F),
    Color(0xFFFAD961),
    Color(0xFFF76B1C),
    Color(0xFFFF9A8B),
  ];

  /// 黑白灰极简
  static const List<Color> mono = [
    Color(0xFF000000),
    Color(0xFF424242),
    Color(0xFF757575),
    Color(0xFFBDBDBD),
    Color(0xFFEEEEEE),
  ];

  /// 科研风
  static const List<Color> scientificColors = [
    Color(0xFF332288),
    Color(0xFF88CCEE),
    Color(0xFF117733),
    Color(0xFF44AA99),
    Color(0xFFDDCC77),
    Color(0xFFCC6677),
    Color(0xFFAA4499),
    Color(0xFF999933),
  ];

  /// Turbo风格
  static const List<Color> turboColors = [
    Color(0xFF30123B),
    Color(0xFF4662D7),
    Color(0xFF36B7C5),
    Color(0xFF53FC2A),
    Color(0xFFC1F334),
    Color(0xFFF7C93A),
    Color(0xFFEE5E38),
    Color(0xFFD73E4A),
    Color(0xFFA62A5C),
    Color(0xFF7A0F6E),
  ];
}
