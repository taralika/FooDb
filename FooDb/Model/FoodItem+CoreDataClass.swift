//
//  FoodItem+CoreDataClass.swift
//  FooDb
//
//  Created by taralika on 4/2/20.
//  Copyright © 2020 at. All rights reserved.
//
//

import CoreData
import UIKit

@objc(FoodItem)
public class FoodItem: NSManagedObject
{
    convenience init(dictionary: [String:AnyObject])
    {
        self.init(entity: NSEntityDescription.entity(forEntityName: "FoodItem", in: DataController.shared.viewContext)!, insertInto: DataController.shared.viewContext)
        
        id = dictionary["foodId"] as? String
        
        let brand = dictionary["brand"] as? String
        
        if (brand != nil)
        {
            name = (dictionary["label"] as! String + ", " + (brand ?? "")).capitalized
        }
        else
        {
            name = (dictionary["label"] as! String).capitalized
        }
        
        let nutrientsDict = dictionary["nutrients"] as! [String: AnyObject]
        calories = Int64(lround(nutrientsDict["ENERC_KCAL"] as? Double ?? 0))
        fat = Int64(lround(nutrientsDict["FAT"] as? Double ?? 0))
        carbs = Int64(lround(nutrientsDict["CHOCDF"] as? Double ?? 0))
        fiber = Int64(lround(nutrientsDict["FIBTG"] as? Double ?? 0))
        protein = Int64(lround(nutrientsDict["PROCNT"] as? Double ?? 0))
        serving_size = "100g"
        
        isFav = false
        let favoriteFoodItems = DataController.shared.fetchFavoriteFoodItems()
        for favoriteItem in favoriteFoodItems
        {
            if (id == favoriteItem.id)
            {
                isFav = true
                break
            }
        }
        
        isDisliked = false
        let dislikeFoodItems = DataController.shared.fetchDislikeFoodItems()
        for dislikeItem in dislikeFoodItems
        {
            if (id == dislikeItem.id)
            {
                isDisliked = true
                break
            }
        }
        
        image_url = dictionary["image"] as? String
        image = nil
    }
    
    func getImage(completionHandler: @escaping (_ image: UIImage?, _ errorString: String?) -> Void)
    {
        if (image != nil)
        {
            completionHandler(UIImage(data: image!), nil)
            return
        }
        
        if (image_url == nil || image_url == "")
        {
            let image = UIImage(named: "food-item-generic")
            self.image = image!.pngData()
            completionHandler(image, nil)
            return
        }
        
        FoodRequests.downloadImage(imageURL: image_url!) { (image, errorString) in
            if (errorString == nil)
            {
                self.image = image?.pngData()
                completionHandler(image, nil)
            }
            else
            {
                let image = UIImage(named: "food-item-generic")
                self.image = image!.pngData()
                completionHandler(image, nil)
            }
        }
    }
}
