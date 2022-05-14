//
//  RecipeModel.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/5/1.
//

import Foundation

class RecipeModel: NSObject {
    static let shared = RecipeModel()
    
    var BASE_URL = "https://api.spoonacular.com/recipes/complexSearch?apiKey=API_KEY"
    var usedURL = ""
    
    var recipes = [Recipe]()
    var result: apiResult?
    var ingredients = [String]()
    var foodListString = ""
    var sortBy = ""
    
    func setIngredient(ingredients: [String]) {
        self.ingredients = ingredients
    }
    
    func setSortBy(sortBy: String) {
        self.sortBy = sortBy
        if (self.sortBy == "missing ingredients") { //change it to api parameter
            self.sortBy = "min-missing-ingredients"
        }
        
    }
    
    func getFoodListString() {
        foodListString = ""
        for ingredient in ingredients {
            let newIngredient = ingredient.replacingOccurrences(of: " ", with: "_") //modify the input ingredients
            foodListString = foodListString + newIngredient + ","
        }
        if (!foodListString.isEmpty) {
            foodListString = String(foodListString.dropLast())
            usedURL = BASE_URL + "includeIngredients=" + foodListString + "&"
        } else {
            usedURL = BASE_URL
        }
    }
    
    func getRecipes(onSuccess: @escaping ([Recipe]) -> Void) { //get recipes from the api, including ingredients information, calories, recipe information, sort by the sorting way that the user chose, sort in ascending way
        getFoodListString()
        if let url = URL(string: "\(usedURL)&fillIngredients=true&minCalories=0&addRecipeInformation=true&sort=\(sortBy)&sortDirection=asc&number=20&ignorePantry=true") {
            let urlRequest = URLRequest(url: url)
            URLSession.shared.dataTask(with: urlRequest) {data, _, error in
                if let data = data {
                    do {
                        self.result = try JSONDecoder().decode(apiResult.self, from: data)
                        self.recipes = self.result!.results //decode the recipes and store
                        onSuccess(self.recipes)
                        
                    } catch let error {
                        print(error)
                        exit(1)
                    }
                }
            }.resume()
        }
    }
    
    
    
}
