import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'sliceable_dict.dart';

final loadRule = RegExp(r'PT (.*?\r?\nER\r?\n)', dotAll: true);

/// 匹配记录到列表
Future<List<String>> load({required String path}) async {
  final text = await File(path).readAsString(encoding: utf8);
  // print(text);
  final matches = loadRule.allMatches(text);
  return matches.map((m) => m.group(1)!).toList();
}

/// 快速合并两个大纯文本文件
Future<void> mergeLargeTextFile({
  required String file1,
  required String file2,
  required String output,
}) async {
  final outSink = File(output).openWrite(mode: FileMode.write);

  final f1Stream = File(file1).openRead();
  await for (final chunk in f1Stream) {
    outSink.add(chunk);
  }

  outSink.add([10]);

  final f2Stream = File(file2)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  int skipped = 0;
  await for (final line in f2Stream) {
    if (skipped < 2) {
      skipped++;
      continue;
    }
    outSink.add(utf8.encode('$line\n'));
  }

  await outSink.close();
}

/// 按照值排序，reverse为True从大到小
Map<String, K> sortByValue<K extends Comparable>(
    {required Map<String, K> data, bool reverse = false}) {
  final entries = data.entries.toList();
  reverse
      ? entries.sort((a, b) => b.value.compareTo(a.value))
      : entries.sort((a, b) => a.value.compareTo(b.value));

  return Map.fromEntries(entries);
}

/// 按照键排序，reverse为True从大到小
Map<K, V> sortByKey<K extends Comparable, V>(
    {required Map<K, V> data, bool reverse = false}) {
  final entries = data.entries.toList();
  reverse
      ? entries.sort((a, b) => b.key.compareTo(a.key))
      : entries.sort((a, b) => a.key.compareTo(b.key));
  return Map.fromEntries(entries);
}

final publishYear = RegExp(r'^PY\s+(\d{4})', multiLine: true);

/// 匹配发表年份
String? matchPy({required String entry}) {
  final py = publishYear.firstMatch(entry);
  return py?.group(1)?.trim();
}

final sourceName = RegExp(r'^SO (.+)', multiLine: true);

/// 匹配期刊名称
String? matchSo({required String entry}) {
  final so = sourceName.firstMatch(entry);
  return so?.group(1)?.trim();
}

final titleInfo = RegExp(r"TI\s+(.+?)(?=\nSO)", dotAll: true);

/// 匹配文章标题，标题是必有的
/// 匹配从 TI 到 SO 之间的所有内容，跨越多行
String matchTi({required String entry}) {
  final title = titleInfo.firstMatch(entry)!.group(1)!.trim();
  return title.replaceAll(RegExp(r'\r?\n\s+'), ' ');
}

final theZ9 = RegExp(r"Z9\s+(\d+)");

/// 匹配综合被引次数
int? matchZ9({required String entry}) {
  final match = theZ9.firstMatch(entry);
  String? rt = match?.group(1);
  if (rt != null) {
    return int.parse(rt);
  }
  return null;
}

final subjectCategory = RegExp(r"^[A-Z]{2} ");

/// 匹配学科分类
List<String>? matchWc({required String entry}) {
  final lines = entry.split('\n');
  final List<String> wcLines = [];
  bool inWc = false;

  for (final line in lines) {
    if (inWc) {
      if (subjectCategory.hasMatch(line) && !line.startsWith('WC ')) {
        break;
      }
      if (line.startsWith(' ') ||
          line.startsWith('\t') ||
          line.trim().isEmpty) {
        wcLines.add(line.trim());
      } else {
        wcLines.add(line.trim());
      }
    } else {
      if (line.startsWith('WC ')) {
        inWc = true;
        wcLines.add(line.substring(3).trim());
      }
    }
  }

  if (wcLines.isEmpty) return null;

  final wcText = wcLines.join(' ');

  final categories = wcText
      .split(';')
      .map((c) => c.trim())
      .where((c) => c.isNotEmpty)
      .toList();

  return categories;
}

final searchArea = RegExp(r"^SC\s+(.+)$", multiLine: true);

/// 匹配研究领域，这个很短，没有多行情况，即使有，不差这一两个被忽略
List<String>? matchSc({required String entry}) {
  final match = searchArea.firstMatch(entry);
  if (match == null) return null;

  final text = match.group(1)!.trim();
  final categories =
      text.split(';').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();

  return categories.isEmpty ? null : categories;
}

final publishMatch = RegExp(r"^PU\s+(.+)$", multiLine: true);

