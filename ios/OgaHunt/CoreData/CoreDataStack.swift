//
//  CoreDataStack.swift
//  OgaHunt
//
//  Created by Humberto Aquino on 5/5/18.
//  Copyright © 2018 Humberto Aquino. All rights reserved.
//

import CoreData

class CoreDataStack {
    private let modelName: String

    init(modelName: String) {
        self.modelName = modelName
    }

    private lazy var storeContainer: NSPersistentContainer = {
        self.buildStoreContainer()
    }()

    lazy var managedContext: NSManagedObjectContext = {
        self.storeContainer.viewContext
    }()

    private func buildStoreContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }

    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        return storeContainer.newBackgroundContext()
    }

//    func resetPersistentStore() {
//        guard let storeURL = self.storeContainer.persistentStoreCoordinator.persistentStores.first?.url else {
//            log.error("No URL in the persistent store! Skip destroy")
//            return
//        }
//
//        do {
//            try storeContainer.persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
//            log.info("Store destroyed successfully")
//
//            // Build a new one
//            storeContainer = buildStoreContainer()
//
//        } catch {
//            print(error)
//            log.error("Error trying to destroy the store: \(error)")
//        }
//
    ////        self.storeContainer.persistentStoreCoordinator.destroyPersistentStore(at: <#T##URL#>, ofType: <#T##String#>, options: <#T##[AnyHashable : Any]?#>)
    ////        try persistentStoreCoordinator.destroyPersistentStoreAtURL(persistentStoreURL, withType: NSSQLiteStoreType, options: nil)
//    }

    // TODO: Images, Settings

    func clearCoreData() {
        clearEntities(entityName: EstateEvent.entity().name)
        clearEntities(entityName: Estate.entity().name)
        clearEntities(entityName: Location.entity().name)
        clearEntities(entityName: Contact.entity().name)
        clearEntities(entityName: Price.entity().name)
        clearEntities(entityName: Image.entity().name)
        clearEntities(entityName: User.entity().name)
    }

    func clearEntities(entityName: String?) {
        guard let entityName = entityName else {
            print("Entity name not provided for clearing. Skipping")
            return
        }
        let context = managedContext
        let coord = storeContainer.persistentStoreCoordinator

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try coord.execute(deleteRequest, with: context)
            print("Success: All \(entityName) deleted!")
        } catch let error as NSError {
            debugPrint(error)
        }
    }
}
