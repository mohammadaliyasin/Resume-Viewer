import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ResumeView extends StatefulWidget {
  const ResumeView({super.key});

  @override
  State<ResumeView> createState() => _ResumeViewState();
}

class _ResumeViewState extends State<ResumeView> {
  String? localPath;

  final String pdfUrl =
      'https://firebasestorage.googleapis.com/v0/b/resume-viewer-9c8f9.appspot.com/o/Resume%20(1).pdf?alt=media&token=c5273e9a-0778-4013-baf5-0c1967037c51';

  @override
  void initState() {
    super.initState();
    fetchPdfFromUrl();
  }

  Future<void> fetchPdfFromUrl() async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/resume.pdf');
        await file
            .writeAsBytes(response.bodyBytes);
        setState(() {
          localPath = file.path;
        });
      } else {
        print('Error downloading PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching PDF from URL: $e');
    }
  }

  Future<void> printPdf() async {
    if (localPath != null) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async =>
            File(localPath!).readAsBytes(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Resume',
          style: GoogleFonts.outfit(
            color: const Color(0xffffffff),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath,
            )
          : const Center(child: CircularProgressIndicator(color: Colors.black,)),
      floatingActionButton: FloatingActionButton(
        onPressed: printPdf,
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.print,
          color: Colors.white,
        ),
      ),
    );
  }
}
