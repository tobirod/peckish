//
//  RecipeModel.swift
//  peckish
//
//  Created by Tobias on 2017-09-16.
//  Copyright © 2017 Tobias Rödebäck. All rights reserved.
//

import UIKit

enum CategoryType: Int {
    case breakfast = 0
    case lunch
    case dinner
    case dessert
    case snack
    case drinks
    
    var description: String {
        switch self {
        case .breakfast: return "breakfast"
        case .lunch: return "lunch"
        case .dinner: return "dinner"
        case .dessert: return "dessert"
        case .snack: return "snack"
        case .drinks: return "drinks"
        }
    }
}

class RecipeModel {
    
    var id: Int
    var categoryType: CategoryType
    var name: String
    var text: String
    //var image: UIImage?
    
    init(id: Int, categoryType: CategoryType, name: String, text: String) {
        
        self.id = id
        self.categoryType = categoryType
        self.name = name
        self.text = text
        
    }
    
    
    
}
