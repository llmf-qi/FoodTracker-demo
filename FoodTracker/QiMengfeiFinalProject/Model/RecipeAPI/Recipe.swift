//
//  Recipe.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/5/1.
//

import Foundation

struct Recipe: Decodable {
    let title: String
    let readyInMinutes: Int
    let sourceUrl: String
    let image: String
    let missedIngredientCount: Int
    let usedIngredients: [Ingredient]
    let nutrition: nutrition
    
}
