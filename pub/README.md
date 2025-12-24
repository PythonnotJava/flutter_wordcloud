# flutter_wordcloud

## 💡极简的Flutter云图

> pub下载: https://pub.dev/packages/flutter_wordcloud
>
> github仓库: https://github.com/PythonnotJava/flutter_wordcloud

只需要传入一个值表示权重的字典，即可一键生成云图。支持高清。

> 注：
>
> - 当遇到大量的样本时，建议传入maxFontSize以及尝试传入wordSpacing，否则可能出现权重大的词的尺寸小于权重小的词

## example

<table style="width:100%; table-layout:fixed;">
  <tr>
    <td style="width:33%; padding:0;">
      <img src="https://PythonnotJava.github.io/src/pkg/flutter_wordclould/example/img/1766496638.png" style="width:100%; display:block;"  alt=""/>
    </td>
    <td style="width:33%; padding:0;">
      <img src="https://PythonnotJava.github.io/src/pkg/flutter_wordclould/example/img/1766496639.png" style="width:100%; display:block;"  alt=""/>
    </td>
    <td style="width:33%; padding:0;">
      <img src="https://PythonnotJava.github.io/src/pkg/flutter_wordclould/example/img/1766496641.png" style="width:100%; display:block;"  alt=""/>
    </td>
  </tr>
</table>

--- 

