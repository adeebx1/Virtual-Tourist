//
//  DataController.swift
//  Virtual-Tourist
//
//  Created by Adeeb alsuhaibani on 03/01/1442 AH.
//  Copyright © 1442 Adeebx1. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
           return persistentContainer.viewContext
       }
    
    var backgroundContext:NSManagedObjectContext!
    
    init (modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts(){
        backgroundContext = persistentContainer.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { storeDiscription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewController()
            self.configureContexts()
            completion?()
        }
       
    }
    
}
extension DataController {
    
    func autoSaveViewController(interval:TimeInterval = 30){
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+interval){
            self.autoSaveViewController(interval: interval)
        }
    }
}
