//
//  FoodRequests.swift
//  FooDb
//
//  Created by taralika on 3/26/20.
//  Copyright © 2020 at. All rights reserved.
//

import Foundation
import UIKit

class FoodRequests
{
    static var foodItems = [FoodItem]()
    static var foodIds = Set<String>()
    
    class func getFoodResults(query: String, requestURL: String, completionHandlerForGetFood: @escaping (_ result: [FoodItem]?,_ nextPageRequestURL: String?,_ errorString: String?) -> Void) -> URLSessionDataTask
    {
        let methodParameters = ["ingr" : query,
                                "app_id" : Constants.SERVER.APP_ID,
                                "app_key" : Constants.SERVER.APP_KEY] as [String : Any]
        
        var urlString = Constants.SERVER.BASE_URL + Constants.SERVER.FOOD_PARSER_METHOD + escapedParameters(methodParameters as [String:AnyObject])
        
        if (!requestURL.isEmpty)
        {
            urlString = requestURL
        }
        else
        {
            foodItems.removeAll()   // reset paginated search results
            foodIds.removeAll()     // reset ID tracking for uniqueness of results
        }
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        
        var nextPageRequestURL = ""
        
        request.httpMethod = "GET"

        // create network request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            guard error == nil else
            {
                completionHandlerForGetFood(nil, nextPageRequestURL, "URL at time of error: \(url)")
                return
            }
            
            if let data = data
            {
                let parsedResult: [String:AnyObject]!
                do
                {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                }
                catch
                {
                    completionHandlerForGetFood(nil, nextPageRequestURL, "Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                if let linksDict = parsedResult["_links"] as? [String:AnyObject]
                {
                    if let nextDict = linksDict["next"] as? [String:AnyObject]
                    {
                        nextPageRequestURL = nextDict["href"] as? String ?? ""
                    }
                }
                
                var tempItems = [FoodItem]()
                if let hintsDictionary = parsedResult["hints"] as? [[String:AnyObject]]
                {
                    tempItems = parseFoodResults(hintsDictionary)
                    self.foodItems = self.foodItems + tempItems
                }
                
                if tempItems.count == 0
                {
                    completionHandlerForGetFood(nil, nextPageRequestURL, "Cannot find any food")
                }
                else
                {
                    completionHandlerForGetFood(self.foodItems, nextPageRequestURL, nil)
                }
            }
        }
        
        // start the task!
        task.resume()
        return task
    }
    
    class func downloadImage(imageURL:String, completionHandler: @escaping (_ image: UIImage?, _ errorString: String?) -> Void)
    {
        let task = URLSession.shared.dataTask(with: NSURLRequest(url: NSURL(string: imageURL)! as URL) as URLRequest)
        {data, response, downloadError in
            if data == nil
            {
                completionHandler(nil, "Error downloading image from: \(imageURL)")
            }
            else
            {
                completionHandler(UIImage(data: data!), nil)
            }
        }
        
        task.resume()
    }
    
    class func parseFoodResults(_ results: [[String:AnyObject]]) -> [FoodItem]
    {
        var items = [FoodItem]()
        
        for result in results
        {
            guard let id = result["food"]?["foodId"] as? String else { continue }
            
            if (foodIds.contains(id))
            {
                continue
            }
            
            items.append(FoodItem(dictionary: result["food"] as! [String : AnyObject]))
            foodIds.insert(id)
        }
        
        return items
    }
    
    class func escapedParameters(_ parameters: [String:AnyObject]) -> String
    {
        if parameters.isEmpty
        {
            return ""
        }
        else
        {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters
            {
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}
