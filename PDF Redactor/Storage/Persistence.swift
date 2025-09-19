//
//  Persistence.swift
//  PDF Redactor
//
//  Created by Роман Грачик on 16.09.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PDF_Redactor")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func savePDFDocument(
        name: String,
        createDate: String,
        data: Data,
        context: NSManagedObjectContext,
        completion: ((Bool) -> Void)?
    ) {
        context.perform {
            let pdfDocument = PDFSavedDocument(context: context)
            pdfDocument.name = name
            pdfDocument.createDate = createDate
            pdfDocument.pdfData = data
            pdfDocument.id = UUID().uuidString
            
            do {
                try context.save()
                completion?(true)
            } catch {
                print("Ошибка сохранения PDF документа: \(error.localizedDescription)")
                completion?(false)
            }
        }
    }
    
    /// Получить все документы
        func fetchAllDocuments(context: NSManagedObjectContext) -> [PDFSavedDocument] {
            let fetchRequest: NSFetchRequest<PDFSavedDocument> = PDFSavedDocument.fetchRequest()
            
            // Сортировка по дате создания (новые сначала)
            let sortDescriptor = NSSortDescriptor(key: "createDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                return try context.fetch(fetchRequest)
            } catch {
                print("Ошибка получения документов: \(error.localizedDescription)")
                return []
            }
        }
    
    /// Получить документ по ID
        func fetchDocument(by id: String, context: NSManagedObjectContext) -> PDFSavedDocument? {
            let fetchRequest: NSFetchRequest<PDFSavedDocument> = PDFSavedDocument.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.fetchLimit = 1
            
            do {
                return try context.fetch(fetchRequest).first
            } catch {
                print("Ошибка получения документа по ID: \(error.localizedDescription)")
                return nil
            }
        }
    
    /// Обновить документ
        func updateDocument(
            _ document: PDFSavedDocument,
            newName: String? = nil,
            newData: Data? = nil,
            context: NSManagedObjectContext,
            completion: ((Bool) -> Void)? = nil
        ) {
            context.perform {
                if let newName = newName {
                    document.name = newName
                }
                if let newData = newData {
                    document.pdfData = newData
                }
                
                do {
                    try context.save()
                    completion?(true)
                } catch {
                    print("Ошибка обновления документа: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
        
    /// Удалить документ
        func deleteDocument(_ document: PDFSavedDocument, context: NSManagedObjectContext, completion: ((Bool) -> Void)? = nil) {
            context.perform {
                context.delete(document)
                
                do {
                    try context.save()
                    completion?(true)
                } catch {
                    print("Ошибка удаления документа: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    
    /// Удалить документ по ID
        func deleteDocument(by id: String, context: NSManagedObjectContext, completion: ((Bool) -> Void)? = nil) {
            if let document = fetchDocument(by: id, context: context) {
                deleteDocument(document, context: context, completion: completion)
            } else {
                completion?(false)
            }
        }
}
