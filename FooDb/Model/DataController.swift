//
//  DataController.swift
//  FooDb
//
//  Created by taralika on 4/2/20.
//  Copyright © 2020 at. All rights reserved.
//

import CoreData

class DataController
{
    lazy var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "FooDb")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError?
            {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static let shared = DataController(modelName: "FooDb")
    
    var viewContext: NSManagedObjectContext
    {
        return persistentContainer.viewContext
    }
    
    init(modelName: String)
    {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil)
    {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else
            {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    func saveContext ()
    {
        let context = persistentContainer.viewContext
        if context.hasChanges
        {
            do
            {
                try context.save()
            }
            catch
            {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchFavoriteFoodItems() -> [FoodItem]
    {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "isFav == true")
        fetchRequest.sortDescriptors = [sort]
        do
        {
            let result = try DataController.shared.viewContext.fetch(fetchRequest)
            return dedup(foodItems: result) // need to do this since the API returns results with same id
        }
        catch
        {
            debugPrint(error)
        }
        
        return [FoodItem()]
    }
    
    func fetchDislikeFoodItems() -> [FoodItem]
    {
        let fetchRequest: NSFetchRequest<FoodItem> = FoodItem.fetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.predicate = NSPredicate(format: "isDisliked == true")
        fetchRequest.sortDescriptors = [sort]
        do
        {
            let result = try DataController.shared.viewContext.fetch(fetchRequest)
            return dedup(foodItems: result) // need to do this since the API returns results with same id
        }
        catch
        {
            debugPrint(error)
        }
        
        return [FoodItem()]
    }
    
    func dedup(foodItems: [FoodItem]) -> [FoodItem]
    {
        var unique:[FoodItem] = []
        
        for rFoodItem in foodItems
        {
            var shouldAppend = true
            for uFoodItem in unique
            {
                if (uFoodItem.id == rFoodItem.id)
                {
                    shouldAppend = false
                    break
                }
            }
            
            if (shouldAppend)
            {
                unique.append(rFoodItem)
            }
        }
        
        return unique
    }
}