```dart
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter_wordcloud/flutter_wordcloud.dart';

// 键值对数据
final jourData = {
  "JOURNAL OF CLEANER PRODUCTION": 47,
  "SUSTAINABILITY": 32,
  "SCIENCE OF THE TOTAL ENVIRONMENT": 28,
  "AMA-AGRICULTURAL MECHANIZATION IN ASIA AFRICA AND LATIN AMERICA": 19,
  "ENVIRONMENTAL SCIENCE AND POLLUTION RESEARCH": 17,
  "JOURNAL OF ENVIRONMENTAL MANAGEMENT": 16,
  "AGRICULTURE ECOSYSTEMS & ENVIRONMENT": 15,
  "AGRONOMY-BASEL": 12,
  "SCIENTIFIC REPORTS": 11,
  "AGRICULTURE-BASEL": 10,
  "ENVIRONMENTAL RESEARCH LETTERS": 10,
  "SOIL & TILLAGE RESEARCH": 8,
  "GLOBAL CHANGE BIOLOGY": 8,
  "AGRICULTURAL SYSTEMS": 7,
  "GEODERMA": 7,
  "FRONTIERS IN ENVIRONMENTAL SCIENCE": 7,
  "BIOGEOSCIENCES": 7,
  "ECOLOGICAL INDICATORS": 6,
  "INTERNATIONAL JOURNAL OF LIFE CYCLE ASSESSMENT": 6,
  "ATMOSPHERIC CHEMISTRY AND PHYSICS": 6,
  "FRONTIERS IN SUSTAINABLE FOOD SYSTEMS": 5,
  "ATMOSPHERIC ENVIRONMENT": 5,
  "SOIL BIOLOGY & BIOCHEMISTRY": 5,
  "MITIGATION AND ADAPTATION STRATEGIES FOR GLOBAL CHANGE": 5,
  "FIELD CROPS RESEARCH": 5,
  "SOIL SCIENCE SOCIETY OF AMERICA JOURNAL": 5,
  "NATURE COMMUNICATIONS": 5,
  "FRESENIUS ENVIRONMENTAL BULLETIN": 4,
  "ENVIRONMENT DEVELOPMENT AND SUSTAINABILITY": 4,
  "NUTRIENT CYCLING IN AGROECOSYSTEMS": 4,
  "SUSTAINABLE PRODUCTION AND CONSUMPTION": 4,
  "BIOMASS CONVERSION AND BIOREFINERY": 4,
  "RENEWABLE & SUSTAINABLE ENERGY REVIEWS": 4,
  "PLOS ONE": 4,
  "GLOBAL CHANGE BIOLOGY BIOENERGY": 4,
  "ENVIRONMENTAL POLLUTION": 4,
  "REGIONAL ENVIRONMENTAL CHANGE": 4,
  "FORESTS": 4,
  "LAND DEGRADATION & DEVELOPMENT": 4,
  "HELIYON": 3,
  "ARCHIVES OF AGRONOMY AND SOIL SCIENCE": 3,
  "ENVIRONMENTAL TECHNOLOGY & INNOVATION": 3,
  "ANTHROPOCENE": 3,
  "PLANT AND SOIL": 3,
  "JOURNAL OF SOILS AND SEDIMENTS": 3,
  "AGRICULTURAL WATER MANAGEMENT": 3,
  "JOURNAL OF THE SCIENCE OF FOOD AND AGRICULTURE": 3,
  "ENERGIES": 3,
  "PEDOSPHERE": 3,
  "SOIL USE AND MANAGEMENT": 3,
  "PLANTS-BASEL": 3,
  "CANADIAN JOURNAL OF SOIL SCIENCE": 2,
  "EARTHS FUTURE": 2,
  "EUROPEAN JOURNAL OF AGRONOMY": 2,
  "INDUSTRIAL CROPS AND PRODUCTS": 2,
  "RESOURCES CONSERVATION AND RECYCLING": 2,
  "COMMUNICATIONS IN SOIL SCIENCE AND PLANT ANALYSIS": 2,
  "GLOBAL ENVIRONMENTAL CHANGE-HUMAN AND POLICY DIMENSIONS": 2,
  "APPLIED SCIENCES-BASEL": 2,
  "APPLIED SOIL ECOLOGY": 2,
  "EUROPEAN JOURNAL OF SOIL SCIENCE": 2,
  "JOURNAL OF HYDROLOGY": 2,
  "CATENA": 2,
  "JOURNAL OF MATERIALS RESEARCH AND TECHNOLOGY-JMR&T": 2,
  "FOOD POLICY": 2,
  "JOURNAL OF FOREST ECONOMICS": 2,
  "ENVIRONMENT INTERNATIONAL": 2,
  "SOIL SCIENCE AND PLANT NUTRITION": 2,
  "DESALINATION AND WATER TREATMENT": 2,
  "ECOLOGICAL ECONOMICS": 2,
  "INTERNATIONAL JOURNAL OF ENVIRONMENTAL SCIENCE AND TECHNOLOGY": 2,
  "ENVIRONMENTAL SCIENCE & POLICY": 2,
  "ACS OMEGA": 2,
  "INTERNATIONAL JOURNAL OF ENVIRONMENTAL RESEARCH AND PUBLIC HEALTH": 2,
  "INTERNATIONAL JOURNAL OF AGRICULTURAL AND BIOLOGICAL ENGINEERING": 2,
  "FRONTIERS IN PLANT SCIENCE": 2,
  "PROCEEDINGS OF THE NATIONAL ACADEMY OF SCIENCES OF THE UNITED STATES OF": 2,
  "INTERNATIONAL SOIL AND WATER CONSERVATION RESEARCH": 2,
  "RANGELAND JOURNAL": 2,
  "SCIENCE": 2,
  "GLOBAL BIOGEOCHEMICAL CYCLES": 2,
  "ENVIRONMENTAL DEVELOPMENT": 2,
  "ANIMAL PRODUCTION SCIENCE": 2,
  "FOREST ECOSYSTEMS": 2,
  "FOREST POLICY AND ECONOMICS": 2,
  "IFOREST-BIOGEOSCIENCES AND FORESTRY": 2,
  "AGRONOMY FOR SUSTAINABLE DEVELOPMENT": 2,
  "FOREST ECOLOGY AND MANAGEMENT": 2,
  "BIOENERGY RESEARCH": 2,
  "JOURNAL OF ENVIRONMENTAL QUALITY": 2,
  "INTERNATIONAL JOURNAL OF GREENHOUSE GAS CONTROL": 2,
  "JOURNAL OF GEOPHYSICAL RESEARCH-BIOGEOSCIENCES": 2,
  "MATERIALS": 1,
  "IEEE JOURNAL OF SELECTED TOPICS IN APPLIED EARTH OBSERVATIONS AND REMOTE": 1,
  "PADDY AND WATER ENVIRONMENT": 1,
  "FRONTIERS IN MICROBIOLOGY": 1,
  "ENERGY SOURCES PART A-RECOVERY UTILIZATION AND ENVIRONMENTAL EFFECTS": 1,
  "PROCESSES": 1,
  "SCIENCE OF ADVANCED MATERIALS": 1,
  "SUSTAINABLE ENERGY TECHNOLOGIES AND ASSESSMENTS": 1
};
final subject = {
  "Environmental Sciences": 313,
  "Green & Sustainable Science & Technology": 104,
  "Soil Science": 70,
  "Engineering, Environmental": 67,
  "Agronomy": 60,
  "Environmental Studies": 50,
  "Ecology": 45,
  "Energy & Fuels": 41,
  "Multidisciplinary Sciences": 35,
  "Agriculture, Multidisciplinary": 34,
  "Meteorology & Atmospheric Sciences": 33,
  "Geosciences, Multidisciplinary": 32,
  "Plant Sciences": 29,
  "Agricultural Engineering": 28,
  "Forestry": 21,
  "Food Science & Technology": 19,
  "Biodiversity Conservation": 18,
  "Water Resources": 18,
  "Engineering, Chemical": 14,
  "Economics": 12,
  "Biotechnology & Applied Microbiology": 11,
  "Materials Science, Multidisciplinary": 11,
  "Chemistry, Multidisciplinary": 9,
  "Chemistry, Analytical": 8,
  "Chemistry, Applied": 7,
  "Agricultural Economics & Policy": 6,
  "Chemistry, Physical": 6,
  "Public, Environmental & Occupational Health": 5,
  "Engineering, Electrical & Electronic": 5,
  "Geography, Physical": 5,
  "Physics, Applied": 5,
  "Engineering, Civil": 4,
  "Agriculture, Dairy & Animal Science": 4,
  "Metallurgy & Metallurgical Engineering": 4,
  "Marine & Freshwater Biology": 3,
  "Thermodynamics": 3,
  "Remote Sensing": 3,
  "Imaging Science & Photographic Technology": 3,
  "Nanoscience & Nanotechnology": 3,
  "Nutrition & Dietetics": 3,
  "Biochemistry & Molecular Biology": 2,
  "Engineering, Multidisciplinary": 2,
  "Construction & Building Technology": 2,
  "Instruments & Instrumentation": 2,
  "Biology": 2,
  "Fisheries": 2,
  "Mathematics, Interdisciplinary Applications": 2,
  "Geography": 2,
  "Polymer Science": 2,
  "Mining & Mineral Processing": 2,
  "Toxicology": 2,
  "Mathematical & Computational Biology": 1,
  "Biochemical Research Methods": 1,
  "Limnology": 1,
  "Spectroscopy": 1,
  "Microbiology": 1,
  "Operations Research & Management Science": 1,
  "Physics, Condensed Matter": 1,
  "Physics, Mathematical": 1,
  "Logic": 1,
  "Entomology": 1,
  "Astronomy & Astrophysics": 1,
  "Materials Science, Ceramics": 1,
  "Mathematics, Applied": 1,
  "Chemistry, Inorganic & Nuclear": 1,
  "Biophysics": 1,
  "Electrochemistry": 1,
  "Computer Science, Artificial Intelligence": 1,
  "Computer Science, Interdisciplinary Applications": 1,
  "Engineering, Mechanical": 1,
  "Mechanics": 1,
  "Automation & Control Systems": 1,
  "Veterinary Sciences": 1,
  "Computer Science, Information Systems": 1,
  "Telecommunications": 1,
  "Management": 1,
  "Materials Science, Composites": 1,
  "Nuclear Science & Technology": 1,
  "Computer Science, Theory & Methods": 1,
  "Chemistry, Organic": 1
};
final research = {
  "Agriculture": 186,
  "Science & Technology - Other Topics": 141,
  "Engineering": 90,
  "Environmental Sciences": 49,
  "Energy & Fuels": 40,
  "Geology": 31,
  "Chemistry": 30,
  "Plant Sciences": 29,
  "Meteorology & Atmospheric Sciences": 29,
  "Forestry": 21,
  "Food Science & Technology": 19,
  "Biodiversity & Conservation": 18,
  "Water Resources": 18,
  "Materials Science": 13,
  "Business & Economics": 12,
  "Biotechnology & Applied Microbiology": 11,
  "Physical Geography": 5,
  "Physics": 5,
  "Public, Environmental & Occupational": 4,
  "Metallurgy & Metallurgical Engineering": 4,
  "Meteorology & Atmospheric": 4,
  "Computer Science": 3,
  "Environmental": 3,
  "Remote Sensing": 3,
  "Marine & Freshwater Biology": 3,
  "Thermodynamics": 3,
  "Mathematics": 3,
  "Biochemistry & Molecular Biology": 3,
  "Fisheries": 2,
  "Imaging Science &": 2,
  "Construction & Building Technology": 2,
  "Toxicology": 2,
  "Polymer Science": 2,
  "Geography": 2,
  "Nutrition": 2,
  "Instruments & Instrumentation": 2,
  "Life Sciences & Biomedicine - Other Topics": 2,
  "Environmental Sciences &": 2,
  "Mining & Mineral Processing": 2,
  "Imaging": 1,
  "Veterinary Sciences": 1,
  "Spectroscopy": 1,
  "Public, Environmental & Occupational Health": 1,
  "Nutrition & Dietetics": 1,
  "Science & Technology -": 1,
  "Operations Research & Management Science": 1,
  "Entomology": 1,
  "Astronomy & Astrophysics": 1,
  "Nuclear Science & Technology": 1,
  "Biophysics": 1,
  "Mechanics": 1,
  "Automation & Control Systems": 1,
  "Telecommunications": 1,
  "Microbiology": 1,
  "Mathematical & Computational Biology": 1
};

// 简单的保持功能
Future<File> saveUint8ListToDesktop(Uint8List data) async {
  final String? desktopPath = await getDownloadsDirectory()
      .then((dir) => dir?.parent.path)
      .then((parent) => '$parent/Desktop');

  final String desktop = desktopPath ??
      r'C:/Users/' + Platform.environment['USERNAME']! + r'/Desktop';

  final Directory desktopDir = Directory(desktop);
  if (!await desktopDir.exists()) {
    await desktopDir.create(recursive: true);
  }

  final String fullPath =
      "$desktop/${DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000}.png";
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
                _buildExample(jourData, '期刊统计', GradientTheme.coolGray,
                    ColorMapTheme.mono, minFontSize: 10),
                _buildExample(subject, '学科统计', GradientTheme.sunset,
                    ColorMapTheme.turboColors, minFontSize: 16),
                _buildExample(research, '研究领域统计', GradientTheme.greenCyan,
                  ColorMapTheme.scientificColors, minFontSize: 20,),
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

  Widget _buildExample(Map<String, int> datas, String title, Gradient gradient,
      List<Color> colorMap,
      {Offset? wordSpacing, double? minFontSize, double? maxFontSize}) {
    final wc = WordCloudLogic(
      datas,
      width: 1600,
      height: 1000,
      minFontSize: minFontSize ?? 10,
      maxFontSize: maxFontSize,
      backgroundGradient: gradient,
      coloMap: colorMap,
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
            IconButton(
                onPressed: () async => savePng(wc),
                icon: const Icon(Icons.save))
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
}
```

