//
//  MergeDocumentView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 19.09.2025.
//

import SwiftUI

struct MergeDocumentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MergeDocumentViewModel
    private var filteredDocs: [PDFSavedDocument] {
        viewModel.documents.filter { doc in
            doc != viewModel.selectedDocument
        }
    }
    
    var body: some View {
        VStack {
            List {
                Section("Выбранный документ") {
                    ItemDocumentView(
                        image: viewModel.getPDFKitPreview(for: viewModel.selectedDocument) ?? UIImage(systemName: "doc.fill")!,
                        name: viewModel.selectedDocument.name ?? "",
                        creationDate: viewModel.selectedDocument.createDate ?? ""
                    )
                }
                
                Section("Выберите документы для объединения") {
                    ForEach(filteredDocs) { document in
                        SelectableDocItem(
                            image: viewModel.getPDFKitPreview(for: document) ?? UIImage(systemName: "doc.fill")!,
                            name: document.name ?? "",
                            creationDate: document.createDate ?? "",
                            isSelected: viewModel.docsForMerge.contains(document)
                        )
                        .onTapGesture {
                            viewModel.toggleDocumentSelection(document)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.docsForMerge.removeAll()
                viewModel.loadDocuments(context: viewContext)
                viewModel.docsForMerge.insert(viewModel.selectedDocument)
            }
        }
        
        Button("Объединить") {
            viewModel.saveDocInCoreData(context: viewContext)
        }
        
        .buttonStyle(MainButtonStyle(fillColor: .appDarkBlue))
        .disabled(viewModel.docsForMerge.count <= 1)
        .opacity(viewModel.docsForMerge.count <= 1 ? 0.5 : 1)
        .padding()
        
        .navigationTitle("Объединение документов")
        .navigationBarTitleDisplayMode(.inline)
        
        .alert(viewModel.titleAlert, isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { dismiss() }
        }
    }
}
