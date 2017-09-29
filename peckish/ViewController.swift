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
                
                let categoryTypeBuffer: CategoryType
                let categoryTypeBuffers = dictionary["categoryType"] as! String
                
                switch categoryTypeBuffers {
                    case "Breakfast": categoryTypeBuffer = .breakfast
                    case "Lunch": categoryTypeBuffer = .lunch
                    case "Dinner": categoryTypeBuffer = .dinner
                    case "Dessert": categoryTypeBuffer = .dessert
                    case "Drink": categoryTypeBuffer = .drinks
                    case "Snack": categoryTypeBuffer = .snack
                }

                
                let recipeBuffer = RecipeModel(id: self.recipeCollection.count, categoryType: dictionary["categoryType"] as! CategoryType, name: dictionary["name"] as! String, text: dictionary["text"] as! String)
                
                self.recipeCollection.append(recipeBuffer)
                print(self.recipeCollection.count)
                
            }
            
            
        })
        
            let recipe = RecipeModel(id: self.recipeCollection.count, categoryType: .breakfast, name: "Gröt", text: "1 dl havregryn, 2 dl vatten")
            let recipe2 = RecipeModel(id: self.recipeCollection.count, categoryType: .lunch, name: "Kycklingsallad", text: "1 dl havregryn, 2 dl vatten")
            let recipe3 = RecipeModel(id: self.recipeCollection.count, categoryType: .dinner, name: "Tacos", text: "1 dl havregryn, 2 dl vatten")
            let recipe4 = RecipeModel(id: self.recipeCollection.count, categoryType: .dessert, name: "Ostbågar", text: "1 dl havregryn, 2 dl vatten")
            let recipe5 = RecipeModel(id: self.recipeCollection.count, categoryType: .drinks, name: "Kiss", text: "1 dl havregryn, 2 dl vatten")
            let recipe6 = RecipeModel(id: self.recipeCollection.count, categoryType: .snack, name: "Chokladbollar", text: "1 dl havregryn, 2 dl vatten")
        let recipe7 = RecipeModel(id: self.recipeCollection.count, categoryType: .snack, name: "Chokladbollar", text: "1 dl havregryn, 2 dl vatten")

        
        self.recipeCollection.append(recipe)
        self.recipeCollection.append(recipe2)
        self.recipeCollection.append(recipe3)
        self.recipeCollection.append(recipe4)
        self.recipeCollection.append(recipe5)
        self.recipeCollection.append(recipe6)
        self.recipeCollection.append(recipe7)
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
        return 6
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
        
        return cell
    }
}

