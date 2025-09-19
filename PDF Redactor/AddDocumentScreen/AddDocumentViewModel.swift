//
//  AddDocumentViewModel.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import Combine
import UIKit
import SwiftUI
import CoreData
internal import PDFKit

final class AddDocumentViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var selectedImages: [UIImage] = []
    @Published var documents: [PDFSavedDocument] = []
    
    func loadDocuments(context: NSManagedObjectContext) {
        documents = PersistenceController.shared.fetchAllDocuments(context: context)
    }
    
    func deleteDocument(document: PDFSavedDocument, context: NSManagedObjectContext) {
        PersistenceController.shared.deleteDocument(document, context: context) { isSuccess in
            if isSuccess {
                if let index = self.documents.firstIndex(where: { $0.id == document.id }) {
                    self.documents.remove(at: index)
                }
            }
        }
    }
    
    func getPDFFromData(data: Data?) -> PDFDocument? {
        guard let data = data, let document = PDFDocument(data: data) else {
            return nil
        }
        
        return document
    }
    
    func getPDFKitPreview(for document: PDFSavedDocument, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let pdfData = document.pdfData,
              let pdfDocument = PDFDocument(data: pdfData),
              let page = pdfDocument.page(at: 0) else {
            return nil
        }
        
        return page.thumbnail(of: size, for: .mediaBox)
    }
}

extension AddDocumentViewModel {
    
    func sharePDF(document: PDFSavedDocument) {
        guard let pdfData = document.pdfData,
              let pdf = getPDFFromData(data: pdfData) else {
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(document.name ?? "document")
            .appendingPathExtension("pdf")
        
        do {
            try pdf.dataRepresentation()?.write(to: tempURL)
            
            let activityVC = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                
                rootViewController.present(activityVC, animated: true)
            }
            
        } catch {
            print("Ошибка при создании временного файла: \(error)")
        }
    }
}
