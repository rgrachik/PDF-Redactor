//
//  PDFEditorViewModel.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 17.09.2025.
//

import Combine
import UIKit
internal import PDFKit
import CoreData
import SwiftUI

final class PDFEditorViewModel: ObservableObject {

    // MARK: - Properties
    private var images: [UIImage] = []
    @Published private(set) var document: PDFDocument?
    @Published var showAlert = false
    @Published var titleAlert: String = ""

    let persistence = PersistenceController.shared

    // MARK: - Init
    init(images: [UIImage]) {
        self.images = images
        self.document = convertImagesToPDF(images: images)
    }

    init(document: PDFDocument) {
        self.document = document
    }

    // MARK: - Public API

    func rebuild(with images: [UIImage]? = nil) {
        if let images { self.images = images }
        self.document = convertImagesToPDF(images: self.images)
    }

    func pdfData() -> Data? {
        document?.dataRepresentation()
    }

    @discardableResult
    func export(fileName: String = "Document.pdf") throws -> URL {
        guard let data = pdfData() else { throw PDFError.noDocument }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: url, options: .atomic)
        return url
    }

    func saveDocInCoreData(context: NSManagedObjectContext) {
        guard let data = pdfData() else {
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
    
    func deletePage(at index: Int) {
        guard let doc = document, index >= 0, index < doc.pageCount else { return }
        doc.removePage(at: index)
        document = (doc.pageCount > 0) ? (doc.copy() as? PDFDocument) : nil
    }

    // MARK: - Private

    private func convertImagesToPDF(images: [UIImage]) -> PDFDocument? {
        guard !images.isEmpty else { return nil }
        let pdf = PDFDocument()
        for (index, img) in images.enumerated() {
            if let page = PDFPage(image: img) {
                pdf.insert(page, at: index)
            }
        }
        return pdf
    }

    enum PDFError: Error {
        case noDocument
    }
}