/// 匹配出版商，只考虑唯一性
String? matchPu({required String entry}) {
  final match = publishMatch.firstMatch(entry);
  if (match == null) return null;
  return match.group(1)!.trim();
}

final theDOI = RegExp(r'^DI (.+)', multiLine: true);

/// 匹配文章的DOI
String? matchDi({required String entry}) {
  final match = theDOI.firstMatch(entry);
  return match?.group(1)!.trim();
}

/// 根据引用次数对论文排序，默认从大到小
Map<String, int> sortByZ9(
    {required List<String> records, bool reverse = true}) {
  final results = <String, int>{};
  for (final entry in records) {
    int? z9 = matchZ9(entry: entry);
    String ti = matchTi(entry: entry);
    if (z9 != null) {
      results[ti] = z9;
    }
  }
  return sortByValue(data: results, reverse: reverse);
}

/// 对于单个值返回进行统计，适用于年份、出版商等情况
Map<String, int> getCountSingle({required List<String> target}) {
  final results = <String, int>{};

  for (final key in target) {
    results.update(key, (value) => value + 1, ifAbsent: () => 1);
  }

  return results;
}

/// 对于返回的列表系列进行统计，适用于学科分类、研究领域等情况
Map<String, int> getCountMult({required List<List<String>> target}) {
  final results = <String, int>{};
  for (final list in target) {
    for (final item in list) {
      results.update(item, (value) => value + 1, ifAbsent: () => 1);
    }
  }
  return results;
}

/// 根据引用次数对论文排序，默认从大到小，同时附加DOI
Map<String, List<dynamic>> sortByZ9DOI(
    {required List<String> records, bool reverse = true}) {
  final results = <String, List<dynamic>>{};
  for (final entry in records) {
    int? z9 = matchZ9(entry: entry);
    String ti = matchTi(entry: entry);
    String? doi = matchDi(entry: entry);
    if (z9 != null && doi != null) {
      results[ti] = [z9, doi];
    }
  }
  final entries = results.entries.toList();
  reverse
      ? entries.sort((a, b) {
          return b.value[0].compareTo(a.value[0]);
        })
      : entries.sort((a, b) {
          return a.value[0].compareTo(b.value[0]);
        });

  return Map.fromEntries(entries);
}

/// 根据一个键有多个值的某个值大小排序
/// 比如说{'A' : [32, 23], 'B' : [12, 0]}
Map<String, List<dynamic>> sortByPointValueDynamic({
  required Map<String, List<dynamic>> data,
  required int which,
  bool reverse = true,
}) {
  final entries = data.entries.toList();

  entries.sort((a, b) {
    final aVal = a.value[which] as Comparable;
    final bVal = b.value[which] as Comparable;
    final cmp = aVal.compareTo(bVal);
    return reverse ? -cmp : cmp;
  });

  return Map.fromEntries(entries);
}

/// 生成文章引用排序的markdown表格
String genMdTableByReference(
    {required Map<String, List<dynamic>> articles, String? output}) {
  String tables = '|Article Name|DOI|Citations|\n|--|--|--|\n';
  articles.forEach((key, value) {
    tables += '|$key|${value[0]}|${value[1]}|\n';
  });
  if (output != null) {
    File file = File(output);
    file.writeAsStringSync(tables);
  }
  return tables;
}

Future<void> toJson(
    {required Map<String, List<dynamic>> articles,
    required String output}) async {
  final jsonString = JsonEncoder.withIndent('  ').convert(articles);
  await File(output).writeAsString(jsonString);
}

/// md表格生成word表格
/// 确保系统已安装 pandoc
Future<void> genWordTable(
    {required Map<String, List<dynamic>> articles,
    required String output}) async {
  final process = await Process.start(
    'pandoc',
    ['-f', 'markdown', '-t', 'docx', '-o', output],
  );

  process.stdin.writeln(genMdTableByReference(articles: articles));
  await process.stdin.close();

  /// 捕获错误输出
  final error = await process.stderr.transform(utf8.decoder).join();
  if (error.isNotEmpty) {
    print('Pandoc error: $error');
  }

  /// 等待进程结束
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Pandoc exited with code $exitCode');
  }
}

main() async {
  final path = r'C:\Users\25654\Desktop\WOSAnalysis\src\main.txt';
  final records = await load(path: path);
  for (final entry in records) {
    print(matchTi(entry: entry));
    print(matchDi(entry: entry));
    print(matchZ9(entry: entry));
    print(matchPu(entry: entry));
    print(matchPy(entry: entry));
    print(matchSc(entry: entry));
    print(matchSo(entry: entry));
    print(matchWc(entry: entry));
    print("-----------------------------");
  }
}
