//
//  RecipesCollectionViewController.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/5/1.
//

import UIKit
import Kingfisher

private let reuseIdentifier = "recipeCell"

class RecipesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private let recipeModel = RecipeModel.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        loadRecipes()

    }

    func loadRecipes() {
        recipeModel.getRecipes { recipes in
            DispatchQueue.main.async {
                
                if (self.recipeModel.sortBy == "min-missing-ingredients") { //the api cannot work well, so do it manually
                    self.recipeModel.recipes = recipes.sorted {
                        recipe_one, recipe_two in
                        return recipe_one.missedIngredientCount < recipe_two.missedIngredientCount
                    }
                } else {
                    self.recipeModel.recipes = recipes //store the recipes
                }
                self.collectionView.reloadData()
            }
            
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeModel.recipes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RecipeDetailCollectionViewCell //self-defined cell
        
        let currRecipe = recipeModel.recipes[indexPath.item]
        let imageLink = currRecipe.image
        
        // Configure the cell
        cell.recipeImageView.kf.setImage(with: URL(string: imageLink))
        cell.titleLabel.text = currRecipe.title
        cell.readyTimeLabel.text = "Ready in \(currRecipe.readyInMinutes) mins"
        cell.caloriesLabel.text = "Calories: \(currRecipe.nutrition.nutrients[0].amount)\(currRecipe.nutrition.nutrients[0].unit)"
        cell.missingNumLabel.text = "Missing \(currRecipe.missedIngredientCount) ingredient(s)"
        var usedString = "Used Ingredients: "
        for ingredient in currRecipe.usedIngredients {
            usedString = usedString + ingredient.name + ", "
        }
        usedString = String(usedString.dropLast(2))
        cell.usedIngredientLabel.text = usedString
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  //go to the selected recipe detail page
        if segue.identifier == "recipeDetailSegue" {
            let destination = segue.destination as! RecipeDetailViewController
            let iPath = collectionView.indexPathsForSelectedItems!.first!.row
            destination.selectedRecipe = recipeModel.recipes[iPath]
        }
    }


}
