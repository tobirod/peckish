//
//  NewRecipeViewController.swift
//  peckish
//
//  Created by Tobias on 2017-09-14.
//  Copyright © 2017 Tobias Rödebäck. All rights reserved.
//

import UIKit

class NewRecipeViewController: UIViewController {

    @IBOutlet weak var recipeCategoryPickerView: UIPickerView!
    @IBOutlet weak var categoryTextField: UITextField!
    
    var selectedCategory: String?
    
    let recipeCategories = ["Breakfast", "Lunch", "Dinner", "Dessert", "Snack", "Drink"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCategoryPicker()
        createPickerViewToolBar()

        // Do any additional setup after loading the view.
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
        pickerViewToolBar.barTintColor = .white
        pickerViewToolBar.tintColor = .black
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(NewRecipeViewController.dismissKeyboard))
        
        pickerViewToolBar.setItems([doneButton], animated: false)
        pickerViewToolBar.isUserInteractionEnabled = true
        
        categoryTextField.inputAccessoryView = pickerViewToolBar
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
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
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "American TypeWriter", size: 17)
        
        label.text = recipeCategories[row]
        
        return label
        
    }
    
}
