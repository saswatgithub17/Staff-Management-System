import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NoticeItem {
  final String type; // 'image' or 'pdf'
  final String data; // Base64 string

  NoticeItem({required this.type, required this.data});

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      type: (json['type'] ?? 'image').toString().toLowerCase(),
      data: (json['data'] ?? '').toString(),
    );
  }
}

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  List<NoticeItem> noticeItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse("https://creativecollege.in/img_retrive.php");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        try {
          var decoded = json.decode(response.body);
          List<dynamic> data = [];

          if (decoded is List) {
            data = decoded;
          } else if (decoded is Map && decoded.containsKey('data')) {
            data = decoded['data'] is List ? decoded['data'] : [];
          }

          List<NoticeItem> items = [];

          for (var entry in data) {
            if (entry is Map) {
              items.add(NoticeItem.fromJson(Map<String, dynamic>.from(entry)));
            } else if (entry is String) {
              items.add(NoticeItem(type: 'image', data: entry));
            }
          }

          setState(() {
            noticeItems = items.reversed.toList();
            isLoading = false;
          });
        } catch (e) {
          print('Error decoding JSON: $e');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('HTTP ${response.statusCode} ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Color(0xFF0F172A);
    const bgColor = Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.black),
      )
          : RefreshIndicator(
        onRefresh: fetchImages,
        color: Colors.black,
        child: noticeItems.isEmpty
            ? CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: _color1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              title: Text('Notice',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              expandedHeight: 100.0,
              pinned: true,
            ),
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.style_outlined,
                        size: 64, color: Colors.grey[700]),
                    SizedBox(height: 12),
                    Text(
                      'No notices found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Drag down from top to refresh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: _color1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              title: Text(
                'Notice',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              expandedHeight: 100.0,
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final item = noticeItems[index];
                  final isPdf = item.type == 'pdf';

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenNoticeViewer(
                              noticeItems: noticeItems,
                              initialIndex: index,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: isPdf
                                  ? Icon(Icons.picture_as_pdf,
                                  color: Colors.red, size: 36)
                                  : Icon(Icons.image,
                                  color: Colors.blue, size: 36),
                              title: Text(
                                "Creative Techno College",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              subtitle: Text(
                                isPdf
                                    ? "PDF Document Notice"
                                    : "Image Notice",
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: isPdf
                                  ? Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius:
                                  BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.red.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.picture_as_pdf,
                                        size: 48,
                                        color: Colors.red),
                                    SizedBox(height: 8),
                                    Text(
                                      "Tap to View PDF Notice",
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                        fontWeight:
                                        FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Image.memory(
                                base64Decode(item.data),
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                Center(
                                  child: Icon(Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: noticeItems.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenNoticeViewer extends StatefulWidget {
  final List<NoticeItem> noticeItems;
  final int initialIndex;

  FullScreenNoticeViewer({
    required this.noticeItems,
    required this.initialIndex,
  });

  @override
  _FullScreenNoticeViewerState createState() => _FullScreenNoticeViewerState();
}

class _FullScreenNoticeViewerState extends State<FullScreenNoticeViewer> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _handlePrint(BuildContext context) async {
    final currentItem = widget.noticeItems[currentIndex];
    try {
      final bytes = base64Decode(currentItem.data);

      if (currentItem.type == 'pdf') {
        // Direct PDF printing
        await Printing.layoutPdf(onLayout: (_) => bytes);
      } else {
        // Image printing converted to PDF document
        final doc = pw.Document();
        final image = pw.MemoryImage(bytes);
        doc.addPage(pw.Page(build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        }));
        await Printing.layoutPdf(onLayout: (_) => doc.save());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error printing document: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const _color1 = Colors.black;
    final currentItem = widget.noticeItems[currentIndex];
    final isPdf = currentItem.type == 'pdf';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          isPdf ? 'PDF Notice' : 'Image Notice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        backgroundColor: _color1,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.print, color: Colors.white),
            onPressed: () {
              _handlePrint(context);
            },
          ),
        ],
      ),
      body: isPdf
          ? SfPdfViewer.memory(
        base64Decode(currentItem.data),
        canShowScrollHead: true,
        canShowScrollStatus: true,
      )
          : PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        itemCount: widget.noticeItems.length,
        builder: (context, index) {
          final item = widget.noticeItems[index];
          if (item.type == 'pdf') {
            return PhotoViewGalleryPageOptions.customChild(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf,
                          size: 80, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        "PDF Document",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return PhotoViewGalleryPageOptions(
              imageProvider: MemoryImage(base64Decode(item.data)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: index),
            );
          }
        },
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: widget.initialIndex),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
