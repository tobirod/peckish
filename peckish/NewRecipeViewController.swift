//
//  NewRecipeViewController.swift
//  peckish
//
//  Created by Tobias on 2017-09-14.
//  Copyright © 2017 Tobias Rödebäck. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class NewRecipeViewController: UIViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var recipeImageView: RoundImageView!
    @IBOutlet weak var recipeNameTextField: RoundTextField!
    @IBOutlet weak var recipeTextView: RoundTextView!
    @IBOutlet weak var saveRecipeButton: RoundButton!
    @IBOutlet weak var saveImageButton: RoundButton!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var updateRecipeDelegate: UpdateRecipeDelegate?
    
    var databaseRef: DatabaseReference?
    var storageRef: StorageReference?
    
    var selectedCategory: String = ""
    
    var editRecipe: RecipeModel?
    
    let recipeCategories = ["Breakfast", "Lunch", "Dinner", "Dessert", "Snack", "Drink"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Only runs when editing a recipe - sets the edited recipe's values to their corresponding view
        if editRecipe != nil{
            
            let category = editRecipe?.categoryType.description.capitalized
            
            categoryTextField.text = category!
            selectedCategory = category!
            
            let image = UIImage(named: "nopicadded")
            recipeImageView.kf.setImage(with: editRecipe?.imageURL, placeholder: image, options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            recipeImageView.alpha = 1
            
            recipeNameTextField.text = editRecipe?.name
            recipeTextView.text = editRecipe?.text
            
            saveImageButton.setTitle("Change image", for: .normal)
            
        }
        
        // Pretty selfexplanatory, creates the pickers used for choosing category
        createCategoryPicker()
        createPickerViewToolBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createCategoryPicker() {
        
        let categoryPicker = UIPickerView()
        categoryPicker.delegate = self
        
        categoryTextField.inputView = categoryPicker
        
        
        // Customization
        categoryPicker.backgroundColor = .white
    }
    
    func createPickerViewToolBar() {
        
        let pickerViewToolBar = UIToolbar()
        pickerViewToolBar.sizeToFit()
        
        // Customization
        pickerViewToolBar.barTintColor = UIColor.darkGray
        pickerViewToolBar.tintColor = .white
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NewRecipeViewController.dismissKeyboard))

        
        if let font = UIFont(name: "American Typewriter", size: 20.0) {
            let attributes = [NSAttributedStringKey.font: font]
            doneButton.setTitleTextAttributes(attributes, for: .normal)
        }
        
        pickerViewToolBar.setItems([doneButton], animated: false)
        pickerViewToolBar.isUserInteractionEnabled = true
        
        categoryTextField.inputAccessoryView = pickerViewToolBar
        
    }
    
    // Dismisses the software keyboard
    @objc func dismissKeyboard() {
        
        view.endEditing(true)
    }
    
    // Dismisses the popover viewcontroller and returns to the main viewcontroller
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    // Runs when button is pressed, starts the process of uploading new recipe to Firebase
    @IBAction func addRecipeButtonPressed(_ sender: Any) {
        
        uploadHandler()
        
    }
    
    // First starts the activityIndicator, showing the user the app is busy
    // Also deactivates all user interaction during upload
    func uploadHandler() {
        
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Runs if saving an edit - basically removes the old entry and saves everything again
        if editRecipe != nil {
            
            databaseRef!.child("recipe").child(editRecipe!.key).removeValue()
            
            let imageKey = editRecipe?.key
            let imageRef = storageRef?.child("recipe_images/" + imageKey!)
            
            imageRef?.delete(completion: {(error) in
                print(error?.localizedDescription as Any)
                
                self.updateRecipeDelegate?.removeRecipe(recipe: self.editRecipe)
            })
        }
        
        let categoryType = self.selectedCategory
        let name = self.recipeNameTextField.text
        let text = self.recipeTextView.text
        
        if let uploadData = UIImagePNGRepresentation(self.recipeImageView.image!) {
            
            let uploadKey = self.databaseRef?.child("recipe").childByAutoId().key as String?
            
            storageRef = Storage.storage().reference().child("recipe_images/" + uploadKey!)
            
            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/png"
            
            let uploadTask = storageRef?.putData(uploadData, metadata: uploadMetadata) { (metadata, error) in guard let metadata = metadata else {
                
                print("I received an error!")
                
                return
                }
                
                let imageURL = metadata.downloadURL()?.absoluteString
                
                // Upload recipe details as a NSDictionary
                
                if self.recipeNameTextField.text != "" {
                    
                    let recipeToDictionary: NSDictionary = [
                        
                        "key" : uploadKey!,
                        "categoryType" : categoryType,
                        "name" : name ?? "Unavailable",
                        "text" : text ?? "Unavailable",
                        "imageUrl" : imageURL ?? "https://firebasestorage.googleapis.com/v0/b/peckish-ee4ec.appspot.com/o/recipe_images%2Fnopicadded.png?alt=media&token=339254eb-cad3-4a53-8289-e18abcfddf4e"
                    ]
                    
                    self.databaseRef?.child("recipe").child(uploadKey!).setValue(recipeToDictionary)
                    
                }
                
            }
            
            // Tracks the upload progress and print it out in console
            uploadTask?.observe(.progress) { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                
                print(percentComplete, " percent complete")
                
            }
            
            // Checks upload for failure and reports it in console
            uploadTask?.observe(.failure) { snapshot in
                if let error = snapshot.error as NSError? {
                    switch (StorageErrorCode(rawValue: error.code)!) {
                    case .objectNotFound:
                        print("No image to upload!")
                    case .unauthorized:
                        print("Unauthorized access to image!")
                    case .cancelled:
                        print("You canceled the upload.")
                    case .unknown:
                        print("An unknown error has occured")
                        
                    default:
                        print("Something happened, and your upload didn't finish. Please try again!")
                    }
                }
            }
            
            // Basically a completion block for the upload
            uploadTask?.observe(.success) { snapshot in
                
                print("Image uploaded successfully!")
                
                self.activityIndicator.stopAnimating()
                
                UIApplication.shared.endIgnoringInteractionEvents()
                
                self.dismiss(animated: true)            }
        }
        
        
        
    }

}

// MARK: - PickerView Extension

extension NewRecipeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipeCategories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = recipeCategories[row]
        
        categoryTextField.text = selectedCategory
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        } else {
            label = UILabel()
        }
        
        categoryTextField.text = "Breakfast"
        selectedCategory = "Breakfast"
        
        
        // Customization
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "American Typewriter", size: 30)
        
        label.text = recipeCategories[row]
        
        return label
        
    }
    
}

// MARK: - Import Image Extension

extension NewRecipeViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBAction func importImageButton(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        image.allowsEditing = false
        
        self.present(image, animated: true) {
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            recipeImageView.image = image
            recipeImageView.alpha = 1
        } else {
            print("Something went wrong! Send help!")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
