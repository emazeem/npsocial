import 'package:flutter/material.dart';
import 'package:np_social/res/constant.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewer extends StatefulWidget {
 final String? pdfUrl;

  const PDFViewer({Key? key, this.pdfUrl}) : super(key: key);

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  @override
  Widget build(BuildContext context) {
    print(widget.pdfUrl);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Constants.titleImage(),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: SfPdfViewer.network("https://condescending-knuth.3-19-145-255.plesk.page/storage/${widget.pdfUrl.toString()}"),
    );
  }
}
