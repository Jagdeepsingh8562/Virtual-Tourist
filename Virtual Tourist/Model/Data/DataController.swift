//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Jagdeep Singh on 02/04/21.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName: String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    func load(completion: (()-> Void )? = nil) {
        persistentContainer.loadPersistentStores { (storeDescripiton, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
        
    }
    static let shared = DataController(modelName: "Virtual_Tourist")

}

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        guard interval > 0 else {
            print("save hasn't happened ")
            return
        }
        if viewContext.hasChanges {
        try? viewContext.save()
    }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
