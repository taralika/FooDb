//
//  SearchViewController.swift
//  FooDb
//
//  Created by taralika on 3/26/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate
{
    func searchItems(_ searchViewController: SearchViewController, didPickItem item: FoodItem?)
}

class SearchViewController: UIViewController
{
    var foodItems: [FoodItem] = []
    var selectedFoodItem:FoodItem?
    
    // stores the last search request, so previous one can be canceled as new requests fire off with new text entries
    var searchTask: URLSessionDataTask?
    
    // for pagination support, if there are more results, the request will be stored in this variable
    var nextPageRequestURL = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var itemTableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationItem.title = "FooDb Search"
    }
    
    @IBAction func openSavedFoodList(_ sender: Any)
    {
        performSegue(withIdentifier: "savedFoodListSegue", sender: self)
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
}

extension SearchViewController: UIGestureRecognizerDelegate
{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        return searchBar.isFirstResponder
    }
}

extension SearchViewController: UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        // cancel the last task
        if let task = searchTask
        {
            task.cancel()
        }
        
        // if the text is empty, we are done
        if searchText == ""
        {
            return
        }

        searchBar.isLoading = true
        searchTask = FoodRequests.getFoodResults(query: searchText, requestURL: "")
        { (foodItems, nextPageRequestURL, error) in
            self.searchTask = nil
            if let foodItems = foodItems
            {
                self.foodItems = foodItems
                self.nextPageRequestURL = nextPageRequestURL ?? ""
                DispatchQueue.main.async
                {
                    self.itemTableView!.reloadData()
                }
            }
            if (error != nil)
            {
                DispatchQueue.main.async
                {
                    self.view.makeToast(error: error!)
                }
            }
            DispatchQueue.main.async
            {
                searchBar.isLoading = false
            }
        }
    }
    
    // Dismiss keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return foodItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CellReuseId = "itemCell"
        let foodItem = foodItems[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId) as! ItemViewCell
        cell.itemLabel.text = foodItem.name
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 8
        cell.itemImageView.layer.cornerRadius = cell.itemImageView.frame.height / 8
        
        let spinner = ActivityIndicator()
        spinner.show(cell.itemImageView)
        foodItem.getImage() {(image, errorString) in
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
        
        // if on last cell
        if indexPath.row == foodItems.count - 1
        {
            if (!nextPageRequestURL.isEmpty) // more items?
            {
                searchBar.isLoading = true
                searchTask = FoodRequests.getFoodResults(query: "", requestURL: nextPageRequestURL)
                {(foodItems, nextPageRequestURL, error) in
                    self.searchTask = nil
                    if let foodItems = foodItems
                    {
                        self.foodItems = foodItems
                        self.nextPageRequestURL = nextPageRequestURL ?? ""
                        DispatchQueue.main.async
                        {
                            self.itemTableView!.reloadData()
                        }
                    }
                    DispatchQueue.main.async
                    {
                        self.searchBar.isLoading = false
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedFoodItem = foodItems[(indexPath as NSIndexPath).row]
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

extension UISearchBar
{
    public var textField: UITextField?
    {
        if #available(iOS 13.0, *)
        {
            return self.searchTextField
        }
        else
        {
            let subViews = subviews.flatMap { $0.subviews }
            guard let textField = (subViews.filter { $0 is UITextField }).first as? UITextField else
            {
                return nil
            }
            return textField
        }
    }

    public var activityIndicator: UIActivityIndicatorView?
    {
        return textField?.leftView?.subviews.compactMap{ $0 as? UIActivityIndicatorView }.first
    }

    var isLoading: Bool
    {
        get
        {
            return activityIndicator != nil
        }
        set
        {
            if newValue
            {
                if activityIndicator == nil
                {
                    let newActivityIndicator = UIActivityIndicatorView(style: .gray)
                    newActivityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    newActivityIndicator.startAnimating()
                    newActivityIndicator.backgroundColor = UIColor.white
                    textField?.leftView?.addSubview(newActivityIndicator)
                    let leftViewSize = textField?.leftView?.frame.size ?? CGSize.zero
                    newActivityIndicator.center = CGPoint(x: leftViewSize.width/2, y: leftViewSize.height/2)
                }
            }
            else
            {
                activityIndicator?.removeFromSuperview()
            }
        }
    }
}
