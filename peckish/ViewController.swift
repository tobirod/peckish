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
import Kingfisher

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var databaseRef: DatabaseReference?
    var storageRef: StorageReference?
    
    var databaseHandle: DatabaseHandle?
    
    var idEdit: Bool
    
    var recipeCollection: [RecipeModel] = []

    override func viewDidLoad() {
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.tableFooterView = UIView()
        
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
                    
                    let recipeBuffer = RecipeModel(id: self.recipeCollection.count, key: dictionary["key"] as Any, categoryType: categoryTypeBuffer, name: dictionary["name"] as! String, text: dictionary["text"] as! String, imageURL: imagePathBuffer)
                    
                    self.recipeCollection.append(recipeBuffer)
                    self.tableView.reloadData()
                }
            }
        })
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? addNewRecipeSegue, let editRecipe = sender as? String {
            vc.result = result
        }
        
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let recipe = self.fetchRecipeForIndexPath(indexPath: indexPath)
        
        databaseRef?.child("recipe").child(recipe.key as! String).removeValue()
        
        let imageKey = recipe.key as! String
        let imageRef = Storage.storage().reference().child("recipe_images/" + imageKey)
        
        recipeCollection.remove(at: recipe.id)
        imageRef.delete(completion: nil)
        
        tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "addNewRecipeSegue", sender: self.fetchRecipeForIndexPath(indexPath: indexPath))
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
        let image = UIImage(named: "nopicadded")
        cell.imageView?.kf.setImage(with: recipe.imageURL, placeholder: image, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        
        return cell
    }
}

