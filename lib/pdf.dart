import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

// this is Pdf viewer in which you can pick file through file picker , download it in local storage as well as in app using hive
class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String? localPath;

  late Box<String> pdfBox;

  @override
  void initState() {
    super.initState();
    initializeHive();
  }

  Future<void> initializeHive() async {
    final directory = await getApplicationDocumentsDirectory();
    final hiveDirectory = Directory('${directory.path}/hive_data');
    await hiveDirectory.create(recursive: true);
    await Hive.initFlutter(hiveDirectory.path);
    pdfBox = await Hive.openBox<String>('pdfBox');
    setState(() {
      localPath = pdfBox.get('pdfPath');
    });
  }

  Future<void> pickPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        localPath = result.files.single.path;
        pdfBox.put('pdfPath', localPath!);
      });
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

  Future<void> savePdf() async {
    if (localPath != null) {
      final directory = await getExternalStorageDirectory();
      final path = '${directory?.path}/saved_pdf.pdf';
      final file = File(localPath!);
      await file.copy(path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'PDF Viewer',
          style: GoogleFonts.outfit(
            color: const Color(0xffffffff),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.folder_open,
              color: Color(0xffffffff),
            ),
            onPressed: pickPdf,
          ),
          IconButton(
            icon: const Icon(
              Icons.save,
              color: Color(0xffffffff),
            ),
            onPressed: savePdf,
          ),
          
        ],
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath,
            )
          : const Center(child: Text('No PDF selected')),
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
