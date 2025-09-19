//
//  AddDocumentView.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct AddDocumentView: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: AddDocumentViewModel
    @State private var isActionSheetPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var isFilesImporterPresented = false
    @State private var goToPreview = false
    @State private var shouldNavigateToMerge = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink(
                    destination: PDFEditorView(viewModel: PDFEditorViewModel(images: viewModel.selectedImages)),
                    isActive: $goToPreview
                ) { EmptyView() }.hidden()
                
                if let selectedDoc = viewModel.selectedDocumentForMerge {
                    NavigationLink(
                        destination: MergeDocumentView(viewModel: MergeDocumentViewModel(selectedDocument: selectedDoc)),
                        isActive: $shouldNavigateToMerge
                    ) { EmptyView() }.hidden()
                }
                
                List(viewModel.documents) { document in
                    
                    NavigationLink(destination: PDFEditorView(viewModel: PDFEditorViewModel(document: viewModel.getPDFFromData(data: document.pdfData)!))) {
                            ItemDocumentView(
                                image: viewModel.getPDFKitPreview(for: document) ?? UIImage(systemName: "doc.fill")!,
                                name: document.name ?? "",
                                creationDate: document.createDate ?? ""
                            )
                        }
                    
                    .contextMenu {
                        
                        Button {
                            viewModel.sharePDF(document: document)
                        } label: {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            viewModel.selectedDocumentForMerge = document
                            shouldNavigateToMerge = true
                        } label: {
                            Label("Объединить", systemImage: "doc.on.doc")
                        }
                        
                        Button(role: .destructive) {
                            viewModel.deleteDocument(document: document, context: viewContext)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
                .onAppear {
                    viewModel.loadDocuments(context: viewContext)
                }
                
                Text(String.getWord(by: "addNewTitle"))
                    .opacity(viewModel.documents.isEmpty ? 1 : .zero)
            }
            
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button {
                            isPhotoPickerPresented = true
                        } label: {
                            Label(String.getWord(by: "openPhotos"), systemImage: "photo")
                        }
                        
                        Button {
                            isFilesImporterPresented = true
                        } label: {
                            Label(String.getWord(by: "openFiles"), systemImage: "folder")
                        }
                    } label: {
                        Label(String.getWord(by: "addItemTitle"), systemImage: "plus")
                    }
                }
            }
            
            .sheet(isPresented: $isPhotoPickerPresented) {
                PhotoPicker { images in
                    viewModel.selectedImages = images
                    goToPreview = !images.isEmpty
                }
            }
            
            .fileImporter(
                isPresented: $isFilesImporterPresented,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    loadImages(from: urls) { images in
                        viewModel.selectedImages = images
                        goToPreview = !images.isEmpty
                    }
                case .failure(let error):
                    print("fileImporter error: \(error)")
                }
            }
        }
    }
    
    private func loadImages(from urls: [URL], completion: @escaping ([UIImage]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var result: [UIImage] = []
            let coordinator = NSFileCoordinator(filePresenter: nil)

            for url in urls {
                let scoped = url.startAccessingSecurityScopedResource()
                defer { if scoped { url.stopAccessingSecurityScopedResource() } }

                var coordError: NSError?
                coordinator.coordinate(readingItemAt: url, options: [], error: &coordError) { readURL in
                    if let isUbiq = try? readURL.resourceValues(forKeys: [.isUbiquitousItemKey]).isUbiquitousItem,
                       isUbiq == true {
                        try? FileManager.default.startDownloadingUbiquitousItem(at: readURL)
                    }

                    if let data = try? Data(contentsOf: readURL),
                       let img  = UIImage(data: data) {
                        result.append(img)
                    }
                }
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}
