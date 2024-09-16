import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../components/startup.dart';
import '../app.dart';


Future<Uint8List> generateDocument(PdfPageFormat format, CustomData data) async {
  String version = Startup().currentVersion;
  final doc = pw.Document(pageMode: PdfPageMode.outlines);

  final font1 = await PdfGoogleFonts.openSansRegular();
  final font2 = await PdfGoogleFonts.openSansBold();

  // Add your data representation here
  doc.addPage(pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: font1,
        bold: font2,
      ),
      pageFormat: format.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
      orientation: pw.PageOrientation.portrait,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      header: (pw.Context context) {
        if (context.pageNumber == 1) {
          return pw.SizedBox();
        }
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey))),
            child: pw.Text('Information We Collect',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      footer: (pw.Context context) {
        return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
                'Drive Adviser version ${Startup().currentVersion}\nPage ${context.pageNumber} of ${context.pagesCount}',
                style: pw.Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (pw.Context context) => [
        pw.Header(
          level:0,
          title: "Drive Adviser version $version",
            text:"Drive Adviser version $version"
        ),
        for (var driveData in data.allDriveData) ...[
          pw.Header(
              level: 1,
              text: 'Drive: ${driveData.driveIdentifier}',
              textStyle: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['No', 'Id', 'Attribute Name', 'Current Value'," Worst Value","Threshold","Raw Value"],
                ...List<List<String>>.generate(
                    driveData.stringList.length, (index) => <String>[
                  '${index + 1}',
                  driveData.idList[index].toString(),
                  driveData.stringList[index],
                  driveData.intList[index].toString(),
                  driveData.worstList[index].toString(),
                  driveData.thresholdList[index].toString(),
                  driveData.rawvalueList[index].toString()
                ])
              ]),
        ]
      ]));

  return await doc.save();
}
