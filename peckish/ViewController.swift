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

protocol UpdateRecipeDelegate{
    func removeRecipe(recipe: RecipeModel?)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var databaseRef: DatabaseReference?
    var storageRef: StorageReference?
    var databaseHandle: DatabaseHandle?
    
    var recipeCollection: [RecipeModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initiate Firebase references
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // Initiate and setup my tableView containing the recipes
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        // Function that runs every time a "child" is added to Firebase Database
        // Reads the data into a RecipeModel object and appends it to the recipeCollection array, and finally reloads the tableview to update its content
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
                    
                    let recipeBuffer = RecipeModel(id: self.recipeCollection.count, key: dictionary["key"] as! String, categoryType: categoryTypeBuffer, name: dictionary["name"] as! String, text: dictionary["text"] as! String, imageURL: imagePathBuffer)
                    
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
    
    // Runs every time a segue happens - the code inside is written to only run when editing a existing recipe
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? NewRecipeViewController, let recipe = sender as? RecipeModel {
            
            destinationVC.updateRecipeDelegate = self
            destinationVC.editRecipe = recipe
        }
    }
    
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "addNewRecipeSegue", sender: nil)
    }
    
    
    func fetchRecipeForIndexPath(indexPath: IndexPath) -> RecipeModel {
        let filteredRecipes = self.recipeCollection.filter {
            $0.categoryType.rawValue == indexPath.section
        }
        
        return filteredRecipes[indexPath.row]
    }

}

// Extension for protocol which handles removal from the recipeCollection array
extension ViewController: UpdateRecipeDelegate {
    
    func removeRecipe(recipe: RecipeModel?) {
        
        guard let recipe = recipe else {
            return
        }
        
        recipeCollection = recipeCollection.filter {
            $0.key != recipe.key
        }
        
        tableView.reloadData()
    }
    
}

// Extension for the tableview
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    // Enables slide to left on every table cell, showing the delete button
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Runs when delete button is pressed, deleting both the post in Firebase Database and the connected image in Firebase Storage
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let recipe = self.fetchRecipeForIndexPath(indexPath: indexPath)
        
        databaseRef?.child("recipe").child(recipe.key).removeValue()
        
        let imageKey = recipe.key
        let imageRef = Storage.storage().reference().child("recipe_images/" + imageKey)
        
        recipeCollection = recipeCollection.filter {
            $0.key != recipe.key
        }
        
        imageRef.delete(completion: nil)
        
        tableView.reloadData()
        
    }
    
    // Sets the number of maximum sections allowed
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    // Runs when a cell in the tableview pressed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recipe = self.fetchRecipeForIndexPath(indexPath: indexPath)
        
        self.performSegue(withIdentifier: "addNewRecipeSegue", sender: recipe)
        
    }
    
    // Sets the header for each section in the tableview
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let categoryType = CategoryType(rawValue: section) {
            return categoryType.description.capitalized
        }
        
        return "Unknown"
    }
    
    // Filters all the recipes into their corresponding sections
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeCollection.filter {
            $0.categoryType.rawValue == section
        }.count
    }
    
    // Setup of the cell, which is reused for every recipe
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let recipe = self.fetchRecipeForIndexPath(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = recipe.name
        
        let image = UIImage(named: "nopicadded")
        cell.imageView?.kf.setImage(with: recipe.imageURL, placeholder: image, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
        
        return cell
    }
}

