//
//  FoodTypeList.swift
//  QiMengfeiFinalProject
//
//  Created by Mengfei Qi on 2022/4/29.
//

import Foundation

struct FoodTypeList: Codable {
    private let type: String
    private var foodList = [Food]()
    
    func getType() -> String {
        return type
    }
    func getFoodList() -> [Food] {
        return foodList
    }
    
    init(type: String, foodlist: [Food]) {
        self.type = type
        self.foodList = foodlist
    }
    
    
}
