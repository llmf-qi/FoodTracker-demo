//
//  AllFoodListProtocol.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/5/4.
//

import Foundation

protocol AllFoodListProtocol {
    func getAllFoodList() -> [FoodTypeList]
    func food(at index: Int, typeIndex: Int) -> Food? //food at selected path
    func insert(insertFood: Food)
    func remove(at index: Int, typeIndex: Int)
    func save(foodList: FoodTypeList)
    func checkIfSameExist(foodName: String, foodType: String) -> Bool
}
