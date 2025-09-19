//
//  PDFEditorView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import SwiftUI
internal import PDFKit

struct ShareItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct PDFEditorView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var shareItem: ShareItem?

    @State private var currentPageIndex: Int = .zero

    var body: some View {
        Group {
            if let doc = viewModel.document {
                PDFKitView(document: doc, currentPageIndex: $currentPageIndex)
            } else {
                Text("Нет документа").foregroundColor(.secondary)
            }
        }
        .alert(viewModel.titleAlert, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { dismiss() }
        }
        .padding()
        .toolbar {
            ToolbarItem {
                Button(role: .destructive) {
                    viewModel.deletePage(at: currentPageIndex)
                    if let doc = viewModel.document {
                        currentPageIndex = min(currentPageIndex, max(0, doc.pageCount - 1))
                    } else {
                        currentPageIndex = .zero
                    }
                } label: {
                    Label("Удалить страницу", systemImage: "document.on.trash")
                }
                .disabled(viewModel.document == nil || viewModel.document?.pageCount ?? 0 == 1)
                .tint(.red)
            }
            
            ToolbarItem {
                Button {
                    viewModel.saveDocInCoreData(context: viewContext)
                } label: {
                    Label(String.getWord(by: "saveTitle"), systemImage: "square.and.arrow.down")
                }
                .disabled(viewModel.document == nil)
            }

            ToolbarItem {
                Button {
                    do {
                        let url = try viewModel.export(fileName: "Document.pdf")
                        shareItem = ShareItem(url: url)
                    } catch {
                        print("Export failed: \(error)")
                    }
                } label: {
                    Label(String.getWord(by: "shareTitle"), systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.document == nil)
            }
        }
        .sheet(item: $shareItem) { item in
            ActivityView(activityItems: [item.url])
        }
    }
}

#Preview {
    let img = UIImage(systemName: "doc")!
    let vm = PDFEditorViewModel(images: [img, img, img])
    return NavigationView { PDFEditorView(viewModel: vm) }
}
