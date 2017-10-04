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
    case unknown
    
    var description: String {
        switch self {
        case .breakfast: return "breakfast"
        case .lunch: return "lunch"
        case .dinner: return "dinner"
        case .dessert: return "dessert"
        case .snack: return "snack"
        case .drinks: return "drinks"
        case .unknown: return "unknown"
        }
    }
}

class RecipeModel {
    
    var id: Int
    var key: String
    var categoryType: CategoryType
    var name: String
    var text: String
    var imageURL: URL
    
    init(id: Int, key: String, categoryType: CategoryType, name: String, text: String, imageURL: URL) {
        
        self.id = id
        self.key = key
        self.categoryType = categoryType
        self.name = name
        self.text = text
        self.imageURL = imageURL
        
    }
    
    
    
}
