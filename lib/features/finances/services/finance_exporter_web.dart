// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'finance_exporter.dart';

class WebFinanceExporter implements FinanceExporter {
  @override
  Future<void> save(String filename, String csvContent) async {
    final List<int> bytes = utf8.encode(csvContent);
    final html.Blob blob = html.Blob(<dynamic>[bytes], 'text/csv');
    final String url = html.Url.createObjectUrlFromBlob(blob);
    final html.AnchorElement anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}

FinanceExporter buildFinanceExporter() => WebFinanceExporter();
