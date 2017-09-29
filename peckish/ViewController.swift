//
//  ViewController.swift
//  peckish
//
//  Created by Tobias on 2017-09-13.
//  Copyright © 2017 Tobias Rödebäck. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var databaseRef: DatabaseReference?
    var storageRef: StorageReference?
    
    var databaseHandle: DatabaseHandle?
    
    var recipeCollection: [RecipeModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
        databaseRef = Database.database().reference()
        
        databaseHandle = databaseRef?.child("recipe").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                var categoryTypeBuffer: CategoryType = .unknown
                let imagePathBuffer: URL
                
                if let category = dictionary["categoryType"] as? String {
                    
                    switch category {
                    case "Breakfast": categoryTypeBuffer = .breakfast
                    case "Lunch": categoryTypeBuffer = .lunch
                    case "Dinner": categoryTypeBuffer = .dinner
                    case "Dessert": categoryTypeBuffer = .dessert
                    case "Drink": categoryTypeBuffer = .drinks
                    case "Snack": categoryTypeBuffer = .snack
                    default: categoryTypeBuffer = .unknown
                    }
                    
                }
                
                if let imagePath = dictionary["imageUrl"] as? String {
                    imagePathBuffer = URL(string: imagePath)!
                    
                    let recipeBuffer = RecipeModel(id: self.recipeCollection.count, categoryType: categoryTypeBuffer, name: dictionary["name"] as! String, text: dictionary["text"] as! String, imageURL: imagePathBuffer)
                    
                    self.recipeCollection.append(recipeBuffer)
                    self.tableView.reloadData()
                }
                
            }
            
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addNewRecipeSegue", sender: Any?.self)
    }
    
    func fetchRecipeForIndexPath(indexPath: IndexPath) -> RecipeModel {
        let filteredRecipes = self.recipeCollection.filter {
            $0.categoryType.rawValue == indexPath.section
        }
        
        return filteredRecipes[indexPath.row]
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue for edit
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let categoryType = CategoryType(rawValue: section) {
            return categoryType.description.capitalized
        }
        
        return "Unknown"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeCollection.filter {
            $0.categoryType.rawValue == section
        }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = self.fetchRecipeForIndexPath(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = recipe.name
        
        let recipeImageUrl = recipe.imageURL
        
        if let url = NSURL(string: recipeImageUrl) {
            
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                
                if error != nil {
                    print(error)
                    return
                }
                
                cell.imageView?.image = UIImage(data: data!)
            })
        }
        
        return cell
    }
}

