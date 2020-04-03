//
//  DislikeTableViewController.swift
//  FooDb
//
//  Created by taralika on 3/26/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class DislikeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var dislikeTableView: UITableView!
    
    var selectedFoodItem:FoodItem?
    var dislikeFoodItems:[FoodItem] = []
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Dislikes"
        
        dislikeFoodItems = DataController.shared.fetchDislikeFoodItems()
        dislikeTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dislikeFoodItems.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let dislikeFoodItem = dislikeFoodItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemViewCell
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 8
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.height / 8
        cell.itemLabel.text = dislikeFoodItem.name
        
        let spinner = ActivityIndicator()
        spinner.show(cell.itemImageView)
        dislikeFoodItem.getImage() {(image, errorString) in
            if image != nil
            {
                DispatchQueue.main.async
                {
                    spinner.hide()
                    cell.itemImageView.image = image
                }
            }
            else
            {
                DispatchQueue.main.async
                {
                    spinner.hide()
                    cell.itemImageView.image = UIImage(named: "food-item-generic")
                }
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        let dislikeFoodItem = dislikeFoodItems[indexPath.row]
        if editingStyle == .delete
        {
            dislikeFoodItems.remove(at: indexPath.row)
            dislikeFoodItem.isDisliked = false
            
            do
            {
                try DataController.shared.viewContext.save()
                // TODO: add an empty view if no items
            }
            catch
            {
                debugPrint(error)
            }
            dislikeTableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedFoodItem = dislikeFoodItems[indexPath.row]
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier! == "detailSegue"
        {
            if let detailVC = segue.destination as? DetailViewController
            {
                detailVC.foodItem = selectedFoodItem!
            }
        }
    }
}
