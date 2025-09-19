//
//  PDFEditorView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import SwiftUI

struct ShareItem: Identifiable {
    let url: URL
    var id: String { url.absoluteString }
}

struct PDFEditorView: View {
    @ObservedObject var viewModel: PDFEditorViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var shareItem: ShareItem?

    var body: some View {
        Group {
            if let doc = viewModel.document {
                PDFKitView(document: doc)
            } else {
                Text("Нет документа").foregroundColor(.secondary)
            }
        }
        
        .alert(viewModel.titleAlert, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
        
        .navigationTitle("Просмотр PDF")
        .padding()
        .toolbar {
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
    let testImage = UIImage(systemName: "doc")!
    let vm = PDFEditorViewModel(images: [testImage])
    return NavigationView {
        PDFEditorView(viewModel: vm)
    }
}

