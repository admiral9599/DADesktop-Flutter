

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf_wild;
import 'package:printing/printing.dart';



class PDFView extends StatefulWidget {
  const PDFView({
    Key? key,
  }) : super(key: key);

  @override
  _PDFViewState createState() => _PDFViewState();
}

class _PDFViewState extends State<PDFView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
        build: (format) => _createPdf(
          format,
        ),
      ),
    );
  }

  Future<Uint8List> _createPdf(
    PdfPageFormat format,
  ) async {
    final pdf = pdf_wild.Document(
      version: PdfVersion.pdf_1_4,
      compress: true,
    );
    pdf.addPage(
      pdf_wild.Page(
        pageFormat: const PdfPageFormat((80 * (72.0 / 25.4)), 600,
            marginAll: 5 * (72.0 / 25.4)),
        //pageFormat: format,
        build: (context) {
          return pdf_wild.SizedBox(
            width: double.infinity,
            child: pdf_wild.FittedBox(
                child: pdf_wild.Column(
                    mainAxisAlignment: pdf_wild.MainAxisAlignment.start,
                    children: [
                  pdf_wild.Text("Follow",
                      style: pdf_wild.TextStyle(
                          fontSize: 35, fontWeight: pdf_wild.FontWeight.bold)),
                  pdf_wild.Container(
                    width: 250,
                    height: 1.5,
                    margin: const pdf_wild.EdgeInsets.symmetric(vertical: 5),
                    color: PdfColors.black,
                  ),
                  pdf_wild.Container(
                    width: 300,
                    child: pdf_wild.Text("#30FlutterTips",
                        style: pdf_wild.TextStyle(
                          fontSize: 35,
                          fontWeight: pdf_wild.FontWeight.bold,
                        ),
                        textAlign: pdf_wild.TextAlign.center,
                        maxLines: 5),
                  ),
                  pdf_wild.Container(
                    width: 250,
                    height: 1.5,
                    margin: const pdf_wild.EdgeInsets.symmetric(vertical: 10),
                    color: PdfColors.black,
                  ),
                  pdf_wild.Text("Lakshydeep Vikram",
                      style: pdf_wild.TextStyle(
                          fontSize: 25, fontWeight: pdf_wild.FontWeight.bold)),
                  pdf_wild.Text("Follow on Medium, LinkedIn, GitHub",
                      style: pdf_wild.TextStyle(
                          fontSize: 25, fontWeight: pdf_wild.FontWeight.bold)),
                ])),
          );
        },
      ),
    );
    return pdf.save();
  }
}
