import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfBookPage extends StatefulWidget {
  final String pdfPath;

  const PdfBookPage({super.key, required this.pdfPath});

  @override
  _PdfBookPageState createState() => _PdfBookPageState();
}

class _PdfBookPageState extends State<PdfBookPage> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  bool _hasError = false;
  final double _buttonSpacing = 10.0;

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          const Text('Failed to load PDF', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => setState(() {
              _hasError = false;
              _isReady = false;
            }),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfView() {
    return PDFView(
      filePath: widget.pdfPath,
      enableSwipe: true,
      autoSpacing: true,
      onViewCreated: (controller) =>
          _controller.complete(controller), // Uncommented this line
      onRender: (pages) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _totalPages = pages ?? 0;
              _isReady = true;
            });
          }
        });
      },
      onPageChanged: (page, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _currentPage = page ?? 0);
          }
        });
      },
      onError: (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _isReady = true;
            });
          }
        });
      },
      onPageError: (page, error) => print('Error loading page $page: $error'),
    );
  }

  Widget _buildNavigationControls(PDFViewController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'prev',
          tooltip: 'Previous Page',
          onPressed: _currentPage > 0
              ? () {
                  // Use post-frame callback to avoid setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.setPage(_currentPage - 1);
                  });
                }
              : null,
          child: const Icon(Icons.chevron_left),
        ),
        SizedBox(width: _buttonSpacing),
        FloatingActionButton.extended(
          heroTag: 'page',
          label: Text('${_currentPage + 1}/$_totalPages'),
          onPressed: null, // Disabled, but styled.
        ),
        SizedBox(width: _buttonSpacing),
        FloatingActionButton(
          heroTag: 'next',
          tooltip: 'Next Page',
          onPressed: _currentPage < _totalPages - 1
              ? () {
                  // Use post-frame callback to avoid setState during build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.setPage(_currentPage + 1);
                  });
                }
              : null,
          child: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Viewer"),
      ),
      body: Stack(
        children: [
          if (!_hasError) _buildPdfView(),
          if (_hasError) _buildErrorView(),
          if (!_isReady && !_hasError)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FutureBuilder<PDFViewController>(
        future: _controller.future,
        builder: (context, snapshot) {
          if (snapshot.hasData && _totalPages > 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildNavigationControls(snapshot.data!),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
