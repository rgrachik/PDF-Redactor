//
//  MergeDocumentViewModel.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 19.09.2025.
//

import Combine
import CoreData
internal import PDFKit

final class MergeDocumentViewModel: ObservableObject {
    
    var selectedDocument: PDFSavedDocument
    let persistence = PersistenceController.shared
    var titleAlert = ""
    @Published var showAlert = false
    @Published var documents: [PDFSavedDocument] = []
    @Published var docsForMerge: Set<PDFSavedDocument> = []
    
    init(selectedDocument: PDFSavedDocument) {
        self.selectedDocument = selectedDocument
    }
    
    func loadDocuments(context: NSManagedObjectContext) {
        documents = PersistenceController.shared.fetchAllDocuments(context: context)
    }
    
    func getPDFKitPreview(for document: PDFSavedDocument, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let pdfData = document.pdfData,
              let pdfDocument = PDFDocument(data: pdfData),
              let page = pdfDocument.page(at: 0) else {
            return nil
        }
        
        return page.thumbnail(of: size, for: .mediaBox)
    }
    
    func toggleDocumentSelection(_ document: PDFSavedDocument) {
        if docsForMerge.contains(document) {
            docsForMerge.remove(document)
        } else {
            docsForMerge.insert(document)
        }
        objectWillChange.send()
    }
    
    func mergeDocuments() -> PDFDocument? {
        let sortedDocuments = Array(docsForMerge).sorted { $0.createDate ?? "" < $1.createDate ?? "" }
        
        let mergedPDF = PDFDocument()
        var currentPageIndex = 0
        
        for document in sortedDocuments {
            guard let pdfData = document.pdfData,
                  let sourcePDF = PDFDocument(data: pdfData) else {
                print("Failed to load PDF data for document: \(document.name ?? "Unknown")")
                continue
            }
            
            for pageIndex in 0..<sourcePDF.pageCount {
                if let page = sourcePDF.page(at: pageIndex) {
                    mergedPDF.insert(page, at: currentPageIndex)
                    currentPageIndex += 1
                }
            }
        }
        
        guard mergedPDF.pageCount > 0 else {
            print("No pages were merged")
            return nil
        }
        
        print("Successfully merged \(mergedPDF.pageCount) pages")
        return mergedPDF
    }
    
    func saveDocInCoreData(context: NSManagedObjectContext) {
        guard let doc = mergeDocuments(), let data = doc.dataRepresentation() else {
            debugPrint("saveDocInCoreData error")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy-HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())

        persistence.savePDFDocument(
            name: formattedDate,
            createDate: formattedDate,
            data: data,
            context: context
        ) { [weak self] isSuccess in
            self?.titleAlert = isSuccess ? "Файл сохранен" : "Файл не сохранен"
            self?.showAlert = true
        }
    }
}
