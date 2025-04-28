import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' as htmlParser;
import 'dart:io';

class ParsingService {
  static Future<String> parsePDF(File file) async {
    String text = "";
    try {
      text = await ReadPdfText.getPDFtext(file.path);
    } catch (e) {
      print('Failed to get PDF text: $e');
    }
    return text;
  }

  static Future<String> parseEPUB(File file) async {
    EpubBook epub = await EpubReader.readBook(file.readAsBytesSync());
    return epub.Chapters?.map((c) => c.HtmlContent ?? "").join("\n") ?? "";
  }

  static Future<String> parseHTML(String htmlString) async {
    var document = htmlParser.parse(htmlString);
    return document.body?.text ?? "";
  }

  static Future<String> parsePlainText(String text) async {
    return text;
  }
}
