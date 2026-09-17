import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'exam_service.dart';

class ExamPdfService {
  static Future<void> shareQuestionsPdf({
    required Exam exam,
    required List<ExamQuestion> questions,
    required bool includeAnswers,
  }) async {
    final regularFont = await PdfGoogleFonts.notoSansBengaliRegular();
    final boldFont = await PdfGoogleFonts.notoSansBengaliBold();

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (context) => context.pageNumber == 1
            ? pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(exam.title,
                      style: pw.TextStyle(font: boldFont, fontSize: 18)),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    [
                      if (exam.date.isNotEmpty) exam.date,
                      if (exam.time.isNotEmpty) exam.time,
                      if (exam.duration.isNotEmpty) exam.duration,
                      '${questions.length} প্রশ্ন',
                    ].join(' • '),
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey700),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(),
                ],
              )
            : pw.SizedBox(),
        build: (context) => [
          for (var i = 0; i < questions.length; i++)
            _buildQuestion(i + 1, questions[i], boldFont, regularFont, includeAnswers),
        ],
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename:
          '${_sanitize(exam.title)}${includeAnswers ? '_answers' : '_questions'}.pdf',
    );
  }

  static String _sanitize(String value) =>
      value.trim().replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'\s+'), '_');

  static pw.Widget _buildQuestion(
    int number,
    ExamQuestion question,
    pw.Font boldFont,
    pw.Font regularFont,
    bool includeAnswers,
  ) {
    final options = {
      'A': question.optionA,
      'B': question.optionB,
      'C': question.optionC,
      'D': question.optionD,
    };
    final correctLetter = question.correctLetter;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 14),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$number. ${question.questionText}',
              style: pw.TextStyle(font: boldFont, fontSize: 12)),
          pw.SizedBox(height: 5),
          for (final entry in options.entries)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 14, bottom: 3),
              child: pw.Text(
                '${entry.key}. ${entry.value}'
                '${includeAnswers && entry.key == correctLetter ? '  ✓' : ''}',
                style: pw.TextStyle(
                  font: includeAnswers && entry.key == correctLetter
                      ? boldFont
                      : regularFont,
                  fontSize: 11,
                  color: includeAnswers && entry.key == correctLetter
                      ? PdfColors.green800
                      : PdfColors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
