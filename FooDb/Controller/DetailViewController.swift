//
//  DetailViewController.swift
//  FooDb
//
//  Created by taralika on 3/26/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var itemInfoLabel: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    var foodItem = FoodItem(context: DataController.shared.viewContext)
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        itemInfoLabel.text = "Name: \(foodItem.name ?? "")\n"
                           + "Calories: \(foodItem.calories)\n"
                           + "Fat: \(foodItem.fat)g\n"
                           + "Carbs: \(foodItem.carbs)g\n"
                           + "Fiber: \(foodItem.fiber)g\n"
                           + "Protein: \(foodItem.protein)g\n"
                           + "Serving: \(foodItem.serving_size ?? "NA")"
                
        itemInfoLabel.adjustsFontSizeToFitWidth = true
        itemInfoLabel.minimumScaleFactor = 0.1
        
        configUI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        self.navigationItem.title = "Nutrition Info"
    }
    
    func configUI()
    {
        if (foodItem.image != nil)
        {
            itemImageView.image = UIImage(data: foodItem.image!)
        }
        else
        {
            itemImageView.image = UIImage(named: "food-generic-item")
        }
        
        itemImageView.layer.cornerRadius = itemImageView.frame.height / 8
        
        if foodItem.isFav
        {
            favoriteButton.setImage(UIImage(named: "star-filled"), for: .normal)
        }
        
        if foodItem.isDisliked
        {
            dislikeButton.setImage(UIImage(named: "dislike-filled"), for: .normal)
        }
    }
    
    @IBAction func addToFavorite(_ sender: Any)
    {
        if !foodItem.isFav
        {
            self.favoriteButton.setImage(UIImage(named: "star-filled"), for: .normal)
            self.dislikeButton.setImage(UIImage(named: "dislike-empty"), for: .normal)
            foodItem.isFav = true
            foodItem.isDisliked = false
        }
        else
        {
            self.favoriteButton.setImage(UIImage(named: "star-empty"), for: .normal)
            foodItem.isFav = false
        }
        
        do
        {
            try DataController.shared.viewContext.save()
        }
        catch
        {
            debugPrint(error)
        }
    }
    
    @IBAction func addToDislike(_ sender: Any)
    {
        if !foodItem.isDisliked
        {
            self.dislikeButton.setImage(UIImage(named: "dislike-filled"), for: .normal)
            self.favoriteButton.setImage(UIImage(named: "star-empty"), for: .normal)
            foodItem.isDisliked = true
            foodItem.isFav = false
        }
        else
        {
            self.dislikeButton.setImage(UIImage(named: "dislike-empty"), for: .normal)
            foodItem.isDisliked = false
        }
        
        do
        {
            try DataController.shared.viewContext.save()
        }
        catch
        {
            debugPrint(error)
        }
    }
}
