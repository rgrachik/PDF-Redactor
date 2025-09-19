//
//  PDFKitView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 18.09.2025.
//

import SwiftUI
internal import PDFKit

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument?
    @Binding var currentPageIndex: Int

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.usePageViewController(true)

        context.coordinator.startObserving(pdfView)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = document
        if let doc = document, doc.pageCount > 0 {
            let clamped = max(0, min(currentPageIndex, doc.pageCount - 1))
            if let page = doc.page(at: clamped) {
                uiView.go(to: page)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(currentPageIndex: $currentPageIndex)
    }

    final class Coordinator {
        private var currentPageIndex: Binding<Int>
        private weak var pdfView: PDFView?
        private var token: NSObjectProtocol?

        init(currentPageIndex: Binding<Int>) {
            self.currentPageIndex = currentPageIndex
        }

        func startObserving(_ pdfView: PDFView) {
            self.pdfView = pdfView
            token = NotificationCenter.default.addObserver(
                forName: Notification.Name.PDFViewPageChanged,
                object: pdfView,
                queue: .main
            ) { [weak self] _ in
                guard
                    let self,
                    let pdfView = self.pdfView,
                    let doc = pdfView.document,
                    let page = pdfView.currentPage
                else { return }

                let idx = doc.index(for: page)
                guard idx != NSNotFound else { return }

                guard self.currentPageIndex.wrappedValue != idx else { return }

                DispatchQueue.main.async {
                    self.currentPageIndex.wrappedValue = idx
                }
            }

        }

        deinit {
            if let token { NotificationCenter.default.removeObserver(token) }
        }
    }
}
