//
//  FavoriteTableViewController.swift
//  FooDb
//
//  Created by taralika on 3/26/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class FavoriteTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var favoriteTableView: UITableView!
    
    var selectedFoodItem:FoodItem?
    var favoriteFoodItems:[FoodItem] = []
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "Favorites"

        favoriteFoodItems = DataController.shared.fetchFavoriteFoodItems()
        favoriteTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteFoodItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let favoriteFoodItem = favoriteFoodItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! ItemViewCell
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 8
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.height / 8
        cell.itemLabel.text = favoriteFoodItem.name

        let spinner = ActivityIndicator()
        spinner.show(cell.itemImageView)
        favoriteFoodItem.getImage() {(image, errorString) in
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
        let favoriteFoodItem = favoriteFoodItems[indexPath.row]
        if editingStyle == .delete
        {
            favoriteFoodItems.remove(at: indexPath.row)
            favoriteFoodItem.isFav = false
            
            do
            {
                try DataController.shared.viewContext.save()
                if favoriteFoodItems.count == 0
                {
                   // TODO: add an empty view?
                }
            }
            catch
            {
                print(error)
            }
            favoriteTableView.reloadData()
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedFoodItem = favoriteFoodItems[indexPath.row]
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
