import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerComponent extends StatelessWidget {
  final String pdfPath;
  final GlobalKey<SfPdfViewerState> pdfViewerKey;
  final PdfViewerController pdfController;
  final Function(PdfDocumentLoadedDetails) onDocumentLoaded;
  final Function(PdfDocumentLoadFailedDetails) onDocumentLoadFailed;
  final Function(PdfPageChangedDetails) onPageChanged;
  final Function(PdfZoomDetails) onZoomLevelChanged;
  final bool isLoading;

  const PdfViewerComponent({
    super.key,
    required this.pdfPath,
    required this.pdfViewerKey,
    required this.pdfController,
    required this.onDocumentLoaded,
    required this.onDocumentLoadFailed,
    required this.onPageChanged,
    required this.onZoomLevelChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height -
          (kToolbarHeight + MediaQuery.of(context).padding.top + 56),
      child: SfPdfViewer.asset(
        pdfPath,
        key: pdfViewerKey,
        controller: pdfController,
        enableDoubleTapZooming: true,
        enableTextSelection: true,
        onDocumentLoaded: onDocumentLoaded,
        onDocumentLoadFailed: onDocumentLoadFailed,
        onPageChanged: onPageChanged,
        onZoomLevelChanged: onZoomLevelChanged,
      ),
    );
  }
}

class PdfBottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const PdfBottomBar({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).bottomAppBarTheme.color ??
          Theme.of(context).primaryColor,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onPreviousPage,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text(
                'Page $currentPage of $totalPages',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: onNextPage,
            ),
          ],
        ),
      ),
    );
  }
}

class PdfSettingsSheet extends StatelessWidget {
  final double currentZoom;
  final int currentPage;
  final Function(double) onZoomChanged;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  const PdfSettingsSheet({
    Key? key,
    required this.currentZoom,
    required this.currentPage,
    required this.onZoomChanged,
    required this.onPreviousPage,
    required this.onNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Zoom Level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Slider(
            value: currentZoom,
            min: 0.5,
            max: 3.0,
            divisions: 5,
            label: '${currentZoom.toStringAsFixed(1)}x',
            onChanged: onZoomChanged,
          ),
          const SizedBox(height: 20),
          Text('Current Page: $currentPage',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: onPreviousPage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              ElevatedButton.icon(
                onPressed: onNextPage,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
